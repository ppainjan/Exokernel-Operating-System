
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 5c 0c 00 00       	call   800ca6 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 00 24 80 00       	push   $0x802400
  800057:	6a 20                	push   $0x20
  800059:	68 13 24 80 00       	push   $0x802413
  80005e:	e8 e2 01 00 00       	call   800245 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 73 0c 00 00       	call   800ce9 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 23 24 80 00       	push   $0x802423
  800083:	6a 22                	push   $0x22
  800085:	68 13 24 80 00       	push   $0x802413
  80008a:	e8 b6 01 00 00       	call   800245 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 93 09 00 00       	call   800a35 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 7a 0c 00 00       	call   800d2b <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 34 24 80 00       	push   $0x802434
  8000be:	6a 25                	push   $0x25
  8000c0:	68 13 24 80 00       	push   $0x802413
  8000c5:	e8 7b 01 00 00       	call   800245 <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 47 24 80 00       	push   $0x802447
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 13 24 80 00       	push   $0x802413
  8000f3:	e8 4d 01 00 00       	call   800245 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 65 0b 00 00       	call   800c68 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 70 80 00    	cmp    $0x807000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 0c 0c 00 00       	call   800d6d <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 57 24 80 00       	push   $0x802457
  80016e:	6a 4c                	push   $0x4c
  800170:	68 13 24 80 00       	push   $0x802413
  800175:	e8 cb 00 00 00       	call   800245 <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 75 24 80 00       	mov    $0x802475,%esi
  80019a:	b8 6e 24 80 00       	mov    $0x80246e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 7b 24 80 00       	push   $0x80247b
  8001b3:	e8 66 01 00 00       	call   80031e <cprintf>
		sys_yield();
  8001b8:	e8 ca 0a 00 00       	call   800c87 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001e6:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8001ed:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8001f0:	e8 73 0a 00 00       	call   800c68 <sys_getenvid>
  8001f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800202:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800207:	85 db                	test   %ebx,%ebx
  800209:	7e 07                	jle    800212 <libmain+0x37>
		binaryname = argv[0];
  80020b:	8b 06                	mov    (%esi),%eax
  80020d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800212:	83 ec 08             	sub    $0x8,%esp
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	e8 67 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  80021c:	e8 0a 00 00 00       	call   80022b <exit>
}
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800231:	e8 6c 0e 00 00       	call   8010a2 <close_all>
	sys_env_destroy(0);
  800236:	83 ec 0c             	sub    $0xc,%esp
  800239:	6a 00                	push   $0x0
  80023b:	e8 e7 09 00 00       	call   800c27 <sys_env_destroy>
}
  800240:	83 c4 10             	add    $0x10,%esp
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80024a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800253:	e8 10 0a 00 00       	call   800c68 <sys_getenvid>
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 0c             	pushl  0xc(%ebp)
  80025e:	ff 75 08             	pushl  0x8(%ebp)
  800261:	56                   	push   %esi
  800262:	50                   	push   %eax
  800263:	68 98 24 80 00       	push   $0x802498
  800268:	e8 b1 00 00 00       	call   80031e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026d:	83 c4 18             	add    $0x18,%esp
  800270:	53                   	push   %ebx
  800271:	ff 75 10             	pushl  0x10(%ebp)
  800274:	e8 54 00 00 00       	call   8002cd <vcprintf>
	cprintf("\n");
  800279:	c7 04 24 8b 24 80 00 	movl   $0x80248b,(%esp)
  800280:	e8 99 00 00 00       	call   80031e <cprintf>
  800285:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800288:	cc                   	int3   
  800289:	eb fd                	jmp    800288 <_panic+0x43>

0080028b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	53                   	push   %ebx
  80028f:	83 ec 04             	sub    $0x4,%esp
  800292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800295:	8b 13                	mov    (%ebx),%edx
  800297:	8d 42 01             	lea    0x1(%edx),%eax
  80029a:	89 03                	mov    %eax,(%ebx)
  80029c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a8:	75 1a                	jne    8002c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	68 ff 00 00 00       	push   $0xff
  8002b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b5:	50                   	push   %eax
  8002b6:	e8 2f 09 00 00       	call   800bea <sys_cputs>
		b->idx = 0;
  8002bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dd:	00 00 00 
	b.cnt = 0;
  8002e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ea:	ff 75 0c             	pushl  0xc(%ebp)
  8002ed:	ff 75 08             	pushl  0x8(%ebp)
  8002f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f6:	50                   	push   %eax
  8002f7:	68 8b 02 80 00       	push   $0x80028b
  8002fc:	e8 54 01 00 00       	call   800455 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800301:	83 c4 08             	add    $0x8,%esp
  800304:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80030a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800310:	50                   	push   %eax
  800311:	e8 d4 08 00 00       	call   800bea <sys_cputs>

	return b.cnt;
}
  800316:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800324:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800327:	50                   	push   %eax
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	e8 9d ff ff ff       	call   8002cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 1c             	sub    $0x1c,%esp
  80033b:	89 c7                	mov    %eax,%edi
  80033d:	89 d6                	mov    %edx,%esi
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	8b 55 0c             	mov    0xc(%ebp),%edx
  800345:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800348:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800353:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800356:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800359:	39 d3                	cmp    %edx,%ebx
  80035b:	72 05                	jb     800362 <printnum+0x30>
  80035d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800360:	77 45                	ja     8003a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800362:	83 ec 0c             	sub    $0xc,%esp
  800365:	ff 75 18             	pushl  0x18(%ebp)
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036e:	53                   	push   %ebx
  80036f:	ff 75 10             	pushl  0x10(%ebp)
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	ff 75 e4             	pushl  -0x1c(%ebp)
  800378:	ff 75 e0             	pushl  -0x20(%ebp)
  80037b:	ff 75 dc             	pushl  -0x24(%ebp)
  80037e:	ff 75 d8             	pushl  -0x28(%ebp)
  800381:	e8 ea 1d 00 00       	call   802170 <__udivdi3>
  800386:	83 c4 18             	add    $0x18,%esp
  800389:	52                   	push   %edx
  80038a:	50                   	push   %eax
  80038b:	89 f2                	mov    %esi,%edx
  80038d:	89 f8                	mov    %edi,%eax
  80038f:	e8 9e ff ff ff       	call   800332 <printnum>
  800394:	83 c4 20             	add    $0x20,%esp
  800397:	eb 18                	jmp    8003b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	56                   	push   %esi
  80039d:	ff 75 18             	pushl  0x18(%ebp)
  8003a0:	ff d7                	call   *%edi
  8003a2:	83 c4 10             	add    $0x10,%esp
  8003a5:	eb 03                	jmp    8003aa <printnum+0x78>
  8003a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003aa:	83 eb 01             	sub    $0x1,%ebx
  8003ad:	85 db                	test   %ebx,%ebx
  8003af:	7f e8                	jg     800399 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	56                   	push   %esi
  8003b5:	83 ec 04             	sub    $0x4,%esp
  8003b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003be:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c4:	e8 d7 1e 00 00       	call   8022a0 <__umoddi3>
  8003c9:	83 c4 14             	add    $0x14,%esp
  8003cc:	0f be 80 bb 24 80 00 	movsbl 0x8024bb(%eax),%eax
  8003d3:	50                   	push   %eax
  8003d4:	ff d7                	call   *%edi
}
  8003d6:	83 c4 10             	add    $0x10,%esp
  8003d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003dc:	5b                   	pop    %ebx
  8003dd:	5e                   	pop    %esi
  8003de:	5f                   	pop    %edi
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    

008003e1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e4:	83 fa 01             	cmp    $0x1,%edx
  8003e7:	7e 0e                	jle    8003f7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 02                	mov    (%edx),%eax
  8003f2:	8b 52 04             	mov    0x4(%edx),%edx
  8003f5:	eb 22                	jmp    800419 <getuint+0x38>
	else if (lflag)
  8003f7:	85 d2                	test   %edx,%edx
  8003f9:	74 10                	je     80040b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fb:	8b 10                	mov    (%eax),%edx
  8003fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800400:	89 08                	mov    %ecx,(%eax)
  800402:	8b 02                	mov    (%edx),%eax
  800404:	ba 00 00 00 00       	mov    $0x0,%edx
  800409:	eb 0e                	jmp    800419 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040b:	8b 10                	mov    (%eax),%edx
  80040d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800410:	89 08                	mov    %ecx,(%eax)
  800412:	8b 02                	mov    (%edx),%eax
  800414:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800421:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800425:	8b 10                	mov    (%eax),%edx
  800427:	3b 50 04             	cmp    0x4(%eax),%edx
  80042a:	73 0a                	jae    800436 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042f:	89 08                	mov    %ecx,(%eax)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	88 02                	mov    %al,(%edx)
}
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800441:	50                   	push   %eax
  800442:	ff 75 10             	pushl  0x10(%ebp)
  800445:	ff 75 0c             	pushl  0xc(%ebp)
  800448:	ff 75 08             	pushl  0x8(%ebp)
  80044b:	e8 05 00 00 00       	call   800455 <vprintfmt>
	va_end(ap);
}
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	c9                   	leave  
  800454:	c3                   	ret    

00800455 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	57                   	push   %edi
  800459:	56                   	push   %esi
  80045a:	53                   	push   %ebx
  80045b:	83 ec 2c             	sub    $0x2c,%esp
  80045e:	8b 75 08             	mov    0x8(%ebp),%esi
  800461:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800464:	8b 7d 10             	mov    0x10(%ebp),%edi
  800467:	eb 12                	jmp    80047b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800469:	85 c0                	test   %eax,%eax
  80046b:	0f 84 89 03 00 00    	je     8007fa <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	50                   	push   %eax
  800476:	ff d6                	call   *%esi
  800478:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047b:	83 c7 01             	add    $0x1,%edi
  80047e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800482:	83 f8 25             	cmp    $0x25,%eax
  800485:	75 e2                	jne    800469 <vprintfmt+0x14>
  800487:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800492:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800499:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a5:	eb 07                	jmp    8004ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8d 47 01             	lea    0x1(%edi),%eax
  8004b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b4:	0f b6 07             	movzbl (%edi),%eax
  8004b7:	0f b6 c8             	movzbl %al,%ecx
  8004ba:	83 e8 23             	sub    $0x23,%eax
  8004bd:	3c 55                	cmp    $0x55,%al
  8004bf:	0f 87 1a 03 00 00    	ja     8007df <vprintfmt+0x38a>
  8004c5:	0f b6 c0             	movzbl %al,%eax
  8004c8:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d6:	eb d6                	jmp    8004ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004db:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004ea:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ed:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004f0:	83 fa 09             	cmp    $0x9,%edx
  8004f3:	77 39                	ja     80052e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f8:	eb e9                	jmp    8004e3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 48 04             	lea    0x4(%eax),%ecx
  800500:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050b:	eb 27                	jmp    800534 <vprintfmt+0xdf>
  80050d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800510:	85 c0                	test   %eax,%eax
  800512:	b9 00 00 00 00       	mov    $0x0,%ecx
  800517:	0f 49 c8             	cmovns %eax,%ecx
  80051a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800520:	eb 8c                	jmp    8004ae <vprintfmt+0x59>
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800525:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052c:	eb 80                	jmp    8004ae <vprintfmt+0x59>
  80052e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800531:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800534:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800538:	0f 89 70 ff ff ff    	jns    8004ae <vprintfmt+0x59>
				width = precision, precision = -1;
  80053e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800541:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800544:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054b:	e9 5e ff ff ff       	jmp    8004ae <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800550:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800556:	e9 53 ff ff ff       	jmp    8004ae <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 50 04             	lea    0x4(%eax),%edx
  800561:	89 55 14             	mov    %edx,0x14(%ebp)
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	ff 30                	pushl  (%eax)
  80056a:	ff d6                	call   *%esi
			break;
  80056c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800572:	e9 04 ff ff ff       	jmp    80047b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	99                   	cltd   
  800583:	31 d0                	xor    %edx,%eax
  800585:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800587:	83 f8 0f             	cmp    $0xf,%eax
  80058a:	7f 0b                	jg     800597 <vprintfmt+0x142>
  80058c:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	75 18                	jne    8005af <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800597:	50                   	push   %eax
  800598:	68 d3 24 80 00       	push   $0x8024d3
  80059d:	53                   	push   %ebx
  80059e:	56                   	push   %esi
  80059f:	e8 94 fe ff ff       	call   800438 <printfmt>
  8005a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005aa:	e9 cc fe ff ff       	jmp    80047b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005af:	52                   	push   %edx
  8005b0:	68 99 28 80 00       	push   $0x802899
  8005b5:	53                   	push   %ebx
  8005b6:	56                   	push   %esi
  8005b7:	e8 7c fe ff ff       	call   800438 <printfmt>
  8005bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c2:	e9 b4 fe ff ff       	jmp    80047b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d2:	85 ff                	test   %edi,%edi
  8005d4:	b8 cc 24 80 00       	mov    $0x8024cc,%eax
  8005d9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e0:	0f 8e 94 00 00 00    	jle    80067a <vprintfmt+0x225>
  8005e6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ea:	0f 84 98 00 00 00    	je     800688 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f6:	57                   	push   %edi
  8005f7:	e8 86 02 00 00       	call   800882 <strnlen>
  8005fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ff:	29 c1                	sub    %eax,%ecx
  800601:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800604:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800607:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800611:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800613:	eb 0f                	jmp    800624 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	ff 75 e0             	pushl  -0x20(%ebp)
  80061c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	83 ef 01             	sub    $0x1,%edi
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	85 ff                	test   %edi,%edi
  800626:	7f ed                	jg     800615 <vprintfmt+0x1c0>
  800628:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	b8 00 00 00 00       	mov    $0x0,%eax
  800635:	0f 49 c1             	cmovns %ecx,%eax
  800638:	29 c1                	sub    %eax,%ecx
  80063a:	89 75 08             	mov    %esi,0x8(%ebp)
  80063d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800640:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800643:	89 cb                	mov    %ecx,%ebx
  800645:	eb 4d                	jmp    800694 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800647:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064b:	74 1b                	je     800668 <vprintfmt+0x213>
  80064d:	0f be c0             	movsbl %al,%eax
  800650:	83 e8 20             	sub    $0x20,%eax
  800653:	83 f8 5e             	cmp    $0x5e,%eax
  800656:	76 10                	jbe    800668 <vprintfmt+0x213>
					putch('?', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	ff 75 0c             	pushl  0xc(%ebp)
  80065e:	6a 3f                	push   $0x3f
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	eb 0d                	jmp    800675 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	ff 75 0c             	pushl  0xc(%ebp)
  80066e:	52                   	push   %edx
  80066f:	ff 55 08             	call   *0x8(%ebp)
  800672:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	83 eb 01             	sub    $0x1,%ebx
  800678:	eb 1a                	jmp    800694 <vprintfmt+0x23f>
  80067a:	89 75 08             	mov    %esi,0x8(%ebp)
  80067d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800680:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800683:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800686:	eb 0c                	jmp    800694 <vprintfmt+0x23f>
  800688:	89 75 08             	mov    %esi,0x8(%ebp)
  80068b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800691:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800694:	83 c7 01             	add    $0x1,%edi
  800697:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069b:	0f be d0             	movsbl %al,%edx
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	74 23                	je     8006c5 <vprintfmt+0x270>
  8006a2:	85 f6                	test   %esi,%esi
  8006a4:	78 a1                	js     800647 <vprintfmt+0x1f2>
  8006a6:	83 ee 01             	sub    $0x1,%esi
  8006a9:	79 9c                	jns    800647 <vprintfmt+0x1f2>
  8006ab:	89 df                	mov    %ebx,%edi
  8006ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b3:	eb 18                	jmp    8006cd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 20                	push   $0x20
  8006bb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 08                	jmp    8006cd <vprintfmt+0x278>
  8006c5:	89 df                	mov    %ebx,%edi
  8006c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cd:	85 ff                	test   %edi,%edi
  8006cf:	7f e4                	jg     8006b5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d4:	e9 a2 fd ff ff       	jmp    80047b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d9:	83 fa 01             	cmp    $0x1,%edx
  8006dc:	7e 16                	jle    8006f4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 08             	lea    0x8(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 50 04             	mov    0x4(%eax),%edx
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f2:	eb 32                	jmp    800726 <vprintfmt+0x2d1>
	else if (lflag)
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	74 18                	je     800710 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800706:	89 c1                	mov    %eax,%ecx
  800708:	c1 f9 1f             	sar    $0x1f,%ecx
  80070b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070e:	eb 16                	jmp    800726 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8d 50 04             	lea    0x4(%eax),%edx
  800716:	89 55 14             	mov    %edx,0x14(%ebp)
  800719:	8b 00                	mov    (%eax),%eax
  80071b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071e:	89 c1                	mov    %eax,%ecx
  800720:	c1 f9 1f             	sar    $0x1f,%ecx
  800723:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800726:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800729:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800731:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800735:	79 74                	jns    8007ab <vprintfmt+0x356>
				putch('-', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 2d                	push   $0x2d
  80073d:	ff d6                	call   *%esi
				num = -(long long) num;
  80073f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800742:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800745:	f7 d8                	neg    %eax
  800747:	83 d2 00             	adc    $0x0,%edx
  80074a:	f7 da                	neg    %edx
  80074c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800754:	eb 55                	jmp    8007ab <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 83 fc ff ff       	call   8003e1 <getuint>
			base = 10;
  80075e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800763:	eb 46                	jmp    8007ab <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800765:	8d 45 14             	lea    0x14(%ebp),%eax
  800768:	e8 74 fc ff ff       	call   8003e1 <getuint>
		        base = 8;
  80076d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800772:	eb 37                	jmp    8007ab <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	53                   	push   %ebx
  800778:	6a 30                	push   $0x30
  80077a:	ff d6                	call   *%esi
			putch('x', putdat);
  80077c:	83 c4 08             	add    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 78                	push   $0x78
  800782:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 50 04             	lea    0x4(%eax),%edx
  80078a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078d:	8b 00                	mov    (%eax),%eax
  80078f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800794:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079c:	eb 0d                	jmp    8007ab <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a1:	e8 3b fc ff ff       	call   8003e1 <getuint>
			base = 16;
  8007a6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ab:	83 ec 0c             	sub    $0xc,%esp
  8007ae:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b2:	57                   	push   %edi
  8007b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b6:	51                   	push   %ecx
  8007b7:	52                   	push   %edx
  8007b8:	50                   	push   %eax
  8007b9:	89 da                	mov    %ebx,%edx
  8007bb:	89 f0                	mov    %esi,%eax
  8007bd:	e8 70 fb ff ff       	call   800332 <printnum>
			break;
  8007c2:	83 c4 20             	add    $0x20,%esp
  8007c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c8:	e9 ae fc ff ff       	jmp    80047b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	53                   	push   %ebx
  8007d1:	51                   	push   %ecx
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007da:	e9 9c fc ff ff       	jmp    80047b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	6a 25                	push   $0x25
  8007e5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	eb 03                	jmp    8007ef <vprintfmt+0x39a>
  8007ec:	83 ef 01             	sub    $0x1,%edi
  8007ef:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f3:	75 f7                	jne    8007ec <vprintfmt+0x397>
  8007f5:	e9 81 fc ff ff       	jmp    80047b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 18             	sub    $0x18,%esp
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800811:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800815:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800818:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081f:	85 c0                	test   %eax,%eax
  800821:	74 26                	je     800849 <vsnprintf+0x47>
  800823:	85 d2                	test   %edx,%edx
  800825:	7e 22                	jle    800849 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800827:	ff 75 14             	pushl  0x14(%ebp)
  80082a:	ff 75 10             	pushl  0x10(%ebp)
  80082d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800830:	50                   	push   %eax
  800831:	68 1b 04 80 00       	push   $0x80041b
  800836:	e8 1a fc ff ff       	call   800455 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800841:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 05                	jmp    80084e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800849:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800859:	50                   	push   %eax
  80085a:	ff 75 10             	pushl  0x10(%ebp)
  80085d:	ff 75 0c             	pushl  0xc(%ebp)
  800860:	ff 75 08             	pushl  0x8(%ebp)
  800863:	e8 9a ff ff ff       	call   800802 <vsnprintf>
	va_end(ap);

	return rc;
}
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
  800875:	eb 03                	jmp    80087a <strlen+0x10>
		n++;
  800877:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80087a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087e:	75 f7                	jne    800877 <strlen+0xd>
		n++;
	return n;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	ba 00 00 00 00       	mov    $0x0,%edx
  800890:	eb 03                	jmp    800895 <strnlen+0x13>
		n++;
  800892:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	39 c2                	cmp    %eax,%edx
  800897:	74 08                	je     8008a1 <strnlen+0x1f>
  800899:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089d:	75 f3                	jne    800892 <strnlen+0x10>
  80089f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	83 c2 01             	add    $0x1,%edx
  8008b2:	83 c1 01             	add    $0x1,%ecx
  8008b5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bc:	84 db                	test   %bl,%bl
  8008be:	75 ef                	jne    8008af <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ca:	53                   	push   %ebx
  8008cb:	e8 9a ff ff ff       	call   80086a <strlen>
  8008d0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d3:	ff 75 0c             	pushl  0xc(%ebp)
  8008d6:	01 d8                	add    %ebx,%eax
  8008d8:	50                   	push   %eax
  8008d9:	e8 c5 ff ff ff       	call   8008a3 <strcpy>
	return dst;
}
  8008de:	89 d8                	mov    %ebx,%eax
  8008e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	89 f3                	mov    %esi,%ebx
  8008f2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	89 f2                	mov    %esi,%edx
  8008f7:	eb 0f                	jmp    800908 <strncpy+0x23>
		*dst++ = *src;
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	0f b6 01             	movzbl (%ecx),%eax
  8008ff:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800902:	80 39 01             	cmpb   $0x1,(%ecx)
  800905:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800908:	39 da                	cmp    %ebx,%edx
  80090a:	75 ed                	jne    8008f9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090c:	89 f0                	mov    %esi,%eax
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	8b 55 10             	mov    0x10(%ebp),%edx
  800920:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800922:	85 d2                	test   %edx,%edx
  800924:	74 21                	je     800947 <strlcpy+0x35>
  800926:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80092a:	89 f2                	mov    %esi,%edx
  80092c:	eb 09                	jmp    800937 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092e:	83 c2 01             	add    $0x1,%edx
  800931:	83 c1 01             	add    $0x1,%ecx
  800934:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800937:	39 c2                	cmp    %eax,%edx
  800939:	74 09                	je     800944 <strlcpy+0x32>
  80093b:	0f b6 19             	movzbl (%ecx),%ebx
  80093e:	84 db                	test   %bl,%bl
  800940:	75 ec                	jne    80092e <strlcpy+0x1c>
  800942:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800944:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800947:	29 f0                	sub    %esi,%eax
}
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800956:	eb 06                	jmp    80095e <strcmp+0x11>
		p++, q++;
  800958:	83 c1 01             	add    $0x1,%ecx
  80095b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095e:	0f b6 01             	movzbl (%ecx),%eax
  800961:	84 c0                	test   %al,%al
  800963:	74 04                	je     800969 <strcmp+0x1c>
  800965:	3a 02                	cmp    (%edx),%al
  800967:	74 ef                	je     800958 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800969:	0f b6 c0             	movzbl %al,%eax
  80096c:	0f b6 12             	movzbl (%edx),%edx
  80096f:	29 d0                	sub    %edx,%eax
}
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097d:	89 c3                	mov    %eax,%ebx
  80097f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800982:	eb 06                	jmp    80098a <strncmp+0x17>
		n--, p++, q++;
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098a:	39 d8                	cmp    %ebx,%eax
  80098c:	74 15                	je     8009a3 <strncmp+0x30>
  80098e:	0f b6 08             	movzbl (%eax),%ecx
  800991:	84 c9                	test   %cl,%cl
  800993:	74 04                	je     800999 <strncmp+0x26>
  800995:	3a 0a                	cmp    (%edx),%cl
  800997:	74 eb                	je     800984 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800999:	0f b6 00             	movzbl (%eax),%eax
  80099c:	0f b6 12             	movzbl (%edx),%edx
  80099f:	29 d0                	sub    %edx,%eax
  8009a1:	eb 05                	jmp    8009a8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	eb 07                	jmp    8009be <strchr+0x13>
		if (*s == c)
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	74 0f                	je     8009ca <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	0f b6 10             	movzbl (%eax),%edx
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	75 f2                	jne    8009b7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d6:	eb 03                	jmp    8009db <strfind+0xf>
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009de:	38 ca                	cmp    %cl,%dl
  8009e0:	74 04                	je     8009e6 <strfind+0x1a>
  8009e2:	84 d2                	test   %dl,%dl
  8009e4:	75 f2                	jne    8009d8 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f4:	85 c9                	test   %ecx,%ecx
  8009f6:	74 36                	je     800a2e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fe:	75 28                	jne    800a28 <memset+0x40>
  800a00:	f6 c1 03             	test   $0x3,%cl
  800a03:	75 23                	jne    800a28 <memset+0x40>
		c &= 0xFF;
  800a05:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a09:	89 d3                	mov    %edx,%ebx
  800a0b:	c1 e3 08             	shl    $0x8,%ebx
  800a0e:	89 d6                	mov    %edx,%esi
  800a10:	c1 e6 18             	shl    $0x18,%esi
  800a13:	89 d0                	mov    %edx,%eax
  800a15:	c1 e0 10             	shl    $0x10,%eax
  800a18:	09 f0                	or     %esi,%eax
  800a1a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a1c:	89 d8                	mov    %ebx,%eax
  800a1e:	09 d0                	or     %edx,%eax
  800a20:	c1 e9 02             	shr    $0x2,%ecx
  800a23:	fc                   	cld    
  800a24:	f3 ab                	rep stos %eax,%es:(%edi)
  800a26:	eb 06                	jmp    800a2e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2b:	fc                   	cld    
  800a2c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2e:	89 f8                	mov    %edi,%eax
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a43:	39 c6                	cmp    %eax,%esi
  800a45:	73 35                	jae    800a7c <memmove+0x47>
  800a47:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	73 2e                	jae    800a7c <memmove+0x47>
		s += n;
		d += n;
  800a4e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a51:	89 d6                	mov    %edx,%esi
  800a53:	09 fe                	or     %edi,%esi
  800a55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5b:	75 13                	jne    800a70 <memmove+0x3b>
  800a5d:	f6 c1 03             	test   $0x3,%cl
  800a60:	75 0e                	jne    800a70 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a62:	83 ef 04             	sub    $0x4,%edi
  800a65:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a68:	c1 e9 02             	shr    $0x2,%ecx
  800a6b:	fd                   	std    
  800a6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6e:	eb 09                	jmp    800a79 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a70:	83 ef 01             	sub    $0x1,%edi
  800a73:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a76:	fd                   	std    
  800a77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a79:	fc                   	cld    
  800a7a:	eb 1d                	jmp    800a99 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7c:	89 f2                	mov    %esi,%edx
  800a7e:	09 c2                	or     %eax,%edx
  800a80:	f6 c2 03             	test   $0x3,%dl
  800a83:	75 0f                	jne    800a94 <memmove+0x5f>
  800a85:	f6 c1 03             	test   $0x3,%cl
  800a88:	75 0a                	jne    800a94 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a8a:	c1 e9 02             	shr    $0x2,%ecx
  800a8d:	89 c7                	mov    %eax,%edi
  800a8f:	fc                   	cld    
  800a90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a92:	eb 05                	jmp    800a99 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	fc                   	cld    
  800a97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa0:	ff 75 10             	pushl  0x10(%ebp)
  800aa3:	ff 75 0c             	pushl  0xc(%ebp)
  800aa6:	ff 75 08             	pushl  0x8(%ebp)
  800aa9:	e8 87 ff ff ff       	call   800a35 <memmove>
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac0:	eb 1a                	jmp    800adc <memcmp+0x2c>
		if (*s1 != *s2)
  800ac2:	0f b6 08             	movzbl (%eax),%ecx
  800ac5:	0f b6 1a             	movzbl (%edx),%ebx
  800ac8:	38 d9                	cmp    %bl,%cl
  800aca:	74 0a                	je     800ad6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800acc:	0f b6 c1             	movzbl %cl,%eax
  800acf:	0f b6 db             	movzbl %bl,%ebx
  800ad2:	29 d8                	sub    %ebx,%eax
  800ad4:	eb 0f                	jmp    800ae5 <memcmp+0x35>
		s1++, s2++;
  800ad6:	83 c0 01             	add    $0x1,%eax
  800ad9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adc:	39 f0                	cmp    %esi,%eax
  800ade:	75 e2                	jne    800ac2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	53                   	push   %ebx
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800af0:	89 c1                	mov    %eax,%ecx
  800af2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af9:	eb 0a                	jmp    800b05 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afb:	0f b6 10             	movzbl (%eax),%edx
  800afe:	39 da                	cmp    %ebx,%edx
  800b00:	74 07                	je     800b09 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	39 c8                	cmp    %ecx,%eax
  800b07:	72 f2                	jb     800afb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b18:	eb 03                	jmp    800b1d <strtol+0x11>
		s++;
  800b1a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1d:	0f b6 01             	movzbl (%ecx),%eax
  800b20:	3c 20                	cmp    $0x20,%al
  800b22:	74 f6                	je     800b1a <strtol+0xe>
  800b24:	3c 09                	cmp    $0x9,%al
  800b26:	74 f2                	je     800b1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b28:	3c 2b                	cmp    $0x2b,%al
  800b2a:	75 0a                	jne    800b36 <strtol+0x2a>
		s++;
  800b2c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b34:	eb 11                	jmp    800b47 <strtol+0x3b>
  800b36:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3b:	3c 2d                	cmp    $0x2d,%al
  800b3d:	75 08                	jne    800b47 <strtol+0x3b>
		s++, neg = 1;
  800b3f:	83 c1 01             	add    $0x1,%ecx
  800b42:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b47:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4d:	75 15                	jne    800b64 <strtol+0x58>
  800b4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b52:	75 10                	jne    800b64 <strtol+0x58>
  800b54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b58:	75 7c                	jne    800bd6 <strtol+0xca>
		s += 2, base = 16;
  800b5a:	83 c1 02             	add    $0x2,%ecx
  800b5d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b62:	eb 16                	jmp    800b7a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	75 12                	jne    800b7a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b68:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b70:	75 08                	jne    800b7a <strtol+0x6e>
		s++, base = 8;
  800b72:	83 c1 01             	add    $0x1,%ecx
  800b75:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b82:	0f b6 11             	movzbl (%ecx),%edx
  800b85:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b88:	89 f3                	mov    %esi,%ebx
  800b8a:	80 fb 09             	cmp    $0x9,%bl
  800b8d:	77 08                	ja     800b97 <strtol+0x8b>
			dig = *s - '0';
  800b8f:	0f be d2             	movsbl %dl,%edx
  800b92:	83 ea 30             	sub    $0x30,%edx
  800b95:	eb 22                	jmp    800bb9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 19             	cmp    $0x19,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 57             	sub    $0x57,%edx
  800ba7:	eb 10                	jmp    800bb9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 16                	ja     800bc9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbc:	7d 0b                	jge    800bc9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c1 01             	add    $0x1,%ecx
  800bc1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc7:	eb b9                	jmp    800b82 <strtol+0x76>

	if (endptr)
  800bc9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcd:	74 0d                	je     800bdc <strtol+0xd0>
		*endptr = (char *) s;
  800bcf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd2:	89 0e                	mov    %ecx,(%esi)
  800bd4:	eb 06                	jmp    800bdc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd6:	85 db                	test   %ebx,%ebx
  800bd8:	74 98                	je     800b72 <strtol+0x66>
  800bda:	eb 9e                	jmp    800b7a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bdc:	89 c2                	mov    %eax,%edx
  800bde:	f7 da                	neg    %edx
  800be0:	85 ff                	test   %edi,%edi
  800be2:	0f 45 c2             	cmovne %edx,%eax
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 c3                	mov    %eax,%ebx
  800bfd:	89 c7                	mov    %eax,%edi
  800bff:	89 c6                	mov    %eax,%esi
  800c01:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 01 00 00 00       	mov    $0x1,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c35:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 cb                	mov    %ecx,%ebx
  800c3f:	89 cf                	mov    %ecx,%edi
  800c41:	89 ce                	mov    %ecx,%esi
  800c43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 03                	push   $0x3
  800c4f:	68 bf 27 80 00       	push   $0x8027bf
  800c54:	6a 23                	push   $0x23
  800c56:	68 dc 27 80 00       	push   $0x8027dc
  800c5b:	e8 e5 f5 ff ff       	call   800245 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	b8 02 00 00 00       	mov    $0x2,%eax
  800c78:	89 d1                	mov    %edx,%ecx
  800c7a:	89 d3                	mov    %edx,%ebx
  800c7c:	89 d7                	mov    %edx,%edi
  800c7e:	89 d6                	mov    %edx,%esi
  800c80:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_yield>:

void
sys_yield(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	89 f7                	mov    %esi,%edi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 04                	push   $0x4
  800cd0:	68 bf 27 80 00       	push   $0x8027bf
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 dc 27 80 00       	push   $0x8027dc
  800cdc:	e8 64 f5 ff ff       	call   800245 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d03:	8b 75 18             	mov    0x18(%ebp),%esi
  800d06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 05                	push   $0x5
  800d12:	68 bf 27 80 00       	push   $0x8027bf
  800d17:	6a 23                	push   $0x23
  800d19:	68 dc 27 80 00       	push   $0x8027dc
  800d1e:	e8 22 f5 ff ff       	call   800245 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d39:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 df                	mov    %ebx,%edi
  800d46:	89 de                	mov    %ebx,%esi
  800d48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 17                	jle    800d65 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 06                	push   $0x6
  800d54:	68 bf 27 80 00       	push   $0x8027bf
  800d59:	6a 23                	push   $0x23
  800d5b:	68 dc 27 80 00       	push   $0x8027dc
  800d60:	e8 e0 f4 ff ff       	call   800245 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 df                	mov    %ebx,%edi
  800d88:	89 de                	mov    %ebx,%esi
  800d8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 08                	push   $0x8
  800d96:	68 bf 27 80 00       	push   $0x8027bf
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 dc 27 80 00       	push   $0x8027dc
  800da2:	e8 9e f4 ff ff       	call   800245 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbd:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	89 df                	mov    %ebx,%edi
  800dca:	89 de                	mov    %ebx,%esi
  800dcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7e 17                	jle    800de9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	50                   	push   %eax
  800dd6:	6a 09                	push   $0x9
  800dd8:	68 bf 27 80 00       	push   $0x8027bf
  800ddd:	6a 23                	push   $0x23
  800ddf:	68 dc 27 80 00       	push   $0x8027dc
  800de4:	e8 5c f4 ff ff       	call   800245 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	89 df                	mov    %ebx,%edi
  800e0c:	89 de                	mov    %ebx,%esi
  800e0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e10:	85 c0                	test   %eax,%eax
  800e12:	7e 17                	jle    800e2b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	50                   	push   %eax
  800e18:	6a 0a                	push   $0xa
  800e1a:	68 bf 27 80 00       	push   $0x8027bf
  800e1f:	6a 23                	push   $0x23
  800e21:	68 dc 27 80 00       	push   $0x8027dc
  800e26:	e8 1a f4 ff ff       	call   800245 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e39:	be 00 00 00 00       	mov    $0x0,%esi
  800e3e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e64:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 cb                	mov    %ecx,%ebx
  800e6e:	89 cf                	mov    %ecx,%edi
  800e70:	89 ce                	mov    %ecx,%esi
  800e72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e74:	85 c0                	test   %eax,%eax
  800e76:	7e 17                	jle    800e8f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	50                   	push   %eax
  800e7c:	6a 0d                	push   $0xd
  800e7e:	68 bf 27 80 00       	push   $0x8027bf
  800e83:	6a 23                	push   $0x23
  800e85:	68 dc 27 80 00       	push   $0x8027dc
  800e8a:	e8 b6 f3 ff ff       	call   800245 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea7:	89 d1                	mov    %edx,%ecx
  800ea9:	89 d3                	mov    %edx,%ebx
  800eab:	89 d7                	mov    %edx,%edi
  800ead:	89 d6                	mov    %edx,%esi
  800eaf:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec1:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	89 df                	mov    %ebx,%edi
  800ece:	89 de                	mov    %ebx,%esi
  800ed0:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
  800edd:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee2:	c1 e8 0c             	shr    $0xc,%eax
}
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eea:	8b 45 08             	mov    0x8(%ebp),%eax
  800eed:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ef7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f04:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f09:	89 c2                	mov    %eax,%edx
  800f0b:	c1 ea 16             	shr    $0x16,%edx
  800f0e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f15:	f6 c2 01             	test   $0x1,%dl
  800f18:	74 11                	je     800f2b <fd_alloc+0x2d>
  800f1a:	89 c2                	mov    %eax,%edx
  800f1c:	c1 ea 0c             	shr    $0xc,%edx
  800f1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f26:	f6 c2 01             	test   $0x1,%dl
  800f29:	75 09                	jne    800f34 <fd_alloc+0x36>
			*fd_store = fd;
  800f2b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f32:	eb 17                	jmp    800f4b <fd_alloc+0x4d>
  800f34:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f39:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f3e:	75 c9                	jne    800f09 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f40:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f46:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f53:	83 f8 1f             	cmp    $0x1f,%eax
  800f56:	77 36                	ja     800f8e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f58:	c1 e0 0c             	shl    $0xc,%eax
  800f5b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f60:	89 c2                	mov    %eax,%edx
  800f62:	c1 ea 16             	shr    $0x16,%edx
  800f65:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6c:	f6 c2 01             	test   $0x1,%dl
  800f6f:	74 24                	je     800f95 <fd_lookup+0x48>
  800f71:	89 c2                	mov    %eax,%edx
  800f73:	c1 ea 0c             	shr    $0xc,%edx
  800f76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7d:	f6 c2 01             	test   $0x1,%dl
  800f80:	74 1a                	je     800f9c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f85:	89 02                	mov    %eax,(%edx)
	return 0;
  800f87:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8c:	eb 13                	jmp    800fa1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f93:	eb 0c                	jmp    800fa1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9a:	eb 05                	jmp    800fa1 <fd_lookup+0x54>
  800f9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 08             	sub    $0x8,%esp
  800fa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fac:	ba 6c 28 80 00       	mov    $0x80286c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb1:	eb 13                	jmp    800fc6 <dev_lookup+0x23>
  800fb3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fb6:	39 08                	cmp    %ecx,(%eax)
  800fb8:	75 0c                	jne    800fc6 <dev_lookup+0x23>
			*dev = devtab[i];
  800fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc4:	eb 2e                	jmp    800ff4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc6:	8b 02                	mov    (%edx),%eax
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	75 e7                	jne    800fb3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fcc:	a1 08 40 80 00       	mov    0x804008,%eax
  800fd1:	8b 40 48             	mov    0x48(%eax),%eax
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	51                   	push   %ecx
  800fd8:	50                   	push   %eax
  800fd9:	68 ec 27 80 00       	push   $0x8027ec
  800fde:	e8 3b f3 ff ff       	call   80031e <cprintf>
	*dev = 0;
  800fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    

00800ff6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 10             	sub    $0x10,%esp
  800ffe:	8b 75 08             	mov    0x8(%ebp),%esi
  801001:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801004:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801007:	50                   	push   %eax
  801008:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80100e:	c1 e8 0c             	shr    $0xc,%eax
  801011:	50                   	push   %eax
  801012:	e8 36 ff ff ff       	call   800f4d <fd_lookup>
  801017:	83 c4 08             	add    $0x8,%esp
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 05                	js     801023 <fd_close+0x2d>
	    || fd != fd2)
  80101e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801021:	74 0c                	je     80102f <fd_close+0x39>
		return (must_exist ? r : 0);
  801023:	84 db                	test   %bl,%bl
  801025:	ba 00 00 00 00       	mov    $0x0,%edx
  80102a:	0f 44 c2             	cmove  %edx,%eax
  80102d:	eb 41                	jmp    801070 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	ff 36                	pushl  (%esi)
  801038:	e8 66 ff ff ff       	call   800fa3 <dev_lookup>
  80103d:	89 c3                	mov    %eax,%ebx
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 1a                	js     801060 <fd_close+0x6a>
		if (dev->dev_close)
  801046:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801049:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80104c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801051:	85 c0                	test   %eax,%eax
  801053:	74 0b                	je     801060 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	56                   	push   %esi
  801059:	ff d0                	call   *%eax
  80105b:	89 c3                	mov    %eax,%ebx
  80105d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 c0 fc ff ff       	call   800d2b <sys_page_unmap>
	return r;
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	89 d8                	mov    %ebx,%eax
}
  801070:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80107d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	ff 75 08             	pushl  0x8(%ebp)
  801084:	e8 c4 fe ff ff       	call   800f4d <fd_lookup>
  801089:	83 c4 08             	add    $0x8,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 10                	js     8010a0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	6a 01                	push   $0x1
  801095:	ff 75 f4             	pushl  -0xc(%ebp)
  801098:	e8 59 ff ff ff       	call   800ff6 <fd_close>
  80109d:	83 c4 10             	add    $0x10,%esp
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <close_all>:

void
close_all(void)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	53                   	push   %ebx
  8010b2:	e8 c0 ff ff ff       	call   801077 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b7:	83 c3 01             	add    $0x1,%ebx
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	83 fb 20             	cmp    $0x20,%ebx
  8010c0:	75 ec                	jne    8010ae <close_all+0xc>
		close(i);
}
  8010c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	57                   	push   %edi
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 2c             	sub    $0x2c,%esp
  8010d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d6:	50                   	push   %eax
  8010d7:	ff 75 08             	pushl  0x8(%ebp)
  8010da:	e8 6e fe ff ff       	call   800f4d <fd_lookup>
  8010df:	83 c4 08             	add    $0x8,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	0f 88 c1 00 00 00    	js     8011ab <dup+0xe4>
		return r;
	close(newfdnum);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	56                   	push   %esi
  8010ee:	e8 84 ff ff ff       	call   801077 <close>

	newfd = INDEX2FD(newfdnum);
  8010f3:	89 f3                	mov    %esi,%ebx
  8010f5:	c1 e3 0c             	shl    $0xc,%ebx
  8010f8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010fe:	83 c4 04             	add    $0x4,%esp
  801101:	ff 75 e4             	pushl  -0x1c(%ebp)
  801104:	e8 de fd ff ff       	call   800ee7 <fd2data>
  801109:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80110b:	89 1c 24             	mov    %ebx,(%esp)
  80110e:	e8 d4 fd ff ff       	call   800ee7 <fd2data>
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801119:	89 f8                	mov    %edi,%eax
  80111b:	c1 e8 16             	shr    $0x16,%eax
  80111e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801125:	a8 01                	test   $0x1,%al
  801127:	74 37                	je     801160 <dup+0x99>
  801129:	89 f8                	mov    %edi,%eax
  80112b:	c1 e8 0c             	shr    $0xc,%eax
  80112e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801135:	f6 c2 01             	test   $0x1,%dl
  801138:	74 26                	je     801160 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80113a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	25 07 0e 00 00       	and    $0xe07,%eax
  801149:	50                   	push   %eax
  80114a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114d:	6a 00                	push   $0x0
  80114f:	57                   	push   %edi
  801150:	6a 00                	push   $0x0
  801152:	e8 92 fb ff ff       	call   800ce9 <sys_page_map>
  801157:	89 c7                	mov    %eax,%edi
  801159:	83 c4 20             	add    $0x20,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 2e                	js     80118e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801160:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801163:	89 d0                	mov    %edx,%eax
  801165:	c1 e8 0c             	shr    $0xc,%eax
  801168:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	25 07 0e 00 00       	and    $0xe07,%eax
  801177:	50                   	push   %eax
  801178:	53                   	push   %ebx
  801179:	6a 00                	push   $0x0
  80117b:	52                   	push   %edx
  80117c:	6a 00                	push   $0x0
  80117e:	e8 66 fb ff ff       	call   800ce9 <sys_page_map>
  801183:	89 c7                	mov    %eax,%edi
  801185:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801188:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80118a:	85 ff                	test   %edi,%edi
  80118c:	79 1d                	jns    8011ab <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	53                   	push   %ebx
  801192:	6a 00                	push   $0x0
  801194:	e8 92 fb ff ff       	call   800d2b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80119f:	6a 00                	push   $0x0
  8011a1:	e8 85 fb ff ff       	call   800d2b <sys_page_unmap>
	return r;
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	89 f8                	mov    %edi,%eax
}
  8011ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ae:	5b                   	pop    %ebx
  8011af:	5e                   	pop    %esi
  8011b0:	5f                   	pop    %edi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 14             	sub    $0x14,%esp
  8011ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	53                   	push   %ebx
  8011c2:	e8 86 fd ff ff       	call   800f4d <fd_lookup>
  8011c7:	83 c4 08             	add    $0x8,%esp
  8011ca:	89 c2                	mov    %eax,%edx
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 6d                	js     80123d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d6:	50                   	push   %eax
  8011d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011da:	ff 30                	pushl  (%eax)
  8011dc:	e8 c2 fd ff ff       	call   800fa3 <dev_lookup>
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 4c                	js     801234 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011eb:	8b 42 08             	mov    0x8(%edx),%eax
  8011ee:	83 e0 03             	and    $0x3,%eax
  8011f1:	83 f8 01             	cmp    $0x1,%eax
  8011f4:	75 21                	jne    801217 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8011fb:	8b 40 48             	mov    0x48(%eax),%eax
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	53                   	push   %ebx
  801202:	50                   	push   %eax
  801203:	68 30 28 80 00       	push   $0x802830
  801208:	e8 11 f1 ff ff       	call   80031e <cprintf>
		return -E_INVAL;
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801215:	eb 26                	jmp    80123d <read+0x8a>
	}
	if (!dev->dev_read)
  801217:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121a:	8b 40 08             	mov    0x8(%eax),%eax
  80121d:	85 c0                	test   %eax,%eax
  80121f:	74 17                	je     801238 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	ff 75 10             	pushl  0x10(%ebp)
  801227:	ff 75 0c             	pushl  0xc(%ebp)
  80122a:	52                   	push   %edx
  80122b:	ff d0                	call   *%eax
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	eb 09                	jmp    80123d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801234:	89 c2                	mov    %eax,%edx
  801236:	eb 05                	jmp    80123d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801238:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80123d:	89 d0                	mov    %edx,%eax
  80123f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
  80124a:	83 ec 0c             	sub    $0xc,%esp
  80124d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801250:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801253:	bb 00 00 00 00       	mov    $0x0,%ebx
  801258:	eb 21                	jmp    80127b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	89 f0                	mov    %esi,%eax
  80125f:	29 d8                	sub    %ebx,%eax
  801261:	50                   	push   %eax
  801262:	89 d8                	mov    %ebx,%eax
  801264:	03 45 0c             	add    0xc(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	57                   	push   %edi
  801269:	e8 45 ff ff ff       	call   8011b3 <read>
		if (m < 0)
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 10                	js     801285 <readn+0x41>
			return m;
		if (m == 0)
  801275:	85 c0                	test   %eax,%eax
  801277:	74 0a                	je     801283 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801279:	01 c3                	add    %eax,%ebx
  80127b:	39 f3                	cmp    %esi,%ebx
  80127d:	72 db                	jb     80125a <readn+0x16>
  80127f:	89 d8                	mov    %ebx,%eax
  801281:	eb 02                	jmp    801285 <readn+0x41>
  801283:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	53                   	push   %ebx
  801291:	83 ec 14             	sub    $0x14,%esp
  801294:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801297:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	53                   	push   %ebx
  80129c:	e8 ac fc ff ff       	call   800f4d <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 68                	js     801312 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	ff 30                	pushl  (%eax)
  8012b6:	e8 e8 fc ff ff       	call   800fa3 <dev_lookup>
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 47                	js     801309 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c9:	75 21                	jne    8012ec <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012cb:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d0:	8b 40 48             	mov    0x48(%eax),%eax
  8012d3:	83 ec 04             	sub    $0x4,%esp
  8012d6:	53                   	push   %ebx
  8012d7:	50                   	push   %eax
  8012d8:	68 4c 28 80 00       	push   $0x80284c
  8012dd:	e8 3c f0 ff ff       	call   80031e <cprintf>
		return -E_INVAL;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ea:	eb 26                	jmp    801312 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ef:	8b 52 0c             	mov    0xc(%edx),%edx
  8012f2:	85 d2                	test   %edx,%edx
  8012f4:	74 17                	je     80130d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012f6:	83 ec 04             	sub    $0x4,%esp
  8012f9:	ff 75 10             	pushl  0x10(%ebp)
  8012fc:	ff 75 0c             	pushl  0xc(%ebp)
  8012ff:	50                   	push   %eax
  801300:	ff d2                	call   *%edx
  801302:	89 c2                	mov    %eax,%edx
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	eb 09                	jmp    801312 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801309:	89 c2                	mov    %eax,%edx
  80130b:	eb 05                	jmp    801312 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80130d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801312:	89 d0                	mov    %edx,%eax
  801314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <seek>:

int
seek(int fdnum, off_t offset)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801322:	50                   	push   %eax
  801323:	ff 75 08             	pushl  0x8(%ebp)
  801326:	e8 22 fc ff ff       	call   800f4d <fd_lookup>
  80132b:	83 c4 08             	add    $0x8,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 0e                	js     801340 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801332:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801335:	8b 55 0c             	mov    0xc(%ebp),%edx
  801338:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	53                   	push   %ebx
  801346:	83 ec 14             	sub    $0x14,%esp
  801349:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	53                   	push   %ebx
  801351:	e8 f7 fb ff ff       	call   800f4d <fd_lookup>
  801356:	83 c4 08             	add    $0x8,%esp
  801359:	89 c2                	mov    %eax,%edx
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 65                	js     8013c4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801369:	ff 30                	pushl  (%eax)
  80136b:	e8 33 fc ff ff       	call   800fa3 <dev_lookup>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 44                	js     8013bb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801377:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80137e:	75 21                	jne    8013a1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801380:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801385:	8b 40 48             	mov    0x48(%eax),%eax
  801388:	83 ec 04             	sub    $0x4,%esp
  80138b:	53                   	push   %ebx
  80138c:	50                   	push   %eax
  80138d:	68 0c 28 80 00       	push   $0x80280c
  801392:	e8 87 ef ff ff       	call   80031e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80139f:	eb 23                	jmp    8013c4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a4:	8b 52 18             	mov    0x18(%edx),%edx
  8013a7:	85 d2                	test   %edx,%edx
  8013a9:	74 14                	je     8013bf <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	ff 75 0c             	pushl  0xc(%ebp)
  8013b1:	50                   	push   %eax
  8013b2:	ff d2                	call   *%edx
  8013b4:	89 c2                	mov    %eax,%edx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	eb 09                	jmp    8013c4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	eb 05                	jmp    8013c4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013c4:	89 d0                	mov    %edx,%eax
  8013c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 14             	sub    $0x14,%esp
  8013d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	ff 75 08             	pushl  0x8(%ebp)
  8013dc:	e8 6c fb ff ff       	call   800f4d <fd_lookup>
  8013e1:	83 c4 08             	add    $0x8,%esp
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 58                	js     801442 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f0:	50                   	push   %eax
  8013f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f4:	ff 30                	pushl  (%eax)
  8013f6:	e8 a8 fb ff ff       	call   800fa3 <dev_lookup>
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 37                	js     801439 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801402:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801405:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801409:	74 32                	je     80143d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80140b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80140e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801415:	00 00 00 
	stat->st_isdir = 0;
  801418:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80141f:	00 00 00 
	stat->st_dev = dev;
  801422:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	53                   	push   %ebx
  80142c:	ff 75 f0             	pushl  -0x10(%ebp)
  80142f:	ff 50 14             	call   *0x14(%eax)
  801432:	89 c2                	mov    %eax,%edx
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	eb 09                	jmp    801442 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801439:	89 c2                	mov    %eax,%edx
  80143b:	eb 05                	jmp    801442 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80143d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801442:	89 d0                	mov    %edx,%eax
  801444:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	6a 00                	push   $0x0
  801453:	ff 75 08             	pushl  0x8(%ebp)
  801456:	e8 e7 01 00 00       	call   801642 <open>
  80145b:	89 c3                	mov    %eax,%ebx
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	78 1b                	js     80147f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	ff 75 0c             	pushl  0xc(%ebp)
  80146a:	50                   	push   %eax
  80146b:	e8 5b ff ff ff       	call   8013cb <fstat>
  801470:	89 c6                	mov    %eax,%esi
	close(fd);
  801472:	89 1c 24             	mov    %ebx,(%esp)
  801475:	e8 fd fb ff ff       	call   801077 <close>
	return r;
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	89 f0                	mov    %esi,%eax
}
  80147f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801482:	5b                   	pop    %ebx
  801483:	5e                   	pop    %esi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	56                   	push   %esi
  80148a:	53                   	push   %ebx
  80148b:	89 c6                	mov    %eax,%esi
  80148d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80148f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801496:	75 12                	jne    8014aa <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801498:	83 ec 0c             	sub    $0xc,%esp
  80149b:	6a 01                	push   $0x1
  80149d:	e8 4b 0c 00 00       	call   8020ed <ipc_find_env>
  8014a2:	a3 00 40 80 00       	mov    %eax,0x804000
  8014a7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014aa:	6a 07                	push   $0x7
  8014ac:	68 00 50 80 00       	push   $0x805000
  8014b1:	56                   	push   %esi
  8014b2:	ff 35 00 40 80 00    	pushl  0x804000
  8014b8:	e8 dc 0b 00 00       	call   802099 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014bd:	83 c4 0c             	add    $0xc,%esp
  8014c0:	6a 00                	push   $0x0
  8014c2:	53                   	push   %ebx
  8014c3:	6a 00                	push   $0x0
  8014c5:	e8 62 0b 00 00       	call   80202c <ipc_recv>
}
  8014ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cd:	5b                   	pop    %ebx
  8014ce:	5e                   	pop    %esi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014da:	8b 40 0c             	mov    0xc(%eax),%eax
  8014dd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ef:	b8 02 00 00 00       	mov    $0x2,%eax
  8014f4:	e8 8d ff ff ff       	call   801486 <fsipc>
}
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801501:	8b 45 08             	mov    0x8(%ebp),%eax
  801504:	8b 40 0c             	mov    0xc(%eax),%eax
  801507:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80150c:	ba 00 00 00 00       	mov    $0x0,%edx
  801511:	b8 06 00 00 00       	mov    $0x6,%eax
  801516:	e8 6b ff ff ff       	call   801486 <fsipc>
}
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	53                   	push   %ebx
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	8b 40 0c             	mov    0xc(%eax),%eax
  80152d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801532:	ba 00 00 00 00       	mov    $0x0,%edx
  801537:	b8 05 00 00 00       	mov    $0x5,%eax
  80153c:	e8 45 ff ff ff       	call   801486 <fsipc>
  801541:	85 c0                	test   %eax,%eax
  801543:	78 2c                	js     801571 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	68 00 50 80 00       	push   $0x805000
  80154d:	53                   	push   %ebx
  80154e:	e8 50 f3 ff ff       	call   8008a3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801553:	a1 80 50 80 00       	mov    0x805080,%eax
  801558:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80155e:	a1 84 50 80 00       	mov    0x805084,%eax
  801563:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	53                   	push   %ebx
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801580:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801585:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80158a:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80158d:	53                   	push   %ebx
  80158e:	ff 75 0c             	pushl  0xc(%ebp)
  801591:	68 08 50 80 00       	push   $0x805008
  801596:	e8 9a f4 ff ff       	call   800a35 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80159b:	8b 45 08             	mov    0x8(%ebp),%eax
  80159e:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a1:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8015a6:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8015ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8015b6:	e8 cb fe ff ff       	call   801486 <fsipc>
	//panic("devfile_write not implemented");
}
  8015bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	56                   	push   %esi
  8015c4:	53                   	push   %ebx
  8015c5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015d3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015de:	b8 03 00 00 00       	mov    $0x3,%eax
  8015e3:	e8 9e fe ff ff       	call   801486 <fsipc>
  8015e8:	89 c3                	mov    %eax,%ebx
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 4b                	js     801639 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015ee:	39 c6                	cmp    %eax,%esi
  8015f0:	73 16                	jae    801608 <devfile_read+0x48>
  8015f2:	68 80 28 80 00       	push   $0x802880
  8015f7:	68 87 28 80 00       	push   $0x802887
  8015fc:	6a 7c                	push   $0x7c
  8015fe:	68 9c 28 80 00       	push   $0x80289c
  801603:	e8 3d ec ff ff       	call   800245 <_panic>
	assert(r <= PGSIZE);
  801608:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80160d:	7e 16                	jle    801625 <devfile_read+0x65>
  80160f:	68 a7 28 80 00       	push   $0x8028a7
  801614:	68 87 28 80 00       	push   $0x802887
  801619:	6a 7d                	push   $0x7d
  80161b:	68 9c 28 80 00       	push   $0x80289c
  801620:	e8 20 ec ff ff       	call   800245 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	50                   	push   %eax
  801629:	68 00 50 80 00       	push   $0x805000
  80162e:	ff 75 0c             	pushl  0xc(%ebp)
  801631:	e8 ff f3 ff ff       	call   800a35 <memmove>
	return r;
  801636:	83 c4 10             	add    $0x10,%esp
}
  801639:	89 d8                	mov    %ebx,%eax
  80163b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    

00801642 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	53                   	push   %ebx
  801646:	83 ec 20             	sub    $0x20,%esp
  801649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80164c:	53                   	push   %ebx
  80164d:	e8 18 f2 ff ff       	call   80086a <strlen>
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80165a:	7f 67                	jg     8016c3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80165c:	83 ec 0c             	sub    $0xc,%esp
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	e8 96 f8 ff ff       	call   800efe <fd_alloc>
  801668:	83 c4 10             	add    $0x10,%esp
		return r;
  80166b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 57                	js     8016c8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	53                   	push   %ebx
  801675:	68 00 50 80 00       	push   $0x805000
  80167a:	e8 24 f2 ff ff       	call   8008a3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80167f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801682:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801687:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168a:	b8 01 00 00 00       	mov    $0x1,%eax
  80168f:	e8 f2 fd ff ff       	call   801486 <fsipc>
  801694:	89 c3                	mov    %eax,%ebx
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	79 14                	jns    8016b1 <open+0x6f>
		fd_close(fd, 0);
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	6a 00                	push   $0x0
  8016a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a5:	e8 4c f9 ff ff       	call   800ff6 <fd_close>
		return r;
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	89 da                	mov    %ebx,%edx
  8016af:	eb 17                	jmp    8016c8 <open+0x86>
	}

	return fd2num(fd);
  8016b1:	83 ec 0c             	sub    $0xc,%esp
  8016b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b7:	e8 1b f8 ff ff       	call   800ed7 <fd2num>
  8016bc:	89 c2                	mov    %eax,%edx
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	eb 05                	jmp    8016c8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016c3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016c8:	89 d0                	mov    %edx,%eax
  8016ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016da:	b8 08 00 00 00       	mov    $0x8,%eax
  8016df:	e8 a2 fd ff ff       	call   801486 <fsipc>
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016ec:	68 b3 28 80 00       	push   $0x8028b3
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	e8 aa f1 ff ff       	call   8008a3 <strcpy>
	return 0;
}
  8016f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	53                   	push   %ebx
  801704:	83 ec 10             	sub    $0x10,%esp
  801707:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80170a:	53                   	push   %ebx
  80170b:	e8 16 0a 00 00       	call   802126 <pageref>
  801710:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801713:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801718:	83 f8 01             	cmp    $0x1,%eax
  80171b:	75 10                	jne    80172d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80171d:	83 ec 0c             	sub    $0xc,%esp
  801720:	ff 73 0c             	pushl  0xc(%ebx)
  801723:	e8 c0 02 00 00       	call   8019e8 <nsipc_close>
  801728:	89 c2                	mov    %eax,%edx
  80172a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80172d:	89 d0                	mov    %edx,%eax
  80172f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80173a:	6a 00                	push   $0x0
  80173c:	ff 75 10             	pushl  0x10(%ebp)
  80173f:	ff 75 0c             	pushl  0xc(%ebp)
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	ff 70 0c             	pushl  0xc(%eax)
  801748:	e8 78 03 00 00       	call   801ac5 <nsipc_send>
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801755:	6a 00                	push   $0x0
  801757:	ff 75 10             	pushl  0x10(%ebp)
  80175a:	ff 75 0c             	pushl  0xc(%ebp)
  80175d:	8b 45 08             	mov    0x8(%ebp),%eax
  801760:	ff 70 0c             	pushl  0xc(%eax)
  801763:	e8 f1 02 00 00       	call   801a59 <nsipc_recv>
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801770:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801773:	52                   	push   %edx
  801774:	50                   	push   %eax
  801775:	e8 d3 f7 ff ff       	call   800f4d <fd_lookup>
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 17                	js     801798 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801781:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801784:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80178a:	39 08                	cmp    %ecx,(%eax)
  80178c:	75 05                	jne    801793 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80178e:	8b 40 0c             	mov    0xc(%eax),%eax
  801791:	eb 05                	jmp    801798 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801793:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	56                   	push   %esi
  80179e:	53                   	push   %ebx
  80179f:	83 ec 1c             	sub    $0x1c,%esp
  8017a2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8017a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a7:	50                   	push   %eax
  8017a8:	e8 51 f7 ff ff       	call   800efe <fd_alloc>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 1b                	js     8017d1 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017b6:	83 ec 04             	sub    $0x4,%esp
  8017b9:	68 07 04 00 00       	push   $0x407
  8017be:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c1:	6a 00                	push   $0x0
  8017c3:	e8 de f4 ff ff       	call   800ca6 <sys_page_alloc>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	79 10                	jns    8017e1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	56                   	push   %esi
  8017d5:	e8 0e 02 00 00       	call   8019e8 <nsipc_close>
		return r;
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	89 d8                	mov    %ebx,%eax
  8017df:	eb 24                	jmp    801805 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017e1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ea:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017f6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017f9:	83 ec 0c             	sub    $0xc,%esp
  8017fc:	50                   	push   %eax
  8017fd:	e8 d5 f6 ff ff       	call   800ed7 <fd2num>
  801802:	83 c4 10             	add    $0x10,%esp
}
  801805:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	e8 50 ff ff ff       	call   80176a <fd2sockid>
		return r;
  80181a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 1f                	js     80183f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801820:	83 ec 04             	sub    $0x4,%esp
  801823:	ff 75 10             	pushl  0x10(%ebp)
  801826:	ff 75 0c             	pushl  0xc(%ebp)
  801829:	50                   	push   %eax
  80182a:	e8 12 01 00 00       	call   801941 <nsipc_accept>
  80182f:	83 c4 10             	add    $0x10,%esp
		return r;
  801832:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801834:	85 c0                	test   %eax,%eax
  801836:	78 07                	js     80183f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801838:	e8 5d ff ff ff       	call   80179a <alloc_sockfd>
  80183d:	89 c1                	mov    %eax,%ecx
}
  80183f:	89 c8                	mov    %ecx,%eax
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	e8 19 ff ff ff       	call   80176a <fd2sockid>
  801851:	85 c0                	test   %eax,%eax
  801853:	78 12                	js     801867 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801855:	83 ec 04             	sub    $0x4,%esp
  801858:	ff 75 10             	pushl  0x10(%ebp)
  80185b:	ff 75 0c             	pushl  0xc(%ebp)
  80185e:	50                   	push   %eax
  80185f:	e8 2d 01 00 00       	call   801991 <nsipc_bind>
  801864:	83 c4 10             	add    $0x10,%esp
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <shutdown>:

int
shutdown(int s, int how)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	e8 f3 fe ff ff       	call   80176a <fd2sockid>
  801877:	85 c0                	test   %eax,%eax
  801879:	78 0f                	js     80188a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	ff 75 0c             	pushl  0xc(%ebp)
  801881:	50                   	push   %eax
  801882:	e8 3f 01 00 00       	call   8019c6 <nsipc_shutdown>
  801887:	83 c4 10             	add    $0x10,%esp
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	e8 d0 fe ff ff       	call   80176a <fd2sockid>
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 12                	js     8018b0 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	ff 75 10             	pushl  0x10(%ebp)
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	50                   	push   %eax
  8018a8:	e8 55 01 00 00       	call   801a02 <nsipc_connect>
  8018ad:	83 c4 10             	add    $0x10,%esp
}
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <listen>:

int
listen(int s, int backlog)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	e8 aa fe ff ff       	call   80176a <fd2sockid>
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 0f                	js     8018d3 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ca:	50                   	push   %eax
  8018cb:	e8 67 01 00 00       	call   801a37 <nsipc_listen>
  8018d0:	83 c4 10             	add    $0x10,%esp
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018db:	ff 75 10             	pushl  0x10(%ebp)
  8018de:	ff 75 0c             	pushl  0xc(%ebp)
  8018e1:	ff 75 08             	pushl  0x8(%ebp)
  8018e4:	e8 3a 02 00 00       	call   801b23 <nsipc_socket>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 05                	js     8018f5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018f0:	e8 a5 fe ff ff       	call   80179a <alloc_sockfd>
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 04             	sub    $0x4,%esp
  8018fe:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801900:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801907:	75 12                	jne    80191b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801909:	83 ec 0c             	sub    $0xc,%esp
  80190c:	6a 02                	push   $0x2
  80190e:	e8 da 07 00 00       	call   8020ed <ipc_find_env>
  801913:	a3 04 40 80 00       	mov    %eax,0x804004
  801918:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80191b:	6a 07                	push   $0x7
  80191d:	68 00 60 80 00       	push   $0x806000
  801922:	53                   	push   %ebx
  801923:	ff 35 04 40 80 00    	pushl  0x804004
  801929:	e8 6b 07 00 00       	call   802099 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80192e:	83 c4 0c             	add    $0xc,%esp
  801931:	6a 00                	push   $0x0
  801933:	6a 00                	push   $0x0
  801935:	6a 00                	push   $0x0
  801937:	e8 f0 06 00 00       	call   80202c <ipc_recv>
}
  80193c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801951:	8b 06                	mov    (%esi),%eax
  801953:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801958:	b8 01 00 00 00       	mov    $0x1,%eax
  80195d:	e8 95 ff ff ff       	call   8018f7 <nsipc>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	85 c0                	test   %eax,%eax
  801966:	78 20                	js     801988 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801968:	83 ec 04             	sub    $0x4,%esp
  80196b:	ff 35 10 60 80 00    	pushl  0x806010
  801971:	68 00 60 80 00       	push   $0x806000
  801976:	ff 75 0c             	pushl  0xc(%ebp)
  801979:	e8 b7 f0 ff ff       	call   800a35 <memmove>
		*addrlen = ret->ret_addrlen;
  80197e:	a1 10 60 80 00       	mov    0x806010,%eax
  801983:	89 06                	mov    %eax,(%esi)
  801985:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801988:	89 d8                	mov    %ebx,%eax
  80198a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5e                   	pop    %esi
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	53                   	push   %ebx
  801995:	83 ec 08             	sub    $0x8,%esp
  801998:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019a3:	53                   	push   %ebx
  8019a4:	ff 75 0c             	pushl  0xc(%ebp)
  8019a7:	68 04 60 80 00       	push   $0x806004
  8019ac:	e8 84 f0 ff ff       	call   800a35 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019b1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8019b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019bc:	e8 36 ff ff ff       	call   8018f7 <nsipc>
}
  8019c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e1:	e8 11 ff ff ff       	call   8018f7 <nsipc>
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <nsipc_close>:

int
nsipc_close(int s)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8019fb:	e8 f7 fe ff ff       	call   8018f7 <nsipc>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	53                   	push   %ebx
  801a06:	83 ec 08             	sub    $0x8,%esp
  801a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a14:	53                   	push   %ebx
  801a15:	ff 75 0c             	pushl  0xc(%ebp)
  801a18:	68 04 60 80 00       	push   $0x806004
  801a1d:	e8 13 f0 ff ff       	call   800a35 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a22:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a28:	b8 05 00 00 00       	mov    $0x5,%eax
  801a2d:	e8 c5 fe ff ff       	call   8018f7 <nsipc>
}
  801a32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a40:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a48:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a4d:	b8 06 00 00 00       	mov    $0x6,%eax
  801a52:	e8 a0 fe ff ff       	call   8018f7 <nsipc>
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a61:	8b 45 08             	mov    0x8(%ebp),%eax
  801a64:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a69:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a72:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a77:	b8 07 00 00 00       	mov    $0x7,%eax
  801a7c:	e8 76 fe ff ff       	call   8018f7 <nsipc>
  801a81:	89 c3                	mov    %eax,%ebx
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 35                	js     801abc <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a87:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a8c:	7f 04                	jg     801a92 <nsipc_recv+0x39>
  801a8e:	39 c6                	cmp    %eax,%esi
  801a90:	7d 16                	jge    801aa8 <nsipc_recv+0x4f>
  801a92:	68 bf 28 80 00       	push   $0x8028bf
  801a97:	68 87 28 80 00       	push   $0x802887
  801a9c:	6a 62                	push   $0x62
  801a9e:	68 d4 28 80 00       	push   $0x8028d4
  801aa3:	e8 9d e7 ff ff       	call   800245 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801aa8:	83 ec 04             	sub    $0x4,%esp
  801aab:	50                   	push   %eax
  801aac:	68 00 60 80 00       	push   $0x806000
  801ab1:	ff 75 0c             	pushl  0xc(%ebp)
  801ab4:	e8 7c ef ff ff       	call   800a35 <memmove>
  801ab9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801abc:	89 d8                	mov    %ebx,%eax
  801abe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	53                   	push   %ebx
  801ac9:	83 ec 04             	sub    $0x4,%esp
  801acc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ad7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801add:	7e 16                	jle    801af5 <nsipc_send+0x30>
  801adf:	68 e0 28 80 00       	push   $0x8028e0
  801ae4:	68 87 28 80 00       	push   $0x802887
  801ae9:	6a 6d                	push   $0x6d
  801aeb:	68 d4 28 80 00       	push   $0x8028d4
  801af0:	e8 50 e7 ff ff       	call   800245 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801af5:	83 ec 04             	sub    $0x4,%esp
  801af8:	53                   	push   %ebx
  801af9:	ff 75 0c             	pushl  0xc(%ebp)
  801afc:	68 0c 60 80 00       	push   $0x80600c
  801b01:	e8 2f ef ff ff       	call   800a35 <memmove>
	nsipcbuf.send.req_size = size;
  801b06:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b0c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b14:	b8 08 00 00 00       	mov    $0x8,%eax
  801b19:	e8 d9 fd ff ff       	call   8018f7 <nsipc>
}
  801b1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    

00801b23 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b34:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b39:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b41:	b8 09 00 00 00       	mov    $0x9,%eax
  801b46:	e8 ac fd ff ff       	call   8018f7 <nsipc>
}
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	ff 75 08             	pushl  0x8(%ebp)
  801b5b:	e8 87 f3 ff ff       	call   800ee7 <fd2data>
  801b60:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b62:	83 c4 08             	add    $0x8,%esp
  801b65:	68 ec 28 80 00       	push   $0x8028ec
  801b6a:	53                   	push   %ebx
  801b6b:	e8 33 ed ff ff       	call   8008a3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b70:	8b 46 04             	mov    0x4(%esi),%eax
  801b73:	2b 06                	sub    (%esi),%eax
  801b75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b7b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b82:	00 00 00 
	stat->st_dev = &devpipe;
  801b85:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b8c:	30 80 00 
	return 0;
}
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b97:	5b                   	pop    %ebx
  801b98:	5e                   	pop    %esi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	53                   	push   %ebx
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ba5:	53                   	push   %ebx
  801ba6:	6a 00                	push   $0x0
  801ba8:	e8 7e f1 ff ff       	call   800d2b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bad:	89 1c 24             	mov    %ebx,(%esp)
  801bb0:	e8 32 f3 ff ff       	call   800ee7 <fd2data>
  801bb5:	83 c4 08             	add    $0x8,%esp
  801bb8:	50                   	push   %eax
  801bb9:	6a 00                	push   $0x0
  801bbb:	e8 6b f1 ff ff       	call   800d2b <sys_page_unmap>
}
  801bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    

00801bc5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	57                   	push   %edi
  801bc9:	56                   	push   %esi
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 1c             	sub    $0x1c,%esp
  801bce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bd1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bd3:	a1 08 40 80 00       	mov    0x804008,%eax
  801bd8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	ff 75 e0             	pushl  -0x20(%ebp)
  801be1:	e8 40 05 00 00       	call   802126 <pageref>
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	89 3c 24             	mov    %edi,(%esp)
  801beb:	e8 36 05 00 00       	call   802126 <pageref>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	39 c3                	cmp    %eax,%ebx
  801bf5:	0f 94 c1             	sete   %cl
  801bf8:	0f b6 c9             	movzbl %cl,%ecx
  801bfb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bfe:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c07:	39 ce                	cmp    %ecx,%esi
  801c09:	74 1b                	je     801c26 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c0b:	39 c3                	cmp    %eax,%ebx
  801c0d:	75 c4                	jne    801bd3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c0f:	8b 42 58             	mov    0x58(%edx),%eax
  801c12:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c15:	50                   	push   %eax
  801c16:	56                   	push   %esi
  801c17:	68 f3 28 80 00       	push   $0x8028f3
  801c1c:	e8 fd e6 ff ff       	call   80031e <cprintf>
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	eb ad                	jmp    801bd3 <_pipeisclosed+0xe>
	}
}
  801c26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	57                   	push   %edi
  801c35:	56                   	push   %esi
  801c36:	53                   	push   %ebx
  801c37:	83 ec 28             	sub    $0x28,%esp
  801c3a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c3d:	56                   	push   %esi
  801c3e:	e8 a4 f2 ff ff       	call   800ee7 <fd2data>
  801c43:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	bf 00 00 00 00       	mov    $0x0,%edi
  801c4d:	eb 4b                	jmp    801c9a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c4f:	89 da                	mov    %ebx,%edx
  801c51:	89 f0                	mov    %esi,%eax
  801c53:	e8 6d ff ff ff       	call   801bc5 <_pipeisclosed>
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	75 48                	jne    801ca4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c5c:	e8 26 f0 ff ff       	call   800c87 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c61:	8b 43 04             	mov    0x4(%ebx),%eax
  801c64:	8b 0b                	mov    (%ebx),%ecx
  801c66:	8d 51 20             	lea    0x20(%ecx),%edx
  801c69:	39 d0                	cmp    %edx,%eax
  801c6b:	73 e2                	jae    801c4f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c70:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c74:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c77:	89 c2                	mov    %eax,%edx
  801c79:	c1 fa 1f             	sar    $0x1f,%edx
  801c7c:	89 d1                	mov    %edx,%ecx
  801c7e:	c1 e9 1b             	shr    $0x1b,%ecx
  801c81:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c84:	83 e2 1f             	and    $0x1f,%edx
  801c87:	29 ca                	sub    %ecx,%edx
  801c89:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c91:	83 c0 01             	add    $0x1,%eax
  801c94:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c97:	83 c7 01             	add    $0x1,%edi
  801c9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c9d:	75 c2                	jne    801c61 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca2:	eb 05                	jmp    801ca9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	57                   	push   %edi
  801cb5:	56                   	push   %esi
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 18             	sub    $0x18,%esp
  801cba:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cbd:	57                   	push   %edi
  801cbe:	e8 24 f2 ff ff       	call   800ee7 <fd2data>
  801cc3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ccd:	eb 3d                	jmp    801d0c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ccf:	85 db                	test   %ebx,%ebx
  801cd1:	74 04                	je     801cd7 <devpipe_read+0x26>
				return i;
  801cd3:	89 d8                	mov    %ebx,%eax
  801cd5:	eb 44                	jmp    801d1b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cd7:	89 f2                	mov    %esi,%edx
  801cd9:	89 f8                	mov    %edi,%eax
  801cdb:	e8 e5 fe ff ff       	call   801bc5 <_pipeisclosed>
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	75 32                	jne    801d16 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ce4:	e8 9e ef ff ff       	call   800c87 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ce9:	8b 06                	mov    (%esi),%eax
  801ceb:	3b 46 04             	cmp    0x4(%esi),%eax
  801cee:	74 df                	je     801ccf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf0:	99                   	cltd   
  801cf1:	c1 ea 1b             	shr    $0x1b,%edx
  801cf4:	01 d0                	add    %edx,%eax
  801cf6:	83 e0 1f             	and    $0x1f,%eax
  801cf9:	29 d0                	sub    %edx,%eax
  801cfb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d03:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d06:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d09:	83 c3 01             	add    $0x1,%ebx
  801d0c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d0f:	75 d8                	jne    801ce9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d11:	8b 45 10             	mov    0x10(%ebp),%eax
  801d14:	eb 05                	jmp    801d1b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2e:	50                   	push   %eax
  801d2f:	e8 ca f1 ff ff       	call   800efe <fd_alloc>
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	0f 88 2c 01 00 00    	js     801e6d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d41:	83 ec 04             	sub    $0x4,%esp
  801d44:	68 07 04 00 00       	push   $0x407
  801d49:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4c:	6a 00                	push   $0x0
  801d4e:	e8 53 ef ff ff       	call   800ca6 <sys_page_alloc>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	89 c2                	mov    %eax,%edx
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	0f 88 0d 01 00 00    	js     801e6d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d60:	83 ec 0c             	sub    $0xc,%esp
  801d63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d66:	50                   	push   %eax
  801d67:	e8 92 f1 ff ff       	call   800efe <fd_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	0f 88 e2 00 00 00    	js     801e5b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d79:	83 ec 04             	sub    $0x4,%esp
  801d7c:	68 07 04 00 00       	push   $0x407
  801d81:	ff 75 f0             	pushl  -0x10(%ebp)
  801d84:	6a 00                	push   $0x0
  801d86:	e8 1b ef ff ff       	call   800ca6 <sys_page_alloc>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	0f 88 c3 00 00 00    	js     801e5b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9e:	e8 44 f1 ff ff       	call   800ee7 <fd2data>
  801da3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da5:	83 c4 0c             	add    $0xc,%esp
  801da8:	68 07 04 00 00       	push   $0x407
  801dad:	50                   	push   %eax
  801dae:	6a 00                	push   $0x0
  801db0:	e8 f1 ee ff ff       	call   800ca6 <sys_page_alloc>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	0f 88 89 00 00 00    	js     801e4b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc8:	e8 1a f1 ff ff       	call   800ee7 <fd2data>
  801dcd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dd4:	50                   	push   %eax
  801dd5:	6a 00                	push   $0x0
  801dd7:	56                   	push   %esi
  801dd8:	6a 00                	push   $0x0
  801dda:	e8 0a ef ff ff       	call   800ce9 <sys_page_map>
  801ddf:	89 c3                	mov    %eax,%ebx
  801de1:	83 c4 20             	add    $0x20,%esp
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 55                	js     801e3d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dfd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e06:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	ff 75 f4             	pushl  -0xc(%ebp)
  801e18:	e8 ba f0 ff ff       	call   800ed7 <fd2num>
  801e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e22:	83 c4 04             	add    $0x4,%esp
  801e25:	ff 75 f0             	pushl  -0x10(%ebp)
  801e28:	e8 aa f0 ff ff       	call   800ed7 <fd2num>
  801e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	ba 00 00 00 00       	mov    $0x0,%edx
  801e3b:	eb 30                	jmp    801e6d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	56                   	push   %esi
  801e41:	6a 00                	push   $0x0
  801e43:	e8 e3 ee ff ff       	call   800d2b <sys_page_unmap>
  801e48:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e4b:	83 ec 08             	sub    $0x8,%esp
  801e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e51:	6a 00                	push   $0x0
  801e53:	e8 d3 ee ff ff       	call   800d2b <sys_page_unmap>
  801e58:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e61:	6a 00                	push   $0x0
  801e63:	e8 c3 ee ff ff       	call   800d2b <sys_page_unmap>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e6d:	89 d0                	mov    %edx,%eax
  801e6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e72:	5b                   	pop    %ebx
  801e73:	5e                   	pop    %esi
  801e74:	5d                   	pop    %ebp
  801e75:	c3                   	ret    

00801e76 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	ff 75 08             	pushl  0x8(%ebp)
  801e83:	e8 c5 f0 ff ff       	call   800f4d <fd_lookup>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 18                	js     801ea7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	ff 75 f4             	pushl  -0xc(%ebp)
  801e95:	e8 4d f0 ff ff       	call   800ee7 <fd2data>
	return _pipeisclosed(fd, p);
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9f:	e8 21 fd ff ff       	call   801bc5 <_pipeisclosed>
  801ea4:	83 c4 10             	add    $0x10,%esp
}
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eac:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb1:	5d                   	pop    %ebp
  801eb2:	c3                   	ret    

00801eb3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb9:	68 0b 29 80 00       	push   $0x80290b
  801ebe:	ff 75 0c             	pushl  0xc(%ebp)
  801ec1:	e8 dd e9 ff ff       	call   8008a3 <strcpy>
	return 0;
}
  801ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecb:	c9                   	leave  
  801ecc:	c3                   	ret    

00801ecd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	57                   	push   %edi
  801ed1:	56                   	push   %esi
  801ed2:	53                   	push   %ebx
  801ed3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ede:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee4:	eb 2d                	jmp    801f13 <devcons_write+0x46>
		m = n - tot;
  801ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801eeb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eee:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ef3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef6:	83 ec 04             	sub    $0x4,%esp
  801ef9:	53                   	push   %ebx
  801efa:	03 45 0c             	add    0xc(%ebp),%eax
  801efd:	50                   	push   %eax
  801efe:	57                   	push   %edi
  801eff:	e8 31 eb ff ff       	call   800a35 <memmove>
		sys_cputs(buf, m);
  801f04:	83 c4 08             	add    $0x8,%esp
  801f07:	53                   	push   %ebx
  801f08:	57                   	push   %edi
  801f09:	e8 dc ec ff ff       	call   800bea <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f0e:	01 de                	add    %ebx,%esi
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	89 f0                	mov    %esi,%eax
  801f15:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f18:	72 cc                	jb     801ee6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    

00801f22 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	83 ec 08             	sub    $0x8,%esp
  801f28:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f31:	74 2a                	je     801f5d <devcons_read+0x3b>
  801f33:	eb 05                	jmp    801f3a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f35:	e8 4d ed ff ff       	call   800c87 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f3a:	e8 c9 ec ff ff       	call   800c08 <sys_cgetc>
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	74 f2                	je     801f35 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f43:	85 c0                	test   %eax,%eax
  801f45:	78 16                	js     801f5d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f47:	83 f8 04             	cmp    $0x4,%eax
  801f4a:	74 0c                	je     801f58 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4f:	88 02                	mov    %al,(%edx)
	return 1;
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	eb 05                	jmp    801f5d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f5d:	c9                   	leave  
  801f5e:	c3                   	ret    

00801f5f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f65:	8b 45 08             	mov    0x8(%ebp),%eax
  801f68:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f6b:	6a 01                	push   $0x1
  801f6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f70:	50                   	push   %eax
  801f71:	e8 74 ec ff ff       	call   800bea <sys_cputs>
}
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <getchar>:

int
getchar(void)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f81:	6a 01                	push   $0x1
  801f83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f86:	50                   	push   %eax
  801f87:	6a 00                	push   $0x0
  801f89:	e8 25 f2 ff ff       	call   8011b3 <read>
	if (r < 0)
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 0f                	js     801fa4 <getchar+0x29>
		return r;
	if (r < 1)
  801f95:	85 c0                	test   %eax,%eax
  801f97:	7e 06                	jle    801f9f <getchar+0x24>
		return -E_EOF;
	return c;
  801f99:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f9d:	eb 05                	jmp    801fa4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f9f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801faf:	50                   	push   %eax
  801fb0:	ff 75 08             	pushl  0x8(%ebp)
  801fb3:	e8 95 ef ff ff       	call   800f4d <fd_lookup>
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	78 11                	js     801fd0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fc8:	39 10                	cmp    %edx,(%eax)
  801fca:	0f 94 c0             	sete   %al
  801fcd:	0f b6 c0             	movzbl %al,%eax
}
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <opencons>:

int
opencons(void)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdb:	50                   	push   %eax
  801fdc:	e8 1d ef ff ff       	call   800efe <fd_alloc>
  801fe1:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	78 3e                	js     802028 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fea:	83 ec 04             	sub    $0x4,%esp
  801fed:	68 07 04 00 00       	push   $0x407
  801ff2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff5:	6a 00                	push   $0x0
  801ff7:	e8 aa ec ff ff       	call   800ca6 <sys_page_alloc>
  801ffc:	83 c4 10             	add    $0x10,%esp
		return r;
  801fff:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802001:	85 c0                	test   %eax,%eax
  802003:	78 23                	js     802028 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802005:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80200b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802013:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80201a:	83 ec 0c             	sub    $0xc,%esp
  80201d:	50                   	push   %eax
  80201e:	e8 b4 ee ff ff       	call   800ed7 <fd2num>
  802023:	89 c2                	mov    %eax,%edx
  802025:	83 c4 10             	add    $0x10,%esp
}
  802028:	89 d0                	mov    %edx,%eax
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	56                   	push   %esi
  802030:	53                   	push   %ebx
  802031:	8b 75 08             	mov    0x8(%ebp),%esi
  802034:	8b 45 0c             	mov    0xc(%ebp),%eax
  802037:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  80203a:	85 c0                	test   %eax,%eax
  80203c:	74 0e                	je     80204c <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  80203e:	83 ec 0c             	sub    $0xc,%esp
  802041:	50                   	push   %eax
  802042:	e8 0f ee ff ff       	call   800e56 <sys_ipc_recv>
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	eb 10                	jmp    80205c <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80204c:	83 ec 0c             	sub    $0xc,%esp
  80204f:	68 00 00 00 f0       	push   $0xf0000000
  802054:	e8 fd ed ff ff       	call   800e56 <sys_ipc_recv>
  802059:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80205c:	85 c0                	test   %eax,%eax
  80205e:	74 0e                	je     80206e <ipc_recv+0x42>
    	*from_env_store = 0;
  802060:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802066:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  80206c:	eb 24                	jmp    802092 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  80206e:	85 f6                	test   %esi,%esi
  802070:	74 0a                	je     80207c <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802072:	a1 08 40 80 00       	mov    0x804008,%eax
  802077:	8b 40 74             	mov    0x74(%eax),%eax
  80207a:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  80207c:	85 db                	test   %ebx,%ebx
  80207e:	74 0a                	je     80208a <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802080:	a1 08 40 80 00       	mov    0x804008,%eax
  802085:	8b 40 78             	mov    0x78(%eax),%eax
  802088:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  80208a:	a1 08 40 80 00       	mov    0x804008,%eax
  80208f:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802095:	5b                   	pop    %ebx
  802096:	5e                   	pop    %esi
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    

00802099 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	57                   	push   %edi
  80209d:	56                   	push   %esi
  80209e:	53                   	push   %ebx
  80209f:	83 ec 0c             	sub    $0xc,%esp
  8020a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8020ab:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8020ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020b2:	0f 44 d8             	cmove  %eax,%ebx
  8020b5:	eb 1c                	jmp    8020d3 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8020b7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ba:	74 12                	je     8020ce <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8020bc:	50                   	push   %eax
  8020bd:	68 17 29 80 00       	push   $0x802917
  8020c2:	6a 4b                	push   $0x4b
  8020c4:	68 2f 29 80 00       	push   $0x80292f
  8020c9:	e8 77 e1 ff ff       	call   800245 <_panic>
        }	
        sys_yield();
  8020ce:	e8 b4 eb ff ff       	call   800c87 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8020d3:	ff 75 14             	pushl  0x14(%ebp)
  8020d6:	53                   	push   %ebx
  8020d7:	56                   	push   %esi
  8020d8:	57                   	push   %edi
  8020d9:	e8 55 ed ff ff       	call   800e33 <sys_ipc_try_send>
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	75 d2                	jne    8020b7 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8020e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    

008020ed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020fb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802101:	8b 52 50             	mov    0x50(%edx),%edx
  802104:	39 ca                	cmp    %ecx,%edx
  802106:	75 0d                	jne    802115 <ipc_find_env+0x28>
			return envs[i].env_id;
  802108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80210b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802110:	8b 40 48             	mov    0x48(%eax),%eax
  802113:	eb 0f                	jmp    802124 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802115:	83 c0 01             	add    $0x1,%eax
  802118:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211d:	75 d9                	jne    8020f8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802124:	5d                   	pop    %ebp
  802125:	c3                   	ret    

00802126 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212c:	89 d0                	mov    %edx,%eax
  80212e:	c1 e8 16             	shr    $0x16,%eax
  802131:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802138:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213d:	f6 c1 01             	test   $0x1,%cl
  802140:	74 1d                	je     80215f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802142:	c1 ea 0c             	shr    $0xc,%edx
  802145:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80214c:	f6 c2 01             	test   $0x1,%dl
  80214f:	74 0e                	je     80215f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802151:	c1 ea 0c             	shr    $0xc,%edx
  802154:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215b:	ef 
  80215c:	0f b7 c0             	movzwl %ax,%eax
}
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    
  802161:	66 90                	xchg   %ax,%ax
  802163:	66 90                	xchg   %ax,%ax
  802165:	66 90                	xchg   %ax,%ax
  802167:	66 90                	xchg   %ax,%ax
  802169:	66 90                	xchg   %ax,%ax
  80216b:	66 90                	xchg   %ax,%ax
  80216d:	66 90                	xchg   %ax,%ax
  80216f:	90                   	nop

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80217b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80217f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 f6                	test   %esi,%esi
  802189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218d:	89 ca                	mov    %ecx,%edx
  80218f:	89 f8                	mov    %edi,%eax
  802191:	75 3d                	jne    8021d0 <__udivdi3+0x60>
  802193:	39 cf                	cmp    %ecx,%edi
  802195:	0f 87 c5 00 00 00    	ja     802260 <__udivdi3+0xf0>
  80219b:	85 ff                	test   %edi,%edi
  80219d:	89 fd                	mov    %edi,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f7                	div    %edi
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 c8                	mov    %ecx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	89 cf                	mov    %ecx,%edi
  8021b8:	f7 f5                	div    %ebp
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 ce                	cmp    %ecx,%esi
  8021d2:	77 74                	ja     802248 <__udivdi3+0xd8>
  8021d4:	0f bd fe             	bsr    %esi,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0x108>
  8021e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	29 fb                	sub    %edi,%ebx
  8021eb:	d3 e6                	shl    %cl,%esi
  8021ed:	89 d9                	mov    %ebx,%ecx
  8021ef:	d3 ed                	shr    %cl,%ebp
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	09 ee                	or     %ebp,%esi
  8021f7:	89 d9                	mov    %ebx,%ecx
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 d5                	mov    %edx,%ebp
  8021ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802203:	d3 ed                	shr    %cl,%ebp
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e2                	shl    %cl,%edx
  802209:	89 d9                	mov    %ebx,%ecx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	09 c2                	or     %eax,%edx
  80220f:	89 d0                	mov    %edx,%eax
  802211:	89 ea                	mov    %ebp,%edx
  802213:	f7 f6                	div    %esi
  802215:	89 d5                	mov    %edx,%ebp
  802217:	89 c3                	mov    %eax,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	72 10                	jb     802231 <__udivdi3+0xc1>
  802221:	8b 74 24 08          	mov    0x8(%esp),%esi
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e6                	shl    %cl,%esi
  802229:	39 c6                	cmp    %eax,%esi
  80222b:	73 07                	jae    802234 <__udivdi3+0xc4>
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	75 03                	jne    802234 <__udivdi3+0xc4>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 d8                	mov    %ebx,%eax
  802238:	89 fa                	mov    %edi,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	31 ff                	xor    %edi,%edi
  80224a:	31 db                	xor    %ebx,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d8                	mov    %ebx,%eax
  802262:	f7 f7                	div    %edi
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 c3                	mov    %eax,%ebx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 fa                	mov    %edi,%edx
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 ce                	cmp    %ecx,%esi
  80227a:	72 0c                	jb     802288 <__udivdi3+0x118>
  80227c:	31 db                	xor    %ebx,%ebx
  80227e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802282:	0f 87 34 ff ff ff    	ja     8021bc <__udivdi3+0x4c>
  802288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80228d:	e9 2a ff ff ff       	jmp    8021bc <__udivdi3+0x4c>
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 d2                	test   %edx,%edx
  8022b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f3                	mov    %esi,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x48>
  8022cc:	39 f7                	cmp    %esi,%edi
  8022ce:	76 50                	jbe    802320 <__umoddi3+0x80>
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	f7 f7                	div    %edi
  8022d6:	89 d0                	mov    %edx,%eax
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	77 52                	ja     802340 <__umoddi3+0xa0>
  8022ee:	0f bd ea             	bsr    %edx,%ebp
  8022f1:	83 f5 1f             	xor    $0x1f,%ebp
  8022f4:	75 5a                	jne    802350 <__umoddi3+0xb0>
  8022f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	39 0c 24             	cmp    %ecx,(%esp)
  802303:	0f 86 d7 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  802309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	85 ff                	test   %edi,%edi
  802322:	89 fd                	mov    %edi,%ebp
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 f0                	mov    %esi,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 c8                	mov    %ecx,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	eb 99                	jmp    8022d8 <__umoddi3+0x38>
  80233f:	90                   	nop
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 1c             	add    $0x1c,%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	8b 34 24             	mov    (%esp),%esi
  802353:	bf 20 00 00 00       	mov    $0x20,%edi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	29 ef                	sub    %ebp,%edi
  80235c:	d3 e0                	shl    %cl,%eax
  80235e:	89 f9                	mov    %edi,%ecx
  802360:	89 f2                	mov    %esi,%edx
  802362:	d3 ea                	shr    %cl,%edx
  802364:	89 e9                	mov    %ebp,%ecx
  802366:	09 c2                	or     %eax,%edx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 14 24             	mov    %edx,(%esp)
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	d3 e2                	shl    %cl,%edx
  802371:	89 f9                	mov    %edi,%ecx
  802373:	89 54 24 04          	mov    %edx,0x4(%esp)
  802377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	89 c6                	mov    %eax,%esi
  802381:	d3 e3                	shl    %cl,%ebx
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 d0                	mov    %edx,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	09 d8                	or     %ebx,%eax
  80238d:	89 d3                	mov    %edx,%ebx
  80238f:	89 f2                	mov    %esi,%edx
  802391:	f7 34 24             	divl   (%esp)
  802394:	89 d6                	mov    %edx,%esi
  802396:	d3 e3                	shl    %cl,%ebx
  802398:	f7 64 24 04          	mull   0x4(%esp)
  80239c:	39 d6                	cmp    %edx,%esi
  80239e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	72 08                	jb     8023b0 <__umoddi3+0x110>
  8023a8:	75 11                	jne    8023bb <__umoddi3+0x11b>
  8023aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ae:	73 0b                	jae    8023bb <__umoddi3+0x11b>
  8023b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b4:	1b 14 24             	sbb    (%esp),%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 c3                	mov    %eax,%ebx
  8023bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023bf:	29 da                	sub    %ebx,%edx
  8023c1:	19 ce                	sbb    %ecx,%esi
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	d3 ee                	shr    %cl,%esi
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	83 c4 1c             	add    $0x1c,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 f9                	sub    %edi,%ecx
  8023e2:	19 d6                	sbb    %edx,%esi
  8023e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ec:	e9 18 ff ff ff       	jmp    802309 <__umoddi3+0x69>
