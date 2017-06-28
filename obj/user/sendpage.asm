
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 0b 0f 00 00       	call   800f49 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 02 11 00 00       	call   80115e <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 60 27 80 00       	push   $0x802760
  80006c:	e8 25 02 00 00       	call   800296 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 63 07 00 00       	call   8007e2 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 58 08 00 00       	call   8008eb <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 74 27 80 00       	push   $0x802774
  8000a2:	e8 ef 01 00 00       	call   800296 <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 2a 07 00 00       	call   8007e2 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 46 09 00 00       	call   800a15 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 eb 10 00 00       	call   8011cb <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 1e 0b 00 00       	call   800c1e <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 d4 06 00 00       	call   8007e2 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 f0 08 00 00       	call   800a15 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 95 10 00 00       	call   8011cb <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 15 10 00 00       	call   80115e <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 60 27 80 00       	push   $0x802760
  800159:	e8 38 01 00 00       	call   800296 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 76 06 00 00       	call   8007e2 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 6b 07 00 00       	call   8008eb <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 94 27 80 00       	push   $0x802794
  80018f:	e8 02 01 00 00       	call   800296 <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001a4:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8001ab:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ae:	e8 2d 0a 00 00       	call   800be0 <sys_getenvid>
  8001b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c0:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c5:	85 db                	test   %ebx,%ebx
  8001c7:	7e 07                	jle    8001d0 <libmain+0x37>
		binaryname = argv[0];
  8001c9:	8b 06                	mov    (%esi),%eax
  8001cb:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	e8 59 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001da:	e8 0a 00 00 00       	call   8001e9 <exit>
}
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001ef:	e8 2f 12 00 00       	call   801423 <close_all>
	sys_env_destroy(0);
  8001f4:	83 ec 0c             	sub    $0xc,%esp
  8001f7:	6a 00                	push   $0x0
  8001f9:	e8 a1 09 00 00       	call   800b9f <sys_env_destroy>
}
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	53                   	push   %ebx
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80020d:	8b 13                	mov    (%ebx),%edx
  80020f:	8d 42 01             	lea    0x1(%edx),%eax
  800212:	89 03                	mov    %eax,(%ebx)
  800214:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800217:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80021b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800220:	75 1a                	jne    80023c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	68 ff 00 00 00       	push   $0xff
  80022a:	8d 43 08             	lea    0x8(%ebx),%eax
  80022d:	50                   	push   %eax
  80022e:	e8 2f 09 00 00       	call   800b62 <sys_cputs>
		b->idx = 0;
  800233:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800239:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80023c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80024e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800255:	00 00 00 
	b.cnt = 0;
  800258:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800262:	ff 75 0c             	pushl  0xc(%ebp)
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026e:	50                   	push   %eax
  80026f:	68 03 02 80 00       	push   $0x800203
  800274:	e8 54 01 00 00       	call   8003cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800282:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800288:	50                   	push   %eax
  800289:	e8 d4 08 00 00       	call   800b62 <sys_cputs>

	return b.cnt;
}
  80028e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029f:	50                   	push   %eax
  8002a0:	ff 75 08             	pushl  0x8(%ebp)
  8002a3:	e8 9d ff ff ff       	call   800245 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 1c             	sub    $0x1c,%esp
  8002b3:	89 c7                	mov    %eax,%edi
  8002b5:	89 d6                	mov    %edx,%esi
  8002b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ce:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002d1:	39 d3                	cmp    %edx,%ebx
  8002d3:	72 05                	jb     8002da <printnum+0x30>
  8002d5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d8:	77 45                	ja     80031f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	ff 75 18             	pushl  0x18(%ebp)
  8002e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e6:	53                   	push   %ebx
  8002e7:	ff 75 10             	pushl  0x10(%ebp)
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f9:	e8 d2 21 00 00       	call   8024d0 <__udivdi3>
  8002fe:	83 c4 18             	add    $0x18,%esp
  800301:	52                   	push   %edx
  800302:	50                   	push   %eax
  800303:	89 f2                	mov    %esi,%edx
  800305:	89 f8                	mov    %edi,%eax
  800307:	e8 9e ff ff ff       	call   8002aa <printnum>
  80030c:	83 c4 20             	add    $0x20,%esp
  80030f:	eb 18                	jmp    800329 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	56                   	push   %esi
  800315:	ff 75 18             	pushl  0x18(%ebp)
  800318:	ff d7                	call   *%edi
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	eb 03                	jmp    800322 <printnum+0x78>
  80031f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800322:	83 eb 01             	sub    $0x1,%ebx
  800325:	85 db                	test   %ebx,%ebx
  800327:	7f e8                	jg     800311 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	56                   	push   %esi
  80032d:	83 ec 04             	sub    $0x4,%esp
  800330:	ff 75 e4             	pushl  -0x1c(%ebp)
  800333:	ff 75 e0             	pushl  -0x20(%ebp)
  800336:	ff 75 dc             	pushl  -0x24(%ebp)
  800339:	ff 75 d8             	pushl  -0x28(%ebp)
  80033c:	e8 bf 22 00 00       	call   802600 <__umoddi3>
  800341:	83 c4 14             	add    $0x14,%esp
  800344:	0f be 80 0c 28 80 00 	movsbl 0x80280c(%eax),%eax
  80034b:	50                   	push   %eax
  80034c:	ff d7                	call   *%edi
}
  80034e:	83 c4 10             	add    $0x10,%esp
  800351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800354:	5b                   	pop    %ebx
  800355:	5e                   	pop    %esi
  800356:	5f                   	pop    %edi
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035c:	83 fa 01             	cmp    $0x1,%edx
  80035f:	7e 0e                	jle    80036f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800361:	8b 10                	mov    (%eax),%edx
  800363:	8d 4a 08             	lea    0x8(%edx),%ecx
  800366:	89 08                	mov    %ecx,(%eax)
  800368:	8b 02                	mov    (%edx),%eax
  80036a:	8b 52 04             	mov    0x4(%edx),%edx
  80036d:	eb 22                	jmp    800391 <getuint+0x38>
	else if (lflag)
  80036f:	85 d2                	test   %edx,%edx
  800371:	74 10                	je     800383 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800373:	8b 10                	mov    (%eax),%edx
  800375:	8d 4a 04             	lea    0x4(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 02                	mov    (%edx),%eax
  80037c:	ba 00 00 00 00       	mov    $0x0,%edx
  800381:	eb 0e                	jmp    800391 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800383:	8b 10                	mov    (%eax),%edx
  800385:	8d 4a 04             	lea    0x4(%edx),%ecx
  800388:	89 08                	mov    %ecx,(%eax)
  80038a:	8b 02                	mov    (%edx),%eax
  80038c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800399:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a2:	73 0a                	jae    8003ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ac:	88 02                	mov    %al,(%edx)
}
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b9:	50                   	push   %eax
  8003ba:	ff 75 10             	pushl  0x10(%ebp)
  8003bd:	ff 75 0c             	pushl  0xc(%ebp)
  8003c0:	ff 75 08             	pushl  0x8(%ebp)
  8003c3:	e8 05 00 00 00       	call   8003cd <vprintfmt>
	va_end(ap);
}
  8003c8:	83 c4 10             	add    $0x10,%esp
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 2c             	sub    $0x2c,%esp
  8003d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003dc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003df:	eb 12                	jmp    8003f3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	0f 84 89 03 00 00    	je     800772 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	53                   	push   %ebx
  8003ed:	50                   	push   %eax
  8003ee:	ff d6                	call   *%esi
  8003f0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f3:	83 c7 01             	add    $0x1,%edi
  8003f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003fa:	83 f8 25             	cmp    $0x25,%eax
  8003fd:	75 e2                	jne    8003e1 <vprintfmt+0x14>
  8003ff:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800403:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80040a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800411:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800418:	ba 00 00 00 00       	mov    $0x0,%edx
  80041d:	eb 07                	jmp    800426 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800422:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8d 47 01             	lea    0x1(%edi),%eax
  800429:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042c:	0f b6 07             	movzbl (%edi),%eax
  80042f:	0f b6 c8             	movzbl %al,%ecx
  800432:	83 e8 23             	sub    $0x23,%eax
  800435:	3c 55                	cmp    $0x55,%al
  800437:	0f 87 1a 03 00 00    	ja     800757 <vprintfmt+0x38a>
  80043d:	0f b6 c0             	movzbl %al,%eax
  800440:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80044e:	eb d6                	jmp    800426 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80045e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800462:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800465:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800468:	83 fa 09             	cmp    $0x9,%edx
  80046b:	77 39                	ja     8004a6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800470:	eb e9                	jmp    80045b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 48 04             	lea    0x4(%eax),%ecx
  800478:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800483:	eb 27                	jmp    8004ac <vprintfmt+0xdf>
  800485:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800488:	85 c0                	test   %eax,%eax
  80048a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80048f:	0f 49 c8             	cmovns %eax,%ecx
  800492:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800498:	eb 8c                	jmp    800426 <vprintfmt+0x59>
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a4:	eb 80                	jmp    800426 <vprintfmt+0x59>
  8004a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	0f 89 70 ff ff ff    	jns    800426 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004c3:	e9 5e ff ff ff       	jmp    800426 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ce:	e9 53 ff ff ff       	jmp    800426 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	ff 30                	pushl  (%eax)
  8004e2:	ff d6                	call   *%esi
			break;
  8004e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ea:	e9 04 ff ff ff       	jmp    8003f3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 50 04             	lea    0x4(%eax),%edx
  8004f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f8:	8b 00                	mov    (%eax),%eax
  8004fa:	99                   	cltd   
  8004fb:	31 d0                	xor    %edx,%eax
  8004fd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ff:	83 f8 0f             	cmp    $0xf,%eax
  800502:	7f 0b                	jg     80050f <vprintfmt+0x142>
  800504:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  80050b:	85 d2                	test   %edx,%edx
  80050d:	75 18                	jne    800527 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80050f:	50                   	push   %eax
  800510:	68 24 28 80 00       	push   $0x802824
  800515:	53                   	push   %ebx
  800516:	56                   	push   %esi
  800517:	e8 94 fe ff ff       	call   8003b0 <printfmt>
  80051c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800522:	e9 cc fe ff ff       	jmp    8003f3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800527:	52                   	push   %edx
  800528:	68 51 2d 80 00       	push   $0x802d51
  80052d:	53                   	push   %ebx
  80052e:	56                   	push   %esi
  80052f:	e8 7c fe ff ff       	call   8003b0 <printfmt>
  800534:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053a:	e9 b4 fe ff ff       	jmp    8003f3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80054a:	85 ff                	test   %edi,%edi
  80054c:	b8 1d 28 80 00       	mov    $0x80281d,%eax
  800551:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800554:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800558:	0f 8e 94 00 00 00    	jle    8005f2 <vprintfmt+0x225>
  80055e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800562:	0f 84 98 00 00 00    	je     800600 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	ff 75 d0             	pushl  -0x30(%ebp)
  80056e:	57                   	push   %edi
  80056f:	e8 86 02 00 00       	call   8007fa <strnlen>
  800574:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800577:	29 c1                	sub    %eax,%ecx
  800579:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80057c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80057f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800586:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800589:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	eb 0f                	jmp    80059c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	53                   	push   %ebx
  800591:	ff 75 e0             	pushl  -0x20(%ebp)
  800594:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800596:	83 ef 01             	sub    $0x1,%edi
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	85 ff                	test   %edi,%edi
  80059e:	7f ed                	jg     80058d <vprintfmt+0x1c0>
  8005a0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005a3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005a6:	85 c9                	test   %ecx,%ecx
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	0f 49 c1             	cmovns %ecx,%eax
  8005b0:	29 c1                	sub    %eax,%ecx
  8005b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005bb:	89 cb                	mov    %ecx,%ebx
  8005bd:	eb 4d                	jmp    80060c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c3:	74 1b                	je     8005e0 <vprintfmt+0x213>
  8005c5:	0f be c0             	movsbl %al,%eax
  8005c8:	83 e8 20             	sub    $0x20,%eax
  8005cb:	83 f8 5e             	cmp    $0x5e,%eax
  8005ce:	76 10                	jbe    8005e0 <vprintfmt+0x213>
					putch('?', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	ff 75 0c             	pushl  0xc(%ebp)
  8005d6:	6a 3f                	push   $0x3f
  8005d8:	ff 55 08             	call   *0x8(%ebp)
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	eb 0d                	jmp    8005ed <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	ff 75 0c             	pushl  0xc(%ebp)
  8005e6:	52                   	push   %edx
  8005e7:	ff 55 08             	call   *0x8(%ebp)
  8005ea:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ed:	83 eb 01             	sub    $0x1,%ebx
  8005f0:	eb 1a                	jmp    80060c <vprintfmt+0x23f>
  8005f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005fb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005fe:	eb 0c                	jmp    80060c <vprintfmt+0x23f>
  800600:	89 75 08             	mov    %esi,0x8(%ebp)
  800603:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800606:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800609:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80060c:	83 c7 01             	add    $0x1,%edi
  80060f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800613:	0f be d0             	movsbl %al,%edx
  800616:	85 d2                	test   %edx,%edx
  800618:	74 23                	je     80063d <vprintfmt+0x270>
  80061a:	85 f6                	test   %esi,%esi
  80061c:	78 a1                	js     8005bf <vprintfmt+0x1f2>
  80061e:	83 ee 01             	sub    $0x1,%esi
  800621:	79 9c                	jns    8005bf <vprintfmt+0x1f2>
  800623:	89 df                	mov    %ebx,%edi
  800625:	8b 75 08             	mov    0x8(%ebp),%esi
  800628:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80062b:	eb 18                	jmp    800645 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 20                	push   $0x20
  800633:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800635:	83 ef 01             	sub    $0x1,%edi
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	eb 08                	jmp    800645 <vprintfmt+0x278>
  80063d:	89 df                	mov    %ebx,%edi
  80063f:	8b 75 08             	mov    0x8(%ebp),%esi
  800642:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800645:	85 ff                	test   %edi,%edi
  800647:	7f e4                	jg     80062d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064c:	e9 a2 fd ff ff       	jmp    8003f3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800651:	83 fa 01             	cmp    $0x1,%edx
  800654:	7e 16                	jle    80066c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 08             	lea    0x8(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 50 04             	mov    0x4(%eax),%edx
  800662:	8b 00                	mov    (%eax),%eax
  800664:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800667:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066a:	eb 32                	jmp    80069e <vprintfmt+0x2d1>
	else if (lflag)
  80066c:	85 d2                	test   %edx,%edx
  80066e:	74 18                	je     800688 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 04             	lea    0x4(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067e:	89 c1                	mov    %eax,%ecx
  800680:	c1 f9 1f             	sar    $0x1f,%ecx
  800683:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800686:	eb 16                	jmp    80069e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800696:	89 c1                	mov    %eax,%ecx
  800698:	c1 f9 1f             	sar    $0x1f,%ecx
  80069b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ad:	79 74                	jns    800723 <vprintfmt+0x356>
				putch('-', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 2d                	push   $0x2d
  8006b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006bd:	f7 d8                	neg    %eax
  8006bf:	83 d2 00             	adc    $0x0,%edx
  8006c2:	f7 da                	neg    %edx
  8006c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006cc:	eb 55                	jmp    800723 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d1:	e8 83 fc ff ff       	call   800359 <getuint>
			base = 10;
  8006d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006db:	eb 46                	jmp    800723 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e0:	e8 74 fc ff ff       	call   800359 <getuint>
		        base = 8;
  8006e5:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006ea:	eb 37                	jmp    800723 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	53                   	push   %ebx
  8006f0:	6a 30                	push   $0x30
  8006f2:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f4:	83 c4 08             	add    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	6a 78                	push   $0x78
  8006fa:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800705:	8b 00                	mov    (%eax),%eax
  800707:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80070c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80070f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800714:	eb 0d                	jmp    800723 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
  800719:	e8 3b fc ff ff       	call   800359 <getuint>
			base = 16;
  80071e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800723:	83 ec 0c             	sub    $0xc,%esp
  800726:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80072a:	57                   	push   %edi
  80072b:	ff 75 e0             	pushl  -0x20(%ebp)
  80072e:	51                   	push   %ecx
  80072f:	52                   	push   %edx
  800730:	50                   	push   %eax
  800731:	89 da                	mov    %ebx,%edx
  800733:	89 f0                	mov    %esi,%eax
  800735:	e8 70 fb ff ff       	call   8002aa <printnum>
			break;
  80073a:	83 c4 20             	add    $0x20,%esp
  80073d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800740:	e9 ae fc ff ff       	jmp    8003f3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	53                   	push   %ebx
  800749:	51                   	push   %ecx
  80074a:	ff d6                	call   *%esi
			break;
  80074c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800752:	e9 9c fc ff ff       	jmp    8003f3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	53                   	push   %ebx
  80075b:	6a 25                	push   $0x25
  80075d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 03                	jmp    800767 <vprintfmt+0x39a>
  800764:	83 ef 01             	sub    $0x1,%edi
  800767:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80076b:	75 f7                	jne    800764 <vprintfmt+0x397>
  80076d:	e9 81 fc ff ff       	jmp    8003f3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	5f                   	pop    %edi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 18             	sub    $0x18,%esp
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800786:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800789:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800790:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800797:	85 c0                	test   %eax,%eax
  800799:	74 26                	je     8007c1 <vsnprintf+0x47>
  80079b:	85 d2                	test   %edx,%edx
  80079d:	7e 22                	jle    8007c1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079f:	ff 75 14             	pushl  0x14(%ebp)
  8007a2:	ff 75 10             	pushl  0x10(%ebp)
  8007a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a8:	50                   	push   %eax
  8007a9:	68 93 03 80 00       	push   $0x800393
  8007ae:	e8 1a fc ff ff       	call   8003cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	eb 05                	jmp    8007c6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d1:	50                   	push   %eax
  8007d2:	ff 75 10             	pushl  0x10(%ebp)
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	ff 75 08             	pushl  0x8(%ebp)
  8007db:	e8 9a ff ff ff       	call   80077a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ed:	eb 03                	jmp    8007f2 <strlen+0x10>
		n++;
  8007ef:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f6:	75 f7                	jne    8007ef <strlen+0xd>
		n++;
	return n;
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800800:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	ba 00 00 00 00       	mov    $0x0,%edx
  800808:	eb 03                	jmp    80080d <strnlen+0x13>
		n++;
  80080a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080d:	39 c2                	cmp    %eax,%edx
  80080f:	74 08                	je     800819 <strnlen+0x1f>
  800811:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800815:	75 f3                	jne    80080a <strnlen+0x10>
  800817:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	89 c2                	mov    %eax,%edx
  800827:	83 c2 01             	add    $0x1,%edx
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800831:	88 5a ff             	mov    %bl,-0x1(%edx)
  800834:	84 db                	test   %bl,%bl
  800836:	75 ef                	jne    800827 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800838:	5b                   	pop    %ebx
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800842:	53                   	push   %ebx
  800843:	e8 9a ff ff ff       	call   8007e2 <strlen>
  800848:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80084b:	ff 75 0c             	pushl  0xc(%ebp)
  80084e:	01 d8                	add    %ebx,%eax
  800850:	50                   	push   %eax
  800851:	e8 c5 ff ff ff       	call   80081b <strcpy>
	return dst;
}
  800856:	89 d8                	mov    %ebx,%eax
  800858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	56                   	push   %esi
  800861:	53                   	push   %ebx
  800862:	8b 75 08             	mov    0x8(%ebp),%esi
  800865:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800868:	89 f3                	mov    %esi,%ebx
  80086a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	89 f2                	mov    %esi,%edx
  80086f:	eb 0f                	jmp    800880 <strncpy+0x23>
		*dst++ = *src;
  800871:	83 c2 01             	add    $0x1,%edx
  800874:	0f b6 01             	movzbl (%ecx),%eax
  800877:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087a:	80 39 01             	cmpb   $0x1,(%ecx)
  80087d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800880:	39 da                	cmp    %ebx,%edx
  800882:	75 ed                	jne    800871 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800884:	89 f0                	mov    %esi,%eax
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	8b 75 08             	mov    0x8(%ebp),%esi
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800895:	8b 55 10             	mov    0x10(%ebp),%edx
  800898:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089a:	85 d2                	test   %edx,%edx
  80089c:	74 21                	je     8008bf <strlcpy+0x35>
  80089e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a2:	89 f2                	mov    %esi,%edx
  8008a4:	eb 09                	jmp    8008af <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a6:	83 c2 01             	add    $0x1,%edx
  8008a9:	83 c1 01             	add    $0x1,%ecx
  8008ac:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008af:	39 c2                	cmp    %eax,%edx
  8008b1:	74 09                	je     8008bc <strlcpy+0x32>
  8008b3:	0f b6 19             	movzbl (%ecx),%ebx
  8008b6:	84 db                	test   %bl,%bl
  8008b8:	75 ec                	jne    8008a6 <strlcpy+0x1c>
  8008ba:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008bc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008bf:	29 f0                	sub    %esi,%eax
}
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ce:	eb 06                	jmp    8008d6 <strcmp+0x11>
		p++, q++;
  8008d0:	83 c1 01             	add    $0x1,%ecx
  8008d3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d6:	0f b6 01             	movzbl (%ecx),%eax
  8008d9:	84 c0                	test   %al,%al
  8008db:	74 04                	je     8008e1 <strcmp+0x1c>
  8008dd:	3a 02                	cmp    (%edx),%al
  8008df:	74 ef                	je     8008d0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 c0             	movzbl %al,%eax
  8008e4:	0f b6 12             	movzbl (%edx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f5:	89 c3                	mov    %eax,%ebx
  8008f7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fa:	eb 06                	jmp    800902 <strncmp+0x17>
		n--, p++, q++;
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 15                	je     80091b <strncmp+0x30>
  800906:	0f b6 08             	movzbl (%eax),%ecx
  800909:	84 c9                	test   %cl,%cl
  80090b:	74 04                	je     800911 <strncmp+0x26>
  80090d:	3a 0a                	cmp    (%edx),%cl
  80090f:	74 eb                	je     8008fc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800911:	0f b6 00             	movzbl (%eax),%eax
  800914:	0f b6 12             	movzbl (%edx),%edx
  800917:	29 d0                	sub    %edx,%eax
  800919:	eb 05                	jmp    800920 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800920:	5b                   	pop    %ebx
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092d:	eb 07                	jmp    800936 <strchr+0x13>
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	74 0f                	je     800942 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	0f b6 10             	movzbl (%eax),%edx
  800939:	84 d2                	test   %dl,%dl
  80093b:	75 f2                	jne    80092f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094e:	eb 03                	jmp    800953 <strfind+0xf>
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800956:	38 ca                	cmp    %cl,%dl
  800958:	74 04                	je     80095e <strfind+0x1a>
  80095a:	84 d2                	test   %dl,%dl
  80095c:	75 f2                	jne    800950 <strfind+0xc>
			break;
	return (char *) s;
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 7d 08             	mov    0x8(%ebp),%edi
  800969:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096c:	85 c9                	test   %ecx,%ecx
  80096e:	74 36                	je     8009a6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800970:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800976:	75 28                	jne    8009a0 <memset+0x40>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 23                	jne    8009a0 <memset+0x40>
		c &= 0xFF;
  80097d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800981:	89 d3                	mov    %edx,%ebx
  800983:	c1 e3 08             	shl    $0x8,%ebx
  800986:	89 d6                	mov    %edx,%esi
  800988:	c1 e6 18             	shl    $0x18,%esi
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	c1 e0 10             	shl    $0x10,%eax
  800990:	09 f0                	or     %esi,%eax
  800992:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800994:	89 d8                	mov    %ebx,%eax
  800996:	09 d0                	or     %edx,%eax
  800998:	c1 e9 02             	shr    $0x2,%ecx
  80099b:	fc                   	cld    
  80099c:	f3 ab                	rep stos %eax,%es:(%edi)
  80099e:	eb 06                	jmp    8009a6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a6:	89 f8                	mov    %edi,%eax
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	57                   	push   %edi
  8009b1:	56                   	push   %esi
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bb:	39 c6                	cmp    %eax,%esi
  8009bd:	73 35                	jae    8009f4 <memmove+0x47>
  8009bf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c2:	39 d0                	cmp    %edx,%eax
  8009c4:	73 2e                	jae    8009f4 <memmove+0x47>
		s += n;
		d += n;
  8009c6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c9:	89 d6                	mov    %edx,%esi
  8009cb:	09 fe                	or     %edi,%esi
  8009cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d3:	75 13                	jne    8009e8 <memmove+0x3b>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 0e                	jne    8009e8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009da:	83 ef 04             	sub    $0x4,%edi
  8009dd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e0:	c1 e9 02             	shr    $0x2,%ecx
  8009e3:	fd                   	std    
  8009e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e6:	eb 09                	jmp    8009f1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e8:	83 ef 01             	sub    $0x1,%edi
  8009eb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ee:	fd                   	std    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f1:	fc                   	cld    
  8009f2:	eb 1d                	jmp    800a11 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f4:	89 f2                	mov    %esi,%edx
  8009f6:	09 c2                	or     %eax,%edx
  8009f8:	f6 c2 03             	test   $0x3,%dl
  8009fb:	75 0f                	jne    800a0c <memmove+0x5f>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0a                	jne    800a0c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a02:	c1 e9 02             	shr    $0x2,%ecx
  800a05:	89 c7                	mov    %eax,%edi
  800a07:	fc                   	cld    
  800a08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0a:	eb 05                	jmp    800a11 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0c:	89 c7                	mov    %eax,%edi
  800a0e:	fc                   	cld    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a18:	ff 75 10             	pushl  0x10(%ebp)
  800a1b:	ff 75 0c             	pushl  0xc(%ebp)
  800a1e:	ff 75 08             	pushl  0x8(%ebp)
  800a21:	e8 87 ff ff ff       	call   8009ad <memmove>
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a33:	89 c6                	mov    %eax,%esi
  800a35:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a38:	eb 1a                	jmp    800a54 <memcmp+0x2c>
		if (*s1 != *s2)
  800a3a:	0f b6 08             	movzbl (%eax),%ecx
  800a3d:	0f b6 1a             	movzbl (%edx),%ebx
  800a40:	38 d9                	cmp    %bl,%cl
  800a42:	74 0a                	je     800a4e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a44:	0f b6 c1             	movzbl %cl,%eax
  800a47:	0f b6 db             	movzbl %bl,%ebx
  800a4a:	29 d8                	sub    %ebx,%eax
  800a4c:	eb 0f                	jmp    800a5d <memcmp+0x35>
		s1++, s2++;
  800a4e:	83 c0 01             	add    $0x1,%eax
  800a51:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a54:	39 f0                	cmp    %esi,%eax
  800a56:	75 e2                	jne    800a3a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	53                   	push   %ebx
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a68:	89 c1                	mov    %eax,%ecx
  800a6a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a71:	eb 0a                	jmp    800a7d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a73:	0f b6 10             	movzbl (%eax),%edx
  800a76:	39 da                	cmp    %ebx,%edx
  800a78:	74 07                	je     800a81 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	39 c8                	cmp    %ecx,%eax
  800a7f:	72 f2                	jb     800a73 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a81:	5b                   	pop    %ebx
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a90:	eb 03                	jmp    800a95 <strtol+0x11>
		s++;
  800a92:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a95:	0f b6 01             	movzbl (%ecx),%eax
  800a98:	3c 20                	cmp    $0x20,%al
  800a9a:	74 f6                	je     800a92 <strtol+0xe>
  800a9c:	3c 09                	cmp    $0x9,%al
  800a9e:	74 f2                	je     800a92 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa0:	3c 2b                	cmp    $0x2b,%al
  800aa2:	75 0a                	jne    800aae <strtol+0x2a>
		s++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aac:	eb 11                	jmp    800abf <strtol+0x3b>
  800aae:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab3:	3c 2d                	cmp    $0x2d,%al
  800ab5:	75 08                	jne    800abf <strtol+0x3b>
		s++, neg = 1;
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac5:	75 15                	jne    800adc <strtol+0x58>
  800ac7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aca:	75 10                	jne    800adc <strtol+0x58>
  800acc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad0:	75 7c                	jne    800b4e <strtol+0xca>
		s += 2, base = 16;
  800ad2:	83 c1 02             	add    $0x2,%ecx
  800ad5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ada:	eb 16                	jmp    800af2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800adc:	85 db                	test   %ebx,%ebx
  800ade:	75 12                	jne    800af2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae8:	75 08                	jne    800af2 <strtol+0x6e>
		s++, base = 8;
  800aea:	83 c1 01             	add    $0x1,%ecx
  800aed:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
  800af7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afa:	0f b6 11             	movzbl (%ecx),%edx
  800afd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b00:	89 f3                	mov    %esi,%ebx
  800b02:	80 fb 09             	cmp    $0x9,%bl
  800b05:	77 08                	ja     800b0f <strtol+0x8b>
			dig = *s - '0';
  800b07:	0f be d2             	movsbl %dl,%edx
  800b0a:	83 ea 30             	sub    $0x30,%edx
  800b0d:	eb 22                	jmp    800b31 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b12:	89 f3                	mov    %esi,%ebx
  800b14:	80 fb 19             	cmp    $0x19,%bl
  800b17:	77 08                	ja     800b21 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b19:	0f be d2             	movsbl %dl,%edx
  800b1c:	83 ea 57             	sub    $0x57,%edx
  800b1f:	eb 10                	jmp    800b31 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b21:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b24:	89 f3                	mov    %esi,%ebx
  800b26:	80 fb 19             	cmp    $0x19,%bl
  800b29:	77 16                	ja     800b41 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b2b:	0f be d2             	movsbl %dl,%edx
  800b2e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b34:	7d 0b                	jge    800b41 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b3f:	eb b9                	jmp    800afa <strtol+0x76>

	if (endptr)
  800b41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b45:	74 0d                	je     800b54 <strtol+0xd0>
		*endptr = (char *) s;
  800b47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4a:	89 0e                	mov    %ecx,(%esi)
  800b4c:	eb 06                	jmp    800b54 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4e:	85 db                	test   %ebx,%ebx
  800b50:	74 98                	je     800aea <strtol+0x66>
  800b52:	eb 9e                	jmp    800af2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b54:	89 c2                	mov    %eax,%edx
  800b56:	f7 da                	neg    %edx
  800b58:	85 ff                	test   %edi,%edi
  800b5a:	0f 45 c2             	cmovne %edx,%eax
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	89 c3                	mov    %eax,%ebx
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	89 c6                	mov    %eax,%esi
  800b79:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bad:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	89 cb                	mov    %ecx,%ebx
  800bb7:	89 cf                	mov    %ecx,%edi
  800bb9:	89 ce                	mov    %ecx,%esi
  800bbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 03                	push   $0x3
  800bc7:	68 ff 2a 80 00       	push   $0x802aff
  800bcc:	6a 23                	push   $0x23
  800bce:	68 1c 2b 80 00       	push   $0x802b1c
  800bd3:	e8 d5 17 00 00       	call   8023ad <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf0:	89 d1                	mov    %edx,%ecx
  800bf2:	89 d3                	mov    %edx,%ebx
  800bf4:	89 d7                	mov    %edx,%edi
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_yield>:

void
sys_yield(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	be 00 00 00 00       	mov    $0x0,%esi
  800c2c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3a:	89 f7                	mov    %esi,%edi
  800c3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 04                	push   $0x4
  800c48:	68 ff 2a 80 00       	push   $0x802aff
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 1c 2b 80 00       	push   $0x802b1c
  800c54:	e8 54 17 00 00       	call   8023ad <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 05                	push   $0x5
  800c8a:	68 ff 2a 80 00       	push   $0x802aff
  800c8f:	6a 23                	push   $0x23
  800c91:	68 1c 2b 80 00       	push   $0x802b1c
  800c96:	e8 12 17 00 00       	call   8023ad <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 06                	push   $0x6
  800ccc:	68 ff 2a 80 00       	push   $0x802aff
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 1c 2b 80 00       	push   $0x802b1c
  800cd8:	e8 d0 16 00 00       	call   8023ad <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf3:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	89 df                	mov    %ebx,%edi
  800d00:	89 de                	mov    %ebx,%esi
  800d02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7e 17                	jle    800d1f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 08                	push   $0x8
  800d0e:	68 ff 2a 80 00       	push   $0x802aff
  800d13:	6a 23                	push   $0x23
  800d15:	68 1c 2b 80 00       	push   $0x802b1c
  800d1a:	e8 8e 16 00 00       	call   8023ad <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 17                	jle    800d61 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 09                	push   $0x9
  800d50:	68 ff 2a 80 00       	push   $0x802aff
  800d55:	6a 23                	push   $0x23
  800d57:	68 1c 2b 80 00       	push   $0x802b1c
  800d5c:	e8 4c 16 00 00       	call   8023ad <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	89 df                	mov    %ebx,%edi
  800d84:	89 de                	mov    %ebx,%esi
  800d86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7e 17                	jle    800da3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	50                   	push   %eax
  800d90:	6a 0a                	push   $0xa
  800d92:	68 ff 2a 80 00       	push   $0x802aff
  800d97:	6a 23                	push   $0x23
  800d99:	68 1c 2b 80 00       	push   $0x802b1c
  800d9e:	e8 0a 16 00 00       	call   8023ad <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	be 00 00 00 00       	mov    $0x0,%esi
  800db6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	89 cb                	mov    %ecx,%ebx
  800de6:	89 cf                	mov    %ecx,%edi
  800de8:	89 ce                	mov    %ecx,%esi
  800dea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7e 17                	jle    800e07 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	50                   	push   %eax
  800df4:	6a 0d                	push   $0xd
  800df6:	68 ff 2a 80 00       	push   $0x802aff
  800dfb:	6a 23                	push   $0x23
  800dfd:	68 1c 2b 80 00       	push   $0x802b1c
  800e02:	e8 a6 15 00 00       	call   8023ad <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e1f:	89 d1                	mov    %edx,%ecx
  800e21:	89 d3                	mov    %edx,%ebx
  800e23:	89 d7                	mov    %edx,%edi
  800e25:	89 d6                	mov    %edx,%esi
  800e27:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e39:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	89 df                	mov    %ebx,%edi
  800e46:	89 de                	mov    %ebx,%esi
  800e48:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	53                   	push   %ebx
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e59:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e5b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e5f:	74 2e                	je     800e8f <pgfault+0x40>
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	c1 ea 16             	shr    $0x16,%edx
  800e66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6d:	f6 c2 01             	test   $0x1,%dl
  800e70:	74 1d                	je     800e8f <pgfault+0x40>
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	c1 ea 0c             	shr    $0xc,%edx
  800e77:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e7e:	f6 c1 01             	test   $0x1,%cl
  800e81:	74 0c                	je     800e8f <pgfault+0x40>
  800e83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8a:	f6 c6 08             	test   $0x8,%dh
  800e8d:	75 14                	jne    800ea3 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	68 2a 2b 80 00       	push   $0x802b2a
  800e97:	6a 1d                	push   $0x1d
  800e99:	68 3d 2b 80 00       	push   $0x802b3d
  800e9e:	e8 0a 15 00 00       	call   8023ad <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800ea3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea8:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	6a 07                	push   $0x7
  800eaf:	68 00 f0 7f 00       	push   $0x7ff000
  800eb4:	6a 00                	push   $0x0
  800eb6:	e8 63 fd ff ff       	call   800c1e <sys_page_alloc>
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	79 14                	jns    800ed6 <pgfault+0x87>
		panic("page alloc failed \n");
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	68 48 2b 80 00       	push   $0x802b48
  800eca:	6a 28                	push   $0x28
  800ecc:	68 3d 2b 80 00       	push   $0x802b3d
  800ed1:	e8 d7 14 00 00       	call   8023ad <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	68 00 10 00 00       	push   $0x1000
  800ede:	53                   	push   %ebx
  800edf:	68 00 f0 7f 00       	push   $0x7ff000
  800ee4:	e8 2c fb ff ff       	call   800a15 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800ee9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef0:	53                   	push   %ebx
  800ef1:	6a 00                	push   $0x0
  800ef3:	68 00 f0 7f 00       	push   $0x7ff000
  800ef8:	6a 00                	push   $0x0
  800efa:	e8 62 fd ff ff       	call   800c61 <sys_page_map>
  800eff:	83 c4 20             	add    $0x20,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	79 14                	jns    800f1a <pgfault+0xcb>
        panic("page map failed \n");
  800f06:	83 ec 04             	sub    $0x4,%esp
  800f09:	68 5c 2b 80 00       	push   $0x802b5c
  800f0e:	6a 2b                	push   $0x2b
  800f10:	68 3d 2b 80 00       	push   $0x802b3d
  800f15:	e8 93 14 00 00       	call   8023ad <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800f1a:	83 ec 08             	sub    $0x8,%esp
  800f1d:	68 00 f0 7f 00       	push   $0x7ff000
  800f22:	6a 00                	push   $0x0
  800f24:	e8 7a fd ff ff       	call   800ca3 <sys_page_unmap>
  800f29:	83 c4 10             	add    $0x10,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	79 14                	jns    800f44 <pgfault+0xf5>
        panic("page unmap failed\n");
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	68 6e 2b 80 00       	push   $0x802b6e
  800f38:	6a 2d                	push   $0x2d
  800f3a:	68 3d 2b 80 00       	push   $0x802b3d
  800f3f:	e8 69 14 00 00       	call   8023ad <_panic>
	
	//panic("pgfault not implemented");
}
  800f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	53                   	push   %ebx
  800f4f:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800f52:	68 4f 0e 80 00       	push   $0x800e4f
  800f57:	e8 97 14 00 00       	call   8023f3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f5c:	b8 07 00 00 00       	mov    $0x7,%eax
  800f61:	cd 30                	int    $0x30
  800f63:	89 c7                	mov    %eax,%edi
  800f65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	79 12                	jns    800f81 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800f6f:	50                   	push   %eax
  800f70:	68 81 2b 80 00       	push   $0x802b81
  800f75:	6a 7a                	push   $0x7a
  800f77:	68 3d 2b 80 00       	push   $0x802b3d
  800f7c:	e8 2c 14 00 00       	call   8023ad <_panic>
  800f81:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f86:	85 c0                	test   %eax,%eax
  800f88:	75 21                	jne    800fab <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f8a:	e8 51 fc ff ff       	call   800be0 <sys_getenvid>
  800f8f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f94:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f97:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9c:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa6:	e9 91 01 00 00       	jmp    80113c <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	c1 e8 16             	shr    $0x16,%eax
  800fb0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb7:	a8 01                	test   $0x1,%al
  800fb9:	0f 84 06 01 00 00    	je     8010c5 <fork+0x17c>
  800fbf:	89 d8                	mov    %ebx,%eax
  800fc1:	c1 e8 0c             	shr    $0xc,%eax
  800fc4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcb:	f6 c2 01             	test   $0x1,%dl
  800fce:	0f 84 f1 00 00 00    	je     8010c5 <fork+0x17c>
  800fd4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdb:	f6 c2 04             	test   $0x4,%dl
  800fde:	0f 84 e1 00 00 00    	je     8010c5 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  800fe4:	89 c6                	mov    %eax,%esi
  800fe6:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  800fe9:	89 f2                	mov    %esi,%edx
  800feb:	c1 ea 16             	shr    $0x16,%edx
  800fee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  800ff5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  800ffc:	f6 c6 04             	test   $0x4,%dh
  800fff:	74 39                	je     80103a <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  801001:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	25 07 0e 00 00       	and    $0xe07,%eax
  801010:	50                   	push   %eax
  801011:	56                   	push   %esi
  801012:	ff 75 e4             	pushl  -0x1c(%ebp)
  801015:	56                   	push   %esi
  801016:	6a 00                	push   $0x0
  801018:	e8 44 fc ff ff       	call   800c61 <sys_page_map>
  80101d:	83 c4 20             	add    $0x20,%esp
  801020:	85 c0                	test   %eax,%eax
  801022:	0f 89 9d 00 00 00    	jns    8010c5 <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  801028:	50                   	push   %eax
  801029:	68 d8 2b 80 00       	push   $0x802bd8
  80102e:	6a 4b                	push   $0x4b
  801030:	68 3d 2b 80 00       	push   $0x802b3d
  801035:	e8 73 13 00 00       	call   8023ad <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  80103a:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801040:	74 59                	je     80109b <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	68 05 08 00 00       	push   $0x805
  80104a:	56                   	push   %esi
  80104b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104e:	56                   	push   %esi
  80104f:	6a 00                	push   $0x0
  801051:	e8 0b fc ff ff       	call   800c61 <sys_page_map>
  801056:	83 c4 20             	add    $0x20,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	79 12                	jns    80106f <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  80105d:	50                   	push   %eax
  80105e:	68 08 2c 80 00       	push   $0x802c08
  801063:	6a 50                	push   $0x50
  801065:	68 3d 2b 80 00       	push   $0x802b3d
  80106a:	e8 3e 13 00 00       	call   8023ad <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	68 05 08 00 00       	push   $0x805
  801077:	56                   	push   %esi
  801078:	6a 00                	push   $0x0
  80107a:	56                   	push   %esi
  80107b:	6a 00                	push   $0x0
  80107d:	e8 df fb ff ff       	call   800c61 <sys_page_map>
  801082:	83 c4 20             	add    $0x20,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	79 3c                	jns    8010c5 <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  801089:	50                   	push   %eax
  80108a:	68 30 2c 80 00       	push   $0x802c30
  80108f:	6a 53                	push   $0x53
  801091:	68 3d 2b 80 00       	push   $0x802b3d
  801096:	e8 12 13 00 00       	call   8023ad <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	6a 05                	push   $0x5
  8010a0:	56                   	push   %esi
  8010a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a4:	56                   	push   %esi
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 b5 fb ff ff       	call   800c61 <sys_page_map>
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 12                	jns    8010c5 <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  8010b3:	50                   	push   %eax
  8010b4:	68 58 2c 80 00       	push   $0x802c58
  8010b9:	6a 58                	push   $0x58
  8010bb:	68 3d 2b 80 00       	push   $0x802b3d
  8010c0:	e8 e8 12 00 00       	call   8023ad <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  8010c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010cb:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d1:	0f 85 d4 fe ff ff    	jne    800fab <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	6a 07                	push   $0x7
  8010dc:	68 00 f0 bf ee       	push   $0xeebff000
  8010e1:	57                   	push   %edi
  8010e2:	e8 37 fb ff ff       	call   800c1e <sys_page_alloc>
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 17                	jns    801105 <fork+0x1bc>
        panic("page alloc failed\n");
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	68 93 2b 80 00       	push   $0x802b93
  8010f6:	68 87 00 00 00       	push   $0x87
  8010fb:	68 3d 2b 80 00       	push   $0x802b3d
  801100:	e8 a8 12 00 00       	call   8023ad <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	68 62 24 80 00       	push   $0x802462
  80110d:	57                   	push   %edi
  80110e:	e8 56 fc ff ff       	call   800d69 <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801113:	83 c4 08             	add    $0x8,%esp
  801116:	6a 02                	push   $0x2
  801118:	57                   	push   %edi
  801119:	e8 c7 fb ff ff       	call   800ce5 <sys_env_set_status>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	79 15                	jns    80113a <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  801125:	50                   	push   %eax
  801126:	68 a6 2b 80 00       	push   $0x802ba6
  80112b:	68 8c 00 00 00       	push   $0x8c
  801130:	68 3d 2b 80 00       	push   $0x802b3d
  801135:	e8 73 12 00 00       	call   8023ad <_panic>

	return envid;
  80113a:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  80113c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <sfork>:

// Challenge!
int
sfork(void)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80114a:	68 bf 2b 80 00       	push   $0x802bbf
  80114f:	68 98 00 00 00       	push   $0x98
  801154:	68 3d 2b 80 00       	push   $0x802b3d
  801159:	e8 4f 12 00 00       	call   8023ad <_panic>

0080115e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	8b 75 08             	mov    0x8(%ebp),%esi
  801166:	8b 45 0c             	mov    0xc(%ebp),%eax
  801169:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  80116c:	85 c0                	test   %eax,%eax
  80116e:	74 0e                	je     80117e <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	50                   	push   %eax
  801174:	e8 55 fc ff ff       	call   800dce <sys_ipc_recv>
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	eb 10                	jmp    80118e <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80117e:	83 ec 0c             	sub    $0xc,%esp
  801181:	68 00 00 00 f0       	push   $0xf0000000
  801186:	e8 43 fc ff ff       	call   800dce <sys_ipc_recv>
  80118b:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80118e:	85 c0                	test   %eax,%eax
  801190:	74 0e                	je     8011a0 <ipc_recv+0x42>
    	*from_env_store = 0;
  801192:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  80119e:	eb 24                	jmp    8011c4 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8011a0:	85 f6                	test   %esi,%esi
  8011a2:	74 0a                	je     8011ae <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8011a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a9:	8b 40 74             	mov    0x74(%eax),%eax
  8011ac:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8011ae:	85 db                	test   %ebx,%ebx
  8011b0:	74 0a                	je     8011bc <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8011b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b7:	8b 40 78             	mov    0x78(%eax),%eax
  8011ba:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8011bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c1:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8011c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8011dd:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8011df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011e4:	0f 44 d8             	cmove  %eax,%ebx
  8011e7:	eb 1c                	jmp    801205 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8011e9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011ec:	74 12                	je     801200 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8011ee:	50                   	push   %eax
  8011ef:	68 84 2c 80 00       	push   $0x802c84
  8011f4:	6a 4b                	push   $0x4b
  8011f6:	68 9c 2c 80 00       	push   $0x802c9c
  8011fb:	e8 ad 11 00 00       	call   8023ad <_panic>
        }	
        sys_yield();
  801200:	e8 fa f9 ff ff       	call   800bff <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801205:	ff 75 14             	pushl  0x14(%ebp)
  801208:	53                   	push   %ebx
  801209:	56                   	push   %esi
  80120a:	57                   	push   %edi
  80120b:	e8 9b fb ff ff       	call   800dab <sys_ipc_try_send>
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	75 d2                	jne    8011e9 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801217:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80122a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80122d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801233:	8b 52 50             	mov    0x50(%edx),%edx
  801236:	39 ca                	cmp    %ecx,%edx
  801238:	75 0d                	jne    801247 <ipc_find_env+0x28>
			return envs[i].env_id;
  80123a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80123d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801242:	8b 40 48             	mov    0x48(%eax),%eax
  801245:	eb 0f                	jmp    801256 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801247:	83 c0 01             	add    $0x1,%eax
  80124a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80124f:	75 d9                	jne    80122a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801251:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	05 00 00 00 30       	add    $0x30000000,%eax
  801263:	c1 e8 0c             	shr    $0xc,%eax
}
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	05 00 00 00 30       	add    $0x30000000,%eax
  801273:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801278:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801285:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	c1 ea 16             	shr    $0x16,%edx
  80128f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801296:	f6 c2 01             	test   $0x1,%dl
  801299:	74 11                	je     8012ac <fd_alloc+0x2d>
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	c1 ea 0c             	shr    $0xc,%edx
  8012a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a7:	f6 c2 01             	test   $0x1,%dl
  8012aa:	75 09                	jne    8012b5 <fd_alloc+0x36>
			*fd_store = fd;
  8012ac:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b3:	eb 17                	jmp    8012cc <fd_alloc+0x4d>
  8012b5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ba:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bf:	75 c9                	jne    80128a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012c7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d4:	83 f8 1f             	cmp    $0x1f,%eax
  8012d7:	77 36                	ja     80130f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d9:	c1 e0 0c             	shl    $0xc,%eax
  8012dc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	c1 ea 16             	shr    $0x16,%edx
  8012e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ed:	f6 c2 01             	test   $0x1,%dl
  8012f0:	74 24                	je     801316 <fd_lookup+0x48>
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	c1 ea 0c             	shr    $0xc,%edx
  8012f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fe:	f6 c2 01             	test   $0x1,%dl
  801301:	74 1a                	je     80131d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801303:	8b 55 0c             	mov    0xc(%ebp),%edx
  801306:	89 02                	mov    %eax,(%edx)
	return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
  80130d:	eb 13                	jmp    801322 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801314:	eb 0c                	jmp    801322 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801316:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131b:	eb 05                	jmp    801322 <fd_lookup+0x54>
  80131d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132d:	ba 24 2d 80 00       	mov    $0x802d24,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801332:	eb 13                	jmp    801347 <dev_lookup+0x23>
  801334:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801337:	39 08                	cmp    %ecx,(%eax)
  801339:	75 0c                	jne    801347 <dev_lookup+0x23>
			*dev = devtab[i];
  80133b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	eb 2e                	jmp    801375 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801347:	8b 02                	mov    (%edx),%eax
  801349:	85 c0                	test   %eax,%eax
  80134b:	75 e7                	jne    801334 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134d:	a1 08 40 80 00       	mov    0x804008,%eax
  801352:	8b 40 48             	mov    0x48(%eax),%eax
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	51                   	push   %ecx
  801359:	50                   	push   %eax
  80135a:	68 a8 2c 80 00       	push   $0x802ca8
  80135f:	e8 32 ef ff ff       	call   800296 <cprintf>
	*dev = 0;
  801364:	8b 45 0c             	mov    0xc(%ebp),%eax
  801367:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
  80137c:	83 ec 10             	sub    $0x10,%esp
  80137f:	8b 75 08             	mov    0x8(%ebp),%esi
  801382:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	50                   	push   %eax
  801389:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80138f:	c1 e8 0c             	shr    $0xc,%eax
  801392:	50                   	push   %eax
  801393:	e8 36 ff ff ff       	call   8012ce <fd_lookup>
  801398:	83 c4 08             	add    $0x8,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 05                	js     8013a4 <fd_close+0x2d>
	    || fd != fd2)
  80139f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013a2:	74 0c                	je     8013b0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013a4:	84 db                	test   %bl,%bl
  8013a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ab:	0f 44 c2             	cmove  %edx,%eax
  8013ae:	eb 41                	jmp    8013f1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	ff 36                	pushl  (%esi)
  8013b9:	e8 66 ff ff ff       	call   801324 <dev_lookup>
  8013be:	89 c3                	mov    %eax,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 1a                	js     8013e1 <fd_close+0x6a>
		if (dev->dev_close)
  8013c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ca:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	74 0b                	je     8013e1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	56                   	push   %esi
  8013da:	ff d0                	call   *%eax
  8013dc:	89 c3                	mov    %eax,%ebx
  8013de:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	56                   	push   %esi
  8013e5:	6a 00                	push   $0x0
  8013e7:	e8 b7 f8 ff ff       	call   800ca3 <sys_page_unmap>
	return r;
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	89 d8                	mov    %ebx,%eax
}
  8013f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5e                   	pop    %esi
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	ff 75 08             	pushl  0x8(%ebp)
  801405:	e8 c4 fe ff ff       	call   8012ce <fd_lookup>
  80140a:	83 c4 08             	add    $0x8,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 10                	js     801421 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	6a 01                	push   $0x1
  801416:	ff 75 f4             	pushl  -0xc(%ebp)
  801419:	e8 59 ff ff ff       	call   801377 <fd_close>
  80141e:	83 c4 10             	add    $0x10,%esp
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <close_all>:

void
close_all(void)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	53                   	push   %ebx
  801427:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80142a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80142f:	83 ec 0c             	sub    $0xc,%esp
  801432:	53                   	push   %ebx
  801433:	e8 c0 ff ff ff       	call   8013f8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801438:	83 c3 01             	add    $0x1,%ebx
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	83 fb 20             	cmp    $0x20,%ebx
  801441:	75 ec                	jne    80142f <close_all+0xc>
		close(i);
}
  801443:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	57                   	push   %edi
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
  80144e:	83 ec 2c             	sub    $0x2c,%esp
  801451:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801454:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801457:	50                   	push   %eax
  801458:	ff 75 08             	pushl  0x8(%ebp)
  80145b:	e8 6e fe ff ff       	call   8012ce <fd_lookup>
  801460:	83 c4 08             	add    $0x8,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	0f 88 c1 00 00 00    	js     80152c <dup+0xe4>
		return r;
	close(newfdnum);
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	56                   	push   %esi
  80146f:	e8 84 ff ff ff       	call   8013f8 <close>

	newfd = INDEX2FD(newfdnum);
  801474:	89 f3                	mov    %esi,%ebx
  801476:	c1 e3 0c             	shl    $0xc,%ebx
  801479:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80147f:	83 c4 04             	add    $0x4,%esp
  801482:	ff 75 e4             	pushl  -0x1c(%ebp)
  801485:	e8 de fd ff ff       	call   801268 <fd2data>
  80148a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80148c:	89 1c 24             	mov    %ebx,(%esp)
  80148f:	e8 d4 fd ff ff       	call   801268 <fd2data>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80149a:	89 f8                	mov    %edi,%eax
  80149c:	c1 e8 16             	shr    $0x16,%eax
  80149f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a6:	a8 01                	test   $0x1,%al
  8014a8:	74 37                	je     8014e1 <dup+0x99>
  8014aa:	89 f8                	mov    %edi,%eax
  8014ac:	c1 e8 0c             	shr    $0xc,%eax
  8014af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	74 26                	je     8014e1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ca:	50                   	push   %eax
  8014cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ce:	6a 00                	push   $0x0
  8014d0:	57                   	push   %edi
  8014d1:	6a 00                	push   $0x0
  8014d3:	e8 89 f7 ff ff       	call   800c61 <sys_page_map>
  8014d8:	89 c7                	mov    %eax,%edi
  8014da:	83 c4 20             	add    $0x20,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 2e                	js     80150f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e4:	89 d0                	mov    %edx,%eax
  8014e6:	c1 e8 0c             	shr    $0xc,%eax
  8014e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f8:	50                   	push   %eax
  8014f9:	53                   	push   %ebx
  8014fa:	6a 00                	push   $0x0
  8014fc:	52                   	push   %edx
  8014fd:	6a 00                	push   $0x0
  8014ff:	e8 5d f7 ff ff       	call   800c61 <sys_page_map>
  801504:	89 c7                	mov    %eax,%edi
  801506:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801509:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150b:	85 ff                	test   %edi,%edi
  80150d:	79 1d                	jns    80152c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	53                   	push   %ebx
  801513:	6a 00                	push   $0x0
  801515:	e8 89 f7 ff ff       	call   800ca3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801520:	6a 00                	push   $0x0
  801522:	e8 7c f7 ff ff       	call   800ca3 <sys_page_unmap>
	return r;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	89 f8                	mov    %edi,%eax
}
  80152c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152f:	5b                   	pop    %ebx
  801530:	5e                   	pop    %esi
  801531:	5f                   	pop    %edi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 14             	sub    $0x14,%esp
  80153b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	53                   	push   %ebx
  801543:	e8 86 fd ff ff       	call   8012ce <fd_lookup>
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 6d                	js     8015be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	ff 30                	pushl  (%eax)
  80155d:	e8 c2 fd ff ff       	call   801324 <dev_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 4c                	js     8015b5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801569:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80156c:	8b 42 08             	mov    0x8(%edx),%eax
  80156f:	83 e0 03             	and    $0x3,%eax
  801572:	83 f8 01             	cmp    $0x1,%eax
  801575:	75 21                	jne    801598 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801577:	a1 08 40 80 00       	mov    0x804008,%eax
  80157c:	8b 40 48             	mov    0x48(%eax),%eax
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	53                   	push   %ebx
  801583:	50                   	push   %eax
  801584:	68 e9 2c 80 00       	push   $0x802ce9
  801589:	e8 08 ed ff ff       	call   800296 <cprintf>
		return -E_INVAL;
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801596:	eb 26                	jmp    8015be <read+0x8a>
	}
	if (!dev->dev_read)
  801598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159b:	8b 40 08             	mov    0x8(%eax),%eax
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	74 17                	je     8015b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	ff 75 10             	pushl  0x10(%ebp)
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	52                   	push   %edx
  8015ac:	ff d0                	call   *%eax
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 09                	jmp    8015be <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	89 c2                	mov    %eax,%edx
  8015b7:	eb 05                	jmp    8015be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015be:	89 d0                	mov    %edx,%eax
  8015c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	57                   	push   %edi
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 0c             	sub    $0xc,%esp
  8015ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d9:	eb 21                	jmp    8015fc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015db:	83 ec 04             	sub    $0x4,%esp
  8015de:	89 f0                	mov    %esi,%eax
  8015e0:	29 d8                	sub    %ebx,%eax
  8015e2:	50                   	push   %eax
  8015e3:	89 d8                	mov    %ebx,%eax
  8015e5:	03 45 0c             	add    0xc(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	57                   	push   %edi
  8015ea:	e8 45 ff ff ff       	call   801534 <read>
		if (m < 0)
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 10                	js     801606 <readn+0x41>
			return m;
		if (m == 0)
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	74 0a                	je     801604 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fa:	01 c3                	add    %eax,%ebx
  8015fc:	39 f3                	cmp    %esi,%ebx
  8015fe:	72 db                	jb     8015db <readn+0x16>
  801600:	89 d8                	mov    %ebx,%eax
  801602:	eb 02                	jmp    801606 <readn+0x41>
  801604:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801606:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801609:	5b                   	pop    %ebx
  80160a:	5e                   	pop    %esi
  80160b:	5f                   	pop    %edi
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	53                   	push   %ebx
  801612:	83 ec 14             	sub    $0x14,%esp
  801615:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801618:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	53                   	push   %ebx
  80161d:	e8 ac fc ff ff       	call   8012ce <fd_lookup>
  801622:	83 c4 08             	add    $0x8,%esp
  801625:	89 c2                	mov    %eax,%edx
  801627:	85 c0                	test   %eax,%eax
  801629:	78 68                	js     801693 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801631:	50                   	push   %eax
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	ff 30                	pushl  (%eax)
  801637:	e8 e8 fc ff ff       	call   801324 <dev_lookup>
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 47                	js     80168a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164a:	75 21                	jne    80166d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80164c:	a1 08 40 80 00       	mov    0x804008,%eax
  801651:	8b 40 48             	mov    0x48(%eax),%eax
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	53                   	push   %ebx
  801658:	50                   	push   %eax
  801659:	68 05 2d 80 00       	push   $0x802d05
  80165e:	e8 33 ec ff ff       	call   800296 <cprintf>
		return -E_INVAL;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80166b:	eb 26                	jmp    801693 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801670:	8b 52 0c             	mov    0xc(%edx),%edx
  801673:	85 d2                	test   %edx,%edx
  801675:	74 17                	je     80168e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	ff 75 10             	pushl  0x10(%ebp)
  80167d:	ff 75 0c             	pushl  0xc(%ebp)
  801680:	50                   	push   %eax
  801681:	ff d2                	call   *%edx
  801683:	89 c2                	mov    %eax,%edx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	eb 09                	jmp    801693 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	eb 05                	jmp    801693 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80168e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801693:	89 d0                	mov    %edx,%eax
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <seek>:

int
seek(int fdnum, off_t offset)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	ff 75 08             	pushl  0x8(%ebp)
  8016a7:	e8 22 fc ff ff       	call   8012ce <fd_lookup>
  8016ac:	83 c4 08             	add    $0x8,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 0e                	js     8016c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 14             	sub    $0x14,%esp
  8016ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	53                   	push   %ebx
  8016d2:	e8 f7 fb ff ff       	call   8012ce <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 65                	js     801745 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ea:	ff 30                	pushl  (%eax)
  8016ec:	e8 33 fc ff ff       	call   801324 <dev_lookup>
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 44                	js     80173c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ff:	75 21                	jne    801722 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801701:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801706:	8b 40 48             	mov    0x48(%eax),%eax
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	53                   	push   %ebx
  80170d:	50                   	push   %eax
  80170e:	68 c8 2c 80 00       	push   $0x802cc8
  801713:	e8 7e eb ff ff       	call   800296 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801720:	eb 23                	jmp    801745 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801722:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801725:	8b 52 18             	mov    0x18(%edx),%edx
  801728:	85 d2                	test   %edx,%edx
  80172a:	74 14                	je     801740 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	ff 75 0c             	pushl  0xc(%ebp)
  801732:	50                   	push   %eax
  801733:	ff d2                	call   *%edx
  801735:	89 c2                	mov    %eax,%edx
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	eb 09                	jmp    801745 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	eb 05                	jmp    801745 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801740:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801745:	89 d0                	mov    %edx,%eax
  801747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 14             	sub    $0x14,%esp
  801753:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	ff 75 08             	pushl  0x8(%ebp)
  80175d:	e8 6c fb ff ff       	call   8012ce <fd_lookup>
  801762:	83 c4 08             	add    $0x8,%esp
  801765:	89 c2                	mov    %eax,%edx
  801767:	85 c0                	test   %eax,%eax
  801769:	78 58                	js     8017c3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801771:	50                   	push   %eax
  801772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801775:	ff 30                	pushl  (%eax)
  801777:	e8 a8 fb ff ff       	call   801324 <dev_lookup>
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 37                	js     8017ba <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801786:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80178a:	74 32                	je     8017be <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80178c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801796:	00 00 00 
	stat->st_isdir = 0;
  801799:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a0:	00 00 00 
	stat->st_dev = dev;
  8017a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	53                   	push   %ebx
  8017ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b0:	ff 50 14             	call   *0x14(%eax)
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	eb 09                	jmp    8017c3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ba:	89 c2                	mov    %eax,%edx
  8017bc:	eb 05                	jmp    8017c3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c3:	89 d0                	mov    %edx,%eax
  8017c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    

008017ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	56                   	push   %esi
  8017ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	6a 00                	push   $0x0
  8017d4:	ff 75 08             	pushl  0x8(%ebp)
  8017d7:	e8 e7 01 00 00       	call   8019c3 <open>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 1b                	js     801800 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	ff 75 0c             	pushl  0xc(%ebp)
  8017eb:	50                   	push   %eax
  8017ec:	e8 5b ff ff ff       	call   80174c <fstat>
  8017f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f3:	89 1c 24             	mov    %ebx,(%esp)
  8017f6:	e8 fd fb ff ff       	call   8013f8 <close>
	return r;
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	89 f0                	mov    %esi,%eax
}
  801800:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	89 c6                	mov    %eax,%esi
  80180e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801810:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801817:	75 12                	jne    80182b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	6a 01                	push   $0x1
  80181e:	e8 fc f9 ff ff       	call   80121f <ipc_find_env>
  801823:	a3 00 40 80 00       	mov    %eax,0x804000
  801828:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80182b:	6a 07                	push   $0x7
  80182d:	68 00 50 80 00       	push   $0x805000
  801832:	56                   	push   %esi
  801833:	ff 35 00 40 80 00    	pushl  0x804000
  801839:	e8 8d f9 ff ff       	call   8011cb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183e:	83 c4 0c             	add    $0xc,%esp
  801841:	6a 00                	push   $0x0
  801843:	53                   	push   %ebx
  801844:	6a 00                	push   $0x0
  801846:	e8 13 f9 ff ff       	call   80115e <ipc_recv>
}
  80184b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 40 0c             	mov    0xc(%eax),%eax
  80185e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801863:	8b 45 0c             	mov    0xc(%ebp),%eax
  801866:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	b8 02 00 00 00       	mov    $0x2,%eax
  801875:	e8 8d ff ff ff       	call   801807 <fsipc>
}
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 40 0c             	mov    0xc(%eax),%eax
  801888:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80188d:	ba 00 00 00 00       	mov    $0x0,%edx
  801892:	b8 06 00 00 00       	mov    $0x6,%eax
  801897:	e8 6b ff ff ff       	call   801807 <fsipc>
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018bd:	e8 45 ff ff ff       	call   801807 <fsipc>
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 2c                	js     8018f2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	68 00 50 80 00       	push   $0x805000
  8018ce:	53                   	push   %ebx
  8018cf:	e8 47 ef ff ff       	call   80081b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d4:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018df:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801901:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801906:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80190b:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80190e:	53                   	push   %ebx
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	68 08 50 80 00       	push   $0x805008
  801917:	e8 91 f0 ff ff       	call   8009ad <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801927:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  80192d:	ba 00 00 00 00       	mov    $0x0,%edx
  801932:	b8 04 00 00 00       	mov    $0x4,%eax
  801937:	e8 cb fe ff ff       	call   801807 <fsipc>
	//panic("devfile_write not implemented");
}
  80193c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	8b 40 0c             	mov    0xc(%eax),%eax
  80194f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801954:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80195a:	ba 00 00 00 00       	mov    $0x0,%edx
  80195f:	b8 03 00 00 00       	mov    $0x3,%eax
  801964:	e8 9e fe ff ff       	call   801807 <fsipc>
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 4b                	js     8019ba <devfile_read+0x79>
		return r;
	assert(r <= n);
  80196f:	39 c6                	cmp    %eax,%esi
  801971:	73 16                	jae    801989 <devfile_read+0x48>
  801973:	68 38 2d 80 00       	push   $0x802d38
  801978:	68 3f 2d 80 00       	push   $0x802d3f
  80197d:	6a 7c                	push   $0x7c
  80197f:	68 54 2d 80 00       	push   $0x802d54
  801984:	e8 24 0a 00 00       	call   8023ad <_panic>
	assert(r <= PGSIZE);
  801989:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198e:	7e 16                	jle    8019a6 <devfile_read+0x65>
  801990:	68 5f 2d 80 00       	push   $0x802d5f
  801995:	68 3f 2d 80 00       	push   $0x802d3f
  80199a:	6a 7d                	push   $0x7d
  80199c:	68 54 2d 80 00       	push   $0x802d54
  8019a1:	e8 07 0a 00 00       	call   8023ad <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	50                   	push   %eax
  8019aa:	68 00 50 80 00       	push   $0x805000
  8019af:	ff 75 0c             	pushl  0xc(%ebp)
  8019b2:	e8 f6 ef ff ff       	call   8009ad <memmove>
	return r;
  8019b7:	83 c4 10             	add    $0x10,%esp
}
  8019ba:	89 d8                	mov    %ebx,%eax
  8019bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bf:	5b                   	pop    %ebx
  8019c0:	5e                   	pop    %esi
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    

008019c3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 20             	sub    $0x20,%esp
  8019ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019cd:	53                   	push   %ebx
  8019ce:	e8 0f ee ff ff       	call   8007e2 <strlen>
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019db:	7f 67                	jg     801a44 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019dd:	83 ec 0c             	sub    $0xc,%esp
  8019e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	e8 96 f8 ff ff       	call   80127f <fd_alloc>
  8019e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ec:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 57                	js     801a49 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	53                   	push   %ebx
  8019f6:	68 00 50 80 00       	push   $0x805000
  8019fb:	e8 1b ee ff ff       	call   80081b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a03:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a10:	e8 f2 fd ff ff       	call   801807 <fsipc>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	79 14                	jns    801a32 <open+0x6f>
		fd_close(fd, 0);
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	6a 00                	push   $0x0
  801a23:	ff 75 f4             	pushl  -0xc(%ebp)
  801a26:	e8 4c f9 ff ff       	call   801377 <fd_close>
		return r;
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	89 da                	mov    %ebx,%edx
  801a30:	eb 17                	jmp    801a49 <open+0x86>
	}

	return fd2num(fd);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	ff 75 f4             	pushl  -0xc(%ebp)
  801a38:	e8 1b f8 ff ff       	call   801258 <fd2num>
  801a3d:	89 c2                	mov    %eax,%edx
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	eb 05                	jmp    801a49 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a44:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a49:	89 d0                	mov    %edx,%eax
  801a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a56:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a60:	e8 a2 fd ff ff       	call   801807 <fsipc>
}
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a6d:	68 6b 2d 80 00       	push   $0x802d6b
  801a72:	ff 75 0c             	pushl  0xc(%ebp)
  801a75:	e8 a1 ed ff ff       	call   80081b <strcpy>
	return 0;
}
  801a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	53                   	push   %ebx
  801a85:	83 ec 10             	sub    $0x10,%esp
  801a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a8b:	53                   	push   %ebx
  801a8c:	e8 f5 09 00 00       	call   802486 <pageref>
  801a91:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a94:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a99:	83 f8 01             	cmp    $0x1,%eax
  801a9c:	75 10                	jne    801aae <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	ff 73 0c             	pushl  0xc(%ebx)
  801aa4:	e8 c0 02 00 00       	call   801d69 <nsipc_close>
  801aa9:	89 c2                	mov    %eax,%edx
  801aab:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801aae:	89 d0                	mov    %edx,%eax
  801ab0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801abb:	6a 00                	push   $0x0
  801abd:	ff 75 10             	pushl  0x10(%ebp)
  801ac0:	ff 75 0c             	pushl  0xc(%ebp)
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	ff 70 0c             	pushl  0xc(%eax)
  801ac9:	e8 78 03 00 00       	call   801e46 <nsipc_send>
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ad6:	6a 00                	push   $0x0
  801ad8:	ff 75 10             	pushl  0x10(%ebp)
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	ff 70 0c             	pushl  0xc(%eax)
  801ae4:	e8 f1 02 00 00       	call   801dda <nsipc_recv>
}
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    

00801aeb <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801af1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801af4:	52                   	push   %edx
  801af5:	50                   	push   %eax
  801af6:	e8 d3 f7 ff ff       	call   8012ce <fd_lookup>
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 17                	js     801b19 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b05:	8b 0d 28 30 80 00    	mov    0x803028,%ecx
  801b0b:	39 08                	cmp    %ecx,(%eax)
  801b0d:	75 05                	jne    801b14 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b12:	eb 05                	jmp    801b19 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b14:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	56                   	push   %esi
  801b1f:	53                   	push   %ebx
  801b20:	83 ec 1c             	sub    $0x1c,%esp
  801b23:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b28:	50                   	push   %eax
  801b29:	e8 51 f7 ff ff       	call   80127f <fd_alloc>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 1b                	js     801b52 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	68 07 04 00 00       	push   $0x407
  801b3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b42:	6a 00                	push   $0x0
  801b44:	e8 d5 f0 ff ff       	call   800c1e <sys_page_alloc>
  801b49:	89 c3                	mov    %eax,%ebx
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	79 10                	jns    801b62 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	56                   	push   %esi
  801b56:	e8 0e 02 00 00       	call   801d69 <nsipc_close>
		return r;
  801b5b:	83 c4 10             	add    $0x10,%esp
  801b5e:	89 d8                	mov    %ebx,%eax
  801b60:	eb 24                	jmp    801b86 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b62:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b70:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b77:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	50                   	push   %eax
  801b7e:	e8 d5 f6 ff ff       	call   801258 <fd2num>
  801b83:	83 c4 10             	add    $0x10,%esp
}
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	e8 50 ff ff ff       	call   801aeb <fd2sockid>
		return r;
  801b9b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 1f                	js     801bc0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	ff 75 10             	pushl  0x10(%ebp)
  801ba7:	ff 75 0c             	pushl  0xc(%ebp)
  801baa:	50                   	push   %eax
  801bab:	e8 12 01 00 00       	call   801cc2 <nsipc_accept>
  801bb0:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	78 07                	js     801bc0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bb9:	e8 5d ff ff ff       	call   801b1b <alloc_sockfd>
  801bbe:	89 c1                	mov    %eax,%ecx
}
  801bc0:	89 c8                	mov    %ecx,%eax
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bca:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcd:	e8 19 ff ff ff       	call   801aeb <fd2sockid>
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	78 12                	js     801be8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801bd6:	83 ec 04             	sub    $0x4,%esp
  801bd9:	ff 75 10             	pushl  0x10(%ebp)
  801bdc:	ff 75 0c             	pushl  0xc(%ebp)
  801bdf:	50                   	push   %eax
  801be0:	e8 2d 01 00 00       	call   801d12 <nsipc_bind>
  801be5:	83 c4 10             	add    $0x10,%esp
}
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <shutdown>:

int
shutdown(int s, int how)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	e8 f3 fe ff ff       	call   801aeb <fd2sockid>
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	78 0f                	js     801c0b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	ff 75 0c             	pushl  0xc(%ebp)
  801c02:	50                   	push   %eax
  801c03:	e8 3f 01 00 00       	call   801d47 <nsipc_shutdown>
  801c08:	83 c4 10             	add    $0x10,%esp
}
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    

00801c0d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	e8 d0 fe ff ff       	call   801aeb <fd2sockid>
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 12                	js     801c31 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c1f:	83 ec 04             	sub    $0x4,%esp
  801c22:	ff 75 10             	pushl  0x10(%ebp)
  801c25:	ff 75 0c             	pushl  0xc(%ebp)
  801c28:	50                   	push   %eax
  801c29:	e8 55 01 00 00       	call   801d83 <nsipc_connect>
  801c2e:	83 c4 10             	add    $0x10,%esp
}
  801c31:	c9                   	leave  
  801c32:	c3                   	ret    

00801c33 <listen>:

int
listen(int s, int backlog)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c39:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3c:	e8 aa fe ff ff       	call   801aeb <fd2sockid>
  801c41:	85 c0                	test   %eax,%eax
  801c43:	78 0f                	js     801c54 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	ff 75 0c             	pushl  0xc(%ebp)
  801c4b:	50                   	push   %eax
  801c4c:	e8 67 01 00 00       	call   801db8 <nsipc_listen>
  801c51:	83 c4 10             	add    $0x10,%esp
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c5c:	ff 75 10             	pushl  0x10(%ebp)
  801c5f:	ff 75 0c             	pushl  0xc(%ebp)
  801c62:	ff 75 08             	pushl  0x8(%ebp)
  801c65:	e8 3a 02 00 00       	call   801ea4 <nsipc_socket>
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 05                	js     801c76 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c71:	e8 a5 fe ff ff       	call   801b1b <alloc_sockfd>
}
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	53                   	push   %ebx
  801c7c:	83 ec 04             	sub    $0x4,%esp
  801c7f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c81:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c88:	75 12                	jne    801c9c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c8a:	83 ec 0c             	sub    $0xc,%esp
  801c8d:	6a 02                	push   $0x2
  801c8f:	e8 8b f5 ff ff       	call   80121f <ipc_find_env>
  801c94:	a3 04 40 80 00       	mov    %eax,0x804004
  801c99:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c9c:	6a 07                	push   $0x7
  801c9e:	68 00 60 80 00       	push   $0x806000
  801ca3:	53                   	push   %ebx
  801ca4:	ff 35 04 40 80 00    	pushl  0x804004
  801caa:	e8 1c f5 ff ff       	call   8011cb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801caf:	83 c4 0c             	add    $0xc,%esp
  801cb2:	6a 00                	push   $0x0
  801cb4:	6a 00                	push   $0x0
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 a1 f4 ff ff       	call   80115e <ipc_recv>
}
  801cbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	56                   	push   %esi
  801cc6:	53                   	push   %ebx
  801cc7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cd2:	8b 06                	mov    (%esi),%eax
  801cd4:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cde:	e8 95 ff ff ff       	call   801c78 <nsipc>
  801ce3:	89 c3                	mov    %eax,%ebx
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 20                	js     801d09 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ce9:	83 ec 04             	sub    $0x4,%esp
  801cec:	ff 35 10 60 80 00    	pushl  0x806010
  801cf2:	68 00 60 80 00       	push   $0x806000
  801cf7:	ff 75 0c             	pushl  0xc(%ebp)
  801cfa:	e8 ae ec ff ff       	call   8009ad <memmove>
		*addrlen = ret->ret_addrlen;
  801cff:	a1 10 60 80 00       	mov    0x806010,%eax
  801d04:	89 06                	mov    %eax,(%esi)
  801d06:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d09:	89 d8                	mov    %ebx,%eax
  801d0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	53                   	push   %ebx
  801d16:	83 ec 08             	sub    $0x8,%esp
  801d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d24:	53                   	push   %ebx
  801d25:	ff 75 0c             	pushl  0xc(%ebp)
  801d28:	68 04 60 80 00       	push   $0x806004
  801d2d:	e8 7b ec ff ff       	call   8009ad <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d32:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d38:	b8 02 00 00 00       	mov    $0x2,%eax
  801d3d:	e8 36 ff ff ff       	call   801c78 <nsipc>
}
  801d42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d50:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d58:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d5d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d62:	e8 11 ff ff ff       	call   801c78 <nsipc>
}
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <nsipc_close>:

int
nsipc_close(int s)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d77:	b8 04 00 00 00       	mov    $0x4,%eax
  801d7c:	e8 f7 fe ff ff       	call   801c78 <nsipc>
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	53                   	push   %ebx
  801d87:	83 ec 08             	sub    $0x8,%esp
  801d8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d90:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d95:	53                   	push   %ebx
  801d96:	ff 75 0c             	pushl  0xc(%ebp)
  801d99:	68 04 60 80 00       	push   $0x806004
  801d9e:	e8 0a ec ff ff       	call   8009ad <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801da3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801da9:	b8 05 00 00 00       	mov    $0x5,%eax
  801dae:	e8 c5 fe ff ff       	call   801c78 <nsipc>
}
  801db3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dce:	b8 06 00 00 00       	mov    $0x6,%eax
  801dd3:	e8 a0 fe ff ff       	call   801c78 <nsipc>
}
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	56                   	push   %esi
  801dde:	53                   	push   %ebx
  801ddf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801de2:	8b 45 08             	mov    0x8(%ebp),%eax
  801de5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dea:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801df0:	8b 45 14             	mov    0x14(%ebp),%eax
  801df3:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801df8:	b8 07 00 00 00       	mov    $0x7,%eax
  801dfd:	e8 76 fe ff ff       	call   801c78 <nsipc>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 35                	js     801e3d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e08:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e0d:	7f 04                	jg     801e13 <nsipc_recv+0x39>
  801e0f:	39 c6                	cmp    %eax,%esi
  801e11:	7d 16                	jge    801e29 <nsipc_recv+0x4f>
  801e13:	68 77 2d 80 00       	push   $0x802d77
  801e18:	68 3f 2d 80 00       	push   $0x802d3f
  801e1d:	6a 62                	push   $0x62
  801e1f:	68 8c 2d 80 00       	push   $0x802d8c
  801e24:	e8 84 05 00 00       	call   8023ad <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e29:	83 ec 04             	sub    $0x4,%esp
  801e2c:	50                   	push   %eax
  801e2d:	68 00 60 80 00       	push   $0x806000
  801e32:	ff 75 0c             	pushl  0xc(%ebp)
  801e35:	e8 73 eb ff ff       	call   8009ad <memmove>
  801e3a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e3d:	89 d8                	mov    %ebx,%eax
  801e3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e42:	5b                   	pop    %ebx
  801e43:	5e                   	pop    %esi
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    

00801e46 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	53                   	push   %ebx
  801e4a:	83 ec 04             	sub    $0x4,%esp
  801e4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e50:	8b 45 08             	mov    0x8(%ebp),%eax
  801e53:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e58:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e5e:	7e 16                	jle    801e76 <nsipc_send+0x30>
  801e60:	68 98 2d 80 00       	push   $0x802d98
  801e65:	68 3f 2d 80 00       	push   $0x802d3f
  801e6a:	6a 6d                	push   $0x6d
  801e6c:	68 8c 2d 80 00       	push   $0x802d8c
  801e71:	e8 37 05 00 00       	call   8023ad <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e76:	83 ec 04             	sub    $0x4,%esp
  801e79:	53                   	push   %ebx
  801e7a:	ff 75 0c             	pushl  0xc(%ebp)
  801e7d:	68 0c 60 80 00       	push   $0x80600c
  801e82:	e8 26 eb ff ff       	call   8009ad <memmove>
	nsipcbuf.send.req_size = size;
  801e87:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e8d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e90:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e95:	b8 08 00 00 00       	mov    $0x8,%eax
  801e9a:	e8 d9 fd ff ff       	call   801c78 <nsipc>
}
  801e9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ead:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801eba:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ec2:	b8 09 00 00 00       	mov    $0x9,%eax
  801ec7:	e8 ac fd ff ff       	call   801c78 <nsipc>
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	56                   	push   %esi
  801ed2:	53                   	push   %ebx
  801ed3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ed6:	83 ec 0c             	sub    $0xc,%esp
  801ed9:	ff 75 08             	pushl  0x8(%ebp)
  801edc:	e8 87 f3 ff ff       	call   801268 <fd2data>
  801ee1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ee3:	83 c4 08             	add    $0x8,%esp
  801ee6:	68 a4 2d 80 00       	push   $0x802da4
  801eeb:	53                   	push   %ebx
  801eec:	e8 2a e9 ff ff       	call   80081b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ef1:	8b 46 04             	mov    0x4(%esi),%eax
  801ef4:	2b 06                	sub    (%esi),%eax
  801ef6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801efc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f03:	00 00 00 
	stat->st_dev = &devpipe;
  801f06:	c7 83 88 00 00 00 44 	movl   $0x803044,0x88(%ebx)
  801f0d:	30 80 00 
	return 0;
}
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
  801f15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	53                   	push   %ebx
  801f20:	83 ec 0c             	sub    $0xc,%esp
  801f23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f26:	53                   	push   %ebx
  801f27:	6a 00                	push   $0x0
  801f29:	e8 75 ed ff ff       	call   800ca3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f2e:	89 1c 24             	mov    %ebx,(%esp)
  801f31:	e8 32 f3 ff ff       	call   801268 <fd2data>
  801f36:	83 c4 08             	add    $0x8,%esp
  801f39:	50                   	push   %eax
  801f3a:	6a 00                	push   $0x0
  801f3c:	e8 62 ed ff ff       	call   800ca3 <sys_page_unmap>
}
  801f41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	57                   	push   %edi
  801f4a:	56                   	push   %esi
  801f4b:	53                   	push   %ebx
  801f4c:	83 ec 1c             	sub    $0x1c,%esp
  801f4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f52:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f54:	a1 08 40 80 00       	mov    0x804008,%eax
  801f59:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f5c:	83 ec 0c             	sub    $0xc,%esp
  801f5f:	ff 75 e0             	pushl  -0x20(%ebp)
  801f62:	e8 1f 05 00 00       	call   802486 <pageref>
  801f67:	89 c3                	mov    %eax,%ebx
  801f69:	89 3c 24             	mov    %edi,(%esp)
  801f6c:	e8 15 05 00 00       	call   802486 <pageref>
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	39 c3                	cmp    %eax,%ebx
  801f76:	0f 94 c1             	sete   %cl
  801f79:	0f b6 c9             	movzbl %cl,%ecx
  801f7c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f7f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f85:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f88:	39 ce                	cmp    %ecx,%esi
  801f8a:	74 1b                	je     801fa7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f8c:	39 c3                	cmp    %eax,%ebx
  801f8e:	75 c4                	jne    801f54 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f90:	8b 42 58             	mov    0x58(%edx),%eax
  801f93:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f96:	50                   	push   %eax
  801f97:	56                   	push   %esi
  801f98:	68 ab 2d 80 00       	push   $0x802dab
  801f9d:	e8 f4 e2 ff ff       	call   800296 <cprintf>
  801fa2:	83 c4 10             	add    $0x10,%esp
  801fa5:	eb ad                	jmp    801f54 <_pipeisclosed+0xe>
	}
}
  801fa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	57                   	push   %edi
  801fb6:	56                   	push   %esi
  801fb7:	53                   	push   %ebx
  801fb8:	83 ec 28             	sub    $0x28,%esp
  801fbb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fbe:	56                   	push   %esi
  801fbf:	e8 a4 f2 ff ff       	call   801268 <fd2data>
  801fc4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	bf 00 00 00 00       	mov    $0x0,%edi
  801fce:	eb 4b                	jmp    80201b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fd0:	89 da                	mov    %ebx,%edx
  801fd2:	89 f0                	mov    %esi,%eax
  801fd4:	e8 6d ff ff ff       	call   801f46 <_pipeisclosed>
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	75 48                	jne    802025 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fdd:	e8 1d ec ff ff       	call   800bff <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fe2:	8b 43 04             	mov    0x4(%ebx),%eax
  801fe5:	8b 0b                	mov    (%ebx),%ecx
  801fe7:	8d 51 20             	lea    0x20(%ecx),%edx
  801fea:	39 d0                	cmp    %edx,%eax
  801fec:	73 e2                	jae    801fd0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ff1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ff5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ff8:	89 c2                	mov    %eax,%edx
  801ffa:	c1 fa 1f             	sar    $0x1f,%edx
  801ffd:	89 d1                	mov    %edx,%ecx
  801fff:	c1 e9 1b             	shr    $0x1b,%ecx
  802002:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802005:	83 e2 1f             	and    $0x1f,%edx
  802008:	29 ca                	sub    %ecx,%edx
  80200a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80200e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802012:	83 c0 01             	add    $0x1,%eax
  802015:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802018:	83 c7 01             	add    $0x1,%edi
  80201b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80201e:	75 c2                	jne    801fe2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802020:	8b 45 10             	mov    0x10(%ebp),%eax
  802023:	eb 05                	jmp    80202a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80202a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	57                   	push   %edi
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
  802038:	83 ec 18             	sub    $0x18,%esp
  80203b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80203e:	57                   	push   %edi
  80203f:	e8 24 f2 ff ff       	call   801268 <fd2data>
  802044:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	bb 00 00 00 00       	mov    $0x0,%ebx
  80204e:	eb 3d                	jmp    80208d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802050:	85 db                	test   %ebx,%ebx
  802052:	74 04                	je     802058 <devpipe_read+0x26>
				return i;
  802054:	89 d8                	mov    %ebx,%eax
  802056:	eb 44                	jmp    80209c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802058:	89 f2                	mov    %esi,%edx
  80205a:	89 f8                	mov    %edi,%eax
  80205c:	e8 e5 fe ff ff       	call   801f46 <_pipeisclosed>
  802061:	85 c0                	test   %eax,%eax
  802063:	75 32                	jne    802097 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802065:	e8 95 eb ff ff       	call   800bff <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80206a:	8b 06                	mov    (%esi),%eax
  80206c:	3b 46 04             	cmp    0x4(%esi),%eax
  80206f:	74 df                	je     802050 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802071:	99                   	cltd   
  802072:	c1 ea 1b             	shr    $0x1b,%edx
  802075:	01 d0                	add    %edx,%eax
  802077:	83 e0 1f             	and    $0x1f,%eax
  80207a:	29 d0                	sub    %edx,%eax
  80207c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802084:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802087:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80208a:	83 c3 01             	add    $0x1,%ebx
  80208d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802090:	75 d8                	jne    80206a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802092:	8b 45 10             	mov    0x10(%ebp),%eax
  802095:	eb 05                	jmp    80209c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802097:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80209c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	56                   	push   %esi
  8020a8:	53                   	push   %ebx
  8020a9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020af:	50                   	push   %eax
  8020b0:	e8 ca f1 ff ff       	call   80127f <fd_alloc>
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	89 c2                	mov    %eax,%edx
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	0f 88 2c 01 00 00    	js     8021ee <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c2:	83 ec 04             	sub    $0x4,%esp
  8020c5:	68 07 04 00 00       	push   $0x407
  8020ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8020cd:	6a 00                	push   $0x0
  8020cf:	e8 4a eb ff ff       	call   800c1e <sys_page_alloc>
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	89 c2                	mov    %eax,%edx
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	0f 88 0d 01 00 00    	js     8021ee <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020e1:	83 ec 0c             	sub    $0xc,%esp
  8020e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020e7:	50                   	push   %eax
  8020e8:	e8 92 f1 ff ff       	call   80127f <fd_alloc>
  8020ed:	89 c3                	mov    %eax,%ebx
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	0f 88 e2 00 00 00    	js     8021dc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020fa:	83 ec 04             	sub    $0x4,%esp
  8020fd:	68 07 04 00 00       	push   $0x407
  802102:	ff 75 f0             	pushl  -0x10(%ebp)
  802105:	6a 00                	push   $0x0
  802107:	e8 12 eb ff ff       	call   800c1e <sys_page_alloc>
  80210c:	89 c3                	mov    %eax,%ebx
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	85 c0                	test   %eax,%eax
  802113:	0f 88 c3 00 00 00    	js     8021dc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802119:	83 ec 0c             	sub    $0xc,%esp
  80211c:	ff 75 f4             	pushl  -0xc(%ebp)
  80211f:	e8 44 f1 ff ff       	call   801268 <fd2data>
  802124:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802126:	83 c4 0c             	add    $0xc,%esp
  802129:	68 07 04 00 00       	push   $0x407
  80212e:	50                   	push   %eax
  80212f:	6a 00                	push   $0x0
  802131:	e8 e8 ea ff ff       	call   800c1e <sys_page_alloc>
  802136:	89 c3                	mov    %eax,%ebx
  802138:	83 c4 10             	add    $0x10,%esp
  80213b:	85 c0                	test   %eax,%eax
  80213d:	0f 88 89 00 00 00    	js     8021cc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802143:	83 ec 0c             	sub    $0xc,%esp
  802146:	ff 75 f0             	pushl  -0x10(%ebp)
  802149:	e8 1a f1 ff ff       	call   801268 <fd2data>
  80214e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802155:	50                   	push   %eax
  802156:	6a 00                	push   $0x0
  802158:	56                   	push   %esi
  802159:	6a 00                	push   $0x0
  80215b:	e8 01 eb ff ff       	call   800c61 <sys_page_map>
  802160:	89 c3                	mov    %eax,%ebx
  802162:	83 c4 20             	add    $0x20,%esp
  802165:	85 c0                	test   %eax,%eax
  802167:	78 55                	js     8021be <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802169:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80216f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802172:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802174:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802177:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80217e:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802184:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802187:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80218c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802193:	83 ec 0c             	sub    $0xc,%esp
  802196:	ff 75 f4             	pushl  -0xc(%ebp)
  802199:	e8 ba f0 ff ff       	call   801258 <fd2num>
  80219e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021a1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021a3:	83 c4 04             	add    $0x4,%esp
  8021a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a9:	e8 aa f0 ff ff       	call   801258 <fd2num>
  8021ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021b1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8021bc:	eb 30                	jmp    8021ee <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021be:	83 ec 08             	sub    $0x8,%esp
  8021c1:	56                   	push   %esi
  8021c2:	6a 00                	push   $0x0
  8021c4:	e8 da ea ff ff       	call   800ca3 <sys_page_unmap>
  8021c9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021cc:	83 ec 08             	sub    $0x8,%esp
  8021cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d2:	6a 00                	push   $0x0
  8021d4:	e8 ca ea ff ff       	call   800ca3 <sys_page_unmap>
  8021d9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021dc:	83 ec 08             	sub    $0x8,%esp
  8021df:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e2:	6a 00                	push   $0x0
  8021e4:	e8 ba ea ff ff       	call   800ca3 <sys_page_unmap>
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021ee:	89 d0                	mov    %edx,%eax
  8021f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5d                   	pop    %ebp
  8021f6:	c3                   	ret    

008021f7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021f7:	55                   	push   %ebp
  8021f8:	89 e5                	mov    %esp,%ebp
  8021fa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802200:	50                   	push   %eax
  802201:	ff 75 08             	pushl  0x8(%ebp)
  802204:	e8 c5 f0 ff ff       	call   8012ce <fd_lookup>
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	85 c0                	test   %eax,%eax
  80220e:	78 18                	js     802228 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802210:	83 ec 0c             	sub    $0xc,%esp
  802213:	ff 75 f4             	pushl  -0xc(%ebp)
  802216:	e8 4d f0 ff ff       	call   801268 <fd2data>
	return _pipeisclosed(fd, p);
  80221b:	89 c2                	mov    %eax,%edx
  80221d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802220:	e8 21 fd ff ff       	call   801f46 <_pipeisclosed>
  802225:	83 c4 10             	add    $0x10,%esp
}
  802228:	c9                   	leave  
  802229:	c3                   	ret    

0080222a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80222a:	55                   	push   %ebp
  80222b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    

00802234 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80223a:	68 c3 2d 80 00       	push   $0x802dc3
  80223f:	ff 75 0c             	pushl  0xc(%ebp)
  802242:	e8 d4 e5 ff ff       	call   80081b <strcpy>
	return 0;
}
  802247:	b8 00 00 00 00       	mov    $0x0,%eax
  80224c:	c9                   	leave  
  80224d:	c3                   	ret    

0080224e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80225a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80225f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802265:	eb 2d                	jmp    802294 <devcons_write+0x46>
		m = n - tot;
  802267:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80226a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80226c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80226f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802274:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802277:	83 ec 04             	sub    $0x4,%esp
  80227a:	53                   	push   %ebx
  80227b:	03 45 0c             	add    0xc(%ebp),%eax
  80227e:	50                   	push   %eax
  80227f:	57                   	push   %edi
  802280:	e8 28 e7 ff ff       	call   8009ad <memmove>
		sys_cputs(buf, m);
  802285:	83 c4 08             	add    $0x8,%esp
  802288:	53                   	push   %ebx
  802289:	57                   	push   %edi
  80228a:	e8 d3 e8 ff ff       	call   800b62 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80228f:	01 de                	add    %ebx,%esi
  802291:	83 c4 10             	add    $0x10,%esp
  802294:	89 f0                	mov    %esi,%eax
  802296:	3b 75 10             	cmp    0x10(%ebp),%esi
  802299:	72 cc                	jb     802267 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80229b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80229e:	5b                   	pop    %ebx
  80229f:	5e                   	pop    %esi
  8022a0:	5f                   	pop    %edi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    

008022a3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	83 ec 08             	sub    $0x8,%esp
  8022a9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022b2:	74 2a                	je     8022de <devcons_read+0x3b>
  8022b4:	eb 05                	jmp    8022bb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022b6:	e8 44 e9 ff ff       	call   800bff <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022bb:	e8 c0 e8 ff ff       	call   800b80 <sys_cgetc>
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	74 f2                	je     8022b6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022c4:	85 c0                	test   %eax,%eax
  8022c6:	78 16                	js     8022de <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022c8:	83 f8 04             	cmp    $0x4,%eax
  8022cb:	74 0c                	je     8022d9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022d0:	88 02                	mov    %al,(%edx)
	return 1;
  8022d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d7:	eb 05                	jmp    8022de <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022d9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022de:	c9                   	leave  
  8022df:	c3                   	ret    

008022e0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022ec:	6a 01                	push   $0x1
  8022ee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022f1:	50                   	push   %eax
  8022f2:	e8 6b e8 ff ff       	call   800b62 <sys_cputs>
}
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	c9                   	leave  
  8022fb:	c3                   	ret    

008022fc <getchar>:

int
getchar(void)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802302:	6a 01                	push   $0x1
  802304:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802307:	50                   	push   %eax
  802308:	6a 00                	push   $0x0
  80230a:	e8 25 f2 ff ff       	call   801534 <read>
	if (r < 0)
  80230f:	83 c4 10             	add    $0x10,%esp
  802312:	85 c0                	test   %eax,%eax
  802314:	78 0f                	js     802325 <getchar+0x29>
		return r;
	if (r < 1)
  802316:	85 c0                	test   %eax,%eax
  802318:	7e 06                	jle    802320 <getchar+0x24>
		return -E_EOF;
	return c;
  80231a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80231e:	eb 05                	jmp    802325 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802320:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802325:	c9                   	leave  
  802326:	c3                   	ret    

00802327 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802327:	55                   	push   %ebp
  802328:	89 e5                	mov    %esp,%ebp
  80232a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80232d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802330:	50                   	push   %eax
  802331:	ff 75 08             	pushl  0x8(%ebp)
  802334:	e8 95 ef ff ff       	call   8012ce <fd_lookup>
  802339:	83 c4 10             	add    $0x10,%esp
  80233c:	85 c0                	test   %eax,%eax
  80233e:	78 11                	js     802351 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802343:	8b 15 60 30 80 00    	mov    0x803060,%edx
  802349:	39 10                	cmp    %edx,(%eax)
  80234b:	0f 94 c0             	sete   %al
  80234e:	0f b6 c0             	movzbl %al,%eax
}
  802351:	c9                   	leave  
  802352:	c3                   	ret    

00802353 <opencons>:

int
opencons(void)
{
  802353:	55                   	push   %ebp
  802354:	89 e5                	mov    %esp,%ebp
  802356:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80235c:	50                   	push   %eax
  80235d:	e8 1d ef ff ff       	call   80127f <fd_alloc>
  802362:	83 c4 10             	add    $0x10,%esp
		return r;
  802365:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802367:	85 c0                	test   %eax,%eax
  802369:	78 3e                	js     8023a9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80236b:	83 ec 04             	sub    $0x4,%esp
  80236e:	68 07 04 00 00       	push   $0x407
  802373:	ff 75 f4             	pushl  -0xc(%ebp)
  802376:	6a 00                	push   $0x0
  802378:	e8 a1 e8 ff ff       	call   800c1e <sys_page_alloc>
  80237d:	83 c4 10             	add    $0x10,%esp
		return r;
  802380:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802382:	85 c0                	test   %eax,%eax
  802384:	78 23                	js     8023a9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802386:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80238c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802394:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80239b:	83 ec 0c             	sub    $0xc,%esp
  80239e:	50                   	push   %eax
  80239f:	e8 b4 ee ff ff       	call   801258 <fd2num>
  8023a4:	89 c2                	mov    %eax,%edx
  8023a6:	83 c4 10             	add    $0x10,%esp
}
  8023a9:	89 d0                	mov    %edx,%eax
  8023ab:	c9                   	leave  
  8023ac:	c3                   	ret    

008023ad <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8023ad:	55                   	push   %ebp
  8023ae:	89 e5                	mov    %esp,%ebp
  8023b0:	56                   	push   %esi
  8023b1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8023b2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8023b5:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8023bb:	e8 20 e8 ff ff       	call   800be0 <sys_getenvid>
  8023c0:	83 ec 0c             	sub    $0xc,%esp
  8023c3:	ff 75 0c             	pushl  0xc(%ebp)
  8023c6:	ff 75 08             	pushl  0x8(%ebp)
  8023c9:	56                   	push   %esi
  8023ca:	50                   	push   %eax
  8023cb:	68 d0 2d 80 00       	push   $0x802dd0
  8023d0:	e8 c1 de ff ff       	call   800296 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8023d5:	83 c4 18             	add    $0x18,%esp
  8023d8:	53                   	push   %ebx
  8023d9:	ff 75 10             	pushl  0x10(%ebp)
  8023dc:	e8 64 de ff ff       	call   800245 <vcprintf>
	cprintf("\n");
  8023e1:	c7 04 24 5a 2b 80 00 	movl   $0x802b5a,(%esp)
  8023e8:	e8 a9 de ff ff       	call   800296 <cprintf>
  8023ed:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023f0:	cc                   	int3   
  8023f1:	eb fd                	jmp    8023f0 <_panic+0x43>

008023f3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023f9:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802400:	75 2c                	jne    80242e <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802402:	83 ec 04             	sub    $0x4,%esp
  802405:	6a 07                	push   $0x7
  802407:	68 00 f0 bf ee       	push   $0xeebff000
  80240c:	6a 00                	push   $0x0
  80240e:	e8 0b e8 ff ff       	call   800c1e <sys_page_alloc>
  802413:	83 c4 10             	add    $0x10,%esp
  802416:	85 c0                	test   %eax,%eax
  802418:	79 14                	jns    80242e <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  80241a:	83 ec 04             	sub    $0x4,%esp
  80241d:	68 f3 2d 80 00       	push   $0x802df3
  802422:	6a 22                	push   $0x22
  802424:	68 0a 2e 80 00       	push   $0x802e0a
  802429:	e8 7f ff ff ff       	call   8023ad <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  80242e:	8b 45 08             	mov    0x8(%ebp),%eax
  802431:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802436:	83 ec 08             	sub    $0x8,%esp
  802439:	68 62 24 80 00       	push   $0x802462
  80243e:	6a 00                	push   $0x0
  802440:	e8 24 e9 ff ff       	call   800d69 <sys_env_set_pgfault_upcall>
  802445:	83 c4 10             	add    $0x10,%esp
  802448:	85 c0                	test   %eax,%eax
  80244a:	79 14                	jns    802460 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  80244c:	83 ec 04             	sub    $0x4,%esp
  80244f:	68 18 2e 80 00       	push   $0x802e18
  802454:	6a 27                	push   $0x27
  802456:	68 0a 2e 80 00       	push   $0x802e0a
  80245b:	e8 4d ff ff ff       	call   8023ad <_panic>
    
}
  802460:	c9                   	leave  
  802461:	c3                   	ret    

00802462 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802462:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802463:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802468:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80246a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  80246d:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  802471:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  802476:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80247a:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80247c:	83 c4 08             	add    $0x8,%esp
	popal
  80247f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  802480:	83 c4 04             	add    $0x4,%esp
	popfl
  802483:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802484:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802485:	c3                   	ret    

00802486 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802486:	55                   	push   %ebp
  802487:	89 e5                	mov    %esp,%ebp
  802489:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80248c:	89 d0                	mov    %edx,%eax
  80248e:	c1 e8 16             	shr    $0x16,%eax
  802491:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802498:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80249d:	f6 c1 01             	test   $0x1,%cl
  8024a0:	74 1d                	je     8024bf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024a2:	c1 ea 0c             	shr    $0xc,%edx
  8024a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024ac:	f6 c2 01             	test   $0x1,%dl
  8024af:	74 0e                	je     8024bf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024b1:	c1 ea 0c             	shr    $0xc,%edx
  8024b4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024bb:	ef 
  8024bc:	0f b7 c0             	movzwl %ax,%eax
}
  8024bf:	5d                   	pop    %ebp
  8024c0:	c3                   	ret    
  8024c1:	66 90                	xchg   %ax,%ax
  8024c3:	66 90                	xchg   %ax,%ax
  8024c5:	66 90                	xchg   %ax,%ax
  8024c7:	66 90                	xchg   %ax,%ax
  8024c9:	66 90                	xchg   %ax,%ax
  8024cb:	66 90                	xchg   %ax,%ax
  8024cd:	66 90                	xchg   %ax,%ax
  8024cf:	90                   	nop

008024d0 <__udivdi3>:
  8024d0:	55                   	push   %ebp
  8024d1:	57                   	push   %edi
  8024d2:	56                   	push   %esi
  8024d3:	53                   	push   %ebx
  8024d4:	83 ec 1c             	sub    $0x1c,%esp
  8024d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024e7:	85 f6                	test   %esi,%esi
  8024e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ed:	89 ca                	mov    %ecx,%edx
  8024ef:	89 f8                	mov    %edi,%eax
  8024f1:	75 3d                	jne    802530 <__udivdi3+0x60>
  8024f3:	39 cf                	cmp    %ecx,%edi
  8024f5:	0f 87 c5 00 00 00    	ja     8025c0 <__udivdi3+0xf0>
  8024fb:	85 ff                	test   %edi,%edi
  8024fd:	89 fd                	mov    %edi,%ebp
  8024ff:	75 0b                	jne    80250c <__udivdi3+0x3c>
  802501:	b8 01 00 00 00       	mov    $0x1,%eax
  802506:	31 d2                	xor    %edx,%edx
  802508:	f7 f7                	div    %edi
  80250a:	89 c5                	mov    %eax,%ebp
  80250c:	89 c8                	mov    %ecx,%eax
  80250e:	31 d2                	xor    %edx,%edx
  802510:	f7 f5                	div    %ebp
  802512:	89 c1                	mov    %eax,%ecx
  802514:	89 d8                	mov    %ebx,%eax
  802516:	89 cf                	mov    %ecx,%edi
  802518:	f7 f5                	div    %ebp
  80251a:	89 c3                	mov    %eax,%ebx
  80251c:	89 d8                	mov    %ebx,%eax
  80251e:	89 fa                	mov    %edi,%edx
  802520:	83 c4 1c             	add    $0x1c,%esp
  802523:	5b                   	pop    %ebx
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    
  802528:	90                   	nop
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	39 ce                	cmp    %ecx,%esi
  802532:	77 74                	ja     8025a8 <__udivdi3+0xd8>
  802534:	0f bd fe             	bsr    %esi,%edi
  802537:	83 f7 1f             	xor    $0x1f,%edi
  80253a:	0f 84 98 00 00 00    	je     8025d8 <__udivdi3+0x108>
  802540:	bb 20 00 00 00       	mov    $0x20,%ebx
  802545:	89 f9                	mov    %edi,%ecx
  802547:	89 c5                	mov    %eax,%ebp
  802549:	29 fb                	sub    %edi,%ebx
  80254b:	d3 e6                	shl    %cl,%esi
  80254d:	89 d9                	mov    %ebx,%ecx
  80254f:	d3 ed                	shr    %cl,%ebp
  802551:	89 f9                	mov    %edi,%ecx
  802553:	d3 e0                	shl    %cl,%eax
  802555:	09 ee                	or     %ebp,%esi
  802557:	89 d9                	mov    %ebx,%ecx
  802559:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80255d:	89 d5                	mov    %edx,%ebp
  80255f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802563:	d3 ed                	shr    %cl,%ebp
  802565:	89 f9                	mov    %edi,%ecx
  802567:	d3 e2                	shl    %cl,%edx
  802569:	89 d9                	mov    %ebx,%ecx
  80256b:	d3 e8                	shr    %cl,%eax
  80256d:	09 c2                	or     %eax,%edx
  80256f:	89 d0                	mov    %edx,%eax
  802571:	89 ea                	mov    %ebp,%edx
  802573:	f7 f6                	div    %esi
  802575:	89 d5                	mov    %edx,%ebp
  802577:	89 c3                	mov    %eax,%ebx
  802579:	f7 64 24 0c          	mull   0xc(%esp)
  80257d:	39 d5                	cmp    %edx,%ebp
  80257f:	72 10                	jb     802591 <__udivdi3+0xc1>
  802581:	8b 74 24 08          	mov    0x8(%esp),%esi
  802585:	89 f9                	mov    %edi,%ecx
  802587:	d3 e6                	shl    %cl,%esi
  802589:	39 c6                	cmp    %eax,%esi
  80258b:	73 07                	jae    802594 <__udivdi3+0xc4>
  80258d:	39 d5                	cmp    %edx,%ebp
  80258f:	75 03                	jne    802594 <__udivdi3+0xc4>
  802591:	83 eb 01             	sub    $0x1,%ebx
  802594:	31 ff                	xor    %edi,%edi
  802596:	89 d8                	mov    %ebx,%eax
  802598:	89 fa                	mov    %edi,%edx
  80259a:	83 c4 1c             	add    $0x1c,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	31 ff                	xor    %edi,%edi
  8025aa:	31 db                	xor    %ebx,%ebx
  8025ac:	89 d8                	mov    %ebx,%eax
  8025ae:	89 fa                	mov    %edi,%edx
  8025b0:	83 c4 1c             	add    $0x1c,%esp
  8025b3:	5b                   	pop    %ebx
  8025b4:	5e                   	pop    %esi
  8025b5:	5f                   	pop    %edi
  8025b6:	5d                   	pop    %ebp
  8025b7:	c3                   	ret    
  8025b8:	90                   	nop
  8025b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	89 d8                	mov    %ebx,%eax
  8025c2:	f7 f7                	div    %edi
  8025c4:	31 ff                	xor    %edi,%edi
  8025c6:	89 c3                	mov    %eax,%ebx
  8025c8:	89 d8                	mov    %ebx,%eax
  8025ca:	89 fa                	mov    %edi,%edx
  8025cc:	83 c4 1c             	add    $0x1c,%esp
  8025cf:	5b                   	pop    %ebx
  8025d0:	5e                   	pop    %esi
  8025d1:	5f                   	pop    %edi
  8025d2:	5d                   	pop    %ebp
  8025d3:	c3                   	ret    
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	39 ce                	cmp    %ecx,%esi
  8025da:	72 0c                	jb     8025e8 <__udivdi3+0x118>
  8025dc:	31 db                	xor    %ebx,%ebx
  8025de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025e2:	0f 87 34 ff ff ff    	ja     80251c <__udivdi3+0x4c>
  8025e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025ed:	e9 2a ff ff ff       	jmp    80251c <__udivdi3+0x4c>
  8025f2:	66 90                	xchg   %ax,%ax
  8025f4:	66 90                	xchg   %ax,%ax
  8025f6:	66 90                	xchg   %ax,%ax
  8025f8:	66 90                	xchg   %ax,%ax
  8025fa:	66 90                	xchg   %ax,%ax
  8025fc:	66 90                	xchg   %ax,%ax
  8025fe:	66 90                	xchg   %ax,%ax

00802600 <__umoddi3>:
  802600:	55                   	push   %ebp
  802601:	57                   	push   %edi
  802602:	56                   	push   %esi
  802603:	53                   	push   %ebx
  802604:	83 ec 1c             	sub    $0x1c,%esp
  802607:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80260b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80260f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802613:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802617:	85 d2                	test   %edx,%edx
  802619:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80261d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802621:	89 f3                	mov    %esi,%ebx
  802623:	89 3c 24             	mov    %edi,(%esp)
  802626:	89 74 24 04          	mov    %esi,0x4(%esp)
  80262a:	75 1c                	jne    802648 <__umoddi3+0x48>
  80262c:	39 f7                	cmp    %esi,%edi
  80262e:	76 50                	jbe    802680 <__umoddi3+0x80>
  802630:	89 c8                	mov    %ecx,%eax
  802632:	89 f2                	mov    %esi,%edx
  802634:	f7 f7                	div    %edi
  802636:	89 d0                	mov    %edx,%eax
  802638:	31 d2                	xor    %edx,%edx
  80263a:	83 c4 1c             	add    $0x1c,%esp
  80263d:	5b                   	pop    %ebx
  80263e:	5e                   	pop    %esi
  80263f:	5f                   	pop    %edi
  802640:	5d                   	pop    %ebp
  802641:	c3                   	ret    
  802642:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802648:	39 f2                	cmp    %esi,%edx
  80264a:	89 d0                	mov    %edx,%eax
  80264c:	77 52                	ja     8026a0 <__umoddi3+0xa0>
  80264e:	0f bd ea             	bsr    %edx,%ebp
  802651:	83 f5 1f             	xor    $0x1f,%ebp
  802654:	75 5a                	jne    8026b0 <__umoddi3+0xb0>
  802656:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80265a:	0f 82 e0 00 00 00    	jb     802740 <__umoddi3+0x140>
  802660:	39 0c 24             	cmp    %ecx,(%esp)
  802663:	0f 86 d7 00 00 00    	jbe    802740 <__umoddi3+0x140>
  802669:	8b 44 24 08          	mov    0x8(%esp),%eax
  80266d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802671:	83 c4 1c             	add    $0x1c,%esp
  802674:	5b                   	pop    %ebx
  802675:	5e                   	pop    %esi
  802676:	5f                   	pop    %edi
  802677:	5d                   	pop    %ebp
  802678:	c3                   	ret    
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	85 ff                	test   %edi,%edi
  802682:	89 fd                	mov    %edi,%ebp
  802684:	75 0b                	jne    802691 <__umoddi3+0x91>
  802686:	b8 01 00 00 00       	mov    $0x1,%eax
  80268b:	31 d2                	xor    %edx,%edx
  80268d:	f7 f7                	div    %edi
  80268f:	89 c5                	mov    %eax,%ebp
  802691:	89 f0                	mov    %esi,%eax
  802693:	31 d2                	xor    %edx,%edx
  802695:	f7 f5                	div    %ebp
  802697:	89 c8                	mov    %ecx,%eax
  802699:	f7 f5                	div    %ebp
  80269b:	89 d0                	mov    %edx,%eax
  80269d:	eb 99                	jmp    802638 <__umoddi3+0x38>
  80269f:	90                   	nop
  8026a0:	89 c8                	mov    %ecx,%eax
  8026a2:	89 f2                	mov    %esi,%edx
  8026a4:	83 c4 1c             	add    $0x1c,%esp
  8026a7:	5b                   	pop    %ebx
  8026a8:	5e                   	pop    %esi
  8026a9:	5f                   	pop    %edi
  8026aa:	5d                   	pop    %ebp
  8026ab:	c3                   	ret    
  8026ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	8b 34 24             	mov    (%esp),%esi
  8026b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026b8:	89 e9                	mov    %ebp,%ecx
  8026ba:	29 ef                	sub    %ebp,%edi
  8026bc:	d3 e0                	shl    %cl,%eax
  8026be:	89 f9                	mov    %edi,%ecx
  8026c0:	89 f2                	mov    %esi,%edx
  8026c2:	d3 ea                	shr    %cl,%edx
  8026c4:	89 e9                	mov    %ebp,%ecx
  8026c6:	09 c2                	or     %eax,%edx
  8026c8:	89 d8                	mov    %ebx,%eax
  8026ca:	89 14 24             	mov    %edx,(%esp)
  8026cd:	89 f2                	mov    %esi,%edx
  8026cf:	d3 e2                	shl    %cl,%edx
  8026d1:	89 f9                	mov    %edi,%ecx
  8026d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026db:	d3 e8                	shr    %cl,%eax
  8026dd:	89 e9                	mov    %ebp,%ecx
  8026df:	89 c6                	mov    %eax,%esi
  8026e1:	d3 e3                	shl    %cl,%ebx
  8026e3:	89 f9                	mov    %edi,%ecx
  8026e5:	89 d0                	mov    %edx,%eax
  8026e7:	d3 e8                	shr    %cl,%eax
  8026e9:	89 e9                	mov    %ebp,%ecx
  8026eb:	09 d8                	or     %ebx,%eax
  8026ed:	89 d3                	mov    %edx,%ebx
  8026ef:	89 f2                	mov    %esi,%edx
  8026f1:	f7 34 24             	divl   (%esp)
  8026f4:	89 d6                	mov    %edx,%esi
  8026f6:	d3 e3                	shl    %cl,%ebx
  8026f8:	f7 64 24 04          	mull   0x4(%esp)
  8026fc:	39 d6                	cmp    %edx,%esi
  8026fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802702:	89 d1                	mov    %edx,%ecx
  802704:	89 c3                	mov    %eax,%ebx
  802706:	72 08                	jb     802710 <__umoddi3+0x110>
  802708:	75 11                	jne    80271b <__umoddi3+0x11b>
  80270a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80270e:	73 0b                	jae    80271b <__umoddi3+0x11b>
  802710:	2b 44 24 04          	sub    0x4(%esp),%eax
  802714:	1b 14 24             	sbb    (%esp),%edx
  802717:	89 d1                	mov    %edx,%ecx
  802719:	89 c3                	mov    %eax,%ebx
  80271b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80271f:	29 da                	sub    %ebx,%edx
  802721:	19 ce                	sbb    %ecx,%esi
  802723:	89 f9                	mov    %edi,%ecx
  802725:	89 f0                	mov    %esi,%eax
  802727:	d3 e0                	shl    %cl,%eax
  802729:	89 e9                	mov    %ebp,%ecx
  80272b:	d3 ea                	shr    %cl,%edx
  80272d:	89 e9                	mov    %ebp,%ecx
  80272f:	d3 ee                	shr    %cl,%esi
  802731:	09 d0                	or     %edx,%eax
  802733:	89 f2                	mov    %esi,%edx
  802735:	83 c4 1c             	add    $0x1c,%esp
  802738:	5b                   	pop    %ebx
  802739:	5e                   	pop    %esi
  80273a:	5f                   	pop    %edi
  80273b:	5d                   	pop    %ebp
  80273c:	c3                   	ret    
  80273d:	8d 76 00             	lea    0x0(%esi),%esi
  802740:	29 f9                	sub    %edi,%ecx
  802742:	19 d6                	sbb    %edx,%esi
  802744:	89 74 24 04          	mov    %esi,0x4(%esp)
  802748:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80274c:	e9 18 ff ff ff       	jmp    802669 <__umoddi3+0x69>
