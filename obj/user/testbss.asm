
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 00 23 80 00       	push   $0x802300
  80003e:	e8 dc 01 00 00       	call   80021f <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 7b 23 80 00       	push   $0x80237b
  80005b:	6a 11                	push   $0x11
  80005d:	68 98 23 80 00       	push   $0x802398
  800062:	e8 df 00 00 00       	call   800146 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 20 23 80 00       	push   $0x802320
  80009b:	6a 16                	push   $0x16
  80009d:	68 98 23 80 00       	push   $0x802398
  8000a2:	e8 9f 00 00 00       	call   800146 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 48 23 80 00       	push   $0x802348
  8000b9:	e8 61 01 00 00       	call   80021f <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 a7 23 80 00       	push   $0x8023a7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 98 23 80 00       	push   $0x802398
  8000d7:	e8 6a 00 00 00       	call   800146 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e7:	c7 05 20 40 c0 00 00 	movl   $0x0,0xc04020
  8000ee:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f1:	e8 73 0a 00 00       	call   800b69 <sys_getenvid>
  8000f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800103:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800108:	85 db                	test   %ebx,%ebx
  80010a:	7e 07                	jle    800113 <libmain+0x37>
		binaryname = argv[0];
  80010c:	8b 06                	mov    (%esi),%eax
  80010e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800113:	83 ec 08             	sub    $0x8,%esp
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	e8 16 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011d:	e8 0a 00 00 00       	call   80012c <exit>
}
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800132:	e8 6c 0e 00 00       	call   800fa3 <close_all>
	sys_env_destroy(0);
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	6a 00                	push   $0x0
  80013c:	e8 e7 09 00 00       	call   800b28 <sys_env_destroy>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	56                   	push   %esi
  80014a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800154:	e8 10 0a 00 00       	call   800b69 <sys_getenvid>
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	ff 75 0c             	pushl  0xc(%ebp)
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	56                   	push   %esi
  800163:	50                   	push   %eax
  800164:	68 c8 23 80 00       	push   $0x8023c8
  800169:	e8 b1 00 00 00       	call   80021f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016e:	83 c4 18             	add    $0x18,%esp
  800171:	53                   	push   %ebx
  800172:	ff 75 10             	pushl  0x10(%ebp)
  800175:	e8 54 00 00 00       	call   8001ce <vcprintf>
	cprintf("\n");
  80017a:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  800181:	e8 99 00 00 00       	call   80021f <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800189:	cc                   	int3   
  80018a:	eb fd                	jmp    800189 <_panic+0x43>

0080018c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 13                	mov    (%ebx),%edx
  800198:	8d 42 01             	lea    0x1(%edx),%eax
  80019b:	89 03                	mov    %eax,(%ebx)
  80019d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a9:	75 1a                	jne    8001c5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	68 ff 00 00 00       	push   $0xff
  8001b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 2f 09 00 00       	call   800aeb <sys_cputs>
		b->idx = 0;
  8001bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001de:	00 00 00 
	b.cnt = 0;
  8001e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	68 8c 01 80 00       	push   $0x80018c
  8001fd:	e8 54 01 00 00       	call   800356 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800202:	83 c4 08             	add    $0x8,%esp
  800205:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800211:	50                   	push   %eax
  800212:	e8 d4 08 00 00       	call   800aeb <sys_cputs>

	return b.cnt;
}
  800217:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800225:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800228:	50                   	push   %eax
  800229:	ff 75 08             	pushl  0x8(%ebp)
  80022c:	e8 9d ff ff ff       	call   8001ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 1c             	sub    $0x1c,%esp
  80023c:	89 c7                	mov    %eax,%edi
  80023e:	89 d6                	mov    %edx,%esi
  800240:	8b 45 08             	mov    0x8(%ebp),%eax
  800243:	8b 55 0c             	mov    0xc(%ebp),%edx
  800246:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800249:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800254:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800257:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025a:	39 d3                	cmp    %edx,%ebx
  80025c:	72 05                	jb     800263 <printnum+0x30>
  80025e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800261:	77 45                	ja     8002a8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 18             	pushl  0x18(%ebp)
  800269:	8b 45 14             	mov    0x14(%ebp),%eax
  80026c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	ff 75 e4             	pushl  -0x1c(%ebp)
  800279:	ff 75 e0             	pushl  -0x20(%ebp)
  80027c:	ff 75 dc             	pushl  -0x24(%ebp)
  80027f:	ff 75 d8             	pushl  -0x28(%ebp)
  800282:	e8 e9 1d 00 00       	call   802070 <__udivdi3>
  800287:	83 c4 18             	add    $0x18,%esp
  80028a:	52                   	push   %edx
  80028b:	50                   	push   %eax
  80028c:	89 f2                	mov    %esi,%edx
  80028e:	89 f8                	mov    %edi,%eax
  800290:	e8 9e ff ff ff       	call   800233 <printnum>
  800295:	83 c4 20             	add    $0x20,%esp
  800298:	eb 18                	jmp    8002b2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	ff d7                	call   *%edi
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	eb 03                	jmp    8002ab <printnum+0x78>
  8002a8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	83 eb 01             	sub    $0x1,%ebx
  8002ae:	85 db                	test   %ebx,%ebx
  8002b0:	7f e8                	jg     80029a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	56                   	push   %esi
  8002b6:	83 ec 04             	sub    $0x4,%esp
  8002b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c5:	e8 d6 1e 00 00       	call   8021a0 <__umoddi3>
  8002ca:	83 c4 14             	add    $0x14,%esp
  8002cd:	0f be 80 eb 23 80 00 	movsbl 0x8023eb(%eax),%eax
  8002d4:	50                   	push   %eax
  8002d5:	ff d7                	call   *%edi
}
  8002d7:	83 c4 10             	add    $0x10,%esp
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getuint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 0e                	jmp    80031a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800322:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800326:	8b 10                	mov    (%eax),%edx
  800328:	3b 50 04             	cmp    0x4(%eax),%edx
  80032b:	73 0a                	jae    800337 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800330:	89 08                	mov    %ecx,(%eax)
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	88 02                	mov    %al,(%edx)
}
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800342:	50                   	push   %eax
  800343:	ff 75 10             	pushl  0x10(%ebp)
  800346:	ff 75 0c             	pushl  0xc(%ebp)
  800349:	ff 75 08             	pushl  0x8(%ebp)
  80034c:	e8 05 00 00 00       	call   800356 <vprintfmt>
	va_end(ap);
}
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	c9                   	leave  
  800355:	c3                   	ret    

00800356 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	57                   	push   %edi
  80035a:	56                   	push   %esi
  80035b:	53                   	push   %ebx
  80035c:	83 ec 2c             	sub    $0x2c,%esp
  80035f:	8b 75 08             	mov    0x8(%ebp),%esi
  800362:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800365:	8b 7d 10             	mov    0x10(%ebp),%edi
  800368:	eb 12                	jmp    80037c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036a:	85 c0                	test   %eax,%eax
  80036c:	0f 84 89 03 00 00    	je     8006fb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	53                   	push   %ebx
  800376:	50                   	push   %eax
  800377:	ff d6                	call   *%esi
  800379:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037c:	83 c7 01             	add    $0x1,%edi
  80037f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800383:	83 f8 25             	cmp    $0x25,%eax
  800386:	75 e2                	jne    80036a <vprintfmt+0x14>
  800388:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80038c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800393:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a6:	eb 07                	jmp    8003af <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ab:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8d 47 01             	lea    0x1(%edi),%eax
  8003b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b5:	0f b6 07             	movzbl (%edi),%eax
  8003b8:	0f b6 c8             	movzbl %al,%ecx
  8003bb:	83 e8 23             	sub    $0x23,%eax
  8003be:	3c 55                	cmp    $0x55,%al
  8003c0:	0f 87 1a 03 00 00    	ja     8006e0 <vprintfmt+0x38a>
  8003c6:	0f b6 c0             	movzbl %al,%eax
  8003c9:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d7:	eb d6                	jmp    8003af <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003eb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ee:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f1:	83 fa 09             	cmp    $0x9,%edx
  8003f4:	77 39                	ja     80042f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f9:	eb e9                	jmp    8003e4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 48 04             	lea    0x4(%eax),%ecx
  800401:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800404:	8b 00                	mov    (%eax),%eax
  800406:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040c:	eb 27                	jmp    800435 <vprintfmt+0xdf>
  80040e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800411:	85 c0                	test   %eax,%eax
  800413:	b9 00 00 00 00       	mov    $0x0,%ecx
  800418:	0f 49 c8             	cmovns %eax,%ecx
  80041b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800421:	eb 8c                	jmp    8003af <vprintfmt+0x59>
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800426:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042d:	eb 80                	jmp    8003af <vprintfmt+0x59>
  80042f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800432:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800435:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800439:	0f 89 70 ff ff ff    	jns    8003af <vprintfmt+0x59>
				width = precision, precision = -1;
  80043f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800442:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800445:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044c:	e9 5e ff ff ff       	jmp    8003af <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800451:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800457:	e9 53 ff ff ff       	jmp    8003af <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	53                   	push   %ebx
  800469:	ff 30                	pushl  (%eax)
  80046b:	ff d6                	call   *%esi
			break;
  80046d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800473:	e9 04 ff ff ff       	jmp    80037c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	8b 00                	mov    (%eax),%eax
  800483:	99                   	cltd   
  800484:	31 d0                	xor    %edx,%eax
  800486:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800488:	83 f8 0f             	cmp    $0xf,%eax
  80048b:	7f 0b                	jg     800498 <vprintfmt+0x142>
  80048d:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800494:	85 d2                	test   %edx,%edx
  800496:	75 18                	jne    8004b0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800498:	50                   	push   %eax
  800499:	68 03 24 80 00       	push   $0x802403
  80049e:	53                   	push   %ebx
  80049f:	56                   	push   %esi
  8004a0:	e8 94 fe ff ff       	call   800339 <printfmt>
  8004a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ab:	e9 cc fe ff ff       	jmp    80037c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b0:	52                   	push   %edx
  8004b1:	68 b9 27 80 00       	push   $0x8027b9
  8004b6:	53                   	push   %ebx
  8004b7:	56                   	push   %esi
  8004b8:	e8 7c fe ff ff       	call   800339 <printfmt>
  8004bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c3:	e9 b4 fe ff ff       	jmp    80037c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d3:	85 ff                	test   %edi,%edi
  8004d5:	b8 fc 23 80 00       	mov    $0x8023fc,%eax
  8004da:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e1:	0f 8e 94 00 00 00    	jle    80057b <vprintfmt+0x225>
  8004e7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004eb:	0f 84 98 00 00 00    	je     800589 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f7:	57                   	push   %edi
  8004f8:	e8 86 02 00 00       	call   800783 <strnlen>
  8004fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800500:	29 c1                	sub    %eax,%ecx
  800502:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800508:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800512:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	eb 0f                	jmp    800525 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	53                   	push   %ebx
  80051a:	ff 75 e0             	pushl  -0x20(%ebp)
  80051d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	83 ef 01             	sub    $0x1,%edi
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	85 ff                	test   %edi,%edi
  800527:	7f ed                	jg     800516 <vprintfmt+0x1c0>
  800529:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80052f:	85 c9                	test   %ecx,%ecx
  800531:	b8 00 00 00 00       	mov    $0x0,%eax
  800536:	0f 49 c1             	cmovns %ecx,%eax
  800539:	29 c1                	sub    %eax,%ecx
  80053b:	89 75 08             	mov    %esi,0x8(%ebp)
  80053e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800541:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800544:	89 cb                	mov    %ecx,%ebx
  800546:	eb 4d                	jmp    800595 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800548:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054c:	74 1b                	je     800569 <vprintfmt+0x213>
  80054e:	0f be c0             	movsbl %al,%eax
  800551:	83 e8 20             	sub    $0x20,%eax
  800554:	83 f8 5e             	cmp    $0x5e,%eax
  800557:	76 10                	jbe    800569 <vprintfmt+0x213>
					putch('?', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	ff 75 0c             	pushl  0xc(%ebp)
  80055f:	6a 3f                	push   $0x3f
  800561:	ff 55 08             	call   *0x8(%ebp)
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	eb 0d                	jmp    800576 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	ff 75 0c             	pushl  0xc(%ebp)
  80056f:	52                   	push   %edx
  800570:	ff 55 08             	call   *0x8(%ebp)
  800573:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	83 eb 01             	sub    $0x1,%ebx
  800579:	eb 1a                	jmp    800595 <vprintfmt+0x23f>
  80057b:	89 75 08             	mov    %esi,0x8(%ebp)
  80057e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800581:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800584:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800587:	eb 0c                	jmp    800595 <vprintfmt+0x23f>
  800589:	89 75 08             	mov    %esi,0x8(%ebp)
  80058c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800592:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800595:	83 c7 01             	add    $0x1,%edi
  800598:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059c:	0f be d0             	movsbl %al,%edx
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	74 23                	je     8005c6 <vprintfmt+0x270>
  8005a3:	85 f6                	test   %esi,%esi
  8005a5:	78 a1                	js     800548 <vprintfmt+0x1f2>
  8005a7:	83 ee 01             	sub    $0x1,%esi
  8005aa:	79 9c                	jns    800548 <vprintfmt+0x1f2>
  8005ac:	89 df                	mov    %ebx,%edi
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b4:	eb 18                	jmp    8005ce <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 20                	push   $0x20
  8005bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005be:	83 ef 01             	sub    $0x1,%edi
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	eb 08                	jmp    8005ce <vprintfmt+0x278>
  8005c6:	89 df                	mov    %ebx,%edi
  8005c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ce:	85 ff                	test   %edi,%edi
  8005d0:	7f e4                	jg     8005b6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d5:	e9 a2 fd ff ff       	jmp    80037c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005da:	83 fa 01             	cmp    $0x1,%edx
  8005dd:	7e 16                	jle    8005f5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 08             	lea    0x8(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 50 04             	mov    0x4(%eax),%edx
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f3:	eb 32                	jmp    800627 <vprintfmt+0x2d1>
	else if (lflag)
  8005f5:	85 d2                	test   %edx,%edx
  8005f7:	74 18                	je     800611 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	89 c1                	mov    %eax,%ecx
  800609:	c1 f9 1f             	sar    $0x1f,%ecx
  80060c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060f:	eb 16                	jmp    800627 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	89 c1                	mov    %eax,%ecx
  800621:	c1 f9 1f             	sar    $0x1f,%ecx
  800624:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800627:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800632:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800636:	79 74                	jns    8006ac <vprintfmt+0x356>
				putch('-', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 2d                	push   $0x2d
  80063e:	ff d6                	call   *%esi
				num = -(long long) num;
  800640:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800643:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800646:	f7 d8                	neg    %eax
  800648:	83 d2 00             	adc    $0x0,%edx
  80064b:	f7 da                	neg    %edx
  80064d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800650:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800655:	eb 55                	jmp    8006ac <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800657:	8d 45 14             	lea    0x14(%ebp),%eax
  80065a:	e8 83 fc ff ff       	call   8002e2 <getuint>
			base = 10;
  80065f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800664:	eb 46                	jmp    8006ac <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 74 fc ff ff       	call   8002e2 <getuint>
		        base = 8;
  80066e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800673:	eb 37                	jmp    8006ac <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 30                	push   $0x30
  80067b:	ff d6                	call   *%esi
			putch('x', putdat);
  80067d:	83 c4 08             	add    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 78                	push   $0x78
  800683:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8d 50 04             	lea    0x4(%eax),%edx
  80068b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800695:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800698:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069d:	eb 0d                	jmp    8006ac <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 3b fc ff ff       	call   8002e2 <getuint>
			base = 16;
  8006a7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ac:	83 ec 0c             	sub    $0xc,%esp
  8006af:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b3:	57                   	push   %edi
  8006b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b7:	51                   	push   %ecx
  8006b8:	52                   	push   %edx
  8006b9:	50                   	push   %eax
  8006ba:	89 da                	mov    %ebx,%edx
  8006bc:	89 f0                	mov    %esi,%eax
  8006be:	e8 70 fb ff ff       	call   800233 <printnum>
			break;
  8006c3:	83 c4 20             	add    $0x20,%esp
  8006c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c9:	e9 ae fc ff ff       	jmp    80037c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	51                   	push   %ecx
  8006d3:	ff d6                	call   *%esi
			break;
  8006d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006db:	e9 9c fc ff ff       	jmp    80037c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	6a 25                	push   $0x25
  8006e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb 03                	jmp    8006f0 <vprintfmt+0x39a>
  8006ed:	83 ef 01             	sub    $0x1,%edi
  8006f0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f4:	75 f7                	jne    8006ed <vprintfmt+0x397>
  8006f6:	e9 81 fc ff ff       	jmp    80037c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fe:	5b                   	pop    %ebx
  8006ff:	5e                   	pop    %esi
  800700:	5f                   	pop    %edi
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	83 ec 18             	sub    $0x18,%esp
  800709:	8b 45 08             	mov    0x8(%ebp),%eax
  80070c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800712:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800716:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800719:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800720:	85 c0                	test   %eax,%eax
  800722:	74 26                	je     80074a <vsnprintf+0x47>
  800724:	85 d2                	test   %edx,%edx
  800726:	7e 22                	jle    80074a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800728:	ff 75 14             	pushl  0x14(%ebp)
  80072b:	ff 75 10             	pushl  0x10(%ebp)
  80072e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	68 1c 03 80 00       	push   $0x80031c
  800737:	e8 1a fc ff ff       	call   800356 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb 05                	jmp    80074f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074f:	c9                   	leave  
  800750:	c3                   	ret    

00800751 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075a:	50                   	push   %eax
  80075b:	ff 75 10             	pushl  0x10(%ebp)
  80075e:	ff 75 0c             	pushl  0xc(%ebp)
  800761:	ff 75 08             	pushl  0x8(%ebp)
  800764:	e8 9a ff ff ff       	call   800703 <vsnprintf>
	va_end(ap);

	return rc;
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800771:	b8 00 00 00 00       	mov    $0x0,%eax
  800776:	eb 03                	jmp    80077b <strlen+0x10>
		n++;
  800778:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077f:	75 f7                	jne    800778 <strlen+0xd>
		n++;
	return n;
}
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800789:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078c:	ba 00 00 00 00       	mov    $0x0,%edx
  800791:	eb 03                	jmp    800796 <strnlen+0x13>
		n++;
  800793:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800796:	39 c2                	cmp    %eax,%edx
  800798:	74 08                	je     8007a2 <strnlen+0x1f>
  80079a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80079e:	75 f3                	jne    800793 <strnlen+0x10>
  8007a0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ae:	89 c2                	mov    %eax,%edx
  8007b0:	83 c2 01             	add    $0x1,%edx
  8007b3:	83 c1 01             	add    $0x1,%ecx
  8007b6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ba:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007bd:	84 db                	test   %bl,%bl
  8007bf:	75 ef                	jne    8007b0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cb:	53                   	push   %ebx
  8007cc:	e8 9a ff ff ff       	call   80076b <strlen>
  8007d1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d4:	ff 75 0c             	pushl  0xc(%ebp)
  8007d7:	01 d8                	add    %ebx,%eax
  8007d9:	50                   	push   %eax
  8007da:	e8 c5 ff ff ff       	call   8007a4 <strcpy>
	return dst;
}
  8007df:	89 d8                	mov    %ebx,%eax
  8007e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	89 f3                	mov    %esi,%ebx
  8007f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f6:	89 f2                	mov    %esi,%edx
  8007f8:	eb 0f                	jmp    800809 <strncpy+0x23>
		*dst++ = *src;
  8007fa:	83 c2 01             	add    $0x1,%edx
  8007fd:	0f b6 01             	movzbl (%ecx),%eax
  800800:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800803:	80 39 01             	cmpb   $0x1,(%ecx)
  800806:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	39 da                	cmp    %ebx,%edx
  80080b:	75 ed                	jne    8007fa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081e:	8b 55 10             	mov    0x10(%ebp),%edx
  800821:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800823:	85 d2                	test   %edx,%edx
  800825:	74 21                	je     800848 <strlcpy+0x35>
  800827:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082b:	89 f2                	mov    %esi,%edx
  80082d:	eb 09                	jmp    800838 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082f:	83 c2 01             	add    $0x1,%edx
  800832:	83 c1 01             	add    $0x1,%ecx
  800835:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800838:	39 c2                	cmp    %eax,%edx
  80083a:	74 09                	je     800845 <strlcpy+0x32>
  80083c:	0f b6 19             	movzbl (%ecx),%ebx
  80083f:	84 db                	test   %bl,%bl
  800841:	75 ec                	jne    80082f <strlcpy+0x1c>
  800843:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800845:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800848:	29 f0                	sub    %esi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800857:	eb 06                	jmp    80085f <strcmp+0x11>
		p++, q++;
  800859:	83 c1 01             	add    $0x1,%ecx
  80085c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085f:	0f b6 01             	movzbl (%ecx),%eax
  800862:	84 c0                	test   %al,%al
  800864:	74 04                	je     80086a <strcmp+0x1c>
  800866:	3a 02                	cmp    (%edx),%al
  800868:	74 ef                	je     800859 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086a:	0f b6 c0             	movzbl %al,%eax
  80086d:	0f b6 12             	movzbl (%edx),%edx
  800870:	29 d0                	sub    %edx,%eax
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	53                   	push   %ebx
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087e:	89 c3                	mov    %eax,%ebx
  800880:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800883:	eb 06                	jmp    80088b <strncmp+0x17>
		n--, p++, q++;
  800885:	83 c0 01             	add    $0x1,%eax
  800888:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088b:	39 d8                	cmp    %ebx,%eax
  80088d:	74 15                	je     8008a4 <strncmp+0x30>
  80088f:	0f b6 08             	movzbl (%eax),%ecx
  800892:	84 c9                	test   %cl,%cl
  800894:	74 04                	je     80089a <strncmp+0x26>
  800896:	3a 0a                	cmp    (%edx),%cl
  800898:	74 eb                	je     800885 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 00             	movzbl (%eax),%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
  8008a2:	eb 05                	jmp    8008a9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b6:	eb 07                	jmp    8008bf <strchr+0x13>
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 0f                	je     8008cb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	0f b6 10             	movzbl (%eax),%edx
  8008c2:	84 d2                	test   %dl,%dl
  8008c4:	75 f2                	jne    8008b8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d7:	eb 03                	jmp    8008dc <strfind+0xf>
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008df:	38 ca                	cmp    %cl,%dl
  8008e1:	74 04                	je     8008e7 <strfind+0x1a>
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	75 f2                	jne    8008d9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	57                   	push   %edi
  8008ed:	56                   	push   %esi
  8008ee:	53                   	push   %ebx
  8008ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f5:	85 c9                	test   %ecx,%ecx
  8008f7:	74 36                	je     80092f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ff:	75 28                	jne    800929 <memset+0x40>
  800901:	f6 c1 03             	test   $0x3,%cl
  800904:	75 23                	jne    800929 <memset+0x40>
		c &= 0xFF;
  800906:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090a:	89 d3                	mov    %edx,%ebx
  80090c:	c1 e3 08             	shl    $0x8,%ebx
  80090f:	89 d6                	mov    %edx,%esi
  800911:	c1 e6 18             	shl    $0x18,%esi
  800914:	89 d0                	mov    %edx,%eax
  800916:	c1 e0 10             	shl    $0x10,%eax
  800919:	09 f0                	or     %esi,%eax
  80091b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80091d:	89 d8                	mov    %ebx,%eax
  80091f:	09 d0                	or     %edx,%eax
  800921:	c1 e9 02             	shr    $0x2,%ecx
  800924:	fc                   	cld    
  800925:	f3 ab                	rep stos %eax,%es:(%edi)
  800927:	eb 06                	jmp    80092f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800929:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092c:	fc                   	cld    
  80092d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092f:	89 f8                	mov    %edi,%eax
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800944:	39 c6                	cmp    %eax,%esi
  800946:	73 35                	jae    80097d <memmove+0x47>
  800948:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094b:	39 d0                	cmp    %edx,%eax
  80094d:	73 2e                	jae    80097d <memmove+0x47>
		s += n;
		d += n;
  80094f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 d6                	mov    %edx,%esi
  800954:	09 fe                	or     %edi,%esi
  800956:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095c:	75 13                	jne    800971 <memmove+0x3b>
  80095e:	f6 c1 03             	test   $0x3,%cl
  800961:	75 0e                	jne    800971 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800963:	83 ef 04             	sub    $0x4,%edi
  800966:	8d 72 fc             	lea    -0x4(%edx),%esi
  800969:	c1 e9 02             	shr    $0x2,%ecx
  80096c:	fd                   	std    
  80096d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096f:	eb 09                	jmp    80097a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800971:	83 ef 01             	sub    $0x1,%edi
  800974:	8d 72 ff             	lea    -0x1(%edx),%esi
  800977:	fd                   	std    
  800978:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097a:	fc                   	cld    
  80097b:	eb 1d                	jmp    80099a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097d:	89 f2                	mov    %esi,%edx
  80097f:	09 c2                	or     %eax,%edx
  800981:	f6 c2 03             	test   $0x3,%dl
  800984:	75 0f                	jne    800995 <memmove+0x5f>
  800986:	f6 c1 03             	test   $0x3,%cl
  800989:	75 0a                	jne    800995 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098b:	c1 e9 02             	shr    $0x2,%ecx
  80098e:	89 c7                	mov    %eax,%edi
  800990:	fc                   	cld    
  800991:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800993:	eb 05                	jmp    80099a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099a:	5e                   	pop    %esi
  80099b:	5f                   	pop    %edi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a1:	ff 75 10             	pushl  0x10(%ebp)
  8009a4:	ff 75 0c             	pushl  0xc(%ebp)
  8009a7:	ff 75 08             	pushl  0x8(%ebp)
  8009aa:	e8 87 ff ff ff       	call   800936 <memmove>
}
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bc:	89 c6                	mov    %eax,%esi
  8009be:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c1:	eb 1a                	jmp    8009dd <memcmp+0x2c>
		if (*s1 != *s2)
  8009c3:	0f b6 08             	movzbl (%eax),%ecx
  8009c6:	0f b6 1a             	movzbl (%edx),%ebx
  8009c9:	38 d9                	cmp    %bl,%cl
  8009cb:	74 0a                	je     8009d7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009cd:	0f b6 c1             	movzbl %cl,%eax
  8009d0:	0f b6 db             	movzbl %bl,%ebx
  8009d3:	29 d8                	sub    %ebx,%eax
  8009d5:	eb 0f                	jmp    8009e6 <memcmp+0x35>
		s1++, s2++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dd:	39 f0                	cmp    %esi,%eax
  8009df:	75 e2                	jne    8009c3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f1:	89 c1                	mov    %eax,%ecx
  8009f3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fa:	eb 0a                	jmp    800a06 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fc:	0f b6 10             	movzbl (%eax),%edx
  8009ff:	39 da                	cmp    %ebx,%edx
  800a01:	74 07                	je     800a0a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	39 c8                	cmp    %ecx,%eax
  800a08:	72 f2                	jb     8009fc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	57                   	push   %edi
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a19:	eb 03                	jmp    800a1e <strtol+0x11>
		s++;
  800a1b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1e:	0f b6 01             	movzbl (%ecx),%eax
  800a21:	3c 20                	cmp    $0x20,%al
  800a23:	74 f6                	je     800a1b <strtol+0xe>
  800a25:	3c 09                	cmp    $0x9,%al
  800a27:	74 f2                	je     800a1b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a29:	3c 2b                	cmp    $0x2b,%al
  800a2b:	75 0a                	jne    800a37 <strtol+0x2a>
		s++;
  800a2d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
  800a35:	eb 11                	jmp    800a48 <strtol+0x3b>
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3c:	3c 2d                	cmp    $0x2d,%al
  800a3e:	75 08                	jne    800a48 <strtol+0x3b>
		s++, neg = 1;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a48:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4e:	75 15                	jne    800a65 <strtol+0x58>
  800a50:	80 39 30             	cmpb   $0x30,(%ecx)
  800a53:	75 10                	jne    800a65 <strtol+0x58>
  800a55:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a59:	75 7c                	jne    800ad7 <strtol+0xca>
		s += 2, base = 16;
  800a5b:	83 c1 02             	add    $0x2,%ecx
  800a5e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a63:	eb 16                	jmp    800a7b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a65:	85 db                	test   %ebx,%ebx
  800a67:	75 12                	jne    800a7b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a69:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a71:	75 08                	jne    800a7b <strtol+0x6e>
		s++, base = 8;
  800a73:	83 c1 01             	add    $0x1,%ecx
  800a76:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a80:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a83:	0f b6 11             	movzbl (%ecx),%edx
  800a86:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 09             	cmp    $0x9,%bl
  800a8e:	77 08                	ja     800a98 <strtol+0x8b>
			dig = *s - '0';
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 30             	sub    $0x30,%edx
  800a96:	eb 22                	jmp    800aba <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a98:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 19             	cmp    $0x19,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 57             	sub    $0x57,%edx
  800aa8:	eb 10                	jmp    800aba <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aaa:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 16                	ja     800aca <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aba:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abd:	7d 0b                	jge    800aca <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800abf:	83 c1 01             	add    $0x1,%ecx
  800ac2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac8:	eb b9                	jmp    800a83 <strtol+0x76>

	if (endptr)
  800aca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ace:	74 0d                	je     800add <strtol+0xd0>
		*endptr = (char *) s;
  800ad0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad3:	89 0e                	mov    %ecx,(%esi)
  800ad5:	eb 06                	jmp    800add <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	74 98                	je     800a73 <strtol+0x66>
  800adb:	eb 9e                	jmp    800a7b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800add:	89 c2                	mov    %eax,%edx
  800adf:	f7 da                	neg    %edx
  800ae1:	85 ff                	test   %edi,%edi
  800ae3:	0f 45 c2             	cmovne %edx,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	89 c3                	mov    %eax,%ebx
  800afe:	89 c7                	mov    %eax,%edi
  800b00:	89 c6                	mov    %eax,%esi
  800b02:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b14:	b8 01 00 00 00       	mov    $0x1,%eax
  800b19:	89 d1                	mov    %edx,%ecx
  800b1b:	89 d3                	mov    %edx,%ebx
  800b1d:	89 d7                	mov    %edx,%edi
  800b1f:	89 d6                	mov    %edx,%esi
  800b21:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b36:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3e:	89 cb                	mov    %ecx,%ebx
  800b40:	89 cf                	mov    %ecx,%edi
  800b42:	89 ce                	mov    %ecx,%esi
  800b44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b46:	85 c0                	test   %eax,%eax
  800b48:	7e 17                	jle    800b61 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	50                   	push   %eax
  800b4e:	6a 03                	push   $0x3
  800b50:	68 df 26 80 00       	push   $0x8026df
  800b55:	6a 23                	push   $0x23
  800b57:	68 fc 26 80 00       	push   $0x8026fc
  800b5c:	e8 e5 f5 ff ff       	call   800146 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 02 00 00 00       	mov    $0x2,%eax
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 d3                	mov    %edx,%ebx
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_yield>:

void
sys_yield(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b98:	89 d1                	mov    %edx,%ecx
  800b9a:	89 d3                	mov    %edx,%ebx
  800b9c:	89 d7                	mov    %edx,%edi
  800b9e:	89 d6                	mov    %edx,%esi
  800ba0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	be 00 00 00 00       	mov    $0x0,%esi
  800bb5:	b8 04 00 00 00       	mov    $0x4,%eax
  800bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc3:	89 f7                	mov    %esi,%edi
  800bc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7e 17                	jle    800be2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	50                   	push   %eax
  800bcf:	6a 04                	push   $0x4
  800bd1:	68 df 26 80 00       	push   $0x8026df
  800bd6:	6a 23                	push   $0x23
  800bd8:	68 fc 26 80 00       	push   $0x8026fc
  800bdd:	e8 64 f5 ff ff       	call   800146 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c01:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c04:	8b 75 18             	mov    0x18(%ebp),%esi
  800c07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7e 17                	jle    800c24 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 05                	push   $0x5
  800c13:	68 df 26 80 00       	push   $0x8026df
  800c18:	6a 23                	push   $0x23
  800c1a:	68 fc 26 80 00       	push   $0x8026fc
  800c1f:	e8 22 f5 ff ff       	call   800146 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7e 17                	jle    800c66 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	50                   	push   %eax
  800c53:	6a 06                	push   $0x6
  800c55:	68 df 26 80 00       	push   $0x8026df
  800c5a:	6a 23                	push   $0x23
  800c5c:	68 fc 26 80 00       	push   $0x8026fc
  800c61:	e8 e0 f4 ff ff       	call   800146 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	89 df                	mov    %ebx,%edi
  800c89:	89 de                	mov    %ebx,%esi
  800c8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7e 17                	jle    800ca8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	50                   	push   %eax
  800c95:	6a 08                	push   $0x8
  800c97:	68 df 26 80 00       	push   $0x8026df
  800c9c:	6a 23                	push   $0x23
  800c9e:	68 fc 26 80 00       	push   $0x8026fc
  800ca3:	e8 9e f4 ff ff       	call   800146 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbe:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 df                	mov    %ebx,%edi
  800ccb:	89 de                	mov    %ebx,%esi
  800ccd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 17                	jle    800cea <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	50                   	push   %eax
  800cd7:	6a 09                	push   $0x9
  800cd9:	68 df 26 80 00       	push   $0x8026df
  800cde:	6a 23                	push   $0x23
  800ce0:	68 fc 26 80 00       	push   $0x8026fc
  800ce5:	e8 5c f4 ff ff       	call   800146 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	89 df                	mov    %ebx,%edi
  800d0d:	89 de                	mov    %ebx,%esi
  800d0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 17                	jle    800d2c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 0a                	push   $0xa
  800d1b:	68 df 26 80 00       	push   $0x8026df
  800d20:	6a 23                	push   $0x23
  800d22:	68 fc 26 80 00       	push   $0x8026fc
  800d27:	e8 1a f4 ff ff       	call   800146 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d3a:	be 00 00 00 00       	mov    $0x0,%esi
  800d3f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d50:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d65:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 cb                	mov    %ecx,%ebx
  800d6f:	89 cf                	mov    %ecx,%edi
  800d71:	89 ce                	mov    %ecx,%esi
  800d73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d75:	85 c0                	test   %eax,%eax
  800d77:	7e 17                	jle    800d90 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	50                   	push   %eax
  800d7d:	6a 0d                	push   $0xd
  800d7f:	68 df 26 80 00       	push   $0x8026df
  800d84:	6a 23                	push   $0x23
  800d86:	68 fc 26 80 00       	push   $0x8026fc
  800d8b:	e8 b6 f3 ff ff       	call   800146 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800da3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da8:	89 d1                	mov    %edx,%ecx
  800daa:	89 d3                	mov    %edx,%ebx
  800dac:	89 d7                	mov    %edx,%edi
  800dae:	89 d6                	mov    %edx,%esi
  800db0:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 df                	mov    %ebx,%edi
  800dcf:	89 de                	mov    %ebx,%esi
  800dd1:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	05 00 00 00 30       	add    $0x30000000,%eax
  800de3:	c1 e8 0c             	shr    $0xc,%eax
}
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	05 00 00 00 30       	add    $0x30000000,%eax
  800df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e05:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e0a:	89 c2                	mov    %eax,%edx
  800e0c:	c1 ea 16             	shr    $0x16,%edx
  800e0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e16:	f6 c2 01             	test   $0x1,%dl
  800e19:	74 11                	je     800e2c <fd_alloc+0x2d>
  800e1b:	89 c2                	mov    %eax,%edx
  800e1d:	c1 ea 0c             	shr    $0xc,%edx
  800e20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e27:	f6 c2 01             	test   $0x1,%dl
  800e2a:	75 09                	jne    800e35 <fd_alloc+0x36>
			*fd_store = fd;
  800e2c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e33:	eb 17                	jmp    800e4c <fd_alloc+0x4d>
  800e35:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e3a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3f:	75 c9                	jne    800e0a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e41:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e47:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e54:	83 f8 1f             	cmp    $0x1f,%eax
  800e57:	77 36                	ja     800e8f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e59:	c1 e0 0c             	shl    $0xc,%eax
  800e5c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	c1 ea 16             	shr    $0x16,%edx
  800e66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6d:	f6 c2 01             	test   $0x1,%dl
  800e70:	74 24                	je     800e96 <fd_lookup+0x48>
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	c1 ea 0c             	shr    $0xc,%edx
  800e77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7e:	f6 c2 01             	test   $0x1,%dl
  800e81:	74 1a                	je     800e9d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e86:	89 02                	mov    %eax,(%edx)
	return 0;
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	eb 13                	jmp    800ea2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e94:	eb 0c                	jmp    800ea2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9b:	eb 05                	jmp    800ea2 <fd_lookup+0x54>
  800e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ead:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb2:	eb 13                	jmp    800ec7 <dev_lookup+0x23>
  800eb4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eb7:	39 08                	cmp    %ecx,(%eax)
  800eb9:	75 0c                	jne    800ec7 <dev_lookup+0x23>
			*dev = devtab[i];
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	eb 2e                	jmp    800ef5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec7:	8b 02                	mov    (%edx),%eax
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	75 e7                	jne    800eb4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ecd:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800ed2:	8b 40 48             	mov    0x48(%eax),%eax
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	51                   	push   %ecx
  800ed9:	50                   	push   %eax
  800eda:	68 0c 27 80 00       	push   $0x80270c
  800edf:	e8 3b f3 ff ff       	call   80021f <cprintf>
	*dev = 0;
  800ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	83 ec 10             	sub    $0x10,%esp
  800eff:	8b 75 08             	mov    0x8(%ebp),%esi
  800f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f08:	50                   	push   %eax
  800f09:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f0f:	c1 e8 0c             	shr    $0xc,%eax
  800f12:	50                   	push   %eax
  800f13:	e8 36 ff ff ff       	call   800e4e <fd_lookup>
  800f18:	83 c4 08             	add    $0x8,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	78 05                	js     800f24 <fd_close+0x2d>
	    || fd != fd2)
  800f1f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f22:	74 0c                	je     800f30 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f24:	84 db                	test   %bl,%bl
  800f26:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2b:	0f 44 c2             	cmove  %edx,%eax
  800f2e:	eb 41                	jmp    800f71 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f36:	50                   	push   %eax
  800f37:	ff 36                	pushl  (%esi)
  800f39:	e8 66 ff ff ff       	call   800ea4 <dev_lookup>
  800f3e:	89 c3                	mov    %eax,%ebx
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 1a                	js     800f61 <fd_close+0x6a>
		if (dev->dev_close)
  800f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f4d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f52:	85 c0                	test   %eax,%eax
  800f54:	74 0b                	je     800f61 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f56:	83 ec 0c             	sub    $0xc,%esp
  800f59:	56                   	push   %esi
  800f5a:	ff d0                	call   *%eax
  800f5c:	89 c3                	mov    %eax,%ebx
  800f5e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f61:	83 ec 08             	sub    $0x8,%esp
  800f64:	56                   	push   %esi
  800f65:	6a 00                	push   $0x0
  800f67:	e8 c0 fc ff ff       	call   800c2c <sys_page_unmap>
	return r;
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	89 d8                	mov    %ebx,%eax
}
  800f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f81:	50                   	push   %eax
  800f82:	ff 75 08             	pushl  0x8(%ebp)
  800f85:	e8 c4 fe ff ff       	call   800e4e <fd_lookup>
  800f8a:	83 c4 08             	add    $0x8,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 10                	js     800fa1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f91:	83 ec 08             	sub    $0x8,%esp
  800f94:	6a 01                	push   $0x1
  800f96:	ff 75 f4             	pushl  -0xc(%ebp)
  800f99:	e8 59 ff ff ff       	call   800ef7 <fd_close>
  800f9e:	83 c4 10             	add    $0x10,%esp
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <close_all>:

void
close_all(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	53                   	push   %ebx
  800fb3:	e8 c0 ff ff ff       	call   800f78 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb8:	83 c3 01             	add    $0x1,%ebx
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	83 fb 20             	cmp    $0x20,%ebx
  800fc1:	75 ec                	jne    800faf <close_all+0xc>
		close(i);
}
  800fc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	57                   	push   %edi
  800fcc:	56                   	push   %esi
  800fcd:	53                   	push   %ebx
  800fce:	83 ec 2c             	sub    $0x2c,%esp
  800fd1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	ff 75 08             	pushl  0x8(%ebp)
  800fdb:	e8 6e fe ff ff       	call   800e4e <fd_lookup>
  800fe0:	83 c4 08             	add    $0x8,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	0f 88 c1 00 00 00    	js     8010ac <dup+0xe4>
		return r;
	close(newfdnum);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	56                   	push   %esi
  800fef:	e8 84 ff ff ff       	call   800f78 <close>

	newfd = INDEX2FD(newfdnum);
  800ff4:	89 f3                	mov    %esi,%ebx
  800ff6:	c1 e3 0c             	shl    $0xc,%ebx
  800ff9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fff:	83 c4 04             	add    $0x4,%esp
  801002:	ff 75 e4             	pushl  -0x1c(%ebp)
  801005:	e8 de fd ff ff       	call   800de8 <fd2data>
  80100a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80100c:	89 1c 24             	mov    %ebx,(%esp)
  80100f:	e8 d4 fd ff ff       	call   800de8 <fd2data>
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80101a:	89 f8                	mov    %edi,%eax
  80101c:	c1 e8 16             	shr    $0x16,%eax
  80101f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801026:	a8 01                	test   $0x1,%al
  801028:	74 37                	je     801061 <dup+0x99>
  80102a:	89 f8                	mov    %edi,%eax
  80102c:	c1 e8 0c             	shr    $0xc,%eax
  80102f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801036:	f6 c2 01             	test   $0x1,%dl
  801039:	74 26                	je     801061 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80103b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	25 07 0e 00 00       	and    $0xe07,%eax
  80104a:	50                   	push   %eax
  80104b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104e:	6a 00                	push   $0x0
  801050:	57                   	push   %edi
  801051:	6a 00                	push   $0x0
  801053:	e8 92 fb ff ff       	call   800bea <sys_page_map>
  801058:	89 c7                	mov    %eax,%edi
  80105a:	83 c4 20             	add    $0x20,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 2e                	js     80108f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801061:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801064:	89 d0                	mov    %edx,%eax
  801066:	c1 e8 0c             	shr    $0xc,%eax
  801069:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	25 07 0e 00 00       	and    $0xe07,%eax
  801078:	50                   	push   %eax
  801079:	53                   	push   %ebx
  80107a:	6a 00                	push   $0x0
  80107c:	52                   	push   %edx
  80107d:	6a 00                	push   $0x0
  80107f:	e8 66 fb ff ff       	call   800bea <sys_page_map>
  801084:	89 c7                	mov    %eax,%edi
  801086:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801089:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108b:	85 ff                	test   %edi,%edi
  80108d:	79 1d                	jns    8010ac <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80108f:	83 ec 08             	sub    $0x8,%esp
  801092:	53                   	push   %ebx
  801093:	6a 00                	push   $0x0
  801095:	e8 92 fb ff ff       	call   800c2c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80109a:	83 c4 08             	add    $0x8,%esp
  80109d:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 85 fb ff ff       	call   800c2c <sys_page_unmap>
	return r;
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	89 f8                	mov    %edi,%eax
}
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 14             	sub    $0x14,%esp
  8010bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c1:	50                   	push   %eax
  8010c2:	53                   	push   %ebx
  8010c3:	e8 86 fd ff ff       	call   800e4e <fd_lookup>
  8010c8:	83 c4 08             	add    $0x8,%esp
  8010cb:	89 c2                	mov    %eax,%edx
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 6d                	js     80113e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d1:	83 ec 08             	sub    $0x8,%esp
  8010d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d7:	50                   	push   %eax
  8010d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010db:	ff 30                	pushl  (%eax)
  8010dd:	e8 c2 fd ff ff       	call   800ea4 <dev_lookup>
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 4c                	js     801135 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ec:	8b 42 08             	mov    0x8(%edx),%eax
  8010ef:	83 e0 03             	and    $0x3,%eax
  8010f2:	83 f8 01             	cmp    $0x1,%eax
  8010f5:	75 21                	jne    801118 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f7:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8010fc:	8b 40 48             	mov    0x48(%eax),%eax
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	53                   	push   %ebx
  801103:	50                   	push   %eax
  801104:	68 50 27 80 00       	push   $0x802750
  801109:	e8 11 f1 ff ff       	call   80021f <cprintf>
		return -E_INVAL;
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801116:	eb 26                	jmp    80113e <read+0x8a>
	}
	if (!dev->dev_read)
  801118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111b:	8b 40 08             	mov    0x8(%eax),%eax
  80111e:	85 c0                	test   %eax,%eax
  801120:	74 17                	je     801139 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	ff 75 10             	pushl  0x10(%ebp)
  801128:	ff 75 0c             	pushl  0xc(%ebp)
  80112b:	52                   	push   %edx
  80112c:	ff d0                	call   *%eax
  80112e:	89 c2                	mov    %eax,%edx
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	eb 09                	jmp    80113e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801135:	89 c2                	mov    %eax,%edx
  801137:	eb 05                	jmp    80113e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801139:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80113e:	89 d0                	mov    %edx,%eax
  801140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801151:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801154:	bb 00 00 00 00       	mov    $0x0,%ebx
  801159:	eb 21                	jmp    80117c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	89 f0                	mov    %esi,%eax
  801160:	29 d8                	sub    %ebx,%eax
  801162:	50                   	push   %eax
  801163:	89 d8                	mov    %ebx,%eax
  801165:	03 45 0c             	add    0xc(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	57                   	push   %edi
  80116a:	e8 45 ff ff ff       	call   8010b4 <read>
		if (m < 0)
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	78 10                	js     801186 <readn+0x41>
			return m;
		if (m == 0)
  801176:	85 c0                	test   %eax,%eax
  801178:	74 0a                	je     801184 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117a:	01 c3                	add    %eax,%ebx
  80117c:	39 f3                	cmp    %esi,%ebx
  80117e:	72 db                	jb     80115b <readn+0x16>
  801180:	89 d8                	mov    %ebx,%eax
  801182:	eb 02                	jmp    801186 <readn+0x41>
  801184:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	53                   	push   %ebx
  801192:	83 ec 14             	sub    $0x14,%esp
  801195:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801198:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	53                   	push   %ebx
  80119d:	e8 ac fc ff ff       	call   800e4e <fd_lookup>
  8011a2:	83 c4 08             	add    $0x8,%esp
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 68                	js     801213 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b5:	ff 30                	pushl  (%eax)
  8011b7:	e8 e8 fc ff ff       	call   800ea4 <dev_lookup>
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 47                	js     80120a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ca:	75 21                	jne    8011ed <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cc:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011d1:	8b 40 48             	mov    0x48(%eax),%eax
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	53                   	push   %ebx
  8011d8:	50                   	push   %eax
  8011d9:	68 6c 27 80 00       	push   $0x80276c
  8011de:	e8 3c f0 ff ff       	call   80021f <cprintf>
		return -E_INVAL;
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011eb:	eb 26                	jmp    801213 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f3:	85 d2                	test   %edx,%edx
  8011f5:	74 17                	je     80120e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	ff 75 10             	pushl  0x10(%ebp)
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	50                   	push   %eax
  801201:	ff d2                	call   *%edx
  801203:	89 c2                	mov    %eax,%edx
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	eb 09                	jmp    801213 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	eb 05                	jmp    801213 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80120e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801213:	89 d0                	mov    %edx,%eax
  801215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <seek>:

int
seek(int fdnum, off_t offset)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801220:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801223:	50                   	push   %eax
  801224:	ff 75 08             	pushl  0x8(%ebp)
  801227:	e8 22 fc ff ff       	call   800e4e <fd_lookup>
  80122c:	83 c4 08             	add    $0x8,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 0e                	js     801241 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801233:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801236:	8b 55 0c             	mov    0xc(%ebp),%edx
  801239:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 14             	sub    $0x14,%esp
  80124a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	53                   	push   %ebx
  801252:	e8 f7 fb ff ff       	call   800e4e <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 65                	js     8012c5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	ff 30                	pushl  (%eax)
  80126c:	e8 33 fc ff ff       	call   800ea4 <dev_lookup>
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 44                	js     8012bc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127f:	75 21                	jne    8012a2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801281:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	53                   	push   %ebx
  80128d:	50                   	push   %eax
  80128e:	68 2c 27 80 00       	push   $0x80272c
  801293:	e8 87 ef ff ff       	call   80021f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a0:	eb 23                	jmp    8012c5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a5:	8b 52 18             	mov    0x18(%edx),%edx
  8012a8:	85 d2                	test   %edx,%edx
  8012aa:	74 14                	je     8012c0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ac:	83 ec 08             	sub    $0x8,%esp
  8012af:	ff 75 0c             	pushl  0xc(%ebp)
  8012b2:	50                   	push   %eax
  8012b3:	ff d2                	call   *%edx
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	eb 09                	jmp    8012c5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bc:	89 c2                	mov    %eax,%edx
  8012be:	eb 05                	jmp    8012c5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012c5:	89 d0                	mov    %edx,%eax
  8012c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 14             	sub    $0x14,%esp
  8012d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d9:	50                   	push   %eax
  8012da:	ff 75 08             	pushl  0x8(%ebp)
  8012dd:	e8 6c fb ff ff       	call   800e4e <fd_lookup>
  8012e2:	83 c4 08             	add    $0x8,%esp
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 58                	js     801343 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	ff 30                	pushl  (%eax)
  8012f7:	e8 a8 fb ff ff       	call   800ea4 <dev_lookup>
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 37                	js     80133a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801306:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80130a:	74 32                	je     80133e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80130c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80130f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801316:	00 00 00 
	stat->st_isdir = 0;
  801319:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801320:	00 00 00 
	stat->st_dev = dev;
  801323:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	53                   	push   %ebx
  80132d:	ff 75 f0             	pushl  -0x10(%ebp)
  801330:	ff 50 14             	call   *0x14(%eax)
  801333:	89 c2                	mov    %eax,%edx
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	eb 09                	jmp    801343 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133a:	89 c2                	mov    %eax,%edx
  80133c:	eb 05                	jmp    801343 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80133e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801343:	89 d0                	mov    %edx,%eax
  801345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	6a 00                	push   $0x0
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 e7 01 00 00       	call   801543 <open>
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 1b                	js     801380 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	ff 75 0c             	pushl  0xc(%ebp)
  80136b:	50                   	push   %eax
  80136c:	e8 5b ff ff ff       	call   8012cc <fstat>
  801371:	89 c6                	mov    %eax,%esi
	close(fd);
  801373:	89 1c 24             	mov    %ebx,(%esp)
  801376:	e8 fd fb ff ff       	call   800f78 <close>
	return r;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	89 f0                	mov    %esi,%eax
}
  801380:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	89 c6                	mov    %eax,%esi
  80138e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801390:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801397:	75 12                	jne    8013ab <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	6a 01                	push   $0x1
  80139e:	e8 4b 0c 00 00       	call   801fee <ipc_find_env>
  8013a3:	a3 00 40 80 00       	mov    %eax,0x804000
  8013a8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ab:	6a 07                	push   $0x7
  8013ad:	68 00 50 c0 00       	push   $0xc05000
  8013b2:	56                   	push   %esi
  8013b3:	ff 35 00 40 80 00    	pushl  0x804000
  8013b9:	e8 dc 0b 00 00       	call   801f9a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013be:	83 c4 0c             	add    $0xc,%esp
  8013c1:	6a 00                	push   $0x0
  8013c3:	53                   	push   %ebx
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 62 0b 00 00       	call   801f2d <ipc_recv>
}
  8013cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ce:	5b                   	pop    %ebx
  8013cf:	5e                   	pop    %esi
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	8b 40 0c             	mov    0xc(%eax),%eax
  8013de:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e6:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f5:	e8 8d ff ff ff       	call   801387 <fsipc>
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	8b 40 0c             	mov    0xc(%eax),%eax
  801408:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 06 00 00 00       	mov    $0x6,%eax
  801417:	e8 6b ff ff ff       	call   801387 <fsipc>
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 04             	sub    $0x4,%esp
  801425:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801428:	8b 45 08             	mov    0x8(%ebp),%eax
  80142b:	8b 40 0c             	mov    0xc(%eax),%eax
  80142e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801433:	ba 00 00 00 00       	mov    $0x0,%edx
  801438:	b8 05 00 00 00       	mov    $0x5,%eax
  80143d:	e8 45 ff ff ff       	call   801387 <fsipc>
  801442:	85 c0                	test   %eax,%eax
  801444:	78 2c                	js     801472 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	68 00 50 c0 00       	push   $0xc05000
  80144e:	53                   	push   %ebx
  80144f:	e8 50 f3 ff ff       	call   8007a4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801454:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801459:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80145f:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801464:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	53                   	push   %ebx
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801481:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801486:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80148b:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80148e:	53                   	push   %ebx
  80148f:	ff 75 0c             	pushl  0xc(%ebp)
  801492:	68 08 50 c0 00       	push   $0xc05008
  801497:	e8 9a f4 ff ff       	call   800936 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80149c:	8b 45 08             	mov    0x8(%ebp),%eax
  80149f:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a2:	a3 00 50 c0 00       	mov    %eax,0xc05000
 	fsipcbuf.write.req_n = n;
  8014a7:	89 1d 04 50 c0 00    	mov    %ebx,0xc05004

 	return fsipc(FSREQ_WRITE, NULL);
  8014ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8014b7:	e8 cb fe ff ff       	call   801387 <fsipc>
	//panic("devfile_write not implemented");
}
  8014bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	56                   	push   %esi
  8014c5:	53                   	push   %ebx
  8014c6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cf:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014d4:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014da:	ba 00 00 00 00       	mov    $0x0,%edx
  8014df:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e4:	e8 9e fe ff ff       	call   801387 <fsipc>
  8014e9:	89 c3                	mov    %eax,%ebx
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 4b                	js     80153a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014ef:	39 c6                	cmp    %eax,%esi
  8014f1:	73 16                	jae    801509 <devfile_read+0x48>
  8014f3:	68 a0 27 80 00       	push   $0x8027a0
  8014f8:	68 a7 27 80 00       	push   $0x8027a7
  8014fd:	6a 7c                	push   $0x7c
  8014ff:	68 bc 27 80 00       	push   $0x8027bc
  801504:	e8 3d ec ff ff       	call   800146 <_panic>
	assert(r <= PGSIZE);
  801509:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80150e:	7e 16                	jle    801526 <devfile_read+0x65>
  801510:	68 c7 27 80 00       	push   $0x8027c7
  801515:	68 a7 27 80 00       	push   $0x8027a7
  80151a:	6a 7d                	push   $0x7d
  80151c:	68 bc 27 80 00       	push   $0x8027bc
  801521:	e8 20 ec ff ff       	call   800146 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801526:	83 ec 04             	sub    $0x4,%esp
  801529:	50                   	push   %eax
  80152a:	68 00 50 c0 00       	push   $0xc05000
  80152f:	ff 75 0c             	pushl  0xc(%ebp)
  801532:	e8 ff f3 ff ff       	call   800936 <memmove>
	return r;
  801537:	83 c4 10             	add    $0x10,%esp
}
  80153a:	89 d8                	mov    %ebx,%eax
  80153c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153f:	5b                   	pop    %ebx
  801540:	5e                   	pop    %esi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 20             	sub    $0x20,%esp
  80154a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80154d:	53                   	push   %ebx
  80154e:	e8 18 f2 ff ff       	call   80076b <strlen>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80155b:	7f 67                	jg     8015c4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80155d:	83 ec 0c             	sub    $0xc,%esp
  801560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	e8 96 f8 ff ff       	call   800dff <fd_alloc>
  801569:	83 c4 10             	add    $0x10,%esp
		return r;
  80156c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 57                	js     8015c9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	53                   	push   %ebx
  801576:	68 00 50 c0 00       	push   $0xc05000
  80157b:	e8 24 f2 ff ff       	call   8007a4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801580:	8b 45 0c             	mov    0xc(%ebp),%eax
  801583:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801588:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158b:	b8 01 00 00 00       	mov    $0x1,%eax
  801590:	e8 f2 fd ff ff       	call   801387 <fsipc>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	79 14                	jns    8015b2 <open+0x6f>
		fd_close(fd, 0);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	6a 00                	push   $0x0
  8015a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a6:	e8 4c f9 ff ff       	call   800ef7 <fd_close>
		return r;
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	89 da                	mov    %ebx,%edx
  8015b0:	eb 17                	jmp    8015c9 <open+0x86>
	}

	return fd2num(fd);
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b8:	e8 1b f8 ff ff       	call   800dd8 <fd2num>
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	eb 05                	jmp    8015c9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015c4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c9:	89 d0                	mov    %edx,%eax
  8015cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015db:	b8 08 00 00 00       	mov    $0x8,%eax
  8015e0:	e8 a2 fd ff ff       	call   801387 <fsipc>
}
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015ed:	68 d3 27 80 00       	push   $0x8027d3
  8015f2:	ff 75 0c             	pushl  0xc(%ebp)
  8015f5:	e8 aa f1 ff ff       	call   8007a4 <strcpy>
	return 0;
}
  8015fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	53                   	push   %ebx
  801605:	83 ec 10             	sub    $0x10,%esp
  801608:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80160b:	53                   	push   %ebx
  80160c:	e8 16 0a 00 00       	call   802027 <pageref>
  801611:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801614:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801619:	83 f8 01             	cmp    $0x1,%eax
  80161c:	75 10                	jne    80162e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	ff 73 0c             	pushl  0xc(%ebx)
  801624:	e8 c0 02 00 00       	call   8018e9 <nsipc_close>
  801629:	89 c2                	mov    %eax,%edx
  80162b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80162e:	89 d0                	mov    %edx,%eax
  801630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80163b:	6a 00                	push   $0x0
  80163d:	ff 75 10             	pushl  0x10(%ebp)
  801640:	ff 75 0c             	pushl  0xc(%ebp)
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	ff 70 0c             	pushl  0xc(%eax)
  801649:	e8 78 03 00 00       	call   8019c6 <nsipc_send>
}
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801656:	6a 00                	push   $0x0
  801658:	ff 75 10             	pushl  0x10(%ebp)
  80165b:	ff 75 0c             	pushl  0xc(%ebp)
  80165e:	8b 45 08             	mov    0x8(%ebp),%eax
  801661:	ff 70 0c             	pushl  0xc(%eax)
  801664:	e8 f1 02 00 00       	call   80195a <nsipc_recv>
}
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801671:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801674:	52                   	push   %edx
  801675:	50                   	push   %eax
  801676:	e8 d3 f7 ff ff       	call   800e4e <fd_lookup>
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 17                	js     801699 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801685:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80168b:	39 08                	cmp    %ecx,(%eax)
  80168d:	75 05                	jne    801694 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80168f:	8b 40 0c             	mov    0xc(%eax),%eax
  801692:	eb 05                	jmp    801699 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801694:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 1c             	sub    $0x1c,%esp
  8016a3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	e8 51 f7 ff ff       	call   800dff <fd_alloc>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 1b                	js     8016d2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016b7:	83 ec 04             	sub    $0x4,%esp
  8016ba:	68 07 04 00 00       	push   $0x407
  8016bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c2:	6a 00                	push   $0x0
  8016c4:	e8 de f4 ff ff       	call   800ba7 <sys_page_alloc>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	79 10                	jns    8016e2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	56                   	push   %esi
  8016d6:	e8 0e 02 00 00       	call   8018e9 <nsipc_close>
		return r;
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	89 d8                	mov    %ebx,%eax
  8016e0:	eb 24                	jmp    801706 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016e2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016eb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016f7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	50                   	push   %eax
  8016fe:	e8 d5 f6 ff ff       	call   800dd8 <fd2num>
  801703:	83 c4 10             	add    $0x10,%esp
}
  801706:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	e8 50 ff ff ff       	call   80166b <fd2sockid>
		return r;
  80171b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80171d:	85 c0                	test   %eax,%eax
  80171f:	78 1f                	js     801740 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801721:	83 ec 04             	sub    $0x4,%esp
  801724:	ff 75 10             	pushl  0x10(%ebp)
  801727:	ff 75 0c             	pushl  0xc(%ebp)
  80172a:	50                   	push   %eax
  80172b:	e8 12 01 00 00       	call   801842 <nsipc_accept>
  801730:	83 c4 10             	add    $0x10,%esp
		return r;
  801733:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801735:	85 c0                	test   %eax,%eax
  801737:	78 07                	js     801740 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801739:	e8 5d ff ff ff       	call   80169b <alloc_sockfd>
  80173e:	89 c1                	mov    %eax,%ecx
}
  801740:	89 c8                	mov    %ecx,%eax
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80174a:	8b 45 08             	mov    0x8(%ebp),%eax
  80174d:	e8 19 ff ff ff       	call   80166b <fd2sockid>
  801752:	85 c0                	test   %eax,%eax
  801754:	78 12                	js     801768 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801756:	83 ec 04             	sub    $0x4,%esp
  801759:	ff 75 10             	pushl  0x10(%ebp)
  80175c:	ff 75 0c             	pushl  0xc(%ebp)
  80175f:	50                   	push   %eax
  801760:	e8 2d 01 00 00       	call   801892 <nsipc_bind>
  801765:	83 c4 10             	add    $0x10,%esp
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <shutdown>:

int
shutdown(int s, int how)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	e8 f3 fe ff ff       	call   80166b <fd2sockid>
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 0f                	js     80178b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80177c:	83 ec 08             	sub    $0x8,%esp
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	50                   	push   %eax
  801783:	e8 3f 01 00 00       	call   8018c7 <nsipc_shutdown>
  801788:	83 c4 10             	add    $0x10,%esp
}
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	e8 d0 fe ff ff       	call   80166b <fd2sockid>
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 12                	js     8017b1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	ff 75 10             	pushl  0x10(%ebp)
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	50                   	push   %eax
  8017a9:	e8 55 01 00 00       	call   801903 <nsipc_connect>
  8017ae:	83 c4 10             	add    $0x10,%esp
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <listen>:

int
listen(int s, int backlog)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	e8 aa fe ff ff       	call   80166b <fd2sockid>
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 0f                	js     8017d4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	ff 75 0c             	pushl  0xc(%ebp)
  8017cb:	50                   	push   %eax
  8017cc:	e8 67 01 00 00       	call   801938 <nsipc_listen>
  8017d1:	83 c4 10             	add    $0x10,%esp
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017dc:	ff 75 10             	pushl  0x10(%ebp)
  8017df:	ff 75 0c             	pushl  0xc(%ebp)
  8017e2:	ff 75 08             	pushl  0x8(%ebp)
  8017e5:	e8 3a 02 00 00       	call   801a24 <nsipc_socket>
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 05                	js     8017f6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017f1:	e8 a5 fe ff ff       	call   80169b <alloc_sockfd>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 04             	sub    $0x4,%esp
  8017ff:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801801:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801808:	75 12                	jne    80181c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	6a 02                	push   $0x2
  80180f:	e8 da 07 00 00       	call   801fee <ipc_find_env>
  801814:	a3 04 40 80 00       	mov    %eax,0x804004
  801819:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80181c:	6a 07                	push   $0x7
  80181e:	68 00 60 c0 00       	push   $0xc06000
  801823:	53                   	push   %ebx
  801824:	ff 35 04 40 80 00    	pushl  0x804004
  80182a:	e8 6b 07 00 00       	call   801f9a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80182f:	83 c4 0c             	add    $0xc,%esp
  801832:	6a 00                	push   $0x0
  801834:	6a 00                	push   $0x0
  801836:	6a 00                	push   $0x0
  801838:	e8 f0 06 00 00       	call   801f2d <ipc_recv>
}
  80183d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	56                   	push   %esi
  801846:	53                   	push   %ebx
  801847:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801852:	8b 06                	mov    (%esi),%eax
  801854:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801859:	b8 01 00 00 00       	mov    $0x1,%eax
  80185e:	e8 95 ff ff ff       	call   8017f8 <nsipc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	85 c0                	test   %eax,%eax
  801867:	78 20                	js     801889 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801869:	83 ec 04             	sub    $0x4,%esp
  80186c:	ff 35 10 60 c0 00    	pushl  0xc06010
  801872:	68 00 60 c0 00       	push   $0xc06000
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	e8 b7 f0 ff ff       	call   800936 <memmove>
		*addrlen = ret->ret_addrlen;
  80187f:	a1 10 60 c0 00       	mov    0xc06010,%eax
  801884:	89 06                	mov    %eax,(%esi)
  801886:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801889:	89 d8                	mov    %ebx,%eax
  80188b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188e:	5b                   	pop    %ebx
  80188f:	5e                   	pop    %esi
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 08             	sub    $0x8,%esp
  801899:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018a4:	53                   	push   %ebx
  8018a5:	ff 75 0c             	pushl  0xc(%ebp)
  8018a8:	68 04 60 c0 00       	push   $0xc06004
  8018ad:	e8 84 f0 ff ff       	call   800936 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018b2:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  8018b8:	b8 02 00 00 00       	mov    $0x2,%eax
  8018bd:	e8 36 ff ff ff       	call   8017f8 <nsipc>
}
  8018c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    

008018c7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d0:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  8018d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d8:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  8018dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e2:	e8 11 ff ff ff       	call   8017f8 <nsipc>
}
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    

008018e9 <nsipc_close>:

int
nsipc_close(int s)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  8018f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8018fc:	e8 f7 fe ff ff       	call   8017f8 <nsipc>
}
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801915:	53                   	push   %ebx
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	68 04 60 c0 00       	push   $0xc06004
  80191e:	e8 13 f0 ff ff       	call   800936 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801923:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  801929:	b8 05 00 00 00       	mov    $0x5,%eax
  80192e:	e8 c5 fe ff ff       	call   8017f8 <nsipc>
}
  801933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80193e:	8b 45 08             	mov    0x8(%ebp),%eax
  801941:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  801946:	8b 45 0c             	mov    0xc(%ebp),%eax
  801949:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  80194e:	b8 06 00 00 00       	mov    $0x6,%eax
  801953:	e8 a0 fe ff ff       	call   8017f8 <nsipc>
}
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	56                   	push   %esi
  80195e:	53                   	push   %ebx
  80195f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  80196a:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  801970:	8b 45 14             	mov    0x14(%ebp),%eax
  801973:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801978:	b8 07 00 00 00       	mov    $0x7,%eax
  80197d:	e8 76 fe ff ff       	call   8017f8 <nsipc>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	85 c0                	test   %eax,%eax
  801986:	78 35                	js     8019bd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801988:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80198d:	7f 04                	jg     801993 <nsipc_recv+0x39>
  80198f:	39 c6                	cmp    %eax,%esi
  801991:	7d 16                	jge    8019a9 <nsipc_recv+0x4f>
  801993:	68 df 27 80 00       	push   $0x8027df
  801998:	68 a7 27 80 00       	push   $0x8027a7
  80199d:	6a 62                	push   $0x62
  80199f:	68 f4 27 80 00       	push   $0x8027f4
  8019a4:	e8 9d e7 ff ff       	call   800146 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019a9:	83 ec 04             	sub    $0x4,%esp
  8019ac:	50                   	push   %eax
  8019ad:	68 00 60 c0 00       	push   $0xc06000
  8019b2:	ff 75 0c             	pushl  0xc(%ebp)
  8019b5:	e8 7c ef ff ff       	call   800936 <memmove>
  8019ba:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019bd:	89 d8                	mov    %ebx,%eax
  8019bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c2:	5b                   	pop    %ebx
  8019c3:	5e                   	pop    %esi
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	53                   	push   %ebx
  8019ca:	83 ec 04             	sub    $0x4,%esp
  8019cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  8019d8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019de:	7e 16                	jle    8019f6 <nsipc_send+0x30>
  8019e0:	68 00 28 80 00       	push   $0x802800
  8019e5:	68 a7 27 80 00       	push   $0x8027a7
  8019ea:	6a 6d                	push   $0x6d
  8019ec:	68 f4 27 80 00       	push   $0x8027f4
  8019f1:	e8 50 e7 ff ff       	call   800146 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	53                   	push   %ebx
  8019fa:	ff 75 0c             	pushl  0xc(%ebp)
  8019fd:	68 0c 60 c0 00       	push   $0xc0600c
  801a02:	e8 2f ef ff ff       	call   800936 <memmove>
	nsipcbuf.send.req_size = size;
  801a07:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801a0d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a10:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801a15:	b8 08 00 00 00       	mov    $0x8,%eax
  801a1a:	e8 d9 fd ff ff       	call   8017f8 <nsipc>
}
  801a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a22:	c9                   	leave  
  801a23:	c3                   	ret    

00801a24 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2d:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a35:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801a3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3d:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801a42:	b8 09 00 00 00       	mov    $0x9,%eax
  801a47:	e8 ac fd ff ff       	call   8017f8 <nsipc>
}
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	56                   	push   %esi
  801a52:	53                   	push   %ebx
  801a53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	ff 75 08             	pushl  0x8(%ebp)
  801a5c:	e8 87 f3 ff ff       	call   800de8 <fd2data>
  801a61:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a63:	83 c4 08             	add    $0x8,%esp
  801a66:	68 0c 28 80 00       	push   $0x80280c
  801a6b:	53                   	push   %ebx
  801a6c:	e8 33 ed ff ff       	call   8007a4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a71:	8b 46 04             	mov    0x4(%esi),%eax
  801a74:	2b 06                	sub    (%esi),%eax
  801a76:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a7c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a83:	00 00 00 
	stat->st_dev = &devpipe;
  801a86:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a8d:	30 80 00 
	return 0;
}
  801a90:	b8 00 00 00 00       	mov    $0x0,%eax
  801a95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aa6:	53                   	push   %ebx
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 7e f1 ff ff       	call   800c2c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aae:	89 1c 24             	mov    %ebx,(%esp)
  801ab1:	e8 32 f3 ff ff       	call   800de8 <fd2data>
  801ab6:	83 c4 08             	add    $0x8,%esp
  801ab9:	50                   	push   %eax
  801aba:	6a 00                	push   $0x0
  801abc:	e8 6b f1 ff ff       	call   800c2c <sys_page_unmap>
}
  801ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	57                   	push   %edi
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	83 ec 1c             	sub    $0x1c,%esp
  801acf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ad2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ad4:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ad9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae2:	e8 40 05 00 00       	call   802027 <pageref>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	89 3c 24             	mov    %edi,(%esp)
  801aec:	e8 36 05 00 00       	call   802027 <pageref>
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	39 c3                	cmp    %eax,%ebx
  801af6:	0f 94 c1             	sete   %cl
  801af9:	0f b6 c9             	movzbl %cl,%ecx
  801afc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aff:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801b05:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b08:	39 ce                	cmp    %ecx,%esi
  801b0a:	74 1b                	je     801b27 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b0c:	39 c3                	cmp    %eax,%ebx
  801b0e:	75 c4                	jne    801ad4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b10:	8b 42 58             	mov    0x58(%edx),%eax
  801b13:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b16:	50                   	push   %eax
  801b17:	56                   	push   %esi
  801b18:	68 13 28 80 00       	push   $0x802813
  801b1d:	e8 fd e6 ff ff       	call   80021f <cprintf>
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	eb ad                	jmp    801ad4 <_pipeisclosed+0xe>
	}
}
  801b27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5f                   	pop    %edi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	83 ec 28             	sub    $0x28,%esp
  801b3b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b3e:	56                   	push   %esi
  801b3f:	e8 a4 f2 ff ff       	call   800de8 <fd2data>
  801b44:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	bf 00 00 00 00       	mov    $0x0,%edi
  801b4e:	eb 4b                	jmp    801b9b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b50:	89 da                	mov    %ebx,%edx
  801b52:	89 f0                	mov    %esi,%eax
  801b54:	e8 6d ff ff ff       	call   801ac6 <_pipeisclosed>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	75 48                	jne    801ba5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b5d:	e8 26 f0 ff ff       	call   800b88 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b62:	8b 43 04             	mov    0x4(%ebx),%eax
  801b65:	8b 0b                	mov    (%ebx),%ecx
  801b67:	8d 51 20             	lea    0x20(%ecx),%edx
  801b6a:	39 d0                	cmp    %edx,%eax
  801b6c:	73 e2                	jae    801b50 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b71:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b75:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b78:	89 c2                	mov    %eax,%edx
  801b7a:	c1 fa 1f             	sar    $0x1f,%edx
  801b7d:	89 d1                	mov    %edx,%ecx
  801b7f:	c1 e9 1b             	shr    $0x1b,%ecx
  801b82:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b85:	83 e2 1f             	and    $0x1f,%edx
  801b88:	29 ca                	sub    %ecx,%edx
  801b8a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b8e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b92:	83 c0 01             	add    $0x1,%eax
  801b95:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b98:	83 c7 01             	add    $0x1,%edi
  801b9b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b9e:	75 c2                	jne    801b62 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ba0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba3:	eb 05                	jmp    801baa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801baa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5f                   	pop    %edi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 18             	sub    $0x18,%esp
  801bbb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bbe:	57                   	push   %edi
  801bbf:	e8 24 f2 ff ff       	call   800de8 <fd2data>
  801bc4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bce:	eb 3d                	jmp    801c0d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bd0:	85 db                	test   %ebx,%ebx
  801bd2:	74 04                	je     801bd8 <devpipe_read+0x26>
				return i;
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	eb 44                	jmp    801c1c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bd8:	89 f2                	mov    %esi,%edx
  801bda:	89 f8                	mov    %edi,%eax
  801bdc:	e8 e5 fe ff ff       	call   801ac6 <_pipeisclosed>
  801be1:	85 c0                	test   %eax,%eax
  801be3:	75 32                	jne    801c17 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801be5:	e8 9e ef ff ff       	call   800b88 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bea:	8b 06                	mov    (%esi),%eax
  801bec:	3b 46 04             	cmp    0x4(%esi),%eax
  801bef:	74 df                	je     801bd0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bf1:	99                   	cltd   
  801bf2:	c1 ea 1b             	shr    $0x1b,%edx
  801bf5:	01 d0                	add    %edx,%eax
  801bf7:	83 e0 1f             	and    $0x1f,%eax
  801bfa:	29 d0                	sub    %edx,%eax
  801bfc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c04:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c07:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0a:	83 c3 01             	add    $0x1,%ebx
  801c0d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c10:	75 d8                	jne    801bea <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c12:	8b 45 10             	mov    0x10(%ebp),%eax
  801c15:	eb 05                	jmp    801c1c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5f                   	pop    %edi
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    

00801c24 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	56                   	push   %esi
  801c28:	53                   	push   %ebx
  801c29:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2f:	50                   	push   %eax
  801c30:	e8 ca f1 ff ff       	call   800dff <fd_alloc>
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	0f 88 2c 01 00 00    	js     801d6e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c42:	83 ec 04             	sub    $0x4,%esp
  801c45:	68 07 04 00 00       	push   $0x407
  801c4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 53 ef ff ff       	call   800ba7 <sys_page_alloc>
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	89 c2                	mov    %eax,%edx
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	0f 88 0d 01 00 00    	js     801d6e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c61:	83 ec 0c             	sub    $0xc,%esp
  801c64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c67:	50                   	push   %eax
  801c68:	e8 92 f1 ff ff       	call   800dff <fd_alloc>
  801c6d:	89 c3                	mov    %eax,%ebx
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	0f 88 e2 00 00 00    	js     801d5c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7a:	83 ec 04             	sub    $0x4,%esp
  801c7d:	68 07 04 00 00       	push   $0x407
  801c82:	ff 75 f0             	pushl  -0x10(%ebp)
  801c85:	6a 00                	push   $0x0
  801c87:	e8 1b ef ff ff       	call   800ba7 <sys_page_alloc>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	0f 88 c3 00 00 00    	js     801d5c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9f:	e8 44 f1 ff ff       	call   800de8 <fd2data>
  801ca4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca6:	83 c4 0c             	add    $0xc,%esp
  801ca9:	68 07 04 00 00       	push   $0x407
  801cae:	50                   	push   %eax
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 f1 ee ff ff       	call   800ba7 <sys_page_alloc>
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	0f 88 89 00 00 00    	js     801d4c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc3:	83 ec 0c             	sub    $0xc,%esp
  801cc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc9:	e8 1a f1 ff ff       	call   800de8 <fd2data>
  801cce:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cd5:	50                   	push   %eax
  801cd6:	6a 00                	push   $0x0
  801cd8:	56                   	push   %esi
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 0a ef ff ff       	call   800bea <sys_page_map>
  801ce0:	89 c3                	mov    %eax,%ebx
  801ce2:	83 c4 20             	add    $0x20,%esp
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 55                	js     801d3e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ce9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cfe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d07:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	ff 75 f4             	pushl  -0xc(%ebp)
  801d19:	e8 ba f0 ff ff       	call   800dd8 <fd2num>
  801d1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d21:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d23:	83 c4 04             	add    $0x4,%esp
  801d26:	ff 75 f0             	pushl  -0x10(%ebp)
  801d29:	e8 aa f0 ff ff       	call   800dd8 <fd2num>
  801d2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d31:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3c:	eb 30                	jmp    801d6e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d3e:	83 ec 08             	sub    $0x8,%esp
  801d41:	56                   	push   %esi
  801d42:	6a 00                	push   $0x0
  801d44:	e8 e3 ee ff ff       	call   800c2c <sys_page_unmap>
  801d49:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d4c:	83 ec 08             	sub    $0x8,%esp
  801d4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d52:	6a 00                	push   $0x0
  801d54:	e8 d3 ee ff ff       	call   800c2c <sys_page_unmap>
  801d59:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d5c:	83 ec 08             	sub    $0x8,%esp
  801d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d62:	6a 00                	push   $0x0
  801d64:	e8 c3 ee ff ff       	call   800c2c <sys_page_unmap>
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d6e:	89 d0                	mov    %edx,%eax
  801d70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    

00801d77 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d80:	50                   	push   %eax
  801d81:	ff 75 08             	pushl  0x8(%ebp)
  801d84:	e8 c5 f0 ff ff       	call   800e4e <fd_lookup>
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	78 18                	js     801da8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d90:	83 ec 0c             	sub    $0xc,%esp
  801d93:	ff 75 f4             	pushl  -0xc(%ebp)
  801d96:	e8 4d f0 ff ff       	call   800de8 <fd2data>
	return _pipeisclosed(fd, p);
  801d9b:	89 c2                	mov    %eax,%edx
  801d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da0:	e8 21 fd ff ff       	call   801ac6 <_pipeisclosed>
  801da5:	83 c4 10             	add    $0x10,%esp
}
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dba:	68 2b 28 80 00       	push   $0x80282b
  801dbf:	ff 75 0c             	pushl  0xc(%ebp)
  801dc2:	e8 dd e9 ff ff       	call   8007a4 <strcpy>
	return 0;
}
  801dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	57                   	push   %edi
  801dd2:	56                   	push   %esi
  801dd3:	53                   	push   %ebx
  801dd4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dda:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de5:	eb 2d                	jmp    801e14 <devcons_write+0x46>
		m = n - tot;
  801de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dea:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dec:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801def:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801df4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df7:	83 ec 04             	sub    $0x4,%esp
  801dfa:	53                   	push   %ebx
  801dfb:	03 45 0c             	add    0xc(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	57                   	push   %edi
  801e00:	e8 31 eb ff ff       	call   800936 <memmove>
		sys_cputs(buf, m);
  801e05:	83 c4 08             	add    $0x8,%esp
  801e08:	53                   	push   %ebx
  801e09:	57                   	push   %edi
  801e0a:	e8 dc ec ff ff       	call   800aeb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0f:	01 de                	add    %ebx,%esi
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	89 f0                	mov    %esi,%eax
  801e16:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e19:	72 cc                	jb     801de7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1e:	5b                   	pop    %ebx
  801e1f:	5e                   	pop    %esi
  801e20:	5f                   	pop    %edi
  801e21:	5d                   	pop    %ebp
  801e22:	c3                   	ret    

00801e23 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 08             	sub    $0x8,%esp
  801e29:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e32:	74 2a                	je     801e5e <devcons_read+0x3b>
  801e34:	eb 05                	jmp    801e3b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e36:	e8 4d ed ff ff       	call   800b88 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e3b:	e8 c9 ec ff ff       	call   800b09 <sys_cgetc>
  801e40:	85 c0                	test   %eax,%eax
  801e42:	74 f2                	je     801e36 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e44:	85 c0                	test   %eax,%eax
  801e46:	78 16                	js     801e5e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e48:	83 f8 04             	cmp    $0x4,%eax
  801e4b:	74 0c                	je     801e59 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e50:	88 02                	mov    %al,(%edx)
	return 1;
  801e52:	b8 01 00 00 00       	mov    $0x1,%eax
  801e57:	eb 05                	jmp    801e5e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e59:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e66:	8b 45 08             	mov    0x8(%ebp),%eax
  801e69:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e6c:	6a 01                	push   $0x1
  801e6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e71:	50                   	push   %eax
  801e72:	e8 74 ec ff ff       	call   800aeb <sys_cputs>
}
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <getchar>:

int
getchar(void)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e82:	6a 01                	push   $0x1
  801e84:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e87:	50                   	push   %eax
  801e88:	6a 00                	push   $0x0
  801e8a:	e8 25 f2 ff ff       	call   8010b4 <read>
	if (r < 0)
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 0f                	js     801ea5 <getchar+0x29>
		return r;
	if (r < 1)
  801e96:	85 c0                	test   %eax,%eax
  801e98:	7e 06                	jle    801ea0 <getchar+0x24>
		return -E_EOF;
	return c;
  801e9a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e9e:	eb 05                	jmp    801ea5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ea0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ead:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb0:	50                   	push   %eax
  801eb1:	ff 75 08             	pushl  0x8(%ebp)
  801eb4:	e8 95 ef ff ff       	call   800e4e <fd_lookup>
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 11                	js     801ed1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ec9:	39 10                	cmp    %edx,(%eax)
  801ecb:	0f 94 c0             	sete   %al
  801ece:	0f b6 c0             	movzbl %al,%eax
}
  801ed1:	c9                   	leave  
  801ed2:	c3                   	ret    

00801ed3 <opencons>:

int
opencons(void)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	e8 1d ef ff ff       	call   800dff <fd_alloc>
  801ee2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 3e                	js     801f29 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eeb:	83 ec 04             	sub    $0x4,%esp
  801eee:	68 07 04 00 00       	push   $0x407
  801ef3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 aa ec ff ff       	call   800ba7 <sys_page_alloc>
  801efd:	83 c4 10             	add    $0x10,%esp
		return r;
  801f00:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 23                	js     801f29 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f06:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f14:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f1b:	83 ec 0c             	sub    $0xc,%esp
  801f1e:	50                   	push   %eax
  801f1f:	e8 b4 ee ff ff       	call   800dd8 <fd2num>
  801f24:	89 c2                	mov    %eax,%edx
  801f26:	83 c4 10             	add    $0x10,%esp
}
  801f29:	89 d0                	mov    %edx,%eax
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	56                   	push   %esi
  801f31:	53                   	push   %ebx
  801f32:	8b 75 08             	mov    0x8(%ebp),%esi
  801f35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	74 0e                	je     801f4d <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	50                   	push   %eax
  801f43:	e8 0f ee ff ff       	call   800d57 <sys_ipc_recv>
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	eb 10                	jmp    801f5d <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801f4d:	83 ec 0c             	sub    $0xc,%esp
  801f50:	68 00 00 00 f0       	push   $0xf0000000
  801f55:	e8 fd ed ff ff       	call   800d57 <sys_ipc_recv>
  801f5a:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	74 0e                	je     801f6f <ipc_recv+0x42>
    	*from_env_store = 0;
  801f61:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801f67:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801f6d:	eb 24                	jmp    801f93 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801f6f:	85 f6                	test   %esi,%esi
  801f71:	74 0a                	je     801f7d <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801f73:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f78:	8b 40 74             	mov    0x74(%eax),%eax
  801f7b:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801f7d:	85 db                	test   %ebx,%ebx
  801f7f:	74 0a                	je     801f8b <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801f81:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f86:	8b 40 78             	mov    0x78(%eax),%eax
  801f89:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801f8b:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f90:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f96:	5b                   	pop    %ebx
  801f97:	5e                   	pop    %esi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	57                   	push   %edi
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 0c             	sub    $0xc,%esp
  801fa3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801fac:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801fae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fb3:	0f 44 d8             	cmove  %eax,%ebx
  801fb6:	eb 1c                	jmp    801fd4 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801fb8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fbb:	74 12                	je     801fcf <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801fbd:	50                   	push   %eax
  801fbe:	68 37 28 80 00       	push   $0x802837
  801fc3:	6a 4b                	push   $0x4b
  801fc5:	68 4f 28 80 00       	push   $0x80284f
  801fca:	e8 77 e1 ff ff       	call   800146 <_panic>
        }	
        sys_yield();
  801fcf:	e8 b4 eb ff ff       	call   800b88 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fd4:	ff 75 14             	pushl  0x14(%ebp)
  801fd7:	53                   	push   %ebx
  801fd8:	56                   	push   %esi
  801fd9:	57                   	push   %edi
  801fda:	e8 55 ed ff ff       	call   800d34 <sys_ipc_try_send>
  801fdf:	83 c4 10             	add    $0x10,%esp
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	75 d2                	jne    801fb8 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe9:	5b                   	pop    %ebx
  801fea:	5e                   	pop    %esi
  801feb:	5f                   	pop    %edi
  801fec:	5d                   	pop    %ebp
  801fed:	c3                   	ret    

00801fee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ff4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ff9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ffc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802002:	8b 52 50             	mov    0x50(%edx),%edx
  802005:	39 ca                	cmp    %ecx,%edx
  802007:	75 0d                	jne    802016 <ipc_find_env+0x28>
			return envs[i].env_id;
  802009:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802011:	8b 40 48             	mov    0x48(%eax),%eax
  802014:	eb 0f                	jmp    802025 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802016:	83 c0 01             	add    $0x1,%eax
  802019:	3d 00 04 00 00       	cmp    $0x400,%eax
  80201e:	75 d9                	jne    801ff9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    

00802027 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202d:	89 d0                	mov    %edx,%eax
  80202f:	c1 e8 16             	shr    $0x16,%eax
  802032:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802039:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203e:	f6 c1 01             	test   $0x1,%cl
  802041:	74 1d                	je     802060 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802043:	c1 ea 0c             	shr    $0xc,%edx
  802046:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204d:	f6 c2 01             	test   $0x1,%dl
  802050:	74 0e                	je     802060 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802052:	c1 ea 0c             	shr    $0xc,%edx
  802055:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80205c:	ef 
  80205d:	0f b7 c0             	movzwl %ax,%eax
}
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
