
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 c7 0d 00 00       	call   800e0b <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 a8 11 00 00       	call   8011fb <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 20 25 80 00       	push   $0x802520
  800065:	6a 0f                	push   $0xf
  800067:	68 2d 25 80 00       	push   $0x80252d
  80006c:	e8 65 02 00 00       	call   8002d6 <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 3c 25 80 00       	push   $0x80253c
  80007b:	6a 11                	push   $0x11
  80007d:	68 2d 25 80 00       	push   $0x80252d
  800082:	e8 4f 02 00 00       	call   8002d6 <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 b8 11 00 00       	call   80124b <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 56 25 80 00       	push   $0x802556
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 2d 25 80 00       	push   $0x80252d
  8000a7:	e8 2a 02 00 00       	call   8002d6 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 5e 25 80 00       	push   $0x80255e
  8000b4:	e8 42 08 00 00       	call   8008fb <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 6c 25 80 00       	push   $0x80256c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 7d 18 00 00       	call   80194d <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 70 25 80 00       	push   $0x802570
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 69 18 00 00       	call   80194d <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 88 25 80 00       	push   $0x802588
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 21 09 00 00       	call   800a27 <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 75 0a 00 00       	call   800bb9 <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 20 0c 00 00       	call   800d6e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 91 0c 00 00       	call   800e0b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 0d 0c 00 00       	call   800d8c <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 b8 0b 00 00       	call   800d6e <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 69 11 00 00       	call   801337 <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 d9 0e 00 00       	call   8010d1 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 61 0e 00 00       	call   801082 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 ee 0b 00 00       	call   800e2a <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 f8 0d 00 00       	call   80105b <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800277:	c7 05 08 44 80 00 00 	movl   $0x0,0x804408
  80027e:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800281:	e8 66 0b 00 00       	call   800dec <sys_getenvid>
  800286:	25 ff 03 00 00       	and    $0x3ff,%eax
  80028b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80028e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800293:	a3 08 44 80 00       	mov    %eax,0x804408

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800298:	85 db                	test   %ebx,%ebx
  80029a:	7e 07                	jle    8002a3 <libmain+0x37>
		binaryname = argv[0];
  80029c:	8b 06                	mov    (%esi),%eax
  80029e:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	e8 86 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002ad:	e8 0a 00 00 00       	call   8002bc <exit>
}
  8002b2:	83 c4 10             	add    $0x10,%esp
  8002b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002c2:	e8 5f 0f 00 00       	call   801226 <close_all>
	sys_env_destroy(0);
  8002c7:	83 ec 0c             	sub    $0xc,%esp
  8002ca:	6a 00                	push   $0x0
  8002cc:	e8 da 0a 00 00       	call   800dab <sys_env_destroy>
}
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002de:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002e4:	e8 03 0b 00 00       	call   800dec <sys_getenvid>
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	ff 75 0c             	pushl  0xc(%ebp)
  8002ef:	ff 75 08             	pushl  0x8(%ebp)
  8002f2:	56                   	push   %esi
  8002f3:	50                   	push   %eax
  8002f4:	68 a0 25 80 00       	push   $0x8025a0
  8002f9:	e8 b1 00 00 00       	call   8003af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002fe:	83 c4 18             	add    $0x18,%esp
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	e8 54 00 00 00       	call   80035e <vcprintf>
	cprintf("\n");
  80030a:	c7 04 24 86 25 80 00 	movl   $0x802586,(%esp)
  800311:	e8 99 00 00 00       	call   8003af <cprintf>
  800316:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800319:	cc                   	int3   
  80031a:	eb fd                	jmp    800319 <_panic+0x43>

0080031c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	53                   	push   %ebx
  800320:	83 ec 04             	sub    $0x4,%esp
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800326:	8b 13                	mov    (%ebx),%edx
  800328:	8d 42 01             	lea    0x1(%edx),%eax
  80032b:	89 03                	mov    %eax,(%ebx)
  80032d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800330:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800334:	3d ff 00 00 00       	cmp    $0xff,%eax
  800339:	75 1a                	jne    800355 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80033b:	83 ec 08             	sub    $0x8,%esp
  80033e:	68 ff 00 00 00       	push   $0xff
  800343:	8d 43 08             	lea    0x8(%ebx),%eax
  800346:	50                   	push   %eax
  800347:	e8 22 0a 00 00       	call   800d6e <sys_cputs>
		b->idx = 0;
  80034c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800352:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800355:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800359:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800367:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036e:	00 00 00 
	b.cnt = 0;
  800371:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800378:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80037b:	ff 75 0c             	pushl  0xc(%ebp)
  80037e:	ff 75 08             	pushl  0x8(%ebp)
  800381:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800387:	50                   	push   %eax
  800388:	68 1c 03 80 00       	push   $0x80031c
  80038d:	e8 54 01 00 00       	call   8004e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800392:	83 c4 08             	add    $0x8,%esp
  800395:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80039b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a1:	50                   	push   %eax
  8003a2:	e8 c7 09 00 00       	call   800d6e <sys_cputs>

	return b.cnt;
}
  8003a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ad:	c9                   	leave  
  8003ae:	c3                   	ret    

008003af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b8:	50                   	push   %eax
  8003b9:	ff 75 08             	pushl  0x8(%ebp)
  8003bc:	e8 9d ff ff ff       	call   80035e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 1c             	sub    $0x1c,%esp
  8003cc:	89 c7                	mov    %eax,%edi
  8003ce:	89 d6                	mov    %edx,%esi
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ea:	39 d3                	cmp    %edx,%ebx
  8003ec:	72 05                	jb     8003f3 <printnum+0x30>
  8003ee:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003f1:	77 45                	ja     800438 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	ff 75 18             	pushl  0x18(%ebp)
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003ff:	53                   	push   %ebx
  800400:	ff 75 10             	pushl  0x10(%ebp)
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	ff 75 e4             	pushl  -0x1c(%ebp)
  800409:	ff 75 e0             	pushl  -0x20(%ebp)
  80040c:	ff 75 dc             	pushl  -0x24(%ebp)
  80040f:	ff 75 d8             	pushl  -0x28(%ebp)
  800412:	e8 69 1e 00 00       	call   802280 <__udivdi3>
  800417:	83 c4 18             	add    $0x18,%esp
  80041a:	52                   	push   %edx
  80041b:	50                   	push   %eax
  80041c:	89 f2                	mov    %esi,%edx
  80041e:	89 f8                	mov    %edi,%eax
  800420:	e8 9e ff ff ff       	call   8003c3 <printnum>
  800425:	83 c4 20             	add    $0x20,%esp
  800428:	eb 18                	jmp    800442 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	56                   	push   %esi
  80042e:	ff 75 18             	pushl  0x18(%ebp)
  800431:	ff d7                	call   *%edi
  800433:	83 c4 10             	add    $0x10,%esp
  800436:	eb 03                	jmp    80043b <printnum+0x78>
  800438:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80043b:	83 eb 01             	sub    $0x1,%ebx
  80043e:	85 db                	test   %ebx,%ebx
  800440:	7f e8                	jg     80042a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	56                   	push   %esi
  800446:	83 ec 04             	sub    $0x4,%esp
  800449:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044c:	ff 75 e0             	pushl  -0x20(%ebp)
  80044f:	ff 75 dc             	pushl  -0x24(%ebp)
  800452:	ff 75 d8             	pushl  -0x28(%ebp)
  800455:	e8 56 1f 00 00       	call   8023b0 <__umoddi3>
  80045a:	83 c4 14             	add    $0x14,%esp
  80045d:	0f be 80 c3 25 80 00 	movsbl 0x8025c3(%eax),%eax
  800464:	50                   	push   %eax
  800465:	ff d7                	call   *%edi
}
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80046d:	5b                   	pop    %ebx
  80046e:	5e                   	pop    %esi
  80046f:	5f                   	pop    %edi
  800470:	5d                   	pop    %ebp
  800471:	c3                   	ret    

00800472 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800475:	83 fa 01             	cmp    $0x1,%edx
  800478:	7e 0e                	jle    800488 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	8b 52 04             	mov    0x4(%edx),%edx
  800486:	eb 22                	jmp    8004aa <getuint+0x38>
	else if (lflag)
  800488:	85 d2                	test   %edx,%edx
  80048a:	74 10                	je     80049c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80048c:	8b 10                	mov    (%eax),%edx
  80048e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800491:	89 08                	mov    %ecx,(%eax)
  800493:	8b 02                	mov    (%edx),%eax
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	eb 0e                	jmp    8004aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004aa:	5d                   	pop    %ebp
  8004ab:	c3                   	ret    

008004ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bb:	73 0a                	jae    8004c7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c5:	88 02                	mov    %al,(%edx)
}
  8004c7:	5d                   	pop    %ebp
  8004c8:	c3                   	ret    

008004c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d2:	50                   	push   %eax
  8004d3:	ff 75 10             	pushl  0x10(%ebp)
  8004d6:	ff 75 0c             	pushl  0xc(%ebp)
  8004d9:	ff 75 08             	pushl  0x8(%ebp)
  8004dc:	e8 05 00 00 00       	call   8004e6 <vprintfmt>
	va_end(ap);
}
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    

008004e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  8004ec:	83 ec 2c             	sub    $0x2c,%esp
  8004ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f8:	eb 12                	jmp    80050c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	0f 84 89 03 00 00    	je     80088b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	53                   	push   %ebx
  800506:	50                   	push   %eax
  800507:	ff d6                	call   *%esi
  800509:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050c:	83 c7 01             	add    $0x1,%edi
  80050f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800513:	83 f8 25             	cmp    $0x25,%eax
  800516:	75 e2                	jne    8004fa <vprintfmt+0x14>
  800518:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80051c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800523:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80052a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800531:	ba 00 00 00 00       	mov    $0x0,%edx
  800536:	eb 07                	jmp    80053f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8d 47 01             	lea    0x1(%edi),%eax
  800542:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800545:	0f b6 07             	movzbl (%edi),%eax
  800548:	0f b6 c8             	movzbl %al,%ecx
  80054b:	83 e8 23             	sub    $0x23,%eax
  80054e:	3c 55                	cmp    $0x55,%al
  800550:	0f 87 1a 03 00 00    	ja     800870 <vprintfmt+0x38a>
  800556:	0f b6 c0             	movzbl %al,%eax
  800559:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800563:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800567:	eb d6                	jmp    80053f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056c:	b8 00 00 00 00       	mov    $0x0,%eax
  800571:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800574:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800577:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80057b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80057e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800581:	83 fa 09             	cmp    $0x9,%edx
  800584:	77 39                	ja     8005bf <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800586:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800589:	eb e9                	jmp    800574 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 48 04             	lea    0x4(%eax),%ecx
  800591:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80059c:	eb 27                	jmp    8005c5 <vprintfmt+0xdf>
  80059e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a8:	0f 49 c8             	cmovns %eax,%ecx
  8005ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	eb 8c                	jmp    80053f <vprintfmt+0x59>
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005bd:	eb 80                	jmp    80053f <vprintfmt+0x59>
  8005bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c9:	0f 89 70 ff ff ff    	jns    80053f <vprintfmt+0x59>
				width = precision, precision = -1;
  8005cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005dc:	e9 5e ff ff ff       	jmp    80053f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005e7:	e9 53 ff ff ff       	jmp    80053f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	ff 30                	pushl  (%eax)
  8005fb:	ff d6                	call   *%esi
			break;
  8005fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800603:	e9 04 ff ff ff       	jmp    80050c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 00                	mov    (%eax),%eax
  800613:	99                   	cltd   
  800614:	31 d0                	xor    %edx,%eax
  800616:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800618:	83 f8 0f             	cmp    $0xf,%eax
  80061b:	7f 0b                	jg     800628 <vprintfmt+0x142>
  80061d:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  800624:	85 d2                	test   %edx,%edx
  800626:	75 18                	jne    800640 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800628:	50                   	push   %eax
  800629:	68 db 25 80 00       	push   $0x8025db
  80062e:	53                   	push   %ebx
  80062f:	56                   	push   %esi
  800630:	e8 94 fe ff ff       	call   8004c9 <printfmt>
  800635:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80063b:	e9 cc fe ff ff       	jmp    80050c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800640:	52                   	push   %edx
  800641:	68 a9 29 80 00       	push   $0x8029a9
  800646:	53                   	push   %ebx
  800647:	56                   	push   %esi
  800648:	e8 7c fe ff ff       	call   8004c9 <printfmt>
  80064d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800653:	e9 b4 fe ff ff       	jmp    80050c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 04             	lea    0x4(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)
  800661:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800663:	85 ff                	test   %edi,%edi
  800665:	b8 d4 25 80 00       	mov    $0x8025d4,%eax
  80066a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80066d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800671:	0f 8e 94 00 00 00    	jle    80070b <vprintfmt+0x225>
  800677:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80067b:	0f 84 98 00 00 00    	je     800719 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	ff 75 d0             	pushl  -0x30(%ebp)
  800687:	57                   	push   %edi
  800688:	e8 79 03 00 00       	call   800a06 <strnlen>
  80068d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800690:	29 c1                	sub    %eax,%ecx
  800692:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800695:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800698:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80069c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006a2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a4:	eb 0f                	jmp    8006b5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ad:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006af:	83 ef 01             	sub    $0x1,%edi
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	85 ff                	test   %edi,%edi
  8006b7:	7f ed                	jg     8006a6 <vprintfmt+0x1c0>
  8006b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006bc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006bf:	85 c9                	test   %ecx,%ecx
  8006c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c6:	0f 49 c1             	cmovns %ecx,%eax
  8006c9:	29 c1                	sub    %eax,%ecx
  8006cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d4:	89 cb                	mov    %ecx,%ebx
  8006d6:	eb 4d                	jmp    800725 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006dc:	74 1b                	je     8006f9 <vprintfmt+0x213>
  8006de:	0f be c0             	movsbl %al,%eax
  8006e1:	83 e8 20             	sub    $0x20,%eax
  8006e4:	83 f8 5e             	cmp    $0x5e,%eax
  8006e7:	76 10                	jbe    8006f9 <vprintfmt+0x213>
					putch('?', putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	ff 75 0c             	pushl  0xc(%ebp)
  8006ef:	6a 3f                	push   $0x3f
  8006f1:	ff 55 08             	call   *0x8(%ebp)
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 0d                	jmp    800706 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	ff 75 0c             	pushl  0xc(%ebp)
  8006ff:	52                   	push   %edx
  800700:	ff 55 08             	call   *0x8(%ebp)
  800703:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800706:	83 eb 01             	sub    $0x1,%ebx
  800709:	eb 1a                	jmp    800725 <vprintfmt+0x23f>
  80070b:	89 75 08             	mov    %esi,0x8(%ebp)
  80070e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800711:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800714:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800717:	eb 0c                	jmp    800725 <vprintfmt+0x23f>
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800725:	83 c7 01             	add    $0x1,%edi
  800728:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80072c:	0f be d0             	movsbl %al,%edx
  80072f:	85 d2                	test   %edx,%edx
  800731:	74 23                	je     800756 <vprintfmt+0x270>
  800733:	85 f6                	test   %esi,%esi
  800735:	78 a1                	js     8006d8 <vprintfmt+0x1f2>
  800737:	83 ee 01             	sub    $0x1,%esi
  80073a:	79 9c                	jns    8006d8 <vprintfmt+0x1f2>
  80073c:	89 df                	mov    %ebx,%edi
  80073e:	8b 75 08             	mov    0x8(%ebp),%esi
  800741:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800744:	eb 18                	jmp    80075e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	53                   	push   %ebx
  80074a:	6a 20                	push   $0x20
  80074c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074e:	83 ef 01             	sub    $0x1,%edi
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	eb 08                	jmp    80075e <vprintfmt+0x278>
  800756:	89 df                	mov    %ebx,%edi
  800758:	8b 75 08             	mov    0x8(%ebp),%esi
  80075b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075e:	85 ff                	test   %edi,%edi
  800760:	7f e4                	jg     800746 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800762:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800765:	e9 a2 fd ff ff       	jmp    80050c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076a:	83 fa 01             	cmp    $0x1,%edx
  80076d:	7e 16                	jle    800785 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8d 50 08             	lea    0x8(%eax),%edx
  800775:	89 55 14             	mov    %edx,0x14(%ebp)
  800778:	8b 50 04             	mov    0x4(%eax),%edx
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800780:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800783:	eb 32                	jmp    8007b7 <vprintfmt+0x2d1>
	else if (lflag)
  800785:	85 d2                	test   %edx,%edx
  800787:	74 18                	je     8007a1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8d 50 04             	lea    0x4(%eax),%edx
  80078f:	89 55 14             	mov    %edx,0x14(%ebp)
  800792:	8b 00                	mov    (%eax),%eax
  800794:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800797:	89 c1                	mov    %eax,%ecx
  800799:	c1 f9 1f             	sar    $0x1f,%ecx
  80079c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80079f:	eb 16                	jmp    8007b7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8d 50 04             	lea    0x4(%eax),%edx
  8007a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007aa:	8b 00                	mov    (%eax),%eax
  8007ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007af:	89 c1                	mov    %eax,%ecx
  8007b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007c6:	79 74                	jns    80083c <vprintfmt+0x356>
				putch('-', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 2d                	push   $0x2d
  8007ce:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007d6:	f7 d8                	neg    %eax
  8007d8:	83 d2 00             	adc    $0x0,%edx
  8007db:	f7 da                	neg    %edx
  8007dd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e5:	eb 55                	jmp    80083c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ea:	e8 83 fc ff ff       	call   800472 <getuint>
			base = 10;
  8007ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007f4:	eb 46                	jmp    80083c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	e8 74 fc ff ff       	call   800472 <getuint>
		        base = 8;
  8007fe:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800803:	eb 37                	jmp    80083c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	53                   	push   %ebx
  800809:	6a 30                	push   $0x30
  80080b:	ff d6                	call   *%esi
			putch('x', putdat);
  80080d:	83 c4 08             	add    $0x8,%esp
  800810:	53                   	push   %ebx
  800811:	6a 78                	push   $0x78
  800813:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8d 50 04             	lea    0x4(%eax),%edx
  80081b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80081e:	8b 00                	mov    (%eax),%eax
  800820:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800825:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800828:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80082d:	eb 0d                	jmp    80083c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	e8 3b fc ff ff       	call   800472 <getuint>
			base = 16;
  800837:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80083c:	83 ec 0c             	sub    $0xc,%esp
  80083f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800843:	57                   	push   %edi
  800844:	ff 75 e0             	pushl  -0x20(%ebp)
  800847:	51                   	push   %ecx
  800848:	52                   	push   %edx
  800849:	50                   	push   %eax
  80084a:	89 da                	mov    %ebx,%edx
  80084c:	89 f0                	mov    %esi,%eax
  80084e:	e8 70 fb ff ff       	call   8003c3 <printnum>
			break;
  800853:	83 c4 20             	add    $0x20,%esp
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800859:	e9 ae fc ff ff       	jmp    80050c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	53                   	push   %ebx
  800862:	51                   	push   %ecx
  800863:	ff d6                	call   *%esi
			break;
  800865:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800868:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80086b:	e9 9c fc ff ff       	jmp    80050c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 25                	push   $0x25
  800876:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	eb 03                	jmp    800880 <vprintfmt+0x39a>
  80087d:	83 ef 01             	sub    $0x1,%edi
  800880:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800884:	75 f7                	jne    80087d <vprintfmt+0x397>
  800886:	e9 81 fc ff ff       	jmp    80050c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80088b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5f                   	pop    %edi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	83 ec 18             	sub    $0x18,%esp
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	74 26                	je     8008da <vsnprintf+0x47>
  8008b4:	85 d2                	test   %edx,%edx
  8008b6:	7e 22                	jle    8008da <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b8:	ff 75 14             	pushl  0x14(%ebp)
  8008bb:	ff 75 10             	pushl  0x10(%ebp)
  8008be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c1:	50                   	push   %eax
  8008c2:	68 ac 04 80 00       	push   $0x8004ac
  8008c7:	e8 1a fc ff ff       	call   8004e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	eb 05                	jmp    8008df <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    

008008e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ea:	50                   	push   %eax
  8008eb:	ff 75 10             	pushl  0x10(%ebp)
  8008ee:	ff 75 0c             	pushl  0xc(%ebp)
  8008f1:	ff 75 08             	pushl  0x8(%ebp)
  8008f4:	e8 9a ff ff ff       	call   800893 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    

008008fb <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	83 ec 0c             	sub    $0xc,%esp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800907:	85 c0                	test   %eax,%eax
  800909:	74 13                	je     80091e <readline+0x23>
		fprintf(1, "%s", prompt);
  80090b:	83 ec 04             	sub    $0x4,%esp
  80090e:	50                   	push   %eax
  80090f:	68 a9 29 80 00       	push   $0x8029a9
  800914:	6a 01                	push   $0x1
  800916:	e8 32 10 00 00       	call   80194d <fprintf>
  80091b:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80091e:	83 ec 0c             	sub    $0xc,%esp
  800921:	6a 00                	push   $0x0
  800923:	e8 be f8 ff ff       	call   8001e6 <iscons>
  800928:	89 c7                	mov    %eax,%edi
  80092a:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80092d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800932:	e8 84 f8 ff ff       	call   8001bb <getchar>
  800937:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800939:	85 c0                	test   %eax,%eax
  80093b:	79 29                	jns    800966 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800942:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800945:	0f 84 9b 00 00 00    	je     8009e6 <readline+0xeb>
				cprintf("read error: %e\n", c);
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	53                   	push   %ebx
  80094f:	68 bf 28 80 00       	push   $0x8028bf
  800954:	e8 56 fa ff ff       	call   8003af <cprintf>
  800959:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
  800961:	e9 80 00 00 00       	jmp    8009e6 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800966:	83 f8 08             	cmp    $0x8,%eax
  800969:	0f 94 c2             	sete   %dl
  80096c:	83 f8 7f             	cmp    $0x7f,%eax
  80096f:	0f 94 c0             	sete   %al
  800972:	08 c2                	or     %al,%dl
  800974:	74 1a                	je     800990 <readline+0x95>
  800976:	85 f6                	test   %esi,%esi
  800978:	7e 16                	jle    800990 <readline+0x95>
			if (echoing)
  80097a:	85 ff                	test   %edi,%edi
  80097c:	74 0d                	je     80098b <readline+0x90>
				cputchar('\b');
  80097e:	83 ec 0c             	sub    $0xc,%esp
  800981:	6a 08                	push   $0x8
  800983:	e8 17 f8 ff ff       	call   80019f <cputchar>
  800988:	83 c4 10             	add    $0x10,%esp
			i--;
  80098b:	83 ee 01             	sub    $0x1,%esi
  80098e:	eb a2                	jmp    800932 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800990:	83 fb 1f             	cmp    $0x1f,%ebx
  800993:	7e 26                	jle    8009bb <readline+0xc0>
  800995:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80099b:	7f 1e                	jg     8009bb <readline+0xc0>
			if (echoing)
  80099d:	85 ff                	test   %edi,%edi
  80099f:	74 0c                	je     8009ad <readline+0xb2>
				cputchar(c);
  8009a1:	83 ec 0c             	sub    $0xc,%esp
  8009a4:	53                   	push   %ebx
  8009a5:	e8 f5 f7 ff ff       	call   80019f <cputchar>
  8009aa:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009ad:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009b3:	8d 76 01             	lea    0x1(%esi),%esi
  8009b6:	e9 77 ff ff ff       	jmp    800932 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009bb:	83 fb 0a             	cmp    $0xa,%ebx
  8009be:	74 09                	je     8009c9 <readline+0xce>
  8009c0:	83 fb 0d             	cmp    $0xd,%ebx
  8009c3:	0f 85 69 ff ff ff    	jne    800932 <readline+0x37>
			if (echoing)
  8009c9:	85 ff                	test   %edi,%edi
  8009cb:	74 0d                	je     8009da <readline+0xdf>
				cputchar('\n');
  8009cd:	83 ec 0c             	sub    $0xc,%esp
  8009d0:	6a 0a                	push   $0xa
  8009d2:	e8 c8 f7 ff ff       	call   80019f <cputchar>
  8009d7:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009da:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009e1:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  8009e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	eb 03                	jmp    8009fe <strlen+0x10>
		n++;
  8009fb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a02:	75 f7                	jne    8009fb <strlen+0xd>
		n++;
	return n;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a14:	eb 03                	jmp    800a19 <strnlen+0x13>
		n++;
  800a16:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a19:	39 c2                	cmp    %eax,%edx
  800a1b:	74 08                	je     800a25 <strnlen+0x1f>
  800a1d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a21:	75 f3                	jne    800a16 <strnlen+0x10>
  800a23:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	83 c2 01             	add    $0x1,%edx
  800a36:	83 c1 01             	add    $0x1,%ecx
  800a39:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a3d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a40:	84 db                	test   %bl,%bl
  800a42:	75 ef                	jne    800a33 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a44:	5b                   	pop    %ebx
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a4e:	53                   	push   %ebx
  800a4f:	e8 9a ff ff ff       	call   8009ee <strlen>
  800a54:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a57:	ff 75 0c             	pushl  0xc(%ebp)
  800a5a:	01 d8                	add    %ebx,%eax
  800a5c:	50                   	push   %eax
  800a5d:	e8 c5 ff ff ff       	call   800a27 <strcpy>
	return dst;
}
  800a62:	89 d8                	mov    %ebx,%eax
  800a64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a79:	89 f2                	mov    %esi,%edx
  800a7b:	eb 0f                	jmp    800a8c <strncpy+0x23>
		*dst++ = *src;
  800a7d:	83 c2 01             	add    $0x1,%edx
  800a80:	0f b6 01             	movzbl (%ecx),%eax
  800a83:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a86:	80 39 01             	cmpb   $0x1,(%ecx)
  800a89:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8c:	39 da                	cmp    %ebx,%edx
  800a8e:	75 ed                	jne    800a7d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a90:	89 f0                	mov    %esi,%eax
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa1:	8b 55 10             	mov    0x10(%ebp),%edx
  800aa4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa6:	85 d2                	test   %edx,%edx
  800aa8:	74 21                	je     800acb <strlcpy+0x35>
  800aaa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aae:	89 f2                	mov    %esi,%edx
  800ab0:	eb 09                	jmp    800abb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab2:	83 c2 01             	add    $0x1,%edx
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800abb:	39 c2                	cmp    %eax,%edx
  800abd:	74 09                	je     800ac8 <strlcpy+0x32>
  800abf:	0f b6 19             	movzbl (%ecx),%ebx
  800ac2:	84 db                	test   %bl,%bl
  800ac4:	75 ec                	jne    800ab2 <strlcpy+0x1c>
  800ac6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ac8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800acb:	29 f0                	sub    %esi,%eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ada:	eb 06                	jmp    800ae2 <strcmp+0x11>
		p++, q++;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae2:	0f b6 01             	movzbl (%ecx),%eax
  800ae5:	84 c0                	test   %al,%al
  800ae7:	74 04                	je     800aed <strcmp+0x1c>
  800ae9:	3a 02                	cmp    (%edx),%al
  800aeb:	74 ef                	je     800adc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aed:	0f b6 c0             	movzbl %al,%eax
  800af0:	0f b6 12             	movzbl (%edx),%edx
  800af3:	29 d0                	sub    %edx,%eax
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b06:	eb 06                	jmp    800b0e <strncmp+0x17>
		n--, p++, q++;
  800b08:	83 c0 01             	add    $0x1,%eax
  800b0b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b0e:	39 d8                	cmp    %ebx,%eax
  800b10:	74 15                	je     800b27 <strncmp+0x30>
  800b12:	0f b6 08             	movzbl (%eax),%ecx
  800b15:	84 c9                	test   %cl,%cl
  800b17:	74 04                	je     800b1d <strncmp+0x26>
  800b19:	3a 0a                	cmp    (%edx),%cl
  800b1b:	74 eb                	je     800b08 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1d:	0f b6 00             	movzbl (%eax),%eax
  800b20:	0f b6 12             	movzbl (%edx),%edx
  800b23:	29 d0                	sub    %edx,%eax
  800b25:	eb 05                	jmp    800b2c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b39:	eb 07                	jmp    800b42 <strchr+0x13>
		if (*s == c)
  800b3b:	38 ca                	cmp    %cl,%dl
  800b3d:	74 0f                	je     800b4e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3f:	83 c0 01             	add    $0x1,%eax
  800b42:	0f b6 10             	movzbl (%eax),%edx
  800b45:	84 d2                	test   %dl,%dl
  800b47:	75 f2                	jne    800b3b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5a:	eb 03                	jmp    800b5f <strfind+0xf>
  800b5c:	83 c0 01             	add    $0x1,%eax
  800b5f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b62:	38 ca                	cmp    %cl,%dl
  800b64:	74 04                	je     800b6a <strfind+0x1a>
  800b66:	84 d2                	test   %dl,%dl
  800b68:	75 f2                	jne    800b5c <strfind+0xc>
			break;
	return (char *) s;
}
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b78:	85 c9                	test   %ecx,%ecx
  800b7a:	74 36                	je     800bb2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b82:	75 28                	jne    800bac <memset+0x40>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	75 23                	jne    800bac <memset+0x40>
		c &= 0xFF;
  800b89:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	c1 e3 08             	shl    $0x8,%ebx
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	c1 e6 18             	shl    $0x18,%esi
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	c1 e0 10             	shl    $0x10,%eax
  800b9c:	09 f0                	or     %esi,%eax
  800b9e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ba0:	89 d8                	mov    %ebx,%eax
  800ba2:	09 d0                	or     %edx,%eax
  800ba4:	c1 e9 02             	shr    $0x2,%ecx
  800ba7:	fc                   	cld    
  800ba8:	f3 ab                	rep stos %eax,%es:(%edi)
  800baa:	eb 06                	jmp    800bb2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baf:	fc                   	cld    
  800bb0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb2:	89 f8                	mov    %edi,%eax
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc7:	39 c6                	cmp    %eax,%esi
  800bc9:	73 35                	jae    800c00 <memmove+0x47>
  800bcb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bce:	39 d0                	cmp    %edx,%eax
  800bd0:	73 2e                	jae    800c00 <memmove+0x47>
		s += n;
		d += n;
  800bd2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	09 fe                	or     %edi,%esi
  800bd9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bdf:	75 13                	jne    800bf4 <memmove+0x3b>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 0e                	jne    800bf4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800be6:	83 ef 04             	sub    $0x4,%edi
  800be9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bec:	c1 e9 02             	shr    $0x2,%ecx
  800bef:	fd                   	std    
  800bf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf2:	eb 09                	jmp    800bfd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf4:	83 ef 01             	sub    $0x1,%edi
  800bf7:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bfa:	fd                   	std    
  800bfb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bfd:	fc                   	cld    
  800bfe:	eb 1d                	jmp    800c1d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c00:	89 f2                	mov    %esi,%edx
  800c02:	09 c2                	or     %eax,%edx
  800c04:	f6 c2 03             	test   $0x3,%dl
  800c07:	75 0f                	jne    800c18 <memmove+0x5f>
  800c09:	f6 c1 03             	test   $0x3,%cl
  800c0c:	75 0a                	jne    800c18 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c0e:	c1 e9 02             	shr    $0x2,%ecx
  800c11:	89 c7                	mov    %eax,%edi
  800c13:	fc                   	cld    
  800c14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c16:	eb 05                	jmp    800c1d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c18:	89 c7                	mov    %eax,%edi
  800c1a:	fc                   	cld    
  800c1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c24:	ff 75 10             	pushl  0x10(%ebp)
  800c27:	ff 75 0c             	pushl  0xc(%ebp)
  800c2a:	ff 75 08             	pushl  0x8(%ebp)
  800c2d:	e8 87 ff ff ff       	call   800bb9 <memmove>
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3f:	89 c6                	mov    %eax,%esi
  800c41:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c44:	eb 1a                	jmp    800c60 <memcmp+0x2c>
		if (*s1 != *s2)
  800c46:	0f b6 08             	movzbl (%eax),%ecx
  800c49:	0f b6 1a             	movzbl (%edx),%ebx
  800c4c:	38 d9                	cmp    %bl,%cl
  800c4e:	74 0a                	je     800c5a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c50:	0f b6 c1             	movzbl %cl,%eax
  800c53:	0f b6 db             	movzbl %bl,%ebx
  800c56:	29 d8                	sub    %ebx,%eax
  800c58:	eb 0f                	jmp    800c69 <memcmp+0x35>
		s1++, s2++;
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c60:	39 f0                	cmp    %esi,%eax
  800c62:	75 e2                	jne    800c46 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	53                   	push   %ebx
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c74:	89 c1                	mov    %eax,%ecx
  800c76:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c79:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7d:	eb 0a                	jmp    800c89 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7f:	0f b6 10             	movzbl (%eax),%edx
  800c82:	39 da                	cmp    %ebx,%edx
  800c84:	74 07                	je     800c8d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c86:	83 c0 01             	add    $0x1,%eax
  800c89:	39 c8                	cmp    %ecx,%eax
  800c8b:	72 f2                	jb     800c7f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9c:	eb 03                	jmp    800ca1 <strtol+0x11>
		s++;
  800c9e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca1:	0f b6 01             	movzbl (%ecx),%eax
  800ca4:	3c 20                	cmp    $0x20,%al
  800ca6:	74 f6                	je     800c9e <strtol+0xe>
  800ca8:	3c 09                	cmp    $0x9,%al
  800caa:	74 f2                	je     800c9e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cac:	3c 2b                	cmp    $0x2b,%al
  800cae:	75 0a                	jne    800cba <strtol+0x2a>
		s++;
  800cb0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb8:	eb 11                	jmp    800ccb <strtol+0x3b>
  800cba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cbf:	3c 2d                	cmp    $0x2d,%al
  800cc1:	75 08                	jne    800ccb <strtol+0x3b>
		s++, neg = 1;
  800cc3:	83 c1 01             	add    $0x1,%ecx
  800cc6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ccb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cd1:	75 15                	jne    800ce8 <strtol+0x58>
  800cd3:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd6:	75 10                	jne    800ce8 <strtol+0x58>
  800cd8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cdc:	75 7c                	jne    800d5a <strtol+0xca>
		s += 2, base = 16;
  800cde:	83 c1 02             	add    $0x2,%ecx
  800ce1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce6:	eb 16                	jmp    800cfe <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ce8:	85 db                	test   %ebx,%ebx
  800cea:	75 12                	jne    800cfe <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf1:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf4:	75 08                	jne    800cfe <strtol+0x6e>
		s++, base = 8;
  800cf6:	83 c1 01             	add    $0x1,%ecx
  800cf9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800d03:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d06:	0f b6 11             	movzbl (%ecx),%edx
  800d09:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d0c:	89 f3                	mov    %esi,%ebx
  800d0e:	80 fb 09             	cmp    $0x9,%bl
  800d11:	77 08                	ja     800d1b <strtol+0x8b>
			dig = *s - '0';
  800d13:	0f be d2             	movsbl %dl,%edx
  800d16:	83 ea 30             	sub    $0x30,%edx
  800d19:	eb 22                	jmp    800d3d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d1b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d1e:	89 f3                	mov    %esi,%ebx
  800d20:	80 fb 19             	cmp    $0x19,%bl
  800d23:	77 08                	ja     800d2d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d25:	0f be d2             	movsbl %dl,%edx
  800d28:	83 ea 57             	sub    $0x57,%edx
  800d2b:	eb 10                	jmp    800d3d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d2d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d30:	89 f3                	mov    %esi,%ebx
  800d32:	80 fb 19             	cmp    $0x19,%bl
  800d35:	77 16                	ja     800d4d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d37:	0f be d2             	movsbl %dl,%edx
  800d3a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d3d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d40:	7d 0b                	jge    800d4d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d42:	83 c1 01             	add    $0x1,%ecx
  800d45:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d49:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d4b:	eb b9                	jmp    800d06 <strtol+0x76>

	if (endptr)
  800d4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d51:	74 0d                	je     800d60 <strtol+0xd0>
		*endptr = (char *) s;
  800d53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d56:	89 0e                	mov    %ecx,(%esi)
  800d58:	eb 06                	jmp    800d60 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d5a:	85 db                	test   %ebx,%ebx
  800d5c:	74 98                	je     800cf6 <strtol+0x66>
  800d5e:	eb 9e                	jmp    800cfe <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d60:	89 c2                	mov    %eax,%edx
  800d62:	f7 da                	neg    %edx
  800d64:	85 ff                	test   %edi,%edi
  800d66:	0f 45 c2             	cmovne %edx,%eax
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b8 00 00 00 00       	mov    $0x0,%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 c3                	mov    %eax,%ebx
  800d81:	89 c7                	mov    %eax,%edi
  800d83:	89 c6                	mov    %eax,%esi
  800d85:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_cgetc>:

int
sys_cgetc(void)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	ba 00 00 00 00       	mov    $0x0,%edx
  800d97:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9c:	89 d1                	mov    %edx,%ecx
  800d9e:	89 d3                	mov    %edx,%ebx
  800da0:	89 d7                	mov    %edx,%edi
  800da2:	89 d6                	mov    %edx,%esi
  800da4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db9:	b8 03 00 00 00       	mov    $0x3,%eax
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	89 cb                	mov    %ecx,%ebx
  800dc3:	89 cf                	mov    %ecx,%edi
  800dc5:	89 ce                	mov    %ecx,%esi
  800dc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 17                	jle    800de4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	50                   	push   %eax
  800dd1:	6a 03                	push   $0x3
  800dd3:	68 cf 28 80 00       	push   $0x8028cf
  800dd8:	6a 23                	push   $0x23
  800dda:	68 ec 28 80 00       	push   $0x8028ec
  800ddf:	e8 f2 f4 ff ff       	call   8002d6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	ba 00 00 00 00       	mov    $0x0,%edx
  800df7:	b8 02 00 00 00       	mov    $0x2,%eax
  800dfc:	89 d1                	mov    %edx,%ecx
  800dfe:	89 d3                	mov    %edx,%ebx
  800e00:	89 d7                	mov    %edx,%edi
  800e02:	89 d6                	mov    %edx,%esi
  800e04:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_yield>:

void
sys_yield(void)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	ba 00 00 00 00       	mov    $0x0,%edx
  800e16:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1b:	89 d1                	mov    %edx,%ecx
  800e1d:	89 d3                	mov    %edx,%ebx
  800e1f:	89 d7                	mov    %edx,%edi
  800e21:	89 d6                	mov    %edx,%esi
  800e23:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	be 00 00 00 00       	mov    $0x0,%esi
  800e38:	b8 04 00 00 00       	mov    $0x4,%eax
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e46:	89 f7                	mov    %esi,%edi
  800e48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	7e 17                	jle    800e65 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4e:	83 ec 0c             	sub    $0xc,%esp
  800e51:	50                   	push   %eax
  800e52:	6a 04                	push   $0x4
  800e54:	68 cf 28 80 00       	push   $0x8028cf
  800e59:	6a 23                	push   $0x23
  800e5b:	68 ec 28 80 00       	push   $0x8028ec
  800e60:	e8 71 f4 ff ff       	call   8002d6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	b8 05 00 00 00       	mov    $0x5,%eax
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e87:	8b 75 18             	mov    0x18(%ebp),%esi
  800e8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	7e 17                	jle    800ea7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	50                   	push   %eax
  800e94:	6a 05                	push   $0x5
  800e96:	68 cf 28 80 00       	push   $0x8028cf
  800e9b:	6a 23                	push   $0x23
  800e9d:	68 ec 28 80 00       	push   $0x8028ec
  800ea2:	e8 2f f4 ff ff       	call   8002d6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebd:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	89 df                	mov    %ebx,%edi
  800eca:	89 de                	mov    %ebx,%esi
  800ecc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	7e 17                	jle    800ee9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	50                   	push   %eax
  800ed6:	6a 06                	push   $0x6
  800ed8:	68 cf 28 80 00       	push   $0x8028cf
  800edd:	6a 23                	push   $0x23
  800edf:	68 ec 28 80 00       	push   $0x8028ec
  800ee4:	e8 ed f3 ff ff       	call   8002d6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ee9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eff:	b8 08 00 00 00       	mov    $0x8,%eax
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0a:	89 df                	mov    %ebx,%edi
  800f0c:	89 de                	mov    %ebx,%esi
  800f0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f10:	85 c0                	test   %eax,%eax
  800f12:	7e 17                	jle    800f2b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f14:	83 ec 0c             	sub    $0xc,%esp
  800f17:	50                   	push   %eax
  800f18:	6a 08                	push   $0x8
  800f1a:	68 cf 28 80 00       	push   $0x8028cf
  800f1f:	6a 23                	push   $0x23
  800f21:	68 ec 28 80 00       	push   $0x8028ec
  800f26:	e8 ab f3 ff ff       	call   8002d6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f41:	b8 09 00 00 00       	mov    $0x9,%eax
  800f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	89 df                	mov    %ebx,%edi
  800f4e:	89 de                	mov    %ebx,%esi
  800f50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f52:	85 c0                	test   %eax,%eax
  800f54:	7e 17                	jle    800f6d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f56:	83 ec 0c             	sub    $0xc,%esp
  800f59:	50                   	push   %eax
  800f5a:	6a 09                	push   $0x9
  800f5c:	68 cf 28 80 00       	push   $0x8028cf
  800f61:	6a 23                	push   $0x23
  800f63:	68 ec 28 80 00       	push   $0x8028ec
  800f68:	e8 69 f3 ff ff       	call   8002d6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	57                   	push   %edi
  800f79:	56                   	push   %esi
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f83:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8e:	89 df                	mov    %ebx,%edi
  800f90:	89 de                	mov    %ebx,%esi
  800f92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f94:	85 c0                	test   %eax,%eax
  800f96:	7e 17                	jle    800faf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	50                   	push   %eax
  800f9c:	6a 0a                	push   $0xa
  800f9e:	68 cf 28 80 00       	push   $0x8028cf
  800fa3:	6a 23                	push   $0x23
  800fa5:	68 ec 28 80 00       	push   $0x8028ec
  800faa:	e8 27 f3 ff ff       	call   8002d6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbd:	be 00 00 00 00       	mov    $0x0,%esi
  800fc2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fca:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff0:	89 cb                	mov    %ecx,%ebx
  800ff2:	89 cf                	mov    %ecx,%edi
  800ff4:	89 ce                	mov    %ecx,%esi
  800ff6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	7e 17                	jle    801013 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	50                   	push   %eax
  801000:	6a 0d                	push   $0xd
  801002:	68 cf 28 80 00       	push   $0x8028cf
  801007:	6a 23                	push   $0x23
  801009:	68 ec 28 80 00       	push   $0x8028ec
  80100e:	e8 c3 f2 ff ff       	call   8002d6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801013:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801021:	ba 00 00 00 00       	mov    $0x0,%edx
  801026:	b8 0e 00 00 00       	mov    $0xe,%eax
  80102b:	89 d1                	mov    %edx,%ecx
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 d7                	mov    %edx,%edi
  801031:	89 d6                	mov    %edx,%esi
  801033:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801040:	bb 00 00 00 00       	mov    $0x0,%ebx
  801045:	b8 0f 00 00 00       	mov    $0xf,%eax
  80104a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104d:	8b 55 08             	mov    0x8(%ebp),%edx
  801050:	89 df                	mov    %ebx,%edi
  801052:	89 de                	mov    %ebx,%esi
  801054:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80105e:	8b 45 08             	mov    0x8(%ebp),%eax
  801061:	05 00 00 00 30       	add    $0x30000000,%eax
  801066:	c1 e8 0c             	shr    $0xc,%eax
}
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
  801071:	05 00 00 00 30       	add    $0x30000000,%eax
  801076:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80107b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801088:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80108d:	89 c2                	mov    %eax,%edx
  80108f:	c1 ea 16             	shr    $0x16,%edx
  801092:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801099:	f6 c2 01             	test   $0x1,%dl
  80109c:	74 11                	je     8010af <fd_alloc+0x2d>
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	c1 ea 0c             	shr    $0xc,%edx
  8010a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010aa:	f6 c2 01             	test   $0x1,%dl
  8010ad:	75 09                	jne    8010b8 <fd_alloc+0x36>
			*fd_store = fd;
  8010af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b6:	eb 17                	jmp    8010cf <fd_alloc+0x4d>
  8010b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c2:	75 c9                	jne    80108d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d7:	83 f8 1f             	cmp    $0x1f,%eax
  8010da:	77 36                	ja     801112 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010dc:	c1 e0 0c             	shl    $0xc,%eax
  8010df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	c1 ea 16             	shr    $0x16,%edx
  8010e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f0:	f6 c2 01             	test   $0x1,%dl
  8010f3:	74 24                	je     801119 <fd_lookup+0x48>
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	c1 ea 0c             	shr    $0xc,%edx
  8010fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801101:	f6 c2 01             	test   $0x1,%dl
  801104:	74 1a                	je     801120 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801106:	8b 55 0c             	mov    0xc(%ebp),%edx
  801109:	89 02                	mov    %eax,(%edx)
	return 0;
  80110b:	b8 00 00 00 00       	mov    $0x0,%eax
  801110:	eb 13                	jmp    801125 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801112:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801117:	eb 0c                	jmp    801125 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801119:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111e:	eb 05                	jmp    801125 <fd_lookup+0x54>
  801120:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801130:	ba 7c 29 80 00       	mov    $0x80297c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801135:	eb 13                	jmp    80114a <dev_lookup+0x23>
  801137:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80113a:	39 08                	cmp    %ecx,(%eax)
  80113c:	75 0c                	jne    80114a <dev_lookup+0x23>
			*dev = devtab[i];
  80113e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801141:	89 01                	mov    %eax,(%ecx)
			return 0;
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
  801148:	eb 2e                	jmp    801178 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80114a:	8b 02                	mov    (%edx),%eax
  80114c:	85 c0                	test   %eax,%eax
  80114e:	75 e7                	jne    801137 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801150:	a1 08 44 80 00       	mov    0x804408,%eax
  801155:	8b 40 48             	mov    0x48(%eax),%eax
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	51                   	push   %ecx
  80115c:	50                   	push   %eax
  80115d:	68 fc 28 80 00       	push   $0x8028fc
  801162:	e8 48 f2 ff ff       	call   8003af <cprintf>
	*dev = 0;
  801167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
  80117f:	83 ec 10             	sub    $0x10,%esp
  801182:	8b 75 08             	mov    0x8(%ebp),%esi
  801185:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801188:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118b:	50                   	push   %eax
  80118c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801192:	c1 e8 0c             	shr    $0xc,%eax
  801195:	50                   	push   %eax
  801196:	e8 36 ff ff ff       	call   8010d1 <fd_lookup>
  80119b:	83 c4 08             	add    $0x8,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 05                	js     8011a7 <fd_close+0x2d>
	    || fd != fd2)
  8011a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a5:	74 0c                	je     8011b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011a7:	84 db                	test   %bl,%bl
  8011a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ae:	0f 44 c2             	cmove  %edx,%eax
  8011b1:	eb 41                	jmp    8011f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	ff 36                	pushl  (%esi)
  8011bc:	e8 66 ff ff ff       	call   801127 <dev_lookup>
  8011c1:	89 c3                	mov    %eax,%ebx
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 1a                	js     8011e4 <fd_close+0x6a>
		if (dev->dev_close)
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	74 0b                	je     8011e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	56                   	push   %esi
  8011dd:	ff d0                	call   *%eax
  8011df:	89 c3                	mov    %eax,%ebx
  8011e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	56                   	push   %esi
  8011e8:	6a 00                	push   $0x0
  8011ea:	e8 c0 fc ff ff       	call   800eaf <sys_page_unmap>
	return r;
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	89 d8                	mov    %ebx,%eax
}
  8011f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	ff 75 08             	pushl  0x8(%ebp)
  801208:	e8 c4 fe ff ff       	call   8010d1 <fd_lookup>
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 10                	js     801224 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	6a 01                	push   $0x1
  801219:	ff 75 f4             	pushl  -0xc(%ebp)
  80121c:	e8 59 ff ff ff       	call   80117a <fd_close>
  801221:	83 c4 10             	add    $0x10,%esp
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <close_all>:

void
close_all(void)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	53                   	push   %ebx
  801236:	e8 c0 ff ff ff       	call   8011fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80123b:	83 c3 01             	add    $0x1,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	83 fb 20             	cmp    $0x20,%ebx
  801244:	75 ec                	jne    801232 <close_all+0xc>
		close(i);
}
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 2c             	sub    $0x2c,%esp
  801254:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801257:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 75 08             	pushl  0x8(%ebp)
  80125e:	e8 6e fe ff ff       	call   8010d1 <fd_lookup>
  801263:	83 c4 08             	add    $0x8,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	0f 88 c1 00 00 00    	js     80132f <dup+0xe4>
		return r;
	close(newfdnum);
  80126e:	83 ec 0c             	sub    $0xc,%esp
  801271:	56                   	push   %esi
  801272:	e8 84 ff ff ff       	call   8011fb <close>

	newfd = INDEX2FD(newfdnum);
  801277:	89 f3                	mov    %esi,%ebx
  801279:	c1 e3 0c             	shl    $0xc,%ebx
  80127c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801282:	83 c4 04             	add    $0x4,%esp
  801285:	ff 75 e4             	pushl  -0x1c(%ebp)
  801288:	e8 de fd ff ff       	call   80106b <fd2data>
  80128d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80128f:	89 1c 24             	mov    %ebx,(%esp)
  801292:	e8 d4 fd ff ff       	call   80106b <fd2data>
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129d:	89 f8                	mov    %edi,%eax
  80129f:	c1 e8 16             	shr    $0x16,%eax
  8012a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a9:	a8 01                	test   $0x1,%al
  8012ab:	74 37                	je     8012e4 <dup+0x99>
  8012ad:	89 f8                	mov    %edi,%eax
  8012af:	c1 e8 0c             	shr    $0xc,%eax
  8012b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	74 26                	je     8012e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cd:	50                   	push   %eax
  8012ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d1:	6a 00                	push   $0x0
  8012d3:	57                   	push   %edi
  8012d4:	6a 00                	push   $0x0
  8012d6:	e8 92 fb ff ff       	call   800e6d <sys_page_map>
  8012db:	89 c7                	mov    %eax,%edi
  8012dd:	83 c4 20             	add    $0x20,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 2e                	js     801312 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e7:	89 d0                	mov    %edx,%eax
  8012e9:	c1 e8 0c             	shr    $0xc,%eax
  8012ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fb:	50                   	push   %eax
  8012fc:	53                   	push   %ebx
  8012fd:	6a 00                	push   $0x0
  8012ff:	52                   	push   %edx
  801300:	6a 00                	push   $0x0
  801302:	e8 66 fb ff ff       	call   800e6d <sys_page_map>
  801307:	89 c7                	mov    %eax,%edi
  801309:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80130c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130e:	85 ff                	test   %edi,%edi
  801310:	79 1d                	jns    80132f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	53                   	push   %ebx
  801316:	6a 00                	push   $0x0
  801318:	e8 92 fb ff ff       	call   800eaf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131d:	83 c4 08             	add    $0x8,%esp
  801320:	ff 75 d4             	pushl  -0x2c(%ebp)
  801323:	6a 00                	push   $0x0
  801325:	e8 85 fb ff ff       	call   800eaf <sys_page_unmap>
	return r;
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	89 f8                	mov    %edi,%eax
}
  80132f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	53                   	push   %ebx
  80133b:	83 ec 14             	sub    $0x14,%esp
  80133e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801341:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	53                   	push   %ebx
  801346:	e8 86 fd ff ff       	call   8010d1 <fd_lookup>
  80134b:	83 c4 08             	add    $0x8,%esp
  80134e:	89 c2                	mov    %eax,%edx
  801350:	85 c0                	test   %eax,%eax
  801352:	78 6d                	js     8013c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135e:	ff 30                	pushl  (%eax)
  801360:	e8 c2 fd ff ff       	call   801127 <dev_lookup>
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 4c                	js     8013b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80136f:	8b 42 08             	mov    0x8(%edx),%eax
  801372:	83 e0 03             	and    $0x3,%eax
  801375:	83 f8 01             	cmp    $0x1,%eax
  801378:	75 21                	jne    80139b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137a:	a1 08 44 80 00       	mov    0x804408,%eax
  80137f:	8b 40 48             	mov    0x48(%eax),%eax
  801382:	83 ec 04             	sub    $0x4,%esp
  801385:	53                   	push   %ebx
  801386:	50                   	push   %eax
  801387:	68 40 29 80 00       	push   $0x802940
  80138c:	e8 1e f0 ff ff       	call   8003af <cprintf>
		return -E_INVAL;
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801399:	eb 26                	jmp    8013c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139e:	8b 40 08             	mov    0x8(%eax),%eax
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	74 17                	je     8013bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	ff 75 10             	pushl  0x10(%ebp)
  8013ab:	ff 75 0c             	pushl  0xc(%ebp)
  8013ae:	52                   	push   %edx
  8013af:	ff d0                	call   *%eax
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	eb 09                	jmp    8013c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b8:	89 c2                	mov    %eax,%edx
  8013ba:	eb 05                	jmp    8013c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013c1:	89 d0                	mov    %edx,%eax
  8013c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	57                   	push   %edi
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013dc:	eb 21                	jmp    8013ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013de:	83 ec 04             	sub    $0x4,%esp
  8013e1:	89 f0                	mov    %esi,%eax
  8013e3:	29 d8                	sub    %ebx,%eax
  8013e5:	50                   	push   %eax
  8013e6:	89 d8                	mov    %ebx,%eax
  8013e8:	03 45 0c             	add    0xc(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	57                   	push   %edi
  8013ed:	e8 45 ff ff ff       	call   801337 <read>
		if (m < 0)
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 10                	js     801409 <readn+0x41>
			return m;
		if (m == 0)
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	74 0a                	je     801407 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fd:	01 c3                	add    %eax,%ebx
  8013ff:	39 f3                	cmp    %esi,%ebx
  801401:	72 db                	jb     8013de <readn+0x16>
  801403:	89 d8                	mov    %ebx,%eax
  801405:	eb 02                	jmp    801409 <readn+0x41>
  801407:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801409:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140c:	5b                   	pop    %ebx
  80140d:	5e                   	pop    %esi
  80140e:	5f                   	pop    %edi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	53                   	push   %ebx
  801415:	83 ec 14             	sub    $0x14,%esp
  801418:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	53                   	push   %ebx
  801420:	e8 ac fc ff ff       	call   8010d1 <fd_lookup>
  801425:	83 c4 08             	add    $0x8,%esp
  801428:	89 c2                	mov    %eax,%edx
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 68                	js     801496 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801438:	ff 30                	pushl  (%eax)
  80143a:	e8 e8 fc ff ff       	call   801127 <dev_lookup>
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 47                	js     80148d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801446:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801449:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144d:	75 21                	jne    801470 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80144f:	a1 08 44 80 00       	mov    0x804408,%eax
  801454:	8b 40 48             	mov    0x48(%eax),%eax
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	53                   	push   %ebx
  80145b:	50                   	push   %eax
  80145c:	68 5c 29 80 00       	push   $0x80295c
  801461:	e8 49 ef ff ff       	call   8003af <cprintf>
		return -E_INVAL;
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146e:	eb 26                	jmp    801496 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801470:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801473:	8b 52 0c             	mov    0xc(%edx),%edx
  801476:	85 d2                	test   %edx,%edx
  801478:	74 17                	je     801491 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	ff 75 10             	pushl  0x10(%ebp)
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	50                   	push   %eax
  801484:	ff d2                	call   *%edx
  801486:	89 c2                	mov    %eax,%edx
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb 09                	jmp    801496 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	eb 05                	jmp    801496 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801491:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801496:	89 d0                	mov    %edx,%eax
  801498:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <seek>:

int
seek(int fdnum, off_t offset)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	ff 75 08             	pushl  0x8(%ebp)
  8014aa:	e8 22 fc ff ff       	call   8010d1 <fd_lookup>
  8014af:	83 c4 08             	add    $0x8,%esp
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 0e                	js     8014c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	53                   	push   %ebx
  8014ca:	83 ec 14             	sub    $0x14,%esp
  8014cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	53                   	push   %ebx
  8014d5:	e8 f7 fb ff ff       	call   8010d1 <fd_lookup>
  8014da:	83 c4 08             	add    $0x8,%esp
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 65                	js     801548 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e9:	50                   	push   %eax
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	ff 30                	pushl  (%eax)
  8014ef:	e8 33 fc ff ff       	call   801127 <dev_lookup>
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 44                	js     80153f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801502:	75 21                	jne    801525 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801504:	a1 08 44 80 00       	mov    0x804408,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801509:	8b 40 48             	mov    0x48(%eax),%eax
  80150c:	83 ec 04             	sub    $0x4,%esp
  80150f:	53                   	push   %ebx
  801510:	50                   	push   %eax
  801511:	68 1c 29 80 00       	push   $0x80291c
  801516:	e8 94 ee ff ff       	call   8003af <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801523:	eb 23                	jmp    801548 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801525:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801528:	8b 52 18             	mov    0x18(%edx),%edx
  80152b:	85 d2                	test   %edx,%edx
  80152d:	74 14                	je     801543 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	ff 75 0c             	pushl  0xc(%ebp)
  801535:	50                   	push   %eax
  801536:	ff d2                	call   *%edx
  801538:	89 c2                	mov    %eax,%edx
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	eb 09                	jmp    801548 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153f:	89 c2                	mov    %eax,%edx
  801541:	eb 05                	jmp    801548 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801543:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801548:	89 d0                	mov    %edx,%eax
  80154a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	53                   	push   %ebx
  801553:	83 ec 14             	sub    $0x14,%esp
  801556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801559:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	ff 75 08             	pushl  0x8(%ebp)
  801560:	e8 6c fb ff ff       	call   8010d1 <fd_lookup>
  801565:	83 c4 08             	add    $0x8,%esp
  801568:	89 c2                	mov    %eax,%edx
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 58                	js     8015c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801578:	ff 30                	pushl  (%eax)
  80157a:	e8 a8 fb ff ff       	call   801127 <dev_lookup>
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 37                	js     8015bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801586:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801589:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80158d:	74 32                	je     8015c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80158f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801592:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801599:	00 00 00 
	stat->st_isdir = 0;
  80159c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a3:	00 00 00 
	stat->st_dev = dev;
  8015a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b3:	ff 50 14             	call   *0x14(%eax)
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	eb 09                	jmp    8015c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	eb 05                	jmp    8015c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015c6:	89 d0                	mov    %edx,%eax
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	6a 00                	push   $0x0
  8015d7:	ff 75 08             	pushl  0x8(%ebp)
  8015da:	e8 e7 01 00 00       	call   8017c6 <open>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 1b                	js     801603 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ee:	50                   	push   %eax
  8015ef:	e8 5b ff ff ff       	call   80154f <fstat>
  8015f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f6:	89 1c 24             	mov    %ebx,(%esp)
  8015f9:	e8 fd fb ff ff       	call   8011fb <close>
	return r;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	89 f0                	mov    %esi,%eax
}
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	89 c6                	mov    %eax,%esi
  801611:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801613:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80161a:	75 12                	jne    80162e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	6a 01                	push   $0x1
  801621:	e8 d8 0b 00 00       	call   8021fe <ipc_find_env>
  801626:	a3 00 44 80 00       	mov    %eax,0x804400
  80162b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80162e:	6a 07                	push   $0x7
  801630:	68 00 50 80 00       	push   $0x805000
  801635:	56                   	push   %esi
  801636:	ff 35 00 44 80 00    	pushl  0x804400
  80163c:	e8 69 0b 00 00       	call   8021aa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801641:	83 c4 0c             	add    $0xc,%esp
  801644:	6a 00                	push   $0x0
  801646:	53                   	push   %ebx
  801647:	6a 00                	push   $0x0
  801649:	e8 ef 0a 00 00       	call   80213d <ipc_recv>
}
  80164e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80165b:	8b 45 08             	mov    0x8(%ebp),%eax
  80165e:	8b 40 0c             	mov    0xc(%eax),%eax
  801661:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801666:	8b 45 0c             	mov    0xc(%ebp),%eax
  801669:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80166e:	ba 00 00 00 00       	mov    $0x0,%edx
  801673:	b8 02 00 00 00       	mov    $0x2,%eax
  801678:	e8 8d ff ff ff       	call   80160a <fsipc>
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801685:	8b 45 08             	mov    0x8(%ebp),%eax
  801688:	8b 40 0c             	mov    0xc(%eax),%eax
  80168b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801690:	ba 00 00 00 00       	mov    $0x0,%edx
  801695:	b8 06 00 00 00       	mov    $0x6,%eax
  80169a:	e8 6b ff ff ff       	call   80160a <fsipc>
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 04             	sub    $0x4,%esp
  8016a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c0:	e8 45 ff ff ff       	call   80160a <fsipc>
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 2c                	js     8016f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	68 00 50 80 00       	push   $0x805000
  8016d1:	53                   	push   %ebx
  8016d2:	e8 50 f3 ff ff       	call   800a27 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8016dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801704:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801709:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80170e:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801711:	53                   	push   %ebx
  801712:	ff 75 0c             	pushl  0xc(%ebp)
  801715:	68 08 50 80 00       	push   $0x805008
  80171a:	e8 9a f4 ff ff       	call   800bb9 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80171f:	8b 45 08             	mov    0x8(%ebp),%eax
  801722:	8b 40 0c             	mov    0xc(%eax),%eax
  801725:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  80172a:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801730:	ba 00 00 00 00       	mov    $0x0,%edx
  801735:	b8 04 00 00 00       	mov    $0x4,%eax
  80173a:	e8 cb fe ff ff       	call   80160a <fsipc>
	//panic("devfile_write not implemented");
}
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
  801749:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	8b 40 0c             	mov    0xc(%eax),%eax
  801752:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801757:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 03 00 00 00       	mov    $0x3,%eax
  801767:	e8 9e fe ff ff       	call   80160a <fsipc>
  80176c:	89 c3                	mov    %eax,%ebx
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 4b                	js     8017bd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801772:	39 c6                	cmp    %eax,%esi
  801774:	73 16                	jae    80178c <devfile_read+0x48>
  801776:	68 90 29 80 00       	push   $0x802990
  80177b:	68 97 29 80 00       	push   $0x802997
  801780:	6a 7c                	push   $0x7c
  801782:	68 ac 29 80 00       	push   $0x8029ac
  801787:	e8 4a eb ff ff       	call   8002d6 <_panic>
	assert(r <= PGSIZE);
  80178c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801791:	7e 16                	jle    8017a9 <devfile_read+0x65>
  801793:	68 b7 29 80 00       	push   $0x8029b7
  801798:	68 97 29 80 00       	push   $0x802997
  80179d:	6a 7d                	push   $0x7d
  80179f:	68 ac 29 80 00       	push   $0x8029ac
  8017a4:	e8 2d eb ff ff       	call   8002d6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a9:	83 ec 04             	sub    $0x4,%esp
  8017ac:	50                   	push   %eax
  8017ad:	68 00 50 80 00       	push   $0x805000
  8017b2:	ff 75 0c             	pushl  0xc(%ebp)
  8017b5:	e8 ff f3 ff ff       	call   800bb9 <memmove>
	return r;
  8017ba:	83 c4 10             	add    $0x10,%esp
}
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 20             	sub    $0x20,%esp
  8017cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017d0:	53                   	push   %ebx
  8017d1:	e8 18 f2 ff ff       	call   8009ee <strlen>
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017de:	7f 67                	jg     801847 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e0:	83 ec 0c             	sub    $0xc,%esp
  8017e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e6:	50                   	push   %eax
  8017e7:	e8 96 f8 ff ff       	call   801082 <fd_alloc>
  8017ec:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ef:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 57                	js     80184c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	53                   	push   %ebx
  8017f9:	68 00 50 80 00       	push   $0x805000
  8017fe:	e8 24 f2 ff ff       	call   800a27 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801803:	8b 45 0c             	mov    0xc(%ebp),%eax
  801806:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80180b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180e:	b8 01 00 00 00       	mov    $0x1,%eax
  801813:	e8 f2 fd ff ff       	call   80160a <fsipc>
  801818:	89 c3                	mov    %eax,%ebx
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	79 14                	jns    801835 <open+0x6f>
		fd_close(fd, 0);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	6a 00                	push   $0x0
  801826:	ff 75 f4             	pushl  -0xc(%ebp)
  801829:	e8 4c f9 ff ff       	call   80117a <fd_close>
		return r;
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	89 da                	mov    %ebx,%edx
  801833:	eb 17                	jmp    80184c <open+0x86>
	}

	return fd2num(fd);
  801835:	83 ec 0c             	sub    $0xc,%esp
  801838:	ff 75 f4             	pushl  -0xc(%ebp)
  80183b:	e8 1b f8 ff ff       	call   80105b <fd2num>
  801840:	89 c2                	mov    %eax,%edx
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	eb 05                	jmp    80184c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801847:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80184c:	89 d0                	mov    %edx,%eax
  80184e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	b8 08 00 00 00       	mov    $0x8,%eax
  801863:	e8 a2 fd ff ff       	call   80160a <fsipc>
}
  801868:	c9                   	leave  
  801869:	c3                   	ret    

0080186a <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80186a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80186e:	7e 37                	jle    8018a7 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	53                   	push   %ebx
  801874:	83 ec 08             	sub    $0x8,%esp
  801877:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801879:	ff 70 04             	pushl  0x4(%eax)
  80187c:	8d 40 10             	lea    0x10(%eax),%eax
  80187f:	50                   	push   %eax
  801880:	ff 33                	pushl  (%ebx)
  801882:	e8 8a fb ff ff       	call   801411 <write>
		if (result > 0)
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	7e 03                	jle    801891 <writebuf+0x27>
			b->result += result;
  80188e:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801891:	3b 43 04             	cmp    0x4(%ebx),%eax
  801894:	74 0d                	je     8018a3 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801896:	85 c0                	test   %eax,%eax
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	0f 4f c2             	cmovg  %edx,%eax
  8018a0:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a6:	c9                   	leave  
  8018a7:	f3 c3                	repz ret 

008018a9 <putch>:

static void
putch(int ch, void *thunk)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 04             	sub    $0x4,%esp
  8018b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018b3:	8b 53 04             	mov    0x4(%ebx),%edx
  8018b6:	8d 42 01             	lea    0x1(%edx),%eax
  8018b9:	89 43 04             	mov    %eax,0x4(%ebx)
  8018bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018bf:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018c3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018c8:	75 0e                	jne    8018d8 <putch+0x2f>
		writebuf(b);
  8018ca:	89 d8                	mov    %ebx,%eax
  8018cc:	e8 99 ff ff ff       	call   80186a <writebuf>
		b->idx = 0;
  8018d1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018d8:	83 c4 04             	add    $0x4,%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018f0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018f7:	00 00 00 
	b.result = 0;
  8018fa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801901:	00 00 00 
	b.error = 1;
  801904:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80190b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80190e:	ff 75 10             	pushl  0x10(%ebp)
  801911:	ff 75 0c             	pushl  0xc(%ebp)
  801914:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	68 a9 18 80 00       	push   $0x8018a9
  801920:	e8 c1 eb ff ff       	call   8004e6 <vprintfmt>
	if (b.idx > 0)
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80192f:	7e 0b                	jle    80193c <vfprintf+0x5e>
		writebuf(&b);
  801931:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801937:	e8 2e ff ff ff       	call   80186a <writebuf>

	return (b.result ? b.result : b.error);
  80193c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801942:	85 c0                	test   %eax,%eax
  801944:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801953:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801956:	50                   	push   %eax
  801957:	ff 75 0c             	pushl  0xc(%ebp)
  80195a:	ff 75 08             	pushl  0x8(%ebp)
  80195d:	e8 7c ff ff ff       	call   8018de <vfprintf>
	va_end(ap);

	return cnt;
}
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <printf>:

int
printf(const char *fmt, ...)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80196a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80196d:	50                   	push   %eax
  80196e:	ff 75 08             	pushl  0x8(%ebp)
  801971:	6a 01                	push   $0x1
  801973:	e8 66 ff ff ff       	call   8018de <vfprintf>
	va_end(ap);

	return cnt;
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801980:	68 c3 29 80 00       	push   $0x8029c3
  801985:	ff 75 0c             	pushl  0xc(%ebp)
  801988:	e8 9a f0 ff ff       	call   800a27 <strcpy>
	return 0;
}
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	53                   	push   %ebx
  801998:	83 ec 10             	sub    $0x10,%esp
  80199b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80199e:	53                   	push   %ebx
  80199f:	e8 93 08 00 00       	call   802237 <pageref>
  8019a4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019a7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019ac:	83 f8 01             	cmp    $0x1,%eax
  8019af:	75 10                	jne    8019c1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019b1:	83 ec 0c             	sub    $0xc,%esp
  8019b4:	ff 73 0c             	pushl  0xc(%ebx)
  8019b7:	e8 c0 02 00 00       	call   801c7c <nsipc_close>
  8019bc:	89 c2                	mov    %eax,%edx
  8019be:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019c1:	89 d0                	mov    %edx,%eax
  8019c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019ce:	6a 00                	push   $0x0
  8019d0:	ff 75 10             	pushl  0x10(%ebp)
  8019d3:	ff 75 0c             	pushl  0xc(%ebp)
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	ff 70 0c             	pushl  0xc(%eax)
  8019dc:	e8 78 03 00 00       	call   801d59 <nsipc_send>
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019e9:	6a 00                	push   $0x0
  8019eb:	ff 75 10             	pushl  0x10(%ebp)
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	ff 70 0c             	pushl  0xc(%eax)
  8019f7:	e8 f1 02 00 00       	call   801ced <nsipc_recv>
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a04:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a07:	52                   	push   %edx
  801a08:	50                   	push   %eax
  801a09:	e8 c3 f6 ff ff       	call   8010d1 <fd_lookup>
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	85 c0                	test   %eax,%eax
  801a13:	78 17                	js     801a2c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a18:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801a1e:	39 08                	cmp    %ecx,(%eax)
  801a20:	75 05                	jne    801a27 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a22:	8b 40 0c             	mov    0xc(%eax),%eax
  801a25:	eb 05                	jmp    801a2c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a27:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	83 ec 1c             	sub    $0x1c,%esp
  801a36:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3b:	50                   	push   %eax
  801a3c:	e8 41 f6 ff ff       	call   801082 <fd_alloc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 1b                	js     801a65 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a4a:	83 ec 04             	sub    $0x4,%esp
  801a4d:	68 07 04 00 00       	push   $0x407
  801a52:	ff 75 f4             	pushl  -0xc(%ebp)
  801a55:	6a 00                	push   $0x0
  801a57:	e8 ce f3 ff ff       	call   800e2a <sys_page_alloc>
  801a5c:	89 c3                	mov    %eax,%ebx
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 c0                	test   %eax,%eax
  801a63:	79 10                	jns    801a75 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	56                   	push   %esi
  801a69:	e8 0e 02 00 00       	call   801c7c <nsipc_close>
		return r;
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	89 d8                	mov    %ebx,%eax
  801a73:	eb 24                	jmp    801a99 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a75:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a83:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a8a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	50                   	push   %eax
  801a91:	e8 c5 f5 ff ff       	call   80105b <fd2num>
  801a96:	83 c4 10             	add    $0x10,%esp
}
  801a99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    

00801aa0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	e8 50 ff ff ff       	call   8019fe <fd2sockid>
		return r;
  801aae:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 1f                	js     801ad3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ab4:	83 ec 04             	sub    $0x4,%esp
  801ab7:	ff 75 10             	pushl  0x10(%ebp)
  801aba:	ff 75 0c             	pushl  0xc(%ebp)
  801abd:	50                   	push   %eax
  801abe:	e8 12 01 00 00       	call   801bd5 <nsipc_accept>
  801ac3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	78 07                	js     801ad3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801acc:	e8 5d ff ff ff       	call   801a2e <alloc_sockfd>
  801ad1:	89 c1                	mov    %eax,%ecx
}
  801ad3:	89 c8                	mov    %ecx,%eax
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801add:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae0:	e8 19 ff ff ff       	call   8019fe <fd2sockid>
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 12                	js     801afb <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ae9:	83 ec 04             	sub    $0x4,%esp
  801aec:	ff 75 10             	pushl  0x10(%ebp)
  801aef:	ff 75 0c             	pushl  0xc(%ebp)
  801af2:	50                   	push   %eax
  801af3:	e8 2d 01 00 00       	call   801c25 <nsipc_bind>
  801af8:	83 c4 10             	add    $0x10,%esp
}
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    

00801afd <shutdown>:

int
shutdown(int s, int how)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	e8 f3 fe ff ff       	call   8019fe <fd2sockid>
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 0f                	js     801b1e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b0f:	83 ec 08             	sub    $0x8,%esp
  801b12:	ff 75 0c             	pushl  0xc(%ebp)
  801b15:	50                   	push   %eax
  801b16:	e8 3f 01 00 00       	call   801c5a <nsipc_shutdown>
  801b1b:	83 c4 10             	add    $0x10,%esp
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	e8 d0 fe ff ff       	call   8019fe <fd2sockid>
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	78 12                	js     801b44 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	ff 75 10             	pushl  0x10(%ebp)
  801b38:	ff 75 0c             	pushl  0xc(%ebp)
  801b3b:	50                   	push   %eax
  801b3c:	e8 55 01 00 00       	call   801c96 <nsipc_connect>
  801b41:	83 c4 10             	add    $0x10,%esp
}
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <listen>:

int
listen(int s, int backlog)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4f:	e8 aa fe ff ff       	call   8019fe <fd2sockid>
  801b54:	85 c0                	test   %eax,%eax
  801b56:	78 0f                	js     801b67 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	ff 75 0c             	pushl  0xc(%ebp)
  801b5e:	50                   	push   %eax
  801b5f:	e8 67 01 00 00       	call   801ccb <nsipc_listen>
  801b64:	83 c4 10             	add    $0x10,%esp
}
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b6f:	ff 75 10             	pushl  0x10(%ebp)
  801b72:	ff 75 0c             	pushl  0xc(%ebp)
  801b75:	ff 75 08             	pushl  0x8(%ebp)
  801b78:	e8 3a 02 00 00       	call   801db7 <nsipc_socket>
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 05                	js     801b89 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b84:	e8 a5 fe ff ff       	call   801a2e <alloc_sockfd>
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	53                   	push   %ebx
  801b8f:	83 ec 04             	sub    $0x4,%esp
  801b92:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b94:	83 3d 04 44 80 00 00 	cmpl   $0x0,0x804404
  801b9b:	75 12                	jne    801baf <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	6a 02                	push   $0x2
  801ba2:	e8 57 06 00 00       	call   8021fe <ipc_find_env>
  801ba7:	a3 04 44 80 00       	mov    %eax,0x804404
  801bac:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801baf:	6a 07                	push   $0x7
  801bb1:	68 00 60 80 00       	push   $0x806000
  801bb6:	53                   	push   %ebx
  801bb7:	ff 35 04 44 80 00    	pushl  0x804404
  801bbd:	e8 e8 05 00 00       	call   8021aa <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bc2:	83 c4 0c             	add    $0xc,%esp
  801bc5:	6a 00                	push   $0x0
  801bc7:	6a 00                	push   $0x0
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 6d 05 00 00       	call   80213d <ipc_recv>
}
  801bd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	56                   	push   %esi
  801bd9:	53                   	push   %ebx
  801bda:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801be0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801be5:	8b 06                	mov    (%esi),%eax
  801be7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bec:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf1:	e8 95 ff ff ff       	call   801b8b <nsipc>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	78 20                	js     801c1c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bfc:	83 ec 04             	sub    $0x4,%esp
  801bff:	ff 35 10 60 80 00    	pushl  0x806010
  801c05:	68 00 60 80 00       	push   $0x806000
  801c0a:	ff 75 0c             	pushl  0xc(%ebp)
  801c0d:	e8 a7 ef ff ff       	call   800bb9 <memmove>
		*addrlen = ret->ret_addrlen;
  801c12:	a1 10 60 80 00       	mov    0x806010,%eax
  801c17:	89 06                	mov    %eax,(%esi)
  801c19:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c21:	5b                   	pop    %ebx
  801c22:	5e                   	pop    %esi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	53                   	push   %ebx
  801c29:	83 ec 08             	sub    $0x8,%esp
  801c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c32:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c37:	53                   	push   %ebx
  801c38:	ff 75 0c             	pushl  0xc(%ebp)
  801c3b:	68 04 60 80 00       	push   $0x806004
  801c40:	e8 74 ef ff ff       	call   800bb9 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c45:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c4b:	b8 02 00 00 00       	mov    $0x2,%eax
  801c50:	e8 36 ff ff ff       	call   801b8b <nsipc>
}
  801c55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c70:	b8 03 00 00 00       	mov    $0x3,%eax
  801c75:	e8 11 ff ff ff       	call   801b8b <nsipc>
}
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <nsipc_close>:

int
nsipc_close(int s)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c8a:	b8 04 00 00 00       	mov    $0x4,%eax
  801c8f:	e8 f7 fe ff ff       	call   801b8b <nsipc>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	53                   	push   %ebx
  801c9a:	83 ec 08             	sub    $0x8,%esp
  801c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ca8:	53                   	push   %ebx
  801ca9:	ff 75 0c             	pushl  0xc(%ebp)
  801cac:	68 04 60 80 00       	push   $0x806004
  801cb1:	e8 03 ef ff ff       	call   800bb9 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cb6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cbc:	b8 05 00 00 00       	mov    $0x5,%eax
  801cc1:	e8 c5 fe ff ff       	call   801b8b <nsipc>
}
  801cc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ce1:	b8 06 00 00 00       	mov    $0x6,%eax
  801ce6:	e8 a0 fe ff ff       	call   801b8b <nsipc>
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
  801cf2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cfd:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d03:	8b 45 14             	mov    0x14(%ebp),%eax
  801d06:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d0b:	b8 07 00 00 00       	mov    $0x7,%eax
  801d10:	e8 76 fe ff ff       	call   801b8b <nsipc>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 35                	js     801d50 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d1b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d20:	7f 04                	jg     801d26 <nsipc_recv+0x39>
  801d22:	39 c6                	cmp    %eax,%esi
  801d24:	7d 16                	jge    801d3c <nsipc_recv+0x4f>
  801d26:	68 cf 29 80 00       	push   $0x8029cf
  801d2b:	68 97 29 80 00       	push   $0x802997
  801d30:	6a 62                	push   $0x62
  801d32:	68 e4 29 80 00       	push   $0x8029e4
  801d37:	e8 9a e5 ff ff       	call   8002d6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d3c:	83 ec 04             	sub    $0x4,%esp
  801d3f:	50                   	push   %eax
  801d40:	68 00 60 80 00       	push   $0x806000
  801d45:	ff 75 0c             	pushl  0xc(%ebp)
  801d48:	e8 6c ee ff ff       	call   800bb9 <memmove>
  801d4d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    

00801d59 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	53                   	push   %ebx
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d63:	8b 45 08             	mov    0x8(%ebp),%eax
  801d66:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d6b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d71:	7e 16                	jle    801d89 <nsipc_send+0x30>
  801d73:	68 f0 29 80 00       	push   $0x8029f0
  801d78:	68 97 29 80 00       	push   $0x802997
  801d7d:	6a 6d                	push   $0x6d
  801d7f:	68 e4 29 80 00       	push   $0x8029e4
  801d84:	e8 4d e5 ff ff       	call   8002d6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d89:	83 ec 04             	sub    $0x4,%esp
  801d8c:	53                   	push   %ebx
  801d8d:	ff 75 0c             	pushl  0xc(%ebp)
  801d90:	68 0c 60 80 00       	push   $0x80600c
  801d95:	e8 1f ee ff ff       	call   800bb9 <memmove>
	nsipcbuf.send.req_size = size;
  801d9a:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801da0:	8b 45 14             	mov    0x14(%ebp),%eax
  801da3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801da8:	b8 08 00 00 00       	mov    $0x8,%eax
  801dad:	e8 d9 fd ff ff       	call   801b8b <nsipc>
}
  801db2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dcd:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dd5:	b8 09 00 00 00       	mov    $0x9,%eax
  801dda:	e8 ac fd ff ff       	call   801b8b <nsipc>
}
  801ddf:	c9                   	leave  
  801de0:	c3                   	ret    

00801de1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801de9:	83 ec 0c             	sub    $0xc,%esp
  801dec:	ff 75 08             	pushl  0x8(%ebp)
  801def:	e8 77 f2 ff ff       	call   80106b <fd2data>
  801df4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801df6:	83 c4 08             	add    $0x8,%esp
  801df9:	68 fc 29 80 00       	push   $0x8029fc
  801dfe:	53                   	push   %ebx
  801dff:	e8 23 ec ff ff       	call   800a27 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e04:	8b 46 04             	mov    0x4(%esi),%eax
  801e07:	2b 06                	sub    (%esi),%eax
  801e09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e0f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e16:	00 00 00 
	stat->st_dev = &devpipe;
  801e19:	c7 83 88 00 00 00 58 	movl   $0x803058,0x88(%ebx)
  801e20:	30 80 00 
	return 0;
}
  801e23:	b8 00 00 00 00       	mov    $0x0,%eax
  801e28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2b:	5b                   	pop    %ebx
  801e2c:	5e                   	pop    %esi
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    

00801e2f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	53                   	push   %ebx
  801e33:	83 ec 0c             	sub    $0xc,%esp
  801e36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e39:	53                   	push   %ebx
  801e3a:	6a 00                	push   $0x0
  801e3c:	e8 6e f0 ff ff       	call   800eaf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e41:	89 1c 24             	mov    %ebx,(%esp)
  801e44:	e8 22 f2 ff ff       	call   80106b <fd2data>
  801e49:	83 c4 08             	add    $0x8,%esp
  801e4c:	50                   	push   %eax
  801e4d:	6a 00                	push   $0x0
  801e4f:	e8 5b f0 ff ff       	call   800eaf <sys_page_unmap>
}
  801e54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	57                   	push   %edi
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	83 ec 1c             	sub    $0x1c,%esp
  801e62:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e65:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e67:	a1 08 44 80 00       	mov    0x804408,%eax
  801e6c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	ff 75 e0             	pushl  -0x20(%ebp)
  801e75:	e8 bd 03 00 00       	call   802237 <pageref>
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	89 3c 24             	mov    %edi,(%esp)
  801e7f:	e8 b3 03 00 00       	call   802237 <pageref>
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	39 c3                	cmp    %eax,%ebx
  801e89:	0f 94 c1             	sete   %cl
  801e8c:	0f b6 c9             	movzbl %cl,%ecx
  801e8f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e92:	8b 15 08 44 80 00    	mov    0x804408,%edx
  801e98:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e9b:	39 ce                	cmp    %ecx,%esi
  801e9d:	74 1b                	je     801eba <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e9f:	39 c3                	cmp    %eax,%ebx
  801ea1:	75 c4                	jne    801e67 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ea3:	8b 42 58             	mov    0x58(%edx),%eax
  801ea6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ea9:	50                   	push   %eax
  801eaa:	56                   	push   %esi
  801eab:	68 03 2a 80 00       	push   $0x802a03
  801eb0:	e8 fa e4 ff ff       	call   8003af <cprintf>
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	eb ad                	jmp    801e67 <_pipeisclosed+0xe>
	}
}
  801eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ebd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec0:	5b                   	pop    %ebx
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    

00801ec5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	57                   	push   %edi
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 28             	sub    $0x28,%esp
  801ece:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ed1:	56                   	push   %esi
  801ed2:	e8 94 f1 ff ff       	call   80106b <fd2data>
  801ed7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	bf 00 00 00 00       	mov    $0x0,%edi
  801ee1:	eb 4b                	jmp    801f2e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ee3:	89 da                	mov    %ebx,%edx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	e8 6d ff ff ff       	call   801e59 <_pipeisclosed>
  801eec:	85 c0                	test   %eax,%eax
  801eee:	75 48                	jne    801f38 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ef0:	e8 16 ef ff ff       	call   800e0b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ef5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ef8:	8b 0b                	mov    (%ebx),%ecx
  801efa:	8d 51 20             	lea    0x20(%ecx),%edx
  801efd:	39 d0                	cmp    %edx,%eax
  801eff:	73 e2                	jae    801ee3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f04:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f08:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f0b:	89 c2                	mov    %eax,%edx
  801f0d:	c1 fa 1f             	sar    $0x1f,%edx
  801f10:	89 d1                	mov    %edx,%ecx
  801f12:	c1 e9 1b             	shr    $0x1b,%ecx
  801f15:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f18:	83 e2 1f             	and    $0x1f,%edx
  801f1b:	29 ca                	sub    %ecx,%edx
  801f1d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f21:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f25:	83 c0 01             	add    $0x1,%eax
  801f28:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2b:	83 c7 01             	add    $0x1,%edi
  801f2e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f31:	75 c2                	jne    801ef5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f33:	8b 45 10             	mov    0x10(%ebp),%eax
  801f36:	eb 05                	jmp    801f3d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f38:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5f                   	pop    %edi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    

00801f45 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	57                   	push   %edi
  801f49:	56                   	push   %esi
  801f4a:	53                   	push   %ebx
  801f4b:	83 ec 18             	sub    $0x18,%esp
  801f4e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f51:	57                   	push   %edi
  801f52:	e8 14 f1 ff ff       	call   80106b <fd2data>
  801f57:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f61:	eb 3d                	jmp    801fa0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f63:	85 db                	test   %ebx,%ebx
  801f65:	74 04                	je     801f6b <devpipe_read+0x26>
				return i;
  801f67:	89 d8                	mov    %ebx,%eax
  801f69:	eb 44                	jmp    801faf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f6b:	89 f2                	mov    %esi,%edx
  801f6d:	89 f8                	mov    %edi,%eax
  801f6f:	e8 e5 fe ff ff       	call   801e59 <_pipeisclosed>
  801f74:	85 c0                	test   %eax,%eax
  801f76:	75 32                	jne    801faa <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f78:	e8 8e ee ff ff       	call   800e0b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f7d:	8b 06                	mov    (%esi),%eax
  801f7f:	3b 46 04             	cmp    0x4(%esi),%eax
  801f82:	74 df                	je     801f63 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f84:	99                   	cltd   
  801f85:	c1 ea 1b             	shr    $0x1b,%edx
  801f88:	01 d0                	add    %edx,%eax
  801f8a:	83 e0 1f             	and    $0x1f,%eax
  801f8d:	29 d0                	sub    %edx,%eax
  801f8f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f97:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f9a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f9d:	83 c3 01             	add    $0x1,%ebx
  801fa0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fa3:	75 d8                	jne    801f7d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fa5:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa8:	eb 05                	jmp    801faf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801faa:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb2:	5b                   	pop    %ebx
  801fb3:	5e                   	pop    %esi
  801fb4:	5f                   	pop    %edi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	56                   	push   %esi
  801fbb:	53                   	push   %ebx
  801fbc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc2:	50                   	push   %eax
  801fc3:	e8 ba f0 ff ff       	call   801082 <fd_alloc>
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	89 c2                	mov    %eax,%edx
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	0f 88 2c 01 00 00    	js     802101 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd5:	83 ec 04             	sub    $0x4,%esp
  801fd8:	68 07 04 00 00       	push   $0x407
  801fdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe0:	6a 00                	push   $0x0
  801fe2:	e8 43 ee ff ff       	call   800e2a <sys_page_alloc>
  801fe7:	83 c4 10             	add    $0x10,%esp
  801fea:	89 c2                	mov    %eax,%edx
  801fec:	85 c0                	test   %eax,%eax
  801fee:	0f 88 0d 01 00 00    	js     802101 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ff4:	83 ec 0c             	sub    $0xc,%esp
  801ff7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ffa:	50                   	push   %eax
  801ffb:	e8 82 f0 ff ff       	call   801082 <fd_alloc>
  802000:	89 c3                	mov    %eax,%ebx
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	0f 88 e2 00 00 00    	js     8020ef <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200d:	83 ec 04             	sub    $0x4,%esp
  802010:	68 07 04 00 00       	push   $0x407
  802015:	ff 75 f0             	pushl  -0x10(%ebp)
  802018:	6a 00                	push   $0x0
  80201a:	e8 0b ee ff ff       	call   800e2a <sys_page_alloc>
  80201f:	89 c3                	mov    %eax,%ebx
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	85 c0                	test   %eax,%eax
  802026:	0f 88 c3 00 00 00    	js     8020ef <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80202c:	83 ec 0c             	sub    $0xc,%esp
  80202f:	ff 75 f4             	pushl  -0xc(%ebp)
  802032:	e8 34 f0 ff ff       	call   80106b <fd2data>
  802037:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802039:	83 c4 0c             	add    $0xc,%esp
  80203c:	68 07 04 00 00       	push   $0x407
  802041:	50                   	push   %eax
  802042:	6a 00                	push   $0x0
  802044:	e8 e1 ed ff ff       	call   800e2a <sys_page_alloc>
  802049:	89 c3                	mov    %eax,%ebx
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	85 c0                	test   %eax,%eax
  802050:	0f 88 89 00 00 00    	js     8020df <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802056:	83 ec 0c             	sub    $0xc,%esp
  802059:	ff 75 f0             	pushl  -0x10(%ebp)
  80205c:	e8 0a f0 ff ff       	call   80106b <fd2data>
  802061:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802068:	50                   	push   %eax
  802069:	6a 00                	push   $0x0
  80206b:	56                   	push   %esi
  80206c:	6a 00                	push   $0x0
  80206e:	e8 fa ed ff ff       	call   800e6d <sys_page_map>
  802073:	89 c3                	mov    %eax,%ebx
  802075:	83 c4 20             	add    $0x20,%esp
  802078:	85 c0                	test   %eax,%eax
  80207a:	78 55                	js     8020d1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80207c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802085:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802087:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802091:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802097:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80209a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80209c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80209f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020a6:	83 ec 0c             	sub    $0xc,%esp
  8020a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ac:	e8 aa ef ff ff       	call   80105b <fd2num>
  8020b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020b6:	83 c4 04             	add    $0x4,%esp
  8020b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8020bc:	e8 9a ef ff ff       	call   80105b <fd2num>
  8020c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020c7:	83 c4 10             	add    $0x10,%esp
  8020ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8020cf:	eb 30                	jmp    802101 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020d1:	83 ec 08             	sub    $0x8,%esp
  8020d4:	56                   	push   %esi
  8020d5:	6a 00                	push   $0x0
  8020d7:	e8 d3 ed ff ff       	call   800eaf <sys_page_unmap>
  8020dc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020df:	83 ec 08             	sub    $0x8,%esp
  8020e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020e5:	6a 00                	push   $0x0
  8020e7:	e8 c3 ed ff ff       	call   800eaf <sys_page_unmap>
  8020ec:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020ef:	83 ec 08             	sub    $0x8,%esp
  8020f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f5:	6a 00                	push   $0x0
  8020f7:	e8 b3 ed ff ff       	call   800eaf <sys_page_unmap>
  8020fc:	83 c4 10             	add    $0x10,%esp
  8020ff:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802101:	89 d0                	mov    %edx,%eax
  802103:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802106:	5b                   	pop    %ebx
  802107:	5e                   	pop    %esi
  802108:	5d                   	pop    %ebp
  802109:	c3                   	ret    

0080210a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80210a:	55                   	push   %ebp
  80210b:	89 e5                	mov    %esp,%ebp
  80210d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802110:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802113:	50                   	push   %eax
  802114:	ff 75 08             	pushl  0x8(%ebp)
  802117:	e8 b5 ef ff ff       	call   8010d1 <fd_lookup>
  80211c:	83 c4 10             	add    $0x10,%esp
  80211f:	85 c0                	test   %eax,%eax
  802121:	78 18                	js     80213b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802123:	83 ec 0c             	sub    $0xc,%esp
  802126:	ff 75 f4             	pushl  -0xc(%ebp)
  802129:	e8 3d ef ff ff       	call   80106b <fd2data>
	return _pipeisclosed(fd, p);
  80212e:	89 c2                	mov    %eax,%edx
  802130:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802133:	e8 21 fd ff ff       	call   801e59 <_pipeisclosed>
  802138:	83 c4 10             	add    $0x10,%esp
}
  80213b:	c9                   	leave  
  80213c:	c3                   	ret    

0080213d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	56                   	push   %esi
  802141:	53                   	push   %ebx
  802142:	8b 75 08             	mov    0x8(%ebp),%esi
  802145:	8b 45 0c             	mov    0xc(%ebp),%eax
  802148:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  80214b:	85 c0                	test   %eax,%eax
  80214d:	74 0e                	je     80215d <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  80214f:	83 ec 0c             	sub    $0xc,%esp
  802152:	50                   	push   %eax
  802153:	e8 82 ee ff ff       	call   800fda <sys_ipc_recv>
  802158:	83 c4 10             	add    $0x10,%esp
  80215b:	eb 10                	jmp    80216d <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80215d:	83 ec 0c             	sub    $0xc,%esp
  802160:	68 00 00 00 f0       	push   $0xf0000000
  802165:	e8 70 ee ff ff       	call   800fda <sys_ipc_recv>
  80216a:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80216d:	85 c0                	test   %eax,%eax
  80216f:	74 0e                	je     80217f <ipc_recv+0x42>
    	*from_env_store = 0;
  802171:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802177:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  80217d:	eb 24                	jmp    8021a3 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  80217f:	85 f6                	test   %esi,%esi
  802181:	74 0a                	je     80218d <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802183:	a1 08 44 80 00       	mov    0x804408,%eax
  802188:	8b 40 74             	mov    0x74(%eax),%eax
  80218b:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  80218d:	85 db                	test   %ebx,%ebx
  80218f:	74 0a                	je     80219b <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802191:	a1 08 44 80 00       	mov    0x804408,%eax
  802196:	8b 40 78             	mov    0x78(%eax),%eax
  802199:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  80219b:	a1 08 44 80 00       	mov    0x804408,%eax
  8021a0:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8021a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a6:	5b                   	pop    %ebx
  8021a7:	5e                   	pop    %esi
  8021a8:	5d                   	pop    %ebp
  8021a9:	c3                   	ret    

008021aa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	57                   	push   %edi
  8021ae:	56                   	push   %esi
  8021af:	53                   	push   %ebx
  8021b0:	83 ec 0c             	sub    $0xc,%esp
  8021b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8021bc:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8021be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8021c3:	0f 44 d8             	cmove  %eax,%ebx
  8021c6:	eb 1c                	jmp    8021e4 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8021c8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021cb:	74 12                	je     8021df <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8021cd:	50                   	push   %eax
  8021ce:	68 1b 2a 80 00       	push   $0x802a1b
  8021d3:	6a 4b                	push   $0x4b
  8021d5:	68 33 2a 80 00       	push   $0x802a33
  8021da:	e8 f7 e0 ff ff       	call   8002d6 <_panic>
        }	
        sys_yield();
  8021df:	e8 27 ec ff ff       	call   800e0b <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8021e4:	ff 75 14             	pushl  0x14(%ebp)
  8021e7:	53                   	push   %ebx
  8021e8:	56                   	push   %esi
  8021e9:	57                   	push   %edi
  8021ea:	e8 c8 ed ff ff       	call   800fb7 <sys_ipc_try_send>
  8021ef:	83 c4 10             	add    $0x10,%esp
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	75 d2                	jne    8021c8 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8021f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f9:	5b                   	pop    %ebx
  8021fa:	5e                   	pop    %esi
  8021fb:	5f                   	pop    %edi
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    

008021fe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802204:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802209:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80220c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802212:	8b 52 50             	mov    0x50(%edx),%edx
  802215:	39 ca                	cmp    %ecx,%edx
  802217:	75 0d                	jne    802226 <ipc_find_env+0x28>
			return envs[i].env_id;
  802219:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80221c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802221:	8b 40 48             	mov    0x48(%eax),%eax
  802224:	eb 0f                	jmp    802235 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802226:	83 c0 01             	add    $0x1,%eax
  802229:	3d 00 04 00 00       	cmp    $0x400,%eax
  80222e:	75 d9                	jne    802209 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802230:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802235:	5d                   	pop    %ebp
  802236:	c3                   	ret    

00802237 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80223d:	89 d0                	mov    %edx,%eax
  80223f:	c1 e8 16             	shr    $0x16,%eax
  802242:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802249:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80224e:	f6 c1 01             	test   $0x1,%cl
  802251:	74 1d                	je     802270 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802253:	c1 ea 0c             	shr    $0xc,%edx
  802256:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80225d:	f6 c2 01             	test   $0x1,%dl
  802260:	74 0e                	je     802270 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802262:	c1 ea 0c             	shr    $0xc,%edx
  802265:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80226c:	ef 
  80226d:	0f b7 c0             	movzwl %ax,%eax
}
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	66 90                	xchg   %ax,%ax
  802274:	66 90                	xchg   %ax,%ax
  802276:	66 90                	xchg   %ax,%ax
  802278:	66 90                	xchg   %ax,%ax
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <__udivdi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80228b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80228f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802297:	85 f6                	test   %esi,%esi
  802299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80229d:	89 ca                	mov    %ecx,%edx
  80229f:	89 f8                	mov    %edi,%eax
  8022a1:	75 3d                	jne    8022e0 <__udivdi3+0x60>
  8022a3:	39 cf                	cmp    %ecx,%edi
  8022a5:	0f 87 c5 00 00 00    	ja     802370 <__udivdi3+0xf0>
  8022ab:	85 ff                	test   %edi,%edi
  8022ad:	89 fd                	mov    %edi,%ebp
  8022af:	75 0b                	jne    8022bc <__udivdi3+0x3c>
  8022b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b6:	31 d2                	xor    %edx,%edx
  8022b8:	f7 f7                	div    %edi
  8022ba:	89 c5                	mov    %eax,%ebp
  8022bc:	89 c8                	mov    %ecx,%eax
  8022be:	31 d2                	xor    %edx,%edx
  8022c0:	f7 f5                	div    %ebp
  8022c2:	89 c1                	mov    %eax,%ecx
  8022c4:	89 d8                	mov    %ebx,%eax
  8022c6:	89 cf                	mov    %ecx,%edi
  8022c8:	f7 f5                	div    %ebp
  8022ca:	89 c3                	mov    %eax,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	39 ce                	cmp    %ecx,%esi
  8022e2:	77 74                	ja     802358 <__udivdi3+0xd8>
  8022e4:	0f bd fe             	bsr    %esi,%edi
  8022e7:	83 f7 1f             	xor    $0x1f,%edi
  8022ea:	0f 84 98 00 00 00    	je     802388 <__udivdi3+0x108>
  8022f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	89 c5                	mov    %eax,%ebp
  8022f9:	29 fb                	sub    %edi,%ebx
  8022fb:	d3 e6                	shl    %cl,%esi
  8022fd:	89 d9                	mov    %ebx,%ecx
  8022ff:	d3 ed                	shr    %cl,%ebp
  802301:	89 f9                	mov    %edi,%ecx
  802303:	d3 e0                	shl    %cl,%eax
  802305:	09 ee                	or     %ebp,%esi
  802307:	89 d9                	mov    %ebx,%ecx
  802309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80230d:	89 d5                	mov    %edx,%ebp
  80230f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802313:	d3 ed                	shr    %cl,%ebp
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e2                	shl    %cl,%edx
  802319:	89 d9                	mov    %ebx,%ecx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	09 c2                	or     %eax,%edx
  80231f:	89 d0                	mov    %edx,%eax
  802321:	89 ea                	mov    %ebp,%edx
  802323:	f7 f6                	div    %esi
  802325:	89 d5                	mov    %edx,%ebp
  802327:	89 c3                	mov    %eax,%ebx
  802329:	f7 64 24 0c          	mull   0xc(%esp)
  80232d:	39 d5                	cmp    %edx,%ebp
  80232f:	72 10                	jb     802341 <__udivdi3+0xc1>
  802331:	8b 74 24 08          	mov    0x8(%esp),%esi
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e6                	shl    %cl,%esi
  802339:	39 c6                	cmp    %eax,%esi
  80233b:	73 07                	jae    802344 <__udivdi3+0xc4>
  80233d:	39 d5                	cmp    %edx,%ebp
  80233f:	75 03                	jne    802344 <__udivdi3+0xc4>
  802341:	83 eb 01             	sub    $0x1,%ebx
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 d8                	mov    %ebx,%eax
  802348:	89 fa                	mov    %edi,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	31 ff                	xor    %edi,%edi
  80235a:	31 db                	xor    %ebx,%ebx
  80235c:	89 d8                	mov    %ebx,%eax
  80235e:	89 fa                	mov    %edi,%edx
  802360:	83 c4 1c             	add    $0x1c,%esp
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    
  802368:	90                   	nop
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	89 d8                	mov    %ebx,%eax
  802372:	f7 f7                	div    %edi
  802374:	31 ff                	xor    %edi,%edi
  802376:	89 c3                	mov    %eax,%ebx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 fa                	mov    %edi,%edx
  80237c:	83 c4 1c             	add    $0x1c,%esp
  80237f:	5b                   	pop    %ebx
  802380:	5e                   	pop    %esi
  802381:	5f                   	pop    %edi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    
  802384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802388:	39 ce                	cmp    %ecx,%esi
  80238a:	72 0c                	jb     802398 <__udivdi3+0x118>
  80238c:	31 db                	xor    %ebx,%ebx
  80238e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802392:	0f 87 34 ff ff ff    	ja     8022cc <__udivdi3+0x4c>
  802398:	bb 01 00 00 00       	mov    $0x1,%ebx
  80239d:	e9 2a ff ff ff       	jmp    8022cc <__udivdi3+0x4c>
  8023a2:	66 90                	xchg   %ax,%ax
  8023a4:	66 90                	xchg   %ax,%ax
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	66 90                	xchg   %ax,%ax
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 1c             	sub    $0x1c,%esp
  8023b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023c7:	85 d2                	test   %edx,%edx
  8023c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023d1:	89 f3                	mov    %esi,%ebx
  8023d3:	89 3c 24             	mov    %edi,(%esp)
  8023d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023da:	75 1c                	jne    8023f8 <__umoddi3+0x48>
  8023dc:	39 f7                	cmp    %esi,%edi
  8023de:	76 50                	jbe    802430 <__umoddi3+0x80>
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	f7 f7                	div    %edi
  8023e6:	89 d0                	mov    %edx,%eax
  8023e8:	31 d2                	xor    %edx,%edx
  8023ea:	83 c4 1c             	add    $0x1c,%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    
  8023f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f8:	39 f2                	cmp    %esi,%edx
  8023fa:	89 d0                	mov    %edx,%eax
  8023fc:	77 52                	ja     802450 <__umoddi3+0xa0>
  8023fe:	0f bd ea             	bsr    %edx,%ebp
  802401:	83 f5 1f             	xor    $0x1f,%ebp
  802404:	75 5a                	jne    802460 <__umoddi3+0xb0>
  802406:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80240a:	0f 82 e0 00 00 00    	jb     8024f0 <__umoddi3+0x140>
  802410:	39 0c 24             	cmp    %ecx,(%esp)
  802413:	0f 86 d7 00 00 00    	jbe    8024f0 <__umoddi3+0x140>
  802419:	8b 44 24 08          	mov    0x8(%esp),%eax
  80241d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	85 ff                	test   %edi,%edi
  802432:	89 fd                	mov    %edi,%ebp
  802434:	75 0b                	jne    802441 <__umoddi3+0x91>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f7                	div    %edi
  80243f:	89 c5                	mov    %eax,%ebp
  802441:	89 f0                	mov    %esi,%eax
  802443:	31 d2                	xor    %edx,%edx
  802445:	f7 f5                	div    %ebp
  802447:	89 c8                	mov    %ecx,%eax
  802449:	f7 f5                	div    %ebp
  80244b:	89 d0                	mov    %edx,%eax
  80244d:	eb 99                	jmp    8023e8 <__umoddi3+0x38>
  80244f:	90                   	nop
  802450:	89 c8                	mov    %ecx,%eax
  802452:	89 f2                	mov    %esi,%edx
  802454:	83 c4 1c             	add    $0x1c,%esp
  802457:	5b                   	pop    %ebx
  802458:	5e                   	pop    %esi
  802459:	5f                   	pop    %edi
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    
  80245c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802460:	8b 34 24             	mov    (%esp),%esi
  802463:	bf 20 00 00 00       	mov    $0x20,%edi
  802468:	89 e9                	mov    %ebp,%ecx
  80246a:	29 ef                	sub    %ebp,%edi
  80246c:	d3 e0                	shl    %cl,%eax
  80246e:	89 f9                	mov    %edi,%ecx
  802470:	89 f2                	mov    %esi,%edx
  802472:	d3 ea                	shr    %cl,%edx
  802474:	89 e9                	mov    %ebp,%ecx
  802476:	09 c2                	or     %eax,%edx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 14 24             	mov    %edx,(%esp)
  80247d:	89 f2                	mov    %esi,%edx
  80247f:	d3 e2                	shl    %cl,%edx
  802481:	89 f9                	mov    %edi,%ecx
  802483:	89 54 24 04          	mov    %edx,0x4(%esp)
  802487:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	89 e9                	mov    %ebp,%ecx
  80248f:	89 c6                	mov    %eax,%esi
  802491:	d3 e3                	shl    %cl,%ebx
  802493:	89 f9                	mov    %edi,%ecx
  802495:	89 d0                	mov    %edx,%eax
  802497:	d3 e8                	shr    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	09 d8                	or     %ebx,%eax
  80249d:	89 d3                	mov    %edx,%ebx
  80249f:	89 f2                	mov    %esi,%edx
  8024a1:	f7 34 24             	divl   (%esp)
  8024a4:	89 d6                	mov    %edx,%esi
  8024a6:	d3 e3                	shl    %cl,%ebx
  8024a8:	f7 64 24 04          	mull   0x4(%esp)
  8024ac:	39 d6                	cmp    %edx,%esi
  8024ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b2:	89 d1                	mov    %edx,%ecx
  8024b4:	89 c3                	mov    %eax,%ebx
  8024b6:	72 08                	jb     8024c0 <__umoddi3+0x110>
  8024b8:	75 11                	jne    8024cb <__umoddi3+0x11b>
  8024ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024be:	73 0b                	jae    8024cb <__umoddi3+0x11b>
  8024c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024c4:	1b 14 24             	sbb    (%esp),%edx
  8024c7:	89 d1                	mov    %edx,%ecx
  8024c9:	89 c3                	mov    %eax,%ebx
  8024cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024cf:	29 da                	sub    %ebx,%edx
  8024d1:	19 ce                	sbb    %ecx,%esi
  8024d3:	89 f9                	mov    %edi,%ecx
  8024d5:	89 f0                	mov    %esi,%eax
  8024d7:	d3 e0                	shl    %cl,%eax
  8024d9:	89 e9                	mov    %ebp,%ecx
  8024db:	d3 ea                	shr    %cl,%edx
  8024dd:	89 e9                	mov    %ebp,%ecx
  8024df:	d3 ee                	shr    %cl,%esi
  8024e1:	09 d0                	or     %edx,%eax
  8024e3:	89 f2                	mov    %esi,%edx
  8024e5:	83 c4 1c             	add    $0x1c,%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
  8024f0:	29 f9                	sub    %edi,%ecx
  8024f2:	19 d6                	sbb    %edx,%esi
  8024f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024fc:	e9 18 ff ff ff       	jmp    802419 <__umoddi3+0x69>
