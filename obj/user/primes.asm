
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 b7 10 00 00       	call   801103 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 c0 26 80 00       	push   $0x8026c0
  800060:	e8 d6 01 00 00       	call   80023b <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 84 0e 00 00       	call   800eee <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 cc 26 80 00       	push   $0x8026cc
  800079:	6a 1a                	push   $0x1a
  80007b:	68 d5 26 80 00       	push   $0x8026d5
  800080:	e8 dd 00 00 00       	call   800162 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 6a 10 00 00       	call   801103 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 c0 10 00 00       	call   801170 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 2f 0e 00 00       	call   800eee <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 cc 26 80 00       	push   $0x8026cc
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 d5 26 80 00       	push   $0x8026d5
  8000d2:	e8 8b 00 00 00       	call   800162 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 80 10 00 00       	call   801170 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800103:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80010a:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 73 0a 00 00       	call   800b85 <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 db                	test   %ebx,%ebx
  800126:	7e 07                	jle    80012f <libmain+0x37>
		binaryname = argv[0];
  800128:	8b 06                	mov    (%esi),%eax
  80012a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
  800134:	e8 7c ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014e:	e8 75 12 00 00       	call   8013c8 <close_all>
	sys_env_destroy(0);
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	6a 00                	push   $0x0
  800158:	e8 e7 09 00 00       	call   800b44 <sys_env_destroy>
}
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800167:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800170:	e8 10 0a 00 00       	call   800b85 <sys_getenvid>
  800175:	83 ec 0c             	sub    $0xc,%esp
  800178:	ff 75 0c             	pushl  0xc(%ebp)
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	56                   	push   %esi
  80017f:	50                   	push   %eax
  800180:	68 f0 26 80 00       	push   $0x8026f0
  800185:	e8 b1 00 00 00       	call   80023b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018a:	83 c4 18             	add    $0x18,%esp
  80018d:	53                   	push   %ebx
  80018e:	ff 75 10             	pushl  0x10(%ebp)
  800191:	e8 54 00 00 00       	call   8001ea <vcprintf>
	cprintf("\n");
  800196:	c7 04 24 7a 2a 80 00 	movl   $0x802a7a,(%esp)
  80019d:	e8 99 00 00 00       	call   80023b <cprintf>
  8001a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a5:	cc                   	int3   
  8001a6:	eb fd                	jmp    8001a5 <_panic+0x43>

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 13                	mov    (%ebx),%edx
  8001b4:	8d 42 01             	lea    0x1(%edx),%eax
  8001b7:	89 03                	mov    %eax,(%ebx)
  8001b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c5:	75 1a                	jne    8001e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	68 ff 00 00 00       	push   $0xff
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	50                   	push   %eax
  8001d3:	e8 2f 09 00 00       	call   800b07 <sys_cputs>
		b->idx = 0;
  8001d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fa:	00 00 00 
	b.cnt = 0;
  8001fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800204:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800207:	ff 75 0c             	pushl  0xc(%ebp)
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800213:	50                   	push   %eax
  800214:	68 a8 01 80 00       	push   $0x8001a8
  800219:	e8 54 01 00 00       	call   800372 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021e:	83 c4 08             	add    $0x8,%esp
  800221:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800227:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022d:	50                   	push   %eax
  80022e:	e8 d4 08 00 00       	call   800b07 <sys_cputs>

	return b.cnt;
}
  800233:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800241:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800244:	50                   	push   %eax
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	e8 9d ff ff ff       	call   8001ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	57                   	push   %edi
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
  800255:	83 ec 1c             	sub    $0x1c,%esp
  800258:	89 c7                	mov    %eax,%edi
  80025a:	89 d6                	mov    %edx,%esi
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800262:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800265:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800268:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80026b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800270:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800273:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800276:	39 d3                	cmp    %edx,%ebx
  800278:	72 05                	jb     80027f <printnum+0x30>
  80027a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027d:	77 45                	ja     8002c4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027f:	83 ec 0c             	sub    $0xc,%esp
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	8b 45 14             	mov    0x14(%ebp),%eax
  800288:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80028b:	53                   	push   %ebx
  80028c:	ff 75 10             	pushl  0x10(%ebp)
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	ff 75 e4             	pushl  -0x1c(%ebp)
  800295:	ff 75 e0             	pushl  -0x20(%ebp)
  800298:	ff 75 dc             	pushl  -0x24(%ebp)
  80029b:	ff 75 d8             	pushl  -0x28(%ebp)
  80029e:	e8 7d 21 00 00       	call   802420 <__udivdi3>
  8002a3:	83 c4 18             	add    $0x18,%esp
  8002a6:	52                   	push   %edx
  8002a7:	50                   	push   %eax
  8002a8:	89 f2                	mov    %esi,%edx
  8002aa:	89 f8                	mov    %edi,%eax
  8002ac:	e8 9e ff ff ff       	call   80024f <printnum>
  8002b1:	83 c4 20             	add    $0x20,%esp
  8002b4:	eb 18                	jmp    8002ce <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	56                   	push   %esi
  8002ba:	ff 75 18             	pushl  0x18(%ebp)
  8002bd:	ff d7                	call   *%edi
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	eb 03                	jmp    8002c7 <printnum+0x78>
  8002c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c7:	83 eb 01             	sub    $0x1,%ebx
  8002ca:	85 db                	test   %ebx,%ebx
  8002cc:	7f e8                	jg     8002b6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ce:	83 ec 08             	sub    $0x8,%esp
  8002d1:	56                   	push   %esi
  8002d2:	83 ec 04             	sub    $0x4,%esp
  8002d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002db:	ff 75 dc             	pushl  -0x24(%ebp)
  8002de:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e1:	e8 6a 22 00 00       	call   802550 <__umoddi3>
  8002e6:	83 c4 14             	add    $0x14,%esp
  8002e9:	0f be 80 13 27 80 00 	movsbl 0x802713(%eax),%eax
  8002f0:	50                   	push   %eax
  8002f1:	ff d7                	call   *%edi
}
  8002f3:	83 c4 10             	add    $0x10,%esp
  8002f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f9:	5b                   	pop    %ebx
  8002fa:	5e                   	pop    %esi
  8002fb:	5f                   	pop    %edi
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800301:	83 fa 01             	cmp    $0x1,%edx
  800304:	7e 0e                	jle    800314 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	8b 52 04             	mov    0x4(%edx),%edx
  800312:	eb 22                	jmp    800336 <getuint+0x38>
	else if (lflag)
  800314:	85 d2                	test   %edx,%edx
  800316:	74 10                	je     800328 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
  800326:	eb 0e                	jmp    800336 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 02                	mov    (%edx),%eax
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800342:	8b 10                	mov    (%eax),%edx
  800344:	3b 50 04             	cmp    0x4(%eax),%edx
  800347:	73 0a                	jae    800353 <sprintputch+0x1b>
		*b->buf++ = ch;
  800349:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034c:	89 08                	mov    %ecx,(%eax)
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	88 02                	mov    %al,(%edx)
}
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80035b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035e:	50                   	push   %eax
  80035f:	ff 75 10             	pushl  0x10(%ebp)
  800362:	ff 75 0c             	pushl  0xc(%ebp)
  800365:	ff 75 08             	pushl  0x8(%ebp)
  800368:	e8 05 00 00 00       	call   800372 <vprintfmt>
	va_end(ap);
}
  80036d:	83 c4 10             	add    $0x10,%esp
  800370:	c9                   	leave  
  800371:	c3                   	ret    

00800372 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
  800378:	83 ec 2c             	sub    $0x2c,%esp
  80037b:	8b 75 08             	mov    0x8(%ebp),%esi
  80037e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800381:	8b 7d 10             	mov    0x10(%ebp),%edi
  800384:	eb 12                	jmp    800398 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800386:	85 c0                	test   %eax,%eax
  800388:	0f 84 89 03 00 00    	je     800717 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	53                   	push   %ebx
  800392:	50                   	push   %eax
  800393:	ff d6                	call   *%esi
  800395:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800398:	83 c7 01             	add    $0x1,%edi
  80039b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039f:	83 f8 25             	cmp    $0x25,%eax
  8003a2:	75 e2                	jne    800386 <vprintfmt+0x14>
  8003a4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c2:	eb 07                	jmp    8003cb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8d 47 01             	lea    0x1(%edi),%eax
  8003ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d1:	0f b6 07             	movzbl (%edi),%eax
  8003d4:	0f b6 c8             	movzbl %al,%ecx
  8003d7:	83 e8 23             	sub    $0x23,%eax
  8003da:	3c 55                	cmp    $0x55,%al
  8003dc:	0f 87 1a 03 00 00    	ja     8006fc <vprintfmt+0x38a>
  8003e2:	0f b6 c0             	movzbl %al,%eax
  8003e5:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ef:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f3:	eb d6                	jmp    8003cb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800400:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800403:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800407:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80040a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040d:	83 fa 09             	cmp    $0x9,%edx
  800410:	77 39                	ja     80044b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800412:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800415:	eb e9                	jmp    800400 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 48 04             	lea    0x4(%eax),%ecx
  80041d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800428:	eb 27                	jmp    800451 <vprintfmt+0xdf>
  80042a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800434:	0f 49 c8             	cmovns %eax,%ecx
  800437:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043d:	eb 8c                	jmp    8003cb <vprintfmt+0x59>
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800442:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800449:	eb 80                	jmp    8003cb <vprintfmt+0x59>
  80044b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800451:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800455:	0f 89 70 ff ff ff    	jns    8003cb <vprintfmt+0x59>
				width = precision, precision = -1;
  80045b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800468:	e9 5e ff ff ff       	jmp    8003cb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800473:	e9 53 ff ff ff       	jmp    8003cb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	53                   	push   %ebx
  800485:	ff 30                	pushl  (%eax)
  800487:	ff d6                	call   *%esi
			break;
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048f:	e9 04 ff ff ff       	jmp    800398 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	99                   	cltd   
  8004a0:	31 d0                	xor    %edx,%eax
  8004a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a4:	83 f8 0f             	cmp    $0xf,%eax
  8004a7:	7f 0b                	jg     8004b4 <vprintfmt+0x142>
  8004a9:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	75 18                	jne    8004cc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004b4:	50                   	push   %eax
  8004b5:	68 2b 27 80 00       	push   $0x80272b
  8004ba:	53                   	push   %ebx
  8004bb:	56                   	push   %esi
  8004bc:	e8 94 fe ff ff       	call   800355 <printfmt>
  8004c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c7:	e9 cc fe ff ff       	jmp    800398 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004cc:	52                   	push   %edx
  8004cd:	68 71 2c 80 00       	push   $0x802c71
  8004d2:	53                   	push   %ebx
  8004d3:	56                   	push   %esi
  8004d4:	e8 7c fe ff ff       	call   800355 <printfmt>
  8004d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	e9 b4 fe ff ff       	jmp    800398 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ed:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ef:	85 ff                	test   %edi,%edi
  8004f1:	b8 24 27 80 00       	mov    $0x802724,%eax
  8004f6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fd:	0f 8e 94 00 00 00    	jle    800597 <vprintfmt+0x225>
  800503:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800507:	0f 84 98 00 00 00    	je     8005a5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 d0             	pushl  -0x30(%ebp)
  800513:	57                   	push   %edi
  800514:	e8 86 02 00 00       	call   80079f <strnlen>
  800519:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051c:	29 c1                	sub    %eax,%ecx
  80051e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800521:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800524:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800528:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800530:	eb 0f                	jmp    800541 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	ff 75 e0             	pushl  -0x20(%ebp)
  800539:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	83 ef 01             	sub    $0x1,%edi
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 ff                	test   %edi,%edi
  800543:	7f ed                	jg     800532 <vprintfmt+0x1c0>
  800545:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800548:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	b8 00 00 00 00       	mov    $0x0,%eax
  800552:	0f 49 c1             	cmovns %ecx,%eax
  800555:	29 c1                	sub    %eax,%ecx
  800557:	89 75 08             	mov    %esi,0x8(%ebp)
  80055a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800560:	89 cb                	mov    %ecx,%ebx
  800562:	eb 4d                	jmp    8005b1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800564:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800568:	74 1b                	je     800585 <vprintfmt+0x213>
  80056a:	0f be c0             	movsbl %al,%eax
  80056d:	83 e8 20             	sub    $0x20,%eax
  800570:	83 f8 5e             	cmp    $0x5e,%eax
  800573:	76 10                	jbe    800585 <vprintfmt+0x213>
					putch('?', putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	ff 75 0c             	pushl  0xc(%ebp)
  80057b:	6a 3f                	push   $0x3f
  80057d:	ff 55 08             	call   *0x8(%ebp)
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	eb 0d                	jmp    800592 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	ff 75 0c             	pushl  0xc(%ebp)
  80058b:	52                   	push   %edx
  80058c:	ff 55 08             	call   *0x8(%ebp)
  80058f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800592:	83 eb 01             	sub    $0x1,%ebx
  800595:	eb 1a                	jmp    8005b1 <vprintfmt+0x23f>
  800597:	89 75 08             	mov    %esi,0x8(%ebp)
  80059a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a3:	eb 0c                	jmp    8005b1 <vprintfmt+0x23f>
  8005a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b1:	83 c7 01             	add    $0x1,%edi
  8005b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b8:	0f be d0             	movsbl %al,%edx
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 23                	je     8005e2 <vprintfmt+0x270>
  8005bf:	85 f6                	test   %esi,%esi
  8005c1:	78 a1                	js     800564 <vprintfmt+0x1f2>
  8005c3:	83 ee 01             	sub    $0x1,%esi
  8005c6:	79 9c                	jns    800564 <vprintfmt+0x1f2>
  8005c8:	89 df                	mov    %ebx,%edi
  8005ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d0:	eb 18                	jmp    8005ea <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 20                	push   $0x20
  8005d8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005da:	83 ef 01             	sub    $0x1,%edi
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	eb 08                	jmp    8005ea <vprintfmt+0x278>
  8005e2:	89 df                	mov    %ebx,%edi
  8005e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ea:	85 ff                	test   %edi,%edi
  8005ec:	7f e4                	jg     8005d2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f1:	e9 a2 fd ff ff       	jmp    800398 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f6:	83 fa 01             	cmp    $0x1,%edx
  8005f9:	7e 16                	jle    800611 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 08             	lea    0x8(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 50 04             	mov    0x4(%eax),%edx
  800607:	8b 00                	mov    (%eax),%eax
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060f:	eb 32                	jmp    800643 <vprintfmt+0x2d1>
	else if (lflag)
  800611:	85 d2                	test   %edx,%edx
  800613:	74 18                	je     80062d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 04             	lea    0x4(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	89 c1                	mov    %eax,%ecx
  800625:	c1 f9 1f             	sar    $0x1f,%ecx
  800628:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80062b:	eb 16                	jmp    800643 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 04             	lea    0x4(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 00                	mov    (%eax),%eax
  800638:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063b:	89 c1                	mov    %eax,%ecx
  80063d:	c1 f9 1f             	sar    $0x1f,%ecx
  800640:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800643:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800646:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800649:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800652:	79 74                	jns    8006c8 <vprintfmt+0x356>
				putch('-', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 2d                	push   $0x2d
  80065a:	ff d6                	call   *%esi
				num = -(long long) num;
  80065c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800662:	f7 d8                	neg    %eax
  800664:	83 d2 00             	adc    $0x0,%edx
  800667:	f7 da                	neg    %edx
  800669:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800671:	eb 55                	jmp    8006c8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 83 fc ff ff       	call   8002fe <getuint>
			base = 10;
  80067b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800680:	eb 46                	jmp    8006c8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 74 fc ff ff       	call   8002fe <getuint>
		        base = 8;
  80068a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80068f:	eb 37                	jmp    8006c8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 30                	push   $0x30
  800697:	ff d6                	call   *%esi
			putch('x', putdat);
  800699:	83 c4 08             	add    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	6a 78                	push   $0x78
  80069f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 04             	lea    0x4(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 3b fc ff ff       	call   8002fe <getuint>
			base = 16;
  8006c3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cf:	57                   	push   %edi
  8006d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d3:	51                   	push   %ecx
  8006d4:	52                   	push   %edx
  8006d5:	50                   	push   %eax
  8006d6:	89 da                	mov    %ebx,%edx
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	e8 70 fb ff ff       	call   80024f <printnum>
			break;
  8006df:	83 c4 20             	add    $0x20,%esp
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e5:	e9 ae fc ff ff       	jmp    800398 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	51                   	push   %ecx
  8006ef:	ff d6                	call   *%esi
			break;
  8006f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f7:	e9 9c fc ff ff       	jmp    800398 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	6a 25                	push   $0x25
  800702:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 03                	jmp    80070c <vprintfmt+0x39a>
  800709:	83 ef 01             	sub    $0x1,%edi
  80070c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800710:	75 f7                	jne    800709 <vprintfmt+0x397>
  800712:	e9 81 fc ff ff       	jmp    800398 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800717:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	5f                   	pop    %edi
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 18             	sub    $0x18,%esp
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800732:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 26                	je     800766 <vsnprintf+0x47>
  800740:	85 d2                	test   %edx,%edx
  800742:	7e 22                	jle    800766 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800744:	ff 75 14             	pushl  0x14(%ebp)
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	68 38 03 80 00       	push   $0x800338
  800753:	e8 1a fc ff ff       	call   800372 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	eb 05                	jmp    80076b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	50                   	push   %eax
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	ff 75 0c             	pushl  0xc(%ebp)
  80077d:	ff 75 08             	pushl  0x8(%ebp)
  800780:	e8 9a ff ff ff       	call   80071f <vsnprintf>
	va_end(ap);

	return rc;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 03                	jmp    800797 <strlen+0x10>
		n++;
  800794:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800797:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079b:	75 f7                	jne    800794 <strlen+0xd>
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ad:	eb 03                	jmp    8007b2 <strnlen+0x13>
		n++;
  8007af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b2:	39 c2                	cmp    %eax,%edx
  8007b4:	74 08                	je     8007be <strnlen+0x1f>
  8007b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ba:	75 f3                	jne    8007af <strnlen+0x10>
  8007bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	83 c1 01             	add    $0x1,%ecx
  8007d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d9:	84 db                	test   %bl,%bl
  8007db:	75 ef                	jne    8007cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e7:	53                   	push   %ebx
  8007e8:	e8 9a ff ff ff       	call   800787 <strlen>
  8007ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	01 d8                	add    %ebx,%eax
  8007f5:	50                   	push   %eax
  8007f6:	e8 c5 ff ff ff       	call   8007c0 <strcpy>
	return dst;
}
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	89 f3                	mov    %esi,%ebx
  80080f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800812:	89 f2                	mov    %esi,%edx
  800814:	eb 0f                	jmp    800825 <strncpy+0x23>
		*dst++ = *src;
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	0f b6 01             	movzbl (%ecx),%eax
  80081c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081f:	80 39 01             	cmpb   $0x1,(%ecx)
  800822:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	39 da                	cmp    %ebx,%edx
  800827:	75 ed                	jne    800816 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800829:	89 f0                	mov    %esi,%eax
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083a:	8b 55 10             	mov    0x10(%ebp),%edx
  80083d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083f:	85 d2                	test   %edx,%edx
  800841:	74 21                	je     800864 <strlcpy+0x35>
  800843:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800847:	89 f2                	mov    %esi,%edx
  800849:	eb 09                	jmp    800854 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800854:	39 c2                	cmp    %eax,%edx
  800856:	74 09                	je     800861 <strlcpy+0x32>
  800858:	0f b6 19             	movzbl (%ecx),%ebx
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ec                	jne    80084b <strlcpy+0x1c>
  80085f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800861:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800864:	29 f0                	sub    %esi,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800873:	eb 06                	jmp    80087b <strcmp+0x11>
		p++, q++;
  800875:	83 c1 01             	add    $0x1,%ecx
  800878:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087b:	0f b6 01             	movzbl (%ecx),%eax
  80087e:	84 c0                	test   %al,%al
  800880:	74 04                	je     800886 <strcmp+0x1c>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	74 ef                	je     800875 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 c0             	movzbl %al,%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	89 c3                	mov    %eax,%ebx
  80089c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089f:	eb 06                	jmp    8008a7 <strncmp+0x17>
		n--, p++, q++;
  8008a1:	83 c0 01             	add    $0x1,%eax
  8008a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a7:	39 d8                	cmp    %ebx,%eax
  8008a9:	74 15                	je     8008c0 <strncmp+0x30>
  8008ab:	0f b6 08             	movzbl (%eax),%ecx
  8008ae:	84 c9                	test   %cl,%cl
  8008b0:	74 04                	je     8008b6 <strncmp+0x26>
  8008b2:	3a 0a                	cmp    (%edx),%cl
  8008b4:	74 eb                	je     8008a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 00             	movzbl (%eax),%eax
  8008b9:	0f b6 12             	movzbl (%edx),%edx
  8008bc:	29 d0                	sub    %edx,%eax
  8008be:	eb 05                	jmp    8008c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	eb 07                	jmp    8008db <strchr+0x13>
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 0f                	je     8008e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d8:	83 c0 01             	add    $0x1,%eax
  8008db:	0f b6 10             	movzbl (%eax),%edx
  8008de:	84 d2                	test   %dl,%dl
  8008e0:	75 f2                	jne    8008d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f3:	eb 03                	jmp    8008f8 <strfind+0xf>
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fb:	38 ca                	cmp    %cl,%dl
  8008fd:	74 04                	je     800903 <strfind+0x1a>
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f2                	jne    8008f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800911:	85 c9                	test   %ecx,%ecx
  800913:	74 36                	je     80094b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800915:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091b:	75 28                	jne    800945 <memset+0x40>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 23                	jne    800945 <memset+0x40>
		c &= 0xFF;
  800922:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800926:	89 d3                	mov    %edx,%ebx
  800928:	c1 e3 08             	shl    $0x8,%ebx
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	c1 e6 18             	shl    $0x18,%esi
  800930:	89 d0                	mov    %edx,%eax
  800932:	c1 e0 10             	shl    $0x10,%eax
  800935:	09 f0                	or     %esi,%eax
  800937:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800939:	89 d8                	mov    %ebx,%eax
  80093b:	09 d0                	or     %edx,%eax
  80093d:	c1 e9 02             	shr    $0x2,%ecx
  800940:	fc                   	cld    
  800941:	f3 ab                	rep stos %eax,%es:(%edi)
  800943:	eb 06                	jmp    80094b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800945:	8b 45 0c             	mov    0xc(%ebp),%eax
  800948:	fc                   	cld    
  800949:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094b:	89 f8                	mov    %edi,%eax
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5f                   	pop    %edi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800960:	39 c6                	cmp    %eax,%esi
  800962:	73 35                	jae    800999 <memmove+0x47>
  800964:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800967:	39 d0                	cmp    %edx,%eax
  800969:	73 2e                	jae    800999 <memmove+0x47>
		s += n;
		d += n;
  80096b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	89 d6                	mov    %edx,%esi
  800970:	09 fe                	or     %edi,%esi
  800972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800978:	75 13                	jne    80098d <memmove+0x3b>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0e                	jne    80098d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097f:	83 ef 04             	sub    $0x4,%edi
  800982:	8d 72 fc             	lea    -0x4(%edx),%esi
  800985:	c1 e9 02             	shr    $0x2,%ecx
  800988:	fd                   	std    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 09                	jmp    800996 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098d:	83 ef 01             	sub    $0x1,%edi
  800990:	8d 72 ff             	lea    -0x1(%edx),%esi
  800993:	fd                   	std    
  800994:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800996:	fc                   	cld    
  800997:	eb 1d                	jmp    8009b6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	89 f2                	mov    %esi,%edx
  80099b:	09 c2                	or     %eax,%edx
  80099d:	f6 c2 03             	test   $0x3,%dl
  8009a0:	75 0f                	jne    8009b1 <memmove+0x5f>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 0a                	jne    8009b1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 05                	jmp    8009b6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bd:	ff 75 10             	pushl  0x10(%ebp)
  8009c0:	ff 75 0c             	pushl  0xc(%ebp)
  8009c3:	ff 75 08             	pushl  0x8(%ebp)
  8009c6:	e8 87 ff ff ff       	call   800952 <memmove>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d8:	89 c6                	mov    %eax,%esi
  8009da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dd:	eb 1a                	jmp    8009f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009df:	0f b6 08             	movzbl (%eax),%ecx
  8009e2:	0f b6 1a             	movzbl (%edx),%ebx
  8009e5:	38 d9                	cmp    %bl,%cl
  8009e7:	74 0a                	je     8009f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e9:	0f b6 c1             	movzbl %cl,%eax
  8009ec:	0f b6 db             	movzbl %bl,%ebx
  8009ef:	29 d8                	sub    %ebx,%eax
  8009f1:	eb 0f                	jmp    800a02 <memcmp+0x35>
		s1++, s2++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 f0                	cmp    %esi,%eax
  8009fb:	75 e2                	jne    8009df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0d:	89 c1                	mov    %eax,%ecx
  800a0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a16:	eb 0a                	jmp    800a22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a18:	0f b6 10             	movzbl (%eax),%edx
  800a1b:	39 da                	cmp    %ebx,%edx
  800a1d:	74 07                	je     800a26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	39 c8                	cmp    %ecx,%eax
  800a24:	72 f2                	jb     800a18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 03                	jmp    800a3a <strtol+0x11>
		s++;
  800a37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f6                	je     800a37 <strtol+0xe>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f2                	je     800a37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	75 0a                	jne    800a53 <strtol+0x2a>
		s++;
  800a49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a51:	eb 11                	jmp    800a64 <strtol+0x3b>
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a58:	3c 2d                	cmp    $0x2d,%al
  800a5a:	75 08                	jne    800a64 <strtol+0x3b>
		s++, neg = 1;
  800a5c:	83 c1 01             	add    $0x1,%ecx
  800a5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6a:	75 15                	jne    800a81 <strtol+0x58>
  800a6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6f:	75 10                	jne    800a81 <strtol+0x58>
  800a71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a75:	75 7c                	jne    800af3 <strtol+0xca>
		s += 2, base = 16;
  800a77:	83 c1 02             	add    $0x2,%ecx
  800a7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7f:	eb 16                	jmp    800a97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	75 12                	jne    800a97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8d:	75 08                	jne    800a97 <strtol+0x6e>
		s++, base = 8;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9f:	0f b6 11             	movzbl (%ecx),%edx
  800aa2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 09             	cmp    $0x9,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0x8b>
			dig = *s - '0';
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 30             	sub    $0x30,%edx
  800ab2:	eb 22                	jmp    800ad6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 08                	ja     800ac6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 57             	sub    $0x57,%edx
  800ac4:	eb 10                	jmp    800ad6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 16                	ja     800ae6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad0:	0f be d2             	movsbl %dl,%edx
  800ad3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad9:	7d 0b                	jge    800ae6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800adb:	83 c1 01             	add    $0x1,%ecx
  800ade:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae4:	eb b9                	jmp    800a9f <strtol+0x76>

	if (endptr)
  800ae6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aea:	74 0d                	je     800af9 <strtol+0xd0>
		*endptr = (char *) s;
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	89 0e                	mov    %ecx,(%esi)
  800af1:	eb 06                	jmp    800af9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af3:	85 db                	test   %ebx,%ebx
  800af5:	74 98                	je     800a8f <strtol+0x66>
  800af7:	eb 9e                	jmp    800a97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af9:	89 c2                	mov    %eax,%edx
  800afb:	f7 da                	neg    %edx
  800afd:	85 ff                	test   %edi,%edi
  800aff:	0f 45 c2             	cmovne %edx,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	89 c6                	mov    %eax,%esi
  800b1e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 01 00 00 00       	mov    $0x1,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	b8 03 00 00 00       	mov    $0x3,%eax
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	89 cb                	mov    %ecx,%ebx
  800b5c:	89 cf                	mov    %ecx,%edi
  800b5e:	89 ce                	mov    %ecx,%esi
  800b60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7e 17                	jle    800b7d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	50                   	push   %eax
  800b6a:	6a 03                	push   $0x3
  800b6c:	68 1f 2a 80 00       	push   $0x802a1f
  800b71:	6a 23                	push   $0x23
  800b73:	68 3c 2a 80 00       	push   $0x802a3c
  800b78:	e8 e5 f5 ff ff       	call   800162 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 02 00 00 00       	mov    $0x2,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_yield>:

void
sys_yield(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bcc:	be 00 00 00 00       	mov    $0x0,%esi
  800bd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdf:	89 f7                	mov    %esi,%edi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 04                	push   $0x4
  800bed:	68 1f 2a 80 00       	push   $0x802a1f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 3c 2a 80 00       	push   $0x802a3c
  800bf9:	e8 64 f5 ff ff       	call   800162 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c20:	8b 75 18             	mov    0x18(%ebp),%esi
  800c23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 05                	push   $0x5
  800c2f:	68 1f 2a 80 00       	push   $0x802a1f
  800c34:	6a 23                	push   $0x23
  800c36:	68 3c 2a 80 00       	push   $0x802a3c
  800c3b:	e8 22 f5 ff ff       	call   800162 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 06                	push   $0x6
  800c71:	68 1f 2a 80 00       	push   $0x802a1f
  800c76:	6a 23                	push   $0x23
  800c78:	68 3c 2a 80 00       	push   $0x802a3c
  800c7d:	e8 e0 f4 ff ff       	call   800162 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 08                	push   $0x8
  800cb3:	68 1f 2a 80 00       	push   $0x802a1f
  800cb8:	6a 23                	push   $0x23
  800cba:	68 3c 2a 80 00       	push   $0x802a3c
  800cbf:	e8 9e f4 ff ff       	call   800162 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 09                	push   $0x9
  800cf5:	68 1f 2a 80 00       	push   $0x802a1f
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 3c 2a 80 00       	push   $0x802a3c
  800d01:	e8 5c f4 ff ff       	call   800162 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 17                	jle    800d48 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 0a                	push   $0xa
  800d37:	68 1f 2a 80 00       	push   $0x802a1f
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 3c 2a 80 00       	push   $0x802a3c
  800d43:	e8 1a f4 ff ff       	call   800162 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	be 00 00 00 00       	mov    $0x0,%esi
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 0d                	push   $0xd
  800d9b:	68 1f 2a 80 00       	push   $0x802a1f
  800da0:	6a 23                	push   $0x23
  800da2:	68 3c 2a 80 00       	push   $0x802a3c
  800da7:	e8 b6 f3 ff ff       	call   800162 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc4:	89 d1                	mov    %edx,%ecx
  800dc6:	89 d3                	mov    %edx,%ebx
  800dc8:	89 d7                	mov    %edx,%edi
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	53                   	push   %ebx
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800dfe:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e00:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e04:	74 2e                	je     800e34 <pgfault+0x40>
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	c1 ea 16             	shr    $0x16,%edx
  800e0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e12:	f6 c2 01             	test   $0x1,%dl
  800e15:	74 1d                	je     800e34 <pgfault+0x40>
  800e17:	89 c2                	mov    %eax,%edx
  800e19:	c1 ea 0c             	shr    $0xc,%edx
  800e1c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e23:	f6 c1 01             	test   $0x1,%cl
  800e26:	74 0c                	je     800e34 <pgfault+0x40>
  800e28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2f:	f6 c6 08             	test   $0x8,%dh
  800e32:	75 14                	jne    800e48 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800e34:	83 ec 04             	sub    $0x4,%esp
  800e37:	68 4a 2a 80 00       	push   $0x802a4a
  800e3c:	6a 1d                	push   $0x1d
  800e3e:	68 5d 2a 80 00       	push   $0x802a5d
  800e43:	e8 1a f3 ff ff       	call   800162 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800e48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4d:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	6a 07                	push   $0x7
  800e54:	68 00 f0 7f 00       	push   $0x7ff000
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 63 fd ff ff       	call   800bc3 <sys_page_alloc>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	79 14                	jns    800e7b <pgfault+0x87>
		panic("page alloc failed \n");
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	68 68 2a 80 00       	push   $0x802a68
  800e6f:	6a 28                	push   $0x28
  800e71:	68 5d 2a 80 00       	push   $0x802a5d
  800e76:	e8 e7 f2 ff ff       	call   800162 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800e7b:	83 ec 04             	sub    $0x4,%esp
  800e7e:	68 00 10 00 00       	push   $0x1000
  800e83:	53                   	push   %ebx
  800e84:	68 00 f0 7f 00       	push   $0x7ff000
  800e89:	e8 2c fb ff ff       	call   8009ba <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800e8e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e95:	53                   	push   %ebx
  800e96:	6a 00                	push   $0x0
  800e98:	68 00 f0 7f 00       	push   $0x7ff000
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 62 fd ff ff       	call   800c06 <sys_page_map>
  800ea4:	83 c4 20             	add    $0x20,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	79 14                	jns    800ebf <pgfault+0xcb>
        panic("page map failed \n");
  800eab:	83 ec 04             	sub    $0x4,%esp
  800eae:	68 7c 2a 80 00       	push   $0x802a7c
  800eb3:	6a 2b                	push   $0x2b
  800eb5:	68 5d 2a 80 00       	push   $0x802a5d
  800eba:	e8 a3 f2 ff ff       	call   800162 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	68 00 f0 7f 00       	push   $0x7ff000
  800ec7:	6a 00                	push   $0x0
  800ec9:	e8 7a fd ff ff       	call   800c48 <sys_page_unmap>
  800ece:	83 c4 10             	add    $0x10,%esp
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	79 14                	jns    800ee9 <pgfault+0xf5>
        panic("page unmap failed\n");
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	68 8e 2a 80 00       	push   $0x802a8e
  800edd:	6a 2d                	push   $0x2d
  800edf:	68 5d 2a 80 00       	push   $0x802a5d
  800ee4:	e8 79 f2 ff ff       	call   800162 <_panic>
	
	//panic("pgfault not implemented");
}
  800ee9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800ef7:	68 f4 0d 80 00       	push   $0x800df4
  800efc:	e8 51 14 00 00       	call   802352 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f01:	b8 07 00 00 00       	mov    $0x7,%eax
  800f06:	cd 30                	int    $0x30
  800f08:	89 c7                	mov    %eax,%edi
  800f0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 12                	jns    800f26 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800f14:	50                   	push   %eax
  800f15:	68 a1 2a 80 00       	push   $0x802aa1
  800f1a:	6a 7a                	push   $0x7a
  800f1c:	68 5d 2a 80 00       	push   $0x802a5d
  800f21:	e8 3c f2 ff ff       	call   800162 <_panic>
  800f26:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	75 21                	jne    800f50 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2f:	e8 51 fc ff ff       	call   800b85 <sys_getenvid>
  800f34:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f41:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4b:	e9 91 01 00 00       	jmp    8010e1 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  800f50:	89 d8                	mov    %ebx,%eax
  800f52:	c1 e8 16             	shr    $0x16,%eax
  800f55:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5c:	a8 01                	test   $0x1,%al
  800f5e:	0f 84 06 01 00 00    	je     80106a <fork+0x17c>
  800f64:	89 d8                	mov    %ebx,%eax
  800f66:	c1 e8 0c             	shr    $0xc,%eax
  800f69:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f70:	f6 c2 01             	test   $0x1,%dl
  800f73:	0f 84 f1 00 00 00    	je     80106a <fork+0x17c>
  800f79:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f80:	f6 c2 04             	test   $0x4,%dl
  800f83:	0f 84 e1 00 00 00    	je     80106a <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  800f89:	89 c6                	mov    %eax,%esi
  800f8b:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  800f8e:	89 f2                	mov    %esi,%edx
  800f90:	c1 ea 16             	shr    $0x16,%edx
  800f93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  800f9a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  800fa1:	f6 c6 04             	test   $0x4,%dh
  800fa4:	74 39                	je     800fdf <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  800fa6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb5:	50                   	push   %eax
  800fb6:	56                   	push   %esi
  800fb7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fba:	56                   	push   %esi
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 44 fc ff ff       	call   800c06 <sys_page_map>
  800fc2:	83 c4 20             	add    $0x20,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	0f 89 9d 00 00 00    	jns    80106a <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  800fcd:	50                   	push   %eax
  800fce:	68 f8 2a 80 00       	push   $0x802af8
  800fd3:	6a 4b                	push   $0x4b
  800fd5:	68 5d 2a 80 00       	push   $0x802a5d
  800fda:	e8 83 f1 ff ff       	call   800162 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  800fdf:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800fe5:	74 59                	je     801040 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	68 05 08 00 00       	push   $0x805
  800fef:	56                   	push   %esi
  800ff0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff3:	56                   	push   %esi
  800ff4:	6a 00                	push   $0x0
  800ff6:	e8 0b fc ff ff       	call   800c06 <sys_page_map>
  800ffb:	83 c4 20             	add    $0x20,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	79 12                	jns    801014 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  801002:	50                   	push   %eax
  801003:	68 28 2b 80 00       	push   $0x802b28
  801008:	6a 50                	push   $0x50
  80100a:	68 5d 2a 80 00       	push   $0x802a5d
  80100f:	e8 4e f1 ff ff       	call   800162 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	68 05 08 00 00       	push   $0x805
  80101c:	56                   	push   %esi
  80101d:	6a 00                	push   $0x0
  80101f:	56                   	push   %esi
  801020:	6a 00                	push   $0x0
  801022:	e8 df fb ff ff       	call   800c06 <sys_page_map>
  801027:	83 c4 20             	add    $0x20,%esp
  80102a:	85 c0                	test   %eax,%eax
  80102c:	79 3c                	jns    80106a <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  80102e:	50                   	push   %eax
  80102f:	68 50 2b 80 00       	push   $0x802b50
  801034:	6a 53                	push   $0x53
  801036:	68 5d 2a 80 00       	push   $0x802a5d
  80103b:	e8 22 f1 ff ff       	call   800162 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	6a 05                	push   $0x5
  801045:	56                   	push   %esi
  801046:	ff 75 e4             	pushl  -0x1c(%ebp)
  801049:	56                   	push   %esi
  80104a:	6a 00                	push   $0x0
  80104c:	e8 b5 fb ff ff       	call   800c06 <sys_page_map>
  801051:	83 c4 20             	add    $0x20,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	79 12                	jns    80106a <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  801058:	50                   	push   %eax
  801059:	68 78 2b 80 00       	push   $0x802b78
  80105e:	6a 58                	push   $0x58
  801060:	68 5d 2a 80 00       	push   $0x802a5d
  801065:	e8 f8 f0 ff ff       	call   800162 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  80106a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801070:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801076:	0f 85 d4 fe ff ff    	jne    800f50 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  80107c:	83 ec 04             	sub    $0x4,%esp
  80107f:	6a 07                	push   $0x7
  801081:	68 00 f0 bf ee       	push   $0xeebff000
  801086:	57                   	push   %edi
  801087:	e8 37 fb ff ff       	call   800bc3 <sys_page_alloc>
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 17                	jns    8010aa <fork+0x1bc>
        panic("page alloc failed\n");
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	68 b3 2a 80 00       	push   $0x802ab3
  80109b:	68 87 00 00 00       	push   $0x87
  8010a0:	68 5d 2a 80 00       	push   $0x802a5d
  8010a5:	e8 b8 f0 ff ff       	call   800162 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	68 c1 23 80 00       	push   $0x8023c1
  8010b2:	57                   	push   %edi
  8010b3:	e8 56 fc ff ff       	call   800d0e <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010b8:	83 c4 08             	add    $0x8,%esp
  8010bb:	6a 02                	push   $0x2
  8010bd:	57                   	push   %edi
  8010be:	e8 c7 fb ff ff       	call   800c8a <sys_env_set_status>
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	79 15                	jns    8010df <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  8010ca:	50                   	push   %eax
  8010cb:	68 c6 2a 80 00       	push   $0x802ac6
  8010d0:	68 8c 00 00 00       	push   $0x8c
  8010d5:	68 5d 2a 80 00       	push   $0x802a5d
  8010da:	e8 83 f0 ff ff       	call   800162 <_panic>

	return envid;
  8010df:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ef:	68 df 2a 80 00       	push   $0x802adf
  8010f4:	68 98 00 00 00       	push   $0x98
  8010f9:	68 5d 2a 80 00       	push   $0x802a5d
  8010fe:	e8 5f f0 ff ff       	call   800162 <_panic>

00801103 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	8b 75 08             	mov    0x8(%ebp),%esi
  80110b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801111:	85 c0                	test   %eax,%eax
  801113:	74 0e                	je     801123 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	50                   	push   %eax
  801119:	e8 55 fc ff ff       	call   800d73 <sys_ipc_recv>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	eb 10                	jmp    801133 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	68 00 00 00 f0       	push   $0xf0000000
  80112b:	e8 43 fc ff ff       	call   800d73 <sys_ipc_recv>
  801130:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801133:	85 c0                	test   %eax,%eax
  801135:	74 0e                	je     801145 <ipc_recv+0x42>
    	*from_env_store = 0;
  801137:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  80113d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801143:	eb 24                	jmp    801169 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801145:	85 f6                	test   %esi,%esi
  801147:	74 0a                	je     801153 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801149:	a1 08 40 80 00       	mov    0x804008,%eax
  80114e:	8b 40 74             	mov    0x74(%eax),%eax
  801151:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801153:	85 db                	test   %ebx,%ebx
  801155:	74 0a                	je     801161 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801157:	a1 08 40 80 00       	mov    0x804008,%eax
  80115c:	8b 40 78             	mov    0x78(%eax),%eax
  80115f:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801161:	a1 08 40 80 00       	mov    0x804008,%eax
  801166:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801169:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80117f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801182:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801184:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801189:	0f 44 d8             	cmove  %eax,%ebx
  80118c:	eb 1c                	jmp    8011aa <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80118e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801191:	74 12                	je     8011a5 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801193:	50                   	push   %eax
  801194:	68 a4 2b 80 00       	push   $0x802ba4
  801199:	6a 4b                	push   $0x4b
  80119b:	68 bc 2b 80 00       	push   $0x802bbc
  8011a0:	e8 bd ef ff ff       	call   800162 <_panic>
        }	
        sys_yield();
  8011a5:	e8 fa f9 ff ff       	call   800ba4 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8011aa:	ff 75 14             	pushl  0x14(%ebp)
  8011ad:	53                   	push   %ebx
  8011ae:	56                   	push   %esi
  8011af:	57                   	push   %edi
  8011b0:	e8 9b fb ff ff       	call   800d50 <sys_ipc_try_send>
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	75 d2                	jne    80118e <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8011bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011cf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011d2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011d8:	8b 52 50             	mov    0x50(%edx),%edx
  8011db:	39 ca                	cmp    %ecx,%edx
  8011dd:	75 0d                	jne    8011ec <ipc_find_env+0x28>
			return envs[i].env_id;
  8011df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ea:	eb 0f                	jmp    8011fb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ec:	83 c0 01             	add    $0x1,%eax
  8011ef:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011f4:	75 d9                	jne    8011cf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	05 00 00 00 30       	add    $0x30000000,%eax
  801208:	c1 e8 0c             	shr    $0xc,%eax
}
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801210:	8b 45 08             	mov    0x8(%ebp),%eax
  801213:	05 00 00 00 30       	add    $0x30000000,%eax
  801218:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80121d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80122f:	89 c2                	mov    %eax,%edx
  801231:	c1 ea 16             	shr    $0x16,%edx
  801234:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123b:	f6 c2 01             	test   $0x1,%dl
  80123e:	74 11                	je     801251 <fd_alloc+0x2d>
  801240:	89 c2                	mov    %eax,%edx
  801242:	c1 ea 0c             	shr    $0xc,%edx
  801245:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124c:	f6 c2 01             	test   $0x1,%dl
  80124f:	75 09                	jne    80125a <fd_alloc+0x36>
			*fd_store = fd;
  801251:	89 01                	mov    %eax,(%ecx)
			return 0;
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	eb 17                	jmp    801271 <fd_alloc+0x4d>
  80125a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80125f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801264:	75 c9                	jne    80122f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801266:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80126c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801279:	83 f8 1f             	cmp    $0x1f,%eax
  80127c:	77 36                	ja     8012b4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80127e:	c1 e0 0c             	shl    $0xc,%eax
  801281:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801286:	89 c2                	mov    %eax,%edx
  801288:	c1 ea 16             	shr    $0x16,%edx
  80128b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801292:	f6 c2 01             	test   $0x1,%dl
  801295:	74 24                	je     8012bb <fd_lookup+0x48>
  801297:	89 c2                	mov    %eax,%edx
  801299:	c1 ea 0c             	shr    $0xc,%edx
  80129c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a3:	f6 c2 01             	test   $0x1,%dl
  8012a6:	74 1a                	je     8012c2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ab:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b2:	eb 13                	jmp    8012c7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b9:	eb 0c                	jmp    8012c7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c0:	eb 05                	jmp    8012c7 <fd_lookup+0x54>
  8012c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d2:	ba 44 2c 80 00       	mov    $0x802c44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d7:	eb 13                	jmp    8012ec <dev_lookup+0x23>
  8012d9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012dc:	39 08                	cmp    %ecx,(%eax)
  8012de:	75 0c                	jne    8012ec <dev_lookup+0x23>
			*dev = devtab[i];
  8012e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ea:	eb 2e                	jmp    80131a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ec:	8b 02                	mov    (%edx),%eax
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	75 e7                	jne    8012d9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8012f7:	8b 40 48             	mov    0x48(%eax),%eax
  8012fa:	83 ec 04             	sub    $0x4,%esp
  8012fd:	51                   	push   %ecx
  8012fe:	50                   	push   %eax
  8012ff:	68 c8 2b 80 00       	push   $0x802bc8
  801304:	e8 32 ef ff ff       	call   80023b <cprintf>
	*dev = 0;
  801309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80131a:	c9                   	leave  
  80131b:	c3                   	ret    

0080131c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	56                   	push   %esi
  801320:	53                   	push   %ebx
  801321:	83 ec 10             	sub    $0x10,%esp
  801324:	8b 75 08             	mov    0x8(%ebp),%esi
  801327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80132a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132d:	50                   	push   %eax
  80132e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801334:	c1 e8 0c             	shr    $0xc,%eax
  801337:	50                   	push   %eax
  801338:	e8 36 ff ff ff       	call   801273 <fd_lookup>
  80133d:	83 c4 08             	add    $0x8,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 05                	js     801349 <fd_close+0x2d>
	    || fd != fd2)
  801344:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801347:	74 0c                	je     801355 <fd_close+0x39>
		return (must_exist ? r : 0);
  801349:	84 db                	test   %bl,%bl
  80134b:	ba 00 00 00 00       	mov    $0x0,%edx
  801350:	0f 44 c2             	cmove  %edx,%eax
  801353:	eb 41                	jmp    801396 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 36                	pushl  (%esi)
  80135e:	e8 66 ff ff ff       	call   8012c9 <dev_lookup>
  801363:	89 c3                	mov    %eax,%ebx
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 1a                	js     801386 <fd_close+0x6a>
		if (dev->dev_close)
  80136c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801372:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801377:	85 c0                	test   %eax,%eax
  801379:	74 0b                	je     801386 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	56                   	push   %esi
  80137f:	ff d0                	call   *%eax
  801381:	89 c3                	mov    %eax,%ebx
  801383:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	56                   	push   %esi
  80138a:	6a 00                	push   $0x0
  80138c:	e8 b7 f8 ff ff       	call   800c48 <sys_page_unmap>
	return r;
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	89 d8                	mov    %ebx,%eax
}
  801396:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	ff 75 08             	pushl  0x8(%ebp)
  8013aa:	e8 c4 fe ff ff       	call   801273 <fd_lookup>
  8013af:	83 c4 08             	add    $0x8,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 10                	js     8013c6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	6a 01                	push   $0x1
  8013bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8013be:	e8 59 ff ff ff       	call   80131c <fd_close>
  8013c3:	83 c4 10             	add    $0x10,%esp
}
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <close_all>:

void
close_all(void)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013d4:	83 ec 0c             	sub    $0xc,%esp
  8013d7:	53                   	push   %ebx
  8013d8:	e8 c0 ff ff ff       	call   80139d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013dd:	83 c3 01             	add    $0x1,%ebx
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	83 fb 20             	cmp    $0x20,%ebx
  8013e6:	75 ec                	jne    8013d4 <close_all+0xc>
		close(i);
}
  8013e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 2c             	sub    $0x2c,%esp
  8013f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	ff 75 08             	pushl  0x8(%ebp)
  801400:	e8 6e fe ff ff       	call   801273 <fd_lookup>
  801405:	83 c4 08             	add    $0x8,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	0f 88 c1 00 00 00    	js     8014d1 <dup+0xe4>
		return r;
	close(newfdnum);
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	56                   	push   %esi
  801414:	e8 84 ff ff ff       	call   80139d <close>

	newfd = INDEX2FD(newfdnum);
  801419:	89 f3                	mov    %esi,%ebx
  80141b:	c1 e3 0c             	shl    $0xc,%ebx
  80141e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801424:	83 c4 04             	add    $0x4,%esp
  801427:	ff 75 e4             	pushl  -0x1c(%ebp)
  80142a:	e8 de fd ff ff       	call   80120d <fd2data>
  80142f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801431:	89 1c 24             	mov    %ebx,(%esp)
  801434:	e8 d4 fd ff ff       	call   80120d <fd2data>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80143f:	89 f8                	mov    %edi,%eax
  801441:	c1 e8 16             	shr    $0x16,%eax
  801444:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144b:	a8 01                	test   $0x1,%al
  80144d:	74 37                	je     801486 <dup+0x99>
  80144f:	89 f8                	mov    %edi,%eax
  801451:	c1 e8 0c             	shr    $0xc,%eax
  801454:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80145b:	f6 c2 01             	test   $0x1,%dl
  80145e:	74 26                	je     801486 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801460:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	25 07 0e 00 00       	and    $0xe07,%eax
  80146f:	50                   	push   %eax
  801470:	ff 75 d4             	pushl  -0x2c(%ebp)
  801473:	6a 00                	push   $0x0
  801475:	57                   	push   %edi
  801476:	6a 00                	push   $0x0
  801478:	e8 89 f7 ff ff       	call   800c06 <sys_page_map>
  80147d:	89 c7                	mov    %eax,%edi
  80147f:	83 c4 20             	add    $0x20,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 2e                	js     8014b4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801489:	89 d0                	mov    %edx,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
  80148e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	25 07 0e 00 00       	and    $0xe07,%eax
  80149d:	50                   	push   %eax
  80149e:	53                   	push   %ebx
  80149f:	6a 00                	push   $0x0
  8014a1:	52                   	push   %edx
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 5d f7 ff ff       	call   800c06 <sys_page_map>
  8014a9:	89 c7                	mov    %eax,%edi
  8014ab:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ae:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b0:	85 ff                	test   %edi,%edi
  8014b2:	79 1d                	jns    8014d1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 89 f7 ff ff       	call   800c48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014bf:	83 c4 08             	add    $0x8,%esp
  8014c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 7c f7 ff ff       	call   800c48 <sys_page_unmap>
	return r;
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	89 f8                	mov    %edi,%eax
}
  8014d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5e                   	pop    %esi
  8014d6:	5f                   	pop    %edi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 14             	sub    $0x14,%esp
  8014e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	53                   	push   %ebx
  8014e8:	e8 86 fd ff ff       	call   801273 <fd_lookup>
  8014ed:	83 c4 08             	add    $0x8,%esp
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 6d                	js     801563 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	ff 30                	pushl  (%eax)
  801502:	e8 c2 fd ff ff       	call   8012c9 <dev_lookup>
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 4c                	js     80155a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80150e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801511:	8b 42 08             	mov    0x8(%edx),%eax
  801514:	83 e0 03             	and    $0x3,%eax
  801517:	83 f8 01             	cmp    $0x1,%eax
  80151a:	75 21                	jne    80153d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80151c:	a1 08 40 80 00       	mov    0x804008,%eax
  801521:	8b 40 48             	mov    0x48(%eax),%eax
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	53                   	push   %ebx
  801528:	50                   	push   %eax
  801529:	68 09 2c 80 00       	push   $0x802c09
  80152e:	e8 08 ed ff ff       	call   80023b <cprintf>
		return -E_INVAL;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153b:	eb 26                	jmp    801563 <read+0x8a>
	}
	if (!dev->dev_read)
  80153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801540:	8b 40 08             	mov    0x8(%eax),%eax
  801543:	85 c0                	test   %eax,%eax
  801545:	74 17                	je     80155e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801547:	83 ec 04             	sub    $0x4,%esp
  80154a:	ff 75 10             	pushl  0x10(%ebp)
  80154d:	ff 75 0c             	pushl  0xc(%ebp)
  801550:	52                   	push   %edx
  801551:	ff d0                	call   *%eax
  801553:	89 c2                	mov    %eax,%edx
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	eb 09                	jmp    801563 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	eb 05                	jmp    801563 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80155e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801563:	89 d0                	mov    %edx,%eax
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	57                   	push   %edi
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	83 ec 0c             	sub    $0xc,%esp
  801573:	8b 7d 08             	mov    0x8(%ebp),%edi
  801576:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801579:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157e:	eb 21                	jmp    8015a1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	89 f0                	mov    %esi,%eax
  801585:	29 d8                	sub    %ebx,%eax
  801587:	50                   	push   %eax
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	03 45 0c             	add    0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	57                   	push   %edi
  80158f:	e8 45 ff ff ff       	call   8014d9 <read>
		if (m < 0)
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 10                	js     8015ab <readn+0x41>
			return m;
		if (m == 0)
  80159b:	85 c0                	test   %eax,%eax
  80159d:	74 0a                	je     8015a9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159f:	01 c3                	add    %eax,%ebx
  8015a1:	39 f3                	cmp    %esi,%ebx
  8015a3:	72 db                	jb     801580 <readn+0x16>
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	eb 02                	jmp    8015ab <readn+0x41>
  8015a9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5f                   	pop    %edi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 14             	sub    $0x14,%esp
  8015ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	53                   	push   %ebx
  8015c2:	e8 ac fc ff ff       	call   801273 <fd_lookup>
  8015c7:	83 c4 08             	add    $0x8,%esp
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 68                	js     801638 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	ff 30                	pushl  (%eax)
  8015dc:	e8 e8 fc ff ff       	call   8012c9 <dev_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 47                	js     80162f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ef:	75 21                	jne    801612 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f6:	8b 40 48             	mov    0x48(%eax),%eax
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	53                   	push   %ebx
  8015fd:	50                   	push   %eax
  8015fe:	68 25 2c 80 00       	push   $0x802c25
  801603:	e8 33 ec ff ff       	call   80023b <cprintf>
		return -E_INVAL;
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801610:	eb 26                	jmp    801638 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801615:	8b 52 0c             	mov    0xc(%edx),%edx
  801618:	85 d2                	test   %edx,%edx
  80161a:	74 17                	je     801633 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161c:	83 ec 04             	sub    $0x4,%esp
  80161f:	ff 75 10             	pushl  0x10(%ebp)
  801622:	ff 75 0c             	pushl  0xc(%ebp)
  801625:	50                   	push   %eax
  801626:	ff d2                	call   *%edx
  801628:	89 c2                	mov    %eax,%edx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb 09                	jmp    801638 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	89 c2                	mov    %eax,%edx
  801631:	eb 05                	jmp    801638 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801633:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801638:	89 d0                	mov    %edx,%eax
  80163a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <seek>:

int
seek(int fdnum, off_t offset)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801645:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	ff 75 08             	pushl  0x8(%ebp)
  80164c:	e8 22 fc ff ff       	call   801273 <fd_lookup>
  801651:	83 c4 08             	add    $0x8,%esp
  801654:	85 c0                	test   %eax,%eax
  801656:	78 0e                	js     801666 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801658:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80165b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80165e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801661:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	53                   	push   %ebx
  80166c:	83 ec 14             	sub    $0x14,%esp
  80166f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801672:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	53                   	push   %ebx
  801677:	e8 f7 fb ff ff       	call   801273 <fd_lookup>
  80167c:	83 c4 08             	add    $0x8,%esp
  80167f:	89 c2                	mov    %eax,%edx
  801681:	85 c0                	test   %eax,%eax
  801683:	78 65                	js     8016ea <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168f:	ff 30                	pushl  (%eax)
  801691:	e8 33 fc ff ff       	call   8012c9 <dev_lookup>
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 44                	js     8016e1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a4:	75 21                	jne    8016c7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016a6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ab:	8b 40 48             	mov    0x48(%eax),%eax
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	53                   	push   %ebx
  8016b2:	50                   	push   %eax
  8016b3:	68 e8 2b 80 00       	push   $0x802be8
  8016b8:	e8 7e eb ff ff       	call   80023b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016c5:	eb 23                	jmp    8016ea <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ca:	8b 52 18             	mov    0x18(%edx),%edx
  8016cd:	85 d2                	test   %edx,%edx
  8016cf:	74 14                	je     8016e5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	50                   	push   %eax
  8016d8:	ff d2                	call   *%edx
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	eb 09                	jmp    8016ea <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	eb 05                	jmp    8016ea <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ea:	89 d0                	mov    %edx,%eax
  8016ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 14             	sub    $0x14,%esp
  8016f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	ff 75 08             	pushl  0x8(%ebp)
  801702:	e8 6c fb ff ff       	call   801273 <fd_lookup>
  801707:	83 c4 08             	add    $0x8,%esp
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 58                	js     801768 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	ff 30                	pushl  (%eax)
  80171c:	e8 a8 fb ff ff       	call   8012c9 <dev_lookup>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 37                	js     80175f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80172f:	74 32                	je     801763 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801731:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801734:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173b:	00 00 00 
	stat->st_isdir = 0;
  80173e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801745:	00 00 00 
	stat->st_dev = dev;
  801748:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80174e:	83 ec 08             	sub    $0x8,%esp
  801751:	53                   	push   %ebx
  801752:	ff 75 f0             	pushl  -0x10(%ebp)
  801755:	ff 50 14             	call   *0x14(%eax)
  801758:	89 c2                	mov    %eax,%edx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb 09                	jmp    801768 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	89 c2                	mov    %eax,%edx
  801761:	eb 05                	jmp    801768 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801763:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801768:	89 d0                	mov    %edx,%eax
  80176a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	6a 00                	push   $0x0
  801779:	ff 75 08             	pushl  0x8(%ebp)
  80177c:	e8 e7 01 00 00       	call   801968 <open>
  801781:	89 c3                	mov    %eax,%ebx
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	78 1b                	js     8017a5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	ff 75 0c             	pushl  0xc(%ebp)
  801790:	50                   	push   %eax
  801791:	e8 5b ff ff ff       	call   8016f1 <fstat>
  801796:	89 c6                	mov    %eax,%esi
	close(fd);
  801798:	89 1c 24             	mov    %ebx,(%esp)
  80179b:	e8 fd fb ff ff       	call   80139d <close>
	return r;
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	89 f0                	mov    %esi,%eax
}
  8017a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	89 c6                	mov    %eax,%esi
  8017b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017bc:	75 12                	jne    8017d0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	6a 01                	push   $0x1
  8017c3:	e8 fc f9 ff ff       	call   8011c4 <ipc_find_env>
  8017c8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017cd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d0:	6a 07                	push   $0x7
  8017d2:	68 00 50 80 00       	push   $0x805000
  8017d7:	56                   	push   %esi
  8017d8:	ff 35 00 40 80 00    	pushl  0x804000
  8017de:	e8 8d f9 ff ff       	call   801170 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e3:	83 c4 0c             	add    $0xc,%esp
  8017e6:	6a 00                	push   $0x0
  8017e8:	53                   	push   %ebx
  8017e9:	6a 00                	push   $0x0
  8017eb:	e8 13 f9 ff ff       	call   801103 <ipc_recv>
}
  8017f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	8b 40 0c             	mov    0xc(%eax),%eax
  801803:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801808:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 02 00 00 00       	mov    $0x2,%eax
  80181a:	e8 8d ff ff ff       	call   8017ac <fsipc>
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	8b 40 0c             	mov    0xc(%eax),%eax
  80182d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801832:	ba 00 00 00 00       	mov    $0x0,%edx
  801837:	b8 06 00 00 00       	mov    $0x6,%eax
  80183c:	e8 6b ff ff ff       	call   8017ac <fsipc>
}
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 05 00 00 00       	mov    $0x5,%eax
  801862:	e8 45 ff ff ff       	call   8017ac <fsipc>
  801867:	85 c0                	test   %eax,%eax
  801869:	78 2c                	js     801897 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	68 00 50 80 00       	push   $0x805000
  801873:	53                   	push   %ebx
  801874:	e8 47 ef ff ff       	call   8007c0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801879:	a1 80 50 80 00       	mov    0x805080,%eax
  80187e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801884:	a1 84 50 80 00       	mov    0x805084,%eax
  801889:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	53                   	push   %ebx
  8018a0:	83 ec 08             	sub    $0x8,%esp
  8018a3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8018a6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018ab:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8018b0:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018b3:	53                   	push   %ebx
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	68 08 50 80 00       	push   $0x805008
  8018bc:	e8 91 f0 ff ff       	call   800952 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c7:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8018cc:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8018d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8018dc:	e8 cb fe ff ff       	call   8017ac <fsipc>
	//panic("devfile_write not implemented");
}
  8018e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	56                   	push   %esi
  8018ea:	53                   	push   %ebx
  8018eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801904:	b8 03 00 00 00       	mov    $0x3,%eax
  801909:	e8 9e fe ff ff       	call   8017ac <fsipc>
  80190e:	89 c3                	mov    %eax,%ebx
  801910:	85 c0                	test   %eax,%eax
  801912:	78 4b                	js     80195f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801914:	39 c6                	cmp    %eax,%esi
  801916:	73 16                	jae    80192e <devfile_read+0x48>
  801918:	68 58 2c 80 00       	push   $0x802c58
  80191d:	68 5f 2c 80 00       	push   $0x802c5f
  801922:	6a 7c                	push   $0x7c
  801924:	68 74 2c 80 00       	push   $0x802c74
  801929:	e8 34 e8 ff ff       	call   800162 <_panic>
	assert(r <= PGSIZE);
  80192e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801933:	7e 16                	jle    80194b <devfile_read+0x65>
  801935:	68 7f 2c 80 00       	push   $0x802c7f
  80193a:	68 5f 2c 80 00       	push   $0x802c5f
  80193f:	6a 7d                	push   $0x7d
  801941:	68 74 2c 80 00       	push   $0x802c74
  801946:	e8 17 e8 ff ff       	call   800162 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80194b:	83 ec 04             	sub    $0x4,%esp
  80194e:	50                   	push   %eax
  80194f:	68 00 50 80 00       	push   $0x805000
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	e8 f6 ef ff ff       	call   800952 <memmove>
	return r;
  80195c:	83 c4 10             	add    $0x10,%esp
}
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 20             	sub    $0x20,%esp
  80196f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801972:	53                   	push   %ebx
  801973:	e8 0f ee ff ff       	call   800787 <strlen>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801980:	7f 67                	jg     8019e9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801988:	50                   	push   %eax
  801989:	e8 96 f8 ff ff       	call   801224 <fd_alloc>
  80198e:	83 c4 10             	add    $0x10,%esp
		return r;
  801991:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801993:	85 c0                	test   %eax,%eax
  801995:	78 57                	js     8019ee <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	53                   	push   %ebx
  80199b:	68 00 50 80 00       	push   $0x805000
  8019a0:	e8 1b ee ff ff       	call   8007c0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b5:	e8 f2 fd ff ff       	call   8017ac <fsipc>
  8019ba:	89 c3                	mov    %eax,%ebx
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	79 14                	jns    8019d7 <open+0x6f>
		fd_close(fd, 0);
  8019c3:	83 ec 08             	sub    $0x8,%esp
  8019c6:	6a 00                	push   $0x0
  8019c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cb:	e8 4c f9 ff ff       	call   80131c <fd_close>
		return r;
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	89 da                	mov    %ebx,%edx
  8019d5:	eb 17                	jmp    8019ee <open+0x86>
	}

	return fd2num(fd);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dd:	e8 1b f8 ff ff       	call   8011fd <fd2num>
  8019e2:	89 c2                	mov    %eax,%edx
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	eb 05                	jmp    8019ee <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019e9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ee:	89 d0                	mov    %edx,%eax
  8019f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    

008019f5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 08 00 00 00       	mov    $0x8,%eax
  801a05:	e8 a2 fd ff ff       	call   8017ac <fsipc>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a12:	68 8b 2c 80 00       	push   $0x802c8b
  801a17:	ff 75 0c             	pushl  0xc(%ebp)
  801a1a:	e8 a1 ed ff ff       	call   8007c0 <strcpy>
	return 0;
}
  801a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 10             	sub    $0x10,%esp
  801a2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a30:	53                   	push   %ebx
  801a31:	e8 af 09 00 00       	call   8023e5 <pageref>
  801a36:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a39:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a3e:	83 f8 01             	cmp    $0x1,%eax
  801a41:	75 10                	jne    801a53 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	ff 73 0c             	pushl  0xc(%ebx)
  801a49:	e8 c0 02 00 00       	call   801d0e <nsipc_close>
  801a4e:	89 c2                	mov    %eax,%edx
  801a50:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a53:	89 d0                	mov    %edx,%eax
  801a55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a58:	c9                   	leave  
  801a59:	c3                   	ret    

00801a5a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a60:	6a 00                	push   $0x0
  801a62:	ff 75 10             	pushl  0x10(%ebp)
  801a65:	ff 75 0c             	pushl  0xc(%ebp)
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	ff 70 0c             	pushl  0xc(%eax)
  801a6e:	e8 78 03 00 00       	call   801deb <nsipc_send>
}
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a7b:	6a 00                	push   $0x0
  801a7d:	ff 75 10             	pushl  0x10(%ebp)
  801a80:	ff 75 0c             	pushl  0xc(%ebp)
  801a83:	8b 45 08             	mov    0x8(%ebp),%eax
  801a86:	ff 70 0c             	pushl  0xc(%eax)
  801a89:	e8 f1 02 00 00       	call   801d7f <nsipc_recv>
}
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a96:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a99:	52                   	push   %edx
  801a9a:	50                   	push   %eax
  801a9b:	e8 d3 f7 ff ff       	call   801273 <fd_lookup>
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	78 17                	js     801abe <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaa:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801ab0:	39 08                	cmp    %ecx,(%eax)
  801ab2:	75 05                	jne    801ab9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ab4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab7:	eb 05                	jmp    801abe <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ab9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 1c             	sub    $0x1c,%esp
  801ac8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	e8 51 f7 ff ff       	call   801224 <fd_alloc>
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 1b                	js     801af7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801adc:	83 ec 04             	sub    $0x4,%esp
  801adf:	68 07 04 00 00       	push   $0x407
  801ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae7:	6a 00                	push   $0x0
  801ae9:	e8 d5 f0 ff ff       	call   800bc3 <sys_page_alloc>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	79 10                	jns    801b07 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	56                   	push   %esi
  801afb:	e8 0e 02 00 00       	call   801d0e <nsipc_close>
		return r;
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	89 d8                	mov    %ebx,%eax
  801b05:	eb 24                	jmp    801b2b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b15:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b1c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	50                   	push   %eax
  801b23:	e8 d5 f6 ff ff       	call   8011fd <fd2num>
  801b28:	83 c4 10             	add    $0x10,%esp
}
  801b2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2e:	5b                   	pop    %ebx
  801b2f:	5e                   	pop    %esi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	e8 50 ff ff ff       	call   801a90 <fd2sockid>
		return r;
  801b40:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 1f                	js     801b65 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b46:	83 ec 04             	sub    $0x4,%esp
  801b49:	ff 75 10             	pushl  0x10(%ebp)
  801b4c:	ff 75 0c             	pushl  0xc(%ebp)
  801b4f:	50                   	push   %eax
  801b50:	e8 12 01 00 00       	call   801c67 <nsipc_accept>
  801b55:	83 c4 10             	add    $0x10,%esp
		return r;
  801b58:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 07                	js     801b65 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b5e:	e8 5d ff ff ff       	call   801ac0 <alloc_sockfd>
  801b63:	89 c1                	mov    %eax,%ecx
}
  801b65:	89 c8                	mov    %ecx,%eax
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	e8 19 ff ff ff       	call   801a90 <fd2sockid>
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 12                	js     801b8d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b7b:	83 ec 04             	sub    $0x4,%esp
  801b7e:	ff 75 10             	pushl  0x10(%ebp)
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	50                   	push   %eax
  801b85:	e8 2d 01 00 00       	call   801cb7 <nsipc_bind>
  801b8a:	83 c4 10             	add    $0x10,%esp
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <shutdown>:

int
shutdown(int s, int how)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b95:	8b 45 08             	mov    0x8(%ebp),%eax
  801b98:	e8 f3 fe ff ff       	call   801a90 <fd2sockid>
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 0f                	js     801bb0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ba1:	83 ec 08             	sub    $0x8,%esp
  801ba4:	ff 75 0c             	pushl  0xc(%ebp)
  801ba7:	50                   	push   %eax
  801ba8:	e8 3f 01 00 00       	call   801cec <nsipc_shutdown>
  801bad:	83 c4 10             	add    $0x10,%esp
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbb:	e8 d0 fe ff ff       	call   801a90 <fd2sockid>
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 12                	js     801bd6 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	ff 75 10             	pushl  0x10(%ebp)
  801bca:	ff 75 0c             	pushl  0xc(%ebp)
  801bcd:	50                   	push   %eax
  801bce:	e8 55 01 00 00       	call   801d28 <nsipc_connect>
  801bd3:	83 c4 10             	add    $0x10,%esp
}
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <listen>:

int
listen(int s, int backlog)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bde:	8b 45 08             	mov    0x8(%ebp),%eax
  801be1:	e8 aa fe ff ff       	call   801a90 <fd2sockid>
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 0f                	js     801bf9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bea:	83 ec 08             	sub    $0x8,%esp
  801bed:	ff 75 0c             	pushl  0xc(%ebp)
  801bf0:	50                   	push   %eax
  801bf1:	e8 67 01 00 00       	call   801d5d <nsipc_listen>
  801bf6:	83 c4 10             	add    $0x10,%esp
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c01:	ff 75 10             	pushl  0x10(%ebp)
  801c04:	ff 75 0c             	pushl  0xc(%ebp)
  801c07:	ff 75 08             	pushl  0x8(%ebp)
  801c0a:	e8 3a 02 00 00       	call   801e49 <nsipc_socket>
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	85 c0                	test   %eax,%eax
  801c14:	78 05                	js     801c1b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c16:	e8 a5 fe ff ff       	call   801ac0 <alloc_sockfd>
}
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	53                   	push   %ebx
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c26:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c2d:	75 12                	jne    801c41 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c2f:	83 ec 0c             	sub    $0xc,%esp
  801c32:	6a 02                	push   $0x2
  801c34:	e8 8b f5 ff ff       	call   8011c4 <ipc_find_env>
  801c39:	a3 04 40 80 00       	mov    %eax,0x804004
  801c3e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c41:	6a 07                	push   $0x7
  801c43:	68 00 60 80 00       	push   $0x806000
  801c48:	53                   	push   %ebx
  801c49:	ff 35 04 40 80 00    	pushl  0x804004
  801c4f:	e8 1c f5 ff ff       	call   801170 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c54:	83 c4 0c             	add    $0xc,%esp
  801c57:	6a 00                	push   $0x0
  801c59:	6a 00                	push   $0x0
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 a1 f4 ff ff       	call   801103 <ipc_recv>
}
  801c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	56                   	push   %esi
  801c6b:	53                   	push   %ebx
  801c6c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c77:	8b 06                	mov    (%esi),%eax
  801c79:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c83:	e8 95 ff ff ff       	call   801c1d <nsipc>
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 20                	js     801cae <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c8e:	83 ec 04             	sub    $0x4,%esp
  801c91:	ff 35 10 60 80 00    	pushl  0x806010
  801c97:	68 00 60 80 00       	push   $0x806000
  801c9c:	ff 75 0c             	pushl  0xc(%ebp)
  801c9f:	e8 ae ec ff ff       	call   800952 <memmove>
		*addrlen = ret->ret_addrlen;
  801ca4:	a1 10 60 80 00       	mov    0x806010,%eax
  801ca9:	89 06                	mov    %eax,(%esi)
  801cab:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cae:	89 d8                	mov    %ebx,%eax
  801cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	53                   	push   %ebx
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cc9:	53                   	push   %ebx
  801cca:	ff 75 0c             	pushl  0xc(%ebp)
  801ccd:	68 04 60 80 00       	push   $0x806004
  801cd2:	e8 7b ec ff ff       	call   800952 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cd7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cdd:	b8 02 00 00 00       	mov    $0x2,%eax
  801ce2:	e8 36 ff ff ff       	call   801c1d <nsipc>
}
  801ce7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d02:	b8 03 00 00 00       	mov    $0x3,%eax
  801d07:	e8 11 ff ff ff       	call   801c1d <nsipc>
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <nsipc_close>:

int
nsipc_close(int s)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d1c:	b8 04 00 00 00       	mov    $0x4,%eax
  801d21:	e8 f7 fe ff ff       	call   801c1d <nsipc>
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 08             	sub    $0x8,%esp
  801d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d32:	8b 45 08             	mov    0x8(%ebp),%eax
  801d35:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d3a:	53                   	push   %ebx
  801d3b:	ff 75 0c             	pushl  0xc(%ebp)
  801d3e:	68 04 60 80 00       	push   $0x806004
  801d43:	e8 0a ec ff ff       	call   800952 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d48:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d4e:	b8 05 00 00 00       	mov    $0x5,%eax
  801d53:	e8 c5 fe ff ff       	call   801c1d <nsipc>
}
  801d58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d63:	8b 45 08             	mov    0x8(%ebp),%eax
  801d66:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d73:	b8 06 00 00 00       	mov    $0x6,%eax
  801d78:	e8 a0 fe ff ff       	call   801c1d <nsipc>
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d8f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d95:	8b 45 14             	mov    0x14(%ebp),%eax
  801d98:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d9d:	b8 07 00 00 00       	mov    $0x7,%eax
  801da2:	e8 76 fe ff ff       	call   801c1d <nsipc>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	85 c0                	test   %eax,%eax
  801dab:	78 35                	js     801de2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801dad:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801db2:	7f 04                	jg     801db8 <nsipc_recv+0x39>
  801db4:	39 c6                	cmp    %eax,%esi
  801db6:	7d 16                	jge    801dce <nsipc_recv+0x4f>
  801db8:	68 97 2c 80 00       	push   $0x802c97
  801dbd:	68 5f 2c 80 00       	push   $0x802c5f
  801dc2:	6a 62                	push   $0x62
  801dc4:	68 ac 2c 80 00       	push   $0x802cac
  801dc9:	e8 94 e3 ff ff       	call   800162 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801dce:	83 ec 04             	sub    $0x4,%esp
  801dd1:	50                   	push   %eax
  801dd2:	68 00 60 80 00       	push   $0x806000
  801dd7:	ff 75 0c             	pushl  0xc(%ebp)
  801dda:	e8 73 eb ff ff       	call   800952 <memmove>
  801ddf:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801de2:	89 d8                	mov    %ebx,%eax
  801de4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	53                   	push   %ebx
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801df5:	8b 45 08             	mov    0x8(%ebp),%eax
  801df8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dfd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e03:	7e 16                	jle    801e1b <nsipc_send+0x30>
  801e05:	68 b8 2c 80 00       	push   $0x802cb8
  801e0a:	68 5f 2c 80 00       	push   $0x802c5f
  801e0f:	6a 6d                	push   $0x6d
  801e11:	68 ac 2c 80 00       	push   $0x802cac
  801e16:	e8 47 e3 ff ff       	call   800162 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e1b:	83 ec 04             	sub    $0x4,%esp
  801e1e:	53                   	push   %ebx
  801e1f:	ff 75 0c             	pushl  0xc(%ebp)
  801e22:	68 0c 60 80 00       	push   $0x80600c
  801e27:	e8 26 eb ff ff       	call   800952 <memmove>
	nsipcbuf.send.req_size = size;
  801e2c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e32:	8b 45 14             	mov    0x14(%ebp),%eax
  801e35:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e3a:	b8 08 00 00 00       	mov    $0x8,%eax
  801e3f:	e8 d9 fd ff ff       	call   801c1d <nsipc>
}
  801e44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e47:	c9                   	leave  
  801e48:	c3                   	ret    

00801e49 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e52:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e62:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e67:	b8 09 00 00 00       	mov    $0x9,%eax
  801e6c:	e8 ac fd ff ff       	call   801c1d <nsipc>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	ff 75 08             	pushl  0x8(%ebp)
  801e81:	e8 87 f3 ff ff       	call   80120d <fd2data>
  801e86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e88:	83 c4 08             	add    $0x8,%esp
  801e8b:	68 c4 2c 80 00       	push   $0x802cc4
  801e90:	53                   	push   %ebx
  801e91:	e8 2a e9 ff ff       	call   8007c0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e96:	8b 46 04             	mov    0x4(%esi),%eax
  801e99:	2b 06                	sub    (%esi),%eax
  801e9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ea1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea8:	00 00 00 
	stat->st_dev = &devpipe;
  801eab:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801eb2:	30 80 00 
	return 0;
}
  801eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	53                   	push   %ebx
  801ec5:	83 ec 0c             	sub    $0xc,%esp
  801ec8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ecb:	53                   	push   %ebx
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 75 ed ff ff       	call   800c48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ed3:	89 1c 24             	mov    %ebx,(%esp)
  801ed6:	e8 32 f3 ff ff       	call   80120d <fd2data>
  801edb:	83 c4 08             	add    $0x8,%esp
  801ede:	50                   	push   %eax
  801edf:	6a 00                	push   $0x0
  801ee1:	e8 62 ed ff ff       	call   800c48 <sys_page_unmap>
}
  801ee6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	57                   	push   %edi
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	83 ec 1c             	sub    $0x1c,%esp
  801ef4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ef7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ef9:	a1 08 40 80 00       	mov    0x804008,%eax
  801efe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f01:	83 ec 0c             	sub    $0xc,%esp
  801f04:	ff 75 e0             	pushl  -0x20(%ebp)
  801f07:	e8 d9 04 00 00       	call   8023e5 <pageref>
  801f0c:	89 c3                	mov    %eax,%ebx
  801f0e:	89 3c 24             	mov    %edi,(%esp)
  801f11:	e8 cf 04 00 00       	call   8023e5 <pageref>
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	39 c3                	cmp    %eax,%ebx
  801f1b:	0f 94 c1             	sete   %cl
  801f1e:	0f b6 c9             	movzbl %cl,%ecx
  801f21:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f24:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f2a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f2d:	39 ce                	cmp    %ecx,%esi
  801f2f:	74 1b                	je     801f4c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f31:	39 c3                	cmp    %eax,%ebx
  801f33:	75 c4                	jne    801ef9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f35:	8b 42 58             	mov    0x58(%edx),%eax
  801f38:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f3b:	50                   	push   %eax
  801f3c:	56                   	push   %esi
  801f3d:	68 cb 2c 80 00       	push   $0x802ccb
  801f42:	e8 f4 e2 ff ff       	call   80023b <cprintf>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	eb ad                	jmp    801ef9 <_pipeisclosed+0xe>
	}
}
  801f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f52:	5b                   	pop    %ebx
  801f53:	5e                   	pop    %esi
  801f54:	5f                   	pop    %edi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	57                   	push   %edi
  801f5b:	56                   	push   %esi
  801f5c:	53                   	push   %ebx
  801f5d:	83 ec 28             	sub    $0x28,%esp
  801f60:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f63:	56                   	push   %esi
  801f64:	e8 a4 f2 ff ff       	call   80120d <fd2data>
  801f69:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	bf 00 00 00 00       	mov    $0x0,%edi
  801f73:	eb 4b                	jmp    801fc0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f75:	89 da                	mov    %ebx,%edx
  801f77:	89 f0                	mov    %esi,%eax
  801f79:	e8 6d ff ff ff       	call   801eeb <_pipeisclosed>
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	75 48                	jne    801fca <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f82:	e8 1d ec ff ff       	call   800ba4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f87:	8b 43 04             	mov    0x4(%ebx),%eax
  801f8a:	8b 0b                	mov    (%ebx),%ecx
  801f8c:	8d 51 20             	lea    0x20(%ecx),%edx
  801f8f:	39 d0                	cmp    %edx,%eax
  801f91:	73 e2                	jae    801f75 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f96:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f9a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f9d:	89 c2                	mov    %eax,%edx
  801f9f:	c1 fa 1f             	sar    $0x1f,%edx
  801fa2:	89 d1                	mov    %edx,%ecx
  801fa4:	c1 e9 1b             	shr    $0x1b,%ecx
  801fa7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801faa:	83 e2 1f             	and    $0x1f,%edx
  801fad:	29 ca                	sub    %ecx,%edx
  801faf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fb3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fb7:	83 c0 01             	add    $0x1,%eax
  801fba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbd:	83 c7 01             	add    $0x1,%edi
  801fc0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fc3:	75 c2                	jne    801f87 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc8:	eb 05                	jmp    801fcf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fca:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd2:	5b                   	pop    %ebx
  801fd3:	5e                   	pop    %esi
  801fd4:	5f                   	pop    %edi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    

00801fd7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	57                   	push   %edi
  801fdb:	56                   	push   %esi
  801fdc:	53                   	push   %ebx
  801fdd:	83 ec 18             	sub    $0x18,%esp
  801fe0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fe3:	57                   	push   %edi
  801fe4:	e8 24 f2 ff ff       	call   80120d <fd2data>
  801fe9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ff3:	eb 3d                	jmp    802032 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ff5:	85 db                	test   %ebx,%ebx
  801ff7:	74 04                	je     801ffd <devpipe_read+0x26>
				return i;
  801ff9:	89 d8                	mov    %ebx,%eax
  801ffb:	eb 44                	jmp    802041 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ffd:	89 f2                	mov    %esi,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	e8 e5 fe ff ff       	call   801eeb <_pipeisclosed>
  802006:	85 c0                	test   %eax,%eax
  802008:	75 32                	jne    80203c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80200a:	e8 95 eb ff ff       	call   800ba4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80200f:	8b 06                	mov    (%esi),%eax
  802011:	3b 46 04             	cmp    0x4(%esi),%eax
  802014:	74 df                	je     801ff5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802016:	99                   	cltd   
  802017:	c1 ea 1b             	shr    $0x1b,%edx
  80201a:	01 d0                	add    %edx,%eax
  80201c:	83 e0 1f             	and    $0x1f,%eax
  80201f:	29 d0                	sub    %edx,%eax
  802021:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802029:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80202c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202f:	83 c3 01             	add    $0x1,%ebx
  802032:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802035:	75 d8                	jne    80200f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802037:	8b 45 10             	mov    0x10(%ebp),%eax
  80203a:	eb 05                	jmp    802041 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80203c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802041:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	56                   	push   %esi
  80204d:	53                   	push   %ebx
  80204e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802054:	50                   	push   %eax
  802055:	e8 ca f1 ff ff       	call   801224 <fd_alloc>
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	89 c2                	mov    %eax,%edx
  80205f:	85 c0                	test   %eax,%eax
  802061:	0f 88 2c 01 00 00    	js     802193 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802067:	83 ec 04             	sub    $0x4,%esp
  80206a:	68 07 04 00 00       	push   $0x407
  80206f:	ff 75 f4             	pushl  -0xc(%ebp)
  802072:	6a 00                	push   $0x0
  802074:	e8 4a eb ff ff       	call   800bc3 <sys_page_alloc>
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	89 c2                	mov    %eax,%edx
  80207e:	85 c0                	test   %eax,%eax
  802080:	0f 88 0d 01 00 00    	js     802193 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802086:	83 ec 0c             	sub    $0xc,%esp
  802089:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80208c:	50                   	push   %eax
  80208d:	e8 92 f1 ff ff       	call   801224 <fd_alloc>
  802092:	89 c3                	mov    %eax,%ebx
  802094:	83 c4 10             	add    $0x10,%esp
  802097:	85 c0                	test   %eax,%eax
  802099:	0f 88 e2 00 00 00    	js     802181 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209f:	83 ec 04             	sub    $0x4,%esp
  8020a2:	68 07 04 00 00       	push   $0x407
  8020a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8020aa:	6a 00                	push   $0x0
  8020ac:	e8 12 eb ff ff       	call   800bc3 <sys_page_alloc>
  8020b1:	89 c3                	mov    %eax,%ebx
  8020b3:	83 c4 10             	add    $0x10,%esp
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	0f 88 c3 00 00 00    	js     802181 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020be:	83 ec 0c             	sub    $0xc,%esp
  8020c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c4:	e8 44 f1 ff ff       	call   80120d <fd2data>
  8020c9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020cb:	83 c4 0c             	add    $0xc,%esp
  8020ce:	68 07 04 00 00       	push   $0x407
  8020d3:	50                   	push   %eax
  8020d4:	6a 00                	push   $0x0
  8020d6:	e8 e8 ea ff ff       	call   800bc3 <sys_page_alloc>
  8020db:	89 c3                	mov    %eax,%ebx
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	0f 88 89 00 00 00    	js     802171 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e8:	83 ec 0c             	sub    $0xc,%esp
  8020eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ee:	e8 1a f1 ff ff       	call   80120d <fd2data>
  8020f3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020fa:	50                   	push   %eax
  8020fb:	6a 00                	push   $0x0
  8020fd:	56                   	push   %esi
  8020fe:	6a 00                	push   $0x0
  802100:	e8 01 eb ff ff       	call   800c06 <sys_page_map>
  802105:	89 c3                	mov    %eax,%ebx
  802107:	83 c4 20             	add    $0x20,%esp
  80210a:	85 c0                	test   %eax,%eax
  80210c:	78 55                	js     802163 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80210e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802117:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802119:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802123:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802129:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80212c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80212e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802131:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802138:	83 ec 0c             	sub    $0xc,%esp
  80213b:	ff 75 f4             	pushl  -0xc(%ebp)
  80213e:	e8 ba f0 ff ff       	call   8011fd <fd2num>
  802143:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802146:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802148:	83 c4 04             	add    $0x4,%esp
  80214b:	ff 75 f0             	pushl  -0x10(%ebp)
  80214e:	e8 aa f0 ff ff       	call   8011fd <fd2num>
  802153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802156:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802159:	83 c4 10             	add    $0x10,%esp
  80215c:	ba 00 00 00 00       	mov    $0x0,%edx
  802161:	eb 30                	jmp    802193 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802163:	83 ec 08             	sub    $0x8,%esp
  802166:	56                   	push   %esi
  802167:	6a 00                	push   $0x0
  802169:	e8 da ea ff ff       	call   800c48 <sys_page_unmap>
  80216e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802171:	83 ec 08             	sub    $0x8,%esp
  802174:	ff 75 f0             	pushl  -0x10(%ebp)
  802177:	6a 00                	push   $0x0
  802179:	e8 ca ea ff ff       	call   800c48 <sys_page_unmap>
  80217e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802181:	83 ec 08             	sub    $0x8,%esp
  802184:	ff 75 f4             	pushl  -0xc(%ebp)
  802187:	6a 00                	push   $0x0
  802189:	e8 ba ea ff ff       	call   800c48 <sys_page_unmap>
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802193:	89 d0                	mov    %edx,%eax
  802195:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    

0080219c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a5:	50                   	push   %eax
  8021a6:	ff 75 08             	pushl  0x8(%ebp)
  8021a9:	e8 c5 f0 ff ff       	call   801273 <fd_lookup>
  8021ae:	83 c4 10             	add    $0x10,%esp
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	78 18                	js     8021cd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b5:	83 ec 0c             	sub    $0xc,%esp
  8021b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8021bb:	e8 4d f0 ff ff       	call   80120d <fd2data>
	return _pipeisclosed(fd, p);
  8021c0:	89 c2                	mov    %eax,%edx
  8021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c5:	e8 21 fd ff ff       	call   801eeb <_pipeisclosed>
  8021ca:	83 c4 10             	add    $0x10,%esp
}
  8021cd:	c9                   	leave  
  8021ce:	c3                   	ret    

008021cf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    

008021d9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d9:	55                   	push   %ebp
  8021da:	89 e5                	mov    %esp,%ebp
  8021dc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021df:	68 e3 2c 80 00       	push   $0x802ce3
  8021e4:	ff 75 0c             	pushl  0xc(%ebp)
  8021e7:	e8 d4 e5 ff ff       	call   8007c0 <strcpy>
	return 0;
}
  8021ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	57                   	push   %edi
  8021f7:	56                   	push   %esi
  8021f8:	53                   	push   %ebx
  8021f9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802204:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80220a:	eb 2d                	jmp    802239 <devcons_write+0x46>
		m = n - tot;
  80220c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80220f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802211:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802214:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802219:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80221c:	83 ec 04             	sub    $0x4,%esp
  80221f:	53                   	push   %ebx
  802220:	03 45 0c             	add    0xc(%ebp),%eax
  802223:	50                   	push   %eax
  802224:	57                   	push   %edi
  802225:	e8 28 e7 ff ff       	call   800952 <memmove>
		sys_cputs(buf, m);
  80222a:	83 c4 08             	add    $0x8,%esp
  80222d:	53                   	push   %ebx
  80222e:	57                   	push   %edi
  80222f:	e8 d3 e8 ff ff       	call   800b07 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802234:	01 de                	add    %ebx,%esi
  802236:	83 c4 10             	add    $0x10,%esp
  802239:	89 f0                	mov    %esi,%eax
  80223b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80223e:	72 cc                	jb     80220c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    

00802248 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 08             	sub    $0x8,%esp
  80224e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802253:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802257:	74 2a                	je     802283 <devcons_read+0x3b>
  802259:	eb 05                	jmp    802260 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80225b:	e8 44 e9 ff ff       	call   800ba4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802260:	e8 c0 e8 ff ff       	call   800b25 <sys_cgetc>
  802265:	85 c0                	test   %eax,%eax
  802267:	74 f2                	je     80225b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802269:	85 c0                	test   %eax,%eax
  80226b:	78 16                	js     802283 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80226d:	83 f8 04             	cmp    $0x4,%eax
  802270:	74 0c                	je     80227e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802272:	8b 55 0c             	mov    0xc(%ebp),%edx
  802275:	88 02                	mov    %al,(%edx)
	return 1;
  802277:	b8 01 00 00 00       	mov    $0x1,%eax
  80227c:	eb 05                	jmp    802283 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80227e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802283:	c9                   	leave  
  802284:	c3                   	ret    

00802285 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80228b:	8b 45 08             	mov    0x8(%ebp),%eax
  80228e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802291:	6a 01                	push   $0x1
  802293:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802296:	50                   	push   %eax
  802297:	e8 6b e8 ff ff       	call   800b07 <sys_cputs>
}
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	c9                   	leave  
  8022a0:	c3                   	ret    

008022a1 <getchar>:

int
getchar(void)
{
  8022a1:	55                   	push   %ebp
  8022a2:	89 e5                	mov    %esp,%ebp
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022a7:	6a 01                	push   $0x1
  8022a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ac:	50                   	push   %eax
  8022ad:	6a 00                	push   $0x0
  8022af:	e8 25 f2 ff ff       	call   8014d9 <read>
	if (r < 0)
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	78 0f                	js     8022ca <getchar+0x29>
		return r;
	if (r < 1)
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	7e 06                	jle    8022c5 <getchar+0x24>
		return -E_EOF;
	return c;
  8022bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022c3:	eb 05                	jmp    8022ca <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022ca:	c9                   	leave  
  8022cb:	c3                   	ret    

008022cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d5:	50                   	push   %eax
  8022d6:	ff 75 08             	pushl  0x8(%ebp)
  8022d9:	e8 95 ef ff ff       	call   801273 <fd_lookup>
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	85 c0                	test   %eax,%eax
  8022e3:	78 11                	js     8022f6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ee:	39 10                	cmp    %edx,(%eax)
  8022f0:	0f 94 c0             	sete   %al
  8022f3:	0f b6 c0             	movzbl %al,%eax
}
  8022f6:	c9                   	leave  
  8022f7:	c3                   	ret    

008022f8 <opencons>:

int
opencons(void)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
  8022fb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802301:	50                   	push   %eax
  802302:	e8 1d ef ff ff       	call   801224 <fd_alloc>
  802307:	83 c4 10             	add    $0x10,%esp
		return r;
  80230a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80230c:	85 c0                	test   %eax,%eax
  80230e:	78 3e                	js     80234e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802310:	83 ec 04             	sub    $0x4,%esp
  802313:	68 07 04 00 00       	push   $0x407
  802318:	ff 75 f4             	pushl  -0xc(%ebp)
  80231b:	6a 00                	push   $0x0
  80231d:	e8 a1 e8 ff ff       	call   800bc3 <sys_page_alloc>
  802322:	83 c4 10             	add    $0x10,%esp
		return r;
  802325:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802327:	85 c0                	test   %eax,%eax
  802329:	78 23                	js     80234e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80232b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802331:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802334:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802336:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802339:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802340:	83 ec 0c             	sub    $0xc,%esp
  802343:	50                   	push   %eax
  802344:	e8 b4 ee ff ff       	call   8011fd <fd2num>
  802349:	89 c2                	mov    %eax,%edx
  80234b:	83 c4 10             	add    $0x10,%esp
}
  80234e:	89 d0                	mov    %edx,%eax
  802350:	c9                   	leave  
  802351:	c3                   	ret    

00802352 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802352:	55                   	push   %ebp
  802353:	89 e5                	mov    %esp,%ebp
  802355:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802358:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80235f:	75 2c                	jne    80238d <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802361:	83 ec 04             	sub    $0x4,%esp
  802364:	6a 07                	push   $0x7
  802366:	68 00 f0 bf ee       	push   $0xeebff000
  80236b:	6a 00                	push   $0x0
  80236d:	e8 51 e8 ff ff       	call   800bc3 <sys_page_alloc>
  802372:	83 c4 10             	add    $0x10,%esp
  802375:	85 c0                	test   %eax,%eax
  802377:	79 14                	jns    80238d <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  802379:	83 ec 04             	sub    $0x4,%esp
  80237c:	68 ef 2c 80 00       	push   $0x802cef
  802381:	6a 22                	push   $0x22
  802383:	68 06 2d 80 00       	push   $0x802d06
  802388:	e8 d5 dd ff ff       	call   800162 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  80238d:	8b 45 08             	mov    0x8(%ebp),%eax
  802390:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802395:	83 ec 08             	sub    $0x8,%esp
  802398:	68 c1 23 80 00       	push   $0x8023c1
  80239d:	6a 00                	push   $0x0
  80239f:	e8 6a e9 ff ff       	call   800d0e <sys_env_set_pgfault_upcall>
  8023a4:	83 c4 10             	add    $0x10,%esp
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	79 14                	jns    8023bf <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8023ab:	83 ec 04             	sub    $0x4,%esp
  8023ae:	68 14 2d 80 00       	push   $0x802d14
  8023b3:	6a 27                	push   $0x27
  8023b5:	68 06 2d 80 00       	push   $0x802d06
  8023ba:	e8 a3 dd ff ff       	call   800162 <_panic>
    
}
  8023bf:	c9                   	leave  
  8023c0:	c3                   	ret    

008023c1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023c1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023c2:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023c7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023c9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8023cc:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8023d0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8023d5:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8023d9:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8023db:	83 c4 08             	add    $0x8,%esp
	popal
  8023de:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8023df:	83 c4 04             	add    $0x4,%esp
	popfl
  8023e2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023e3:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023e4:	c3                   	ret    

008023e5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	c1 e8 16             	shr    $0x16,%eax
  8023f0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023f7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023fc:	f6 c1 01             	test   $0x1,%cl
  8023ff:	74 1d                	je     80241e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802401:	c1 ea 0c             	shr    $0xc,%edx
  802404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80240b:	f6 c2 01             	test   $0x1,%dl
  80240e:	74 0e                	je     80241e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802410:	c1 ea 0c             	shr    $0xc,%edx
  802413:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80241a:	ef 
  80241b:	0f b7 c0             	movzwl %ax,%eax
}
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    

00802420 <__udivdi3>:
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	53                   	push   %ebx
  802424:	83 ec 1c             	sub    $0x1c,%esp
  802427:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80242b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80242f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802433:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802437:	85 f6                	test   %esi,%esi
  802439:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80243d:	89 ca                	mov    %ecx,%edx
  80243f:	89 f8                	mov    %edi,%eax
  802441:	75 3d                	jne    802480 <__udivdi3+0x60>
  802443:	39 cf                	cmp    %ecx,%edi
  802445:	0f 87 c5 00 00 00    	ja     802510 <__udivdi3+0xf0>
  80244b:	85 ff                	test   %edi,%edi
  80244d:	89 fd                	mov    %edi,%ebp
  80244f:	75 0b                	jne    80245c <__udivdi3+0x3c>
  802451:	b8 01 00 00 00       	mov    $0x1,%eax
  802456:	31 d2                	xor    %edx,%edx
  802458:	f7 f7                	div    %edi
  80245a:	89 c5                	mov    %eax,%ebp
  80245c:	89 c8                	mov    %ecx,%eax
  80245e:	31 d2                	xor    %edx,%edx
  802460:	f7 f5                	div    %ebp
  802462:	89 c1                	mov    %eax,%ecx
  802464:	89 d8                	mov    %ebx,%eax
  802466:	89 cf                	mov    %ecx,%edi
  802468:	f7 f5                	div    %ebp
  80246a:	89 c3                	mov    %eax,%ebx
  80246c:	89 d8                	mov    %ebx,%eax
  80246e:	89 fa                	mov    %edi,%edx
  802470:	83 c4 1c             	add    $0x1c,%esp
  802473:	5b                   	pop    %ebx
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
  802478:	90                   	nop
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	39 ce                	cmp    %ecx,%esi
  802482:	77 74                	ja     8024f8 <__udivdi3+0xd8>
  802484:	0f bd fe             	bsr    %esi,%edi
  802487:	83 f7 1f             	xor    $0x1f,%edi
  80248a:	0f 84 98 00 00 00    	je     802528 <__udivdi3+0x108>
  802490:	bb 20 00 00 00       	mov    $0x20,%ebx
  802495:	89 f9                	mov    %edi,%ecx
  802497:	89 c5                	mov    %eax,%ebp
  802499:	29 fb                	sub    %edi,%ebx
  80249b:	d3 e6                	shl    %cl,%esi
  80249d:	89 d9                	mov    %ebx,%ecx
  80249f:	d3 ed                	shr    %cl,%ebp
  8024a1:	89 f9                	mov    %edi,%ecx
  8024a3:	d3 e0                	shl    %cl,%eax
  8024a5:	09 ee                	or     %ebp,%esi
  8024a7:	89 d9                	mov    %ebx,%ecx
  8024a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ad:	89 d5                	mov    %edx,%ebp
  8024af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024b3:	d3 ed                	shr    %cl,%ebp
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	d3 e2                	shl    %cl,%edx
  8024b9:	89 d9                	mov    %ebx,%ecx
  8024bb:	d3 e8                	shr    %cl,%eax
  8024bd:	09 c2                	or     %eax,%edx
  8024bf:	89 d0                	mov    %edx,%eax
  8024c1:	89 ea                	mov    %ebp,%edx
  8024c3:	f7 f6                	div    %esi
  8024c5:	89 d5                	mov    %edx,%ebp
  8024c7:	89 c3                	mov    %eax,%ebx
  8024c9:	f7 64 24 0c          	mull   0xc(%esp)
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	72 10                	jb     8024e1 <__udivdi3+0xc1>
  8024d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	d3 e6                	shl    %cl,%esi
  8024d9:	39 c6                	cmp    %eax,%esi
  8024db:	73 07                	jae    8024e4 <__udivdi3+0xc4>
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	75 03                	jne    8024e4 <__udivdi3+0xc4>
  8024e1:	83 eb 01             	sub    $0x1,%ebx
  8024e4:	31 ff                	xor    %edi,%edi
  8024e6:	89 d8                	mov    %ebx,%eax
  8024e8:	89 fa                	mov    %edi,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	31 ff                	xor    %edi,%edi
  8024fa:	31 db                	xor    %ebx,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	89 d8                	mov    %ebx,%eax
  802512:	f7 f7                	div    %edi
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 c3                	mov    %eax,%ebx
  802518:	89 d8                	mov    %ebx,%eax
  80251a:	89 fa                	mov    %edi,%edx
  80251c:	83 c4 1c             	add    $0x1c,%esp
  80251f:	5b                   	pop    %ebx
  802520:	5e                   	pop    %esi
  802521:	5f                   	pop    %edi
  802522:	5d                   	pop    %ebp
  802523:	c3                   	ret    
  802524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802528:	39 ce                	cmp    %ecx,%esi
  80252a:	72 0c                	jb     802538 <__udivdi3+0x118>
  80252c:	31 db                	xor    %ebx,%ebx
  80252e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802532:	0f 87 34 ff ff ff    	ja     80246c <__udivdi3+0x4c>
  802538:	bb 01 00 00 00       	mov    $0x1,%ebx
  80253d:	e9 2a ff ff ff       	jmp    80246c <__udivdi3+0x4c>
  802542:	66 90                	xchg   %ax,%ax
  802544:	66 90                	xchg   %ax,%ax
  802546:	66 90                	xchg   %ax,%ax
  802548:	66 90                	xchg   %ax,%ax
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <__umoddi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80255b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80255f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 d2                	test   %edx,%edx
  802569:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80256d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802571:	89 f3                	mov    %esi,%ebx
  802573:	89 3c 24             	mov    %edi,(%esp)
  802576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80257a:	75 1c                	jne    802598 <__umoddi3+0x48>
  80257c:	39 f7                	cmp    %esi,%edi
  80257e:	76 50                	jbe    8025d0 <__umoddi3+0x80>
  802580:	89 c8                	mov    %ecx,%eax
  802582:	89 f2                	mov    %esi,%edx
  802584:	f7 f7                	div    %edi
  802586:	89 d0                	mov    %edx,%eax
  802588:	31 d2                	xor    %edx,%edx
  80258a:	83 c4 1c             	add    $0x1c,%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    
  802592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802598:	39 f2                	cmp    %esi,%edx
  80259a:	89 d0                	mov    %edx,%eax
  80259c:	77 52                	ja     8025f0 <__umoddi3+0xa0>
  80259e:	0f bd ea             	bsr    %edx,%ebp
  8025a1:	83 f5 1f             	xor    $0x1f,%ebp
  8025a4:	75 5a                	jne    802600 <__umoddi3+0xb0>
  8025a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025aa:	0f 82 e0 00 00 00    	jb     802690 <__umoddi3+0x140>
  8025b0:	39 0c 24             	cmp    %ecx,(%esp)
  8025b3:	0f 86 d7 00 00 00    	jbe    802690 <__umoddi3+0x140>
  8025b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025c1:	83 c4 1c             	add    $0x1c,%esp
  8025c4:	5b                   	pop    %ebx
  8025c5:	5e                   	pop    %esi
  8025c6:	5f                   	pop    %edi
  8025c7:	5d                   	pop    %ebp
  8025c8:	c3                   	ret    
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	85 ff                	test   %edi,%edi
  8025d2:	89 fd                	mov    %edi,%ebp
  8025d4:	75 0b                	jne    8025e1 <__umoddi3+0x91>
  8025d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	f7 f7                	div    %edi
  8025df:	89 c5                	mov    %eax,%ebp
  8025e1:	89 f0                	mov    %esi,%eax
  8025e3:	31 d2                	xor    %edx,%edx
  8025e5:	f7 f5                	div    %ebp
  8025e7:	89 c8                	mov    %ecx,%eax
  8025e9:	f7 f5                	div    %ebp
  8025eb:	89 d0                	mov    %edx,%eax
  8025ed:	eb 99                	jmp    802588 <__umoddi3+0x38>
  8025ef:	90                   	nop
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 f2                	mov    %esi,%edx
  8025f4:	83 c4 1c             	add    $0x1c,%esp
  8025f7:	5b                   	pop    %ebx
  8025f8:	5e                   	pop    %esi
  8025f9:	5f                   	pop    %edi
  8025fa:	5d                   	pop    %ebp
  8025fb:	c3                   	ret    
  8025fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802600:	8b 34 24             	mov    (%esp),%esi
  802603:	bf 20 00 00 00       	mov    $0x20,%edi
  802608:	89 e9                	mov    %ebp,%ecx
  80260a:	29 ef                	sub    %ebp,%edi
  80260c:	d3 e0                	shl    %cl,%eax
  80260e:	89 f9                	mov    %edi,%ecx
  802610:	89 f2                	mov    %esi,%edx
  802612:	d3 ea                	shr    %cl,%edx
  802614:	89 e9                	mov    %ebp,%ecx
  802616:	09 c2                	or     %eax,%edx
  802618:	89 d8                	mov    %ebx,%eax
  80261a:	89 14 24             	mov    %edx,(%esp)
  80261d:	89 f2                	mov    %esi,%edx
  80261f:	d3 e2                	shl    %cl,%edx
  802621:	89 f9                	mov    %edi,%ecx
  802623:	89 54 24 04          	mov    %edx,0x4(%esp)
  802627:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	89 e9                	mov    %ebp,%ecx
  80262f:	89 c6                	mov    %eax,%esi
  802631:	d3 e3                	shl    %cl,%ebx
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 d0                	mov    %edx,%eax
  802637:	d3 e8                	shr    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	09 d8                	or     %ebx,%eax
  80263d:	89 d3                	mov    %edx,%ebx
  80263f:	89 f2                	mov    %esi,%edx
  802641:	f7 34 24             	divl   (%esp)
  802644:	89 d6                	mov    %edx,%esi
  802646:	d3 e3                	shl    %cl,%ebx
  802648:	f7 64 24 04          	mull   0x4(%esp)
  80264c:	39 d6                	cmp    %edx,%esi
  80264e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802652:	89 d1                	mov    %edx,%ecx
  802654:	89 c3                	mov    %eax,%ebx
  802656:	72 08                	jb     802660 <__umoddi3+0x110>
  802658:	75 11                	jne    80266b <__umoddi3+0x11b>
  80265a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80265e:	73 0b                	jae    80266b <__umoddi3+0x11b>
  802660:	2b 44 24 04          	sub    0x4(%esp),%eax
  802664:	1b 14 24             	sbb    (%esp),%edx
  802667:	89 d1                	mov    %edx,%ecx
  802669:	89 c3                	mov    %eax,%ebx
  80266b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80266f:	29 da                	sub    %ebx,%edx
  802671:	19 ce                	sbb    %ecx,%esi
  802673:	89 f9                	mov    %edi,%ecx
  802675:	89 f0                	mov    %esi,%eax
  802677:	d3 e0                	shl    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	d3 ea                	shr    %cl,%edx
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	d3 ee                	shr    %cl,%esi
  802681:	09 d0                	or     %edx,%eax
  802683:	89 f2                	mov    %esi,%edx
  802685:	83 c4 1c             	add    $0x1c,%esp
  802688:	5b                   	pop    %ebx
  802689:	5e                   	pop    %esi
  80268a:	5f                   	pop    %edi
  80268b:	5d                   	pop    %ebp
  80268c:	c3                   	ret    
  80268d:	8d 76 00             	lea    0x0(%esi),%esi
  802690:	29 f9                	sub    %edi,%ecx
  802692:	19 d6                	sbb    %edx,%esi
  802694:	89 74 24 04          	mov    %esi,0x4(%esp)
  802698:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80269c:	e9 18 ff ff ff       	jmp    8025b9 <__umoddi3+0x69>
