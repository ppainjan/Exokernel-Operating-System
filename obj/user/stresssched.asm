
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 3d 0b 00 00       	call   800b7a <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 9a 0e 00 00       	call   800ee3 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 38 0b 00 00       	call   800b99 <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 0f 0b 00 00       	call   800b99 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 08 40 80 00       	mov    0x804008,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 08 40 80 00       	mov    %eax,0x804008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 c0 26 80 00       	push   $0x8026c0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 e8 26 80 00       	push   $0x8026e8
  8000c4:	e8 8e 00 00 00       	call   800157 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 fb 26 80 00       	push   $0x8026fb
  8000de:	e8 4d 01 00 00       	call   800230 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000f8:	c7 05 0c 40 80 00 00 	movl   $0x0,0x80400c
  8000ff:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800102:	e8 73 0a 00 00       	call   800b7a <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x37>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
  800129:	e8 05 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80012e:	e8 0a 00 00 00       	call   80013d <exit>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800143:	e8 7b 11 00 00       	call   8012c3 <close_all>
	sys_env_destroy(0);
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	6a 00                	push   $0x0
  80014d:	e8 e7 09 00 00       	call   800b39 <sys_env_destroy>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800165:	e8 10 0a 00 00       	call   800b7a <sys_getenvid>
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	ff 75 0c             	pushl  0xc(%ebp)
  800170:	ff 75 08             	pushl  0x8(%ebp)
  800173:	56                   	push   %esi
  800174:	50                   	push   %eax
  800175:	68 24 27 80 00       	push   $0x802724
  80017a:	e8 b1 00 00 00       	call   800230 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	83 c4 18             	add    $0x18,%esp
  800182:	53                   	push   %ebx
  800183:	ff 75 10             	pushl  0x10(%ebp)
  800186:	e8 54 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  80018b:	c7 04 24 9a 2a 80 00 	movl   $0x802a9a,(%esp)
  800192:	e8 99 00 00 00       	call   800230 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x43>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 04             	sub    $0x4,%esp
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a7:	8b 13                	mov    (%ebx),%edx
  8001a9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ac:	89 03                	mov    %eax,(%ebx)
  8001ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ba:	75 1a                	jne    8001d6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	68 ff 00 00 00       	push   $0xff
  8001c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c7:	50                   	push   %eax
  8001c8:	e8 2f 09 00 00       	call   800afc <sys_cputs>
		b->idx = 0;
  8001cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ef:	00 00 00 
	b.cnt = 0;
  8001f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fc:	ff 75 0c             	pushl  0xc(%ebp)
  8001ff:	ff 75 08             	pushl  0x8(%ebp)
  800202:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	68 9d 01 80 00       	push   $0x80019d
  80020e:	e8 54 01 00 00       	call   800367 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800213:	83 c4 08             	add    $0x8,%esp
  800216:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800222:	50                   	push   %eax
  800223:	e8 d4 08 00 00       	call   800afc <sys_cputs>

	return b.cnt;
}
  800228:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800236:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800239:	50                   	push   %eax
  80023a:	ff 75 08             	pushl  0x8(%ebp)
  80023d:	e8 9d ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
  80024a:	83 ec 1c             	sub    $0x1c,%esp
  80024d:	89 c7                	mov    %eax,%edi
  80024f:	89 d6                	mov    %edx,%esi
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	8b 55 0c             	mov    0xc(%ebp),%edx
  800257:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800268:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026b:	39 d3                	cmp    %edx,%ebx
  80026d:	72 05                	jb     800274 <printnum+0x30>
  80026f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800272:	77 45                	ja     8002b9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800274:	83 ec 0c             	sub    $0xc,%esp
  800277:	ff 75 18             	pushl  0x18(%ebp)
  80027a:	8b 45 14             	mov    0x14(%ebp),%eax
  80027d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800280:	53                   	push   %ebx
  800281:	ff 75 10             	pushl  0x10(%ebp)
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028a:	ff 75 e0             	pushl  -0x20(%ebp)
  80028d:	ff 75 dc             	pushl  -0x24(%ebp)
  800290:	ff 75 d8             	pushl  -0x28(%ebp)
  800293:	e8 88 21 00 00       	call   802420 <__udivdi3>
  800298:	83 c4 18             	add    $0x18,%esp
  80029b:	52                   	push   %edx
  80029c:	50                   	push   %eax
  80029d:	89 f2                	mov    %esi,%edx
  80029f:	89 f8                	mov    %edi,%eax
  8002a1:	e8 9e ff ff ff       	call   800244 <printnum>
  8002a6:	83 c4 20             	add    $0x20,%esp
  8002a9:	eb 18                	jmp    8002c3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	56                   	push   %esi
  8002af:	ff 75 18             	pushl  0x18(%ebp)
  8002b2:	ff d7                	call   *%edi
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	eb 03                	jmp    8002bc <printnum+0x78>
  8002b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	85 db                	test   %ebx,%ebx
  8002c1:	7f e8                	jg     8002ab <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	56                   	push   %esi
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d6:	e8 75 22 00 00       	call   802550 <__umoddi3>
  8002db:	83 c4 14             	add    $0x14,%esp
  8002de:	0f be 80 47 27 80 00 	movsbl 0x802747(%eax),%eax
  8002e5:	50                   	push   %eax
  8002e6:	ff d7                	call   *%edi
}
  8002e8:	83 c4 10             	add    $0x10,%esp
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f6:	83 fa 01             	cmp    $0x1,%edx
  8002f9:	7e 0e                	jle    800309 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	8d 4a 08             	lea    0x8(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 02                	mov    (%edx),%eax
  800304:	8b 52 04             	mov    0x4(%edx),%edx
  800307:	eb 22                	jmp    80032b <getuint+0x38>
	else if (lflag)
  800309:	85 d2                	test   %edx,%edx
  80030b:	74 10                	je     80031d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 0e                	jmp    80032b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800333:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800337:	8b 10                	mov    (%eax),%edx
  800339:	3b 50 04             	cmp    0x4(%eax),%edx
  80033c:	73 0a                	jae    800348 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 45 08             	mov    0x8(%ebp),%eax
  800346:	88 02                	mov    %al,(%edx)
}
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800350:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800353:	50                   	push   %eax
  800354:	ff 75 10             	pushl  0x10(%ebp)
  800357:	ff 75 0c             	pushl  0xc(%ebp)
  80035a:	ff 75 08             	pushl  0x8(%ebp)
  80035d:	e8 05 00 00 00       	call   800367 <vprintfmt>
	va_end(ap);
}
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	c9                   	leave  
  800366:	c3                   	ret    

00800367 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	57                   	push   %edi
  80036b:	56                   	push   %esi
  80036c:	53                   	push   %ebx
  80036d:	83 ec 2c             	sub    $0x2c,%esp
  800370:	8b 75 08             	mov    0x8(%ebp),%esi
  800373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800376:	8b 7d 10             	mov    0x10(%ebp),%edi
  800379:	eb 12                	jmp    80038d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037b:	85 c0                	test   %eax,%eax
  80037d:	0f 84 89 03 00 00    	je     80070c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800383:	83 ec 08             	sub    $0x8,%esp
  800386:	53                   	push   %ebx
  800387:	50                   	push   %eax
  800388:	ff d6                	call   *%esi
  80038a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038d:	83 c7 01             	add    $0x1,%edi
  800390:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800394:	83 f8 25             	cmp    $0x25,%eax
  800397:	75 e2                	jne    80037b <vprintfmt+0x14>
  800399:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ab:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b7:	eb 07                	jmp    8003c0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bc:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8d 47 01             	lea    0x1(%edi),%eax
  8003c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c6:	0f b6 07             	movzbl (%edi),%eax
  8003c9:	0f b6 c8             	movzbl %al,%ecx
  8003cc:	83 e8 23             	sub    $0x23,%eax
  8003cf:	3c 55                	cmp    $0x55,%al
  8003d1:	0f 87 1a 03 00 00    	ja     8006f1 <vprintfmt+0x38a>
  8003d7:	0f b6 c0             	movzbl %al,%eax
  8003da:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e8:	eb d6                	jmp    8003c0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ff:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800402:	83 fa 09             	cmp    $0x9,%edx
  800405:	77 39                	ja     800440 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800407:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040a:	eb e9                	jmp    8003f5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 48 04             	lea    0x4(%eax),%ecx
  800412:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041d:	eb 27                	jmp    800446 <vprintfmt+0xdf>
  80041f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800422:	85 c0                	test   %eax,%eax
  800424:	b9 00 00 00 00       	mov    $0x0,%ecx
  800429:	0f 49 c8             	cmovns %eax,%ecx
  80042c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800432:	eb 8c                	jmp    8003c0 <vprintfmt+0x59>
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800437:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043e:	eb 80                	jmp    8003c0 <vprintfmt+0x59>
  800440:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800443:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800446:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044a:	0f 89 70 ff ff ff    	jns    8003c0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800450:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800456:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045d:	e9 5e ff ff ff       	jmp    8003c0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800462:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800468:	e9 53 ff ff ff       	jmp    8003c0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 50 04             	lea    0x4(%eax),%edx
  800473:	89 55 14             	mov    %edx,0x14(%ebp)
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	53                   	push   %ebx
  80047a:	ff 30                	pushl  (%eax)
  80047c:	ff d6                	call   *%esi
			break;
  80047e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800484:	e9 04 ff ff ff       	jmp    80038d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	8b 00                	mov    (%eax),%eax
  800494:	99                   	cltd   
  800495:	31 d0                	xor    %edx,%eax
  800497:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800499:	83 f8 0f             	cmp    $0xf,%eax
  80049c:	7f 0b                	jg     8004a9 <vprintfmt+0x142>
  80049e:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	75 18                	jne    8004c1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a9:	50                   	push   %eax
  8004aa:	68 5f 27 80 00       	push   $0x80275f
  8004af:	53                   	push   %ebx
  8004b0:	56                   	push   %esi
  8004b1:	e8 94 fe ff ff       	call   80034a <printfmt>
  8004b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bc:	e9 cc fe ff ff       	jmp    80038d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c1:	52                   	push   %edx
  8004c2:	68 6d 2c 80 00       	push   $0x802c6d
  8004c7:	53                   	push   %ebx
  8004c8:	56                   	push   %esi
  8004c9:	e8 7c fe ff ff       	call   80034a <printfmt>
  8004ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d4:	e9 b4 fe ff ff       	jmp    80038d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 50 04             	lea    0x4(%eax),%edx
  8004df:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e4:	85 ff                	test   %edi,%edi
  8004e6:	b8 58 27 80 00       	mov    $0x802758,%eax
  8004eb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f2:	0f 8e 94 00 00 00    	jle    80058c <vprintfmt+0x225>
  8004f8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fc:	0f 84 98 00 00 00    	je     80059a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	ff 75 d0             	pushl  -0x30(%ebp)
  800508:	57                   	push   %edi
  800509:	e8 86 02 00 00       	call   800794 <strnlen>
  80050e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800511:	29 c1                	sub    %eax,%ecx
  800513:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800516:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800519:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800520:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800523:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800525:	eb 0f                	jmp    800536 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	53                   	push   %ebx
  80052b:	ff 75 e0             	pushl  -0x20(%ebp)
  80052e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800530:	83 ef 01             	sub    $0x1,%edi
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	85 ff                	test   %edi,%edi
  800538:	7f ed                	jg     800527 <vprintfmt+0x1c0>
  80053a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800540:	85 c9                	test   %ecx,%ecx
  800542:	b8 00 00 00 00       	mov    $0x0,%eax
  800547:	0f 49 c1             	cmovns %ecx,%eax
  80054a:	29 c1                	sub    %eax,%ecx
  80054c:	89 75 08             	mov    %esi,0x8(%ebp)
  80054f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800552:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800555:	89 cb                	mov    %ecx,%ebx
  800557:	eb 4d                	jmp    8005a6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800559:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055d:	74 1b                	je     80057a <vprintfmt+0x213>
  80055f:	0f be c0             	movsbl %al,%eax
  800562:	83 e8 20             	sub    $0x20,%eax
  800565:	83 f8 5e             	cmp    $0x5e,%eax
  800568:	76 10                	jbe    80057a <vprintfmt+0x213>
					putch('?', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	ff 75 0c             	pushl  0xc(%ebp)
  800570:	6a 3f                	push   $0x3f
  800572:	ff 55 08             	call   *0x8(%ebp)
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	eb 0d                	jmp    800587 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	ff 75 0c             	pushl  0xc(%ebp)
  800580:	52                   	push   %edx
  800581:	ff 55 08             	call   *0x8(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800587:	83 eb 01             	sub    $0x1,%ebx
  80058a:	eb 1a                	jmp    8005a6 <vprintfmt+0x23f>
  80058c:	89 75 08             	mov    %esi,0x8(%ebp)
  80058f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800592:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800595:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800598:	eb 0c                	jmp    8005a6 <vprintfmt+0x23f>
  80059a:	89 75 08             	mov    %esi,0x8(%ebp)
  80059d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a6:	83 c7 01             	add    $0x1,%edi
  8005a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ad:	0f be d0             	movsbl %al,%edx
  8005b0:	85 d2                	test   %edx,%edx
  8005b2:	74 23                	je     8005d7 <vprintfmt+0x270>
  8005b4:	85 f6                	test   %esi,%esi
  8005b6:	78 a1                	js     800559 <vprintfmt+0x1f2>
  8005b8:	83 ee 01             	sub    $0x1,%esi
  8005bb:	79 9c                	jns    800559 <vprintfmt+0x1f2>
  8005bd:	89 df                	mov    %ebx,%edi
  8005bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c5:	eb 18                	jmp    8005df <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	6a 20                	push   $0x20
  8005cd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cf:	83 ef 01             	sub    $0x1,%edi
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	eb 08                	jmp    8005df <vprintfmt+0x278>
  8005d7:	89 df                	mov    %ebx,%edi
  8005d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005df:	85 ff                	test   %edi,%edi
  8005e1:	7f e4                	jg     8005c7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e6:	e9 a2 fd ff ff       	jmp    80038d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005eb:	83 fa 01             	cmp    $0x1,%edx
  8005ee:	7e 16                	jle    800606 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 08             	lea    0x8(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	8b 50 04             	mov    0x4(%eax),%edx
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800601:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800604:	eb 32                	jmp    800638 <vprintfmt+0x2d1>
	else if (lflag)
  800606:	85 d2                	test   %edx,%edx
  800608:	74 18                	je     800622 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 50 04             	lea    0x4(%eax),%edx
  800610:	89 55 14             	mov    %edx,0x14(%ebp)
  800613:	8b 00                	mov    (%eax),%eax
  800615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800618:	89 c1                	mov    %eax,%ecx
  80061a:	c1 f9 1f             	sar    $0x1f,%ecx
  80061d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800620:	eb 16                	jmp    800638 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800630:	89 c1                	mov    %eax,%ecx
  800632:	c1 f9 1f             	sar    $0x1f,%ecx
  800635:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800638:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800643:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800647:	79 74                	jns    8006bd <vprintfmt+0x356>
				putch('-', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 2d                	push   $0x2d
  80064f:	ff d6                	call   *%esi
				num = -(long long) num;
  800651:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800654:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800657:	f7 d8                	neg    %eax
  800659:	83 d2 00             	adc    $0x0,%edx
  80065c:	f7 da                	neg    %edx
  80065e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800661:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800666:	eb 55                	jmp    8006bd <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800668:	8d 45 14             	lea    0x14(%ebp),%eax
  80066b:	e8 83 fc ff ff       	call   8002f3 <getuint>
			base = 10;
  800670:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800675:	eb 46                	jmp    8006bd <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 74 fc ff ff       	call   8002f3 <getuint>
		        base = 8;
  80067f:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800684:	eb 37                	jmp    8006bd <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 30                	push   $0x30
  80068c:	ff d6                	call   *%esi
			putch('x', putdat);
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 78                	push   $0x78
  800694:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069f:	8b 00                	mov    (%eax),%eax
  8006a1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ae:	eb 0d                	jmp    8006bd <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b3:	e8 3b fc ff ff       	call   8002f3 <getuint>
			base = 16;
  8006b8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c4:	57                   	push   %edi
  8006c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c8:	51                   	push   %ecx
  8006c9:	52                   	push   %edx
  8006ca:	50                   	push   %eax
  8006cb:	89 da                	mov    %ebx,%edx
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	e8 70 fb ff ff       	call   800244 <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	e9 ae fc ff ff       	jmp    80038d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	51                   	push   %ecx
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ec:	e9 9c fc ff ff       	jmp    80038d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 25                	push   $0x25
  8006f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 03                	jmp    800701 <vprintfmt+0x39a>
  8006fe:	83 ef 01             	sub    $0x1,%edi
  800701:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800705:	75 f7                	jne    8006fe <vprintfmt+0x397>
  800707:	e9 81 fc ff ff       	jmp    80038d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070f:	5b                   	pop    %ebx
  800710:	5e                   	pop    %esi
  800711:	5f                   	pop    %edi
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 18             	sub    $0x18,%esp
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800720:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800723:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800727:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 26                	je     80075b <vsnprintf+0x47>
  800735:	85 d2                	test   %edx,%edx
  800737:	7e 22                	jle    80075b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800739:	ff 75 14             	pushl  0x14(%ebp)
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	68 2d 03 80 00       	push   $0x80032d
  800748:	e8 1a fc ff ff       	call   800367 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800750:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 05                	jmp    800760 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076b:	50                   	push   %eax
  80076c:	ff 75 10             	pushl  0x10(%ebp)
  80076f:	ff 75 0c             	pushl  0xc(%ebp)
  800772:	ff 75 08             	pushl  0x8(%ebp)
  800775:	e8 9a ff ff ff       	call   800714 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	eb 03                	jmp    80078c <strlen+0x10>
		n++;
  800789:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800790:	75 f7                	jne    800789 <strlen+0xd>
		n++;
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a2:	eb 03                	jmp    8007a7 <strnlen+0x13>
		n++;
  8007a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 c2                	cmp    %eax,%edx
  8007a9:	74 08                	je     8007b3 <strnlen+0x1f>
  8007ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007af:	75 f3                	jne    8007a4 <strnlen+0x10>
  8007b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ce:	84 db                	test   %bl,%bl
  8007d0:	75 ef                	jne    8007c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 9a ff ff ff       	call   80077c <strlen>
  8007e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 c5 ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 0f                	jmp    80081a <strncpy+0x23>
		*dst++ = *src;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	0f b6 01             	movzbl (%ecx),%eax
  800811:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800814:	80 39 01             	cmpb   $0x1,(%ecx)
  800817:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081a:	39 da                	cmp    %ebx,%edx
  80081c:	75 ed                	jne    80080b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
  800832:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 d2                	test   %edx,%edx
  800836:	74 21                	je     800859 <strlcpy+0x35>
  800838:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083c:	89 f2                	mov    %esi,%edx
  80083e:	eb 09                	jmp    800849 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800849:	39 c2                	cmp    %eax,%edx
  80084b:	74 09                	je     800856 <strlcpy+0x32>
  80084d:	0f b6 19             	movzbl (%ecx),%ebx
  800850:	84 db                	test   %bl,%bl
  800852:	75 ec                	jne    800840 <strlcpy+0x1c>
  800854:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800856:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800859:	29 f0                	sub    %esi,%eax
}
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800868:	eb 06                	jmp    800870 <strcmp+0x11>
		p++, q++;
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	84 c0                	test   %al,%al
  800875:	74 04                	je     80087b <strcmp+0x1c>
  800877:	3a 02                	cmp    (%edx),%al
  800879:	74 ef                	je     80086a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 c0             	movzbl %al,%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800894:	eb 06                	jmp    80089c <strncmp+0x17>
		n--, p++, q++;
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089c:	39 d8                	cmp    %ebx,%eax
  80089e:	74 15                	je     8008b5 <strncmp+0x30>
  8008a0:	0f b6 08             	movzbl (%eax),%ecx
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	74 04                	je     8008ab <strncmp+0x26>
  8008a7:	3a 0a                	cmp    (%edx),%cl
  8008a9:	74 eb                	je     800896 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
  8008b3:	eb 05                	jmp    8008ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c7:	eb 07                	jmp    8008d0 <strchr+0x13>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 0f                	je     8008dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f2                	jne    8008c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	eb 03                	jmp    8008ed <strfind+0xf>
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 04                	je     8008f8 <strfind+0x1a>
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	75 f2                	jne    8008ea <strfind+0xc>
			break;
	return (char *) s;
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 7d 08             	mov    0x8(%ebp),%edi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800906:	85 c9                	test   %ecx,%ecx
  800908:	74 36                	je     800940 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800910:	75 28                	jne    80093a <memset+0x40>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 23                	jne    80093a <memset+0x40>
		c &= 0xFF;
  800917:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091b:	89 d3                	mov    %edx,%ebx
  80091d:	c1 e3 08             	shl    $0x8,%ebx
  800920:	89 d6                	mov    %edx,%esi
  800922:	c1 e6 18             	shl    $0x18,%esi
  800925:	89 d0                	mov    %edx,%eax
  800927:	c1 e0 10             	shl    $0x10,%eax
  80092a:	09 f0                	or     %esi,%eax
  80092c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	09 d0                	or     %edx,%eax
  800932:	c1 e9 02             	shr    $0x2,%ecx
  800935:	fc                   	cld    
  800936:	f3 ab                	rep stos %eax,%es:(%edi)
  800938:	eb 06                	jmp    800940 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 f8                	mov    %edi,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800955:	39 c6                	cmp    %eax,%esi
  800957:	73 35                	jae    80098e <memmove+0x47>
  800959:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095c:	39 d0                	cmp    %edx,%eax
  80095e:	73 2e                	jae    80098e <memmove+0x47>
		s += n;
		d += n;
  800960:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800963:	89 d6                	mov    %edx,%esi
  800965:	09 fe                	or     %edi,%esi
  800967:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096d:	75 13                	jne    800982 <memmove+0x3b>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 0e                	jne    800982 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800974:	83 ef 04             	sub    $0x4,%edi
  800977:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097a:	c1 e9 02             	shr    $0x2,%ecx
  80097d:	fd                   	std    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 09                	jmp    80098b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800982:	83 ef 01             	sub    $0x1,%edi
  800985:	8d 72 ff             	lea    -0x1(%edx),%esi
  800988:	fd                   	std    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098b:	fc                   	cld    
  80098c:	eb 1d                	jmp    8009ab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	89 f2                	mov    %esi,%edx
  800990:	09 c2                	or     %eax,%edx
  800992:	f6 c2 03             	test   $0x3,%dl
  800995:	75 0f                	jne    8009a6 <memmove+0x5f>
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 0a                	jne    8009a6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099c:	c1 e9 02             	shr    $0x2,%ecx
  80099f:	89 c7                	mov    %eax,%edi
  8009a1:	fc                   	cld    
  8009a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a4:	eb 05                	jmp    8009ab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a6:	89 c7                	mov    %eax,%edi
  8009a8:	fc                   	cld    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b2:	ff 75 10             	pushl  0x10(%ebp)
  8009b5:	ff 75 0c             	pushl  0xc(%ebp)
  8009b8:	ff 75 08             	pushl  0x8(%ebp)
  8009bb:	e8 87 ff ff ff       	call   800947 <memmove>
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 c6                	mov    %eax,%esi
  8009cf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d2:	eb 1a                	jmp    8009ee <memcmp+0x2c>
		if (*s1 != *s2)
  8009d4:	0f b6 08             	movzbl (%eax),%ecx
  8009d7:	0f b6 1a             	movzbl (%edx),%ebx
  8009da:	38 d9                	cmp    %bl,%cl
  8009dc:	74 0a                	je     8009e8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009de:	0f b6 c1             	movzbl %cl,%eax
  8009e1:	0f b6 db             	movzbl %bl,%ebx
  8009e4:	29 d8                	sub    %ebx,%eax
  8009e6:	eb 0f                	jmp    8009f7 <memcmp+0x35>
		s1++, s2++;
  8009e8:	83 c0 01             	add    $0x1,%eax
  8009eb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	39 f0                	cmp    %esi,%eax
  8009f0:	75 e2                	jne    8009d4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a02:	89 c1                	mov    %eax,%ecx
  800a04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	eb 0a                	jmp    800a17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	39 da                	cmp    %ebx,%edx
  800a12:	74 07                	je     800a1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	39 c8                	cmp    %ecx,%eax
  800a19:	72 f2                	jb     800a0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2a:	eb 03                	jmp    800a2f <strtol+0x11>
		s++;
  800a2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	0f b6 01             	movzbl (%ecx),%eax
  800a32:	3c 20                	cmp    $0x20,%al
  800a34:	74 f6                	je     800a2c <strtol+0xe>
  800a36:	3c 09                	cmp    $0x9,%al
  800a38:	74 f2                	je     800a2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3a:	3c 2b                	cmp    $0x2b,%al
  800a3c:	75 0a                	jne    800a48 <strtol+0x2a>
		s++;
  800a3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a41:	bf 00 00 00 00       	mov    $0x0,%edi
  800a46:	eb 11                	jmp    800a59 <strtol+0x3b>
  800a48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4d:	3c 2d                	cmp    $0x2d,%al
  800a4f:	75 08                	jne    800a59 <strtol+0x3b>
		s++, neg = 1;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5f:	75 15                	jne    800a76 <strtol+0x58>
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	75 10                	jne    800a76 <strtol+0x58>
  800a66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6a:	75 7c                	jne    800ae8 <strtol+0xca>
		s += 2, base = 16;
  800a6c:	83 c1 02             	add    $0x2,%ecx
  800a6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a74:	eb 16                	jmp    800a8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	75 12                	jne    800a8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	75 08                	jne    800a8c <strtol+0x6e>
		s++, base = 8;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a94:	0f b6 11             	movzbl (%ecx),%edx
  800a97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 09             	cmp    $0x9,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0x8b>
			dig = *s - '0';
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 30             	sub    $0x30,%edx
  800aa7:	eb 22                	jmp    800acb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 08                	ja     800abb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 57             	sub    $0x57,%edx
  800ab9:	eb 10                	jmp    800acb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abe:	89 f3                	mov    %esi,%ebx
  800ac0:	80 fb 19             	cmp    $0x19,%bl
  800ac3:	77 16                	ja     800adb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac5:	0f be d2             	movsbl %dl,%edx
  800ac8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ace:	7d 0b                	jge    800adb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad9:	eb b9                	jmp    800a94 <strtol+0x76>

	if (endptr)
  800adb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adf:	74 0d                	je     800aee <strtol+0xd0>
		*endptr = (char *) s;
  800ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae4:	89 0e                	mov    %ecx,(%esi)
  800ae6:	eb 06                	jmp    800aee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae8:	85 db                	test   %ebx,%ebx
  800aea:	74 98                	je     800a84 <strtol+0x66>
  800aec:	eb 9e                	jmp    800a8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aee:	89 c2                	mov    %eax,%edx
  800af0:	f7 da                	neg    %edx
  800af2:	85 ff                	test   %edi,%edi
  800af4:	0f 45 c2             	cmovne %edx,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	89 c6                	mov    %eax,%esi
  800b13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b47:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	89 cb                	mov    %ecx,%ebx
  800b51:	89 cf                	mov    %ecx,%edi
  800b53:	89 ce                	mov    %ecx,%esi
  800b55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b57:	85 c0                	test   %eax,%eax
  800b59:	7e 17                	jle    800b72 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	50                   	push   %eax
  800b5f:	6a 03                	push   $0x3
  800b61:	68 3f 2a 80 00       	push   $0x802a3f
  800b66:	6a 23                	push   $0x23
  800b68:	68 5c 2a 80 00       	push   $0x802a5c
  800b6d:	e8 e5 f5 ff ff       	call   800157 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_yield>:

void
sys_yield(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba9:	89 d1                	mov    %edx,%ecx
  800bab:	89 d3                	mov    %edx,%ebx
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	be 00 00 00 00       	mov    $0x0,%esi
  800bc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	89 f7                	mov    %esi,%edi
  800bd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 04                	push   $0x4
  800be2:	68 3f 2a 80 00       	push   $0x802a3f
  800be7:	6a 23                	push   $0x23
  800be9:	68 5c 2a 80 00       	push   $0x802a5c
  800bee:	e8 64 f5 ff ff       	call   800157 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	b8 05 00 00 00       	mov    $0x5,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c15:	8b 75 18             	mov    0x18(%ebp),%esi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 05                	push   $0x5
  800c24:	68 3f 2a 80 00       	push   $0x802a3f
  800c29:	6a 23                	push   $0x23
  800c2b:	68 5c 2a 80 00       	push   $0x802a5c
  800c30:	e8 22 f5 ff ff       	call   800157 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 06                	push   $0x6
  800c66:	68 3f 2a 80 00       	push   $0x802a3f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 5c 2a 80 00       	push   $0x802a5c
  800c72:	e8 e0 f4 ff ff       	call   800157 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 08                	push   $0x8
  800ca8:	68 3f 2a 80 00       	push   $0x802a3f
  800cad:	6a 23                	push   $0x23
  800caf:	68 5c 2a 80 00       	push   $0x802a5c
  800cb4:	e8 9e f4 ff ff       	call   800157 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 09                	push   $0x9
  800cea:	68 3f 2a 80 00       	push   $0x802a3f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 5c 2a 80 00       	push   $0x802a5c
  800cf6:	e8 5c f4 ff ff       	call   800157 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 17                	jle    800d3d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 0a                	push   $0xa
  800d2c:	68 3f 2a 80 00       	push   $0x802a3f
  800d31:	6a 23                	push   $0x23
  800d33:	68 5c 2a 80 00       	push   $0x802a5c
  800d38:	e8 1a f4 ff ff       	call   800157 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	be 00 00 00 00       	mov    $0x0,%esi
  800d50:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d61:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 cb                	mov    %ecx,%ebx
  800d80:	89 cf                	mov    %ecx,%edi
  800d82:	89 ce                	mov    %ecx,%esi
  800d84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 0d                	push   $0xd
  800d90:	68 3f 2a 80 00       	push   $0x802a3f
  800d95:	6a 23                	push   $0x23
  800d97:	68 5c 2a 80 00       	push   $0x802a5c
  800d9c:	e8 b6 f3 ff ff       	call   800157 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db9:	89 d1                	mov    %edx,%ecx
  800dbb:	89 d3                	mov    %edx,%ebx
  800dbd:	89 d7                	mov    %edx,%edi
  800dbf:	89 d6                	mov    %edx,%esi
  800dc1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 df                	mov    %ebx,%edi
  800de0:	89 de                	mov    %ebx,%esi
  800de2:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	53                   	push   %ebx
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800df3:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800df5:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800df9:	74 2e                	je     800e29 <pgfault+0x40>
  800dfb:	89 c2                	mov    %eax,%edx
  800dfd:	c1 ea 16             	shr    $0x16,%edx
  800e00:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e07:	f6 c2 01             	test   $0x1,%dl
  800e0a:	74 1d                	je     800e29 <pgfault+0x40>
  800e0c:	89 c2                	mov    %eax,%edx
  800e0e:	c1 ea 0c             	shr    $0xc,%edx
  800e11:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e18:	f6 c1 01             	test   $0x1,%cl
  800e1b:	74 0c                	je     800e29 <pgfault+0x40>
  800e1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e24:	f6 c6 08             	test   $0x8,%dh
  800e27:	75 14                	jne    800e3d <pgfault+0x54>
        panic("Not copy-on-write\n");
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	68 6a 2a 80 00       	push   $0x802a6a
  800e31:	6a 1d                	push   $0x1d
  800e33:	68 7d 2a 80 00       	push   $0x802a7d
  800e38:	e8 1a f3 ff ff       	call   800157 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800e3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e42:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800e44:	83 ec 04             	sub    $0x4,%esp
  800e47:	6a 07                	push   $0x7
  800e49:	68 00 f0 7f 00       	push   $0x7ff000
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 63 fd ff ff       	call   800bb8 <sys_page_alloc>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	79 14                	jns    800e70 <pgfault+0x87>
		panic("page alloc failed \n");
  800e5c:	83 ec 04             	sub    $0x4,%esp
  800e5f:	68 88 2a 80 00       	push   $0x802a88
  800e64:	6a 28                	push   $0x28
  800e66:	68 7d 2a 80 00       	push   $0x802a7d
  800e6b:	e8 e7 f2 ff ff       	call   800157 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	68 00 10 00 00       	push   $0x1000
  800e78:	53                   	push   %ebx
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	e8 2c fb ff ff       	call   8009af <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800e83:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e8a:	53                   	push   %ebx
  800e8b:	6a 00                	push   $0x0
  800e8d:	68 00 f0 7f 00       	push   $0x7ff000
  800e92:	6a 00                	push   $0x0
  800e94:	e8 62 fd ff ff       	call   800bfb <sys_page_map>
  800e99:	83 c4 20             	add    $0x20,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	79 14                	jns    800eb4 <pgfault+0xcb>
        panic("page map failed \n");
  800ea0:	83 ec 04             	sub    $0x4,%esp
  800ea3:	68 9c 2a 80 00       	push   $0x802a9c
  800ea8:	6a 2b                	push   $0x2b
  800eaa:	68 7d 2a 80 00       	push   $0x802a7d
  800eaf:	e8 a3 f2 ff ff       	call   800157 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	68 00 f0 7f 00       	push   $0x7ff000
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 7a fd ff ff       	call   800c3d <sys_page_unmap>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	79 14                	jns    800ede <pgfault+0xf5>
        panic("page unmap failed\n");
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 ae 2a 80 00       	push   $0x802aae
  800ed2:	6a 2d                	push   $0x2d
  800ed4:	68 7d 2a 80 00       	push   $0x802a7d
  800ed9:	e8 79 f2 ff ff       	call   800157 <_panic>
	
	//panic("pgfault not implemented");
}
  800ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800eec:	68 e9 0d 80 00       	push   $0x800de9
  800ef1:	e8 57 13 00 00       	call   80224d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ef6:	b8 07 00 00 00       	mov    $0x7,%eax
  800efb:	cd 30                	int    $0x30
  800efd:	89 c7                	mov    %eax,%edi
  800eff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	79 12                	jns    800f1b <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800f09:	50                   	push   %eax
  800f0a:	68 c1 2a 80 00       	push   $0x802ac1
  800f0f:	6a 7a                	push   $0x7a
  800f11:	68 7d 2a 80 00       	push   $0x802a7d
  800f16:	e8 3c f2 ff ff       	call   800157 <_panic>
  800f1b:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f20:	85 c0                	test   %eax,%eax
  800f22:	75 21                	jne    800f45 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f24:	e8 51 fc ff ff       	call   800b7a <sys_getenvid>
  800f29:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f2e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f31:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f36:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f40:	e9 91 01 00 00       	jmp    8010d6 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  800f45:	89 d8                	mov    %ebx,%eax
  800f47:	c1 e8 16             	shr    $0x16,%eax
  800f4a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f51:	a8 01                	test   $0x1,%al
  800f53:	0f 84 06 01 00 00    	je     80105f <fork+0x17c>
  800f59:	89 d8                	mov    %ebx,%eax
  800f5b:	c1 e8 0c             	shr    $0xc,%eax
  800f5e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f65:	f6 c2 01             	test   $0x1,%dl
  800f68:	0f 84 f1 00 00 00    	je     80105f <fork+0x17c>
  800f6e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f75:	f6 c2 04             	test   $0x4,%dl
  800f78:	0f 84 e1 00 00 00    	je     80105f <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  800f7e:	89 c6                	mov    %eax,%esi
  800f80:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	c1 ea 16             	shr    $0x16,%edx
  800f88:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  800f8f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  800f96:	f6 c6 04             	test   $0x4,%dh
  800f99:	74 39                	je     800fd4 <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  800f9b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	25 07 0e 00 00       	and    $0xe07,%eax
  800faa:	50                   	push   %eax
  800fab:	56                   	push   %esi
  800fac:	ff 75 e4             	pushl  -0x1c(%ebp)
  800faf:	56                   	push   %esi
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 44 fc ff ff       	call   800bfb <sys_page_map>
  800fb7:	83 c4 20             	add    $0x20,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	0f 89 9d 00 00 00    	jns    80105f <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  800fc2:	50                   	push   %eax
  800fc3:	68 18 2b 80 00       	push   $0x802b18
  800fc8:	6a 4b                	push   $0x4b
  800fca:	68 7d 2a 80 00       	push   $0x802a7d
  800fcf:	e8 83 f1 ff ff       	call   800157 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  800fd4:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800fda:	74 59                	je     801035 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	68 05 08 00 00       	push   $0x805
  800fe4:	56                   	push   %esi
  800fe5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe8:	56                   	push   %esi
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 0b fc ff ff       	call   800bfb <sys_page_map>
  800ff0:	83 c4 20             	add    $0x20,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	79 12                	jns    801009 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  800ff7:	50                   	push   %eax
  800ff8:	68 48 2b 80 00       	push   $0x802b48
  800ffd:	6a 50                	push   $0x50
  800fff:	68 7d 2a 80 00       	push   $0x802a7d
  801004:	e8 4e f1 ff ff       	call   800157 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	68 05 08 00 00       	push   $0x805
  801011:	56                   	push   %esi
  801012:	6a 00                	push   $0x0
  801014:	56                   	push   %esi
  801015:	6a 00                	push   $0x0
  801017:	e8 df fb ff ff       	call   800bfb <sys_page_map>
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	79 3c                	jns    80105f <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  801023:	50                   	push   %eax
  801024:	68 70 2b 80 00       	push   $0x802b70
  801029:	6a 53                	push   $0x53
  80102b:	68 7d 2a 80 00       	push   $0x802a7d
  801030:	e8 22 f1 ff ff       	call   800157 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	6a 05                	push   $0x5
  80103a:	56                   	push   %esi
  80103b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103e:	56                   	push   %esi
  80103f:	6a 00                	push   $0x0
  801041:	e8 b5 fb ff ff       	call   800bfb <sys_page_map>
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 12                	jns    80105f <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  80104d:	50                   	push   %eax
  80104e:	68 98 2b 80 00       	push   $0x802b98
  801053:	6a 58                	push   $0x58
  801055:	68 7d 2a 80 00       	push   $0x802a7d
  80105a:	e8 f8 f0 ff ff       	call   800157 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  80105f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801065:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80106b:	0f 85 d4 fe ff ff    	jne    800f45 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  801071:	83 ec 04             	sub    $0x4,%esp
  801074:	6a 07                	push   $0x7
  801076:	68 00 f0 bf ee       	push   $0xeebff000
  80107b:	57                   	push   %edi
  80107c:	e8 37 fb ff ff       	call   800bb8 <sys_page_alloc>
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	79 17                	jns    80109f <fork+0x1bc>
        panic("page alloc failed\n");
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	68 d3 2a 80 00       	push   $0x802ad3
  801090:	68 87 00 00 00       	push   $0x87
  801095:	68 7d 2a 80 00       	push   $0x802a7d
  80109a:	e8 b8 f0 ff ff       	call   800157 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	68 bc 22 80 00       	push   $0x8022bc
  8010a7:	57                   	push   %edi
  8010a8:	e8 56 fc ff ff       	call   800d03 <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010ad:	83 c4 08             	add    $0x8,%esp
  8010b0:	6a 02                	push   $0x2
  8010b2:	57                   	push   %edi
  8010b3:	e8 c7 fb ff ff       	call   800c7f <sys_env_set_status>
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	79 15                	jns    8010d4 <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  8010bf:	50                   	push   %eax
  8010c0:	68 e6 2a 80 00       	push   $0x802ae6
  8010c5:	68 8c 00 00 00       	push   $0x8c
  8010ca:	68 7d 2a 80 00       	push   $0x802a7d
  8010cf:	e8 83 f0 ff ff       	call   800157 <_panic>

	return envid;
  8010d4:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  8010d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d9:	5b                   	pop    %ebx
  8010da:	5e                   	pop    %esi
  8010db:	5f                   	pop    %edi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <sfork>:

// Challenge!
int
sfork(void)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e4:	68 ff 2a 80 00       	push   $0x802aff
  8010e9:	68 98 00 00 00       	push   $0x98
  8010ee:	68 7d 2a 80 00       	push   $0x802a7d
  8010f3:	e8 5f f0 ff ff       	call   800157 <_panic>

008010f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801103:	c1 e8 0c             	shr    $0xc,%eax
}
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	05 00 00 00 30       	add    $0x30000000,%eax
  801113:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801118:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801125:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 ea 16             	shr    $0x16,%edx
  80112f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	74 11                	je     80114c <fd_alloc+0x2d>
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 ea 0c             	shr    $0xc,%edx
  801140:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	75 09                	jne    801155 <fd_alloc+0x36>
			*fd_store = fd;
  80114c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
  801153:	eb 17                	jmp    80116c <fd_alloc+0x4d>
  801155:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80115f:	75 c9                	jne    80112a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801161:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801167:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801174:	83 f8 1f             	cmp    $0x1f,%eax
  801177:	77 36                	ja     8011af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801179:	c1 e0 0c             	shl    $0xc,%eax
  80117c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801181:	89 c2                	mov    %eax,%edx
  801183:	c1 ea 16             	shr    $0x16,%edx
  801186:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118d:	f6 c2 01             	test   $0x1,%dl
  801190:	74 24                	je     8011b6 <fd_lookup+0x48>
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 0c             	shr    $0xc,%edx
  801197:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 1a                	je     8011bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ad:	eb 13                	jmp    8011c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b4:	eb 0c                	jmp    8011c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bb:	eb 05                	jmp    8011c2 <fd_lookup+0x54>
  8011bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011cd:	ba 40 2c 80 00       	mov    $0x802c40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d2:	eb 13                	jmp    8011e7 <dev_lookup+0x23>
  8011d4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011d7:	39 08                	cmp    %ecx,(%eax)
  8011d9:	75 0c                	jne    8011e7 <dev_lookup+0x23>
			*dev = devtab[i];
  8011db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e5:	eb 2e                	jmp    801215 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e7:	8b 02                	mov    (%edx),%eax
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	75 e7                	jne    8011d4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ed:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011f2:	8b 40 48             	mov    0x48(%eax),%eax
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	51                   	push   %ecx
  8011f9:	50                   	push   %eax
  8011fa:	68 c4 2b 80 00       	push   $0x802bc4
  8011ff:	e8 2c f0 ff ff       	call   800230 <cprintf>
	*dev = 0;
  801204:	8b 45 0c             	mov    0xc(%ebp),%eax
  801207:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	56                   	push   %esi
  80121b:	53                   	push   %ebx
  80121c:	83 ec 10             	sub    $0x10,%esp
  80121f:	8b 75 08             	mov    0x8(%ebp),%esi
  801222:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801225:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80122f:	c1 e8 0c             	shr    $0xc,%eax
  801232:	50                   	push   %eax
  801233:	e8 36 ff ff ff       	call   80116e <fd_lookup>
  801238:	83 c4 08             	add    $0x8,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 05                	js     801244 <fd_close+0x2d>
	    || fd != fd2)
  80123f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801242:	74 0c                	je     801250 <fd_close+0x39>
		return (must_exist ? r : 0);
  801244:	84 db                	test   %bl,%bl
  801246:	ba 00 00 00 00       	mov    $0x0,%edx
  80124b:	0f 44 c2             	cmove  %edx,%eax
  80124e:	eb 41                	jmp    801291 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801256:	50                   	push   %eax
  801257:	ff 36                	pushl  (%esi)
  801259:	e8 66 ff ff ff       	call   8011c4 <dev_lookup>
  80125e:	89 c3                	mov    %eax,%ebx
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 1a                	js     801281 <fd_close+0x6a>
		if (dev->dev_close)
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80126d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801272:	85 c0                	test   %eax,%eax
  801274:	74 0b                	je     801281 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	56                   	push   %esi
  80127a:	ff d0                	call   *%eax
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	56                   	push   %esi
  801285:	6a 00                	push   $0x0
  801287:	e8 b1 f9 ff ff       	call   800c3d <sys_page_unmap>
	return r;
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	89 d8                	mov    %ebx,%eax
}
  801291:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 08             	pushl  0x8(%ebp)
  8012a5:	e8 c4 fe ff ff       	call   80116e <fd_lookup>
  8012aa:	83 c4 08             	add    $0x8,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 10                	js     8012c1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	6a 01                	push   $0x1
  8012b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b9:	e8 59 ff ff ff       	call   801217 <fd_close>
  8012be:	83 c4 10             	add    $0x10,%esp
}
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <close_all>:

void
close_all(void)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	53                   	push   %ebx
  8012d3:	e8 c0 ff ff ff       	call   801298 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d8:	83 c3 01             	add    $0x1,%ebx
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	83 fb 20             	cmp    $0x20,%ebx
  8012e1:	75 ec                	jne    8012cf <close_all+0xc>
		close(i);
}
  8012e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	57                   	push   %edi
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 2c             	sub    $0x2c,%esp
  8012f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	ff 75 08             	pushl  0x8(%ebp)
  8012fb:	e8 6e fe ff ff       	call   80116e <fd_lookup>
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	0f 88 c1 00 00 00    	js     8013cc <dup+0xe4>
		return r;
	close(newfdnum);
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	56                   	push   %esi
  80130f:	e8 84 ff ff ff       	call   801298 <close>

	newfd = INDEX2FD(newfdnum);
  801314:	89 f3                	mov    %esi,%ebx
  801316:	c1 e3 0c             	shl    $0xc,%ebx
  801319:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80131f:	83 c4 04             	add    $0x4,%esp
  801322:	ff 75 e4             	pushl  -0x1c(%ebp)
  801325:	e8 de fd ff ff       	call   801108 <fd2data>
  80132a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80132c:	89 1c 24             	mov    %ebx,(%esp)
  80132f:	e8 d4 fd ff ff       	call   801108 <fd2data>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133a:	89 f8                	mov    %edi,%eax
  80133c:	c1 e8 16             	shr    $0x16,%eax
  80133f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801346:	a8 01                	test   $0x1,%al
  801348:	74 37                	je     801381 <dup+0x99>
  80134a:	89 f8                	mov    %edi,%eax
  80134c:	c1 e8 0c             	shr    $0xc,%eax
  80134f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801356:	f6 c2 01             	test   $0x1,%dl
  801359:	74 26                	je     801381 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80135b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	25 07 0e 00 00       	and    $0xe07,%eax
  80136a:	50                   	push   %eax
  80136b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136e:	6a 00                	push   $0x0
  801370:	57                   	push   %edi
  801371:	6a 00                	push   $0x0
  801373:	e8 83 f8 ff ff       	call   800bfb <sys_page_map>
  801378:	89 c7                	mov    %eax,%edi
  80137a:	83 c4 20             	add    $0x20,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 2e                	js     8013af <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801381:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801384:	89 d0                	mov    %edx,%eax
  801386:	c1 e8 0c             	shr    $0xc,%eax
  801389:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	25 07 0e 00 00       	and    $0xe07,%eax
  801398:	50                   	push   %eax
  801399:	53                   	push   %ebx
  80139a:	6a 00                	push   $0x0
  80139c:	52                   	push   %edx
  80139d:	6a 00                	push   $0x0
  80139f:	e8 57 f8 ff ff       	call   800bfb <sys_page_map>
  8013a4:	89 c7                	mov    %eax,%edi
  8013a6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013a9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ab:	85 ff                	test   %edi,%edi
  8013ad:	79 1d                	jns    8013cc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	6a 00                	push   $0x0
  8013b5:	e8 83 f8 ff ff       	call   800c3d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 76 f8 ff ff       	call   800c3d <sys_page_unmap>
	return r;
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	89 f8                	mov    %edi,%eax
}
  8013cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 14             	sub    $0x14,%esp
  8013db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	53                   	push   %ebx
  8013e3:	e8 86 fd ff ff       	call   80116e <fd_lookup>
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	89 c2                	mov    %eax,%edx
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 6d                	js     80145e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fb:	ff 30                	pushl  (%eax)
  8013fd:	e8 c2 fd ff ff       	call   8011c4 <dev_lookup>
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 4c                	js     801455 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801409:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140c:	8b 42 08             	mov    0x8(%edx),%eax
  80140f:	83 e0 03             	and    $0x3,%eax
  801412:	83 f8 01             	cmp    $0x1,%eax
  801415:	75 21                	jne    801438 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801417:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80141c:	8b 40 48             	mov    0x48(%eax),%eax
  80141f:	83 ec 04             	sub    $0x4,%esp
  801422:	53                   	push   %ebx
  801423:	50                   	push   %eax
  801424:	68 05 2c 80 00       	push   $0x802c05
  801429:	e8 02 ee ff ff       	call   800230 <cprintf>
		return -E_INVAL;
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801436:	eb 26                	jmp    80145e <read+0x8a>
	}
	if (!dev->dev_read)
  801438:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143b:	8b 40 08             	mov    0x8(%eax),%eax
  80143e:	85 c0                	test   %eax,%eax
  801440:	74 17                	je     801459 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	ff 75 10             	pushl  0x10(%ebp)
  801448:	ff 75 0c             	pushl  0xc(%ebp)
  80144b:	52                   	push   %edx
  80144c:	ff d0                	call   *%eax
  80144e:	89 c2                	mov    %eax,%edx
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	eb 09                	jmp    80145e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801455:	89 c2                	mov    %eax,%edx
  801457:	eb 05                	jmp    80145e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801459:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80145e:	89 d0                	mov    %edx,%eax
  801460:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	57                   	push   %edi
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801471:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801474:	bb 00 00 00 00       	mov    $0x0,%ebx
  801479:	eb 21                	jmp    80149c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	89 f0                	mov    %esi,%eax
  801480:	29 d8                	sub    %ebx,%eax
  801482:	50                   	push   %eax
  801483:	89 d8                	mov    %ebx,%eax
  801485:	03 45 0c             	add    0xc(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	57                   	push   %edi
  80148a:	e8 45 ff ff ff       	call   8013d4 <read>
		if (m < 0)
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 10                	js     8014a6 <readn+0x41>
			return m;
		if (m == 0)
  801496:	85 c0                	test   %eax,%eax
  801498:	74 0a                	je     8014a4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149a:	01 c3                	add    %eax,%ebx
  80149c:	39 f3                	cmp    %esi,%ebx
  80149e:	72 db                	jb     80147b <readn+0x16>
  8014a0:	89 d8                	mov    %ebx,%eax
  8014a2:	eb 02                	jmp    8014a6 <readn+0x41>
  8014a4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5e                   	pop    %esi
  8014ab:	5f                   	pop    %edi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 14             	sub    $0x14,%esp
  8014b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	53                   	push   %ebx
  8014bd:	e8 ac fc ff ff       	call   80116e <fd_lookup>
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 68                	js     801533 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d5:	ff 30                	pushl  (%eax)
  8014d7:	e8 e8 fc ff ff       	call   8011c4 <dev_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 47                	js     80152a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ea:	75 21                	jne    80150d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ec:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014f1:	8b 40 48             	mov    0x48(%eax),%eax
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	53                   	push   %ebx
  8014f8:	50                   	push   %eax
  8014f9:	68 21 2c 80 00       	push   $0x802c21
  8014fe:	e8 2d ed ff ff       	call   800230 <cprintf>
		return -E_INVAL;
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150b:	eb 26                	jmp    801533 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80150d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801510:	8b 52 0c             	mov    0xc(%edx),%edx
  801513:	85 d2                	test   %edx,%edx
  801515:	74 17                	je     80152e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	ff 75 10             	pushl  0x10(%ebp)
  80151d:	ff 75 0c             	pushl  0xc(%ebp)
  801520:	50                   	push   %eax
  801521:	ff d2                	call   *%edx
  801523:	89 c2                	mov    %eax,%edx
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	eb 09                	jmp    801533 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	eb 05                	jmp    801533 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80152e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801533:	89 d0                	mov    %edx,%eax
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <seek>:

int
seek(int fdnum, off_t offset)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801540:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	ff 75 08             	pushl  0x8(%ebp)
  801547:	e8 22 fc ff ff       	call   80116e <fd_lookup>
  80154c:	83 c4 08             	add    $0x8,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 0e                	js     801561 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801553:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801556:	8b 55 0c             	mov    0xc(%ebp),%edx
  801559:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 14             	sub    $0x14,%esp
  80156a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	53                   	push   %ebx
  801572:	e8 f7 fb ff ff       	call   80116e <fd_lookup>
  801577:	83 c4 08             	add    $0x8,%esp
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 65                	js     8015e5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	ff 30                	pushl  (%eax)
  80158c:	e8 33 fc ff ff       	call   8011c4 <dev_lookup>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 44                	js     8015dc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159f:	75 21                	jne    8015c2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a1:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a6:	8b 40 48             	mov    0x48(%eax),%eax
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	50                   	push   %eax
  8015ae:	68 e4 2b 80 00       	push   $0x802be4
  8015b3:	e8 78 ec ff ff       	call   800230 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c0:	eb 23                	jmp    8015e5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c5:	8b 52 18             	mov    0x18(%edx),%edx
  8015c8:	85 d2                	test   %edx,%edx
  8015ca:	74 14                	je     8015e0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	50                   	push   %eax
  8015d3:	ff d2                	call   *%edx
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	eb 09                	jmp    8015e5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	eb 05                	jmp    8015e5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 14             	sub    $0x14,%esp
  8015f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	ff 75 08             	pushl  0x8(%ebp)
  8015fd:	e8 6c fb ff ff       	call   80116e <fd_lookup>
  801602:	83 c4 08             	add    $0x8,%esp
  801605:	89 c2                	mov    %eax,%edx
  801607:	85 c0                	test   %eax,%eax
  801609:	78 58                	js     801663 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	ff 30                	pushl  (%eax)
  801617:	e8 a8 fb ff ff       	call   8011c4 <dev_lookup>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 37                	js     80165a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801626:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80162a:	74 32                	je     80165e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80162c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80162f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801636:	00 00 00 
	stat->st_isdir = 0;
  801639:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801640:	00 00 00 
	stat->st_dev = dev;
  801643:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	53                   	push   %ebx
  80164d:	ff 75 f0             	pushl  -0x10(%ebp)
  801650:	ff 50 14             	call   *0x14(%eax)
  801653:	89 c2                	mov    %eax,%edx
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	eb 09                	jmp    801663 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	eb 05                	jmp    801663 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80165e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801663:	89 d0                	mov    %edx,%eax
  801665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	6a 00                	push   $0x0
  801674:	ff 75 08             	pushl  0x8(%ebp)
  801677:	e8 e7 01 00 00       	call   801863 <open>
  80167c:	89 c3                	mov    %eax,%ebx
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	85 c0                	test   %eax,%eax
  801683:	78 1b                	js     8016a0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	ff 75 0c             	pushl  0xc(%ebp)
  80168b:	50                   	push   %eax
  80168c:	e8 5b ff ff ff       	call   8015ec <fstat>
  801691:	89 c6                	mov    %eax,%esi
	close(fd);
  801693:	89 1c 24             	mov    %ebx,(%esp)
  801696:	e8 fd fb ff ff       	call   801298 <close>
	return r;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	89 f0                	mov    %esi,%eax
}
  8016a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a3:	5b                   	pop    %ebx
  8016a4:	5e                   	pop    %esi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
  8016ac:	89 c6                	mov    %eax,%esi
  8016ae:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016b7:	75 12                	jne    8016cb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	6a 01                	push   $0x1
  8016be:	e8 de 0c 00 00       	call   8023a1 <ipc_find_env>
  8016c3:	a3 00 40 80 00       	mov    %eax,0x804000
  8016c8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016cb:	6a 07                	push   $0x7
  8016cd:	68 00 50 80 00       	push   $0x805000
  8016d2:	56                   	push   %esi
  8016d3:	ff 35 00 40 80 00    	pushl  0x804000
  8016d9:	e8 6f 0c 00 00       	call   80234d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016de:	83 c4 0c             	add    $0xc,%esp
  8016e1:	6a 00                	push   $0x0
  8016e3:	53                   	push   %ebx
  8016e4:	6a 00                	push   $0x0
  8016e6:	e8 f5 0b 00 00       	call   8022e0 <ipc_recv>
}
  8016eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801703:	8b 45 0c             	mov    0xc(%ebp),%eax
  801706:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170b:	ba 00 00 00 00       	mov    $0x0,%edx
  801710:	b8 02 00 00 00       	mov    $0x2,%eax
  801715:	e8 8d ff ff ff       	call   8016a7 <fsipc>
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 40 0c             	mov    0xc(%eax),%eax
  801728:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 06 00 00 00       	mov    $0x6,%eax
  801737:	e8 6b ff ff ff       	call   8016a7 <fsipc>
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 04             	sub    $0x4,%esp
  801745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	8b 40 0c             	mov    0xc(%eax),%eax
  80174e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801753:	ba 00 00 00 00       	mov    $0x0,%edx
  801758:	b8 05 00 00 00       	mov    $0x5,%eax
  80175d:	e8 45 ff ff ff       	call   8016a7 <fsipc>
  801762:	85 c0                	test   %eax,%eax
  801764:	78 2c                	js     801792 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	68 00 50 80 00       	push   $0x805000
  80176e:	53                   	push   %ebx
  80176f:	e8 41 f0 ff ff       	call   8007b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801774:	a1 80 50 80 00       	mov    0x805080,%eax
  801779:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80177f:	a1 84 50 80 00       	mov    0x805084,%eax
  801784:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	53                   	push   %ebx
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8017a1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017a6:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017ab:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017ae:	53                   	push   %ebx
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	68 08 50 80 00       	push   $0x805008
  8017b7:	e8 8b f1 ff ff       	call   800947 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c2:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8017c7:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8017d7:	e8 cb fe ff ff       	call   8016a7 <fsipc>
	//panic("devfile_write not implemented");
}
  8017dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	56                   	push   %esi
  8017e5:	53                   	push   %ebx
  8017e6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801804:	e8 9e fe ff ff       	call   8016a7 <fsipc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 4b                	js     80185a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80180f:	39 c6                	cmp    %eax,%esi
  801811:	73 16                	jae    801829 <devfile_read+0x48>
  801813:	68 54 2c 80 00       	push   $0x802c54
  801818:	68 5b 2c 80 00       	push   $0x802c5b
  80181d:	6a 7c                	push   $0x7c
  80181f:	68 70 2c 80 00       	push   $0x802c70
  801824:	e8 2e e9 ff ff       	call   800157 <_panic>
	assert(r <= PGSIZE);
  801829:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182e:	7e 16                	jle    801846 <devfile_read+0x65>
  801830:	68 7b 2c 80 00       	push   $0x802c7b
  801835:	68 5b 2c 80 00       	push   $0x802c5b
  80183a:	6a 7d                	push   $0x7d
  80183c:	68 70 2c 80 00       	push   $0x802c70
  801841:	e8 11 e9 ff ff       	call   800157 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	50                   	push   %eax
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	ff 75 0c             	pushl  0xc(%ebp)
  801852:	e8 f0 f0 ff ff       	call   800947 <memmove>
	return r;
  801857:	83 c4 10             	add    $0x10,%esp
}
  80185a:	89 d8                	mov    %ebx,%eax
  80185c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185f:	5b                   	pop    %ebx
  801860:	5e                   	pop    %esi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 20             	sub    $0x20,%esp
  80186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80186d:	53                   	push   %ebx
  80186e:	e8 09 ef ff ff       	call   80077c <strlen>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80187b:	7f 67                	jg     8018e4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801883:	50                   	push   %eax
  801884:	e8 96 f8 ff ff       	call   80111f <fd_alloc>
  801889:	83 c4 10             	add    $0x10,%esp
		return r;
  80188c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 57                	js     8018e9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	53                   	push   %ebx
  801896:	68 00 50 80 00       	push   $0x805000
  80189b:	e8 15 ef ff ff       	call   8007b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b0:	e8 f2 fd ff ff       	call   8016a7 <fsipc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	79 14                	jns    8018d2 <open+0x6f>
		fd_close(fd, 0);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	6a 00                	push   $0x0
  8018c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c6:	e8 4c f9 ff ff       	call   801217 <fd_close>
		return r;
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	89 da                	mov    %ebx,%edx
  8018d0:	eb 17                	jmp    8018e9 <open+0x86>
	}

	return fd2num(fd);
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d8:	e8 1b f8 ff ff       	call   8010f8 <fd2num>
  8018dd:	89 c2                	mov    %eax,%edx
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	eb 05                	jmp    8018e9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018e9:	89 d0                	mov    %edx,%eax
  8018eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801900:	e8 a2 fd ff ff       	call   8016a7 <fsipc>
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80190d:	68 87 2c 80 00       	push   $0x802c87
  801912:	ff 75 0c             	pushl  0xc(%ebp)
  801915:	e8 9b ee ff ff       	call   8007b5 <strcpy>
	return 0;
}
  80191a:	b8 00 00 00 00       	mov    $0x0,%eax
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 10             	sub    $0x10,%esp
  801928:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80192b:	53                   	push   %ebx
  80192c:	e8 a9 0a 00 00       	call   8023da <pageref>
  801931:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801934:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801939:	83 f8 01             	cmp    $0x1,%eax
  80193c:	75 10                	jne    80194e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	ff 73 0c             	pushl  0xc(%ebx)
  801944:	e8 c0 02 00 00       	call   801c09 <nsipc_close>
  801949:	89 c2                	mov    %eax,%edx
  80194b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80194e:	89 d0                	mov    %edx,%eax
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80195b:	6a 00                	push   $0x0
  80195d:	ff 75 10             	pushl  0x10(%ebp)
  801960:	ff 75 0c             	pushl  0xc(%ebp)
  801963:	8b 45 08             	mov    0x8(%ebp),%eax
  801966:	ff 70 0c             	pushl  0xc(%eax)
  801969:	e8 78 03 00 00       	call   801ce6 <nsipc_send>
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801976:	6a 00                	push   $0x0
  801978:	ff 75 10             	pushl  0x10(%ebp)
  80197b:	ff 75 0c             	pushl  0xc(%ebp)
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	ff 70 0c             	pushl  0xc(%eax)
  801984:	e8 f1 02 00 00       	call   801c7a <nsipc_recv>
}
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801991:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801994:	52                   	push   %edx
  801995:	50                   	push   %eax
  801996:	e8 d3 f7 ff ff       	call   80116e <fd_lookup>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 17                	js     8019b9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019ab:	39 08                	cmp    %ecx,(%eax)
  8019ad:	75 05                	jne    8019b4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019af:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b2:	eb 05                	jmp    8019b9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 1c             	sub    $0x1c,%esp
  8019c3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	e8 51 f7 ff ff       	call   80111f <fd_alloc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 1b                	js     8019f2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	68 07 04 00 00       	push   $0x407
  8019df:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e2:	6a 00                	push   $0x0
  8019e4:	e8 cf f1 ff ff       	call   800bb8 <sys_page_alloc>
  8019e9:	89 c3                	mov    %eax,%ebx
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	79 10                	jns    801a02 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	56                   	push   %esi
  8019f6:	e8 0e 02 00 00       	call   801c09 <nsipc_close>
		return r;
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	89 d8                	mov    %ebx,%eax
  801a00:	eb 24                	jmp    801a26 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a02:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a10:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a17:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	50                   	push   %eax
  801a1e:	e8 d5 f6 ff ff       	call   8010f8 <fd2num>
  801a23:	83 c4 10             	add    $0x10,%esp
}
  801a26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a33:	8b 45 08             	mov    0x8(%ebp),%eax
  801a36:	e8 50 ff ff ff       	call   80198b <fd2sockid>
		return r;
  801a3b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 1f                	js     801a60 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a41:	83 ec 04             	sub    $0x4,%esp
  801a44:	ff 75 10             	pushl  0x10(%ebp)
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 12 01 00 00       	call   801b62 <nsipc_accept>
  801a50:	83 c4 10             	add    $0x10,%esp
		return r;
  801a53:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a55:	85 c0                	test   %eax,%eax
  801a57:	78 07                	js     801a60 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a59:	e8 5d ff ff ff       	call   8019bb <alloc_sockfd>
  801a5e:	89 c1                	mov    %eax,%ecx
}
  801a60:	89 c8                	mov    %ecx,%eax
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6d:	e8 19 ff ff ff       	call   80198b <fd2sockid>
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 12                	js     801a88 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a76:	83 ec 04             	sub    $0x4,%esp
  801a79:	ff 75 10             	pushl  0x10(%ebp)
  801a7c:	ff 75 0c             	pushl  0xc(%ebp)
  801a7f:	50                   	push   %eax
  801a80:	e8 2d 01 00 00       	call   801bb2 <nsipc_bind>
  801a85:	83 c4 10             	add    $0x10,%esp
}
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <shutdown>:

int
shutdown(int s, int how)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	e8 f3 fe ff ff       	call   80198b <fd2sockid>
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 0f                	js     801aab <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	ff 75 0c             	pushl  0xc(%ebp)
  801aa2:	50                   	push   %eax
  801aa3:	e8 3f 01 00 00       	call   801be7 <nsipc_shutdown>
  801aa8:	83 c4 10             	add    $0x10,%esp
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	e8 d0 fe ff ff       	call   80198b <fd2sockid>
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 12                	js     801ad1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801abf:	83 ec 04             	sub    $0x4,%esp
  801ac2:	ff 75 10             	pushl  0x10(%ebp)
  801ac5:	ff 75 0c             	pushl  0xc(%ebp)
  801ac8:	50                   	push   %eax
  801ac9:	e8 55 01 00 00       	call   801c23 <nsipc_connect>
  801ace:	83 c4 10             	add    $0x10,%esp
}
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <listen>:

int
listen(int s, int backlog)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  801adc:	e8 aa fe ff ff       	call   80198b <fd2sockid>
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	78 0f                	js     801af4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ae5:	83 ec 08             	sub    $0x8,%esp
  801ae8:	ff 75 0c             	pushl  0xc(%ebp)
  801aeb:	50                   	push   %eax
  801aec:	e8 67 01 00 00       	call   801c58 <nsipc_listen>
  801af1:	83 c4 10             	add    $0x10,%esp
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801afc:	ff 75 10             	pushl  0x10(%ebp)
  801aff:	ff 75 0c             	pushl  0xc(%ebp)
  801b02:	ff 75 08             	pushl  0x8(%ebp)
  801b05:	e8 3a 02 00 00       	call   801d44 <nsipc_socket>
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 05                	js     801b16 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b11:	e8 a5 fe ff ff       	call   8019bb <alloc_sockfd>
}
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 04             	sub    $0x4,%esp
  801b1f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b21:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b28:	75 12                	jne    801b3c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	6a 02                	push   $0x2
  801b2f:	e8 6d 08 00 00       	call   8023a1 <ipc_find_env>
  801b34:	a3 04 40 80 00       	mov    %eax,0x804004
  801b39:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b3c:	6a 07                	push   $0x7
  801b3e:	68 00 60 80 00       	push   $0x806000
  801b43:	53                   	push   %ebx
  801b44:	ff 35 04 40 80 00    	pushl  0x804004
  801b4a:	e8 fe 07 00 00       	call   80234d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b4f:	83 c4 0c             	add    $0xc,%esp
  801b52:	6a 00                	push   $0x0
  801b54:	6a 00                	push   $0x0
  801b56:	6a 00                	push   $0x0
  801b58:	e8 83 07 00 00       	call   8022e0 <ipc_recv>
}
  801b5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	56                   	push   %esi
  801b66:	53                   	push   %ebx
  801b67:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b72:	8b 06                	mov    (%esi),%eax
  801b74:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b79:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7e:	e8 95 ff ff ff       	call   801b18 <nsipc>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 20                	js     801ba9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	ff 35 10 60 80 00    	pushl  0x806010
  801b92:	68 00 60 80 00       	push   $0x806000
  801b97:	ff 75 0c             	pushl  0xc(%ebp)
  801b9a:	e8 a8 ed ff ff       	call   800947 <memmove>
		*addrlen = ret->ret_addrlen;
  801b9f:	a1 10 60 80 00       	mov    0x806010,%eax
  801ba4:	89 06                	mov    %eax,(%esi)
  801ba6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ba9:	89 d8                	mov    %ebx,%eax
  801bab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	53                   	push   %ebx
  801bb6:	83 ec 08             	sub    $0x8,%esp
  801bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bc4:	53                   	push   %ebx
  801bc5:	ff 75 0c             	pushl  0xc(%ebp)
  801bc8:	68 04 60 80 00       	push   $0x806004
  801bcd:	e8 75 ed ff ff       	call   800947 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bd2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bd8:	b8 02 00 00 00       	mov    $0x2,%eax
  801bdd:	e8 36 ff ff ff       	call   801b18 <nsipc>
}
  801be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bed:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bfd:	b8 03 00 00 00       	mov    $0x3,%eax
  801c02:	e8 11 ff ff ff       	call   801b18 <nsipc>
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <nsipc_close>:

int
nsipc_close(int s)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c17:	b8 04 00 00 00       	mov    $0x4,%eax
  801c1c:	e8 f7 fe ff ff       	call   801b18 <nsipc>
}
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    

00801c23 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	53                   	push   %ebx
  801c27:	83 ec 08             	sub    $0x8,%esp
  801c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c35:	53                   	push   %ebx
  801c36:	ff 75 0c             	pushl  0xc(%ebp)
  801c39:	68 04 60 80 00       	push   $0x806004
  801c3e:	e8 04 ed ff ff       	call   800947 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c43:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c49:	b8 05 00 00 00       	mov    $0x5,%eax
  801c4e:	e8 c5 fe ff ff       	call   801b18 <nsipc>
}
  801c53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c61:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c69:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  801c73:	e8 a0 fe ff ff       	call   801b18 <nsipc>
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c8a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c90:	8b 45 14             	mov    0x14(%ebp),%eax
  801c93:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c98:	b8 07 00 00 00       	mov    $0x7,%eax
  801c9d:	e8 76 fe ff ff       	call   801b18 <nsipc>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 35                	js     801cdd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ca8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cad:	7f 04                	jg     801cb3 <nsipc_recv+0x39>
  801caf:	39 c6                	cmp    %eax,%esi
  801cb1:	7d 16                	jge    801cc9 <nsipc_recv+0x4f>
  801cb3:	68 93 2c 80 00       	push   $0x802c93
  801cb8:	68 5b 2c 80 00       	push   $0x802c5b
  801cbd:	6a 62                	push   $0x62
  801cbf:	68 a8 2c 80 00       	push   $0x802ca8
  801cc4:	e8 8e e4 ff ff       	call   800157 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cc9:	83 ec 04             	sub    $0x4,%esp
  801ccc:	50                   	push   %eax
  801ccd:	68 00 60 80 00       	push   $0x806000
  801cd2:	ff 75 0c             	pushl  0xc(%ebp)
  801cd5:	e8 6d ec ff ff       	call   800947 <memmove>
  801cda:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801cdd:	89 d8                	mov    %ebx,%eax
  801cdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce2:	5b                   	pop    %ebx
  801ce3:	5e                   	pop    %esi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	53                   	push   %ebx
  801cea:	83 ec 04             	sub    $0x4,%esp
  801ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801cf8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cfe:	7e 16                	jle    801d16 <nsipc_send+0x30>
  801d00:	68 b4 2c 80 00       	push   $0x802cb4
  801d05:	68 5b 2c 80 00       	push   $0x802c5b
  801d0a:	6a 6d                	push   $0x6d
  801d0c:	68 a8 2c 80 00       	push   $0x802ca8
  801d11:	e8 41 e4 ff ff       	call   800157 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	53                   	push   %ebx
  801d1a:	ff 75 0c             	pushl  0xc(%ebp)
  801d1d:	68 0c 60 80 00       	push   $0x80600c
  801d22:	e8 20 ec ff ff       	call   800947 <memmove>
	nsipcbuf.send.req_size = size;
  801d27:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d30:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d35:	b8 08 00 00 00       	mov    $0x8,%eax
  801d3a:	e8 d9 fd ff ff       	call   801b18 <nsipc>
}
  801d3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d55:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d62:	b8 09 00 00 00       	mov    $0x9,%eax
  801d67:	e8 ac fd ff ff       	call   801b18 <nsipc>
}
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	56                   	push   %esi
  801d72:	53                   	push   %ebx
  801d73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	ff 75 08             	pushl  0x8(%ebp)
  801d7c:	e8 87 f3 ff ff       	call   801108 <fd2data>
  801d81:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d83:	83 c4 08             	add    $0x8,%esp
  801d86:	68 c0 2c 80 00       	push   $0x802cc0
  801d8b:	53                   	push   %ebx
  801d8c:	e8 24 ea ff ff       	call   8007b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d91:	8b 46 04             	mov    0x4(%esi),%eax
  801d94:	2b 06                	sub    (%esi),%eax
  801d96:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d9c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801da3:	00 00 00 
	stat->st_dev = &devpipe;
  801da6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801dad:	30 80 00 
	return 0;
}
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
  801db5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	53                   	push   %ebx
  801dc0:	83 ec 0c             	sub    $0xc,%esp
  801dc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dc6:	53                   	push   %ebx
  801dc7:	6a 00                	push   $0x0
  801dc9:	e8 6f ee ff ff       	call   800c3d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dce:	89 1c 24             	mov    %ebx,(%esp)
  801dd1:	e8 32 f3 ff ff       	call   801108 <fd2data>
  801dd6:	83 c4 08             	add    $0x8,%esp
  801dd9:	50                   	push   %eax
  801dda:	6a 00                	push   $0x0
  801ddc:	e8 5c ee ff ff       	call   800c3d <sys_page_unmap>
}
  801de1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de4:	c9                   	leave  
  801de5:	c3                   	ret    

00801de6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	57                   	push   %edi
  801dea:	56                   	push   %esi
  801deb:	53                   	push   %ebx
  801dec:	83 ec 1c             	sub    $0x1c,%esp
  801def:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801df2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801df4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801df9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	ff 75 e0             	pushl  -0x20(%ebp)
  801e02:	e8 d3 05 00 00       	call   8023da <pageref>
  801e07:	89 c3                	mov    %eax,%ebx
  801e09:	89 3c 24             	mov    %edi,(%esp)
  801e0c:	e8 c9 05 00 00       	call   8023da <pageref>
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	39 c3                	cmp    %eax,%ebx
  801e16:	0f 94 c1             	sete   %cl
  801e19:	0f b6 c9             	movzbl %cl,%ecx
  801e1c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e1f:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801e25:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e28:	39 ce                	cmp    %ecx,%esi
  801e2a:	74 1b                	je     801e47 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e2c:	39 c3                	cmp    %eax,%ebx
  801e2e:	75 c4                	jne    801df4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e30:	8b 42 58             	mov    0x58(%edx),%eax
  801e33:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e36:	50                   	push   %eax
  801e37:	56                   	push   %esi
  801e38:	68 c7 2c 80 00       	push   $0x802cc7
  801e3d:	e8 ee e3 ff ff       	call   800230 <cprintf>
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	eb ad                	jmp    801df4 <_pipeisclosed+0xe>
	}
}
  801e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	83 ec 28             	sub    $0x28,%esp
  801e5b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e5e:	56                   	push   %esi
  801e5f:	e8 a4 f2 ff ff       	call   801108 <fd2data>
  801e64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	bf 00 00 00 00       	mov    $0x0,%edi
  801e6e:	eb 4b                	jmp    801ebb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e70:	89 da                	mov    %ebx,%edx
  801e72:	89 f0                	mov    %esi,%eax
  801e74:	e8 6d ff ff ff       	call   801de6 <_pipeisclosed>
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	75 48                	jne    801ec5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e7d:	e8 17 ed ff ff       	call   800b99 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e82:	8b 43 04             	mov    0x4(%ebx),%eax
  801e85:	8b 0b                	mov    (%ebx),%ecx
  801e87:	8d 51 20             	lea    0x20(%ecx),%edx
  801e8a:	39 d0                	cmp    %edx,%eax
  801e8c:	73 e2                	jae    801e70 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e91:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e95:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e98:	89 c2                	mov    %eax,%edx
  801e9a:	c1 fa 1f             	sar    $0x1f,%edx
  801e9d:	89 d1                	mov    %edx,%ecx
  801e9f:	c1 e9 1b             	shr    $0x1b,%ecx
  801ea2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ea5:	83 e2 1f             	and    $0x1f,%edx
  801ea8:	29 ca                	sub    %ecx,%edx
  801eaa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801eae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801eb2:	83 c0 01             	add    $0x1,%eax
  801eb5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb8:	83 c7 01             	add    $0x1,%edi
  801ebb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ebe:	75 c2                	jne    801e82 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ec0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec3:	eb 05                	jmp    801eca <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 18             	sub    $0x18,%esp
  801edb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ede:	57                   	push   %edi
  801edf:	e8 24 f2 ff ff       	call   801108 <fd2data>
  801ee4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eee:	eb 3d                	jmp    801f2d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ef0:	85 db                	test   %ebx,%ebx
  801ef2:	74 04                	je     801ef8 <devpipe_read+0x26>
				return i;
  801ef4:	89 d8                	mov    %ebx,%eax
  801ef6:	eb 44                	jmp    801f3c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ef8:	89 f2                	mov    %esi,%edx
  801efa:	89 f8                	mov    %edi,%eax
  801efc:	e8 e5 fe ff ff       	call   801de6 <_pipeisclosed>
  801f01:	85 c0                	test   %eax,%eax
  801f03:	75 32                	jne    801f37 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f05:	e8 8f ec ff ff       	call   800b99 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f0a:	8b 06                	mov    (%esi),%eax
  801f0c:	3b 46 04             	cmp    0x4(%esi),%eax
  801f0f:	74 df                	je     801ef0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f11:	99                   	cltd   
  801f12:	c1 ea 1b             	shr    $0x1b,%edx
  801f15:	01 d0                	add    %edx,%eax
  801f17:	83 e0 1f             	and    $0x1f,%eax
  801f1a:	29 d0                	sub    %edx,%eax
  801f1c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f24:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f27:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2a:	83 c3 01             	add    $0x1,%ebx
  801f2d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f30:	75 d8                	jne    801f0a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f32:	8b 45 10             	mov    0x10(%ebp),%eax
  801f35:	eb 05                	jmp    801f3c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	56                   	push   %esi
  801f48:	53                   	push   %ebx
  801f49:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4f:	50                   	push   %eax
  801f50:	e8 ca f1 ff ff       	call   80111f <fd_alloc>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	89 c2                	mov    %eax,%edx
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	0f 88 2c 01 00 00    	js     80208e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f62:	83 ec 04             	sub    $0x4,%esp
  801f65:	68 07 04 00 00       	push   $0x407
  801f6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6d:	6a 00                	push   $0x0
  801f6f:	e8 44 ec ff ff       	call   800bb8 <sys_page_alloc>
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	89 c2                	mov    %eax,%edx
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	0f 88 0d 01 00 00    	js     80208e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f81:	83 ec 0c             	sub    $0xc,%esp
  801f84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f87:	50                   	push   %eax
  801f88:	e8 92 f1 ff ff       	call   80111f <fd_alloc>
  801f8d:	89 c3                	mov    %eax,%ebx
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	0f 88 e2 00 00 00    	js     80207c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9a:	83 ec 04             	sub    $0x4,%esp
  801f9d:	68 07 04 00 00       	push   $0x407
  801fa2:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa5:	6a 00                	push   $0x0
  801fa7:	e8 0c ec ff ff       	call   800bb8 <sys_page_alloc>
  801fac:	89 c3                	mov    %eax,%ebx
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	0f 88 c3 00 00 00    	js     80207c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbf:	e8 44 f1 ff ff       	call   801108 <fd2data>
  801fc4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc6:	83 c4 0c             	add    $0xc,%esp
  801fc9:	68 07 04 00 00       	push   $0x407
  801fce:	50                   	push   %eax
  801fcf:	6a 00                	push   $0x0
  801fd1:	e8 e2 eb ff ff       	call   800bb8 <sys_page_alloc>
  801fd6:	89 c3                	mov    %eax,%ebx
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	0f 88 89 00 00 00    	js     80206c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe9:	e8 1a f1 ff ff       	call   801108 <fd2data>
  801fee:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ff5:	50                   	push   %eax
  801ff6:	6a 00                	push   $0x0
  801ff8:	56                   	push   %esi
  801ff9:	6a 00                	push   $0x0
  801ffb:	e8 fb eb ff ff       	call   800bfb <sys_page_map>
  802000:	89 c3                	mov    %eax,%ebx
  802002:	83 c4 20             	add    $0x20,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 55                	js     80205e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802009:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802012:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802017:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80201e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802024:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802027:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802029:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80202c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802033:	83 ec 0c             	sub    $0xc,%esp
  802036:	ff 75 f4             	pushl  -0xc(%ebp)
  802039:	e8 ba f0 ff ff       	call   8010f8 <fd2num>
  80203e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802041:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802043:	83 c4 04             	add    $0x4,%esp
  802046:	ff 75 f0             	pushl  -0x10(%ebp)
  802049:	e8 aa f0 ff ff       	call   8010f8 <fd2num>
  80204e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802051:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	ba 00 00 00 00       	mov    $0x0,%edx
  80205c:	eb 30                	jmp    80208e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80205e:	83 ec 08             	sub    $0x8,%esp
  802061:	56                   	push   %esi
  802062:	6a 00                	push   $0x0
  802064:	e8 d4 eb ff ff       	call   800c3d <sys_page_unmap>
  802069:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80206c:	83 ec 08             	sub    $0x8,%esp
  80206f:	ff 75 f0             	pushl  -0x10(%ebp)
  802072:	6a 00                	push   $0x0
  802074:	e8 c4 eb ff ff       	call   800c3d <sys_page_unmap>
  802079:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80207c:	83 ec 08             	sub    $0x8,%esp
  80207f:	ff 75 f4             	pushl  -0xc(%ebp)
  802082:	6a 00                	push   $0x0
  802084:	e8 b4 eb ff ff       	call   800c3d <sys_page_unmap>
  802089:	83 c4 10             	add    $0x10,%esp
  80208c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80208e:	89 d0                	mov    %edx,%eax
  802090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80209d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a0:	50                   	push   %eax
  8020a1:	ff 75 08             	pushl  0x8(%ebp)
  8020a4:	e8 c5 f0 ff ff       	call   80116e <fd_lookup>
  8020a9:	83 c4 10             	add    $0x10,%esp
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	78 18                	js     8020c8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b6:	e8 4d f0 ff ff       	call   801108 <fd2data>
	return _pipeisclosed(fd, p);
  8020bb:	89 c2                	mov    %eax,%edx
  8020bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c0:	e8 21 fd ff ff       	call   801de6 <_pipeisclosed>
  8020c5:	83 c4 10             	add    $0x10,%esp
}
  8020c8:	c9                   	leave  
  8020c9:	c3                   	ret    

008020ca <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020da:	68 df 2c 80 00       	push   $0x802cdf
  8020df:	ff 75 0c             	pushl  0xc(%ebp)
  8020e2:	e8 ce e6 ff ff       	call   8007b5 <strcpy>
	return 0;
}
  8020e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ec:	c9                   	leave  
  8020ed:	c3                   	ret    

008020ee <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020fa:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020ff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802105:	eb 2d                	jmp    802134 <devcons_write+0x46>
		m = n - tot;
  802107:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80210a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80210c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80210f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802114:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802117:	83 ec 04             	sub    $0x4,%esp
  80211a:	53                   	push   %ebx
  80211b:	03 45 0c             	add    0xc(%ebp),%eax
  80211e:	50                   	push   %eax
  80211f:	57                   	push   %edi
  802120:	e8 22 e8 ff ff       	call   800947 <memmove>
		sys_cputs(buf, m);
  802125:	83 c4 08             	add    $0x8,%esp
  802128:	53                   	push   %ebx
  802129:	57                   	push   %edi
  80212a:	e8 cd e9 ff ff       	call   800afc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80212f:	01 de                	add    %ebx,%esi
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	89 f0                	mov    %esi,%eax
  802136:	3b 75 10             	cmp    0x10(%ebp),%esi
  802139:	72 cc                	jb     802107 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80213b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80213e:	5b                   	pop    %ebx
  80213f:	5e                   	pop    %esi
  802140:	5f                   	pop    %edi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    

00802143 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	83 ec 08             	sub    $0x8,%esp
  802149:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80214e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802152:	74 2a                	je     80217e <devcons_read+0x3b>
  802154:	eb 05                	jmp    80215b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802156:	e8 3e ea ff ff       	call   800b99 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80215b:	e8 ba e9 ff ff       	call   800b1a <sys_cgetc>
  802160:	85 c0                	test   %eax,%eax
  802162:	74 f2                	je     802156 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802164:	85 c0                	test   %eax,%eax
  802166:	78 16                	js     80217e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802168:	83 f8 04             	cmp    $0x4,%eax
  80216b:	74 0c                	je     802179 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80216d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802170:	88 02                	mov    %al,(%edx)
	return 1;
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb 05                	jmp    80217e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802179:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80217e:	c9                   	leave  
  80217f:	c3                   	ret    

00802180 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802186:	8b 45 08             	mov    0x8(%ebp),%eax
  802189:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80218c:	6a 01                	push   $0x1
  80218e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802191:	50                   	push   %eax
  802192:	e8 65 e9 ff ff       	call   800afc <sys_cputs>
}
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	c9                   	leave  
  80219b:	c3                   	ret    

0080219c <getchar>:

int
getchar(void)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021a2:	6a 01                	push   $0x1
  8021a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021a7:	50                   	push   %eax
  8021a8:	6a 00                	push   $0x0
  8021aa:	e8 25 f2 ff ff       	call   8013d4 <read>
	if (r < 0)
  8021af:	83 c4 10             	add    $0x10,%esp
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	78 0f                	js     8021c5 <getchar+0x29>
		return r;
	if (r < 1)
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	7e 06                	jle    8021c0 <getchar+0x24>
		return -E_EOF;
	return c;
  8021ba:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021be:	eb 05                	jmp    8021c5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021c0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    

008021c7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d0:	50                   	push   %eax
  8021d1:	ff 75 08             	pushl  0x8(%ebp)
  8021d4:	e8 95 ef ff ff       	call   80116e <fd_lookup>
  8021d9:	83 c4 10             	add    $0x10,%esp
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	78 11                	js     8021f1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021e9:	39 10                	cmp    %edx,(%eax)
  8021eb:	0f 94 c0             	sete   %al
  8021ee:	0f b6 c0             	movzbl %al,%eax
}
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <opencons>:

int
opencons(void)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fc:	50                   	push   %eax
  8021fd:	e8 1d ef ff ff       	call   80111f <fd_alloc>
  802202:	83 c4 10             	add    $0x10,%esp
		return r;
  802205:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802207:	85 c0                	test   %eax,%eax
  802209:	78 3e                	js     802249 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80220b:	83 ec 04             	sub    $0x4,%esp
  80220e:	68 07 04 00 00       	push   $0x407
  802213:	ff 75 f4             	pushl  -0xc(%ebp)
  802216:	6a 00                	push   $0x0
  802218:	e8 9b e9 ff ff       	call   800bb8 <sys_page_alloc>
  80221d:	83 c4 10             	add    $0x10,%esp
		return r;
  802220:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802222:	85 c0                	test   %eax,%eax
  802224:	78 23                	js     802249 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802226:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80222c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802231:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802234:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80223b:	83 ec 0c             	sub    $0xc,%esp
  80223e:	50                   	push   %eax
  80223f:	e8 b4 ee ff ff       	call   8010f8 <fd2num>
  802244:	89 c2                	mov    %eax,%edx
  802246:	83 c4 10             	add    $0x10,%esp
}
  802249:	89 d0                	mov    %edx,%eax
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802253:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80225a:	75 2c                	jne    802288 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80225c:	83 ec 04             	sub    $0x4,%esp
  80225f:	6a 07                	push   $0x7
  802261:	68 00 f0 bf ee       	push   $0xeebff000
  802266:	6a 00                	push   $0x0
  802268:	e8 4b e9 ff ff       	call   800bb8 <sys_page_alloc>
  80226d:	83 c4 10             	add    $0x10,%esp
  802270:	85 c0                	test   %eax,%eax
  802272:	79 14                	jns    802288 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  802274:	83 ec 04             	sub    $0x4,%esp
  802277:	68 eb 2c 80 00       	push   $0x802ceb
  80227c:	6a 22                	push   $0x22
  80227e:	68 02 2d 80 00       	push   $0x802d02
  802283:	e8 cf de ff ff       	call   800157 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  802288:	8b 45 08             	mov    0x8(%ebp),%eax
  80228b:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802290:	83 ec 08             	sub    $0x8,%esp
  802293:	68 bc 22 80 00       	push   $0x8022bc
  802298:	6a 00                	push   $0x0
  80229a:	e8 64 ea ff ff       	call   800d03 <sys_env_set_pgfault_upcall>
  80229f:	83 c4 10             	add    $0x10,%esp
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	79 14                	jns    8022ba <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8022a6:	83 ec 04             	sub    $0x4,%esp
  8022a9:	68 10 2d 80 00       	push   $0x802d10
  8022ae:	6a 27                	push   $0x27
  8022b0:	68 02 2d 80 00       	push   $0x802d02
  8022b5:	e8 9d de ff ff       	call   800157 <_panic>
    
}
  8022ba:	c9                   	leave  
  8022bb:	c3                   	ret    

008022bc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022bc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022bd:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022c2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022c4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8022c7:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8022cb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8022d0:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8022d4:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8022d6:	83 c4 08             	add    $0x8,%esp
	popal
  8022d9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8022da:	83 c4 04             	add    $0x4,%esp
	popfl
  8022dd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022de:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022df:	c3                   	ret    

008022e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	56                   	push   %esi
  8022e4:	53                   	push   %ebx
  8022e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8022e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	74 0e                	je     802300 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8022f2:	83 ec 0c             	sub    $0xc,%esp
  8022f5:	50                   	push   %eax
  8022f6:	e8 6d ea ff ff       	call   800d68 <sys_ipc_recv>
  8022fb:	83 c4 10             	add    $0x10,%esp
  8022fe:	eb 10                	jmp    802310 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802300:	83 ec 0c             	sub    $0xc,%esp
  802303:	68 00 00 00 f0       	push   $0xf0000000
  802308:	e8 5b ea ff ff       	call   800d68 <sys_ipc_recv>
  80230d:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  802310:	85 c0                	test   %eax,%eax
  802312:	74 0e                	je     802322 <ipc_recv+0x42>
    	*from_env_store = 0;
  802314:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  80231a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  802320:	eb 24                	jmp    802346 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  802322:	85 f6                	test   %esi,%esi
  802324:	74 0a                	je     802330 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802326:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80232b:	8b 40 74             	mov    0x74(%eax),%eax
  80232e:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802330:	85 db                	test   %ebx,%ebx
  802332:	74 0a                	je     80233e <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802334:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802339:	8b 40 78             	mov    0x78(%eax),%eax
  80233c:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  80233e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802343:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802346:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802349:	5b                   	pop    %ebx
  80234a:	5e                   	pop    %esi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    

0080234d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80234d:	55                   	push   %ebp
  80234e:	89 e5                	mov    %esp,%ebp
  802350:	57                   	push   %edi
  802351:	56                   	push   %esi
  802352:	53                   	push   %ebx
  802353:	83 ec 0c             	sub    $0xc,%esp
  802356:	8b 7d 08             	mov    0x8(%ebp),%edi
  802359:	8b 75 0c             	mov    0xc(%ebp),%esi
  80235c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  80235f:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802361:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802366:	0f 44 d8             	cmove  %eax,%ebx
  802369:	eb 1c                	jmp    802387 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80236b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80236e:	74 12                	je     802382 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802370:	50                   	push   %eax
  802371:	68 34 2d 80 00       	push   $0x802d34
  802376:	6a 4b                	push   $0x4b
  802378:	68 4c 2d 80 00       	push   $0x802d4c
  80237d:	e8 d5 dd ff ff       	call   800157 <_panic>
        }	
        sys_yield();
  802382:	e8 12 e8 ff ff       	call   800b99 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802387:	ff 75 14             	pushl  0x14(%ebp)
  80238a:	53                   	push   %ebx
  80238b:	56                   	push   %esi
  80238c:	57                   	push   %edi
  80238d:	e8 b3 e9 ff ff       	call   800d45 <sys_ipc_try_send>
  802392:	83 c4 10             	add    $0x10,%esp
  802395:	85 c0                	test   %eax,%eax
  802397:	75 d2                	jne    80236b <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802399:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239c:	5b                   	pop    %ebx
  80239d:	5e                   	pop    %esi
  80239e:	5f                   	pop    %edi
  80239f:	5d                   	pop    %ebp
  8023a0:	c3                   	ret    

008023a1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023a1:	55                   	push   %ebp
  8023a2:	89 e5                	mov    %esp,%ebp
  8023a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023ac:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023b5:	8b 52 50             	mov    0x50(%edx),%edx
  8023b8:	39 ca                	cmp    %ecx,%edx
  8023ba:	75 0d                	jne    8023c9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8023bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023c4:	8b 40 48             	mov    0x48(%eax),%eax
  8023c7:	eb 0f                	jmp    8023d8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023c9:	83 c0 01             	add    $0x1,%eax
  8023cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023d1:	75 d9                	jne    8023ac <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023d8:	5d                   	pop    %ebp
  8023d9:	c3                   	ret    

008023da <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023da:	55                   	push   %ebp
  8023db:	89 e5                	mov    %esp,%ebp
  8023dd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e0:	89 d0                	mov    %edx,%eax
  8023e2:	c1 e8 16             	shr    $0x16,%eax
  8023e5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023ec:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023f1:	f6 c1 01             	test   $0x1,%cl
  8023f4:	74 1d                	je     802413 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023f6:	c1 ea 0c             	shr    $0xc,%edx
  8023f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802400:	f6 c2 01             	test   $0x1,%dl
  802403:	74 0e                	je     802413 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802405:	c1 ea 0c             	shr    $0xc,%edx
  802408:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80240f:	ef 
  802410:	0f b7 c0             	movzwl %ax,%eax
}
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
  802415:	66 90                	xchg   %ax,%ax
  802417:	66 90                	xchg   %ax,%ax
  802419:	66 90                	xchg   %ax,%ax
  80241b:	66 90                	xchg   %ax,%ax
  80241d:	66 90                	xchg   %ax,%ax
  80241f:	90                   	nop

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
