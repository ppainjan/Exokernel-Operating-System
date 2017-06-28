
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 5f 15 00 00       	call   8015b0 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 00 28 80 00       	push   $0x802800
  80006d:	6a 15                	push   $0x15
  80006f:	68 2f 28 80 00       	push   $0x80282f
  800074:	e8 29 02 00 00       	call   8002a2 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 41 28 80 00       	push   $0x802841
  800084:	e8 f2 02 00 00       	call   80037b <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 fe 1f 00 00       	call   80208f <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 45 28 80 00       	push   $0x802845
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 2f 28 80 00       	push   $0x80282f
  8000a8:	e8 f5 01 00 00       	call   8002a2 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 7c 0f 00 00       	call   80102e <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 4e 28 80 00       	push   $0x80284e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 2f 28 80 00       	push   $0x80282f
  8000c3:	e8 da 01 00 00       	call   8002a2 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 0e 13 00 00       	call   8013e3 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 03 13 00 00       	call   8013e3 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 ed 12 00 00       	call   8013e3 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 a5 14 00 00       	call   8015b0 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 57 28 80 00       	push   $0x802857
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 2f 28 80 00       	push   $0x80282f
  800132:	e8 6b 01 00 00       	call   8002a2 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 ab 14 00 00       	call   8015f9 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 73 28 80 00       	push   $0x802873
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 2f 28 80 00       	push   $0x80282f
  800174:	e8 29 01 00 00       	call   8002a2 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 8d 	movl   $0x80288d,0x803000
  800187:	28 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 fc 1e 00 00       	call   80208f <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 45 28 80 00       	push   $0x802845
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 2f 28 80 00       	push   $0x80282f
  8001aa:	e8 f3 00 00 00       	call   8002a2 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 7a 0e 00 00       	call   80102e <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 4e 28 80 00       	push   $0x80284e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 2f 28 80 00       	push   $0x80282f
  8001c5:	e8 d8 00 00 00       	call   8002a2 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 0a 12 00 00       	call   8013e3 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 f4 11 00 00       	call   8013e3 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 ef 13 00 00       	call   8015f9 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 98 28 80 00       	push   $0x802898
  800226:	6a 4a                	push   $0x4a
  800228:	68 2f 28 80 00       	push   $0x80282f
  80022d:	e8 70 00 00 00       	call   8002a2 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800243:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80024a:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80024d:	e8 73 0a 00 00       	call   800cc5 <sys_getenvid>
  800252:	25 ff 03 00 00       	and    $0x3ff,%eax
  800257:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80025a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80025f:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800264:	85 db                	test   %ebx,%ebx
  800266:	7e 07                	jle    80026f <libmain+0x37>
		binaryname = argv[0];
  800268:	8b 06                	mov    (%esi),%eax
  80026a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	e8 00 ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  800279:	e8 0a 00 00 00       	call   800288 <exit>
}
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80028e:	e8 7b 11 00 00       	call   80140e <close_all>
	sys_env_destroy(0);
  800293:	83 ec 0c             	sub    $0xc,%esp
  800296:	6a 00                	push   $0x0
  800298:	e8 e7 09 00 00       	call   800c84 <sys_env_destroy>
}
  80029d:	83 c4 10             	add    $0x10,%esp
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002a7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002aa:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002b0:	e8 10 0a 00 00       	call   800cc5 <sys_getenvid>
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	ff 75 0c             	pushl  0xc(%ebp)
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	56                   	push   %esi
  8002bf:	50                   	push   %eax
  8002c0:	68 bc 28 80 00       	push   $0x8028bc
  8002c5:	e8 b1 00 00 00       	call   80037b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ca:	83 c4 18             	add    $0x18,%esp
  8002cd:	53                   	push   %ebx
  8002ce:	ff 75 10             	pushl  0x10(%ebp)
  8002d1:	e8 54 00 00 00       	call   80032a <vcprintf>
	cprintf("\n");
  8002d6:	c7 04 24 3a 2c 80 00 	movl   $0x802c3a,(%esp)
  8002dd:	e8 99 00 00 00       	call   80037b <cprintf>
  8002e2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e5:	cc                   	int3   
  8002e6:	eb fd                	jmp    8002e5 <_panic+0x43>

008002e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 04             	sub    $0x4,%esp
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f2:	8b 13                	mov    (%ebx),%edx
  8002f4:	8d 42 01             	lea    0x1(%edx),%eax
  8002f7:	89 03                	mov    %eax,(%ebx)
  8002f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800300:	3d ff 00 00 00       	cmp    $0xff,%eax
  800305:	75 1a                	jne    800321 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	68 ff 00 00 00       	push   $0xff
  80030f:	8d 43 08             	lea    0x8(%ebx),%eax
  800312:	50                   	push   %eax
  800313:	e8 2f 09 00 00       	call   800c47 <sys_cputs>
		b->idx = 0;
  800318:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800321:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800333:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033a:	00 00 00 
	b.cnt = 0;
  80033d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800344:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800347:	ff 75 0c             	pushl  0xc(%ebp)
  80034a:	ff 75 08             	pushl  0x8(%ebp)
  80034d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800353:	50                   	push   %eax
  800354:	68 e8 02 80 00       	push   $0x8002e8
  800359:	e8 54 01 00 00       	call   8004b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035e:	83 c4 08             	add    $0x8,%esp
  800361:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800367:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036d:	50                   	push   %eax
  80036e:	e8 d4 08 00 00       	call   800c47 <sys_cputs>

	return b.cnt;
}
  800373:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800379:	c9                   	leave  
  80037a:	c3                   	ret    

0080037b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800381:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800384:	50                   	push   %eax
  800385:	ff 75 08             	pushl  0x8(%ebp)
  800388:	e8 9d ff ff ff       	call   80032a <vcprintf>
	va_end(ap);

	return cnt;
}
  80038d:	c9                   	leave  
  80038e:	c3                   	ret    

0080038f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	57                   	push   %edi
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 1c             	sub    $0x1c,%esp
  800398:	89 c7                	mov    %eax,%edi
  80039a:	89 d6                	mov    %edx,%esi
  80039c:	8b 45 08             	mov    0x8(%ebp),%eax
  80039f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003b6:	39 d3                	cmp    %edx,%ebx
  8003b8:	72 05                	jb     8003bf <printnum+0x30>
  8003ba:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003bd:	77 45                	ja     800404 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	ff 75 18             	pushl  0x18(%ebp)
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003cb:	53                   	push   %ebx
  8003cc:	ff 75 10             	pushl  0x10(%ebp)
  8003cf:	83 ec 08             	sub    $0x8,%esp
  8003d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003db:	ff 75 d8             	pushl  -0x28(%ebp)
  8003de:	e8 7d 21 00 00       	call   802560 <__udivdi3>
  8003e3:	83 c4 18             	add    $0x18,%esp
  8003e6:	52                   	push   %edx
  8003e7:	50                   	push   %eax
  8003e8:	89 f2                	mov    %esi,%edx
  8003ea:	89 f8                	mov    %edi,%eax
  8003ec:	e8 9e ff ff ff       	call   80038f <printnum>
  8003f1:	83 c4 20             	add    $0x20,%esp
  8003f4:	eb 18                	jmp    80040e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f6:	83 ec 08             	sub    $0x8,%esp
  8003f9:	56                   	push   %esi
  8003fa:	ff 75 18             	pushl  0x18(%ebp)
  8003fd:	ff d7                	call   *%edi
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	eb 03                	jmp    800407 <printnum+0x78>
  800404:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800407:	83 eb 01             	sub    $0x1,%ebx
  80040a:	85 db                	test   %ebx,%ebx
  80040c:	7f e8                	jg     8003f6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	56                   	push   %esi
  800412:	83 ec 04             	sub    $0x4,%esp
  800415:	ff 75 e4             	pushl  -0x1c(%ebp)
  800418:	ff 75 e0             	pushl  -0x20(%ebp)
  80041b:	ff 75 dc             	pushl  -0x24(%ebp)
  80041e:	ff 75 d8             	pushl  -0x28(%ebp)
  800421:	e8 6a 22 00 00       	call   802690 <__umoddi3>
  800426:	83 c4 14             	add    $0x14,%esp
  800429:	0f be 80 df 28 80 00 	movsbl 0x8028df(%eax),%eax
  800430:	50                   	push   %eax
  800431:	ff d7                	call   *%edi
}
  800433:	83 c4 10             	add    $0x10,%esp
  800436:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800439:	5b                   	pop    %ebx
  80043a:	5e                   	pop    %esi
  80043b:	5f                   	pop    %edi
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800441:	83 fa 01             	cmp    $0x1,%edx
  800444:	7e 0e                	jle    800454 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800446:	8b 10                	mov    (%eax),%edx
  800448:	8d 4a 08             	lea    0x8(%edx),%ecx
  80044b:	89 08                	mov    %ecx,(%eax)
  80044d:	8b 02                	mov    (%edx),%eax
  80044f:	8b 52 04             	mov    0x4(%edx),%edx
  800452:	eb 22                	jmp    800476 <getuint+0x38>
	else if (lflag)
  800454:	85 d2                	test   %edx,%edx
  800456:	74 10                	je     800468 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800458:	8b 10                	mov    (%eax),%edx
  80045a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045d:	89 08                	mov    %ecx,(%eax)
  80045f:	8b 02                	mov    (%edx),%eax
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
  800466:	eb 0e                	jmp    800476 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800468:	8b 10                	mov    (%eax),%edx
  80046a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046d:	89 08                	mov    %ecx,(%eax)
  80046f:	8b 02                	mov    (%edx),%eax
  800471:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    

00800478 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80047e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800482:	8b 10                	mov    (%eax),%edx
  800484:	3b 50 04             	cmp    0x4(%eax),%edx
  800487:	73 0a                	jae    800493 <sprintputch+0x1b>
		*b->buf++ = ch;
  800489:	8d 4a 01             	lea    0x1(%edx),%ecx
  80048c:	89 08                	mov    %ecx,(%eax)
  80048e:	8b 45 08             	mov    0x8(%ebp),%eax
  800491:	88 02                	mov    %al,(%edx)
}
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    

00800495 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80049b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80049e:	50                   	push   %eax
  80049f:	ff 75 10             	pushl  0x10(%ebp)
  8004a2:	ff 75 0c             	pushl  0xc(%ebp)
  8004a5:	ff 75 08             	pushl  0x8(%ebp)
  8004a8:	e8 05 00 00 00       	call   8004b2 <vprintfmt>
	va_end(ap);
}
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	57                   	push   %edi
  8004b6:	56                   	push   %esi
  8004b7:	53                   	push   %ebx
  8004b8:	83 ec 2c             	sub    $0x2c,%esp
  8004bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004c4:	eb 12                	jmp    8004d8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	0f 84 89 03 00 00    	je     800857 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	50                   	push   %eax
  8004d3:	ff d6                	call   *%esi
  8004d5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004d8:	83 c7 01             	add    $0x1,%edi
  8004db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004df:	83 f8 25             	cmp    $0x25,%eax
  8004e2:	75 e2                	jne    8004c6 <vprintfmt+0x14>
  8004e4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004e8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004f6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800502:	eb 07                	jmp    80050b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800507:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8d 47 01             	lea    0x1(%edi),%eax
  80050e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800511:	0f b6 07             	movzbl (%edi),%eax
  800514:	0f b6 c8             	movzbl %al,%ecx
  800517:	83 e8 23             	sub    $0x23,%eax
  80051a:	3c 55                	cmp    $0x55,%al
  80051c:	0f 87 1a 03 00 00    	ja     80083c <vprintfmt+0x38a>
  800522:	0f b6 c0             	movzbl %al,%eax
  800525:	ff 24 85 20 2a 80 00 	jmp    *0x802a20(,%eax,4)
  80052c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80052f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800533:	eb d6                	jmp    80050b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800540:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800543:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800547:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80054a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80054d:	83 fa 09             	cmp    $0x9,%edx
  800550:	77 39                	ja     80058b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800552:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800555:	eb e9                	jmp    800540 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 48 04             	lea    0x4(%eax),%ecx
  80055d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800568:	eb 27                	jmp    800591 <vprintfmt+0xdf>
  80056a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056d:	85 c0                	test   %eax,%eax
  80056f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800574:	0f 49 c8             	cmovns %eax,%ecx
  800577:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057d:	eb 8c                	jmp    80050b <vprintfmt+0x59>
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800582:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800589:	eb 80                	jmp    80050b <vprintfmt+0x59>
  80058b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800591:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800595:	0f 89 70 ff ff ff    	jns    80050b <vprintfmt+0x59>
				width = precision, precision = -1;
  80059b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a8:	e9 5e ff ff ff       	jmp    80050b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ad:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005b3:	e9 53 ff ff ff       	jmp    80050b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	ff 30                	pushl  (%eax)
  8005c7:	ff d6                	call   *%esi
			break;
  8005c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005cf:	e9 04 ff ff ff       	jmp    8004d8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	99                   	cltd   
  8005e0:	31 d0                	xor    %edx,%eax
  8005e2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e4:	83 f8 0f             	cmp    $0xf,%eax
  8005e7:	7f 0b                	jg     8005f4 <vprintfmt+0x142>
  8005e9:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  8005f0:	85 d2                	test   %edx,%edx
  8005f2:	75 18                	jne    80060c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005f4:	50                   	push   %eax
  8005f5:	68 f7 28 80 00       	push   $0x8028f7
  8005fa:	53                   	push   %ebx
  8005fb:	56                   	push   %esi
  8005fc:	e8 94 fe ff ff       	call   800495 <printfmt>
  800601:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800607:	e9 cc fe ff ff       	jmp    8004d8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80060c:	52                   	push   %edx
  80060d:	68 0d 2e 80 00       	push   $0x802e0d
  800612:	53                   	push   %ebx
  800613:	56                   	push   %esi
  800614:	e8 7c fe ff ff       	call   800495 <printfmt>
  800619:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061f:	e9 b4 fe ff ff       	jmp    8004d8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80062f:	85 ff                	test   %edi,%edi
  800631:	b8 f0 28 80 00       	mov    $0x8028f0,%eax
  800636:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800639:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80063d:	0f 8e 94 00 00 00    	jle    8006d7 <vprintfmt+0x225>
  800643:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800647:	0f 84 98 00 00 00    	je     8006e5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	ff 75 d0             	pushl  -0x30(%ebp)
  800653:	57                   	push   %edi
  800654:	e8 86 02 00 00       	call   8008df <strnlen>
  800659:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80065c:	29 c1                	sub    %eax,%ecx
  80065e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800661:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800664:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800668:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80066b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80066e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800670:	eb 0f                	jmp    800681 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	ff 75 e0             	pushl  -0x20(%ebp)
  800679:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80067b:	83 ef 01             	sub    $0x1,%edi
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	85 ff                	test   %edi,%edi
  800683:	7f ed                	jg     800672 <vprintfmt+0x1c0>
  800685:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800688:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80068b:	85 c9                	test   %ecx,%ecx
  80068d:	b8 00 00 00 00       	mov    $0x0,%eax
  800692:	0f 49 c1             	cmovns %ecx,%eax
  800695:	29 c1                	sub    %eax,%ecx
  800697:	89 75 08             	mov    %esi,0x8(%ebp)
  80069a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80069d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a0:	89 cb                	mov    %ecx,%ebx
  8006a2:	eb 4d                	jmp    8006f1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a8:	74 1b                	je     8006c5 <vprintfmt+0x213>
  8006aa:	0f be c0             	movsbl %al,%eax
  8006ad:	83 e8 20             	sub    $0x20,%eax
  8006b0:	83 f8 5e             	cmp    $0x5e,%eax
  8006b3:	76 10                	jbe    8006c5 <vprintfmt+0x213>
					putch('?', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	6a 3f                	push   $0x3f
  8006bd:	ff 55 08             	call   *0x8(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 0d                	jmp    8006d2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	ff 75 0c             	pushl  0xc(%ebp)
  8006cb:	52                   	push   %edx
  8006cc:	ff 55 08             	call   *0x8(%ebp)
  8006cf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d2:	83 eb 01             	sub    $0x1,%ebx
  8006d5:	eb 1a                	jmp    8006f1 <vprintfmt+0x23f>
  8006d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8006da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e3:	eb 0c                	jmp    8006f1 <vprintfmt+0x23f>
  8006e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ee:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006f1:	83 c7 01             	add    $0x1,%edi
  8006f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f8:	0f be d0             	movsbl %al,%edx
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	74 23                	je     800722 <vprintfmt+0x270>
  8006ff:	85 f6                	test   %esi,%esi
  800701:	78 a1                	js     8006a4 <vprintfmt+0x1f2>
  800703:	83 ee 01             	sub    $0x1,%esi
  800706:	79 9c                	jns    8006a4 <vprintfmt+0x1f2>
  800708:	89 df                	mov    %ebx,%edi
  80070a:	8b 75 08             	mov    0x8(%ebp),%esi
  80070d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800710:	eb 18                	jmp    80072a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 20                	push   $0x20
  800718:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071a:	83 ef 01             	sub    $0x1,%edi
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	eb 08                	jmp    80072a <vprintfmt+0x278>
  800722:	89 df                	mov    %ebx,%edi
  800724:	8b 75 08             	mov    0x8(%ebp),%esi
  800727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072a:	85 ff                	test   %edi,%edi
  80072c:	7f e4                	jg     800712 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800731:	e9 a2 fd ff ff       	jmp    8004d8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800736:	83 fa 01             	cmp    $0x1,%edx
  800739:	7e 16                	jle    800751 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8d 50 08             	lea    0x8(%eax),%edx
  800741:	89 55 14             	mov    %edx,0x14(%ebp)
  800744:	8b 50 04             	mov    0x4(%eax),%edx
  800747:	8b 00                	mov    (%eax),%eax
  800749:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074f:	eb 32                	jmp    800783 <vprintfmt+0x2d1>
	else if (lflag)
  800751:	85 d2                	test   %edx,%edx
  800753:	74 18                	je     80076d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8d 50 04             	lea    0x4(%eax),%edx
  80075b:	89 55 14             	mov    %edx,0x14(%ebp)
  80075e:	8b 00                	mov    (%eax),%eax
  800760:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800763:	89 c1                	mov    %eax,%ecx
  800765:	c1 f9 1f             	sar    $0x1f,%ecx
  800768:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80076b:	eb 16                	jmp    800783 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8d 50 04             	lea    0x4(%eax),%edx
  800773:	89 55 14             	mov    %edx,0x14(%ebp)
  800776:	8b 00                	mov    (%eax),%eax
  800778:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077b:	89 c1                	mov    %eax,%ecx
  80077d:	c1 f9 1f             	sar    $0x1f,%ecx
  800780:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800783:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800786:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800789:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800792:	79 74                	jns    800808 <vprintfmt+0x356>
				putch('-', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 2d                	push   $0x2d
  80079a:	ff d6                	call   *%esi
				num = -(long long) num;
  80079c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80079f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007a2:	f7 d8                	neg    %eax
  8007a4:	83 d2 00             	adc    $0x0,%edx
  8007a7:	f7 da                	neg    %edx
  8007a9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b1:	eb 55                	jmp    800808 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b6:	e8 83 fc ff ff       	call   80043e <getuint>
			base = 10;
  8007bb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007c0:	eb 46                	jmp    800808 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c5:	e8 74 fc ff ff       	call   80043e <getuint>
		        base = 8;
  8007ca:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8007cf:	eb 37                	jmp    800808 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	53                   	push   %ebx
  8007d5:	6a 30                	push   $0x30
  8007d7:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	53                   	push   %ebx
  8007dd:	6a 78                	push   $0x78
  8007df:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 50 04             	lea    0x4(%eax),%edx
  8007e7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ea:	8b 00                	mov    (%eax),%eax
  8007ec:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007f9:	eb 0d                	jmp    800808 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fe:	e8 3b fc ff ff       	call   80043e <getuint>
			base = 16;
  800803:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800808:	83 ec 0c             	sub    $0xc,%esp
  80080b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80080f:	57                   	push   %edi
  800810:	ff 75 e0             	pushl  -0x20(%ebp)
  800813:	51                   	push   %ecx
  800814:	52                   	push   %edx
  800815:	50                   	push   %eax
  800816:	89 da                	mov    %ebx,%edx
  800818:	89 f0                	mov    %esi,%eax
  80081a:	e8 70 fb ff ff       	call   80038f <printnum>
			break;
  80081f:	83 c4 20             	add    $0x20,%esp
  800822:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800825:	e9 ae fc ff ff       	jmp    8004d8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	53                   	push   %ebx
  80082e:	51                   	push   %ecx
  80082f:	ff d6                	call   *%esi
			break;
  800831:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800834:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800837:	e9 9c fc ff ff       	jmp    8004d8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	53                   	push   %ebx
  800840:	6a 25                	push   $0x25
  800842:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 03                	jmp    80084c <vprintfmt+0x39a>
  800849:	83 ef 01             	sub    $0x1,%edi
  80084c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800850:	75 f7                	jne    800849 <vprintfmt+0x397>
  800852:	e9 81 fc ff ff       	jmp    8004d8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800857:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5f                   	pop    %edi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	83 ec 18             	sub    $0x18,%esp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800872:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800875:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087c:	85 c0                	test   %eax,%eax
  80087e:	74 26                	je     8008a6 <vsnprintf+0x47>
  800880:	85 d2                	test   %edx,%edx
  800882:	7e 22                	jle    8008a6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800884:	ff 75 14             	pushl  0x14(%ebp)
  800887:	ff 75 10             	pushl  0x10(%ebp)
  80088a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088d:	50                   	push   %eax
  80088e:	68 78 04 80 00       	push   $0x800478
  800893:	e8 1a fc ff ff       	call   8004b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800898:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a1:	83 c4 10             	add    $0x10,%esp
  8008a4:	eb 05                	jmp    8008ab <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b6:	50                   	push   %eax
  8008b7:	ff 75 10             	pushl  0x10(%ebp)
  8008ba:	ff 75 0c             	pushl  0xc(%ebp)
  8008bd:	ff 75 08             	pushl  0x8(%ebp)
  8008c0:	e8 9a ff ff ff       	call   80085f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	eb 03                	jmp    8008d7 <strlen+0x10>
		n++;
  8008d4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008db:	75 f7                	jne    8008d4 <strlen+0xd>
		n++;
	return n;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ed:	eb 03                	jmp    8008f2 <strnlen+0x13>
		n++;
  8008ef:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f2:	39 c2                	cmp    %eax,%edx
  8008f4:	74 08                	je     8008fe <strnlen+0x1f>
  8008f6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008fa:	75 f3                	jne    8008ef <strnlen+0x10>
  8008fc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	53                   	push   %ebx
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	83 c2 01             	add    $0x1,%edx
  80090f:	83 c1 01             	add    $0x1,%ecx
  800912:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800916:	88 5a ff             	mov    %bl,-0x1(%edx)
  800919:	84 db                	test   %bl,%bl
  80091b:	75 ef                	jne    80090c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80091d:	5b                   	pop    %ebx
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	53                   	push   %ebx
  800924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800927:	53                   	push   %ebx
  800928:	e8 9a ff ff ff       	call   8008c7 <strlen>
  80092d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800930:	ff 75 0c             	pushl  0xc(%ebp)
  800933:	01 d8                	add    %ebx,%eax
  800935:	50                   	push   %eax
  800936:	e8 c5 ff ff ff       	call   800900 <strcpy>
	return dst;
}
  80093b:	89 d8                	mov    %ebx,%eax
  80093d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 75 08             	mov    0x8(%ebp),%esi
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	89 f3                	mov    %esi,%ebx
  80094f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800952:	89 f2                	mov    %esi,%edx
  800954:	eb 0f                	jmp    800965 <strncpy+0x23>
		*dst++ = *src;
  800956:	83 c2 01             	add    $0x1,%edx
  800959:	0f b6 01             	movzbl (%ecx),%eax
  80095c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095f:	80 39 01             	cmpb   $0x1,(%ecx)
  800962:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	39 da                	cmp    %ebx,%edx
  800967:	75 ed                	jne    800956 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800969:	89 f0                	mov    %esi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	56                   	push   %esi
  800973:	53                   	push   %ebx
  800974:	8b 75 08             	mov    0x8(%ebp),%esi
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097a:	8b 55 10             	mov    0x10(%ebp),%edx
  80097d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097f:	85 d2                	test   %edx,%edx
  800981:	74 21                	je     8009a4 <strlcpy+0x35>
  800983:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800987:	89 f2                	mov    %esi,%edx
  800989:	eb 09                	jmp    800994 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80098b:	83 c2 01             	add    $0x1,%edx
  80098e:	83 c1 01             	add    $0x1,%ecx
  800991:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800994:	39 c2                	cmp    %eax,%edx
  800996:	74 09                	je     8009a1 <strlcpy+0x32>
  800998:	0f b6 19             	movzbl (%ecx),%ebx
  80099b:	84 db                	test   %bl,%bl
  80099d:	75 ec                	jne    80098b <strlcpy+0x1c>
  80099f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a4:	29 f0                	sub    %esi,%eax
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b3:	eb 06                	jmp    8009bb <strcmp+0x11>
		p++, q++;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bb:	0f b6 01             	movzbl (%ecx),%eax
  8009be:	84 c0                	test   %al,%al
  8009c0:	74 04                	je     8009c6 <strcmp+0x1c>
  8009c2:	3a 02                	cmp    (%edx),%al
  8009c4:	74 ef                	je     8009b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c6:	0f b6 c0             	movzbl %al,%eax
  8009c9:	0f b6 12             	movzbl (%edx),%edx
  8009cc:	29 d0                	sub    %edx,%eax
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	53                   	push   %ebx
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009da:	89 c3                	mov    %eax,%ebx
  8009dc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009df:	eb 06                	jmp    8009e7 <strncmp+0x17>
		n--, p++, q++;
  8009e1:	83 c0 01             	add    $0x1,%eax
  8009e4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e7:	39 d8                	cmp    %ebx,%eax
  8009e9:	74 15                	je     800a00 <strncmp+0x30>
  8009eb:	0f b6 08             	movzbl (%eax),%ecx
  8009ee:	84 c9                	test   %cl,%cl
  8009f0:	74 04                	je     8009f6 <strncmp+0x26>
  8009f2:	3a 0a                	cmp    (%edx),%cl
  8009f4:	74 eb                	je     8009e1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f6:	0f b6 00             	movzbl (%eax),%eax
  8009f9:	0f b6 12             	movzbl (%edx),%edx
  8009fc:	29 d0                	sub    %edx,%eax
  8009fe:	eb 05                	jmp    800a05 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a05:	5b                   	pop    %ebx
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a12:	eb 07                	jmp    800a1b <strchr+0x13>
		if (*s == c)
  800a14:	38 ca                	cmp    %cl,%dl
  800a16:	74 0f                	je     800a27 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	0f b6 10             	movzbl (%eax),%edx
  800a1e:	84 d2                	test   %dl,%dl
  800a20:	75 f2                	jne    800a14 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a33:	eb 03                	jmp    800a38 <strfind+0xf>
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	74 04                	je     800a43 <strfind+0x1a>
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	75 f2                	jne    800a35 <strfind+0xc>
			break;
	return (char *) s;
}
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a51:	85 c9                	test   %ecx,%ecx
  800a53:	74 36                	je     800a8b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a55:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5b:	75 28                	jne    800a85 <memset+0x40>
  800a5d:	f6 c1 03             	test   $0x3,%cl
  800a60:	75 23                	jne    800a85 <memset+0x40>
		c &= 0xFF;
  800a62:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a66:	89 d3                	mov    %edx,%ebx
  800a68:	c1 e3 08             	shl    $0x8,%ebx
  800a6b:	89 d6                	mov    %edx,%esi
  800a6d:	c1 e6 18             	shl    $0x18,%esi
  800a70:	89 d0                	mov    %edx,%eax
  800a72:	c1 e0 10             	shl    $0x10,%eax
  800a75:	09 f0                	or     %esi,%eax
  800a77:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a79:	89 d8                	mov    %ebx,%eax
  800a7b:	09 d0                	or     %edx,%eax
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
  800a80:	fc                   	cld    
  800a81:	f3 ab                	rep stos %eax,%es:(%edi)
  800a83:	eb 06                	jmp    800a8b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a88:	fc                   	cld    
  800a89:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8b:	89 f8                	mov    %edi,%eax
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa0:	39 c6                	cmp    %eax,%esi
  800aa2:	73 35                	jae    800ad9 <memmove+0x47>
  800aa4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa7:	39 d0                	cmp    %edx,%eax
  800aa9:	73 2e                	jae    800ad9 <memmove+0x47>
		s += n;
		d += n;
  800aab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aae:	89 d6                	mov    %edx,%esi
  800ab0:	09 fe                	or     %edi,%esi
  800ab2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab8:	75 13                	jne    800acd <memmove+0x3b>
  800aba:	f6 c1 03             	test   $0x3,%cl
  800abd:	75 0e                	jne    800acd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800abf:	83 ef 04             	sub    $0x4,%edi
  800ac2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac5:	c1 e9 02             	shr    $0x2,%ecx
  800ac8:	fd                   	std    
  800ac9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acb:	eb 09                	jmp    800ad6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800acd:	83 ef 01             	sub    $0x1,%edi
  800ad0:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ad3:	fd                   	std    
  800ad4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad6:	fc                   	cld    
  800ad7:	eb 1d                	jmp    800af6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad9:	89 f2                	mov    %esi,%edx
  800adb:	09 c2                	or     %eax,%edx
  800add:	f6 c2 03             	test   $0x3,%dl
  800ae0:	75 0f                	jne    800af1 <memmove+0x5f>
  800ae2:	f6 c1 03             	test   $0x3,%cl
  800ae5:	75 0a                	jne    800af1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ae7:	c1 e9 02             	shr    $0x2,%ecx
  800aea:	89 c7                	mov    %eax,%edi
  800aec:	fc                   	cld    
  800aed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aef:	eb 05                	jmp    800af6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	fc                   	cld    
  800af4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800afd:	ff 75 10             	pushl  0x10(%ebp)
  800b00:	ff 75 0c             	pushl  0xc(%ebp)
  800b03:	ff 75 08             	pushl  0x8(%ebp)
  800b06:	e8 87 ff ff ff       	call   800a92 <memmove>
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b18:	89 c6                	mov    %eax,%esi
  800b1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1d:	eb 1a                	jmp    800b39 <memcmp+0x2c>
		if (*s1 != *s2)
  800b1f:	0f b6 08             	movzbl (%eax),%ecx
  800b22:	0f b6 1a             	movzbl (%edx),%ebx
  800b25:	38 d9                	cmp    %bl,%cl
  800b27:	74 0a                	je     800b33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b29:	0f b6 c1             	movzbl %cl,%eax
  800b2c:	0f b6 db             	movzbl %bl,%ebx
  800b2f:	29 d8                	sub    %ebx,%eax
  800b31:	eb 0f                	jmp    800b42 <memcmp+0x35>
		s1++, s2++;
  800b33:	83 c0 01             	add    $0x1,%eax
  800b36:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b39:	39 f0                	cmp    %esi,%eax
  800b3b:	75 e2                	jne    800b1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	53                   	push   %ebx
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4d:	89 c1                	mov    %eax,%ecx
  800b4f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b52:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b56:	eb 0a                	jmp    800b62 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b58:	0f b6 10             	movzbl (%eax),%edx
  800b5b:	39 da                	cmp    %ebx,%edx
  800b5d:	74 07                	je     800b66 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5f:	83 c0 01             	add    $0x1,%eax
  800b62:	39 c8                	cmp    %ecx,%eax
  800b64:	72 f2                	jb     800b58 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b66:	5b                   	pop    %ebx
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b75:	eb 03                	jmp    800b7a <strtol+0x11>
		s++;
  800b77:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 01             	movzbl (%ecx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 f6                	je     800b77 <strtol+0xe>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	74 f2                	je     800b77 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b85:	3c 2b                	cmp    $0x2b,%al
  800b87:	75 0a                	jne    800b93 <strtol+0x2a>
		s++;
  800b89:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b91:	eb 11                	jmp    800ba4 <strtol+0x3b>
  800b93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b98:	3c 2d                	cmp    $0x2d,%al
  800b9a:	75 08                	jne    800ba4 <strtol+0x3b>
		s++, neg = 1;
  800b9c:	83 c1 01             	add    $0x1,%ecx
  800b9f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800baa:	75 15                	jne    800bc1 <strtol+0x58>
  800bac:	80 39 30             	cmpb   $0x30,(%ecx)
  800baf:	75 10                	jne    800bc1 <strtol+0x58>
  800bb1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb5:	75 7c                	jne    800c33 <strtol+0xca>
		s += 2, base = 16;
  800bb7:	83 c1 02             	add    $0x2,%ecx
  800bba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbf:	eb 16                	jmp    800bd7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bc1:	85 db                	test   %ebx,%ebx
  800bc3:	75 12                	jne    800bd7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bca:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcd:	75 08                	jne    800bd7 <strtol+0x6e>
		s++, base = 8;
  800bcf:	83 c1 01             	add    $0x1,%ecx
  800bd2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bdf:	0f b6 11             	movzbl (%ecx),%edx
  800be2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 09             	cmp    $0x9,%bl
  800bea:	77 08                	ja     800bf4 <strtol+0x8b>
			dig = *s - '0';
  800bec:	0f be d2             	movsbl %dl,%edx
  800bef:	83 ea 30             	sub    $0x30,%edx
  800bf2:	eb 22                	jmp    800c16 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bf4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bf7:	89 f3                	mov    %esi,%ebx
  800bf9:	80 fb 19             	cmp    $0x19,%bl
  800bfc:	77 08                	ja     800c06 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bfe:	0f be d2             	movsbl %dl,%edx
  800c01:	83 ea 57             	sub    $0x57,%edx
  800c04:	eb 10                	jmp    800c16 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c06:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c09:	89 f3                	mov    %esi,%ebx
  800c0b:	80 fb 19             	cmp    $0x19,%bl
  800c0e:	77 16                	ja     800c26 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c10:	0f be d2             	movsbl %dl,%edx
  800c13:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c16:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c19:	7d 0b                	jge    800c26 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c1b:	83 c1 01             	add    $0x1,%ecx
  800c1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c22:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c24:	eb b9                	jmp    800bdf <strtol+0x76>

	if (endptr)
  800c26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2a:	74 0d                	je     800c39 <strtol+0xd0>
		*endptr = (char *) s;
  800c2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2f:	89 0e                	mov    %ecx,(%esi)
  800c31:	eb 06                	jmp    800c39 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c33:	85 db                	test   %ebx,%ebx
  800c35:	74 98                	je     800bcf <strtol+0x66>
  800c37:	eb 9e                	jmp    800bd7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c39:	89 c2                	mov    %eax,%edx
  800c3b:	f7 da                	neg    %edx
  800c3d:	85 ff                	test   %edi,%edi
  800c3f:	0f 45 c2             	cmovne %edx,%eax
}
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 c3                	mov    %eax,%ebx
  800c5a:	89 c7                	mov    %eax,%edi
  800c5c:	89 c6                	mov    %eax,%esi
  800c5e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c70:	b8 01 00 00 00       	mov    $0x1,%eax
  800c75:	89 d1                	mov    %edx,%ecx
  800c77:	89 d3                	mov    %edx,%ebx
  800c79:	89 d7                	mov    %edx,%edi
  800c7b:	89 d6                	mov    %edx,%esi
  800c7d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c92:	b8 03 00 00 00       	mov    $0x3,%eax
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 cb                	mov    %ecx,%ebx
  800c9c:	89 cf                	mov    %ecx,%edi
  800c9e:	89 ce                	mov    %ecx,%esi
  800ca0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 03                	push   $0x3
  800cac:	68 df 2b 80 00       	push   $0x802bdf
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 fc 2b 80 00       	push   $0x802bfc
  800cb8:	e8 e5 f5 ff ff       	call   8002a2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_yield>:

void
sys_yield(void)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	ba 00 00 00 00       	mov    $0x0,%edx
  800cef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf4:	89 d1                	mov    %edx,%ecx
  800cf6:	89 d3                	mov    %edx,%ebx
  800cf8:	89 d7                	mov    %edx,%edi
  800cfa:	89 d6                	mov    %edx,%esi
  800cfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 04 00 00 00       	mov    $0x4,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	89 f7                	mov    %esi,%edi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 04                	push   $0x4
  800d2d:	68 df 2b 80 00       	push   $0x802bdf
  800d32:	6a 23                	push   $0x23
  800d34:	68 fc 2b 80 00       	push   $0x802bfc
  800d39:	e8 64 f5 ff ff       	call   8002a2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d60:	8b 75 18             	mov    0x18(%ebp),%esi
  800d63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 17                	jle    800d80 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 05                	push   $0x5
  800d6f:	68 df 2b 80 00       	push   $0x802bdf
  800d74:	6a 23                	push   $0x23
  800d76:	68 fc 2b 80 00       	push   $0x802bfc
  800d7b:	e8 22 f5 ff ff       	call   8002a2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d96:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 df                	mov    %ebx,%edi
  800da3:	89 de                	mov    %ebx,%esi
  800da5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 17                	jle    800dc2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 06                	push   $0x6
  800db1:	68 df 2b 80 00       	push   $0x802bdf
  800db6:	6a 23                	push   $0x23
  800db8:	68 fc 2b 80 00       	push   $0x802bfc
  800dbd:	e8 e0 f4 ff ff       	call   8002a2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 17                	jle    800e04 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	50                   	push   %eax
  800df1:	6a 08                	push   $0x8
  800df3:	68 df 2b 80 00       	push   $0x802bdf
  800df8:	6a 23                	push   $0x23
  800dfa:	68 fc 2b 80 00       	push   $0x802bfc
  800dff:	e8 9e f4 ff ff       	call   8002a2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 17                	jle    800e46 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	50                   	push   %eax
  800e33:	6a 09                	push   $0x9
  800e35:	68 df 2b 80 00       	push   $0x802bdf
  800e3a:	6a 23                	push   $0x23
  800e3c:	68 fc 2b 80 00       	push   $0x802bfc
  800e41:	e8 5c f4 ff ff       	call   8002a2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	89 de                	mov    %ebx,%esi
  800e6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7e 17                	jle    800e88 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e71:	83 ec 0c             	sub    $0xc,%esp
  800e74:	50                   	push   %eax
  800e75:	6a 0a                	push   $0xa
  800e77:	68 df 2b 80 00       	push   $0x802bdf
  800e7c:	6a 23                	push   $0x23
  800e7e:	68 fc 2b 80 00       	push   $0x802bfc
  800e83:	e8 1a f4 ff ff       	call   8002a2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e96:	be 00 00 00 00       	mov    $0x0,%esi
  800e9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eac:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	89 cb                	mov    %ecx,%ebx
  800ecb:	89 cf                	mov    %ecx,%edi
  800ecd:	89 ce                	mov    %ecx,%esi
  800ecf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	7e 17                	jle    800eec <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	50                   	push   %eax
  800ed9:	6a 0d                	push   $0xd
  800edb:	68 df 2b 80 00       	push   $0x802bdf
  800ee0:	6a 23                	push   $0x23
  800ee2:	68 fc 2b 80 00       	push   $0x802bfc
  800ee7:	e8 b6 f3 ff ff       	call   8002a2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f04:	89 d1                	mov    %edx,%ecx
  800f06:	89 d3                	mov    %edx,%ebx
  800f08:	89 d7                	mov    %edx,%edi
  800f0a:	89 d6                	mov    %edx,%esi
  800f0c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 df                	mov    %ebx,%edi
  800f2b:	89 de                	mov    %ebx,%esi
  800f2d:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	53                   	push   %ebx
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f3e:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f40:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f44:	74 2e                	je     800f74 <pgfault+0x40>
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	c1 ea 16             	shr    $0x16,%edx
  800f4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f52:	f6 c2 01             	test   $0x1,%dl
  800f55:	74 1d                	je     800f74 <pgfault+0x40>
  800f57:	89 c2                	mov    %eax,%edx
  800f59:	c1 ea 0c             	shr    $0xc,%edx
  800f5c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f63:	f6 c1 01             	test   $0x1,%cl
  800f66:	74 0c                	je     800f74 <pgfault+0x40>
  800f68:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6f:	f6 c6 08             	test   $0x8,%dh
  800f72:	75 14                	jne    800f88 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	68 0a 2c 80 00       	push   $0x802c0a
  800f7c:	6a 1d                	push   $0x1d
  800f7e:	68 1d 2c 80 00       	push   $0x802c1d
  800f83:	e8 1a f3 ff ff       	call   8002a2 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f8d:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	6a 07                	push   $0x7
  800f94:	68 00 f0 7f 00       	push   $0x7ff000
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 63 fd ff ff       	call   800d03 <sys_page_alloc>
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	79 14                	jns    800fbb <pgfault+0x87>
		panic("page alloc failed \n");
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	68 28 2c 80 00       	push   $0x802c28
  800faf:	6a 28                	push   $0x28
  800fb1:	68 1d 2c 80 00       	push   $0x802c1d
  800fb6:	e8 e7 f2 ff ff       	call   8002a2 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	68 00 10 00 00       	push   $0x1000
  800fc3:	53                   	push   %ebx
  800fc4:	68 00 f0 7f 00       	push   $0x7ff000
  800fc9:	e8 2c fb ff ff       	call   800afa <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800fce:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fd5:	53                   	push   %ebx
  800fd6:	6a 00                	push   $0x0
  800fd8:	68 00 f0 7f 00       	push   $0x7ff000
  800fdd:	6a 00                	push   $0x0
  800fdf:	e8 62 fd ff ff       	call   800d46 <sys_page_map>
  800fe4:	83 c4 20             	add    $0x20,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	79 14                	jns    800fff <pgfault+0xcb>
        panic("page map failed \n");
  800feb:	83 ec 04             	sub    $0x4,%esp
  800fee:	68 3c 2c 80 00       	push   $0x802c3c
  800ff3:	6a 2b                	push   $0x2b
  800ff5:	68 1d 2c 80 00       	push   $0x802c1d
  800ffa:	e8 a3 f2 ff ff       	call   8002a2 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	68 00 f0 7f 00       	push   $0x7ff000
  801007:	6a 00                	push   $0x0
  801009:	e8 7a fd ff ff       	call   800d88 <sys_page_unmap>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	79 14                	jns    801029 <pgfault+0xf5>
        panic("page unmap failed\n");
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	68 4e 2c 80 00       	push   $0x802c4e
  80101d:	6a 2d                	push   $0x2d
  80101f:	68 1d 2c 80 00       	push   $0x802c1d
  801024:	e8 79 f2 ff ff       	call   8002a2 <_panic>
	
	//panic("pgfault not implemented");
}
  801029:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    

0080102e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  801037:	68 34 0f 80 00       	push   $0x800f34
  80103c:	e8 57 13 00 00       	call   802398 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801041:	b8 07 00 00 00       	mov    $0x7,%eax
  801046:	cd 30                	int    $0x30
  801048:	89 c7                	mov    %eax,%edi
  80104a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	79 12                	jns    801066 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  801054:	50                   	push   %eax
  801055:	68 61 2c 80 00       	push   $0x802c61
  80105a:	6a 7a                	push   $0x7a
  80105c:	68 1d 2c 80 00       	push   $0x802c1d
  801061:	e8 3c f2 ff ff       	call   8002a2 <_panic>
  801066:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  80106b:	85 c0                	test   %eax,%eax
  80106d:	75 21                	jne    801090 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  80106f:	e8 51 fc ff ff       	call   800cc5 <sys_getenvid>
  801074:	25 ff 03 00 00       	and    $0x3ff,%eax
  801079:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80107c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801081:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
  80108b:	e9 91 01 00 00       	jmp    801221 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  801090:	89 d8                	mov    %ebx,%eax
  801092:	c1 e8 16             	shr    $0x16,%eax
  801095:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109c:	a8 01                	test   $0x1,%al
  80109e:	0f 84 06 01 00 00    	je     8011aa <fork+0x17c>
  8010a4:	89 d8                	mov    %ebx,%eax
  8010a6:	c1 e8 0c             	shr    $0xc,%eax
  8010a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b0:	f6 c2 01             	test   $0x1,%dl
  8010b3:	0f 84 f1 00 00 00    	je     8011aa <fork+0x17c>
  8010b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c0:	f6 c2 04             	test   $0x4,%dl
  8010c3:	0f 84 e1 00 00 00    	je     8011aa <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  8010c9:	89 c6                	mov    %eax,%esi
  8010cb:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  8010ce:	89 f2                	mov    %esi,%edx
  8010d0:	c1 ea 16             	shr    $0x16,%edx
  8010d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  8010da:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  8010e1:	f6 c6 04             	test   $0x4,%dh
  8010e4:	74 39                	je     80111f <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  8010e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f5:	50                   	push   %eax
  8010f6:	56                   	push   %esi
  8010f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fa:	56                   	push   %esi
  8010fb:	6a 00                	push   $0x0
  8010fd:	e8 44 fc ff ff       	call   800d46 <sys_page_map>
  801102:	83 c4 20             	add    $0x20,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	0f 89 9d 00 00 00    	jns    8011aa <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  80110d:	50                   	push   %eax
  80110e:	68 b8 2c 80 00       	push   $0x802cb8
  801113:	6a 4b                	push   $0x4b
  801115:	68 1d 2c 80 00       	push   $0x802c1d
  80111a:	e8 83 f1 ff ff       	call   8002a2 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  80111f:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801125:	74 59                	je     801180 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	68 05 08 00 00       	push   $0x805
  80112f:	56                   	push   %esi
  801130:	ff 75 e4             	pushl  -0x1c(%ebp)
  801133:	56                   	push   %esi
  801134:	6a 00                	push   $0x0
  801136:	e8 0b fc ff ff       	call   800d46 <sys_page_map>
  80113b:	83 c4 20             	add    $0x20,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	79 12                	jns    801154 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  801142:	50                   	push   %eax
  801143:	68 e8 2c 80 00       	push   $0x802ce8
  801148:	6a 50                	push   $0x50
  80114a:	68 1d 2c 80 00       	push   $0x802c1d
  80114f:	e8 4e f1 ff ff       	call   8002a2 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	68 05 08 00 00       	push   $0x805
  80115c:	56                   	push   %esi
  80115d:	6a 00                	push   $0x0
  80115f:	56                   	push   %esi
  801160:	6a 00                	push   $0x0
  801162:	e8 df fb ff ff       	call   800d46 <sys_page_map>
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	79 3c                	jns    8011aa <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  80116e:	50                   	push   %eax
  80116f:	68 10 2d 80 00       	push   $0x802d10
  801174:	6a 53                	push   $0x53
  801176:	68 1d 2c 80 00       	push   $0x802c1d
  80117b:	e8 22 f1 ff ff       	call   8002a2 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	6a 05                	push   $0x5
  801185:	56                   	push   %esi
  801186:	ff 75 e4             	pushl  -0x1c(%ebp)
  801189:	56                   	push   %esi
  80118a:	6a 00                	push   $0x0
  80118c:	e8 b5 fb ff ff       	call   800d46 <sys_page_map>
  801191:	83 c4 20             	add    $0x20,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	79 12                	jns    8011aa <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  801198:	50                   	push   %eax
  801199:	68 38 2d 80 00       	push   $0x802d38
  80119e:	6a 58                	push   $0x58
  8011a0:	68 1d 2c 80 00       	push   $0x802c1d
  8011a5:	e8 f8 f0 ff ff       	call   8002a2 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  8011aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011b0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011b6:	0f 85 d4 fe ff ff    	jne    801090 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	6a 07                	push   $0x7
  8011c1:	68 00 f0 bf ee       	push   $0xeebff000
  8011c6:	57                   	push   %edi
  8011c7:	e8 37 fb ff ff       	call   800d03 <sys_page_alloc>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	79 17                	jns    8011ea <fork+0x1bc>
        panic("page alloc failed\n");
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	68 73 2c 80 00       	push   $0x802c73
  8011db:	68 87 00 00 00       	push   $0x87
  8011e0:	68 1d 2c 80 00       	push   $0x802c1d
  8011e5:	e8 b8 f0 ff ff       	call   8002a2 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	68 07 24 80 00       	push   $0x802407
  8011f2:	57                   	push   %edi
  8011f3:	e8 56 fc ff ff       	call   800e4e <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011f8:	83 c4 08             	add    $0x8,%esp
  8011fb:	6a 02                	push   $0x2
  8011fd:	57                   	push   %edi
  8011fe:	e8 c7 fb ff ff       	call   800dca <sys_env_set_status>
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	79 15                	jns    80121f <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  80120a:	50                   	push   %eax
  80120b:	68 86 2c 80 00       	push   $0x802c86
  801210:	68 8c 00 00 00       	push   $0x8c
  801215:	68 1d 2c 80 00       	push   $0x802c1d
  80121a:	e8 83 f0 ff ff       	call   8002a2 <_panic>

	return envid;
  80121f:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <sfork>:

// Challenge!
int
sfork(void)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80122f:	68 9f 2c 80 00       	push   $0x802c9f
  801234:	68 98 00 00 00       	push   $0x98
  801239:	68 1d 2c 80 00       	push   $0x802c1d
  80123e:	e8 5f f0 ff ff       	call   8002a2 <_panic>

00801243 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
  801249:	05 00 00 00 30       	add    $0x30000000,%eax
  80124e:	c1 e8 0c             	shr    $0xc,%eax
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801256:	8b 45 08             	mov    0x8(%ebp),%eax
  801259:	05 00 00 00 30       	add    $0x30000000,%eax
  80125e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801263:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801270:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 ea 16             	shr    $0x16,%edx
  80127a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801281:	f6 c2 01             	test   $0x1,%dl
  801284:	74 11                	je     801297 <fd_alloc+0x2d>
  801286:	89 c2                	mov    %eax,%edx
  801288:	c1 ea 0c             	shr    $0xc,%edx
  80128b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801292:	f6 c2 01             	test   $0x1,%dl
  801295:	75 09                	jne    8012a0 <fd_alloc+0x36>
			*fd_store = fd;
  801297:	89 01                	mov    %eax,(%ecx)
			return 0;
  801299:	b8 00 00 00 00       	mov    $0x0,%eax
  80129e:	eb 17                	jmp    8012b7 <fd_alloc+0x4d>
  8012a0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012a5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012aa:	75 c9                	jne    801275 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012ac:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012b2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012bf:	83 f8 1f             	cmp    $0x1f,%eax
  8012c2:	77 36                	ja     8012fa <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c4:	c1 e0 0c             	shl    $0xc,%eax
  8012c7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012cc:	89 c2                	mov    %eax,%edx
  8012ce:	c1 ea 16             	shr    $0x16,%edx
  8012d1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d8:	f6 c2 01             	test   $0x1,%dl
  8012db:	74 24                	je     801301 <fd_lookup+0x48>
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	c1 ea 0c             	shr    $0xc,%edx
  8012e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e9:	f6 c2 01             	test   $0x1,%dl
  8012ec:	74 1a                	je     801308 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f8:	eb 13                	jmp    80130d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ff:	eb 0c                	jmp    80130d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801301:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801306:	eb 05                	jmp    80130d <fd_lookup+0x54>
  801308:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801318:	ba e0 2d 80 00       	mov    $0x802de0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80131d:	eb 13                	jmp    801332 <dev_lookup+0x23>
  80131f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801322:	39 08                	cmp    %ecx,(%eax)
  801324:	75 0c                	jne    801332 <dev_lookup+0x23>
			*dev = devtab[i];
  801326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801329:	89 01                	mov    %eax,(%ecx)
			return 0;
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
  801330:	eb 2e                	jmp    801360 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801332:	8b 02                	mov    (%edx),%eax
  801334:	85 c0                	test   %eax,%eax
  801336:	75 e7                	jne    80131f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801338:	a1 08 40 80 00       	mov    0x804008,%eax
  80133d:	8b 40 48             	mov    0x48(%eax),%eax
  801340:	83 ec 04             	sub    $0x4,%esp
  801343:	51                   	push   %ecx
  801344:	50                   	push   %eax
  801345:	68 64 2d 80 00       	push   $0x802d64
  80134a:	e8 2c f0 ff ff       	call   80037b <cprintf>
	*dev = 0;
  80134f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801352:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	83 ec 10             	sub    $0x10,%esp
  80136a:	8b 75 08             	mov    0x8(%ebp),%esi
  80136d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80137a:	c1 e8 0c             	shr    $0xc,%eax
  80137d:	50                   	push   %eax
  80137e:	e8 36 ff ff ff       	call   8012b9 <fd_lookup>
  801383:	83 c4 08             	add    $0x8,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 05                	js     80138f <fd_close+0x2d>
	    || fd != fd2)
  80138a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80138d:	74 0c                	je     80139b <fd_close+0x39>
		return (must_exist ? r : 0);
  80138f:	84 db                	test   %bl,%bl
  801391:	ba 00 00 00 00       	mov    $0x0,%edx
  801396:	0f 44 c2             	cmove  %edx,%eax
  801399:	eb 41                	jmp    8013dc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	ff 36                	pushl  (%esi)
  8013a4:	e8 66 ff ff ff       	call   80130f <dev_lookup>
  8013a9:	89 c3                	mov    %eax,%ebx
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	78 1a                	js     8013cc <fd_close+0x6a>
		if (dev->dev_close)
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	74 0b                	je     8013cc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013c1:	83 ec 0c             	sub    $0xc,%esp
  8013c4:	56                   	push   %esi
  8013c5:	ff d0                	call   *%eax
  8013c7:	89 c3                	mov    %eax,%ebx
  8013c9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	56                   	push   %esi
  8013d0:	6a 00                	push   $0x0
  8013d2:	e8 b1 f9 ff ff       	call   800d88 <sys_page_unmap>
	return r;
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	89 d8                	mov    %ebx,%eax
}
  8013dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5e                   	pop    %esi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	ff 75 08             	pushl  0x8(%ebp)
  8013f0:	e8 c4 fe ff ff       	call   8012b9 <fd_lookup>
  8013f5:	83 c4 08             	add    $0x8,%esp
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 10                	js     80140c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	6a 01                	push   $0x1
  801401:	ff 75 f4             	pushl  -0xc(%ebp)
  801404:	e8 59 ff ff ff       	call   801362 <fd_close>
  801409:	83 c4 10             	add    $0x10,%esp
}
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <close_all>:

void
close_all(void)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	53                   	push   %ebx
  801412:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801415:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	53                   	push   %ebx
  80141e:	e8 c0 ff ff ff       	call   8013e3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801423:	83 c3 01             	add    $0x1,%ebx
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	83 fb 20             	cmp    $0x20,%ebx
  80142c:	75 ec                	jne    80141a <close_all+0xc>
		close(i);
}
  80142e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	57                   	push   %edi
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
  801439:	83 ec 2c             	sub    $0x2c,%esp
  80143c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80143f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	ff 75 08             	pushl  0x8(%ebp)
  801446:	e8 6e fe ff ff       	call   8012b9 <fd_lookup>
  80144b:	83 c4 08             	add    $0x8,%esp
  80144e:	85 c0                	test   %eax,%eax
  801450:	0f 88 c1 00 00 00    	js     801517 <dup+0xe4>
		return r;
	close(newfdnum);
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	56                   	push   %esi
  80145a:	e8 84 ff ff ff       	call   8013e3 <close>

	newfd = INDEX2FD(newfdnum);
  80145f:	89 f3                	mov    %esi,%ebx
  801461:	c1 e3 0c             	shl    $0xc,%ebx
  801464:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80146a:	83 c4 04             	add    $0x4,%esp
  80146d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801470:	e8 de fd ff ff       	call   801253 <fd2data>
  801475:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801477:	89 1c 24             	mov    %ebx,(%esp)
  80147a:	e8 d4 fd ff ff       	call   801253 <fd2data>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801485:	89 f8                	mov    %edi,%eax
  801487:	c1 e8 16             	shr    $0x16,%eax
  80148a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801491:	a8 01                	test   $0x1,%al
  801493:	74 37                	je     8014cc <dup+0x99>
  801495:	89 f8                	mov    %edi,%eax
  801497:	c1 e8 0c             	shr    $0xc,%eax
  80149a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014a1:	f6 c2 01             	test   $0x1,%dl
  8014a4:	74 26                	je     8014cc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b5:	50                   	push   %eax
  8014b6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b9:	6a 00                	push   $0x0
  8014bb:	57                   	push   %edi
  8014bc:	6a 00                	push   $0x0
  8014be:	e8 83 f8 ff ff       	call   800d46 <sys_page_map>
  8014c3:	89 c7                	mov    %eax,%edi
  8014c5:	83 c4 20             	add    $0x20,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 2e                	js     8014fa <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014cf:	89 d0                	mov    %edx,%eax
  8014d1:	c1 e8 0c             	shr    $0xc,%eax
  8014d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014db:	83 ec 0c             	sub    $0xc,%esp
  8014de:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e3:	50                   	push   %eax
  8014e4:	53                   	push   %ebx
  8014e5:	6a 00                	push   $0x0
  8014e7:	52                   	push   %edx
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 57 f8 ff ff       	call   800d46 <sys_page_map>
  8014ef:	89 c7                	mov    %eax,%edi
  8014f1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014f4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f6:	85 ff                	test   %edi,%edi
  8014f8:	79 1d                	jns    801517 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	53                   	push   %ebx
  8014fe:	6a 00                	push   $0x0
  801500:	e8 83 f8 ff ff       	call   800d88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801505:	83 c4 08             	add    $0x8,%esp
  801508:	ff 75 d4             	pushl  -0x2c(%ebp)
  80150b:	6a 00                	push   $0x0
  80150d:	e8 76 f8 ff ff       	call   800d88 <sys_page_unmap>
	return r;
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	89 f8                	mov    %edi,%eax
}
  801517:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151a:	5b                   	pop    %ebx
  80151b:	5e                   	pop    %esi
  80151c:	5f                   	pop    %edi
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    

0080151f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	53                   	push   %ebx
  801523:	83 ec 14             	sub    $0x14,%esp
  801526:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801529:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	53                   	push   %ebx
  80152e:	e8 86 fd ff ff       	call   8012b9 <fd_lookup>
  801533:	83 c4 08             	add    $0x8,%esp
  801536:	89 c2                	mov    %eax,%edx
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 6d                	js     8015a9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	ff 30                	pushl  (%eax)
  801548:	e8 c2 fd ff ff       	call   80130f <dev_lookup>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 4c                	js     8015a0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801554:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801557:	8b 42 08             	mov    0x8(%edx),%eax
  80155a:	83 e0 03             	and    $0x3,%eax
  80155d:	83 f8 01             	cmp    $0x1,%eax
  801560:	75 21                	jne    801583 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801562:	a1 08 40 80 00       	mov    0x804008,%eax
  801567:	8b 40 48             	mov    0x48(%eax),%eax
  80156a:	83 ec 04             	sub    $0x4,%esp
  80156d:	53                   	push   %ebx
  80156e:	50                   	push   %eax
  80156f:	68 a5 2d 80 00       	push   $0x802da5
  801574:	e8 02 ee ff ff       	call   80037b <cprintf>
		return -E_INVAL;
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801581:	eb 26                	jmp    8015a9 <read+0x8a>
	}
	if (!dev->dev_read)
  801583:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801586:	8b 40 08             	mov    0x8(%eax),%eax
  801589:	85 c0                	test   %eax,%eax
  80158b:	74 17                	je     8015a4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80158d:	83 ec 04             	sub    $0x4,%esp
  801590:	ff 75 10             	pushl  0x10(%ebp)
  801593:	ff 75 0c             	pushl  0xc(%ebp)
  801596:	52                   	push   %edx
  801597:	ff d0                	call   *%eax
  801599:	89 c2                	mov    %eax,%edx
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	eb 09                	jmp    8015a9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a0:	89 c2                	mov    %eax,%edx
  8015a2:	eb 05                	jmp    8015a9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015a9:	89 d0                	mov    %edx,%eax
  8015ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	57                   	push   %edi
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 0c             	sub    $0xc,%esp
  8015b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c4:	eb 21                	jmp    8015e7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c6:	83 ec 04             	sub    $0x4,%esp
  8015c9:	89 f0                	mov    %esi,%eax
  8015cb:	29 d8                	sub    %ebx,%eax
  8015cd:	50                   	push   %eax
  8015ce:	89 d8                	mov    %ebx,%eax
  8015d0:	03 45 0c             	add    0xc(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	57                   	push   %edi
  8015d5:	e8 45 ff ff ff       	call   80151f <read>
		if (m < 0)
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 10                	js     8015f1 <readn+0x41>
			return m;
		if (m == 0)
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	74 0a                	je     8015ef <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e5:	01 c3                	add    %eax,%ebx
  8015e7:	39 f3                	cmp    %esi,%ebx
  8015e9:	72 db                	jb     8015c6 <readn+0x16>
  8015eb:	89 d8                	mov    %ebx,%eax
  8015ed:	eb 02                	jmp    8015f1 <readn+0x41>
  8015ef:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5e                   	pop    %esi
  8015f6:	5f                   	pop    %edi
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    

008015f9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 14             	sub    $0x14,%esp
  801600:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801603:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	53                   	push   %ebx
  801608:	e8 ac fc ff ff       	call   8012b9 <fd_lookup>
  80160d:	83 c4 08             	add    $0x8,%esp
  801610:	89 c2                	mov    %eax,%edx
  801612:	85 c0                	test   %eax,%eax
  801614:	78 68                	js     80167e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	ff 30                	pushl  (%eax)
  801622:	e8 e8 fc ff ff       	call   80130f <dev_lookup>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 47                	js     801675 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801635:	75 21                	jne    801658 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801637:	a1 08 40 80 00       	mov    0x804008,%eax
  80163c:	8b 40 48             	mov    0x48(%eax),%eax
  80163f:	83 ec 04             	sub    $0x4,%esp
  801642:	53                   	push   %ebx
  801643:	50                   	push   %eax
  801644:	68 c1 2d 80 00       	push   $0x802dc1
  801649:	e8 2d ed ff ff       	call   80037b <cprintf>
		return -E_INVAL;
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801656:	eb 26                	jmp    80167e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801658:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165b:	8b 52 0c             	mov    0xc(%edx),%edx
  80165e:	85 d2                	test   %edx,%edx
  801660:	74 17                	je     801679 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801662:	83 ec 04             	sub    $0x4,%esp
  801665:	ff 75 10             	pushl  0x10(%ebp)
  801668:	ff 75 0c             	pushl  0xc(%ebp)
  80166b:	50                   	push   %eax
  80166c:	ff d2                	call   *%edx
  80166e:	89 c2                	mov    %eax,%edx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	eb 09                	jmp    80167e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801675:	89 c2                	mov    %eax,%edx
  801677:	eb 05                	jmp    80167e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801679:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80167e:	89 d0                	mov    %edx,%eax
  801680:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <seek>:

int
seek(int fdnum, off_t offset)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80168b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80168e:	50                   	push   %eax
  80168f:	ff 75 08             	pushl  0x8(%ebp)
  801692:	e8 22 fc ff ff       	call   8012b9 <fd_lookup>
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 0e                	js     8016ac <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80169e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 14             	sub    $0x14,%esp
  8016b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bb:	50                   	push   %eax
  8016bc:	53                   	push   %ebx
  8016bd:	e8 f7 fb ff ff       	call   8012b9 <fd_lookup>
  8016c2:	83 c4 08             	add    $0x8,%esp
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 65                	js     801730 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d1:	50                   	push   %eax
  8016d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d5:	ff 30                	pushl  (%eax)
  8016d7:	e8 33 fc ff ff       	call   80130f <dev_lookup>
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 44                	js     801727 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ea:	75 21                	jne    80170d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ec:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016f1:	8b 40 48             	mov    0x48(%eax),%eax
  8016f4:	83 ec 04             	sub    $0x4,%esp
  8016f7:	53                   	push   %ebx
  8016f8:	50                   	push   %eax
  8016f9:	68 84 2d 80 00       	push   $0x802d84
  8016fe:	e8 78 ec ff ff       	call   80037b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80170b:	eb 23                	jmp    801730 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80170d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801710:	8b 52 18             	mov    0x18(%edx),%edx
  801713:	85 d2                	test   %edx,%edx
  801715:	74 14                	je     80172b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	ff 75 0c             	pushl  0xc(%ebp)
  80171d:	50                   	push   %eax
  80171e:	ff d2                	call   *%edx
  801720:	89 c2                	mov    %eax,%edx
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	eb 09                	jmp    801730 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801727:	89 c2                	mov    %eax,%edx
  801729:	eb 05                	jmp    801730 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80172b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801730:	89 d0                	mov    %edx,%eax
  801732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 14             	sub    $0x14,%esp
  80173e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801741:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801744:	50                   	push   %eax
  801745:	ff 75 08             	pushl  0x8(%ebp)
  801748:	e8 6c fb ff ff       	call   8012b9 <fd_lookup>
  80174d:	83 c4 08             	add    $0x8,%esp
  801750:	89 c2                	mov    %eax,%edx
  801752:	85 c0                	test   %eax,%eax
  801754:	78 58                	js     8017ae <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175c:	50                   	push   %eax
  80175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801760:	ff 30                	pushl  (%eax)
  801762:	e8 a8 fb ff ff       	call   80130f <dev_lookup>
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 37                	js     8017a5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80176e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801771:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801775:	74 32                	je     8017a9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801777:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80177a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801781:	00 00 00 
	stat->st_isdir = 0;
  801784:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80178b:	00 00 00 
	stat->st_dev = dev;
  80178e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801794:	83 ec 08             	sub    $0x8,%esp
  801797:	53                   	push   %ebx
  801798:	ff 75 f0             	pushl  -0x10(%ebp)
  80179b:	ff 50 14             	call   *0x14(%eax)
  80179e:	89 c2                	mov    %eax,%edx
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	eb 09                	jmp    8017ae <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a5:	89 c2                	mov    %eax,%edx
  8017a7:	eb 05                	jmp    8017ae <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017ae:	89 d0                	mov    %edx,%eax
  8017b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ba:	83 ec 08             	sub    $0x8,%esp
  8017bd:	6a 00                	push   $0x0
  8017bf:	ff 75 08             	pushl  0x8(%ebp)
  8017c2:	e8 e7 01 00 00       	call   8019ae <open>
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 1b                	js     8017eb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	ff 75 0c             	pushl  0xc(%ebp)
  8017d6:	50                   	push   %eax
  8017d7:	e8 5b ff ff ff       	call   801737 <fstat>
  8017dc:	89 c6                	mov    %eax,%esi
	close(fd);
  8017de:	89 1c 24             	mov    %ebx,(%esp)
  8017e1:	e8 fd fb ff ff       	call   8013e3 <close>
	return r;
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	89 f0                	mov    %esi,%eax
}
  8017eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ee:	5b                   	pop    %ebx
  8017ef:	5e                   	pop    %esi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	89 c6                	mov    %eax,%esi
  8017f9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017fb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801802:	75 12                	jne    801816 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801804:	83 ec 0c             	sub    $0xc,%esp
  801807:	6a 01                	push   $0x1
  801809:	e8 de 0c 00 00       	call   8024ec <ipc_find_env>
  80180e:	a3 00 40 80 00       	mov    %eax,0x804000
  801813:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801816:	6a 07                	push   $0x7
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	56                   	push   %esi
  80181e:	ff 35 00 40 80 00    	pushl  0x804000
  801824:	e8 6f 0c 00 00       	call   802498 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801829:	83 c4 0c             	add    $0xc,%esp
  80182c:	6a 00                	push   $0x0
  80182e:	53                   	push   %ebx
  80182f:	6a 00                	push   $0x0
  801831:	e8 f5 0b 00 00       	call   80242b <ipc_recv>
}
  801836:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	8b 40 0c             	mov    0xc(%eax),%eax
  801849:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80184e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801851:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 02 00 00 00       	mov    $0x2,%eax
  801860:	e8 8d ff ff ff       	call   8017f2 <fsipc>
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	8b 40 0c             	mov    0xc(%eax),%eax
  801873:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 06 00 00 00       	mov    $0x6,%eax
  801882:	e8 6b ff ff ff       	call   8017f2 <fsipc>
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	53                   	push   %ebx
  80188d:	83 ec 04             	sub    $0x4,%esp
  801890:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
  801896:	8b 40 0c             	mov    0xc(%eax),%eax
  801899:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a8:	e8 45 ff ff ff       	call   8017f2 <fsipc>
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 2c                	js     8018dd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	68 00 50 80 00       	push   $0x805000
  8018b9:	53                   	push   %ebx
  8018ba:	e8 41 f0 ff ff       	call   800900 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018bf:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ca:	a1 84 50 80 00       	mov    0x805084,%eax
  8018cf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	53                   	push   %ebx
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8018ec:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018f1:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8018f6:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018f9:	53                   	push   %ebx
  8018fa:	ff 75 0c             	pushl  0xc(%ebp)
  8018fd:	68 08 50 80 00       	push   $0x805008
  801902:	e8 8b f1 ff ff       	call   800a92 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	8b 40 0c             	mov    0xc(%eax),%eax
  80190d:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801912:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801918:	ba 00 00 00 00       	mov    $0x0,%edx
  80191d:	b8 04 00 00 00       	mov    $0x4,%eax
  801922:	e8 cb fe ff ff       	call   8017f2 <fsipc>
	//panic("devfile_write not implemented");
}
  801927:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	8b 40 0c             	mov    0xc(%eax),%eax
  80193a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80193f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801945:	ba 00 00 00 00       	mov    $0x0,%edx
  80194a:	b8 03 00 00 00       	mov    $0x3,%eax
  80194f:	e8 9e fe ff ff       	call   8017f2 <fsipc>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	85 c0                	test   %eax,%eax
  801958:	78 4b                	js     8019a5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80195a:	39 c6                	cmp    %eax,%esi
  80195c:	73 16                	jae    801974 <devfile_read+0x48>
  80195e:	68 f4 2d 80 00       	push   $0x802df4
  801963:	68 fb 2d 80 00       	push   $0x802dfb
  801968:	6a 7c                	push   $0x7c
  80196a:	68 10 2e 80 00       	push   $0x802e10
  80196f:	e8 2e e9 ff ff       	call   8002a2 <_panic>
	assert(r <= PGSIZE);
  801974:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801979:	7e 16                	jle    801991 <devfile_read+0x65>
  80197b:	68 1b 2e 80 00       	push   $0x802e1b
  801980:	68 fb 2d 80 00       	push   $0x802dfb
  801985:	6a 7d                	push   $0x7d
  801987:	68 10 2e 80 00       	push   $0x802e10
  80198c:	e8 11 e9 ff ff       	call   8002a2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801991:	83 ec 04             	sub    $0x4,%esp
  801994:	50                   	push   %eax
  801995:	68 00 50 80 00       	push   $0x805000
  80199a:	ff 75 0c             	pushl  0xc(%ebp)
  80199d:	e8 f0 f0 ff ff       	call   800a92 <memmove>
	return r;
  8019a2:	83 c4 10             	add    $0x10,%esp
}
  8019a5:	89 d8                	mov    %ebx,%eax
  8019a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019aa:	5b                   	pop    %ebx
  8019ab:	5e                   	pop    %esi
  8019ac:	5d                   	pop    %ebp
  8019ad:	c3                   	ret    

008019ae <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	53                   	push   %ebx
  8019b2:	83 ec 20             	sub    $0x20,%esp
  8019b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019b8:	53                   	push   %ebx
  8019b9:	e8 09 ef ff ff       	call   8008c7 <strlen>
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c6:	7f 67                	jg     801a2f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ce:	50                   	push   %eax
  8019cf:	e8 96 f8 ff ff       	call   80126a <fd_alloc>
  8019d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 57                	js     801a34 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	53                   	push   %ebx
  8019e1:	68 00 50 80 00       	push   $0x805000
  8019e6:	e8 15 ef ff ff       	call   800900 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ee:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fb:	e8 f2 fd ff ff       	call   8017f2 <fsipc>
  801a00:	89 c3                	mov    %eax,%ebx
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 c0                	test   %eax,%eax
  801a07:	79 14                	jns    801a1d <open+0x6f>
		fd_close(fd, 0);
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	6a 00                	push   $0x0
  801a0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a11:	e8 4c f9 ff ff       	call   801362 <fd_close>
		return r;
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	89 da                	mov    %ebx,%edx
  801a1b:	eb 17                	jmp    801a34 <open+0x86>
	}

	return fd2num(fd);
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	ff 75 f4             	pushl  -0xc(%ebp)
  801a23:	e8 1b f8 ff ff       	call   801243 <fd2num>
  801a28:	89 c2                	mov    %eax,%edx
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	eb 05                	jmp    801a34 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a2f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a34:	89 d0                	mov    %edx,%eax
  801a36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a41:	ba 00 00 00 00       	mov    $0x0,%edx
  801a46:	b8 08 00 00 00       	mov    $0x8,%eax
  801a4b:	e8 a2 fd ff ff       	call   8017f2 <fsipc>
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a58:	68 27 2e 80 00       	push   $0x802e27
  801a5d:	ff 75 0c             	pushl  0xc(%ebp)
  801a60:	e8 9b ee ff ff       	call   800900 <strcpy>
	return 0;
}
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	53                   	push   %ebx
  801a70:	83 ec 10             	sub    $0x10,%esp
  801a73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a76:	53                   	push   %ebx
  801a77:	e8 a9 0a 00 00       	call   802525 <pageref>
  801a7c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a7f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a84:	83 f8 01             	cmp    $0x1,%eax
  801a87:	75 10                	jne    801a99 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a89:	83 ec 0c             	sub    $0xc,%esp
  801a8c:	ff 73 0c             	pushl  0xc(%ebx)
  801a8f:	e8 c0 02 00 00       	call   801d54 <nsipc_close>
  801a94:	89 c2                	mov    %eax,%edx
  801a96:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a99:	89 d0                	mov    %edx,%eax
  801a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aa6:	6a 00                	push   $0x0
  801aa8:	ff 75 10             	pushl  0x10(%ebp)
  801aab:	ff 75 0c             	pushl  0xc(%ebp)
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	ff 70 0c             	pushl  0xc(%eax)
  801ab4:	e8 78 03 00 00       	call   801e31 <nsipc_send>
}
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ac1:	6a 00                	push   $0x0
  801ac3:	ff 75 10             	pushl  0x10(%ebp)
  801ac6:	ff 75 0c             	pushl  0xc(%ebp)
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	ff 70 0c             	pushl  0xc(%eax)
  801acf:	e8 f1 02 00 00       	call   801dc5 <nsipc_recv>
}
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801adc:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801adf:	52                   	push   %edx
  801ae0:	50                   	push   %eax
  801ae1:	e8 d3 f7 ff ff       	call   8012b9 <fd_lookup>
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 17                	js     801b04 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af0:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801af6:	39 08                	cmp    %ecx,(%eax)
  801af8:	75 05                	jne    801aff <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801afa:	8b 40 0c             	mov    0xc(%eax),%eax
  801afd:	eb 05                	jmp    801b04 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	83 ec 1c             	sub    $0x1c,%esp
  801b0e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b13:	50                   	push   %eax
  801b14:	e8 51 f7 ff ff       	call   80126a <fd_alloc>
  801b19:	89 c3                	mov    %eax,%ebx
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 1b                	js     801b3d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b22:	83 ec 04             	sub    $0x4,%esp
  801b25:	68 07 04 00 00       	push   $0x407
  801b2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2d:	6a 00                	push   $0x0
  801b2f:	e8 cf f1 ff ff       	call   800d03 <sys_page_alloc>
  801b34:	89 c3                	mov    %eax,%ebx
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	79 10                	jns    801b4d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	56                   	push   %esi
  801b41:	e8 0e 02 00 00       	call   801d54 <nsipc_close>
		return r;
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	89 d8                	mov    %ebx,%eax
  801b4b:	eb 24                	jmp    801b71 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b56:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b62:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b65:	83 ec 0c             	sub    $0xc,%esp
  801b68:	50                   	push   %eax
  801b69:	e8 d5 f6 ff ff       	call   801243 <fd2num>
  801b6e:	83 c4 10             	add    $0x10,%esp
}
  801b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	e8 50 ff ff ff       	call   801ad6 <fd2sockid>
		return r;
  801b86:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 1f                	js     801bab <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	ff 75 10             	pushl  0x10(%ebp)
  801b92:	ff 75 0c             	pushl  0xc(%ebp)
  801b95:	50                   	push   %eax
  801b96:	e8 12 01 00 00       	call   801cad <nsipc_accept>
  801b9b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b9e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 07                	js     801bab <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ba4:	e8 5d ff ff ff       	call   801b06 <alloc_sockfd>
  801ba9:	89 c1                	mov    %eax,%ecx
}
  801bab:	89 c8                	mov    %ecx,%eax
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb8:	e8 19 ff ff ff       	call   801ad6 <fd2sockid>
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	78 12                	js     801bd3 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	ff 75 10             	pushl  0x10(%ebp)
  801bc7:	ff 75 0c             	pushl  0xc(%ebp)
  801bca:	50                   	push   %eax
  801bcb:	e8 2d 01 00 00       	call   801cfd <nsipc_bind>
  801bd0:	83 c4 10             	add    $0x10,%esp
}
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <shutdown>:

int
shutdown(int s, int how)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	e8 f3 fe ff ff       	call   801ad6 <fd2sockid>
  801be3:	85 c0                	test   %eax,%eax
  801be5:	78 0f                	js     801bf6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801be7:	83 ec 08             	sub    $0x8,%esp
  801bea:	ff 75 0c             	pushl  0xc(%ebp)
  801bed:	50                   	push   %eax
  801bee:	e8 3f 01 00 00       	call   801d32 <nsipc_shutdown>
  801bf3:	83 c4 10             	add    $0x10,%esp
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801c01:	e8 d0 fe ff ff       	call   801ad6 <fd2sockid>
  801c06:	85 c0                	test   %eax,%eax
  801c08:	78 12                	js     801c1c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c0a:	83 ec 04             	sub    $0x4,%esp
  801c0d:	ff 75 10             	pushl  0x10(%ebp)
  801c10:	ff 75 0c             	pushl  0xc(%ebp)
  801c13:	50                   	push   %eax
  801c14:	e8 55 01 00 00       	call   801d6e <nsipc_connect>
  801c19:	83 c4 10             	add    $0x10,%esp
}
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <listen>:

int
listen(int s, int backlog)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	e8 aa fe ff ff       	call   801ad6 <fd2sockid>
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	78 0f                	js     801c3f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c30:	83 ec 08             	sub    $0x8,%esp
  801c33:	ff 75 0c             	pushl  0xc(%ebp)
  801c36:	50                   	push   %eax
  801c37:	e8 67 01 00 00       	call   801da3 <nsipc_listen>
  801c3c:	83 c4 10             	add    $0x10,%esp
}
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c47:	ff 75 10             	pushl  0x10(%ebp)
  801c4a:	ff 75 0c             	pushl  0xc(%ebp)
  801c4d:	ff 75 08             	pushl  0x8(%ebp)
  801c50:	e8 3a 02 00 00       	call   801e8f <nsipc_socket>
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	78 05                	js     801c61 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c5c:	e8 a5 fe ff ff       	call   801b06 <alloc_sockfd>
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	53                   	push   %ebx
  801c67:	83 ec 04             	sub    $0x4,%esp
  801c6a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c6c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c73:	75 12                	jne    801c87 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	6a 02                	push   $0x2
  801c7a:	e8 6d 08 00 00       	call   8024ec <ipc_find_env>
  801c7f:	a3 04 40 80 00       	mov    %eax,0x804004
  801c84:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c87:	6a 07                	push   $0x7
  801c89:	68 00 60 80 00       	push   $0x806000
  801c8e:	53                   	push   %ebx
  801c8f:	ff 35 04 40 80 00    	pushl  0x804004
  801c95:	e8 fe 07 00 00       	call   802498 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c9a:	83 c4 0c             	add    $0xc,%esp
  801c9d:	6a 00                	push   $0x0
  801c9f:	6a 00                	push   $0x0
  801ca1:	6a 00                	push   $0x0
  801ca3:	e8 83 07 00 00       	call   80242b <ipc_recv>
}
  801ca8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	56                   	push   %esi
  801cb1:	53                   	push   %ebx
  801cb2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cbd:	8b 06                	mov    (%esi),%eax
  801cbf:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc9:	e8 95 ff ff ff       	call   801c63 <nsipc>
  801cce:	89 c3                	mov    %eax,%ebx
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	78 20                	js     801cf4 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cd4:	83 ec 04             	sub    $0x4,%esp
  801cd7:	ff 35 10 60 80 00    	pushl  0x806010
  801cdd:	68 00 60 80 00       	push   $0x806000
  801ce2:	ff 75 0c             	pushl  0xc(%ebp)
  801ce5:	e8 a8 ed ff ff       	call   800a92 <memmove>
		*addrlen = ret->ret_addrlen;
  801cea:	a1 10 60 80 00       	mov    0x806010,%eax
  801cef:	89 06                	mov    %eax,(%esi)
  801cf1:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cf4:	89 d8                	mov    %ebx,%eax
  801cf6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    

00801cfd <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	53                   	push   %ebx
  801d01:	83 ec 08             	sub    $0x8,%esp
  801d04:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d0f:	53                   	push   %ebx
  801d10:	ff 75 0c             	pushl  0xc(%ebp)
  801d13:	68 04 60 80 00       	push   $0x806004
  801d18:	e8 75 ed ff ff       	call   800a92 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d1d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d23:	b8 02 00 00 00       	mov    $0x2,%eax
  801d28:	e8 36 ff ff ff       	call   801c63 <nsipc>
}
  801d2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d38:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d43:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d48:	b8 03 00 00 00       	mov    $0x3,%eax
  801d4d:	e8 11 ff ff ff       	call   801c63 <nsipc>
}
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <nsipc_close>:

int
nsipc_close(int s)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5d:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d62:	b8 04 00 00 00       	mov    $0x4,%eax
  801d67:	e8 f7 fe ff ff       	call   801c63 <nsipc>
}
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	53                   	push   %ebx
  801d72:	83 ec 08             	sub    $0x8,%esp
  801d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d80:	53                   	push   %ebx
  801d81:	ff 75 0c             	pushl  0xc(%ebp)
  801d84:	68 04 60 80 00       	push   $0x806004
  801d89:	e8 04 ed ff ff       	call   800a92 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d8e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d94:	b8 05 00 00 00       	mov    $0x5,%eax
  801d99:	e8 c5 fe ff ff       	call   801c63 <nsipc>
}
  801d9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801db1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801db9:	b8 06 00 00 00       	mov    $0x6,%eax
  801dbe:	e8 a0 fe ff ff       	call   801c63 <nsipc>
}
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	56                   	push   %esi
  801dc9:	53                   	push   %ebx
  801dca:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dd5:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ddb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dde:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801de3:	b8 07 00 00 00       	mov    $0x7,%eax
  801de8:	e8 76 fe ff ff       	call   801c63 <nsipc>
  801ded:	89 c3                	mov    %eax,%ebx
  801def:	85 c0                	test   %eax,%eax
  801df1:	78 35                	js     801e28 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801df3:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801df8:	7f 04                	jg     801dfe <nsipc_recv+0x39>
  801dfa:	39 c6                	cmp    %eax,%esi
  801dfc:	7d 16                	jge    801e14 <nsipc_recv+0x4f>
  801dfe:	68 33 2e 80 00       	push   $0x802e33
  801e03:	68 fb 2d 80 00       	push   $0x802dfb
  801e08:	6a 62                	push   $0x62
  801e0a:	68 48 2e 80 00       	push   $0x802e48
  801e0f:	e8 8e e4 ff ff       	call   8002a2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e14:	83 ec 04             	sub    $0x4,%esp
  801e17:	50                   	push   %eax
  801e18:	68 00 60 80 00       	push   $0x806000
  801e1d:	ff 75 0c             	pushl  0xc(%ebp)
  801e20:	e8 6d ec ff ff       	call   800a92 <memmove>
  801e25:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e28:	89 d8                	mov    %ebx,%eax
  801e2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2d:	5b                   	pop    %ebx
  801e2e:	5e                   	pop    %esi
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    

00801e31 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	53                   	push   %ebx
  801e35:	83 ec 04             	sub    $0x4,%esp
  801e38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e43:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e49:	7e 16                	jle    801e61 <nsipc_send+0x30>
  801e4b:	68 54 2e 80 00       	push   $0x802e54
  801e50:	68 fb 2d 80 00       	push   $0x802dfb
  801e55:	6a 6d                	push   $0x6d
  801e57:	68 48 2e 80 00       	push   $0x802e48
  801e5c:	e8 41 e4 ff ff       	call   8002a2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e61:	83 ec 04             	sub    $0x4,%esp
  801e64:	53                   	push   %ebx
  801e65:	ff 75 0c             	pushl  0xc(%ebp)
  801e68:	68 0c 60 80 00       	push   $0x80600c
  801e6d:	e8 20 ec ff ff       	call   800a92 <memmove>
	nsipcbuf.send.req_size = size;
  801e72:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e78:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e80:	b8 08 00 00 00       	mov    $0x8,%eax
  801e85:	e8 d9 fd ff ff       	call   801c63 <nsipc>
}
  801e8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e95:	8b 45 08             	mov    0x8(%ebp),%eax
  801e98:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ea5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ead:	b8 09 00 00 00       	mov    $0x9,%eax
  801eb2:	e8 ac fd ff ff       	call   801c63 <nsipc>
}
  801eb7:	c9                   	leave  
  801eb8:	c3                   	ret    

00801eb9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	56                   	push   %esi
  801ebd:	53                   	push   %ebx
  801ebe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	ff 75 08             	pushl  0x8(%ebp)
  801ec7:	e8 87 f3 ff ff       	call   801253 <fd2data>
  801ecc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ece:	83 c4 08             	add    $0x8,%esp
  801ed1:	68 60 2e 80 00       	push   $0x802e60
  801ed6:	53                   	push   %ebx
  801ed7:	e8 24 ea ff ff       	call   800900 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801edc:	8b 46 04             	mov    0x4(%esi),%eax
  801edf:	2b 06                	sub    (%esi),%eax
  801ee1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ee7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eee:	00 00 00 
	stat->st_dev = &devpipe;
  801ef1:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ef8:	30 80 00 
	return 0;
}
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
  801f00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    

00801f07 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	53                   	push   %ebx
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f11:	53                   	push   %ebx
  801f12:	6a 00                	push   $0x0
  801f14:	e8 6f ee ff ff       	call   800d88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f19:	89 1c 24             	mov    %ebx,(%esp)
  801f1c:	e8 32 f3 ff ff       	call   801253 <fd2data>
  801f21:	83 c4 08             	add    $0x8,%esp
  801f24:	50                   	push   %eax
  801f25:	6a 00                	push   $0x0
  801f27:	e8 5c ee ff ff       	call   800d88 <sys_page_unmap>
}
  801f2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	57                   	push   %edi
  801f35:	56                   	push   %esi
  801f36:	53                   	push   %ebx
  801f37:	83 ec 1c             	sub    $0x1c,%esp
  801f3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f3d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f44:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f47:	83 ec 0c             	sub    $0xc,%esp
  801f4a:	ff 75 e0             	pushl  -0x20(%ebp)
  801f4d:	e8 d3 05 00 00       	call   802525 <pageref>
  801f52:	89 c3                	mov    %eax,%ebx
  801f54:	89 3c 24             	mov    %edi,(%esp)
  801f57:	e8 c9 05 00 00       	call   802525 <pageref>
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	39 c3                	cmp    %eax,%ebx
  801f61:	0f 94 c1             	sete   %cl
  801f64:	0f b6 c9             	movzbl %cl,%ecx
  801f67:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f6a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f70:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f73:	39 ce                	cmp    %ecx,%esi
  801f75:	74 1b                	je     801f92 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f77:	39 c3                	cmp    %eax,%ebx
  801f79:	75 c4                	jne    801f3f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f7b:	8b 42 58             	mov    0x58(%edx),%eax
  801f7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f81:	50                   	push   %eax
  801f82:	56                   	push   %esi
  801f83:	68 67 2e 80 00       	push   $0x802e67
  801f88:	e8 ee e3 ff ff       	call   80037b <cprintf>
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	eb ad                	jmp    801f3f <_pipeisclosed+0xe>
	}
}
  801f92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	57                   	push   %edi
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	83 ec 28             	sub    $0x28,%esp
  801fa6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fa9:	56                   	push   %esi
  801faa:	e8 a4 f2 ff ff       	call   801253 <fd2data>
  801faf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	bf 00 00 00 00       	mov    $0x0,%edi
  801fb9:	eb 4b                	jmp    802006 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fbb:	89 da                	mov    %ebx,%edx
  801fbd:	89 f0                	mov    %esi,%eax
  801fbf:	e8 6d ff ff ff       	call   801f31 <_pipeisclosed>
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	75 48                	jne    802010 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fc8:	e8 17 ed ff ff       	call   800ce4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fcd:	8b 43 04             	mov    0x4(%ebx),%eax
  801fd0:	8b 0b                	mov    (%ebx),%ecx
  801fd2:	8d 51 20             	lea    0x20(%ecx),%edx
  801fd5:	39 d0                	cmp    %edx,%eax
  801fd7:	73 e2                	jae    801fbb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fdc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fe0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fe3:	89 c2                	mov    %eax,%edx
  801fe5:	c1 fa 1f             	sar    $0x1f,%edx
  801fe8:	89 d1                	mov    %edx,%ecx
  801fea:	c1 e9 1b             	shr    $0x1b,%ecx
  801fed:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ff0:	83 e2 1f             	and    $0x1f,%edx
  801ff3:	29 ca                	sub    %ecx,%edx
  801ff5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ff9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ffd:	83 c0 01             	add    $0x1,%eax
  802000:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802003:	83 c7 01             	add    $0x1,%edi
  802006:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802009:	75 c2                	jne    801fcd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80200b:	8b 45 10             	mov    0x10(%ebp),%eax
  80200e:	eb 05                	jmp    802015 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802015:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    

0080201d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	57                   	push   %edi
  802021:	56                   	push   %esi
  802022:	53                   	push   %ebx
  802023:	83 ec 18             	sub    $0x18,%esp
  802026:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802029:	57                   	push   %edi
  80202a:	e8 24 f2 ff ff       	call   801253 <fd2data>
  80202f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	bb 00 00 00 00       	mov    $0x0,%ebx
  802039:	eb 3d                	jmp    802078 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80203b:	85 db                	test   %ebx,%ebx
  80203d:	74 04                	je     802043 <devpipe_read+0x26>
				return i;
  80203f:	89 d8                	mov    %ebx,%eax
  802041:	eb 44                	jmp    802087 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802043:	89 f2                	mov    %esi,%edx
  802045:	89 f8                	mov    %edi,%eax
  802047:	e8 e5 fe ff ff       	call   801f31 <_pipeisclosed>
  80204c:	85 c0                	test   %eax,%eax
  80204e:	75 32                	jne    802082 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802050:	e8 8f ec ff ff       	call   800ce4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802055:	8b 06                	mov    (%esi),%eax
  802057:	3b 46 04             	cmp    0x4(%esi),%eax
  80205a:	74 df                	je     80203b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80205c:	99                   	cltd   
  80205d:	c1 ea 1b             	shr    $0x1b,%edx
  802060:	01 d0                	add    %edx,%eax
  802062:	83 e0 1f             	and    $0x1f,%eax
  802065:	29 d0                	sub    %edx,%eax
  802067:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80206c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80206f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802072:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802075:	83 c3 01             	add    $0x1,%ebx
  802078:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80207b:	75 d8                	jne    802055 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80207d:	8b 45 10             	mov    0x10(%ebp),%eax
  802080:	eb 05                	jmp    802087 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208a:	5b                   	pop    %ebx
  80208b:	5e                   	pop    %esi
  80208c:	5f                   	pop    %edi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802097:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209a:	50                   	push   %eax
  80209b:	e8 ca f1 ff ff       	call   80126a <fd_alloc>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	89 c2                	mov    %eax,%edx
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	0f 88 2c 01 00 00    	js     8021d9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ad:	83 ec 04             	sub    $0x4,%esp
  8020b0:	68 07 04 00 00       	push   $0x407
  8020b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b8:	6a 00                	push   $0x0
  8020ba:	e8 44 ec ff ff       	call   800d03 <sys_page_alloc>
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	89 c2                	mov    %eax,%edx
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	0f 88 0d 01 00 00    	js     8021d9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020cc:	83 ec 0c             	sub    $0xc,%esp
  8020cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020d2:	50                   	push   %eax
  8020d3:	e8 92 f1 ff ff       	call   80126a <fd_alloc>
  8020d8:	89 c3                	mov    %eax,%ebx
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	0f 88 e2 00 00 00    	js     8021c7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e5:	83 ec 04             	sub    $0x4,%esp
  8020e8:	68 07 04 00 00       	push   $0x407
  8020ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f0:	6a 00                	push   $0x0
  8020f2:	e8 0c ec ff ff       	call   800d03 <sys_page_alloc>
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	83 c4 10             	add    $0x10,%esp
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	0f 88 c3 00 00 00    	js     8021c7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802104:	83 ec 0c             	sub    $0xc,%esp
  802107:	ff 75 f4             	pushl  -0xc(%ebp)
  80210a:	e8 44 f1 ff ff       	call   801253 <fd2data>
  80210f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802111:	83 c4 0c             	add    $0xc,%esp
  802114:	68 07 04 00 00       	push   $0x407
  802119:	50                   	push   %eax
  80211a:	6a 00                	push   $0x0
  80211c:	e8 e2 eb ff ff       	call   800d03 <sys_page_alloc>
  802121:	89 c3                	mov    %eax,%ebx
  802123:	83 c4 10             	add    $0x10,%esp
  802126:	85 c0                	test   %eax,%eax
  802128:	0f 88 89 00 00 00    	js     8021b7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212e:	83 ec 0c             	sub    $0xc,%esp
  802131:	ff 75 f0             	pushl  -0x10(%ebp)
  802134:	e8 1a f1 ff ff       	call   801253 <fd2data>
  802139:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802140:	50                   	push   %eax
  802141:	6a 00                	push   $0x0
  802143:	56                   	push   %esi
  802144:	6a 00                	push   $0x0
  802146:	e8 fb eb ff ff       	call   800d46 <sys_page_map>
  80214b:	89 c3                	mov    %eax,%ebx
  80214d:	83 c4 20             	add    $0x20,%esp
  802150:	85 c0                	test   %eax,%eax
  802152:	78 55                	js     8021a9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802154:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80215a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80215f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802162:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802169:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80216f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802172:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802174:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802177:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80217e:	83 ec 0c             	sub    $0xc,%esp
  802181:	ff 75 f4             	pushl  -0xc(%ebp)
  802184:	e8 ba f0 ff ff       	call   801243 <fd2num>
  802189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80218e:	83 c4 04             	add    $0x4,%esp
  802191:	ff 75 f0             	pushl  -0x10(%ebp)
  802194:	e8 aa f0 ff ff       	call   801243 <fd2num>
  802199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80219f:	83 c4 10             	add    $0x10,%esp
  8021a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021a7:	eb 30                	jmp    8021d9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021a9:	83 ec 08             	sub    $0x8,%esp
  8021ac:	56                   	push   %esi
  8021ad:	6a 00                	push   $0x0
  8021af:	e8 d4 eb ff ff       	call   800d88 <sys_page_unmap>
  8021b4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021b7:	83 ec 08             	sub    $0x8,%esp
  8021ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8021bd:	6a 00                	push   $0x0
  8021bf:	e8 c4 eb ff ff       	call   800d88 <sys_page_unmap>
  8021c4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021c7:	83 ec 08             	sub    $0x8,%esp
  8021ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cd:	6a 00                	push   $0x0
  8021cf:	e8 b4 eb ff ff       	call   800d88 <sys_page_unmap>
  8021d4:	83 c4 10             	add    $0x10,%esp
  8021d7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021d9:	89 d0                	mov    %edx,%eax
  8021db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021de:	5b                   	pop    %ebx
  8021df:	5e                   	pop    %esi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    

008021e2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021eb:	50                   	push   %eax
  8021ec:	ff 75 08             	pushl  0x8(%ebp)
  8021ef:	e8 c5 f0 ff ff       	call   8012b9 <fd_lookup>
  8021f4:	83 c4 10             	add    $0x10,%esp
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	78 18                	js     802213 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021fb:	83 ec 0c             	sub    $0xc,%esp
  8021fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802201:	e8 4d f0 ff ff       	call   801253 <fd2data>
	return _pipeisclosed(fd, p);
  802206:	89 c2                	mov    %eax,%edx
  802208:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220b:	e8 21 fd ff ff       	call   801f31 <_pipeisclosed>
  802210:	83 c4 10             	add    $0x10,%esp
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802218:	b8 00 00 00 00       	mov    $0x0,%eax
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    

0080221f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802225:	68 7a 2e 80 00       	push   $0x802e7a
  80222a:	ff 75 0c             	pushl  0xc(%ebp)
  80222d:	e8 ce e6 ff ff       	call   800900 <strcpy>
	return 0;
}
  802232:	b8 00 00 00 00       	mov    $0x0,%eax
  802237:	c9                   	leave  
  802238:	c3                   	ret    

00802239 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	57                   	push   %edi
  80223d:	56                   	push   %esi
  80223e:	53                   	push   %ebx
  80223f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802245:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80224a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802250:	eb 2d                	jmp    80227f <devcons_write+0x46>
		m = n - tot;
  802252:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802255:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802257:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80225a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80225f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802262:	83 ec 04             	sub    $0x4,%esp
  802265:	53                   	push   %ebx
  802266:	03 45 0c             	add    0xc(%ebp),%eax
  802269:	50                   	push   %eax
  80226a:	57                   	push   %edi
  80226b:	e8 22 e8 ff ff       	call   800a92 <memmove>
		sys_cputs(buf, m);
  802270:	83 c4 08             	add    $0x8,%esp
  802273:	53                   	push   %ebx
  802274:	57                   	push   %edi
  802275:	e8 cd e9 ff ff       	call   800c47 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80227a:	01 de                	add    %ebx,%esi
  80227c:	83 c4 10             	add    $0x10,%esp
  80227f:	89 f0                	mov    %esi,%eax
  802281:	3b 75 10             	cmp    0x10(%ebp),%esi
  802284:	72 cc                	jb     802252 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802289:	5b                   	pop    %ebx
  80228a:	5e                   	pop    %esi
  80228b:	5f                   	pop    %edi
  80228c:	5d                   	pop    %ebp
  80228d:	c3                   	ret    

0080228e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80228e:	55                   	push   %ebp
  80228f:	89 e5                	mov    %esp,%ebp
  802291:	83 ec 08             	sub    $0x8,%esp
  802294:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802299:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80229d:	74 2a                	je     8022c9 <devcons_read+0x3b>
  80229f:	eb 05                	jmp    8022a6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022a1:	e8 3e ea ff ff       	call   800ce4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022a6:	e8 ba e9 ff ff       	call   800c65 <sys_cgetc>
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	74 f2                	je     8022a1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022af:	85 c0                	test   %eax,%eax
  8022b1:	78 16                	js     8022c9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022b3:	83 f8 04             	cmp    $0x4,%eax
  8022b6:	74 0c                	je     8022c4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022bb:	88 02                	mov    %al,(%edx)
	return 1;
  8022bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c2:	eb 05                	jmp    8022c9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022c4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    

008022cb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022d7:	6a 01                	push   $0x1
  8022d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022dc:	50                   	push   %eax
  8022dd:	e8 65 e9 ff ff       	call   800c47 <sys_cputs>
}
  8022e2:	83 c4 10             	add    $0x10,%esp
  8022e5:	c9                   	leave  
  8022e6:	c3                   	ret    

008022e7 <getchar>:

int
getchar(void)
{
  8022e7:	55                   	push   %ebp
  8022e8:	89 e5                	mov    %esp,%ebp
  8022ea:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022ed:	6a 01                	push   $0x1
  8022ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022f2:	50                   	push   %eax
  8022f3:	6a 00                	push   $0x0
  8022f5:	e8 25 f2 ff ff       	call   80151f <read>
	if (r < 0)
  8022fa:	83 c4 10             	add    $0x10,%esp
  8022fd:	85 c0                	test   %eax,%eax
  8022ff:	78 0f                	js     802310 <getchar+0x29>
		return r;
	if (r < 1)
  802301:	85 c0                	test   %eax,%eax
  802303:	7e 06                	jle    80230b <getchar+0x24>
		return -E_EOF;
	return c;
  802305:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802309:	eb 05                	jmp    802310 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80230b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802310:	c9                   	leave  
  802311:	c3                   	ret    

00802312 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80231b:	50                   	push   %eax
  80231c:	ff 75 08             	pushl  0x8(%ebp)
  80231f:	e8 95 ef ff ff       	call   8012b9 <fd_lookup>
  802324:	83 c4 10             	add    $0x10,%esp
  802327:	85 c0                	test   %eax,%eax
  802329:	78 11                	js     80233c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80232b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802334:	39 10                	cmp    %edx,(%eax)
  802336:	0f 94 c0             	sete   %al
  802339:	0f b6 c0             	movzbl %al,%eax
}
  80233c:	c9                   	leave  
  80233d:	c3                   	ret    

0080233e <opencons>:

int
opencons(void)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802347:	50                   	push   %eax
  802348:	e8 1d ef ff ff       	call   80126a <fd_alloc>
  80234d:	83 c4 10             	add    $0x10,%esp
		return r;
  802350:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802352:	85 c0                	test   %eax,%eax
  802354:	78 3e                	js     802394 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802356:	83 ec 04             	sub    $0x4,%esp
  802359:	68 07 04 00 00       	push   $0x407
  80235e:	ff 75 f4             	pushl  -0xc(%ebp)
  802361:	6a 00                	push   $0x0
  802363:	e8 9b e9 ff ff       	call   800d03 <sys_page_alloc>
  802368:	83 c4 10             	add    $0x10,%esp
		return r;
  80236b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 23                	js     802394 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802371:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802377:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802386:	83 ec 0c             	sub    $0xc,%esp
  802389:	50                   	push   %eax
  80238a:	e8 b4 ee ff ff       	call   801243 <fd2num>
  80238f:	89 c2                	mov    %eax,%edx
  802391:	83 c4 10             	add    $0x10,%esp
}
  802394:	89 d0                	mov    %edx,%eax
  802396:	c9                   	leave  
  802397:	c3                   	ret    

00802398 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
  80239b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80239e:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023a5:	75 2c                	jne    8023d3 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8023a7:	83 ec 04             	sub    $0x4,%esp
  8023aa:	6a 07                	push   $0x7
  8023ac:	68 00 f0 bf ee       	push   $0xeebff000
  8023b1:	6a 00                	push   $0x0
  8023b3:	e8 4b e9 ff ff       	call   800d03 <sys_page_alloc>
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	79 14                	jns    8023d3 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  8023bf:	83 ec 04             	sub    $0x4,%esp
  8023c2:	68 86 2e 80 00       	push   $0x802e86
  8023c7:	6a 22                	push   $0x22
  8023c9:	68 9d 2e 80 00       	push   $0x802e9d
  8023ce:	e8 cf de ff ff       	call   8002a2 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  8023d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d6:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8023db:	83 ec 08             	sub    $0x8,%esp
  8023de:	68 07 24 80 00       	push   $0x802407
  8023e3:	6a 00                	push   $0x0
  8023e5:	e8 64 ea ff ff       	call   800e4e <sys_env_set_pgfault_upcall>
  8023ea:	83 c4 10             	add    $0x10,%esp
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	79 14                	jns    802405 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8023f1:	83 ec 04             	sub    $0x4,%esp
  8023f4:	68 ac 2e 80 00       	push   $0x802eac
  8023f9:	6a 27                	push   $0x27
  8023fb:	68 9d 2e 80 00       	push   $0x802e9d
  802400:	e8 9d de ff ff       	call   8002a2 <_panic>
    
}
  802405:	c9                   	leave  
  802406:	c3                   	ret    

00802407 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802407:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802408:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80240d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80240f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  802412:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  802416:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  80241b:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80241f:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802421:	83 c4 08             	add    $0x8,%esp
	popal
  802424:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  802425:	83 c4 04             	add    $0x4,%esp
	popfl
  802428:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802429:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80242a:	c3                   	ret    

0080242b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	56                   	push   %esi
  80242f:	53                   	push   %ebx
  802430:	8b 75 08             	mov    0x8(%ebp),%esi
  802433:	8b 45 0c             	mov    0xc(%ebp),%eax
  802436:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802439:	85 c0                	test   %eax,%eax
  80243b:	74 0e                	je     80244b <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  80243d:	83 ec 0c             	sub    $0xc,%esp
  802440:	50                   	push   %eax
  802441:	e8 6d ea ff ff       	call   800eb3 <sys_ipc_recv>
  802446:	83 c4 10             	add    $0x10,%esp
  802449:	eb 10                	jmp    80245b <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80244b:	83 ec 0c             	sub    $0xc,%esp
  80244e:	68 00 00 00 f0       	push   $0xf0000000
  802453:	e8 5b ea ff ff       	call   800eb3 <sys_ipc_recv>
  802458:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80245b:	85 c0                	test   %eax,%eax
  80245d:	74 0e                	je     80246d <ipc_recv+0x42>
    	*from_env_store = 0;
  80245f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802465:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  80246b:	eb 24                	jmp    802491 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  80246d:	85 f6                	test   %esi,%esi
  80246f:	74 0a                	je     80247b <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802471:	a1 08 40 80 00       	mov    0x804008,%eax
  802476:	8b 40 74             	mov    0x74(%eax),%eax
  802479:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  80247b:	85 db                	test   %ebx,%ebx
  80247d:	74 0a                	je     802489 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  80247f:	a1 08 40 80 00       	mov    0x804008,%eax
  802484:	8b 40 78             	mov    0x78(%eax),%eax
  802487:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802489:	a1 08 40 80 00       	mov    0x804008,%eax
  80248e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802491:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802494:	5b                   	pop    %ebx
  802495:	5e                   	pop    %esi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    

00802498 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802498:	55                   	push   %ebp
  802499:	89 e5                	mov    %esp,%ebp
  80249b:	57                   	push   %edi
  80249c:	56                   	push   %esi
  80249d:	53                   	push   %ebx
  80249e:	83 ec 0c             	sub    $0xc,%esp
  8024a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8024aa:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8024ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8024b1:	0f 44 d8             	cmove  %eax,%ebx
  8024b4:	eb 1c                	jmp    8024d2 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8024b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024b9:	74 12                	je     8024cd <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8024bb:	50                   	push   %eax
  8024bc:	68 d0 2e 80 00       	push   $0x802ed0
  8024c1:	6a 4b                	push   $0x4b
  8024c3:	68 e8 2e 80 00       	push   $0x802ee8
  8024c8:	e8 d5 dd ff ff       	call   8002a2 <_panic>
        }	
        sys_yield();
  8024cd:	e8 12 e8 ff ff       	call   800ce4 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8024d2:	ff 75 14             	pushl  0x14(%ebp)
  8024d5:	53                   	push   %ebx
  8024d6:	56                   	push   %esi
  8024d7:	57                   	push   %edi
  8024d8:	e8 b3 e9 ff ff       	call   800e90 <sys_ipc_try_send>
  8024dd:	83 c4 10             	add    $0x10,%esp
  8024e0:	85 c0                	test   %eax,%eax
  8024e2:	75 d2                	jne    8024b6 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8024e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e7:	5b                   	pop    %ebx
  8024e8:	5e                   	pop    %esi
  8024e9:	5f                   	pop    %edi
  8024ea:	5d                   	pop    %ebp
  8024eb:	c3                   	ret    

008024ec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024ec:	55                   	push   %ebp
  8024ed:	89 e5                	mov    %esp,%ebp
  8024ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024f2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024f7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024fa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802500:	8b 52 50             	mov    0x50(%edx),%edx
  802503:	39 ca                	cmp    %ecx,%edx
  802505:	75 0d                	jne    802514 <ipc_find_env+0x28>
			return envs[i].env_id;
  802507:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80250a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80250f:	8b 40 48             	mov    0x48(%eax),%eax
  802512:	eb 0f                	jmp    802523 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802514:	83 c0 01             	add    $0x1,%eax
  802517:	3d 00 04 00 00       	cmp    $0x400,%eax
  80251c:	75 d9                	jne    8024f7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80251e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    

00802525 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	c1 e8 16             	shr    $0x16,%eax
  802530:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802537:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80253c:	f6 c1 01             	test   $0x1,%cl
  80253f:	74 1d                	je     80255e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802541:	c1 ea 0c             	shr    $0xc,%edx
  802544:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80254b:	f6 c2 01             	test   $0x1,%dl
  80254e:	74 0e                	je     80255e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802550:	c1 ea 0c             	shr    $0xc,%edx
  802553:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80255a:	ef 
  80255b:	0f b7 c0             	movzwl %ax,%eax
}
  80255e:	5d                   	pop    %ebp
  80255f:	c3                   	ret    

00802560 <__udivdi3>:
  802560:	55                   	push   %ebp
  802561:	57                   	push   %edi
  802562:	56                   	push   %esi
  802563:	53                   	push   %ebx
  802564:	83 ec 1c             	sub    $0x1c,%esp
  802567:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80256b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80256f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802573:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802577:	85 f6                	test   %esi,%esi
  802579:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80257d:	89 ca                	mov    %ecx,%edx
  80257f:	89 f8                	mov    %edi,%eax
  802581:	75 3d                	jne    8025c0 <__udivdi3+0x60>
  802583:	39 cf                	cmp    %ecx,%edi
  802585:	0f 87 c5 00 00 00    	ja     802650 <__udivdi3+0xf0>
  80258b:	85 ff                	test   %edi,%edi
  80258d:	89 fd                	mov    %edi,%ebp
  80258f:	75 0b                	jne    80259c <__udivdi3+0x3c>
  802591:	b8 01 00 00 00       	mov    $0x1,%eax
  802596:	31 d2                	xor    %edx,%edx
  802598:	f7 f7                	div    %edi
  80259a:	89 c5                	mov    %eax,%ebp
  80259c:	89 c8                	mov    %ecx,%eax
  80259e:	31 d2                	xor    %edx,%edx
  8025a0:	f7 f5                	div    %ebp
  8025a2:	89 c1                	mov    %eax,%ecx
  8025a4:	89 d8                	mov    %ebx,%eax
  8025a6:	89 cf                	mov    %ecx,%edi
  8025a8:	f7 f5                	div    %ebp
  8025aa:	89 c3                	mov    %eax,%ebx
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
  8025c0:	39 ce                	cmp    %ecx,%esi
  8025c2:	77 74                	ja     802638 <__udivdi3+0xd8>
  8025c4:	0f bd fe             	bsr    %esi,%edi
  8025c7:	83 f7 1f             	xor    $0x1f,%edi
  8025ca:	0f 84 98 00 00 00    	je     802668 <__udivdi3+0x108>
  8025d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025d5:	89 f9                	mov    %edi,%ecx
  8025d7:	89 c5                	mov    %eax,%ebp
  8025d9:	29 fb                	sub    %edi,%ebx
  8025db:	d3 e6                	shl    %cl,%esi
  8025dd:	89 d9                	mov    %ebx,%ecx
  8025df:	d3 ed                	shr    %cl,%ebp
  8025e1:	89 f9                	mov    %edi,%ecx
  8025e3:	d3 e0                	shl    %cl,%eax
  8025e5:	09 ee                	or     %ebp,%esi
  8025e7:	89 d9                	mov    %ebx,%ecx
  8025e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025ed:	89 d5                	mov    %edx,%ebp
  8025ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025f3:	d3 ed                	shr    %cl,%ebp
  8025f5:	89 f9                	mov    %edi,%ecx
  8025f7:	d3 e2                	shl    %cl,%edx
  8025f9:	89 d9                	mov    %ebx,%ecx
  8025fb:	d3 e8                	shr    %cl,%eax
  8025fd:	09 c2                	or     %eax,%edx
  8025ff:	89 d0                	mov    %edx,%eax
  802601:	89 ea                	mov    %ebp,%edx
  802603:	f7 f6                	div    %esi
  802605:	89 d5                	mov    %edx,%ebp
  802607:	89 c3                	mov    %eax,%ebx
  802609:	f7 64 24 0c          	mull   0xc(%esp)
  80260d:	39 d5                	cmp    %edx,%ebp
  80260f:	72 10                	jb     802621 <__udivdi3+0xc1>
  802611:	8b 74 24 08          	mov    0x8(%esp),%esi
  802615:	89 f9                	mov    %edi,%ecx
  802617:	d3 e6                	shl    %cl,%esi
  802619:	39 c6                	cmp    %eax,%esi
  80261b:	73 07                	jae    802624 <__udivdi3+0xc4>
  80261d:	39 d5                	cmp    %edx,%ebp
  80261f:	75 03                	jne    802624 <__udivdi3+0xc4>
  802621:	83 eb 01             	sub    $0x1,%ebx
  802624:	31 ff                	xor    %edi,%edi
  802626:	89 d8                	mov    %ebx,%eax
  802628:	89 fa                	mov    %edi,%edx
  80262a:	83 c4 1c             	add    $0x1c,%esp
  80262d:	5b                   	pop    %ebx
  80262e:	5e                   	pop    %esi
  80262f:	5f                   	pop    %edi
  802630:	5d                   	pop    %ebp
  802631:	c3                   	ret    
  802632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802638:	31 ff                	xor    %edi,%edi
  80263a:	31 db                	xor    %ebx,%ebx
  80263c:	89 d8                	mov    %ebx,%eax
  80263e:	89 fa                	mov    %edi,%edx
  802640:	83 c4 1c             	add    $0x1c,%esp
  802643:	5b                   	pop    %ebx
  802644:	5e                   	pop    %esi
  802645:	5f                   	pop    %edi
  802646:	5d                   	pop    %ebp
  802647:	c3                   	ret    
  802648:	90                   	nop
  802649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802650:	89 d8                	mov    %ebx,%eax
  802652:	f7 f7                	div    %edi
  802654:	31 ff                	xor    %edi,%edi
  802656:	89 c3                	mov    %eax,%ebx
  802658:	89 d8                	mov    %ebx,%eax
  80265a:	89 fa                	mov    %edi,%edx
  80265c:	83 c4 1c             	add    $0x1c,%esp
  80265f:	5b                   	pop    %ebx
  802660:	5e                   	pop    %esi
  802661:	5f                   	pop    %edi
  802662:	5d                   	pop    %ebp
  802663:	c3                   	ret    
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	39 ce                	cmp    %ecx,%esi
  80266a:	72 0c                	jb     802678 <__udivdi3+0x118>
  80266c:	31 db                	xor    %ebx,%ebx
  80266e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802672:	0f 87 34 ff ff ff    	ja     8025ac <__udivdi3+0x4c>
  802678:	bb 01 00 00 00       	mov    $0x1,%ebx
  80267d:	e9 2a ff ff ff       	jmp    8025ac <__udivdi3+0x4c>
  802682:	66 90                	xchg   %ax,%ax
  802684:	66 90                	xchg   %ax,%ax
  802686:	66 90                	xchg   %ax,%ax
  802688:	66 90                	xchg   %ax,%ax
  80268a:	66 90                	xchg   %ax,%ax
  80268c:	66 90                	xchg   %ax,%ax
  80268e:	66 90                	xchg   %ax,%ax

00802690 <__umoddi3>:
  802690:	55                   	push   %ebp
  802691:	57                   	push   %edi
  802692:	56                   	push   %esi
  802693:	53                   	push   %ebx
  802694:	83 ec 1c             	sub    $0x1c,%esp
  802697:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80269b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80269f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026a7:	85 d2                	test   %edx,%edx
  8026a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026b1:	89 f3                	mov    %esi,%ebx
  8026b3:	89 3c 24             	mov    %edi,(%esp)
  8026b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ba:	75 1c                	jne    8026d8 <__umoddi3+0x48>
  8026bc:	39 f7                	cmp    %esi,%edi
  8026be:	76 50                	jbe    802710 <__umoddi3+0x80>
  8026c0:	89 c8                	mov    %ecx,%eax
  8026c2:	89 f2                	mov    %esi,%edx
  8026c4:	f7 f7                	div    %edi
  8026c6:	89 d0                	mov    %edx,%eax
  8026c8:	31 d2                	xor    %edx,%edx
  8026ca:	83 c4 1c             	add    $0x1c,%esp
  8026cd:	5b                   	pop    %ebx
  8026ce:	5e                   	pop    %esi
  8026cf:	5f                   	pop    %edi
  8026d0:	5d                   	pop    %ebp
  8026d1:	c3                   	ret    
  8026d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026d8:	39 f2                	cmp    %esi,%edx
  8026da:	89 d0                	mov    %edx,%eax
  8026dc:	77 52                	ja     802730 <__umoddi3+0xa0>
  8026de:	0f bd ea             	bsr    %edx,%ebp
  8026e1:	83 f5 1f             	xor    $0x1f,%ebp
  8026e4:	75 5a                	jne    802740 <__umoddi3+0xb0>
  8026e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026ea:	0f 82 e0 00 00 00    	jb     8027d0 <__umoddi3+0x140>
  8026f0:	39 0c 24             	cmp    %ecx,(%esp)
  8026f3:	0f 86 d7 00 00 00    	jbe    8027d0 <__umoddi3+0x140>
  8026f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802701:	83 c4 1c             	add    $0x1c,%esp
  802704:	5b                   	pop    %ebx
  802705:	5e                   	pop    %esi
  802706:	5f                   	pop    %edi
  802707:	5d                   	pop    %ebp
  802708:	c3                   	ret    
  802709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802710:	85 ff                	test   %edi,%edi
  802712:	89 fd                	mov    %edi,%ebp
  802714:	75 0b                	jne    802721 <__umoddi3+0x91>
  802716:	b8 01 00 00 00       	mov    $0x1,%eax
  80271b:	31 d2                	xor    %edx,%edx
  80271d:	f7 f7                	div    %edi
  80271f:	89 c5                	mov    %eax,%ebp
  802721:	89 f0                	mov    %esi,%eax
  802723:	31 d2                	xor    %edx,%edx
  802725:	f7 f5                	div    %ebp
  802727:	89 c8                	mov    %ecx,%eax
  802729:	f7 f5                	div    %ebp
  80272b:	89 d0                	mov    %edx,%eax
  80272d:	eb 99                	jmp    8026c8 <__umoddi3+0x38>
  80272f:	90                   	nop
  802730:	89 c8                	mov    %ecx,%eax
  802732:	89 f2                	mov    %esi,%edx
  802734:	83 c4 1c             	add    $0x1c,%esp
  802737:	5b                   	pop    %ebx
  802738:	5e                   	pop    %esi
  802739:	5f                   	pop    %edi
  80273a:	5d                   	pop    %ebp
  80273b:	c3                   	ret    
  80273c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802740:	8b 34 24             	mov    (%esp),%esi
  802743:	bf 20 00 00 00       	mov    $0x20,%edi
  802748:	89 e9                	mov    %ebp,%ecx
  80274a:	29 ef                	sub    %ebp,%edi
  80274c:	d3 e0                	shl    %cl,%eax
  80274e:	89 f9                	mov    %edi,%ecx
  802750:	89 f2                	mov    %esi,%edx
  802752:	d3 ea                	shr    %cl,%edx
  802754:	89 e9                	mov    %ebp,%ecx
  802756:	09 c2                	or     %eax,%edx
  802758:	89 d8                	mov    %ebx,%eax
  80275a:	89 14 24             	mov    %edx,(%esp)
  80275d:	89 f2                	mov    %esi,%edx
  80275f:	d3 e2                	shl    %cl,%edx
  802761:	89 f9                	mov    %edi,%ecx
  802763:	89 54 24 04          	mov    %edx,0x4(%esp)
  802767:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80276b:	d3 e8                	shr    %cl,%eax
  80276d:	89 e9                	mov    %ebp,%ecx
  80276f:	89 c6                	mov    %eax,%esi
  802771:	d3 e3                	shl    %cl,%ebx
  802773:	89 f9                	mov    %edi,%ecx
  802775:	89 d0                	mov    %edx,%eax
  802777:	d3 e8                	shr    %cl,%eax
  802779:	89 e9                	mov    %ebp,%ecx
  80277b:	09 d8                	or     %ebx,%eax
  80277d:	89 d3                	mov    %edx,%ebx
  80277f:	89 f2                	mov    %esi,%edx
  802781:	f7 34 24             	divl   (%esp)
  802784:	89 d6                	mov    %edx,%esi
  802786:	d3 e3                	shl    %cl,%ebx
  802788:	f7 64 24 04          	mull   0x4(%esp)
  80278c:	39 d6                	cmp    %edx,%esi
  80278e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802792:	89 d1                	mov    %edx,%ecx
  802794:	89 c3                	mov    %eax,%ebx
  802796:	72 08                	jb     8027a0 <__umoddi3+0x110>
  802798:	75 11                	jne    8027ab <__umoddi3+0x11b>
  80279a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80279e:	73 0b                	jae    8027ab <__umoddi3+0x11b>
  8027a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027a4:	1b 14 24             	sbb    (%esp),%edx
  8027a7:	89 d1                	mov    %edx,%ecx
  8027a9:	89 c3                	mov    %eax,%ebx
  8027ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027af:	29 da                	sub    %ebx,%edx
  8027b1:	19 ce                	sbb    %ecx,%esi
  8027b3:	89 f9                	mov    %edi,%ecx
  8027b5:	89 f0                	mov    %esi,%eax
  8027b7:	d3 e0                	shl    %cl,%eax
  8027b9:	89 e9                	mov    %ebp,%ecx
  8027bb:	d3 ea                	shr    %cl,%edx
  8027bd:	89 e9                	mov    %ebp,%ecx
  8027bf:	d3 ee                	shr    %cl,%esi
  8027c1:	09 d0                	or     %edx,%eax
  8027c3:	89 f2                	mov    %esi,%edx
  8027c5:	83 c4 1c             	add    $0x1c,%esp
  8027c8:	5b                   	pop    %ebx
  8027c9:	5e                   	pop    %esi
  8027ca:	5f                   	pop    %edi
  8027cb:	5d                   	pop    %ebp
  8027cc:	c3                   	ret    
  8027cd:	8d 76 00             	lea    0x0(%esi),%esi
  8027d0:	29 f9                	sub    %edi,%ecx
  8027d2:	19 d6                	sbb    %edx,%esi
  8027d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027dc:	e9 18 ff ff ff       	jmp    8026f9 <__umoddi3+0x69>
