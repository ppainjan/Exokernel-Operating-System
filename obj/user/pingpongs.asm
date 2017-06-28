
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 68 10 00 00       	call   8010a9 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 f2 0a 00 00       	call   800b45 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 c0 26 80 00       	push   $0x8026c0
  80005d:	e8 99 01 00 00       	call   8001fb <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 db 0a 00 00       	call   800b45 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 da 26 80 00       	push   $0x8026da
  800074:	e8 82 01 00 00       	call   8001fb <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 a9 10 00 00       	call   801130 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 29 10 00 00       	call   8010c3 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 92 0a 00 00       	call   800b45 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 f0 26 80 00       	push   $0x8026f0
  8000c2:	e8 34 01 00 00       	call   8001fb <cprintf>
		if (val == 10)
  8000c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 46 10 00 00       	call   801130 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800109:	c7 05 0c 40 80 00 00 	movl   $0x0,0x80400c
  800110:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800113:	e8 2d 0a 00 00       	call   800b45 <sys_getenvid>
  800118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	85 db                	test   %ebx,%ebx
  80012c:	7e 07                	jle    800135 <libmain+0x37>
		binaryname = argv[0];
  80012e:	8b 06                	mov    (%esi),%eax
  800130:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
  80013a:	e8 f4 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013f:	e8 0a 00 00 00       	call   80014e <exit>
}
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800154:	e8 2f 12 00 00       	call   801388 <close_all>
	sys_env_destroy(0);
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	6a 00                	push   $0x0
  80015e:	e8 a1 09 00 00       	call   800b04 <sys_env_destroy>
}
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	75 1a                	jne    8001a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 2f 09 00 00       	call   800ac7 <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	50                   	push   %eax
  8001d4:	68 68 01 80 00       	push   $0x800168
  8001d9:	e8 54 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001de:	83 c4 08             	add    $0x8,%esp
  8001e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 d4 08 00 00       	call   800ac7 <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	50                   	push   %eax
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	e8 9d ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 1c             	sub    $0x1c,%esp
  800218:	89 c7                	mov    %eax,%edi
  80021a:	89 d6                	mov    %edx,%esi
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800222:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800225:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800228:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800233:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800236:	39 d3                	cmp    %edx,%ebx
  800238:	72 05                	jb     80023f <printnum+0x30>
  80023a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023d:	77 45                	ja     800284 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 18             	pushl  0x18(%ebp)
  800245:	8b 45 14             	mov    0x14(%ebp),%eax
  800248:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024b:	53                   	push   %ebx
  80024c:	ff 75 10             	pushl  0x10(%ebp)
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 cd 21 00 00       	call   802430 <__udivdi3>
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	52                   	push   %edx
  800267:	50                   	push   %eax
  800268:	89 f2                	mov    %esi,%edx
  80026a:	89 f8                	mov    %edi,%eax
  80026c:	e8 9e ff ff ff       	call   80020f <printnum>
  800271:	83 c4 20             	add    $0x20,%esp
  800274:	eb 18                	jmp    80028e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	eb 03                	jmp    800287 <printnum+0x78>
  800284:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	83 eb 01             	sub    $0x1,%ebx
  80028a:	85 db                	test   %ebx,%ebx
  80028c:	7f e8                	jg     800276 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	ff 75 e4             	pushl  -0x1c(%ebp)
  800298:	ff 75 e0             	pushl  -0x20(%ebp)
  80029b:	ff 75 dc             	pushl  -0x24(%ebp)
  80029e:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a1:	e8 ba 22 00 00       	call   802560 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 20 27 80 00 	movsbl 0x802720(%eax),%eax
  8002b0:	50                   	push   %eax
  8002b1:	ff d7                	call   *%edi
}
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	88 02                	mov    %al,(%edx)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	eb 12                	jmp    800358 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 89 03 00 00    	je     8006d7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	53                   	push   %ebx
  800352:	50                   	push   %eax
  800353:	ff d6                	call   *%esi
  800355:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800358:	83 c7 01             	add    $0x1,%edi
  80035b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035f:	83 f8 25             	cmp    $0x25,%eax
  800362:	75 e2                	jne    800346 <vprintfmt+0x14>
  800364:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800368:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800376:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
  800382:	eb 07                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800387:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8d 47 01             	lea    0x1(%edi),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	0f b6 07             	movzbl (%edi),%eax
  800394:	0f b6 c8             	movzbl %al,%ecx
  800397:	83 e8 23             	sub    $0x23,%eax
  80039a:	3c 55                	cmp    $0x55,%al
  80039c:	0f 87 1a 03 00 00    	ja     8006bc <vprintfmt+0x38a>
  8003a2:	0f b6 c0             	movzbl %al,%eax
  8003a5:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b3:	eb d6                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003cd:	83 fa 09             	cmp    $0x9,%edx
  8003d0:	77 39                	ja     80040b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e8:	eb 27                	jmp    800411 <vprintfmt+0xdf>
  8003ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f4:	0f 49 c8             	cmovns %eax,%ecx
  8003f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fd:	eb 8c                	jmp    80038b <vprintfmt+0x59>
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800402:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800409:	eb 80                	jmp    80038b <vprintfmt+0x59>
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	0f 89 70 ff ff ff    	jns    80038b <vprintfmt+0x59>
				width = precision, precision = -1;
  80041b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800421:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800428:	e9 5e ff ff ff       	jmp    80038b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800433:	e9 53 ff ff ff       	jmp    80038b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	ff 30                	pushl  (%eax)
  800447:	ff d6                	call   *%esi
			break;
  800449:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044f:	e9 04 ff ff ff       	jmp    800358 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	99                   	cltd   
  800460:	31 d0                	xor    %edx,%eax
  800462:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800464:	83 f8 0f             	cmp    $0xf,%eax
  800467:	7f 0b                	jg     800474 <vprintfmt+0x142>
  800469:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	75 18                	jne    80048c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800474:	50                   	push   %eax
  800475:	68 38 27 80 00       	push   $0x802738
  80047a:	53                   	push   %ebx
  80047b:	56                   	push   %esi
  80047c:	e8 94 fe ff ff       	call   800315 <printfmt>
  800481:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800487:	e9 cc fe ff ff       	jmp    800358 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048c:	52                   	push   %edx
  80048d:	68 71 2c 80 00       	push   $0x802c71
  800492:	53                   	push   %ebx
  800493:	56                   	push   %esi
  800494:	e8 7c fe ff ff       	call   800315 <printfmt>
  800499:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049f:	e9 b4 fe ff ff       	jmp    800358 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004af:	85 ff                	test   %edi,%edi
  8004b1:	b8 31 27 80 00       	mov    $0x802731,%eax
  8004b6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bd:	0f 8e 94 00 00 00    	jle    800557 <vprintfmt+0x225>
  8004c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c7:	0f 84 98 00 00 00    	je     800565 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d3:	57                   	push   %edi
  8004d4:	e8 86 02 00 00       	call   80075f <strnlen>
  8004d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004dc:	29 c1                	sub    %eax,%ecx
  8004de:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004eb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ee:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	eb 0f                	jmp    800501 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ef 01             	sub    $0x1,%edi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 ff                	test   %edi,%edi
  800503:	7f ed                	jg     8004f2 <vprintfmt+0x1c0>
  800505:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800508:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80050b:	85 c9                	test   %ecx,%ecx
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	0f 49 c1             	cmovns %ecx,%eax
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 75 08             	mov    %esi,0x8(%ebp)
  80051a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800520:	89 cb                	mov    %ecx,%ebx
  800522:	eb 4d                	jmp    800571 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800524:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800528:	74 1b                	je     800545 <vprintfmt+0x213>
  80052a:	0f be c0             	movsbl %al,%eax
  80052d:	83 e8 20             	sub    $0x20,%eax
  800530:	83 f8 5e             	cmp    $0x5e,%eax
  800533:	76 10                	jbe    800545 <vprintfmt+0x213>
					putch('?', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 0c             	pushl  0xc(%ebp)
  80053b:	6a 3f                	push   $0x3f
  80053d:	ff 55 08             	call   *0x8(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb 0d                	jmp    800552 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	ff 75 0c             	pushl  0xc(%ebp)
  80054b:	52                   	push   %edx
  80054c:	ff 55 08             	call   *0x8(%ebp)
  80054f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	83 eb 01             	sub    $0x1,%ebx
  800555:	eb 1a                	jmp    800571 <vprintfmt+0x23f>
  800557:	89 75 08             	mov    %esi,0x8(%ebp)
  80055a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800560:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800563:	eb 0c                	jmp    800571 <vprintfmt+0x23f>
  800565:	89 75 08             	mov    %esi,0x8(%ebp)
  800568:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800571:	83 c7 01             	add    $0x1,%edi
  800574:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800578:	0f be d0             	movsbl %al,%edx
  80057b:	85 d2                	test   %edx,%edx
  80057d:	74 23                	je     8005a2 <vprintfmt+0x270>
  80057f:	85 f6                	test   %esi,%esi
  800581:	78 a1                	js     800524 <vprintfmt+0x1f2>
  800583:	83 ee 01             	sub    $0x1,%esi
  800586:	79 9c                	jns    800524 <vprintfmt+0x1f2>
  800588:	89 df                	mov    %ebx,%edi
  80058a:	8b 75 08             	mov    0x8(%ebp),%esi
  80058d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800590:	eb 18                	jmp    8005aa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	6a 20                	push   $0x20
  800598:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059a:	83 ef 01             	sub    $0x1,%edi
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	eb 08                	jmp    8005aa <vprintfmt+0x278>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	85 ff                	test   %edi,%edi
  8005ac:	7f e4                	jg     800592 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	e9 a2 fd ff ff       	jmp    800358 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b6:	83 fa 01             	cmp    $0x1,%edx
  8005b9:	7e 16                	jle    8005d1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 08             	lea    0x8(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 50 04             	mov    0x4(%eax),%edx
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cf:	eb 32                	jmp    800603 <vprintfmt+0x2d1>
	else if (lflag)
  8005d1:	85 d2                	test   %edx,%edx
  8005d3:	74 18                	je     8005ed <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	eb 16                	jmp    800603 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fb:	89 c1                	mov    %eax,%ecx
  8005fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800600:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800603:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800606:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800609:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800612:	79 74                	jns    800688 <vprintfmt+0x356>
				putch('-', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 2d                	push   $0x2d
  80061a:	ff d6                	call   *%esi
				num = -(long long) num;
  80061c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800622:	f7 d8                	neg    %eax
  800624:	83 d2 00             	adc    $0x0,%edx
  800627:	f7 da                	neg    %edx
  800629:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800631:	eb 55                	jmp    800688 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 83 fc ff ff       	call   8002be <getuint>
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800640:	eb 46                	jmp    800688 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 74 fc ff ff       	call   8002be <getuint>
		        base = 8;
  80064a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80064f:	eb 37                	jmp    800688 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 30                	push   $0x30
  800657:	ff d6                	call   *%esi
			putch('x', putdat);
  800659:	83 c4 08             	add    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 78                	push   $0x78
  80065f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 50 04             	lea    0x4(%eax),%edx
  800667:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066a:	8b 00                	mov    (%eax),%eax
  80066c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800671:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800674:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800679:	eb 0d                	jmp    800688 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 3b fc ff ff       	call   8002be <getuint>
			base = 16;
  800683:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068f:	57                   	push   %edi
  800690:	ff 75 e0             	pushl  -0x20(%ebp)
  800693:	51                   	push   %ecx
  800694:	52                   	push   %edx
  800695:	50                   	push   %eax
  800696:	89 da                	mov    %ebx,%edx
  800698:	89 f0                	mov    %esi,%eax
  80069a:	e8 70 fb ff ff       	call   80020f <printnum>
			break;
  80069f:	83 c4 20             	add    $0x20,%esp
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a5:	e9 ae fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	51                   	push   %ecx
  8006af:	ff d6                	call   *%esi
			break;
  8006b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b7:	e9 9c fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 25                	push   $0x25
  8006c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb 03                	jmp    8006cc <vprintfmt+0x39a>
  8006c9:	83 ef 01             	sub    $0x1,%edi
  8006cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d0:	75 f7                	jne    8006c9 <vprintfmt+0x397>
  8006d2:	e9 81 fc ff ff       	jmp    800358 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006da:	5b                   	pop    %ebx
  8006db:	5e                   	pop    %esi
  8006dc:	5f                   	pop    %edi
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 18             	sub    $0x18,%esp
  8006e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 26                	je     800726 <vsnprintf+0x47>
  800700:	85 d2                	test   %edx,%edx
  800702:	7e 22                	jle    800726 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800704:	ff 75 14             	pushl  0x14(%ebp)
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	68 f8 02 80 00       	push   $0x8002f8
  800713:	e8 1a fc ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb 05                	jmp    80072b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800736:	50                   	push   %eax
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	ff 75 08             	pushl  0x8(%ebp)
  800740:	e8 9a ff ff ff       	call   8006df <vsnprintf>
	va_end(ap);

	return rc;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	eb 03                	jmp    800757 <strlen+0x10>
		n++;
  800754:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800757:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075b:	75 f7                	jne    800754 <strlen+0xd>
		n++;
	return n;
}
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800765:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	ba 00 00 00 00       	mov    $0x0,%edx
  80076d:	eb 03                	jmp    800772 <strnlen+0x13>
		n++;
  80076f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800772:	39 c2                	cmp    %eax,%edx
  800774:	74 08                	je     80077e <strnlen+0x1f>
  800776:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077a:	75 f3                	jne    80076f <strnlen+0x10>
  80077c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078a:	89 c2                	mov    %eax,%edx
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	83 c1 01             	add    $0x1,%ecx
  800792:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800796:	88 5a ff             	mov    %bl,-0x1(%edx)
  800799:	84 db                	test   %bl,%bl
  80079b:	75 ef                	jne    80078c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a7:	53                   	push   %ebx
  8007a8:	e8 9a ff ff ff       	call   800747 <strlen>
  8007ad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b0:	ff 75 0c             	pushl  0xc(%ebp)
  8007b3:	01 d8                	add    %ebx,%eax
  8007b5:	50                   	push   %eax
  8007b6:	e8 c5 ff ff ff       	call   800780 <strcpy>
	return dst;
}
  8007bb:	89 d8                	mov    %ebx,%eax
  8007bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	89 f3                	mov    %esi,%ebx
  8007cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	eb 0f                	jmp    8007e5 <strncpy+0x23>
		*dst++ = *src;
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	0f b6 01             	movzbl (%ecx),%eax
  8007dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007df:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e5:	39 da                	cmp    %ebx,%edx
  8007e7:	75 ed                	jne    8007d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ff:	85 d2                	test   %edx,%edx
  800801:	74 21                	je     800824 <strlcpy+0x35>
  800803:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 09                	jmp    800814 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800814:	39 c2                	cmp    %eax,%edx
  800816:	74 09                	je     800821 <strlcpy+0x32>
  800818:	0f b6 19             	movzbl (%ecx),%ebx
  80081b:	84 db                	test   %bl,%bl
  80081d:	75 ec                	jne    80080b <strlcpy+0x1c>
  80081f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800821:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800824:	29 f0                	sub    %esi,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800833:	eb 06                	jmp    80083b <strcmp+0x11>
		p++, q++;
  800835:	83 c1 01             	add    $0x1,%ecx
  800838:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083b:	0f b6 01             	movzbl (%ecx),%eax
  80083e:	84 c0                	test   %al,%al
  800840:	74 04                	je     800846 <strcmp+0x1c>
  800842:	3a 02                	cmp    (%edx),%al
  800844:	74 ef                	je     800835 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800846:	0f b6 c0             	movzbl %al,%eax
  800849:	0f b6 12             	movzbl (%edx),%edx
  80084c:	29 d0                	sub    %edx,%eax
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	89 c3                	mov    %eax,%ebx
  80085c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strncmp+0x17>
		n--, p++, q++;
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	74 15                	je     800880 <strncmp+0x30>
  80086b:	0f b6 08             	movzbl (%eax),%ecx
  80086e:	84 c9                	test   %cl,%cl
  800870:	74 04                	je     800876 <strncmp+0x26>
  800872:	3a 0a                	cmp    (%edx),%cl
  800874:	74 eb                	je     800861 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 00             	movzbl (%eax),%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
  80087e:	eb 05                	jmp    800885 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800892:	eb 07                	jmp    80089b <strchr+0x13>
		if (*s == c)
  800894:	38 ca                	cmp    %cl,%dl
  800896:	74 0f                	je     8008a7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	0f b6 10             	movzbl (%eax),%edx
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	75 f2                	jne    800894 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b3:	eb 03                	jmp    8008b8 <strfind+0xf>
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 04                	je     8008c3 <strfind+0x1a>
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f2                	jne    8008b5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d1:	85 c9                	test   %ecx,%ecx
  8008d3:	74 36                	je     80090b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 28                	jne    800905 <memset+0x40>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 23                	jne    800905 <memset+0x40>
		c &= 0xFF;
  8008e2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e6:	89 d3                	mov    %edx,%ebx
  8008e8:	c1 e3 08             	shl    $0x8,%ebx
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	c1 e6 18             	shl    $0x18,%esi
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	c1 e0 10             	shl    $0x10,%eax
  8008f5:	09 f0                	or     %esi,%eax
  8008f7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f9:	89 d8                	mov    %ebx,%eax
  8008fb:	09 d0                	or     %edx,%eax
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb 06                	jmp    80090b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	fc                   	cld    
  800909:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800920:	39 c6                	cmp    %eax,%esi
  800922:	73 35                	jae    800959 <memmove+0x47>
  800924:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800927:	39 d0                	cmp    %edx,%eax
  800929:	73 2e                	jae    800959 <memmove+0x47>
		s += n;
		d += n;
  80092b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 d6                	mov    %edx,%esi
  800930:	09 fe                	or     %edi,%esi
  800932:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800938:	75 13                	jne    80094d <memmove+0x3b>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 0e                	jne    80094d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093f:	83 ef 04             	sub    $0x4,%edi
  800942:	8d 72 fc             	lea    -0x4(%edx),%esi
  800945:	c1 e9 02             	shr    $0x2,%ecx
  800948:	fd                   	std    
  800949:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094b:	eb 09                	jmp    800956 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094d:	83 ef 01             	sub    $0x1,%edi
  800950:	8d 72 ff             	lea    -0x1(%edx),%esi
  800953:	fd                   	std    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800956:	fc                   	cld    
  800957:	eb 1d                	jmp    800976 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 f2                	mov    %esi,%edx
  80095b:	09 c2                	or     %eax,%edx
  80095d:	f6 c2 03             	test   $0x3,%dl
  800960:	75 0f                	jne    800971 <memmove+0x5f>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 0a                	jne    800971 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800967:	c1 e9 02             	shr    $0x2,%ecx
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096f:	eb 05                	jmp    800976 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097d:	ff 75 10             	pushl  0x10(%ebp)
  800980:	ff 75 0c             	pushl  0xc(%ebp)
  800983:	ff 75 08             	pushl  0x8(%ebp)
  800986:	e8 87 ff ff ff       	call   800912 <memmove>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
  800998:	89 c6                	mov    %eax,%esi
  80099a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099d:	eb 1a                	jmp    8009b9 <memcmp+0x2c>
		if (*s1 != *s2)
  80099f:	0f b6 08             	movzbl (%eax),%ecx
  8009a2:	0f b6 1a             	movzbl (%edx),%ebx
  8009a5:	38 d9                	cmp    %bl,%cl
  8009a7:	74 0a                	je     8009b3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a9:	0f b6 c1             	movzbl %cl,%eax
  8009ac:	0f b6 db             	movzbl %bl,%ebx
  8009af:	29 d8                	sub    %ebx,%eax
  8009b1:	eb 0f                	jmp    8009c2 <memcmp+0x35>
		s1++, s2++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b9:	39 f0                	cmp    %esi,%eax
  8009bb:	75 e2                	jne    80099f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009cd:	89 c1                	mov    %eax,%ecx
  8009cf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	eb 0a                	jmp    8009e2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d8:	0f b6 10             	movzbl (%eax),%edx
  8009db:	39 da                	cmp    %ebx,%edx
  8009dd:	74 07                	je     8009e6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	39 c8                	cmp    %ecx,%eax
  8009e4:	72 f2                	jb     8009d8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f5:	eb 03                	jmp    8009fa <strtol+0x11>
		s++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	0f b6 01             	movzbl (%ecx),%eax
  8009fd:	3c 20                	cmp    $0x20,%al
  8009ff:	74 f6                	je     8009f7 <strtol+0xe>
  800a01:	3c 09                	cmp    $0x9,%al
  800a03:	74 f2                	je     8009f7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a05:	3c 2b                	cmp    $0x2b,%al
  800a07:	75 0a                	jne    800a13 <strtol+0x2a>
		s++;
  800a09:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a11:	eb 11                	jmp    800a24 <strtol+0x3b>
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a18:	3c 2d                	cmp    $0x2d,%al
  800a1a:	75 08                	jne    800a24 <strtol+0x3b>
		s++, neg = 1;
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2a:	75 15                	jne    800a41 <strtol+0x58>
  800a2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2f:	75 10                	jne    800a41 <strtol+0x58>
  800a31:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a35:	75 7c                	jne    800ab3 <strtol+0xca>
		s += 2, base = 16;
  800a37:	83 c1 02             	add    $0x2,%ecx
  800a3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3f:	eb 16                	jmp    800a57 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a41:	85 db                	test   %ebx,%ebx
  800a43:	75 12                	jne    800a57 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a45:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4d:	75 08                	jne    800a57 <strtol+0x6e>
		s++, base = 8;
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5f:	0f b6 11             	movzbl (%ecx),%edx
  800a62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 09             	cmp    $0x9,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0x8b>
			dig = *s - '0';
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 30             	sub    $0x30,%edx
  800a72:	eb 22                	jmp    800a96 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 57             	sub    $0x57,%edx
  800a84:	eb 10                	jmp    800a96 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 16                	ja     800aa6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 0b                	jge    800aa6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa4:	eb b9                	jmp    800a5f <strtol+0x76>

	if (endptr)
  800aa6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaa:	74 0d                	je     800ab9 <strtol+0xd0>
		*endptr = (char *) s;
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	89 0e                	mov    %ecx,(%esi)
  800ab1:	eb 06                	jmp    800ab9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	74 98                	je     800a4f <strtol+0x66>
  800ab7:	eb 9e                	jmp    800a57 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab9:	89 c2                	mov    %eax,%edx
  800abb:	f7 da                	neg    %edx
  800abd:	85 ff                	test   %edi,%edi
  800abf:	0f 45 c2             	cmovne %edx,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	89 c6                	mov    %eax,%esi
  800ade:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 01 00 00 00       	mov    $0x1,%eax
  800af5:	89 d1                	mov    %edx,%ecx
  800af7:	89 d3                	mov    %edx,%ebx
  800af9:	89 d7                	mov    %edx,%edi
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b12:	b8 03 00 00 00       	mov    $0x3,%eax
  800b17:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1a:	89 cb                	mov    %ecx,%ebx
  800b1c:	89 cf                	mov    %ecx,%edi
  800b1e:	89 ce                	mov    %ecx,%esi
  800b20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b22:	85 c0                	test   %eax,%eax
  800b24:	7e 17                	jle    800b3d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	50                   	push   %eax
  800b2a:	6a 03                	push   $0x3
  800b2c:	68 1f 2a 80 00       	push   $0x802a1f
  800b31:	6a 23                	push   $0x23
  800b33:	68 3c 2a 80 00       	push   $0x802a3c
  800b38:	e8 d5 17 00 00       	call   802312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 02 00 00 00       	mov    $0x2,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_yield>:

void
sys_yield(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b74:	89 d1                	mov    %edx,%ecx
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	89 d7                	mov    %edx,%edi
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	be 00 00 00 00       	mov    $0x0,%esi
  800b91:	b8 04 00 00 00       	mov    $0x4,%eax
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9f:	89 f7                	mov    %esi,%edi
  800ba1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 17                	jle    800bbe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	50                   	push   %eax
  800bab:	6a 04                	push   $0x4
  800bad:	68 1f 2a 80 00       	push   $0x802a1f
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 3c 2a 80 00       	push   $0x802a3c
  800bb9:	e8 54 17 00 00       	call   802312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be0:	8b 75 18             	mov    0x18(%ebp),%esi
  800be3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 05                	push   $0x5
  800bef:	68 1f 2a 80 00       	push   $0x802a1f
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 3c 2a 80 00       	push   $0x802a3c
  800bfb:	e8 12 17 00 00       	call   802312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 17                	jle    800c42 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	6a 06                	push   $0x6
  800c31:	68 1f 2a 80 00       	push   $0x802a1f
  800c36:	6a 23                	push   $0x23
  800c38:	68 3c 2a 80 00       	push   $0x802a3c
  800c3d:	e8 d0 16 00 00       	call   802312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 08                	push   $0x8
  800c73:	68 1f 2a 80 00       	push   $0x802a1f
  800c78:	6a 23                	push   $0x23
  800c7a:	68 3c 2a 80 00       	push   $0x802a3c
  800c7f:	e8 8e 16 00 00       	call   802312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 17                	jle    800cc6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 09                	push   $0x9
  800cb5:	68 1f 2a 80 00       	push   $0x802a1f
  800cba:	6a 23                	push   $0x23
  800cbc:	68 3c 2a 80 00       	push   $0x802a3c
  800cc1:	e8 4c 16 00 00       	call   802312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 df                	mov    %ebx,%edi
  800ce9:	89 de                	mov    %ebx,%esi
  800ceb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7e 17                	jle    800d08 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	50                   	push   %eax
  800cf5:	6a 0a                	push   $0xa
  800cf7:	68 1f 2a 80 00       	push   $0x802a1f
  800cfc:	6a 23                	push   $0x23
  800cfe:	68 3c 2a 80 00       	push   $0x802a3c
  800d03:	e8 0a 16 00 00       	call   802312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	be 00 00 00 00       	mov    $0x0,%esi
  800d1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 cb                	mov    %ecx,%ebx
  800d4b:	89 cf                	mov    %ecx,%edi
  800d4d:	89 ce                	mov    %ecx,%esi
  800d4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 17                	jle    800d6c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 0d                	push   $0xd
  800d5b:	68 1f 2a 80 00       	push   $0x802a1f
  800d60:	6a 23                	push   $0x23
  800d62:	68 3c 2a 80 00       	push   $0x802a3c
  800d67:	e8 a6 15 00 00       	call   802312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d84:	89 d1                	mov    %edx,%ecx
  800d86:	89 d3                	mov    %edx,%ebx
  800d88:	89 d7                	mov    %edx,%edi
  800d8a:	89 d6                	mov    %edx,%esi
  800d8c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	53                   	push   %ebx
  800db8:	83 ec 04             	sub    $0x4,%esp
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800dbe:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800dc0:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800dc4:	74 2e                	je     800df4 <pgfault+0x40>
  800dc6:	89 c2                	mov    %eax,%edx
  800dc8:	c1 ea 16             	shr    $0x16,%edx
  800dcb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd2:	f6 c2 01             	test   $0x1,%dl
  800dd5:	74 1d                	je     800df4 <pgfault+0x40>
  800dd7:	89 c2                	mov    %eax,%edx
  800dd9:	c1 ea 0c             	shr    $0xc,%edx
  800ddc:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800de3:	f6 c1 01             	test   $0x1,%cl
  800de6:	74 0c                	je     800df4 <pgfault+0x40>
  800de8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800def:	f6 c6 08             	test   $0x8,%dh
  800df2:	75 14                	jne    800e08 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	68 4a 2a 80 00       	push   $0x802a4a
  800dfc:	6a 1d                	push   $0x1d
  800dfe:	68 5d 2a 80 00       	push   $0x802a5d
  800e03:	e8 0a 15 00 00       	call   802312 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800e08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0d:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	6a 07                	push   $0x7
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 63 fd ff ff       	call   800b83 <sys_page_alloc>
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 14                	jns    800e3b <pgfault+0x87>
		panic("page alloc failed \n");
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 68 2a 80 00       	push   $0x802a68
  800e2f:	6a 28                	push   $0x28
  800e31:	68 5d 2a 80 00       	push   $0x802a5d
  800e36:	e8 d7 14 00 00       	call   802312 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800e3b:	83 ec 04             	sub    $0x4,%esp
  800e3e:	68 00 10 00 00       	push   $0x1000
  800e43:	53                   	push   %ebx
  800e44:	68 00 f0 7f 00       	push   $0x7ff000
  800e49:	e8 2c fb ff ff       	call   80097a <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800e4e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e55:	53                   	push   %ebx
  800e56:	6a 00                	push   $0x0
  800e58:	68 00 f0 7f 00       	push   $0x7ff000
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 62 fd ff ff       	call   800bc6 <sys_page_map>
  800e64:	83 c4 20             	add    $0x20,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 14                	jns    800e7f <pgfault+0xcb>
        panic("page map failed \n");
  800e6b:	83 ec 04             	sub    $0x4,%esp
  800e6e:	68 7c 2a 80 00       	push   $0x802a7c
  800e73:	6a 2b                	push   $0x2b
  800e75:	68 5d 2a 80 00       	push   $0x802a5d
  800e7a:	e8 93 14 00 00       	call   802312 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	68 00 f0 7f 00       	push   $0x7ff000
  800e87:	6a 00                	push   $0x0
  800e89:	e8 7a fd ff ff       	call   800c08 <sys_page_unmap>
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	85 c0                	test   %eax,%eax
  800e93:	79 14                	jns    800ea9 <pgfault+0xf5>
        panic("page unmap failed\n");
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	68 8e 2a 80 00       	push   $0x802a8e
  800e9d:	6a 2d                	push   $0x2d
  800e9f:	68 5d 2a 80 00       	push   $0x802a5d
  800ea4:	e8 69 14 00 00       	call   802312 <_panic>
	
	//panic("pgfault not implemented");
}
  800ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800eb7:	68 b4 0d 80 00       	push   $0x800db4
  800ebc:	e8 97 14 00 00       	call   802358 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ec1:	b8 07 00 00 00       	mov    $0x7,%eax
  800ec6:	cd 30                	int    $0x30
  800ec8:	89 c7                	mov    %eax,%edi
  800eca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	79 12                	jns    800ee6 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800ed4:	50                   	push   %eax
  800ed5:	68 a1 2a 80 00       	push   $0x802aa1
  800eda:	6a 7a                	push   $0x7a
  800edc:	68 5d 2a 80 00       	push   $0x802a5d
  800ee1:	e8 2c 14 00 00       	call   802312 <_panic>
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	75 21                	jne    800f10 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eef:	e8 51 fc ff ff       	call   800b45 <sys_getenvid>
  800ef4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800efc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f01:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0b:	e9 91 01 00 00       	jmp    8010a1 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	c1 e8 16             	shr    $0x16,%eax
  800f15:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f1c:	a8 01                	test   $0x1,%al
  800f1e:	0f 84 06 01 00 00    	je     80102a <fork+0x17c>
  800f24:	89 d8                	mov    %ebx,%eax
  800f26:	c1 e8 0c             	shr    $0xc,%eax
  800f29:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	0f 84 f1 00 00 00    	je     80102a <fork+0x17c>
  800f39:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f40:	f6 c2 04             	test   $0x4,%dl
  800f43:	0f 84 e1 00 00 00    	je     80102a <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  800f49:	89 c6                	mov    %eax,%esi
  800f4b:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  800f4e:	89 f2                	mov    %esi,%edx
  800f50:	c1 ea 16             	shr    $0x16,%edx
  800f53:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  800f5a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  800f61:	f6 c6 04             	test   $0x4,%dh
  800f64:	74 39                	je     800f9f <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  800f66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	25 07 0e 00 00       	and    $0xe07,%eax
  800f75:	50                   	push   %eax
  800f76:	56                   	push   %esi
  800f77:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7a:	56                   	push   %esi
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 44 fc ff ff       	call   800bc6 <sys_page_map>
  800f82:	83 c4 20             	add    $0x20,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	0f 89 9d 00 00 00    	jns    80102a <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  800f8d:	50                   	push   %eax
  800f8e:	68 f8 2a 80 00       	push   $0x802af8
  800f93:	6a 4b                	push   $0x4b
  800f95:	68 5d 2a 80 00       	push   $0x802a5d
  800f9a:	e8 73 13 00 00       	call   802312 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  800f9f:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800fa5:	74 59                	je     801000 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	68 05 08 00 00       	push   $0x805
  800faf:	56                   	push   %esi
  800fb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 0b fc ff ff       	call   800bc6 <sys_page_map>
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	79 12                	jns    800fd4 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  800fc2:	50                   	push   %eax
  800fc3:	68 28 2b 80 00       	push   $0x802b28
  800fc8:	6a 50                	push   $0x50
  800fca:	68 5d 2a 80 00       	push   $0x802a5d
  800fcf:	e8 3e 13 00 00       	call   802312 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800fd4:	83 ec 0c             	sub    $0xc,%esp
  800fd7:	68 05 08 00 00       	push   $0x805
  800fdc:	56                   	push   %esi
  800fdd:	6a 00                	push   $0x0
  800fdf:	56                   	push   %esi
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 df fb ff ff       	call   800bc6 <sys_page_map>
  800fe7:	83 c4 20             	add    $0x20,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	79 3c                	jns    80102a <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  800fee:	50                   	push   %eax
  800fef:	68 50 2b 80 00       	push   $0x802b50
  800ff4:	6a 53                	push   $0x53
  800ff6:	68 5d 2a 80 00       	push   $0x802a5d
  800ffb:	e8 12 13 00 00       	call   802312 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	6a 05                	push   $0x5
  801005:	56                   	push   %esi
  801006:	ff 75 e4             	pushl  -0x1c(%ebp)
  801009:	56                   	push   %esi
  80100a:	6a 00                	push   $0x0
  80100c:	e8 b5 fb ff ff       	call   800bc6 <sys_page_map>
  801011:	83 c4 20             	add    $0x20,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	79 12                	jns    80102a <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  801018:	50                   	push   %eax
  801019:	68 78 2b 80 00       	push   $0x802b78
  80101e:	6a 58                	push   $0x58
  801020:	68 5d 2a 80 00       	push   $0x802a5d
  801025:	e8 e8 12 00 00       	call   802312 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  80102a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801030:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801036:	0f 85 d4 fe ff ff    	jne    800f10 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	6a 07                	push   $0x7
  801041:	68 00 f0 bf ee       	push   $0xeebff000
  801046:	57                   	push   %edi
  801047:	e8 37 fb ff ff       	call   800b83 <sys_page_alloc>
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 17                	jns    80106a <fork+0x1bc>
        panic("page alloc failed\n");
  801053:	83 ec 04             	sub    $0x4,%esp
  801056:	68 b3 2a 80 00       	push   $0x802ab3
  80105b:	68 87 00 00 00       	push   $0x87
  801060:	68 5d 2a 80 00       	push   $0x802a5d
  801065:	e8 a8 12 00 00       	call   802312 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	68 c7 23 80 00       	push   $0x8023c7
  801072:	57                   	push   %edi
  801073:	e8 56 fc ff ff       	call   800cce <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801078:	83 c4 08             	add    $0x8,%esp
  80107b:	6a 02                	push   $0x2
  80107d:	57                   	push   %edi
  80107e:	e8 c7 fb ff ff       	call   800c4a <sys_env_set_status>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	79 15                	jns    80109f <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  80108a:	50                   	push   %eax
  80108b:	68 c6 2a 80 00       	push   $0x802ac6
  801090:	68 8c 00 00 00       	push   $0x8c
  801095:	68 5d 2a 80 00       	push   $0x802a5d
  80109a:	e8 73 12 00 00       	call   802312 <_panic>

	return envid;
  80109f:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  8010a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5e                   	pop    %esi
  8010a6:	5f                   	pop    %edi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <sfork>:

// Challenge!
int
sfork(void)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010af:	68 df 2a 80 00       	push   $0x802adf
  8010b4:	68 98 00 00 00       	push   $0x98
  8010b9:	68 5d 2a 80 00       	push   $0x802a5d
  8010be:	e8 4f 12 00 00       	call   802312 <_panic>

008010c3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8010cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	74 0e                	je     8010e3 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	50                   	push   %eax
  8010d9:	e8 55 fc ff ff       	call   800d33 <sys_ipc_recv>
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	eb 10                	jmp    8010f3 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	68 00 00 00 f0       	push   $0xf0000000
  8010eb:	e8 43 fc ff ff       	call   800d33 <sys_ipc_recv>
  8010f0:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 0e                	je     801105 <ipc_recv+0x42>
    	*from_env_store = 0;
  8010f7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8010fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801103:	eb 24                	jmp    801129 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801105:	85 f6                	test   %esi,%esi
  801107:	74 0a                	je     801113 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801109:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80110e:	8b 40 74             	mov    0x74(%eax),%eax
  801111:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801113:	85 db                	test   %ebx,%ebx
  801115:	74 0a                	je     801121 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801117:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80111c:	8b 40 78             	mov    0x78(%eax),%eax
  80111f:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801121:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801126:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	53                   	push   %ebx
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80113f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801142:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801149:	0f 44 d8             	cmove  %eax,%ebx
  80114c:	eb 1c                	jmp    80116a <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80114e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801151:	74 12                	je     801165 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801153:	50                   	push   %eax
  801154:	68 a4 2b 80 00       	push   $0x802ba4
  801159:	6a 4b                	push   $0x4b
  80115b:	68 bc 2b 80 00       	push   $0x802bbc
  801160:	e8 ad 11 00 00       	call   802312 <_panic>
        }	
        sys_yield();
  801165:	e8 fa f9 ff ff       	call   800b64 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80116a:	ff 75 14             	pushl  0x14(%ebp)
  80116d:	53                   	push   %ebx
  80116e:	56                   	push   %esi
  80116f:	57                   	push   %edi
  801170:	e8 9b fb ff ff       	call   800d10 <sys_ipc_try_send>
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	75 d2                	jne    80114e <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80118f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801192:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801198:	8b 52 50             	mov    0x50(%edx),%edx
  80119b:	39 ca                	cmp    %ecx,%edx
  80119d:	75 0d                	jne    8011ac <ipc_find_env+0x28>
			return envs[i].env_id;
  80119f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a7:	8b 40 48             	mov    0x48(%eax),%eax
  8011aa:	eb 0f                	jmp    8011bb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ac:	83 c0 01             	add    $0x1,%eax
  8011af:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011b4:	75 d9                	jne    80118f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c8:	c1 e8 0c             	shr    $0xc,%eax
}
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011dd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	c1 ea 16             	shr    $0x16,%edx
  8011f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fb:	f6 c2 01             	test   $0x1,%dl
  8011fe:	74 11                	je     801211 <fd_alloc+0x2d>
  801200:	89 c2                	mov    %eax,%edx
  801202:	c1 ea 0c             	shr    $0xc,%edx
  801205:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120c:	f6 c2 01             	test   $0x1,%dl
  80120f:	75 09                	jne    80121a <fd_alloc+0x36>
			*fd_store = fd;
  801211:	89 01                	mov    %eax,(%ecx)
			return 0;
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
  801218:	eb 17                	jmp    801231 <fd_alloc+0x4d>
  80121a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80121f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801224:	75 c9                	jne    8011ef <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801226:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80122c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801239:	83 f8 1f             	cmp    $0x1f,%eax
  80123c:	77 36                	ja     801274 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123e:	c1 e0 0c             	shl    $0xc,%eax
  801241:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801246:	89 c2                	mov    %eax,%edx
  801248:	c1 ea 16             	shr    $0x16,%edx
  80124b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801252:	f6 c2 01             	test   $0x1,%dl
  801255:	74 24                	je     80127b <fd_lookup+0x48>
  801257:	89 c2                	mov    %eax,%edx
  801259:	c1 ea 0c             	shr    $0xc,%edx
  80125c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801263:	f6 c2 01             	test   $0x1,%dl
  801266:	74 1a                	je     801282 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126b:	89 02                	mov    %eax,(%edx)
	return 0;
  80126d:	b8 00 00 00 00       	mov    $0x0,%eax
  801272:	eb 13                	jmp    801287 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801274:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801279:	eb 0c                	jmp    801287 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801280:	eb 05                	jmp    801287 <fd_lookup+0x54>
  801282:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801292:	ba 44 2c 80 00       	mov    $0x802c44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801297:	eb 13                	jmp    8012ac <dev_lookup+0x23>
  801299:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80129c:	39 08                	cmp    %ecx,(%eax)
  80129e:	75 0c                	jne    8012ac <dev_lookup+0x23>
			*dev = devtab[i];
  8012a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012aa:	eb 2e                	jmp    8012da <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ac:	8b 02                	mov    (%edx),%eax
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	75 e7                	jne    801299 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012b7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	51                   	push   %ecx
  8012be:	50                   	push   %eax
  8012bf:	68 c8 2b 80 00       	push   $0x802bc8
  8012c4:	e8 32 ef ff ff       	call   8001fb <cprintf>
	*dev = 0;
  8012c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012da:	c9                   	leave  
  8012db:	c3                   	ret    

008012dc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
  8012e1:	83 ec 10             	sub    $0x10,%esp
  8012e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f4:	c1 e8 0c             	shr    $0xc,%eax
  8012f7:	50                   	push   %eax
  8012f8:	e8 36 ff ff ff       	call   801233 <fd_lookup>
  8012fd:	83 c4 08             	add    $0x8,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 05                	js     801309 <fd_close+0x2d>
	    || fd != fd2)
  801304:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801307:	74 0c                	je     801315 <fd_close+0x39>
		return (must_exist ? r : 0);
  801309:	84 db                	test   %bl,%bl
  80130b:	ba 00 00 00 00       	mov    $0x0,%edx
  801310:	0f 44 c2             	cmove  %edx,%eax
  801313:	eb 41                	jmp    801356 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	ff 36                	pushl  (%esi)
  80131e:	e8 66 ff ff ff       	call   801289 <dev_lookup>
  801323:	89 c3                	mov    %eax,%ebx
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 1a                	js     801346 <fd_close+0x6a>
		if (dev->dev_close)
  80132c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801332:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801337:	85 c0                	test   %eax,%eax
  801339:	74 0b                	je     801346 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	56                   	push   %esi
  80133f:	ff d0                	call   *%eax
  801341:	89 c3                	mov    %eax,%ebx
  801343:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	56                   	push   %esi
  80134a:	6a 00                	push   $0x0
  80134c:	e8 b7 f8 ff ff       	call   800c08 <sys_page_unmap>
	return r;
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	89 d8                	mov    %ebx,%eax
}
  801356:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801359:	5b                   	pop    %ebx
  80135a:	5e                   	pop    %esi
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    

0080135d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801363:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 c4 fe ff ff       	call   801233 <fd_lookup>
  80136f:	83 c4 08             	add    $0x8,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	78 10                	js     801386 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	6a 01                	push   $0x1
  80137b:	ff 75 f4             	pushl  -0xc(%ebp)
  80137e:	e8 59 ff ff ff       	call   8012dc <fd_close>
  801383:	83 c4 10             	add    $0x10,%esp
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <close_all>:

void
close_all(void)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	53                   	push   %ebx
  80138c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80138f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801394:	83 ec 0c             	sub    $0xc,%esp
  801397:	53                   	push   %ebx
  801398:	e8 c0 ff ff ff       	call   80135d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80139d:	83 c3 01             	add    $0x1,%ebx
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	83 fb 20             	cmp    $0x20,%ebx
  8013a6:	75 ec                	jne    801394 <close_all+0xc>
		close(i);
}
  8013a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    

008013ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	57                   	push   %edi
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 2c             	sub    $0x2c,%esp
  8013b6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	e8 6e fe ff ff       	call   801233 <fd_lookup>
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	0f 88 c1 00 00 00    	js     801491 <dup+0xe4>
		return r;
	close(newfdnum);
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	56                   	push   %esi
  8013d4:	e8 84 ff ff ff       	call   80135d <close>

	newfd = INDEX2FD(newfdnum);
  8013d9:	89 f3                	mov    %esi,%ebx
  8013db:	c1 e3 0c             	shl    $0xc,%ebx
  8013de:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e4:	83 c4 04             	add    $0x4,%esp
  8013e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ea:	e8 de fd ff ff       	call   8011cd <fd2data>
  8013ef:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f1:	89 1c 24             	mov    %ebx,(%esp)
  8013f4:	e8 d4 fd ff ff       	call   8011cd <fd2data>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ff:	89 f8                	mov    %edi,%eax
  801401:	c1 e8 16             	shr    $0x16,%eax
  801404:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80140b:	a8 01                	test   $0x1,%al
  80140d:	74 37                	je     801446 <dup+0x99>
  80140f:	89 f8                	mov    %edi,%eax
  801411:	c1 e8 0c             	shr    $0xc,%eax
  801414:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80141b:	f6 c2 01             	test   $0x1,%dl
  80141e:	74 26                	je     801446 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801420:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	25 07 0e 00 00       	and    $0xe07,%eax
  80142f:	50                   	push   %eax
  801430:	ff 75 d4             	pushl  -0x2c(%ebp)
  801433:	6a 00                	push   $0x0
  801435:	57                   	push   %edi
  801436:	6a 00                	push   $0x0
  801438:	e8 89 f7 ff ff       	call   800bc6 <sys_page_map>
  80143d:	89 c7                	mov    %eax,%edi
  80143f:	83 c4 20             	add    $0x20,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 2e                	js     801474 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801446:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801449:	89 d0                	mov    %edx,%eax
  80144b:	c1 e8 0c             	shr    $0xc,%eax
  80144e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	25 07 0e 00 00       	and    $0xe07,%eax
  80145d:	50                   	push   %eax
  80145e:	53                   	push   %ebx
  80145f:	6a 00                	push   $0x0
  801461:	52                   	push   %edx
  801462:	6a 00                	push   $0x0
  801464:	e8 5d f7 ff ff       	call   800bc6 <sys_page_map>
  801469:	89 c7                	mov    %eax,%edi
  80146b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80146e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801470:	85 ff                	test   %edi,%edi
  801472:	79 1d                	jns    801491 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	53                   	push   %ebx
  801478:	6a 00                	push   $0x0
  80147a:	e8 89 f7 ff ff       	call   800c08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	ff 75 d4             	pushl  -0x2c(%ebp)
  801485:	6a 00                	push   $0x0
  801487:	e8 7c f7 ff ff       	call   800c08 <sys_page_unmap>
	return r;
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	89 f8                	mov    %edi,%eax
}
  801491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801494:	5b                   	pop    %ebx
  801495:	5e                   	pop    %esi
  801496:	5f                   	pop    %edi
  801497:	5d                   	pop    %ebp
  801498:	c3                   	ret    

00801499 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	53                   	push   %ebx
  80149d:	83 ec 14             	sub    $0x14,%esp
  8014a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	53                   	push   %ebx
  8014a8:	e8 86 fd ff ff       	call   801233 <fd_lookup>
  8014ad:	83 c4 08             	add    $0x8,%esp
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 6d                	js     801523 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c0:	ff 30                	pushl  (%eax)
  8014c2:	e8 c2 fd ff ff       	call   801289 <dev_lookup>
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 4c                	js     80151a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d1:	8b 42 08             	mov    0x8(%edx),%eax
  8014d4:	83 e0 03             	and    $0x3,%eax
  8014d7:	83 f8 01             	cmp    $0x1,%eax
  8014da:	75 21                	jne    8014fd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dc:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014e1:	8b 40 48             	mov    0x48(%eax),%eax
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	53                   	push   %ebx
  8014e8:	50                   	push   %eax
  8014e9:	68 09 2c 80 00       	push   $0x802c09
  8014ee:	e8 08 ed ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fb:	eb 26                	jmp    801523 <read+0x8a>
	}
	if (!dev->dev_read)
  8014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801500:	8b 40 08             	mov    0x8(%eax),%eax
  801503:	85 c0                	test   %eax,%eax
  801505:	74 17                	je     80151e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	ff 75 10             	pushl  0x10(%ebp)
  80150d:	ff 75 0c             	pushl  0xc(%ebp)
  801510:	52                   	push   %edx
  801511:	ff d0                	call   *%eax
  801513:	89 c2                	mov    %eax,%edx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	eb 09                	jmp    801523 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	eb 05                	jmp    801523 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80151e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801523:	89 d0                	mov    %edx,%eax
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	57                   	push   %edi
  80152e:	56                   	push   %esi
  80152f:	53                   	push   %ebx
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	8b 7d 08             	mov    0x8(%ebp),%edi
  801536:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801539:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153e:	eb 21                	jmp    801561 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	89 f0                	mov    %esi,%eax
  801545:	29 d8                	sub    %ebx,%eax
  801547:	50                   	push   %eax
  801548:	89 d8                	mov    %ebx,%eax
  80154a:	03 45 0c             	add    0xc(%ebp),%eax
  80154d:	50                   	push   %eax
  80154e:	57                   	push   %edi
  80154f:	e8 45 ff ff ff       	call   801499 <read>
		if (m < 0)
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 10                	js     80156b <readn+0x41>
			return m;
		if (m == 0)
  80155b:	85 c0                	test   %eax,%eax
  80155d:	74 0a                	je     801569 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155f:	01 c3                	add    %eax,%ebx
  801561:	39 f3                	cmp    %esi,%ebx
  801563:	72 db                	jb     801540 <readn+0x16>
  801565:	89 d8                	mov    %ebx,%eax
  801567:	eb 02                	jmp    80156b <readn+0x41>
  801569:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80156b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 14             	sub    $0x14,%esp
  80157a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	53                   	push   %ebx
  801582:	e8 ac fc ff ff       	call   801233 <fd_lookup>
  801587:	83 c4 08             	add    $0x8,%esp
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 68                	js     8015f8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801590:	83 ec 08             	sub    $0x8,%esp
  801593:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159a:	ff 30                	pushl  (%eax)
  80159c:	e8 e8 fc ff ff       	call   801289 <dev_lookup>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 47                	js     8015ef <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015af:	75 21                	jne    8015d2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015b6:	8b 40 48             	mov    0x48(%eax),%eax
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	50                   	push   %eax
  8015be:	68 25 2c 80 00       	push   $0x802c25
  8015c3:	e8 33 ec ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d0:	eb 26                	jmp    8015f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d8:	85 d2                	test   %edx,%edx
  8015da:	74 17                	je     8015f3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	ff 75 10             	pushl  0x10(%ebp)
  8015e2:	ff 75 0c             	pushl  0xc(%ebp)
  8015e5:	50                   	push   %eax
  8015e6:	ff d2                	call   *%edx
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	eb 09                	jmp    8015f8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	eb 05                	jmp    8015f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f8:	89 d0                	mov    %edx,%eax
  8015fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801605:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	ff 75 08             	pushl  0x8(%ebp)
  80160c:	e8 22 fc ff ff       	call   801233 <fd_lookup>
  801611:	83 c4 08             	add    $0x8,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 0e                	js     801626 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801618:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801621:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	53                   	push   %ebx
  80162c:	83 ec 14             	sub    $0x14,%esp
  80162f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801632:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	53                   	push   %ebx
  801637:	e8 f7 fb ff ff       	call   801233 <fd_lookup>
  80163c:	83 c4 08             	add    $0x8,%esp
  80163f:	89 c2                	mov    %eax,%edx
  801641:	85 c0                	test   %eax,%eax
  801643:	78 65                	js     8016aa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	ff 30                	pushl  (%eax)
  801651:	e8 33 fc ff ff       	call   801289 <dev_lookup>
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 44                	js     8016a1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801660:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801664:	75 21                	jne    801687 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801666:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80166b:	8b 40 48             	mov    0x48(%eax),%eax
  80166e:	83 ec 04             	sub    $0x4,%esp
  801671:	53                   	push   %ebx
  801672:	50                   	push   %eax
  801673:	68 e8 2b 80 00       	push   $0x802be8
  801678:	e8 7e eb ff ff       	call   8001fb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801685:	eb 23                	jmp    8016aa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801687:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168a:	8b 52 18             	mov    0x18(%edx),%edx
  80168d:	85 d2                	test   %edx,%edx
  80168f:	74 14                	je     8016a5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	ff 75 0c             	pushl  0xc(%ebp)
  801697:	50                   	push   %eax
  801698:	ff d2                	call   *%edx
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	eb 09                	jmp    8016aa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	eb 05                	jmp    8016aa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016aa:	89 d0                	mov    %edx,%eax
  8016ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 14             	sub    $0x14,%esp
  8016b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016be:	50                   	push   %eax
  8016bf:	ff 75 08             	pushl  0x8(%ebp)
  8016c2:	e8 6c fb ff ff       	call   801233 <fd_lookup>
  8016c7:	83 c4 08             	add    $0x8,%esp
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 58                	js     801728 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d0:	83 ec 08             	sub    $0x8,%esp
  8016d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016da:	ff 30                	pushl  (%eax)
  8016dc:	e8 a8 fb ff ff       	call   801289 <dev_lookup>
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 37                	js     80171f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ef:	74 32                	je     801723 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fb:	00 00 00 
	stat->st_isdir = 0;
  8016fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801705:	00 00 00 
	stat->st_dev = dev;
  801708:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	53                   	push   %ebx
  801712:	ff 75 f0             	pushl  -0x10(%ebp)
  801715:	ff 50 14             	call   *0x14(%eax)
  801718:	89 c2                	mov    %eax,%edx
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	eb 09                	jmp    801728 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171f:	89 c2                	mov    %eax,%edx
  801721:	eb 05                	jmp    801728 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801723:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801728:	89 d0                	mov    %edx,%eax
  80172a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	56                   	push   %esi
  801733:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801734:	83 ec 08             	sub    $0x8,%esp
  801737:	6a 00                	push   $0x0
  801739:	ff 75 08             	pushl  0x8(%ebp)
  80173c:	e8 e7 01 00 00       	call   801928 <open>
  801741:	89 c3                	mov    %eax,%ebx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	78 1b                	js     801765 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	50                   	push   %eax
  801751:	e8 5b ff ff ff       	call   8016b1 <fstat>
  801756:	89 c6                	mov    %eax,%esi
	close(fd);
  801758:	89 1c 24             	mov    %ebx,(%esp)
  80175b:	e8 fd fb ff ff       	call   80135d <close>
	return r;
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	89 f0                	mov    %esi,%eax
}
  801765:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801768:	5b                   	pop    %ebx
  801769:	5e                   	pop    %esi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	89 c6                	mov    %eax,%esi
  801773:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801775:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177c:	75 12                	jne    801790 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177e:	83 ec 0c             	sub    $0xc,%esp
  801781:	6a 01                	push   $0x1
  801783:	e8 fc f9 ff ff       	call   801184 <ipc_find_env>
  801788:	a3 00 40 80 00       	mov    %eax,0x804000
  80178d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801790:	6a 07                	push   $0x7
  801792:	68 00 50 80 00       	push   $0x805000
  801797:	56                   	push   %esi
  801798:	ff 35 00 40 80 00    	pushl  0x804000
  80179e:	e8 8d f9 ff ff       	call   801130 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a3:	83 c4 0c             	add    $0xc,%esp
  8017a6:	6a 00                	push   $0x0
  8017a8:	53                   	push   %ebx
  8017a9:	6a 00                	push   $0x0
  8017ab:	e8 13 f9 ff ff       	call   8010c3 <ipc_recv>
}
  8017b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017da:	e8 8d ff ff ff       	call   80176c <fsipc>
}
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017fc:	e8 6b ff ff ff       	call   80176c <fsipc>
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	83 ec 04             	sub    $0x4,%esp
  80180a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	8b 40 0c             	mov    0xc(%eax),%eax
  801813:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
  80181d:	b8 05 00 00 00       	mov    $0x5,%eax
  801822:	e8 45 ff ff ff       	call   80176c <fsipc>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 2c                	js     801857 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	68 00 50 80 00       	push   $0x805000
  801833:	53                   	push   %ebx
  801834:	e8 47 ef ff ff       	call   800780 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801839:	a1 80 50 80 00       	mov    0x805080,%eax
  80183e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801844:	a1 84 50 80 00       	mov    0x805084,%eax
  801849:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	53                   	push   %ebx
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801866:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80186b:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801870:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801873:	53                   	push   %ebx
  801874:	ff 75 0c             	pushl  0xc(%ebp)
  801877:	68 08 50 80 00       	push   $0x805008
  80187c:	e8 91 f0 ff ff       	call   800912 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801881:	8b 45 08             	mov    0x8(%ebp),%eax
  801884:	8b 40 0c             	mov    0xc(%eax),%eax
  801887:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  80188c:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	b8 04 00 00 00       	mov    $0x4,%eax
  80189c:	e8 cb fe ff ff       	call   80176c <fsipc>
	//panic("devfile_write not implemented");
}
  8018a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c9:	e8 9e fe ff ff       	call   80176c <fsipc>
  8018ce:	89 c3                	mov    %eax,%ebx
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 4b                	js     80191f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d4:	39 c6                	cmp    %eax,%esi
  8018d6:	73 16                	jae    8018ee <devfile_read+0x48>
  8018d8:	68 58 2c 80 00       	push   $0x802c58
  8018dd:	68 5f 2c 80 00       	push   $0x802c5f
  8018e2:	6a 7c                	push   $0x7c
  8018e4:	68 74 2c 80 00       	push   $0x802c74
  8018e9:	e8 24 0a 00 00       	call   802312 <_panic>
	assert(r <= PGSIZE);
  8018ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f3:	7e 16                	jle    80190b <devfile_read+0x65>
  8018f5:	68 7f 2c 80 00       	push   $0x802c7f
  8018fa:	68 5f 2c 80 00       	push   $0x802c5f
  8018ff:	6a 7d                	push   $0x7d
  801901:	68 74 2c 80 00       	push   $0x802c74
  801906:	e8 07 0a 00 00       	call   802312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190b:	83 ec 04             	sub    $0x4,%esp
  80190e:	50                   	push   %eax
  80190f:	68 00 50 80 00       	push   $0x805000
  801914:	ff 75 0c             	pushl  0xc(%ebp)
  801917:	e8 f6 ef ff ff       	call   800912 <memmove>
	return r;
  80191c:	83 c4 10             	add    $0x10,%esp
}
  80191f:	89 d8                	mov    %ebx,%eax
  801921:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	53                   	push   %ebx
  80192c:	83 ec 20             	sub    $0x20,%esp
  80192f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801932:	53                   	push   %ebx
  801933:	e8 0f ee ff ff       	call   800747 <strlen>
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801940:	7f 67                	jg     8019a9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801942:	83 ec 0c             	sub    $0xc,%esp
  801945:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	e8 96 f8 ff ff       	call   8011e4 <fd_alloc>
  80194e:	83 c4 10             	add    $0x10,%esp
		return r;
  801951:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801953:	85 c0                	test   %eax,%eax
  801955:	78 57                	js     8019ae <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	53                   	push   %ebx
  80195b:	68 00 50 80 00       	push   $0x805000
  801960:	e8 1b ee ff ff       	call   800780 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801965:	8b 45 0c             	mov    0xc(%ebp),%eax
  801968:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80196d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801970:	b8 01 00 00 00       	mov    $0x1,%eax
  801975:	e8 f2 fd ff ff       	call   80176c <fsipc>
  80197a:	89 c3                	mov    %eax,%ebx
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	85 c0                	test   %eax,%eax
  801981:	79 14                	jns    801997 <open+0x6f>
		fd_close(fd, 0);
  801983:	83 ec 08             	sub    $0x8,%esp
  801986:	6a 00                	push   $0x0
  801988:	ff 75 f4             	pushl  -0xc(%ebp)
  80198b:	e8 4c f9 ff ff       	call   8012dc <fd_close>
		return r;
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	89 da                	mov    %ebx,%edx
  801995:	eb 17                	jmp    8019ae <open+0x86>
	}

	return fd2num(fd);
  801997:	83 ec 0c             	sub    $0xc,%esp
  80199a:	ff 75 f4             	pushl  -0xc(%ebp)
  80199d:	e8 1b f8 ff ff       	call   8011bd <fd2num>
  8019a2:	89 c2                	mov    %eax,%edx
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	eb 05                	jmp    8019ae <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ae:	89 d0                	mov    %edx,%eax
  8019b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c5:	e8 a2 fd ff ff       	call   80176c <fsipc>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019d2:	68 8b 2c 80 00       	push   $0x802c8b
  8019d7:	ff 75 0c             	pushl  0xc(%ebp)
  8019da:	e8 a1 ed ff ff       	call   800780 <strcpy>
	return 0;
}
  8019df:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 10             	sub    $0x10,%esp
  8019ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019f0:	53                   	push   %ebx
  8019f1:	e8 f5 09 00 00       	call   8023eb <pageref>
  8019f6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019f9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019fe:	83 f8 01             	cmp    $0x1,%eax
  801a01:	75 10                	jne    801a13 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	ff 73 0c             	pushl  0xc(%ebx)
  801a09:	e8 c0 02 00 00       	call   801cce <nsipc_close>
  801a0e:	89 c2                	mov    %eax,%edx
  801a10:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a13:	89 d0                	mov    %edx,%eax
  801a15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a20:	6a 00                	push   $0x0
  801a22:	ff 75 10             	pushl  0x10(%ebp)
  801a25:	ff 75 0c             	pushl  0xc(%ebp)
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	ff 70 0c             	pushl  0xc(%eax)
  801a2e:	e8 78 03 00 00       	call   801dab <nsipc_send>
}
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a3b:	6a 00                	push   $0x0
  801a3d:	ff 75 10             	pushl  0x10(%ebp)
  801a40:	ff 75 0c             	pushl  0xc(%ebp)
  801a43:	8b 45 08             	mov    0x8(%ebp),%eax
  801a46:	ff 70 0c             	pushl  0xc(%eax)
  801a49:	e8 f1 02 00 00       	call   801d3f <nsipc_recv>
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a56:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a59:	52                   	push   %edx
  801a5a:	50                   	push   %eax
  801a5b:	e8 d3 f7 ff ff       	call   801233 <fd_lookup>
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 17                	js     801a7e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a70:	39 08                	cmp    %ecx,(%eax)
  801a72:	75 05                	jne    801a79 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a74:	8b 40 0c             	mov    0xc(%eax),%eax
  801a77:	eb 05                	jmp    801a7e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a79:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	83 ec 1c             	sub    $0x1c,%esp
  801a88:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8d:	50                   	push   %eax
  801a8e:	e8 51 f7 ff ff       	call   8011e4 <fd_alloc>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 1b                	js     801ab7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a9c:	83 ec 04             	sub    $0x4,%esp
  801a9f:	68 07 04 00 00       	push   $0x407
  801aa4:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 d5 f0 ff ff       	call   800b83 <sys_page_alloc>
  801aae:	89 c3                	mov    %eax,%ebx
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	79 10                	jns    801ac7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	56                   	push   %esi
  801abb:	e8 0e 02 00 00       	call   801cce <nsipc_close>
		return r;
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	89 d8                	mov    %ebx,%eax
  801ac5:	eb 24                	jmp    801aeb <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ac7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801adc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	50                   	push   %eax
  801ae3:	e8 d5 f6 ff ff       	call   8011bd <fd2num>
  801ae8:	83 c4 10             	add    $0x10,%esp
}
  801aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	e8 50 ff ff ff       	call   801a50 <fd2sockid>
		return r;
  801b00:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b02:	85 c0                	test   %eax,%eax
  801b04:	78 1f                	js     801b25 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b06:	83 ec 04             	sub    $0x4,%esp
  801b09:	ff 75 10             	pushl  0x10(%ebp)
  801b0c:	ff 75 0c             	pushl  0xc(%ebp)
  801b0f:	50                   	push   %eax
  801b10:	e8 12 01 00 00       	call   801c27 <nsipc_accept>
  801b15:	83 c4 10             	add    $0x10,%esp
		return r;
  801b18:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 07                	js     801b25 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b1e:	e8 5d ff ff ff       	call   801a80 <alloc_sockfd>
  801b23:	89 c1                	mov    %eax,%ecx
}
  801b25:	89 c8                	mov    %ecx,%eax
  801b27:	c9                   	leave  
  801b28:	c3                   	ret    

00801b29 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	e8 19 ff ff ff       	call   801a50 <fd2sockid>
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 12                	js     801b4d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b3b:	83 ec 04             	sub    $0x4,%esp
  801b3e:	ff 75 10             	pushl  0x10(%ebp)
  801b41:	ff 75 0c             	pushl  0xc(%ebp)
  801b44:	50                   	push   %eax
  801b45:	e8 2d 01 00 00       	call   801c77 <nsipc_bind>
  801b4a:	83 c4 10             	add    $0x10,%esp
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    

00801b4f <shutdown>:

int
shutdown(int s, int how)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b55:	8b 45 08             	mov    0x8(%ebp),%eax
  801b58:	e8 f3 fe ff ff       	call   801a50 <fd2sockid>
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	78 0f                	js     801b70 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b61:	83 ec 08             	sub    $0x8,%esp
  801b64:	ff 75 0c             	pushl  0xc(%ebp)
  801b67:	50                   	push   %eax
  801b68:	e8 3f 01 00 00       	call   801cac <nsipc_shutdown>
  801b6d:	83 c4 10             	add    $0x10,%esp
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	e8 d0 fe ff ff       	call   801a50 <fd2sockid>
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 12                	js     801b96 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	ff 75 10             	pushl  0x10(%ebp)
  801b8a:	ff 75 0c             	pushl  0xc(%ebp)
  801b8d:	50                   	push   %eax
  801b8e:	e8 55 01 00 00       	call   801ce8 <nsipc_connect>
  801b93:	83 c4 10             	add    $0x10,%esp
}
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <listen>:

int
listen(int s, int backlog)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba1:	e8 aa fe ff ff       	call   801a50 <fd2sockid>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 0f                	js     801bb9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801baa:	83 ec 08             	sub    $0x8,%esp
  801bad:	ff 75 0c             	pushl  0xc(%ebp)
  801bb0:	50                   	push   %eax
  801bb1:	e8 67 01 00 00       	call   801d1d <nsipc_listen>
  801bb6:	83 c4 10             	add    $0x10,%esp
}
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bc1:	ff 75 10             	pushl  0x10(%ebp)
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	ff 75 08             	pushl  0x8(%ebp)
  801bca:	e8 3a 02 00 00       	call   801e09 <nsipc_socket>
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	78 05                	js     801bdb <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bd6:	e8 a5 fe ff ff       	call   801a80 <alloc_sockfd>
}
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	53                   	push   %ebx
  801be1:	83 ec 04             	sub    $0x4,%esp
  801be4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801be6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bed:	75 12                	jne    801c01 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bef:	83 ec 0c             	sub    $0xc,%esp
  801bf2:	6a 02                	push   $0x2
  801bf4:	e8 8b f5 ff ff       	call   801184 <ipc_find_env>
  801bf9:	a3 04 40 80 00       	mov    %eax,0x804004
  801bfe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c01:	6a 07                	push   $0x7
  801c03:	68 00 60 80 00       	push   $0x806000
  801c08:	53                   	push   %ebx
  801c09:	ff 35 04 40 80 00    	pushl  0x804004
  801c0f:	e8 1c f5 ff ff       	call   801130 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c14:	83 c4 0c             	add    $0xc,%esp
  801c17:	6a 00                	push   $0x0
  801c19:	6a 00                	push   $0x0
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 a1 f4 ff ff       	call   8010c3 <ipc_recv>
}
  801c22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c32:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c37:	8b 06                	mov    (%esi),%eax
  801c39:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c43:	e8 95 ff ff ff       	call   801bdd <nsipc>
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 20                	js     801c6e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c4e:	83 ec 04             	sub    $0x4,%esp
  801c51:	ff 35 10 60 80 00    	pushl  0x806010
  801c57:	68 00 60 80 00       	push   $0x806000
  801c5c:	ff 75 0c             	pushl  0xc(%ebp)
  801c5f:	e8 ae ec ff ff       	call   800912 <memmove>
		*addrlen = ret->ret_addrlen;
  801c64:	a1 10 60 80 00       	mov    0x806010,%eax
  801c69:	89 06                	mov    %eax,(%esi)
  801c6b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c6e:	89 d8                	mov    %ebx,%eax
  801c70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 08             	sub    $0x8,%esp
  801c7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c89:	53                   	push   %ebx
  801c8a:	ff 75 0c             	pushl  0xc(%ebp)
  801c8d:	68 04 60 80 00       	push   $0x806004
  801c92:	e8 7b ec ff ff       	call   800912 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c97:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c9d:	b8 02 00 00 00       	mov    $0x2,%eax
  801ca2:	e8 36 ff ff ff       	call   801bdd <nsipc>
}
  801ca7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cc2:	b8 03 00 00 00       	mov    $0x3,%eax
  801cc7:	e8 11 ff ff ff       	call   801bdd <nsipc>
}
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <nsipc_close>:

int
nsipc_close(int s)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd7:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cdc:	b8 04 00 00 00       	mov    $0x4,%eax
  801ce1:	e8 f7 fe ff ff       	call   801bdd <nsipc>
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 08             	sub    $0x8,%esp
  801cef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cfa:	53                   	push   %ebx
  801cfb:	ff 75 0c             	pushl  0xc(%ebp)
  801cfe:	68 04 60 80 00       	push   $0x806004
  801d03:	e8 0a ec ff ff       	call   800912 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d08:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d0e:	b8 05 00 00 00       	mov    $0x5,%eax
  801d13:	e8 c5 fe ff ff       	call   801bdd <nsipc>
}
  801d18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d33:	b8 06 00 00 00       	mov    $0x6,%eax
  801d38:	e8 a0 fe ff ff       	call   801bdd <nsipc>
}
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d4f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d55:	8b 45 14             	mov    0x14(%ebp),%eax
  801d58:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d5d:	b8 07 00 00 00       	mov    $0x7,%eax
  801d62:	e8 76 fe ff ff       	call   801bdd <nsipc>
  801d67:	89 c3                	mov    %eax,%ebx
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	78 35                	js     801da2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d6d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d72:	7f 04                	jg     801d78 <nsipc_recv+0x39>
  801d74:	39 c6                	cmp    %eax,%esi
  801d76:	7d 16                	jge    801d8e <nsipc_recv+0x4f>
  801d78:	68 97 2c 80 00       	push   $0x802c97
  801d7d:	68 5f 2c 80 00       	push   $0x802c5f
  801d82:	6a 62                	push   $0x62
  801d84:	68 ac 2c 80 00       	push   $0x802cac
  801d89:	e8 84 05 00 00       	call   802312 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d8e:	83 ec 04             	sub    $0x4,%esp
  801d91:	50                   	push   %eax
  801d92:	68 00 60 80 00       	push   $0x806000
  801d97:	ff 75 0c             	pushl  0xc(%ebp)
  801d9a:	e8 73 eb ff ff       	call   800912 <memmove>
  801d9f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801da2:	89 d8                	mov    %ebx,%eax
  801da4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	53                   	push   %ebx
  801daf:	83 ec 04             	sub    $0x4,%esp
  801db2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801db5:	8b 45 08             	mov    0x8(%ebp),%eax
  801db8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dbd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dc3:	7e 16                	jle    801ddb <nsipc_send+0x30>
  801dc5:	68 b8 2c 80 00       	push   $0x802cb8
  801dca:	68 5f 2c 80 00       	push   $0x802c5f
  801dcf:	6a 6d                	push   $0x6d
  801dd1:	68 ac 2c 80 00       	push   $0x802cac
  801dd6:	e8 37 05 00 00       	call   802312 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ddb:	83 ec 04             	sub    $0x4,%esp
  801dde:	53                   	push   %ebx
  801ddf:	ff 75 0c             	pushl  0xc(%ebp)
  801de2:	68 0c 60 80 00       	push   $0x80600c
  801de7:	e8 26 eb ff ff       	call   800912 <memmove>
	nsipcbuf.send.req_size = size;
  801dec:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801df2:	8b 45 14             	mov    0x14(%ebp),%eax
  801df5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dfa:	b8 08 00 00 00       	mov    $0x8,%eax
  801dff:	e8 d9 fd ff ff       	call   801bdd <nsipc>
}
  801e04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    

00801e09 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e12:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e22:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e27:	b8 09 00 00 00       	mov    $0x9,%eax
  801e2c:	e8 ac fd ff ff       	call   801bdd <nsipc>
}
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	56                   	push   %esi
  801e37:	53                   	push   %ebx
  801e38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e3b:	83 ec 0c             	sub    $0xc,%esp
  801e3e:	ff 75 08             	pushl  0x8(%ebp)
  801e41:	e8 87 f3 ff ff       	call   8011cd <fd2data>
  801e46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e48:	83 c4 08             	add    $0x8,%esp
  801e4b:	68 c4 2c 80 00       	push   $0x802cc4
  801e50:	53                   	push   %ebx
  801e51:	e8 2a e9 ff ff       	call   800780 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e56:	8b 46 04             	mov    0x4(%esi),%eax
  801e59:	2b 06                	sub    (%esi),%eax
  801e5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e68:	00 00 00 
	stat->st_dev = &devpipe;
  801e6b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e72:	30 80 00 
	return 0;
}
  801e75:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e7d:	5b                   	pop    %ebx
  801e7e:	5e                   	pop    %esi
  801e7f:	5d                   	pop    %ebp
  801e80:	c3                   	ret    

00801e81 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	53                   	push   %ebx
  801e85:	83 ec 0c             	sub    $0xc,%esp
  801e88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e8b:	53                   	push   %ebx
  801e8c:	6a 00                	push   $0x0
  801e8e:	e8 75 ed ff ff       	call   800c08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e93:	89 1c 24             	mov    %ebx,(%esp)
  801e96:	e8 32 f3 ff ff       	call   8011cd <fd2data>
  801e9b:	83 c4 08             	add    $0x8,%esp
  801e9e:	50                   	push   %eax
  801e9f:	6a 00                	push   $0x0
  801ea1:	e8 62 ed ff ff       	call   800c08 <sys_page_unmap>
}
  801ea6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	57                   	push   %edi
  801eaf:	56                   	push   %esi
  801eb0:	53                   	push   %ebx
  801eb1:	83 ec 1c             	sub    $0x1c,%esp
  801eb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801eb7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801eb9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801ebe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ec7:	e8 1f 05 00 00       	call   8023eb <pageref>
  801ecc:	89 c3                	mov    %eax,%ebx
  801ece:	89 3c 24             	mov    %edi,(%esp)
  801ed1:	e8 15 05 00 00       	call   8023eb <pageref>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	39 c3                	cmp    %eax,%ebx
  801edb:	0f 94 c1             	sete   %cl
  801ede:	0f b6 c9             	movzbl %cl,%ecx
  801ee1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ee4:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801eea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801eed:	39 ce                	cmp    %ecx,%esi
  801eef:	74 1b                	je     801f0c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ef1:	39 c3                	cmp    %eax,%ebx
  801ef3:	75 c4                	jne    801eb9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ef5:	8b 42 58             	mov    0x58(%edx),%eax
  801ef8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801efb:	50                   	push   %eax
  801efc:	56                   	push   %esi
  801efd:	68 cb 2c 80 00       	push   $0x802ccb
  801f02:	e8 f4 e2 ff ff       	call   8001fb <cprintf>
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	eb ad                	jmp    801eb9 <_pipeisclosed+0xe>
	}
}
  801f0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f12:	5b                   	pop    %ebx
  801f13:	5e                   	pop    %esi
  801f14:	5f                   	pop    %edi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    

00801f17 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	57                   	push   %edi
  801f1b:	56                   	push   %esi
  801f1c:	53                   	push   %ebx
  801f1d:	83 ec 28             	sub    $0x28,%esp
  801f20:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f23:	56                   	push   %esi
  801f24:	e8 a4 f2 ff ff       	call   8011cd <fd2data>
  801f29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	bf 00 00 00 00       	mov    $0x0,%edi
  801f33:	eb 4b                	jmp    801f80 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f35:	89 da                	mov    %ebx,%edx
  801f37:	89 f0                	mov    %esi,%eax
  801f39:	e8 6d ff ff ff       	call   801eab <_pipeisclosed>
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	75 48                	jne    801f8a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f42:	e8 1d ec ff ff       	call   800b64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f47:	8b 43 04             	mov    0x4(%ebx),%eax
  801f4a:	8b 0b                	mov    (%ebx),%ecx
  801f4c:	8d 51 20             	lea    0x20(%ecx),%edx
  801f4f:	39 d0                	cmp    %edx,%eax
  801f51:	73 e2                	jae    801f35 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f56:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f5a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f5d:	89 c2                	mov    %eax,%edx
  801f5f:	c1 fa 1f             	sar    $0x1f,%edx
  801f62:	89 d1                	mov    %edx,%ecx
  801f64:	c1 e9 1b             	shr    $0x1b,%ecx
  801f67:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f6a:	83 e2 1f             	and    $0x1f,%edx
  801f6d:	29 ca                	sub    %ecx,%edx
  801f6f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f77:	83 c0 01             	add    $0x1,%eax
  801f7a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7d:	83 c7 01             	add    $0x1,%edi
  801f80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f83:	75 c2                	jne    801f47 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f85:	8b 45 10             	mov    0x10(%ebp),%eax
  801f88:	eb 05                	jmp    801f8f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f8a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f92:	5b                   	pop    %ebx
  801f93:	5e                   	pop    %esi
  801f94:	5f                   	pop    %edi
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    

00801f97 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	57                   	push   %edi
  801f9b:	56                   	push   %esi
  801f9c:	53                   	push   %ebx
  801f9d:	83 ec 18             	sub    $0x18,%esp
  801fa0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fa3:	57                   	push   %edi
  801fa4:	e8 24 f2 ff ff       	call   8011cd <fd2data>
  801fa9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fab:	83 c4 10             	add    $0x10,%esp
  801fae:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb3:	eb 3d                	jmp    801ff2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fb5:	85 db                	test   %ebx,%ebx
  801fb7:	74 04                	je     801fbd <devpipe_read+0x26>
				return i;
  801fb9:	89 d8                	mov    %ebx,%eax
  801fbb:	eb 44                	jmp    802001 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fbd:	89 f2                	mov    %esi,%edx
  801fbf:	89 f8                	mov    %edi,%eax
  801fc1:	e8 e5 fe ff ff       	call   801eab <_pipeisclosed>
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	75 32                	jne    801ffc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fca:	e8 95 eb ff ff       	call   800b64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fcf:	8b 06                	mov    (%esi),%eax
  801fd1:	3b 46 04             	cmp    0x4(%esi),%eax
  801fd4:	74 df                	je     801fb5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fd6:	99                   	cltd   
  801fd7:	c1 ea 1b             	shr    $0x1b,%edx
  801fda:	01 d0                	add    %edx,%eax
  801fdc:	83 e0 1f             	and    $0x1f,%eax
  801fdf:	29 d0                	sub    %edx,%eax
  801fe1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fe6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fe9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fef:	83 c3 01             	add    $0x1,%ebx
  801ff2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ff5:	75 d8                	jne    801fcf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ff7:	8b 45 10             	mov    0x10(%ebp),%eax
  801ffa:	eb 05                	jmp    802001 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ffc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802001:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	56                   	push   %esi
  80200d:	53                   	push   %ebx
  80200e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802011:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802014:	50                   	push   %eax
  802015:	e8 ca f1 ff ff       	call   8011e4 <fd_alloc>
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	89 c2                	mov    %eax,%edx
  80201f:	85 c0                	test   %eax,%eax
  802021:	0f 88 2c 01 00 00    	js     802153 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802027:	83 ec 04             	sub    $0x4,%esp
  80202a:	68 07 04 00 00       	push   $0x407
  80202f:	ff 75 f4             	pushl  -0xc(%ebp)
  802032:	6a 00                	push   $0x0
  802034:	e8 4a eb ff ff       	call   800b83 <sys_page_alloc>
  802039:	83 c4 10             	add    $0x10,%esp
  80203c:	89 c2                	mov    %eax,%edx
  80203e:	85 c0                	test   %eax,%eax
  802040:	0f 88 0d 01 00 00    	js     802153 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802046:	83 ec 0c             	sub    $0xc,%esp
  802049:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80204c:	50                   	push   %eax
  80204d:	e8 92 f1 ff ff       	call   8011e4 <fd_alloc>
  802052:	89 c3                	mov    %eax,%ebx
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	85 c0                	test   %eax,%eax
  802059:	0f 88 e2 00 00 00    	js     802141 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205f:	83 ec 04             	sub    $0x4,%esp
  802062:	68 07 04 00 00       	push   $0x407
  802067:	ff 75 f0             	pushl  -0x10(%ebp)
  80206a:	6a 00                	push   $0x0
  80206c:	e8 12 eb ff ff       	call   800b83 <sys_page_alloc>
  802071:	89 c3                	mov    %eax,%ebx
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	85 c0                	test   %eax,%eax
  802078:	0f 88 c3 00 00 00    	js     802141 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80207e:	83 ec 0c             	sub    $0xc,%esp
  802081:	ff 75 f4             	pushl  -0xc(%ebp)
  802084:	e8 44 f1 ff ff       	call   8011cd <fd2data>
  802089:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208b:	83 c4 0c             	add    $0xc,%esp
  80208e:	68 07 04 00 00       	push   $0x407
  802093:	50                   	push   %eax
  802094:	6a 00                	push   $0x0
  802096:	e8 e8 ea ff ff       	call   800b83 <sys_page_alloc>
  80209b:	89 c3                	mov    %eax,%ebx
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	0f 88 89 00 00 00    	js     802131 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a8:	83 ec 0c             	sub    $0xc,%esp
  8020ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ae:	e8 1a f1 ff ff       	call   8011cd <fd2data>
  8020b3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020ba:	50                   	push   %eax
  8020bb:	6a 00                	push   $0x0
  8020bd:	56                   	push   %esi
  8020be:	6a 00                	push   $0x0
  8020c0:	e8 01 eb ff ff       	call   800bc6 <sys_page_map>
  8020c5:	89 c3                	mov    %eax,%ebx
  8020c7:	83 c4 20             	add    $0x20,%esp
  8020ca:	85 c0                	test   %eax,%eax
  8020cc:	78 55                	js     802123 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020ce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020e3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020f8:	83 ec 0c             	sub    $0xc,%esp
  8020fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fe:	e8 ba f0 ff ff       	call   8011bd <fd2num>
  802103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802106:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802108:	83 c4 04             	add    $0x4,%esp
  80210b:	ff 75 f0             	pushl  -0x10(%ebp)
  80210e:	e8 aa f0 ff ff       	call   8011bd <fd2num>
  802113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802116:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	ba 00 00 00 00       	mov    $0x0,%edx
  802121:	eb 30                	jmp    802153 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802123:	83 ec 08             	sub    $0x8,%esp
  802126:	56                   	push   %esi
  802127:	6a 00                	push   $0x0
  802129:	e8 da ea ff ff       	call   800c08 <sys_page_unmap>
  80212e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802131:	83 ec 08             	sub    $0x8,%esp
  802134:	ff 75 f0             	pushl  -0x10(%ebp)
  802137:	6a 00                	push   $0x0
  802139:	e8 ca ea ff ff       	call   800c08 <sys_page_unmap>
  80213e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802141:	83 ec 08             	sub    $0x8,%esp
  802144:	ff 75 f4             	pushl  -0xc(%ebp)
  802147:	6a 00                	push   $0x0
  802149:	e8 ba ea ff ff       	call   800c08 <sys_page_unmap>
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802153:	89 d0                	mov    %edx,%eax
  802155:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    

0080215c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802162:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802165:	50                   	push   %eax
  802166:	ff 75 08             	pushl  0x8(%ebp)
  802169:	e8 c5 f0 ff ff       	call   801233 <fd_lookup>
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	85 c0                	test   %eax,%eax
  802173:	78 18                	js     80218d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802175:	83 ec 0c             	sub    $0xc,%esp
  802178:	ff 75 f4             	pushl  -0xc(%ebp)
  80217b:	e8 4d f0 ff ff       	call   8011cd <fd2data>
	return _pipeisclosed(fd, p);
  802180:	89 c2                	mov    %eax,%edx
  802182:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802185:	e8 21 fd ff ff       	call   801eab <_pipeisclosed>
  80218a:	83 c4 10             	add    $0x10,%esp
}
  80218d:	c9                   	leave  
  80218e:	c3                   	ret    

0080218f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802192:	b8 00 00 00 00       	mov    $0x0,%eax
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    

00802199 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80219f:	68 e3 2c 80 00       	push   $0x802ce3
  8021a4:	ff 75 0c             	pushl  0xc(%ebp)
  8021a7:	e8 d4 e5 ff ff       	call   800780 <strcpy>
	return 0;
}
  8021ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b1:	c9                   	leave  
  8021b2:	c3                   	ret    

008021b3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	57                   	push   %edi
  8021b7:	56                   	push   %esi
  8021b8:	53                   	push   %ebx
  8021b9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021bf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021c4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ca:	eb 2d                	jmp    8021f9 <devcons_write+0x46>
		m = n - tot;
  8021cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021cf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021d1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021d4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021d9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021dc:	83 ec 04             	sub    $0x4,%esp
  8021df:	53                   	push   %ebx
  8021e0:	03 45 0c             	add    0xc(%ebp),%eax
  8021e3:	50                   	push   %eax
  8021e4:	57                   	push   %edi
  8021e5:	e8 28 e7 ff ff       	call   800912 <memmove>
		sys_cputs(buf, m);
  8021ea:	83 c4 08             	add    $0x8,%esp
  8021ed:	53                   	push   %ebx
  8021ee:	57                   	push   %edi
  8021ef:	e8 d3 e8 ff ff       	call   800ac7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021f4:	01 de                	add    %ebx,%esi
  8021f6:	83 c4 10             	add    $0x10,%esp
  8021f9:	89 f0                	mov    %esi,%eax
  8021fb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021fe:	72 cc                	jb     8021cc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    

00802208 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	83 ec 08             	sub    $0x8,%esp
  80220e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802213:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802217:	74 2a                	je     802243 <devcons_read+0x3b>
  802219:	eb 05                	jmp    802220 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80221b:	e8 44 e9 ff ff       	call   800b64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802220:	e8 c0 e8 ff ff       	call   800ae5 <sys_cgetc>
  802225:	85 c0                	test   %eax,%eax
  802227:	74 f2                	je     80221b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802229:	85 c0                	test   %eax,%eax
  80222b:	78 16                	js     802243 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80222d:	83 f8 04             	cmp    $0x4,%eax
  802230:	74 0c                	je     80223e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802232:	8b 55 0c             	mov    0xc(%ebp),%edx
  802235:	88 02                	mov    %al,(%edx)
	return 1;
  802237:	b8 01 00 00 00       	mov    $0x1,%eax
  80223c:	eb 05                	jmp    802243 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80223e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802243:	c9                   	leave  
  802244:	c3                   	ret    

00802245 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80224b:	8b 45 08             	mov    0x8(%ebp),%eax
  80224e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802251:	6a 01                	push   $0x1
  802253:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802256:	50                   	push   %eax
  802257:	e8 6b e8 ff ff       	call   800ac7 <sys_cputs>
}
  80225c:	83 c4 10             	add    $0x10,%esp
  80225f:	c9                   	leave  
  802260:	c3                   	ret    

00802261 <getchar>:

int
getchar(void)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802267:	6a 01                	push   $0x1
  802269:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80226c:	50                   	push   %eax
  80226d:	6a 00                	push   $0x0
  80226f:	e8 25 f2 ff ff       	call   801499 <read>
	if (r < 0)
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	85 c0                	test   %eax,%eax
  802279:	78 0f                	js     80228a <getchar+0x29>
		return r;
	if (r < 1)
  80227b:	85 c0                	test   %eax,%eax
  80227d:	7e 06                	jle    802285 <getchar+0x24>
		return -E_EOF;
	return c;
  80227f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802283:	eb 05                	jmp    80228a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802285:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    

0080228c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802292:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802295:	50                   	push   %eax
  802296:	ff 75 08             	pushl  0x8(%ebp)
  802299:	e8 95 ef ff ff       	call   801233 <fd_lookup>
  80229e:	83 c4 10             	add    $0x10,%esp
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	78 11                	js     8022b6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ae:	39 10                	cmp    %edx,(%eax)
  8022b0:	0f 94 c0             	sete   %al
  8022b3:	0f b6 c0             	movzbl %al,%eax
}
  8022b6:	c9                   	leave  
  8022b7:	c3                   	ret    

008022b8 <opencons>:

int
opencons(void)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c1:	50                   	push   %eax
  8022c2:	e8 1d ef ff ff       	call   8011e4 <fd_alloc>
  8022c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8022ca:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022cc:	85 c0                	test   %eax,%eax
  8022ce:	78 3e                	js     80230e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d0:	83 ec 04             	sub    $0x4,%esp
  8022d3:	68 07 04 00 00       	push   $0x407
  8022d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8022db:	6a 00                	push   $0x0
  8022dd:	e8 a1 e8 ff ff       	call   800b83 <sys_page_alloc>
  8022e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8022e5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022e7:	85 c0                	test   %eax,%eax
  8022e9:	78 23                	js     80230e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022eb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802300:	83 ec 0c             	sub    $0xc,%esp
  802303:	50                   	push   %eax
  802304:	e8 b4 ee ff ff       	call   8011bd <fd2num>
  802309:	89 c2                	mov    %eax,%edx
  80230b:	83 c4 10             	add    $0x10,%esp
}
  80230e:	89 d0                	mov    %edx,%eax
  802310:	c9                   	leave  
  802311:	c3                   	ret    

00802312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	56                   	push   %esi
  802316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80231a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802320:	e8 20 e8 ff ff       	call   800b45 <sys_getenvid>
  802325:	83 ec 0c             	sub    $0xc,%esp
  802328:	ff 75 0c             	pushl  0xc(%ebp)
  80232b:	ff 75 08             	pushl  0x8(%ebp)
  80232e:	56                   	push   %esi
  80232f:	50                   	push   %eax
  802330:	68 f0 2c 80 00       	push   $0x802cf0
  802335:	e8 c1 de ff ff       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80233a:	83 c4 18             	add    $0x18,%esp
  80233d:	53                   	push   %ebx
  80233e:	ff 75 10             	pushl  0x10(%ebp)
  802341:	e8 64 de ff ff       	call   8001aa <vcprintf>
	cprintf("\n");
  802346:	c7 04 24 7a 2a 80 00 	movl   $0x802a7a,(%esp)
  80234d:	e8 a9 de ff ff       	call   8001fb <cprintf>
  802352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802355:	cc                   	int3   
  802356:	eb fd                	jmp    802355 <_panic+0x43>

00802358 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80235e:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802365:	75 2c                	jne    802393 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802367:	83 ec 04             	sub    $0x4,%esp
  80236a:	6a 07                	push   $0x7
  80236c:	68 00 f0 bf ee       	push   $0xeebff000
  802371:	6a 00                	push   $0x0
  802373:	e8 0b e8 ff ff       	call   800b83 <sys_page_alloc>
  802378:	83 c4 10             	add    $0x10,%esp
  80237b:	85 c0                	test   %eax,%eax
  80237d:	79 14                	jns    802393 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  80237f:	83 ec 04             	sub    $0x4,%esp
  802382:	68 13 2d 80 00       	push   $0x802d13
  802387:	6a 22                	push   $0x22
  802389:	68 2a 2d 80 00       	push   $0x802d2a
  80238e:	e8 7f ff ff ff       	call   802312 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  802393:	8b 45 08             	mov    0x8(%ebp),%eax
  802396:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80239b:	83 ec 08             	sub    $0x8,%esp
  80239e:	68 c7 23 80 00       	push   $0x8023c7
  8023a3:	6a 00                	push   $0x0
  8023a5:	e8 24 e9 ff ff       	call   800cce <sys_env_set_pgfault_upcall>
  8023aa:	83 c4 10             	add    $0x10,%esp
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	79 14                	jns    8023c5 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8023b1:	83 ec 04             	sub    $0x4,%esp
  8023b4:	68 38 2d 80 00       	push   $0x802d38
  8023b9:	6a 27                	push   $0x27
  8023bb:	68 2a 2d 80 00       	push   $0x802d2a
  8023c0:	e8 4d ff ff ff       	call   802312 <_panic>
    
}
  8023c5:	c9                   	leave  
  8023c6:	c3                   	ret    

008023c7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023c7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023c8:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023cd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023cf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8023d2:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8023d6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8023db:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8023df:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8023e1:	83 c4 08             	add    $0x8,%esp
	popal
  8023e4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8023e5:	83 c4 04             	add    $0x4,%esp
	popfl
  8023e8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023e9:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023ea:	c3                   	ret    

008023eb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023f1:	89 d0                	mov    %edx,%eax
  8023f3:	c1 e8 16             	shr    $0x16,%eax
  8023f6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023fd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802402:	f6 c1 01             	test   $0x1,%cl
  802405:	74 1d                	je     802424 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802407:	c1 ea 0c             	shr    $0xc,%edx
  80240a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802411:	f6 c2 01             	test   $0x1,%dl
  802414:	74 0e                	je     802424 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802416:	c1 ea 0c             	shr    $0xc,%edx
  802419:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802420:	ef 
  802421:	0f b7 c0             	movzwl %ax,%eax
}
  802424:	5d                   	pop    %ebp
  802425:	c3                   	ret    
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__udivdi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80243b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80243f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 f6                	test   %esi,%esi
  802449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80244d:	89 ca                	mov    %ecx,%edx
  80244f:	89 f8                	mov    %edi,%eax
  802451:	75 3d                	jne    802490 <__udivdi3+0x60>
  802453:	39 cf                	cmp    %ecx,%edi
  802455:	0f 87 c5 00 00 00    	ja     802520 <__udivdi3+0xf0>
  80245b:	85 ff                	test   %edi,%edi
  80245d:	89 fd                	mov    %edi,%ebp
  80245f:	75 0b                	jne    80246c <__udivdi3+0x3c>
  802461:	b8 01 00 00 00       	mov    $0x1,%eax
  802466:	31 d2                	xor    %edx,%edx
  802468:	f7 f7                	div    %edi
  80246a:	89 c5                	mov    %eax,%ebp
  80246c:	89 c8                	mov    %ecx,%eax
  80246e:	31 d2                	xor    %edx,%edx
  802470:	f7 f5                	div    %ebp
  802472:	89 c1                	mov    %eax,%ecx
  802474:	89 d8                	mov    %ebx,%eax
  802476:	89 cf                	mov    %ecx,%edi
  802478:	f7 f5                	div    %ebp
  80247a:	89 c3                	mov    %eax,%ebx
  80247c:	89 d8                	mov    %ebx,%eax
  80247e:	89 fa                	mov    %edi,%edx
  802480:	83 c4 1c             	add    $0x1c,%esp
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	90                   	nop
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	39 ce                	cmp    %ecx,%esi
  802492:	77 74                	ja     802508 <__udivdi3+0xd8>
  802494:	0f bd fe             	bsr    %esi,%edi
  802497:	83 f7 1f             	xor    $0x1f,%edi
  80249a:	0f 84 98 00 00 00    	je     802538 <__udivdi3+0x108>
  8024a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	89 c5                	mov    %eax,%ebp
  8024a9:	29 fb                	sub    %edi,%ebx
  8024ab:	d3 e6                	shl    %cl,%esi
  8024ad:	89 d9                	mov    %ebx,%ecx
  8024af:	d3 ed                	shr    %cl,%ebp
  8024b1:	89 f9                	mov    %edi,%ecx
  8024b3:	d3 e0                	shl    %cl,%eax
  8024b5:	09 ee                	or     %ebp,%esi
  8024b7:	89 d9                	mov    %ebx,%ecx
  8024b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024bd:	89 d5                	mov    %edx,%ebp
  8024bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024c3:	d3 ed                	shr    %cl,%ebp
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e2                	shl    %cl,%edx
  8024c9:	89 d9                	mov    %ebx,%ecx
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	09 c2                	or     %eax,%edx
  8024cf:	89 d0                	mov    %edx,%eax
  8024d1:	89 ea                	mov    %ebp,%edx
  8024d3:	f7 f6                	div    %esi
  8024d5:	89 d5                	mov    %edx,%ebp
  8024d7:	89 c3                	mov    %eax,%ebx
  8024d9:	f7 64 24 0c          	mull   0xc(%esp)
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	72 10                	jb     8024f1 <__udivdi3+0xc1>
  8024e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e6                	shl    %cl,%esi
  8024e9:	39 c6                	cmp    %eax,%esi
  8024eb:	73 07                	jae    8024f4 <__udivdi3+0xc4>
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	75 03                	jne    8024f4 <__udivdi3+0xc4>
  8024f1:	83 eb 01             	sub    $0x1,%ebx
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 d8                	mov    %ebx,%eax
  8024f8:	89 fa                	mov    %edi,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	31 ff                	xor    %edi,%edi
  80250a:	31 db                	xor    %ebx,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d8                	mov    %ebx,%eax
  802522:	f7 f7                	div    %edi
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 c3                	mov    %eax,%ebx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 fa                	mov    %edi,%edx
  80252c:	83 c4 1c             	add    $0x1c,%esp
  80252f:	5b                   	pop    %ebx
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    
  802534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802538:	39 ce                	cmp    %ecx,%esi
  80253a:	72 0c                	jb     802548 <__udivdi3+0x118>
  80253c:	31 db                	xor    %ebx,%ebx
  80253e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802542:	0f 87 34 ff ff ff    	ja     80247c <__udivdi3+0x4c>
  802548:	bb 01 00 00 00       	mov    $0x1,%ebx
  80254d:	e9 2a ff ff ff       	jmp    80247c <__udivdi3+0x4c>
  802552:	66 90                	xchg   %ax,%ax
  802554:	66 90                	xchg   %ax,%ax
  802556:	66 90                	xchg   %ax,%ax
  802558:	66 90                	xchg   %ax,%ax
  80255a:	66 90                	xchg   %ax,%ax
  80255c:	66 90                	xchg   %ax,%ax
  80255e:	66 90                	xchg   %ax,%ax

00802560 <__umoddi3>:
  802560:	55                   	push   %ebp
  802561:	57                   	push   %edi
  802562:	56                   	push   %esi
  802563:	53                   	push   %ebx
  802564:	83 ec 1c             	sub    $0x1c,%esp
  802567:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80256b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80256f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802573:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802577:	85 d2                	test   %edx,%edx
  802579:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80257d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802581:	89 f3                	mov    %esi,%ebx
  802583:	89 3c 24             	mov    %edi,(%esp)
  802586:	89 74 24 04          	mov    %esi,0x4(%esp)
  80258a:	75 1c                	jne    8025a8 <__umoddi3+0x48>
  80258c:	39 f7                	cmp    %esi,%edi
  80258e:	76 50                	jbe    8025e0 <__umoddi3+0x80>
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	f7 f7                	div    %edi
  802596:	89 d0                	mov    %edx,%eax
  802598:	31 d2                	xor    %edx,%edx
  80259a:	83 c4 1c             	add    $0x1c,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	39 f2                	cmp    %esi,%edx
  8025aa:	89 d0                	mov    %edx,%eax
  8025ac:	77 52                	ja     802600 <__umoddi3+0xa0>
  8025ae:	0f bd ea             	bsr    %edx,%ebp
  8025b1:	83 f5 1f             	xor    $0x1f,%ebp
  8025b4:	75 5a                	jne    802610 <__umoddi3+0xb0>
  8025b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ba:	0f 82 e0 00 00 00    	jb     8026a0 <__umoddi3+0x140>
  8025c0:	39 0c 24             	cmp    %ecx,(%esp)
  8025c3:	0f 86 d7 00 00 00    	jbe    8026a0 <__umoddi3+0x140>
  8025c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025d1:	83 c4 1c             	add    $0x1c,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	85 ff                	test   %edi,%edi
  8025e2:	89 fd                	mov    %edi,%ebp
  8025e4:	75 0b                	jne    8025f1 <__umoddi3+0x91>
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	f7 f7                	div    %edi
  8025ef:	89 c5                	mov    %eax,%ebp
  8025f1:	89 f0                	mov    %esi,%eax
  8025f3:	31 d2                	xor    %edx,%edx
  8025f5:	f7 f5                	div    %ebp
  8025f7:	89 c8                	mov    %ecx,%eax
  8025f9:	f7 f5                	div    %ebp
  8025fb:	89 d0                	mov    %edx,%eax
  8025fd:	eb 99                	jmp    802598 <__umoddi3+0x38>
  8025ff:	90                   	nop
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	83 c4 1c             	add    $0x1c,%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5f                   	pop    %edi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    
  80260c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802610:	8b 34 24             	mov    (%esp),%esi
  802613:	bf 20 00 00 00       	mov    $0x20,%edi
  802618:	89 e9                	mov    %ebp,%ecx
  80261a:	29 ef                	sub    %ebp,%edi
  80261c:	d3 e0                	shl    %cl,%eax
  80261e:	89 f9                	mov    %edi,%ecx
  802620:	89 f2                	mov    %esi,%edx
  802622:	d3 ea                	shr    %cl,%edx
  802624:	89 e9                	mov    %ebp,%ecx
  802626:	09 c2                	or     %eax,%edx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 14 24             	mov    %edx,(%esp)
  80262d:	89 f2                	mov    %esi,%edx
  80262f:	d3 e2                	shl    %cl,%edx
  802631:	89 f9                	mov    %edi,%ecx
  802633:	89 54 24 04          	mov    %edx,0x4(%esp)
  802637:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80263b:	d3 e8                	shr    %cl,%eax
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	89 c6                	mov    %eax,%esi
  802641:	d3 e3                	shl    %cl,%ebx
  802643:	89 f9                	mov    %edi,%ecx
  802645:	89 d0                	mov    %edx,%eax
  802647:	d3 e8                	shr    %cl,%eax
  802649:	89 e9                	mov    %ebp,%ecx
  80264b:	09 d8                	or     %ebx,%eax
  80264d:	89 d3                	mov    %edx,%ebx
  80264f:	89 f2                	mov    %esi,%edx
  802651:	f7 34 24             	divl   (%esp)
  802654:	89 d6                	mov    %edx,%esi
  802656:	d3 e3                	shl    %cl,%ebx
  802658:	f7 64 24 04          	mull   0x4(%esp)
  80265c:	39 d6                	cmp    %edx,%esi
  80265e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802662:	89 d1                	mov    %edx,%ecx
  802664:	89 c3                	mov    %eax,%ebx
  802666:	72 08                	jb     802670 <__umoddi3+0x110>
  802668:	75 11                	jne    80267b <__umoddi3+0x11b>
  80266a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80266e:	73 0b                	jae    80267b <__umoddi3+0x11b>
  802670:	2b 44 24 04          	sub    0x4(%esp),%eax
  802674:	1b 14 24             	sbb    (%esp),%edx
  802677:	89 d1                	mov    %edx,%ecx
  802679:	89 c3                	mov    %eax,%ebx
  80267b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80267f:	29 da                	sub    %ebx,%edx
  802681:	19 ce                	sbb    %ecx,%esi
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 f0                	mov    %esi,%eax
  802687:	d3 e0                	shl    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	d3 ea                	shr    %cl,%edx
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	d3 ee                	shr    %cl,%esi
  802691:	09 d0                	or     %edx,%eax
  802693:	89 f2                	mov    %esi,%edx
  802695:	83 c4 1c             	add    $0x1c,%esp
  802698:	5b                   	pop    %ebx
  802699:	5e                   	pop    %esi
  80269a:	5f                   	pop    %edi
  80269b:	5d                   	pop    %ebp
  80269c:	c3                   	ret    
  80269d:	8d 76 00             	lea    0x0(%esi),%esi
  8026a0:	29 f9                	sub    %edi,%ecx
  8026a2:	19 d6                	sbb    %edx,%esi
  8026a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ac:	e9 18 ff ff ff       	jmp    8025c9 <__umoddi3+0x69>
