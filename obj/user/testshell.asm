
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 82 18 00 00       	call   8018d1 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 78 18 00 00       	call   8018d1 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 c0 2e 80 00 	movl   $0x802ec0,(%esp)
  800060:	e8 62 05 00 00       	call   8005c7 <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 2b 2f 80 00 	movl   $0x802f2b,(%esp)
  80006c:	e8 56 05 00 00       	call   8005c7 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 10 0e 00 00       	call   800e93 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 d9 16 00 00       	call   80176b <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 3a 2f 80 00       	push   $0x802f3a
  8000a1:	e8 21 05 00 00       	call   8005c7 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 db 0d 00 00       	call   800e93 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 a4 16 00 00       	call   80176b <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 35 2f 80 00       	push   $0x802f35
  8000d6:	e8 ec 04 00 00       	call   8005c7 <cprintf>
	exit();
  8000db:	e8 f4 03 00 00       	call   8004d4 <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 34 15 00 00       	call   80162f <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 28 15 00 00       	call   80162f <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 48 2f 80 00       	push   $0x802f48
  80011b:	e8 da 1a 00 00       	call   801bfa <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 55 2f 80 00       	push   $0x802f55
  80012f:	6a 13                	push   $0x13
  800131:	68 6b 2f 80 00       	push   $0x802f6b
  800136:	e8 b3 03 00 00       	call   8004ee <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 3e 27 00 00       	call   802885 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 7c 2f 80 00       	push   $0x802f7c
  800154:	6a 15                	push   $0x15
  800156:	68 6b 2f 80 00       	push   $0x802f6b
  80015b:	e8 8e 03 00 00       	call   8004ee <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 e4 2e 80 00       	push   $0x802ee4
  80016b:	e8 57 04 00 00       	call   8005c7 <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 05 11 00 00       	call   80127a <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 85 2f 80 00       	push   $0x802f85
  800182:	6a 1a                	push   $0x1a
  800184:	68 6b 2f 80 00       	push   $0x802f6b
  800189:	e8 60 03 00 00       	call   8004ee <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 e2 14 00 00       	call   80167f <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 d7 14 00 00       	call   80167f <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 7f 14 00 00       	call   80162f <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 77 14 00 00       	call   80162f <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 8e 2f 80 00       	push   $0x802f8e
  8001bf:	68 52 2f 80 00       	push   $0x802f52
  8001c4:	68 91 2f 80 00       	push   $0x802f91
  8001c9:	e8 07 20 00 00       	call   8021d5 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 95 2f 80 00       	push   $0x802f95
  8001dd:	6a 21                	push   $0x21
  8001df:	68 6b 2f 80 00       	push   $0x802f6b
  8001e4:	e8 05 03 00 00       	call   8004ee <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 3c 14 00 00       	call   80162f <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 30 14 00 00       	call   80162f <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 04 28 00 00       	call   802a0b <wait>
		exit();
  800207:	e8 c8 02 00 00       	call   8004d4 <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 17 14 00 00       	call   80162f <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 0f 14 00 00       	call   80162f <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 9f 2f 80 00       	push   $0x802f9f
  800230:	e8 c5 19 00 00       	call   801bfa <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 08 2f 80 00       	push   $0x802f08
  800245:	6a 2c                	push   $0x2c
  800247:	68 6b 2f 80 00       	push   $0x802f6b
  80024c:	e8 9d 02 00 00       	call   8004ee <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 ff 14 00 00       	call   80176b <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 ec 14 00 00       	call   80176b <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 ad 2f 80 00       	push   $0x802fad
  80028c:	6a 33                	push   $0x33
  80028e:	68 6b 2f 80 00       	push   $0x802f6b
  800293:	e8 56 02 00 00       	call   8004ee <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 c7 2f 80 00       	push   $0x802fc7
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 6b 2f 80 00       	push   $0x802f6b
  8002a9:	e8 40 02 00 00       	call   8004ee <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 e1 2f 80 00       	push   $0x802fe1
  8002f0:	e8 d2 02 00 00       	call   8005c7 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 f6 2f 80 00       	push   $0x802ff6
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 2e 08 00 00       	call   800b4c <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 82 09 00 00       	call   800cde <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 2d 0b 00 00       	call   800e93 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 9e 0b 00 00       	call   800f30 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 1a 0b 00 00       	call   800eb1 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 c5 0a 00 00       	call   800e93 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 85 13 00 00       	call   80176b <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 f5 10 00 00       	call   801505 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 7d 10 00 00       	call   8014b6 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 fb 0a 00 00       	call   800f4f <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 14 10 00 00       	call   80148f <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80048f:	c7 05 08 50 80 00 00 	movl   $0x0,0x805008
  800496:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800499:	e8 73 0a 00 00       	call   800f11 <sys_getenvid>
  80049e:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004a3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004ab:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004b0:	85 db                	test   %ebx,%ebx
  8004b2:	7e 07                	jle    8004bb <libmain+0x37>
		binaryname = argv[0];
  8004b4:	8b 06                	mov    (%esi),%eax
  8004b6:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	56                   	push   %esi
  8004bf:	53                   	push   %ebx
  8004c0:	e8 26 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004c5:	e8 0a 00 00 00       	call   8004d4 <exit>
}
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5d                   	pop    %ebp
  8004d3:	c3                   	ret    

008004d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004da:	e8 7b 11 00 00       	call   80165a <close_all>
	sys_env_destroy(0);
  8004df:	83 ec 0c             	sub    $0xc,%esp
  8004e2:	6a 00                	push   $0x0
  8004e4:	e8 e7 09 00 00       	call   800ed0 <sys_env_destroy>
}
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    

008004ee <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	56                   	push   %esi
  8004f2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004f3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004f6:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004fc:	e8 10 0a 00 00       	call   800f11 <sys_getenvid>
  800501:	83 ec 0c             	sub    $0xc,%esp
  800504:	ff 75 0c             	pushl  0xc(%ebp)
  800507:	ff 75 08             	pushl  0x8(%ebp)
  80050a:	56                   	push   %esi
  80050b:	50                   	push   %eax
  80050c:	68 0c 30 80 00       	push   $0x80300c
  800511:	e8 b1 00 00 00       	call   8005c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800516:	83 c4 18             	add    $0x18,%esp
  800519:	53                   	push   %ebx
  80051a:	ff 75 10             	pushl  0x10(%ebp)
  80051d:	e8 54 00 00 00       	call   800576 <vcprintf>
	cprintf("\n");
  800522:	c7 04 24 9a 33 80 00 	movl   $0x80339a,(%esp)
  800529:	e8 99 00 00 00       	call   8005c7 <cprintf>
  80052e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800531:	cc                   	int3   
  800532:	eb fd                	jmp    800531 <_panic+0x43>

00800534 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	53                   	push   %ebx
  800538:	83 ec 04             	sub    $0x4,%esp
  80053b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80053e:	8b 13                	mov    (%ebx),%edx
  800540:	8d 42 01             	lea    0x1(%edx),%eax
  800543:	89 03                	mov    %eax,(%ebx)
  800545:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800548:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80054c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800551:	75 1a                	jne    80056d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	68 ff 00 00 00       	push   $0xff
  80055b:	8d 43 08             	lea    0x8(%ebx),%eax
  80055e:	50                   	push   %eax
  80055f:	e8 2f 09 00 00       	call   800e93 <sys_cputs>
		b->idx = 0;
  800564:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80056a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80056d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800574:	c9                   	leave  
  800575:	c3                   	ret    

00800576 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
  800579:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80057f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800586:	00 00 00 
	b.cnt = 0;
  800589:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800590:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800593:	ff 75 0c             	pushl  0xc(%ebp)
  800596:	ff 75 08             	pushl  0x8(%ebp)
  800599:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059f:	50                   	push   %eax
  8005a0:	68 34 05 80 00       	push   $0x800534
  8005a5:	e8 54 01 00 00       	call   8006fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005aa:	83 c4 08             	add    $0x8,%esp
  8005ad:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005b3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b9:	50                   	push   %eax
  8005ba:	e8 d4 08 00 00       	call   800e93 <sys_cputs>

	return b.cnt;
}
  8005bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005c5:	c9                   	leave  
  8005c6:	c3                   	ret    

008005c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005d0:	50                   	push   %eax
  8005d1:	ff 75 08             	pushl  0x8(%ebp)
  8005d4:	e8 9d ff ff ff       	call   800576 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005d9:	c9                   	leave  
  8005da:	c3                   	ret    

008005db <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005db:	55                   	push   %ebp
  8005dc:	89 e5                	mov    %esp,%ebp
  8005de:	57                   	push   %edi
  8005df:	56                   	push   %esi
  8005e0:	53                   	push   %ebx
  8005e1:	83 ec 1c             	sub    $0x1c,%esp
  8005e4:	89 c7                	mov    %eax,%edi
  8005e6:	89 d6                	mov    %edx,%esi
  8005e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800602:	39 d3                	cmp    %edx,%ebx
  800604:	72 05                	jb     80060b <printnum+0x30>
  800606:	39 45 10             	cmp    %eax,0x10(%ebp)
  800609:	77 45                	ja     800650 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	ff 75 18             	pushl  0x18(%ebp)
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800617:	53                   	push   %ebx
  800618:	ff 75 10             	pushl  0x10(%ebp)
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800621:	ff 75 e0             	pushl  -0x20(%ebp)
  800624:	ff 75 dc             	pushl  -0x24(%ebp)
  800627:	ff 75 d8             	pushl  -0x28(%ebp)
  80062a:	e8 01 26 00 00       	call   802c30 <__udivdi3>
  80062f:	83 c4 18             	add    $0x18,%esp
  800632:	52                   	push   %edx
  800633:	50                   	push   %eax
  800634:	89 f2                	mov    %esi,%edx
  800636:	89 f8                	mov    %edi,%eax
  800638:	e8 9e ff ff ff       	call   8005db <printnum>
  80063d:	83 c4 20             	add    $0x20,%esp
  800640:	eb 18                	jmp    80065a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	56                   	push   %esi
  800646:	ff 75 18             	pushl  0x18(%ebp)
  800649:	ff d7                	call   *%edi
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	eb 03                	jmp    800653 <printnum+0x78>
  800650:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800653:	83 eb 01             	sub    $0x1,%ebx
  800656:	85 db                	test   %ebx,%ebx
  800658:	7f e8                	jg     800642 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	56                   	push   %esi
  80065e:	83 ec 04             	sub    $0x4,%esp
  800661:	ff 75 e4             	pushl  -0x1c(%ebp)
  800664:	ff 75 e0             	pushl  -0x20(%ebp)
  800667:	ff 75 dc             	pushl  -0x24(%ebp)
  80066a:	ff 75 d8             	pushl  -0x28(%ebp)
  80066d:	e8 ee 26 00 00       	call   802d60 <__umoddi3>
  800672:	83 c4 14             	add    $0x14,%esp
  800675:	0f be 80 2f 30 80 00 	movsbl 0x80302f(%eax),%eax
  80067c:	50                   	push   %eax
  80067d:	ff d7                	call   *%edi
}
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800685:	5b                   	pop    %ebx
  800686:	5e                   	pop    %esi
  800687:	5f                   	pop    %edi
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80068d:	83 fa 01             	cmp    $0x1,%edx
  800690:	7e 0e                	jle    8006a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800692:	8b 10                	mov    (%eax),%edx
  800694:	8d 4a 08             	lea    0x8(%edx),%ecx
  800697:	89 08                	mov    %ecx,(%eax)
  800699:	8b 02                	mov    (%edx),%eax
  80069b:	8b 52 04             	mov    0x4(%edx),%edx
  80069e:	eb 22                	jmp    8006c2 <getuint+0x38>
	else if (lflag)
  8006a0:	85 d2                	test   %edx,%edx
  8006a2:	74 10                	je     8006b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006a4:	8b 10                	mov    (%eax),%edx
  8006a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a9:	89 08                	mov    %ecx,(%eax)
  8006ab:	8b 02                	mov    (%edx),%eax
  8006ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b2:	eb 0e                	jmp    8006c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b9:	89 08                	mov    %ecx,(%eax)
  8006bb:	8b 02                	mov    (%edx),%eax
  8006bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006ca:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	3b 50 04             	cmp    0x4(%eax),%edx
  8006d3:	73 0a                	jae    8006df <sprintputch+0x1b>
		*b->buf++ = ch;
  8006d5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006d8:	89 08                	mov    %ecx,(%eax)
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	88 02                	mov    %al,(%edx)
}
  8006df:	5d                   	pop    %ebp
  8006e0:	c3                   	ret    

008006e1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006ea:	50                   	push   %eax
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	ff 75 0c             	pushl  0xc(%ebp)
  8006f1:	ff 75 08             	pushl  0x8(%ebp)
  8006f4:	e8 05 00 00 00       	call   8006fe <vprintfmt>
	va_end(ap);
}
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	57                   	push   %edi
  800702:	56                   	push   %esi
  800703:	53                   	push   %ebx
  800704:	83 ec 2c             	sub    $0x2c,%esp
  800707:	8b 75 08             	mov    0x8(%ebp),%esi
  80070a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800710:	eb 12                	jmp    800724 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800712:	85 c0                	test   %eax,%eax
  800714:	0f 84 89 03 00 00    	je     800aa3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	53                   	push   %ebx
  80071e:	50                   	push   %eax
  80071f:	ff d6                	call   *%esi
  800721:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800724:	83 c7 01             	add    $0x1,%edi
  800727:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80072b:	83 f8 25             	cmp    $0x25,%eax
  80072e:	75 e2                	jne    800712 <vprintfmt+0x14>
  800730:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800734:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80073b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800742:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
  80074e:	eb 07                	jmp    800757 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800750:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800753:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800757:	8d 47 01             	lea    0x1(%edi),%eax
  80075a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80075d:	0f b6 07             	movzbl (%edi),%eax
  800760:	0f b6 c8             	movzbl %al,%ecx
  800763:	83 e8 23             	sub    $0x23,%eax
  800766:	3c 55                	cmp    $0x55,%al
  800768:	0f 87 1a 03 00 00    	ja     800a88 <vprintfmt+0x38a>
  80076e:	0f b6 c0             	movzbl %al,%eax
  800771:	ff 24 85 80 31 80 00 	jmp    *0x803180(,%eax,4)
  800778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80077b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80077f:	eb d6                	jmp    800757 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80078c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80078f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800793:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800796:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800799:	83 fa 09             	cmp    $0x9,%edx
  80079c:	77 39                	ja     8007d7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007a1:	eb e9                	jmp    80078c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8007a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007b4:	eb 27                	jmp    8007dd <vprintfmt+0xdf>
  8007b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c0:	0f 49 c8             	cmovns %eax,%ecx
  8007c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c9:	eb 8c                	jmp    800757 <vprintfmt+0x59>
  8007cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007d5:	eb 80                	jmp    800757 <vprintfmt+0x59>
  8007d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007da:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007e1:	0f 89 70 ff ff ff    	jns    800757 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007f4:	e9 5e ff ff ff       	jmp    800757 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ff:	e9 53 ff ff ff       	jmp    800757 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8d 50 04             	lea    0x4(%eax),%edx
  80080a:	89 55 14             	mov    %edx,0x14(%ebp)
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	53                   	push   %ebx
  800811:	ff 30                	pushl  (%eax)
  800813:	ff d6                	call   *%esi
			break;
  800815:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80081b:	e9 04 ff ff ff       	jmp    800724 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8d 50 04             	lea    0x4(%eax),%edx
  800826:	89 55 14             	mov    %edx,0x14(%ebp)
  800829:	8b 00                	mov    (%eax),%eax
  80082b:	99                   	cltd   
  80082c:	31 d0                	xor    %edx,%eax
  80082e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800830:	83 f8 0f             	cmp    $0xf,%eax
  800833:	7f 0b                	jg     800840 <vprintfmt+0x142>
  800835:	8b 14 85 e0 32 80 00 	mov    0x8032e0(,%eax,4),%edx
  80083c:	85 d2                	test   %edx,%edx
  80083e:	75 18                	jne    800858 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800840:	50                   	push   %eax
  800841:	68 47 30 80 00       	push   $0x803047
  800846:	53                   	push   %ebx
  800847:	56                   	push   %esi
  800848:	e8 94 fe ff ff       	call   8006e1 <printfmt>
  80084d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800853:	e9 cc fe ff ff       	jmp    800724 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800858:	52                   	push   %edx
  800859:	68 6d 35 80 00       	push   $0x80356d
  80085e:	53                   	push   %ebx
  80085f:	56                   	push   %esi
  800860:	e8 7c fe ff ff       	call   8006e1 <printfmt>
  800865:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800868:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086b:	e9 b4 fe ff ff       	jmp    800724 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8d 50 04             	lea    0x4(%eax),%edx
  800876:	89 55 14             	mov    %edx,0x14(%ebp)
  800879:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80087b:	85 ff                	test   %edi,%edi
  80087d:	b8 40 30 80 00       	mov    $0x803040,%eax
  800882:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800885:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800889:	0f 8e 94 00 00 00    	jle    800923 <vprintfmt+0x225>
  80088f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800893:	0f 84 98 00 00 00    	je     800931 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800899:	83 ec 08             	sub    $0x8,%esp
  80089c:	ff 75 d0             	pushl  -0x30(%ebp)
  80089f:	57                   	push   %edi
  8008a0:	e8 86 02 00 00       	call   800b2b <strnlen>
  8008a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008a8:	29 c1                	sub    %eax,%ecx
  8008aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008ad:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008b0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008ba:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bc:	eb 0f                	jmp    8008cd <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c7:	83 ef 01             	sub    $0x1,%edi
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	85 ff                	test   %edi,%edi
  8008cf:	7f ed                	jg     8008be <vprintfmt+0x1c0>
  8008d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008d4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008d7:	85 c9                	test   %ecx,%ecx
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008de:	0f 49 c1             	cmovns %ecx,%eax
  8008e1:	29 c1                	sub    %eax,%ecx
  8008e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8008e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008ec:	89 cb                	mov    %ecx,%ebx
  8008ee:	eb 4d                	jmp    80093d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008f4:	74 1b                	je     800911 <vprintfmt+0x213>
  8008f6:	0f be c0             	movsbl %al,%eax
  8008f9:	83 e8 20             	sub    $0x20,%eax
  8008fc:	83 f8 5e             	cmp    $0x5e,%eax
  8008ff:	76 10                	jbe    800911 <vprintfmt+0x213>
					putch('?', putdat);
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	ff 75 0c             	pushl  0xc(%ebp)
  800907:	6a 3f                	push   $0x3f
  800909:	ff 55 08             	call   *0x8(%ebp)
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	eb 0d                	jmp    80091e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	52                   	push   %edx
  800918:	ff 55 08             	call   *0x8(%ebp)
  80091b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80091e:	83 eb 01             	sub    $0x1,%ebx
  800921:	eb 1a                	jmp    80093d <vprintfmt+0x23f>
  800923:	89 75 08             	mov    %esi,0x8(%ebp)
  800926:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800929:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80092c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80092f:	eb 0c                	jmp    80093d <vprintfmt+0x23f>
  800931:	89 75 08             	mov    %esi,0x8(%ebp)
  800934:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800937:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80093a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80093d:	83 c7 01             	add    $0x1,%edi
  800940:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800944:	0f be d0             	movsbl %al,%edx
  800947:	85 d2                	test   %edx,%edx
  800949:	74 23                	je     80096e <vprintfmt+0x270>
  80094b:	85 f6                	test   %esi,%esi
  80094d:	78 a1                	js     8008f0 <vprintfmt+0x1f2>
  80094f:	83 ee 01             	sub    $0x1,%esi
  800952:	79 9c                	jns    8008f0 <vprintfmt+0x1f2>
  800954:	89 df                	mov    %ebx,%edi
  800956:	8b 75 08             	mov    0x8(%ebp),%esi
  800959:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095c:	eb 18                	jmp    800976 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80095e:	83 ec 08             	sub    $0x8,%esp
  800961:	53                   	push   %ebx
  800962:	6a 20                	push   $0x20
  800964:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800966:	83 ef 01             	sub    $0x1,%edi
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	eb 08                	jmp    800976 <vprintfmt+0x278>
  80096e:	89 df                	mov    %ebx,%edi
  800970:	8b 75 08             	mov    0x8(%ebp),%esi
  800973:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800976:	85 ff                	test   %edi,%edi
  800978:	7f e4                	jg     80095e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80097d:	e9 a2 fd ff ff       	jmp    800724 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800982:	83 fa 01             	cmp    $0x1,%edx
  800985:	7e 16                	jle    80099d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800987:	8b 45 14             	mov    0x14(%ebp),%eax
  80098a:	8d 50 08             	lea    0x8(%eax),%edx
  80098d:	89 55 14             	mov    %edx,0x14(%ebp)
  800990:	8b 50 04             	mov    0x4(%eax),%edx
  800993:	8b 00                	mov    (%eax),%eax
  800995:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800998:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80099b:	eb 32                	jmp    8009cf <vprintfmt+0x2d1>
	else if (lflag)
  80099d:	85 d2                	test   %edx,%edx
  80099f:	74 18                	je     8009b9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8009a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a4:	8d 50 04             	lea    0x4(%eax),%edx
  8009a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009aa:	8b 00                	mov    (%eax),%eax
  8009ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009af:	89 c1                	mov    %eax,%ecx
  8009b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8009b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009b7:	eb 16                	jmp    8009cf <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bc:	8d 50 04             	lea    0x4(%eax),%edx
  8009bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c2:	8b 00                	mov    (%eax),%eax
  8009c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009c7:	89 c1                	mov    %eax,%ecx
  8009c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8009cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009de:	79 74                	jns    800a54 <vprintfmt+0x356>
				putch('-', putdat);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	53                   	push   %ebx
  8009e4:	6a 2d                	push   $0x2d
  8009e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009ee:	f7 d8                	neg    %eax
  8009f0:	83 d2 00             	adc    $0x0,%edx
  8009f3:	f7 da                	neg    %edx
  8009f5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009fd:	eb 55                	jmp    800a54 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800a02:	e8 83 fc ff ff       	call   80068a <getuint>
			base = 10;
  800a07:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a0c:	eb 46                	jmp    800a54 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a0e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a11:	e8 74 fc ff ff       	call   80068a <getuint>
		        base = 8;
  800a16:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800a1b:	eb 37                	jmp    800a54 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a1d:	83 ec 08             	sub    $0x8,%esp
  800a20:	53                   	push   %ebx
  800a21:	6a 30                	push   $0x30
  800a23:	ff d6                	call   *%esi
			putch('x', putdat);
  800a25:	83 c4 08             	add    $0x8,%esp
  800a28:	53                   	push   %ebx
  800a29:	6a 78                	push   $0x78
  800a2b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a30:	8d 50 04             	lea    0x4(%eax),%edx
  800a33:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a36:	8b 00                	mov    (%eax),%eax
  800a38:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a3d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a40:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a45:	eb 0d                	jmp    800a54 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a47:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4a:	e8 3b fc ff ff       	call   80068a <getuint>
			base = 16;
  800a4f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a54:	83 ec 0c             	sub    $0xc,%esp
  800a57:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a5b:	57                   	push   %edi
  800a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5f:	51                   	push   %ecx
  800a60:	52                   	push   %edx
  800a61:	50                   	push   %eax
  800a62:	89 da                	mov    %ebx,%edx
  800a64:	89 f0                	mov    %esi,%eax
  800a66:	e8 70 fb ff ff       	call   8005db <printnum>
			break;
  800a6b:	83 c4 20             	add    $0x20,%esp
  800a6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a71:	e9 ae fc ff ff       	jmp    800724 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a76:	83 ec 08             	sub    $0x8,%esp
  800a79:	53                   	push   %ebx
  800a7a:	51                   	push   %ecx
  800a7b:	ff d6                	call   *%esi
			break;
  800a7d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a83:	e9 9c fc ff ff       	jmp    800724 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a88:	83 ec 08             	sub    $0x8,%esp
  800a8b:	53                   	push   %ebx
  800a8c:	6a 25                	push   $0x25
  800a8e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a90:	83 c4 10             	add    $0x10,%esp
  800a93:	eb 03                	jmp    800a98 <vprintfmt+0x39a>
  800a95:	83 ef 01             	sub    $0x1,%edi
  800a98:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a9c:	75 f7                	jne    800a95 <vprintfmt+0x397>
  800a9e:	e9 81 fc ff ff       	jmp    800724 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	83 ec 18             	sub    $0x18,%esp
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ab7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800abe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ac1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	74 26                	je     800af2 <vsnprintf+0x47>
  800acc:	85 d2                	test   %edx,%edx
  800ace:	7e 22                	jle    800af2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ad0:	ff 75 14             	pushl  0x14(%ebp)
  800ad3:	ff 75 10             	pushl  0x10(%ebp)
  800ad6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad9:	50                   	push   %eax
  800ada:	68 c4 06 80 00       	push   $0x8006c4
  800adf:	e8 1a fc ff ff       	call   8006fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ae4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ae7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aed:	83 c4 10             	add    $0x10,%esp
  800af0:	eb 05                	jmp    800af7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800af2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b02:	50                   	push   %eax
  800b03:	ff 75 10             	pushl  0x10(%ebp)
  800b06:	ff 75 0c             	pushl  0xc(%ebp)
  800b09:	ff 75 08             	pushl  0x8(%ebp)
  800b0c:	e8 9a ff ff ff       	call   800aab <vsnprintf>
	va_end(ap);

	return rc;
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1e:	eb 03                	jmp    800b23 <strlen+0x10>
		n++;
  800b20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b27:	75 f7                	jne    800b20 <strlen+0xd>
		n++;
	return n;
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b31:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	eb 03                	jmp    800b3e <strnlen+0x13>
		n++;
  800b3b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b3e:	39 c2                	cmp    %eax,%edx
  800b40:	74 08                	je     800b4a <strnlen+0x1f>
  800b42:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b46:	75 f3                	jne    800b3b <strnlen+0x10>
  800b48:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	53                   	push   %ebx
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	83 c2 01             	add    $0x1,%edx
  800b5b:	83 c1 01             	add    $0x1,%ecx
  800b5e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b62:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b65:	84 db                	test   %bl,%bl
  800b67:	75 ef                	jne    800b58 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	53                   	push   %ebx
  800b70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b73:	53                   	push   %ebx
  800b74:	e8 9a ff ff ff       	call   800b13 <strlen>
  800b79:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b7c:	ff 75 0c             	pushl  0xc(%ebp)
  800b7f:	01 d8                	add    %ebx,%eax
  800b81:	50                   	push   %eax
  800b82:	e8 c5 ff ff ff       	call   800b4c <strcpy>
	return dst;
}
  800b87:	89 d8                	mov    %ebx,%eax
  800b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	8b 75 08             	mov    0x8(%ebp),%esi
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b9e:	89 f2                	mov    %esi,%edx
  800ba0:	eb 0f                	jmp    800bb1 <strncpy+0x23>
		*dst++ = *src;
  800ba2:	83 c2 01             	add    $0x1,%edx
  800ba5:	0f b6 01             	movzbl (%ecx),%eax
  800ba8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bab:	80 39 01             	cmpb   $0x1,(%ecx)
  800bae:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb1:	39 da                	cmp    %ebx,%edx
  800bb3:	75 ed                	jne    800ba2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bb5:	89 f0                	mov    %esi,%eax
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	8b 75 08             	mov    0x8(%ebp),%esi
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 10             	mov    0x10(%ebp),%edx
  800bc9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bcb:	85 d2                	test   %edx,%edx
  800bcd:	74 21                	je     800bf0 <strlcpy+0x35>
  800bcf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bd3:	89 f2                	mov    %esi,%edx
  800bd5:	eb 09                	jmp    800be0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bd7:	83 c2 01             	add    $0x1,%edx
  800bda:	83 c1 01             	add    $0x1,%ecx
  800bdd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800be0:	39 c2                	cmp    %eax,%edx
  800be2:	74 09                	je     800bed <strlcpy+0x32>
  800be4:	0f b6 19             	movzbl (%ecx),%ebx
  800be7:	84 db                	test   %bl,%bl
  800be9:	75 ec                	jne    800bd7 <strlcpy+0x1c>
  800beb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bf0:	29 f0                	sub    %esi,%eax
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bff:	eb 06                	jmp    800c07 <strcmp+0x11>
		p++, q++;
  800c01:	83 c1 01             	add    $0x1,%ecx
  800c04:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c07:	0f b6 01             	movzbl (%ecx),%eax
  800c0a:	84 c0                	test   %al,%al
  800c0c:	74 04                	je     800c12 <strcmp+0x1c>
  800c0e:	3a 02                	cmp    (%edx),%al
  800c10:	74 ef                	je     800c01 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c12:	0f b6 c0             	movzbl %al,%eax
  800c15:	0f b6 12             	movzbl (%edx),%edx
  800c18:	29 d0                	sub    %edx,%eax
}
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	53                   	push   %ebx
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
  800c23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c26:	89 c3                	mov    %eax,%ebx
  800c28:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c2b:	eb 06                	jmp    800c33 <strncmp+0x17>
		n--, p++, q++;
  800c2d:	83 c0 01             	add    $0x1,%eax
  800c30:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c33:	39 d8                	cmp    %ebx,%eax
  800c35:	74 15                	je     800c4c <strncmp+0x30>
  800c37:	0f b6 08             	movzbl (%eax),%ecx
  800c3a:	84 c9                	test   %cl,%cl
  800c3c:	74 04                	je     800c42 <strncmp+0x26>
  800c3e:	3a 0a                	cmp    (%edx),%cl
  800c40:	74 eb                	je     800c2d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c42:	0f b6 00             	movzbl (%eax),%eax
  800c45:	0f b6 12             	movzbl (%edx),%edx
  800c48:	29 d0                	sub    %edx,%eax
  800c4a:	eb 05                	jmp    800c51 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c4c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c5e:	eb 07                	jmp    800c67 <strchr+0x13>
		if (*s == c)
  800c60:	38 ca                	cmp    %cl,%dl
  800c62:	74 0f                	je     800c73 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c64:	83 c0 01             	add    $0x1,%eax
  800c67:	0f b6 10             	movzbl (%eax),%edx
  800c6a:	84 d2                	test   %dl,%dl
  800c6c:	75 f2                	jne    800c60 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c7f:	eb 03                	jmp    800c84 <strfind+0xf>
  800c81:	83 c0 01             	add    $0x1,%eax
  800c84:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c87:	38 ca                	cmp    %cl,%dl
  800c89:	74 04                	je     800c8f <strfind+0x1a>
  800c8b:	84 d2                	test   %dl,%dl
  800c8d:	75 f2                	jne    800c81 <strfind+0xc>
			break;
	return (char *) s;
}
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c9d:	85 c9                	test   %ecx,%ecx
  800c9f:	74 36                	je     800cd7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ca1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca7:	75 28                	jne    800cd1 <memset+0x40>
  800ca9:	f6 c1 03             	test   $0x3,%cl
  800cac:	75 23                	jne    800cd1 <memset+0x40>
		c &= 0xFF;
  800cae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cb2:	89 d3                	mov    %edx,%ebx
  800cb4:	c1 e3 08             	shl    $0x8,%ebx
  800cb7:	89 d6                	mov    %edx,%esi
  800cb9:	c1 e6 18             	shl    $0x18,%esi
  800cbc:	89 d0                	mov    %edx,%eax
  800cbe:	c1 e0 10             	shl    $0x10,%eax
  800cc1:	09 f0                	or     %esi,%eax
  800cc3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cc5:	89 d8                	mov    %ebx,%eax
  800cc7:	09 d0                	or     %edx,%eax
  800cc9:	c1 e9 02             	shr    $0x2,%ecx
  800ccc:	fc                   	cld    
  800ccd:	f3 ab                	rep stos %eax,%es:(%edi)
  800ccf:	eb 06                	jmp    800cd7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd4:	fc                   	cld    
  800cd5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cd7:	89 f8                	mov    %edi,%eax
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cec:	39 c6                	cmp    %eax,%esi
  800cee:	73 35                	jae    800d25 <memmove+0x47>
  800cf0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cf3:	39 d0                	cmp    %edx,%eax
  800cf5:	73 2e                	jae    800d25 <memmove+0x47>
		s += n;
		d += n;
  800cf7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cfa:	89 d6                	mov    %edx,%esi
  800cfc:	09 fe                	or     %edi,%esi
  800cfe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d04:	75 13                	jne    800d19 <memmove+0x3b>
  800d06:	f6 c1 03             	test   $0x3,%cl
  800d09:	75 0e                	jne    800d19 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d0b:	83 ef 04             	sub    $0x4,%edi
  800d0e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d11:	c1 e9 02             	shr    $0x2,%ecx
  800d14:	fd                   	std    
  800d15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d17:	eb 09                	jmp    800d22 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d19:	83 ef 01             	sub    $0x1,%edi
  800d1c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d1f:	fd                   	std    
  800d20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d22:	fc                   	cld    
  800d23:	eb 1d                	jmp    800d42 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d25:	89 f2                	mov    %esi,%edx
  800d27:	09 c2                	or     %eax,%edx
  800d29:	f6 c2 03             	test   $0x3,%dl
  800d2c:	75 0f                	jne    800d3d <memmove+0x5f>
  800d2e:	f6 c1 03             	test   $0x3,%cl
  800d31:	75 0a                	jne    800d3d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d33:	c1 e9 02             	shr    $0x2,%ecx
  800d36:	89 c7                	mov    %eax,%edi
  800d38:	fc                   	cld    
  800d39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d3b:	eb 05                	jmp    800d42 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d3d:	89 c7                	mov    %eax,%edi
  800d3f:	fc                   	cld    
  800d40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d49:	ff 75 10             	pushl  0x10(%ebp)
  800d4c:	ff 75 0c             	pushl  0xc(%ebp)
  800d4f:	ff 75 08             	pushl  0x8(%ebp)
  800d52:	e8 87 ff ff ff       	call   800cde <memmove>
}
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    

00800d59 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d64:	89 c6                	mov    %eax,%esi
  800d66:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d69:	eb 1a                	jmp    800d85 <memcmp+0x2c>
		if (*s1 != *s2)
  800d6b:	0f b6 08             	movzbl (%eax),%ecx
  800d6e:	0f b6 1a             	movzbl (%edx),%ebx
  800d71:	38 d9                	cmp    %bl,%cl
  800d73:	74 0a                	je     800d7f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d75:	0f b6 c1             	movzbl %cl,%eax
  800d78:	0f b6 db             	movzbl %bl,%ebx
  800d7b:	29 d8                	sub    %ebx,%eax
  800d7d:	eb 0f                	jmp    800d8e <memcmp+0x35>
		s1++, s2++;
  800d7f:	83 c0 01             	add    $0x1,%eax
  800d82:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d85:	39 f0                	cmp    %esi,%eax
  800d87:	75 e2                	jne    800d6b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	53                   	push   %ebx
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d99:	89 c1                	mov    %eax,%ecx
  800d9b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da2:	eb 0a                	jmp    800dae <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800da4:	0f b6 10             	movzbl (%eax),%edx
  800da7:	39 da                	cmp    %ebx,%edx
  800da9:	74 07                	je     800db2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dab:	83 c0 01             	add    $0x1,%eax
  800dae:	39 c8                	cmp    %ecx,%eax
  800db0:	72 f2                	jb     800da4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800db2:	5b                   	pop    %ebx
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dc1:	eb 03                	jmp    800dc6 <strtol+0x11>
		s++;
  800dc3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dc6:	0f b6 01             	movzbl (%ecx),%eax
  800dc9:	3c 20                	cmp    $0x20,%al
  800dcb:	74 f6                	je     800dc3 <strtol+0xe>
  800dcd:	3c 09                	cmp    $0x9,%al
  800dcf:	74 f2                	je     800dc3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dd1:	3c 2b                	cmp    $0x2b,%al
  800dd3:	75 0a                	jne    800ddf <strtol+0x2a>
		s++;
  800dd5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ddd:	eb 11                	jmp    800df0 <strtol+0x3b>
  800ddf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800de4:	3c 2d                	cmp    $0x2d,%al
  800de6:	75 08                	jne    800df0 <strtol+0x3b>
		s++, neg = 1;
  800de8:	83 c1 01             	add    $0x1,%ecx
  800deb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800df0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800df6:	75 15                	jne    800e0d <strtol+0x58>
  800df8:	80 39 30             	cmpb   $0x30,(%ecx)
  800dfb:	75 10                	jne    800e0d <strtol+0x58>
  800dfd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e01:	75 7c                	jne    800e7f <strtol+0xca>
		s += 2, base = 16;
  800e03:	83 c1 02             	add    $0x2,%ecx
  800e06:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e0b:	eb 16                	jmp    800e23 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e0d:	85 db                	test   %ebx,%ebx
  800e0f:	75 12                	jne    800e23 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e11:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e16:	80 39 30             	cmpb   $0x30,(%ecx)
  800e19:	75 08                	jne    800e23 <strtol+0x6e>
		s++, base = 8;
  800e1b:	83 c1 01             	add    $0x1,%ecx
  800e1e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
  800e28:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e2b:	0f b6 11             	movzbl (%ecx),%edx
  800e2e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e31:	89 f3                	mov    %esi,%ebx
  800e33:	80 fb 09             	cmp    $0x9,%bl
  800e36:	77 08                	ja     800e40 <strtol+0x8b>
			dig = *s - '0';
  800e38:	0f be d2             	movsbl %dl,%edx
  800e3b:	83 ea 30             	sub    $0x30,%edx
  800e3e:	eb 22                	jmp    800e62 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e40:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e43:	89 f3                	mov    %esi,%ebx
  800e45:	80 fb 19             	cmp    $0x19,%bl
  800e48:	77 08                	ja     800e52 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e4a:	0f be d2             	movsbl %dl,%edx
  800e4d:	83 ea 57             	sub    $0x57,%edx
  800e50:	eb 10                	jmp    800e62 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e52:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e55:	89 f3                	mov    %esi,%ebx
  800e57:	80 fb 19             	cmp    $0x19,%bl
  800e5a:	77 16                	ja     800e72 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e5c:	0f be d2             	movsbl %dl,%edx
  800e5f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e62:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e65:	7d 0b                	jge    800e72 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e67:	83 c1 01             	add    $0x1,%ecx
  800e6a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e6e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e70:	eb b9                	jmp    800e2b <strtol+0x76>

	if (endptr)
  800e72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e76:	74 0d                	je     800e85 <strtol+0xd0>
		*endptr = (char *) s;
  800e78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e7b:	89 0e                	mov    %ecx,(%esi)
  800e7d:	eb 06                	jmp    800e85 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7f:	85 db                	test   %ebx,%ebx
  800e81:	74 98                	je     800e1b <strtol+0x66>
  800e83:	eb 9e                	jmp    800e23 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	f7 da                	neg    %edx
  800e89:	85 ff                	test   %edi,%edi
  800e8b:	0f 45 c2             	cmovne %edx,%eax
}
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	89 c3                	mov    %eax,%ebx
  800ea6:	89 c7                	mov    %eax,%edi
  800ea8:	89 c6                	mov    %eax,%esi
  800eaa:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec1:	89 d1                	mov    %edx,%ecx
  800ec3:	89 d3                	mov    %edx,%ebx
  800ec5:	89 d7                	mov    %edx,%edi
  800ec7:	89 d6                	mov    %edx,%esi
  800ec9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ede:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 cb                	mov    %ecx,%ebx
  800ee8:	89 cf                	mov    %ecx,%edi
  800eea:	89 ce                	mov    %ecx,%esi
  800eec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	7e 17                	jle    800f09 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef2:	83 ec 0c             	sub    $0xc,%esp
  800ef5:	50                   	push   %eax
  800ef6:	6a 03                	push   $0x3
  800ef8:	68 3f 33 80 00       	push   $0x80333f
  800efd:	6a 23                	push   $0x23
  800eff:	68 5c 33 80 00       	push   $0x80335c
  800f04:	e8 e5 f5 ff ff       	call   8004ee <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	57                   	push   %edi
  800f15:	56                   	push   %esi
  800f16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f17:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1c:	b8 02 00 00 00       	mov    $0x2,%eax
  800f21:	89 d1                	mov    %edx,%ecx
  800f23:	89 d3                	mov    %edx,%ebx
  800f25:	89 d7                	mov    %edx,%edi
  800f27:	89 d6                	mov    %edx,%esi
  800f29:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_yield>:

void
sys_yield(void)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f36:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f40:	89 d1                	mov    %edx,%ecx
  800f42:	89 d3                	mov    %edx,%ebx
  800f44:	89 d7                	mov    %edx,%edi
  800f46:	89 d6                	mov    %edx,%esi
  800f48:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f58:	be 00 00 00 00       	mov    $0x0,%esi
  800f5d:	b8 04 00 00 00       	mov    $0x4,%eax
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6b:	89 f7                	mov    %esi,%edi
  800f6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	7e 17                	jle    800f8a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f73:	83 ec 0c             	sub    $0xc,%esp
  800f76:	50                   	push   %eax
  800f77:	6a 04                	push   $0x4
  800f79:	68 3f 33 80 00       	push   $0x80333f
  800f7e:	6a 23                	push   $0x23
  800f80:	68 5c 33 80 00       	push   $0x80335c
  800f85:	e8 64 f5 ff ff       	call   8004ee <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9b:	b8 05 00 00 00       	mov    $0x5,%eax
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fac:	8b 75 18             	mov    0x18(%ebp),%esi
  800faf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	7e 17                	jle    800fcc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	50                   	push   %eax
  800fb9:	6a 05                	push   $0x5
  800fbb:	68 3f 33 80 00       	push   $0x80333f
  800fc0:	6a 23                	push   $0x23
  800fc2:	68 5c 33 80 00       	push   $0x80335c
  800fc7:	e8 22 f5 ff ff       	call   8004ee <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe2:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fea:	8b 55 08             	mov    0x8(%ebp),%edx
  800fed:	89 df                	mov    %ebx,%edi
  800fef:	89 de                	mov    %ebx,%esi
  800ff1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	7e 17                	jle    80100e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	50                   	push   %eax
  800ffb:	6a 06                	push   $0x6
  800ffd:	68 3f 33 80 00       	push   $0x80333f
  801002:	6a 23                	push   $0x23
  801004:	68 5c 33 80 00       	push   $0x80335c
  801009:	e8 e0 f4 ff ff       	call   8004ee <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80100e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
  80101c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801024:	b8 08 00 00 00       	mov    $0x8,%eax
  801029:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102c:	8b 55 08             	mov    0x8(%ebp),%edx
  80102f:	89 df                	mov    %ebx,%edi
  801031:	89 de                	mov    %ebx,%esi
  801033:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801035:	85 c0                	test   %eax,%eax
  801037:	7e 17                	jle    801050 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	50                   	push   %eax
  80103d:	6a 08                	push   $0x8
  80103f:	68 3f 33 80 00       	push   $0x80333f
  801044:	6a 23                	push   $0x23
  801046:	68 5c 33 80 00       	push   $0x80335c
  80104b:	e8 9e f4 ff ff       	call   8004ee <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
  801066:	b8 09 00 00 00       	mov    $0x9,%eax
  80106b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	89 df                	mov    %ebx,%edi
  801073:	89 de                	mov    %ebx,%esi
  801075:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	7e 17                	jle    801092 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	50                   	push   %eax
  80107f:	6a 09                	push   $0x9
  801081:	68 3f 33 80 00       	push   $0x80333f
  801086:	6a 23                	push   $0x23
  801088:	68 5c 33 80 00       	push   $0x80335c
  80108d:	e8 5c f4 ff ff       	call   8004ee <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801092:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801095:	5b                   	pop    %ebx
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b3:	89 df                	mov    %ebx,%edi
  8010b5:	89 de                	mov    %ebx,%esi
  8010b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	7e 17                	jle    8010d4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	50                   	push   %eax
  8010c1:	6a 0a                	push   $0xa
  8010c3:	68 3f 33 80 00       	push   $0x80333f
  8010c8:	6a 23                	push   $0x23
  8010ca:	68 5c 33 80 00       	push   $0x80335c
  8010cf:	e8 1a f4 ff ff       	call   8004ee <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e2:	be 00 00 00 00       	mov    $0x0,%esi
  8010e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801108:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801112:	8b 55 08             	mov    0x8(%ebp),%edx
  801115:	89 cb                	mov    %ecx,%ebx
  801117:	89 cf                	mov    %ecx,%edi
  801119:	89 ce                	mov    %ecx,%esi
  80111b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111d:	85 c0                	test   %eax,%eax
  80111f:	7e 17                	jle    801138 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	50                   	push   %eax
  801125:	6a 0d                	push   $0xd
  801127:	68 3f 33 80 00       	push   $0x80333f
  80112c:	6a 23                	push   $0x23
  80112e:	68 5c 33 80 00       	push   $0x80335c
  801133:	e8 b6 f3 ff ff       	call   8004ee <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801146:	ba 00 00 00 00       	mov    $0x0,%edx
  80114b:	b8 0e 00 00 00       	mov    $0xe,%eax
  801150:	89 d1                	mov    %edx,%ecx
  801152:	89 d3                	mov    %edx,%ebx
  801154:	89 d7                	mov    %edx,%edi
  801156:	89 d6                	mov    %edx,%esi
  801158:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	57                   	push   %edi
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801165:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80116f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801172:	8b 55 08             	mov    0x8(%ebp),%edx
  801175:	89 df                	mov    %ebx,%edi
  801177:	89 de                	mov    %ebx,%esi
  801179:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80118a:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  80118c:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801190:	74 2e                	je     8011c0 <pgfault+0x40>
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 16             	shr    $0x16,%edx
  801197:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 1d                	je     8011c0 <pgfault+0x40>
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	c1 ea 0c             	shr    $0xc,%edx
  8011a8:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8011af:	f6 c1 01             	test   $0x1,%cl
  8011b2:	74 0c                	je     8011c0 <pgfault+0x40>
  8011b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bb:	f6 c6 08             	test   $0x8,%dh
  8011be:	75 14                	jne    8011d4 <pgfault+0x54>
        panic("Not copy-on-write\n");
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	68 6a 33 80 00       	push   $0x80336a
  8011c8:	6a 1d                	push   $0x1d
  8011ca:	68 7d 33 80 00       	push   $0x80337d
  8011cf:	e8 1a f3 ff ff       	call   8004ee <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8011d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d9:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	6a 07                	push   $0x7
  8011e0:	68 00 f0 7f 00       	push   $0x7ff000
  8011e5:	6a 00                	push   $0x0
  8011e7:	e8 63 fd ff ff       	call   800f4f <sys_page_alloc>
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	79 14                	jns    801207 <pgfault+0x87>
		panic("page alloc failed \n");
  8011f3:	83 ec 04             	sub    $0x4,%esp
  8011f6:	68 88 33 80 00       	push   $0x803388
  8011fb:	6a 28                	push   $0x28
  8011fd:	68 7d 33 80 00       	push   $0x80337d
  801202:	e8 e7 f2 ff ff       	call   8004ee <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  801207:	83 ec 04             	sub    $0x4,%esp
  80120a:	68 00 10 00 00       	push   $0x1000
  80120f:	53                   	push   %ebx
  801210:	68 00 f0 7f 00       	push   $0x7ff000
  801215:	e8 2c fb ff ff       	call   800d46 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  80121a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801221:	53                   	push   %ebx
  801222:	6a 00                	push   $0x0
  801224:	68 00 f0 7f 00       	push   $0x7ff000
  801229:	6a 00                	push   $0x0
  80122b:	e8 62 fd ff ff       	call   800f92 <sys_page_map>
  801230:	83 c4 20             	add    $0x20,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	79 14                	jns    80124b <pgfault+0xcb>
        panic("page map failed \n");
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	68 9c 33 80 00       	push   $0x80339c
  80123f:	6a 2b                	push   $0x2b
  801241:	68 7d 33 80 00       	push   $0x80337d
  801246:	e8 a3 f2 ff ff       	call   8004ee <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	68 00 f0 7f 00       	push   $0x7ff000
  801253:	6a 00                	push   $0x0
  801255:	e8 7a fd ff ff       	call   800fd4 <sys_page_unmap>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	79 14                	jns    801275 <pgfault+0xf5>
        panic("page unmap failed\n");
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	68 ae 33 80 00       	push   $0x8033ae
  801269:	6a 2d                	push   $0x2d
  80126b:	68 7d 33 80 00       	push   $0x80337d
  801270:	e8 79 f2 ff ff       	call   8004ee <_panic>
	
	//panic("pgfault not implemented");
}
  801275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	57                   	push   %edi
  80127e:	56                   	push   %esi
  80127f:	53                   	push   %ebx
  801280:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  801283:	68 80 11 80 00       	push   $0x801180
  801288:	e8 cd 17 00 00       	call   802a5a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80128d:	b8 07 00 00 00       	mov    $0x7,%eax
  801292:	cd 30                	int    $0x30
  801294:	89 c7                	mov    %eax,%edi
  801296:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	79 12                	jns    8012b2 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  8012a0:	50                   	push   %eax
  8012a1:	68 c1 33 80 00       	push   $0x8033c1
  8012a6:	6a 7a                	push   $0x7a
  8012a8:	68 7d 33 80 00       	push   $0x80337d
  8012ad:	e8 3c f2 ff ff       	call   8004ee <_panic>
  8012b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	75 21                	jne    8012dc <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012bb:	e8 51 fc ff ff       	call   800f11 <sys_getenvid>
  8012c0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012c5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012cd:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d7:	e9 91 01 00 00       	jmp    80146d <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  8012dc:	89 d8                	mov    %ebx,%eax
  8012de:	c1 e8 16             	shr    $0x16,%eax
  8012e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e8:	a8 01                	test   $0x1,%al
  8012ea:	0f 84 06 01 00 00    	je     8013f6 <fork+0x17c>
  8012f0:	89 d8                	mov    %ebx,%eax
  8012f2:	c1 e8 0c             	shr    $0xc,%eax
  8012f5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012fc:	f6 c2 01             	test   $0x1,%dl
  8012ff:	0f 84 f1 00 00 00    	je     8013f6 <fork+0x17c>
  801305:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130c:	f6 c2 04             	test   $0x4,%dl
  80130f:	0f 84 e1 00 00 00    	je     8013f6 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  801315:	89 c6                	mov    %eax,%esi
  801317:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  80131a:	89 f2                	mov    %esi,%edx
  80131c:	c1 ea 16             	shr    $0x16,%edx
  80131f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  801326:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  80132d:	f6 c6 04             	test   $0x4,%dh
  801330:	74 39                	je     80136b <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  801332:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	25 07 0e 00 00       	and    $0xe07,%eax
  801341:	50                   	push   %eax
  801342:	56                   	push   %esi
  801343:	ff 75 e4             	pushl  -0x1c(%ebp)
  801346:	56                   	push   %esi
  801347:	6a 00                	push   $0x0
  801349:	e8 44 fc ff ff       	call   800f92 <sys_page_map>
  80134e:	83 c4 20             	add    $0x20,%esp
  801351:	85 c0                	test   %eax,%eax
  801353:	0f 89 9d 00 00 00    	jns    8013f6 <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  801359:	50                   	push   %eax
  80135a:	68 18 34 80 00       	push   $0x803418
  80135f:	6a 4b                	push   $0x4b
  801361:	68 7d 33 80 00       	push   $0x80337d
  801366:	e8 83 f1 ff ff       	call   8004ee <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  80136b:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801371:	74 59                	je     8013cc <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	68 05 08 00 00       	push   $0x805
  80137b:	56                   	push   %esi
  80137c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137f:	56                   	push   %esi
  801380:	6a 00                	push   $0x0
  801382:	e8 0b fc ff ff       	call   800f92 <sys_page_map>
  801387:	83 c4 20             	add    $0x20,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	79 12                	jns    8013a0 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  80138e:	50                   	push   %eax
  80138f:	68 48 34 80 00       	push   $0x803448
  801394:	6a 50                	push   $0x50
  801396:	68 7d 33 80 00       	push   $0x80337d
  80139b:	e8 4e f1 ff ff       	call   8004ee <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8013a0:	83 ec 0c             	sub    $0xc,%esp
  8013a3:	68 05 08 00 00       	push   $0x805
  8013a8:	56                   	push   %esi
  8013a9:	6a 00                	push   $0x0
  8013ab:	56                   	push   %esi
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 df fb ff ff       	call   800f92 <sys_page_map>
  8013b3:	83 c4 20             	add    $0x20,%esp
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	79 3c                	jns    8013f6 <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  8013ba:	50                   	push   %eax
  8013bb:	68 70 34 80 00       	push   $0x803470
  8013c0:	6a 53                	push   $0x53
  8013c2:	68 7d 33 80 00       	push   $0x80337d
  8013c7:	e8 22 f1 ff ff       	call   8004ee <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  8013cc:	83 ec 0c             	sub    $0xc,%esp
  8013cf:	6a 05                	push   $0x5
  8013d1:	56                   	push   %esi
  8013d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013d5:	56                   	push   %esi
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 b5 fb ff ff       	call   800f92 <sys_page_map>
  8013dd:	83 c4 20             	add    $0x20,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	79 12                	jns    8013f6 <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  8013e4:	50                   	push   %eax
  8013e5:	68 98 34 80 00       	push   $0x803498
  8013ea:	6a 58                	push   $0x58
  8013ec:	68 7d 33 80 00       	push   $0x80337d
  8013f1:	e8 f8 f0 ff ff       	call   8004ee <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  8013f6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013fc:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801402:	0f 85 d4 fe ff ff    	jne    8012dc <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  801408:	83 ec 04             	sub    $0x4,%esp
  80140b:	6a 07                	push   $0x7
  80140d:	68 00 f0 bf ee       	push   $0xeebff000
  801412:	57                   	push   %edi
  801413:	e8 37 fb ff ff       	call   800f4f <sys_page_alloc>
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	85 c0                	test   %eax,%eax
  80141d:	79 17                	jns    801436 <fork+0x1bc>
        panic("page alloc failed\n");
  80141f:	83 ec 04             	sub    $0x4,%esp
  801422:	68 d3 33 80 00       	push   $0x8033d3
  801427:	68 87 00 00 00       	push   $0x87
  80142c:	68 7d 33 80 00       	push   $0x80337d
  801431:	e8 b8 f0 ff ff       	call   8004ee <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	68 c9 2a 80 00       	push   $0x802ac9
  80143e:	57                   	push   %edi
  80143f:	e8 56 fc ff ff       	call   80109a <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801444:	83 c4 08             	add    $0x8,%esp
  801447:	6a 02                	push   $0x2
  801449:	57                   	push   %edi
  80144a:	e8 c7 fb ff ff       	call   801016 <sys_env_set_status>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	79 15                	jns    80146b <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  801456:	50                   	push   %eax
  801457:	68 e6 33 80 00       	push   $0x8033e6
  80145c:	68 8c 00 00 00       	push   $0x8c
  801461:	68 7d 33 80 00       	push   $0x80337d
  801466:	e8 83 f0 ff ff       	call   8004ee <_panic>

	return envid;
  80146b:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  80146d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801470:	5b                   	pop    %ebx
  801471:	5e                   	pop    %esi
  801472:	5f                   	pop    %edi
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <sfork>:

// Challenge!
int
sfork(void)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80147b:	68 ff 33 80 00       	push   $0x8033ff
  801480:	68 98 00 00 00       	push   $0x98
  801485:	68 7d 33 80 00       	push   $0x80337d
  80148a:	e8 5f f0 ff ff       	call   8004ee <_panic>

0080148f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	05 00 00 00 30       	add    $0x30000000,%eax
  80149a:	c1 e8 0c             	shr    $0xc,%eax
}
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8014aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014af:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014bc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	c1 ea 16             	shr    $0x16,%edx
  8014c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014cd:	f6 c2 01             	test   $0x1,%dl
  8014d0:	74 11                	je     8014e3 <fd_alloc+0x2d>
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	c1 ea 0c             	shr    $0xc,%edx
  8014d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014de:	f6 c2 01             	test   $0x1,%dl
  8014e1:	75 09                	jne    8014ec <fd_alloc+0x36>
			*fd_store = fd;
  8014e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ea:	eb 17                	jmp    801503 <fd_alloc+0x4d>
  8014ec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014f6:	75 c9                	jne    8014c1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80150b:	83 f8 1f             	cmp    $0x1f,%eax
  80150e:	77 36                	ja     801546 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801510:	c1 e0 0c             	shl    $0xc,%eax
  801513:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801518:	89 c2                	mov    %eax,%edx
  80151a:	c1 ea 16             	shr    $0x16,%edx
  80151d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801524:	f6 c2 01             	test   $0x1,%dl
  801527:	74 24                	je     80154d <fd_lookup+0x48>
  801529:	89 c2                	mov    %eax,%edx
  80152b:	c1 ea 0c             	shr    $0xc,%edx
  80152e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801535:	f6 c2 01             	test   $0x1,%dl
  801538:	74 1a                	je     801554 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80153a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153d:	89 02                	mov    %eax,(%edx)
	return 0;
  80153f:	b8 00 00 00 00       	mov    $0x0,%eax
  801544:	eb 13                	jmp    801559 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801546:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154b:	eb 0c                	jmp    801559 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80154d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801552:	eb 05                	jmp    801559 <fd_lookup+0x54>
  801554:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801564:	ba 40 35 80 00       	mov    $0x803540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801569:	eb 13                	jmp    80157e <dev_lookup+0x23>
  80156b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80156e:	39 08                	cmp    %ecx,(%eax)
  801570:	75 0c                	jne    80157e <dev_lookup+0x23>
			*dev = devtab[i];
  801572:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801575:	89 01                	mov    %eax,(%ecx)
			return 0;
  801577:	b8 00 00 00 00       	mov    $0x0,%eax
  80157c:	eb 2e                	jmp    8015ac <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80157e:	8b 02                	mov    (%edx),%eax
  801580:	85 c0                	test   %eax,%eax
  801582:	75 e7                	jne    80156b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801584:	a1 08 50 80 00       	mov    0x805008,%eax
  801589:	8b 40 48             	mov    0x48(%eax),%eax
  80158c:	83 ec 04             	sub    $0x4,%esp
  80158f:	51                   	push   %ecx
  801590:	50                   	push   %eax
  801591:	68 c4 34 80 00       	push   $0x8034c4
  801596:	e8 2c f0 ff ff       	call   8005c7 <cprintf>
	*dev = 0;
  80159b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	56                   	push   %esi
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 10             	sub    $0x10,%esp
  8015b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015c6:	c1 e8 0c             	shr    $0xc,%eax
  8015c9:	50                   	push   %eax
  8015ca:	e8 36 ff ff ff       	call   801505 <fd_lookup>
  8015cf:	83 c4 08             	add    $0x8,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 05                	js     8015db <fd_close+0x2d>
	    || fd != fd2)
  8015d6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015d9:	74 0c                	je     8015e7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015db:	84 db                	test   %bl,%bl
  8015dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e2:	0f 44 c2             	cmove  %edx,%eax
  8015e5:	eb 41                	jmp    801628 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	ff 36                	pushl  (%esi)
  8015f0:	e8 66 ff ff ff       	call   80155b <dev_lookup>
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 1a                	js     801618 <fd_close+0x6a>
		if (dev->dev_close)
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801604:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801609:	85 c0                	test   %eax,%eax
  80160b:	74 0b                	je     801618 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80160d:	83 ec 0c             	sub    $0xc,%esp
  801610:	56                   	push   %esi
  801611:	ff d0                	call   *%eax
  801613:	89 c3                	mov    %eax,%ebx
  801615:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	56                   	push   %esi
  80161c:	6a 00                	push   $0x0
  80161e:	e8 b1 f9 ff ff       	call   800fd4 <sys_page_unmap>
	return r;
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	89 d8                	mov    %ebx,%eax
}
  801628:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801635:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	ff 75 08             	pushl  0x8(%ebp)
  80163c:	e8 c4 fe ff ff       	call   801505 <fd_lookup>
  801641:	83 c4 08             	add    $0x8,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	78 10                	js     801658 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	6a 01                	push   $0x1
  80164d:	ff 75 f4             	pushl  -0xc(%ebp)
  801650:	e8 59 ff ff ff       	call   8015ae <fd_close>
  801655:	83 c4 10             	add    $0x10,%esp
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <close_all>:

void
close_all(void)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801661:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	53                   	push   %ebx
  80166a:	e8 c0 ff ff ff       	call   80162f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80166f:	83 c3 01             	add    $0x1,%ebx
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	83 fb 20             	cmp    $0x20,%ebx
  801678:	75 ec                	jne    801666 <close_all+0xc>
		close(i);
}
  80167a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	57                   	push   %edi
  801683:	56                   	push   %esi
  801684:	53                   	push   %ebx
  801685:	83 ec 2c             	sub    $0x2c,%esp
  801688:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80168b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80168e:	50                   	push   %eax
  80168f:	ff 75 08             	pushl  0x8(%ebp)
  801692:	e8 6e fe ff ff       	call   801505 <fd_lookup>
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	85 c0                	test   %eax,%eax
  80169c:	0f 88 c1 00 00 00    	js     801763 <dup+0xe4>
		return r;
	close(newfdnum);
  8016a2:	83 ec 0c             	sub    $0xc,%esp
  8016a5:	56                   	push   %esi
  8016a6:	e8 84 ff ff ff       	call   80162f <close>

	newfd = INDEX2FD(newfdnum);
  8016ab:	89 f3                	mov    %esi,%ebx
  8016ad:	c1 e3 0c             	shl    $0xc,%ebx
  8016b0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016b6:	83 c4 04             	add    $0x4,%esp
  8016b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016bc:	e8 de fd ff ff       	call   80149f <fd2data>
  8016c1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016c3:	89 1c 24             	mov    %ebx,(%esp)
  8016c6:	e8 d4 fd ff ff       	call   80149f <fd2data>
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016d1:	89 f8                	mov    %edi,%eax
  8016d3:	c1 e8 16             	shr    $0x16,%eax
  8016d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016dd:	a8 01                	test   $0x1,%al
  8016df:	74 37                	je     801718 <dup+0x99>
  8016e1:	89 f8                	mov    %edi,%eax
  8016e3:	c1 e8 0c             	shr    $0xc,%eax
  8016e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ed:	f6 c2 01             	test   $0x1,%dl
  8016f0:	74 26                	je     801718 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f9:	83 ec 0c             	sub    $0xc,%esp
  8016fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801701:	50                   	push   %eax
  801702:	ff 75 d4             	pushl  -0x2c(%ebp)
  801705:	6a 00                	push   $0x0
  801707:	57                   	push   %edi
  801708:	6a 00                	push   $0x0
  80170a:	e8 83 f8 ff ff       	call   800f92 <sys_page_map>
  80170f:	89 c7                	mov    %eax,%edi
  801711:	83 c4 20             	add    $0x20,%esp
  801714:	85 c0                	test   %eax,%eax
  801716:	78 2e                	js     801746 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801718:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80171b:	89 d0                	mov    %edx,%eax
  80171d:	c1 e8 0c             	shr    $0xc,%eax
  801720:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	25 07 0e 00 00       	and    $0xe07,%eax
  80172f:	50                   	push   %eax
  801730:	53                   	push   %ebx
  801731:	6a 00                	push   $0x0
  801733:	52                   	push   %edx
  801734:	6a 00                	push   $0x0
  801736:	e8 57 f8 ff ff       	call   800f92 <sys_page_map>
  80173b:	89 c7                	mov    %eax,%edi
  80173d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801740:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801742:	85 ff                	test   %edi,%edi
  801744:	79 1d                	jns    801763 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	53                   	push   %ebx
  80174a:	6a 00                	push   $0x0
  80174c:	e8 83 f8 ff ff       	call   800fd4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801751:	83 c4 08             	add    $0x8,%esp
  801754:	ff 75 d4             	pushl  -0x2c(%ebp)
  801757:	6a 00                	push   $0x0
  801759:	e8 76 f8 ff ff       	call   800fd4 <sys_page_unmap>
	return r;
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	89 f8                	mov    %edi,%eax
}
  801763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5f                   	pop    %edi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	53                   	push   %ebx
  80176f:	83 ec 14             	sub    $0x14,%esp
  801772:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801775:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801778:	50                   	push   %eax
  801779:	53                   	push   %ebx
  80177a:	e8 86 fd ff ff       	call   801505 <fd_lookup>
  80177f:	83 c4 08             	add    $0x8,%esp
  801782:	89 c2                	mov    %eax,%edx
  801784:	85 c0                	test   %eax,%eax
  801786:	78 6d                	js     8017f5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801792:	ff 30                	pushl  (%eax)
  801794:	e8 c2 fd ff ff       	call   80155b <dev_lookup>
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 4c                	js     8017ec <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a3:	8b 42 08             	mov    0x8(%edx),%eax
  8017a6:	83 e0 03             	and    $0x3,%eax
  8017a9:	83 f8 01             	cmp    $0x1,%eax
  8017ac:	75 21                	jne    8017cf <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ae:	a1 08 50 80 00       	mov    0x805008,%eax
  8017b3:	8b 40 48             	mov    0x48(%eax),%eax
  8017b6:	83 ec 04             	sub    $0x4,%esp
  8017b9:	53                   	push   %ebx
  8017ba:	50                   	push   %eax
  8017bb:	68 05 35 80 00       	push   $0x803505
  8017c0:	e8 02 ee ff ff       	call   8005c7 <cprintf>
		return -E_INVAL;
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017cd:	eb 26                	jmp    8017f5 <read+0x8a>
	}
	if (!dev->dev_read)
  8017cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d2:	8b 40 08             	mov    0x8(%eax),%eax
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	74 17                	je     8017f0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	ff 75 10             	pushl  0x10(%ebp)
  8017df:	ff 75 0c             	pushl  0xc(%ebp)
  8017e2:	52                   	push   %edx
  8017e3:	ff d0                	call   *%eax
  8017e5:	89 c2                	mov    %eax,%edx
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	eb 09                	jmp    8017f5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ec:	89 c2                	mov    %eax,%edx
  8017ee:	eb 05                	jmp    8017f5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017f5:	89 d0                	mov    %edx,%eax
  8017f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	57                   	push   %edi
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	8b 7d 08             	mov    0x8(%ebp),%edi
  801808:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80180b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801810:	eb 21                	jmp    801833 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801812:	83 ec 04             	sub    $0x4,%esp
  801815:	89 f0                	mov    %esi,%eax
  801817:	29 d8                	sub    %ebx,%eax
  801819:	50                   	push   %eax
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	03 45 0c             	add    0xc(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	57                   	push   %edi
  801821:	e8 45 ff ff ff       	call   80176b <read>
		if (m < 0)
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 10                	js     80183d <readn+0x41>
			return m;
		if (m == 0)
  80182d:	85 c0                	test   %eax,%eax
  80182f:	74 0a                	je     80183b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801831:	01 c3                	add    %eax,%ebx
  801833:	39 f3                	cmp    %esi,%ebx
  801835:	72 db                	jb     801812 <readn+0x16>
  801837:	89 d8                	mov    %ebx,%eax
  801839:	eb 02                	jmp    80183d <readn+0x41>
  80183b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80183d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801840:	5b                   	pop    %ebx
  801841:	5e                   	pop    %esi
  801842:	5f                   	pop    %edi
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	53                   	push   %ebx
  801849:	83 ec 14             	sub    $0x14,%esp
  80184c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801852:	50                   	push   %eax
  801853:	53                   	push   %ebx
  801854:	e8 ac fc ff ff       	call   801505 <fd_lookup>
  801859:	83 c4 08             	add    $0x8,%esp
  80185c:	89 c2                	mov    %eax,%edx
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 68                	js     8018ca <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186c:	ff 30                	pushl  (%eax)
  80186e:	e8 e8 fc ff ff       	call   80155b <dev_lookup>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	78 47                	js     8018c1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801881:	75 21                	jne    8018a4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801883:	a1 08 50 80 00       	mov    0x805008,%eax
  801888:	8b 40 48             	mov    0x48(%eax),%eax
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	53                   	push   %ebx
  80188f:	50                   	push   %eax
  801890:	68 21 35 80 00       	push   $0x803521
  801895:	e8 2d ed ff ff       	call   8005c7 <cprintf>
		return -E_INVAL;
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018a2:	eb 26                	jmp    8018ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8018aa:	85 d2                	test   %edx,%edx
  8018ac:	74 17                	je     8018c5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	ff 75 10             	pushl  0x10(%ebp)
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	50                   	push   %eax
  8018b8:	ff d2                	call   *%edx
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	eb 09                	jmp    8018ca <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c1:	89 c2                	mov    %eax,%edx
  8018c3:	eb 05                	jmp    8018ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018ca:	89 d0                	mov    %edx,%eax
  8018cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018da:	50                   	push   %eax
  8018db:	ff 75 08             	pushl  0x8(%ebp)
  8018de:	e8 22 fc ff ff       	call   801505 <fd_lookup>
  8018e3:	83 c4 08             	add    $0x8,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 0e                	js     8018f8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 14             	sub    $0x14,%esp
  801901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801904:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801907:	50                   	push   %eax
  801908:	53                   	push   %ebx
  801909:	e8 f7 fb ff ff       	call   801505 <fd_lookup>
  80190e:	83 c4 08             	add    $0x8,%esp
  801911:	89 c2                	mov    %eax,%edx
  801913:	85 c0                	test   %eax,%eax
  801915:	78 65                	js     80197c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191d:	50                   	push   %eax
  80191e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801921:	ff 30                	pushl  (%eax)
  801923:	e8 33 fc ff ff       	call   80155b <dev_lookup>
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 44                	js     801973 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80192f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801932:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801936:	75 21                	jne    801959 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801938:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80193d:	8b 40 48             	mov    0x48(%eax),%eax
  801940:	83 ec 04             	sub    $0x4,%esp
  801943:	53                   	push   %ebx
  801944:	50                   	push   %eax
  801945:	68 e4 34 80 00       	push   $0x8034e4
  80194a:	e8 78 ec ff ff       	call   8005c7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801957:	eb 23                	jmp    80197c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801959:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195c:	8b 52 18             	mov    0x18(%edx),%edx
  80195f:	85 d2                	test   %edx,%edx
  801961:	74 14                	je     801977 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	ff 75 0c             	pushl  0xc(%ebp)
  801969:	50                   	push   %eax
  80196a:	ff d2                	call   *%edx
  80196c:	89 c2                	mov    %eax,%edx
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	eb 09                	jmp    80197c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801973:	89 c2                	mov    %eax,%edx
  801975:	eb 05                	jmp    80197c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801977:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80197c:	89 d0                	mov    %edx,%eax
  80197e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	53                   	push   %ebx
  801987:	83 ec 14             	sub    $0x14,%esp
  80198a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80198d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801990:	50                   	push   %eax
  801991:	ff 75 08             	pushl  0x8(%ebp)
  801994:	e8 6c fb ff ff       	call   801505 <fd_lookup>
  801999:	83 c4 08             	add    $0x8,%esp
  80199c:	89 c2                	mov    %eax,%edx
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 58                	js     8019fa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a8:	50                   	push   %eax
  8019a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ac:	ff 30                	pushl  (%eax)
  8019ae:	e8 a8 fb ff ff       	call   80155b <dev_lookup>
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 37                	js     8019f1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019c1:	74 32                	je     8019f5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019cd:	00 00 00 
	stat->st_isdir = 0;
  8019d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d7:	00 00 00 
	stat->st_dev = dev;
  8019da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019e0:	83 ec 08             	sub    $0x8,%esp
  8019e3:	53                   	push   %ebx
  8019e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e7:	ff 50 14             	call   *0x14(%eax)
  8019ea:	89 c2                	mov    %eax,%edx
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	eb 09                	jmp    8019fa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f1:	89 c2                	mov    %eax,%edx
  8019f3:	eb 05                	jmp    8019fa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019fa:	89 d0                	mov    %edx,%eax
  8019fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a06:	83 ec 08             	sub    $0x8,%esp
  801a09:	6a 00                	push   $0x0
  801a0b:	ff 75 08             	pushl  0x8(%ebp)
  801a0e:	e8 e7 01 00 00       	call   801bfa <open>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	78 1b                	js     801a37 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	ff 75 0c             	pushl  0xc(%ebp)
  801a22:	50                   	push   %eax
  801a23:	e8 5b ff ff ff       	call   801983 <fstat>
  801a28:	89 c6                	mov    %eax,%esi
	close(fd);
  801a2a:	89 1c 24             	mov    %ebx,(%esp)
  801a2d:	e8 fd fb ff ff       	call   80162f <close>
	return r;
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	89 f0                	mov    %esi,%eax
}
  801a37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	89 c6                	mov    %eax,%esi
  801a45:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a47:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a4e:	75 12                	jne    801a62 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	6a 01                	push   $0x1
  801a55:	e8 54 11 00 00       	call   802bae <ipc_find_env>
  801a5a:	a3 00 50 80 00       	mov    %eax,0x805000
  801a5f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a62:	6a 07                	push   $0x7
  801a64:	68 00 60 80 00       	push   $0x806000
  801a69:	56                   	push   %esi
  801a6a:	ff 35 00 50 80 00    	pushl  0x805000
  801a70:	e8 e5 10 00 00       	call   802b5a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a75:	83 c4 0c             	add    $0xc,%esp
  801a78:	6a 00                	push   $0x0
  801a7a:	53                   	push   %ebx
  801a7b:	6a 00                	push   $0x0
  801a7d:	e8 6b 10 00 00       	call   802aed <ipc_recv>
}
  801a82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	8b 40 0c             	mov    0xc(%eax),%eax
  801a95:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa7:	b8 02 00 00 00       	mov    $0x2,%eax
  801aac:	e8 8d ff ff ff       	call   801a3e <fsipc>
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	8b 40 0c             	mov    0xc(%eax),%eax
  801abf:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	b8 06 00 00 00       	mov    $0x6,%eax
  801ace:	e8 6b ff ff ff       	call   801a3e <fsipc>
}
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    

00801ad5 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 04             	sub    $0x4,%esp
  801adc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae5:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aea:	ba 00 00 00 00       	mov    $0x0,%edx
  801aef:	b8 05 00 00 00       	mov    $0x5,%eax
  801af4:	e8 45 ff ff ff       	call   801a3e <fsipc>
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 2c                	js     801b29 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801afd:	83 ec 08             	sub    $0x8,%esp
  801b00:	68 00 60 80 00       	push   $0x806000
  801b05:	53                   	push   %ebx
  801b06:	e8 41 f0 ff ff       	call   800b4c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b0b:	a1 80 60 80 00       	mov    0x806080,%eax
  801b10:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b16:	a1 84 60 80 00       	mov    0x806084,%eax
  801b1b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	53                   	push   %ebx
  801b32:	83 ec 08             	sub    $0x8,%esp
  801b35:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801b38:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b3d:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801b42:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b45:	53                   	push   %ebx
  801b46:	ff 75 0c             	pushl  0xc(%ebp)
  801b49:	68 08 60 80 00       	push   $0x806008
  801b4e:	e8 8b f1 ff ff       	call   800cde <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b53:	8b 45 08             	mov    0x8(%ebp),%eax
  801b56:	8b 40 0c             	mov    0xc(%eax),%eax
  801b59:	a3 00 60 80 00       	mov    %eax,0x806000
 	fsipcbuf.write.req_n = n;
  801b5e:	89 1d 04 60 80 00    	mov    %ebx,0x806004

 	return fsipc(FSREQ_WRITE, NULL);
  801b64:	ba 00 00 00 00       	mov    $0x0,%edx
  801b69:	b8 04 00 00 00       	mov    $0x4,%eax
  801b6e:	e8 cb fe ff ff       	call   801a3e <fsipc>
	//panic("devfile_write not implemented");
}
  801b73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	56                   	push   %esi
  801b7c:	53                   	push   %ebx
  801b7d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	8b 40 0c             	mov    0xc(%eax),%eax
  801b86:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b8b:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b91:	ba 00 00 00 00       	mov    $0x0,%edx
  801b96:	b8 03 00 00 00       	mov    $0x3,%eax
  801b9b:	e8 9e fe ff ff       	call   801a3e <fsipc>
  801ba0:	89 c3                	mov    %eax,%ebx
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	78 4b                	js     801bf1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ba6:	39 c6                	cmp    %eax,%esi
  801ba8:	73 16                	jae    801bc0 <devfile_read+0x48>
  801baa:	68 54 35 80 00       	push   $0x803554
  801baf:	68 5b 35 80 00       	push   $0x80355b
  801bb4:	6a 7c                	push   $0x7c
  801bb6:	68 70 35 80 00       	push   $0x803570
  801bbb:	e8 2e e9 ff ff       	call   8004ee <_panic>
	assert(r <= PGSIZE);
  801bc0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bc5:	7e 16                	jle    801bdd <devfile_read+0x65>
  801bc7:	68 7b 35 80 00       	push   $0x80357b
  801bcc:	68 5b 35 80 00       	push   $0x80355b
  801bd1:	6a 7d                	push   $0x7d
  801bd3:	68 70 35 80 00       	push   $0x803570
  801bd8:	e8 11 e9 ff ff       	call   8004ee <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bdd:	83 ec 04             	sub    $0x4,%esp
  801be0:	50                   	push   %eax
  801be1:	68 00 60 80 00       	push   $0x806000
  801be6:	ff 75 0c             	pushl  0xc(%ebp)
  801be9:	e8 f0 f0 ff ff       	call   800cde <memmove>
	return r;
  801bee:	83 c4 10             	add    $0x10,%esp
}
  801bf1:	89 d8                	mov    %ebx,%eax
  801bf3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    

00801bfa <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	53                   	push   %ebx
  801bfe:	83 ec 20             	sub    $0x20,%esp
  801c01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c04:	53                   	push   %ebx
  801c05:	e8 09 ef ff ff       	call   800b13 <strlen>
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c12:	7f 67                	jg     801c7b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	e8 96 f8 ff ff       	call   8014b6 <fd_alloc>
  801c20:	83 c4 10             	add    $0x10,%esp
		return r;
  801c23:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c25:	85 c0                	test   %eax,%eax
  801c27:	78 57                	js     801c80 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c29:	83 ec 08             	sub    $0x8,%esp
  801c2c:	53                   	push   %ebx
  801c2d:	68 00 60 80 00       	push   $0x806000
  801c32:	e8 15 ef ff ff       	call   800b4c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3a:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c42:	b8 01 00 00 00       	mov    $0x1,%eax
  801c47:	e8 f2 fd ff ff       	call   801a3e <fsipc>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	79 14                	jns    801c69 <open+0x6f>
		fd_close(fd, 0);
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	6a 00                	push   $0x0
  801c5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5d:	e8 4c f9 ff ff       	call   8015ae <fd_close>
		return r;
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	89 da                	mov    %ebx,%edx
  801c67:	eb 17                	jmp    801c80 <open+0x86>
	}

	return fd2num(fd);
  801c69:	83 ec 0c             	sub    $0xc,%esp
  801c6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6f:	e8 1b f8 ff ff       	call   80148f <fd2num>
  801c74:	89 c2                	mov    %eax,%edx
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	eb 05                	jmp    801c80 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c7b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c80:	89 d0                	mov    %edx,%eax
  801c82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c85:	c9                   	leave  
  801c86:	c3                   	ret    

00801c87 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c92:	b8 08 00 00 00       	mov    $0x8,%eax
  801c97:	e8 a2 fd ff ff       	call   801a3e <fsipc>
}
  801c9c:	c9                   	leave  
  801c9d:	c3                   	ret    

00801c9e <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801caa:	6a 00                	push   $0x0
  801cac:	ff 75 08             	pushl  0x8(%ebp)
  801caf:	e8 46 ff ff ff       	call   801bfa <open>
  801cb4:	89 c7                	mov    %eax,%edi
  801cb6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	0f 88 a4 04 00 00    	js     80216b <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801cc7:	83 ec 04             	sub    $0x4,%esp
  801cca:	68 00 02 00 00       	push   $0x200
  801ccf:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801cd5:	50                   	push   %eax
  801cd6:	57                   	push   %edi
  801cd7:	e8 20 fb ff ff       	call   8017fc <readn>
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	3d 00 02 00 00       	cmp    $0x200,%eax
  801ce4:	75 0c                	jne    801cf2 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801ce6:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ced:	45 4c 46 
  801cf0:	74 33                	je     801d25 <spawn+0x87>
		close(fd);
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cfb:	e8 2f f9 ff ff       	call   80162f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d00:	83 c4 0c             	add    $0xc,%esp
  801d03:	68 7f 45 4c 46       	push   $0x464c457f
  801d08:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d0e:	68 87 35 80 00       	push   $0x803587
  801d13:	e8 af e8 ff ff       	call   8005c7 <cprintf>
		return -E_NOT_EXEC;
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801d20:	e9 a6 04 00 00       	jmp    8021cb <spawn+0x52d>
  801d25:	b8 07 00 00 00       	mov    $0x7,%eax
  801d2a:	cd 30                	int    $0x30
  801d2c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d32:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	0f 88 33 04 00 00    	js     802173 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d40:	89 c6                	mov    %eax,%esi
  801d42:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d48:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d4b:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d51:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d57:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d5e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d64:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d6a:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d6f:	be 00 00 00 00       	mov    $0x0,%esi
  801d74:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d77:	eb 13                	jmp    801d8c <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	50                   	push   %eax
  801d7d:	e8 91 ed ff ff       	call   800b13 <strlen>
  801d82:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d86:	83 c3 01             	add    $0x1,%ebx
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d93:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d96:	85 c0                	test   %eax,%eax
  801d98:	75 df                	jne    801d79 <spawn+0xdb>
  801d9a:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801da0:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801da6:	bf 00 10 40 00       	mov    $0x401000,%edi
  801dab:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801dad:	89 fa                	mov    %edi,%edx
  801daf:	83 e2 fc             	and    $0xfffffffc,%edx
  801db2:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801db9:	29 c2                	sub    %eax,%edx
  801dbb:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801dc1:	8d 42 f8             	lea    -0x8(%edx),%eax
  801dc4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801dc9:	0f 86 b4 03 00 00    	jbe    802183 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dcf:	83 ec 04             	sub    $0x4,%esp
  801dd2:	6a 07                	push   $0x7
  801dd4:	68 00 00 40 00       	push   $0x400000
  801dd9:	6a 00                	push   $0x0
  801ddb:	e8 6f f1 ff ff       	call   800f4f <sys_page_alloc>
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	85 c0                	test   %eax,%eax
  801de5:	0f 88 9f 03 00 00    	js     80218a <spawn+0x4ec>
  801deb:	be 00 00 00 00       	mov    $0x0,%esi
  801df0:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801df6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801df9:	eb 30                	jmp    801e2b <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801dfb:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e01:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e07:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801e0a:	83 ec 08             	sub    $0x8,%esp
  801e0d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e10:	57                   	push   %edi
  801e11:	e8 36 ed ff ff       	call   800b4c <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e16:	83 c4 04             	add    $0x4,%esp
  801e19:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e1c:	e8 f2 ec ff ff       	call   800b13 <strlen>
  801e21:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e25:	83 c6 01             	add    $0x1,%esi
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e31:	7f c8                	jg     801dfb <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e33:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e39:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e3f:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e46:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e4c:	74 19                	je     801e67 <spawn+0x1c9>
  801e4e:	68 fc 35 80 00       	push   $0x8035fc
  801e53:	68 5b 35 80 00       	push   $0x80355b
  801e58:	68 f1 00 00 00       	push   $0xf1
  801e5d:	68 a1 35 80 00       	push   $0x8035a1
  801e62:	e8 87 e6 ff ff       	call   8004ee <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e67:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e6d:	89 f8                	mov    %edi,%eax
  801e6f:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e74:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e77:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e7d:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e80:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e86:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	6a 07                	push   $0x7
  801e91:	68 00 d0 bf ee       	push   $0xeebfd000
  801e96:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e9c:	68 00 00 40 00       	push   $0x400000
  801ea1:	6a 00                	push   $0x0
  801ea3:	e8 ea f0 ff ff       	call   800f92 <sys_page_map>
  801ea8:	89 c3                	mov    %eax,%ebx
  801eaa:	83 c4 20             	add    $0x20,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	0f 88 04 03 00 00    	js     8021b9 <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801eb5:	83 ec 08             	sub    $0x8,%esp
  801eb8:	68 00 00 40 00       	push   $0x400000
  801ebd:	6a 00                	push   $0x0
  801ebf:	e8 10 f1 ff ff       	call   800fd4 <sys_page_unmap>
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	83 c4 10             	add    $0x10,%esp
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	0f 88 e8 02 00 00    	js     8021b9 <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ed1:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ed7:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ede:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ee4:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801eeb:	00 00 00 
  801eee:	e9 88 01 00 00       	jmp    80207b <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801ef3:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ef9:	83 38 01             	cmpl   $0x1,(%eax)
  801efc:	0f 85 6b 01 00 00    	jne    80206d <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f02:	89 c7                	mov    %eax,%edi
  801f04:	8b 40 18             	mov    0x18(%eax),%eax
  801f07:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f0d:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f10:	83 f8 01             	cmp    $0x1,%eax
  801f13:	19 c0                	sbb    %eax,%eax
  801f15:	83 e0 fe             	and    $0xfffffffe,%eax
  801f18:	83 c0 07             	add    $0x7,%eax
  801f1b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801f21:	89 f8                	mov    %edi,%eax
  801f23:	8b 7f 04             	mov    0x4(%edi),%edi
  801f26:	89 f9                	mov    %edi,%ecx
  801f28:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801f2e:	8b 78 10             	mov    0x10(%eax),%edi
  801f31:	8b 50 14             	mov    0x14(%eax),%edx
  801f34:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801f3a:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f3d:	89 f0                	mov    %esi,%eax
  801f3f:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f44:	74 14                	je     801f5a <spawn+0x2bc>
		va -= i;
  801f46:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f48:	01 c2                	add    %eax,%edx
  801f4a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801f50:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f52:	29 c1                	sub    %eax,%ecx
  801f54:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f5f:	e9 f7 00 00 00       	jmp    80205b <spawn+0x3bd>
		if (i >= filesz) {
  801f64:	39 df                	cmp    %ebx,%edi
  801f66:	77 27                	ja     801f8f <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f68:	83 ec 04             	sub    $0x4,%esp
  801f6b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f71:	56                   	push   %esi
  801f72:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f78:	e8 d2 ef ff ff       	call   800f4f <sys_page_alloc>
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	85 c0                	test   %eax,%eax
  801f82:	0f 89 c7 00 00 00    	jns    80204f <spawn+0x3b1>
  801f88:	89 c3                	mov    %eax,%ebx
  801f8a:	e9 09 02 00 00       	jmp    802198 <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f8f:	83 ec 04             	sub    $0x4,%esp
  801f92:	6a 07                	push   $0x7
  801f94:	68 00 00 40 00       	push   $0x400000
  801f99:	6a 00                	push   $0x0
  801f9b:	e8 af ef ff ff       	call   800f4f <sys_page_alloc>
  801fa0:	83 c4 10             	add    $0x10,%esp
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	0f 88 e3 01 00 00    	js     80218e <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801fab:	83 ec 08             	sub    $0x8,%esp
  801fae:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801fb4:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801fba:	50                   	push   %eax
  801fbb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fc1:	e8 0b f9 ff ff       	call   8018d1 <seek>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	0f 88 c1 01 00 00    	js     802192 <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fd1:	83 ec 04             	sub    $0x4,%esp
  801fd4:	89 f8                	mov    %edi,%eax
  801fd6:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801fdc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801fe1:	ba 00 10 00 00       	mov    $0x1000,%edx
  801fe6:	0f 47 c2             	cmova  %edx,%eax
  801fe9:	50                   	push   %eax
  801fea:	68 00 00 40 00       	push   $0x400000
  801fef:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ff5:	e8 02 f8 ff ff       	call   8017fc <readn>
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	0f 88 91 01 00 00    	js     802196 <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802005:	83 ec 0c             	sub    $0xc,%esp
  802008:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80200e:	56                   	push   %esi
  80200f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802015:	68 00 00 40 00       	push   $0x400000
  80201a:	6a 00                	push   $0x0
  80201c:	e8 71 ef ff ff       	call   800f92 <sys_page_map>
  802021:	83 c4 20             	add    $0x20,%esp
  802024:	85 c0                	test   %eax,%eax
  802026:	79 15                	jns    80203d <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802028:	50                   	push   %eax
  802029:	68 ad 35 80 00       	push   $0x8035ad
  80202e:	68 24 01 00 00       	push   $0x124
  802033:	68 a1 35 80 00       	push   $0x8035a1
  802038:	e8 b1 e4 ff ff       	call   8004ee <_panic>
			sys_page_unmap(0, UTEMP);
  80203d:	83 ec 08             	sub    $0x8,%esp
  802040:	68 00 00 40 00       	push   $0x400000
  802045:	6a 00                	push   $0x0
  802047:	e8 88 ef ff ff       	call   800fd4 <sys_page_unmap>
  80204c:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80204f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802055:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80205b:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802061:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802067:	0f 87 f7 fe ff ff    	ja     801f64 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80206d:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802074:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80207b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802082:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802088:	0f 8c 65 fe ff ff    	jl     801ef3 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80208e:	83 ec 0c             	sub    $0xc,%esp
  802091:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802097:	e8 93 f5 ff ff       	call   80162f <close>
  80209c:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  80209f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020a4:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
 	{
    	if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)) {
  8020aa:	89 d8                	mov    %ebx,%eax
  8020ac:	c1 e8 16             	shr    $0x16,%eax
  8020af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020b6:	a8 01                	test   $0x1,%al
  8020b8:	74 46                	je     802100 <spawn+0x462>
  8020ba:	89 d8                	mov    %ebx,%eax
  8020bc:	c1 e8 0c             	shr    $0xc,%eax
  8020bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020c6:	f6 c2 01             	test   $0x1,%dl
  8020c9:	74 35                	je     802100 <spawn+0x462>
  8020cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020d2:	f6 c2 04             	test   $0x4,%dl
  8020d5:	74 29                	je     802100 <spawn+0x462>
  8020d7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020de:	f6 c6 04             	test   $0x4,%dh
  8020e1:	74 1d                	je     802100 <spawn+0x462>
        	sys_page_map(0, (void*)i, child, (void*)i, (uvpt[PGNUM(i)] & PTE_SYSCALL));
  8020e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020ea:	83 ec 0c             	sub    $0xc,%esp
  8020ed:	25 07 0e 00 00       	and    $0xe07,%eax
  8020f2:	50                   	push   %eax
  8020f3:	53                   	push   %ebx
  8020f4:	56                   	push   %esi
  8020f5:	53                   	push   %ebx
  8020f6:	6a 00                	push   $0x0
  8020f8:	e8 95 ee ff ff       	call   800f92 <sys_page_map>
  8020fd:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  802100:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802106:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80210c:	75 9c                	jne    8020aa <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80210e:	83 ec 08             	sub    $0x8,%esp
  802111:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802117:	50                   	push   %eax
  802118:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80211e:	e8 35 ef ff ff       	call   801058 <sys_env_set_trapframe>
  802123:	83 c4 10             	add    $0x10,%esp
  802126:	85 c0                	test   %eax,%eax
  802128:	79 15                	jns    80213f <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  80212a:	50                   	push   %eax
  80212b:	68 ca 35 80 00       	push   $0x8035ca
  802130:	68 85 00 00 00       	push   $0x85
  802135:	68 a1 35 80 00       	push   $0x8035a1
  80213a:	e8 af e3 ff ff       	call   8004ee <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80213f:	83 ec 08             	sub    $0x8,%esp
  802142:	6a 02                	push   $0x2
  802144:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80214a:	e8 c7 ee ff ff       	call   801016 <sys_env_set_status>
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	85 c0                	test   %eax,%eax
  802154:	79 25                	jns    80217b <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  802156:	50                   	push   %eax
  802157:	68 e4 35 80 00       	push   $0x8035e4
  80215c:	68 88 00 00 00       	push   $0x88
  802161:	68 a1 35 80 00       	push   $0x8035a1
  802166:	e8 83 e3 ff ff       	call   8004ee <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80216b:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802171:	eb 58                	jmp    8021cb <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802173:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802179:	eb 50                	jmp    8021cb <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80217b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802181:	eb 48                	jmp    8021cb <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802183:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802188:	eb 41                	jmp    8021cb <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80218a:	89 c3                	mov    %eax,%ebx
  80218c:	eb 3d                	jmp    8021cb <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	eb 06                	jmp    802198 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802192:	89 c3                	mov    %eax,%ebx
  802194:	eb 02                	jmp    802198 <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802196:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802198:	83 ec 0c             	sub    $0xc,%esp
  80219b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021a1:	e8 2a ed ff ff       	call   800ed0 <sys_env_destroy>
	close(fd);
  8021a6:	83 c4 04             	add    $0x4,%esp
  8021a9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8021af:	e8 7b f4 ff ff       	call   80162f <close>
	return r;
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	eb 12                	jmp    8021cb <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8021b9:	83 ec 08             	sub    $0x8,%esp
  8021bc:	68 00 00 40 00       	push   $0x400000
  8021c1:	6a 00                	push   $0x0
  8021c3:	e8 0c ee ff ff       	call   800fd4 <sys_page_unmap>
  8021c8:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021cb:	89 d8                	mov    %ebx,%eax
  8021cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    

008021d5 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	56                   	push   %esi
  8021d9:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021da:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021dd:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021e2:	eb 03                	jmp    8021e7 <spawnl+0x12>
		argc++;
  8021e4:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021e7:	83 c2 04             	add    $0x4,%edx
  8021ea:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021ee:	75 f4                	jne    8021e4 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021f0:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021f7:	83 e2 f0             	and    $0xfffffff0,%edx
  8021fa:	29 d4                	sub    %edx,%esp
  8021fc:	8d 54 24 03          	lea    0x3(%esp),%edx
  802200:	c1 ea 02             	shr    $0x2,%edx
  802203:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80220a:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80220c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80220f:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802216:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80221d:	00 
  80221e:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802220:	b8 00 00 00 00       	mov    $0x0,%eax
  802225:	eb 0a                	jmp    802231 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802227:	83 c0 01             	add    $0x1,%eax
  80222a:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80222e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802231:	39 d0                	cmp    %edx,%eax
  802233:	75 f2                	jne    802227 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802235:	83 ec 08             	sub    $0x8,%esp
  802238:	56                   	push   %esi
  802239:	ff 75 08             	pushl  0x8(%ebp)
  80223c:	e8 5d fa ff ff       	call   801c9e <spawn>
}
  802241:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    

00802248 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80224e:	68 22 36 80 00       	push   $0x803622
  802253:	ff 75 0c             	pushl  0xc(%ebp)
  802256:	e8 f1 e8 ff ff       	call   800b4c <strcpy>
	return 0;
}
  80225b:	b8 00 00 00 00       	mov    $0x0,%eax
  802260:	c9                   	leave  
  802261:	c3                   	ret    

00802262 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	53                   	push   %ebx
  802266:	83 ec 10             	sub    $0x10,%esp
  802269:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80226c:	53                   	push   %ebx
  80226d:	e8 75 09 00 00       	call   802be7 <pageref>
  802272:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802275:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80227a:	83 f8 01             	cmp    $0x1,%eax
  80227d:	75 10                	jne    80228f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80227f:	83 ec 0c             	sub    $0xc,%esp
  802282:	ff 73 0c             	pushl  0xc(%ebx)
  802285:	e8 c0 02 00 00       	call   80254a <nsipc_close>
  80228a:	89 c2                	mov    %eax,%edx
  80228c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80228f:	89 d0                	mov    %edx,%eax
  802291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802294:	c9                   	leave  
  802295:	c3                   	ret    

00802296 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802296:	55                   	push   %ebp
  802297:	89 e5                	mov    %esp,%ebp
  802299:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80229c:	6a 00                	push   $0x0
  80229e:	ff 75 10             	pushl  0x10(%ebp)
  8022a1:	ff 75 0c             	pushl  0xc(%ebp)
  8022a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a7:	ff 70 0c             	pushl  0xc(%eax)
  8022aa:	e8 78 03 00 00       	call   802627 <nsipc_send>
}
  8022af:	c9                   	leave  
  8022b0:	c3                   	ret    

008022b1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8022b1:	55                   	push   %ebp
  8022b2:	89 e5                	mov    %esp,%ebp
  8022b4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8022b7:	6a 00                	push   $0x0
  8022b9:	ff 75 10             	pushl  0x10(%ebp)
  8022bc:	ff 75 0c             	pushl  0xc(%ebp)
  8022bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c2:	ff 70 0c             	pushl  0xc(%eax)
  8022c5:	e8 f1 02 00 00       	call   8025bb <nsipc_recv>
}
  8022ca:	c9                   	leave  
  8022cb:	c3                   	ret    

008022cc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8022d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8022d5:	52                   	push   %edx
  8022d6:	50                   	push   %eax
  8022d7:	e8 29 f2 ff ff       	call   801505 <fd_lookup>
  8022dc:	83 c4 10             	add    $0x10,%esp
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	78 17                	js     8022fa <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8022e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e6:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  8022ec:	39 08                	cmp    %ecx,(%eax)
  8022ee:	75 05                	jne    8022f5 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8022f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8022f3:	eb 05                	jmp    8022fa <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8022f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8022fa:	c9                   	leave  
  8022fb:	c3                   	ret    

008022fc <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	56                   	push   %esi
  802300:	53                   	push   %ebx
  802301:	83 ec 1c             	sub    $0x1c,%esp
  802304:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802309:	50                   	push   %eax
  80230a:	e8 a7 f1 ff ff       	call   8014b6 <fd_alloc>
  80230f:	89 c3                	mov    %eax,%ebx
  802311:	83 c4 10             	add    $0x10,%esp
  802314:	85 c0                	test   %eax,%eax
  802316:	78 1b                	js     802333 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802318:	83 ec 04             	sub    $0x4,%esp
  80231b:	68 07 04 00 00       	push   $0x407
  802320:	ff 75 f4             	pushl  -0xc(%ebp)
  802323:	6a 00                	push   $0x0
  802325:	e8 25 ec ff ff       	call   800f4f <sys_page_alloc>
  80232a:	89 c3                	mov    %eax,%ebx
  80232c:	83 c4 10             	add    $0x10,%esp
  80232f:	85 c0                	test   %eax,%eax
  802331:	79 10                	jns    802343 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802333:	83 ec 0c             	sub    $0xc,%esp
  802336:	56                   	push   %esi
  802337:	e8 0e 02 00 00       	call   80254a <nsipc_close>
		return r;
  80233c:	83 c4 10             	add    $0x10,%esp
  80233f:	89 d8                	mov    %ebx,%eax
  802341:	eb 24                	jmp    802367 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802343:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80234e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802351:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802358:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80235b:	83 ec 0c             	sub    $0xc,%esp
  80235e:	50                   	push   %eax
  80235f:	e8 2b f1 ff ff       	call   80148f <fd2num>
  802364:	83 c4 10             	add    $0x10,%esp
}
  802367:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80236a:	5b                   	pop    %ebx
  80236b:	5e                   	pop    %esi
  80236c:	5d                   	pop    %ebp
  80236d:	c3                   	ret    

0080236e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802374:	8b 45 08             	mov    0x8(%ebp),%eax
  802377:	e8 50 ff ff ff       	call   8022cc <fd2sockid>
		return r;
  80237c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80237e:	85 c0                	test   %eax,%eax
  802380:	78 1f                	js     8023a1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802382:	83 ec 04             	sub    $0x4,%esp
  802385:	ff 75 10             	pushl  0x10(%ebp)
  802388:	ff 75 0c             	pushl  0xc(%ebp)
  80238b:	50                   	push   %eax
  80238c:	e8 12 01 00 00       	call   8024a3 <nsipc_accept>
  802391:	83 c4 10             	add    $0x10,%esp
		return r;
  802394:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802396:	85 c0                	test   %eax,%eax
  802398:	78 07                	js     8023a1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80239a:	e8 5d ff ff ff       	call   8022fc <alloc_sockfd>
  80239f:	89 c1                	mov    %eax,%ecx
}
  8023a1:	89 c8                	mov    %ecx,%eax
  8023a3:	c9                   	leave  
  8023a4:	c3                   	ret    

008023a5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ae:	e8 19 ff ff ff       	call   8022cc <fd2sockid>
  8023b3:	85 c0                	test   %eax,%eax
  8023b5:	78 12                	js     8023c9 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8023b7:	83 ec 04             	sub    $0x4,%esp
  8023ba:	ff 75 10             	pushl  0x10(%ebp)
  8023bd:	ff 75 0c             	pushl  0xc(%ebp)
  8023c0:	50                   	push   %eax
  8023c1:	e8 2d 01 00 00       	call   8024f3 <nsipc_bind>
  8023c6:	83 c4 10             	add    $0x10,%esp
}
  8023c9:	c9                   	leave  
  8023ca:	c3                   	ret    

008023cb <shutdown>:

int
shutdown(int s, int how)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d4:	e8 f3 fe ff ff       	call   8022cc <fd2sockid>
  8023d9:	85 c0                	test   %eax,%eax
  8023db:	78 0f                	js     8023ec <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8023dd:	83 ec 08             	sub    $0x8,%esp
  8023e0:	ff 75 0c             	pushl  0xc(%ebp)
  8023e3:	50                   	push   %eax
  8023e4:	e8 3f 01 00 00       	call   802528 <nsipc_shutdown>
  8023e9:	83 c4 10             	add    $0x10,%esp
}
  8023ec:	c9                   	leave  
  8023ed:	c3                   	ret    

008023ee <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f7:	e8 d0 fe ff ff       	call   8022cc <fd2sockid>
  8023fc:	85 c0                	test   %eax,%eax
  8023fe:	78 12                	js     802412 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802400:	83 ec 04             	sub    $0x4,%esp
  802403:	ff 75 10             	pushl  0x10(%ebp)
  802406:	ff 75 0c             	pushl  0xc(%ebp)
  802409:	50                   	push   %eax
  80240a:	e8 55 01 00 00       	call   802564 <nsipc_connect>
  80240f:	83 c4 10             	add    $0x10,%esp
}
  802412:	c9                   	leave  
  802413:	c3                   	ret    

00802414 <listen>:

int
listen(int s, int backlog)
{
  802414:	55                   	push   %ebp
  802415:	89 e5                	mov    %esp,%ebp
  802417:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80241a:	8b 45 08             	mov    0x8(%ebp),%eax
  80241d:	e8 aa fe ff ff       	call   8022cc <fd2sockid>
  802422:	85 c0                	test   %eax,%eax
  802424:	78 0f                	js     802435 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802426:	83 ec 08             	sub    $0x8,%esp
  802429:	ff 75 0c             	pushl  0xc(%ebp)
  80242c:	50                   	push   %eax
  80242d:	e8 67 01 00 00       	call   802599 <nsipc_listen>
  802432:	83 c4 10             	add    $0x10,%esp
}
  802435:	c9                   	leave  
  802436:	c3                   	ret    

00802437 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80243d:	ff 75 10             	pushl  0x10(%ebp)
  802440:	ff 75 0c             	pushl  0xc(%ebp)
  802443:	ff 75 08             	pushl  0x8(%ebp)
  802446:	e8 3a 02 00 00       	call   802685 <nsipc_socket>
  80244b:	83 c4 10             	add    $0x10,%esp
  80244e:	85 c0                	test   %eax,%eax
  802450:	78 05                	js     802457 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802452:	e8 a5 fe ff ff       	call   8022fc <alloc_sockfd>
}
  802457:	c9                   	leave  
  802458:	c3                   	ret    

00802459 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802459:	55                   	push   %ebp
  80245a:	89 e5                	mov    %esp,%ebp
  80245c:	53                   	push   %ebx
  80245d:	83 ec 04             	sub    $0x4,%esp
  802460:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802462:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802469:	75 12                	jne    80247d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80246b:	83 ec 0c             	sub    $0xc,%esp
  80246e:	6a 02                	push   $0x2
  802470:	e8 39 07 00 00       	call   802bae <ipc_find_env>
  802475:	a3 04 50 80 00       	mov    %eax,0x805004
  80247a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80247d:	6a 07                	push   $0x7
  80247f:	68 00 70 80 00       	push   $0x807000
  802484:	53                   	push   %ebx
  802485:	ff 35 04 50 80 00    	pushl  0x805004
  80248b:	e8 ca 06 00 00       	call   802b5a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802490:	83 c4 0c             	add    $0xc,%esp
  802493:	6a 00                	push   $0x0
  802495:	6a 00                	push   $0x0
  802497:	6a 00                	push   $0x0
  802499:	e8 4f 06 00 00       	call   802aed <ipc_recv>
}
  80249e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024a1:	c9                   	leave  
  8024a2:	c3                   	ret    

008024a3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024a3:	55                   	push   %ebp
  8024a4:	89 e5                	mov    %esp,%ebp
  8024a6:	56                   	push   %esi
  8024a7:	53                   	push   %ebx
  8024a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8024ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ae:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8024b3:	8b 06                	mov    (%esi),%eax
  8024b5:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8024ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bf:	e8 95 ff ff ff       	call   802459 <nsipc>
  8024c4:	89 c3                	mov    %eax,%ebx
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	78 20                	js     8024ea <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8024ca:	83 ec 04             	sub    $0x4,%esp
  8024cd:	ff 35 10 70 80 00    	pushl  0x807010
  8024d3:	68 00 70 80 00       	push   $0x807000
  8024d8:	ff 75 0c             	pushl  0xc(%ebp)
  8024db:	e8 fe e7 ff ff       	call   800cde <memmove>
		*addrlen = ret->ret_addrlen;
  8024e0:	a1 10 70 80 00       	mov    0x807010,%eax
  8024e5:	89 06                	mov    %eax,(%esi)
  8024e7:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8024ea:	89 d8                	mov    %ebx,%eax
  8024ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024ef:	5b                   	pop    %ebx
  8024f0:	5e                   	pop    %esi
  8024f1:	5d                   	pop    %ebp
  8024f2:	c3                   	ret    

008024f3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024f3:	55                   	push   %ebp
  8024f4:	89 e5                	mov    %esp,%ebp
  8024f6:	53                   	push   %ebx
  8024f7:	83 ec 08             	sub    $0x8,%esp
  8024fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802500:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802505:	53                   	push   %ebx
  802506:	ff 75 0c             	pushl  0xc(%ebp)
  802509:	68 04 70 80 00       	push   $0x807004
  80250e:	e8 cb e7 ff ff       	call   800cde <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802513:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802519:	b8 02 00 00 00       	mov    $0x2,%eax
  80251e:	e8 36 ff ff ff       	call   802459 <nsipc>
}
  802523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802526:	c9                   	leave  
  802527:	c3                   	ret    

00802528 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802528:	55                   	push   %ebp
  802529:	89 e5                	mov    %esp,%ebp
  80252b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80252e:	8b 45 08             	mov    0x8(%ebp),%eax
  802531:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802536:	8b 45 0c             	mov    0xc(%ebp),%eax
  802539:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80253e:	b8 03 00 00 00       	mov    $0x3,%eax
  802543:	e8 11 ff ff ff       	call   802459 <nsipc>
}
  802548:	c9                   	leave  
  802549:	c3                   	ret    

0080254a <nsipc_close>:

int
nsipc_close(int s)
{
  80254a:	55                   	push   %ebp
  80254b:	89 e5                	mov    %esp,%ebp
  80254d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802550:	8b 45 08             	mov    0x8(%ebp),%eax
  802553:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802558:	b8 04 00 00 00       	mov    $0x4,%eax
  80255d:	e8 f7 fe ff ff       	call   802459 <nsipc>
}
  802562:	c9                   	leave  
  802563:	c3                   	ret    

00802564 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802564:	55                   	push   %ebp
  802565:	89 e5                	mov    %esp,%ebp
  802567:	53                   	push   %ebx
  802568:	83 ec 08             	sub    $0x8,%esp
  80256b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80256e:	8b 45 08             	mov    0x8(%ebp),%eax
  802571:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802576:	53                   	push   %ebx
  802577:	ff 75 0c             	pushl  0xc(%ebp)
  80257a:	68 04 70 80 00       	push   $0x807004
  80257f:	e8 5a e7 ff ff       	call   800cde <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802584:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80258a:	b8 05 00 00 00       	mov    $0x5,%eax
  80258f:	e8 c5 fe ff ff       	call   802459 <nsipc>
}
  802594:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802597:	c9                   	leave  
  802598:	c3                   	ret    

00802599 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802599:	55                   	push   %ebp
  80259a:	89 e5                	mov    %esp,%ebp
  80259c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80259f:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8025a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025aa:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8025af:	b8 06 00 00 00       	mov    $0x6,%eax
  8025b4:	e8 a0 fe ff ff       	call   802459 <nsipc>
}
  8025b9:	c9                   	leave  
  8025ba:	c3                   	ret    

008025bb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8025bb:	55                   	push   %ebp
  8025bc:	89 e5                	mov    %esp,%ebp
  8025be:	56                   	push   %esi
  8025bf:	53                   	push   %ebx
  8025c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8025c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8025cb:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8025d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8025d4:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8025de:	e8 76 fe ff ff       	call   802459 <nsipc>
  8025e3:	89 c3                	mov    %eax,%ebx
  8025e5:	85 c0                	test   %eax,%eax
  8025e7:	78 35                	js     80261e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8025e9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025ee:	7f 04                	jg     8025f4 <nsipc_recv+0x39>
  8025f0:	39 c6                	cmp    %eax,%esi
  8025f2:	7d 16                	jge    80260a <nsipc_recv+0x4f>
  8025f4:	68 2e 36 80 00       	push   $0x80362e
  8025f9:	68 5b 35 80 00       	push   $0x80355b
  8025fe:	6a 62                	push   $0x62
  802600:	68 43 36 80 00       	push   $0x803643
  802605:	e8 e4 de ff ff       	call   8004ee <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80260a:	83 ec 04             	sub    $0x4,%esp
  80260d:	50                   	push   %eax
  80260e:	68 00 70 80 00       	push   $0x807000
  802613:	ff 75 0c             	pushl  0xc(%ebp)
  802616:	e8 c3 e6 ff ff       	call   800cde <memmove>
  80261b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80261e:	89 d8                	mov    %ebx,%eax
  802620:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802623:	5b                   	pop    %ebx
  802624:	5e                   	pop    %esi
  802625:	5d                   	pop    %ebp
  802626:	c3                   	ret    

00802627 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802627:	55                   	push   %ebp
  802628:	89 e5                	mov    %esp,%ebp
  80262a:	53                   	push   %ebx
  80262b:	83 ec 04             	sub    $0x4,%esp
  80262e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802631:	8b 45 08             	mov    0x8(%ebp),%eax
  802634:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802639:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80263f:	7e 16                	jle    802657 <nsipc_send+0x30>
  802641:	68 4f 36 80 00       	push   $0x80364f
  802646:	68 5b 35 80 00       	push   $0x80355b
  80264b:	6a 6d                	push   $0x6d
  80264d:	68 43 36 80 00       	push   $0x803643
  802652:	e8 97 de ff ff       	call   8004ee <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802657:	83 ec 04             	sub    $0x4,%esp
  80265a:	53                   	push   %ebx
  80265b:	ff 75 0c             	pushl  0xc(%ebp)
  80265e:	68 0c 70 80 00       	push   $0x80700c
  802663:	e8 76 e6 ff ff       	call   800cde <memmove>
	nsipcbuf.send.req_size = size;
  802668:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80266e:	8b 45 14             	mov    0x14(%ebp),%eax
  802671:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802676:	b8 08 00 00 00       	mov    $0x8,%eax
  80267b:	e8 d9 fd ff ff       	call   802459 <nsipc>
}
  802680:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802683:	c9                   	leave  
  802684:	c3                   	ret    

00802685 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802685:	55                   	push   %ebp
  802686:	89 e5                	mov    %esp,%ebp
  802688:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80268b:	8b 45 08             	mov    0x8(%ebp),%eax
  80268e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802693:	8b 45 0c             	mov    0xc(%ebp),%eax
  802696:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80269b:	8b 45 10             	mov    0x10(%ebp),%eax
  80269e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8026a3:	b8 09 00 00 00       	mov    $0x9,%eax
  8026a8:	e8 ac fd ff ff       	call   802459 <nsipc>
}
  8026ad:	c9                   	leave  
  8026ae:	c3                   	ret    

008026af <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8026af:	55                   	push   %ebp
  8026b0:	89 e5                	mov    %esp,%ebp
  8026b2:	56                   	push   %esi
  8026b3:	53                   	push   %ebx
  8026b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8026b7:	83 ec 0c             	sub    $0xc,%esp
  8026ba:	ff 75 08             	pushl  0x8(%ebp)
  8026bd:	e8 dd ed ff ff       	call   80149f <fd2data>
  8026c2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8026c4:	83 c4 08             	add    $0x8,%esp
  8026c7:	68 5b 36 80 00       	push   $0x80365b
  8026cc:	53                   	push   %ebx
  8026cd:	e8 7a e4 ff ff       	call   800b4c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8026d2:	8b 46 04             	mov    0x4(%esi),%eax
  8026d5:	2b 06                	sub    (%esi),%eax
  8026d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8026dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8026e4:	00 00 00 
	stat->st_dev = &devpipe;
  8026e7:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  8026ee:	40 80 00 
	return 0;
}
  8026f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8026f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026f9:	5b                   	pop    %ebx
  8026fa:	5e                   	pop    %esi
  8026fb:	5d                   	pop    %ebp
  8026fc:	c3                   	ret    

008026fd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8026fd:	55                   	push   %ebp
  8026fe:	89 e5                	mov    %esp,%ebp
  802700:	53                   	push   %ebx
  802701:	83 ec 0c             	sub    $0xc,%esp
  802704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802707:	53                   	push   %ebx
  802708:	6a 00                	push   $0x0
  80270a:	e8 c5 e8 ff ff       	call   800fd4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80270f:	89 1c 24             	mov    %ebx,(%esp)
  802712:	e8 88 ed ff ff       	call   80149f <fd2data>
  802717:	83 c4 08             	add    $0x8,%esp
  80271a:	50                   	push   %eax
  80271b:	6a 00                	push   $0x0
  80271d:	e8 b2 e8 ff ff       	call   800fd4 <sys_page_unmap>
}
  802722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802725:	c9                   	leave  
  802726:	c3                   	ret    

00802727 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802727:	55                   	push   %ebp
  802728:	89 e5                	mov    %esp,%ebp
  80272a:	57                   	push   %edi
  80272b:	56                   	push   %esi
  80272c:	53                   	push   %ebx
  80272d:	83 ec 1c             	sub    $0x1c,%esp
  802730:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802733:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802735:	a1 08 50 80 00       	mov    0x805008,%eax
  80273a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80273d:	83 ec 0c             	sub    $0xc,%esp
  802740:	ff 75 e0             	pushl  -0x20(%ebp)
  802743:	e8 9f 04 00 00       	call   802be7 <pageref>
  802748:	89 c3                	mov    %eax,%ebx
  80274a:	89 3c 24             	mov    %edi,(%esp)
  80274d:	e8 95 04 00 00       	call   802be7 <pageref>
  802752:	83 c4 10             	add    $0x10,%esp
  802755:	39 c3                	cmp    %eax,%ebx
  802757:	0f 94 c1             	sete   %cl
  80275a:	0f b6 c9             	movzbl %cl,%ecx
  80275d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802760:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802766:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802769:	39 ce                	cmp    %ecx,%esi
  80276b:	74 1b                	je     802788 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80276d:	39 c3                	cmp    %eax,%ebx
  80276f:	75 c4                	jne    802735 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802771:	8b 42 58             	mov    0x58(%edx),%eax
  802774:	ff 75 e4             	pushl  -0x1c(%ebp)
  802777:	50                   	push   %eax
  802778:	56                   	push   %esi
  802779:	68 62 36 80 00       	push   $0x803662
  80277e:	e8 44 de ff ff       	call   8005c7 <cprintf>
  802783:	83 c4 10             	add    $0x10,%esp
  802786:	eb ad                	jmp    802735 <_pipeisclosed+0xe>
	}
}
  802788:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80278b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80278e:	5b                   	pop    %ebx
  80278f:	5e                   	pop    %esi
  802790:	5f                   	pop    %edi
  802791:	5d                   	pop    %ebp
  802792:	c3                   	ret    

00802793 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802793:	55                   	push   %ebp
  802794:	89 e5                	mov    %esp,%ebp
  802796:	57                   	push   %edi
  802797:	56                   	push   %esi
  802798:	53                   	push   %ebx
  802799:	83 ec 28             	sub    $0x28,%esp
  80279c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80279f:	56                   	push   %esi
  8027a0:	e8 fa ec ff ff       	call   80149f <fd2data>
  8027a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027a7:	83 c4 10             	add    $0x10,%esp
  8027aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8027af:	eb 4b                	jmp    8027fc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8027b1:	89 da                	mov    %ebx,%edx
  8027b3:	89 f0                	mov    %esi,%eax
  8027b5:	e8 6d ff ff ff       	call   802727 <_pipeisclosed>
  8027ba:	85 c0                	test   %eax,%eax
  8027bc:	75 48                	jne    802806 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8027be:	e8 6d e7 ff ff       	call   800f30 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8027c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8027c6:	8b 0b                	mov    (%ebx),%ecx
  8027c8:	8d 51 20             	lea    0x20(%ecx),%edx
  8027cb:	39 d0                	cmp    %edx,%eax
  8027cd:	73 e2                	jae    8027b1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8027cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027d2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8027d6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8027d9:	89 c2                	mov    %eax,%edx
  8027db:	c1 fa 1f             	sar    $0x1f,%edx
  8027de:	89 d1                	mov    %edx,%ecx
  8027e0:	c1 e9 1b             	shr    $0x1b,%ecx
  8027e3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8027e6:	83 e2 1f             	and    $0x1f,%edx
  8027e9:	29 ca                	sub    %ecx,%edx
  8027eb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8027ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8027f3:	83 c0 01             	add    $0x1,%eax
  8027f6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027f9:	83 c7 01             	add    $0x1,%edi
  8027fc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8027ff:	75 c2                	jne    8027c3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802801:	8b 45 10             	mov    0x10(%ebp),%eax
  802804:	eb 05                	jmp    80280b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802806:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80280b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80280e:	5b                   	pop    %ebx
  80280f:	5e                   	pop    %esi
  802810:	5f                   	pop    %edi
  802811:	5d                   	pop    %ebp
  802812:	c3                   	ret    

00802813 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802813:	55                   	push   %ebp
  802814:	89 e5                	mov    %esp,%ebp
  802816:	57                   	push   %edi
  802817:	56                   	push   %esi
  802818:	53                   	push   %ebx
  802819:	83 ec 18             	sub    $0x18,%esp
  80281c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80281f:	57                   	push   %edi
  802820:	e8 7a ec ff ff       	call   80149f <fd2data>
  802825:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802827:	83 c4 10             	add    $0x10,%esp
  80282a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80282f:	eb 3d                	jmp    80286e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802831:	85 db                	test   %ebx,%ebx
  802833:	74 04                	je     802839 <devpipe_read+0x26>
				return i;
  802835:	89 d8                	mov    %ebx,%eax
  802837:	eb 44                	jmp    80287d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802839:	89 f2                	mov    %esi,%edx
  80283b:	89 f8                	mov    %edi,%eax
  80283d:	e8 e5 fe ff ff       	call   802727 <_pipeisclosed>
  802842:	85 c0                	test   %eax,%eax
  802844:	75 32                	jne    802878 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802846:	e8 e5 e6 ff ff       	call   800f30 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80284b:	8b 06                	mov    (%esi),%eax
  80284d:	3b 46 04             	cmp    0x4(%esi),%eax
  802850:	74 df                	je     802831 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802852:	99                   	cltd   
  802853:	c1 ea 1b             	shr    $0x1b,%edx
  802856:	01 d0                	add    %edx,%eax
  802858:	83 e0 1f             	and    $0x1f,%eax
  80285b:	29 d0                	sub    %edx,%eax
  80285d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802865:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802868:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80286b:	83 c3 01             	add    $0x1,%ebx
  80286e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802871:	75 d8                	jne    80284b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802873:	8b 45 10             	mov    0x10(%ebp),%eax
  802876:	eb 05                	jmp    80287d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802878:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80287d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802880:	5b                   	pop    %ebx
  802881:	5e                   	pop    %esi
  802882:	5f                   	pop    %edi
  802883:	5d                   	pop    %ebp
  802884:	c3                   	ret    

00802885 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802885:	55                   	push   %ebp
  802886:	89 e5                	mov    %esp,%ebp
  802888:	56                   	push   %esi
  802889:	53                   	push   %ebx
  80288a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80288d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802890:	50                   	push   %eax
  802891:	e8 20 ec ff ff       	call   8014b6 <fd_alloc>
  802896:	83 c4 10             	add    $0x10,%esp
  802899:	89 c2                	mov    %eax,%edx
  80289b:	85 c0                	test   %eax,%eax
  80289d:	0f 88 2c 01 00 00    	js     8029cf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028a3:	83 ec 04             	sub    $0x4,%esp
  8028a6:	68 07 04 00 00       	push   $0x407
  8028ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8028ae:	6a 00                	push   $0x0
  8028b0:	e8 9a e6 ff ff       	call   800f4f <sys_page_alloc>
  8028b5:	83 c4 10             	add    $0x10,%esp
  8028b8:	89 c2                	mov    %eax,%edx
  8028ba:	85 c0                	test   %eax,%eax
  8028bc:	0f 88 0d 01 00 00    	js     8029cf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8028c2:	83 ec 0c             	sub    $0xc,%esp
  8028c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028c8:	50                   	push   %eax
  8028c9:	e8 e8 eb ff ff       	call   8014b6 <fd_alloc>
  8028ce:	89 c3                	mov    %eax,%ebx
  8028d0:	83 c4 10             	add    $0x10,%esp
  8028d3:	85 c0                	test   %eax,%eax
  8028d5:	0f 88 e2 00 00 00    	js     8029bd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028db:	83 ec 04             	sub    $0x4,%esp
  8028de:	68 07 04 00 00       	push   $0x407
  8028e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8028e6:	6a 00                	push   $0x0
  8028e8:	e8 62 e6 ff ff       	call   800f4f <sys_page_alloc>
  8028ed:	89 c3                	mov    %eax,%ebx
  8028ef:	83 c4 10             	add    $0x10,%esp
  8028f2:	85 c0                	test   %eax,%eax
  8028f4:	0f 88 c3 00 00 00    	js     8029bd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8028fa:	83 ec 0c             	sub    $0xc,%esp
  8028fd:	ff 75 f4             	pushl  -0xc(%ebp)
  802900:	e8 9a eb ff ff       	call   80149f <fd2data>
  802905:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802907:	83 c4 0c             	add    $0xc,%esp
  80290a:	68 07 04 00 00       	push   $0x407
  80290f:	50                   	push   %eax
  802910:	6a 00                	push   $0x0
  802912:	e8 38 e6 ff ff       	call   800f4f <sys_page_alloc>
  802917:	89 c3                	mov    %eax,%ebx
  802919:	83 c4 10             	add    $0x10,%esp
  80291c:	85 c0                	test   %eax,%eax
  80291e:	0f 88 89 00 00 00    	js     8029ad <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802924:	83 ec 0c             	sub    $0xc,%esp
  802927:	ff 75 f0             	pushl  -0x10(%ebp)
  80292a:	e8 70 eb ff ff       	call   80149f <fd2data>
  80292f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802936:	50                   	push   %eax
  802937:	6a 00                	push   $0x0
  802939:	56                   	push   %esi
  80293a:	6a 00                	push   $0x0
  80293c:	e8 51 e6 ff ff       	call   800f92 <sys_page_map>
  802941:	89 c3                	mov    %eax,%ebx
  802943:	83 c4 20             	add    $0x20,%esp
  802946:	85 c0                	test   %eax,%eax
  802948:	78 55                	js     80299f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80294a:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802953:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802958:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80295f:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802965:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802968:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80296a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80296d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802974:	83 ec 0c             	sub    $0xc,%esp
  802977:	ff 75 f4             	pushl  -0xc(%ebp)
  80297a:	e8 10 eb ff ff       	call   80148f <fd2num>
  80297f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802982:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802984:	83 c4 04             	add    $0x4,%esp
  802987:	ff 75 f0             	pushl  -0x10(%ebp)
  80298a:	e8 00 eb ff ff       	call   80148f <fd2num>
  80298f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802992:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802995:	83 c4 10             	add    $0x10,%esp
  802998:	ba 00 00 00 00       	mov    $0x0,%edx
  80299d:	eb 30                	jmp    8029cf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80299f:	83 ec 08             	sub    $0x8,%esp
  8029a2:	56                   	push   %esi
  8029a3:	6a 00                	push   $0x0
  8029a5:	e8 2a e6 ff ff       	call   800fd4 <sys_page_unmap>
  8029aa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8029ad:	83 ec 08             	sub    $0x8,%esp
  8029b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8029b3:	6a 00                	push   $0x0
  8029b5:	e8 1a e6 ff ff       	call   800fd4 <sys_page_unmap>
  8029ba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8029bd:	83 ec 08             	sub    $0x8,%esp
  8029c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8029c3:	6a 00                	push   $0x0
  8029c5:	e8 0a e6 ff ff       	call   800fd4 <sys_page_unmap>
  8029ca:	83 c4 10             	add    $0x10,%esp
  8029cd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8029cf:	89 d0                	mov    %edx,%eax
  8029d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029d4:	5b                   	pop    %ebx
  8029d5:	5e                   	pop    %esi
  8029d6:	5d                   	pop    %ebp
  8029d7:	c3                   	ret    

008029d8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8029d8:	55                   	push   %ebp
  8029d9:	89 e5                	mov    %esp,%ebp
  8029db:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029e1:	50                   	push   %eax
  8029e2:	ff 75 08             	pushl  0x8(%ebp)
  8029e5:	e8 1b eb ff ff       	call   801505 <fd_lookup>
  8029ea:	83 c4 10             	add    $0x10,%esp
  8029ed:	85 c0                	test   %eax,%eax
  8029ef:	78 18                	js     802a09 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8029f1:	83 ec 0c             	sub    $0xc,%esp
  8029f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8029f7:	e8 a3 ea ff ff       	call   80149f <fd2data>
	return _pipeisclosed(fd, p);
  8029fc:	89 c2                	mov    %eax,%edx
  8029fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a01:	e8 21 fd ff ff       	call   802727 <_pipeisclosed>
  802a06:	83 c4 10             	add    $0x10,%esp
}
  802a09:	c9                   	leave  
  802a0a:	c3                   	ret    

00802a0b <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802a0b:	55                   	push   %ebp
  802a0c:	89 e5                	mov    %esp,%ebp
  802a0e:	56                   	push   %esi
  802a0f:	53                   	push   %ebx
  802a10:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802a13:	85 f6                	test   %esi,%esi
  802a15:	75 16                	jne    802a2d <wait+0x22>
  802a17:	68 7a 36 80 00       	push   $0x80367a
  802a1c:	68 5b 35 80 00       	push   $0x80355b
  802a21:	6a 09                	push   $0x9
  802a23:	68 85 36 80 00       	push   $0x803685
  802a28:	e8 c1 da ff ff       	call   8004ee <_panic>
	e = &envs[ENVX(envid)];
  802a2d:	89 f3                	mov    %esi,%ebx
  802a2f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a35:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802a38:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802a3e:	eb 05                	jmp    802a45 <wait+0x3a>
		sys_yield();
  802a40:	e8 eb e4 ff ff       	call   800f30 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a45:	8b 43 48             	mov    0x48(%ebx),%eax
  802a48:	39 c6                	cmp    %eax,%esi
  802a4a:	75 07                	jne    802a53 <wait+0x48>
  802a4c:	8b 43 54             	mov    0x54(%ebx),%eax
  802a4f:	85 c0                	test   %eax,%eax
  802a51:	75 ed                	jne    802a40 <wait+0x35>
		sys_yield();
}
  802a53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a56:	5b                   	pop    %ebx
  802a57:	5e                   	pop    %esi
  802a58:	5d                   	pop    %ebp
  802a59:	c3                   	ret    

00802a5a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a5a:	55                   	push   %ebp
  802a5b:	89 e5                	mov    %esp,%ebp
  802a5d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802a60:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802a67:	75 2c                	jne    802a95 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802a69:	83 ec 04             	sub    $0x4,%esp
  802a6c:	6a 07                	push   $0x7
  802a6e:	68 00 f0 bf ee       	push   $0xeebff000
  802a73:	6a 00                	push   $0x0
  802a75:	e8 d5 e4 ff ff       	call   800f4f <sys_page_alloc>
  802a7a:	83 c4 10             	add    $0x10,%esp
  802a7d:	85 c0                	test   %eax,%eax
  802a7f:	79 14                	jns    802a95 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  802a81:	83 ec 04             	sub    $0x4,%esp
  802a84:	68 90 36 80 00       	push   $0x803690
  802a89:	6a 22                	push   $0x22
  802a8b:	68 a7 36 80 00       	push   $0x8036a7
  802a90:	e8 59 da ff ff       	call   8004ee <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  802a95:	8b 45 08             	mov    0x8(%ebp),%eax
  802a98:	a3 00 80 80 00       	mov    %eax,0x808000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802a9d:	83 ec 08             	sub    $0x8,%esp
  802aa0:	68 c9 2a 80 00       	push   $0x802ac9
  802aa5:	6a 00                	push   $0x0
  802aa7:	e8 ee e5 ff ff       	call   80109a <sys_env_set_pgfault_upcall>
  802aac:	83 c4 10             	add    $0x10,%esp
  802aaf:	85 c0                	test   %eax,%eax
  802ab1:	79 14                	jns    802ac7 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  802ab3:	83 ec 04             	sub    $0x4,%esp
  802ab6:	68 b8 36 80 00       	push   $0x8036b8
  802abb:	6a 27                	push   $0x27
  802abd:	68 a7 36 80 00       	push   $0x8036a7
  802ac2:	e8 27 da ff ff       	call   8004ee <_panic>
    
}
  802ac7:	c9                   	leave  
  802ac8:	c3                   	ret    

00802ac9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ac9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802aca:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802acf:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ad1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  802ad4:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  802ad8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  802add:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802ae1:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802ae3:	83 c4 08             	add    $0x8,%esp
	popal
  802ae6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  802ae7:	83 c4 04             	add    $0x4,%esp
	popfl
  802aea:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802aeb:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802aec:	c3                   	ret    

00802aed <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802aed:	55                   	push   %ebp
  802aee:	89 e5                	mov    %esp,%ebp
  802af0:	56                   	push   %esi
  802af1:	53                   	push   %ebx
  802af2:	8b 75 08             	mov    0x8(%ebp),%esi
  802af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  802af8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802afb:	85 c0                	test   %eax,%eax
  802afd:	74 0e                	je     802b0d <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  802aff:	83 ec 0c             	sub    $0xc,%esp
  802b02:	50                   	push   %eax
  802b03:	e8 f7 e5 ff ff       	call   8010ff <sys_ipc_recv>
  802b08:	83 c4 10             	add    $0x10,%esp
  802b0b:	eb 10                	jmp    802b1d <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802b0d:	83 ec 0c             	sub    $0xc,%esp
  802b10:	68 00 00 00 f0       	push   $0xf0000000
  802b15:	e8 e5 e5 ff ff       	call   8010ff <sys_ipc_recv>
  802b1a:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  802b1d:	85 c0                	test   %eax,%eax
  802b1f:	74 0e                	je     802b2f <ipc_recv+0x42>
    	*from_env_store = 0;
  802b21:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802b27:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  802b2d:	eb 24                	jmp    802b53 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  802b2f:	85 f6                	test   %esi,%esi
  802b31:	74 0a                	je     802b3d <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802b33:	a1 08 50 80 00       	mov    0x805008,%eax
  802b38:	8b 40 74             	mov    0x74(%eax),%eax
  802b3b:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802b3d:	85 db                	test   %ebx,%ebx
  802b3f:	74 0a                	je     802b4b <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802b41:	a1 08 50 80 00       	mov    0x805008,%eax
  802b46:	8b 40 78             	mov    0x78(%eax),%eax
  802b49:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802b4b:	a1 08 50 80 00       	mov    0x805008,%eax
  802b50:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802b53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b56:	5b                   	pop    %ebx
  802b57:	5e                   	pop    %esi
  802b58:	5d                   	pop    %ebp
  802b59:	c3                   	ret    

00802b5a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b5a:	55                   	push   %ebp
  802b5b:	89 e5                	mov    %esp,%ebp
  802b5d:	57                   	push   %edi
  802b5e:	56                   	push   %esi
  802b5f:	53                   	push   %ebx
  802b60:	83 ec 0c             	sub    $0xc,%esp
  802b63:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802b6c:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802b73:	0f 44 d8             	cmove  %eax,%ebx
  802b76:	eb 1c                	jmp    802b94 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802b78:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b7b:	74 12                	je     802b8f <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802b7d:	50                   	push   %eax
  802b7e:	68 dc 36 80 00       	push   $0x8036dc
  802b83:	6a 4b                	push   $0x4b
  802b85:	68 f4 36 80 00       	push   $0x8036f4
  802b8a:	e8 5f d9 ff ff       	call   8004ee <_panic>
        }	
        sys_yield();
  802b8f:	e8 9c e3 ff ff       	call   800f30 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802b94:	ff 75 14             	pushl  0x14(%ebp)
  802b97:	53                   	push   %ebx
  802b98:	56                   	push   %esi
  802b99:	57                   	push   %edi
  802b9a:	e8 3d e5 ff ff       	call   8010dc <sys_ipc_try_send>
  802b9f:	83 c4 10             	add    $0x10,%esp
  802ba2:	85 c0                	test   %eax,%eax
  802ba4:	75 d2                	jne    802b78 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ba9:	5b                   	pop    %ebx
  802baa:	5e                   	pop    %esi
  802bab:	5f                   	pop    %edi
  802bac:	5d                   	pop    %ebp
  802bad:	c3                   	ret    

00802bae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802bae:	55                   	push   %ebp
  802baf:	89 e5                	mov    %esp,%ebp
  802bb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802bb4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802bb9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802bbc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802bc2:	8b 52 50             	mov    0x50(%edx),%edx
  802bc5:	39 ca                	cmp    %ecx,%edx
  802bc7:	75 0d                	jne    802bd6 <ipc_find_env+0x28>
			return envs[i].env_id;
  802bc9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802bcc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802bd1:	8b 40 48             	mov    0x48(%eax),%eax
  802bd4:	eb 0f                	jmp    802be5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802bd6:	83 c0 01             	add    $0x1,%eax
  802bd9:	3d 00 04 00 00       	cmp    $0x400,%eax
  802bde:	75 d9                	jne    802bb9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802be0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802be5:	5d                   	pop    %ebp
  802be6:	c3                   	ret    

00802be7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802be7:	55                   	push   %ebp
  802be8:	89 e5                	mov    %esp,%ebp
  802bea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bed:	89 d0                	mov    %edx,%eax
  802bef:	c1 e8 16             	shr    $0x16,%eax
  802bf2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802bf9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bfe:	f6 c1 01             	test   $0x1,%cl
  802c01:	74 1d                	je     802c20 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802c03:	c1 ea 0c             	shr    $0xc,%edx
  802c06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802c0d:	f6 c2 01             	test   $0x1,%dl
  802c10:	74 0e                	je     802c20 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802c12:	c1 ea 0c             	shr    $0xc,%edx
  802c15:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802c1c:	ef 
  802c1d:	0f b7 c0             	movzwl %ax,%eax
}
  802c20:	5d                   	pop    %ebp
  802c21:	c3                   	ret    
  802c22:	66 90                	xchg   %ax,%ax
  802c24:	66 90                	xchg   %ax,%ax
  802c26:	66 90                	xchg   %ax,%ax
  802c28:	66 90                	xchg   %ax,%ax
  802c2a:	66 90                	xchg   %ax,%ax
  802c2c:	66 90                	xchg   %ax,%ax
  802c2e:	66 90                	xchg   %ax,%ax

00802c30 <__udivdi3>:
  802c30:	55                   	push   %ebp
  802c31:	57                   	push   %edi
  802c32:	56                   	push   %esi
  802c33:	53                   	push   %ebx
  802c34:	83 ec 1c             	sub    $0x1c,%esp
  802c37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802c3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802c3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c47:	85 f6                	test   %esi,%esi
  802c49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c4d:	89 ca                	mov    %ecx,%edx
  802c4f:	89 f8                	mov    %edi,%eax
  802c51:	75 3d                	jne    802c90 <__udivdi3+0x60>
  802c53:	39 cf                	cmp    %ecx,%edi
  802c55:	0f 87 c5 00 00 00    	ja     802d20 <__udivdi3+0xf0>
  802c5b:	85 ff                	test   %edi,%edi
  802c5d:	89 fd                	mov    %edi,%ebp
  802c5f:	75 0b                	jne    802c6c <__udivdi3+0x3c>
  802c61:	b8 01 00 00 00       	mov    $0x1,%eax
  802c66:	31 d2                	xor    %edx,%edx
  802c68:	f7 f7                	div    %edi
  802c6a:	89 c5                	mov    %eax,%ebp
  802c6c:	89 c8                	mov    %ecx,%eax
  802c6e:	31 d2                	xor    %edx,%edx
  802c70:	f7 f5                	div    %ebp
  802c72:	89 c1                	mov    %eax,%ecx
  802c74:	89 d8                	mov    %ebx,%eax
  802c76:	89 cf                	mov    %ecx,%edi
  802c78:	f7 f5                	div    %ebp
  802c7a:	89 c3                	mov    %eax,%ebx
  802c7c:	89 d8                	mov    %ebx,%eax
  802c7e:	89 fa                	mov    %edi,%edx
  802c80:	83 c4 1c             	add    $0x1c,%esp
  802c83:	5b                   	pop    %ebx
  802c84:	5e                   	pop    %esi
  802c85:	5f                   	pop    %edi
  802c86:	5d                   	pop    %ebp
  802c87:	c3                   	ret    
  802c88:	90                   	nop
  802c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c90:	39 ce                	cmp    %ecx,%esi
  802c92:	77 74                	ja     802d08 <__udivdi3+0xd8>
  802c94:	0f bd fe             	bsr    %esi,%edi
  802c97:	83 f7 1f             	xor    $0x1f,%edi
  802c9a:	0f 84 98 00 00 00    	je     802d38 <__udivdi3+0x108>
  802ca0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802ca5:	89 f9                	mov    %edi,%ecx
  802ca7:	89 c5                	mov    %eax,%ebp
  802ca9:	29 fb                	sub    %edi,%ebx
  802cab:	d3 e6                	shl    %cl,%esi
  802cad:	89 d9                	mov    %ebx,%ecx
  802caf:	d3 ed                	shr    %cl,%ebp
  802cb1:	89 f9                	mov    %edi,%ecx
  802cb3:	d3 e0                	shl    %cl,%eax
  802cb5:	09 ee                	or     %ebp,%esi
  802cb7:	89 d9                	mov    %ebx,%ecx
  802cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cbd:	89 d5                	mov    %edx,%ebp
  802cbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  802cc3:	d3 ed                	shr    %cl,%ebp
  802cc5:	89 f9                	mov    %edi,%ecx
  802cc7:	d3 e2                	shl    %cl,%edx
  802cc9:	89 d9                	mov    %ebx,%ecx
  802ccb:	d3 e8                	shr    %cl,%eax
  802ccd:	09 c2                	or     %eax,%edx
  802ccf:	89 d0                	mov    %edx,%eax
  802cd1:	89 ea                	mov    %ebp,%edx
  802cd3:	f7 f6                	div    %esi
  802cd5:	89 d5                	mov    %edx,%ebp
  802cd7:	89 c3                	mov    %eax,%ebx
  802cd9:	f7 64 24 0c          	mull   0xc(%esp)
  802cdd:	39 d5                	cmp    %edx,%ebp
  802cdf:	72 10                	jb     802cf1 <__udivdi3+0xc1>
  802ce1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ce5:	89 f9                	mov    %edi,%ecx
  802ce7:	d3 e6                	shl    %cl,%esi
  802ce9:	39 c6                	cmp    %eax,%esi
  802ceb:	73 07                	jae    802cf4 <__udivdi3+0xc4>
  802ced:	39 d5                	cmp    %edx,%ebp
  802cef:	75 03                	jne    802cf4 <__udivdi3+0xc4>
  802cf1:	83 eb 01             	sub    $0x1,%ebx
  802cf4:	31 ff                	xor    %edi,%edi
  802cf6:	89 d8                	mov    %ebx,%eax
  802cf8:	89 fa                	mov    %edi,%edx
  802cfa:	83 c4 1c             	add    $0x1c,%esp
  802cfd:	5b                   	pop    %ebx
  802cfe:	5e                   	pop    %esi
  802cff:	5f                   	pop    %edi
  802d00:	5d                   	pop    %ebp
  802d01:	c3                   	ret    
  802d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d08:	31 ff                	xor    %edi,%edi
  802d0a:	31 db                	xor    %ebx,%ebx
  802d0c:	89 d8                	mov    %ebx,%eax
  802d0e:	89 fa                	mov    %edi,%edx
  802d10:	83 c4 1c             	add    $0x1c,%esp
  802d13:	5b                   	pop    %ebx
  802d14:	5e                   	pop    %esi
  802d15:	5f                   	pop    %edi
  802d16:	5d                   	pop    %ebp
  802d17:	c3                   	ret    
  802d18:	90                   	nop
  802d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d20:	89 d8                	mov    %ebx,%eax
  802d22:	f7 f7                	div    %edi
  802d24:	31 ff                	xor    %edi,%edi
  802d26:	89 c3                	mov    %eax,%ebx
  802d28:	89 d8                	mov    %ebx,%eax
  802d2a:	89 fa                	mov    %edi,%edx
  802d2c:	83 c4 1c             	add    $0x1c,%esp
  802d2f:	5b                   	pop    %ebx
  802d30:	5e                   	pop    %esi
  802d31:	5f                   	pop    %edi
  802d32:	5d                   	pop    %ebp
  802d33:	c3                   	ret    
  802d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d38:	39 ce                	cmp    %ecx,%esi
  802d3a:	72 0c                	jb     802d48 <__udivdi3+0x118>
  802d3c:	31 db                	xor    %ebx,%ebx
  802d3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802d42:	0f 87 34 ff ff ff    	ja     802c7c <__udivdi3+0x4c>
  802d48:	bb 01 00 00 00       	mov    $0x1,%ebx
  802d4d:	e9 2a ff ff ff       	jmp    802c7c <__udivdi3+0x4c>
  802d52:	66 90                	xchg   %ax,%ax
  802d54:	66 90                	xchg   %ax,%ax
  802d56:	66 90                	xchg   %ax,%ax
  802d58:	66 90                	xchg   %ax,%ax
  802d5a:	66 90                	xchg   %ax,%ax
  802d5c:	66 90                	xchg   %ax,%ax
  802d5e:	66 90                	xchg   %ax,%ax

00802d60 <__umoddi3>:
  802d60:	55                   	push   %ebp
  802d61:	57                   	push   %edi
  802d62:	56                   	push   %esi
  802d63:	53                   	push   %ebx
  802d64:	83 ec 1c             	sub    $0x1c,%esp
  802d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802d6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802d6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802d77:	85 d2                	test   %edx,%edx
  802d79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d81:	89 f3                	mov    %esi,%ebx
  802d83:	89 3c 24             	mov    %edi,(%esp)
  802d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d8a:	75 1c                	jne    802da8 <__umoddi3+0x48>
  802d8c:	39 f7                	cmp    %esi,%edi
  802d8e:	76 50                	jbe    802de0 <__umoddi3+0x80>
  802d90:	89 c8                	mov    %ecx,%eax
  802d92:	89 f2                	mov    %esi,%edx
  802d94:	f7 f7                	div    %edi
  802d96:	89 d0                	mov    %edx,%eax
  802d98:	31 d2                	xor    %edx,%edx
  802d9a:	83 c4 1c             	add    $0x1c,%esp
  802d9d:	5b                   	pop    %ebx
  802d9e:	5e                   	pop    %esi
  802d9f:	5f                   	pop    %edi
  802da0:	5d                   	pop    %ebp
  802da1:	c3                   	ret    
  802da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802da8:	39 f2                	cmp    %esi,%edx
  802daa:	89 d0                	mov    %edx,%eax
  802dac:	77 52                	ja     802e00 <__umoddi3+0xa0>
  802dae:	0f bd ea             	bsr    %edx,%ebp
  802db1:	83 f5 1f             	xor    $0x1f,%ebp
  802db4:	75 5a                	jne    802e10 <__umoddi3+0xb0>
  802db6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802dba:	0f 82 e0 00 00 00    	jb     802ea0 <__umoddi3+0x140>
  802dc0:	39 0c 24             	cmp    %ecx,(%esp)
  802dc3:	0f 86 d7 00 00 00    	jbe    802ea0 <__umoddi3+0x140>
  802dc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  802dcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802dd1:	83 c4 1c             	add    $0x1c,%esp
  802dd4:	5b                   	pop    %ebx
  802dd5:	5e                   	pop    %esi
  802dd6:	5f                   	pop    %edi
  802dd7:	5d                   	pop    %ebp
  802dd8:	c3                   	ret    
  802dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802de0:	85 ff                	test   %edi,%edi
  802de2:	89 fd                	mov    %edi,%ebp
  802de4:	75 0b                	jne    802df1 <__umoddi3+0x91>
  802de6:	b8 01 00 00 00       	mov    $0x1,%eax
  802deb:	31 d2                	xor    %edx,%edx
  802ded:	f7 f7                	div    %edi
  802def:	89 c5                	mov    %eax,%ebp
  802df1:	89 f0                	mov    %esi,%eax
  802df3:	31 d2                	xor    %edx,%edx
  802df5:	f7 f5                	div    %ebp
  802df7:	89 c8                	mov    %ecx,%eax
  802df9:	f7 f5                	div    %ebp
  802dfb:	89 d0                	mov    %edx,%eax
  802dfd:	eb 99                	jmp    802d98 <__umoddi3+0x38>
  802dff:	90                   	nop
  802e00:	89 c8                	mov    %ecx,%eax
  802e02:	89 f2                	mov    %esi,%edx
  802e04:	83 c4 1c             	add    $0x1c,%esp
  802e07:	5b                   	pop    %ebx
  802e08:	5e                   	pop    %esi
  802e09:	5f                   	pop    %edi
  802e0a:	5d                   	pop    %ebp
  802e0b:	c3                   	ret    
  802e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e10:	8b 34 24             	mov    (%esp),%esi
  802e13:	bf 20 00 00 00       	mov    $0x20,%edi
  802e18:	89 e9                	mov    %ebp,%ecx
  802e1a:	29 ef                	sub    %ebp,%edi
  802e1c:	d3 e0                	shl    %cl,%eax
  802e1e:	89 f9                	mov    %edi,%ecx
  802e20:	89 f2                	mov    %esi,%edx
  802e22:	d3 ea                	shr    %cl,%edx
  802e24:	89 e9                	mov    %ebp,%ecx
  802e26:	09 c2                	or     %eax,%edx
  802e28:	89 d8                	mov    %ebx,%eax
  802e2a:	89 14 24             	mov    %edx,(%esp)
  802e2d:	89 f2                	mov    %esi,%edx
  802e2f:	d3 e2                	shl    %cl,%edx
  802e31:	89 f9                	mov    %edi,%ecx
  802e33:	89 54 24 04          	mov    %edx,0x4(%esp)
  802e37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802e3b:	d3 e8                	shr    %cl,%eax
  802e3d:	89 e9                	mov    %ebp,%ecx
  802e3f:	89 c6                	mov    %eax,%esi
  802e41:	d3 e3                	shl    %cl,%ebx
  802e43:	89 f9                	mov    %edi,%ecx
  802e45:	89 d0                	mov    %edx,%eax
  802e47:	d3 e8                	shr    %cl,%eax
  802e49:	89 e9                	mov    %ebp,%ecx
  802e4b:	09 d8                	or     %ebx,%eax
  802e4d:	89 d3                	mov    %edx,%ebx
  802e4f:	89 f2                	mov    %esi,%edx
  802e51:	f7 34 24             	divl   (%esp)
  802e54:	89 d6                	mov    %edx,%esi
  802e56:	d3 e3                	shl    %cl,%ebx
  802e58:	f7 64 24 04          	mull   0x4(%esp)
  802e5c:	39 d6                	cmp    %edx,%esi
  802e5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802e62:	89 d1                	mov    %edx,%ecx
  802e64:	89 c3                	mov    %eax,%ebx
  802e66:	72 08                	jb     802e70 <__umoddi3+0x110>
  802e68:	75 11                	jne    802e7b <__umoddi3+0x11b>
  802e6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802e6e:	73 0b                	jae    802e7b <__umoddi3+0x11b>
  802e70:	2b 44 24 04          	sub    0x4(%esp),%eax
  802e74:	1b 14 24             	sbb    (%esp),%edx
  802e77:	89 d1                	mov    %edx,%ecx
  802e79:	89 c3                	mov    %eax,%ebx
  802e7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802e7f:	29 da                	sub    %ebx,%edx
  802e81:	19 ce                	sbb    %ecx,%esi
  802e83:	89 f9                	mov    %edi,%ecx
  802e85:	89 f0                	mov    %esi,%eax
  802e87:	d3 e0                	shl    %cl,%eax
  802e89:	89 e9                	mov    %ebp,%ecx
  802e8b:	d3 ea                	shr    %cl,%edx
  802e8d:	89 e9                	mov    %ebp,%ecx
  802e8f:	d3 ee                	shr    %cl,%esi
  802e91:	09 d0                	or     %edx,%eax
  802e93:	89 f2                	mov    %esi,%edx
  802e95:	83 c4 1c             	add    $0x1c,%esp
  802e98:	5b                   	pop    %ebx
  802e99:	5e                   	pop    %esi
  802e9a:	5f                   	pop    %edi
  802e9b:	5d                   	pop    %ebp
  802e9c:	c3                   	ret    
  802e9d:	8d 76 00             	lea    0x0(%esi),%esi
  802ea0:	29 f9                	sub    %edi,%ecx
  802ea2:	19 d6                	sbb    %edx,%esi
  802ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ea8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802eac:	e9 18 ff ff ff       	jmp    802dc9 <__umoddi3+0x69>
