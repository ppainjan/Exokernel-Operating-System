
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 a0 25 80 00       	push   $0x8025a0
  80003e:	e8 c7 01 00 00       	call   80020a <cprintf>
	exit();
  800043:	e8 15 01 00 00       	call   80015d <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 57 0d 00 00       	call   800dc3 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 5d 0d 00 00       	call   800df3 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 59 13 00 00       	call   80140b <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 b4 25 80 00       	push   $0x8025b4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 2f 17 00 00       	call   801809 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 b4 25 80 00       	push   $0x8025b4
  8000f5:	e8 10 01 00 00       	call   80020a <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800118:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80011f:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800122:	e8 2d 0a 00 00       	call   800b54 <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80012f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800134:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800139:	85 db                	test   %ebx,%ebx
  80013b:	7e 07                	jle    800144 <libmain+0x37>
		binaryname = argv[0];
  80013d:	8b 06                	mov    (%esi),%eax
  80013f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
  800149:	e8 ff fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  80014e:	e8 0a 00 00 00       	call   80015d <exit>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800163:	e8 7a 0f 00 00       	call   8010e2 <close_all>
	sys_env_destroy(0);
  800168:	83 ec 0c             	sub    $0xc,%esp
  80016b:	6a 00                	push   $0x0
  80016d:	e8 a1 09 00 00       	call   800b13 <sys_env_destroy>
}
  800172:	83 c4 10             	add    $0x10,%esp
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	83 ec 04             	sub    $0x4,%esp
  80017e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800181:	8b 13                	mov    (%ebx),%edx
  800183:	8d 42 01             	lea    0x1(%edx),%eax
  800186:	89 03                	mov    %eax,(%ebx)
  800188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800194:	75 1a                	jne    8001b0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	68 ff 00 00 00       	push   $0xff
  80019e:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a1:	50                   	push   %eax
  8001a2:	e8 2f 09 00 00       	call   800ad6 <sys_cputs>
		b->idx = 0;
  8001a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ad:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c9:	00 00 00 
	b.cnt = 0;
  8001cc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d6:	ff 75 0c             	pushl  0xc(%ebp)
  8001d9:	ff 75 08             	pushl  0x8(%ebp)
  8001dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	68 77 01 80 00       	push   $0x800177
  8001e8:	e8 54 01 00 00       	call   800341 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ed:	83 c4 08             	add    $0x8,%esp
  8001f0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 d4 08 00 00       	call   800ad6 <sys_cputs>

	return b.cnt;
}
  800202:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800210:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800213:	50                   	push   %eax
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	e8 9d ff ff ff       	call   8001b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	57                   	push   %edi
  800222:	56                   	push   %esi
  800223:	53                   	push   %ebx
  800224:	83 ec 1c             	sub    $0x1c,%esp
  800227:	89 c7                	mov    %eax,%edi
  800229:	89 d6                	mov    %edx,%esi
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800237:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800242:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800245:	39 d3                	cmp    %edx,%ebx
  800247:	72 05                	jb     80024e <printnum+0x30>
  800249:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024c:	77 45                	ja     800293 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 18             	pushl  0x18(%ebp)
  800254:	8b 45 14             	mov    0x14(%ebp),%eax
  800257:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025a:	53                   	push   %ebx
  80025b:	ff 75 10             	pushl  0x10(%ebp)
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	ff 75 e4             	pushl  -0x1c(%ebp)
  800264:	ff 75 e0             	pushl  -0x20(%ebp)
  800267:	ff 75 dc             	pushl  -0x24(%ebp)
  80026a:	ff 75 d8             	pushl  -0x28(%ebp)
  80026d:	e8 8e 20 00 00       	call   802300 <__udivdi3>
  800272:	83 c4 18             	add    $0x18,%esp
  800275:	52                   	push   %edx
  800276:	50                   	push   %eax
  800277:	89 f2                	mov    %esi,%edx
  800279:	89 f8                	mov    %edi,%eax
  80027b:	e8 9e ff ff ff       	call   80021e <printnum>
  800280:	83 c4 20             	add    $0x20,%esp
  800283:	eb 18                	jmp    80029d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	ff 75 18             	pushl  0x18(%ebp)
  80028c:	ff d7                	call   *%edi
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	eb 03                	jmp    800296 <printnum+0x78>
  800293:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800296:	83 eb 01             	sub    $0x1,%ebx
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f e8                	jg     800285 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 7b 21 00 00       	call   802430 <__umoddi3>
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	0f be 80 e6 25 80 00 	movsbl 0x8025e6(%eax),%eax
  8002bf:	50                   	push   %eax
  8002c0:	ff d7                	call   *%edi
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d0:	83 fa 01             	cmp    $0x1,%edx
  8002d3:	7e 0e                	jle    8002e3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 02                	mov    (%edx),%eax
  8002de:	8b 52 04             	mov    0x4(%edx),%edx
  8002e1:	eb 22                	jmp    800305 <getuint+0x38>
	else if (lflag)
  8002e3:	85 d2                	test   %edx,%edx
  8002e5:	74 10                	je     8002f7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e7:	8b 10                	mov    (%eax),%edx
  8002e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ec:	89 08                	mov    %ecx,(%eax)
  8002ee:	8b 02                	mov    (%edx),%eax
  8002f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f5:	eb 0e                	jmp    800305 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 02                	mov    (%edx),%eax
  800300:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800311:	8b 10                	mov    (%eax),%edx
  800313:	3b 50 04             	cmp    0x4(%eax),%edx
  800316:	73 0a                	jae    800322 <sprintputch+0x1b>
		*b->buf++ = ch;
  800318:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	88 02                	mov    %al,(%edx)
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032d:	50                   	push   %eax
  80032e:	ff 75 10             	pushl  0x10(%ebp)
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	e8 05 00 00 00       	call   800341 <vprintfmt>
	va_end(ap);
}
  80033c:	83 c4 10             	add    $0x10,%esp
  80033f:	c9                   	leave  
  800340:	c3                   	ret    

00800341 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	57                   	push   %edi
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
  800347:	83 ec 2c             	sub    $0x2c,%esp
  80034a:	8b 75 08             	mov    0x8(%ebp),%esi
  80034d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800350:	8b 7d 10             	mov    0x10(%ebp),%edi
  800353:	eb 12                	jmp    800367 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800355:	85 c0                	test   %eax,%eax
  800357:	0f 84 89 03 00 00    	je     8006e6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80035d:	83 ec 08             	sub    $0x8,%esp
  800360:	53                   	push   %ebx
  800361:	50                   	push   %eax
  800362:	ff d6                	call   *%esi
  800364:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800367:	83 c7 01             	add    $0x1,%edi
  80036a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036e:	83 f8 25             	cmp    $0x25,%eax
  800371:	75 e2                	jne    800355 <vprintfmt+0x14>
  800373:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800377:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800385:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038c:	ba 00 00 00 00       	mov    $0x0,%edx
  800391:	eb 07                	jmp    80039a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800396:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8d 47 01             	lea    0x1(%edi),%eax
  80039d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a0:	0f b6 07             	movzbl (%edi),%eax
  8003a3:	0f b6 c8             	movzbl %al,%ecx
  8003a6:	83 e8 23             	sub    $0x23,%eax
  8003a9:	3c 55                	cmp    $0x55,%al
  8003ab:	0f 87 1a 03 00 00    	ja     8006cb <vprintfmt+0x38a>
  8003b1:	0f b6 c0             	movzbl %al,%eax
  8003b4:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003be:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c2:	eb d6                	jmp    80039a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003dc:	83 fa 09             	cmp    $0x9,%edx
  8003df:	77 39                	ja     80041a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e4:	eb e9                	jmp    8003cf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f7:	eb 27                	jmp    800420 <vprintfmt+0xdf>
  8003f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800403:	0f 49 c8             	cmovns %eax,%ecx
  800406:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040c:	eb 8c                	jmp    80039a <vprintfmt+0x59>
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800411:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800418:	eb 80                	jmp    80039a <vprintfmt+0x59>
  80041a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800420:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800424:	0f 89 70 ff ff ff    	jns    80039a <vprintfmt+0x59>
				width = precision, precision = -1;
  80042a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80042d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800430:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800437:	e9 5e ff ff ff       	jmp    80039a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800442:	e9 53 ff ff ff       	jmp    80039a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	53                   	push   %ebx
  800454:	ff 30                	pushl  (%eax)
  800456:	ff d6                	call   *%esi
			break;
  800458:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045e:	e9 04 ff ff ff       	jmp    800367 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	8b 00                	mov    (%eax),%eax
  80046e:	99                   	cltd   
  80046f:	31 d0                	xor    %edx,%eax
  800471:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800473:	83 f8 0f             	cmp    $0xf,%eax
  800476:	7f 0b                	jg     800483 <vprintfmt+0x142>
  800478:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	75 18                	jne    80049b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800483:	50                   	push   %eax
  800484:	68 fe 25 80 00       	push   $0x8025fe
  800489:	53                   	push   %ebx
  80048a:	56                   	push   %esi
  80048b:	e8 94 fe ff ff       	call   800324 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800496:	e9 cc fe ff ff       	jmp    800367 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80049b:	52                   	push   %edx
  80049c:	68 b5 29 80 00       	push   $0x8029b5
  8004a1:	53                   	push   %ebx
  8004a2:	56                   	push   %esi
  8004a3:	e8 7c fe ff ff       	call   800324 <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	e9 b4 fe ff ff       	jmp    800367 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 50 04             	lea    0x4(%eax),%edx
  8004b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004be:	85 ff                	test   %edi,%edi
  8004c0:	b8 f7 25 80 00       	mov    $0x8025f7,%eax
  8004c5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cc:	0f 8e 94 00 00 00    	jle    800566 <vprintfmt+0x225>
  8004d2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d6:	0f 84 98 00 00 00    	je     800574 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e2:	57                   	push   %edi
  8004e3:	e8 86 02 00 00       	call   80076e <strnlen>
  8004e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004eb:	29 c1                	sub    %eax,%ecx
  8004ed:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004fd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	eb 0f                	jmp    800510 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	ff 75 e0             	pushl  -0x20(%ebp)
  800508:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	83 ef 01             	sub    $0x1,%edi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 ff                	test   %edi,%edi
  800512:	7f ed                	jg     800501 <vprintfmt+0x1c0>
  800514:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800517:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051a:	85 c9                	test   %ecx,%ecx
  80051c:	b8 00 00 00 00       	mov    $0x0,%eax
  800521:	0f 49 c1             	cmovns %ecx,%eax
  800524:	29 c1                	sub    %eax,%ecx
  800526:	89 75 08             	mov    %esi,0x8(%ebp)
  800529:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052f:	89 cb                	mov    %ecx,%ebx
  800531:	eb 4d                	jmp    800580 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800533:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800537:	74 1b                	je     800554 <vprintfmt+0x213>
  800539:	0f be c0             	movsbl %al,%eax
  80053c:	83 e8 20             	sub    $0x20,%eax
  80053f:	83 f8 5e             	cmp    $0x5e,%eax
  800542:	76 10                	jbe    800554 <vprintfmt+0x213>
					putch('?', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	ff 75 0c             	pushl  0xc(%ebp)
  80054a:	6a 3f                	push   $0x3f
  80054c:	ff 55 08             	call   *0x8(%ebp)
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	eb 0d                	jmp    800561 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	ff 75 0c             	pushl  0xc(%ebp)
  80055a:	52                   	push   %edx
  80055b:	ff 55 08             	call   *0x8(%ebp)
  80055e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800561:	83 eb 01             	sub    $0x1,%ebx
  800564:	eb 1a                	jmp    800580 <vprintfmt+0x23f>
  800566:	89 75 08             	mov    %esi,0x8(%ebp)
  800569:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800572:	eb 0c                	jmp    800580 <vprintfmt+0x23f>
  800574:	89 75 08             	mov    %esi,0x8(%ebp)
  800577:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800580:	83 c7 01             	add    $0x1,%edi
  800583:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800587:	0f be d0             	movsbl %al,%edx
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 23                	je     8005b1 <vprintfmt+0x270>
  80058e:	85 f6                	test   %esi,%esi
  800590:	78 a1                	js     800533 <vprintfmt+0x1f2>
  800592:	83 ee 01             	sub    $0x1,%esi
  800595:	79 9c                	jns    800533 <vprintfmt+0x1f2>
  800597:	89 df                	mov    %ebx,%edi
  800599:	8b 75 08             	mov    0x8(%ebp),%esi
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059f:	eb 18                	jmp    8005b9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	53                   	push   %ebx
  8005a5:	6a 20                	push   $0x20
  8005a7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a9:	83 ef 01             	sub    $0x1,%edi
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	eb 08                	jmp    8005b9 <vprintfmt+0x278>
  8005b1:	89 df                	mov    %ebx,%edi
  8005b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	7f e4                	jg     8005a1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c0:	e9 a2 fd ff ff       	jmp    800367 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c5:	83 fa 01             	cmp    $0x1,%edx
  8005c8:	7e 16                	jle    8005e0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 08             	lea    0x8(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 50 04             	mov    0x4(%eax),%edx
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005de:	eb 32                	jmp    800612 <vprintfmt+0x2d1>
	else if (lflag)
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	74 18                	je     8005fc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f2:	89 c1                	mov    %eax,%ecx
  8005f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fa:	eb 16                	jmp    800612 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 c1                	mov    %eax,%ecx
  80060c:	c1 f9 1f             	sar    $0x1f,%ecx
  80060f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800618:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800621:	79 74                	jns    800697 <vprintfmt+0x356>
				putch('-', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 2d                	push   $0x2d
  800629:	ff d6                	call   *%esi
				num = -(long long) num;
  80062b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800631:	f7 d8                	neg    %eax
  800633:	83 d2 00             	adc    $0x0,%edx
  800636:	f7 da                	neg    %edx
  800638:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800640:	eb 55                	jmp    800697 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 83 fc ff ff       	call   8002cd <getuint>
			base = 10;
  80064a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064f:	eb 46                	jmp    800697 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
  800654:	e8 74 fc ff ff       	call   8002cd <getuint>
		        base = 8;
  800659:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80065e:	eb 37                	jmp    800697 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 30                	push   $0x30
  800666:	ff d6                	call   *%esi
			putch('x', putdat);
  800668:	83 c4 08             	add    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 78                	push   $0x78
  80066e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 04             	lea    0x4(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800680:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800683:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800688:	eb 0d                	jmp    800697 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 3b fc ff ff       	call   8002cd <getuint>
			base = 16;
  800692:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800697:	83 ec 0c             	sub    $0xc,%esp
  80069a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80069e:	57                   	push   %edi
  80069f:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a2:	51                   	push   %ecx
  8006a3:	52                   	push   %edx
  8006a4:	50                   	push   %eax
  8006a5:	89 da                	mov    %ebx,%edx
  8006a7:	89 f0                	mov    %esi,%eax
  8006a9:	e8 70 fb ff ff       	call   80021e <printnum>
			break;
  8006ae:	83 c4 20             	add    $0x20,%esp
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b4:	e9 ae fc ff ff       	jmp    800367 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	51                   	push   %ecx
  8006be:	ff d6                	call   *%esi
			break;
  8006c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c6:	e9 9c fc ff ff       	jmp    800367 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 25                	push   $0x25
  8006d1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	eb 03                	jmp    8006db <vprintfmt+0x39a>
  8006d8:	83 ef 01             	sub    $0x1,%edi
  8006db:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006df:	75 f7                	jne    8006d8 <vprintfmt+0x397>
  8006e1:	e9 81 fc ff ff       	jmp    800367 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e9:	5b                   	pop    %ebx
  8006ea:	5e                   	pop    %esi
  8006eb:	5f                   	pop    %edi
  8006ec:	5d                   	pop    %ebp
  8006ed:	c3                   	ret    

008006ee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	83 ec 18             	sub    $0x18,%esp
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800701:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800704:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070b:	85 c0                	test   %eax,%eax
  80070d:	74 26                	je     800735 <vsnprintf+0x47>
  80070f:	85 d2                	test   %edx,%edx
  800711:	7e 22                	jle    800735 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800713:	ff 75 14             	pushl  0x14(%ebp)
  800716:	ff 75 10             	pushl  0x10(%ebp)
  800719:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	68 07 03 80 00       	push   $0x800307
  800722:	e8 1a fc ff ff       	call   800341 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800727:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 05                	jmp    80073a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800735:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800745:	50                   	push   %eax
  800746:	ff 75 10             	pushl  0x10(%ebp)
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	ff 75 08             	pushl  0x8(%ebp)
  80074f:	e8 9a ff ff ff       	call   8006ee <vsnprintf>
	va_end(ap);

	return rc;
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075c:	b8 00 00 00 00       	mov    $0x0,%eax
  800761:	eb 03                	jmp    800766 <strlen+0x10>
		n++;
  800763:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076a:	75 f7                	jne    800763 <strlen+0xd>
		n++;
	return n;
}
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800774:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	ba 00 00 00 00       	mov    $0x0,%edx
  80077c:	eb 03                	jmp    800781 <strnlen+0x13>
		n++;
  80077e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	39 c2                	cmp    %eax,%edx
  800783:	74 08                	je     80078d <strnlen+0x1f>
  800785:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800789:	75 f3                	jne    80077e <strnlen+0x10>
  80078b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800799:	89 c2                	mov    %eax,%edx
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	83 c1 01             	add    $0x1,%ecx
  8007a1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a8:	84 db                	test   %bl,%bl
  8007aa:	75 ef                	jne    80079b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ac:	5b                   	pop    %ebx
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b6:	53                   	push   %ebx
  8007b7:	e8 9a ff ff ff       	call   800756 <strlen>
  8007bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	01 d8                	add    %ebx,%eax
  8007c4:	50                   	push   %eax
  8007c5:	e8 c5 ff ff ff       	call   80078f <strcpy>
	return dst;
}
  8007ca:	89 d8                	mov    %ebx,%eax
  8007cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	56                   	push   %esi
  8007d5:	53                   	push   %ebx
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dc:	89 f3                	mov    %esi,%ebx
  8007de:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e1:	89 f2                	mov    %esi,%edx
  8007e3:	eb 0f                	jmp    8007f4 <strncpy+0x23>
		*dst++ = *src;
  8007e5:	83 c2 01             	add    $0x1,%edx
  8007e8:	0f b6 01             	movzbl (%ecx),%eax
  8007eb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ee:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f4:	39 da                	cmp    %ebx,%edx
  8007f6:	75 ed                	jne    8007e5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f8:	89 f0                	mov    %esi,%eax
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800809:	8b 55 10             	mov    0x10(%ebp),%edx
  80080c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080e:	85 d2                	test   %edx,%edx
  800810:	74 21                	je     800833 <strlcpy+0x35>
  800812:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800816:	89 f2                	mov    %esi,%edx
  800818:	eb 09                	jmp    800823 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081a:	83 c2 01             	add    $0x1,%edx
  80081d:	83 c1 01             	add    $0x1,%ecx
  800820:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800823:	39 c2                	cmp    %eax,%edx
  800825:	74 09                	je     800830 <strlcpy+0x32>
  800827:	0f b6 19             	movzbl (%ecx),%ebx
  80082a:	84 db                	test   %bl,%bl
  80082c:	75 ec                	jne    80081a <strlcpy+0x1c>
  80082e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800830:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800833:	29 f0                	sub    %esi,%eax
}
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800842:	eb 06                	jmp    80084a <strcmp+0x11>
		p++, q++;
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084a:	0f b6 01             	movzbl (%ecx),%eax
  80084d:	84 c0                	test   %al,%al
  80084f:	74 04                	je     800855 <strcmp+0x1c>
  800851:	3a 02                	cmp    (%edx),%al
  800853:	74 ef                	je     800844 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800855:	0f b6 c0             	movzbl %al,%eax
  800858:	0f b6 12             	movzbl (%edx),%edx
  80085b:	29 d0                	sub    %edx,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	53                   	push   %ebx
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
  800869:	89 c3                	mov    %eax,%ebx
  80086b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086e:	eb 06                	jmp    800876 <strncmp+0x17>
		n--, p++, q++;
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800876:	39 d8                	cmp    %ebx,%eax
  800878:	74 15                	je     80088f <strncmp+0x30>
  80087a:	0f b6 08             	movzbl (%eax),%ecx
  80087d:	84 c9                	test   %cl,%cl
  80087f:	74 04                	je     800885 <strncmp+0x26>
  800881:	3a 0a                	cmp    (%edx),%cl
  800883:	74 eb                	je     800870 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800885:	0f b6 00             	movzbl (%eax),%eax
  800888:	0f b6 12             	movzbl (%edx),%edx
  80088b:	29 d0                	sub    %edx,%eax
  80088d:	eb 05                	jmp    800894 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800894:	5b                   	pop    %ebx
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a1:	eb 07                	jmp    8008aa <strchr+0x13>
		if (*s == c)
  8008a3:	38 ca                	cmp    %cl,%dl
  8008a5:	74 0f                	je     8008b6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	0f b6 10             	movzbl (%eax),%edx
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	75 f2                	jne    8008a3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c2:	eb 03                	jmp    8008c7 <strfind+0xf>
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 04                	je     8008d2 <strfind+0x1a>
  8008ce:	84 d2                	test   %dl,%dl
  8008d0:	75 f2                	jne    8008c4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e0:	85 c9                	test   %ecx,%ecx
  8008e2:	74 36                	je     80091a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ea:	75 28                	jne    800914 <memset+0x40>
  8008ec:	f6 c1 03             	test   $0x3,%cl
  8008ef:	75 23                	jne    800914 <memset+0x40>
		c &= 0xFF;
  8008f1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f5:	89 d3                	mov    %edx,%ebx
  8008f7:	c1 e3 08             	shl    $0x8,%ebx
  8008fa:	89 d6                	mov    %edx,%esi
  8008fc:	c1 e6 18             	shl    $0x18,%esi
  8008ff:	89 d0                	mov    %edx,%eax
  800901:	c1 e0 10             	shl    $0x10,%eax
  800904:	09 f0                	or     %esi,%eax
  800906:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800908:	89 d8                	mov    %ebx,%eax
  80090a:	09 d0                	or     %edx,%eax
  80090c:	c1 e9 02             	shr    $0x2,%ecx
  80090f:	fc                   	cld    
  800910:	f3 ab                	rep stos %eax,%es:(%edi)
  800912:	eb 06                	jmp    80091a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	fc                   	cld    
  800918:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091a:	89 f8                	mov    %edi,%eax
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092f:	39 c6                	cmp    %eax,%esi
  800931:	73 35                	jae    800968 <memmove+0x47>
  800933:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800936:	39 d0                	cmp    %edx,%eax
  800938:	73 2e                	jae    800968 <memmove+0x47>
		s += n;
		d += n;
  80093a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	09 fe                	or     %edi,%esi
  800941:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800947:	75 13                	jne    80095c <memmove+0x3b>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 0e                	jne    80095c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80094e:	83 ef 04             	sub    $0x4,%edi
  800951:	8d 72 fc             	lea    -0x4(%edx),%esi
  800954:	c1 e9 02             	shr    $0x2,%ecx
  800957:	fd                   	std    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 09                	jmp    800965 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800962:	fd                   	std    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800965:	fc                   	cld    
  800966:	eb 1d                	jmp    800985 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	89 f2                	mov    %esi,%edx
  80096a:	09 c2                	or     %eax,%edx
  80096c:	f6 c2 03             	test   $0x3,%dl
  80096f:	75 0f                	jne    800980 <memmove+0x5f>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 0a                	jne    800980 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800976:	c1 e9 02             	shr    $0x2,%ecx
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097e:	eb 05                	jmp    800985 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800980:	89 c7                	mov    %eax,%edi
  800982:	fc                   	cld    
  800983:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800985:	5e                   	pop    %esi
  800986:	5f                   	pop    %edi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098c:	ff 75 10             	pushl  0x10(%ebp)
  80098f:	ff 75 0c             	pushl  0xc(%ebp)
  800992:	ff 75 08             	pushl  0x8(%ebp)
  800995:	e8 87 ff ff ff       	call   800921 <memmove>
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a7:	89 c6                	mov    %eax,%esi
  8009a9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	eb 1a                	jmp    8009c8 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ae:	0f b6 08             	movzbl (%eax),%ecx
  8009b1:	0f b6 1a             	movzbl (%edx),%ebx
  8009b4:	38 d9                	cmp    %bl,%cl
  8009b6:	74 0a                	je     8009c2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b8:	0f b6 c1             	movzbl %cl,%eax
  8009bb:	0f b6 db             	movzbl %bl,%ebx
  8009be:	29 d8                	sub    %ebx,%eax
  8009c0:	eb 0f                	jmp    8009d1 <memcmp+0x35>
		s1++, s2++;
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	39 f0                	cmp    %esi,%eax
  8009ca:	75 e2                	jne    8009ae <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	53                   	push   %ebx
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009dc:	89 c1                	mov    %eax,%ecx
  8009de:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e5:	eb 0a                	jmp    8009f1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e7:	0f b6 10             	movzbl (%eax),%edx
  8009ea:	39 da                	cmp    %ebx,%edx
  8009ec:	74 07                	je     8009f5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	39 c8                	cmp    %ecx,%eax
  8009f3:	72 f2                	jb     8009e7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a04:	eb 03                	jmp    800a09 <strtol+0x11>
		s++;
  800a06:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a09:	0f b6 01             	movzbl (%ecx),%eax
  800a0c:	3c 20                	cmp    $0x20,%al
  800a0e:	74 f6                	je     800a06 <strtol+0xe>
  800a10:	3c 09                	cmp    $0x9,%al
  800a12:	74 f2                	je     800a06 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a14:	3c 2b                	cmp    $0x2b,%al
  800a16:	75 0a                	jne    800a22 <strtol+0x2a>
		s++;
  800a18:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a20:	eb 11                	jmp    800a33 <strtol+0x3b>
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a27:	3c 2d                	cmp    $0x2d,%al
  800a29:	75 08                	jne    800a33 <strtol+0x3b>
		s++, neg = 1;
  800a2b:	83 c1 01             	add    $0x1,%ecx
  800a2e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a33:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a39:	75 15                	jne    800a50 <strtol+0x58>
  800a3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3e:	75 10                	jne    800a50 <strtol+0x58>
  800a40:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a44:	75 7c                	jne    800ac2 <strtol+0xca>
		s += 2, base = 16;
  800a46:	83 c1 02             	add    $0x2,%ecx
  800a49:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4e:	eb 16                	jmp    800a66 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a50:	85 db                	test   %ebx,%ebx
  800a52:	75 12                	jne    800a66 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a54:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a59:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5c:	75 08                	jne    800a66 <strtol+0x6e>
		s++, base = 8;
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6e:	0f b6 11             	movzbl (%ecx),%edx
  800a71:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 09             	cmp    $0x9,%bl
  800a79:	77 08                	ja     800a83 <strtol+0x8b>
			dig = *s - '0';
  800a7b:	0f be d2             	movsbl %dl,%edx
  800a7e:	83 ea 30             	sub    $0x30,%edx
  800a81:	eb 22                	jmp    800aa5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a83:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 19             	cmp    $0x19,%bl
  800a8b:	77 08                	ja     800a95 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 57             	sub    $0x57,%edx
  800a93:	eb 10                	jmp    800aa5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a95:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 19             	cmp    $0x19,%bl
  800a9d:	77 16                	ja     800ab5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a9f:	0f be d2             	movsbl %dl,%edx
  800aa2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa8:	7d 0b                	jge    800ab5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aaa:	83 c1 01             	add    $0x1,%ecx
  800aad:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab3:	eb b9                	jmp    800a6e <strtol+0x76>

	if (endptr)
  800ab5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab9:	74 0d                	je     800ac8 <strtol+0xd0>
		*endptr = (char *) s;
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	89 0e                	mov    %ecx,(%esi)
  800ac0:	eb 06                	jmp    800ac8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac2:	85 db                	test   %ebx,%ebx
  800ac4:	74 98                	je     800a5e <strtol+0x66>
  800ac6:	eb 9e                	jmp    800a66 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac8:	89 c2                	mov    %eax,%edx
  800aca:	f7 da                	neg    %edx
  800acc:	85 ff                	test   %edi,%edi
  800ace:	0f 45 c2             	cmovne %edx,%eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	89 c7                	mov    %eax,%edi
  800aeb:	89 c6                	mov    %eax,%esi
  800aed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aff:	b8 01 00 00 00       	mov    $0x1,%eax
  800b04:	89 d1                	mov    %edx,%ecx
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	89 d7                	mov    %edx,%edi
  800b0a:	89 d6                	mov    %edx,%esi
  800b0c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b21:	b8 03 00 00 00       	mov    $0x3,%eax
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	89 cb                	mov    %ecx,%ebx
  800b2b:	89 cf                	mov    %ecx,%edi
  800b2d:	89 ce                	mov    %ecx,%esi
  800b2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7e 17                	jle    800b4c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	50                   	push   %eax
  800b39:	6a 03                	push   $0x3
  800b3b:	68 df 28 80 00       	push   $0x8028df
  800b40:	6a 23                	push   $0x23
  800b42:	68 fc 28 80 00       	push   $0x8028fc
  800b47:	e8 30 16 00 00       	call   80217c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b64:	89 d1                	mov    %edx,%ecx
  800b66:	89 d3                	mov    %edx,%ebx
  800b68:	89 d7                	mov    %edx,%edi
  800b6a:	89 d6                	mov    %edx,%esi
  800b6c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_yield>:

void
sys_yield(void)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b79:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b83:	89 d1                	mov    %edx,%ecx
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	89 d7                	mov    %edx,%edi
  800b89:	89 d6                	mov    %edx,%esi
  800b8b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	be 00 00 00 00       	mov    $0x0,%esi
  800ba0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bae:	89 f7                	mov    %esi,%edi
  800bb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	7e 17                	jle    800bcd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	50                   	push   %eax
  800bba:	6a 04                	push   $0x4
  800bbc:	68 df 28 80 00       	push   $0x8028df
  800bc1:	6a 23                	push   $0x23
  800bc3:	68 fc 28 80 00       	push   $0x8028fc
  800bc8:	e8 af 15 00 00       	call   80217c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b8 05 00 00 00       	mov    $0x5,%eax
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bef:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	7e 17                	jle    800c0f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	50                   	push   %eax
  800bfc:	6a 05                	push   $0x5
  800bfe:	68 df 28 80 00       	push   $0x8028df
  800c03:	6a 23                	push   $0x23
  800c05:	68 fc 28 80 00       	push   $0x8028fc
  800c0a:	e8 6d 15 00 00       	call   80217c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c25:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	89 df                	mov    %ebx,%edi
  800c32:	89 de                	mov    %ebx,%esi
  800c34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 06                	push   $0x6
  800c40:	68 df 28 80 00       	push   $0x8028df
  800c45:	6a 23                	push   $0x23
  800c47:	68 fc 28 80 00       	push   $0x8028fc
  800c4c:	e8 2b 15 00 00       	call   80217c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c67:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	89 df                	mov    %ebx,%edi
  800c74:	89 de                	mov    %ebx,%esi
  800c76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7e 17                	jle    800c93 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	83 ec 0c             	sub    $0xc,%esp
  800c7f:	50                   	push   %eax
  800c80:	6a 08                	push   $0x8
  800c82:	68 df 28 80 00       	push   $0x8028df
  800c87:	6a 23                	push   $0x23
  800c89:	68 fc 28 80 00       	push   $0x8028fc
  800c8e:	e8 e9 14 00 00       	call   80217c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 df                	mov    %ebx,%edi
  800cb6:	89 de                	mov    %ebx,%esi
  800cb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 17                	jle    800cd5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 09                	push   $0x9
  800cc4:	68 df 28 80 00       	push   $0x8028df
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 fc 28 80 00       	push   $0x8028fc
  800cd0:	e8 a7 14 00 00       	call   80217c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ceb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 df                	mov    %ebx,%edi
  800cf8:	89 de                	mov    %ebx,%esi
  800cfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7e 17                	jle    800d17 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	83 ec 0c             	sub    $0xc,%esp
  800d03:	50                   	push   %eax
  800d04:	6a 0a                	push   $0xa
  800d06:	68 df 28 80 00       	push   $0x8028df
  800d0b:	6a 23                	push   $0x23
  800d0d:	68 fc 28 80 00       	push   $0x8028fc
  800d12:	e8 65 14 00 00       	call   80217c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	be 00 00 00 00       	mov    $0x0,%esi
  800d2a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d50:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 cb                	mov    %ecx,%ebx
  800d5a:	89 cf                	mov    %ecx,%edi
  800d5c:	89 ce                	mov    %ecx,%esi
  800d5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7e 17                	jle    800d7b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 0d                	push   $0xd
  800d6a:	68 df 28 80 00       	push   $0x8028df
  800d6f:	6a 23                	push   $0x23
  800d71:	68 fc 28 80 00       	push   $0x8028fc
  800d76:	e8 01 14 00 00       	call   80217c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d93:	89 d1                	mov    %edx,%ecx
  800d95:	89 d3                	mov    %edx,%ebx
  800d97:	89 d7                	mov    %edx,%edi
  800d99:	89 d6                	mov    %edx,%esi
  800d9b:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dad:	b8 0f 00 00 00       	mov    $0xf,%eax
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	89 df                	mov    %ebx,%edi
  800dba:	89 de                	mov    %ebx,%esi
  800dbc:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800dcf:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800dd1:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800dd4:	83 3a 01             	cmpl   $0x1,(%edx)
  800dd7:	7e 09                	jle    800de2 <argstart+0x1f>
  800dd9:	ba b1 25 80 00       	mov    $0x8025b1,%edx
  800dde:	85 c9                	test   %ecx,%ecx
  800de0:	75 05                	jne    800de7 <argstart+0x24>
  800de2:	ba 00 00 00 00       	mov    $0x0,%edx
  800de7:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800dea:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <argnext>:

int
argnext(struct Argstate *args)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	53                   	push   %ebx
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dfd:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e04:	8b 43 08             	mov    0x8(%ebx),%eax
  800e07:	85 c0                	test   %eax,%eax
  800e09:	74 6f                	je     800e7a <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e0b:	80 38 00             	cmpb   $0x0,(%eax)
  800e0e:	75 4e                	jne    800e5e <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e10:	8b 0b                	mov    (%ebx),%ecx
  800e12:	83 39 01             	cmpl   $0x1,(%ecx)
  800e15:	74 55                	je     800e6c <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e17:	8b 53 04             	mov    0x4(%ebx),%edx
  800e1a:	8b 42 04             	mov    0x4(%edx),%eax
  800e1d:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e20:	75 4a                	jne    800e6c <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e22:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e26:	74 44                	je     800e6c <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e28:	83 c0 01             	add    $0x1,%eax
  800e2b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	8b 01                	mov    (%ecx),%eax
  800e33:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e3a:	50                   	push   %eax
  800e3b:	8d 42 08             	lea    0x8(%edx),%eax
  800e3e:	50                   	push   %eax
  800e3f:	83 c2 04             	add    $0x4,%edx
  800e42:	52                   	push   %edx
  800e43:	e8 d9 fa ff ff       	call   800921 <memmove>
		(*args->argc)--;
  800e48:	8b 03                	mov    (%ebx),%eax
  800e4a:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e4d:	8b 43 08             	mov    0x8(%ebx),%eax
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e56:	75 06                	jne    800e5e <argnext+0x6b>
  800e58:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e5c:	74 0e                	je     800e6c <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e5e:	8b 53 08             	mov    0x8(%ebx),%edx
  800e61:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e64:	83 c2 01             	add    $0x1,%edx
  800e67:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e6a:	eb 13                	jmp    800e7f <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e6c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e78:	eb 05                	jmp    800e7f <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	53                   	push   %ebx
  800e88:	83 ec 04             	sub    $0x4,%esp
  800e8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e8e:	8b 43 08             	mov    0x8(%ebx),%eax
  800e91:	85 c0                	test   %eax,%eax
  800e93:	74 58                	je     800eed <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e95:	80 38 00             	cmpb   $0x0,(%eax)
  800e98:	74 0c                	je     800ea6 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e9a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e9d:	c7 43 08 b1 25 80 00 	movl   $0x8025b1,0x8(%ebx)
  800ea4:	eb 42                	jmp    800ee8 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800ea6:	8b 13                	mov    (%ebx),%edx
  800ea8:	83 3a 01             	cmpl   $0x1,(%edx)
  800eab:	7e 2d                	jle    800eda <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800ead:	8b 43 04             	mov    0x4(%ebx),%eax
  800eb0:	8b 48 04             	mov    0x4(%eax),%ecx
  800eb3:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800eb6:	83 ec 04             	sub    $0x4,%esp
  800eb9:	8b 12                	mov    (%edx),%edx
  800ebb:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800ec2:	52                   	push   %edx
  800ec3:	8d 50 08             	lea    0x8(%eax),%edx
  800ec6:	52                   	push   %edx
  800ec7:	83 c0 04             	add    $0x4,%eax
  800eca:	50                   	push   %eax
  800ecb:	e8 51 fa ff ff       	call   800921 <memmove>
		(*args->argc)--;
  800ed0:	8b 03                	mov    (%ebx),%eax
  800ed2:	83 28 01             	subl   $0x1,(%eax)
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	eb 0e                	jmp    800ee8 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800eda:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800ee1:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ee8:	8b 43 0c             	mov    0xc(%ebx),%eax
  800eeb:	eb 05                	jmp    800ef2 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ef2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 08             	sub    $0x8,%esp
  800efd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f00:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f03:	89 d0                	mov    %edx,%eax
  800f05:	85 d2                	test   %edx,%edx
  800f07:	75 0c                	jne    800f15 <argvalue+0x1e>
  800f09:	83 ec 0c             	sub    $0xc,%esp
  800f0c:	51                   	push   %ecx
  800f0d:	e8 72 ff ff ff       	call   800e84 <argnextvalue>
  800f12:	83 c4 10             	add    $0x10,%esp
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1d:	05 00 00 00 30       	add    $0x30000000,%eax
  800f22:	c1 e8 0c             	shr    $0xc,%eax
}
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2d:	05 00 00 00 30       	add    $0x30000000,%eax
  800f32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f37:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f44:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f49:	89 c2                	mov    %eax,%edx
  800f4b:	c1 ea 16             	shr    $0x16,%edx
  800f4e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f55:	f6 c2 01             	test   $0x1,%dl
  800f58:	74 11                	je     800f6b <fd_alloc+0x2d>
  800f5a:	89 c2                	mov    %eax,%edx
  800f5c:	c1 ea 0c             	shr    $0xc,%edx
  800f5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f66:	f6 c2 01             	test   $0x1,%dl
  800f69:	75 09                	jne    800f74 <fd_alloc+0x36>
			*fd_store = fd;
  800f6b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f72:	eb 17                	jmp    800f8b <fd_alloc+0x4d>
  800f74:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f79:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f7e:	75 c9                	jne    800f49 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f80:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f86:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f93:	83 f8 1f             	cmp    $0x1f,%eax
  800f96:	77 36                	ja     800fce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f98:	c1 e0 0c             	shl    $0xc,%eax
  800f9b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa0:	89 c2                	mov    %eax,%edx
  800fa2:	c1 ea 16             	shr    $0x16,%edx
  800fa5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fac:	f6 c2 01             	test   $0x1,%dl
  800faf:	74 24                	je     800fd5 <fd_lookup+0x48>
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	c1 ea 0c             	shr    $0xc,%edx
  800fb6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbd:	f6 c2 01             	test   $0x1,%dl
  800fc0:	74 1a                	je     800fdc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc5:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcc:	eb 13                	jmp    800fe1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd3:	eb 0c                	jmp    800fe1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fda:	eb 05                	jmp    800fe1 <fd_lookup+0x54>
  800fdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 08             	sub    $0x8,%esp
  800fe9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fec:	ba 88 29 80 00       	mov    $0x802988,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff1:	eb 13                	jmp    801006 <dev_lookup+0x23>
  800ff3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ff6:	39 08                	cmp    %ecx,(%eax)
  800ff8:	75 0c                	jne    801006 <dev_lookup+0x23>
			*dev = devtab[i];
  800ffa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fff:	b8 00 00 00 00       	mov    $0x0,%eax
  801004:	eb 2e                	jmp    801034 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801006:	8b 02                	mov    (%edx),%eax
  801008:	85 c0                	test   %eax,%eax
  80100a:	75 e7                	jne    800ff3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80100c:	a1 08 40 80 00       	mov    0x804008,%eax
  801011:	8b 40 48             	mov    0x48(%eax),%eax
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	51                   	push   %ecx
  801018:	50                   	push   %eax
  801019:	68 0c 29 80 00       	push   $0x80290c
  80101e:	e8 e7 f1 ff ff       	call   80020a <cprintf>
	*dev = 0;
  801023:	8b 45 0c             	mov    0xc(%ebp),%eax
  801026:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	83 ec 10             	sub    $0x10,%esp
  80103e:	8b 75 08             	mov    0x8(%ebp),%esi
  801041:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801044:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801047:	50                   	push   %eax
  801048:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80104e:	c1 e8 0c             	shr    $0xc,%eax
  801051:	50                   	push   %eax
  801052:	e8 36 ff ff ff       	call   800f8d <fd_lookup>
  801057:	83 c4 08             	add    $0x8,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 05                	js     801063 <fd_close+0x2d>
	    || fd != fd2)
  80105e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801061:	74 0c                	je     80106f <fd_close+0x39>
		return (must_exist ? r : 0);
  801063:	84 db                	test   %bl,%bl
  801065:	ba 00 00 00 00       	mov    $0x0,%edx
  80106a:	0f 44 c2             	cmove  %edx,%eax
  80106d:	eb 41                	jmp    8010b0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	ff 36                	pushl  (%esi)
  801078:	e8 66 ff ff ff       	call   800fe3 <dev_lookup>
  80107d:	89 c3                	mov    %eax,%ebx
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 1a                	js     8010a0 <fd_close+0x6a>
		if (dev->dev_close)
  801086:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801089:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801091:	85 c0                	test   %eax,%eax
  801093:	74 0b                	je     8010a0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	56                   	push   %esi
  801099:	ff d0                	call   *%eax
  80109b:	89 c3                	mov    %eax,%ebx
  80109d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	56                   	push   %esi
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 6c fb ff ff       	call   800c17 <sys_page_unmap>
	return r;
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	89 d8                	mov    %ebx,%eax
}
  8010b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	e8 c4 fe ff ff       	call   800f8d <fd_lookup>
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 10                	js     8010e0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010d0:	83 ec 08             	sub    $0x8,%esp
  8010d3:	6a 01                	push   $0x1
  8010d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d8:	e8 59 ff ff ff       	call   801036 <fd_close>
  8010dd:	83 c4 10             	add    $0x10,%esp
}
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <close_all>:

void
close_all(void)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ee:	83 ec 0c             	sub    $0xc,%esp
  8010f1:	53                   	push   %ebx
  8010f2:	e8 c0 ff ff ff       	call   8010b7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010f7:	83 c3 01             	add    $0x1,%ebx
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	83 fb 20             	cmp    $0x20,%ebx
  801100:	75 ec                	jne    8010ee <close_all+0xc>
		close(i);
}
  801102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 2c             	sub    $0x2c,%esp
  801110:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801113:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	ff 75 08             	pushl  0x8(%ebp)
  80111a:	e8 6e fe ff ff       	call   800f8d <fd_lookup>
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	0f 88 c1 00 00 00    	js     8011eb <dup+0xe4>
		return r;
	close(newfdnum);
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	56                   	push   %esi
  80112e:	e8 84 ff ff ff       	call   8010b7 <close>

	newfd = INDEX2FD(newfdnum);
  801133:	89 f3                	mov    %esi,%ebx
  801135:	c1 e3 0c             	shl    $0xc,%ebx
  801138:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80113e:	83 c4 04             	add    $0x4,%esp
  801141:	ff 75 e4             	pushl  -0x1c(%ebp)
  801144:	e8 de fd ff ff       	call   800f27 <fd2data>
  801149:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80114b:	89 1c 24             	mov    %ebx,(%esp)
  80114e:	e8 d4 fd ff ff       	call   800f27 <fd2data>
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801159:	89 f8                	mov    %edi,%eax
  80115b:	c1 e8 16             	shr    $0x16,%eax
  80115e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801165:	a8 01                	test   $0x1,%al
  801167:	74 37                	je     8011a0 <dup+0x99>
  801169:	89 f8                	mov    %edi,%eax
  80116b:	c1 e8 0c             	shr    $0xc,%eax
  80116e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801175:	f6 c2 01             	test   $0x1,%dl
  801178:	74 26                	je     8011a0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	25 07 0e 00 00       	and    $0xe07,%eax
  801189:	50                   	push   %eax
  80118a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80118d:	6a 00                	push   $0x0
  80118f:	57                   	push   %edi
  801190:	6a 00                	push   $0x0
  801192:	e8 3e fa ff ff       	call   800bd5 <sys_page_map>
  801197:	89 c7                	mov    %eax,%edi
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 2e                	js     8011ce <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011a3:	89 d0                	mov    %edx,%eax
  8011a5:	c1 e8 0c             	shr    $0xc,%eax
  8011a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b7:	50                   	push   %eax
  8011b8:	53                   	push   %ebx
  8011b9:	6a 00                	push   $0x0
  8011bb:	52                   	push   %edx
  8011bc:	6a 00                	push   $0x0
  8011be:	e8 12 fa ff ff       	call   800bd5 <sys_page_map>
  8011c3:	89 c7                	mov    %eax,%edi
  8011c5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011c8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ca:	85 ff                	test   %edi,%edi
  8011cc:	79 1d                	jns    8011eb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	53                   	push   %ebx
  8011d2:	6a 00                	push   $0x0
  8011d4:	e8 3e fa ff ff       	call   800c17 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d9:	83 c4 08             	add    $0x8,%esp
  8011dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011df:	6a 00                	push   $0x0
  8011e1:	e8 31 fa ff ff       	call   800c17 <sys_page_unmap>
	return r;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	89 f8                	mov    %edi,%eax
}
  8011eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 14             	sub    $0x14,%esp
  8011fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801200:	50                   	push   %eax
  801201:	53                   	push   %ebx
  801202:	e8 86 fd ff ff       	call   800f8d <fd_lookup>
  801207:	83 c4 08             	add    $0x8,%esp
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	85 c0                	test   %eax,%eax
  80120e:	78 6d                	js     80127d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121a:	ff 30                	pushl  (%eax)
  80121c:	e8 c2 fd ff ff       	call   800fe3 <dev_lookup>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 4c                	js     801274 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801228:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80122b:	8b 42 08             	mov    0x8(%edx),%eax
  80122e:	83 e0 03             	and    $0x3,%eax
  801231:	83 f8 01             	cmp    $0x1,%eax
  801234:	75 21                	jne    801257 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801236:	a1 08 40 80 00       	mov    0x804008,%eax
  80123b:	8b 40 48             	mov    0x48(%eax),%eax
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	53                   	push   %ebx
  801242:	50                   	push   %eax
  801243:	68 4d 29 80 00       	push   $0x80294d
  801248:	e8 bd ef ff ff       	call   80020a <cprintf>
		return -E_INVAL;
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801255:	eb 26                	jmp    80127d <read+0x8a>
	}
	if (!dev->dev_read)
  801257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125a:	8b 40 08             	mov    0x8(%eax),%eax
  80125d:	85 c0                	test   %eax,%eax
  80125f:	74 17                	je     801278 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	ff 75 10             	pushl  0x10(%ebp)
  801267:	ff 75 0c             	pushl  0xc(%ebp)
  80126a:	52                   	push   %edx
  80126b:	ff d0                	call   *%eax
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	eb 09                	jmp    80127d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801274:	89 c2                	mov    %eax,%edx
  801276:	eb 05                	jmp    80127d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801278:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80127d:	89 d0                	mov    %edx,%eax
  80127f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801282:	c9                   	leave  
  801283:	c3                   	ret    

00801284 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	57                   	push   %edi
  801288:	56                   	push   %esi
  801289:	53                   	push   %ebx
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801290:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801293:	bb 00 00 00 00       	mov    $0x0,%ebx
  801298:	eb 21                	jmp    8012bb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	89 f0                	mov    %esi,%eax
  80129f:	29 d8                	sub    %ebx,%eax
  8012a1:	50                   	push   %eax
  8012a2:	89 d8                	mov    %ebx,%eax
  8012a4:	03 45 0c             	add    0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	57                   	push   %edi
  8012a9:	e8 45 ff ff ff       	call   8011f3 <read>
		if (m < 0)
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 10                	js     8012c5 <readn+0x41>
			return m;
		if (m == 0)
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	74 0a                	je     8012c3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b9:	01 c3                	add    %eax,%ebx
  8012bb:	39 f3                	cmp    %esi,%ebx
  8012bd:	72 db                	jb     80129a <readn+0x16>
  8012bf:	89 d8                	mov    %ebx,%eax
  8012c1:	eb 02                	jmp    8012c5 <readn+0x41>
  8012c3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 14             	sub    $0x14,%esp
  8012d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	53                   	push   %ebx
  8012dc:	e8 ac fc ff ff       	call   800f8d <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	89 c2                	mov    %eax,%edx
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 68                	js     801352 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	ff 30                	pushl  (%eax)
  8012f6:	e8 e8 fc ff ff       	call   800fe3 <dev_lookup>
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 47                	js     801349 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801309:	75 21                	jne    80132c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80130b:	a1 08 40 80 00       	mov    0x804008,%eax
  801310:	8b 40 48             	mov    0x48(%eax),%eax
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	53                   	push   %ebx
  801317:	50                   	push   %eax
  801318:	68 69 29 80 00       	push   $0x802969
  80131d:	e8 e8 ee ff ff       	call   80020a <cprintf>
		return -E_INVAL;
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132a:	eb 26                	jmp    801352 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80132c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132f:	8b 52 0c             	mov    0xc(%edx),%edx
  801332:	85 d2                	test   %edx,%edx
  801334:	74 17                	je     80134d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801336:	83 ec 04             	sub    $0x4,%esp
  801339:	ff 75 10             	pushl  0x10(%ebp)
  80133c:	ff 75 0c             	pushl  0xc(%ebp)
  80133f:	50                   	push   %eax
  801340:	ff d2                	call   *%edx
  801342:	89 c2                	mov    %eax,%edx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	eb 09                	jmp    801352 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	89 c2                	mov    %eax,%edx
  80134b:	eb 05                	jmp    801352 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80134d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801352:	89 d0                	mov    %edx,%eax
  801354:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <seek>:

int
seek(int fdnum, off_t offset)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801362:	50                   	push   %eax
  801363:	ff 75 08             	pushl  0x8(%ebp)
  801366:	e8 22 fc ff ff       	call   800f8d <fd_lookup>
  80136b:	83 c4 08             	add    $0x8,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 0e                	js     801380 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801372:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801375:	8b 55 0c             	mov    0xc(%ebp),%edx
  801378:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 14             	sub    $0x14,%esp
  801389:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	53                   	push   %ebx
  801391:	e8 f7 fb ff ff       	call   800f8d <fd_lookup>
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	89 c2                	mov    %eax,%edx
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 65                	js     801404 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	ff 30                	pushl  (%eax)
  8013ab:	e8 33 fc ff ff       	call   800fe3 <dev_lookup>
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 44                	js     8013fb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013be:	75 21                	jne    8013e1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c5:	8b 40 48             	mov    0x48(%eax),%eax
  8013c8:	83 ec 04             	sub    $0x4,%esp
  8013cb:	53                   	push   %ebx
  8013cc:	50                   	push   %eax
  8013cd:	68 2c 29 80 00       	push   $0x80292c
  8013d2:	e8 33 ee ff ff       	call   80020a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013df:	eb 23                	jmp    801404 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e4:	8b 52 18             	mov    0x18(%edx),%edx
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	74 14                	je     8013ff <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	ff 75 0c             	pushl  0xc(%ebp)
  8013f1:	50                   	push   %eax
  8013f2:	ff d2                	call   *%edx
  8013f4:	89 c2                	mov    %eax,%edx
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	eb 09                	jmp    801404 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fb:	89 c2                	mov    %eax,%edx
  8013fd:	eb 05                	jmp    801404 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801404:	89 d0                	mov    %edx,%eax
  801406:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 14             	sub    $0x14,%esp
  801412:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801415:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	ff 75 08             	pushl  0x8(%ebp)
  80141c:	e8 6c fb ff ff       	call   800f8d <fd_lookup>
  801421:	83 c4 08             	add    $0x8,%esp
  801424:	89 c2                	mov    %eax,%edx
  801426:	85 c0                	test   %eax,%eax
  801428:	78 58                	js     801482 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801430:	50                   	push   %eax
  801431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801434:	ff 30                	pushl  (%eax)
  801436:	e8 a8 fb ff ff       	call   800fe3 <dev_lookup>
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 37                	js     801479 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801442:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801445:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801449:	74 32                	je     80147d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80144b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80144e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801455:	00 00 00 
	stat->st_isdir = 0;
  801458:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80145f:	00 00 00 
	stat->st_dev = dev;
  801462:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	53                   	push   %ebx
  80146c:	ff 75 f0             	pushl  -0x10(%ebp)
  80146f:	ff 50 14             	call   *0x14(%eax)
  801472:	89 c2                	mov    %eax,%edx
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	eb 09                	jmp    801482 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801479:	89 c2                	mov    %eax,%edx
  80147b:	eb 05                	jmp    801482 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80147d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801482:	89 d0                	mov    %edx,%eax
  801484:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	6a 00                	push   $0x0
  801493:	ff 75 08             	pushl  0x8(%ebp)
  801496:	e8 e7 01 00 00       	call   801682 <open>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 1b                	js     8014bf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	ff 75 0c             	pushl  0xc(%ebp)
  8014aa:	50                   	push   %eax
  8014ab:	e8 5b ff ff ff       	call   80140b <fstat>
  8014b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b2:	89 1c 24             	mov    %ebx,(%esp)
  8014b5:	e8 fd fb ff ff       	call   8010b7 <close>
	return r;
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	89 f0                	mov    %esi,%eax
}
  8014bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c2:	5b                   	pop    %ebx
  8014c3:	5e                   	pop    %esi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
  8014cb:	89 c6                	mov    %eax,%esi
  8014cd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014cf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014d6:	75 12                	jne    8014ea <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	6a 01                	push   $0x1
  8014dd:	e8 a1 0d 00 00       	call   802283 <ipc_find_env>
  8014e2:	a3 00 40 80 00       	mov    %eax,0x804000
  8014e7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014ea:	6a 07                	push   $0x7
  8014ec:	68 00 50 80 00       	push   $0x805000
  8014f1:	56                   	push   %esi
  8014f2:	ff 35 00 40 80 00    	pushl  0x804000
  8014f8:	e8 32 0d 00 00       	call   80222f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014fd:	83 c4 0c             	add    $0xc,%esp
  801500:	6a 00                	push   $0x0
  801502:	53                   	push   %ebx
  801503:	6a 00                	push   $0x0
  801505:	e8 b8 0c 00 00       	call   8021c2 <ipc_recv>
}
  80150a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150d:	5b                   	pop    %ebx
  80150e:	5e                   	pop    %esi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801517:	8b 45 08             	mov    0x8(%ebp),%eax
  80151a:	8b 40 0c             	mov    0xc(%eax),%eax
  80151d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801522:	8b 45 0c             	mov    0xc(%ebp),%eax
  801525:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80152a:	ba 00 00 00 00       	mov    $0x0,%edx
  80152f:	b8 02 00 00 00       	mov    $0x2,%eax
  801534:	e8 8d ff ff ff       	call   8014c6 <fsipc>
}
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801541:	8b 45 08             	mov    0x8(%ebp),%eax
  801544:	8b 40 0c             	mov    0xc(%eax),%eax
  801547:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80154c:	ba 00 00 00 00       	mov    $0x0,%edx
  801551:	b8 06 00 00 00       	mov    $0x6,%eax
  801556:	e8 6b ff ff ff       	call   8014c6 <fsipc>
}
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	53                   	push   %ebx
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801567:	8b 45 08             	mov    0x8(%ebp),%eax
  80156a:	8b 40 0c             	mov    0xc(%eax),%eax
  80156d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 05 00 00 00       	mov    $0x5,%eax
  80157c:	e8 45 ff ff ff       	call   8014c6 <fsipc>
  801581:	85 c0                	test   %eax,%eax
  801583:	78 2c                	js     8015b1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	68 00 50 80 00       	push   $0x805000
  80158d:	53                   	push   %ebx
  80158e:	e8 fc f1 ff ff       	call   80078f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801593:	a1 80 50 80 00       	mov    0x805080,%eax
  801598:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80159e:	a1 84 50 80 00       	mov    0x805084,%eax
  8015a3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8015c0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015c5:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8015ca:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015cd:	53                   	push   %ebx
  8015ce:	ff 75 0c             	pushl  0xc(%ebp)
  8015d1:	68 08 50 80 00       	push   $0x805008
  8015d6:	e8 46 f3 ff ff       	call   800921 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015db:	8b 45 08             	mov    0x8(%ebp),%eax
  8015de:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e1:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8015e6:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8015ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8015f6:	e8 cb fe ff ff       	call   8014c6 <fsipc>
	//panic("devfile_write not implemented");
}
  8015fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801608:	8b 45 08             	mov    0x8(%ebp),%eax
  80160b:	8b 40 0c             	mov    0xc(%eax),%eax
  80160e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801613:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801619:	ba 00 00 00 00       	mov    $0x0,%edx
  80161e:	b8 03 00 00 00       	mov    $0x3,%eax
  801623:	e8 9e fe ff ff       	call   8014c6 <fsipc>
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 4b                	js     801679 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80162e:	39 c6                	cmp    %eax,%esi
  801630:	73 16                	jae    801648 <devfile_read+0x48>
  801632:	68 9c 29 80 00       	push   $0x80299c
  801637:	68 a3 29 80 00       	push   $0x8029a3
  80163c:	6a 7c                	push   $0x7c
  80163e:	68 b8 29 80 00       	push   $0x8029b8
  801643:	e8 34 0b 00 00       	call   80217c <_panic>
	assert(r <= PGSIZE);
  801648:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80164d:	7e 16                	jle    801665 <devfile_read+0x65>
  80164f:	68 c3 29 80 00       	push   $0x8029c3
  801654:	68 a3 29 80 00       	push   $0x8029a3
  801659:	6a 7d                	push   $0x7d
  80165b:	68 b8 29 80 00       	push   $0x8029b8
  801660:	e8 17 0b 00 00       	call   80217c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801665:	83 ec 04             	sub    $0x4,%esp
  801668:	50                   	push   %eax
  801669:	68 00 50 80 00       	push   $0x805000
  80166e:	ff 75 0c             	pushl  0xc(%ebp)
  801671:	e8 ab f2 ff ff       	call   800921 <memmove>
	return r;
  801676:	83 c4 10             	add    $0x10,%esp
}
  801679:	89 d8                	mov    %ebx,%eax
  80167b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 20             	sub    $0x20,%esp
  801689:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80168c:	53                   	push   %ebx
  80168d:	e8 c4 f0 ff ff       	call   800756 <strlen>
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80169a:	7f 67                	jg     801703 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80169c:	83 ec 0c             	sub    $0xc,%esp
  80169f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	e8 96 f8 ff ff       	call   800f3e <fd_alloc>
  8016a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8016ab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 57                	js     801708 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	53                   	push   %ebx
  8016b5:	68 00 50 80 00       	push   $0x805000
  8016ba:	e8 d0 f0 ff ff       	call   80078f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8016cf:	e8 f2 fd ff ff       	call   8014c6 <fsipc>
  8016d4:	89 c3                	mov    %eax,%ebx
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	79 14                	jns    8016f1 <open+0x6f>
		fd_close(fd, 0);
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	6a 00                	push   $0x0
  8016e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e5:	e8 4c f9 ff ff       	call   801036 <fd_close>
		return r;
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	89 da                	mov    %ebx,%edx
  8016ef:	eb 17                	jmp    801708 <open+0x86>
	}

	return fd2num(fd);
  8016f1:	83 ec 0c             	sub    $0xc,%esp
  8016f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f7:	e8 1b f8 ff ff       	call   800f17 <fd2num>
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	eb 05                	jmp    801708 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801703:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801708:	89 d0                	mov    %edx,%eax
  80170a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801715:	ba 00 00 00 00       	mov    $0x0,%edx
  80171a:	b8 08 00 00 00       	mov    $0x8,%eax
  80171f:	e8 a2 fd ff ff       	call   8014c6 <fsipc>
}
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801726:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80172a:	7e 37                	jle    801763 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	53                   	push   %ebx
  801730:	83 ec 08             	sub    $0x8,%esp
  801733:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801735:	ff 70 04             	pushl  0x4(%eax)
  801738:	8d 40 10             	lea    0x10(%eax),%eax
  80173b:	50                   	push   %eax
  80173c:	ff 33                	pushl  (%ebx)
  80173e:	e8 8a fb ff ff       	call   8012cd <write>
		if (result > 0)
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	7e 03                	jle    80174d <writebuf+0x27>
			b->result += result;
  80174a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80174d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801750:	74 0d                	je     80175f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801752:	85 c0                	test   %eax,%eax
  801754:	ba 00 00 00 00       	mov    $0x0,%edx
  801759:	0f 4f c2             	cmovg  %edx,%eax
  80175c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80175f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801762:	c9                   	leave  
  801763:	f3 c3                	repz ret 

00801765 <putch>:

static void
putch(int ch, void *thunk)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	53                   	push   %ebx
  801769:	83 ec 04             	sub    $0x4,%esp
  80176c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80176f:	8b 53 04             	mov    0x4(%ebx),%edx
  801772:	8d 42 01             	lea    0x1(%edx),%eax
  801775:	89 43 04             	mov    %eax,0x4(%ebx)
  801778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80177f:	3d 00 01 00 00       	cmp    $0x100,%eax
  801784:	75 0e                	jne    801794 <putch+0x2f>
		writebuf(b);
  801786:	89 d8                	mov    %ebx,%eax
  801788:	e8 99 ff ff ff       	call   801726 <writebuf>
		b->idx = 0;
  80178d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801794:	83 c4 04             	add    $0x4,%esp
  801797:	5b                   	pop    %ebx
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a6:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017ac:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017b3:	00 00 00 
	b.result = 0;
  8017b6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017bd:	00 00 00 
	b.error = 1;
  8017c0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017c7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017ca:	ff 75 10             	pushl  0x10(%ebp)
  8017cd:	ff 75 0c             	pushl  0xc(%ebp)
  8017d0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	68 65 17 80 00       	push   $0x801765
  8017dc:	e8 60 eb ff ff       	call   800341 <vprintfmt>
	if (b.idx > 0)
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017eb:	7e 0b                	jle    8017f8 <vfprintf+0x5e>
		writebuf(&b);
  8017ed:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017f3:	e8 2e ff ff ff       	call   801726 <writebuf>

	return (b.result ? b.result : b.error);
  8017f8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017fe:	85 c0                	test   %eax,%eax
  801800:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80180f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801812:	50                   	push   %eax
  801813:	ff 75 0c             	pushl  0xc(%ebp)
  801816:	ff 75 08             	pushl  0x8(%ebp)
  801819:	e8 7c ff ff ff       	call   80179a <vfprintf>
	va_end(ap);

	return cnt;
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <printf>:

int
printf(const char *fmt, ...)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801826:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801829:	50                   	push   %eax
  80182a:	ff 75 08             	pushl  0x8(%ebp)
  80182d:	6a 01                	push   $0x1
  80182f:	e8 66 ff ff ff       	call   80179a <vfprintf>
	va_end(ap);

	return cnt;
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80183c:	68 cf 29 80 00       	push   $0x8029cf
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	e8 46 ef ff ff       	call   80078f <strcpy>
	return 0;
}
  801849:	b8 00 00 00 00       	mov    $0x0,%eax
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	53                   	push   %ebx
  801854:	83 ec 10             	sub    $0x10,%esp
  801857:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80185a:	53                   	push   %ebx
  80185b:	e8 5c 0a 00 00       	call   8022bc <pageref>
  801860:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801863:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801868:	83 f8 01             	cmp    $0x1,%eax
  80186b:	75 10                	jne    80187d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	ff 73 0c             	pushl  0xc(%ebx)
  801873:	e8 c0 02 00 00       	call   801b38 <nsipc_close>
  801878:	89 c2                	mov    %eax,%edx
  80187a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80187d:	89 d0                	mov    %edx,%eax
  80187f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80188a:	6a 00                	push   $0x0
  80188c:	ff 75 10             	pushl  0x10(%ebp)
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	ff 70 0c             	pushl  0xc(%eax)
  801898:	e8 78 03 00 00       	call   801c15 <nsipc_send>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018a5:	6a 00                	push   $0x0
  8018a7:	ff 75 10             	pushl  0x10(%ebp)
  8018aa:	ff 75 0c             	pushl  0xc(%ebp)
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	ff 70 0c             	pushl  0xc(%eax)
  8018b3:	e8 f1 02 00 00       	call   801ba9 <nsipc_recv>
}
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018c0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018c3:	52                   	push   %edx
  8018c4:	50                   	push   %eax
  8018c5:	e8 c3 f6 ff ff       	call   800f8d <fd_lookup>
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 17                	js     8018e8 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d4:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018da:	39 08                	cmp    %ecx,(%eax)
  8018dc:	75 05                	jne    8018e3 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018de:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e1:	eb 05                	jmp    8018e8 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	56                   	push   %esi
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 1c             	sub    $0x1c,%esp
  8018f2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f7:	50                   	push   %eax
  8018f8:	e8 41 f6 ff ff       	call   800f3e <fd_alloc>
  8018fd:	89 c3                	mov    %eax,%ebx
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	85 c0                	test   %eax,%eax
  801904:	78 1b                	js     801921 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801906:	83 ec 04             	sub    $0x4,%esp
  801909:	68 07 04 00 00       	push   $0x407
  80190e:	ff 75 f4             	pushl  -0xc(%ebp)
  801911:	6a 00                	push   $0x0
  801913:	e8 7a f2 ff ff       	call   800b92 <sys_page_alloc>
  801918:	89 c3                	mov    %eax,%ebx
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	85 c0                	test   %eax,%eax
  80191f:	79 10                	jns    801931 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	56                   	push   %esi
  801925:	e8 0e 02 00 00       	call   801b38 <nsipc_close>
		return r;
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	89 d8                	mov    %ebx,%eax
  80192f:	eb 24                	jmp    801955 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801931:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801937:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80193c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801946:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801949:	83 ec 0c             	sub    $0xc,%esp
  80194c:	50                   	push   %eax
  80194d:	e8 c5 f5 ff ff       	call   800f17 <fd2num>
  801952:	83 c4 10             	add    $0x10,%esp
}
  801955:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	e8 50 ff ff ff       	call   8018ba <fd2sockid>
		return r;
  80196a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 1f                	js     80198f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801970:	83 ec 04             	sub    $0x4,%esp
  801973:	ff 75 10             	pushl  0x10(%ebp)
  801976:	ff 75 0c             	pushl  0xc(%ebp)
  801979:	50                   	push   %eax
  80197a:	e8 12 01 00 00       	call   801a91 <nsipc_accept>
  80197f:	83 c4 10             	add    $0x10,%esp
		return r;
  801982:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801984:	85 c0                	test   %eax,%eax
  801986:	78 07                	js     80198f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801988:	e8 5d ff ff ff       	call   8018ea <alloc_sockfd>
  80198d:	89 c1                	mov    %eax,%ecx
}
  80198f:	89 c8                	mov    %ecx,%eax
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	e8 19 ff ff ff       	call   8018ba <fd2sockid>
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 12                	js     8019b7 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019a5:	83 ec 04             	sub    $0x4,%esp
  8019a8:	ff 75 10             	pushl  0x10(%ebp)
  8019ab:	ff 75 0c             	pushl  0xc(%ebp)
  8019ae:	50                   	push   %eax
  8019af:	e8 2d 01 00 00       	call   801ae1 <nsipc_bind>
  8019b4:	83 c4 10             	add    $0x10,%esp
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <shutdown>:

int
shutdown(int s, int how)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	e8 f3 fe ff ff       	call   8018ba <fd2sockid>
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	78 0f                	js     8019da <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019cb:	83 ec 08             	sub    $0x8,%esp
  8019ce:	ff 75 0c             	pushl  0xc(%ebp)
  8019d1:	50                   	push   %eax
  8019d2:	e8 3f 01 00 00       	call   801b16 <nsipc_shutdown>
  8019d7:	83 c4 10             	add    $0x10,%esp
}
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e5:	e8 d0 fe ff ff       	call   8018ba <fd2sockid>
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 12                	js     801a00 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019ee:	83 ec 04             	sub    $0x4,%esp
  8019f1:	ff 75 10             	pushl  0x10(%ebp)
  8019f4:	ff 75 0c             	pushl  0xc(%ebp)
  8019f7:	50                   	push   %eax
  8019f8:	e8 55 01 00 00       	call   801b52 <nsipc_connect>
  8019fd:	83 c4 10             	add    $0x10,%esp
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <listen>:

int
listen(int s, int backlog)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a08:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0b:	e8 aa fe ff ff       	call   8018ba <fd2sockid>
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 0f                	js     801a23 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a14:	83 ec 08             	sub    $0x8,%esp
  801a17:	ff 75 0c             	pushl  0xc(%ebp)
  801a1a:	50                   	push   %eax
  801a1b:	e8 67 01 00 00       	call   801b87 <nsipc_listen>
  801a20:	83 c4 10             	add    $0x10,%esp
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a2b:	ff 75 10             	pushl  0x10(%ebp)
  801a2e:	ff 75 0c             	pushl  0xc(%ebp)
  801a31:	ff 75 08             	pushl  0x8(%ebp)
  801a34:	e8 3a 02 00 00       	call   801c73 <nsipc_socket>
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 05                	js     801a45 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a40:	e8 a5 fe ff ff       	call   8018ea <alloc_sockfd>
}
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a50:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a57:	75 12                	jne    801a6b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	6a 02                	push   $0x2
  801a5e:	e8 20 08 00 00       	call   802283 <ipc_find_env>
  801a63:	a3 04 40 80 00       	mov    %eax,0x804004
  801a68:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a6b:	6a 07                	push   $0x7
  801a6d:	68 00 60 80 00       	push   $0x806000
  801a72:	53                   	push   %ebx
  801a73:	ff 35 04 40 80 00    	pushl  0x804004
  801a79:	e8 b1 07 00 00       	call   80222f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a7e:	83 c4 0c             	add    $0xc,%esp
  801a81:	6a 00                	push   $0x0
  801a83:	6a 00                	push   $0x0
  801a85:	6a 00                	push   $0x0
  801a87:	e8 36 07 00 00       	call   8021c2 <ipc_recv>
}
  801a8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a99:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801aa1:	8b 06                	mov    (%esi),%eax
  801aa3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aa8:	b8 01 00 00 00       	mov    $0x1,%eax
  801aad:	e8 95 ff ff ff       	call   801a47 <nsipc>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	78 20                	js     801ad8 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ab8:	83 ec 04             	sub    $0x4,%esp
  801abb:	ff 35 10 60 80 00    	pushl  0x806010
  801ac1:	68 00 60 80 00       	push   $0x806000
  801ac6:	ff 75 0c             	pushl  0xc(%ebp)
  801ac9:	e8 53 ee ff ff       	call   800921 <memmove>
		*addrlen = ret->ret_addrlen;
  801ace:	a1 10 60 80 00       	mov    0x806010,%eax
  801ad3:	89 06                	mov    %eax,(%esi)
  801ad5:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ad8:	89 d8                	mov    %ebx,%eax
  801ada:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 08             	sub    $0x8,%esp
  801ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801af3:	53                   	push   %ebx
  801af4:	ff 75 0c             	pushl  0xc(%ebp)
  801af7:	68 04 60 80 00       	push   $0x806004
  801afc:	e8 20 ee ff ff       	call   800921 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b01:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b07:	b8 02 00 00 00       	mov    $0x2,%eax
  801b0c:	e8 36 ff ff ff       	call   801a47 <nsipc>
}
  801b11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b27:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b2c:	b8 03 00 00 00       	mov    $0x3,%eax
  801b31:	e8 11 ff ff ff       	call   801a47 <nsipc>
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <nsipc_close>:

int
nsipc_close(int s)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b46:	b8 04 00 00 00       	mov    $0x4,%eax
  801b4b:	e8 f7 fe ff ff       	call   801a47 <nsipc>
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b64:	53                   	push   %ebx
  801b65:	ff 75 0c             	pushl  0xc(%ebp)
  801b68:	68 04 60 80 00       	push   $0x806004
  801b6d:	e8 af ed ff ff       	call   800921 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b72:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b78:	b8 05 00 00 00       	mov    $0x5,%eax
  801b7d:	e8 c5 fe ff ff       	call   801a47 <nsipc>
}
  801b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b98:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b9d:	b8 06 00 00 00       	mov    $0x6,%eax
  801ba2:	e8 a0 fe ff ff       	call   801a47 <nsipc>
}
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	56                   	push   %esi
  801bad:	53                   	push   %ebx
  801bae:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bb9:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bbf:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc2:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bc7:	b8 07 00 00 00       	mov    $0x7,%eax
  801bcc:	e8 76 fe ff ff       	call   801a47 <nsipc>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	78 35                	js     801c0c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bd7:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bdc:	7f 04                	jg     801be2 <nsipc_recv+0x39>
  801bde:	39 c6                	cmp    %eax,%esi
  801be0:	7d 16                	jge    801bf8 <nsipc_recv+0x4f>
  801be2:	68 db 29 80 00       	push   $0x8029db
  801be7:	68 a3 29 80 00       	push   $0x8029a3
  801bec:	6a 62                	push   $0x62
  801bee:	68 f0 29 80 00       	push   $0x8029f0
  801bf3:	e8 84 05 00 00       	call   80217c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bf8:	83 ec 04             	sub    $0x4,%esp
  801bfb:	50                   	push   %eax
  801bfc:	68 00 60 80 00       	push   $0x806000
  801c01:	ff 75 0c             	pushl  0xc(%ebp)
  801c04:	e8 18 ed ff ff       	call   800921 <memmove>
  801c09:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5e                   	pop    %esi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	53                   	push   %ebx
  801c19:	83 ec 04             	sub    $0x4,%esp
  801c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c22:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c27:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c2d:	7e 16                	jle    801c45 <nsipc_send+0x30>
  801c2f:	68 fc 29 80 00       	push   $0x8029fc
  801c34:	68 a3 29 80 00       	push   $0x8029a3
  801c39:	6a 6d                	push   $0x6d
  801c3b:	68 f0 29 80 00       	push   $0x8029f0
  801c40:	e8 37 05 00 00       	call   80217c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c45:	83 ec 04             	sub    $0x4,%esp
  801c48:	53                   	push   %ebx
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	68 0c 60 80 00       	push   $0x80600c
  801c51:	e8 cb ec ff ff       	call   800921 <memmove>
	nsipcbuf.send.req_size = size;
  801c56:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c5c:	8b 45 14             	mov    0x14(%ebp),%eax
  801c5f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c64:	b8 08 00 00 00       	mov    $0x8,%eax
  801c69:	e8 d9 fd ff ff       	call   801a47 <nsipc>
}
  801c6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c79:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c84:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c89:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c91:	b8 09 00 00 00       	mov    $0x9,%eax
  801c96:	e8 ac fd ff ff       	call   801a47 <nsipc>
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ca5:	83 ec 0c             	sub    $0xc,%esp
  801ca8:	ff 75 08             	pushl  0x8(%ebp)
  801cab:	e8 77 f2 ff ff       	call   800f27 <fd2data>
  801cb0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cb2:	83 c4 08             	add    $0x8,%esp
  801cb5:	68 08 2a 80 00       	push   $0x802a08
  801cba:	53                   	push   %ebx
  801cbb:	e8 cf ea ff ff       	call   80078f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc0:	8b 46 04             	mov    0x4(%esi),%eax
  801cc3:	2b 06                	sub    (%esi),%eax
  801cc5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ccb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cd2:	00 00 00 
	stat->st_dev = &devpipe;
  801cd5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cdc:	30 80 00 
	return 0;
}
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	53                   	push   %ebx
  801cef:	83 ec 0c             	sub    $0xc,%esp
  801cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cf5:	53                   	push   %ebx
  801cf6:	6a 00                	push   $0x0
  801cf8:	e8 1a ef ff ff       	call   800c17 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cfd:	89 1c 24             	mov    %ebx,(%esp)
  801d00:	e8 22 f2 ff ff       	call   800f27 <fd2data>
  801d05:	83 c4 08             	add    $0x8,%esp
  801d08:	50                   	push   %eax
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 07 ef ff ff       	call   800c17 <sys_page_unmap>
}
  801d10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	57                   	push   %edi
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
  801d1b:	83 ec 1c             	sub    $0x1c,%esp
  801d1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d21:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d23:	a1 08 40 80 00       	mov    0x804008,%eax
  801d28:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d2b:	83 ec 0c             	sub    $0xc,%esp
  801d2e:	ff 75 e0             	pushl  -0x20(%ebp)
  801d31:	e8 86 05 00 00       	call   8022bc <pageref>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	89 3c 24             	mov    %edi,(%esp)
  801d3b:	e8 7c 05 00 00       	call   8022bc <pageref>
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	39 c3                	cmp    %eax,%ebx
  801d45:	0f 94 c1             	sete   %cl
  801d48:	0f b6 c9             	movzbl %cl,%ecx
  801d4b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d4e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d54:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d57:	39 ce                	cmp    %ecx,%esi
  801d59:	74 1b                	je     801d76 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d5b:	39 c3                	cmp    %eax,%ebx
  801d5d:	75 c4                	jne    801d23 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d5f:	8b 42 58             	mov    0x58(%edx),%eax
  801d62:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d65:	50                   	push   %eax
  801d66:	56                   	push   %esi
  801d67:	68 0f 2a 80 00       	push   $0x802a0f
  801d6c:	e8 99 e4 ff ff       	call   80020a <cprintf>
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	eb ad                	jmp    801d23 <_pipeisclosed+0xe>
	}
}
  801d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    

00801d81 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	57                   	push   %edi
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
  801d87:	83 ec 28             	sub    $0x28,%esp
  801d8a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d8d:	56                   	push   %esi
  801d8e:	e8 94 f1 ff ff       	call   800f27 <fd2data>
  801d93:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9d:	eb 4b                	jmp    801dea <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d9f:	89 da                	mov    %ebx,%edx
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	e8 6d ff ff ff       	call   801d15 <_pipeisclosed>
  801da8:	85 c0                	test   %eax,%eax
  801daa:	75 48                	jne    801df4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dac:	e8 c2 ed ff ff       	call   800b73 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801db1:	8b 43 04             	mov    0x4(%ebx),%eax
  801db4:	8b 0b                	mov    (%ebx),%ecx
  801db6:	8d 51 20             	lea    0x20(%ecx),%edx
  801db9:	39 d0                	cmp    %edx,%eax
  801dbb:	73 e2                	jae    801d9f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dc4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dc7:	89 c2                	mov    %eax,%edx
  801dc9:	c1 fa 1f             	sar    $0x1f,%edx
  801dcc:	89 d1                	mov    %edx,%ecx
  801dce:	c1 e9 1b             	shr    $0x1b,%ecx
  801dd1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dd4:	83 e2 1f             	and    $0x1f,%edx
  801dd7:	29 ca                	sub    %ecx,%edx
  801dd9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ddd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801de1:	83 c0 01             	add    $0x1,%eax
  801de4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de7:	83 c7 01             	add    $0x1,%edi
  801dea:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ded:	75 c2                	jne    801db1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801def:	8b 45 10             	mov    0x10(%ebp),%eax
  801df2:	eb 05                	jmp    801df9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5f                   	pop    %edi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    

00801e01 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	57                   	push   %edi
  801e05:	56                   	push   %esi
  801e06:	53                   	push   %ebx
  801e07:	83 ec 18             	sub    $0x18,%esp
  801e0a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e0d:	57                   	push   %edi
  801e0e:	e8 14 f1 ff ff       	call   800f27 <fd2data>
  801e13:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e1d:	eb 3d                	jmp    801e5c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e1f:	85 db                	test   %ebx,%ebx
  801e21:	74 04                	je     801e27 <devpipe_read+0x26>
				return i;
  801e23:	89 d8                	mov    %ebx,%eax
  801e25:	eb 44                	jmp    801e6b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e27:	89 f2                	mov    %esi,%edx
  801e29:	89 f8                	mov    %edi,%eax
  801e2b:	e8 e5 fe ff ff       	call   801d15 <_pipeisclosed>
  801e30:	85 c0                	test   %eax,%eax
  801e32:	75 32                	jne    801e66 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e34:	e8 3a ed ff ff       	call   800b73 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e39:	8b 06                	mov    (%esi),%eax
  801e3b:	3b 46 04             	cmp    0x4(%esi),%eax
  801e3e:	74 df                	je     801e1f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e40:	99                   	cltd   
  801e41:	c1 ea 1b             	shr    $0x1b,%edx
  801e44:	01 d0                	add    %edx,%eax
  801e46:	83 e0 1f             	and    $0x1f,%eax
  801e49:	29 d0                	sub    %edx,%eax
  801e4b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e53:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e56:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e59:	83 c3 01             	add    $0x1,%ebx
  801e5c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e5f:	75 d8                	jne    801e39 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e61:	8b 45 10             	mov    0x10(%ebp),%eax
  801e64:	eb 05                	jmp    801e6b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e66:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e6e:	5b                   	pop    %ebx
  801e6f:	5e                   	pop    %esi
  801e70:	5f                   	pop    %edi
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    

00801e73 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7e:	50                   	push   %eax
  801e7f:	e8 ba f0 ff ff       	call   800f3e <fd_alloc>
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	89 c2                	mov    %eax,%edx
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	0f 88 2c 01 00 00    	js     801fbd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e91:	83 ec 04             	sub    $0x4,%esp
  801e94:	68 07 04 00 00       	push   $0x407
  801e99:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9c:	6a 00                	push   $0x0
  801e9e:	e8 ef ec ff ff       	call   800b92 <sys_page_alloc>
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	89 c2                	mov    %eax,%edx
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	0f 88 0d 01 00 00    	js     801fbd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eb0:	83 ec 0c             	sub    $0xc,%esp
  801eb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb6:	50                   	push   %eax
  801eb7:	e8 82 f0 ff ff       	call   800f3e <fd_alloc>
  801ebc:	89 c3                	mov    %eax,%ebx
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	0f 88 e2 00 00 00    	js     801fab <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec9:	83 ec 04             	sub    $0x4,%esp
  801ecc:	68 07 04 00 00       	push   $0x407
  801ed1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed4:	6a 00                	push   $0x0
  801ed6:	e8 b7 ec ff ff       	call   800b92 <sys_page_alloc>
  801edb:	89 c3                	mov    %eax,%ebx
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	0f 88 c3 00 00 00    	js     801fab <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ee8:	83 ec 0c             	sub    $0xc,%esp
  801eeb:	ff 75 f4             	pushl  -0xc(%ebp)
  801eee:	e8 34 f0 ff ff       	call   800f27 <fd2data>
  801ef3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef5:	83 c4 0c             	add    $0xc,%esp
  801ef8:	68 07 04 00 00       	push   $0x407
  801efd:	50                   	push   %eax
  801efe:	6a 00                	push   $0x0
  801f00:	e8 8d ec ff ff       	call   800b92 <sys_page_alloc>
  801f05:	89 c3                	mov    %eax,%ebx
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	0f 88 89 00 00 00    	js     801f9b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	ff 75 f0             	pushl  -0x10(%ebp)
  801f18:	e8 0a f0 ff ff       	call   800f27 <fd2data>
  801f1d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f24:	50                   	push   %eax
  801f25:	6a 00                	push   $0x0
  801f27:	56                   	push   %esi
  801f28:	6a 00                	push   $0x0
  801f2a:	e8 a6 ec ff ff       	call   800bd5 <sys_page_map>
  801f2f:	89 c3                	mov    %eax,%ebx
  801f31:	83 c4 20             	add    $0x20,%esp
  801f34:	85 c0                	test   %eax,%eax
  801f36:	78 55                	js     801f8d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f38:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f41:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f46:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f4d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f56:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f5b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f62:	83 ec 0c             	sub    $0xc,%esp
  801f65:	ff 75 f4             	pushl  -0xc(%ebp)
  801f68:	e8 aa ef ff ff       	call   800f17 <fd2num>
  801f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f70:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f72:	83 c4 04             	add    $0x4,%esp
  801f75:	ff 75 f0             	pushl  -0x10(%ebp)
  801f78:	e8 9a ef ff ff       	call   800f17 <fd2num>
  801f7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f80:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f83:	83 c4 10             	add    $0x10,%esp
  801f86:	ba 00 00 00 00       	mov    $0x0,%edx
  801f8b:	eb 30                	jmp    801fbd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f8d:	83 ec 08             	sub    $0x8,%esp
  801f90:	56                   	push   %esi
  801f91:	6a 00                	push   $0x0
  801f93:	e8 7f ec ff ff       	call   800c17 <sys_page_unmap>
  801f98:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f9b:	83 ec 08             	sub    $0x8,%esp
  801f9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa1:	6a 00                	push   $0x0
  801fa3:	e8 6f ec ff ff       	call   800c17 <sys_page_unmap>
  801fa8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fab:	83 ec 08             	sub    $0x8,%esp
  801fae:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb1:	6a 00                	push   $0x0
  801fb3:	e8 5f ec ff ff       	call   800c17 <sys_page_unmap>
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fbd:	89 d0                	mov    %edx,%eax
  801fbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc2:	5b                   	pop    %ebx
  801fc3:	5e                   	pop    %esi
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    

00801fc6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcf:	50                   	push   %eax
  801fd0:	ff 75 08             	pushl  0x8(%ebp)
  801fd3:	e8 b5 ef ff ff       	call   800f8d <fd_lookup>
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	78 18                	js     801ff7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fdf:	83 ec 0c             	sub    $0xc,%esp
  801fe2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe5:	e8 3d ef ff ff       	call   800f27 <fd2data>
	return _pipeisclosed(fd, p);
  801fea:	89 c2                	mov    %eax,%edx
  801fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fef:	e8 21 fd ff ff       	call   801d15 <_pipeisclosed>
  801ff4:	83 c4 10             	add    $0x10,%esp
}
  801ff7:	c9                   	leave  
  801ff8:	c3                   	ret    

00801ff9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  802001:	5d                   	pop    %ebp
  802002:	c3                   	ret    

00802003 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802009:	68 27 2a 80 00       	push   $0x802a27
  80200e:	ff 75 0c             	pushl  0xc(%ebp)
  802011:	e8 79 e7 ff ff       	call   80078f <strcpy>
	return 0;
}
  802016:	b8 00 00 00 00       	mov    $0x0,%eax
  80201b:	c9                   	leave  
  80201c:	c3                   	ret    

0080201d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	57                   	push   %edi
  802021:	56                   	push   %esi
  802022:	53                   	push   %ebx
  802023:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802029:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80202e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802034:	eb 2d                	jmp    802063 <devcons_write+0x46>
		m = n - tot;
  802036:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802039:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80203b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80203e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802043:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802046:	83 ec 04             	sub    $0x4,%esp
  802049:	53                   	push   %ebx
  80204a:	03 45 0c             	add    0xc(%ebp),%eax
  80204d:	50                   	push   %eax
  80204e:	57                   	push   %edi
  80204f:	e8 cd e8 ff ff       	call   800921 <memmove>
		sys_cputs(buf, m);
  802054:	83 c4 08             	add    $0x8,%esp
  802057:	53                   	push   %ebx
  802058:	57                   	push   %edi
  802059:	e8 78 ea ff ff       	call   800ad6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80205e:	01 de                	add    %ebx,%esi
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	89 f0                	mov    %esi,%eax
  802065:	3b 75 10             	cmp    0x10(%ebp),%esi
  802068:	72 cc                	jb     802036 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80206a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    

00802072 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	83 ec 08             	sub    $0x8,%esp
  802078:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80207d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802081:	74 2a                	je     8020ad <devcons_read+0x3b>
  802083:	eb 05                	jmp    80208a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802085:	e8 e9 ea ff ff       	call   800b73 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80208a:	e8 65 ea ff ff       	call   800af4 <sys_cgetc>
  80208f:	85 c0                	test   %eax,%eax
  802091:	74 f2                	je     802085 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802093:	85 c0                	test   %eax,%eax
  802095:	78 16                	js     8020ad <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802097:	83 f8 04             	cmp    $0x4,%eax
  80209a:	74 0c                	je     8020a8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80209c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80209f:	88 02                	mov    %al,(%edx)
	return 1;
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	eb 05                	jmp    8020ad <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020a8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020bb:	6a 01                	push   $0x1
  8020bd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c0:	50                   	push   %eax
  8020c1:	e8 10 ea ff ff       	call   800ad6 <sys_cputs>
}
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    

008020cb <getchar>:

int
getchar(void)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020d1:	6a 01                	push   $0x1
  8020d3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d6:	50                   	push   %eax
  8020d7:	6a 00                	push   $0x0
  8020d9:	e8 15 f1 ff ff       	call   8011f3 <read>
	if (r < 0)
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 0f                	js     8020f4 <getchar+0x29>
		return r;
	if (r < 1)
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	7e 06                	jle    8020ef <getchar+0x24>
		return -E_EOF;
	return c;
  8020e9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020ed:	eb 05                	jmp    8020f4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020ef:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020f4:	c9                   	leave  
  8020f5:	c3                   	ret    

008020f6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ff:	50                   	push   %eax
  802100:	ff 75 08             	pushl  0x8(%ebp)
  802103:	e8 85 ee ff ff       	call   800f8d <fd_lookup>
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	85 c0                	test   %eax,%eax
  80210d:	78 11                	js     802120 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80210f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802112:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802118:	39 10                	cmp    %edx,(%eax)
  80211a:	0f 94 c0             	sete   %al
  80211d:	0f b6 c0             	movzbl %al,%eax
}
  802120:	c9                   	leave  
  802121:	c3                   	ret    

00802122 <opencons>:

int
opencons(void)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802128:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212b:	50                   	push   %eax
  80212c:	e8 0d ee ff ff       	call   800f3e <fd_alloc>
  802131:	83 c4 10             	add    $0x10,%esp
		return r;
  802134:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802136:	85 c0                	test   %eax,%eax
  802138:	78 3e                	js     802178 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80213a:	83 ec 04             	sub    $0x4,%esp
  80213d:	68 07 04 00 00       	push   $0x407
  802142:	ff 75 f4             	pushl  -0xc(%ebp)
  802145:	6a 00                	push   $0x0
  802147:	e8 46 ea ff ff       	call   800b92 <sys_page_alloc>
  80214c:	83 c4 10             	add    $0x10,%esp
		return r;
  80214f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802151:	85 c0                	test   %eax,%eax
  802153:	78 23                	js     802178 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802155:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80215b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802160:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802163:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80216a:	83 ec 0c             	sub    $0xc,%esp
  80216d:	50                   	push   %eax
  80216e:	e8 a4 ed ff ff       	call   800f17 <fd2num>
  802173:	89 c2                	mov    %eax,%edx
  802175:	83 c4 10             	add    $0x10,%esp
}
  802178:	89 d0                	mov    %edx,%eax
  80217a:	c9                   	leave  
  80217b:	c3                   	ret    

0080217c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	56                   	push   %esi
  802180:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802181:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802184:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80218a:	e8 c5 e9 ff ff       	call   800b54 <sys_getenvid>
  80218f:	83 ec 0c             	sub    $0xc,%esp
  802192:	ff 75 0c             	pushl  0xc(%ebp)
  802195:	ff 75 08             	pushl  0x8(%ebp)
  802198:	56                   	push   %esi
  802199:	50                   	push   %eax
  80219a:	68 34 2a 80 00       	push   $0x802a34
  80219f:	e8 66 e0 ff ff       	call   80020a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021a4:	83 c4 18             	add    $0x18,%esp
  8021a7:	53                   	push   %ebx
  8021a8:	ff 75 10             	pushl  0x10(%ebp)
  8021ab:	e8 09 e0 ff ff       	call   8001b9 <vcprintf>
	cprintf("\n");
  8021b0:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  8021b7:	e8 4e e0 ff ff       	call   80020a <cprintf>
  8021bc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021bf:	cc                   	int3   
  8021c0:	eb fd                	jmp    8021bf <_panic+0x43>

008021c2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	56                   	push   %esi
  8021c6:	53                   	push   %ebx
  8021c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	74 0e                	je     8021e2 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8021d4:	83 ec 0c             	sub    $0xc,%esp
  8021d7:	50                   	push   %eax
  8021d8:	e8 65 eb ff ff       	call   800d42 <sys_ipc_recv>
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	eb 10                	jmp    8021f2 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8021e2:	83 ec 0c             	sub    $0xc,%esp
  8021e5:	68 00 00 00 f0       	push   $0xf0000000
  8021ea:	e8 53 eb ff ff       	call   800d42 <sys_ipc_recv>
  8021ef:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	74 0e                	je     802204 <ipc_recv+0x42>
    	*from_env_store = 0;
  8021f6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8021fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  802202:	eb 24                	jmp    802228 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  802204:	85 f6                	test   %esi,%esi
  802206:	74 0a                	je     802212 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802208:	a1 08 40 80 00       	mov    0x804008,%eax
  80220d:	8b 40 74             	mov    0x74(%eax),%eax
  802210:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802212:	85 db                	test   %ebx,%ebx
  802214:	74 0a                	je     802220 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802216:	a1 08 40 80 00       	mov    0x804008,%eax
  80221b:	8b 40 78             	mov    0x78(%eax),%eax
  80221e:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802220:	a1 08 40 80 00       	mov    0x804008,%eax
  802225:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802228:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222b:	5b                   	pop    %ebx
  80222c:	5e                   	pop    %esi
  80222d:	5d                   	pop    %ebp
  80222e:	c3                   	ret    

0080222f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	57                   	push   %edi
  802233:	56                   	push   %esi
  802234:	53                   	push   %ebx
  802235:	83 ec 0c             	sub    $0xc,%esp
  802238:	8b 7d 08             	mov    0x8(%ebp),%edi
  80223b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80223e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802241:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802243:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802248:	0f 44 d8             	cmove  %eax,%ebx
  80224b:	eb 1c                	jmp    802269 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80224d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802250:	74 12                	je     802264 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802252:	50                   	push   %eax
  802253:	68 58 2a 80 00       	push   $0x802a58
  802258:	6a 4b                	push   $0x4b
  80225a:	68 70 2a 80 00       	push   $0x802a70
  80225f:	e8 18 ff ff ff       	call   80217c <_panic>
        }	
        sys_yield();
  802264:	e8 0a e9 ff ff       	call   800b73 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802269:	ff 75 14             	pushl  0x14(%ebp)
  80226c:	53                   	push   %ebx
  80226d:	56                   	push   %esi
  80226e:	57                   	push   %edi
  80226f:	e8 ab ea ff ff       	call   800d1f <sys_ipc_try_send>
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	85 c0                	test   %eax,%eax
  802279:	75 d2                	jne    80224d <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80227b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5e                   	pop    %esi
  802280:	5f                   	pop    %edi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    

00802283 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802289:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80228e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802291:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802297:	8b 52 50             	mov    0x50(%edx),%edx
  80229a:	39 ca                	cmp    %ecx,%edx
  80229c:	75 0d                	jne    8022ab <ipc_find_env+0x28>
			return envs[i].env_id;
  80229e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022a6:	8b 40 48             	mov    0x48(%eax),%eax
  8022a9:	eb 0f                	jmp    8022ba <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ab:	83 c0 01             	add    $0x1,%eax
  8022ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022b3:	75 d9                	jne    80228e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    

008022bc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022bc:	55                   	push   %ebp
  8022bd:	89 e5                	mov    %esp,%ebp
  8022bf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c2:	89 d0                	mov    %edx,%eax
  8022c4:	c1 e8 16             	shr    $0x16,%eax
  8022c7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022ce:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d3:	f6 c1 01             	test   $0x1,%cl
  8022d6:	74 1d                	je     8022f5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022d8:	c1 ea 0c             	shr    $0xc,%edx
  8022db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022e2:	f6 c2 01             	test   $0x1,%dl
  8022e5:	74 0e                	je     8022f5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022e7:	c1 ea 0c             	shr    $0xc,%edx
  8022ea:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022f1:	ef 
  8022f2:	0f b7 c0             	movzwl %ax,%eax
}
  8022f5:	5d                   	pop    %ebp
  8022f6:	c3                   	ret    
  8022f7:	66 90                	xchg   %ax,%ax
  8022f9:	66 90                	xchg   %ax,%ax
  8022fb:	66 90                	xchg   %ax,%ax
  8022fd:	66 90                	xchg   %ax,%ax
  8022ff:	90                   	nop

00802300 <__udivdi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80230b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80230f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 f6                	test   %esi,%esi
  802319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	89 f8                	mov    %edi,%eax
  802321:	75 3d                	jne    802360 <__udivdi3+0x60>
  802323:	39 cf                	cmp    %ecx,%edi
  802325:	0f 87 c5 00 00 00    	ja     8023f0 <__udivdi3+0xf0>
  80232b:	85 ff                	test   %edi,%edi
  80232d:	89 fd                	mov    %edi,%ebp
  80232f:	75 0b                	jne    80233c <__udivdi3+0x3c>
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
  802336:	31 d2                	xor    %edx,%edx
  802338:	f7 f7                	div    %edi
  80233a:	89 c5                	mov    %eax,%ebp
  80233c:	89 c8                	mov    %ecx,%eax
  80233e:	31 d2                	xor    %edx,%edx
  802340:	f7 f5                	div    %ebp
  802342:	89 c1                	mov    %eax,%ecx
  802344:	89 d8                	mov    %ebx,%eax
  802346:	89 cf                	mov    %ecx,%edi
  802348:	f7 f5                	div    %ebp
  80234a:	89 c3                	mov    %eax,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	39 ce                	cmp    %ecx,%esi
  802362:	77 74                	ja     8023d8 <__udivdi3+0xd8>
  802364:	0f bd fe             	bsr    %esi,%edi
  802367:	83 f7 1f             	xor    $0x1f,%edi
  80236a:	0f 84 98 00 00 00    	je     802408 <__udivdi3+0x108>
  802370:	bb 20 00 00 00       	mov    $0x20,%ebx
  802375:	89 f9                	mov    %edi,%ecx
  802377:	89 c5                	mov    %eax,%ebp
  802379:	29 fb                	sub    %edi,%ebx
  80237b:	d3 e6                	shl    %cl,%esi
  80237d:	89 d9                	mov    %ebx,%ecx
  80237f:	d3 ed                	shr    %cl,%ebp
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e0                	shl    %cl,%eax
  802385:	09 ee                	or     %ebp,%esi
  802387:	89 d9                	mov    %ebx,%ecx
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 d5                	mov    %edx,%ebp
  80238f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e2                	shl    %cl,%edx
  802399:	89 d9                	mov    %ebx,%ecx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	09 c2                	or     %eax,%edx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	89 ea                	mov    %ebp,%edx
  8023a3:	f7 f6                	div    %esi
  8023a5:	89 d5                	mov    %edx,%ebp
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	72 10                	jb     8023c1 <__udivdi3+0xc1>
  8023b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e6                	shl    %cl,%esi
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	73 07                	jae    8023c4 <__udivdi3+0xc4>
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	75 03                	jne    8023c4 <__udivdi3+0xc4>
  8023c1:	83 eb 01             	sub    $0x1,%ebx
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	89 d8                	mov    %ebx,%eax
  8023c8:	89 fa                	mov    %edi,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 ff                	xor    %edi,%edi
  8023da:	31 db                	xor    %ebx,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	f7 f7                	div    %edi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 c3                	mov    %eax,%ebx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 fa                	mov    %edi,%edx
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 ce                	cmp    %ecx,%esi
  80240a:	72 0c                	jb     802418 <__udivdi3+0x118>
  80240c:	31 db                	xor    %ebx,%ebx
  80240e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802412:	0f 87 34 ff ff ff    	ja     80234c <__udivdi3+0x4c>
  802418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80241d:	e9 2a ff ff ff       	jmp    80234c <__udivdi3+0x4c>
  802422:	66 90                	xchg   %ax,%ax
  802424:	66 90                	xchg   %ax,%ax
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80243b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80243f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 d2                	test   %edx,%edx
  802449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f3                	mov    %esi,%ebx
  802453:	89 3c 24             	mov    %edi,(%esp)
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	75 1c                	jne    802478 <__umoddi3+0x48>
  80245c:	39 f7                	cmp    %esi,%edi
  80245e:	76 50                	jbe    8024b0 <__umoddi3+0x80>
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	f7 f7                	div    %edi
  802466:	89 d0                	mov    %edx,%eax
  802468:	31 d2                	xor    %edx,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	77 52                	ja     8024d0 <__umoddi3+0xa0>
  80247e:	0f bd ea             	bsr    %edx,%ebp
  802481:	83 f5 1f             	xor    $0x1f,%ebp
  802484:	75 5a                	jne    8024e0 <__umoddi3+0xb0>
  802486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	39 0c 24             	cmp    %ecx,(%esp)
  802493:	0f 86 d7 00 00 00    	jbe    802570 <__umoddi3+0x140>
  802499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80249d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	85 ff                	test   %edi,%edi
  8024b2:	89 fd                	mov    %edi,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 c8                	mov    %ecx,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	eb 99                	jmp    802468 <__umoddi3+0x38>
  8024cf:	90                   	nop
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	83 c4 1c             	add    $0x1c,%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	8b 34 24             	mov    (%esp),%esi
  8024e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	29 ef                	sub    %ebp,%edi
  8024ec:	d3 e0                	shl    %cl,%eax
  8024ee:	89 f9                	mov    %edi,%ecx
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	d3 ea                	shr    %cl,%edx
  8024f4:	89 e9                	mov    %ebp,%ecx
  8024f6:	09 c2                	or     %eax,%edx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 14 24             	mov    %edx,(%esp)
  8024fd:	89 f2                	mov    %esi,%edx
  8024ff:	d3 e2                	shl    %cl,%edx
  802501:	89 f9                	mov    %edi,%ecx
  802503:	89 54 24 04          	mov    %edx,0x4(%esp)
  802507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	89 c6                	mov    %eax,%esi
  802511:	d3 e3                	shl    %cl,%ebx
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 d0                	mov    %edx,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	09 d8                	or     %ebx,%eax
  80251d:	89 d3                	mov    %edx,%ebx
  80251f:	89 f2                	mov    %esi,%edx
  802521:	f7 34 24             	divl   (%esp)
  802524:	89 d6                	mov    %edx,%esi
  802526:	d3 e3                	shl    %cl,%ebx
  802528:	f7 64 24 04          	mull   0x4(%esp)
  80252c:	39 d6                	cmp    %edx,%esi
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 d1                	mov    %edx,%ecx
  802534:	89 c3                	mov    %eax,%ebx
  802536:	72 08                	jb     802540 <__umoddi3+0x110>
  802538:	75 11                	jne    80254b <__umoddi3+0x11b>
  80253a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80253e:	73 0b                	jae    80254b <__umoddi3+0x11b>
  802540:	2b 44 24 04          	sub    0x4(%esp),%eax
  802544:	1b 14 24             	sbb    (%esp),%edx
  802547:	89 d1                	mov    %edx,%ecx
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80254f:	29 da                	sub    %ebx,%edx
  802551:	19 ce                	sbb    %ecx,%esi
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 f0                	mov    %esi,%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	d3 ea                	shr    %cl,%edx
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	d3 ee                	shr    %cl,%esi
  802561:	09 d0                	or     %edx,%eax
  802563:	89 f2                	mov    %esi,%edx
  802565:	83 c4 1c             	add    $0x1c,%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 f9                	sub    %edi,%ecx
  802572:	19 d6                	sbb    %edx,%esi
  802574:	89 74 24 04          	mov    %esi,0x4(%esp)
  802578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257c:	e9 18 ff ff ff       	jmp    802499 <__umoddi3+0x69>
