
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 40 80 00 c0 	movl   $0x8028c0,0x804004
  800042:	28 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 bb 20 00 00       	call   802109 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 cc 28 80 00       	push   $0x8028cc
  80005d:	6a 0e                	push   $0xe
  80005f:	68 d5 28 80 00       	push   $0x8028d5
  800064:	e8 b3 02 00 00       	call   80031c <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 3a 10 00 00       	call   8010a8 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 e5 28 80 00       	push   $0x8028e5
  80007a:	6a 11                	push   $0x11
  80007c:	68 d5 28 80 00       	push   $0x8028d5
  800081:	e8 96 02 00 00       	call   80031c <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 08 50 80 00       	mov    0x805008,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ee 28 80 00       	push   $0x8028ee
  8000a2:	e8 4e 03 00 00       	call   8003f5 <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 ab 13 00 00       	call   80145d <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 08 50 80 00       	mov    0x805008,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 0b 29 80 00       	push   $0x80290b
  8000c6:	e8 2a 03 00 00       	call   8003f5 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 4e 15 00 00       	call   80162a <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 28 29 80 00       	push   $0x802928
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 d5 28 80 00       	push   $0x8028d5
  8000f2:	e8 25 02 00 00       	call   80031c <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 40 80 00    	pushl  0x804000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 16 09 00 00       	call   800a24 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 31 29 80 00       	push   $0x802931
  80011d:	e8 d3 02 00 00       	call   8003f5 <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 4d 29 80 00       	push   $0x80294d
  800134:	e8 bc 02 00 00       	call   8003f5 <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 c1 01 00 00       	call   800302 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 08 50 80 00       	mov    0x805008,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ee 28 80 00       	push   $0x8028ee
  80015a:	e8 96 02 00 00       	call   8003f5 <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 f3 12 00 00       	call   80145d <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 08 50 80 00       	mov    0x805008,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 60 29 80 00       	push   $0x802960
  80017e:	e8 72 02 00 00       	call   8003f5 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 40 80 00    	pushl  0x804000
  80018c:	e8 b0 07 00 00       	call   800941 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 40 80 00    	pushl  0x804000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 d0 14 00 00       	call   801673 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 40 80 00    	pushl  0x804000
  8001ae:	e8 8e 07 00 00       	call   800941 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 7d 29 80 00       	push   $0x80297d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 d5 28 80 00       	push   $0x8028d5
  8001c7:	e8 50 01 00 00       	call   80031c <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 86 12 00 00       	call   80145d <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 ac 20 00 00       	call   80228f <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 40 80 00 87 	movl   $0x802987,0x804004
  8001ea:	29 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 11 1f 00 00       	call   802109 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 cc 28 80 00       	push   $0x8028cc
  800207:	6a 2c                	push   $0x2c
  800209:	68 d5 28 80 00       	push   $0x8028d5
  80020e:	e8 09 01 00 00       	call   80031c <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 90 0e 00 00       	call   8010a8 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 e5 28 80 00       	push   $0x8028e5
  800224:	6a 2f                	push   $0x2f
  800226:	68 d5 28 80 00       	push   $0x8028d5
  80022b:	e8 ec 00 00 00       	call   80031c <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 1e 12 00 00       	call   80145d <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 94 29 80 00       	push   $0x802994
  80024a:	e8 a6 01 00 00       	call   8003f5 <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 96 29 80 00       	push   $0x802996
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 12 14 00 00       	call   801673 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 98 29 80 00       	push   $0x802998
  800271:	e8 7f 01 00 00       	call   8003f5 <cprintf>
		exit();
  800276:	e8 87 00 00 00       	call   800302 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 d4 11 00 00       	call   80145d <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 c9 11 00 00       	call   80145d <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 f3 1f 00 00       	call   80228f <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 b5 29 80 00 	movl   $0x8029b5,(%esp)
  8002a3:	e8 4d 01 00 00       	call   8003f5 <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8002bd:	c7 05 08 50 80 00 00 	movl   $0x0,0x805008
  8002c4:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8002c7:	e8 73 0a 00 00       	call   800d3f <sys_getenvid>
  8002cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002d9:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002de:	85 db                	test   %ebx,%ebx
  8002e0:	7e 07                	jle    8002e9 <libmain+0x37>
		binaryname = argv[0];
  8002e2:	8b 06                	mov    (%esi),%eax
  8002e4:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	e8 40 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002f3:	e8 0a 00 00 00       	call   800302 <exit>
}
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800308:	e8 7b 11 00 00       	call   801488 <close_all>
	sys_env_destroy(0);
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	6a 00                	push   $0x0
  800312:	e8 e7 09 00 00       	call   800cfe <sys_env_destroy>
}
  800317:	83 c4 10             	add    $0x10,%esp
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800321:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800324:	8b 35 04 40 80 00    	mov    0x804004,%esi
  80032a:	e8 10 0a 00 00       	call   800d3f <sys_getenvid>
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	ff 75 0c             	pushl  0xc(%ebp)
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	56                   	push   %esi
  800339:	50                   	push   %eax
  80033a:	68 18 2a 80 00       	push   $0x802a18
  80033f:	e8 b1 00 00 00       	call   8003f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800344:	83 c4 18             	add    $0x18,%esp
  800347:	53                   	push   %ebx
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	e8 54 00 00 00       	call   8003a4 <vcprintf>
	cprintf("\n");
  800350:	c7 04 24 9a 2d 80 00 	movl   $0x802d9a,(%esp)
  800357:	e8 99 00 00 00       	call   8003f5 <cprintf>
  80035c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035f:	cc                   	int3   
  800360:	eb fd                	jmp    80035f <_panic+0x43>

00800362 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	53                   	push   %ebx
  800366:	83 ec 04             	sub    $0x4,%esp
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036c:	8b 13                	mov    (%ebx),%edx
  80036e:	8d 42 01             	lea    0x1(%edx),%eax
  800371:	89 03                	mov    %eax,(%ebx)
  800373:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800376:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80037a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037f:	75 1a                	jne    80039b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	68 ff 00 00 00       	push   $0xff
  800389:	8d 43 08             	lea    0x8(%ebx),%eax
  80038c:	50                   	push   %eax
  80038d:	e8 2f 09 00 00       	call   800cc1 <sys_cputs>
		b->idx = 0;
  800392:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800398:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80039b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b4:	00 00 00 
	b.cnt = 0;
  8003b7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003be:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c1:	ff 75 0c             	pushl  0xc(%ebp)
  8003c4:	ff 75 08             	pushl  0x8(%ebp)
  8003c7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003cd:	50                   	push   %eax
  8003ce:	68 62 03 80 00       	push   $0x800362
  8003d3:	e8 54 01 00 00       	call   80052c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d8:	83 c4 08             	add    $0x8,%esp
  8003db:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e7:	50                   	push   %eax
  8003e8:	e8 d4 08 00 00       	call   800cc1 <sys_cputs>

	return b.cnt;
}
  8003ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fe:	50                   	push   %eax
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	e8 9d ff ff ff       	call   8003a4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800407:	c9                   	leave  
  800408:	c3                   	ret    

00800409 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	57                   	push   %edi
  80040d:	56                   	push   %esi
  80040e:	53                   	push   %ebx
  80040f:	83 ec 1c             	sub    $0x1c,%esp
  800412:	89 c7                	mov    %eax,%edi
  800414:	89 d6                	mov    %edx,%esi
  800416:	8b 45 08             	mov    0x8(%ebp),%eax
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800422:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800425:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80042d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800430:	39 d3                	cmp    %edx,%ebx
  800432:	72 05                	jb     800439 <printnum+0x30>
  800434:	39 45 10             	cmp    %eax,0x10(%ebp)
  800437:	77 45                	ja     80047e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800439:	83 ec 0c             	sub    $0xc,%esp
  80043c:	ff 75 18             	pushl  0x18(%ebp)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800445:	53                   	push   %ebx
  800446:	ff 75 10             	pushl  0x10(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044f:	ff 75 e0             	pushl  -0x20(%ebp)
  800452:	ff 75 dc             	pushl  -0x24(%ebp)
  800455:	ff 75 d8             	pushl  -0x28(%ebp)
  800458:	e8 d3 21 00 00       	call   802630 <__udivdi3>
  80045d:	83 c4 18             	add    $0x18,%esp
  800460:	52                   	push   %edx
  800461:	50                   	push   %eax
  800462:	89 f2                	mov    %esi,%edx
  800464:	89 f8                	mov    %edi,%eax
  800466:	e8 9e ff ff ff       	call   800409 <printnum>
  80046b:	83 c4 20             	add    $0x20,%esp
  80046e:	eb 18                	jmp    800488 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	56                   	push   %esi
  800474:	ff 75 18             	pushl  0x18(%ebp)
  800477:	ff d7                	call   *%edi
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	eb 03                	jmp    800481 <printnum+0x78>
  80047e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800481:	83 eb 01             	sub    $0x1,%ebx
  800484:	85 db                	test   %ebx,%ebx
  800486:	7f e8                	jg     800470 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	56                   	push   %esi
  80048c:	83 ec 04             	sub    $0x4,%esp
  80048f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800492:	ff 75 e0             	pushl  -0x20(%ebp)
  800495:	ff 75 dc             	pushl  -0x24(%ebp)
  800498:	ff 75 d8             	pushl  -0x28(%ebp)
  80049b:	e8 c0 22 00 00       	call   802760 <__umoddi3>
  8004a0:	83 c4 14             	add    $0x14,%esp
  8004a3:	0f be 80 3b 2a 80 00 	movsbl 0x802a3b(%eax),%eax
  8004aa:	50                   	push   %eax
  8004ab:	ff d7                	call   *%edi
}
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b3:	5b                   	pop    %ebx
  8004b4:	5e                   	pop    %esi
  8004b5:	5f                   	pop    %edi
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bb:	83 fa 01             	cmp    $0x1,%edx
  8004be:	7e 0e                	jle    8004ce <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	8b 52 04             	mov    0x4(%edx),%edx
  8004cc:	eb 22                	jmp    8004f0 <getuint+0x38>
	else if (lflag)
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	74 10                	je     8004e2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d7:	89 08                	mov    %ecx,(%eax)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e0:	eb 0e                	jmp    8004f0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fc:	8b 10                	mov    (%eax),%edx
  8004fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800501:	73 0a                	jae    80050d <sprintputch+0x1b>
		*b->buf++ = ch;
  800503:	8d 4a 01             	lea    0x1(%edx),%ecx
  800506:	89 08                	mov    %ecx,(%eax)
  800508:	8b 45 08             	mov    0x8(%ebp),%eax
  80050b:	88 02                	mov    %al,(%edx)
}
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    

0080050f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800515:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800518:	50                   	push   %eax
  800519:	ff 75 10             	pushl  0x10(%ebp)
  80051c:	ff 75 0c             	pushl  0xc(%ebp)
  80051f:	ff 75 08             	pushl  0x8(%ebp)
  800522:	e8 05 00 00 00       	call   80052c <vprintfmt>
	va_end(ap);
}
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	57                   	push   %edi
  800530:	56                   	push   %esi
  800531:	53                   	push   %ebx
  800532:	83 ec 2c             	sub    $0x2c,%esp
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053e:	eb 12                	jmp    800552 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800540:	85 c0                	test   %eax,%eax
  800542:	0f 84 89 03 00 00    	je     8008d1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	50                   	push   %eax
  80054d:	ff d6                	call   *%esi
  80054f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800552:	83 c7 01             	add    $0x1,%edi
  800555:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800559:	83 f8 25             	cmp    $0x25,%eax
  80055c:	75 e2                	jne    800540 <vprintfmt+0x14>
  80055e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800562:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800569:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800570:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800577:	ba 00 00 00 00       	mov    $0x0,%edx
  80057c:	eb 07                	jmp    800585 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800581:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8d 47 01             	lea    0x1(%edi),%eax
  800588:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058b:	0f b6 07             	movzbl (%edi),%eax
  80058e:	0f b6 c8             	movzbl %al,%ecx
  800591:	83 e8 23             	sub    $0x23,%eax
  800594:	3c 55                	cmp    $0x55,%al
  800596:	0f 87 1a 03 00 00    	ja     8008b6 <vprintfmt+0x38a>
  80059c:	0f b6 c0             	movzbl %al,%eax
  80059f:	ff 24 85 80 2b 80 00 	jmp    *0x802b80(,%eax,4)
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005ad:	eb d6                	jmp    800585 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ba:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005bd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005c4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005c7:	83 fa 09             	cmp    $0x9,%edx
  8005ca:	77 39                	ja     800605 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005cf:	eb e9                	jmp    8005ba <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005d7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e2:	eb 27                	jmp    80060b <vprintfmt+0xdf>
  8005e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ee:	0f 49 c8             	cmovns %eax,%ecx
  8005f1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f7:	eb 8c                	jmp    800585 <vprintfmt+0x59>
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800603:	eb 80                	jmp    800585 <vprintfmt+0x59>
  800605:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800608:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80060b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060f:	0f 89 70 ff ff ff    	jns    800585 <vprintfmt+0x59>
				width = precision, precision = -1;
  800615:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800618:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800622:	e9 5e ff ff ff       	jmp    800585 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800627:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062d:	e9 53 ff ff ff       	jmp    800585 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	ff 30                	pushl  (%eax)
  800641:	ff d6                	call   *%esi
			break;
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800649:	e9 04 ff ff ff       	jmp    800552 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 00                	mov    (%eax),%eax
  800659:	99                   	cltd   
  80065a:	31 d0                	xor    %edx,%eax
  80065c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065e:	83 f8 0f             	cmp    $0xf,%eax
  800661:	7f 0b                	jg     80066e <vprintfmt+0x142>
  800663:	8b 14 85 e0 2c 80 00 	mov    0x802ce0(,%eax,4),%edx
  80066a:	85 d2                	test   %edx,%edx
  80066c:	75 18                	jne    800686 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80066e:	50                   	push   %eax
  80066f:	68 53 2a 80 00       	push   $0x802a53
  800674:	53                   	push   %ebx
  800675:	56                   	push   %esi
  800676:	e8 94 fe ff ff       	call   80050f <printfmt>
  80067b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800681:	e9 cc fe ff ff       	jmp    800552 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800686:	52                   	push   %edx
  800687:	68 6d 2f 80 00       	push   $0x802f6d
  80068c:	53                   	push   %ebx
  80068d:	56                   	push   %esi
  80068e:	e8 7c fe ff ff       	call   80050f <printfmt>
  800693:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800699:	e9 b4 fe ff ff       	jmp    800552 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a9:	85 ff                	test   %edi,%edi
  8006ab:	b8 4c 2a 80 00       	mov    $0x802a4c,%eax
  8006b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b7:	0f 8e 94 00 00 00    	jle    800751 <vprintfmt+0x225>
  8006bd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c1:	0f 84 98 00 00 00    	je     80075f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	ff 75 d0             	pushl  -0x30(%ebp)
  8006cd:	57                   	push   %edi
  8006ce:	e8 86 02 00 00       	call   800959 <strnlen>
  8006d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d6:	29 c1                	sub    %eax,%ecx
  8006d8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006db:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006de:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ea:	eb 0f                	jmp    8006fb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	53                   	push   %ebx
  8006f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	85 ff                	test   %edi,%edi
  8006fd:	7f ed                	jg     8006ec <vprintfmt+0x1c0>
  8006ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800702:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800705:	85 c9                	test   %ecx,%ecx
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
  80070c:	0f 49 c1             	cmovns %ecx,%eax
  80070f:	29 c1                	sub    %eax,%ecx
  800711:	89 75 08             	mov    %esi,0x8(%ebp)
  800714:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800717:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071a:	89 cb                	mov    %ecx,%ebx
  80071c:	eb 4d                	jmp    80076b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800722:	74 1b                	je     80073f <vprintfmt+0x213>
  800724:	0f be c0             	movsbl %al,%eax
  800727:	83 e8 20             	sub    $0x20,%eax
  80072a:	83 f8 5e             	cmp    $0x5e,%eax
  80072d:	76 10                	jbe    80073f <vprintfmt+0x213>
					putch('?', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	6a 3f                	push   $0x3f
  800737:	ff 55 08             	call   *0x8(%ebp)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	eb 0d                	jmp    80074c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	52                   	push   %edx
  800746:	ff 55 08             	call   *0x8(%ebp)
  800749:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074c:	83 eb 01             	sub    $0x1,%ebx
  80074f:	eb 1a                	jmp    80076b <vprintfmt+0x23f>
  800751:	89 75 08             	mov    %esi,0x8(%ebp)
  800754:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800757:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075d:	eb 0c                	jmp    80076b <vprintfmt+0x23f>
  80075f:	89 75 08             	mov    %esi,0x8(%ebp)
  800762:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800765:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800768:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076b:	83 c7 01             	add    $0x1,%edi
  80076e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800772:	0f be d0             	movsbl %al,%edx
  800775:	85 d2                	test   %edx,%edx
  800777:	74 23                	je     80079c <vprintfmt+0x270>
  800779:	85 f6                	test   %esi,%esi
  80077b:	78 a1                	js     80071e <vprintfmt+0x1f2>
  80077d:	83 ee 01             	sub    $0x1,%esi
  800780:	79 9c                	jns    80071e <vprintfmt+0x1f2>
  800782:	89 df                	mov    %ebx,%edi
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078a:	eb 18                	jmp    8007a4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 20                	push   $0x20
  800792:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800794:	83 ef 01             	sub    $0x1,%edi
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	eb 08                	jmp    8007a4 <vprintfmt+0x278>
  80079c:	89 df                	mov    %ebx,%edi
  80079e:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a4:	85 ff                	test   %edi,%edi
  8007a6:	7f e4                	jg     80078c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ab:	e9 a2 fd ff ff       	jmp    800552 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b0:	83 fa 01             	cmp    $0x1,%edx
  8007b3:	7e 16                	jle    8007cb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 50 08             	lea    0x8(%eax),%edx
  8007bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007be:	8b 50 04             	mov    0x4(%eax),%edx
  8007c1:	8b 00                	mov    (%eax),%eax
  8007c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c9:	eb 32                	jmp    8007fd <vprintfmt+0x2d1>
	else if (lflag)
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	74 18                	je     8007e7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 04             	lea    0x4(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dd:	89 c1                	mov    %eax,%ecx
  8007df:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e5:	eb 16                	jmp    8007fd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8d 50 04             	lea    0x4(%eax),%edx
  8007ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f0:	8b 00                	mov    (%eax),%eax
  8007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f5:	89 c1                	mov    %eax,%ecx
  8007f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800800:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800803:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800808:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80080c:	79 74                	jns    800882 <vprintfmt+0x356>
				putch('-', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	53                   	push   %ebx
  800812:	6a 2d                	push   $0x2d
  800814:	ff d6                	call   *%esi
				num = -(long long) num;
  800816:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800819:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80081c:	f7 d8                	neg    %eax
  80081e:	83 d2 00             	adc    $0x0,%edx
  800821:	f7 da                	neg    %edx
  800823:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800826:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80082b:	eb 55                	jmp    800882 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082d:	8d 45 14             	lea    0x14(%ebp),%eax
  800830:	e8 83 fc ff ff       	call   8004b8 <getuint>
			base = 10;
  800835:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80083a:	eb 46                	jmp    800882 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80083c:	8d 45 14             	lea    0x14(%ebp),%eax
  80083f:	e8 74 fc ff ff       	call   8004b8 <getuint>
		        base = 8;
  800844:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800849:	eb 37                	jmp    800882 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	6a 30                	push   $0x30
  800851:	ff d6                	call   *%esi
			putch('x', putdat);
  800853:	83 c4 08             	add    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 78                	push   $0x78
  800859:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 50 04             	lea    0x4(%eax),%edx
  800861:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800864:	8b 00                	mov    (%eax),%eax
  800866:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80086b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800873:	eb 0d                	jmp    800882 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
  800878:	e8 3b fc ff ff       	call   8004b8 <getuint>
			base = 16;
  80087d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800882:	83 ec 0c             	sub    $0xc,%esp
  800885:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800889:	57                   	push   %edi
  80088a:	ff 75 e0             	pushl  -0x20(%ebp)
  80088d:	51                   	push   %ecx
  80088e:	52                   	push   %edx
  80088f:	50                   	push   %eax
  800890:	89 da                	mov    %ebx,%edx
  800892:	89 f0                	mov    %esi,%eax
  800894:	e8 70 fb ff ff       	call   800409 <printnum>
			break;
  800899:	83 c4 20             	add    $0x20,%esp
  80089c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089f:	e9 ae fc ff ff       	jmp    800552 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	53                   	push   %ebx
  8008a8:	51                   	push   %ecx
  8008a9:	ff d6                	call   *%esi
			break;
  8008ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b1:	e9 9c fc ff ff       	jmp    800552 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	6a 25                	push   $0x25
  8008bc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	eb 03                	jmp    8008c6 <vprintfmt+0x39a>
  8008c3:	83 ef 01             	sub    $0x1,%edi
  8008c6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ca:	75 f7                	jne    8008c3 <vprintfmt+0x397>
  8008cc:	e9 81 fc ff ff       	jmp    800552 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5f                   	pop    %edi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	83 ec 18             	sub    $0x18,%esp
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	74 26                	je     800920 <vsnprintf+0x47>
  8008fa:	85 d2                	test   %edx,%edx
  8008fc:	7e 22                	jle    800920 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008fe:	ff 75 14             	pushl  0x14(%ebp)
  800901:	ff 75 10             	pushl  0x10(%ebp)
  800904:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800907:	50                   	push   %eax
  800908:	68 f2 04 80 00       	push   $0x8004f2
  80090d:	e8 1a fc ff ff       	call   80052c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800912:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800915:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800918:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	eb 05                	jmp    800925 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800920:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80092d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800930:	50                   	push   %eax
  800931:	ff 75 10             	pushl  0x10(%ebp)
  800934:	ff 75 0c             	pushl  0xc(%ebp)
  800937:	ff 75 08             	pushl  0x8(%ebp)
  80093a:	e8 9a ff ff ff       	call   8008d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
  80094c:	eb 03                	jmp    800951 <strlen+0x10>
		n++;
  80094e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800951:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800955:	75 f7                	jne    80094e <strlen+0xd>
		n++;
	return n;
}
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	eb 03                	jmp    80096c <strnlen+0x13>
		n++;
  800969:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096c:	39 c2                	cmp    %eax,%edx
  80096e:	74 08                	je     800978 <strnlen+0x1f>
  800970:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800974:	75 f3                	jne    800969 <strnlen+0x10>
  800976:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800984:	89 c2                	mov    %eax,%edx
  800986:	83 c2 01             	add    $0x1,%edx
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800990:	88 5a ff             	mov    %bl,-0x1(%edx)
  800993:	84 db                	test   %bl,%bl
  800995:	75 ef                	jne    800986 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a1:	53                   	push   %ebx
  8009a2:	e8 9a ff ff ff       	call   800941 <strlen>
  8009a7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009aa:	ff 75 0c             	pushl  0xc(%ebp)
  8009ad:	01 d8                	add    %ebx,%eax
  8009af:	50                   	push   %eax
  8009b0:	e8 c5 ff ff ff       	call   80097a <strcpy>
	return dst;
}
  8009b5:	89 d8                	mov    %ebx,%eax
  8009b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c7:	89 f3                	mov    %esi,%ebx
  8009c9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009cc:	89 f2                	mov    %esi,%edx
  8009ce:	eb 0f                	jmp    8009df <strncpy+0x23>
		*dst++ = *src;
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009dc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009df:	39 da                	cmp    %ebx,%edx
  8009e1:	75 ed                	jne    8009d0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e3:	89 f0                	mov    %esi,%eax
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8009f7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f9:	85 d2                	test   %edx,%edx
  8009fb:	74 21                	je     800a1e <strlcpy+0x35>
  8009fd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a01:	89 f2                	mov    %esi,%edx
  800a03:	eb 09                	jmp    800a0e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a05:	83 c2 01             	add    $0x1,%edx
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a0e:	39 c2                	cmp    %eax,%edx
  800a10:	74 09                	je     800a1b <strlcpy+0x32>
  800a12:	0f b6 19             	movzbl (%ecx),%ebx
  800a15:	84 db                	test   %bl,%bl
  800a17:	75 ec                	jne    800a05 <strlcpy+0x1c>
  800a19:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a1b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a1e:	29 f0                	sub    %esi,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a2d:	eb 06                	jmp    800a35 <strcmp+0x11>
		p++, q++;
  800a2f:	83 c1 01             	add    $0x1,%ecx
  800a32:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a35:	0f b6 01             	movzbl (%ecx),%eax
  800a38:	84 c0                	test   %al,%al
  800a3a:	74 04                	je     800a40 <strcmp+0x1c>
  800a3c:	3a 02                	cmp    (%edx),%al
  800a3e:	74 ef                	je     800a2f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a40:	0f b6 c0             	movzbl %al,%eax
  800a43:	0f b6 12             	movzbl (%edx),%edx
  800a46:	29 d0                	sub    %edx,%eax
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	53                   	push   %ebx
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a59:	eb 06                	jmp    800a61 <strncmp+0x17>
		n--, p++, q++;
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a61:	39 d8                	cmp    %ebx,%eax
  800a63:	74 15                	je     800a7a <strncmp+0x30>
  800a65:	0f b6 08             	movzbl (%eax),%ecx
  800a68:	84 c9                	test   %cl,%cl
  800a6a:	74 04                	je     800a70 <strncmp+0x26>
  800a6c:	3a 0a                	cmp    (%edx),%cl
  800a6e:	74 eb                	je     800a5b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a70:	0f b6 00             	movzbl (%eax),%eax
  800a73:	0f b6 12             	movzbl (%edx),%edx
  800a76:	29 d0                	sub    %edx,%eax
  800a78:	eb 05                	jmp    800a7f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8c:	eb 07                	jmp    800a95 <strchr+0x13>
		if (*s == c)
  800a8e:	38 ca                	cmp    %cl,%dl
  800a90:	74 0f                	je     800aa1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	75 f2                	jne    800a8e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aad:	eb 03                	jmp    800ab2 <strfind+0xf>
  800aaf:	83 c0 01             	add    $0x1,%eax
  800ab2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ab5:	38 ca                	cmp    %cl,%dl
  800ab7:	74 04                	je     800abd <strfind+0x1a>
  800ab9:	84 d2                	test   %dl,%dl
  800abb:	75 f2                	jne    800aaf <strfind+0xc>
			break;
	return (char *) s;
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800acb:	85 c9                	test   %ecx,%ecx
  800acd:	74 36                	je     800b05 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800acf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad5:	75 28                	jne    800aff <memset+0x40>
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 23                	jne    800aff <memset+0x40>
		c &= 0xFF;
  800adc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	c1 e3 08             	shl    $0x8,%ebx
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	c1 e6 18             	shl    $0x18,%esi
  800aea:	89 d0                	mov    %edx,%eax
  800aec:	c1 e0 10             	shl    $0x10,%eax
  800aef:	09 f0                	or     %esi,%eax
  800af1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800af3:	89 d8                	mov    %ebx,%eax
  800af5:	09 d0                	or     %edx,%eax
  800af7:	c1 e9 02             	shr    $0x2,%ecx
  800afa:	fc                   	cld    
  800afb:	f3 ab                	rep stos %eax,%es:(%edi)
  800afd:	eb 06                	jmp    800b05 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	fc                   	cld    
  800b03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b05:	89 f8                	mov    %edi,%eax
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b1a:	39 c6                	cmp    %eax,%esi
  800b1c:	73 35                	jae    800b53 <memmove+0x47>
  800b1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b21:	39 d0                	cmp    %edx,%eax
  800b23:	73 2e                	jae    800b53 <memmove+0x47>
		s += n;
		d += n;
  800b25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	09 fe                	or     %edi,%esi
  800b2c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b32:	75 13                	jne    800b47 <memmove+0x3b>
  800b34:	f6 c1 03             	test   $0x3,%cl
  800b37:	75 0e                	jne    800b47 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b39:	83 ef 04             	sub    $0x4,%edi
  800b3c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b3f:	c1 e9 02             	shr    $0x2,%ecx
  800b42:	fd                   	std    
  800b43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b45:	eb 09                	jmp    800b50 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b47:	83 ef 01             	sub    $0x1,%edi
  800b4a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b4d:	fd                   	std    
  800b4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b50:	fc                   	cld    
  800b51:	eb 1d                	jmp    800b70 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b53:	89 f2                	mov    %esi,%edx
  800b55:	09 c2                	or     %eax,%edx
  800b57:	f6 c2 03             	test   $0x3,%dl
  800b5a:	75 0f                	jne    800b6b <memmove+0x5f>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	75 0a                	jne    800b6b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b61:	c1 e9 02             	shr    $0x2,%ecx
  800b64:	89 c7                	mov    %eax,%edi
  800b66:	fc                   	cld    
  800b67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b69:	eb 05                	jmp    800b70 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	fc                   	cld    
  800b6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b77:	ff 75 10             	pushl  0x10(%ebp)
  800b7a:	ff 75 0c             	pushl  0xc(%ebp)
  800b7d:	ff 75 08             	pushl  0x8(%ebp)
  800b80:	e8 87 ff ff ff       	call   800b0c <memmove>
}
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b97:	eb 1a                	jmp    800bb3 <memcmp+0x2c>
		if (*s1 != *s2)
  800b99:	0f b6 08             	movzbl (%eax),%ecx
  800b9c:	0f b6 1a             	movzbl (%edx),%ebx
  800b9f:	38 d9                	cmp    %bl,%cl
  800ba1:	74 0a                	je     800bad <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ba3:	0f b6 c1             	movzbl %cl,%eax
  800ba6:	0f b6 db             	movzbl %bl,%ebx
  800ba9:	29 d8                	sub    %ebx,%eax
  800bab:	eb 0f                	jmp    800bbc <memcmp+0x35>
		s1++, s2++;
  800bad:	83 c0 01             	add    $0x1,%eax
  800bb0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb3:	39 f0                	cmp    %esi,%eax
  800bb5:	75 e2                	jne    800b99 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	53                   	push   %ebx
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc7:	89 c1                	mov    %eax,%ecx
  800bc9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bcc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd0:	eb 0a                	jmp    800bdc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd2:	0f b6 10             	movzbl (%eax),%edx
  800bd5:	39 da                	cmp    %ebx,%edx
  800bd7:	74 07                	je     800be0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd9:	83 c0 01             	add    $0x1,%eax
  800bdc:	39 c8                	cmp    %ecx,%eax
  800bde:	72 f2                	jb     800bd2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be0:	5b                   	pop    %ebx
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	eb 03                	jmp    800bf4 <strtol+0x11>
		s++;
  800bf1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf4:	0f b6 01             	movzbl (%ecx),%eax
  800bf7:	3c 20                	cmp    $0x20,%al
  800bf9:	74 f6                	je     800bf1 <strtol+0xe>
  800bfb:	3c 09                	cmp    $0x9,%al
  800bfd:	74 f2                	je     800bf1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bff:	3c 2b                	cmp    $0x2b,%al
  800c01:	75 0a                	jne    800c0d <strtol+0x2a>
		s++;
  800c03:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c06:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0b:	eb 11                	jmp    800c1e <strtol+0x3b>
  800c0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c12:	3c 2d                	cmp    $0x2d,%al
  800c14:	75 08                	jne    800c1e <strtol+0x3b>
		s++, neg = 1;
  800c16:	83 c1 01             	add    $0x1,%ecx
  800c19:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c24:	75 15                	jne    800c3b <strtol+0x58>
  800c26:	80 39 30             	cmpb   $0x30,(%ecx)
  800c29:	75 10                	jne    800c3b <strtol+0x58>
  800c2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c2f:	75 7c                	jne    800cad <strtol+0xca>
		s += 2, base = 16;
  800c31:	83 c1 02             	add    $0x2,%ecx
  800c34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c39:	eb 16                	jmp    800c51 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c3b:	85 db                	test   %ebx,%ebx
  800c3d:	75 12                	jne    800c51 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c44:	80 39 30             	cmpb   $0x30,(%ecx)
  800c47:	75 08                	jne    800c51 <strtol+0x6e>
		s++, base = 8;
  800c49:	83 c1 01             	add    $0x1,%ecx
  800c4c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c51:	b8 00 00 00 00       	mov    $0x0,%eax
  800c56:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c59:	0f b6 11             	movzbl (%ecx),%edx
  800c5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 09             	cmp    $0x9,%bl
  800c64:	77 08                	ja     800c6e <strtol+0x8b>
			dig = *s - '0';
  800c66:	0f be d2             	movsbl %dl,%edx
  800c69:	83 ea 30             	sub    $0x30,%edx
  800c6c:	eb 22                	jmp    800c90 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	80 fb 19             	cmp    $0x19,%bl
  800c76:	77 08                	ja     800c80 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c78:	0f be d2             	movsbl %dl,%edx
  800c7b:	83 ea 57             	sub    $0x57,%edx
  800c7e:	eb 10                	jmp    800c90 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c83:	89 f3                	mov    %esi,%ebx
  800c85:	80 fb 19             	cmp    $0x19,%bl
  800c88:	77 16                	ja     800ca0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c8a:	0f be d2             	movsbl %dl,%edx
  800c8d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c93:	7d 0b                	jge    800ca0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c95:	83 c1 01             	add    $0x1,%ecx
  800c98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c9c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c9e:	eb b9                	jmp    800c59 <strtol+0x76>

	if (endptr)
  800ca0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca4:	74 0d                	je     800cb3 <strtol+0xd0>
		*endptr = (char *) s;
  800ca6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca9:	89 0e                	mov    %ecx,(%esi)
  800cab:	eb 06                	jmp    800cb3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cad:	85 db                	test   %ebx,%ebx
  800caf:	74 98                	je     800c49 <strtol+0x66>
  800cb1:	eb 9e                	jmp    800c51 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cb3:	89 c2                	mov    %eax,%edx
  800cb5:	f7 da                	neg    %edx
  800cb7:	85 ff                	test   %edi,%edi
  800cb9:	0f 45 c2             	cmovne %edx,%eax
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	89 c3                	mov    %eax,%ebx
  800cd4:	89 c7                	mov    %eax,%edi
  800cd6:	89 c6                	mov    %eax,%esi
  800cd8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_cgetc>:

int
sys_cgetc(void)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cea:	b8 01 00 00 00       	mov    $0x1,%eax
  800cef:	89 d1                	mov    %edx,%ecx
  800cf1:	89 d3                	mov    %edx,%ebx
  800cf3:	89 d7                	mov    %edx,%edi
  800cf5:	89 d6                	mov    %edx,%esi
  800cf7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 cb                	mov    %ecx,%ebx
  800d16:	89 cf                	mov    %ecx,%edi
  800d18:	89 ce                	mov    %ecx,%esi
  800d1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 17                	jle    800d37 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 03                	push   $0x3
  800d26:	68 3f 2d 80 00       	push   $0x802d3f
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 5c 2d 80 00       	push   $0x802d5c
  800d32:	e8 e5 f5 ff ff       	call   80031c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4f:	89 d1                	mov    %edx,%ecx
  800d51:	89 d3                	mov    %edx,%ebx
  800d53:	89 d7                	mov    %edx,%edi
  800d55:	89 d6                	mov    %edx,%esi
  800d57:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_yield>:

void
sys_yield(void)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	ba 00 00 00 00       	mov    $0x0,%edx
  800d69:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d6e:	89 d1                	mov    %edx,%ecx
  800d70:	89 d3                	mov    %edx,%ebx
  800d72:	89 d7                	mov    %edx,%edi
  800d74:	89 d6                	mov    %edx,%esi
  800d76:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	be 00 00 00 00       	mov    $0x0,%esi
  800d8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d99:	89 f7                	mov    %esi,%edi
  800d9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7e 17                	jle    800db8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 04                	push   $0x4
  800da7:	68 3f 2d 80 00       	push   $0x802d3f
  800dac:	6a 23                	push   $0x23
  800dae:	68 5c 2d 80 00       	push   $0x802d5c
  800db3:	e8 64 f5 ff ff       	call   80031c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dda:	8b 75 18             	mov    0x18(%ebp),%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 05                	push   $0x5
  800de9:	68 3f 2d 80 00       	push   $0x802d3f
  800dee:	6a 23                	push   $0x23
  800df0:	68 5c 2d 80 00       	push   $0x802d5c
  800df5:	e8 22 f5 ff ff       	call   80031c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 06 00 00 00       	mov    $0x6,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 17                	jle    800e3c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 06                	push   $0x6
  800e2b:	68 3f 2d 80 00       	push   $0x802d3f
  800e30:	6a 23                	push   $0x23
  800e32:	68 5c 2d 80 00       	push   $0x802d5c
  800e37:	e8 e0 f4 ff ff       	call   80031c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e52:	b8 08 00 00 00       	mov    $0x8,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 df                	mov    %ebx,%edi
  800e5f:	89 de                	mov    %ebx,%esi
  800e61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 17                	jle    800e7e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	50                   	push   %eax
  800e6b:	6a 08                	push   $0x8
  800e6d:	68 3f 2d 80 00       	push   $0x802d3f
  800e72:	6a 23                	push   $0x23
  800e74:	68 5c 2d 80 00       	push   $0x802d5c
  800e79:	e8 9e f4 ff ff       	call   80031c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e94:	b8 09 00 00 00       	mov    $0x9,%eax
  800e99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 df                	mov    %ebx,%edi
  800ea1:	89 de                	mov    %ebx,%esi
  800ea3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	7e 17                	jle    800ec0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	50                   	push   %eax
  800ead:	6a 09                	push   $0x9
  800eaf:	68 3f 2d 80 00       	push   $0x802d3f
  800eb4:	6a 23                	push   $0x23
  800eb6:	68 5c 2d 80 00       	push   $0x802d5c
  800ebb:	e8 5c f4 ff ff       	call   80031c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800edb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ede:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee1:	89 df                	mov    %ebx,%edi
  800ee3:	89 de                	mov    %ebx,%esi
  800ee5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 17                	jle    800f02 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	50                   	push   %eax
  800eef:	6a 0a                	push   $0xa
  800ef1:	68 3f 2d 80 00       	push   $0x802d3f
  800ef6:	6a 23                	push   $0x23
  800ef8:	68 5c 2d 80 00       	push   $0x802d5c
  800efd:	e8 1a f4 ff ff       	call   80031c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	be 00 00 00 00       	mov    $0x0,%esi
  800f15:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f26:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
  800f33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	89 cb                	mov    %ecx,%ebx
  800f45:	89 cf                	mov    %ecx,%edi
  800f47:	89 ce                	mov    %ecx,%esi
  800f49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	7e 17                	jle    800f66 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	50                   	push   %eax
  800f53:	6a 0d                	push   $0xd
  800f55:	68 3f 2d 80 00       	push   $0x802d3f
  800f5a:	6a 23                	push   $0x23
  800f5c:	68 5c 2d 80 00       	push   $0x802d5c
  800f61:	e8 b6 f3 ff ff       	call   80031c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	ba 00 00 00 00       	mov    $0x0,%edx
  800f79:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f7e:	89 d1                	mov    %edx,%ecx
  800f80:	89 d3                	mov    %edx,%ebx
  800f82:	89 d7                	mov    %edx,%edi
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	57                   	push   %edi
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f98:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	89 df                	mov    %ebx,%edi
  800fa5:	89 de                	mov    %ebx,%esi
  800fa7:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	53                   	push   %ebx
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800fb8:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800fba:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fbe:	74 2e                	je     800fee <pgfault+0x40>
  800fc0:	89 c2                	mov    %eax,%edx
  800fc2:	c1 ea 16             	shr    $0x16,%edx
  800fc5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fcc:	f6 c2 01             	test   $0x1,%dl
  800fcf:	74 1d                	je     800fee <pgfault+0x40>
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	c1 ea 0c             	shr    $0xc,%edx
  800fd6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fdd:	f6 c1 01             	test   $0x1,%cl
  800fe0:	74 0c                	je     800fee <pgfault+0x40>
  800fe2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe9:	f6 c6 08             	test   $0x8,%dh
  800fec:	75 14                	jne    801002 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 6a 2d 80 00       	push   $0x802d6a
  800ff6:	6a 1d                	push   $0x1d
  800ff8:	68 7d 2d 80 00       	push   $0x802d7d
  800ffd:	e8 1a f3 ff ff       	call   80031c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  801002:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801007:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	6a 07                	push   $0x7
  80100e:	68 00 f0 7f 00       	push   $0x7ff000
  801013:	6a 00                	push   $0x0
  801015:	e8 63 fd ff ff       	call   800d7d <sys_page_alloc>
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	79 14                	jns    801035 <pgfault+0x87>
		panic("page alloc failed \n");
  801021:	83 ec 04             	sub    $0x4,%esp
  801024:	68 88 2d 80 00       	push   $0x802d88
  801029:	6a 28                	push   $0x28
  80102b:	68 7d 2d 80 00       	push   $0x802d7d
  801030:	e8 e7 f2 ff ff       	call   80031c <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	68 00 10 00 00       	push   $0x1000
  80103d:	53                   	push   %ebx
  80103e:	68 00 f0 7f 00       	push   $0x7ff000
  801043:	e8 2c fb ff ff       	call   800b74 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  801048:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80104f:	53                   	push   %ebx
  801050:	6a 00                	push   $0x0
  801052:	68 00 f0 7f 00       	push   $0x7ff000
  801057:	6a 00                	push   $0x0
  801059:	e8 62 fd ff ff       	call   800dc0 <sys_page_map>
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 14                	jns    801079 <pgfault+0xcb>
        panic("page map failed \n");
  801065:	83 ec 04             	sub    $0x4,%esp
  801068:	68 9c 2d 80 00       	push   $0x802d9c
  80106d:	6a 2b                	push   $0x2b
  80106f:	68 7d 2d 80 00       	push   $0x802d7d
  801074:	e8 a3 f2 ff ff       	call   80031c <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  801079:	83 ec 08             	sub    $0x8,%esp
  80107c:	68 00 f0 7f 00       	push   $0x7ff000
  801081:	6a 00                	push   $0x0
  801083:	e8 7a fd ff ff       	call   800e02 <sys_page_unmap>
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	79 14                	jns    8010a3 <pgfault+0xf5>
        panic("page unmap failed\n");
  80108f:	83 ec 04             	sub    $0x4,%esp
  801092:	68 ae 2d 80 00       	push   $0x802dae
  801097:	6a 2d                	push   $0x2d
  801099:	68 7d 2d 80 00       	push   $0x802d7d
  80109e:	e8 79 f2 ff ff       	call   80031c <_panic>
	
	//panic("pgfault not implemented");
}
  8010a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a6:	c9                   	leave  
  8010a7:	c3                   	ret    

008010a8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	57                   	push   %edi
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  8010b1:	68 ae 0f 80 00       	push   $0x800fae
  8010b6:	e8 a6 13 00 00       	call   802461 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010bb:	b8 07 00 00 00       	mov    $0x7,%eax
  8010c0:	cd 30                	int    $0x30
  8010c2:	89 c7                	mov    %eax,%edi
  8010c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	79 12                	jns    8010e0 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  8010ce:	50                   	push   %eax
  8010cf:	68 c1 2d 80 00       	push   $0x802dc1
  8010d4:	6a 7a                	push   $0x7a
  8010d6:	68 7d 2d 80 00       	push   $0x802d7d
  8010db:	e8 3c f2 ff ff       	call   80031c <_panic>
  8010e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	75 21                	jne    80110a <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010e9:	e8 51 fc ff ff       	call   800d3f <sys_getenvid>
  8010ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010fb:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
  801105:	e9 91 01 00 00       	jmp    80129b <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  80110a:	89 d8                	mov    %ebx,%eax
  80110c:	c1 e8 16             	shr    $0x16,%eax
  80110f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801116:	a8 01                	test   $0x1,%al
  801118:	0f 84 06 01 00 00    	je     801224 <fork+0x17c>
  80111e:	89 d8                	mov    %ebx,%eax
  801120:	c1 e8 0c             	shr    $0xc,%eax
  801123:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112a:	f6 c2 01             	test   $0x1,%dl
  80112d:	0f 84 f1 00 00 00    	je     801224 <fork+0x17c>
  801133:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80113a:	f6 c2 04             	test   $0x4,%dl
  80113d:	0f 84 e1 00 00 00    	je     801224 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  801143:	89 c6                	mov    %eax,%esi
  801145:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  801148:	89 f2                	mov    %esi,%edx
  80114a:	c1 ea 16             	shr    $0x16,%edx
  80114d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  801154:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  80115b:	f6 c6 04             	test   $0x4,%dh
  80115e:	74 39                	je     801199 <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  801160:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801167:	83 ec 0c             	sub    $0xc,%esp
  80116a:	25 07 0e 00 00       	and    $0xe07,%eax
  80116f:	50                   	push   %eax
  801170:	56                   	push   %esi
  801171:	ff 75 e4             	pushl  -0x1c(%ebp)
  801174:	56                   	push   %esi
  801175:	6a 00                	push   $0x0
  801177:	e8 44 fc ff ff       	call   800dc0 <sys_page_map>
  80117c:	83 c4 20             	add    $0x20,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	0f 89 9d 00 00 00    	jns    801224 <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  801187:	50                   	push   %eax
  801188:	68 18 2e 80 00       	push   $0x802e18
  80118d:	6a 4b                	push   $0x4b
  80118f:	68 7d 2d 80 00       	push   $0x802d7d
  801194:	e8 83 f1 ff ff       	call   80031c <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  801199:	f7 c2 02 08 00 00    	test   $0x802,%edx
  80119f:	74 59                	je     8011fa <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	68 05 08 00 00       	push   $0x805
  8011a9:	56                   	push   %esi
  8011aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ad:	56                   	push   %esi
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 0b fc ff ff       	call   800dc0 <sys_page_map>
  8011b5:	83 c4 20             	add    $0x20,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	79 12                	jns    8011ce <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  8011bc:	50                   	push   %eax
  8011bd:	68 48 2e 80 00       	push   $0x802e48
  8011c2:	6a 50                	push   $0x50
  8011c4:	68 7d 2d 80 00       	push   $0x802d7d
  8011c9:	e8 4e f1 ff ff       	call   80031c <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	68 05 08 00 00       	push   $0x805
  8011d6:	56                   	push   %esi
  8011d7:	6a 00                	push   $0x0
  8011d9:	56                   	push   %esi
  8011da:	6a 00                	push   $0x0
  8011dc:	e8 df fb ff ff       	call   800dc0 <sys_page_map>
  8011e1:	83 c4 20             	add    $0x20,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	79 3c                	jns    801224 <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  8011e8:	50                   	push   %eax
  8011e9:	68 70 2e 80 00       	push   $0x802e70
  8011ee:	6a 53                	push   $0x53
  8011f0:	68 7d 2d 80 00       	push   $0x802d7d
  8011f5:	e8 22 f1 ff ff       	call   80031c <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  8011fa:	83 ec 0c             	sub    $0xc,%esp
  8011fd:	6a 05                	push   $0x5
  8011ff:	56                   	push   %esi
  801200:	ff 75 e4             	pushl  -0x1c(%ebp)
  801203:	56                   	push   %esi
  801204:	6a 00                	push   $0x0
  801206:	e8 b5 fb ff ff       	call   800dc0 <sys_page_map>
  80120b:	83 c4 20             	add    $0x20,%esp
  80120e:	85 c0                	test   %eax,%eax
  801210:	79 12                	jns    801224 <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  801212:	50                   	push   %eax
  801213:	68 98 2e 80 00       	push   $0x802e98
  801218:	6a 58                	push   $0x58
  80121a:	68 7d 2d 80 00       	push   $0x802d7d
  80121f:	e8 f8 f0 ff ff       	call   80031c <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  801224:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80122a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801230:	0f 85 d4 fe ff ff    	jne    80110a <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  801236:	83 ec 04             	sub    $0x4,%esp
  801239:	6a 07                	push   $0x7
  80123b:	68 00 f0 bf ee       	push   $0xeebff000
  801240:	57                   	push   %edi
  801241:	e8 37 fb ff ff       	call   800d7d <sys_page_alloc>
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	79 17                	jns    801264 <fork+0x1bc>
        panic("page alloc failed\n");
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	68 d3 2d 80 00       	push   $0x802dd3
  801255:	68 87 00 00 00       	push   $0x87
  80125a:	68 7d 2d 80 00       	push   $0x802d7d
  80125f:	e8 b8 f0 ff ff       	call   80031c <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	68 d0 24 80 00       	push   $0x8024d0
  80126c:	57                   	push   %edi
  80126d:	e8 56 fc ff ff       	call   800ec8 <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801272:	83 c4 08             	add    $0x8,%esp
  801275:	6a 02                	push   $0x2
  801277:	57                   	push   %edi
  801278:	e8 c7 fb ff ff       	call   800e44 <sys_env_set_status>
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	79 15                	jns    801299 <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  801284:	50                   	push   %eax
  801285:	68 e6 2d 80 00       	push   $0x802de6
  80128a:	68 8c 00 00 00       	push   $0x8c
  80128f:	68 7d 2d 80 00       	push   $0x802d7d
  801294:	e8 83 f0 ff ff       	call   80031c <_panic>

	return envid;
  801299:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  80129b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5f                   	pop    %edi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <sfork>:

// Challenge!
int
sfork(void)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012a9:	68 ff 2d 80 00       	push   $0x802dff
  8012ae:	68 98 00 00 00       	push   $0x98
  8012b3:	68 7d 2d 80 00       	push   $0x802d7d
  8012b8:	e8 5f f0 ff ff       	call   80031c <_panic>

008012bd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c8:	c1 e8 0c             	shr    $0xc,%eax
}
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012dd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ef:	89 c2                	mov    %eax,%edx
  8012f1:	c1 ea 16             	shr    $0x16,%edx
  8012f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012fb:	f6 c2 01             	test   $0x1,%dl
  8012fe:	74 11                	je     801311 <fd_alloc+0x2d>
  801300:	89 c2                	mov    %eax,%edx
  801302:	c1 ea 0c             	shr    $0xc,%edx
  801305:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130c:	f6 c2 01             	test   $0x1,%dl
  80130f:	75 09                	jne    80131a <fd_alloc+0x36>
			*fd_store = fd;
  801311:	89 01                	mov    %eax,(%ecx)
			return 0;
  801313:	b8 00 00 00 00       	mov    $0x0,%eax
  801318:	eb 17                	jmp    801331 <fd_alloc+0x4d>
  80131a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80131f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801324:	75 c9                	jne    8012ef <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801326:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80132c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801339:	83 f8 1f             	cmp    $0x1f,%eax
  80133c:	77 36                	ja     801374 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133e:	c1 e0 0c             	shl    $0xc,%eax
  801341:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801346:	89 c2                	mov    %eax,%edx
  801348:	c1 ea 16             	shr    $0x16,%edx
  80134b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801352:	f6 c2 01             	test   $0x1,%dl
  801355:	74 24                	je     80137b <fd_lookup+0x48>
  801357:	89 c2                	mov    %eax,%edx
  801359:	c1 ea 0c             	shr    $0xc,%edx
  80135c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801363:	f6 c2 01             	test   $0x1,%dl
  801366:	74 1a                	je     801382 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136b:	89 02                	mov    %eax,(%edx)
	return 0;
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	eb 13                	jmp    801387 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801379:	eb 0c                	jmp    801387 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80137b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801380:	eb 05                	jmp    801387 <fd_lookup+0x54>
  801382:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    

00801389 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801392:	ba 40 2f 80 00       	mov    $0x802f40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801397:	eb 13                	jmp    8013ac <dev_lookup+0x23>
  801399:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80139c:	39 08                	cmp    %ecx,(%eax)
  80139e:	75 0c                	jne    8013ac <dev_lookup+0x23>
			*dev = devtab[i];
  8013a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013aa:	eb 2e                	jmp    8013da <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ac:	8b 02                	mov    (%edx),%eax
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	75 e7                	jne    801399 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013b2:	a1 08 50 80 00       	mov    0x805008,%eax
  8013b7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ba:	83 ec 04             	sub    $0x4,%esp
  8013bd:	51                   	push   %ecx
  8013be:	50                   	push   %eax
  8013bf:	68 c4 2e 80 00       	push   $0x802ec4
  8013c4:	e8 2c f0 ff ff       	call   8003f5 <cprintf>
	*dev = 0;
  8013c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 10             	sub    $0x10,%esp
  8013e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013f4:	c1 e8 0c             	shr    $0xc,%eax
  8013f7:	50                   	push   %eax
  8013f8:	e8 36 ff ff ff       	call   801333 <fd_lookup>
  8013fd:	83 c4 08             	add    $0x8,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 05                	js     801409 <fd_close+0x2d>
	    || fd != fd2)
  801404:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801407:	74 0c                	je     801415 <fd_close+0x39>
		return (must_exist ? r : 0);
  801409:	84 db                	test   %bl,%bl
  80140b:	ba 00 00 00 00       	mov    $0x0,%edx
  801410:	0f 44 c2             	cmove  %edx,%eax
  801413:	eb 41                	jmp    801456 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	ff 36                	pushl  (%esi)
  80141e:	e8 66 ff ff ff       	call   801389 <dev_lookup>
  801423:	89 c3                	mov    %eax,%ebx
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 1a                	js     801446 <fd_close+0x6a>
		if (dev->dev_close)
  80142c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801432:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801437:	85 c0                	test   %eax,%eax
  801439:	74 0b                	je     801446 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	56                   	push   %esi
  80143f:	ff d0                	call   *%eax
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	56                   	push   %esi
  80144a:	6a 00                	push   $0x0
  80144c:	e8 b1 f9 ff ff       	call   800e02 <sys_page_unmap>
	return r;
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	89 d8                	mov    %ebx,%eax
}
  801456:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801459:	5b                   	pop    %ebx
  80145a:	5e                   	pop    %esi
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    

0080145d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801463:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	ff 75 08             	pushl  0x8(%ebp)
  80146a:	e8 c4 fe ff ff       	call   801333 <fd_lookup>
  80146f:	83 c4 08             	add    $0x8,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	78 10                	js     801486 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	6a 01                	push   $0x1
  80147b:	ff 75 f4             	pushl  -0xc(%ebp)
  80147e:	e8 59 ff ff ff       	call   8013dc <fd_close>
  801483:	83 c4 10             	add    $0x10,%esp
}
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <close_all>:

void
close_all(void)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801494:	83 ec 0c             	sub    $0xc,%esp
  801497:	53                   	push   %ebx
  801498:	e8 c0 ff ff ff       	call   80145d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80149d:	83 c3 01             	add    $0x1,%ebx
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	83 fb 20             	cmp    $0x20,%ebx
  8014a6:	75 ec                	jne    801494 <close_all+0xc>
		close(i);
}
  8014a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ab:	c9                   	leave  
  8014ac:	c3                   	ret    

008014ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	57                   	push   %edi
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 2c             	sub    $0x2c,%esp
  8014b6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	ff 75 08             	pushl  0x8(%ebp)
  8014c0:	e8 6e fe ff ff       	call   801333 <fd_lookup>
  8014c5:	83 c4 08             	add    $0x8,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	0f 88 c1 00 00 00    	js     801591 <dup+0xe4>
		return r;
	close(newfdnum);
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	56                   	push   %esi
  8014d4:	e8 84 ff ff ff       	call   80145d <close>

	newfd = INDEX2FD(newfdnum);
  8014d9:	89 f3                	mov    %esi,%ebx
  8014db:	c1 e3 0c             	shl    $0xc,%ebx
  8014de:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014e4:	83 c4 04             	add    $0x4,%esp
  8014e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ea:	e8 de fd ff ff       	call   8012cd <fd2data>
  8014ef:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014f1:	89 1c 24             	mov    %ebx,(%esp)
  8014f4:	e8 d4 fd ff ff       	call   8012cd <fd2data>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ff:	89 f8                	mov    %edi,%eax
  801501:	c1 e8 16             	shr    $0x16,%eax
  801504:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80150b:	a8 01                	test   $0x1,%al
  80150d:	74 37                	je     801546 <dup+0x99>
  80150f:	89 f8                	mov    %edi,%eax
  801511:	c1 e8 0c             	shr    $0xc,%eax
  801514:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80151b:	f6 c2 01             	test   $0x1,%dl
  80151e:	74 26                	je     801546 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801520:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801527:	83 ec 0c             	sub    $0xc,%esp
  80152a:	25 07 0e 00 00       	and    $0xe07,%eax
  80152f:	50                   	push   %eax
  801530:	ff 75 d4             	pushl  -0x2c(%ebp)
  801533:	6a 00                	push   $0x0
  801535:	57                   	push   %edi
  801536:	6a 00                	push   $0x0
  801538:	e8 83 f8 ff ff       	call   800dc0 <sys_page_map>
  80153d:	89 c7                	mov    %eax,%edi
  80153f:	83 c4 20             	add    $0x20,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 2e                	js     801574 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801546:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801549:	89 d0                	mov    %edx,%eax
  80154b:	c1 e8 0c             	shr    $0xc,%eax
  80154e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801555:	83 ec 0c             	sub    $0xc,%esp
  801558:	25 07 0e 00 00       	and    $0xe07,%eax
  80155d:	50                   	push   %eax
  80155e:	53                   	push   %ebx
  80155f:	6a 00                	push   $0x0
  801561:	52                   	push   %edx
  801562:	6a 00                	push   $0x0
  801564:	e8 57 f8 ff ff       	call   800dc0 <sys_page_map>
  801569:	89 c7                	mov    %eax,%edi
  80156b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80156e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801570:	85 ff                	test   %edi,%edi
  801572:	79 1d                	jns    801591 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	53                   	push   %ebx
  801578:	6a 00                	push   $0x0
  80157a:	e8 83 f8 ff ff       	call   800e02 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80157f:	83 c4 08             	add    $0x8,%esp
  801582:	ff 75 d4             	pushl  -0x2c(%ebp)
  801585:	6a 00                	push   $0x0
  801587:	e8 76 f8 ff ff       	call   800e02 <sys_page_unmap>
	return r;
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	89 f8                	mov    %edi,%eax
}
  801591:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5f                   	pop    %edi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    

00801599 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	53                   	push   %ebx
  80159d:	83 ec 14             	sub    $0x14,%esp
  8015a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	53                   	push   %ebx
  8015a8:	e8 86 fd ff ff       	call   801333 <fd_lookup>
  8015ad:	83 c4 08             	add    $0x8,%esp
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 6d                	js     801623 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	ff 30                	pushl  (%eax)
  8015c2:	e8 c2 fd ff ff       	call   801389 <dev_lookup>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 4c                	js     80161a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015d1:	8b 42 08             	mov    0x8(%edx),%eax
  8015d4:	83 e0 03             	and    $0x3,%eax
  8015d7:	83 f8 01             	cmp    $0x1,%eax
  8015da:	75 21                	jne    8015fd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015dc:	a1 08 50 80 00       	mov    0x805008,%eax
  8015e1:	8b 40 48             	mov    0x48(%eax),%eax
  8015e4:	83 ec 04             	sub    $0x4,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	50                   	push   %eax
  8015e9:	68 05 2f 80 00       	push   $0x802f05
  8015ee:	e8 02 ee ff ff       	call   8003f5 <cprintf>
		return -E_INVAL;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fb:	eb 26                	jmp    801623 <read+0x8a>
	}
	if (!dev->dev_read)
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	8b 40 08             	mov    0x8(%eax),%eax
  801603:	85 c0                	test   %eax,%eax
  801605:	74 17                	je     80161e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	ff 75 10             	pushl  0x10(%ebp)
  80160d:	ff 75 0c             	pushl  0xc(%ebp)
  801610:	52                   	push   %edx
  801611:	ff d0                	call   *%eax
  801613:	89 c2                	mov    %eax,%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 09                	jmp    801623 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	eb 05                	jmp    801623 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80161e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801623:	89 d0                	mov    %edx,%eax
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	57                   	push   %edi
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	83 ec 0c             	sub    $0xc,%esp
  801633:	8b 7d 08             	mov    0x8(%ebp),%edi
  801636:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801639:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163e:	eb 21                	jmp    801661 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	89 f0                	mov    %esi,%eax
  801645:	29 d8                	sub    %ebx,%eax
  801647:	50                   	push   %eax
  801648:	89 d8                	mov    %ebx,%eax
  80164a:	03 45 0c             	add    0xc(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	57                   	push   %edi
  80164f:	e8 45 ff ff ff       	call   801599 <read>
		if (m < 0)
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 10                	js     80166b <readn+0x41>
			return m;
		if (m == 0)
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 0a                	je     801669 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165f:	01 c3                	add    %eax,%ebx
  801661:	39 f3                	cmp    %esi,%ebx
  801663:	72 db                	jb     801640 <readn+0x16>
  801665:	89 d8                	mov    %ebx,%eax
  801667:	eb 02                	jmp    80166b <readn+0x41>
  801669:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80166b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5f                   	pop    %edi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	53                   	push   %ebx
  801677:	83 ec 14             	sub    $0x14,%esp
  80167a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	53                   	push   %ebx
  801682:	e8 ac fc ff ff       	call   801333 <fd_lookup>
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 68                	js     8016f8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	ff 30                	pushl  (%eax)
  80169c:	e8 e8 fc ff ff       	call   801389 <dev_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 47                	js     8016ef <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016af:	75 21                	jne    8016d2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b1:	a1 08 50 80 00       	mov    0x805008,%eax
  8016b6:	8b 40 48             	mov    0x48(%eax),%eax
  8016b9:	83 ec 04             	sub    $0x4,%esp
  8016bc:	53                   	push   %ebx
  8016bd:	50                   	push   %eax
  8016be:	68 21 2f 80 00       	push   $0x802f21
  8016c3:	e8 2d ed ff ff       	call   8003f5 <cprintf>
		return -E_INVAL;
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016d0:	eb 26                	jmp    8016f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d8:	85 d2                	test   %edx,%edx
  8016da:	74 17                	je     8016f3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016dc:	83 ec 04             	sub    $0x4,%esp
  8016df:	ff 75 10             	pushl  0x10(%ebp)
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	50                   	push   %eax
  8016e6:	ff d2                	call   *%edx
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	eb 09                	jmp    8016f8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	eb 05                	jmp    8016f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016f8:	89 d0                	mov    %edx,%eax
  8016fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801705:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801708:	50                   	push   %eax
  801709:	ff 75 08             	pushl  0x8(%ebp)
  80170c:	e8 22 fc ff ff       	call   801333 <fd_lookup>
  801711:	83 c4 08             	add    $0x8,%esp
  801714:	85 c0                	test   %eax,%eax
  801716:	78 0e                	js     801726 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801718:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80171b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801721:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	53                   	push   %ebx
  80172c:	83 ec 14             	sub    $0x14,%esp
  80172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801735:	50                   	push   %eax
  801736:	53                   	push   %ebx
  801737:	e8 f7 fb ff ff       	call   801333 <fd_lookup>
  80173c:	83 c4 08             	add    $0x8,%esp
  80173f:	89 c2                	mov    %eax,%edx
  801741:	85 c0                	test   %eax,%eax
  801743:	78 65                	js     8017aa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801745:	83 ec 08             	sub    $0x8,%esp
  801748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174b:	50                   	push   %eax
  80174c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174f:	ff 30                	pushl  (%eax)
  801751:	e8 33 fc ff ff       	call   801389 <dev_lookup>
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 44                	js     8017a1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801764:	75 21                	jne    801787 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801766:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80176b:	8b 40 48             	mov    0x48(%eax),%eax
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	53                   	push   %ebx
  801772:	50                   	push   %eax
  801773:	68 e4 2e 80 00       	push   $0x802ee4
  801778:	e8 78 ec ff ff       	call   8003f5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801785:	eb 23                	jmp    8017aa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178a:	8b 52 18             	mov    0x18(%edx),%edx
  80178d:	85 d2                	test   %edx,%edx
  80178f:	74 14                	je     8017a5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	50                   	push   %eax
  801798:	ff d2                	call   *%edx
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	eb 09                	jmp    8017aa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a1:	89 c2                	mov    %eax,%edx
  8017a3:	eb 05                	jmp    8017aa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017aa:	89 d0                	mov    %edx,%eax
  8017ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 14             	sub    $0x14,%esp
  8017b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017be:	50                   	push   %eax
  8017bf:	ff 75 08             	pushl  0x8(%ebp)
  8017c2:	e8 6c fb ff ff       	call   801333 <fd_lookup>
  8017c7:	83 c4 08             	add    $0x8,%esp
  8017ca:	89 c2                	mov    %eax,%edx
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 58                	js     801828 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017da:	ff 30                	pushl  (%eax)
  8017dc:	e8 a8 fb ff ff       	call   801389 <dev_lookup>
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 37                	js     80181f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ef:	74 32                	je     801823 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017fb:	00 00 00 
	stat->st_isdir = 0;
  8017fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801805:	00 00 00 
	stat->st_dev = dev;
  801808:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	53                   	push   %ebx
  801812:	ff 75 f0             	pushl  -0x10(%ebp)
  801815:	ff 50 14             	call   *0x14(%eax)
  801818:	89 c2                	mov    %eax,%edx
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	eb 09                	jmp    801828 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181f:	89 c2                	mov    %eax,%edx
  801821:	eb 05                	jmp    801828 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801823:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801828:	89 d0                	mov    %edx,%eax
  80182a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	56                   	push   %esi
  801833:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	6a 00                	push   $0x0
  801839:	ff 75 08             	pushl  0x8(%ebp)
  80183c:	e8 e7 01 00 00       	call   801a28 <open>
  801841:	89 c3                	mov    %eax,%ebx
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	85 c0                	test   %eax,%eax
  801848:	78 1b                	js     801865 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80184a:	83 ec 08             	sub    $0x8,%esp
  80184d:	ff 75 0c             	pushl  0xc(%ebp)
  801850:	50                   	push   %eax
  801851:	e8 5b ff ff ff       	call   8017b1 <fstat>
  801856:	89 c6                	mov    %eax,%esi
	close(fd);
  801858:	89 1c 24             	mov    %ebx,(%esp)
  80185b:	e8 fd fb ff ff       	call   80145d <close>
	return r;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	89 f0                	mov    %esi,%eax
}
  801865:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801868:	5b                   	pop    %ebx
  801869:	5e                   	pop    %esi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	89 c6                	mov    %eax,%esi
  801873:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801875:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80187c:	75 12                	jne    801890 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	6a 01                	push   $0x1
  801883:	e8 2d 0d 00 00       	call   8025b5 <ipc_find_env>
  801888:	a3 00 50 80 00       	mov    %eax,0x805000
  80188d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801890:	6a 07                	push   $0x7
  801892:	68 00 60 80 00       	push   $0x806000
  801897:	56                   	push   %esi
  801898:	ff 35 00 50 80 00    	pushl  0x805000
  80189e:	e8 be 0c 00 00       	call   802561 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018a3:	83 c4 0c             	add    $0xc,%esp
  8018a6:	6a 00                	push   $0x0
  8018a8:	53                   	push   %ebx
  8018a9:	6a 00                	push   $0x0
  8018ab:	e8 44 0c 00 00       	call   8024f4 <ipc_recv>
}
  8018b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b3:	5b                   	pop    %ebx
  8018b4:	5e                   	pop    %esi
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c3:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8018c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cb:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8018da:	e8 8d ff ff ff       	call   80186c <fsipc>
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    

008018e1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8018fc:	e8 6b ff ff ff       	call   80186c <fsipc>
}
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	8b 40 0c             	mov    0xc(%eax),%eax
  801913:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801918:	ba 00 00 00 00       	mov    $0x0,%edx
  80191d:	b8 05 00 00 00       	mov    $0x5,%eax
  801922:	e8 45 ff ff ff       	call   80186c <fsipc>
  801927:	85 c0                	test   %eax,%eax
  801929:	78 2c                	js     801957 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	68 00 60 80 00       	push   $0x806000
  801933:	53                   	push   %ebx
  801934:	e8 41 f0 ff ff       	call   80097a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801939:	a1 80 60 80 00       	mov    0x806080,%eax
  80193e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801944:	a1 84 60 80 00       	mov    0x806084,%eax
  801949:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 08             	sub    $0x8,%esp
  801963:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801966:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80196b:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801970:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801973:	53                   	push   %ebx
  801974:	ff 75 0c             	pushl  0xc(%ebp)
  801977:	68 08 60 80 00       	push   $0x806008
  80197c:	e8 8b f1 ff ff       	call   800b0c <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801981:	8b 45 08             	mov    0x8(%ebp),%eax
  801984:	8b 40 0c             	mov    0xc(%eax),%eax
  801987:	a3 00 60 80 00       	mov    %eax,0x806000
 	fsipcbuf.write.req_n = n;
  80198c:	89 1d 04 60 80 00    	mov    %ebx,0x806004

 	return fsipc(FSREQ_WRITE, NULL);
  801992:	ba 00 00 00 00       	mov    $0x0,%edx
  801997:	b8 04 00 00 00       	mov    $0x4,%eax
  80199c:	e8 cb fe ff ff       	call   80186c <fsipc>
	//panic("devfile_write not implemented");
}
  8019a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	56                   	push   %esi
  8019aa:	53                   	push   %ebx
  8019ab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8019b9:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c9:	e8 9e fe ff ff       	call   80186c <fsipc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 4b                	js     801a1f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019d4:	39 c6                	cmp    %eax,%esi
  8019d6:	73 16                	jae    8019ee <devfile_read+0x48>
  8019d8:	68 54 2f 80 00       	push   $0x802f54
  8019dd:	68 5b 2f 80 00       	push   $0x802f5b
  8019e2:	6a 7c                	push   $0x7c
  8019e4:	68 70 2f 80 00       	push   $0x802f70
  8019e9:	e8 2e e9 ff ff       	call   80031c <_panic>
	assert(r <= PGSIZE);
  8019ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019f3:	7e 16                	jle    801a0b <devfile_read+0x65>
  8019f5:	68 7b 2f 80 00       	push   $0x802f7b
  8019fa:	68 5b 2f 80 00       	push   $0x802f5b
  8019ff:	6a 7d                	push   $0x7d
  801a01:	68 70 2f 80 00       	push   $0x802f70
  801a06:	e8 11 e9 ff ff       	call   80031c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a0b:	83 ec 04             	sub    $0x4,%esp
  801a0e:	50                   	push   %eax
  801a0f:	68 00 60 80 00       	push   $0x806000
  801a14:	ff 75 0c             	pushl  0xc(%ebp)
  801a17:	e8 f0 f0 ff ff       	call   800b0c <memmove>
	return r;
  801a1c:	83 c4 10             	add    $0x10,%esp
}
  801a1f:	89 d8                	mov    %ebx,%eax
  801a21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a24:	5b                   	pop    %ebx
  801a25:	5e                   	pop    %esi
  801a26:	5d                   	pop    %ebp
  801a27:	c3                   	ret    

00801a28 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	53                   	push   %ebx
  801a2c:	83 ec 20             	sub    $0x20,%esp
  801a2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a32:	53                   	push   %ebx
  801a33:	e8 09 ef ff ff       	call   800941 <strlen>
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a40:	7f 67                	jg     801aa9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a48:	50                   	push   %eax
  801a49:	e8 96 f8 ff ff       	call   8012e4 <fd_alloc>
  801a4e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a51:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 57                	js     801aae <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a57:	83 ec 08             	sub    $0x8,%esp
  801a5a:	53                   	push   %ebx
  801a5b:	68 00 60 80 00       	push   $0x806000
  801a60:	e8 15 ef ff ff       	call   80097a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a68:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a70:	b8 01 00 00 00       	mov    $0x1,%eax
  801a75:	e8 f2 fd ff ff       	call   80186c <fsipc>
  801a7a:	89 c3                	mov    %eax,%ebx
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	79 14                	jns    801a97 <open+0x6f>
		fd_close(fd, 0);
  801a83:	83 ec 08             	sub    $0x8,%esp
  801a86:	6a 00                	push   $0x0
  801a88:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8b:	e8 4c f9 ff ff       	call   8013dc <fd_close>
		return r;
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	89 da                	mov    %ebx,%edx
  801a95:	eb 17                	jmp    801aae <open+0x86>
	}

	return fd2num(fd);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9d:	e8 1b f8 ff ff       	call   8012bd <fd2num>
  801aa2:	89 c2                	mov    %eax,%edx
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	eb 05                	jmp    801aae <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aa9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aae:	89 d0                	mov    %edx,%eax
  801ab0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801abb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ac5:	e8 a2 fd ff ff       	call   80186c <fsipc>
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ad2:	68 87 2f 80 00       	push   $0x802f87
  801ad7:	ff 75 0c             	pushl  0xc(%ebp)
  801ada:	e8 9b ee ff ff       	call   80097a <strcpy>
	return 0;
}
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	53                   	push   %ebx
  801aea:	83 ec 10             	sub    $0x10,%esp
  801aed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801af0:	53                   	push   %ebx
  801af1:	e8 f8 0a 00 00       	call   8025ee <pageref>
  801af6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801af9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801afe:	83 f8 01             	cmp    $0x1,%eax
  801b01:	75 10                	jne    801b13 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	ff 73 0c             	pushl  0xc(%ebx)
  801b09:	e8 c0 02 00 00       	call   801dce <nsipc_close>
  801b0e:	89 c2                	mov    %eax,%edx
  801b10:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b13:	89 d0                	mov    %edx,%eax
  801b15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b20:	6a 00                	push   $0x0
  801b22:	ff 75 10             	pushl  0x10(%ebp)
  801b25:	ff 75 0c             	pushl  0xc(%ebp)
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	ff 70 0c             	pushl  0xc(%eax)
  801b2e:	e8 78 03 00 00       	call   801eab <nsipc_send>
}
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b3b:	6a 00                	push   $0x0
  801b3d:	ff 75 10             	pushl  0x10(%ebp)
  801b40:	ff 75 0c             	pushl  0xc(%ebp)
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
  801b46:	ff 70 0c             	pushl  0xc(%eax)
  801b49:	e8 f1 02 00 00       	call   801e3f <nsipc_recv>
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b56:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b59:	52                   	push   %edx
  801b5a:	50                   	push   %eax
  801b5b:	e8 d3 f7 ff ff       	call   801333 <fd_lookup>
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 17                	js     801b7e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6a:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801b70:	39 08                	cmp    %ecx,(%eax)
  801b72:	75 05                	jne    801b79 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b74:	8b 40 0c             	mov    0xc(%eax),%eax
  801b77:	eb 05                	jmp    801b7e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b79:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 1c             	sub    $0x1c,%esp
  801b88:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	e8 51 f7 ff ff       	call   8012e4 <fd_alloc>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	78 1b                	js     801bb7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b9c:	83 ec 04             	sub    $0x4,%esp
  801b9f:	68 07 04 00 00       	push   $0x407
  801ba4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba7:	6a 00                	push   $0x0
  801ba9:	e8 cf f1 ff ff       	call   800d7d <sys_page_alloc>
  801bae:	89 c3                	mov    %eax,%ebx
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	79 10                	jns    801bc7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	56                   	push   %esi
  801bbb:	e8 0e 02 00 00       	call   801dce <nsipc_close>
		return r;
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	89 d8                	mov    %ebx,%eax
  801bc5:	eb 24                	jmp    801beb <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bc7:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bdc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bdf:	83 ec 0c             	sub    $0xc,%esp
  801be2:	50                   	push   %eax
  801be3:	e8 d5 f6 ff ff       	call   8012bd <fd2num>
  801be8:	83 c4 10             	add    $0x10,%esp
}
  801beb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	e8 50 ff ff ff       	call   801b50 <fd2sockid>
		return r;
  801c00:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 1f                	js     801c25 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c06:	83 ec 04             	sub    $0x4,%esp
  801c09:	ff 75 10             	pushl  0x10(%ebp)
  801c0c:	ff 75 0c             	pushl  0xc(%ebp)
  801c0f:	50                   	push   %eax
  801c10:	e8 12 01 00 00       	call   801d27 <nsipc_accept>
  801c15:	83 c4 10             	add    $0x10,%esp
		return r;
  801c18:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	78 07                	js     801c25 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c1e:	e8 5d ff ff ff       	call   801b80 <alloc_sockfd>
  801c23:	89 c1                	mov    %eax,%ecx
}
  801c25:	89 c8                	mov    %ecx,%eax
  801c27:	c9                   	leave  
  801c28:	c3                   	ret    

00801c29 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c32:	e8 19 ff ff ff       	call   801b50 <fd2sockid>
  801c37:	85 c0                	test   %eax,%eax
  801c39:	78 12                	js     801c4d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c3b:	83 ec 04             	sub    $0x4,%esp
  801c3e:	ff 75 10             	pushl  0x10(%ebp)
  801c41:	ff 75 0c             	pushl  0xc(%ebp)
  801c44:	50                   	push   %eax
  801c45:	e8 2d 01 00 00       	call   801d77 <nsipc_bind>
  801c4a:	83 c4 10             	add    $0x10,%esp
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <shutdown>:

int
shutdown(int s, int how)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	e8 f3 fe ff ff       	call   801b50 <fd2sockid>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 0f                	js     801c70 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c61:	83 ec 08             	sub    $0x8,%esp
  801c64:	ff 75 0c             	pushl  0xc(%ebp)
  801c67:	50                   	push   %eax
  801c68:	e8 3f 01 00 00       	call   801dac <nsipc_shutdown>
  801c6d:	83 c4 10             	add    $0x10,%esp
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c78:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7b:	e8 d0 fe ff ff       	call   801b50 <fd2sockid>
  801c80:	85 c0                	test   %eax,%eax
  801c82:	78 12                	js     801c96 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c84:	83 ec 04             	sub    $0x4,%esp
  801c87:	ff 75 10             	pushl  0x10(%ebp)
  801c8a:	ff 75 0c             	pushl  0xc(%ebp)
  801c8d:	50                   	push   %eax
  801c8e:	e8 55 01 00 00       	call   801de8 <nsipc_connect>
  801c93:	83 c4 10             	add    $0x10,%esp
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <listen>:

int
listen(int s, int backlog)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	e8 aa fe ff ff       	call   801b50 <fd2sockid>
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	78 0f                	js     801cb9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801caa:	83 ec 08             	sub    $0x8,%esp
  801cad:	ff 75 0c             	pushl  0xc(%ebp)
  801cb0:	50                   	push   %eax
  801cb1:	e8 67 01 00 00       	call   801e1d <nsipc_listen>
  801cb6:	83 c4 10             	add    $0x10,%esp
}
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cc1:	ff 75 10             	pushl  0x10(%ebp)
  801cc4:	ff 75 0c             	pushl  0xc(%ebp)
  801cc7:	ff 75 08             	pushl  0x8(%ebp)
  801cca:	e8 3a 02 00 00       	call   801f09 <nsipc_socket>
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	78 05                	js     801cdb <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cd6:	e8 a5 fe ff ff       	call   801b80 <alloc_sockfd>
}
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    

00801cdd <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	53                   	push   %ebx
  801ce1:	83 ec 04             	sub    $0x4,%esp
  801ce4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ce6:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801ced:	75 12                	jne    801d01 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cef:	83 ec 0c             	sub    $0xc,%esp
  801cf2:	6a 02                	push   $0x2
  801cf4:	e8 bc 08 00 00       	call   8025b5 <ipc_find_env>
  801cf9:	a3 04 50 80 00       	mov    %eax,0x805004
  801cfe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d01:	6a 07                	push   $0x7
  801d03:	68 00 70 80 00       	push   $0x807000
  801d08:	53                   	push   %ebx
  801d09:	ff 35 04 50 80 00    	pushl  0x805004
  801d0f:	e8 4d 08 00 00       	call   802561 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d14:	83 c4 0c             	add    $0xc,%esp
  801d17:	6a 00                	push   $0x0
  801d19:	6a 00                	push   $0x0
  801d1b:	6a 00                	push   $0x0
  801d1d:	e8 d2 07 00 00       	call   8024f4 <ipc_recv>
}
  801d22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    

00801d27 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	56                   	push   %esi
  801d2b:	53                   	push   %ebx
  801d2c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d32:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d37:	8b 06                	mov    (%esi),%eax
  801d39:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d43:	e8 95 ff ff ff       	call   801cdd <nsipc>
  801d48:	89 c3                	mov    %eax,%ebx
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 20                	js     801d6e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d4e:	83 ec 04             	sub    $0x4,%esp
  801d51:	ff 35 10 70 80 00    	pushl  0x807010
  801d57:	68 00 70 80 00       	push   $0x807000
  801d5c:	ff 75 0c             	pushl  0xc(%ebp)
  801d5f:	e8 a8 ed ff ff       	call   800b0c <memmove>
		*addrlen = ret->ret_addrlen;
  801d64:	a1 10 70 80 00       	mov    0x807010,%eax
  801d69:	89 06                	mov    %eax,(%esi)
  801d6b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d6e:	89 d8                	mov    %ebx,%eax
  801d70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    

00801d77 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	53                   	push   %ebx
  801d7b:	83 ec 08             	sub    $0x8,%esp
  801d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d81:	8b 45 08             	mov    0x8(%ebp),%eax
  801d84:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d89:	53                   	push   %ebx
  801d8a:	ff 75 0c             	pushl  0xc(%ebp)
  801d8d:	68 04 70 80 00       	push   $0x807004
  801d92:	e8 75 ed ff ff       	call   800b0c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d97:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801d9d:	b8 02 00 00 00       	mov    $0x2,%eax
  801da2:	e8 36 ff ff ff       	call   801cdd <nsipc>
}
  801da7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801dc2:	b8 03 00 00 00       	mov    $0x3,%eax
  801dc7:	e8 11 ff ff ff       	call   801cdd <nsipc>
}
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <nsipc_close>:

int
nsipc_close(int s)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd7:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ddc:	b8 04 00 00 00       	mov    $0x4,%eax
  801de1:	e8 f7 fe ff ff       	call   801cdd <nsipc>
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	53                   	push   %ebx
  801dec:	83 ec 08             	sub    $0x8,%esp
  801def:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dfa:	53                   	push   %ebx
  801dfb:	ff 75 0c             	pushl  0xc(%ebp)
  801dfe:	68 04 70 80 00       	push   $0x807004
  801e03:	e8 04 ed ff ff       	call   800b0c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e08:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801e0e:	b8 05 00 00 00       	mov    $0x5,%eax
  801e13:	e8 c5 fe ff ff       	call   801cdd <nsipc>
}
  801e18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e23:	8b 45 08             	mov    0x8(%ebp),%eax
  801e26:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801e33:	b8 06 00 00 00       	mov    $0x6,%eax
  801e38:	e8 a0 fe ff ff       	call   801cdd <nsipc>
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801e4f:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801e55:	8b 45 14             	mov    0x14(%ebp),%eax
  801e58:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e5d:	b8 07 00 00 00       	mov    $0x7,%eax
  801e62:	e8 76 fe ff ff       	call   801cdd <nsipc>
  801e67:	89 c3                	mov    %eax,%ebx
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 35                	js     801ea2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e6d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e72:	7f 04                	jg     801e78 <nsipc_recv+0x39>
  801e74:	39 c6                	cmp    %eax,%esi
  801e76:	7d 16                	jge    801e8e <nsipc_recv+0x4f>
  801e78:	68 93 2f 80 00       	push   $0x802f93
  801e7d:	68 5b 2f 80 00       	push   $0x802f5b
  801e82:	6a 62                	push   $0x62
  801e84:	68 a8 2f 80 00       	push   $0x802fa8
  801e89:	e8 8e e4 ff ff       	call   80031c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e8e:	83 ec 04             	sub    $0x4,%esp
  801e91:	50                   	push   %eax
  801e92:	68 00 70 80 00       	push   $0x807000
  801e97:	ff 75 0c             	pushl  0xc(%ebp)
  801e9a:	e8 6d ec ff ff       	call   800b0c <memmove>
  801e9f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ea2:	89 d8                	mov    %ebx,%eax
  801ea4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea7:	5b                   	pop    %ebx
  801ea8:	5e                   	pop    %esi
  801ea9:	5d                   	pop    %ebp
  801eaa:	c3                   	ret    

00801eab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	53                   	push   %ebx
  801eaf:	83 ec 04             	sub    $0x4,%esp
  801eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801ebd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ec3:	7e 16                	jle    801edb <nsipc_send+0x30>
  801ec5:	68 b4 2f 80 00       	push   $0x802fb4
  801eca:	68 5b 2f 80 00       	push   $0x802f5b
  801ecf:	6a 6d                	push   $0x6d
  801ed1:	68 a8 2f 80 00       	push   $0x802fa8
  801ed6:	e8 41 e4 ff ff       	call   80031c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801edb:	83 ec 04             	sub    $0x4,%esp
  801ede:	53                   	push   %ebx
  801edf:	ff 75 0c             	pushl  0xc(%ebp)
  801ee2:	68 0c 70 80 00       	push   $0x80700c
  801ee7:	e8 20 ec ff ff       	call   800b0c <memmove>
	nsipcbuf.send.req_size = size;
  801eec:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801ef2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ef5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801efa:	b8 08 00 00 00       	mov    $0x8,%eax
  801eff:	e8 d9 fd ff ff       	call   801cdd <nsipc>
}
  801f04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f12:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1a:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801f22:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801f27:	b8 09 00 00 00       	mov    $0x9,%eax
  801f2c:	e8 ac fd ff ff       	call   801cdd <nsipc>
}
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f3b:	83 ec 0c             	sub    $0xc,%esp
  801f3e:	ff 75 08             	pushl  0x8(%ebp)
  801f41:	e8 87 f3 ff ff       	call   8012cd <fd2data>
  801f46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f48:	83 c4 08             	add    $0x8,%esp
  801f4b:	68 c0 2f 80 00       	push   $0x802fc0
  801f50:	53                   	push   %ebx
  801f51:	e8 24 ea ff ff       	call   80097a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f56:	8b 46 04             	mov    0x4(%esi),%eax
  801f59:	2b 06                	sub    (%esi),%eax
  801f5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f68:	00 00 00 
	stat->st_dev = &devpipe;
  801f6b:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  801f72:	40 80 00 
	return 0;
}
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    

00801f81 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	53                   	push   %ebx
  801f85:	83 ec 0c             	sub    $0xc,%esp
  801f88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f8b:	53                   	push   %ebx
  801f8c:	6a 00                	push   $0x0
  801f8e:	e8 6f ee ff ff       	call   800e02 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f93:	89 1c 24             	mov    %ebx,(%esp)
  801f96:	e8 32 f3 ff ff       	call   8012cd <fd2data>
  801f9b:	83 c4 08             	add    $0x8,%esp
  801f9e:	50                   	push   %eax
  801f9f:	6a 00                	push   $0x0
  801fa1:	e8 5c ee ff ff       	call   800e02 <sys_page_unmap>
}
  801fa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	57                   	push   %edi
  801faf:	56                   	push   %esi
  801fb0:	53                   	push   %ebx
  801fb1:	83 ec 1c             	sub    $0x1c,%esp
  801fb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fb7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fb9:	a1 08 50 80 00       	mov    0x805008,%eax
  801fbe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fc1:	83 ec 0c             	sub    $0xc,%esp
  801fc4:	ff 75 e0             	pushl  -0x20(%ebp)
  801fc7:	e8 22 06 00 00       	call   8025ee <pageref>
  801fcc:	89 c3                	mov    %eax,%ebx
  801fce:	89 3c 24             	mov    %edi,(%esp)
  801fd1:	e8 18 06 00 00       	call   8025ee <pageref>
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	39 c3                	cmp    %eax,%ebx
  801fdb:	0f 94 c1             	sete   %cl
  801fde:	0f b6 c9             	movzbl %cl,%ecx
  801fe1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fe4:	8b 15 08 50 80 00    	mov    0x805008,%edx
  801fea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fed:	39 ce                	cmp    %ecx,%esi
  801fef:	74 1b                	je     80200c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ff1:	39 c3                	cmp    %eax,%ebx
  801ff3:	75 c4                	jne    801fb9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ff5:	8b 42 58             	mov    0x58(%edx),%eax
  801ff8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ffb:	50                   	push   %eax
  801ffc:	56                   	push   %esi
  801ffd:	68 c7 2f 80 00       	push   $0x802fc7
  802002:	e8 ee e3 ff ff       	call   8003f5 <cprintf>
  802007:	83 c4 10             	add    $0x10,%esp
  80200a:	eb ad                	jmp    801fb9 <_pipeisclosed+0xe>
	}
}
  80200c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80200f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802012:	5b                   	pop    %ebx
  802013:	5e                   	pop    %esi
  802014:	5f                   	pop    %edi
  802015:	5d                   	pop    %ebp
  802016:	c3                   	ret    

00802017 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	57                   	push   %edi
  80201b:	56                   	push   %esi
  80201c:	53                   	push   %ebx
  80201d:	83 ec 28             	sub    $0x28,%esp
  802020:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802023:	56                   	push   %esi
  802024:	e8 a4 f2 ff ff       	call   8012cd <fd2data>
  802029:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	bf 00 00 00 00       	mov    $0x0,%edi
  802033:	eb 4b                	jmp    802080 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802035:	89 da                	mov    %ebx,%edx
  802037:	89 f0                	mov    %esi,%eax
  802039:	e8 6d ff ff ff       	call   801fab <_pipeisclosed>
  80203e:	85 c0                	test   %eax,%eax
  802040:	75 48                	jne    80208a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802042:	e8 17 ed ff ff       	call   800d5e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802047:	8b 43 04             	mov    0x4(%ebx),%eax
  80204a:	8b 0b                	mov    (%ebx),%ecx
  80204c:	8d 51 20             	lea    0x20(%ecx),%edx
  80204f:	39 d0                	cmp    %edx,%eax
  802051:	73 e2                	jae    802035 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802053:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802056:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80205a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80205d:	89 c2                	mov    %eax,%edx
  80205f:	c1 fa 1f             	sar    $0x1f,%edx
  802062:	89 d1                	mov    %edx,%ecx
  802064:	c1 e9 1b             	shr    $0x1b,%ecx
  802067:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80206a:	83 e2 1f             	and    $0x1f,%edx
  80206d:	29 ca                	sub    %ecx,%edx
  80206f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802073:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802077:	83 c0 01             	add    $0x1,%eax
  80207a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80207d:	83 c7 01             	add    $0x1,%edi
  802080:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802083:	75 c2                	jne    802047 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802085:	8b 45 10             	mov    0x10(%ebp),%eax
  802088:	eb 05                	jmp    80208f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80208a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80208f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802092:	5b                   	pop    %ebx
  802093:	5e                   	pop    %esi
  802094:	5f                   	pop    %edi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	57                   	push   %edi
  80209b:	56                   	push   %esi
  80209c:	53                   	push   %ebx
  80209d:	83 ec 18             	sub    $0x18,%esp
  8020a0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020a3:	57                   	push   %edi
  8020a4:	e8 24 f2 ff ff       	call   8012cd <fd2data>
  8020a9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ab:	83 c4 10             	add    $0x10,%esp
  8020ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020b3:	eb 3d                	jmp    8020f2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020b5:	85 db                	test   %ebx,%ebx
  8020b7:	74 04                	je     8020bd <devpipe_read+0x26>
				return i;
  8020b9:	89 d8                	mov    %ebx,%eax
  8020bb:	eb 44                	jmp    802101 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020bd:	89 f2                	mov    %esi,%edx
  8020bf:	89 f8                	mov    %edi,%eax
  8020c1:	e8 e5 fe ff ff       	call   801fab <_pipeisclosed>
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	75 32                	jne    8020fc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020ca:	e8 8f ec ff ff       	call   800d5e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020cf:	8b 06                	mov    (%esi),%eax
  8020d1:	3b 46 04             	cmp    0x4(%esi),%eax
  8020d4:	74 df                	je     8020b5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020d6:	99                   	cltd   
  8020d7:	c1 ea 1b             	shr    $0x1b,%edx
  8020da:	01 d0                	add    %edx,%eax
  8020dc:	83 e0 1f             	and    $0x1f,%eax
  8020df:	29 d0                	sub    %edx,%eax
  8020e1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020e9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020ec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ef:	83 c3 01             	add    $0x1,%ebx
  8020f2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020f5:	75 d8                	jne    8020cf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8020fa:	eb 05                	jmp    802101 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020fc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    

00802109 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	56                   	push   %esi
  80210d:	53                   	push   %ebx
  80210e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802114:	50                   	push   %eax
  802115:	e8 ca f1 ff ff       	call   8012e4 <fd_alloc>
  80211a:	83 c4 10             	add    $0x10,%esp
  80211d:	89 c2                	mov    %eax,%edx
  80211f:	85 c0                	test   %eax,%eax
  802121:	0f 88 2c 01 00 00    	js     802253 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802127:	83 ec 04             	sub    $0x4,%esp
  80212a:	68 07 04 00 00       	push   $0x407
  80212f:	ff 75 f4             	pushl  -0xc(%ebp)
  802132:	6a 00                	push   $0x0
  802134:	e8 44 ec ff ff       	call   800d7d <sys_page_alloc>
  802139:	83 c4 10             	add    $0x10,%esp
  80213c:	89 c2                	mov    %eax,%edx
  80213e:	85 c0                	test   %eax,%eax
  802140:	0f 88 0d 01 00 00    	js     802253 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802146:	83 ec 0c             	sub    $0xc,%esp
  802149:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80214c:	50                   	push   %eax
  80214d:	e8 92 f1 ff ff       	call   8012e4 <fd_alloc>
  802152:	89 c3                	mov    %eax,%ebx
  802154:	83 c4 10             	add    $0x10,%esp
  802157:	85 c0                	test   %eax,%eax
  802159:	0f 88 e2 00 00 00    	js     802241 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80215f:	83 ec 04             	sub    $0x4,%esp
  802162:	68 07 04 00 00       	push   $0x407
  802167:	ff 75 f0             	pushl  -0x10(%ebp)
  80216a:	6a 00                	push   $0x0
  80216c:	e8 0c ec ff ff       	call   800d7d <sys_page_alloc>
  802171:	89 c3                	mov    %eax,%ebx
  802173:	83 c4 10             	add    $0x10,%esp
  802176:	85 c0                	test   %eax,%eax
  802178:	0f 88 c3 00 00 00    	js     802241 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80217e:	83 ec 0c             	sub    $0xc,%esp
  802181:	ff 75 f4             	pushl  -0xc(%ebp)
  802184:	e8 44 f1 ff ff       	call   8012cd <fd2data>
  802189:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218b:	83 c4 0c             	add    $0xc,%esp
  80218e:	68 07 04 00 00       	push   $0x407
  802193:	50                   	push   %eax
  802194:	6a 00                	push   $0x0
  802196:	e8 e2 eb ff ff       	call   800d7d <sys_page_alloc>
  80219b:	89 c3                	mov    %eax,%ebx
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	85 c0                	test   %eax,%eax
  8021a2:	0f 88 89 00 00 00    	js     802231 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a8:	83 ec 0c             	sub    $0xc,%esp
  8021ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ae:	e8 1a f1 ff ff       	call   8012cd <fd2data>
  8021b3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021ba:	50                   	push   %eax
  8021bb:	6a 00                	push   $0x0
  8021bd:	56                   	push   %esi
  8021be:	6a 00                	push   $0x0
  8021c0:	e8 fb eb ff ff       	call   800dc0 <sys_page_map>
  8021c5:	89 c3                	mov    %eax,%ebx
  8021c7:	83 c4 20             	add    $0x20,%esp
  8021ca:	85 c0                	test   %eax,%eax
  8021cc:	78 55                	js     802223 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021ce:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8021d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021e3:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8021e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021f8:	83 ec 0c             	sub    $0xc,%esp
  8021fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8021fe:	e8 ba f0 ff ff       	call   8012bd <fd2num>
  802203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802206:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802208:	83 c4 04             	add    $0x4,%esp
  80220b:	ff 75 f0             	pushl  -0x10(%ebp)
  80220e:	e8 aa f0 ff ff       	call   8012bd <fd2num>
  802213:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802216:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802219:	83 c4 10             	add    $0x10,%esp
  80221c:	ba 00 00 00 00       	mov    $0x0,%edx
  802221:	eb 30                	jmp    802253 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802223:	83 ec 08             	sub    $0x8,%esp
  802226:	56                   	push   %esi
  802227:	6a 00                	push   $0x0
  802229:	e8 d4 eb ff ff       	call   800e02 <sys_page_unmap>
  80222e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802231:	83 ec 08             	sub    $0x8,%esp
  802234:	ff 75 f0             	pushl  -0x10(%ebp)
  802237:	6a 00                	push   $0x0
  802239:	e8 c4 eb ff ff       	call   800e02 <sys_page_unmap>
  80223e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802241:	83 ec 08             	sub    $0x8,%esp
  802244:	ff 75 f4             	pushl  -0xc(%ebp)
  802247:	6a 00                	push   $0x0
  802249:	e8 b4 eb ff ff       	call   800e02 <sys_page_unmap>
  80224e:	83 c4 10             	add    $0x10,%esp
  802251:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802253:	89 d0                	mov    %edx,%eax
  802255:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    

0080225c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802265:	50                   	push   %eax
  802266:	ff 75 08             	pushl  0x8(%ebp)
  802269:	e8 c5 f0 ff ff       	call   801333 <fd_lookup>
  80226e:	83 c4 10             	add    $0x10,%esp
  802271:	85 c0                	test   %eax,%eax
  802273:	78 18                	js     80228d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802275:	83 ec 0c             	sub    $0xc,%esp
  802278:	ff 75 f4             	pushl  -0xc(%ebp)
  80227b:	e8 4d f0 ff ff       	call   8012cd <fd2data>
	return _pipeisclosed(fd, p);
  802280:	89 c2                	mov    %eax,%edx
  802282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802285:	e8 21 fd ff ff       	call   801fab <_pipeisclosed>
  80228a:	83 c4 10             	add    $0x10,%esp
}
  80228d:	c9                   	leave  
  80228e:	c3                   	ret    

0080228f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80228f:	55                   	push   %ebp
  802290:	89 e5                	mov    %esp,%ebp
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802297:	85 f6                	test   %esi,%esi
  802299:	75 16                	jne    8022b1 <wait+0x22>
  80229b:	68 df 2f 80 00       	push   $0x802fdf
  8022a0:	68 5b 2f 80 00       	push   $0x802f5b
  8022a5:	6a 09                	push   $0x9
  8022a7:	68 ea 2f 80 00       	push   $0x802fea
  8022ac:	e8 6b e0 ff ff       	call   80031c <_panic>
	e = &envs[ENVX(envid)];
  8022b1:	89 f3                	mov    %esi,%ebx
  8022b3:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022b9:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022bc:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8022c2:	eb 05                	jmp    8022c9 <wait+0x3a>
		sys_yield();
  8022c4:	e8 95 ea ff ff       	call   800d5e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022c9:	8b 43 48             	mov    0x48(%ebx),%eax
  8022cc:	39 c6                	cmp    %eax,%esi
  8022ce:	75 07                	jne    8022d7 <wait+0x48>
  8022d0:	8b 43 54             	mov    0x54(%ebx),%eax
  8022d3:	85 c0                	test   %eax,%eax
  8022d5:	75 ed                	jne    8022c4 <wait+0x35>
		sys_yield();
}
  8022d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022da:	5b                   	pop    %ebx
  8022db:	5e                   	pop    %esi
  8022dc:	5d                   	pop    %ebp
  8022dd:	c3                   	ret    

008022de <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022de:	55                   	push   %ebp
  8022df:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    

008022e8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022ee:	68 f5 2f 80 00       	push   $0x802ff5
  8022f3:	ff 75 0c             	pushl  0xc(%ebp)
  8022f6:	e8 7f e6 ff ff       	call   80097a <strcpy>
	return 0;
}
  8022fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802300:	c9                   	leave  
  802301:	c3                   	ret    

00802302 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	57                   	push   %edi
  802306:	56                   	push   %esi
  802307:	53                   	push   %ebx
  802308:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80230e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802313:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802319:	eb 2d                	jmp    802348 <devcons_write+0x46>
		m = n - tot;
  80231b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80231e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802320:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802323:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802328:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80232b:	83 ec 04             	sub    $0x4,%esp
  80232e:	53                   	push   %ebx
  80232f:	03 45 0c             	add    0xc(%ebp),%eax
  802332:	50                   	push   %eax
  802333:	57                   	push   %edi
  802334:	e8 d3 e7 ff ff       	call   800b0c <memmove>
		sys_cputs(buf, m);
  802339:	83 c4 08             	add    $0x8,%esp
  80233c:	53                   	push   %ebx
  80233d:	57                   	push   %edi
  80233e:	e8 7e e9 ff ff       	call   800cc1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802343:	01 de                	add    %ebx,%esi
  802345:	83 c4 10             	add    $0x10,%esp
  802348:	89 f0                	mov    %esi,%eax
  80234a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80234d:	72 cc                	jb     80231b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80234f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802352:	5b                   	pop    %ebx
  802353:	5e                   	pop    %esi
  802354:	5f                   	pop    %edi
  802355:	5d                   	pop    %ebp
  802356:	c3                   	ret    

00802357 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
  80235a:	83 ec 08             	sub    $0x8,%esp
  80235d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802362:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802366:	74 2a                	je     802392 <devcons_read+0x3b>
  802368:	eb 05                	jmp    80236f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80236a:	e8 ef e9 ff ff       	call   800d5e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80236f:	e8 6b e9 ff ff       	call   800cdf <sys_cgetc>
  802374:	85 c0                	test   %eax,%eax
  802376:	74 f2                	je     80236a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802378:	85 c0                	test   %eax,%eax
  80237a:	78 16                	js     802392 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80237c:	83 f8 04             	cmp    $0x4,%eax
  80237f:	74 0c                	je     80238d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802381:	8b 55 0c             	mov    0xc(%ebp),%edx
  802384:	88 02                	mov    %al,(%edx)
	return 1;
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	eb 05                	jmp    802392 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80238d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802392:	c9                   	leave  
  802393:	c3                   	ret    

00802394 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80239a:	8b 45 08             	mov    0x8(%ebp),%eax
  80239d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023a0:	6a 01                	push   $0x1
  8023a2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023a5:	50                   	push   %eax
  8023a6:	e8 16 e9 ff ff       	call   800cc1 <sys_cputs>
}
  8023ab:	83 c4 10             	add    $0x10,%esp
  8023ae:	c9                   	leave  
  8023af:	c3                   	ret    

008023b0 <getchar>:

int
getchar(void)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023b6:	6a 01                	push   $0x1
  8023b8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023bb:	50                   	push   %eax
  8023bc:	6a 00                	push   $0x0
  8023be:	e8 d6 f1 ff ff       	call   801599 <read>
	if (r < 0)
  8023c3:	83 c4 10             	add    $0x10,%esp
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	78 0f                	js     8023d9 <getchar+0x29>
		return r;
	if (r < 1)
  8023ca:	85 c0                	test   %eax,%eax
  8023cc:	7e 06                	jle    8023d4 <getchar+0x24>
		return -E_EOF;
	return c;
  8023ce:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023d2:	eb 05                	jmp    8023d9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023d4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023d9:	c9                   	leave  
  8023da:	c3                   	ret    

008023db <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023db:	55                   	push   %ebp
  8023dc:	89 e5                	mov    %esp,%ebp
  8023de:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e4:	50                   	push   %eax
  8023e5:	ff 75 08             	pushl  0x8(%ebp)
  8023e8:	e8 46 ef ff ff       	call   801333 <fd_lookup>
  8023ed:	83 c4 10             	add    $0x10,%esp
  8023f0:	85 c0                	test   %eax,%eax
  8023f2:	78 11                	js     802405 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f7:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8023fd:	39 10                	cmp    %edx,(%eax)
  8023ff:	0f 94 c0             	sete   %al
  802402:	0f b6 c0             	movzbl %al,%eax
}
  802405:	c9                   	leave  
  802406:	c3                   	ret    

00802407 <opencons>:

int
opencons(void)
{
  802407:	55                   	push   %ebp
  802408:	89 e5                	mov    %esp,%ebp
  80240a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80240d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802410:	50                   	push   %eax
  802411:	e8 ce ee ff ff       	call   8012e4 <fd_alloc>
  802416:	83 c4 10             	add    $0x10,%esp
		return r;
  802419:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80241b:	85 c0                	test   %eax,%eax
  80241d:	78 3e                	js     80245d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80241f:	83 ec 04             	sub    $0x4,%esp
  802422:	68 07 04 00 00       	push   $0x407
  802427:	ff 75 f4             	pushl  -0xc(%ebp)
  80242a:	6a 00                	push   $0x0
  80242c:	e8 4c e9 ff ff       	call   800d7d <sys_page_alloc>
  802431:	83 c4 10             	add    $0x10,%esp
		return r;
  802434:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802436:	85 c0                	test   %eax,%eax
  802438:	78 23                	js     80245d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80243a:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802443:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802445:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802448:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80244f:	83 ec 0c             	sub    $0xc,%esp
  802452:	50                   	push   %eax
  802453:	e8 65 ee ff ff       	call   8012bd <fd2num>
  802458:	89 c2                	mov    %eax,%edx
  80245a:	83 c4 10             	add    $0x10,%esp
}
  80245d:	89 d0                	mov    %edx,%eax
  80245f:	c9                   	leave  
  802460:	c3                   	ret    

00802461 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802461:	55                   	push   %ebp
  802462:	89 e5                	mov    %esp,%ebp
  802464:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802467:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80246e:	75 2c                	jne    80249c <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802470:	83 ec 04             	sub    $0x4,%esp
  802473:	6a 07                	push   $0x7
  802475:	68 00 f0 bf ee       	push   $0xeebff000
  80247a:	6a 00                	push   $0x0
  80247c:	e8 fc e8 ff ff       	call   800d7d <sys_page_alloc>
  802481:	83 c4 10             	add    $0x10,%esp
  802484:	85 c0                	test   %eax,%eax
  802486:	79 14                	jns    80249c <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  802488:	83 ec 04             	sub    $0x4,%esp
  80248b:	68 01 30 80 00       	push   $0x803001
  802490:	6a 22                	push   $0x22
  802492:	68 18 30 80 00       	push   $0x803018
  802497:	e8 80 de ff ff       	call   80031c <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  80249c:	8b 45 08             	mov    0x8(%ebp),%eax
  80249f:	a3 00 80 80 00       	mov    %eax,0x808000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8024a4:	83 ec 08             	sub    $0x8,%esp
  8024a7:	68 d0 24 80 00       	push   $0x8024d0
  8024ac:	6a 00                	push   $0x0
  8024ae:	e8 15 ea ff ff       	call   800ec8 <sys_env_set_pgfault_upcall>
  8024b3:	83 c4 10             	add    $0x10,%esp
  8024b6:	85 c0                	test   %eax,%eax
  8024b8:	79 14                	jns    8024ce <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8024ba:	83 ec 04             	sub    $0x4,%esp
  8024bd:	68 28 30 80 00       	push   $0x803028
  8024c2:	6a 27                	push   $0x27
  8024c4:	68 18 30 80 00       	push   $0x803018
  8024c9:	e8 4e de ff ff       	call   80031c <_panic>
    
}
  8024ce:	c9                   	leave  
  8024cf:	c3                   	ret    

008024d0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024d0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024d1:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8024d6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024d8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8024db:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8024df:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8024e4:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8024e8:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8024ea:	83 c4 08             	add    $0x8,%esp
	popal
  8024ed:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8024ee:	83 c4 04             	add    $0x4,%esp
	popfl
  8024f1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8024f2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024f3:	c3                   	ret    

008024f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024f4:	55                   	push   %ebp
  8024f5:	89 e5                	mov    %esp,%ebp
  8024f7:	56                   	push   %esi
  8024f8:	53                   	push   %ebx
  8024f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8024fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802502:	85 c0                	test   %eax,%eax
  802504:	74 0e                	je     802514 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  802506:	83 ec 0c             	sub    $0xc,%esp
  802509:	50                   	push   %eax
  80250a:	e8 1e ea ff ff       	call   800f2d <sys_ipc_recv>
  80250f:	83 c4 10             	add    $0x10,%esp
  802512:	eb 10                	jmp    802524 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802514:	83 ec 0c             	sub    $0xc,%esp
  802517:	68 00 00 00 f0       	push   $0xf0000000
  80251c:	e8 0c ea ff ff       	call   800f2d <sys_ipc_recv>
  802521:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  802524:	85 c0                	test   %eax,%eax
  802526:	74 0e                	je     802536 <ipc_recv+0x42>
    	*from_env_store = 0;
  802528:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  80252e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  802534:	eb 24                	jmp    80255a <ipc_recv+0x66>
    }	
    if (from_env_store) {
  802536:	85 f6                	test   %esi,%esi
  802538:	74 0a                	je     802544 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  80253a:	a1 08 50 80 00       	mov    0x805008,%eax
  80253f:	8b 40 74             	mov    0x74(%eax),%eax
  802542:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802544:	85 db                	test   %ebx,%ebx
  802546:	74 0a                	je     802552 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802548:	a1 08 50 80 00       	mov    0x805008,%eax
  80254d:	8b 40 78             	mov    0x78(%eax),%eax
  802550:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802552:	a1 08 50 80 00       	mov    0x805008,%eax
  802557:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80255a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    

00802561 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	57                   	push   %edi
  802565:	56                   	push   %esi
  802566:	53                   	push   %ebx
  802567:	83 ec 0c             	sub    $0xc,%esp
  80256a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80256d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802570:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802573:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802575:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80257a:	0f 44 d8             	cmove  %eax,%ebx
  80257d:	eb 1c                	jmp    80259b <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80257f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802582:	74 12                	je     802596 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802584:	50                   	push   %eax
  802585:	68 4c 30 80 00       	push   $0x80304c
  80258a:	6a 4b                	push   $0x4b
  80258c:	68 64 30 80 00       	push   $0x803064
  802591:	e8 86 dd ff ff       	call   80031c <_panic>
        }	
        sys_yield();
  802596:	e8 c3 e7 ff ff       	call   800d5e <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80259b:	ff 75 14             	pushl  0x14(%ebp)
  80259e:	53                   	push   %ebx
  80259f:	56                   	push   %esi
  8025a0:	57                   	push   %edi
  8025a1:	e8 64 e9 ff ff       	call   800f0a <sys_ipc_try_send>
  8025a6:	83 c4 10             	add    $0x10,%esp
  8025a9:	85 c0                	test   %eax,%eax
  8025ab:	75 d2                	jne    80257f <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8025ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025b0:	5b                   	pop    %ebx
  8025b1:	5e                   	pop    %esi
  8025b2:	5f                   	pop    %edi
  8025b3:	5d                   	pop    %ebp
  8025b4:	c3                   	ret    

008025b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025b5:	55                   	push   %ebp
  8025b6:	89 e5                	mov    %esp,%ebp
  8025b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025c0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025c3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025c9:	8b 52 50             	mov    0x50(%edx),%edx
  8025cc:	39 ca                	cmp    %ecx,%edx
  8025ce:	75 0d                	jne    8025dd <ipc_find_env+0x28>
			return envs[i].env_id;
  8025d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025d8:	8b 40 48             	mov    0x48(%eax),%eax
  8025db:	eb 0f                	jmp    8025ec <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025dd:	83 c0 01             	add    $0x1,%eax
  8025e0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025e5:	75 d9                	jne    8025c0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025ec:	5d                   	pop    %ebp
  8025ed:	c3                   	ret    

008025ee <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025ee:	55                   	push   %ebp
  8025ef:	89 e5                	mov    %esp,%ebp
  8025f1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025f4:	89 d0                	mov    %edx,%eax
  8025f6:	c1 e8 16             	shr    $0x16,%eax
  8025f9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802600:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802605:	f6 c1 01             	test   $0x1,%cl
  802608:	74 1d                	je     802627 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80260a:	c1 ea 0c             	shr    $0xc,%edx
  80260d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802614:	f6 c2 01             	test   $0x1,%dl
  802617:	74 0e                	je     802627 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802619:	c1 ea 0c             	shr    $0xc,%edx
  80261c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802623:	ef 
  802624:	0f b7 c0             	movzwl %ax,%eax
}
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    
  802629:	66 90                	xchg   %ax,%ax
  80262b:	66 90                	xchg   %ax,%ax
  80262d:	66 90                	xchg   %ax,%ax
  80262f:	90                   	nop

00802630 <__udivdi3>:
  802630:	55                   	push   %ebp
  802631:	57                   	push   %edi
  802632:	56                   	push   %esi
  802633:	53                   	push   %ebx
  802634:	83 ec 1c             	sub    $0x1c,%esp
  802637:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80263b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80263f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802643:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802647:	85 f6                	test   %esi,%esi
  802649:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80264d:	89 ca                	mov    %ecx,%edx
  80264f:	89 f8                	mov    %edi,%eax
  802651:	75 3d                	jne    802690 <__udivdi3+0x60>
  802653:	39 cf                	cmp    %ecx,%edi
  802655:	0f 87 c5 00 00 00    	ja     802720 <__udivdi3+0xf0>
  80265b:	85 ff                	test   %edi,%edi
  80265d:	89 fd                	mov    %edi,%ebp
  80265f:	75 0b                	jne    80266c <__udivdi3+0x3c>
  802661:	b8 01 00 00 00       	mov    $0x1,%eax
  802666:	31 d2                	xor    %edx,%edx
  802668:	f7 f7                	div    %edi
  80266a:	89 c5                	mov    %eax,%ebp
  80266c:	89 c8                	mov    %ecx,%eax
  80266e:	31 d2                	xor    %edx,%edx
  802670:	f7 f5                	div    %ebp
  802672:	89 c1                	mov    %eax,%ecx
  802674:	89 d8                	mov    %ebx,%eax
  802676:	89 cf                	mov    %ecx,%edi
  802678:	f7 f5                	div    %ebp
  80267a:	89 c3                	mov    %eax,%ebx
  80267c:	89 d8                	mov    %ebx,%eax
  80267e:	89 fa                	mov    %edi,%edx
  802680:	83 c4 1c             	add    $0x1c,%esp
  802683:	5b                   	pop    %ebx
  802684:	5e                   	pop    %esi
  802685:	5f                   	pop    %edi
  802686:	5d                   	pop    %ebp
  802687:	c3                   	ret    
  802688:	90                   	nop
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	39 ce                	cmp    %ecx,%esi
  802692:	77 74                	ja     802708 <__udivdi3+0xd8>
  802694:	0f bd fe             	bsr    %esi,%edi
  802697:	83 f7 1f             	xor    $0x1f,%edi
  80269a:	0f 84 98 00 00 00    	je     802738 <__udivdi3+0x108>
  8026a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026a5:	89 f9                	mov    %edi,%ecx
  8026a7:	89 c5                	mov    %eax,%ebp
  8026a9:	29 fb                	sub    %edi,%ebx
  8026ab:	d3 e6                	shl    %cl,%esi
  8026ad:	89 d9                	mov    %ebx,%ecx
  8026af:	d3 ed                	shr    %cl,%ebp
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	d3 e0                	shl    %cl,%eax
  8026b5:	09 ee                	or     %ebp,%esi
  8026b7:	89 d9                	mov    %ebx,%ecx
  8026b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026bd:	89 d5                	mov    %edx,%ebp
  8026bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026c3:	d3 ed                	shr    %cl,%ebp
  8026c5:	89 f9                	mov    %edi,%ecx
  8026c7:	d3 e2                	shl    %cl,%edx
  8026c9:	89 d9                	mov    %ebx,%ecx
  8026cb:	d3 e8                	shr    %cl,%eax
  8026cd:	09 c2                	or     %eax,%edx
  8026cf:	89 d0                	mov    %edx,%eax
  8026d1:	89 ea                	mov    %ebp,%edx
  8026d3:	f7 f6                	div    %esi
  8026d5:	89 d5                	mov    %edx,%ebp
  8026d7:	89 c3                	mov    %eax,%ebx
  8026d9:	f7 64 24 0c          	mull   0xc(%esp)
  8026dd:	39 d5                	cmp    %edx,%ebp
  8026df:	72 10                	jb     8026f1 <__udivdi3+0xc1>
  8026e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	d3 e6                	shl    %cl,%esi
  8026e9:	39 c6                	cmp    %eax,%esi
  8026eb:	73 07                	jae    8026f4 <__udivdi3+0xc4>
  8026ed:	39 d5                	cmp    %edx,%ebp
  8026ef:	75 03                	jne    8026f4 <__udivdi3+0xc4>
  8026f1:	83 eb 01             	sub    $0x1,%ebx
  8026f4:	31 ff                	xor    %edi,%edi
  8026f6:	89 d8                	mov    %ebx,%eax
  8026f8:	89 fa                	mov    %edi,%edx
  8026fa:	83 c4 1c             	add    $0x1c,%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
  802702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802708:	31 ff                	xor    %edi,%edi
  80270a:	31 db                	xor    %ebx,%ebx
  80270c:	89 d8                	mov    %ebx,%eax
  80270e:	89 fa                	mov    %edi,%edx
  802710:	83 c4 1c             	add    $0x1c,%esp
  802713:	5b                   	pop    %ebx
  802714:	5e                   	pop    %esi
  802715:	5f                   	pop    %edi
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    
  802718:	90                   	nop
  802719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802720:	89 d8                	mov    %ebx,%eax
  802722:	f7 f7                	div    %edi
  802724:	31 ff                	xor    %edi,%edi
  802726:	89 c3                	mov    %eax,%ebx
  802728:	89 d8                	mov    %ebx,%eax
  80272a:	89 fa                	mov    %edi,%edx
  80272c:	83 c4 1c             	add    $0x1c,%esp
  80272f:	5b                   	pop    %ebx
  802730:	5e                   	pop    %esi
  802731:	5f                   	pop    %edi
  802732:	5d                   	pop    %ebp
  802733:	c3                   	ret    
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	39 ce                	cmp    %ecx,%esi
  80273a:	72 0c                	jb     802748 <__udivdi3+0x118>
  80273c:	31 db                	xor    %ebx,%ebx
  80273e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802742:	0f 87 34 ff ff ff    	ja     80267c <__udivdi3+0x4c>
  802748:	bb 01 00 00 00       	mov    $0x1,%ebx
  80274d:	e9 2a ff ff ff       	jmp    80267c <__udivdi3+0x4c>
  802752:	66 90                	xchg   %ax,%ax
  802754:	66 90                	xchg   %ax,%ax
  802756:	66 90                	xchg   %ax,%ax
  802758:	66 90                	xchg   %ax,%ax
  80275a:	66 90                	xchg   %ax,%ax
  80275c:	66 90                	xchg   %ax,%ax
  80275e:	66 90                	xchg   %ax,%ax

00802760 <__umoddi3>:
  802760:	55                   	push   %ebp
  802761:	57                   	push   %edi
  802762:	56                   	push   %esi
  802763:	53                   	push   %ebx
  802764:	83 ec 1c             	sub    $0x1c,%esp
  802767:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80276b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80276f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802773:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802777:	85 d2                	test   %edx,%edx
  802779:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80277d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802781:	89 f3                	mov    %esi,%ebx
  802783:	89 3c 24             	mov    %edi,(%esp)
  802786:	89 74 24 04          	mov    %esi,0x4(%esp)
  80278a:	75 1c                	jne    8027a8 <__umoddi3+0x48>
  80278c:	39 f7                	cmp    %esi,%edi
  80278e:	76 50                	jbe    8027e0 <__umoddi3+0x80>
  802790:	89 c8                	mov    %ecx,%eax
  802792:	89 f2                	mov    %esi,%edx
  802794:	f7 f7                	div    %edi
  802796:	89 d0                	mov    %edx,%eax
  802798:	31 d2                	xor    %edx,%edx
  80279a:	83 c4 1c             	add    $0x1c,%esp
  80279d:	5b                   	pop    %ebx
  80279e:	5e                   	pop    %esi
  80279f:	5f                   	pop    %edi
  8027a0:	5d                   	pop    %ebp
  8027a1:	c3                   	ret    
  8027a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027a8:	39 f2                	cmp    %esi,%edx
  8027aa:	89 d0                	mov    %edx,%eax
  8027ac:	77 52                	ja     802800 <__umoddi3+0xa0>
  8027ae:	0f bd ea             	bsr    %edx,%ebp
  8027b1:	83 f5 1f             	xor    $0x1f,%ebp
  8027b4:	75 5a                	jne    802810 <__umoddi3+0xb0>
  8027b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027ba:	0f 82 e0 00 00 00    	jb     8028a0 <__umoddi3+0x140>
  8027c0:	39 0c 24             	cmp    %ecx,(%esp)
  8027c3:	0f 86 d7 00 00 00    	jbe    8028a0 <__umoddi3+0x140>
  8027c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027d1:	83 c4 1c             	add    $0x1c,%esp
  8027d4:	5b                   	pop    %ebx
  8027d5:	5e                   	pop    %esi
  8027d6:	5f                   	pop    %edi
  8027d7:	5d                   	pop    %ebp
  8027d8:	c3                   	ret    
  8027d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	85 ff                	test   %edi,%edi
  8027e2:	89 fd                	mov    %edi,%ebp
  8027e4:	75 0b                	jne    8027f1 <__umoddi3+0x91>
  8027e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027eb:	31 d2                	xor    %edx,%edx
  8027ed:	f7 f7                	div    %edi
  8027ef:	89 c5                	mov    %eax,%ebp
  8027f1:	89 f0                	mov    %esi,%eax
  8027f3:	31 d2                	xor    %edx,%edx
  8027f5:	f7 f5                	div    %ebp
  8027f7:	89 c8                	mov    %ecx,%eax
  8027f9:	f7 f5                	div    %ebp
  8027fb:	89 d0                	mov    %edx,%eax
  8027fd:	eb 99                	jmp    802798 <__umoddi3+0x38>
  8027ff:	90                   	nop
  802800:	89 c8                	mov    %ecx,%eax
  802802:	89 f2                	mov    %esi,%edx
  802804:	83 c4 1c             	add    $0x1c,%esp
  802807:	5b                   	pop    %ebx
  802808:	5e                   	pop    %esi
  802809:	5f                   	pop    %edi
  80280a:	5d                   	pop    %ebp
  80280b:	c3                   	ret    
  80280c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802810:	8b 34 24             	mov    (%esp),%esi
  802813:	bf 20 00 00 00       	mov    $0x20,%edi
  802818:	89 e9                	mov    %ebp,%ecx
  80281a:	29 ef                	sub    %ebp,%edi
  80281c:	d3 e0                	shl    %cl,%eax
  80281e:	89 f9                	mov    %edi,%ecx
  802820:	89 f2                	mov    %esi,%edx
  802822:	d3 ea                	shr    %cl,%edx
  802824:	89 e9                	mov    %ebp,%ecx
  802826:	09 c2                	or     %eax,%edx
  802828:	89 d8                	mov    %ebx,%eax
  80282a:	89 14 24             	mov    %edx,(%esp)
  80282d:	89 f2                	mov    %esi,%edx
  80282f:	d3 e2                	shl    %cl,%edx
  802831:	89 f9                	mov    %edi,%ecx
  802833:	89 54 24 04          	mov    %edx,0x4(%esp)
  802837:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	89 e9                	mov    %ebp,%ecx
  80283f:	89 c6                	mov    %eax,%esi
  802841:	d3 e3                	shl    %cl,%ebx
  802843:	89 f9                	mov    %edi,%ecx
  802845:	89 d0                	mov    %edx,%eax
  802847:	d3 e8                	shr    %cl,%eax
  802849:	89 e9                	mov    %ebp,%ecx
  80284b:	09 d8                	or     %ebx,%eax
  80284d:	89 d3                	mov    %edx,%ebx
  80284f:	89 f2                	mov    %esi,%edx
  802851:	f7 34 24             	divl   (%esp)
  802854:	89 d6                	mov    %edx,%esi
  802856:	d3 e3                	shl    %cl,%ebx
  802858:	f7 64 24 04          	mull   0x4(%esp)
  80285c:	39 d6                	cmp    %edx,%esi
  80285e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802862:	89 d1                	mov    %edx,%ecx
  802864:	89 c3                	mov    %eax,%ebx
  802866:	72 08                	jb     802870 <__umoddi3+0x110>
  802868:	75 11                	jne    80287b <__umoddi3+0x11b>
  80286a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80286e:	73 0b                	jae    80287b <__umoddi3+0x11b>
  802870:	2b 44 24 04          	sub    0x4(%esp),%eax
  802874:	1b 14 24             	sbb    (%esp),%edx
  802877:	89 d1                	mov    %edx,%ecx
  802879:	89 c3                	mov    %eax,%ebx
  80287b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80287f:	29 da                	sub    %ebx,%edx
  802881:	19 ce                	sbb    %ecx,%esi
  802883:	89 f9                	mov    %edi,%ecx
  802885:	89 f0                	mov    %esi,%eax
  802887:	d3 e0                	shl    %cl,%eax
  802889:	89 e9                	mov    %ebp,%ecx
  80288b:	d3 ea                	shr    %cl,%edx
  80288d:	89 e9                	mov    %ebp,%ecx
  80288f:	d3 ee                	shr    %cl,%esi
  802891:	09 d0                	or     %edx,%eax
  802893:	89 f2                	mov    %esi,%edx
  802895:	83 c4 1c             	add    $0x1c,%esp
  802898:	5b                   	pop    %ebx
  802899:	5e                   	pop    %esi
  80289a:	5f                   	pop    %edi
  80289b:	5d                   	pop    %ebp
  80289c:	c3                   	ret    
  80289d:	8d 76 00             	lea    0x0(%esi),%esi
  8028a0:	29 f9                	sub    %edi,%ecx
  8028a2:	19 d6                	sbb    %edx,%esi
  8028a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028ac:	e9 18 ff ff ff       	jmp    8027c9 <__umoddi3+0x69>
