
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 40 2a 80 00       	push   $0x802a40
  800072:	e8 6b 04 00 00       	call   8004e2 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 40 80 00       	push   $0x804000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 08 2b 80 00       	push   $0x802b08
  8000a1:	e8 3c 04 00 00       	call   8004e2 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 4f 2a 80 00       	push   $0x802a4f
  8000b3:	e8 2a 04 00 00       	call   8004e2 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 60 80 00       	push   $0x806020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 44 2b 80 00       	push   $0x802b44
  8000dd:	e8 00 04 00 00       	call   8004e2 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 66 2a 80 00       	push   $0x802a66
  8000ef:	e8 ee 03 00 00       	call   8004e2 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 7c 2a 80 00       	push   $0x802a7c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 7c 09 00 00       	call   800a87 <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 88 2a 80 00       	push   $0x802a88
  800123:	56                   	push   %esi
  800124:	e8 5e 09 00 00       	call   800a87 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 52 09 00 00       	call   800a87 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 89 2a 80 00       	push   $0x802a89
  80013d:	56                   	push   %esi
  80013e:	e8 44 09 00 00       	call   800a87 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 8b 2a 80 00       	push   $0x802a8b
  80015d:	e8 80 03 00 00       	call   8004e2 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 8f 2a 80 00 	movl   $0x802a8f,(%esp)
  800169:	e8 74 03 00 00       	call   8004e2 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 c1 10 00 00       	call   80123b <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 a1 2a 80 00       	push   $0x802aa1
  80018c:	6a 37                	push   $0x37
  80018e:	68 ae 2a 80 00       	push   $0x802aae
  800193:	e8 71 02 00 00       	call   800409 <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 ba 2a 80 00       	push   $0x802aba
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 ae 2a 80 00       	push   $0x802aae
  8001a9:	e8 5b 02 00 00       	call   800409 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 d1 10 00 00       	call   80128b <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 d4 2a 80 00       	push   $0x802ad4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ae 2a 80 00       	push   $0x802aae
  8001ce:	e8 36 02 00 00       	call   800409 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 dc 2a 80 00       	push   $0x802adc
  8001db:	e8 02 03 00 00       	call   8004e2 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 f0 2a 80 00       	push   $0x802af0
  8001ea:	68 ef 2a 80 00       	push   $0x802aef
  8001ef:	e8 ed 1b 00 00       	call   801de1 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 f3 2a 80 00       	push   $0x802af3
  800204:	e8 d9 02 00 00       	call   8004e2 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 00 24 00 00       	call   802617 <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 73 2b 80 00       	push   $0x802b73
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 2e 08 00 00       	call   800a67 <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 82 09 00 00       	call   800bf9 <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 2d 0b 00 00       	call   800dae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 9e 0b 00 00       	call   800e4b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 1a 0b 00 00       	call   800dcc <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 c5 0a 00 00       	call   800dae <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 76 10 00 00       	call   801377 <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 e6 0d 00 00       	call   801111 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 6e 0d 00 00       	call   8010c2 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 fb 0a 00 00       	call   800e6a <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 05 0d 00 00       	call   80109b <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8003aa:	c7 05 90 77 80 00 00 	movl   $0x0,0x807790
  8003b1:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8003b4:	e8 73 0a 00 00       	call   800e2c <sys_getenvid>
  8003b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003c6:	a3 90 77 80 00       	mov    %eax,0x807790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003cb:	85 db                	test   %ebx,%ebx
  8003cd:	7e 07                	jle    8003d6 <libmain+0x37>
		binaryname = argv[0];
  8003cf:	8b 06                	mov    (%esi),%eax
  8003d1:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003d6:	83 ec 08             	sub    $0x8,%esp
  8003d9:	56                   	push   %esi
  8003da:	53                   	push   %ebx
  8003db:	e8 7e fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003e0:	e8 0a 00 00 00       	call   8003ef <exit>
}
  8003e5:	83 c4 10             	add    $0x10,%esp
  8003e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003eb:	5b                   	pop    %ebx
  8003ec:	5e                   	pop    %esi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003f5:	e8 6c 0e 00 00       	call   801266 <close_all>
	sys_env_destroy(0);
  8003fa:	83 ec 0c             	sub    $0xc,%esp
  8003fd:	6a 00                	push   $0x0
  8003ff:	e8 e7 09 00 00       	call   800deb <sys_env_destroy>
}
  800404:	83 c4 10             	add    $0x10,%esp
  800407:	c9                   	leave  
  800408:	c3                   	ret    

00800409 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	56                   	push   %esi
  80040d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80040e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800411:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  800417:	e8 10 0a 00 00       	call   800e2c <sys_getenvid>
  80041c:	83 ec 0c             	sub    $0xc,%esp
  80041f:	ff 75 0c             	pushl  0xc(%ebp)
  800422:	ff 75 08             	pushl  0x8(%ebp)
  800425:	56                   	push   %esi
  800426:	50                   	push   %eax
  800427:	68 8c 2b 80 00       	push   $0x802b8c
  80042c:	e8 b1 00 00 00       	call   8004e2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800431:	83 c4 18             	add    $0x18,%esp
  800434:	53                   	push   %ebx
  800435:	ff 75 10             	pushl  0x10(%ebp)
  800438:	e8 54 00 00 00       	call   800491 <vcprintf>
	cprintf("\n");
  80043d:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  800444:	e8 99 00 00 00       	call   8004e2 <cprintf>
  800449:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80044c:	cc                   	int3   
  80044d:	eb fd                	jmp    80044c <_panic+0x43>

0080044f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	53                   	push   %ebx
  800453:	83 ec 04             	sub    $0x4,%esp
  800456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800459:	8b 13                	mov    (%ebx),%edx
  80045b:	8d 42 01             	lea    0x1(%edx),%eax
  80045e:	89 03                	mov    %eax,(%ebx)
  800460:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800463:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800467:	3d ff 00 00 00       	cmp    $0xff,%eax
  80046c:	75 1a                	jne    800488 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	68 ff 00 00 00       	push   $0xff
  800476:	8d 43 08             	lea    0x8(%ebx),%eax
  800479:	50                   	push   %eax
  80047a:	e8 2f 09 00 00       	call   800dae <sys_cputs>
		b->idx = 0;
  80047f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800485:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800488:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80048c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80049a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004a1:	00 00 00 
	b.cnt = 0;
  8004a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004ae:	ff 75 0c             	pushl  0xc(%ebp)
  8004b1:	ff 75 08             	pushl  0x8(%ebp)
  8004b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004ba:	50                   	push   %eax
  8004bb:	68 4f 04 80 00       	push   $0x80044f
  8004c0:	e8 54 01 00 00       	call   800619 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004c5:	83 c4 08             	add    $0x8,%esp
  8004c8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004d4:	50                   	push   %eax
  8004d5:	e8 d4 08 00 00       	call   800dae <sys_cputs>

	return b.cnt;
}
  8004da:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004e0:	c9                   	leave  
  8004e1:	c3                   	ret    

008004e2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004e8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004eb:	50                   	push   %eax
  8004ec:	ff 75 08             	pushl  0x8(%ebp)
  8004ef:	e8 9d ff ff ff       	call   800491 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004f4:	c9                   	leave  
  8004f5:	c3                   	ret    

008004f6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	57                   	push   %edi
  8004fa:	56                   	push   %esi
  8004fb:	53                   	push   %ebx
  8004fc:	83 ec 1c             	sub    $0x1c,%esp
  8004ff:	89 c7                	mov    %eax,%edi
  800501:	89 d6                	mov    %edx,%esi
  800503:	8b 45 08             	mov    0x8(%ebp),%eax
  800506:	8b 55 0c             	mov    0xc(%ebp),%edx
  800509:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80050f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800512:	bb 00 00 00 00       	mov    $0x0,%ebx
  800517:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80051a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80051d:	39 d3                	cmp    %edx,%ebx
  80051f:	72 05                	jb     800526 <printnum+0x30>
  800521:	39 45 10             	cmp    %eax,0x10(%ebp)
  800524:	77 45                	ja     80056b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	ff 75 18             	pushl  0x18(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800532:	53                   	push   %ebx
  800533:	ff 75 10             	pushl  0x10(%ebp)
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 e4             	pushl  -0x1c(%ebp)
  80053c:	ff 75 e0             	pushl  -0x20(%ebp)
  80053f:	ff 75 dc             	pushl  -0x24(%ebp)
  800542:	ff 75 d8             	pushl  -0x28(%ebp)
  800545:	e8 56 22 00 00       	call   8027a0 <__udivdi3>
  80054a:	83 c4 18             	add    $0x18,%esp
  80054d:	52                   	push   %edx
  80054e:	50                   	push   %eax
  80054f:	89 f2                	mov    %esi,%edx
  800551:	89 f8                	mov    %edi,%eax
  800553:	e8 9e ff ff ff       	call   8004f6 <printnum>
  800558:	83 c4 20             	add    $0x20,%esp
  80055b:	eb 18                	jmp    800575 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	56                   	push   %esi
  800561:	ff 75 18             	pushl  0x18(%ebp)
  800564:	ff d7                	call   *%edi
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	eb 03                	jmp    80056e <printnum+0x78>
  80056b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80056e:	83 eb 01             	sub    $0x1,%ebx
  800571:	85 db                	test   %ebx,%ebx
  800573:	7f e8                	jg     80055d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	56                   	push   %esi
  800579:	83 ec 04             	sub    $0x4,%esp
  80057c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057f:	ff 75 e0             	pushl  -0x20(%ebp)
  800582:	ff 75 dc             	pushl  -0x24(%ebp)
  800585:	ff 75 d8             	pushl  -0x28(%ebp)
  800588:	e8 43 23 00 00       	call   8028d0 <__umoddi3>
  80058d:	83 c4 14             	add    $0x14,%esp
  800590:	0f be 80 af 2b 80 00 	movsbl 0x802baf(%eax),%eax
  800597:	50                   	push   %eax
  800598:	ff d7                	call   *%edi
}
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005a0:	5b                   	pop    %ebx
  8005a1:	5e                   	pop    %esi
  8005a2:	5f                   	pop    %edi
  8005a3:	5d                   	pop    %ebp
  8005a4:	c3                   	ret    

008005a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005a5:	55                   	push   %ebp
  8005a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005a8:	83 fa 01             	cmp    $0x1,%edx
  8005ab:	7e 0e                	jle    8005bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005b2:	89 08                	mov    %ecx,(%eax)
  8005b4:	8b 02                	mov    (%edx),%eax
  8005b6:	8b 52 04             	mov    0x4(%edx),%edx
  8005b9:	eb 22                	jmp    8005dd <getuint+0x38>
	else if (lflag)
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 10                	je     8005cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c4:	89 08                	mov    %ecx,(%eax)
  8005c6:	8b 02                	mov    (%edx),%eax
  8005c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005cd:	eb 0e                	jmp    8005dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005cf:	8b 10                	mov    (%eax),%edx
  8005d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d4:	89 08                	mov    %ecx,(%eax)
  8005d6:	8b 02                	mov    (%edx),%eax
  8005d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ee:	73 0a                	jae    8005fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8005f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005f3:	89 08                	mov    %ecx,(%eax)
  8005f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f8:	88 02                	mov    %al,(%edx)
}
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    

008005fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800605:	50                   	push   %eax
  800606:	ff 75 10             	pushl  0x10(%ebp)
  800609:	ff 75 0c             	pushl  0xc(%ebp)
  80060c:	ff 75 08             	pushl  0x8(%ebp)
  80060f:	e8 05 00 00 00       	call   800619 <vprintfmt>
	va_end(ap);
}
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	c9                   	leave  
  800618:	c3                   	ret    

00800619 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800619:	55                   	push   %ebp
  80061a:	89 e5                	mov    %esp,%ebp
  80061c:	57                   	push   %edi
  80061d:	56                   	push   %esi
  80061e:	53                   	push   %ebx
  80061f:	83 ec 2c             	sub    $0x2c,%esp
  800622:	8b 75 08             	mov    0x8(%ebp),%esi
  800625:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800628:	8b 7d 10             	mov    0x10(%ebp),%edi
  80062b:	eb 12                	jmp    80063f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80062d:	85 c0                	test   %eax,%eax
  80062f:	0f 84 89 03 00 00    	je     8009be <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	50                   	push   %eax
  80063a:	ff d6                	call   *%esi
  80063c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063f:	83 c7 01             	add    $0x1,%edi
  800642:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800646:	83 f8 25             	cmp    $0x25,%eax
  800649:	75 e2                	jne    80062d <vprintfmt+0x14>
  80064b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80064f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800656:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80065d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800664:	ba 00 00 00 00       	mov    $0x0,%edx
  800669:	eb 07                	jmp    800672 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80066e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8d 47 01             	lea    0x1(%edi),%eax
  800675:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800678:	0f b6 07             	movzbl (%edi),%eax
  80067b:	0f b6 c8             	movzbl %al,%ecx
  80067e:	83 e8 23             	sub    $0x23,%eax
  800681:	3c 55                	cmp    $0x55,%al
  800683:	0f 87 1a 03 00 00    	ja     8009a3 <vprintfmt+0x38a>
  800689:	0f b6 c0             	movzbl %al,%eax
  80068c:	ff 24 85 00 2d 80 00 	jmp    *0x802d00(,%eax,4)
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800696:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80069a:	eb d6                	jmp    800672 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069f:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006a7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006aa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006ae:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006b1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006b4:	83 fa 09             	cmp    $0x9,%edx
  8006b7:	77 39                	ja     8006f2 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006b9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006bc:	eb e9                	jmp    8006a7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006cf:	eb 27                	jmp    8006f8 <vprintfmt+0xdf>
  8006d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	0f 49 c8             	cmovns %eax,%ecx
  8006de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e4:	eb 8c                	jmp    800672 <vprintfmt+0x59>
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006e9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006f0:	eb 80                	jmp    800672 <vprintfmt+0x59>
  8006f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006fc:	0f 89 70 ff ff ff    	jns    800672 <vprintfmt+0x59>
				width = precision, precision = -1;
  800702:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800705:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800708:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80070f:	e9 5e ff ff ff       	jmp    800672 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800714:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80071a:	e9 53 ff ff ff       	jmp    800672 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8d 50 04             	lea    0x4(%eax),%edx
  800725:	89 55 14             	mov    %edx,0x14(%ebp)
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	ff 30                	pushl  (%eax)
  80072e:	ff d6                	call   *%esi
			break;
  800730:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800736:	e9 04 ff ff ff       	jmp    80063f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8d 50 04             	lea    0x4(%eax),%edx
  800741:	89 55 14             	mov    %edx,0x14(%ebp)
  800744:	8b 00                	mov    (%eax),%eax
  800746:	99                   	cltd   
  800747:	31 d0                	xor    %edx,%eax
  800749:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80074b:	83 f8 0f             	cmp    $0xf,%eax
  80074e:	7f 0b                	jg     80075b <vprintfmt+0x142>
  800750:	8b 14 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%edx
  800757:	85 d2                	test   %edx,%edx
  800759:	75 18                	jne    800773 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80075b:	50                   	push   %eax
  80075c:	68 c7 2b 80 00       	push   $0x802bc7
  800761:	53                   	push   %ebx
  800762:	56                   	push   %esi
  800763:	e8 94 fe ff ff       	call   8005fc <printfmt>
  800768:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80076e:	e9 cc fe ff ff       	jmp    80063f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800773:	52                   	push   %edx
  800774:	68 95 2f 80 00       	push   $0x802f95
  800779:	53                   	push   %ebx
  80077a:	56                   	push   %esi
  80077b:	e8 7c fe ff ff       	call   8005fc <printfmt>
  800780:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800783:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800786:	e9 b4 fe ff ff       	jmp    80063f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8d 50 04             	lea    0x4(%eax),%edx
  800791:	89 55 14             	mov    %edx,0x14(%ebp)
  800794:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800796:	85 ff                	test   %edi,%edi
  800798:	b8 c0 2b 80 00       	mov    $0x802bc0,%eax
  80079d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a4:	0f 8e 94 00 00 00    	jle    80083e <vprintfmt+0x225>
  8007aa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007ae:	0f 84 98 00 00 00    	je     80084c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8007ba:	57                   	push   %edi
  8007bb:	e8 86 02 00 00       	call   800a46 <strnlen>
  8007c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007c3:	29 c1                	sub    %eax,%ecx
  8007c5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007c8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007cb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007d2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007d5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d7:	eb 0f                	jmp    8007e8 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	53                   	push   %ebx
  8007dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e2:	83 ef 01             	sub    $0x1,%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	85 ff                	test   %edi,%edi
  8007ea:	7f ed                	jg     8007d9 <vprintfmt+0x1c0>
  8007ec:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007ef:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007f2:	85 c9                	test   %ecx,%ecx
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f9:	0f 49 c1             	cmovns %ecx,%eax
  8007fc:	29 c1                	sub    %eax,%ecx
  8007fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800801:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800804:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800807:	89 cb                	mov    %ecx,%ebx
  800809:	eb 4d                	jmp    800858 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80080b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80080f:	74 1b                	je     80082c <vprintfmt+0x213>
  800811:	0f be c0             	movsbl %al,%eax
  800814:	83 e8 20             	sub    $0x20,%eax
  800817:	83 f8 5e             	cmp    $0x5e,%eax
  80081a:	76 10                	jbe    80082c <vprintfmt+0x213>
					putch('?', putdat);
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	6a 3f                	push   $0x3f
  800824:	ff 55 08             	call   *0x8(%ebp)
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	eb 0d                	jmp    800839 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	ff 75 0c             	pushl  0xc(%ebp)
  800832:	52                   	push   %edx
  800833:	ff 55 08             	call   *0x8(%ebp)
  800836:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800839:	83 eb 01             	sub    $0x1,%ebx
  80083c:	eb 1a                	jmp    800858 <vprintfmt+0x23f>
  80083e:	89 75 08             	mov    %esi,0x8(%ebp)
  800841:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800844:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800847:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084a:	eb 0c                	jmp    800858 <vprintfmt+0x23f>
  80084c:	89 75 08             	mov    %esi,0x8(%ebp)
  80084f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800852:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800855:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800858:	83 c7 01             	add    $0x1,%edi
  80085b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80085f:	0f be d0             	movsbl %al,%edx
  800862:	85 d2                	test   %edx,%edx
  800864:	74 23                	je     800889 <vprintfmt+0x270>
  800866:	85 f6                	test   %esi,%esi
  800868:	78 a1                	js     80080b <vprintfmt+0x1f2>
  80086a:	83 ee 01             	sub    $0x1,%esi
  80086d:	79 9c                	jns    80080b <vprintfmt+0x1f2>
  80086f:	89 df                	mov    %ebx,%edi
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800877:	eb 18                	jmp    800891 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	53                   	push   %ebx
  80087d:	6a 20                	push   $0x20
  80087f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800881:	83 ef 01             	sub    $0x1,%edi
  800884:	83 c4 10             	add    $0x10,%esp
  800887:	eb 08                	jmp    800891 <vprintfmt+0x278>
  800889:	89 df                	mov    %ebx,%edi
  80088b:	8b 75 08             	mov    0x8(%ebp),%esi
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800891:	85 ff                	test   %edi,%edi
  800893:	7f e4                	jg     800879 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800895:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800898:	e9 a2 fd ff ff       	jmp    80063f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80089d:	83 fa 01             	cmp    $0x1,%edx
  8008a0:	7e 16                	jle    8008b8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	8d 50 08             	lea    0x8(%eax),%edx
  8008a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ab:	8b 50 04             	mov    0x4(%eax),%edx
  8008ae:	8b 00                	mov    (%eax),%eax
  8008b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b6:	eb 32                	jmp    8008ea <vprintfmt+0x2d1>
	else if (lflag)
  8008b8:	85 d2                	test   %edx,%edx
  8008ba:	74 18                	je     8008d4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8d 50 04             	lea    0x4(%eax),%edx
  8008c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c5:	8b 00                	mov    (%eax),%eax
  8008c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ca:	89 c1                	mov    %eax,%ecx
  8008cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8008cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008d2:	eb 16                	jmp    8008ea <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	8d 50 04             	lea    0x4(%eax),%edx
  8008da:	89 55 14             	mov    %edx,0x14(%ebp)
  8008dd:	8b 00                	mov    (%eax),%eax
  8008df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e2:	89 c1                	mov    %eax,%ecx
  8008e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8008e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008f9:	79 74                	jns    80096f <vprintfmt+0x356>
				putch('-', putdat);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	53                   	push   %ebx
  8008ff:	6a 2d                	push   $0x2d
  800901:	ff d6                	call   *%esi
				num = -(long long) num;
  800903:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800906:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800909:	f7 d8                	neg    %eax
  80090b:	83 d2 00             	adc    $0x0,%edx
  80090e:	f7 da                	neg    %edx
  800910:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800913:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800918:	eb 55                	jmp    80096f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80091a:	8d 45 14             	lea    0x14(%ebp),%eax
  80091d:	e8 83 fc ff ff       	call   8005a5 <getuint>
			base = 10;
  800922:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800927:	eb 46                	jmp    80096f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800929:	8d 45 14             	lea    0x14(%ebp),%eax
  80092c:	e8 74 fc ff ff       	call   8005a5 <getuint>
		        base = 8;
  800931:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800936:	eb 37                	jmp    80096f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800938:	83 ec 08             	sub    $0x8,%esp
  80093b:	53                   	push   %ebx
  80093c:	6a 30                	push   $0x30
  80093e:	ff d6                	call   *%esi
			putch('x', putdat);
  800940:	83 c4 08             	add    $0x8,%esp
  800943:	53                   	push   %ebx
  800944:	6a 78                	push   $0x78
  800946:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	8d 50 04             	lea    0x4(%eax),%edx
  80094e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800951:	8b 00                	mov    (%eax),%eax
  800953:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800958:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80095b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800960:	eb 0d                	jmp    80096f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800962:	8d 45 14             	lea    0x14(%ebp),%eax
  800965:	e8 3b fc ff ff       	call   8005a5 <getuint>
			base = 16;
  80096a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80096f:	83 ec 0c             	sub    $0xc,%esp
  800972:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800976:	57                   	push   %edi
  800977:	ff 75 e0             	pushl  -0x20(%ebp)
  80097a:	51                   	push   %ecx
  80097b:	52                   	push   %edx
  80097c:	50                   	push   %eax
  80097d:	89 da                	mov    %ebx,%edx
  80097f:	89 f0                	mov    %esi,%eax
  800981:	e8 70 fb ff ff       	call   8004f6 <printnum>
			break;
  800986:	83 c4 20             	add    $0x20,%esp
  800989:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80098c:	e9 ae fc ff ff       	jmp    80063f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800991:	83 ec 08             	sub    $0x8,%esp
  800994:	53                   	push   %ebx
  800995:	51                   	push   %ecx
  800996:	ff d6                	call   *%esi
			break;
  800998:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80099e:	e9 9c fc ff ff       	jmp    80063f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009a3:	83 ec 08             	sub    $0x8,%esp
  8009a6:	53                   	push   %ebx
  8009a7:	6a 25                	push   $0x25
  8009a9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009ab:	83 c4 10             	add    $0x10,%esp
  8009ae:	eb 03                	jmp    8009b3 <vprintfmt+0x39a>
  8009b0:	83 ef 01             	sub    $0x1,%edi
  8009b3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009b7:	75 f7                	jne    8009b0 <vprintfmt+0x397>
  8009b9:	e9 81 fc ff ff       	jmp    80063f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 18             	sub    $0x18,%esp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e3:	85 c0                	test   %eax,%eax
  8009e5:	74 26                	je     800a0d <vsnprintf+0x47>
  8009e7:	85 d2                	test   %edx,%edx
  8009e9:	7e 22                	jle    800a0d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009eb:	ff 75 14             	pushl  0x14(%ebp)
  8009ee:	ff 75 10             	pushl  0x10(%ebp)
  8009f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009f4:	50                   	push   %eax
  8009f5:	68 df 05 80 00       	push   $0x8005df
  8009fa:	e8 1a fc ff ff       	call   800619 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a02:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a08:	83 c4 10             	add    $0x10,%esp
  800a0b:	eb 05                	jmp    800a12 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a1a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a1d:	50                   	push   %eax
  800a1e:	ff 75 10             	pushl  0x10(%ebp)
  800a21:	ff 75 0c             	pushl  0xc(%ebp)
  800a24:	ff 75 08             	pushl  0x8(%ebp)
  800a27:	e8 9a ff ff ff       	call   8009c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	eb 03                	jmp    800a3e <strlen+0x10>
		n++;
  800a3b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a42:	75 f7                	jne    800a3b <strlen+0xd>
		n++;
	return n;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a54:	eb 03                	jmp    800a59 <strnlen+0x13>
		n++;
  800a56:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a59:	39 c2                	cmp    %eax,%edx
  800a5b:	74 08                	je     800a65 <strnlen+0x1f>
  800a5d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a61:	75 f3                	jne    800a56 <strnlen+0x10>
  800a63:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a71:	89 c2                	mov    %eax,%edx
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a7d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a80:	84 db                	test   %bl,%bl
  800a82:	75 ef                	jne    800a73 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a84:	5b                   	pop    %ebx
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	53                   	push   %ebx
  800a8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8e:	53                   	push   %ebx
  800a8f:	e8 9a ff ff ff       	call   800a2e <strlen>
  800a94:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a97:	ff 75 0c             	pushl  0xc(%ebp)
  800a9a:	01 d8                	add    %ebx,%eax
  800a9c:	50                   	push   %eax
  800a9d:	e8 c5 ff ff ff       	call   800a67 <strcpy>
	return dst;
}
  800aa2:	89 d8                	mov    %ebx,%eax
  800aa4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab9:	89 f2                	mov    %esi,%edx
  800abb:	eb 0f                	jmp    800acc <strncpy+0x23>
		*dst++ = *src;
  800abd:	83 c2 01             	add    $0x1,%edx
  800ac0:	0f b6 01             	movzbl (%ecx),%eax
  800ac3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac6:	80 39 01             	cmpb   $0x1,(%ecx)
  800ac9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acc:	39 da                	cmp    %ebx,%edx
  800ace:	75 ed                	jne    800abd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad0:	89 f0                	mov    %esi,%eax
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae1:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae6:	85 d2                	test   %edx,%edx
  800ae8:	74 21                	je     800b0b <strlcpy+0x35>
  800aea:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aee:	89 f2                	mov    %esi,%edx
  800af0:	eb 09                	jmp    800afb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800af2:	83 c2 01             	add    $0x1,%edx
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800afb:	39 c2                	cmp    %eax,%edx
  800afd:	74 09                	je     800b08 <strlcpy+0x32>
  800aff:	0f b6 19             	movzbl (%ecx),%ebx
  800b02:	84 db                	test   %bl,%bl
  800b04:	75 ec                	jne    800af2 <strlcpy+0x1c>
  800b06:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b08:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b0b:	29 f0                	sub    %esi,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1a:	eb 06                	jmp    800b22 <strcmp+0x11>
		p++, q++;
  800b1c:	83 c1 01             	add    $0x1,%ecx
  800b1f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b22:	0f b6 01             	movzbl (%ecx),%eax
  800b25:	84 c0                	test   %al,%al
  800b27:	74 04                	je     800b2d <strcmp+0x1c>
  800b29:	3a 02                	cmp    (%edx),%al
  800b2b:	74 ef                	je     800b1c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2d:	0f b6 c0             	movzbl %al,%eax
  800b30:	0f b6 12             	movzbl (%edx),%edx
  800b33:	29 d0                	sub    %edx,%eax
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b46:	eb 06                	jmp    800b4e <strncmp+0x17>
		n--, p++, q++;
  800b48:	83 c0 01             	add    $0x1,%eax
  800b4b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4e:	39 d8                	cmp    %ebx,%eax
  800b50:	74 15                	je     800b67 <strncmp+0x30>
  800b52:	0f b6 08             	movzbl (%eax),%ecx
  800b55:	84 c9                	test   %cl,%cl
  800b57:	74 04                	je     800b5d <strncmp+0x26>
  800b59:	3a 0a                	cmp    (%edx),%cl
  800b5b:	74 eb                	je     800b48 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5d:	0f b6 00             	movzbl (%eax),%eax
  800b60:	0f b6 12             	movzbl (%edx),%edx
  800b63:	29 d0                	sub    %edx,%eax
  800b65:	eb 05                	jmp    800b6c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b79:	eb 07                	jmp    800b82 <strchr+0x13>
		if (*s == c)
  800b7b:	38 ca                	cmp    %cl,%dl
  800b7d:	74 0f                	je     800b8e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b7f:	83 c0 01             	add    $0x1,%eax
  800b82:	0f b6 10             	movzbl (%eax),%edx
  800b85:	84 d2                	test   %dl,%dl
  800b87:	75 f2                	jne    800b7b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
  800b96:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9a:	eb 03                	jmp    800b9f <strfind+0xf>
  800b9c:	83 c0 01             	add    $0x1,%eax
  800b9f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ba2:	38 ca                	cmp    %cl,%dl
  800ba4:	74 04                	je     800baa <strfind+0x1a>
  800ba6:	84 d2                	test   %dl,%dl
  800ba8:	75 f2                	jne    800b9c <strfind+0xc>
			break;
	return (char *) s;
}
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb8:	85 c9                	test   %ecx,%ecx
  800bba:	74 36                	je     800bf2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc2:	75 28                	jne    800bec <memset+0x40>
  800bc4:	f6 c1 03             	test   $0x3,%cl
  800bc7:	75 23                	jne    800bec <memset+0x40>
		c &= 0xFF;
  800bc9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	c1 e3 08             	shl    $0x8,%ebx
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	c1 e6 18             	shl    $0x18,%esi
  800bd7:	89 d0                	mov    %edx,%eax
  800bd9:	c1 e0 10             	shl    $0x10,%eax
  800bdc:	09 f0                	or     %esi,%eax
  800bde:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800be0:	89 d8                	mov    %ebx,%eax
  800be2:	09 d0                	or     %edx,%eax
  800be4:	c1 e9 02             	shr    $0x2,%ecx
  800be7:	fc                   	cld    
  800be8:	f3 ab                	rep stos %eax,%es:(%edi)
  800bea:	eb 06                	jmp    800bf2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bef:	fc                   	cld    
  800bf0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf2:	89 f8                	mov    %edi,%eax
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c07:	39 c6                	cmp    %eax,%esi
  800c09:	73 35                	jae    800c40 <memmove+0x47>
  800c0b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c0e:	39 d0                	cmp    %edx,%eax
  800c10:	73 2e                	jae    800c40 <memmove+0x47>
		s += n;
		d += n;
  800c12:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	09 fe                	or     %edi,%esi
  800c19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c1f:	75 13                	jne    800c34 <memmove+0x3b>
  800c21:	f6 c1 03             	test   $0x3,%cl
  800c24:	75 0e                	jne    800c34 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c26:	83 ef 04             	sub    $0x4,%edi
  800c29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c2c:	c1 e9 02             	shr    $0x2,%ecx
  800c2f:	fd                   	std    
  800c30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c32:	eb 09                	jmp    800c3d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c34:	83 ef 01             	sub    $0x1,%edi
  800c37:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c3a:	fd                   	std    
  800c3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3d:	fc                   	cld    
  800c3e:	eb 1d                	jmp    800c5d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c40:	89 f2                	mov    %esi,%edx
  800c42:	09 c2                	or     %eax,%edx
  800c44:	f6 c2 03             	test   $0x3,%dl
  800c47:	75 0f                	jne    800c58 <memmove+0x5f>
  800c49:	f6 c1 03             	test   $0x3,%cl
  800c4c:	75 0a                	jne    800c58 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c4e:	c1 e9 02             	shr    $0x2,%ecx
  800c51:	89 c7                	mov    %eax,%edi
  800c53:	fc                   	cld    
  800c54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c56:	eb 05                	jmp    800c5d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c58:	89 c7                	mov    %eax,%edi
  800c5a:	fc                   	cld    
  800c5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c64:	ff 75 10             	pushl  0x10(%ebp)
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	ff 75 08             	pushl  0x8(%ebp)
  800c6d:	e8 87 ff ff ff       	call   800bf9 <memmove>
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7f:	89 c6                	mov    %eax,%esi
  800c81:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c84:	eb 1a                	jmp    800ca0 <memcmp+0x2c>
		if (*s1 != *s2)
  800c86:	0f b6 08             	movzbl (%eax),%ecx
  800c89:	0f b6 1a             	movzbl (%edx),%ebx
  800c8c:	38 d9                	cmp    %bl,%cl
  800c8e:	74 0a                	je     800c9a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c90:	0f b6 c1             	movzbl %cl,%eax
  800c93:	0f b6 db             	movzbl %bl,%ebx
  800c96:	29 d8                	sub    %ebx,%eax
  800c98:	eb 0f                	jmp    800ca9 <memcmp+0x35>
		s1++, s2++;
  800c9a:	83 c0 01             	add    $0x1,%eax
  800c9d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca0:	39 f0                	cmp    %esi,%eax
  800ca2:	75 e2                	jne    800c86 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	53                   	push   %ebx
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cb4:	89 c1                	mov    %eax,%ecx
  800cb6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbd:	eb 0a                	jmp    800cc9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cbf:	0f b6 10             	movzbl (%eax),%edx
  800cc2:	39 da                	cmp    %ebx,%edx
  800cc4:	74 07                	je     800ccd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc6:	83 c0 01             	add    $0x1,%eax
  800cc9:	39 c8                	cmp    %ecx,%eax
  800ccb:	72 f2                	jb     800cbf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdc:	eb 03                	jmp    800ce1 <strtol+0x11>
		s++;
  800cde:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce1:	0f b6 01             	movzbl (%ecx),%eax
  800ce4:	3c 20                	cmp    $0x20,%al
  800ce6:	74 f6                	je     800cde <strtol+0xe>
  800ce8:	3c 09                	cmp    $0x9,%al
  800cea:	74 f2                	je     800cde <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cec:	3c 2b                	cmp    $0x2b,%al
  800cee:	75 0a                	jne    800cfa <strtol+0x2a>
		s++;
  800cf0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cf3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf8:	eb 11                	jmp    800d0b <strtol+0x3b>
  800cfa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cff:	3c 2d                	cmp    $0x2d,%al
  800d01:	75 08                	jne    800d0b <strtol+0x3b>
		s++, neg = 1;
  800d03:	83 c1 01             	add    $0x1,%ecx
  800d06:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d0b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d11:	75 15                	jne    800d28 <strtol+0x58>
  800d13:	80 39 30             	cmpb   $0x30,(%ecx)
  800d16:	75 10                	jne    800d28 <strtol+0x58>
  800d18:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d1c:	75 7c                	jne    800d9a <strtol+0xca>
		s += 2, base = 16;
  800d1e:	83 c1 02             	add    $0x2,%ecx
  800d21:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d26:	eb 16                	jmp    800d3e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d28:	85 db                	test   %ebx,%ebx
  800d2a:	75 12                	jne    800d3e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d31:	80 39 30             	cmpb   $0x30,(%ecx)
  800d34:	75 08                	jne    800d3e <strtol+0x6e>
		s++, base = 8;
  800d36:	83 c1 01             	add    $0x1,%ecx
  800d39:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d43:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d46:	0f b6 11             	movzbl (%ecx),%edx
  800d49:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d4c:	89 f3                	mov    %esi,%ebx
  800d4e:	80 fb 09             	cmp    $0x9,%bl
  800d51:	77 08                	ja     800d5b <strtol+0x8b>
			dig = *s - '0';
  800d53:	0f be d2             	movsbl %dl,%edx
  800d56:	83 ea 30             	sub    $0x30,%edx
  800d59:	eb 22                	jmp    800d7d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d5b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d5e:	89 f3                	mov    %esi,%ebx
  800d60:	80 fb 19             	cmp    $0x19,%bl
  800d63:	77 08                	ja     800d6d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d65:	0f be d2             	movsbl %dl,%edx
  800d68:	83 ea 57             	sub    $0x57,%edx
  800d6b:	eb 10                	jmp    800d7d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d6d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d70:	89 f3                	mov    %esi,%ebx
  800d72:	80 fb 19             	cmp    $0x19,%bl
  800d75:	77 16                	ja     800d8d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d77:	0f be d2             	movsbl %dl,%edx
  800d7a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d7d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d80:	7d 0b                	jge    800d8d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d82:	83 c1 01             	add    $0x1,%ecx
  800d85:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d89:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d8b:	eb b9                	jmp    800d46 <strtol+0x76>

	if (endptr)
  800d8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d91:	74 0d                	je     800da0 <strtol+0xd0>
		*endptr = (char *) s;
  800d93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d96:	89 0e                	mov    %ecx,(%esi)
  800d98:	eb 06                	jmp    800da0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d9a:	85 db                	test   %ebx,%ebx
  800d9c:	74 98                	je     800d36 <strtol+0x66>
  800d9e:	eb 9e                	jmp    800d3e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800da0:	89 c2                	mov    %eax,%edx
  800da2:	f7 da                	neg    %edx
  800da4:	85 ff                	test   %edi,%edi
  800da6:	0f 45 c2             	cmovne %edx,%eax
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 c3                	mov    %eax,%ebx
  800dc1:	89 c7                	mov    %eax,%edi
  800dc3:	89 c6                	mov    %eax,%esi
  800dc5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_cgetc>:

int
sys_cgetc(void)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddc:	89 d1                	mov    %edx,%ecx
  800dde:	89 d3                	mov    %edx,%ebx
  800de0:	89 d7                	mov    %edx,%edi
  800de2:	89 d6                	mov    %edx,%esi
  800de4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	b8 03 00 00 00       	mov    $0x3,%eax
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 17                	jle    800e24 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	50                   	push   %eax
  800e11:	6a 03                	push   $0x3
  800e13:	68 bf 2e 80 00       	push   $0x802ebf
  800e18:	6a 23                	push   $0x23
  800e1a:	68 dc 2e 80 00       	push   $0x802edc
  800e1f:	e8 e5 f5 ff ff       	call   800409 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	ba 00 00 00 00       	mov    $0x0,%edx
  800e37:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3c:	89 d1                	mov    %edx,%ecx
  800e3e:	89 d3                	mov    %edx,%ebx
  800e40:	89 d7                	mov    %edx,%edi
  800e42:	89 d6                	mov    %edx,%esi
  800e44:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_yield>:

void
sys_yield(void)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	ba 00 00 00 00       	mov    $0x0,%edx
  800e56:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e5b:	89 d1                	mov    %edx,%ecx
  800e5d:	89 d3                	mov    %edx,%ebx
  800e5f:	89 d7                	mov    %edx,%edi
  800e61:	89 d6                	mov    %edx,%esi
  800e63:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	be 00 00 00 00       	mov    $0x0,%esi
  800e78:	b8 04 00 00 00       	mov    $0x4,%eax
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e86:	89 f7                	mov    %esi,%edi
  800e88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	7e 17                	jle    800ea5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8e:	83 ec 0c             	sub    $0xc,%esp
  800e91:	50                   	push   %eax
  800e92:	6a 04                	push   $0x4
  800e94:	68 bf 2e 80 00       	push   $0x802ebf
  800e99:	6a 23                	push   $0x23
  800e9b:	68 dc 2e 80 00       	push   $0x802edc
  800ea0:	e8 64 f5 ff ff       	call   800409 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ea5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec7:	8b 75 18             	mov    0x18(%ebp),%esi
  800eca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 17                	jle    800ee7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	50                   	push   %eax
  800ed4:	6a 05                	push   $0x5
  800ed6:	68 bf 2e 80 00       	push   $0x802ebf
  800edb:	6a 23                	push   $0x23
  800edd:	68 dc 2e 80 00       	push   $0x802edc
  800ee2:	e8 22 f5 ff ff       	call   800409 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efd:	b8 06 00 00 00       	mov    $0x6,%eax
  800f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f05:	8b 55 08             	mov    0x8(%ebp),%edx
  800f08:	89 df                	mov    %ebx,%edi
  800f0a:	89 de                	mov    %ebx,%esi
  800f0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	7e 17                	jle    800f29 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	50                   	push   %eax
  800f16:	6a 06                	push   $0x6
  800f18:	68 bf 2e 80 00       	push   $0x802ebf
  800f1d:	6a 23                	push   $0x23
  800f1f:	68 dc 2e 80 00       	push   $0x802edc
  800f24:	e8 e0 f4 ff ff       	call   800409 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3f:	b8 08 00 00 00       	mov    $0x8,%eax
  800f44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f47:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4a:	89 df                	mov    %ebx,%edi
  800f4c:	89 de                	mov    %ebx,%esi
  800f4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	7e 17                	jle    800f6b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	50                   	push   %eax
  800f58:	6a 08                	push   $0x8
  800f5a:	68 bf 2e 80 00       	push   $0x802ebf
  800f5f:	6a 23                	push   $0x23
  800f61:	68 dc 2e 80 00       	push   $0x802edc
  800f66:	e8 9e f4 ff ff       	call   800409 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f81:	b8 09 00 00 00       	mov    $0x9,%eax
  800f86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f89:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8c:	89 df                	mov    %ebx,%edi
  800f8e:	89 de                	mov    %ebx,%esi
  800f90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f92:	85 c0                	test   %eax,%eax
  800f94:	7e 17                	jle    800fad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	50                   	push   %eax
  800f9a:	6a 09                	push   $0x9
  800f9c:	68 bf 2e 80 00       	push   $0x802ebf
  800fa1:	6a 23                	push   $0x23
  800fa3:	68 dc 2e 80 00       	push   $0x802edc
  800fa8:	e8 5c f4 ff ff       	call   800409 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fce:	89 df                	mov    %ebx,%edi
  800fd0:	89 de                	mov    %ebx,%esi
  800fd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	7e 17                	jle    800fef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	50                   	push   %eax
  800fdc:	6a 0a                	push   $0xa
  800fde:	68 bf 2e 80 00       	push   $0x802ebf
  800fe3:	6a 23                	push   $0x23
  800fe5:	68 dc 2e 80 00       	push   $0x802edc
  800fea:	e8 1a f4 ff ff       	call   800409 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5f                   	pop    %edi
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffd:	be 00 00 00 00       	mov    $0x0,%esi
  801002:	b8 0c 00 00 00       	mov    $0xc,%eax
  801007:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100a:	8b 55 08             	mov    0x8(%ebp),%edx
  80100d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801010:	8b 7d 14             	mov    0x14(%ebp),%edi
  801013:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801023:	b9 00 00 00 00       	mov    $0x0,%ecx
  801028:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102d:	8b 55 08             	mov    0x8(%ebp),%edx
  801030:	89 cb                	mov    %ecx,%ebx
  801032:	89 cf                	mov    %ecx,%edi
  801034:	89 ce                	mov    %ecx,%esi
  801036:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801038:	85 c0                	test   %eax,%eax
  80103a:	7e 17                	jle    801053 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	50                   	push   %eax
  801040:	6a 0d                	push   $0xd
  801042:	68 bf 2e 80 00       	push   $0x802ebf
  801047:	6a 23                	push   $0x23
  801049:	68 dc 2e 80 00       	push   $0x802edc
  80104e:	e8 b6 f3 ff ff       	call   800409 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801053:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	ba 00 00 00 00       	mov    $0x0,%edx
  801066:	b8 0e 00 00 00       	mov    $0xe,%eax
  80106b:	89 d1                	mov    %edx,%ecx
  80106d:	89 d3                	mov    %edx,%ebx
  80106f:	89 d7                	mov    %edx,%edi
  801071:	89 d6                	mov    %edx,%esi
  801073:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801075:	5b                   	pop    %ebx
  801076:	5e                   	pop    %esi
  801077:	5f                   	pop    %edi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801080:	bb 00 00 00 00       	mov    $0x0,%ebx
  801085:	b8 0f 00 00 00       	mov    $0xf,%eax
  80108a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108d:	8b 55 08             	mov    0x8(%ebp),%edx
  801090:	89 df                	mov    %ebx,%edi
  801092:	89 de                	mov    %ebx,%esi
  801094:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  801096:	5b                   	pop    %ebx
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a6:	c1 e8 0c             	shr    $0xc,%eax
}
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010bb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	c1 ea 16             	shr    $0x16,%edx
  8010d2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d9:	f6 c2 01             	test   $0x1,%dl
  8010dc:	74 11                	je     8010ef <fd_alloc+0x2d>
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	c1 ea 0c             	shr    $0xc,%edx
  8010e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ea:	f6 c2 01             	test   $0x1,%dl
  8010ed:	75 09                	jne    8010f8 <fd_alloc+0x36>
			*fd_store = fd;
  8010ef:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f6:	eb 17                	jmp    80110f <fd_alloc+0x4d>
  8010f8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801102:	75 c9                	jne    8010cd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801104:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80110a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801117:	83 f8 1f             	cmp    $0x1f,%eax
  80111a:	77 36                	ja     801152 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80111c:	c1 e0 0c             	shl    $0xc,%eax
  80111f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801124:	89 c2                	mov    %eax,%edx
  801126:	c1 ea 16             	shr    $0x16,%edx
  801129:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801130:	f6 c2 01             	test   $0x1,%dl
  801133:	74 24                	je     801159 <fd_lookup+0x48>
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 ea 0c             	shr    $0xc,%edx
  80113a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801141:	f6 c2 01             	test   $0x1,%dl
  801144:	74 1a                	je     801160 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801146:	8b 55 0c             	mov    0xc(%ebp),%edx
  801149:	89 02                	mov    %eax,(%edx)
	return 0;
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
  801150:	eb 13                	jmp    801165 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801152:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801157:	eb 0c                	jmp    801165 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801159:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115e:	eb 05                	jmp    801165 <fd_lookup+0x54>
  801160:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801170:	ba 68 2f 80 00       	mov    $0x802f68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801175:	eb 13                	jmp    80118a <dev_lookup+0x23>
  801177:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80117a:	39 08                	cmp    %ecx,(%eax)
  80117c:	75 0c                	jne    80118a <dev_lookup+0x23>
			*dev = devtab[i];
  80117e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801181:	89 01                	mov    %eax,(%ecx)
			return 0;
  801183:	b8 00 00 00 00       	mov    $0x0,%eax
  801188:	eb 2e                	jmp    8011b8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80118a:	8b 02                	mov    (%edx),%eax
  80118c:	85 c0                	test   %eax,%eax
  80118e:	75 e7                	jne    801177 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801190:	a1 90 77 80 00       	mov    0x807790,%eax
  801195:	8b 40 48             	mov    0x48(%eax),%eax
  801198:	83 ec 04             	sub    $0x4,%esp
  80119b:	51                   	push   %ecx
  80119c:	50                   	push   %eax
  80119d:	68 ec 2e 80 00       	push   $0x802eec
  8011a2:	e8 3b f3 ff ff       	call   8004e2 <cprintf>
	*dev = 0;
  8011a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 10             	sub    $0x10,%esp
  8011c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011d2:	c1 e8 0c             	shr    $0xc,%eax
  8011d5:	50                   	push   %eax
  8011d6:	e8 36 ff ff ff       	call   801111 <fd_lookup>
  8011db:	83 c4 08             	add    $0x8,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 05                	js     8011e7 <fd_close+0x2d>
	    || fd != fd2)
  8011e2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011e5:	74 0c                	je     8011f3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011e7:	84 db                	test   %bl,%bl
  8011e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ee:	0f 44 c2             	cmove  %edx,%eax
  8011f1:	eb 41                	jmp    801234 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	ff 36                	pushl  (%esi)
  8011fc:	e8 66 ff ff ff       	call   801167 <dev_lookup>
  801201:	89 c3                	mov    %eax,%ebx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	78 1a                	js     801224 <fd_close+0x6a>
		if (dev->dev_close)
  80120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801210:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801215:	85 c0                	test   %eax,%eax
  801217:	74 0b                	je     801224 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	56                   	push   %esi
  80121d:	ff d0                	call   *%eax
  80121f:	89 c3                	mov    %eax,%ebx
  801221:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	56                   	push   %esi
  801228:	6a 00                	push   $0x0
  80122a:	e8 c0 fc ff ff       	call   800eef <sys_page_unmap>
	return r;
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	89 d8                	mov    %ebx,%eax
}
  801234:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	ff 75 08             	pushl  0x8(%ebp)
  801248:	e8 c4 fe ff ff       	call   801111 <fd_lookup>
  80124d:	83 c4 08             	add    $0x8,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 10                	js     801264 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	6a 01                	push   $0x1
  801259:	ff 75 f4             	pushl  -0xc(%ebp)
  80125c:	e8 59 ff ff ff       	call   8011ba <fd_close>
  801261:	83 c4 10             	add    $0x10,%esp
}
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <close_all>:

void
close_all(void)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80126d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801272:	83 ec 0c             	sub    $0xc,%esp
  801275:	53                   	push   %ebx
  801276:	e8 c0 ff ff ff       	call   80123b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80127b:	83 c3 01             	add    $0x1,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	83 fb 20             	cmp    $0x20,%ebx
  801284:	75 ec                	jne    801272 <close_all+0xc>
		close(i);
}
  801286:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	57                   	push   %edi
  80128f:	56                   	push   %esi
  801290:	53                   	push   %ebx
  801291:	83 ec 2c             	sub    $0x2c,%esp
  801294:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801297:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	ff 75 08             	pushl  0x8(%ebp)
  80129e:	e8 6e fe ff ff       	call   801111 <fd_lookup>
  8012a3:	83 c4 08             	add    $0x8,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	0f 88 c1 00 00 00    	js     80136f <dup+0xe4>
		return r;
	close(newfdnum);
  8012ae:	83 ec 0c             	sub    $0xc,%esp
  8012b1:	56                   	push   %esi
  8012b2:	e8 84 ff ff ff       	call   80123b <close>

	newfd = INDEX2FD(newfdnum);
  8012b7:	89 f3                	mov    %esi,%ebx
  8012b9:	c1 e3 0c             	shl    $0xc,%ebx
  8012bc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012c2:	83 c4 04             	add    $0x4,%esp
  8012c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012c8:	e8 de fd ff ff       	call   8010ab <fd2data>
  8012cd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012cf:	89 1c 24             	mov    %ebx,(%esp)
  8012d2:	e8 d4 fd ff ff       	call   8010ab <fd2data>
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012dd:	89 f8                	mov    %edi,%eax
  8012df:	c1 e8 16             	shr    $0x16,%eax
  8012e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e9:	a8 01                	test   $0x1,%al
  8012eb:	74 37                	je     801324 <dup+0x99>
  8012ed:	89 f8                	mov    %edi,%eax
  8012ef:	c1 e8 0c             	shr    $0xc,%eax
  8012f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f9:	f6 c2 01             	test   $0x1,%dl
  8012fc:	74 26                	je     801324 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	25 07 0e 00 00       	and    $0xe07,%eax
  80130d:	50                   	push   %eax
  80130e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801311:	6a 00                	push   $0x0
  801313:	57                   	push   %edi
  801314:	6a 00                	push   $0x0
  801316:	e8 92 fb ff ff       	call   800ead <sys_page_map>
  80131b:	89 c7                	mov    %eax,%edi
  80131d:	83 c4 20             	add    $0x20,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 2e                	js     801352 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801324:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801327:	89 d0                	mov    %edx,%eax
  801329:	c1 e8 0c             	shr    $0xc,%eax
  80132c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	25 07 0e 00 00       	and    $0xe07,%eax
  80133b:	50                   	push   %eax
  80133c:	53                   	push   %ebx
  80133d:	6a 00                	push   $0x0
  80133f:	52                   	push   %edx
  801340:	6a 00                	push   $0x0
  801342:	e8 66 fb ff ff       	call   800ead <sys_page_map>
  801347:	89 c7                	mov    %eax,%edi
  801349:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80134c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134e:	85 ff                	test   %edi,%edi
  801350:	79 1d                	jns    80136f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	53                   	push   %ebx
  801356:	6a 00                	push   $0x0
  801358:	e8 92 fb ff ff       	call   800eef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	ff 75 d4             	pushl  -0x2c(%ebp)
  801363:	6a 00                	push   $0x0
  801365:	e8 85 fb ff ff       	call   800eef <sys_page_unmap>
	return r;
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	89 f8                	mov    %edi,%eax
}
  80136f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 14             	sub    $0x14,%esp
  80137e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801381:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	53                   	push   %ebx
  801386:	e8 86 fd ff ff       	call   801111 <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	89 c2                	mov    %eax,%edx
  801390:	85 c0                	test   %eax,%eax
  801392:	78 6d                	js     801401 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139e:	ff 30                	pushl  (%eax)
  8013a0:	e8 c2 fd ff ff       	call   801167 <dev_lookup>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 4c                	js     8013f8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013af:	8b 42 08             	mov    0x8(%edx),%eax
  8013b2:	83 e0 03             	and    $0x3,%eax
  8013b5:	83 f8 01             	cmp    $0x1,%eax
  8013b8:	75 21                	jne    8013db <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ba:	a1 90 77 80 00       	mov    0x807790,%eax
  8013bf:	8b 40 48             	mov    0x48(%eax),%eax
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	53                   	push   %ebx
  8013c6:	50                   	push   %eax
  8013c7:	68 2d 2f 80 00       	push   $0x802f2d
  8013cc:	e8 11 f1 ff ff       	call   8004e2 <cprintf>
		return -E_INVAL;
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d9:	eb 26                	jmp    801401 <read+0x8a>
	}
	if (!dev->dev_read)
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	8b 40 08             	mov    0x8(%eax),%eax
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	74 17                	je     8013fc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013e5:	83 ec 04             	sub    $0x4,%esp
  8013e8:	ff 75 10             	pushl  0x10(%ebp)
  8013eb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ee:	52                   	push   %edx
  8013ef:	ff d0                	call   *%eax
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	eb 09                	jmp    801401 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f8:	89 c2                	mov    %eax,%edx
  8013fa:	eb 05                	jmp    801401 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801401:	89 d0                	mov    %edx,%eax
  801403:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	57                   	push   %edi
  80140c:	56                   	push   %esi
  80140d:	53                   	push   %ebx
  80140e:	83 ec 0c             	sub    $0xc,%esp
  801411:	8b 7d 08             	mov    0x8(%ebp),%edi
  801414:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801417:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141c:	eb 21                	jmp    80143f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80141e:	83 ec 04             	sub    $0x4,%esp
  801421:	89 f0                	mov    %esi,%eax
  801423:	29 d8                	sub    %ebx,%eax
  801425:	50                   	push   %eax
  801426:	89 d8                	mov    %ebx,%eax
  801428:	03 45 0c             	add    0xc(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	57                   	push   %edi
  80142d:	e8 45 ff ff ff       	call   801377 <read>
		if (m < 0)
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 10                	js     801449 <readn+0x41>
			return m;
		if (m == 0)
  801439:	85 c0                	test   %eax,%eax
  80143b:	74 0a                	je     801447 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80143d:	01 c3                	add    %eax,%ebx
  80143f:	39 f3                	cmp    %esi,%ebx
  801441:	72 db                	jb     80141e <readn+0x16>
  801443:	89 d8                	mov    %ebx,%eax
  801445:	eb 02                	jmp    801449 <readn+0x41>
  801447:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5f                   	pop    %edi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	53                   	push   %ebx
  801455:	83 ec 14             	sub    $0x14,%esp
  801458:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	53                   	push   %ebx
  801460:	e8 ac fc ff ff       	call   801111 <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	89 c2                	mov    %eax,%edx
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 68                	js     8014d6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801478:	ff 30                	pushl  (%eax)
  80147a:	e8 e8 fc ff ff       	call   801167 <dev_lookup>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 47                	js     8014cd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801486:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801489:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80148d:	75 21                	jne    8014b0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80148f:	a1 90 77 80 00       	mov    0x807790,%eax
  801494:	8b 40 48             	mov    0x48(%eax),%eax
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	53                   	push   %ebx
  80149b:	50                   	push   %eax
  80149c:	68 49 2f 80 00       	push   $0x802f49
  8014a1:	e8 3c f0 ff ff       	call   8004e2 <cprintf>
		return -E_INVAL;
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ae:	eb 26                	jmp    8014d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b6:	85 d2                	test   %edx,%edx
  8014b8:	74 17                	je     8014d1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	ff 75 10             	pushl  0x10(%ebp)
  8014c0:	ff 75 0c             	pushl  0xc(%ebp)
  8014c3:	50                   	push   %eax
  8014c4:	ff d2                	call   *%edx
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	eb 09                	jmp    8014d6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	eb 05                	jmp    8014d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014d6:	89 d0                	mov    %edx,%eax
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <seek>:

int
seek(int fdnum, off_t offset)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	e8 22 fc ff ff       	call   801111 <fd_lookup>
  8014ef:	83 c4 08             	add    $0x8,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 0e                	js     801504 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 14             	sub    $0x14,%esp
  80150d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801510:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	53                   	push   %ebx
  801515:	e8 f7 fb ff ff       	call   801111 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 65                	js     801588 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152d:	ff 30                	pushl  (%eax)
  80152f:	e8 33 fc ff ff       	call   801167 <dev_lookup>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 44                	js     80157f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801542:	75 21                	jne    801565 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801544:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801549:	8b 40 48             	mov    0x48(%eax),%eax
  80154c:	83 ec 04             	sub    $0x4,%esp
  80154f:	53                   	push   %ebx
  801550:	50                   	push   %eax
  801551:	68 0c 2f 80 00       	push   $0x802f0c
  801556:	e8 87 ef ff ff       	call   8004e2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801563:	eb 23                	jmp    801588 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801565:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801568:	8b 52 18             	mov    0x18(%edx),%edx
  80156b:	85 d2                	test   %edx,%edx
  80156d:	74 14                	je     801583 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	ff 75 0c             	pushl  0xc(%ebp)
  801575:	50                   	push   %eax
  801576:	ff d2                	call   *%edx
  801578:	89 c2                	mov    %eax,%edx
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	eb 09                	jmp    801588 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157f:	89 c2                	mov    %eax,%edx
  801581:	eb 05                	jmp    801588 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801583:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801588:	89 d0                	mov    %edx,%eax
  80158a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 14             	sub    $0x14,%esp
  801596:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801599:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 6c fb ff ff       	call   801111 <fd_lookup>
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 58                	js     801606 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b8:	ff 30                	pushl  (%eax)
  8015ba:	e8 a8 fb ff ff       	call   801167 <dev_lookup>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 37                	js     8015fd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015cd:	74 32                	je     801601 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015d9:	00 00 00 
	stat->st_isdir = 0;
  8015dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e3:	00 00 00 
	stat->st_dev = dev;
  8015e6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f3:	ff 50 14             	call   *0x14(%eax)
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	eb 09                	jmp    801606 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	eb 05                	jmp    801606 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801601:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801606:	89 d0                	mov    %edx,%eax
  801608:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160b:	c9                   	leave  
  80160c:	c3                   	ret    

0080160d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	6a 00                	push   $0x0
  801617:	ff 75 08             	pushl  0x8(%ebp)
  80161a:	e8 e7 01 00 00       	call   801806 <open>
  80161f:	89 c3                	mov    %eax,%ebx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	78 1b                	js     801643 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	50                   	push   %eax
  80162f:	e8 5b ff ff ff       	call   80158f <fstat>
  801634:	89 c6                	mov    %eax,%esi
	close(fd);
  801636:	89 1c 24             	mov    %ebx,(%esp)
  801639:	e8 fd fb ff ff       	call   80123b <close>
	return r;
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	89 f0                	mov    %esi,%eax
}
  801643:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	56                   	push   %esi
  80164e:	53                   	push   %ebx
  80164f:	89 c6                	mov    %eax,%esi
  801651:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801653:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80165a:	75 12                	jne    80166e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80165c:	83 ec 0c             	sub    $0xc,%esp
  80165f:	6a 01                	push   $0x1
  801661:	e8 c1 10 00 00       	call   802727 <ipc_find_env>
  801666:	a3 00 60 80 00       	mov    %eax,0x806000
  80166b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80166e:	6a 07                	push   $0x7
  801670:	68 00 80 80 00       	push   $0x808000
  801675:	56                   	push   %esi
  801676:	ff 35 00 60 80 00    	pushl  0x806000
  80167c:	e8 52 10 00 00       	call   8026d3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801681:	83 c4 0c             	add    $0xc,%esp
  801684:	6a 00                	push   $0x0
  801686:	53                   	push   %ebx
  801687:	6a 00                	push   $0x0
  801689:	e8 d8 0f 00 00       	call   802666 <ipc_recv>
}
  80168e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801691:	5b                   	pop    %ebx
  801692:	5e                   	pop    %esi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a1:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  8016a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a9:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b8:	e8 8d ff ff ff       	call   80164a <fsipc>
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cb:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016da:	e8 6b ff ff ff       	call   80164a <fsipc>
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 04             	sub    $0x4,%esp
  8016e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f1:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fb:	b8 05 00 00 00       	mov    $0x5,%eax
  801700:	e8 45 ff ff ff       	call   80164a <fsipc>
  801705:	85 c0                	test   %eax,%eax
  801707:	78 2c                	js     801735 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	68 00 80 80 00       	push   $0x808000
  801711:	53                   	push   %ebx
  801712:	e8 50 f3 ff ff       	call   800a67 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801717:	a1 80 80 80 00       	mov    0x808080,%eax
  80171c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801722:	a1 84 80 80 00       	mov    0x808084,%eax
  801727:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	83 ec 08             	sub    $0x8,%esp
  801741:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801744:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801749:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80174e:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801751:	53                   	push   %ebx
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	68 08 80 80 00       	push   $0x808008
  80175a:	e8 9a f4 ff ff       	call   800bf9 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80175f:	8b 45 08             	mov    0x8(%ebp),%eax
  801762:	8b 40 0c             	mov    0xc(%eax),%eax
  801765:	a3 00 80 80 00       	mov    %eax,0x808000
 	fsipcbuf.write.req_n = n;
  80176a:	89 1d 04 80 80 00    	mov    %ebx,0x808004

 	return fsipc(FSREQ_WRITE, NULL);
  801770:	ba 00 00 00 00       	mov    $0x0,%edx
  801775:	b8 04 00 00 00       	mov    $0x4,%eax
  80177a:	e8 cb fe ff ff       	call   80164a <fsipc>
	//panic("devfile_write not implemented");
}
  80177f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 40 0c             	mov    0xc(%eax),%eax
  801792:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801797:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a7:	e8 9e fe ff ff       	call   80164a <fsipc>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 4b                	js     8017fd <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b2:	39 c6                	cmp    %eax,%esi
  8017b4:	73 16                	jae    8017cc <devfile_read+0x48>
  8017b6:	68 7c 2f 80 00       	push   $0x802f7c
  8017bb:	68 83 2f 80 00       	push   $0x802f83
  8017c0:	6a 7c                	push   $0x7c
  8017c2:	68 98 2f 80 00       	push   $0x802f98
  8017c7:	e8 3d ec ff ff       	call   800409 <_panic>
	assert(r <= PGSIZE);
  8017cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d1:	7e 16                	jle    8017e9 <devfile_read+0x65>
  8017d3:	68 a3 2f 80 00       	push   $0x802fa3
  8017d8:	68 83 2f 80 00       	push   $0x802f83
  8017dd:	6a 7d                	push   $0x7d
  8017df:	68 98 2f 80 00       	push   $0x802f98
  8017e4:	e8 20 ec ff ff       	call   800409 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e9:	83 ec 04             	sub    $0x4,%esp
  8017ec:	50                   	push   %eax
  8017ed:	68 00 80 80 00       	push   $0x808000
  8017f2:	ff 75 0c             	pushl  0xc(%ebp)
  8017f5:	e8 ff f3 ff ff       	call   800bf9 <memmove>
	return r;
  8017fa:	83 c4 10             	add    $0x10,%esp
}
  8017fd:	89 d8                	mov    %ebx,%eax
  8017ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801802:	5b                   	pop    %ebx
  801803:	5e                   	pop    %esi
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	53                   	push   %ebx
  80180a:	83 ec 20             	sub    $0x20,%esp
  80180d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801810:	53                   	push   %ebx
  801811:	e8 18 f2 ff ff       	call   800a2e <strlen>
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181e:	7f 67                	jg     801887 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801826:	50                   	push   %eax
  801827:	e8 96 f8 ff ff       	call   8010c2 <fd_alloc>
  80182c:	83 c4 10             	add    $0x10,%esp
		return r;
  80182f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801831:	85 c0                	test   %eax,%eax
  801833:	78 57                	js     80188c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801835:	83 ec 08             	sub    $0x8,%esp
  801838:	53                   	push   %ebx
  801839:	68 00 80 80 00       	push   $0x808000
  80183e:	e8 24 f2 ff ff       	call   800a67 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801843:	8b 45 0c             	mov    0xc(%ebp),%eax
  801846:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80184b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184e:	b8 01 00 00 00       	mov    $0x1,%eax
  801853:	e8 f2 fd ff ff       	call   80164a <fsipc>
  801858:	89 c3                	mov    %eax,%ebx
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	79 14                	jns    801875 <open+0x6f>
		fd_close(fd, 0);
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	6a 00                	push   $0x0
  801866:	ff 75 f4             	pushl  -0xc(%ebp)
  801869:	e8 4c f9 ff ff       	call   8011ba <fd_close>
		return r;
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	89 da                	mov    %ebx,%edx
  801873:	eb 17                	jmp    80188c <open+0x86>
	}

	return fd2num(fd);
  801875:	83 ec 0c             	sub    $0xc,%esp
  801878:	ff 75 f4             	pushl  -0xc(%ebp)
  80187b:	e8 1b f8 ff ff       	call   80109b <fd2num>
  801880:	89 c2                	mov    %eax,%edx
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	eb 05                	jmp    80188c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801887:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80188c:	89 d0                	mov    %edx,%eax
  80188e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a3:	e8 a2 fd ff ff       	call   80164a <fsipc>
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	57                   	push   %edi
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018b6:	6a 00                	push   $0x0
  8018b8:	ff 75 08             	pushl  0x8(%ebp)
  8018bb:	e8 46 ff ff ff       	call   801806 <open>
  8018c0:	89 c7                	mov    %eax,%edi
  8018c2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	0f 88 a4 04 00 00    	js     801d77 <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018d3:	83 ec 04             	sub    $0x4,%esp
  8018d6:	68 00 02 00 00       	push   $0x200
  8018db:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018e1:	50                   	push   %eax
  8018e2:	57                   	push   %edi
  8018e3:	e8 20 fb ff ff       	call   801408 <readn>
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018f0:	75 0c                	jne    8018fe <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018f2:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018f9:	45 4c 46 
  8018fc:	74 33                	je     801931 <spawn+0x87>
		close(fd);
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801907:	e8 2f f9 ff ff       	call   80123b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80190c:	83 c4 0c             	add    $0xc,%esp
  80190f:	68 7f 45 4c 46       	push   $0x464c457f
  801914:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80191a:	68 af 2f 80 00       	push   $0x802faf
  80191f:	e8 be eb ff ff       	call   8004e2 <cprintf>
		return -E_NOT_EXEC;
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80192c:	e9 a6 04 00 00       	jmp    801dd7 <spawn+0x52d>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801931:	b8 07 00 00 00       	mov    $0x7,%eax
  801936:	cd 30                	int    $0x30
  801938:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80193e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801944:	85 c0                	test   %eax,%eax
  801946:	0f 88 33 04 00 00    	js     801d7f <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80194c:	89 c6                	mov    %eax,%esi
  80194e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801954:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801957:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80195d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801963:	b9 11 00 00 00       	mov    $0x11,%ecx
  801968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80196a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801970:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801976:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80197b:	be 00 00 00 00       	mov    $0x0,%esi
  801980:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801983:	eb 13                	jmp    801998 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	50                   	push   %eax
  801989:	e8 a0 f0 ff ff       	call   800a2e <strlen>
  80198e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801992:	83 c3 01             	add    $0x1,%ebx
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80199f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	75 df                	jne    801985 <spawn+0xdb>
  8019a6:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019ac:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019b2:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019b7:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019b9:	89 fa                	mov    %edi,%edx
  8019bb:	83 e2 fc             	and    $0xfffffffc,%edx
  8019be:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019c5:	29 c2                	sub    %eax,%edx
  8019c7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019cd:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019d0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019d5:	0f 86 b4 03 00 00    	jbe    801d8f <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019db:	83 ec 04             	sub    $0x4,%esp
  8019de:	6a 07                	push   $0x7
  8019e0:	68 00 00 40 00       	push   $0x400000
  8019e5:	6a 00                	push   $0x0
  8019e7:	e8 7e f4 ff ff       	call   800e6a <sys_page_alloc>
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	0f 88 9f 03 00 00    	js     801d96 <spawn+0x4ec>
  8019f7:	be 00 00 00 00       	mov    $0x0,%esi
  8019fc:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a05:	eb 30                	jmp    801a37 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a07:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a0d:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a13:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a16:	83 ec 08             	sub    $0x8,%esp
  801a19:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a1c:	57                   	push   %edi
  801a1d:	e8 45 f0 ff ff       	call   800a67 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a22:	83 c4 04             	add    $0x4,%esp
  801a25:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a28:	e8 01 f0 ff ff       	call   800a2e <strlen>
  801a2d:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a31:	83 c6 01             	add    $0x1,%esi
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a3d:	7f c8                	jg     801a07 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a3f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a45:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a4b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a52:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a58:	74 19                	je     801a73 <spawn+0x1c9>
  801a5a:	68 24 30 80 00       	push   $0x803024
  801a5f:	68 83 2f 80 00       	push   $0x802f83
  801a64:	68 f1 00 00 00       	push   $0xf1
  801a69:	68 c9 2f 80 00       	push   $0x802fc9
  801a6e:	e8 96 e9 ff ff       	call   800409 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a73:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a79:	89 f8                	mov    %edi,%eax
  801a7b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a80:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a83:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a89:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a8c:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a92:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	6a 07                	push   $0x7
  801a9d:	68 00 d0 bf ee       	push   $0xeebfd000
  801aa2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aa8:	68 00 00 40 00       	push   $0x400000
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 f9 f3 ff ff       	call   800ead <sys_page_map>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	83 c4 20             	add    $0x20,%esp
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	0f 88 04 03 00 00    	js     801dc5 <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ac1:	83 ec 08             	sub    $0x8,%esp
  801ac4:	68 00 00 40 00       	push   $0x400000
  801ac9:	6a 00                	push   $0x0
  801acb:	e8 1f f4 ff ff       	call   800eef <sys_page_unmap>
  801ad0:	89 c3                	mov    %eax,%ebx
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	0f 88 e8 02 00 00    	js     801dc5 <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801add:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ae3:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801aea:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801af0:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801af7:	00 00 00 
  801afa:	e9 88 01 00 00       	jmp    801c87 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801aff:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b05:	83 38 01             	cmpl   $0x1,(%eax)
  801b08:	0f 85 6b 01 00 00    	jne    801c79 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b0e:	89 c7                	mov    %eax,%edi
  801b10:	8b 40 18             	mov    0x18(%eax),%eax
  801b13:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b19:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b1c:	83 f8 01             	cmp    $0x1,%eax
  801b1f:	19 c0                	sbb    %eax,%eax
  801b21:	83 e0 fe             	and    $0xfffffffe,%eax
  801b24:	83 c0 07             	add    $0x7,%eax
  801b27:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b2d:	89 f8                	mov    %edi,%eax
  801b2f:	8b 7f 04             	mov    0x4(%edi),%edi
  801b32:	89 f9                	mov    %edi,%ecx
  801b34:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b3a:	8b 78 10             	mov    0x10(%eax),%edi
  801b3d:	8b 50 14             	mov    0x14(%eax),%edx
  801b40:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b46:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b49:	89 f0                	mov    %esi,%eax
  801b4b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b50:	74 14                	je     801b66 <spawn+0x2bc>
		va -= i;
  801b52:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b54:	01 c2                	add    %eax,%edx
  801b56:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b5c:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b5e:	29 c1                	sub    %eax,%ecx
  801b60:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b66:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b6b:	e9 f7 00 00 00       	jmp    801c67 <spawn+0x3bd>
		if (i >= filesz) {
  801b70:	39 df                	cmp    %ebx,%edi
  801b72:	77 27                	ja     801b9b <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b74:	83 ec 04             	sub    $0x4,%esp
  801b77:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b7d:	56                   	push   %esi
  801b7e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b84:	e8 e1 f2 ff ff       	call   800e6a <sys_page_alloc>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	0f 89 c7 00 00 00    	jns    801c5b <spawn+0x3b1>
  801b94:	89 c3                	mov    %eax,%ebx
  801b96:	e9 09 02 00 00       	jmp    801da4 <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b9b:	83 ec 04             	sub    $0x4,%esp
  801b9e:	6a 07                	push   $0x7
  801ba0:	68 00 00 40 00       	push   $0x400000
  801ba5:	6a 00                	push   $0x0
  801ba7:	e8 be f2 ff ff       	call   800e6a <sys_page_alloc>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	0f 88 e3 01 00 00    	js     801d9a <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bb7:	83 ec 08             	sub    $0x8,%esp
  801bba:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bc0:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bc6:	50                   	push   %eax
  801bc7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bcd:	e8 0b f9 ff ff       	call   8014dd <seek>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 c1 01 00 00    	js     801d9e <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bdd:	83 ec 04             	sub    $0x4,%esp
  801be0:	89 f8                	mov    %edi,%eax
  801be2:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801be8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bed:	ba 00 10 00 00       	mov    $0x1000,%edx
  801bf2:	0f 47 c2             	cmova  %edx,%eax
  801bf5:	50                   	push   %eax
  801bf6:	68 00 00 40 00       	push   $0x400000
  801bfb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c01:	e8 02 f8 ff ff       	call   801408 <readn>
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 91 01 00 00    	js     801da2 <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c1a:	56                   	push   %esi
  801c1b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c21:	68 00 00 40 00       	push   $0x400000
  801c26:	6a 00                	push   $0x0
  801c28:	e8 80 f2 ff ff       	call   800ead <sys_page_map>
  801c2d:	83 c4 20             	add    $0x20,%esp
  801c30:	85 c0                	test   %eax,%eax
  801c32:	79 15                	jns    801c49 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c34:	50                   	push   %eax
  801c35:	68 d5 2f 80 00       	push   $0x802fd5
  801c3a:	68 24 01 00 00       	push   $0x124
  801c3f:	68 c9 2f 80 00       	push   $0x802fc9
  801c44:	e8 c0 e7 ff ff       	call   800409 <_panic>
			sys_page_unmap(0, UTEMP);
  801c49:	83 ec 08             	sub    $0x8,%esp
  801c4c:	68 00 00 40 00       	push   $0x400000
  801c51:	6a 00                	push   $0x0
  801c53:	e8 97 f2 ff ff       	call   800eef <sys_page_unmap>
  801c58:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c5b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c61:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c67:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c6d:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c73:	0f 87 f7 fe ff ff    	ja     801b70 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c79:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c80:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c87:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c8e:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c94:	0f 8c 65 fe ff ff    	jl     801aff <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c9a:	83 ec 0c             	sub    $0xc,%esp
  801c9d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ca3:	e8 93 f5 ff ff       	call   80123b <close>
  801ca8:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  801cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb0:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
 	{
    	if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)) {
  801cb6:	89 d8                	mov    %ebx,%eax
  801cb8:	c1 e8 16             	shr    $0x16,%eax
  801cbb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cc2:	a8 01                	test   $0x1,%al
  801cc4:	74 46                	je     801d0c <spawn+0x462>
  801cc6:	89 d8                	mov    %ebx,%eax
  801cc8:	c1 e8 0c             	shr    $0xc,%eax
  801ccb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cd2:	f6 c2 01             	test   $0x1,%dl
  801cd5:	74 35                	je     801d0c <spawn+0x462>
  801cd7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cde:	f6 c2 04             	test   $0x4,%dl
  801ce1:	74 29                	je     801d0c <spawn+0x462>
  801ce3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cea:	f6 c6 04             	test   $0x4,%dh
  801ced:	74 1d                	je     801d0c <spawn+0x462>
        	sys_page_map(0, (void*)i, child, (void*)i, (uvpt[PGNUM(i)] & PTE_SYSCALL));
  801cef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	25 07 0e 00 00       	and    $0xe07,%eax
  801cfe:	50                   	push   %eax
  801cff:	53                   	push   %ebx
  801d00:	56                   	push   %esi
  801d01:	53                   	push   %ebx
  801d02:	6a 00                	push   $0x0
  801d04:	e8 a4 f1 ff ff       	call   800ead <sys_page_map>
  801d09:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  801d0c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d12:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d18:	75 9c                	jne    801cb6 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d1a:	83 ec 08             	sub    $0x8,%esp
  801d1d:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d23:	50                   	push   %eax
  801d24:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d2a:	e8 44 f2 ff ff       	call   800f73 <sys_env_set_trapframe>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	79 15                	jns    801d4b <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  801d36:	50                   	push   %eax
  801d37:	68 f2 2f 80 00       	push   $0x802ff2
  801d3c:	68 85 00 00 00       	push   $0x85
  801d41:	68 c9 2f 80 00       	push   $0x802fc9
  801d46:	e8 be e6 ff ff       	call   800409 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d4b:	83 ec 08             	sub    $0x8,%esp
  801d4e:	6a 02                	push   $0x2
  801d50:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d56:	e8 d6 f1 ff ff       	call   800f31 <sys_env_set_status>
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	79 25                	jns    801d87 <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  801d62:	50                   	push   %eax
  801d63:	68 0c 30 80 00       	push   $0x80300c
  801d68:	68 88 00 00 00       	push   $0x88
  801d6d:	68 c9 2f 80 00       	push   $0x802fc9
  801d72:	e8 92 e6 ff ff       	call   800409 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d77:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d7d:	eb 58                	jmp    801dd7 <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d7f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d85:	eb 50                	jmp    801dd7 <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d87:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d8d:	eb 48                	jmp    801dd7 <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d8f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d94:	eb 41                	jmp    801dd7 <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	eb 3d                	jmp    801dd7 <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	eb 06                	jmp    801da4 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d9e:	89 c3                	mov    %eax,%ebx
  801da0:	eb 02                	jmp    801da4 <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801da2:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dad:	e8 39 f0 ff ff       	call   800deb <sys_env_destroy>
	close(fd);
  801db2:	83 c4 04             	add    $0x4,%esp
  801db5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dbb:	e8 7b f4 ff ff       	call   80123b <close>
	return r;
  801dc0:	83 c4 10             	add    $0x10,%esp
  801dc3:	eb 12                	jmp    801dd7 <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dc5:	83 ec 08             	sub    $0x8,%esp
  801dc8:	68 00 00 40 00       	push   $0x400000
  801dcd:	6a 00                	push   $0x0
  801dcf:	e8 1b f1 ff ff       	call   800eef <sys_page_unmap>
  801dd4:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801dd7:	89 d8                	mov    %ebx,%eax
  801dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ddc:	5b                   	pop    %ebx
  801ddd:	5e                   	pop    %esi
  801dde:	5f                   	pop    %edi
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    

00801de1 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801de6:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801de9:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dee:	eb 03                	jmp    801df3 <spawnl+0x12>
		argc++;
  801df0:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df3:	83 c2 04             	add    $0x4,%edx
  801df6:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801dfa:	75 f4                	jne    801df0 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dfc:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e03:	83 e2 f0             	and    $0xfffffff0,%edx
  801e06:	29 d4                	sub    %edx,%esp
  801e08:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e0c:	c1 ea 02             	shr    $0x2,%edx
  801e0f:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e16:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e22:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e29:	00 
  801e2a:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e31:	eb 0a                	jmp    801e3d <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e33:	83 c0 01             	add    $0x1,%eax
  801e36:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e3a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e3d:	39 d0                	cmp    %edx,%eax
  801e3f:	75 f2                	jne    801e33 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	56                   	push   %esi
  801e45:	ff 75 08             	pushl  0x8(%ebp)
  801e48:	e8 5d fa ff ff       	call   8018aa <spawn>
}
  801e4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801e5a:	68 4c 30 80 00       	push   $0x80304c
  801e5f:	ff 75 0c             	pushl  0xc(%ebp)
  801e62:	e8 00 ec ff ff       	call   800a67 <strcpy>
	return 0;
}
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	53                   	push   %ebx
  801e72:	83 ec 10             	sub    $0x10,%esp
  801e75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e78:	53                   	push   %ebx
  801e79:	e8 e2 08 00 00       	call   802760 <pageref>
  801e7e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801e81:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801e86:	83 f8 01             	cmp    $0x1,%eax
  801e89:	75 10                	jne    801e9b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	ff 73 0c             	pushl  0xc(%ebx)
  801e91:	e8 c0 02 00 00       	call   802156 <nsipc_close>
  801e96:	89 c2                	mov    %eax,%edx
  801e98:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801e9b:	89 d0                	mov    %edx,%eax
  801e9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ea8:	6a 00                	push   $0x0
  801eaa:	ff 75 10             	pushl  0x10(%ebp)
  801ead:	ff 75 0c             	pushl  0xc(%ebp)
  801eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb3:	ff 70 0c             	pushl  0xc(%eax)
  801eb6:	e8 78 03 00 00       	call   802233 <nsipc_send>
}
  801ebb:	c9                   	leave  
  801ebc:	c3                   	ret    

00801ebd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ec3:	6a 00                	push   $0x0
  801ec5:	ff 75 10             	pushl  0x10(%ebp)
  801ec8:	ff 75 0c             	pushl  0xc(%ebp)
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ece:	ff 70 0c             	pushl  0xc(%eax)
  801ed1:	e8 f1 02 00 00       	call   8021c7 <nsipc_recv>
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ede:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ee1:	52                   	push   %edx
  801ee2:	50                   	push   %eax
  801ee3:	e8 29 f2 ff ff       	call   801111 <fd_lookup>
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 17                	js     801f06 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef2:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  801ef8:	39 08                	cmp    %ecx,(%eax)
  801efa:	75 05                	jne    801f01 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801efc:	8b 40 0c             	mov    0xc(%eax),%eax
  801eff:	eb 05                	jmp    801f06 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f01:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	56                   	push   %esi
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 1c             	sub    $0x1c,%esp
  801f10:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f15:	50                   	push   %eax
  801f16:	e8 a7 f1 ff ff       	call   8010c2 <fd_alloc>
  801f1b:	89 c3                	mov    %eax,%ebx
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 1b                	js     801f3f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f24:	83 ec 04             	sub    $0x4,%esp
  801f27:	68 07 04 00 00       	push   $0x407
  801f2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2f:	6a 00                	push   $0x0
  801f31:	e8 34 ef ff ff       	call   800e6a <sys_page_alloc>
  801f36:	89 c3                	mov    %eax,%ebx
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	79 10                	jns    801f4f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	56                   	push   %esi
  801f43:	e8 0e 02 00 00       	call   802156 <nsipc_close>
		return r;
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	89 d8                	mov    %ebx,%eax
  801f4d:	eb 24                	jmp    801f73 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f4f:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  801f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f58:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f64:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f67:	83 ec 0c             	sub    $0xc,%esp
  801f6a:	50                   	push   %eax
  801f6b:	e8 2b f1 ff ff       	call   80109b <fd2num>
  801f70:	83 c4 10             	add    $0x10,%esp
}
  801f73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5e                   	pop    %esi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f80:	8b 45 08             	mov    0x8(%ebp),%eax
  801f83:	e8 50 ff ff ff       	call   801ed8 <fd2sockid>
		return r;
  801f88:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	78 1f                	js     801fad <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f8e:	83 ec 04             	sub    $0x4,%esp
  801f91:	ff 75 10             	pushl  0x10(%ebp)
  801f94:	ff 75 0c             	pushl  0xc(%ebp)
  801f97:	50                   	push   %eax
  801f98:	e8 12 01 00 00       	call   8020af <nsipc_accept>
  801f9d:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 07                	js     801fad <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801fa6:	e8 5d ff ff ff       	call   801f08 <alloc_sockfd>
  801fab:	89 c1                	mov    %eax,%ecx
}
  801fad:	89 c8                	mov    %ecx,%eax
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    

00801fb1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fba:	e8 19 ff ff ff       	call   801ed8 <fd2sockid>
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	78 12                	js     801fd5 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801fc3:	83 ec 04             	sub    $0x4,%esp
  801fc6:	ff 75 10             	pushl  0x10(%ebp)
  801fc9:	ff 75 0c             	pushl  0xc(%ebp)
  801fcc:	50                   	push   %eax
  801fcd:	e8 2d 01 00 00       	call   8020ff <nsipc_bind>
  801fd2:	83 c4 10             	add    $0x10,%esp
}
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <shutdown>:

int
shutdown(int s, int how)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe0:	e8 f3 fe ff ff       	call   801ed8 <fd2sockid>
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	78 0f                	js     801ff8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801fe9:	83 ec 08             	sub    $0x8,%esp
  801fec:	ff 75 0c             	pushl  0xc(%ebp)
  801fef:	50                   	push   %eax
  801ff0:	e8 3f 01 00 00       	call   802134 <nsipc_shutdown>
  801ff5:	83 c4 10             	add    $0x10,%esp
}
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802000:	8b 45 08             	mov    0x8(%ebp),%eax
  802003:	e8 d0 fe ff ff       	call   801ed8 <fd2sockid>
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 12                	js     80201e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80200c:	83 ec 04             	sub    $0x4,%esp
  80200f:	ff 75 10             	pushl  0x10(%ebp)
  802012:	ff 75 0c             	pushl  0xc(%ebp)
  802015:	50                   	push   %eax
  802016:	e8 55 01 00 00       	call   802170 <nsipc_connect>
  80201b:	83 c4 10             	add    $0x10,%esp
}
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <listen>:

int
listen(int s, int backlog)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802026:	8b 45 08             	mov    0x8(%ebp),%eax
  802029:	e8 aa fe ff ff       	call   801ed8 <fd2sockid>
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 0f                	js     802041 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802032:	83 ec 08             	sub    $0x8,%esp
  802035:	ff 75 0c             	pushl  0xc(%ebp)
  802038:	50                   	push   %eax
  802039:	e8 67 01 00 00       	call   8021a5 <nsipc_listen>
  80203e:	83 c4 10             	add    $0x10,%esp
}
  802041:	c9                   	leave  
  802042:	c3                   	ret    

00802043 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802043:	55                   	push   %ebp
  802044:	89 e5                	mov    %esp,%ebp
  802046:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802049:	ff 75 10             	pushl  0x10(%ebp)
  80204c:	ff 75 0c             	pushl  0xc(%ebp)
  80204f:	ff 75 08             	pushl  0x8(%ebp)
  802052:	e8 3a 02 00 00       	call   802291 <nsipc_socket>
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	78 05                	js     802063 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80205e:	e8 a5 fe ff ff       	call   801f08 <alloc_sockfd>
}
  802063:	c9                   	leave  
  802064:	c3                   	ret    

00802065 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	53                   	push   %ebx
  802069:	83 ec 04             	sub    $0x4,%esp
  80206c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80206e:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  802075:	75 12                	jne    802089 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802077:	83 ec 0c             	sub    $0xc,%esp
  80207a:	6a 02                	push   $0x2
  80207c:	e8 a6 06 00 00       	call   802727 <ipc_find_env>
  802081:	a3 04 60 80 00       	mov    %eax,0x806004
  802086:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802089:	6a 07                	push   $0x7
  80208b:	68 00 90 80 00       	push   $0x809000
  802090:	53                   	push   %ebx
  802091:	ff 35 04 60 80 00    	pushl  0x806004
  802097:	e8 37 06 00 00       	call   8026d3 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80209c:	83 c4 0c             	add    $0xc,%esp
  80209f:	6a 00                	push   $0x0
  8020a1:	6a 00                	push   $0x0
  8020a3:	6a 00                	push   $0x0
  8020a5:	e8 bc 05 00 00       	call   802666 <ipc_recv>
}
  8020aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ba:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020bf:	8b 06                	mov    (%esi),%eax
  8020c1:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cb:	e8 95 ff ff ff       	call   802065 <nsipc>
  8020d0:	89 c3                	mov    %eax,%ebx
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	78 20                	js     8020f6 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8020d6:	83 ec 04             	sub    $0x4,%esp
  8020d9:	ff 35 10 90 80 00    	pushl  0x809010
  8020df:	68 00 90 80 00       	push   $0x809000
  8020e4:	ff 75 0c             	pushl  0xc(%ebp)
  8020e7:	e8 0d eb ff ff       	call   800bf9 <memmove>
		*addrlen = ret->ret_addrlen;
  8020ec:	a1 10 90 80 00       	mov    0x809010,%eax
  8020f1:	89 06                	mov    %eax,(%esi)
  8020f3:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fb:	5b                   	pop    %ebx
  8020fc:	5e                   	pop    %esi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	53                   	push   %ebx
  802103:	83 ec 08             	sub    $0x8,%esp
  802106:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802109:	8b 45 08             	mov    0x8(%ebp),%eax
  80210c:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802111:	53                   	push   %ebx
  802112:	ff 75 0c             	pushl  0xc(%ebp)
  802115:	68 04 90 80 00       	push   $0x809004
  80211a:	e8 da ea ff ff       	call   800bf9 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80211f:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  802125:	b8 02 00 00 00       	mov    $0x2,%eax
  80212a:	e8 36 ff ff ff       	call   802065 <nsipc>
}
  80212f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802132:	c9                   	leave  
  802133:	c3                   	ret    

00802134 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80213a:	8b 45 08             	mov    0x8(%ebp),%eax
  80213d:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  802142:	8b 45 0c             	mov    0xc(%ebp),%eax
  802145:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  80214a:	b8 03 00 00 00       	mov    $0x3,%eax
  80214f:	e8 11 ff ff ff       	call   802065 <nsipc>
}
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <nsipc_close>:

int
nsipc_close(int s)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80215c:	8b 45 08             	mov    0x8(%ebp),%eax
  80215f:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  802164:	b8 04 00 00 00       	mov    $0x4,%eax
  802169:	e8 f7 fe ff ff       	call   802065 <nsipc>
}
  80216e:	c9                   	leave  
  80216f:	c3                   	ret    

00802170 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	53                   	push   %ebx
  802174:	83 ec 08             	sub    $0x8,%esp
  802177:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80217a:	8b 45 08             	mov    0x8(%ebp),%eax
  80217d:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802182:	53                   	push   %ebx
  802183:	ff 75 0c             	pushl  0xc(%ebp)
  802186:	68 04 90 80 00       	push   $0x809004
  80218b:	e8 69 ea ff ff       	call   800bf9 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802190:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  802196:	b8 05 00 00 00       	mov    $0x5,%eax
  80219b:	e8 c5 fe ff ff       	call   802065 <nsipc>
}
  8021a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a3:	c9                   	leave  
  8021a4:	c3                   	ret    

008021a5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ae:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  8021b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b6:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  8021bb:	b8 06 00 00 00       	mov    $0x6,%eax
  8021c0:	e8 a0 fe ff ff       	call   802065 <nsipc>
}
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    

008021c7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	56                   	push   %esi
  8021cb:	53                   	push   %ebx
  8021cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d2:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  8021d7:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  8021dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e0:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021e5:	b8 07 00 00 00       	mov    $0x7,%eax
  8021ea:	e8 76 fe ff ff       	call   802065 <nsipc>
  8021ef:	89 c3                	mov    %eax,%ebx
  8021f1:	85 c0                	test   %eax,%eax
  8021f3:	78 35                	js     80222a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8021f5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8021fa:	7f 04                	jg     802200 <nsipc_recv+0x39>
  8021fc:	39 c6                	cmp    %eax,%esi
  8021fe:	7d 16                	jge    802216 <nsipc_recv+0x4f>
  802200:	68 58 30 80 00       	push   $0x803058
  802205:	68 83 2f 80 00       	push   $0x802f83
  80220a:	6a 62                	push   $0x62
  80220c:	68 6d 30 80 00       	push   $0x80306d
  802211:	e8 f3 e1 ff ff       	call   800409 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802216:	83 ec 04             	sub    $0x4,%esp
  802219:	50                   	push   %eax
  80221a:	68 00 90 80 00       	push   $0x809000
  80221f:	ff 75 0c             	pushl  0xc(%ebp)
  802222:	e8 d2 e9 ff ff       	call   800bf9 <memmove>
  802227:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80222a:	89 d8                	mov    %ebx,%eax
  80222c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    

00802233 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	53                   	push   %ebx
  802237:	83 ec 04             	sub    $0x4,%esp
  80223a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80223d:	8b 45 08             	mov    0x8(%ebp),%eax
  802240:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  802245:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80224b:	7e 16                	jle    802263 <nsipc_send+0x30>
  80224d:	68 79 30 80 00       	push   $0x803079
  802252:	68 83 2f 80 00       	push   $0x802f83
  802257:	6a 6d                	push   $0x6d
  802259:	68 6d 30 80 00       	push   $0x80306d
  80225e:	e8 a6 e1 ff ff       	call   800409 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802263:	83 ec 04             	sub    $0x4,%esp
  802266:	53                   	push   %ebx
  802267:	ff 75 0c             	pushl  0xc(%ebp)
  80226a:	68 0c 90 80 00       	push   $0x80900c
  80226f:	e8 85 e9 ff ff       	call   800bf9 <memmove>
	nsipcbuf.send.req_size = size;
  802274:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  80227a:	8b 45 14             	mov    0x14(%ebp),%eax
  80227d:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  802282:	b8 08 00 00 00       	mov    $0x8,%eax
  802287:	e8 d9 fd ff ff       	call   802065 <nsipc>
}
  80228c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80228f:	c9                   	leave  
  802290:	c3                   	ret    

00802291 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802297:	8b 45 08             	mov    0x8(%ebp),%eax
  80229a:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  80229f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a2:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  8022a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8022aa:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  8022af:	b8 09 00 00 00       	mov    $0x9,%eax
  8022b4:	e8 ac fd ff ff       	call   802065 <nsipc>
}
  8022b9:	c9                   	leave  
  8022ba:	c3                   	ret    

008022bb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	56                   	push   %esi
  8022bf:	53                   	push   %ebx
  8022c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022c3:	83 ec 0c             	sub    $0xc,%esp
  8022c6:	ff 75 08             	pushl  0x8(%ebp)
  8022c9:	e8 dd ed ff ff       	call   8010ab <fd2data>
  8022ce:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8022d0:	83 c4 08             	add    $0x8,%esp
  8022d3:	68 85 30 80 00       	push   $0x803085
  8022d8:	53                   	push   %ebx
  8022d9:	e8 89 e7 ff ff       	call   800a67 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022de:	8b 46 04             	mov    0x4(%esi),%eax
  8022e1:	2b 06                	sub    (%esi),%eax
  8022e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022f0:	00 00 00 
	stat->st_dev = &devpipe;
  8022f3:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  8022fa:	57 80 00 
	return 0;
}
  8022fd:	b8 00 00 00 00       	mov    $0x0,%eax
  802302:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802305:	5b                   	pop    %ebx
  802306:	5e                   	pop    %esi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    

00802309 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	53                   	push   %ebx
  80230d:	83 ec 0c             	sub    $0xc,%esp
  802310:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802313:	53                   	push   %ebx
  802314:	6a 00                	push   $0x0
  802316:	e8 d4 eb ff ff       	call   800eef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80231b:	89 1c 24             	mov    %ebx,(%esp)
  80231e:	e8 88 ed ff ff       	call   8010ab <fd2data>
  802323:	83 c4 08             	add    $0x8,%esp
  802326:	50                   	push   %eax
  802327:	6a 00                	push   $0x0
  802329:	e8 c1 eb ff ff       	call   800eef <sys_page_unmap>
}
  80232e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802331:	c9                   	leave  
  802332:	c3                   	ret    

00802333 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802333:	55                   	push   %ebp
  802334:	89 e5                	mov    %esp,%ebp
  802336:	57                   	push   %edi
  802337:	56                   	push   %esi
  802338:	53                   	push   %ebx
  802339:	83 ec 1c             	sub    $0x1c,%esp
  80233c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80233f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802341:	a1 90 77 80 00       	mov    0x807790,%eax
  802346:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802349:	83 ec 0c             	sub    $0xc,%esp
  80234c:	ff 75 e0             	pushl  -0x20(%ebp)
  80234f:	e8 0c 04 00 00       	call   802760 <pageref>
  802354:	89 c3                	mov    %eax,%ebx
  802356:	89 3c 24             	mov    %edi,(%esp)
  802359:	e8 02 04 00 00       	call   802760 <pageref>
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	39 c3                	cmp    %eax,%ebx
  802363:	0f 94 c1             	sete   %cl
  802366:	0f b6 c9             	movzbl %cl,%ecx
  802369:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80236c:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802372:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802375:	39 ce                	cmp    %ecx,%esi
  802377:	74 1b                	je     802394 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802379:	39 c3                	cmp    %eax,%ebx
  80237b:	75 c4                	jne    802341 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80237d:	8b 42 58             	mov    0x58(%edx),%eax
  802380:	ff 75 e4             	pushl  -0x1c(%ebp)
  802383:	50                   	push   %eax
  802384:	56                   	push   %esi
  802385:	68 8c 30 80 00       	push   $0x80308c
  80238a:	e8 53 e1 ff ff       	call   8004e2 <cprintf>
  80238f:	83 c4 10             	add    $0x10,%esp
  802392:	eb ad                	jmp    802341 <_pipeisclosed+0xe>
	}
}
  802394:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802397:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239a:	5b                   	pop    %ebx
  80239b:	5e                   	pop    %esi
  80239c:	5f                   	pop    %edi
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    

0080239f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	57                   	push   %edi
  8023a3:	56                   	push   %esi
  8023a4:	53                   	push   %ebx
  8023a5:	83 ec 28             	sub    $0x28,%esp
  8023a8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023ab:	56                   	push   %esi
  8023ac:	e8 fa ec ff ff       	call   8010ab <fd2data>
  8023b1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023b3:	83 c4 10             	add    $0x10,%esp
  8023b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8023bb:	eb 4b                	jmp    802408 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8023bd:	89 da                	mov    %ebx,%edx
  8023bf:	89 f0                	mov    %esi,%eax
  8023c1:	e8 6d ff ff ff       	call   802333 <_pipeisclosed>
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	75 48                	jne    802412 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8023ca:	e8 7c ea ff ff       	call   800e4b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023cf:	8b 43 04             	mov    0x4(%ebx),%eax
  8023d2:	8b 0b                	mov    (%ebx),%ecx
  8023d4:	8d 51 20             	lea    0x20(%ecx),%edx
  8023d7:	39 d0                	cmp    %edx,%eax
  8023d9:	73 e2                	jae    8023bd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023de:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023e2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023e5:	89 c2                	mov    %eax,%edx
  8023e7:	c1 fa 1f             	sar    $0x1f,%edx
  8023ea:	89 d1                	mov    %edx,%ecx
  8023ec:	c1 e9 1b             	shr    $0x1b,%ecx
  8023ef:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8023f2:	83 e2 1f             	and    $0x1f,%edx
  8023f5:	29 ca                	sub    %ecx,%edx
  8023f7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8023fb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8023ff:	83 c0 01             	add    $0x1,%eax
  802402:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802405:	83 c7 01             	add    $0x1,%edi
  802408:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80240b:	75 c2                	jne    8023cf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80240d:	8b 45 10             	mov    0x10(%ebp),%eax
  802410:	eb 05                	jmp    802417 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802412:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802417:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80241a:	5b                   	pop    %ebx
  80241b:	5e                   	pop    %esi
  80241c:	5f                   	pop    %edi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    

0080241f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80241f:	55                   	push   %ebp
  802420:	89 e5                	mov    %esp,%ebp
  802422:	57                   	push   %edi
  802423:	56                   	push   %esi
  802424:	53                   	push   %ebx
  802425:	83 ec 18             	sub    $0x18,%esp
  802428:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80242b:	57                   	push   %edi
  80242c:	e8 7a ec ff ff       	call   8010ab <fd2data>
  802431:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802433:	83 c4 10             	add    $0x10,%esp
  802436:	bb 00 00 00 00       	mov    $0x0,%ebx
  80243b:	eb 3d                	jmp    80247a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80243d:	85 db                	test   %ebx,%ebx
  80243f:	74 04                	je     802445 <devpipe_read+0x26>
				return i;
  802441:	89 d8                	mov    %ebx,%eax
  802443:	eb 44                	jmp    802489 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802445:	89 f2                	mov    %esi,%edx
  802447:	89 f8                	mov    %edi,%eax
  802449:	e8 e5 fe ff ff       	call   802333 <_pipeisclosed>
  80244e:	85 c0                	test   %eax,%eax
  802450:	75 32                	jne    802484 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802452:	e8 f4 e9 ff ff       	call   800e4b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802457:	8b 06                	mov    (%esi),%eax
  802459:	3b 46 04             	cmp    0x4(%esi),%eax
  80245c:	74 df                	je     80243d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80245e:	99                   	cltd   
  80245f:	c1 ea 1b             	shr    $0x1b,%edx
  802462:	01 d0                	add    %edx,%eax
  802464:	83 e0 1f             	and    $0x1f,%eax
  802467:	29 d0                	sub    %edx,%eax
  802469:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80246e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802471:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802474:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802477:	83 c3 01             	add    $0x1,%ebx
  80247a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80247d:	75 d8                	jne    802457 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80247f:	8b 45 10             	mov    0x10(%ebp),%eax
  802482:	eb 05                	jmp    802489 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802484:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802489:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80248c:	5b                   	pop    %ebx
  80248d:	5e                   	pop    %esi
  80248e:	5f                   	pop    %edi
  80248f:	5d                   	pop    %ebp
  802490:	c3                   	ret    

00802491 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802491:	55                   	push   %ebp
  802492:	89 e5                	mov    %esp,%ebp
  802494:	56                   	push   %esi
  802495:	53                   	push   %ebx
  802496:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80249c:	50                   	push   %eax
  80249d:	e8 20 ec ff ff       	call   8010c2 <fd_alloc>
  8024a2:	83 c4 10             	add    $0x10,%esp
  8024a5:	89 c2                	mov    %eax,%edx
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	0f 88 2c 01 00 00    	js     8025db <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024af:	83 ec 04             	sub    $0x4,%esp
  8024b2:	68 07 04 00 00       	push   $0x407
  8024b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8024ba:	6a 00                	push   $0x0
  8024bc:	e8 a9 e9 ff ff       	call   800e6a <sys_page_alloc>
  8024c1:	83 c4 10             	add    $0x10,%esp
  8024c4:	89 c2                	mov    %eax,%edx
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	0f 88 0d 01 00 00    	js     8025db <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8024ce:	83 ec 0c             	sub    $0xc,%esp
  8024d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8024d4:	50                   	push   %eax
  8024d5:	e8 e8 eb ff ff       	call   8010c2 <fd_alloc>
  8024da:	89 c3                	mov    %eax,%ebx
  8024dc:	83 c4 10             	add    $0x10,%esp
  8024df:	85 c0                	test   %eax,%eax
  8024e1:	0f 88 e2 00 00 00    	js     8025c9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024e7:	83 ec 04             	sub    $0x4,%esp
  8024ea:	68 07 04 00 00       	push   $0x407
  8024ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8024f2:	6a 00                	push   $0x0
  8024f4:	e8 71 e9 ff ff       	call   800e6a <sys_page_alloc>
  8024f9:	89 c3                	mov    %eax,%ebx
  8024fb:	83 c4 10             	add    $0x10,%esp
  8024fe:	85 c0                	test   %eax,%eax
  802500:	0f 88 c3 00 00 00    	js     8025c9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802506:	83 ec 0c             	sub    $0xc,%esp
  802509:	ff 75 f4             	pushl  -0xc(%ebp)
  80250c:	e8 9a eb ff ff       	call   8010ab <fd2data>
  802511:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802513:	83 c4 0c             	add    $0xc,%esp
  802516:	68 07 04 00 00       	push   $0x407
  80251b:	50                   	push   %eax
  80251c:	6a 00                	push   $0x0
  80251e:	e8 47 e9 ff ff       	call   800e6a <sys_page_alloc>
  802523:	89 c3                	mov    %eax,%ebx
  802525:	83 c4 10             	add    $0x10,%esp
  802528:	85 c0                	test   %eax,%eax
  80252a:	0f 88 89 00 00 00    	js     8025b9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802530:	83 ec 0c             	sub    $0xc,%esp
  802533:	ff 75 f0             	pushl  -0x10(%ebp)
  802536:	e8 70 eb ff ff       	call   8010ab <fd2data>
  80253b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802542:	50                   	push   %eax
  802543:	6a 00                	push   $0x0
  802545:	56                   	push   %esi
  802546:	6a 00                	push   $0x0
  802548:	e8 60 e9 ff ff       	call   800ead <sys_page_map>
  80254d:	89 c3                	mov    %eax,%ebx
  80254f:	83 c4 20             	add    $0x20,%esp
  802552:	85 c0                	test   %eax,%eax
  802554:	78 55                	js     8025ab <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802556:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  80255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802564:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80256b:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  802571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802574:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802576:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802579:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802580:	83 ec 0c             	sub    $0xc,%esp
  802583:	ff 75 f4             	pushl  -0xc(%ebp)
  802586:	e8 10 eb ff ff       	call   80109b <fd2num>
  80258b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80258e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802590:	83 c4 04             	add    $0x4,%esp
  802593:	ff 75 f0             	pushl  -0x10(%ebp)
  802596:	e8 00 eb ff ff       	call   80109b <fd2num>
  80259b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80259e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8025a1:	83 c4 10             	add    $0x10,%esp
  8025a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8025a9:	eb 30                	jmp    8025db <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8025ab:	83 ec 08             	sub    $0x8,%esp
  8025ae:	56                   	push   %esi
  8025af:	6a 00                	push   $0x0
  8025b1:	e8 39 e9 ff ff       	call   800eef <sys_page_unmap>
  8025b6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8025b9:	83 ec 08             	sub    $0x8,%esp
  8025bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8025bf:	6a 00                	push   $0x0
  8025c1:	e8 29 e9 ff ff       	call   800eef <sys_page_unmap>
  8025c6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8025c9:	83 ec 08             	sub    $0x8,%esp
  8025cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8025cf:	6a 00                	push   $0x0
  8025d1:	e8 19 e9 ff ff       	call   800eef <sys_page_unmap>
  8025d6:	83 c4 10             	add    $0x10,%esp
  8025d9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025e0:	5b                   	pop    %ebx
  8025e1:	5e                   	pop    %esi
  8025e2:	5d                   	pop    %ebp
  8025e3:	c3                   	ret    

008025e4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025e4:	55                   	push   %ebp
  8025e5:	89 e5                	mov    %esp,%ebp
  8025e7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ed:	50                   	push   %eax
  8025ee:	ff 75 08             	pushl  0x8(%ebp)
  8025f1:	e8 1b eb ff ff       	call   801111 <fd_lookup>
  8025f6:	83 c4 10             	add    $0x10,%esp
  8025f9:	85 c0                	test   %eax,%eax
  8025fb:	78 18                	js     802615 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025fd:	83 ec 0c             	sub    $0xc,%esp
  802600:	ff 75 f4             	pushl  -0xc(%ebp)
  802603:	e8 a3 ea ff ff       	call   8010ab <fd2data>
	return _pipeisclosed(fd, p);
  802608:	89 c2                	mov    %eax,%edx
  80260a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260d:	e8 21 fd ff ff       	call   802333 <_pipeisclosed>
  802612:	83 c4 10             	add    $0x10,%esp
}
  802615:	c9                   	leave  
  802616:	c3                   	ret    

00802617 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802617:	55                   	push   %ebp
  802618:	89 e5                	mov    %esp,%ebp
  80261a:	56                   	push   %esi
  80261b:	53                   	push   %ebx
  80261c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80261f:	85 f6                	test   %esi,%esi
  802621:	75 16                	jne    802639 <wait+0x22>
  802623:	68 a4 30 80 00       	push   $0x8030a4
  802628:	68 83 2f 80 00       	push   $0x802f83
  80262d:	6a 09                	push   $0x9
  80262f:	68 af 30 80 00       	push   $0x8030af
  802634:	e8 d0 dd ff ff       	call   800409 <_panic>
	e = &envs[ENVX(envid)];
  802639:	89 f3                	mov    %esi,%ebx
  80263b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802641:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802644:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80264a:	eb 05                	jmp    802651 <wait+0x3a>
		sys_yield();
  80264c:	e8 fa e7 ff ff       	call   800e4b <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802651:	8b 43 48             	mov    0x48(%ebx),%eax
  802654:	39 c6                	cmp    %eax,%esi
  802656:	75 07                	jne    80265f <wait+0x48>
  802658:	8b 43 54             	mov    0x54(%ebx),%eax
  80265b:	85 c0                	test   %eax,%eax
  80265d:	75 ed                	jne    80264c <wait+0x35>
		sys_yield();
}
  80265f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802662:	5b                   	pop    %ebx
  802663:	5e                   	pop    %esi
  802664:	5d                   	pop    %ebp
  802665:	c3                   	ret    

00802666 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802666:	55                   	push   %ebp
  802667:	89 e5                	mov    %esp,%ebp
  802669:	56                   	push   %esi
  80266a:	53                   	push   %ebx
  80266b:	8b 75 08             	mov    0x8(%ebp),%esi
  80266e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802671:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802674:	85 c0                	test   %eax,%eax
  802676:	74 0e                	je     802686 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  802678:	83 ec 0c             	sub    $0xc,%esp
  80267b:	50                   	push   %eax
  80267c:	e8 99 e9 ff ff       	call   80101a <sys_ipc_recv>
  802681:	83 c4 10             	add    $0x10,%esp
  802684:	eb 10                	jmp    802696 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802686:	83 ec 0c             	sub    $0xc,%esp
  802689:	68 00 00 00 f0       	push   $0xf0000000
  80268e:	e8 87 e9 ff ff       	call   80101a <sys_ipc_recv>
  802693:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  802696:	85 c0                	test   %eax,%eax
  802698:	74 0e                	je     8026a8 <ipc_recv+0x42>
    	*from_env_store = 0;
  80269a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8026a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8026a6:	eb 24                	jmp    8026cc <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8026a8:	85 f6                	test   %esi,%esi
  8026aa:	74 0a                	je     8026b6 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8026ac:	a1 90 77 80 00       	mov    0x807790,%eax
  8026b1:	8b 40 74             	mov    0x74(%eax),%eax
  8026b4:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8026b6:	85 db                	test   %ebx,%ebx
  8026b8:	74 0a                	je     8026c4 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8026ba:	a1 90 77 80 00       	mov    0x807790,%eax
  8026bf:	8b 40 78             	mov    0x78(%eax),%eax
  8026c2:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8026c4:	a1 90 77 80 00       	mov    0x807790,%eax
  8026c9:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8026cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026cf:	5b                   	pop    %ebx
  8026d0:	5e                   	pop    %esi
  8026d1:	5d                   	pop    %ebp
  8026d2:	c3                   	ret    

008026d3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026d3:	55                   	push   %ebp
  8026d4:	89 e5                	mov    %esp,%ebp
  8026d6:	57                   	push   %edi
  8026d7:	56                   	push   %esi
  8026d8:	53                   	push   %ebx
  8026d9:	83 ec 0c             	sub    $0xc,%esp
  8026dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8026e5:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8026e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8026ec:	0f 44 d8             	cmove  %eax,%ebx
  8026ef:	eb 1c                	jmp    80270d <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8026f1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026f4:	74 12                	je     802708 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8026f6:	50                   	push   %eax
  8026f7:	68 ba 30 80 00       	push   $0x8030ba
  8026fc:	6a 4b                	push   $0x4b
  8026fe:	68 d2 30 80 00       	push   $0x8030d2
  802703:	e8 01 dd ff ff       	call   800409 <_panic>
        }	
        sys_yield();
  802708:	e8 3e e7 ff ff       	call   800e4b <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80270d:	ff 75 14             	pushl  0x14(%ebp)
  802710:	53                   	push   %ebx
  802711:	56                   	push   %esi
  802712:	57                   	push   %edi
  802713:	e8 df e8 ff ff       	call   800ff7 <sys_ipc_try_send>
  802718:	83 c4 10             	add    $0x10,%esp
  80271b:	85 c0                	test   %eax,%eax
  80271d:	75 d2                	jne    8026f1 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80271f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802722:	5b                   	pop    %ebx
  802723:	5e                   	pop    %esi
  802724:	5f                   	pop    %edi
  802725:	5d                   	pop    %ebp
  802726:	c3                   	ret    

00802727 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802727:	55                   	push   %ebp
  802728:	89 e5                	mov    %esp,%ebp
  80272a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80272d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802732:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802735:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80273b:	8b 52 50             	mov    0x50(%edx),%edx
  80273e:	39 ca                	cmp    %ecx,%edx
  802740:	75 0d                	jne    80274f <ipc_find_env+0x28>
			return envs[i].env_id;
  802742:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802745:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80274a:	8b 40 48             	mov    0x48(%eax),%eax
  80274d:	eb 0f                	jmp    80275e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80274f:	83 c0 01             	add    $0x1,%eax
  802752:	3d 00 04 00 00       	cmp    $0x400,%eax
  802757:	75 d9                	jne    802732 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802759:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80275e:	5d                   	pop    %ebp
  80275f:	c3                   	ret    

00802760 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802766:	89 d0                	mov    %edx,%eax
  802768:	c1 e8 16             	shr    $0x16,%eax
  80276b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802772:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802777:	f6 c1 01             	test   $0x1,%cl
  80277a:	74 1d                	je     802799 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80277c:	c1 ea 0c             	shr    $0xc,%edx
  80277f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802786:	f6 c2 01             	test   $0x1,%dl
  802789:	74 0e                	je     802799 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80278b:	c1 ea 0c             	shr    $0xc,%edx
  80278e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802795:	ef 
  802796:	0f b7 c0             	movzwl %ax,%eax
}
  802799:	5d                   	pop    %ebp
  80279a:	c3                   	ret    
  80279b:	66 90                	xchg   %ax,%ax
  80279d:	66 90                	xchg   %ax,%ax
  80279f:	90                   	nop

008027a0 <__udivdi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 f6                	test   %esi,%esi
  8027b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bd:	89 ca                	mov    %ecx,%edx
  8027bf:	89 f8                	mov    %edi,%eax
  8027c1:	75 3d                	jne    802800 <__udivdi3+0x60>
  8027c3:	39 cf                	cmp    %ecx,%edi
  8027c5:	0f 87 c5 00 00 00    	ja     802890 <__udivdi3+0xf0>
  8027cb:	85 ff                	test   %edi,%edi
  8027cd:	89 fd                	mov    %edi,%ebp
  8027cf:	75 0b                	jne    8027dc <__udivdi3+0x3c>
  8027d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d6:	31 d2                	xor    %edx,%edx
  8027d8:	f7 f7                	div    %edi
  8027da:	89 c5                	mov    %eax,%ebp
  8027dc:	89 c8                	mov    %ecx,%eax
  8027de:	31 d2                	xor    %edx,%edx
  8027e0:	f7 f5                	div    %ebp
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	89 d8                	mov    %ebx,%eax
  8027e6:	89 cf                	mov    %ecx,%edi
  8027e8:	f7 f5                	div    %ebp
  8027ea:	89 c3                	mov    %eax,%ebx
  8027ec:	89 d8                	mov    %ebx,%eax
  8027ee:	89 fa                	mov    %edi,%edx
  8027f0:	83 c4 1c             	add    $0x1c,%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	90                   	nop
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	39 ce                	cmp    %ecx,%esi
  802802:	77 74                	ja     802878 <__udivdi3+0xd8>
  802804:	0f bd fe             	bsr    %esi,%edi
  802807:	83 f7 1f             	xor    $0x1f,%edi
  80280a:	0f 84 98 00 00 00    	je     8028a8 <__udivdi3+0x108>
  802810:	bb 20 00 00 00       	mov    $0x20,%ebx
  802815:	89 f9                	mov    %edi,%ecx
  802817:	89 c5                	mov    %eax,%ebp
  802819:	29 fb                	sub    %edi,%ebx
  80281b:	d3 e6                	shl    %cl,%esi
  80281d:	89 d9                	mov    %ebx,%ecx
  80281f:	d3 ed                	shr    %cl,%ebp
  802821:	89 f9                	mov    %edi,%ecx
  802823:	d3 e0                	shl    %cl,%eax
  802825:	09 ee                	or     %ebp,%esi
  802827:	89 d9                	mov    %ebx,%ecx
  802829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80282d:	89 d5                	mov    %edx,%ebp
  80282f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802833:	d3 ed                	shr    %cl,%ebp
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e2                	shl    %cl,%edx
  802839:	89 d9                	mov    %ebx,%ecx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	09 c2                	or     %eax,%edx
  80283f:	89 d0                	mov    %edx,%eax
  802841:	89 ea                	mov    %ebp,%edx
  802843:	f7 f6                	div    %esi
  802845:	89 d5                	mov    %edx,%ebp
  802847:	89 c3                	mov    %eax,%ebx
  802849:	f7 64 24 0c          	mull   0xc(%esp)
  80284d:	39 d5                	cmp    %edx,%ebp
  80284f:	72 10                	jb     802861 <__udivdi3+0xc1>
  802851:	8b 74 24 08          	mov    0x8(%esp),%esi
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e6                	shl    %cl,%esi
  802859:	39 c6                	cmp    %eax,%esi
  80285b:	73 07                	jae    802864 <__udivdi3+0xc4>
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	75 03                	jne    802864 <__udivdi3+0xc4>
  802861:	83 eb 01             	sub    $0x1,%ebx
  802864:	31 ff                	xor    %edi,%edi
  802866:	89 d8                	mov    %ebx,%eax
  802868:	89 fa                	mov    %edi,%edx
  80286a:	83 c4 1c             	add    $0x1c,%esp
  80286d:	5b                   	pop    %ebx
  80286e:	5e                   	pop    %esi
  80286f:	5f                   	pop    %edi
  802870:	5d                   	pop    %ebp
  802871:	c3                   	ret    
  802872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802878:	31 ff                	xor    %edi,%edi
  80287a:	31 db                	xor    %ebx,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 d8                	mov    %ebx,%eax
  802892:	f7 f7                	div    %edi
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 c3                	mov    %eax,%ebx
  802898:	89 d8                	mov    %ebx,%eax
  80289a:	89 fa                	mov    %edi,%edx
  80289c:	83 c4 1c             	add    $0x1c,%esp
  80289f:	5b                   	pop    %ebx
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    
  8028a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	39 ce                	cmp    %ecx,%esi
  8028aa:	72 0c                	jb     8028b8 <__udivdi3+0x118>
  8028ac:	31 db                	xor    %ebx,%ebx
  8028ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028b2:	0f 87 34 ff ff ff    	ja     8027ec <__udivdi3+0x4c>
  8028b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028bd:	e9 2a ff ff ff       	jmp    8027ec <__udivdi3+0x4c>
  8028c2:	66 90                	xchg   %ax,%ax
  8028c4:	66 90                	xchg   %ax,%ax
  8028c6:	66 90                	xchg   %ax,%ax
  8028c8:	66 90                	xchg   %ax,%ax
  8028ca:	66 90                	xchg   %ax,%ax
  8028cc:	66 90                	xchg   %ax,%ax
  8028ce:	66 90                	xchg   %ax,%ax

008028d0 <__umoddi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	83 ec 1c             	sub    $0x1c,%esp
  8028d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e7:	85 d2                	test   %edx,%edx
  8028e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028f1:	89 f3                	mov    %esi,%ebx
  8028f3:	89 3c 24             	mov    %edi,(%esp)
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	75 1c                	jne    802918 <__umoddi3+0x48>
  8028fc:	39 f7                	cmp    %esi,%edi
  8028fe:	76 50                	jbe    802950 <__umoddi3+0x80>
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	f7 f7                	div    %edi
  802906:	89 d0                	mov    %edx,%eax
  802908:	31 d2                	xor    %edx,%edx
  80290a:	83 c4 1c             	add    $0x1c,%esp
  80290d:	5b                   	pop    %ebx
  80290e:	5e                   	pop    %esi
  80290f:	5f                   	pop    %edi
  802910:	5d                   	pop    %ebp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	39 f2                	cmp    %esi,%edx
  80291a:	89 d0                	mov    %edx,%eax
  80291c:	77 52                	ja     802970 <__umoddi3+0xa0>
  80291e:	0f bd ea             	bsr    %edx,%ebp
  802921:	83 f5 1f             	xor    $0x1f,%ebp
  802924:	75 5a                	jne    802980 <__umoddi3+0xb0>
  802926:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80292a:	0f 82 e0 00 00 00    	jb     802a10 <__umoddi3+0x140>
  802930:	39 0c 24             	cmp    %ecx,(%esp)
  802933:	0f 86 d7 00 00 00    	jbe    802a10 <__umoddi3+0x140>
  802939:	8b 44 24 08          	mov    0x8(%esp),%eax
  80293d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802941:	83 c4 1c             	add    $0x1c,%esp
  802944:	5b                   	pop    %ebx
  802945:	5e                   	pop    %esi
  802946:	5f                   	pop    %edi
  802947:	5d                   	pop    %ebp
  802948:	c3                   	ret    
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	85 ff                	test   %edi,%edi
  802952:	89 fd                	mov    %edi,%ebp
  802954:	75 0b                	jne    802961 <__umoddi3+0x91>
  802956:	b8 01 00 00 00       	mov    $0x1,%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	f7 f7                	div    %edi
  80295f:	89 c5                	mov    %eax,%ebp
  802961:	89 f0                	mov    %esi,%eax
  802963:	31 d2                	xor    %edx,%edx
  802965:	f7 f5                	div    %ebp
  802967:	89 c8                	mov    %ecx,%eax
  802969:	f7 f5                	div    %ebp
  80296b:	89 d0                	mov    %edx,%eax
  80296d:	eb 99                	jmp    802908 <__umoddi3+0x38>
  80296f:	90                   	nop
  802970:	89 c8                	mov    %ecx,%eax
  802972:	89 f2                	mov    %esi,%edx
  802974:	83 c4 1c             	add    $0x1c,%esp
  802977:	5b                   	pop    %ebx
  802978:	5e                   	pop    %esi
  802979:	5f                   	pop    %edi
  80297a:	5d                   	pop    %ebp
  80297b:	c3                   	ret    
  80297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802980:	8b 34 24             	mov    (%esp),%esi
  802983:	bf 20 00 00 00       	mov    $0x20,%edi
  802988:	89 e9                	mov    %ebp,%ecx
  80298a:	29 ef                	sub    %ebp,%edi
  80298c:	d3 e0                	shl    %cl,%eax
  80298e:	89 f9                	mov    %edi,%ecx
  802990:	89 f2                	mov    %esi,%edx
  802992:	d3 ea                	shr    %cl,%edx
  802994:	89 e9                	mov    %ebp,%ecx
  802996:	09 c2                	or     %eax,%edx
  802998:	89 d8                	mov    %ebx,%eax
  80299a:	89 14 24             	mov    %edx,(%esp)
  80299d:	89 f2                	mov    %esi,%edx
  80299f:	d3 e2                	shl    %cl,%edx
  8029a1:	89 f9                	mov    %edi,%ecx
  8029a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029ab:	d3 e8                	shr    %cl,%eax
  8029ad:	89 e9                	mov    %ebp,%ecx
  8029af:	89 c6                	mov    %eax,%esi
  8029b1:	d3 e3                	shl    %cl,%ebx
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 d0                	mov    %edx,%eax
  8029b7:	d3 e8                	shr    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	09 d8                	or     %ebx,%eax
  8029bd:	89 d3                	mov    %edx,%ebx
  8029bf:	89 f2                	mov    %esi,%edx
  8029c1:	f7 34 24             	divl   (%esp)
  8029c4:	89 d6                	mov    %edx,%esi
  8029c6:	d3 e3                	shl    %cl,%ebx
  8029c8:	f7 64 24 04          	mull   0x4(%esp)
  8029cc:	39 d6                	cmp    %edx,%esi
  8029ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029d2:	89 d1                	mov    %edx,%ecx
  8029d4:	89 c3                	mov    %eax,%ebx
  8029d6:	72 08                	jb     8029e0 <__umoddi3+0x110>
  8029d8:	75 11                	jne    8029eb <__umoddi3+0x11b>
  8029da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029de:	73 0b                	jae    8029eb <__umoddi3+0x11b>
  8029e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029e4:	1b 14 24             	sbb    (%esp),%edx
  8029e7:	89 d1                	mov    %edx,%ecx
  8029e9:	89 c3                	mov    %eax,%ebx
  8029eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ef:	29 da                	sub    %ebx,%edx
  8029f1:	19 ce                	sbb    %ecx,%esi
  8029f3:	89 f9                	mov    %edi,%ecx
  8029f5:	89 f0                	mov    %esi,%eax
  8029f7:	d3 e0                	shl    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	d3 ea                	shr    %cl,%edx
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	d3 ee                	shr    %cl,%esi
  802a01:	09 d0                	or     %edx,%eax
  802a03:	89 f2                	mov    %esi,%edx
  802a05:	83 c4 1c             	add    $0x1c,%esp
  802a08:	5b                   	pop    %ebx
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	29 f9                	sub    %edi,%ecx
  802a12:	19 d6                	sbb    %edx,%esi
  802a14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a1c:	e9 18 ff ff ff       	jmp    802939 <__umoddi3+0x69>
