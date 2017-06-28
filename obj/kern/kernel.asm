
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 8c 1e 2a f0 00 	cmpl   $0x0,0xf02a1e8c
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 8c 1e 2a f0    	mov    %esi,0xf02a1e8c

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 99 5c 00 00       	call   f0105cfa <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 6a 10 f0       	push   $0xf0106a80
f010006d:	e8 7a 36 00 00       	call   f01036ec <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 4a 36 00 00       	call   f01036c6 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 26 73 10 f0 	movl   $0xf0107326,(%esp)
f0100083:	e8 64 36 00 00       	call   f01036ec <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 2e 09 00 00       	call   f01009c3 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 00 44 32 f0       	mov    $0xf0324400,%eax
f01000a6:	2d b4 0a 2a f0       	sub    $0xf02a0ab4,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 b4 0a 2a f0       	push   $0xf02a0ab4
f01000b3:	e8 22 56 00 00       	call   f01056da <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 d1 05 00 00       	call   f010068e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ec 6a 10 f0       	push   $0xf0106aec
f01000ca:	e8 1d 36 00 00       	call   f01036ec <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 47 12 00 00       	call   f010131b <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 8e 2e 00 00       	call   f0102f67 <env_init>
	trap_init();
f01000d9:	e8 f1 36 00 00       	call   f01037cf <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 0d 59 00 00       	call   f01059f0 <mp_init>
	lapic_init();
f01000e3:	e8 2d 5c 00 00       	call   f0105d15 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 10 35 00 00       	call   f01035fd <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000ed:	e8 a1 66 00 00       	call   f0106793 <time_init>
	pci_init();
f01000f2:	e8 7c 66 00 00       	call   f0106773 <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000f7:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f01000fe:	e8 65 5e 00 00       	call   f0105f68 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100103:	83 c4 10             	add    $0x10,%esp
f0100106:	83 3d ac 1e 2a f0 07 	cmpl   $0x7,0xf02a1eac
f010010d:	77 16                	ja     f0100125 <i386_init+0x8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010010f:	68 00 70 00 00       	push   $0x7000
f0100114:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0100119:	6a 6a                	push   $0x6a
f010011b:	68 07 6b 10 f0       	push   $0xf0106b07
f0100120:	e8 1b ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100125:	83 ec 04             	sub    $0x4,%esp
f0100128:	b8 56 59 10 f0       	mov    $0xf0105956,%eax
f010012d:	2d dc 58 10 f0       	sub    $0xf01058dc,%eax
f0100132:	50                   	push   %eax
f0100133:	68 dc 58 10 f0       	push   $0xf01058dc
f0100138:	68 00 70 00 f0       	push   $0xf0007000
f010013d:	e8 e5 55 00 00       	call   f0105727 <memmove>
f0100142:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100145:	bb 20 20 2a f0       	mov    $0xf02a2020,%ebx
f010014a:	eb 4d                	jmp    f0100199 <i386_init+0xff>
		if (c == cpus + cpunum())  // We've started already.
f010014c:	e8 a9 5b 00 00       	call   f0105cfa <cpunum>
f0100151:	6b c0 74             	imul   $0x74,%eax,%eax
f0100154:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f0100159:	39 c3                	cmp    %eax,%ebx
f010015b:	74 39                	je     f0100196 <i386_init+0xfc>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015d:	89 d8                	mov    %ebx,%eax
f010015f:	2d 20 20 2a f0       	sub    $0xf02a2020,%eax
f0100164:	c1 f8 02             	sar    $0x2,%eax
f0100167:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016d:	c1 e0 0f             	shl    $0xf,%eax
f0100170:	05 00 b0 2a f0       	add    $0xf02ab000,%eax
f0100175:	a3 90 1e 2a f0       	mov    %eax,0xf02a1e90
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010017a:	83 ec 08             	sub    $0x8,%esp
f010017d:	68 00 70 00 00       	push   $0x7000
f0100182:	0f b6 03             	movzbl (%ebx),%eax
f0100185:	50                   	push   %eax
f0100186:	e8 d8 5c 00 00       	call   f0105e63 <lapic_startap>
f010018b:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010018e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100191:	83 f8 01             	cmp    $0x1,%eax
f0100194:	75 f8                	jne    f010018e <i386_init+0xf4>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100196:	83 c3 74             	add    $0x74,%ebx
f0100199:	6b 05 c4 23 2a f0 74 	imul   $0x74,0xf02a23c4,%eax
f01001a0:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f01001a5:	39 c3                	cmp    %eax,%ebx
f01001a7:	72 a3                	jb     f010014c <i386_init+0xb2>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001a9:	83 ec 08             	sub    $0x8,%esp
f01001ac:	6a 01                	push   $0x1
f01001ae:	68 a4 12 1d f0       	push   $0xf01d12a4
f01001b3:	e8 60 2f 00 00       	call   f0103118 <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001b8:	83 c4 08             	add    $0x8,%esp
f01001bb:	6a 02                	push   $0x2
f01001bd:	68 34 89 22 f0       	push   $0xf0228934
f01001c2:	e8 51 2f 00 00       	call   f0103118 <env_create>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
f01001c7:	83 c4 08             	add    $0x8,%esp
f01001ca:	6a 00                	push   $0x0
f01001cc:	68 50 c1 1c f0       	push   $0xf01cc150
f01001d1:	e8 42 2f 00 00       	call   f0103118 <env_create>
	//ENV_CREATE(user_primes, ENV_TYPE_USER);
	
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001d6:	83 c4 08             	add    $0x8,%esp
f01001d9:	6a 00                	push   $0x0
f01001db:	68 bc a3 16 f0       	push   $0xf016a3bc
f01001e0:	e8 33 2f 00 00       	call   f0103118 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001e5:	83 c4 08             	add    $0x8,%esp
f01001e8:	6a 00                	push   $0x0
f01001ea:	68 bc a3 16 f0       	push   $0xf016a3bc
f01001ef:	e8 24 2f 00 00       	call   f0103118 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001f4:	83 c4 08             	add    $0x8,%esp
f01001f7:	6a 00                	push   $0x0
f01001f9:	68 bc a3 16 f0       	push   $0xf016a3bc
f01001fe:	e8 15 2f 00 00       	call   f0103118 <env_create>

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100203:	e8 2a 04 00 00       	call   f0100632 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f0100208:	e8 00 43 00 00       	call   f010450d <sched_yield>

f010020d <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010020d:	55                   	push   %ebp
f010020e:	89 e5                	mov    %esp,%ebp
f0100210:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f0100213:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100218:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010021d:	77 15                	ja     f0100234 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010021f:	50                   	push   %eax
f0100220:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0100225:	68 81 00 00 00       	push   $0x81
f010022a:	68 07 6b 10 f0       	push   $0xf0106b07
f010022f:	e8 0c fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100234:	05 00 00 00 10       	add    $0x10000000,%eax
f0100239:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010023c:	e8 b9 5a 00 00       	call   f0105cfa <cpunum>
f0100241:	83 ec 08             	sub    $0x8,%esp
f0100244:	50                   	push   %eax
f0100245:	68 13 6b 10 f0       	push   $0xf0106b13
f010024a:	e8 9d 34 00 00       	call   f01036ec <cprintf>

	lapic_init();
f010024f:	e8 c1 5a 00 00       	call   f0105d15 <lapic_init>
	env_init_percpu();
f0100254:	e8 de 2c 00 00       	call   f0102f37 <env_init_percpu>
	trap_init_percpu();
f0100259:	e8 a2 34 00 00       	call   f0103700 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010025e:	e8 97 5a 00 00       	call   f0105cfa <cpunum>
f0100263:	6b d0 74             	imul   $0x74,%eax,%edx
f0100266:	81 c2 20 20 2a f0    	add    $0xf02a2020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010026c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100271:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100275:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f010027c:	e8 e7 5c 00 00       	call   f0105f68 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	
	sched_yield();
f0100281:	e8 87 42 00 00       	call   f010450d <sched_yield>

f0100286 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100286:	55                   	push   %ebp
f0100287:	89 e5                	mov    %esp,%ebp
f0100289:	53                   	push   %ebx
f010028a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010028d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100290:	ff 75 0c             	pushl  0xc(%ebp)
f0100293:	ff 75 08             	pushl  0x8(%ebp)
f0100296:	68 29 6b 10 f0       	push   $0xf0106b29
f010029b:	e8 4c 34 00 00       	call   f01036ec <cprintf>
	vcprintf(fmt, ap);
f01002a0:	83 c4 08             	add    $0x8,%esp
f01002a3:	53                   	push   %ebx
f01002a4:	ff 75 10             	pushl  0x10(%ebp)
f01002a7:	e8 1a 34 00 00       	call   f01036c6 <vcprintf>
	cprintf("\n");
f01002ac:	c7 04 24 26 73 10 f0 	movl   $0xf0107326,(%esp)
f01002b3:	e8 34 34 00 00       	call   f01036ec <cprintf>
	va_end(ap);
}
f01002b8:	83 c4 10             	add    $0x10,%esp
f01002bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002be:	c9                   	leave  
f01002bf:	c3                   	ret    

f01002c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002c9:	a8 01                	test   $0x1,%al
f01002cb:	74 0b                	je     f01002d8 <serial_proc_data+0x18>
f01002cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002d3:	0f b6 c0             	movzbl %al,%eax
f01002d6:	eb 05                	jmp    f01002dd <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002dd:	5d                   	pop    %ebp
f01002de:	c3                   	ret    

f01002df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002df:	55                   	push   %ebp
f01002e0:	89 e5                	mov    %esp,%ebp
f01002e2:	53                   	push   %ebx
f01002e3:	83 ec 04             	sub    $0x4,%esp
f01002e6:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e8:	eb 2b                	jmp    f0100315 <cons_intr+0x36>
		if (c == 0)
f01002ea:	85 c0                	test   %eax,%eax
f01002ec:	74 27                	je     f0100315 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002ee:	8b 0d 24 12 2a f0    	mov    0xf02a1224,%ecx
f01002f4:	8d 51 01             	lea    0x1(%ecx),%edx
f01002f7:	89 15 24 12 2a f0    	mov    %edx,0xf02a1224
f01002fd:	88 81 20 10 2a f0    	mov    %al,-0xfd5efe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100303:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100309:	75 0a                	jne    f0100315 <cons_intr+0x36>
			cons.wpos = 0;
f010030b:	c7 05 24 12 2a f0 00 	movl   $0x0,0xf02a1224
f0100312:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100315:	ff d3                	call   *%ebx
f0100317:	83 f8 ff             	cmp    $0xffffffff,%eax
f010031a:	75 ce                	jne    f01002ea <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010031c:	83 c4 04             	add    $0x4,%esp
f010031f:	5b                   	pop    %ebx
f0100320:	5d                   	pop    %ebp
f0100321:	c3                   	ret    

f0100322 <kbd_proc_data>:
f0100322:	ba 64 00 00 00       	mov    $0x64,%edx
f0100327:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100328:	a8 01                	test   $0x1,%al
f010032a:	0f 84 f0 00 00 00    	je     f0100420 <kbd_proc_data+0xfe>
f0100330:	ba 60 00 00 00       	mov    $0x60,%edx
f0100335:	ec                   	in     (%dx),%al
f0100336:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100338:	3c e0                	cmp    $0xe0,%al
f010033a:	75 0d                	jne    f0100349 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f010033c:	83 0d 00 10 2a f0 40 	orl    $0x40,0xf02a1000
		return 0;
f0100343:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100348:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100349:	55                   	push   %ebp
f010034a:	89 e5                	mov    %esp,%ebp
f010034c:	53                   	push   %ebx
f010034d:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100350:	84 c0                	test   %al,%al
f0100352:	79 36                	jns    f010038a <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100354:	8b 0d 00 10 2a f0    	mov    0xf02a1000,%ecx
f010035a:	89 cb                	mov    %ecx,%ebx
f010035c:	83 e3 40             	and    $0x40,%ebx
f010035f:	83 e0 7f             	and    $0x7f,%eax
f0100362:	85 db                	test   %ebx,%ebx
f0100364:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100367:	0f b6 d2             	movzbl %dl,%edx
f010036a:	0f b6 82 a0 6c 10 f0 	movzbl -0xfef9360(%edx),%eax
f0100371:	83 c8 40             	or     $0x40,%eax
f0100374:	0f b6 c0             	movzbl %al,%eax
f0100377:	f7 d0                	not    %eax
f0100379:	21 c8                	and    %ecx,%eax
f010037b:	a3 00 10 2a f0       	mov    %eax,0xf02a1000
		return 0;
f0100380:	b8 00 00 00 00       	mov    $0x0,%eax
f0100385:	e9 9e 00 00 00       	jmp    f0100428 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010038a:	8b 0d 00 10 2a f0    	mov    0xf02a1000,%ecx
f0100390:	f6 c1 40             	test   $0x40,%cl
f0100393:	74 0e                	je     f01003a3 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100395:	83 c8 80             	or     $0xffffff80,%eax
f0100398:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010039a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010039d:	89 0d 00 10 2a f0    	mov    %ecx,0xf02a1000
	}

	shift |= shiftcode[data];
f01003a3:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01003a6:	0f b6 82 a0 6c 10 f0 	movzbl -0xfef9360(%edx),%eax
f01003ad:	0b 05 00 10 2a f0    	or     0xf02a1000,%eax
f01003b3:	0f b6 8a a0 6b 10 f0 	movzbl -0xfef9460(%edx),%ecx
f01003ba:	31 c8                	xor    %ecx,%eax
f01003bc:	a3 00 10 2a f0       	mov    %eax,0xf02a1000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003c1:	89 c1                	mov    %eax,%ecx
f01003c3:	83 e1 03             	and    $0x3,%ecx
f01003c6:	8b 0c 8d 80 6b 10 f0 	mov    -0xfef9480(,%ecx,4),%ecx
f01003cd:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003d1:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003d4:	a8 08                	test   $0x8,%al
f01003d6:	74 1b                	je     f01003f3 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01003d8:	89 da                	mov    %ebx,%edx
f01003da:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003dd:	83 f9 19             	cmp    $0x19,%ecx
f01003e0:	77 05                	ja     f01003e7 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01003e2:	83 eb 20             	sub    $0x20,%ebx
f01003e5:	eb 0c                	jmp    f01003f3 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01003e7:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ea:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ed:	83 fa 19             	cmp    $0x19,%edx
f01003f0:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003f3:	f7 d0                	not    %eax
f01003f5:	a8 06                	test   $0x6,%al
f01003f7:	75 2d                	jne    f0100426 <kbd_proc_data+0x104>
f01003f9:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003ff:	75 25                	jne    f0100426 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100401:	83 ec 0c             	sub    $0xc,%esp
f0100404:	68 43 6b 10 f0       	push   $0xf0106b43
f0100409:	e8 de 32 00 00       	call   f01036ec <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100413:	b8 03 00 00 00       	mov    $0x3,%eax
f0100418:	ee                   	out    %al,(%dx)
f0100419:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010041c:	89 d8                	mov    %ebx,%eax
f010041e:	eb 08                	jmp    f0100428 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100420:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100425:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100426:	89 d8                	mov    %ebx,%eax
}
f0100428:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010042b:	c9                   	leave  
f010042c:	c3                   	ret    

f010042d <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010042d:	55                   	push   %ebp
f010042e:	89 e5                	mov    %esp,%ebp
f0100430:	57                   	push   %edi
f0100431:	56                   	push   %esi
f0100432:	53                   	push   %ebx
f0100433:	83 ec 1c             	sub    $0x1c,%esp
f0100436:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100438:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010043d:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100442:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100447:	eb 09                	jmp    f0100452 <cons_putc+0x25>
f0100449:	89 ca                	mov    %ecx,%edx
f010044b:	ec                   	in     (%dx),%al
f010044c:	ec                   	in     (%dx),%al
f010044d:	ec                   	in     (%dx),%al
f010044e:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010044f:	83 c3 01             	add    $0x1,%ebx
f0100452:	89 f2                	mov    %esi,%edx
f0100454:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100455:	a8 20                	test   $0x20,%al
f0100457:	75 08                	jne    f0100461 <cons_putc+0x34>
f0100459:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010045f:	7e e8                	jle    f0100449 <cons_putc+0x1c>
f0100461:	89 f8                	mov    %edi,%eax
f0100463:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100466:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010046b:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010046c:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100471:	be 79 03 00 00       	mov    $0x379,%esi
f0100476:	b9 84 00 00 00       	mov    $0x84,%ecx
f010047b:	eb 09                	jmp    f0100486 <cons_putc+0x59>
f010047d:	89 ca                	mov    %ecx,%edx
f010047f:	ec                   	in     (%dx),%al
f0100480:	ec                   	in     (%dx),%al
f0100481:	ec                   	in     (%dx),%al
f0100482:	ec                   	in     (%dx),%al
f0100483:	83 c3 01             	add    $0x1,%ebx
f0100486:	89 f2                	mov    %esi,%edx
f0100488:	ec                   	in     (%dx),%al
f0100489:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010048f:	7f 04                	jg     f0100495 <cons_putc+0x68>
f0100491:	84 c0                	test   %al,%al
f0100493:	79 e8                	jns    f010047d <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100495:	ba 78 03 00 00       	mov    $0x378,%edx
f010049a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010049e:	ee                   	out    %al,(%dx)
f010049f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004a4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004a9:	ee                   	out    %al,(%dx)
f01004aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01004af:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004b0:	89 fa                	mov    %edi,%edx
f01004b2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004b8:	89 f8                	mov    %edi,%eax
f01004ba:	80 cc 07             	or     $0x7,%ah
f01004bd:	85 d2                	test   %edx,%edx
f01004bf:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004c2:	89 f8                	mov    %edi,%eax
f01004c4:	0f b6 c0             	movzbl %al,%eax
f01004c7:	83 f8 09             	cmp    $0x9,%eax
f01004ca:	74 74                	je     f0100540 <cons_putc+0x113>
f01004cc:	83 f8 09             	cmp    $0x9,%eax
f01004cf:	7f 0a                	jg     f01004db <cons_putc+0xae>
f01004d1:	83 f8 08             	cmp    $0x8,%eax
f01004d4:	74 14                	je     f01004ea <cons_putc+0xbd>
f01004d6:	e9 99 00 00 00       	jmp    f0100574 <cons_putc+0x147>
f01004db:	83 f8 0a             	cmp    $0xa,%eax
f01004de:	74 3a                	je     f010051a <cons_putc+0xed>
f01004e0:	83 f8 0d             	cmp    $0xd,%eax
f01004e3:	74 3d                	je     f0100522 <cons_putc+0xf5>
f01004e5:	e9 8a 00 00 00       	jmp    f0100574 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004ea:	0f b7 05 28 12 2a f0 	movzwl 0xf02a1228,%eax
f01004f1:	66 85 c0             	test   %ax,%ax
f01004f4:	0f 84 e6 00 00 00    	je     f01005e0 <cons_putc+0x1b3>
			crt_pos--;
f01004fa:	83 e8 01             	sub    $0x1,%eax
f01004fd:	66 a3 28 12 2a f0    	mov    %ax,0xf02a1228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100503:	0f b7 c0             	movzwl %ax,%eax
f0100506:	66 81 e7 00 ff       	and    $0xff00,%di
f010050b:	83 cf 20             	or     $0x20,%edi
f010050e:	8b 15 2c 12 2a f0    	mov    0xf02a122c,%edx
f0100514:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100518:	eb 78                	jmp    f0100592 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010051a:	66 83 05 28 12 2a f0 	addw   $0x50,0xf02a1228
f0100521:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100522:	0f b7 05 28 12 2a f0 	movzwl 0xf02a1228,%eax
f0100529:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010052f:	c1 e8 16             	shr    $0x16,%eax
f0100532:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100535:	c1 e0 04             	shl    $0x4,%eax
f0100538:	66 a3 28 12 2a f0    	mov    %ax,0xf02a1228
f010053e:	eb 52                	jmp    f0100592 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100540:	b8 20 00 00 00       	mov    $0x20,%eax
f0100545:	e8 e3 fe ff ff       	call   f010042d <cons_putc>
		cons_putc(' ');
f010054a:	b8 20 00 00 00       	mov    $0x20,%eax
f010054f:	e8 d9 fe ff ff       	call   f010042d <cons_putc>
		cons_putc(' ');
f0100554:	b8 20 00 00 00       	mov    $0x20,%eax
f0100559:	e8 cf fe ff ff       	call   f010042d <cons_putc>
		cons_putc(' ');
f010055e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100563:	e8 c5 fe ff ff       	call   f010042d <cons_putc>
		cons_putc(' ');
f0100568:	b8 20 00 00 00       	mov    $0x20,%eax
f010056d:	e8 bb fe ff ff       	call   f010042d <cons_putc>
f0100572:	eb 1e                	jmp    f0100592 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100574:	0f b7 05 28 12 2a f0 	movzwl 0xf02a1228,%eax
f010057b:	8d 50 01             	lea    0x1(%eax),%edx
f010057e:	66 89 15 28 12 2a f0 	mov    %dx,0xf02a1228
f0100585:	0f b7 c0             	movzwl %ax,%eax
f0100588:	8b 15 2c 12 2a f0    	mov    0xf02a122c,%edx
f010058e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100592:	66 81 3d 28 12 2a f0 	cmpw   $0x7cf,0xf02a1228
f0100599:	cf 07 
f010059b:	76 43                	jbe    f01005e0 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010059d:	a1 2c 12 2a f0       	mov    0xf02a122c,%eax
f01005a2:	83 ec 04             	sub    $0x4,%esp
f01005a5:	68 00 0f 00 00       	push   $0xf00
f01005aa:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b0:	52                   	push   %edx
f01005b1:	50                   	push   %eax
f01005b2:	e8 70 51 00 00       	call   f0105727 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005b7:	8b 15 2c 12 2a f0    	mov    0xf02a122c,%edx
f01005bd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005c3:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005c9:	83 c4 10             	add    $0x10,%esp
f01005cc:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005d1:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d4:	39 d0                	cmp    %edx,%eax
f01005d6:	75 f4                	jne    f01005cc <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005d8:	66 83 2d 28 12 2a f0 	subw   $0x50,0xf02a1228
f01005df:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005e0:	8b 0d 30 12 2a f0    	mov    0xf02a1230,%ecx
f01005e6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005eb:	89 ca                	mov    %ecx,%edx
f01005ed:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ee:	0f b7 1d 28 12 2a f0 	movzwl 0xf02a1228,%ebx
f01005f5:	8d 71 01             	lea    0x1(%ecx),%esi
f01005f8:	89 d8                	mov    %ebx,%eax
f01005fa:	66 c1 e8 08          	shr    $0x8,%ax
f01005fe:	89 f2                	mov    %esi,%edx
f0100600:	ee                   	out    %al,(%dx)
f0100601:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100606:	89 ca                	mov    %ecx,%edx
f0100608:	ee                   	out    %al,(%dx)
f0100609:	89 d8                	mov    %ebx,%eax
f010060b:	89 f2                	mov    %esi,%edx
f010060d:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010060e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100611:	5b                   	pop    %ebx
f0100612:	5e                   	pop    %esi
f0100613:	5f                   	pop    %edi
f0100614:	5d                   	pop    %ebp
f0100615:	c3                   	ret    

f0100616 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100616:	80 3d 34 12 2a f0 00 	cmpb   $0x0,0xf02a1234
f010061d:	74 11                	je     f0100630 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010061f:	55                   	push   %ebp
f0100620:	89 e5                	mov    %esp,%ebp
f0100622:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100625:	b8 c0 02 10 f0       	mov    $0xf01002c0,%eax
f010062a:	e8 b0 fc ff ff       	call   f01002df <cons_intr>
}
f010062f:	c9                   	leave  
f0100630:	f3 c3                	repz ret 

f0100632 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100638:	b8 22 03 10 f0       	mov    $0xf0100322,%eax
f010063d:	e8 9d fc ff ff       	call   f01002df <cons_intr>
}
f0100642:	c9                   	leave  
f0100643:	c3                   	ret    

f0100644 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100644:	55                   	push   %ebp
f0100645:	89 e5                	mov    %esp,%ebp
f0100647:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010064a:	e8 c7 ff ff ff       	call   f0100616 <serial_intr>
	kbd_intr();
f010064f:	e8 de ff ff ff       	call   f0100632 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100654:	a1 20 12 2a f0       	mov    0xf02a1220,%eax
f0100659:	3b 05 24 12 2a f0    	cmp    0xf02a1224,%eax
f010065f:	74 26                	je     f0100687 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100661:	8d 50 01             	lea    0x1(%eax),%edx
f0100664:	89 15 20 12 2a f0    	mov    %edx,0xf02a1220
f010066a:	0f b6 88 20 10 2a f0 	movzbl -0xfd5efe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100671:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100673:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100679:	75 11                	jne    f010068c <cons_getc+0x48>
			cons.rpos = 0;
f010067b:	c7 05 20 12 2a f0 00 	movl   $0x0,0xf02a1220
f0100682:	00 00 00 
f0100685:	eb 05                	jmp    f010068c <cons_getc+0x48>
		return c;
	}
	return 0;
f0100687:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010068c:	c9                   	leave  
f010068d:	c3                   	ret    

f010068e <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010068e:	55                   	push   %ebp
f010068f:	89 e5                	mov    %esp,%ebp
f0100691:	57                   	push   %edi
f0100692:	56                   	push   %esi
f0100693:	53                   	push   %ebx
f0100694:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100697:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010069e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006a5:	5a a5 
	if (*cp != 0xA55A) {
f01006a7:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006ae:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006b2:	74 11                	je     f01006c5 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006b4:	c7 05 30 12 2a f0 b4 	movl   $0x3b4,0xf02a1230
f01006bb:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006be:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006c3:	eb 16                	jmp    f01006db <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006c5:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006cc:	c7 05 30 12 2a f0 d4 	movl   $0x3d4,0xf02a1230
f01006d3:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006d6:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006db:	8b 3d 30 12 2a f0    	mov    0xf02a1230,%edi
f01006e1:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006e6:	89 fa                	mov    %edi,%edx
f01006e8:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006e9:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ec:	89 da                	mov    %ebx,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	0f b6 c8             	movzbl %al,%ecx
f01006f2:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fa:	89 fa                	mov    %edi,%edx
f01006fc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fd:	89 da                	mov    %ebx,%edx
f01006ff:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100700:	89 35 2c 12 2a f0    	mov    %esi,0xf02a122c
	crt_pos = pos;
f0100706:	0f b6 c0             	movzbl %al,%eax
f0100709:	09 c8                	or     %ecx,%eax
f010070b:	66 a3 28 12 2a f0    	mov    %ax,0xf02a1228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100711:	e8 1c ff ff ff       	call   f0100632 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100716:	83 ec 0c             	sub    $0xc,%esp
f0100719:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0100720:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100725:	50                   	push   %eax
f0100726:	e8 5a 2e 00 00       	call   f0103585 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072b:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100730:	b8 00 00 00 00       	mov    $0x0,%eax
f0100735:	89 f2                	mov    %esi,%edx
f0100737:	ee                   	out    %al,(%dx)
f0100738:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010073d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100742:	ee                   	out    %al,(%dx)
f0100743:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100748:	b8 0c 00 00 00       	mov    $0xc,%eax
f010074d:	89 da                	mov    %ebx,%edx
f010074f:	ee                   	out    %al,(%dx)
f0100750:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100755:	b8 00 00 00 00       	mov    $0x0,%eax
f010075a:	ee                   	out    %al,(%dx)
f010075b:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100760:	b8 03 00 00 00       	mov    $0x3,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010076b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100770:	ee                   	out    %al,(%dx)
f0100771:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100776:	b8 01 00 00 00       	mov    $0x1,%eax
f010077b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010077c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100781:	ec                   	in     (%dx),%al
f0100782:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100784:	83 c4 10             	add    $0x10,%esp
f0100787:	3c ff                	cmp    $0xff,%al
f0100789:	0f 95 05 34 12 2a f0 	setne  0xf02a1234
f0100790:	89 f2                	mov    %esi,%edx
f0100792:	ec                   	in     (%dx),%al
f0100793:	89 da                	mov    %ebx,%edx
f0100795:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100796:	80 f9 ff             	cmp    $0xff,%cl
f0100799:	74 21                	je     f01007bc <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f010079b:	83 ec 0c             	sub    $0xc,%esp
f010079e:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01007a5:	25 ef ff 00 00       	and    $0xffef,%eax
f01007aa:	50                   	push   %eax
f01007ab:	e8 d5 2d 00 00       	call   f0103585 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007b0:	83 c4 10             	add    $0x10,%esp
f01007b3:	80 3d 34 12 2a f0 00 	cmpb   $0x0,0xf02a1234
f01007ba:	75 10                	jne    f01007cc <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f01007bc:	83 ec 0c             	sub    $0xc,%esp
f01007bf:	68 4f 6b 10 f0       	push   $0xf0106b4f
f01007c4:	e8 23 2f 00 00       	call   f01036ec <cprintf>
f01007c9:	83 c4 10             	add    $0x10,%esp
}
f01007cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007cf:	5b                   	pop    %ebx
f01007d0:	5e                   	pop    %esi
f01007d1:	5f                   	pop    %edi
f01007d2:	5d                   	pop    %ebp
f01007d3:	c3                   	ret    

f01007d4 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007d4:	55                   	push   %ebp
f01007d5:	89 e5                	mov    %esp,%ebp
f01007d7:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007da:	8b 45 08             	mov    0x8(%ebp),%eax
f01007dd:	e8 4b fc ff ff       	call   f010042d <cons_putc>
}
f01007e2:	c9                   	leave  
f01007e3:	c3                   	ret    

f01007e4 <getchar>:

int
getchar(void)
{
f01007e4:	55                   	push   %ebp
f01007e5:	89 e5                	mov    %esp,%ebp
f01007e7:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ea:	e8 55 fe ff ff       	call   f0100644 <cons_getc>
f01007ef:	85 c0                	test   %eax,%eax
f01007f1:	74 f7                	je     f01007ea <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007f3:	c9                   	leave  
f01007f4:	c3                   	ret    

f01007f5 <iscons>:

int
iscons(int fdnum)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007fd:	5d                   	pop    %ebp
f01007fe:	c3                   	ret    

f01007ff <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007ff:	55                   	push   %ebp
f0100800:	89 e5                	mov    %esp,%ebp
f0100802:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100805:	68 a0 6d 10 f0       	push   $0xf0106da0
f010080a:	68 be 6d 10 f0       	push   $0xf0106dbe
f010080f:	68 c3 6d 10 f0       	push   $0xf0106dc3
f0100814:	e8 d3 2e 00 00       	call   f01036ec <cprintf>
f0100819:	83 c4 0c             	add    $0xc,%esp
f010081c:	68 8c 6e 10 f0       	push   $0xf0106e8c
f0100821:	68 cc 6d 10 f0       	push   $0xf0106dcc
f0100826:	68 c3 6d 10 f0       	push   $0xf0106dc3
f010082b:	e8 bc 2e 00 00       	call   f01036ec <cprintf>
f0100830:	83 c4 0c             	add    $0xc,%esp
f0100833:	68 d5 6d 10 f0       	push   $0xf0106dd5
f0100838:	68 ec 6d 10 f0       	push   $0xf0106dec
f010083d:	68 c3 6d 10 f0       	push   $0xf0106dc3
f0100842:	e8 a5 2e 00 00       	call   f01036ec <cprintf>
	return 0;
}
f0100847:	b8 00 00 00 00       	mov    $0x0,%eax
f010084c:	c9                   	leave  
f010084d:	c3                   	ret    

f010084e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010084e:	55                   	push   %ebp
f010084f:	89 e5                	mov    %esp,%ebp
f0100851:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100854:	68 f6 6d 10 f0       	push   $0xf0106df6
f0100859:	e8 8e 2e 00 00       	call   f01036ec <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010085e:	83 c4 08             	add    $0x8,%esp
f0100861:	68 0c 00 10 00       	push   $0x10000c
f0100866:	68 b4 6e 10 f0       	push   $0xf0106eb4
f010086b:	e8 7c 2e 00 00       	call   f01036ec <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100870:	83 c4 0c             	add    $0xc,%esp
f0100873:	68 0c 00 10 00       	push   $0x10000c
f0100878:	68 0c 00 10 f0       	push   $0xf010000c
f010087d:	68 dc 6e 10 f0       	push   $0xf0106edc
f0100882:	e8 65 2e 00 00       	call   f01036ec <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100887:	83 c4 0c             	add    $0xc,%esp
f010088a:	68 61 6a 10 00       	push   $0x106a61
f010088f:	68 61 6a 10 f0       	push   $0xf0106a61
f0100894:	68 00 6f 10 f0       	push   $0xf0106f00
f0100899:	e8 4e 2e 00 00       	call   f01036ec <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010089e:	83 c4 0c             	add    $0xc,%esp
f01008a1:	68 b4 0a 2a 00       	push   $0x2a0ab4
f01008a6:	68 b4 0a 2a f0       	push   $0xf02a0ab4
f01008ab:	68 24 6f 10 f0       	push   $0xf0106f24
f01008b0:	e8 37 2e 00 00       	call   f01036ec <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008b5:	83 c4 0c             	add    $0xc,%esp
f01008b8:	68 00 44 32 00       	push   $0x324400
f01008bd:	68 00 44 32 f0       	push   $0xf0324400
f01008c2:	68 48 6f 10 f0       	push   $0xf0106f48
f01008c7:	e8 20 2e 00 00       	call   f01036ec <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008cc:	b8 ff 47 32 f0       	mov    $0xf03247ff,%eax
f01008d1:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008d6:	83 c4 08             	add    $0x8,%esp
f01008d9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008de:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008e4:	85 c0                	test   %eax,%eax
f01008e6:	0f 48 c2             	cmovs  %edx,%eax
f01008e9:	c1 f8 0a             	sar    $0xa,%eax
f01008ec:	50                   	push   %eax
f01008ed:	68 6c 6f 10 f0       	push   $0xf0106f6c
f01008f2:	e8 f5 2d 00 00       	call   f01036ec <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fc:	c9                   	leave  
f01008fd:	c3                   	ret    

f01008fe <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008fe:	55                   	push   %ebp
f01008ff:	89 e5                	mov    %esp,%ebp
f0100901:	56                   	push   %esi
f0100902:	53                   	push   %ebx
f0100903:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100906:	89 eb                	mov    %ebp,%ebx
	struct Eipdebuginfo info;
	uint32_t *test = (uint32_t *) read_ebp();
	cprintf("Stack backtrace:\n");
f0100908:	68 0f 6e 10 f0       	push   $0xf0106e0f
f010090d:	e8 da 2d 00 00       	call   f01036ec <cprintf>
	while(test){
f0100912:	83 c4 10             	add    $0x10,%esp
    		cprintf(" %08x", *(test+2));
    		cprintf(" %08x", *(test+3));
   		cprintf(" %08x", *(test+4));
		cprintf(" %08x", *(test+5));
   		cprintf(" %08x\n", *(test+6));
		debuginfo_eip(*(test+1), &info);
f0100915:	8d 75 e0             	lea    -0x20(%ebp),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	struct Eipdebuginfo info;
	uint32_t *test = (uint32_t *) read_ebp();
	cprintf("Stack backtrace:\n");
	while(test){
f0100918:	e9 92 00 00 00       	jmp    f01009af <mon_backtrace+0xb1>
    		cprintf("ebp %08x  eip %08x Args", test, *(test+1));
f010091d:	83 ec 04             	sub    $0x4,%esp
f0100920:	ff 73 04             	pushl  0x4(%ebx)
f0100923:	53                   	push   %ebx
f0100924:	68 21 6e 10 f0       	push   $0xf0106e21
f0100929:	e8 be 2d 00 00       	call   f01036ec <cprintf>
    		cprintf(" %08x", *(test+2));
f010092e:	83 c4 08             	add    $0x8,%esp
f0100931:	ff 73 08             	pushl  0x8(%ebx)
f0100934:	68 39 6e 10 f0       	push   $0xf0106e39
f0100939:	e8 ae 2d 00 00       	call   f01036ec <cprintf>
    		cprintf(" %08x", *(test+3));
f010093e:	83 c4 08             	add    $0x8,%esp
f0100941:	ff 73 0c             	pushl  0xc(%ebx)
f0100944:	68 39 6e 10 f0       	push   $0xf0106e39
f0100949:	e8 9e 2d 00 00       	call   f01036ec <cprintf>
   		cprintf(" %08x", *(test+4));
f010094e:	83 c4 08             	add    $0x8,%esp
f0100951:	ff 73 10             	pushl  0x10(%ebx)
f0100954:	68 39 6e 10 f0       	push   $0xf0106e39
f0100959:	e8 8e 2d 00 00       	call   f01036ec <cprintf>
		cprintf(" %08x", *(test+5));
f010095e:	83 c4 08             	add    $0x8,%esp
f0100961:	ff 73 14             	pushl  0x14(%ebx)
f0100964:	68 39 6e 10 f0       	push   $0xf0106e39
f0100969:	e8 7e 2d 00 00       	call   f01036ec <cprintf>
   		cprintf(" %08x\n", *(test+6));
f010096e:	83 c4 08             	add    $0x8,%esp
f0100971:	ff 73 18             	pushl  0x18(%ebx)
f0100974:	68 ce 86 10 f0       	push   $0xf01086ce
f0100979:	e8 6e 2d 00 00       	call   f01036ec <cprintf>
		debuginfo_eip(*(test+1), &info);
f010097e:	83 c4 08             	add    $0x8,%esp
f0100981:	56                   	push   %esi
f0100982:	ff 73 04             	pushl  0x4(%ebx)
f0100985:	e8 c6 42 00 00       	call   f0104c50 <debuginfo_eip>
		cprintf("%s:%d:%.*s+%d\n",info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (int)*(test+1) - info.eip_fn_addr);
f010098a:	83 c4 08             	add    $0x8,%esp
f010098d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100990:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100993:	50                   	push   %eax
f0100994:	ff 75 e8             	pushl  -0x18(%ebp)
f0100997:	ff 75 ec             	pushl  -0x14(%ebp)
f010099a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010099d:	ff 75 e0             	pushl  -0x20(%ebp)
f01009a0:	68 3f 6e 10 f0       	push   $0xf0106e3f
f01009a5:	e8 42 2d 00 00       	call   f01036ec <cprintf>
		test = (uint32_t *) *test;
f01009aa:	8b 1b                	mov    (%ebx),%ebx
f01009ac:	83 c4 20             	add    $0x20,%esp
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	struct Eipdebuginfo info;
	uint32_t *test = (uint32_t *) read_ebp();
	cprintf("Stack backtrace:\n");
	while(test){
f01009af:	85 db                	test   %ebx,%ebx
f01009b1:	0f 85 66 ff ff ff    	jne    f010091d <mon_backtrace+0x1f>
		debuginfo_eip(*(test+1), &info);
		cprintf("%s:%d:%.*s+%d\n",info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (int)*(test+1) - info.eip_fn_addr);
		test = (uint32_t *) *test;
	}
	return 0;
}
f01009b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01009bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009bf:	5b                   	pop    %ebx
f01009c0:	5e                   	pop    %esi
f01009c1:	5d                   	pop    %ebp
f01009c2:	c3                   	ret    

f01009c3 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009c3:	55                   	push   %ebp
f01009c4:	89 e5                	mov    %esp,%ebp
f01009c6:	57                   	push   %edi
f01009c7:	56                   	push   %esi
f01009c8:	53                   	push   %ebx
f01009c9:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009cc:	68 98 6f 10 f0       	push   $0xf0106f98
f01009d1:	e8 16 2d 00 00       	call   f01036ec <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009d6:	c7 04 24 bc 6f 10 f0 	movl   $0xf0106fbc,(%esp)
f01009dd:	e8 0a 2d 00 00       	call   f01036ec <cprintf>

	if (tf != NULL)
f01009e2:	83 c4 10             	add    $0x10,%esp
f01009e5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009e9:	74 0e                	je     f01009f9 <monitor+0x36>
		print_trapframe(tf);
f01009eb:	83 ec 0c             	sub    $0xc,%esp
f01009ee:	ff 75 08             	pushl  0x8(%ebp)
f01009f1:	e8 55 34 00 00       	call   f0103e4b <print_trapframe>
f01009f6:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009f9:	83 ec 0c             	sub    $0xc,%esp
f01009fc:	68 4e 6e 10 f0       	push   $0xf0106e4e
f0100a01:	e8 65 4a 00 00       	call   f010546b <readline>
f0100a06:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a08:	83 c4 10             	add    $0x10,%esp
f0100a0b:	85 c0                	test   %eax,%eax
f0100a0d:	74 ea                	je     f01009f9 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a0f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a16:	be 00 00 00 00       	mov    $0x0,%esi
f0100a1b:	eb 0a                	jmp    f0100a27 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a1d:	c6 03 00             	movb   $0x0,(%ebx)
f0100a20:	89 f7                	mov    %esi,%edi
f0100a22:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a25:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a27:	0f b6 03             	movzbl (%ebx),%eax
f0100a2a:	84 c0                	test   %al,%al
f0100a2c:	74 63                	je     f0100a91 <monitor+0xce>
f0100a2e:	83 ec 08             	sub    $0x8,%esp
f0100a31:	0f be c0             	movsbl %al,%eax
f0100a34:	50                   	push   %eax
f0100a35:	68 52 6e 10 f0       	push   $0xf0106e52
f0100a3a:	e8 5e 4c 00 00       	call   f010569d <strchr>
f0100a3f:	83 c4 10             	add    $0x10,%esp
f0100a42:	85 c0                	test   %eax,%eax
f0100a44:	75 d7                	jne    f0100a1d <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100a46:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a49:	74 46                	je     f0100a91 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a4b:	83 fe 0f             	cmp    $0xf,%esi
f0100a4e:	75 14                	jne    f0100a64 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a50:	83 ec 08             	sub    $0x8,%esp
f0100a53:	6a 10                	push   $0x10
f0100a55:	68 57 6e 10 f0       	push   $0xf0106e57
f0100a5a:	e8 8d 2c 00 00       	call   f01036ec <cprintf>
f0100a5f:	83 c4 10             	add    $0x10,%esp
f0100a62:	eb 95                	jmp    f01009f9 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a64:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a67:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a6b:	eb 03                	jmp    f0100a70 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a6d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a70:	0f b6 03             	movzbl (%ebx),%eax
f0100a73:	84 c0                	test   %al,%al
f0100a75:	74 ae                	je     f0100a25 <monitor+0x62>
f0100a77:	83 ec 08             	sub    $0x8,%esp
f0100a7a:	0f be c0             	movsbl %al,%eax
f0100a7d:	50                   	push   %eax
f0100a7e:	68 52 6e 10 f0       	push   $0xf0106e52
f0100a83:	e8 15 4c 00 00       	call   f010569d <strchr>
f0100a88:	83 c4 10             	add    $0x10,%esp
f0100a8b:	85 c0                	test   %eax,%eax
f0100a8d:	74 de                	je     f0100a6d <monitor+0xaa>
f0100a8f:	eb 94                	jmp    f0100a25 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a91:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a98:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a99:	85 f6                	test   %esi,%esi
f0100a9b:	0f 84 58 ff ff ff    	je     f01009f9 <monitor+0x36>
f0100aa1:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aa6:	83 ec 08             	sub    $0x8,%esp
f0100aa9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100aac:	ff 34 85 00 70 10 f0 	pushl  -0xfef9000(,%eax,4)
f0100ab3:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ab6:	e8 84 4b 00 00       	call   f010563f <strcmp>
f0100abb:	83 c4 10             	add    $0x10,%esp
f0100abe:	85 c0                	test   %eax,%eax
f0100ac0:	75 21                	jne    f0100ae3 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100ac2:	83 ec 04             	sub    $0x4,%esp
f0100ac5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ac8:	ff 75 08             	pushl  0x8(%ebp)
f0100acb:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ace:	52                   	push   %edx
f0100acf:	56                   	push   %esi
f0100ad0:	ff 14 85 08 70 10 f0 	call   *-0xfef8ff8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ad7:	83 c4 10             	add    $0x10,%esp
f0100ada:	85 c0                	test   %eax,%eax
f0100adc:	78 25                	js     f0100b03 <monitor+0x140>
f0100ade:	e9 16 ff ff ff       	jmp    f01009f9 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ae3:	83 c3 01             	add    $0x1,%ebx
f0100ae6:	83 fb 03             	cmp    $0x3,%ebx
f0100ae9:	75 bb                	jne    f0100aa6 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aeb:	83 ec 08             	sub    $0x8,%esp
f0100aee:	ff 75 a8             	pushl  -0x58(%ebp)
f0100af1:	68 74 6e 10 f0       	push   $0xf0106e74
f0100af6:	e8 f1 2b 00 00       	call   f01036ec <cprintf>
f0100afb:	83 c4 10             	add    $0x10,%esp
f0100afe:	e9 f6 fe ff ff       	jmp    f01009f9 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100b03:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b06:	5b                   	pop    %ebx
f0100b07:	5e                   	pop    %esi
f0100b08:	5f                   	pop    %edi
f0100b09:	5d                   	pop    %ebp
f0100b0a:	c3                   	ret    

f0100b0b <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b0b:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b0d:	83 3d 38 12 2a f0 00 	cmpl   $0x0,0xf02a1238
f0100b14:	75 0f                	jne    f0100b25 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b16:	b8 ff 53 32 f0       	mov    $0xf03253ff,%eax
f0100b1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b20:	a3 38 12 2a f0       	mov    %eax,0xf02a1238
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("boot_alloc memory at %x\n", nextfree);
    	//cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if(n > 0){
f0100b25:	85 d2                	test   %edx,%edx
f0100b27:	74 42                	je     f0100b6b <boot_alloc+0x60>
		result = nextfree;
f0100b29:	a1 38 12 2a f0       	mov    0xf02a1238,%eax
		nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
f0100b2e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b35:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b3b:	89 15 38 12 2a f0    	mov    %edx,0xf02a1238
		if(((uint32_t)nextfree - KERNBASE) > (npages * PGSIZE)){
f0100b41:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100b47:	8b 0d ac 1e 2a f0    	mov    0xf02a1eac,%ecx
f0100b4d:	c1 e1 0c             	shl    $0xc,%ecx
f0100b50:	39 ca                	cmp    %ecx,%edx
f0100b52:	76 1c                	jbe    f0100b70 <boot_alloc+0x65>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b54:	55                   	push   %ebp
f0100b55:	89 e5                	mov    %esp,%ebp
f0100b57:	83 ec 0c             	sub    $0xc,%esp
    	//cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if(n > 0){
		result = nextfree;
		nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
		if(((uint32_t)nextfree - KERNBASE) > (npages * PGSIZE)){
			panic("Panic: Out of Memory");
f0100b5a:	68 24 70 10 f0       	push   $0xf0107024
f0100b5f:	6a 72                	push   $0x72
f0100b61:	68 39 70 10 f0       	push   $0xf0107039
f0100b66:	e8 d5 f4 ff ff       	call   f0100040 <_panic>
		}
	}
	else{
		result = nextfree;
f0100b6b:	a1 38 12 2a f0       	mov    0xf02a1238,%eax
	}
	nextfree1 = nextfree; 
	return result;
	
}
f0100b70:	f3 c3                	repz ret 

f0100b72 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b72:	89 d1                	mov    %edx,%ecx
f0100b74:	c1 e9 16             	shr    $0x16,%ecx
f0100b77:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b7a:	a8 01                	test   $0x1,%al
f0100b7c:	74 52                	je     f0100bd0 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b83:	89 c1                	mov    %eax,%ecx
f0100b85:	c1 e9 0c             	shr    $0xc,%ecx
f0100b88:	3b 0d ac 1e 2a f0    	cmp    0xf02a1eac,%ecx
f0100b8e:	72 1b                	jb     f0100bab <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b90:	55                   	push   %ebp
f0100b91:	89 e5                	mov    %esp,%ebp
f0100b93:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b96:	50                   	push   %eax
f0100b97:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0100b9c:	68 8b 03 00 00       	push   $0x38b
f0100ba1:	68 39 70 10 f0       	push   $0xf0107039
f0100ba6:	e8 95 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100bab:	c1 ea 0c             	shr    $0xc,%edx
f0100bae:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100bb4:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100bbb:	89 c2                	mov    %eax,%edx
f0100bbd:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bc0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bc5:	85 d2                	test   %edx,%edx
f0100bc7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bcc:	0f 44 c2             	cmove  %edx,%eax
f0100bcf:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bd5:	c3                   	ret    

f0100bd6 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bd6:	55                   	push   %ebp
f0100bd7:	89 e5                	mov    %esp,%ebp
f0100bd9:	57                   	push   %edi
f0100bda:	56                   	push   %esi
f0100bdb:	53                   	push   %ebx
f0100bdc:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bdf:	84 c0                	test   %al,%al
f0100be1:	0f 85 91 02 00 00    	jne    f0100e78 <check_page_free_list+0x2a2>
f0100be7:	e9 9e 02 00 00       	jmp    f0100e8a <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bec:	83 ec 04             	sub    $0x4,%esp
f0100bef:	68 58 73 10 f0       	push   $0xf0107358
f0100bf4:	68 c0 02 00 00       	push   $0x2c0
f0100bf9:	68 39 70 10 f0       	push   $0xf0107039
f0100bfe:	e8 3d f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c03:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c06:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c09:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c0c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c0f:	89 c2                	mov    %eax,%edx
f0100c11:	2b 15 b4 1e 2a f0    	sub    0xf02a1eb4,%edx
f0100c17:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c1d:	0f 95 c2             	setne  %dl
f0100c20:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c23:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c27:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c29:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c2d:	8b 00                	mov    (%eax),%eax
f0100c2f:	85 c0                	test   %eax,%eax
f0100c31:	75 dc                	jne    f0100c0f <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c36:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c3f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c42:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c44:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c47:	a3 40 12 2a f0       	mov    %eax,0xf02a1240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c4c:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c51:	8b 1d 40 12 2a f0    	mov    0xf02a1240,%ebx
f0100c57:	eb 53                	jmp    f0100cac <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c59:	89 d8                	mov    %ebx,%eax
f0100c5b:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0100c61:	c1 f8 03             	sar    $0x3,%eax
f0100c64:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c67:	89 c2                	mov    %eax,%edx
f0100c69:	c1 ea 16             	shr    $0x16,%edx
f0100c6c:	39 f2                	cmp    %esi,%edx
f0100c6e:	73 3a                	jae    f0100caa <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c70:	89 c2                	mov    %eax,%edx
f0100c72:	c1 ea 0c             	shr    $0xc,%edx
f0100c75:	3b 15 ac 1e 2a f0    	cmp    0xf02a1eac,%edx
f0100c7b:	72 12                	jb     f0100c8f <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c7d:	50                   	push   %eax
f0100c7e:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0100c83:	6a 58                	push   $0x58
f0100c85:	68 45 70 10 f0       	push   $0xf0107045
f0100c8a:	e8 b1 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c8f:	83 ec 04             	sub    $0x4,%esp
f0100c92:	68 80 00 00 00       	push   $0x80
f0100c97:	68 97 00 00 00       	push   $0x97
f0100c9c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ca1:	50                   	push   %eax
f0100ca2:	e8 33 4a 00 00       	call   f01056da <memset>
f0100ca7:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100caa:	8b 1b                	mov    (%ebx),%ebx
f0100cac:	85 db                	test   %ebx,%ebx
f0100cae:	75 a9                	jne    f0100c59 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100cb0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb5:	e8 51 fe ff ff       	call   f0100b0b <boot_alloc>
f0100cba:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cbd:	8b 15 40 12 2a f0    	mov    0xf02a1240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cc3:	8b 0d b4 1e 2a f0    	mov    0xf02a1eb4,%ecx
		assert(pp < pages + npages);
f0100cc9:	a1 ac 1e 2a f0       	mov    0xf02a1eac,%eax
f0100cce:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cd1:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cd7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cda:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cdf:	e9 52 01 00 00       	jmp    f0100e36 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ce4:	39 ca                	cmp    %ecx,%edx
f0100ce6:	73 19                	jae    f0100d01 <check_page_free_list+0x12b>
f0100ce8:	68 53 70 10 f0       	push   $0xf0107053
f0100ced:	68 5f 70 10 f0       	push   $0xf010705f
f0100cf2:	68 da 02 00 00       	push   $0x2da
f0100cf7:	68 39 70 10 f0       	push   $0xf0107039
f0100cfc:	e8 3f f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d01:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d04:	72 19                	jb     f0100d1f <check_page_free_list+0x149>
f0100d06:	68 74 70 10 f0       	push   $0xf0107074
f0100d0b:	68 5f 70 10 f0       	push   $0xf010705f
f0100d10:	68 db 02 00 00       	push   $0x2db
f0100d15:	68 39 70 10 f0       	push   $0xf0107039
f0100d1a:	e8 21 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d1f:	89 d0                	mov    %edx,%eax
f0100d21:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d24:	a8 07                	test   $0x7,%al
f0100d26:	74 19                	je     f0100d41 <check_page_free_list+0x16b>
f0100d28:	68 7c 73 10 f0       	push   $0xf010737c
f0100d2d:	68 5f 70 10 f0       	push   $0xf010705f
f0100d32:	68 dc 02 00 00       	push   $0x2dc
f0100d37:	68 39 70 10 f0       	push   $0xf0107039
f0100d3c:	e8 ff f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d41:	c1 f8 03             	sar    $0x3,%eax
f0100d44:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d47:	85 c0                	test   %eax,%eax
f0100d49:	75 19                	jne    f0100d64 <check_page_free_list+0x18e>
f0100d4b:	68 88 70 10 f0       	push   $0xf0107088
f0100d50:	68 5f 70 10 f0       	push   $0xf010705f
f0100d55:	68 df 02 00 00       	push   $0x2df
f0100d5a:	68 39 70 10 f0       	push   $0xf0107039
f0100d5f:	e8 dc f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d64:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d69:	75 19                	jne    f0100d84 <check_page_free_list+0x1ae>
f0100d6b:	68 99 70 10 f0       	push   $0xf0107099
f0100d70:	68 5f 70 10 f0       	push   $0xf010705f
f0100d75:	68 e0 02 00 00       	push   $0x2e0
f0100d7a:	68 39 70 10 f0       	push   $0xf0107039
f0100d7f:	e8 bc f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d84:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d89:	75 19                	jne    f0100da4 <check_page_free_list+0x1ce>
f0100d8b:	68 b0 73 10 f0       	push   $0xf01073b0
f0100d90:	68 5f 70 10 f0       	push   $0xf010705f
f0100d95:	68 e1 02 00 00       	push   $0x2e1
f0100d9a:	68 39 70 10 f0       	push   $0xf0107039
f0100d9f:	e8 9c f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da4:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da9:	75 19                	jne    f0100dc4 <check_page_free_list+0x1ee>
f0100dab:	68 b2 70 10 f0       	push   $0xf01070b2
f0100db0:	68 5f 70 10 f0       	push   $0xf010705f
f0100db5:	68 e2 02 00 00       	push   $0x2e2
f0100dba:	68 39 70 10 f0       	push   $0xf0107039
f0100dbf:	e8 7c f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dc4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dc9:	0f 86 de 00 00 00    	jbe    f0100ead <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dcf:	89 c7                	mov    %eax,%edi
f0100dd1:	c1 ef 0c             	shr    $0xc,%edi
f0100dd4:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100dd7:	77 12                	ja     f0100deb <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd9:	50                   	push   %eax
f0100dda:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0100ddf:	6a 58                	push   $0x58
f0100de1:	68 45 70 10 f0       	push   $0xf0107045
f0100de6:	e8 55 f2 ff ff       	call   f0100040 <_panic>
f0100deb:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100df1:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100df4:	0f 86 a7 00 00 00    	jbe    f0100ea1 <check_page_free_list+0x2cb>
f0100dfa:	68 d4 73 10 f0       	push   $0xf01073d4
f0100dff:	68 5f 70 10 f0       	push   $0xf010705f
f0100e04:	68 e3 02 00 00       	push   $0x2e3
f0100e09:	68 39 70 10 f0       	push   $0xf0107039
f0100e0e:	e8 2d f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e13:	68 cc 70 10 f0       	push   $0xf01070cc
f0100e18:	68 5f 70 10 f0       	push   $0xf010705f
f0100e1d:	68 e5 02 00 00       	push   $0x2e5
f0100e22:	68 39 70 10 f0       	push   $0xf0107039
f0100e27:	e8 14 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e2c:	83 c6 01             	add    $0x1,%esi
f0100e2f:	eb 03                	jmp    f0100e34 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100e31:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e34:	8b 12                	mov    (%edx),%edx
f0100e36:	85 d2                	test   %edx,%edx
f0100e38:	0f 85 a6 fe ff ff    	jne    f0100ce4 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e3e:	85 f6                	test   %esi,%esi
f0100e40:	7f 19                	jg     f0100e5b <check_page_free_list+0x285>
f0100e42:	68 e9 70 10 f0       	push   $0xf01070e9
f0100e47:	68 5f 70 10 f0       	push   $0xf010705f
f0100e4c:	68 ed 02 00 00       	push   $0x2ed
f0100e51:	68 39 70 10 f0       	push   $0xf0107039
f0100e56:	e8 e5 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e5b:	85 db                	test   %ebx,%ebx
f0100e5d:	7f 5e                	jg     f0100ebd <check_page_free_list+0x2e7>
f0100e5f:	68 fb 70 10 f0       	push   $0xf01070fb
f0100e64:	68 5f 70 10 f0       	push   $0xf010705f
f0100e69:	68 ee 02 00 00       	push   $0x2ee
f0100e6e:	68 39 70 10 f0       	push   $0xf0107039
f0100e73:	e8 c8 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e78:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f0100e7d:	85 c0                	test   %eax,%eax
f0100e7f:	0f 85 7e fd ff ff    	jne    f0100c03 <check_page_free_list+0x2d>
f0100e85:	e9 62 fd ff ff       	jmp    f0100bec <check_page_free_list+0x16>
f0100e8a:	83 3d 40 12 2a f0 00 	cmpl   $0x0,0xf02a1240
f0100e91:	0f 84 55 fd ff ff    	je     f0100bec <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e97:	be 00 04 00 00       	mov    $0x400,%esi
f0100e9c:	e9 b0 fd ff ff       	jmp    f0100c51 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ea1:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ea6:	75 89                	jne    f0100e31 <check_page_free_list+0x25b>
f0100ea8:	e9 66 ff ff ff       	jmp    f0100e13 <check_page_free_list+0x23d>
f0100ead:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100eb2:	0f 85 74 ff ff ff    	jne    f0100e2c <check_page_free_list+0x256>
f0100eb8:	e9 56 ff ff ff       	jmp    f0100e13 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100ebd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ec0:	5b                   	pop    %ebx
f0100ec1:	5e                   	pop    %esi
f0100ec2:	5f                   	pop    %edi
f0100ec3:	5d                   	pop    %ebp
f0100ec4:	c3                   	ret    

f0100ec5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ec5:	55                   	push   %ebp
f0100ec6:	89 e5                	mov    %esp,%ebp
f0100ec8:	56                   	push   %esi
f0100ec9:	53                   	push   %ebx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i; 
	for (i = 1; i < npages_basemem; i++) {
f0100eca:	8b 35 44 12 2a f0    	mov    0xf02a1244,%esi
f0100ed0:	8b 1d 40 12 2a f0    	mov    0xf02a1240,%ebx
f0100ed6:	ba 00 00 00 00       	mov    $0x0,%edx
f0100edb:	b8 01 00 00 00       	mov    $0x1,%eax
f0100ee0:	eb 2c                	jmp    f0100f0e <page_init+0x49>
		if(i != PGNUM(MPENTRY_PADDR)){
f0100ee2:	83 f8 07             	cmp    $0x7,%eax
f0100ee5:	74 24                	je     f0100f0b <page_init+0x46>
			pages[i].pp_ref = 0;
f0100ee7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100eee:	89 d1                	mov    %edx,%ecx
f0100ef0:	03 0d b4 1e 2a f0    	add    0xf02a1eb4,%ecx
f0100ef6:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f0100efc:	89 19                	mov    %ebx,(%ecx)
			page_free_list = &pages[i];
f0100efe:	03 15 b4 1e 2a f0    	add    0xf02a1eb4,%edx
f0100f04:	89 d3                	mov    %edx,%ebx
f0100f06:	ba 01 00 00 00       	mov    $0x1,%edx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i; 
	for (i = 1; i < npages_basemem; i++) {
f0100f0b:	83 c0 01             	add    $0x1,%eax
f0100f0e:	39 f0                	cmp    %esi,%eax
f0100f10:	72 d0                	jb     f0100ee2 <page_init+0x1d>
f0100f12:	84 d2                	test   %dl,%dl
f0100f14:	74 06                	je     f0100f1c <page_init+0x57>
f0100f16:	89 1d 40 12 2a f0    	mov    %ebx,0xf02a1240
	//cprintf("\nIOPHYSMEM page-%d\n",(size_t)PGNUM(IOPHYSMEM));
	//cprintf("\nEXTPHYSMEM page-%d\n",(size_t)PGNUM(EXTPHYSMEM));
	//cprintf("\nkernel dat page-%d\n",((uint32_t)boot_alloc(0) - KERNBASE)/PGSIZE);
	
	//int free = (int)ROUNDUP(((char *)pages + (npages * sizeof (struct PageInfo))) - KERNBASE,PGSIZE)/PGSIZE;
	int free =(int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - KERNBASE, PGSIZE)/PGSIZE;
f0100f1c:	a1 48 12 2a f0       	mov    0xf02a1248,%eax
f0100f21:	05 ff ff 01 10       	add    $0x1001ffff,%eax

	//cprintf("free-%d\n",free);
	//cprintf("npages-%d\n",npages);
	
	for (i = free; i < npages; i++) {
f0100f26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f2b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f31:	85 c0                	test   %eax,%eax
f0100f33:	0f 48 c2             	cmovs  %edx,%eax
f0100f36:	c1 f8 0c             	sar    $0xc,%eax
f0100f39:	89 c2                	mov    %eax,%edx
f0100f3b:	8b 1d 40 12 2a f0    	mov    0xf02a1240,%ebx
f0100f41:	c1 e0 03             	shl    $0x3,%eax
f0100f44:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f49:	eb 23                	jmp    f0100f6e <page_init+0xa9>
		pages[i].pp_ref = 0; 
f0100f4b:	89 c1                	mov    %eax,%ecx
f0100f4d:	03 0d b4 1e 2a f0    	add    0xf02a1eb4,%ecx
f0100f53:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f59:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100f5b:	89 c3                	mov    %eax,%ebx
f0100f5d:	03 1d b4 1e 2a f0    	add    0xf02a1eb4,%ebx
	int free =(int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - KERNBASE, PGSIZE)/PGSIZE;

	//cprintf("free-%d\n",free);
	//cprintf("npages-%d\n",npages);
	
	for (i = free; i < npages; i++) {
f0100f63:	83 c2 01             	add    $0x1,%edx
f0100f66:	83 c0 08             	add    $0x8,%eax
f0100f69:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100f6e:	3b 15 ac 1e 2a f0    	cmp    0xf02a1eac,%edx
f0100f74:	72 d5                	jb     f0100f4b <page_init+0x86>
f0100f76:	84 c9                	test   %cl,%cl
f0100f78:	74 06                	je     f0100f80 <page_init+0xbb>
f0100f7a:	89 1d 40 12 2a f0    	mov    %ebx,0xf02a1240
		pages[i].pp_ref = 0; 
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100f80:	5b                   	pop    %ebx
f0100f81:	5e                   	pop    %esi
f0100f82:	5d                   	pop    %ebp
f0100f83:	c3                   	ret    

f0100f84 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f84:	55                   	push   %ebp
f0100f85:	89 e5                	mov    %esp,%ebp
f0100f87:	53                   	push   %ebx
f0100f88:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* newpage;
	newpage = page_free_list;
f0100f8b:	8b 1d 40 12 2a f0    	mov    0xf02a1240,%ebx
	if(page_free_list){
f0100f91:	85 db                	test   %ebx,%ebx
f0100f93:	74 5c                	je     f0100ff1 <page_alloc+0x6d>
		page_free_list = page_free_list->pp_link;
f0100f95:	8b 03                	mov    (%ebx),%eax
f0100f97:	a3 40 12 2a f0       	mov    %eax,0xf02a1240
		if(alloc_flags & ALLOC_ZERO){
f0100f9c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fa0:	74 45                	je     f0100fe7 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fa2:	89 d8                	mov    %ebx,%eax
f0100fa4:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0100faa:	c1 f8 03             	sar    $0x3,%eax
f0100fad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fb0:	89 c2                	mov    %eax,%edx
f0100fb2:	c1 ea 0c             	shr    $0xc,%edx
f0100fb5:	3b 15 ac 1e 2a f0    	cmp    0xf02a1eac,%edx
f0100fbb:	72 12                	jb     f0100fcf <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbd:	50                   	push   %eax
f0100fbe:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0100fc3:	6a 58                	push   $0x58
f0100fc5:	68 45 70 10 f0       	push   $0xf0107045
f0100fca:	e8 71 f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(newpage), 0, PGSIZE);
f0100fcf:	83 ec 04             	sub    $0x4,%esp
f0100fd2:	68 00 10 00 00       	push   $0x1000
f0100fd7:	6a 00                	push   $0x0
f0100fd9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fde:	50                   	push   %eax
f0100fdf:	e8 f6 46 00 00       	call   f01056da <memset>
f0100fe4:	83 c4 10             	add    $0x10,%esp
		}	
		newpage->pp_link = NULL;
f0100fe7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return newpage;	
f0100fed:	89 d8                	mov    %ebx,%eax
f0100fef:	eb 05                	jmp    f0100ff6 <page_alloc+0x72>
	}
	return NULL;
f0100ff1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ff6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ff9:	c9                   	leave  
f0100ffa:	c3                   	ret    

f0100ffb <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ffb:	55                   	push   %ebp
f0100ffc:	89 e5                	mov    %esp,%ebp
f0100ffe:	83 ec 08             	sub    $0x8,%esp
f0101001:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if((pp->pp_ref != 0) || (pp->pp_link != NULL)){
f0101004:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101009:	75 05                	jne    f0101010 <page_free+0x15>
f010100b:	83 38 00             	cmpl   $0x0,(%eax)
f010100e:	74 17                	je     f0101027 <page_free+0x2c>
		panic("Page in use\n");
f0101010:	83 ec 04             	sub    $0x4,%esp
f0101013:	68 0c 71 10 f0       	push   $0xf010710c
f0101018:	68 8e 01 00 00       	push   $0x18e
f010101d:	68 39 70 10 f0       	push   $0xf0107039
f0101022:	e8 19 f0 ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f0101027:	8b 15 40 12 2a f0    	mov    0xf02a1240,%edx
f010102d:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010102f:	a3 40 12 2a f0       	mov    %eax,0xf02a1240
}
f0101034:	c9                   	leave  
f0101035:	c3                   	ret    

f0101036 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101036:	55                   	push   %ebp
f0101037:	89 e5                	mov    %esp,%ebp
f0101039:	83 ec 08             	sub    $0x8,%esp
f010103c:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010103f:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101043:	83 e8 01             	sub    $0x1,%eax
f0101046:	66 89 42 04          	mov    %ax,0x4(%edx)
f010104a:	66 85 c0             	test   %ax,%ax
f010104d:	75 0c                	jne    f010105b <page_decref+0x25>
		page_free(pp);
f010104f:	83 ec 0c             	sub    $0xc,%esp
f0101052:	52                   	push   %edx
f0101053:	e8 a3 ff ff ff       	call   f0100ffb <page_free>
f0101058:	83 c4 10             	add    $0x10,%esp
}
f010105b:	c9                   	leave  
f010105c:	c3                   	ret    

f010105d <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010105d:	55                   	push   %ebp
f010105e:	89 e5                	mov    %esp,%ebp
f0101060:	56                   	push   %esi
f0101061:	53                   	push   %ebx
f0101062:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (!(pgdir[PDX(va)] & PTE_P)) { 
f0101065:	89 f3                	mov    %esi,%ebx
f0101067:	c1 eb 16             	shr    $0x16,%ebx
f010106a:	c1 e3 02             	shl    $0x2,%ebx
f010106d:	03 5d 08             	add    0x8(%ebp),%ebx
f0101070:	f6 03 01             	testb  $0x1,(%ebx)
f0101073:	75 2d                	jne    f01010a2 <pgdir_walk+0x45>
        if (create == 1) {
f0101075:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0101079:	75 64                	jne    f01010df <pgdir_walk+0x82>
            struct PageInfo *newpage = page_alloc(ALLOC_ZERO); 
f010107b:	83 ec 0c             	sub    $0xc,%esp
f010107e:	6a 01                	push   $0x1
f0101080:	e8 ff fe ff ff       	call   f0100f84 <page_alloc>
            if (!newpage){
f0101085:	83 c4 10             	add    $0x10,%esp
f0101088:	85 c0                	test   %eax,%eax
f010108a:	74 5a                	je     f01010e6 <pgdir_walk+0x89>
				 return NULL;  
			}
			else{
            	newpage->pp_ref++;
f010108c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
            	pgdir[PDX(va)] = page2pa(newpage) | PTE_P | PTE_U | PTE_W;
f0101091:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0101097:	c1 f8 03             	sar    $0x3,%eax
f010109a:	c1 e0 0c             	shl    $0xc,%eax
f010109d:	83 c8 07             	or     $0x7,%eax
f01010a0:	89 03                	mov    %eax,(%ebx)
			}    
        } else return NULL;
    }
    pte_t *new = (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]));
f01010a2:	8b 13                	mov    (%ebx),%edx
f01010a4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010aa:	89 d0                	mov    %edx,%eax
f01010ac:	c1 e8 0c             	shr    $0xc,%eax
f01010af:	3b 05 ac 1e 2a f0    	cmp    0xf02a1eac,%eax
f01010b5:	72 15                	jb     f01010cc <pgdir_walk+0x6f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b7:	52                   	push   %edx
f01010b8:	68 a4 6a 10 f0       	push   $0xf0106aa4
f01010bd:	68 c4 01 00 00       	push   $0x1c4
f01010c2:	68 39 70 10 f0       	push   $0xf0107039
f01010c7:	e8 74 ef ff ff       	call   f0100040 <_panic>
	return &new[PTX(va)];
f01010cc:	89 f0                	mov    %esi,%eax
f01010ce:	c1 e8 0a             	shr    $0xa,%eax
f01010d1:	25 fc 0f 00 00       	and    $0xffc,%eax
f01010d6:	8d 84 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%eax
f01010dd:	eb 0c                	jmp    f01010eb <pgdir_walk+0x8e>
			}
			else{
            	newpage->pp_ref++;
            	pgdir[PDX(va)] = page2pa(newpage) | PTE_P | PTE_U | PTE_W;
			}    
        } else return NULL;
f01010df:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e4:	eb 05                	jmp    f01010eb <pgdir_walk+0x8e>
{
	if (!(pgdir[PDX(va)] & PTE_P)) { 
        if (create == 1) {
            struct PageInfo *newpage = page_alloc(ALLOC_ZERO); 
            if (!newpage){
				 return NULL;  
f01010e6:	b8 00 00 00 00       	mov    $0x0,%eax
			}    
        } else return NULL;
    }
    pte_t *new = (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]));
	return &new[PTX(va)];
}
f01010eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010ee:	5b                   	pop    %ebx
f01010ef:	5e                   	pop    %esi
f01010f0:	5d                   	pop    %ebp
f01010f1:	c3                   	ret    

f01010f2 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010f2:	55                   	push   %ebp
f01010f3:	89 e5                	mov    %esp,%ebp
f01010f5:	57                   	push   %edi
f01010f6:	56                   	push   %esi
f01010f7:	53                   	push   %ebx
f01010f8:	83 ec 1c             	sub    $0x1c,%esp
f01010fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101101:	c1 e9 0c             	shr    $0xc,%ecx
f0101104:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	int i;
    for (i = 0; i < size/PGSIZE;i++ ) {
f0101107:	89 c3                	mov    %eax,%ebx
f0101109:	be 00 00 00 00       	mov    $0x0,%esi
        pte_t *p = pgdir_walk(pgdir, (void *) va, 1); 
f010110e:	89 d7                	mov    %edx,%edi
f0101110:	29 c7                	sub    %eax,%edi
        if (!p){
			panic("boot_map_region panic, out of memory\n");			
		}
        *p = pa | perm | PTE_P;
f0101112:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101115:	83 c8 01             	or     $0x1,%eax
f0101118:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
    for (i = 0; i < size/PGSIZE;i++ ) {
f010111b:	eb 3f                	jmp    f010115c <boot_map_region+0x6a>
        pte_t *p = pgdir_walk(pgdir, (void *) va, 1); 
f010111d:	83 ec 04             	sub    $0x4,%esp
f0101120:	6a 01                	push   $0x1
f0101122:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101125:	50                   	push   %eax
f0101126:	ff 75 e0             	pushl  -0x20(%ebp)
f0101129:	e8 2f ff ff ff       	call   f010105d <pgdir_walk>
        if (!p){
f010112e:	83 c4 10             	add    $0x10,%esp
f0101131:	85 c0                	test   %eax,%eax
f0101133:	75 17                	jne    f010114c <boot_map_region+0x5a>
			panic("boot_map_region panic, out of memory\n");			
f0101135:	83 ec 04             	sub    $0x4,%esp
f0101138:	68 1c 74 10 f0       	push   $0xf010741c
f010113d:	68 da 01 00 00       	push   $0x1da
f0101142:	68 39 70 10 f0       	push   $0xf0107039
f0101147:	e8 f4 ee ff ff       	call   f0100040 <_panic>
		}
        *p = pa | perm | PTE_P;
f010114c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010114f:	09 da                	or     %ebx,%edx
f0101151:	89 10                	mov    %edx,(%eax)
		va = va + PGSIZE;
		pa = pa + PGSIZE;		
f0101153:	81 c3 00 10 00 00    	add    $0x1000,%ebx
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
    for (i = 0; i < size/PGSIZE;i++ ) {
f0101159:	83 c6 01             	add    $0x1,%esi
f010115c:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010115f:	75 bc                	jne    f010111d <boot_map_region+0x2b>
		}
        *p = pa | perm | PTE_P;
		va = va + PGSIZE;
		pa = pa + PGSIZE;		
    }
}
f0101161:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101164:	5b                   	pop    %ebx
f0101165:	5e                   	pop    %esi
f0101166:	5f                   	pop    %edi
f0101167:	5d                   	pop    %ebp
f0101168:	c3                   	ret    

f0101169 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101169:	55                   	push   %ebp
f010116a:	89 e5                	mov    %esp,%ebp
f010116c:	53                   	push   %ebx
f010116d:	83 ec 08             	sub    $0x8,%esp
f0101170:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * page = pgdir_walk(pgdir, va, 0);
f0101173:	6a 00                	push   $0x0
f0101175:	ff 75 0c             	pushl  0xc(%ebp)
f0101178:	ff 75 08             	pushl  0x8(%ebp)
f010117b:	e8 dd fe ff ff       	call   f010105d <pgdir_walk>
	if(!page){
f0101180:	83 c4 10             	add    $0x10,%esp
f0101183:	85 c0                	test   %eax,%eax
f0101185:	74 32                	je     f01011b9 <page_lookup+0x50>
		return NULL;
	}
	if(pte_store){
f0101187:	85 db                	test   %ebx,%ebx
f0101189:	74 02                	je     f010118d <page_lookup+0x24>
		*pte_store = page;
f010118b:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010118d:	8b 00                	mov    (%eax),%eax
f010118f:	c1 e8 0c             	shr    $0xc,%eax
f0101192:	3b 05 ac 1e 2a f0    	cmp    0xf02a1eac,%eax
f0101198:	72 14                	jb     f01011ae <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f010119a:	83 ec 04             	sub    $0x4,%esp
f010119d:	68 44 74 10 f0       	push   $0xf0107444
f01011a2:	6a 51                	push   $0x51
f01011a4:	68 45 70 10 f0       	push   $0xf0107045
f01011a9:	e8 92 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011ae:	8b 15 b4 1e 2a f0    	mov    0xf02a1eb4,%edx
f01011b4:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	}
	return pa2page(PTE_ADDR(*page));
f01011b7:	eb 05                	jmp    f01011be <page_lookup+0x55>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t * page = pgdir_walk(pgdir, va, 0);
	if(!page){
		return NULL;
f01011b9:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte_store){
		*pte_store = page;
	}
	return pa2page(PTE_ADDR(*page));
	
}
f01011be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011c1:	c9                   	leave  
f01011c2:	c3                   	ret    

f01011c3 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011c3:	55                   	push   %ebp
f01011c4:	89 e5                	mov    %esp,%ebp
f01011c6:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011c9:	e8 2c 4b 00 00       	call   f0105cfa <cpunum>
f01011ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01011d1:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f01011d8:	74 16                	je     f01011f0 <tlb_invalidate+0x2d>
f01011da:	e8 1b 4b 00 00       	call   f0105cfa <cpunum>
f01011df:	6b c0 74             	imul   $0x74,%eax,%eax
f01011e2:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01011e8:	8b 55 08             	mov    0x8(%ebp),%edx
f01011eb:	39 50 60             	cmp    %edx,0x60(%eax)
f01011ee:	75 06                	jne    f01011f6 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011f3:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011f6:	c9                   	leave  
f01011f7:	c3                   	ret    

f01011f8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011f8:	55                   	push   %ebp
f01011f9:	89 e5                	mov    %esp,%ebp
f01011fb:	56                   	push   %esi
f01011fc:	53                   	push   %ebx
f01011fd:	83 ec 14             	sub    $0x14,%esp
f0101200:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101203:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t * pgtentry; 
	struct PageInfo * page = page_lookup(pgdir, va, &pgtentry);
f0101206:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101209:	50                   	push   %eax
f010120a:	56                   	push   %esi
f010120b:	53                   	push   %ebx
f010120c:	e8 58 ff ff ff       	call   f0101169 <page_lookup>
	if(!page ||!(*pgtentry & PTE_P)){
f0101211:	83 c4 10             	add    $0x10,%esp
f0101214:	85 c0                	test   %eax,%eax
f0101216:	74 27                	je     f010123f <page_remove+0x47>
f0101218:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010121b:	f6 02 01             	testb  $0x1,(%edx)
f010121e:	74 1f                	je     f010123f <page_remove+0x47>
		return;
	}
	page_decref(page);
f0101220:	83 ec 0c             	sub    $0xc,%esp
f0101223:	50                   	push   %eax
f0101224:	e8 0d fe ff ff       	call   f0101036 <page_decref>
	*pgtentry = 0;
f0101229:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010122c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101232:	83 c4 08             	add    $0x8,%esp
f0101235:	56                   	push   %esi
f0101236:	53                   	push   %ebx
f0101237:	e8 87 ff ff ff       	call   f01011c3 <tlb_invalidate>
f010123c:	83 c4 10             	add    $0x10,%esp
}
f010123f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101242:	5b                   	pop    %ebx
f0101243:	5e                   	pop    %esi
f0101244:	5d                   	pop    %ebp
f0101245:	c3                   	ret    

f0101246 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101246:	55                   	push   %ebp
f0101247:	89 e5                	mov    %esp,%ebp
f0101249:	57                   	push   %edi
f010124a:	56                   	push   %esi
f010124b:	53                   	push   %ebx
f010124c:	83 ec 10             	sub    $0x10,%esp
f010124f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101252:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);  
f0101255:	6a 01                	push   $0x1
f0101257:	57                   	push   %edi
f0101258:	ff 75 08             	pushl  0x8(%ebp)
f010125b:	e8 fd fd ff ff       	call   f010105d <pgdir_walk>
    if (!pte)   
f0101260:	83 c4 10             	add    $0x10,%esp
f0101263:	85 c0                	test   %eax,%eax
f0101265:	74 38                	je     f010129f <page_insert+0x59>
f0101267:	89 c6                	mov    %eax,%esi
        return -E_NO_MEM;   
    pp->pp_ref++;   
f0101269:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    if (*pte & PTE_P)   
f010126e:	f6 00 01             	testb  $0x1,(%eax)
f0101271:	74 0f                	je     f0101282 <page_insert+0x3c>
        page_remove(pgdir, va);
f0101273:	83 ec 08             	sub    $0x8,%esp
f0101276:	57                   	push   %edi
f0101277:	ff 75 08             	pushl  0x8(%ebp)
f010127a:	e8 79 ff ff ff       	call   f01011f8 <page_remove>
f010127f:	83 c4 10             	add    $0x10,%esp
    *pte = page2pa(pp) | perm | PTE_P;
f0101282:	2b 1d b4 1e 2a f0    	sub    0xf02a1eb4,%ebx
f0101288:	c1 fb 03             	sar    $0x3,%ebx
f010128b:	c1 e3 0c             	shl    $0xc,%ebx
f010128e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101291:	83 c8 01             	or     $0x1,%eax
f0101294:	09 c3                	or     %eax,%ebx
f0101296:	89 1e                	mov    %ebx,(%esi)
    return 0;
f0101298:	b8 00 00 00 00       	mov    $0x0,%eax
f010129d:	eb 05                	jmp    f01012a4 <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);  
    if (!pte)   
        return -E_NO_MEM;   
f010129f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    pp->pp_ref++;   
    if (*pte & PTE_P)   
        page_remove(pgdir, va);
    *pte = page2pa(pp) | perm | PTE_P;
    return 0;
}
f01012a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a7:	5b                   	pop    %ebx
f01012a8:	5e                   	pop    %esi
f01012a9:	5f                   	pop    %edi
f01012aa:	5d                   	pop    %ebp
f01012ab:	c3                   	ret    

f01012ac <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012ac:	55                   	push   %ebp
f01012ad:	89 e5                	mov    %esp,%ebp
f01012af:	53                   	push   %ebx
f01012b0:	83 ec 04             	sub    $0x4,%esp
f01012b3:	8b 45 08             	mov    0x8(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
		physaddr_t start = (physaddr_t)ROUNDDOWN(pa, PGSIZE);
f01012b6:	89 c1                	mov    %eax,%ecx
f01012b8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	size_t end = (size_t)ROUNDUP(pa + size, PGSIZE);
f01012be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012c1:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
	
	size = end - start;
f01012c8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01012ce:	29 cb                	sub    %ecx,%ebx
	
	if((base + size) >= MMIOLIM)
f01012d0:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f01012d6:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01012d9:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01012de:	76 17                	jbe    f01012f7 <mmio_map_region+0x4b>
		panic("Extending memory mapped IO limit");
f01012e0:	83 ec 04             	sub    $0x4,%esp
f01012e3:	68 64 74 10 f0       	push   $0xf0107464
f01012e8:	68 6f 02 00 00       	push   $0x26f
f01012ed:	68 39 70 10 f0       	push   $0xf0107039
f01012f2:	e8 49 ed ff ff       	call   f0100040 <_panic>
	
	boot_map_region(kern_pgdir, base, size, start, PTE_W|PTE_PCD|PTE_PWT);
f01012f7:	83 ec 08             	sub    $0x8,%esp
f01012fa:	6a 1a                	push   $0x1a
f01012fc:	51                   	push   %ecx
f01012fd:	89 d9                	mov    %ebx,%ecx
f01012ff:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f0101304:	e8 e9 fd ff ff       	call   f01010f2 <boot_map_region>
	
	base = base + size;
f0101309:	a1 00 33 12 f0       	mov    0xf0123300,%eax
f010130e:	01 c3                	add    %eax,%ebx
f0101310:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
	
	return (void *)(base - size);
}
f0101316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101319:	c9                   	leave  
f010131a:	c3                   	ret    

f010131b <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010131b:	55                   	push   %ebp
f010131c:	89 e5                	mov    %esp,%ebp
f010131e:	57                   	push   %edi
f010131f:	56                   	push   %esi
f0101320:	53                   	push   %ebx
f0101321:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101324:	6a 15                	push   $0x15
f0101326:	e8 2c 22 00 00       	call   f0103557 <mc146818_read>
f010132b:	89 c3                	mov    %eax,%ebx
f010132d:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101334:	e8 1e 22 00 00       	call   f0103557 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101339:	c1 e0 08             	shl    $0x8,%eax
f010133c:	09 d8                	or     %ebx,%eax
f010133e:	c1 e0 0a             	shl    $0xa,%eax
f0101341:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101347:	85 c0                	test   %eax,%eax
f0101349:	0f 48 c2             	cmovs  %edx,%eax
f010134c:	c1 f8 0c             	sar    $0xc,%eax
f010134f:	a3 44 12 2a f0       	mov    %eax,0xf02a1244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101354:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010135b:	e8 f7 21 00 00       	call   f0103557 <mc146818_read>
f0101360:	89 c3                	mov    %eax,%ebx
f0101362:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101369:	e8 e9 21 00 00       	call   f0103557 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010136e:	c1 e0 08             	shl    $0x8,%eax
f0101371:	09 d8                	or     %ebx,%eax
f0101373:	c1 e0 0a             	shl    $0xa,%eax
f0101376:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010137c:	83 c4 10             	add    $0x10,%esp
f010137f:	85 c0                	test   %eax,%eax
f0101381:	0f 48 c2             	cmovs  %edx,%eax
f0101384:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101387:	85 c0                	test   %eax,%eax
f0101389:	74 0e                	je     f0101399 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010138b:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101391:	89 15 ac 1e 2a f0    	mov    %edx,0xf02a1eac
f0101397:	eb 0c                	jmp    f01013a5 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101399:	8b 15 44 12 2a f0    	mov    0xf02a1244,%edx
f010139f:	89 15 ac 1e 2a f0    	mov    %edx,0xf02a1eac
	//cprintf("Amount of physical memory (in pages) %u\n",npages);
	//cprintf("Page Size is %u\n", PGSIZE);
	//cprintf("Amount of base memory (in pages) is %u\n", npages_basemem);
	
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013a5:	c1 e0 0c             	shl    $0xc,%eax
f01013a8:	c1 e8 0a             	shr    $0xa,%eax
f01013ab:	50                   	push   %eax
f01013ac:	a1 44 12 2a f0       	mov    0xf02a1244,%eax
f01013b1:	c1 e0 0c             	shl    $0xc,%eax
f01013b4:	c1 e8 0a             	shr    $0xa,%eax
f01013b7:	50                   	push   %eax
f01013b8:	a1 ac 1e 2a f0       	mov    0xf02a1eac,%eax
f01013bd:	c1 e0 0c             	shl    $0xc,%eax
f01013c0:	c1 e8 0a             	shr    $0xa,%eax
f01013c3:	50                   	push   %eax
f01013c4:	68 88 74 10 f0       	push   $0xf0107488
f01013c9:	e8 1e 23 00 00       	call   f01036ec <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013ce:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013d3:	e8 33 f7 ff ff       	call   f0100b0b <boot_alloc>
f01013d8:	a3 b0 1e 2a f0       	mov    %eax,0xf02a1eb0
	memset(kern_pgdir, 0, PGSIZE);
f01013dd:	83 c4 0c             	add    $0xc,%esp
f01013e0:	68 00 10 00 00       	push   $0x1000
f01013e5:	6a 00                	push   $0x0
f01013e7:	50                   	push   %eax
f01013e8:	e8 ed 42 00 00       	call   f01056da <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013ed:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013f2:	83 c4 10             	add    $0x10,%esp
f01013f5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013fa:	77 15                	ja     f0101411 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013fc:	50                   	push   %eax
f01013fd:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0101402:	68 9e 00 00 00       	push   $0x9e
f0101407:	68 39 70 10 f0       	push   $0xf0107039
f010140c:	e8 2f ec ff ff       	call   f0100040 <_panic>
f0101411:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101417:	83 ca 05             	or     $0x5,%edx
f010141a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc (npages * sizeof (struct PageInfo)); 
f0101420:	a1 ac 1e 2a f0       	mov    0xf02a1eac,%eax
f0101425:	c1 e0 03             	shl    $0x3,%eax
f0101428:	e8 de f6 ff ff       	call   f0100b0b <boot_alloc>
f010142d:	a3 b4 1e 2a f0       	mov    %eax,0xf02a1eb4
	memset(pages, 0, npages * sizeof (struct PageInfo));
f0101432:	83 ec 04             	sub    $0x4,%esp
f0101435:	8b 0d ac 1e 2a f0    	mov    0xf02a1eac,%ecx
f010143b:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101442:	52                   	push   %edx
f0101443:	6a 00                	push   $0x0
f0101445:	50                   	push   %eax
f0101446:	e8 8f 42 00 00       	call   f01056da <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc (NENV * sizeof(struct Env));
f010144b:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101450:	e8 b6 f6 ff ff       	call   f0100b0b <boot_alloc>
f0101455:	a3 48 12 2a f0       	mov    %eax,0xf02a1248
	memset(envs, 0, NENV * sizeof (struct Env));
f010145a:	83 c4 0c             	add    $0xc,%esp
f010145d:	68 00 f0 01 00       	push   $0x1f000
f0101462:	6a 00                	push   $0x0
f0101464:	50                   	push   %eax
f0101465:	e8 70 42 00 00       	call   f01056da <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010146a:	e8 56 fa ff ff       	call   f0100ec5 <page_init>

	check_page_free_list(1);
f010146f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101474:	e8 5d f7 ff ff       	call   f0100bd6 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101479:	83 c4 10             	add    $0x10,%esp
f010147c:	83 3d b4 1e 2a f0 00 	cmpl   $0x0,0xf02a1eb4
f0101483:	75 17                	jne    f010149c <mem_init+0x181>
		panic("'pages' is a null pointer!");
f0101485:	83 ec 04             	sub    $0x4,%esp
f0101488:	68 19 71 10 f0       	push   $0xf0107119
f010148d:	68 ff 02 00 00       	push   $0x2ff
f0101492:	68 39 70 10 f0       	push   $0xf0107039
f0101497:	e8 a4 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010149c:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f01014a1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014a6:	eb 05                	jmp    f01014ad <mem_init+0x192>
		++nfree;
f01014a8:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014ab:	8b 00                	mov    (%eax),%eax
f01014ad:	85 c0                	test   %eax,%eax
f01014af:	75 f7                	jne    f01014a8 <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014b1:	83 ec 0c             	sub    $0xc,%esp
f01014b4:	6a 00                	push   $0x0
f01014b6:	e8 c9 fa ff ff       	call   f0100f84 <page_alloc>
f01014bb:	89 c7                	mov    %eax,%edi
f01014bd:	83 c4 10             	add    $0x10,%esp
f01014c0:	85 c0                	test   %eax,%eax
f01014c2:	75 19                	jne    f01014dd <mem_init+0x1c2>
f01014c4:	68 34 71 10 f0       	push   $0xf0107134
f01014c9:	68 5f 70 10 f0       	push   $0xf010705f
f01014ce:	68 07 03 00 00       	push   $0x307
f01014d3:	68 39 70 10 f0       	push   $0xf0107039
f01014d8:	e8 63 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01014dd:	83 ec 0c             	sub    $0xc,%esp
f01014e0:	6a 00                	push   $0x0
f01014e2:	e8 9d fa ff ff       	call   f0100f84 <page_alloc>
f01014e7:	89 c6                	mov    %eax,%esi
f01014e9:	83 c4 10             	add    $0x10,%esp
f01014ec:	85 c0                	test   %eax,%eax
f01014ee:	75 19                	jne    f0101509 <mem_init+0x1ee>
f01014f0:	68 4a 71 10 f0       	push   $0xf010714a
f01014f5:	68 5f 70 10 f0       	push   $0xf010705f
f01014fa:	68 08 03 00 00       	push   $0x308
f01014ff:	68 39 70 10 f0       	push   $0xf0107039
f0101504:	e8 37 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101509:	83 ec 0c             	sub    $0xc,%esp
f010150c:	6a 00                	push   $0x0
f010150e:	e8 71 fa ff ff       	call   f0100f84 <page_alloc>
f0101513:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101516:	83 c4 10             	add    $0x10,%esp
f0101519:	85 c0                	test   %eax,%eax
f010151b:	75 19                	jne    f0101536 <mem_init+0x21b>
f010151d:	68 60 71 10 f0       	push   $0xf0107160
f0101522:	68 5f 70 10 f0       	push   $0xf010705f
f0101527:	68 09 03 00 00       	push   $0x309
f010152c:	68 39 70 10 f0       	push   $0xf0107039
f0101531:	e8 0a eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101536:	39 f7                	cmp    %esi,%edi
f0101538:	75 19                	jne    f0101553 <mem_init+0x238>
f010153a:	68 76 71 10 f0       	push   $0xf0107176
f010153f:	68 5f 70 10 f0       	push   $0xf010705f
f0101544:	68 0c 03 00 00       	push   $0x30c
f0101549:	68 39 70 10 f0       	push   $0xf0107039
f010154e:	e8 ed ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101553:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101556:	39 c6                	cmp    %eax,%esi
f0101558:	74 04                	je     f010155e <mem_init+0x243>
f010155a:	39 c7                	cmp    %eax,%edi
f010155c:	75 19                	jne    f0101577 <mem_init+0x25c>
f010155e:	68 c4 74 10 f0       	push   $0xf01074c4
f0101563:	68 5f 70 10 f0       	push   $0xf010705f
f0101568:	68 0d 03 00 00       	push   $0x30d
f010156d:	68 39 70 10 f0       	push   $0xf0107039
f0101572:	e8 c9 ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101577:	8b 0d b4 1e 2a f0    	mov    0xf02a1eb4,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010157d:	8b 15 ac 1e 2a f0    	mov    0xf02a1eac,%edx
f0101583:	c1 e2 0c             	shl    $0xc,%edx
f0101586:	89 f8                	mov    %edi,%eax
f0101588:	29 c8                	sub    %ecx,%eax
f010158a:	c1 f8 03             	sar    $0x3,%eax
f010158d:	c1 e0 0c             	shl    $0xc,%eax
f0101590:	39 d0                	cmp    %edx,%eax
f0101592:	72 19                	jb     f01015ad <mem_init+0x292>
f0101594:	68 88 71 10 f0       	push   $0xf0107188
f0101599:	68 5f 70 10 f0       	push   $0xf010705f
f010159e:	68 0e 03 00 00       	push   $0x30e
f01015a3:	68 39 70 10 f0       	push   $0xf0107039
f01015a8:	e8 93 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01015ad:	89 f0                	mov    %esi,%eax
f01015af:	29 c8                	sub    %ecx,%eax
f01015b1:	c1 f8 03             	sar    $0x3,%eax
f01015b4:	c1 e0 0c             	shl    $0xc,%eax
f01015b7:	39 c2                	cmp    %eax,%edx
f01015b9:	77 19                	ja     f01015d4 <mem_init+0x2b9>
f01015bb:	68 a5 71 10 f0       	push   $0xf01071a5
f01015c0:	68 5f 70 10 f0       	push   $0xf010705f
f01015c5:	68 0f 03 00 00       	push   $0x30f
f01015ca:	68 39 70 10 f0       	push   $0xf0107039
f01015cf:	e8 6c ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01015d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015d7:	29 c8                	sub    %ecx,%eax
f01015d9:	c1 f8 03             	sar    $0x3,%eax
f01015dc:	c1 e0 0c             	shl    $0xc,%eax
f01015df:	39 c2                	cmp    %eax,%edx
f01015e1:	77 19                	ja     f01015fc <mem_init+0x2e1>
f01015e3:	68 c2 71 10 f0       	push   $0xf01071c2
f01015e8:	68 5f 70 10 f0       	push   $0xf010705f
f01015ed:	68 10 03 00 00       	push   $0x310
f01015f2:	68 39 70 10 f0       	push   $0xf0107039
f01015f7:	e8 44 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01015fc:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f0101601:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101604:	c7 05 40 12 2a f0 00 	movl   $0x0,0xf02a1240
f010160b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010160e:	83 ec 0c             	sub    $0xc,%esp
f0101611:	6a 00                	push   $0x0
f0101613:	e8 6c f9 ff ff       	call   f0100f84 <page_alloc>
f0101618:	83 c4 10             	add    $0x10,%esp
f010161b:	85 c0                	test   %eax,%eax
f010161d:	74 19                	je     f0101638 <mem_init+0x31d>
f010161f:	68 df 71 10 f0       	push   $0xf01071df
f0101624:	68 5f 70 10 f0       	push   $0xf010705f
f0101629:	68 17 03 00 00       	push   $0x317
f010162e:	68 39 70 10 f0       	push   $0xf0107039
f0101633:	e8 08 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101638:	83 ec 0c             	sub    $0xc,%esp
f010163b:	57                   	push   %edi
f010163c:	e8 ba f9 ff ff       	call   f0100ffb <page_free>
	page_free(pp1);
f0101641:	89 34 24             	mov    %esi,(%esp)
f0101644:	e8 b2 f9 ff ff       	call   f0100ffb <page_free>
	page_free(pp2);
f0101649:	83 c4 04             	add    $0x4,%esp
f010164c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010164f:	e8 a7 f9 ff ff       	call   f0100ffb <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010165b:	e8 24 f9 ff ff       	call   f0100f84 <page_alloc>
f0101660:	89 c6                	mov    %eax,%esi
f0101662:	83 c4 10             	add    $0x10,%esp
f0101665:	85 c0                	test   %eax,%eax
f0101667:	75 19                	jne    f0101682 <mem_init+0x367>
f0101669:	68 34 71 10 f0       	push   $0xf0107134
f010166e:	68 5f 70 10 f0       	push   $0xf010705f
f0101673:	68 1e 03 00 00       	push   $0x31e
f0101678:	68 39 70 10 f0       	push   $0xf0107039
f010167d:	e8 be e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101682:	83 ec 0c             	sub    $0xc,%esp
f0101685:	6a 00                	push   $0x0
f0101687:	e8 f8 f8 ff ff       	call   f0100f84 <page_alloc>
f010168c:	89 c7                	mov    %eax,%edi
f010168e:	83 c4 10             	add    $0x10,%esp
f0101691:	85 c0                	test   %eax,%eax
f0101693:	75 19                	jne    f01016ae <mem_init+0x393>
f0101695:	68 4a 71 10 f0       	push   $0xf010714a
f010169a:	68 5f 70 10 f0       	push   $0xf010705f
f010169f:	68 1f 03 00 00       	push   $0x31f
f01016a4:	68 39 70 10 f0       	push   $0xf0107039
f01016a9:	e8 92 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016ae:	83 ec 0c             	sub    $0xc,%esp
f01016b1:	6a 00                	push   $0x0
f01016b3:	e8 cc f8 ff ff       	call   f0100f84 <page_alloc>
f01016b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016bb:	83 c4 10             	add    $0x10,%esp
f01016be:	85 c0                	test   %eax,%eax
f01016c0:	75 19                	jne    f01016db <mem_init+0x3c0>
f01016c2:	68 60 71 10 f0       	push   $0xf0107160
f01016c7:	68 5f 70 10 f0       	push   $0xf010705f
f01016cc:	68 20 03 00 00       	push   $0x320
f01016d1:	68 39 70 10 f0       	push   $0xf0107039
f01016d6:	e8 65 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016db:	39 fe                	cmp    %edi,%esi
f01016dd:	75 19                	jne    f01016f8 <mem_init+0x3dd>
f01016df:	68 76 71 10 f0       	push   $0xf0107176
f01016e4:	68 5f 70 10 f0       	push   $0xf010705f
f01016e9:	68 22 03 00 00       	push   $0x322
f01016ee:	68 39 70 10 f0       	push   $0xf0107039
f01016f3:	e8 48 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016fb:	39 c7                	cmp    %eax,%edi
f01016fd:	74 04                	je     f0101703 <mem_init+0x3e8>
f01016ff:	39 c6                	cmp    %eax,%esi
f0101701:	75 19                	jne    f010171c <mem_init+0x401>
f0101703:	68 c4 74 10 f0       	push   $0xf01074c4
f0101708:	68 5f 70 10 f0       	push   $0xf010705f
f010170d:	68 23 03 00 00       	push   $0x323
f0101712:	68 39 70 10 f0       	push   $0xf0107039
f0101717:	e8 24 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010171c:	83 ec 0c             	sub    $0xc,%esp
f010171f:	6a 00                	push   $0x0
f0101721:	e8 5e f8 ff ff       	call   f0100f84 <page_alloc>
f0101726:	83 c4 10             	add    $0x10,%esp
f0101729:	85 c0                	test   %eax,%eax
f010172b:	74 19                	je     f0101746 <mem_init+0x42b>
f010172d:	68 df 71 10 f0       	push   $0xf01071df
f0101732:	68 5f 70 10 f0       	push   $0xf010705f
f0101737:	68 24 03 00 00       	push   $0x324
f010173c:	68 39 70 10 f0       	push   $0xf0107039
f0101741:	e8 fa e8 ff ff       	call   f0100040 <_panic>
f0101746:	89 f0                	mov    %esi,%eax
f0101748:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f010174e:	c1 f8 03             	sar    $0x3,%eax
f0101751:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101754:	89 c2                	mov    %eax,%edx
f0101756:	c1 ea 0c             	shr    $0xc,%edx
f0101759:	3b 15 ac 1e 2a f0    	cmp    0xf02a1eac,%edx
f010175f:	72 12                	jb     f0101773 <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101761:	50                   	push   %eax
f0101762:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0101767:	6a 58                	push   $0x58
f0101769:	68 45 70 10 f0       	push   $0xf0107045
f010176e:	e8 cd e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101773:	83 ec 04             	sub    $0x4,%esp
f0101776:	68 00 10 00 00       	push   $0x1000
f010177b:	6a 01                	push   $0x1
f010177d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101782:	50                   	push   %eax
f0101783:	e8 52 3f 00 00       	call   f01056da <memset>
	page_free(pp0);
f0101788:	89 34 24             	mov    %esi,(%esp)
f010178b:	e8 6b f8 ff ff       	call   f0100ffb <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101790:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101797:	e8 e8 f7 ff ff       	call   f0100f84 <page_alloc>
f010179c:	83 c4 10             	add    $0x10,%esp
f010179f:	85 c0                	test   %eax,%eax
f01017a1:	75 19                	jne    f01017bc <mem_init+0x4a1>
f01017a3:	68 ee 71 10 f0       	push   $0xf01071ee
f01017a8:	68 5f 70 10 f0       	push   $0xf010705f
f01017ad:	68 29 03 00 00       	push   $0x329
f01017b2:	68 39 70 10 f0       	push   $0xf0107039
f01017b7:	e8 84 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017bc:	39 c6                	cmp    %eax,%esi
f01017be:	74 19                	je     f01017d9 <mem_init+0x4be>
f01017c0:	68 0c 72 10 f0       	push   $0xf010720c
f01017c5:	68 5f 70 10 f0       	push   $0xf010705f
f01017ca:	68 2a 03 00 00       	push   $0x32a
f01017cf:	68 39 70 10 f0       	push   $0xf0107039
f01017d4:	e8 67 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017d9:	89 f0                	mov    %esi,%eax
f01017db:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f01017e1:	c1 f8 03             	sar    $0x3,%eax
f01017e4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017e7:	89 c2                	mov    %eax,%edx
f01017e9:	c1 ea 0c             	shr    $0xc,%edx
f01017ec:	3b 15 ac 1e 2a f0    	cmp    0xf02a1eac,%edx
f01017f2:	72 12                	jb     f0101806 <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017f4:	50                   	push   %eax
f01017f5:	68 a4 6a 10 f0       	push   $0xf0106aa4
f01017fa:	6a 58                	push   $0x58
f01017fc:	68 45 70 10 f0       	push   $0xf0107045
f0101801:	e8 3a e8 ff ff       	call   f0100040 <_panic>
f0101806:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010180c:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101812:	80 38 00             	cmpb   $0x0,(%eax)
f0101815:	74 19                	je     f0101830 <mem_init+0x515>
f0101817:	68 1c 72 10 f0       	push   $0xf010721c
f010181c:	68 5f 70 10 f0       	push   $0xf010705f
f0101821:	68 2d 03 00 00       	push   $0x32d
f0101826:	68 39 70 10 f0       	push   $0xf0107039
f010182b:	e8 10 e8 ff ff       	call   f0100040 <_panic>
f0101830:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101833:	39 d0                	cmp    %edx,%eax
f0101835:	75 db                	jne    f0101812 <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101837:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010183a:	a3 40 12 2a f0       	mov    %eax,0xf02a1240

	// free the pages we took
	page_free(pp0);
f010183f:	83 ec 0c             	sub    $0xc,%esp
f0101842:	56                   	push   %esi
f0101843:	e8 b3 f7 ff ff       	call   f0100ffb <page_free>
	page_free(pp1);
f0101848:	89 3c 24             	mov    %edi,(%esp)
f010184b:	e8 ab f7 ff ff       	call   f0100ffb <page_free>
	page_free(pp2);
f0101850:	83 c4 04             	add    $0x4,%esp
f0101853:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101856:	e8 a0 f7 ff ff       	call   f0100ffb <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010185b:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f0101860:	83 c4 10             	add    $0x10,%esp
f0101863:	eb 05                	jmp    f010186a <mem_init+0x54f>
		--nfree;
f0101865:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101868:	8b 00                	mov    (%eax),%eax
f010186a:	85 c0                	test   %eax,%eax
f010186c:	75 f7                	jne    f0101865 <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f010186e:	85 db                	test   %ebx,%ebx
f0101870:	74 19                	je     f010188b <mem_init+0x570>
f0101872:	68 26 72 10 f0       	push   $0xf0107226
f0101877:	68 5f 70 10 f0       	push   $0xf010705f
f010187c:	68 3a 03 00 00       	push   $0x33a
f0101881:	68 39 70 10 f0       	push   $0xf0107039
f0101886:	e8 b5 e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010188b:	83 ec 0c             	sub    $0xc,%esp
f010188e:	68 e4 74 10 f0       	push   $0xf01074e4
f0101893:	e8 54 1e 00 00       	call   f01036ec <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101898:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010189f:	e8 e0 f6 ff ff       	call   f0100f84 <page_alloc>
f01018a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018a7:	83 c4 10             	add    $0x10,%esp
f01018aa:	85 c0                	test   %eax,%eax
f01018ac:	75 19                	jne    f01018c7 <mem_init+0x5ac>
f01018ae:	68 34 71 10 f0       	push   $0xf0107134
f01018b3:	68 5f 70 10 f0       	push   $0xf010705f
f01018b8:	68 a0 03 00 00       	push   $0x3a0
f01018bd:	68 39 70 10 f0       	push   $0xf0107039
f01018c2:	e8 79 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018c7:	83 ec 0c             	sub    $0xc,%esp
f01018ca:	6a 00                	push   $0x0
f01018cc:	e8 b3 f6 ff ff       	call   f0100f84 <page_alloc>
f01018d1:	89 c3                	mov    %eax,%ebx
f01018d3:	83 c4 10             	add    $0x10,%esp
f01018d6:	85 c0                	test   %eax,%eax
f01018d8:	75 19                	jne    f01018f3 <mem_init+0x5d8>
f01018da:	68 4a 71 10 f0       	push   $0xf010714a
f01018df:	68 5f 70 10 f0       	push   $0xf010705f
f01018e4:	68 a1 03 00 00       	push   $0x3a1
f01018e9:	68 39 70 10 f0       	push   $0xf0107039
f01018ee:	e8 4d e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018f3:	83 ec 0c             	sub    $0xc,%esp
f01018f6:	6a 00                	push   $0x0
f01018f8:	e8 87 f6 ff ff       	call   f0100f84 <page_alloc>
f01018fd:	89 c6                	mov    %eax,%esi
f01018ff:	83 c4 10             	add    $0x10,%esp
f0101902:	85 c0                	test   %eax,%eax
f0101904:	75 19                	jne    f010191f <mem_init+0x604>
f0101906:	68 60 71 10 f0       	push   $0xf0107160
f010190b:	68 5f 70 10 f0       	push   $0xf010705f
f0101910:	68 a2 03 00 00       	push   $0x3a2
f0101915:	68 39 70 10 f0       	push   $0xf0107039
f010191a:	e8 21 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010191f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101922:	75 19                	jne    f010193d <mem_init+0x622>
f0101924:	68 76 71 10 f0       	push   $0xf0107176
f0101929:	68 5f 70 10 f0       	push   $0xf010705f
f010192e:	68 a5 03 00 00       	push   $0x3a5
f0101933:	68 39 70 10 f0       	push   $0xf0107039
f0101938:	e8 03 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010193d:	39 c3                	cmp    %eax,%ebx
f010193f:	74 05                	je     f0101946 <mem_init+0x62b>
f0101941:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101944:	75 19                	jne    f010195f <mem_init+0x644>
f0101946:	68 c4 74 10 f0       	push   $0xf01074c4
f010194b:	68 5f 70 10 f0       	push   $0xf010705f
f0101950:	68 a6 03 00 00       	push   $0x3a6
f0101955:	68 39 70 10 f0       	push   $0xf0107039
f010195a:	e8 e1 e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010195f:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f0101964:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101967:	c7 05 40 12 2a f0 00 	movl   $0x0,0xf02a1240
f010196e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101971:	83 ec 0c             	sub    $0xc,%esp
f0101974:	6a 00                	push   $0x0
f0101976:	e8 09 f6 ff ff       	call   f0100f84 <page_alloc>
f010197b:	83 c4 10             	add    $0x10,%esp
f010197e:	85 c0                	test   %eax,%eax
f0101980:	74 19                	je     f010199b <mem_init+0x680>
f0101982:	68 df 71 10 f0       	push   $0xf01071df
f0101987:	68 5f 70 10 f0       	push   $0xf010705f
f010198c:	68 ad 03 00 00       	push   $0x3ad
f0101991:	68 39 70 10 f0       	push   $0xf0107039
f0101996:	e8 a5 e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010199b:	83 ec 04             	sub    $0x4,%esp
f010199e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019a1:	50                   	push   %eax
f01019a2:	6a 00                	push   $0x0
f01019a4:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f01019aa:	e8 ba f7 ff ff       	call   f0101169 <page_lookup>
f01019af:	83 c4 10             	add    $0x10,%esp
f01019b2:	85 c0                	test   %eax,%eax
f01019b4:	74 19                	je     f01019cf <mem_init+0x6b4>
f01019b6:	68 04 75 10 f0       	push   $0xf0107504
f01019bb:	68 5f 70 10 f0       	push   $0xf010705f
f01019c0:	68 b0 03 00 00       	push   $0x3b0
f01019c5:	68 39 70 10 f0       	push   $0xf0107039
f01019ca:	e8 71 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019cf:	6a 02                	push   $0x2
f01019d1:	6a 00                	push   $0x0
f01019d3:	53                   	push   %ebx
f01019d4:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f01019da:	e8 67 f8 ff ff       	call   f0101246 <page_insert>
f01019df:	83 c4 10             	add    $0x10,%esp
f01019e2:	85 c0                	test   %eax,%eax
f01019e4:	78 19                	js     f01019ff <mem_init+0x6e4>
f01019e6:	68 3c 75 10 f0       	push   $0xf010753c
f01019eb:	68 5f 70 10 f0       	push   $0xf010705f
f01019f0:	68 b3 03 00 00       	push   $0x3b3
f01019f5:	68 39 70 10 f0       	push   $0xf0107039
f01019fa:	e8 41 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019ff:	83 ec 0c             	sub    $0xc,%esp
f0101a02:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a05:	e8 f1 f5 ff ff       	call   f0100ffb <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a0a:	6a 02                	push   $0x2
f0101a0c:	6a 00                	push   $0x0
f0101a0e:	53                   	push   %ebx
f0101a0f:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101a15:	e8 2c f8 ff ff       	call   f0101246 <page_insert>
f0101a1a:	83 c4 20             	add    $0x20,%esp
f0101a1d:	85 c0                	test   %eax,%eax
f0101a1f:	74 19                	je     f0101a3a <mem_init+0x71f>
f0101a21:	68 6c 75 10 f0       	push   $0xf010756c
f0101a26:	68 5f 70 10 f0       	push   $0xf010705f
f0101a2b:	68 b7 03 00 00       	push   $0x3b7
f0101a30:	68 39 70 10 f0       	push   $0xf0107039
f0101a35:	e8 06 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a3a:	8b 3d b0 1e 2a f0    	mov    0xf02a1eb0,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a40:	a1 b4 1e 2a f0       	mov    0xf02a1eb4,%eax
f0101a45:	89 c1                	mov    %eax,%ecx
f0101a47:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a4a:	8b 17                	mov    (%edi),%edx
f0101a4c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a55:	29 c8                	sub    %ecx,%eax
f0101a57:	c1 f8 03             	sar    $0x3,%eax
f0101a5a:	c1 e0 0c             	shl    $0xc,%eax
f0101a5d:	39 c2                	cmp    %eax,%edx
f0101a5f:	74 19                	je     f0101a7a <mem_init+0x75f>
f0101a61:	68 9c 75 10 f0       	push   $0xf010759c
f0101a66:	68 5f 70 10 f0       	push   $0xf010705f
f0101a6b:	68 b8 03 00 00       	push   $0x3b8
f0101a70:	68 39 70 10 f0       	push   $0xf0107039
f0101a75:	e8 c6 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a7a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a7f:	89 f8                	mov    %edi,%eax
f0101a81:	e8 ec f0 ff ff       	call   f0100b72 <check_va2pa>
f0101a86:	89 da                	mov    %ebx,%edx
f0101a88:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a8b:	c1 fa 03             	sar    $0x3,%edx
f0101a8e:	c1 e2 0c             	shl    $0xc,%edx
f0101a91:	39 d0                	cmp    %edx,%eax
f0101a93:	74 19                	je     f0101aae <mem_init+0x793>
f0101a95:	68 c4 75 10 f0       	push   $0xf01075c4
f0101a9a:	68 5f 70 10 f0       	push   $0xf010705f
f0101a9f:	68 b9 03 00 00       	push   $0x3b9
f0101aa4:	68 39 70 10 f0       	push   $0xf0107039
f0101aa9:	e8 92 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101aae:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ab3:	74 19                	je     f0101ace <mem_init+0x7b3>
f0101ab5:	68 31 72 10 f0       	push   $0xf0107231
f0101aba:	68 5f 70 10 f0       	push   $0xf010705f
f0101abf:	68 ba 03 00 00       	push   $0x3ba
f0101ac4:	68 39 70 10 f0       	push   $0xf0107039
f0101ac9:	e8 72 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ace:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ad1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ad6:	74 19                	je     f0101af1 <mem_init+0x7d6>
f0101ad8:	68 42 72 10 f0       	push   $0xf0107242
f0101add:	68 5f 70 10 f0       	push   $0xf010705f
f0101ae2:	68 bb 03 00 00       	push   $0x3bb
f0101ae7:	68 39 70 10 f0       	push   $0xf0107039
f0101aec:	e8 4f e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101af1:	6a 02                	push   $0x2
f0101af3:	68 00 10 00 00       	push   $0x1000
f0101af8:	56                   	push   %esi
f0101af9:	57                   	push   %edi
f0101afa:	e8 47 f7 ff ff       	call   f0101246 <page_insert>
f0101aff:	83 c4 10             	add    $0x10,%esp
f0101b02:	85 c0                	test   %eax,%eax
f0101b04:	74 19                	je     f0101b1f <mem_init+0x804>
f0101b06:	68 f4 75 10 f0       	push   $0xf01075f4
f0101b0b:	68 5f 70 10 f0       	push   $0xf010705f
f0101b10:	68 be 03 00 00       	push   $0x3be
f0101b15:	68 39 70 10 f0       	push   $0xf0107039
f0101b1a:	e8 21 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b1f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b24:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f0101b29:	e8 44 f0 ff ff       	call   f0100b72 <check_va2pa>
f0101b2e:	89 f2                	mov    %esi,%edx
f0101b30:	2b 15 b4 1e 2a f0    	sub    0xf02a1eb4,%edx
f0101b36:	c1 fa 03             	sar    $0x3,%edx
f0101b39:	c1 e2 0c             	shl    $0xc,%edx
f0101b3c:	39 d0                	cmp    %edx,%eax
f0101b3e:	74 19                	je     f0101b59 <mem_init+0x83e>
f0101b40:	68 30 76 10 f0       	push   $0xf0107630
f0101b45:	68 5f 70 10 f0       	push   $0xf010705f
f0101b4a:	68 bf 03 00 00       	push   $0x3bf
f0101b4f:	68 39 70 10 f0       	push   $0xf0107039
f0101b54:	e8 e7 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b59:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b5e:	74 19                	je     f0101b79 <mem_init+0x85e>
f0101b60:	68 53 72 10 f0       	push   $0xf0107253
f0101b65:	68 5f 70 10 f0       	push   $0xf010705f
f0101b6a:	68 c0 03 00 00       	push   $0x3c0
f0101b6f:	68 39 70 10 f0       	push   $0xf0107039
f0101b74:	e8 c7 e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b79:	83 ec 0c             	sub    $0xc,%esp
f0101b7c:	6a 00                	push   $0x0
f0101b7e:	e8 01 f4 ff ff       	call   f0100f84 <page_alloc>
f0101b83:	83 c4 10             	add    $0x10,%esp
f0101b86:	85 c0                	test   %eax,%eax
f0101b88:	74 19                	je     f0101ba3 <mem_init+0x888>
f0101b8a:	68 df 71 10 f0       	push   $0xf01071df
f0101b8f:	68 5f 70 10 f0       	push   $0xf010705f
f0101b94:	68 c3 03 00 00       	push   $0x3c3
f0101b99:	68 39 70 10 f0       	push   $0xf0107039
f0101b9e:	e8 9d e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ba3:	6a 02                	push   $0x2
f0101ba5:	68 00 10 00 00       	push   $0x1000
f0101baa:	56                   	push   %esi
f0101bab:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101bb1:	e8 90 f6 ff ff       	call   f0101246 <page_insert>
f0101bb6:	83 c4 10             	add    $0x10,%esp
f0101bb9:	85 c0                	test   %eax,%eax
f0101bbb:	74 19                	je     f0101bd6 <mem_init+0x8bb>
f0101bbd:	68 f4 75 10 f0       	push   $0xf01075f4
f0101bc2:	68 5f 70 10 f0       	push   $0xf010705f
f0101bc7:	68 c6 03 00 00       	push   $0x3c6
f0101bcc:	68 39 70 10 f0       	push   $0xf0107039
f0101bd1:	e8 6a e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bd6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bdb:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f0101be0:	e8 8d ef ff ff       	call   f0100b72 <check_va2pa>
f0101be5:	89 f2                	mov    %esi,%edx
f0101be7:	2b 15 b4 1e 2a f0    	sub    0xf02a1eb4,%edx
f0101bed:	c1 fa 03             	sar    $0x3,%edx
f0101bf0:	c1 e2 0c             	shl    $0xc,%edx
f0101bf3:	39 d0                	cmp    %edx,%eax
f0101bf5:	74 19                	je     f0101c10 <mem_init+0x8f5>
f0101bf7:	68 30 76 10 f0       	push   $0xf0107630
f0101bfc:	68 5f 70 10 f0       	push   $0xf010705f
f0101c01:	68 c7 03 00 00       	push   $0x3c7
f0101c06:	68 39 70 10 f0       	push   $0xf0107039
f0101c0b:	e8 30 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c10:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c15:	74 19                	je     f0101c30 <mem_init+0x915>
f0101c17:	68 53 72 10 f0       	push   $0xf0107253
f0101c1c:	68 5f 70 10 f0       	push   $0xf010705f
f0101c21:	68 c8 03 00 00       	push   $0x3c8
f0101c26:	68 39 70 10 f0       	push   $0xf0107039
f0101c2b:	e8 10 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c30:	83 ec 0c             	sub    $0xc,%esp
f0101c33:	6a 00                	push   $0x0
f0101c35:	e8 4a f3 ff ff       	call   f0100f84 <page_alloc>
f0101c3a:	83 c4 10             	add    $0x10,%esp
f0101c3d:	85 c0                	test   %eax,%eax
f0101c3f:	74 19                	je     f0101c5a <mem_init+0x93f>
f0101c41:	68 df 71 10 f0       	push   $0xf01071df
f0101c46:	68 5f 70 10 f0       	push   $0xf010705f
f0101c4b:	68 cc 03 00 00       	push   $0x3cc
f0101c50:	68 39 70 10 f0       	push   $0xf0107039
f0101c55:	e8 e6 e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c5a:	8b 15 b0 1e 2a f0    	mov    0xf02a1eb0,%edx
f0101c60:	8b 02                	mov    (%edx),%eax
f0101c62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c67:	89 c1                	mov    %eax,%ecx
f0101c69:	c1 e9 0c             	shr    $0xc,%ecx
f0101c6c:	3b 0d ac 1e 2a f0    	cmp    0xf02a1eac,%ecx
f0101c72:	72 15                	jb     f0101c89 <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c74:	50                   	push   %eax
f0101c75:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0101c7a:	68 cf 03 00 00       	push   $0x3cf
f0101c7f:	68 39 70 10 f0       	push   $0xf0107039
f0101c84:	e8 b7 e3 ff ff       	call   f0100040 <_panic>
f0101c89:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c91:	83 ec 04             	sub    $0x4,%esp
f0101c94:	6a 00                	push   $0x0
f0101c96:	68 00 10 00 00       	push   $0x1000
f0101c9b:	52                   	push   %edx
f0101c9c:	e8 bc f3 ff ff       	call   f010105d <pgdir_walk>
f0101ca1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ca4:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ca7:	83 c4 10             	add    $0x10,%esp
f0101caa:	39 d0                	cmp    %edx,%eax
f0101cac:	74 19                	je     f0101cc7 <mem_init+0x9ac>
f0101cae:	68 60 76 10 f0       	push   $0xf0107660
f0101cb3:	68 5f 70 10 f0       	push   $0xf010705f
f0101cb8:	68 d0 03 00 00       	push   $0x3d0
f0101cbd:	68 39 70 10 f0       	push   $0xf0107039
f0101cc2:	e8 79 e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cc7:	6a 06                	push   $0x6
f0101cc9:	68 00 10 00 00       	push   $0x1000
f0101cce:	56                   	push   %esi
f0101ccf:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101cd5:	e8 6c f5 ff ff       	call   f0101246 <page_insert>
f0101cda:	83 c4 10             	add    $0x10,%esp
f0101cdd:	85 c0                	test   %eax,%eax
f0101cdf:	74 19                	je     f0101cfa <mem_init+0x9df>
f0101ce1:	68 a0 76 10 f0       	push   $0xf01076a0
f0101ce6:	68 5f 70 10 f0       	push   $0xf010705f
f0101ceb:	68 d3 03 00 00       	push   $0x3d3
f0101cf0:	68 39 70 10 f0       	push   $0xf0107039
f0101cf5:	e8 46 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cfa:	8b 3d b0 1e 2a f0    	mov    0xf02a1eb0,%edi
f0101d00:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d05:	89 f8                	mov    %edi,%eax
f0101d07:	e8 66 ee ff ff       	call   f0100b72 <check_va2pa>
f0101d0c:	89 f2                	mov    %esi,%edx
f0101d0e:	2b 15 b4 1e 2a f0    	sub    0xf02a1eb4,%edx
f0101d14:	c1 fa 03             	sar    $0x3,%edx
f0101d17:	c1 e2 0c             	shl    $0xc,%edx
f0101d1a:	39 d0                	cmp    %edx,%eax
f0101d1c:	74 19                	je     f0101d37 <mem_init+0xa1c>
f0101d1e:	68 30 76 10 f0       	push   $0xf0107630
f0101d23:	68 5f 70 10 f0       	push   $0xf010705f
f0101d28:	68 d4 03 00 00       	push   $0x3d4
f0101d2d:	68 39 70 10 f0       	push   $0xf0107039
f0101d32:	e8 09 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d37:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d3c:	74 19                	je     f0101d57 <mem_init+0xa3c>
f0101d3e:	68 53 72 10 f0       	push   $0xf0107253
f0101d43:	68 5f 70 10 f0       	push   $0xf010705f
f0101d48:	68 d5 03 00 00       	push   $0x3d5
f0101d4d:	68 39 70 10 f0       	push   $0xf0107039
f0101d52:	e8 e9 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d57:	83 ec 04             	sub    $0x4,%esp
f0101d5a:	6a 00                	push   $0x0
f0101d5c:	68 00 10 00 00       	push   $0x1000
f0101d61:	57                   	push   %edi
f0101d62:	e8 f6 f2 ff ff       	call   f010105d <pgdir_walk>
f0101d67:	83 c4 10             	add    $0x10,%esp
f0101d6a:	f6 00 04             	testb  $0x4,(%eax)
f0101d6d:	75 19                	jne    f0101d88 <mem_init+0xa6d>
f0101d6f:	68 e0 76 10 f0       	push   $0xf01076e0
f0101d74:	68 5f 70 10 f0       	push   $0xf010705f
f0101d79:	68 d6 03 00 00       	push   $0x3d6
f0101d7e:	68 39 70 10 f0       	push   $0xf0107039
f0101d83:	e8 b8 e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d88:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f0101d8d:	f6 00 04             	testb  $0x4,(%eax)
f0101d90:	75 19                	jne    f0101dab <mem_init+0xa90>
f0101d92:	68 64 72 10 f0       	push   $0xf0107264
f0101d97:	68 5f 70 10 f0       	push   $0xf010705f
f0101d9c:	68 d7 03 00 00       	push   $0x3d7
f0101da1:	68 39 70 10 f0       	push   $0xf0107039
f0101da6:	e8 95 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dab:	6a 02                	push   $0x2
f0101dad:	68 00 10 00 00       	push   $0x1000
f0101db2:	56                   	push   %esi
f0101db3:	50                   	push   %eax
f0101db4:	e8 8d f4 ff ff       	call   f0101246 <page_insert>
f0101db9:	83 c4 10             	add    $0x10,%esp
f0101dbc:	85 c0                	test   %eax,%eax
f0101dbe:	74 19                	je     f0101dd9 <mem_init+0xabe>
f0101dc0:	68 f4 75 10 f0       	push   $0xf01075f4
f0101dc5:	68 5f 70 10 f0       	push   $0xf010705f
f0101dca:	68 da 03 00 00       	push   $0x3da
f0101dcf:	68 39 70 10 f0       	push   $0xf0107039
f0101dd4:	e8 67 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101dd9:	83 ec 04             	sub    $0x4,%esp
f0101ddc:	6a 00                	push   $0x0
f0101dde:	68 00 10 00 00       	push   $0x1000
f0101de3:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101de9:	e8 6f f2 ff ff       	call   f010105d <pgdir_walk>
f0101dee:	83 c4 10             	add    $0x10,%esp
f0101df1:	f6 00 02             	testb  $0x2,(%eax)
f0101df4:	75 19                	jne    f0101e0f <mem_init+0xaf4>
f0101df6:	68 14 77 10 f0       	push   $0xf0107714
f0101dfb:	68 5f 70 10 f0       	push   $0xf010705f
f0101e00:	68 db 03 00 00       	push   $0x3db
f0101e05:	68 39 70 10 f0       	push   $0xf0107039
f0101e0a:	e8 31 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e0f:	83 ec 04             	sub    $0x4,%esp
f0101e12:	6a 00                	push   $0x0
f0101e14:	68 00 10 00 00       	push   $0x1000
f0101e19:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101e1f:	e8 39 f2 ff ff       	call   f010105d <pgdir_walk>
f0101e24:	83 c4 10             	add    $0x10,%esp
f0101e27:	f6 00 04             	testb  $0x4,(%eax)
f0101e2a:	74 19                	je     f0101e45 <mem_init+0xb2a>
f0101e2c:	68 48 77 10 f0       	push   $0xf0107748
f0101e31:	68 5f 70 10 f0       	push   $0xf010705f
f0101e36:	68 dc 03 00 00       	push   $0x3dc
f0101e3b:	68 39 70 10 f0       	push   $0xf0107039
f0101e40:	e8 fb e1 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e45:	6a 02                	push   $0x2
f0101e47:	68 00 00 40 00       	push   $0x400000
f0101e4c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e4f:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101e55:	e8 ec f3 ff ff       	call   f0101246 <page_insert>
f0101e5a:	83 c4 10             	add    $0x10,%esp
f0101e5d:	85 c0                	test   %eax,%eax
f0101e5f:	78 19                	js     f0101e7a <mem_init+0xb5f>
f0101e61:	68 80 77 10 f0       	push   $0xf0107780
f0101e66:	68 5f 70 10 f0       	push   $0xf010705f
f0101e6b:	68 df 03 00 00       	push   $0x3df
f0101e70:	68 39 70 10 f0       	push   $0xf0107039
f0101e75:	e8 c6 e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e7a:	6a 02                	push   $0x2
f0101e7c:	68 00 10 00 00       	push   $0x1000
f0101e81:	53                   	push   %ebx
f0101e82:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101e88:	e8 b9 f3 ff ff       	call   f0101246 <page_insert>
f0101e8d:	83 c4 10             	add    $0x10,%esp
f0101e90:	85 c0                	test   %eax,%eax
f0101e92:	74 19                	je     f0101ead <mem_init+0xb92>
f0101e94:	68 b8 77 10 f0       	push   $0xf01077b8
f0101e99:	68 5f 70 10 f0       	push   $0xf010705f
f0101e9e:	68 e2 03 00 00       	push   $0x3e2
f0101ea3:	68 39 70 10 f0       	push   $0xf0107039
f0101ea8:	e8 93 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ead:	83 ec 04             	sub    $0x4,%esp
f0101eb0:	6a 00                	push   $0x0
f0101eb2:	68 00 10 00 00       	push   $0x1000
f0101eb7:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101ebd:	e8 9b f1 ff ff       	call   f010105d <pgdir_walk>
f0101ec2:	83 c4 10             	add    $0x10,%esp
f0101ec5:	f6 00 04             	testb  $0x4,(%eax)
f0101ec8:	74 19                	je     f0101ee3 <mem_init+0xbc8>
f0101eca:	68 48 77 10 f0       	push   $0xf0107748
f0101ecf:	68 5f 70 10 f0       	push   $0xf010705f
f0101ed4:	68 e3 03 00 00       	push   $0x3e3
f0101ed9:	68 39 70 10 f0       	push   $0xf0107039
f0101ede:	e8 5d e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ee3:	8b 3d b0 1e 2a f0    	mov    0xf02a1eb0,%edi
f0101ee9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eee:	89 f8                	mov    %edi,%eax
f0101ef0:	e8 7d ec ff ff       	call   f0100b72 <check_va2pa>
f0101ef5:	89 c1                	mov    %eax,%ecx
f0101ef7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101efa:	89 d8                	mov    %ebx,%eax
f0101efc:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0101f02:	c1 f8 03             	sar    $0x3,%eax
f0101f05:	c1 e0 0c             	shl    $0xc,%eax
f0101f08:	39 c1                	cmp    %eax,%ecx
f0101f0a:	74 19                	je     f0101f25 <mem_init+0xc0a>
f0101f0c:	68 f4 77 10 f0       	push   $0xf01077f4
f0101f11:	68 5f 70 10 f0       	push   $0xf010705f
f0101f16:	68 e6 03 00 00       	push   $0x3e6
f0101f1b:	68 39 70 10 f0       	push   $0xf0107039
f0101f20:	e8 1b e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f25:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f2a:	89 f8                	mov    %edi,%eax
f0101f2c:	e8 41 ec ff ff       	call   f0100b72 <check_va2pa>
f0101f31:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101f34:	74 19                	je     f0101f4f <mem_init+0xc34>
f0101f36:	68 20 78 10 f0       	push   $0xf0107820
f0101f3b:	68 5f 70 10 f0       	push   $0xf010705f
f0101f40:	68 e7 03 00 00       	push   $0x3e7
f0101f45:	68 39 70 10 f0       	push   $0xf0107039
f0101f4a:	e8 f1 e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f4f:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101f54:	74 19                	je     f0101f6f <mem_init+0xc54>
f0101f56:	68 7a 72 10 f0       	push   $0xf010727a
f0101f5b:	68 5f 70 10 f0       	push   $0xf010705f
f0101f60:	68 e9 03 00 00       	push   $0x3e9
f0101f65:	68 39 70 10 f0       	push   $0xf0107039
f0101f6a:	e8 d1 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f6f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f74:	74 19                	je     f0101f8f <mem_init+0xc74>
f0101f76:	68 8b 72 10 f0       	push   $0xf010728b
f0101f7b:	68 5f 70 10 f0       	push   $0xf010705f
f0101f80:	68 ea 03 00 00       	push   $0x3ea
f0101f85:	68 39 70 10 f0       	push   $0xf0107039
f0101f8a:	e8 b1 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f8f:	83 ec 0c             	sub    $0xc,%esp
f0101f92:	6a 00                	push   $0x0
f0101f94:	e8 eb ef ff ff       	call   f0100f84 <page_alloc>
f0101f99:	83 c4 10             	add    $0x10,%esp
f0101f9c:	85 c0                	test   %eax,%eax
f0101f9e:	74 04                	je     f0101fa4 <mem_init+0xc89>
f0101fa0:	39 c6                	cmp    %eax,%esi
f0101fa2:	74 19                	je     f0101fbd <mem_init+0xca2>
f0101fa4:	68 50 78 10 f0       	push   $0xf0107850
f0101fa9:	68 5f 70 10 f0       	push   $0xf010705f
f0101fae:	68 ed 03 00 00       	push   $0x3ed
f0101fb3:	68 39 70 10 f0       	push   $0xf0107039
f0101fb8:	e8 83 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101fbd:	83 ec 08             	sub    $0x8,%esp
f0101fc0:	6a 00                	push   $0x0
f0101fc2:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0101fc8:	e8 2b f2 ff ff       	call   f01011f8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fcd:	8b 3d b0 1e 2a f0    	mov    0xf02a1eb0,%edi
f0101fd3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fd8:	89 f8                	mov    %edi,%eax
f0101fda:	e8 93 eb ff ff       	call   f0100b72 <check_va2pa>
f0101fdf:	83 c4 10             	add    $0x10,%esp
f0101fe2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fe5:	74 19                	je     f0102000 <mem_init+0xce5>
f0101fe7:	68 74 78 10 f0       	push   $0xf0107874
f0101fec:	68 5f 70 10 f0       	push   $0xf010705f
f0101ff1:	68 f1 03 00 00       	push   $0x3f1
f0101ff6:	68 39 70 10 f0       	push   $0xf0107039
f0101ffb:	e8 40 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102000:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102005:	89 f8                	mov    %edi,%eax
f0102007:	e8 66 eb ff ff       	call   f0100b72 <check_va2pa>
f010200c:	89 da                	mov    %ebx,%edx
f010200e:	2b 15 b4 1e 2a f0    	sub    0xf02a1eb4,%edx
f0102014:	c1 fa 03             	sar    $0x3,%edx
f0102017:	c1 e2 0c             	shl    $0xc,%edx
f010201a:	39 d0                	cmp    %edx,%eax
f010201c:	74 19                	je     f0102037 <mem_init+0xd1c>
f010201e:	68 20 78 10 f0       	push   $0xf0107820
f0102023:	68 5f 70 10 f0       	push   $0xf010705f
f0102028:	68 f2 03 00 00       	push   $0x3f2
f010202d:	68 39 70 10 f0       	push   $0xf0107039
f0102032:	e8 09 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102037:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010203c:	74 19                	je     f0102057 <mem_init+0xd3c>
f010203e:	68 31 72 10 f0       	push   $0xf0107231
f0102043:	68 5f 70 10 f0       	push   $0xf010705f
f0102048:	68 f3 03 00 00       	push   $0x3f3
f010204d:	68 39 70 10 f0       	push   $0xf0107039
f0102052:	e8 e9 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102057:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010205c:	74 19                	je     f0102077 <mem_init+0xd5c>
f010205e:	68 8b 72 10 f0       	push   $0xf010728b
f0102063:	68 5f 70 10 f0       	push   $0xf010705f
f0102068:	68 f4 03 00 00       	push   $0x3f4
f010206d:	68 39 70 10 f0       	push   $0xf0107039
f0102072:	e8 c9 df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102077:	6a 00                	push   $0x0
f0102079:	68 00 10 00 00       	push   $0x1000
f010207e:	53                   	push   %ebx
f010207f:	57                   	push   %edi
f0102080:	e8 c1 f1 ff ff       	call   f0101246 <page_insert>
f0102085:	83 c4 10             	add    $0x10,%esp
f0102088:	85 c0                	test   %eax,%eax
f010208a:	74 19                	je     f01020a5 <mem_init+0xd8a>
f010208c:	68 98 78 10 f0       	push   $0xf0107898
f0102091:	68 5f 70 10 f0       	push   $0xf010705f
f0102096:	68 f7 03 00 00       	push   $0x3f7
f010209b:	68 39 70 10 f0       	push   $0xf0107039
f01020a0:	e8 9b df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01020a5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020aa:	75 19                	jne    f01020c5 <mem_init+0xdaa>
f01020ac:	68 9c 72 10 f0       	push   $0xf010729c
f01020b1:	68 5f 70 10 f0       	push   $0xf010705f
f01020b6:	68 f8 03 00 00       	push   $0x3f8
f01020bb:	68 39 70 10 f0       	push   $0xf0107039
f01020c0:	e8 7b df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01020c5:	83 3b 00             	cmpl   $0x0,(%ebx)
f01020c8:	74 19                	je     f01020e3 <mem_init+0xdc8>
f01020ca:	68 a8 72 10 f0       	push   $0xf01072a8
f01020cf:	68 5f 70 10 f0       	push   $0xf010705f
f01020d4:	68 f9 03 00 00       	push   $0x3f9
f01020d9:	68 39 70 10 f0       	push   $0xf0107039
f01020de:	e8 5d df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01020e3:	83 ec 08             	sub    $0x8,%esp
f01020e6:	68 00 10 00 00       	push   $0x1000
f01020eb:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f01020f1:	e8 02 f1 ff ff       	call   f01011f8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020f6:	8b 3d b0 1e 2a f0    	mov    0xf02a1eb0,%edi
f01020fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102101:	89 f8                	mov    %edi,%eax
f0102103:	e8 6a ea ff ff       	call   f0100b72 <check_va2pa>
f0102108:	83 c4 10             	add    $0x10,%esp
f010210b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010210e:	74 19                	je     f0102129 <mem_init+0xe0e>
f0102110:	68 74 78 10 f0       	push   $0xf0107874
f0102115:	68 5f 70 10 f0       	push   $0xf010705f
f010211a:	68 fd 03 00 00       	push   $0x3fd
f010211f:	68 39 70 10 f0       	push   $0xf0107039
f0102124:	e8 17 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102129:	ba 00 10 00 00       	mov    $0x1000,%edx
f010212e:	89 f8                	mov    %edi,%eax
f0102130:	e8 3d ea ff ff       	call   f0100b72 <check_va2pa>
f0102135:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102138:	74 19                	je     f0102153 <mem_init+0xe38>
f010213a:	68 d0 78 10 f0       	push   $0xf01078d0
f010213f:	68 5f 70 10 f0       	push   $0xf010705f
f0102144:	68 fe 03 00 00       	push   $0x3fe
f0102149:	68 39 70 10 f0       	push   $0xf0107039
f010214e:	e8 ed de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102153:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102158:	74 19                	je     f0102173 <mem_init+0xe58>
f010215a:	68 bd 72 10 f0       	push   $0xf01072bd
f010215f:	68 5f 70 10 f0       	push   $0xf010705f
f0102164:	68 ff 03 00 00       	push   $0x3ff
f0102169:	68 39 70 10 f0       	push   $0xf0107039
f010216e:	e8 cd de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102173:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102178:	74 19                	je     f0102193 <mem_init+0xe78>
f010217a:	68 8b 72 10 f0       	push   $0xf010728b
f010217f:	68 5f 70 10 f0       	push   $0xf010705f
f0102184:	68 00 04 00 00       	push   $0x400
f0102189:	68 39 70 10 f0       	push   $0xf0107039
f010218e:	e8 ad de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102193:	83 ec 0c             	sub    $0xc,%esp
f0102196:	6a 00                	push   $0x0
f0102198:	e8 e7 ed ff ff       	call   f0100f84 <page_alloc>
f010219d:	83 c4 10             	add    $0x10,%esp
f01021a0:	39 c3                	cmp    %eax,%ebx
f01021a2:	75 04                	jne    f01021a8 <mem_init+0xe8d>
f01021a4:	85 c0                	test   %eax,%eax
f01021a6:	75 19                	jne    f01021c1 <mem_init+0xea6>
f01021a8:	68 f8 78 10 f0       	push   $0xf01078f8
f01021ad:	68 5f 70 10 f0       	push   $0xf010705f
f01021b2:	68 03 04 00 00       	push   $0x403
f01021b7:	68 39 70 10 f0       	push   $0xf0107039
f01021bc:	e8 7f de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01021c1:	83 ec 0c             	sub    $0xc,%esp
f01021c4:	6a 00                	push   $0x0
f01021c6:	e8 b9 ed ff ff       	call   f0100f84 <page_alloc>
f01021cb:	83 c4 10             	add    $0x10,%esp
f01021ce:	85 c0                	test   %eax,%eax
f01021d0:	74 19                	je     f01021eb <mem_init+0xed0>
f01021d2:	68 df 71 10 f0       	push   $0xf01071df
f01021d7:	68 5f 70 10 f0       	push   $0xf010705f
f01021dc:	68 06 04 00 00       	push   $0x406
f01021e1:	68 39 70 10 f0       	push   $0xf0107039
f01021e6:	e8 55 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021eb:	8b 0d b0 1e 2a f0    	mov    0xf02a1eb0,%ecx
f01021f1:	8b 11                	mov    (%ecx),%edx
f01021f3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021fc:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0102202:	c1 f8 03             	sar    $0x3,%eax
f0102205:	c1 e0 0c             	shl    $0xc,%eax
f0102208:	39 c2                	cmp    %eax,%edx
f010220a:	74 19                	je     f0102225 <mem_init+0xf0a>
f010220c:	68 9c 75 10 f0       	push   $0xf010759c
f0102211:	68 5f 70 10 f0       	push   $0xf010705f
f0102216:	68 09 04 00 00       	push   $0x409
f010221b:	68 39 70 10 f0       	push   $0xf0107039
f0102220:	e8 1b de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102225:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010222b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010222e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102233:	74 19                	je     f010224e <mem_init+0xf33>
f0102235:	68 42 72 10 f0       	push   $0xf0107242
f010223a:	68 5f 70 10 f0       	push   $0xf010705f
f010223f:	68 0b 04 00 00       	push   $0x40b
f0102244:	68 39 70 10 f0       	push   $0xf0107039
f0102249:	e8 f2 dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010224e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102251:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102257:	83 ec 0c             	sub    $0xc,%esp
f010225a:	50                   	push   %eax
f010225b:	e8 9b ed ff ff       	call   f0100ffb <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102260:	83 c4 0c             	add    $0xc,%esp
f0102263:	6a 01                	push   $0x1
f0102265:	68 00 10 40 00       	push   $0x401000
f010226a:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0102270:	e8 e8 ed ff ff       	call   f010105d <pgdir_walk>
f0102275:	89 c7                	mov    %eax,%edi
f0102277:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010227a:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f010227f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102282:	8b 40 04             	mov    0x4(%eax),%eax
f0102285:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010228a:	8b 0d ac 1e 2a f0    	mov    0xf02a1eac,%ecx
f0102290:	89 c2                	mov    %eax,%edx
f0102292:	c1 ea 0c             	shr    $0xc,%edx
f0102295:	83 c4 10             	add    $0x10,%esp
f0102298:	39 ca                	cmp    %ecx,%edx
f010229a:	72 15                	jb     f01022b1 <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010229c:	50                   	push   %eax
f010229d:	68 a4 6a 10 f0       	push   $0xf0106aa4
f01022a2:	68 12 04 00 00       	push   $0x412
f01022a7:	68 39 70 10 f0       	push   $0xf0107039
f01022ac:	e8 8f dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01022b1:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01022b6:	39 c7                	cmp    %eax,%edi
f01022b8:	74 19                	je     f01022d3 <mem_init+0xfb8>
f01022ba:	68 ce 72 10 f0       	push   $0xf01072ce
f01022bf:	68 5f 70 10 f0       	push   $0xf010705f
f01022c4:	68 13 04 00 00       	push   $0x413
f01022c9:	68 39 70 10 f0       	push   $0xf0107039
f01022ce:	e8 6d dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01022d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01022d6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01022dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022e0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022e6:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f01022ec:	c1 f8 03             	sar    $0x3,%eax
f01022ef:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022f2:	89 c2                	mov    %eax,%edx
f01022f4:	c1 ea 0c             	shr    $0xc,%edx
f01022f7:	39 d1                	cmp    %edx,%ecx
f01022f9:	77 12                	ja     f010230d <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022fb:	50                   	push   %eax
f01022fc:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0102301:	6a 58                	push   $0x58
f0102303:	68 45 70 10 f0       	push   $0xf0107045
f0102308:	e8 33 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010230d:	83 ec 04             	sub    $0x4,%esp
f0102310:	68 00 10 00 00       	push   $0x1000
f0102315:	68 ff 00 00 00       	push   $0xff
f010231a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010231f:	50                   	push   %eax
f0102320:	e8 b5 33 00 00       	call   f01056da <memset>
	page_free(pp0);
f0102325:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102328:	89 3c 24             	mov    %edi,(%esp)
f010232b:	e8 cb ec ff ff       	call   f0100ffb <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102330:	83 c4 0c             	add    $0xc,%esp
f0102333:	6a 01                	push   $0x1
f0102335:	6a 00                	push   $0x0
f0102337:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f010233d:	e8 1b ed ff ff       	call   f010105d <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102342:	89 fa                	mov    %edi,%edx
f0102344:	2b 15 b4 1e 2a f0    	sub    0xf02a1eb4,%edx
f010234a:	c1 fa 03             	sar    $0x3,%edx
f010234d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102350:	89 d0                	mov    %edx,%eax
f0102352:	c1 e8 0c             	shr    $0xc,%eax
f0102355:	83 c4 10             	add    $0x10,%esp
f0102358:	3b 05 ac 1e 2a f0    	cmp    0xf02a1eac,%eax
f010235e:	72 12                	jb     f0102372 <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102360:	52                   	push   %edx
f0102361:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0102366:	6a 58                	push   $0x58
f0102368:	68 45 70 10 f0       	push   $0xf0107045
f010236d:	e8 ce dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102372:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010237b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102381:	f6 00 01             	testb  $0x1,(%eax)
f0102384:	74 19                	je     f010239f <mem_init+0x1084>
f0102386:	68 e6 72 10 f0       	push   $0xf01072e6
f010238b:	68 5f 70 10 f0       	push   $0xf010705f
f0102390:	68 1d 04 00 00       	push   $0x41d
f0102395:	68 39 70 10 f0       	push   $0xf0107039
f010239a:	e8 a1 dc ff ff       	call   f0100040 <_panic>
f010239f:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01023a2:	39 d0                	cmp    %edx,%eax
f01023a4:	75 db                	jne    f0102381 <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01023a6:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f01023ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023b4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01023ba:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01023bd:	89 0d 40 12 2a f0    	mov    %ecx,0xf02a1240

	// free the pages we took
	page_free(pp0);
f01023c3:	83 ec 0c             	sub    $0xc,%esp
f01023c6:	50                   	push   %eax
f01023c7:	e8 2f ec ff ff       	call   f0100ffb <page_free>
	page_free(pp1);
f01023cc:	89 1c 24             	mov    %ebx,(%esp)
f01023cf:	e8 27 ec ff ff       	call   f0100ffb <page_free>
	page_free(pp2);
f01023d4:	89 34 24             	mov    %esi,(%esp)
f01023d7:	e8 1f ec ff ff       	call   f0100ffb <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01023dc:	83 c4 08             	add    $0x8,%esp
f01023df:	68 01 10 00 00       	push   $0x1001
f01023e4:	6a 00                	push   $0x0
f01023e6:	e8 c1 ee ff ff       	call   f01012ac <mmio_map_region>
f01023eb:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01023ed:	83 c4 08             	add    $0x8,%esp
f01023f0:	68 00 10 00 00       	push   $0x1000
f01023f5:	6a 00                	push   $0x0
f01023f7:	e8 b0 ee ff ff       	call   f01012ac <mmio_map_region>
f01023fc:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01023fe:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102404:	83 c4 10             	add    $0x10,%esp
f0102407:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010240d:	76 07                	jbe    f0102416 <mem_init+0x10fb>
f010240f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102414:	76 19                	jbe    f010242f <mem_init+0x1114>
f0102416:	68 1c 79 10 f0       	push   $0xf010791c
f010241b:	68 5f 70 10 f0       	push   $0xf010705f
f0102420:	68 2d 04 00 00       	push   $0x42d
f0102425:	68 39 70 10 f0       	push   $0xf0107039
f010242a:	e8 11 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010242f:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102435:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010243b:	77 08                	ja     f0102445 <mem_init+0x112a>
f010243d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102443:	77 19                	ja     f010245e <mem_init+0x1143>
f0102445:	68 44 79 10 f0       	push   $0xf0107944
f010244a:	68 5f 70 10 f0       	push   $0xf010705f
f010244f:	68 2e 04 00 00       	push   $0x42e
f0102454:	68 39 70 10 f0       	push   $0xf0107039
f0102459:	e8 e2 db ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010245e:	89 da                	mov    %ebx,%edx
f0102460:	09 f2                	or     %esi,%edx
f0102462:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102468:	74 19                	je     f0102483 <mem_init+0x1168>
f010246a:	68 6c 79 10 f0       	push   $0xf010796c
f010246f:	68 5f 70 10 f0       	push   $0xf010705f
f0102474:	68 30 04 00 00       	push   $0x430
f0102479:	68 39 70 10 f0       	push   $0xf0107039
f010247e:	e8 bd db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102483:	39 c6                	cmp    %eax,%esi
f0102485:	73 19                	jae    f01024a0 <mem_init+0x1185>
f0102487:	68 fd 72 10 f0       	push   $0xf01072fd
f010248c:	68 5f 70 10 f0       	push   $0xf010705f
f0102491:	68 32 04 00 00       	push   $0x432
f0102496:	68 39 70 10 f0       	push   $0xf0107039
f010249b:	e8 a0 db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024a0:	8b 3d b0 1e 2a f0    	mov    0xf02a1eb0,%edi
f01024a6:	89 da                	mov    %ebx,%edx
f01024a8:	89 f8                	mov    %edi,%eax
f01024aa:	e8 c3 e6 ff ff       	call   f0100b72 <check_va2pa>
f01024af:	85 c0                	test   %eax,%eax
f01024b1:	74 19                	je     f01024cc <mem_init+0x11b1>
f01024b3:	68 94 79 10 f0       	push   $0xf0107994
f01024b8:	68 5f 70 10 f0       	push   $0xf010705f
f01024bd:	68 34 04 00 00       	push   $0x434
f01024c2:	68 39 70 10 f0       	push   $0xf0107039
f01024c7:	e8 74 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024cc:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024d5:	89 c2                	mov    %eax,%edx
f01024d7:	89 f8                	mov    %edi,%eax
f01024d9:	e8 94 e6 ff ff       	call   f0100b72 <check_va2pa>
f01024de:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024e3:	74 19                	je     f01024fe <mem_init+0x11e3>
f01024e5:	68 b8 79 10 f0       	push   $0xf01079b8
f01024ea:	68 5f 70 10 f0       	push   $0xf010705f
f01024ef:	68 35 04 00 00       	push   $0x435
f01024f4:	68 39 70 10 f0       	push   $0xf0107039
f01024f9:	e8 42 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024fe:	89 f2                	mov    %esi,%edx
f0102500:	89 f8                	mov    %edi,%eax
f0102502:	e8 6b e6 ff ff       	call   f0100b72 <check_va2pa>
f0102507:	85 c0                	test   %eax,%eax
f0102509:	74 19                	je     f0102524 <mem_init+0x1209>
f010250b:	68 e8 79 10 f0       	push   $0xf01079e8
f0102510:	68 5f 70 10 f0       	push   $0xf010705f
f0102515:	68 36 04 00 00       	push   $0x436
f010251a:	68 39 70 10 f0       	push   $0xf0107039
f010251f:	e8 1c db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102524:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010252a:	89 f8                	mov    %edi,%eax
f010252c:	e8 41 e6 ff ff       	call   f0100b72 <check_va2pa>
f0102531:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102534:	74 19                	je     f010254f <mem_init+0x1234>
f0102536:	68 0c 7a 10 f0       	push   $0xf0107a0c
f010253b:	68 5f 70 10 f0       	push   $0xf010705f
f0102540:	68 37 04 00 00       	push   $0x437
f0102545:	68 39 70 10 f0       	push   $0xf0107039
f010254a:	e8 f1 da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010254f:	83 ec 04             	sub    $0x4,%esp
f0102552:	6a 00                	push   $0x0
f0102554:	53                   	push   %ebx
f0102555:	57                   	push   %edi
f0102556:	e8 02 eb ff ff       	call   f010105d <pgdir_walk>
f010255b:	83 c4 10             	add    $0x10,%esp
f010255e:	f6 00 1a             	testb  $0x1a,(%eax)
f0102561:	75 19                	jne    f010257c <mem_init+0x1261>
f0102563:	68 38 7a 10 f0       	push   $0xf0107a38
f0102568:	68 5f 70 10 f0       	push   $0xf010705f
f010256d:	68 39 04 00 00       	push   $0x439
f0102572:	68 39 70 10 f0       	push   $0xf0107039
f0102577:	e8 c4 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010257c:	83 ec 04             	sub    $0x4,%esp
f010257f:	6a 00                	push   $0x0
f0102581:	53                   	push   %ebx
f0102582:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0102588:	e8 d0 ea ff ff       	call   f010105d <pgdir_walk>
f010258d:	8b 00                	mov    (%eax),%eax
f010258f:	83 c4 10             	add    $0x10,%esp
f0102592:	83 e0 04             	and    $0x4,%eax
f0102595:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102598:	74 19                	je     f01025b3 <mem_init+0x1298>
f010259a:	68 7c 7a 10 f0       	push   $0xf0107a7c
f010259f:	68 5f 70 10 f0       	push   $0xf010705f
f01025a4:	68 3a 04 00 00       	push   $0x43a
f01025a9:	68 39 70 10 f0       	push   $0xf0107039
f01025ae:	e8 8d da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01025b3:	83 ec 04             	sub    $0x4,%esp
f01025b6:	6a 00                	push   $0x0
f01025b8:	53                   	push   %ebx
f01025b9:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f01025bf:	e8 99 ea ff ff       	call   f010105d <pgdir_walk>
f01025c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01025ca:	83 c4 0c             	add    $0xc,%esp
f01025cd:	6a 00                	push   $0x0
f01025cf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01025d2:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f01025d8:	e8 80 ea ff ff       	call   f010105d <pgdir_walk>
f01025dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01025e3:	83 c4 0c             	add    $0xc,%esp
f01025e6:	6a 00                	push   $0x0
f01025e8:	56                   	push   %esi
f01025e9:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f01025ef:	e8 69 ea ff ff       	call   f010105d <pgdir_walk>
f01025f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01025fa:	c7 04 24 0f 73 10 f0 	movl   $0xf010730f,(%esp)
f0102601:	e8 e6 10 00 00       	call   f01036ec <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE

	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES , ROUNDUP((sizeof(struct PageInfo ) * npages),PGSIZE), PADDR(pages), PTE_U | PTE_P);
f0102606:	a1 b4 1e 2a f0       	mov    0xf02a1eb4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010260b:	83 c4 10             	add    $0x10,%esp
f010260e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102613:	77 15                	ja     f010262a <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102615:	50                   	push   %eax
f0102616:	68 c8 6a 10 f0       	push   $0xf0106ac8
f010261b:	68 c6 00 00 00       	push   $0xc6
f0102620:	68 39 70 10 f0       	push   $0xf0107039
f0102625:	e8 16 da ff ff       	call   f0100040 <_panic>
f010262a:	8b 15 ac 1e 2a f0    	mov    0xf02a1eac,%edx
f0102630:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102637:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010263d:	83 ec 08             	sub    $0x8,%esp
f0102640:	6a 05                	push   $0x5
f0102642:	05 00 00 00 10       	add    $0x10000000,%eax
f0102647:	50                   	push   %eax
f0102648:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010264d:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f0102652:	e8 9b ea ff ff       	call   f01010f2 <boot_map_region>
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	//////////////////////////////////////////////////////////////////////
	// Your code goes here: 
	boot_map_region(kern_pgdir, UENVS, ROUNDUP((sizeof(struct Env) * NENV), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f0102657:	a1 48 12 2a f0       	mov    0xf02a1248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010265c:	83 c4 10             	add    $0x10,%esp
f010265f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102664:	77 15                	ja     f010267b <mem_init+0x1360>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102666:	50                   	push   %eax
f0102667:	68 c8 6a 10 f0       	push   $0xf0106ac8
f010266c:	68 d2 00 00 00       	push   $0xd2
f0102671:	68 39 70 10 f0       	push   $0xf0107039
f0102676:	e8 c5 d9 ff ff       	call   f0100040 <_panic>
f010267b:	83 ec 08             	sub    $0x8,%esp
f010267e:	6a 05                	push   $0x5
f0102680:	05 00 00 00 10       	add    $0x10000000,%eax
f0102685:	50                   	push   %eax
f0102686:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010268b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102690:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f0102695:	e8 58 ea ff ff       	call   f01010f2 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010269a:	83 c4 10             	add    $0x10,%esp
f010269d:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01026a2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026a7:	77 15                	ja     f01026be <mem_init+0x13a3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a9:	50                   	push   %eax
f01026aa:	68 c8 6a 10 f0       	push   $0xf0106ac8
f01026af:	68 df 00 00 00       	push   $0xdf
f01026b4:	68 39 70 10 f0       	push   $0xf0107039
f01026b9:	e8 82 d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE,KSTKSIZE, PADDR(bootstack) ,PTE_W);	
f01026be:	83 ec 08             	sub    $0x8,%esp
f01026c1:	6a 02                	push   $0x2
f01026c3:	68 00 90 11 00       	push   $0x119000
f01026c8:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026cd:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026d2:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f01026d7:	e8 16 ea ff ff       	call   f01010f2 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE ,-KERNBASE, 0 ,PTE_W);	
f01026dc:	83 c4 08             	add    $0x8,%esp
f01026df:	6a 02                	push   $0x2
f01026e1:	6a 00                	push   $0x0
f01026e3:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026e8:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026ed:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f01026f2:	e8 fb e9 ff ff       	call   f01010f2 <boot_map_region>
f01026f7:	c7 45 c4 00 30 2a f0 	movl   $0xf02a3000,-0x3c(%ebp)
f01026fe:	83 c4 10             	add    $0x10,%esp
f0102701:	bb 00 30 2a f0       	mov    $0xf02a3000,%ebx
f0102706:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010270b:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102711:	77 15                	ja     f0102728 <mem_init+0x140d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102713:	53                   	push   %ebx
f0102714:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0102719:	68 21 01 00 00       	push   $0x121
f010271e:	68 39 70 10 f0       	push   $0xf0107039
f0102723:	e8 18 d9 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++)
   	{
   		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
       	boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102728:	83 ec 08             	sub    $0x8,%esp
f010272b:	6a 02                	push   $0x2
f010272d:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102733:	50                   	push   %eax
f0102734:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102739:	89 f2                	mov    %esi,%edx
f010273b:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
f0102740:	e8 ad e9 ff ff       	call   f01010f2 <boot_map_region>
f0102745:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010274b:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++)
f0102751:	83 c4 10             	add    $0x10,%esp
f0102754:	b8 00 30 2e f0       	mov    $0xf02e3000,%eax
f0102759:	39 d8                	cmp    %ebx,%eax
f010275b:	75 ae                	jne    f010270b <mem_init+0x13f0>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010275d:	8b 3d b0 1e 2a f0    	mov    0xf02a1eb0,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102763:	a1 ac 1e 2a f0       	mov    0xf02a1eac,%eax
f0102768:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010276b:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102772:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102777:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010277a:	8b 35 b4 1e 2a f0    	mov    0xf02a1eb4,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102780:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102783:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102788:	eb 55                	jmp    f01027df <mem_init+0x14c4>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010278a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102790:	89 f8                	mov    %edi,%eax
f0102792:	e8 db e3 ff ff       	call   f0100b72 <check_va2pa>
f0102797:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010279e:	77 15                	ja     f01027b5 <mem_init+0x149a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a0:	56                   	push   %esi
f01027a1:	68 c8 6a 10 f0       	push   $0xf0106ac8
f01027a6:	68 52 03 00 00       	push   $0x352
f01027ab:	68 39 70 10 f0       	push   $0xf0107039
f01027b0:	e8 8b d8 ff ff       	call   f0100040 <_panic>
f01027b5:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01027bc:	39 c2                	cmp    %eax,%edx
f01027be:	74 19                	je     f01027d9 <mem_init+0x14be>
f01027c0:	68 b0 7a 10 f0       	push   $0xf0107ab0
f01027c5:	68 5f 70 10 f0       	push   $0xf010705f
f01027ca:	68 52 03 00 00       	push   $0x352
f01027cf:	68 39 70 10 f0       	push   $0xf0107039
f01027d4:	e8 67 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027df:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01027e2:	77 a6                	ja     f010278a <mem_init+0x146f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027e4:	8b 35 48 12 2a f0    	mov    0xf02a1248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027ea:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01027ed:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01027f2:	89 da                	mov    %ebx,%edx
f01027f4:	89 f8                	mov    %edi,%eax
f01027f6:	e8 77 e3 ff ff       	call   f0100b72 <check_va2pa>
f01027fb:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102802:	77 15                	ja     f0102819 <mem_init+0x14fe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102804:	56                   	push   %esi
f0102805:	68 c8 6a 10 f0       	push   $0xf0106ac8
f010280a:	68 57 03 00 00       	push   $0x357
f010280f:	68 39 70 10 f0       	push   $0xf0107039
f0102814:	e8 27 d8 ff ff       	call   f0100040 <_panic>
f0102819:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102820:	39 d0                	cmp    %edx,%eax
f0102822:	74 19                	je     f010283d <mem_init+0x1522>
f0102824:	68 e4 7a 10 f0       	push   $0xf0107ae4
f0102829:	68 5f 70 10 f0       	push   $0xf010705f
f010282e:	68 57 03 00 00       	push   $0x357
f0102833:	68 39 70 10 f0       	push   $0xf0107039
f0102838:	e8 03 d8 ff ff       	call   f0100040 <_panic>
f010283d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102843:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102849:	75 a7                	jne    f01027f2 <mem_init+0x14d7>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010284b:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010284e:	c1 e6 0c             	shl    $0xc,%esi
f0102851:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102856:	eb 30                	jmp    f0102888 <mem_init+0x156d>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102858:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010285e:	89 f8                	mov    %edi,%eax
f0102860:	e8 0d e3 ff ff       	call   f0100b72 <check_va2pa>
f0102865:	39 c3                	cmp    %eax,%ebx
f0102867:	74 19                	je     f0102882 <mem_init+0x1567>
f0102869:	68 18 7b 10 f0       	push   $0xf0107b18
f010286e:	68 5f 70 10 f0       	push   $0xf010705f
f0102873:	68 5b 03 00 00       	push   $0x35b
f0102878:	68 39 70 10 f0       	push   $0xf0107039
f010287d:	e8 be d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102882:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102888:	39 f3                	cmp    %esi,%ebx
f010288a:	72 cc                	jb     f0102858 <mem_init+0x153d>
f010288c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102891:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102894:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102897:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010289a:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01028a0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01028a3:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01028a5:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01028a8:	05 00 80 00 20       	add    $0x20008000,%eax
f01028ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028b0:	89 da                	mov    %ebx,%edx
f01028b2:	89 f8                	mov    %edi,%eax
f01028b4:	e8 b9 e2 ff ff       	call   f0100b72 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028b9:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028bf:	77 15                	ja     f01028d6 <mem_init+0x15bb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028c1:	56                   	push   %esi
f01028c2:	68 c8 6a 10 f0       	push   $0xf0106ac8
f01028c7:	68 63 03 00 00       	push   $0x363
f01028cc:	68 39 70 10 f0       	push   $0xf0107039
f01028d1:	e8 6a d7 ff ff       	call   f0100040 <_panic>
f01028d6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01028d9:	8d 94 0b 00 30 2a f0 	lea    -0xfd5d000(%ebx,%ecx,1),%edx
f01028e0:	39 d0                	cmp    %edx,%eax
f01028e2:	74 19                	je     f01028fd <mem_init+0x15e2>
f01028e4:	68 40 7b 10 f0       	push   $0xf0107b40
f01028e9:	68 5f 70 10 f0       	push   $0xf010705f
f01028ee:	68 63 03 00 00       	push   $0x363
f01028f3:	68 39 70 10 f0       	push   $0xf0107039
f01028f8:	e8 43 d7 ff ff       	call   f0100040 <_panic>
f01028fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102903:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102906:	75 a8                	jne    f01028b0 <mem_init+0x1595>
f0102908:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010290b:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102911:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102914:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102916:	89 da                	mov    %ebx,%edx
f0102918:	89 f8                	mov    %edi,%eax
f010291a:	e8 53 e2 ff ff       	call   f0100b72 <check_va2pa>
f010291f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102922:	74 19                	je     f010293d <mem_init+0x1622>
f0102924:	68 88 7b 10 f0       	push   $0xf0107b88
f0102929:	68 5f 70 10 f0       	push   $0xf010705f
f010292e:	68 65 03 00 00       	push   $0x365
f0102933:	68 39 70 10 f0       	push   $0xf0107039
f0102938:	e8 03 d7 ff ff       	call   f0100040 <_panic>
f010293d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102943:	39 de                	cmp    %ebx,%esi
f0102945:	75 cf                	jne    f0102916 <mem_init+0x15fb>
f0102947:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010294a:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102951:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102958:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010295e:	81 fe 00 30 2e f0    	cmp    $0xf02e3000,%esi
f0102964:	0f 85 2d ff ff ff    	jne    f0102897 <mem_init+0x157c>
f010296a:	b8 00 00 00 00       	mov    $0x0,%eax
f010296f:	eb 2a                	jmp    f010299b <mem_init+0x1680>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102971:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102977:	83 fa 04             	cmp    $0x4,%edx
f010297a:	77 1f                	ja     f010299b <mem_init+0x1680>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010297c:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102980:	75 7e                	jne    f0102a00 <mem_init+0x16e5>
f0102982:	68 28 73 10 f0       	push   $0xf0107328
f0102987:	68 5f 70 10 f0       	push   $0xf010705f
f010298c:	68 70 03 00 00       	push   $0x370
f0102991:	68 39 70 10 f0       	push   $0xf0107039
f0102996:	e8 a5 d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010299b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029a0:	76 3f                	jbe    f01029e1 <mem_init+0x16c6>
				assert(pgdir[i] & PTE_P);
f01029a2:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01029a5:	f6 c2 01             	test   $0x1,%dl
f01029a8:	75 19                	jne    f01029c3 <mem_init+0x16a8>
f01029aa:	68 28 73 10 f0       	push   $0xf0107328
f01029af:	68 5f 70 10 f0       	push   $0xf010705f
f01029b4:	68 74 03 00 00       	push   $0x374
f01029b9:	68 39 70 10 f0       	push   $0xf0107039
f01029be:	e8 7d d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01029c3:	f6 c2 02             	test   $0x2,%dl
f01029c6:	75 38                	jne    f0102a00 <mem_init+0x16e5>
f01029c8:	68 39 73 10 f0       	push   $0xf0107339
f01029cd:	68 5f 70 10 f0       	push   $0xf010705f
f01029d2:	68 75 03 00 00       	push   $0x375
f01029d7:	68 39 70 10 f0       	push   $0xf0107039
f01029dc:	e8 5f d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029e1:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01029e5:	74 19                	je     f0102a00 <mem_init+0x16e5>
f01029e7:	68 4a 73 10 f0       	push   $0xf010734a
f01029ec:	68 5f 70 10 f0       	push   $0xf010705f
f01029f1:	68 77 03 00 00       	push   $0x377
f01029f6:	68 39 70 10 f0       	push   $0xf0107039
f01029fb:	e8 40 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a00:	83 c0 01             	add    $0x1,%eax
f0102a03:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a08:	0f 86 63 ff ff ff    	jbe    f0102971 <mem_init+0x1656>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a0e:	83 ec 0c             	sub    $0xc,%esp
f0102a11:	68 ac 7b 10 f0       	push   $0xf0107bac
f0102a16:	e8 d1 0c 00 00       	call   f01036ec <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a1b:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a20:	83 c4 10             	add    $0x10,%esp
f0102a23:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a28:	77 15                	ja     f0102a3f <mem_init+0x1724>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a2a:	50                   	push   %eax
f0102a2b:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0102a30:	68 f8 00 00 00       	push   $0xf8
f0102a35:	68 39 70 10 f0       	push   $0xf0107039
f0102a3a:	e8 01 d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a3f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a44:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a47:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a4c:	e8 85 e1 ff ff       	call   f0100bd6 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a51:	0f 20 c0             	mov    %cr0,%eax
f0102a54:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a57:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a5c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a5f:	83 ec 0c             	sub    $0xc,%esp
f0102a62:	6a 00                	push   $0x0
f0102a64:	e8 1b e5 ff ff       	call   f0100f84 <page_alloc>
f0102a69:	89 c3                	mov    %eax,%ebx
f0102a6b:	83 c4 10             	add    $0x10,%esp
f0102a6e:	85 c0                	test   %eax,%eax
f0102a70:	75 19                	jne    f0102a8b <mem_init+0x1770>
f0102a72:	68 34 71 10 f0       	push   $0xf0107134
f0102a77:	68 5f 70 10 f0       	push   $0xf010705f
f0102a7c:	68 4f 04 00 00       	push   $0x44f
f0102a81:	68 39 70 10 f0       	push   $0xf0107039
f0102a86:	e8 b5 d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a8b:	83 ec 0c             	sub    $0xc,%esp
f0102a8e:	6a 00                	push   $0x0
f0102a90:	e8 ef e4 ff ff       	call   f0100f84 <page_alloc>
f0102a95:	89 c7                	mov    %eax,%edi
f0102a97:	83 c4 10             	add    $0x10,%esp
f0102a9a:	85 c0                	test   %eax,%eax
f0102a9c:	75 19                	jne    f0102ab7 <mem_init+0x179c>
f0102a9e:	68 4a 71 10 f0       	push   $0xf010714a
f0102aa3:	68 5f 70 10 f0       	push   $0xf010705f
f0102aa8:	68 50 04 00 00       	push   $0x450
f0102aad:	68 39 70 10 f0       	push   $0xf0107039
f0102ab2:	e8 89 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ab7:	83 ec 0c             	sub    $0xc,%esp
f0102aba:	6a 00                	push   $0x0
f0102abc:	e8 c3 e4 ff ff       	call   f0100f84 <page_alloc>
f0102ac1:	89 c6                	mov    %eax,%esi
f0102ac3:	83 c4 10             	add    $0x10,%esp
f0102ac6:	85 c0                	test   %eax,%eax
f0102ac8:	75 19                	jne    f0102ae3 <mem_init+0x17c8>
f0102aca:	68 60 71 10 f0       	push   $0xf0107160
f0102acf:	68 5f 70 10 f0       	push   $0xf010705f
f0102ad4:	68 51 04 00 00       	push   $0x451
f0102ad9:	68 39 70 10 f0       	push   $0xf0107039
f0102ade:	e8 5d d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102ae3:	83 ec 0c             	sub    $0xc,%esp
f0102ae6:	53                   	push   %ebx
f0102ae7:	e8 0f e5 ff ff       	call   f0100ffb <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aec:	89 f8                	mov    %edi,%eax
f0102aee:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0102af4:	c1 f8 03             	sar    $0x3,%eax
f0102af7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102afa:	89 c2                	mov    %eax,%edx
f0102afc:	c1 ea 0c             	shr    $0xc,%edx
f0102aff:	83 c4 10             	add    $0x10,%esp
f0102b02:	3b 15 ac 1e 2a f0    	cmp    0xf02a1eac,%edx
f0102b08:	72 12                	jb     f0102b1c <mem_init+0x1801>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b0a:	50                   	push   %eax
f0102b0b:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0102b10:	6a 58                	push   $0x58
f0102b12:	68 45 70 10 f0       	push   $0xf0107045
f0102b17:	e8 24 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b1c:	83 ec 04             	sub    $0x4,%esp
f0102b1f:	68 00 10 00 00       	push   $0x1000
f0102b24:	6a 01                	push   $0x1
f0102b26:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b2b:	50                   	push   %eax
f0102b2c:	e8 a9 2b 00 00       	call   f01056da <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b31:	89 f0                	mov    %esi,%eax
f0102b33:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0102b39:	c1 f8 03             	sar    $0x3,%eax
f0102b3c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b3f:	89 c2                	mov    %eax,%edx
f0102b41:	c1 ea 0c             	shr    $0xc,%edx
f0102b44:	83 c4 10             	add    $0x10,%esp
f0102b47:	3b 15 ac 1e 2a f0    	cmp    0xf02a1eac,%edx
f0102b4d:	72 12                	jb     f0102b61 <mem_init+0x1846>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b4f:	50                   	push   %eax
f0102b50:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0102b55:	6a 58                	push   $0x58
f0102b57:	68 45 70 10 f0       	push   $0xf0107045
f0102b5c:	e8 df d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b61:	83 ec 04             	sub    $0x4,%esp
f0102b64:	68 00 10 00 00       	push   $0x1000
f0102b69:	6a 02                	push   $0x2
f0102b6b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b70:	50                   	push   %eax
f0102b71:	e8 64 2b 00 00       	call   f01056da <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b76:	6a 02                	push   $0x2
f0102b78:	68 00 10 00 00       	push   $0x1000
f0102b7d:	57                   	push   %edi
f0102b7e:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0102b84:	e8 bd e6 ff ff       	call   f0101246 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b89:	83 c4 20             	add    $0x20,%esp
f0102b8c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b91:	74 19                	je     f0102bac <mem_init+0x1891>
f0102b93:	68 31 72 10 f0       	push   $0xf0107231
f0102b98:	68 5f 70 10 f0       	push   $0xf010705f
f0102b9d:	68 56 04 00 00       	push   $0x456
f0102ba2:	68 39 70 10 f0       	push   $0xf0107039
f0102ba7:	e8 94 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bac:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bb3:	01 01 01 
f0102bb6:	74 19                	je     f0102bd1 <mem_init+0x18b6>
f0102bb8:	68 cc 7b 10 f0       	push   $0xf0107bcc
f0102bbd:	68 5f 70 10 f0       	push   $0xf010705f
f0102bc2:	68 57 04 00 00       	push   $0x457
f0102bc7:	68 39 70 10 f0       	push   $0xf0107039
f0102bcc:	e8 6f d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bd1:	6a 02                	push   $0x2
f0102bd3:	68 00 10 00 00       	push   $0x1000
f0102bd8:	56                   	push   %esi
f0102bd9:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0102bdf:	e8 62 e6 ff ff       	call   f0101246 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102be4:	83 c4 10             	add    $0x10,%esp
f0102be7:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bee:	02 02 02 
f0102bf1:	74 19                	je     f0102c0c <mem_init+0x18f1>
f0102bf3:	68 f0 7b 10 f0       	push   $0xf0107bf0
f0102bf8:	68 5f 70 10 f0       	push   $0xf010705f
f0102bfd:	68 59 04 00 00       	push   $0x459
f0102c02:	68 39 70 10 f0       	push   $0xf0107039
f0102c07:	e8 34 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c0c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c11:	74 19                	je     f0102c2c <mem_init+0x1911>
f0102c13:	68 53 72 10 f0       	push   $0xf0107253
f0102c18:	68 5f 70 10 f0       	push   $0xf010705f
f0102c1d:	68 5a 04 00 00       	push   $0x45a
f0102c22:	68 39 70 10 f0       	push   $0xf0107039
f0102c27:	e8 14 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c2c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c31:	74 19                	je     f0102c4c <mem_init+0x1931>
f0102c33:	68 bd 72 10 f0       	push   $0xf01072bd
f0102c38:	68 5f 70 10 f0       	push   $0xf010705f
f0102c3d:	68 5b 04 00 00       	push   $0x45b
f0102c42:	68 39 70 10 f0       	push   $0xf0107039
f0102c47:	e8 f4 d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c4c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c53:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c56:	89 f0                	mov    %esi,%eax
f0102c58:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0102c5e:	c1 f8 03             	sar    $0x3,%eax
f0102c61:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c64:	89 c2                	mov    %eax,%edx
f0102c66:	c1 ea 0c             	shr    $0xc,%edx
f0102c69:	3b 15 ac 1e 2a f0    	cmp    0xf02a1eac,%edx
f0102c6f:	72 12                	jb     f0102c83 <mem_init+0x1968>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c71:	50                   	push   %eax
f0102c72:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0102c77:	6a 58                	push   $0x58
f0102c79:	68 45 70 10 f0       	push   $0xf0107045
f0102c7e:	e8 bd d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c83:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c8a:	03 03 03 
f0102c8d:	74 19                	je     f0102ca8 <mem_init+0x198d>
f0102c8f:	68 14 7c 10 f0       	push   $0xf0107c14
f0102c94:	68 5f 70 10 f0       	push   $0xf010705f
f0102c99:	68 5d 04 00 00       	push   $0x45d
f0102c9e:	68 39 70 10 f0       	push   $0xf0107039
f0102ca3:	e8 98 d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ca8:	83 ec 08             	sub    $0x8,%esp
f0102cab:	68 00 10 00 00       	push   $0x1000
f0102cb0:	ff 35 b0 1e 2a f0    	pushl  0xf02a1eb0
f0102cb6:	e8 3d e5 ff ff       	call   f01011f8 <page_remove>
	assert(pp2->pp_ref == 0);
f0102cbb:	83 c4 10             	add    $0x10,%esp
f0102cbe:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102cc3:	74 19                	je     f0102cde <mem_init+0x19c3>
f0102cc5:	68 8b 72 10 f0       	push   $0xf010728b
f0102cca:	68 5f 70 10 f0       	push   $0xf010705f
f0102ccf:	68 5f 04 00 00       	push   $0x45f
f0102cd4:	68 39 70 10 f0       	push   $0xf0107039
f0102cd9:	e8 62 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102cde:	8b 0d b0 1e 2a f0    	mov    0xf02a1eb0,%ecx
f0102ce4:	8b 11                	mov    (%ecx),%edx
f0102ce6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102cec:	89 d8                	mov    %ebx,%eax
f0102cee:	2b 05 b4 1e 2a f0    	sub    0xf02a1eb4,%eax
f0102cf4:	c1 f8 03             	sar    $0x3,%eax
f0102cf7:	c1 e0 0c             	shl    $0xc,%eax
f0102cfa:	39 c2                	cmp    %eax,%edx
f0102cfc:	74 19                	je     f0102d17 <mem_init+0x19fc>
f0102cfe:	68 9c 75 10 f0       	push   $0xf010759c
f0102d03:	68 5f 70 10 f0       	push   $0xf010705f
f0102d08:	68 62 04 00 00       	push   $0x462
f0102d0d:	68 39 70 10 f0       	push   $0xf0107039
f0102d12:	e8 29 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d17:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d1d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d22:	74 19                	je     f0102d3d <mem_init+0x1a22>
f0102d24:	68 42 72 10 f0       	push   $0xf0107242
f0102d29:	68 5f 70 10 f0       	push   $0xf010705f
f0102d2e:	68 64 04 00 00       	push   $0x464
f0102d33:	68 39 70 10 f0       	push   $0xf0107039
f0102d38:	e8 03 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d3d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d43:	83 ec 0c             	sub    $0xc,%esp
f0102d46:	53                   	push   %ebx
f0102d47:	e8 af e2 ff ff       	call   f0100ffb <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d4c:	c7 04 24 40 7c 10 f0 	movl   $0xf0107c40,(%esp)
f0102d53:	e8 94 09 00 00       	call   f01036ec <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d58:	83 c4 10             	add    $0x10,%esp
f0102d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d5e:	5b                   	pop    %ebx
f0102d5f:	5e                   	pop    %esi
f0102d60:	5f                   	pop    %edi
f0102d61:	5d                   	pop    %ebp
f0102d62:	c3                   	ret    

f0102d63 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d63:	55                   	push   %ebp
f0102d64:	89 e5                	mov    %esp,%ebp
f0102d66:	57                   	push   %edi
f0102d67:	56                   	push   %esi
f0102d68:	53                   	push   %ebx
f0102d69:	83 ec 1c             	sub    $0x1c,%esp
f0102d6c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d6f:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	 uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102d72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d75:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d7e:	03 45 10             	add    0x10(%ebp),%eax
f0102d81:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uint32_t i;
    for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102d8e:	eb 43                	jmp    f0102dd3 <user_mem_check+0x70>
        pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102d90:	83 ec 04             	sub    $0x4,%esp
f0102d93:	6a 00                	push   $0x0
f0102d95:	53                   	push   %ebx
f0102d96:	ff 77 60             	pushl  0x60(%edi)
f0102d99:	e8 bf e2 ff ff       	call   f010105d <pgdir_walk>
        if ((i>=ULIM) || !(pte) || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102d9e:	83 c4 10             	add    $0x10,%esp
f0102da1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102da7:	77 10                	ja     f0102db9 <user_mem_check+0x56>
f0102da9:	85 c0                	test   %eax,%eax
f0102dab:	74 0c                	je     f0102db9 <user_mem_check+0x56>
f0102dad:	8b 00                	mov    (%eax),%eax
f0102daf:	a8 01                	test   $0x1,%al
f0102db1:	74 06                	je     f0102db9 <user_mem_check+0x56>
f0102db3:	21 f0                	and    %esi,%eax
f0102db5:	39 c6                	cmp    %eax,%esi
f0102db7:	74 14                	je     f0102dcd <user_mem_check+0x6a>
            user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102db9:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102dbc:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102dc0:	89 1d 3c 12 2a f0    	mov    %ebx,0xf02a123c
            return -E_FAULT;
f0102dc6:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dcb:	eb 10                	jmp    f0102ddd <user_mem_check+0x7a>
{
	// LAB 3: Your code here.
	 uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
    uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
    uint32_t i;
    for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102dcd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102dd3:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102dd6:	72 b8                	jb     f0102d90 <user_mem_check+0x2d>
            user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
            return -E_FAULT;
        }
    }
   // cprintf("user_mem_check success va: %x, len: %x\n", va, len);
    return 0;
f0102dd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102de0:	5b                   	pop    %ebx
f0102de1:	5e                   	pop    %esi
f0102de2:	5f                   	pop    %edi
f0102de3:	5d                   	pop    %ebp
f0102de4:	c3                   	ret    

f0102de5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102de5:	55                   	push   %ebp
f0102de6:	89 e5                	mov    %esp,%ebp
f0102de8:	53                   	push   %ebx
f0102de9:	83 ec 04             	sub    $0x4,%esp
f0102dec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102def:	8b 45 14             	mov    0x14(%ebp),%eax
f0102df2:	83 c8 04             	or     $0x4,%eax
f0102df5:	50                   	push   %eax
f0102df6:	ff 75 10             	pushl  0x10(%ebp)
f0102df9:	ff 75 0c             	pushl  0xc(%ebp)
f0102dfc:	53                   	push   %ebx
f0102dfd:	e8 61 ff ff ff       	call   f0102d63 <user_mem_check>
f0102e02:	83 c4 10             	add    $0x10,%esp
f0102e05:	85 c0                	test   %eax,%eax
f0102e07:	79 21                	jns    f0102e2a <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e09:	83 ec 04             	sub    $0x4,%esp
f0102e0c:	ff 35 3c 12 2a f0    	pushl  0xf02a123c
f0102e12:	ff 73 48             	pushl  0x48(%ebx)
f0102e15:	68 6c 7c 10 f0       	push   $0xf0107c6c
f0102e1a:	e8 cd 08 00 00       	call   f01036ec <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e1f:	89 1c 24             	mov    %ebx,(%esp)
f0102e22:	e8 aa 05 00 00       	call   f01033d1 <env_destroy>
f0102e27:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e2d:	c9                   	leave  
f0102e2e:	c3                   	ret    

f0102e2f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{	
f0102e2f:	55                   	push   %ebp
f0102e30:	89 e5                	mov    %esp,%ebp
f0102e32:	57                   	push   %edi
f0102e33:	56                   	push   %esi
f0102e34:	53                   	push   %ebx
f0102e35:	83 ec 0c             	sub    $0xc,%esp
f0102e38:	89 c7                	mov    %eax,%edi
	
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	void * begin = (void *) ROUNDDOWN(va, PGSIZE);
f0102e3a:	89 d3                	mov    %edx,%ebx
f0102e3c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
 	void * end = (void *) ROUNDUP(va + len, PGSIZE);
f0102e42:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102e49:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (begin; begin < end; begin += PGSIZE) {
f0102e4f:	eb 3d                	jmp    f0102e8e <region_alloc+0x5f>
        struct PageInfo *page = page_alloc(0);    
f0102e51:	83 ec 0c             	sub    $0xc,%esp
f0102e54:	6a 00                	push   $0x0
f0102e56:	e8 29 e1 ff ff       	call   f0100f84 <page_alloc>
        if (!page){ 
f0102e5b:	83 c4 10             	add    $0x10,%esp
f0102e5e:	85 c0                	test   %eax,%eax
f0102e60:	75 17                	jne    f0102e79 <region_alloc+0x4a>
			panic("region_alloc failed");
f0102e62:	83 ec 04             	sub    $0x4,%esp
f0102e65:	68 a1 7c 10 f0       	push   $0xf0107ca1
f0102e6a:	68 2b 01 00 00       	push   $0x12b
f0102e6f:	68 b5 7c 10 f0       	push   $0xf0107cb5
f0102e74:	e8 c7 d1 ff ff       	call   f0100040 <_panic>
		}	
    page_insert(e->env_pgdir, page, begin, PTE_W | PTE_U | PTE_P);
f0102e79:	6a 07                	push   $0x7
f0102e7b:	53                   	push   %ebx
f0102e7c:	50                   	push   %eax
f0102e7d:	ff 77 60             	pushl  0x60(%edi)
f0102e80:	e8 c1 e3 ff ff       	call   f0101246 <page_insert>
	
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	void * begin = (void *) ROUNDDOWN(va, PGSIZE);
 	void * end = (void *) ROUNDUP(va + len, PGSIZE);
	for (begin; begin < end; begin += PGSIZE) {
f0102e85:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e8b:	83 c4 10             	add    $0x10,%esp
f0102e8e:	39 f3                	cmp    %esi,%ebx
f0102e90:	72 bf                	jb     f0102e51 <region_alloc+0x22>
    }
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e95:	5b                   	pop    %ebx
f0102e96:	5e                   	pop    %esi
f0102e97:	5f                   	pop    %edi
f0102e98:	5d                   	pop    %ebp
f0102e99:	c3                   	ret    

f0102e9a <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e9a:	55                   	push   %ebp
f0102e9b:	89 e5                	mov    %esp,%ebp
f0102e9d:	56                   	push   %esi
f0102e9e:	53                   	push   %ebx
f0102e9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ea2:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102ea5:	85 c0                	test   %eax,%eax
f0102ea7:	75 1a                	jne    f0102ec3 <envid2env+0x29>
		*env_store = curenv;
f0102ea9:	e8 4c 2e 00 00       	call   f0105cfa <cpunum>
f0102eae:	6b c0 74             	imul   $0x74,%eax,%eax
f0102eb1:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0102eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102eba:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102ebc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ec1:	eb 70                	jmp    f0102f33 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102ec3:	89 c3                	mov    %eax,%ebx
f0102ec5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102ecb:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102ece:	03 1d 48 12 2a f0    	add    0xf02a1248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102ed4:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102ed8:	74 05                	je     f0102edf <envid2env+0x45>
f0102eda:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102edd:	74 10                	je     f0102eef <envid2env+0x55>
		*env_store = 0;
f0102edf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ee2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ee8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eed:	eb 44                	jmp    f0102f33 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102eef:	84 d2                	test   %dl,%dl
f0102ef1:	74 36                	je     f0102f29 <envid2env+0x8f>
f0102ef3:	e8 02 2e 00 00       	call   f0105cfa <cpunum>
f0102ef8:	6b c0 74             	imul   $0x74,%eax,%eax
f0102efb:	3b 98 28 20 2a f0    	cmp    -0xfd5dfd8(%eax),%ebx
f0102f01:	74 26                	je     f0102f29 <envid2env+0x8f>
f0102f03:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f06:	e8 ef 2d 00 00       	call   f0105cfa <cpunum>
f0102f0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f0e:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0102f14:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f17:	74 10                	je     f0102f29 <envid2env+0x8f>
		*env_store = 0;
f0102f19:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f22:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f27:	eb 0a                	jmp    f0102f33 <envid2env+0x99>
	}

	*env_store = e;
f0102f29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f2c:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f33:	5b                   	pop    %ebx
f0102f34:	5e                   	pop    %esi
f0102f35:	5d                   	pop    %ebp
f0102f36:	c3                   	ret    

f0102f37 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f37:	55                   	push   %ebp
f0102f38:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f3a:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f0102f3f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102f42:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f47:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102f49:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f4b:	b8 10 00 00 00       	mov    $0x10,%eax
f0102f50:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f52:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f54:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f56:	ea 5d 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f5d
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f62:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f65:	5d                   	pop    %ebp
f0102f66:	c3                   	ret    

f0102f67 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f67:	55                   	push   %ebp
f0102f68:	89 e5                	mov    %esp,%ebp
f0102f6a:	56                   	push   %esi
f0102f6b:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	
	for (i = NENV -1; i >= 0; --i) {
		envs[i].env_id = 0;
f0102f6c:	8b 35 48 12 2a f0    	mov    0xf02a1248,%esi
f0102f72:	8b 15 4c 12 2a f0    	mov    0xf02a124c,%edx
f0102f78:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f7e:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f81:	89 c1                	mov    %eax,%ecx
f0102f83:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_parent_id = 0;
f0102f8a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		envs[i].env_type = ENV_TYPE_USER;
f0102f91:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
		envs[i].env_status = ENV_FREE;
f0102f98:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0102f9f:	89 50 44             	mov    %edx,0x44(%eax)
f0102fa2:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];	
f0102fa5:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	
	for (i = NENV -1; i >= 0; --i) {
f0102fa7:	39 d8                	cmp    %ebx,%eax
f0102fa9:	75 d6                	jne    f0102f81 <env_init+0x1a>
f0102fab:	89 35 4c 12 2a f0    	mov    %esi,0xf02a124c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];	
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102fb1:	e8 81 ff ff ff       	call   f0102f37 <env_init_percpu>
}
f0102fb6:	5b                   	pop    %ebx
f0102fb7:	5e                   	pop    %esi
f0102fb8:	5d                   	pop    %ebp
f0102fb9:	c3                   	ret    

f0102fba <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102fba:	55                   	push   %ebp
f0102fbb:	89 e5                	mov    %esp,%ebp
f0102fbd:	56                   	push   %esi
f0102fbe:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102fbf:	8b 1d 4c 12 2a f0    	mov    0xf02a124c,%ebx
f0102fc5:	85 db                	test   %ebx,%ebx
f0102fc7:	0f 84 38 01 00 00    	je     f0103105 <env_alloc+0x14b>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102fcd:	83 ec 0c             	sub    $0xc,%esp
f0102fd0:	6a 01                	push   $0x1
f0102fd2:	e8 ad df ff ff       	call   f0100f84 <page_alloc>
f0102fd7:	83 c4 10             	add    $0x10,%esp
f0102fda:	85 c0                	test   %eax,%eax
f0102fdc:	0f 84 2a 01 00 00    	je     f010310c <env_alloc+0x152>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102fe2:	89 c2                	mov    %eax,%edx
f0102fe4:	2b 15 b4 1e 2a f0    	sub    0xf02a1eb4,%edx
f0102fea:	c1 fa 03             	sar    $0x3,%edx
f0102fed:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ff0:	89 d1                	mov    %edx,%ecx
f0102ff2:	c1 e9 0c             	shr    $0xc,%ecx
f0102ff5:	3b 0d ac 1e 2a f0    	cmp    0xf02a1eac,%ecx
f0102ffb:	72 12                	jb     f010300f <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ffd:	52                   	push   %edx
f0102ffe:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0103003:	6a 58                	push   $0x58
f0103005:	68 45 70 10 f0       	push   $0xf0107045
f010300a:	e8 31 d0 ff ff       	call   f0100040 <_panic>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	   
    e->env_pgdir = (pde_t *) page2kva(p);
f010300f:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103015:	89 53 60             	mov    %edx,0x60(%ebx)
f0103018:	ba ec 0e 00 00       	mov    $0xeec,%edx
    for(i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f010301d:	8b 0d b0 1e 2a f0    	mov    0xf02a1eb0,%ecx
f0103023:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f0103026:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0103029:	89 34 11             	mov    %esi,(%ecx,%edx,1)
f010302c:	83 c2 04             	add    $0x4,%edx
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	   
    e->env_pgdir = (pde_t *) page2kva(p);
    for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f010302f:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0103035:	75 e6                	jne    f010301d <env_alloc+0x63>
		e->env_pgdir[i] = kern_pgdir[i];
	}
	p->pp_ref++; 
f0103037:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010303c:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010303f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103044:	77 15                	ja     f010305b <env_alloc+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103046:	50                   	push   %eax
f0103047:	68 c8 6a 10 f0       	push   $0xf0106ac8
f010304c:	68 cb 00 00 00       	push   $0xcb
f0103051:	68 b5 7c 10 f0       	push   $0xf0107cb5
f0103056:	e8 e5 cf ff ff       	call   f0100040 <_panic>
f010305b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103061:	83 ca 05             	or     $0x5,%edx
f0103064:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010306a:	8b 43 48             	mov    0x48(%ebx),%eax
f010306d:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103072:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103077:	ba 00 10 00 00       	mov    $0x1000,%edx
f010307c:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010307f:	89 da                	mov    %ebx,%edx
f0103081:	2b 15 48 12 2a f0    	sub    0xf02a1248,%edx
f0103087:	c1 fa 02             	sar    $0x2,%edx
f010308a:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103090:	09 d0                	or     %edx,%eax
f0103092:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103095:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103098:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010309b:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030a2:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030a9:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030b0:	83 ec 04             	sub    $0x4,%esp
f01030b3:	6a 44                	push   $0x44
f01030b5:	6a 00                	push   $0x0
f01030b7:	53                   	push   %ebx
f01030b8:	e8 1d 26 00 00       	call   f01056da <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030bd:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01030c3:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01030c9:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01030cf:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030d6:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01030dc:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01030e3:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01030ea:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01030ee:	8b 43 44             	mov    0x44(%ebx),%eax
f01030f1:	a3 4c 12 2a f0       	mov    %eax,0xf02a124c
	*newenv_store = e;
f01030f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01030f9:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01030fb:	83 c4 10             	add    $0x10,%esp
f01030fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103103:	eb 0c                	jmp    f0103111 <env_alloc+0x157>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103105:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010310a:	eb 05                	jmp    f0103111 <env_alloc+0x157>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010310c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103111:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103114:	5b                   	pop    %ebx
f0103115:	5e                   	pop    %esi
f0103116:	5d                   	pop    %ebp
f0103117:	c3                   	ret    

f0103118 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103118:	55                   	push   %ebp
f0103119:	89 e5                	mov    %esp,%ebp
f010311b:	57                   	push   %edi
f010311c:	56                   	push   %esi
f010311d:	53                   	push   %ebx
f010311e:	83 ec 34             	sub    $0x34,%esp
f0103121:	8b 7d 08             	mov    0x8(%ebp),%edi

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env * e;
	int i = env_alloc(&e, 0);
f0103124:	6a 00                	push   $0x0
f0103126:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103129:	50                   	push   %eax
f010312a:	e8 8b fe ff ff       	call   f0102fba <env_alloc>
	if(i < 0){
f010312f:	83 c4 10             	add    $0x10,%esp
f0103132:	85 c0                	test   %eax,%eax
f0103134:	79 17                	jns    f010314d <env_create+0x35>
		panic("env_create failed");
f0103136:	83 ec 04             	sub    $0x4,%esp
f0103139:	68 c0 7c 10 f0       	push   $0xf0107cc0
f010313e:	68 96 01 00 00       	push   $0x196
f0103143:	68 b5 7c 10 f0       	push   $0xf0107cb5
f0103148:	e8 f3 ce ff ff       	call   f0100040 <_panic>
	}
	else{	
		load_icode(e, binary);
f010314d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103150:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103153:	89 fb                	mov    %edi,%ebx
f0103155:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + ELFHDR->e_phnum;
f0103158:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010315c:	c1 e6 05             	shl    $0x5,%esi
f010315f:	01 de                	add    %ebx,%esi
    lcr3(PADDR(e->env_pgdir));
f0103161:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103164:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103169:	77 15                	ja     f0103180 <env_create+0x68>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010316b:	50                   	push   %eax
f010316c:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0103171:	68 6f 01 00 00       	push   $0x16f
f0103176:	68 b5 7c 10 f0       	push   $0xf0107cb5
f010317b:	e8 c0 ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103180:	05 00 00 00 10       	add    $0x10000000,%eax
f0103185:	0f 22 d8             	mov    %eax,%cr3
f0103188:	eb 3d                	jmp    f01031c7 <env_create+0xaf>
  	for (; ph < eph; ph++){
  	
  		if(ph->p_type == ELF_PROG_LOAD){
f010318a:	83 3b 01             	cmpl   $0x1,(%ebx)
f010318d:	75 35                	jne    f01031c4 <env_create+0xac>
  			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f010318f:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103192:	8b 53 08             	mov    0x8(%ebx),%edx
f0103195:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103198:	e8 92 fc ff ff       	call   f0102e2f <region_alloc>
  			memset((void *)ph->p_va,0,ph->p_memsz);
f010319d:	83 ec 04             	sub    $0x4,%esp
f01031a0:	ff 73 14             	pushl  0x14(%ebx)
f01031a3:	6a 00                	push   $0x0
f01031a5:	ff 73 08             	pushl  0x8(%ebx)
f01031a8:	e8 2d 25 00 00       	call   f01056da <memset>
  			memcpy((void *)ph->p_va,(void *)(binary + ph->p_offset),ph->p_filesz);
f01031ad:	83 c4 0c             	add    $0xc,%esp
f01031b0:	ff 73 10             	pushl  0x10(%ebx)
f01031b3:	89 f8                	mov    %edi,%eax
f01031b5:	03 43 04             	add    0x4(%ebx),%eax
f01031b8:	50                   	push   %eax
f01031b9:	ff 73 08             	pushl  0x8(%ebx)
f01031bc:	e8 ce 25 00 00       	call   f010578f <memcpy>
f01031c1:	83 c4 10             	add    $0x10,%esp
	struct Elf *ELFHDR = (struct Elf *) binary;
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    lcr3(PADDR(e->env_pgdir));
  	for (; ph < eph; ph++){
f01031c4:	83 c3 20             	add    $0x20,%ebx
f01031c7:	39 de                	cmp    %ebx,%esi
f01031c9:	77 bf                	ja     f010318a <env_create+0x72>
  			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
  			memset((void *)ph->p_va,0,ph->p_memsz);
  			memcpy((void *)ph->p_va,(void *)(binary + ph->p_offset),ph->p_filesz);
  		}
  	}
  	lcr3(PADDR(kern_pgdir));			
f01031cb:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031d5:	77 15                	ja     f01031ec <env_create+0xd4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031d7:	50                   	push   %eax
f01031d8:	68 c8 6a 10 f0       	push   $0xf0106ac8
f01031dd:	68 78 01 00 00       	push   $0x178
f01031e2:	68 b5 7c 10 f0       	push   $0xf0107cb5
f01031e7:	e8 54 ce ff ff       	call   f0100040 <_panic>
f01031ec:	05 00 00 00 10       	add    $0x10000000,%eax
f01031f1:	0f 22 d8             	mov    %eax,%cr3
  	
  	
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01031f4:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01031f9:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01031fe:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103201:	89 f0                	mov    %esi,%eax
f0103203:	e8 27 fc ff ff       	call   f0102e2f <region_alloc>
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103208:	8b 47 18             	mov    0x18(%edi),%eax
f010320b:	89 46 30             	mov    %eax,0x30(%esi)
	if(i < 0){
		panic("env_create failed");
	}
	else{	
		load_icode(e, binary);
		e->env_type = type;
f010320e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103214:	89 48 50             	mov    %ecx,0x50(%eax)
	}	
	
	if (type == ENV_TYPE_FS) {
f0103217:	83 f9 01             	cmp    $0x1,%ecx
f010321a:	75 07                	jne    f0103223 <env_create+0x10b>
        e->env_tf.tf_eflags |= FL_IOPL_3;
f010321c:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
    }
}
f0103223:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103226:	5b                   	pop    %ebx
f0103227:	5e                   	pop    %esi
f0103228:	5f                   	pop    %edi
f0103229:	5d                   	pop    %ebp
f010322a:	c3                   	ret    

f010322b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010322b:	55                   	push   %ebp
f010322c:	89 e5                	mov    %esp,%ebp
f010322e:	57                   	push   %edi
f010322f:	56                   	push   %esi
f0103230:	53                   	push   %ebx
f0103231:	83 ec 1c             	sub    $0x1c,%esp
f0103234:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103237:	e8 be 2a 00 00       	call   f0105cfa <cpunum>
f010323c:	6b c0 74             	imul   $0x74,%eax,%eax
f010323f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103246:	39 b8 28 20 2a f0    	cmp    %edi,-0xfd5dfd8(%eax)
f010324c:	75 30                	jne    f010327e <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f010324e:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103253:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103258:	77 15                	ja     f010326f <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010325a:	50                   	push   %eax
f010325b:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0103260:	68 b0 01 00 00       	push   $0x1b0
f0103265:	68 b5 7c 10 f0       	push   $0xf0107cb5
f010326a:	e8 d1 cd ff ff       	call   f0100040 <_panic>
f010326f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103274:	0f 22 d8             	mov    %eax,%cr3
f0103277:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010327e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103281:	89 d0                	mov    %edx,%eax
f0103283:	c1 e0 02             	shl    $0x2,%eax
f0103286:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103289:	8b 47 60             	mov    0x60(%edi),%eax
f010328c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010328f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103295:	0f 84 a8 00 00 00    	je     f0103343 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010329b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032a1:	89 f0                	mov    %esi,%eax
f01032a3:	c1 e8 0c             	shr    $0xc,%eax
f01032a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032a9:	39 05 ac 1e 2a f0    	cmp    %eax,0xf02a1eac
f01032af:	77 15                	ja     f01032c6 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032b1:	56                   	push   %esi
f01032b2:	68 a4 6a 10 f0       	push   $0xf0106aa4
f01032b7:	68 bf 01 00 00       	push   $0x1bf
f01032bc:	68 b5 7c 10 f0       	push   $0xf0107cb5
f01032c1:	e8 7a cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032c9:	c1 e0 16             	shl    $0x16,%eax
f01032cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032cf:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01032d4:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01032db:	01 
f01032dc:	74 17                	je     f01032f5 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032de:	83 ec 08             	sub    $0x8,%esp
f01032e1:	89 d8                	mov    %ebx,%eax
f01032e3:	c1 e0 0c             	shl    $0xc,%eax
f01032e6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01032e9:	50                   	push   %eax
f01032ea:	ff 77 60             	pushl  0x60(%edi)
f01032ed:	e8 06 df ff ff       	call   f01011f8 <page_remove>
f01032f2:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032f5:	83 c3 01             	add    $0x1,%ebx
f01032f8:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01032fe:	75 d4                	jne    f01032d4 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103300:	8b 47 60             	mov    0x60(%edi),%eax
f0103303:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103306:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010330d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103310:	3b 05 ac 1e 2a f0    	cmp    0xf02a1eac,%eax
f0103316:	72 14                	jb     f010332c <env_free+0x101>
		panic("pa2page called with invalid pa");
f0103318:	83 ec 04             	sub    $0x4,%esp
f010331b:	68 44 74 10 f0       	push   $0xf0107444
f0103320:	6a 51                	push   $0x51
f0103322:	68 45 70 10 f0       	push   $0xf0107045
f0103327:	e8 14 cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010332c:	83 ec 0c             	sub    $0xc,%esp
f010332f:	a1 b4 1e 2a f0       	mov    0xf02a1eb4,%eax
f0103334:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103337:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010333a:	50                   	push   %eax
f010333b:	e8 f6 dc ff ff       	call   f0101036 <page_decref>
f0103340:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103343:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103347:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010334a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010334f:	0f 85 29 ff ff ff    	jne    f010327e <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103355:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103358:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010335d:	77 15                	ja     f0103374 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010335f:	50                   	push   %eax
f0103360:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0103365:	68 cd 01 00 00       	push   $0x1cd
f010336a:	68 b5 7c 10 f0       	push   $0xf0107cb5
f010336f:	e8 cc cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103374:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010337b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103380:	c1 e8 0c             	shr    $0xc,%eax
f0103383:	3b 05 ac 1e 2a f0    	cmp    0xf02a1eac,%eax
f0103389:	72 14                	jb     f010339f <env_free+0x174>
		panic("pa2page called with invalid pa");
f010338b:	83 ec 04             	sub    $0x4,%esp
f010338e:	68 44 74 10 f0       	push   $0xf0107444
f0103393:	6a 51                	push   $0x51
f0103395:	68 45 70 10 f0       	push   $0xf0107045
f010339a:	e8 a1 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010339f:	83 ec 0c             	sub    $0xc,%esp
f01033a2:	8b 15 b4 1e 2a f0    	mov    0xf02a1eb4,%edx
f01033a8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01033ab:	50                   	push   %eax
f01033ac:	e8 85 dc ff ff       	call   f0101036 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033b1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033b8:	a1 4c 12 2a f0       	mov    0xf02a124c,%eax
f01033bd:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033c0:	89 3d 4c 12 2a f0    	mov    %edi,0xf02a124c
}
f01033c6:	83 c4 10             	add    $0x10,%esp
f01033c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033cc:	5b                   	pop    %ebx
f01033cd:	5e                   	pop    %esi
f01033ce:	5f                   	pop    %edi
f01033cf:	5d                   	pop    %ebp
f01033d0:	c3                   	ret    

f01033d1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01033d1:	55                   	push   %ebp
f01033d2:	89 e5                	mov    %esp,%ebp
f01033d4:	53                   	push   %ebx
f01033d5:	83 ec 04             	sub    $0x4,%esp
f01033d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01033db:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01033df:	75 19                	jne    f01033fa <env_destroy+0x29>
f01033e1:	e8 14 29 00 00       	call   f0105cfa <cpunum>
f01033e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e9:	3b 98 28 20 2a f0    	cmp    -0xfd5dfd8(%eax),%ebx
f01033ef:	74 09                	je     f01033fa <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01033f1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01033f8:	eb 33                	jmp    f010342d <env_destroy+0x5c>
	}

	env_free(e);
f01033fa:	83 ec 0c             	sub    $0xc,%esp
f01033fd:	53                   	push   %ebx
f01033fe:	e8 28 fe ff ff       	call   f010322b <env_free>

	if (curenv == e) {
f0103403:	e8 f2 28 00 00       	call   f0105cfa <cpunum>
f0103408:	6b c0 74             	imul   $0x74,%eax,%eax
f010340b:	83 c4 10             	add    $0x10,%esp
f010340e:	3b 98 28 20 2a f0    	cmp    -0xfd5dfd8(%eax),%ebx
f0103414:	75 17                	jne    f010342d <env_destroy+0x5c>
		curenv = NULL;
f0103416:	e8 df 28 00 00       	call   f0105cfa <cpunum>
f010341b:	6b c0 74             	imul   $0x74,%eax,%eax
f010341e:	c7 80 28 20 2a f0 00 	movl   $0x0,-0xfd5dfd8(%eax)
f0103425:	00 00 00 
		sched_yield();
f0103428:	e8 e0 10 00 00       	call   f010450d <sched_yield>
	}
}
f010342d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103430:	c9                   	leave  
f0103431:	c3                   	ret    

f0103432 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103432:	55                   	push   %ebp
f0103433:	89 e5                	mov    %esp,%ebp
f0103435:	53                   	push   %ebx
f0103436:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103439:	e8 bc 28 00 00       	call   f0105cfa <cpunum>
f010343e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103441:	8b 98 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%ebx
f0103447:	e8 ae 28 00 00       	call   f0105cfa <cpunum>
f010344c:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f010344f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103452:	61                   	popa   
f0103453:	07                   	pop    %es
f0103454:	1f                   	pop    %ds
f0103455:	83 c4 08             	add    $0x8,%esp
f0103458:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103459:	83 ec 04             	sub    $0x4,%esp
f010345c:	68 d2 7c 10 f0       	push   $0xf0107cd2
f0103461:	68 03 02 00 00       	push   $0x203
f0103466:	68 b5 7c 10 f0       	push   $0xf0107cb5
f010346b:	e8 d0 cb ff ff       	call   f0100040 <_panic>

f0103470 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103470:	55                   	push   %ebp
f0103471:	89 e5                	mov    %esp,%ebp
f0103473:	53                   	push   %ebx
f0103474:	83 ec 04             	sub    $0x4,%esp
f0103477:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f010347a:	e8 7b 28 00 00       	call   f0105cfa <cpunum>
f010347f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103482:	39 98 28 20 2a f0    	cmp    %ebx,-0xfd5dfd8(%eax)
f0103488:	0f 84 a4 00 00 00    	je     f0103532 <env_run+0xc2>
		if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f010348e:	e8 67 28 00 00       	call   f0105cfa <cpunum>
f0103493:	6b c0 74             	imul   $0x74,%eax,%eax
f0103496:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f010349d:	74 29                	je     f01034c8 <env_run+0x58>
f010349f:	e8 56 28 00 00       	call   f0105cfa <cpunum>
f01034a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01034a7:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01034ad:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01034b1:	75 15                	jne    f01034c8 <env_run+0x58>
    	{
     		curenv->env_status = ENV_RUNNABLE;
f01034b3:	e8 42 28 00 00       	call   f0105cfa <cpunum>
f01034b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01034bb:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01034c1:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    	}
    	curenv = e;
f01034c8:	e8 2d 28 00 00       	call   f0105cfa <cpunum>
f01034cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d0:	89 98 28 20 2a f0    	mov    %ebx,-0xfd5dfd8(%eax)
    	curenv->env_status = ENV_RUNNING;
f01034d6:	e8 1f 28 00 00       	call   f0105cfa <cpunum>
f01034db:	6b c0 74             	imul   $0x74,%eax,%eax
f01034de:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01034e4:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f01034eb:	e8 0a 28 00 00       	call   f0105cfa <cpunum>
f01034f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01034f3:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01034f9:	83 40 58 01          	addl   $0x1,0x58(%eax)
    	lcr3(PADDR(curenv->env_pgdir));
f01034fd:	e8 f8 27 00 00       	call   f0105cfa <cpunum>
f0103502:	6b c0 74             	imul   $0x74,%eax,%eax
f0103505:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f010350b:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010350e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103513:	77 15                	ja     f010352a <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103515:	50                   	push   %eax
f0103516:	68 c8 6a 10 f0       	push   $0xf0106ac8
f010351b:	68 29 02 00 00       	push   $0x229
f0103520:	68 b5 7c 10 f0       	push   $0xf0107cb5
f0103525:	e8 16 cb ff ff       	call   f0100040 <_panic>
f010352a:	05 00 00 00 10       	add    $0x10000000,%eax
f010352f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103532:	83 ec 0c             	sub    $0xc,%esp
f0103535:	68 c0 33 12 f0       	push   $0xf01233c0
f010353a:	e8 c6 2a 00 00       	call   f0106005 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010353f:	f3 90                	pause  
    }	
    unlock_kernel();
 	env_pop_tf(&(curenv->env_tf));
f0103541:	e8 b4 27 00 00       	call   f0105cfa <cpunum>
f0103546:	83 c4 04             	add    $0x4,%esp
f0103549:	6b c0 74             	imul   $0x74,%eax,%eax
f010354c:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0103552:	e8 db fe ff ff       	call   f0103432 <env_pop_tf>

f0103557 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103557:	55                   	push   %ebp
f0103558:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010355a:	ba 70 00 00 00       	mov    $0x70,%edx
f010355f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103562:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103563:	ba 71 00 00 00       	mov    $0x71,%edx
f0103568:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103569:	0f b6 c0             	movzbl %al,%eax
}
f010356c:	5d                   	pop    %ebp
f010356d:	c3                   	ret    

f010356e <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010356e:	55                   	push   %ebp
f010356f:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103571:	ba 70 00 00 00       	mov    $0x70,%edx
f0103576:	8b 45 08             	mov    0x8(%ebp),%eax
f0103579:	ee                   	out    %al,(%dx)
f010357a:	ba 71 00 00 00       	mov    $0x71,%edx
f010357f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103582:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103583:	5d                   	pop    %ebp
f0103584:	c3                   	ret    

f0103585 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103585:	55                   	push   %ebp
f0103586:	89 e5                	mov    %esp,%ebp
f0103588:	56                   	push   %esi
f0103589:	53                   	push   %ebx
f010358a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010358d:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f0103593:	80 3d 50 12 2a f0 00 	cmpb   $0x0,0xf02a1250
f010359a:	74 5a                	je     f01035f6 <irq_setmask_8259A+0x71>
f010359c:	89 c6                	mov    %eax,%esi
f010359e:	ba 21 00 00 00       	mov    $0x21,%edx
f01035a3:	ee                   	out    %al,(%dx)
f01035a4:	66 c1 e8 08          	shr    $0x8,%ax
f01035a8:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035ad:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01035ae:	83 ec 0c             	sub    $0xc,%esp
f01035b1:	68 de 7c 10 f0       	push   $0xf0107cde
f01035b6:	e8 31 01 00 00       	call   f01036ec <cprintf>
f01035bb:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01035be:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01035c3:	0f b7 f6             	movzwl %si,%esi
f01035c6:	f7 d6                	not    %esi
f01035c8:	0f a3 de             	bt     %ebx,%esi
f01035cb:	73 11                	jae    f01035de <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01035cd:	83 ec 08             	sub    $0x8,%esp
f01035d0:	53                   	push   %ebx
f01035d1:	68 73 81 10 f0       	push   $0xf0108173
f01035d6:	e8 11 01 00 00       	call   f01036ec <cprintf>
f01035db:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01035de:	83 c3 01             	add    $0x1,%ebx
f01035e1:	83 fb 10             	cmp    $0x10,%ebx
f01035e4:	75 e2                	jne    f01035c8 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01035e6:	83 ec 0c             	sub    $0xc,%esp
f01035e9:	68 26 73 10 f0       	push   $0xf0107326
f01035ee:	e8 f9 00 00 00       	call   f01036ec <cprintf>
f01035f3:	83 c4 10             	add    $0x10,%esp
}
f01035f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035f9:	5b                   	pop    %ebx
f01035fa:	5e                   	pop    %esi
f01035fb:	5d                   	pop    %ebp
f01035fc:	c3                   	ret    

f01035fd <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01035fd:	c6 05 50 12 2a f0 01 	movb   $0x1,0xf02a1250
f0103604:	ba 21 00 00 00       	mov    $0x21,%edx
f0103609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010360e:	ee                   	out    %al,(%dx)
f010360f:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103614:	ee                   	out    %al,(%dx)
f0103615:	ba 20 00 00 00       	mov    $0x20,%edx
f010361a:	b8 11 00 00 00       	mov    $0x11,%eax
f010361f:	ee                   	out    %al,(%dx)
f0103620:	ba 21 00 00 00       	mov    $0x21,%edx
f0103625:	b8 20 00 00 00       	mov    $0x20,%eax
f010362a:	ee                   	out    %al,(%dx)
f010362b:	b8 04 00 00 00       	mov    $0x4,%eax
f0103630:	ee                   	out    %al,(%dx)
f0103631:	b8 03 00 00 00       	mov    $0x3,%eax
f0103636:	ee                   	out    %al,(%dx)
f0103637:	ba a0 00 00 00       	mov    $0xa0,%edx
f010363c:	b8 11 00 00 00       	mov    $0x11,%eax
f0103641:	ee                   	out    %al,(%dx)
f0103642:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103647:	b8 28 00 00 00       	mov    $0x28,%eax
f010364c:	ee                   	out    %al,(%dx)
f010364d:	b8 02 00 00 00       	mov    $0x2,%eax
f0103652:	ee                   	out    %al,(%dx)
f0103653:	b8 01 00 00 00       	mov    $0x1,%eax
f0103658:	ee                   	out    %al,(%dx)
f0103659:	ba 20 00 00 00       	mov    $0x20,%edx
f010365e:	b8 68 00 00 00       	mov    $0x68,%eax
f0103663:	ee                   	out    %al,(%dx)
f0103664:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103669:	ee                   	out    %al,(%dx)
f010366a:	ba a0 00 00 00       	mov    $0xa0,%edx
f010366f:	b8 68 00 00 00       	mov    $0x68,%eax
f0103674:	ee                   	out    %al,(%dx)
f0103675:	b8 0a 00 00 00       	mov    $0xa,%eax
f010367a:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010367b:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0103682:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103686:	74 13                	je     f010369b <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103688:	55                   	push   %ebp
f0103689:	89 e5                	mov    %esp,%ebp
f010368b:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010368e:	0f b7 c0             	movzwl %ax,%eax
f0103691:	50                   	push   %eax
f0103692:	e8 ee fe ff ff       	call   f0103585 <irq_setmask_8259A>
f0103697:	83 c4 10             	add    $0x10,%esp
}
f010369a:	c9                   	leave  
f010369b:	f3 c3                	repz ret 

f010369d <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f010369d:	55                   	push   %ebp
f010369e:	89 e5                	mov    %esp,%ebp
f01036a0:	ba 20 00 00 00       	mov    $0x20,%edx
f01036a5:	b8 20 00 00 00       	mov    $0x20,%eax
f01036aa:	ee                   	out    %al,(%dx)
f01036ab:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036b0:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f01036b1:	5d                   	pop    %ebp
f01036b2:	c3                   	ret    

f01036b3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036b3:	55                   	push   %ebp
f01036b4:	89 e5                	mov    %esp,%ebp
f01036b6:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01036b9:	ff 75 08             	pushl  0x8(%ebp)
f01036bc:	e8 13 d1 ff ff       	call   f01007d4 <cputchar>
	*cnt++;
}
f01036c1:	83 c4 10             	add    $0x10,%esp
f01036c4:	c9                   	leave  
f01036c5:	c3                   	ret    

f01036c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01036c6:	55                   	push   %ebp
f01036c7:	89 e5                	mov    %esp,%ebp
f01036c9:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01036cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036d3:	ff 75 0c             	pushl  0xc(%ebp)
f01036d6:	ff 75 08             	pushl  0x8(%ebp)
f01036d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036dc:	50                   	push   %eax
f01036dd:	68 b3 36 10 f0       	push   $0xf01036b3
f01036e2:	e8 6f 19 00 00       	call   f0105056 <vprintfmt>
	return cnt;
}
f01036e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01036ea:	c9                   	leave  
f01036eb:	c3                   	ret    

f01036ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01036ec:	55                   	push   %ebp
f01036ed:	89 e5                	mov    %esp,%ebp
f01036ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01036f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01036f5:	50                   	push   %eax
f01036f6:	ff 75 08             	pushl  0x8(%ebp)
f01036f9:	e8 c8 ff ff ff       	call   f01036c6 <vcprintf>
	va_end(ap);

	return cnt;
}
f01036fe:	c9                   	leave  
f01036ff:	c3                   	ret    

f0103700 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103700:	55                   	push   %ebp
f0103701:	89 e5                	mov    %esp,%ebp
f0103703:	57                   	push   %edi
f0103704:	56                   	push   %esi
f0103705:	53                   	push   %ebx
f0103706:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f0103709:	e8 ec 25 00 00       	call   f0105cfa <cpunum>
f010370e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103711:	0f b6 b0 20 20 2a f0 	movzbl -0xfd5dfe0(%eax),%esi
f0103718:	89 f0                	mov    %esi,%eax
f010371a:	0f b6 d8             	movzbl %al,%ebx
    
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f010371d:	e8 d8 25 00 00       	call   f0105cfa <cpunum>
f0103722:	6b c0 74             	imul   $0x74,%eax,%eax
f0103725:	89 d9                	mov    %ebx,%ecx
f0103727:	c1 e1 10             	shl    $0x10,%ecx
f010372a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010372f:	29 ca                	sub    %ecx,%edx
f0103731:	89 90 30 20 2a f0    	mov    %edx,-0xfd5dfd0(%eax)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103737:	e8 be 25 00 00       	call   f0105cfa <cpunum>
f010373c:	6b c0 74             	imul   $0x74,%eax,%eax
f010373f:	66 c7 80 34 20 2a f0 	movw   $0x10,-0xfd5dfcc(%eax)
f0103746:	10 00 
	
	// Initialize the TSS slot of the gdt.
	
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103748:	83 c3 05             	add    $0x5,%ebx
f010374b:	e8 aa 25 00 00       	call   f0105cfa <cpunum>
f0103750:	89 c7                	mov    %eax,%edi
f0103752:	e8 a3 25 00 00       	call   f0105cfa <cpunum>
f0103757:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010375a:	e8 9b 25 00 00       	call   f0105cfa <cpunum>
f010375f:	66 c7 04 dd 40 33 12 	movw   $0x67,-0xfedccc0(,%ebx,8)
f0103766:	f0 67 00 
f0103769:	6b ff 74             	imul   $0x74,%edi,%edi
f010376c:	81 c7 2c 20 2a f0    	add    $0xf02a202c,%edi
f0103772:	66 89 3c dd 42 33 12 	mov    %di,-0xfedccbe(,%ebx,8)
f0103779:	f0 
f010377a:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f010377e:	81 c2 2c 20 2a f0    	add    $0xf02a202c,%edx
f0103784:	c1 ea 10             	shr    $0x10,%edx
f0103787:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f010378e:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f0103795:	40 
f0103796:	6b c0 74             	imul   $0x74,%eax,%eax
f0103799:	05 2c 20 2a f0       	add    $0xf02a202c,%eax
f010379e:	c1 e8 18             	shr    $0x18,%eax
f01037a1:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
                    sizeof(struct Taskstate) - 1, 0);
    gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f01037a8:	c6 04 dd 45 33 12 f0 	movb   $0x89,-0xfedccbb(,%ebx,8)
f01037af:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01037b0:	89 f0                	mov    %esi,%eax
f01037b2:	0f b6 f0             	movzbl %al,%esi
f01037b5:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f01037bc:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01037bf:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f01037c4:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0  + (cid << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f01037c7:	83 c4 1c             	add    $0x1c,%esp
f01037ca:	5b                   	pop    %ebx
f01037cb:	5e                   	pop    %esi
f01037cc:	5f                   	pop    %edi
f01037cd:	5d                   	pop    %ebp
f01037ce:	c3                   	ret    

f01037cf <trap_init>:
}


void
trap_init(void)
{
f01037cf:	55                   	push   %ebp
f01037d0:	89 e5                	mov    %esp,%ebp
f01037d2:	83 ec 08             	sub    $0x8,%esp
    extern void th45();
    extern void th46();
    extern void th47();
	// LAB 3: Your code here.
	
	SETGATE(idt[T_DIVIDE], 0, GD_KT, divzero_entry, 0);
f01037d5:	b8 30 43 10 f0       	mov    $0xf0104330,%eax
f01037da:	66 a3 60 12 2a f0    	mov    %ax,0xf02a1260
f01037e0:	66 c7 05 62 12 2a f0 	movw   $0x8,0xf02a1262
f01037e7:	08 00 
f01037e9:	c6 05 64 12 2a f0 00 	movb   $0x0,0xf02a1264
f01037f0:	c6 05 65 12 2a f0 8e 	movb   $0x8e,0xf02a1265
f01037f7:	c1 e8 10             	shr    $0x10,%eax
f01037fa:	66 a3 66 12 2a f0    	mov    %ax,0xf02a1266
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_entry, 0);
f0103800:	b8 3a 43 10 f0       	mov    $0xf010433a,%eax
f0103805:	66 a3 68 12 2a f0    	mov    %ax,0xf02a1268
f010380b:	66 c7 05 6a 12 2a f0 	movw   $0x8,0xf02a126a
f0103812:	08 00 
f0103814:	c6 05 6c 12 2a f0 00 	movb   $0x0,0xf02a126c
f010381b:	c6 05 6d 12 2a f0 8e 	movb   $0x8e,0xf02a126d
f0103822:	c1 e8 10             	shr    $0x10,%eax
f0103825:	66 a3 6e 12 2a f0    	mov    %ax,0xf02a126e
	SETGATE(idt[T_NMI], 0, GD_KT, nmi_entry, 0);
f010382b:	b8 44 43 10 f0       	mov    $0xf0104344,%eax
f0103830:	66 a3 70 12 2a f0    	mov    %ax,0xf02a1270
f0103836:	66 c7 05 72 12 2a f0 	movw   $0x8,0xf02a1272
f010383d:	08 00 
f010383f:	c6 05 74 12 2a f0 00 	movb   $0x0,0xf02a1274
f0103846:	c6 05 75 12 2a f0 8e 	movb   $0x8e,0xf02a1275
f010384d:	c1 e8 10             	shr    $0x10,%eax
f0103850:	66 a3 76 12 2a f0    	mov    %ax,0xf02a1276
	SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt_entry, 3); // changed from 0 to 3 for excerise 6
f0103856:	b8 4e 43 10 f0       	mov    $0xf010434e,%eax
f010385b:	66 a3 78 12 2a f0    	mov    %ax,0xf02a1278
f0103861:	66 c7 05 7a 12 2a f0 	movw   $0x8,0xf02a127a
f0103868:	08 00 
f010386a:	c6 05 7c 12 2a f0 00 	movb   $0x0,0xf02a127c
f0103871:	c6 05 7d 12 2a f0 ee 	movb   $0xee,0xf02a127d
f0103878:	c1 e8 10             	shr    $0x10,%eax
f010387b:	66 a3 7e 12 2a f0    	mov    %ax,0xf02a127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, oflow_entry, 0);
f0103881:	b8 58 43 10 f0       	mov    $0xf0104358,%eax
f0103886:	66 a3 80 12 2a f0    	mov    %ax,0xf02a1280
f010388c:	66 c7 05 82 12 2a f0 	movw   $0x8,0xf02a1282
f0103893:	08 00 
f0103895:	c6 05 84 12 2a f0 00 	movb   $0x0,0xf02a1284
f010389c:	c6 05 85 12 2a f0 8e 	movb   $0x8e,0xf02a1285
f01038a3:	c1 e8 10             	shr    $0x10,%eax
f01038a6:	66 a3 86 12 2a f0    	mov    %ax,0xf02a1286
	SETGATE(idt[T_BOUND], 0, GD_KT, bound_entry, 0);
f01038ac:	b8 62 43 10 f0       	mov    $0xf0104362,%eax
f01038b1:	66 a3 88 12 2a f0    	mov    %ax,0xf02a1288
f01038b7:	66 c7 05 8a 12 2a f0 	movw   $0x8,0xf02a128a
f01038be:	08 00 
f01038c0:	c6 05 8c 12 2a f0 00 	movb   $0x0,0xf02a128c
f01038c7:	c6 05 8d 12 2a f0 8e 	movb   $0x8e,0xf02a128d
f01038ce:	c1 e8 10             	shr    $0x10,%eax
f01038d1:	66 a3 8e 12 2a f0    	mov    %ax,0xf02a128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, illop_entry, 0);
f01038d7:	b8 6c 43 10 f0       	mov    $0xf010436c,%eax
f01038dc:	66 a3 90 12 2a f0    	mov    %ax,0xf02a1290
f01038e2:	66 c7 05 92 12 2a f0 	movw   $0x8,0xf02a1292
f01038e9:	08 00 
f01038eb:	c6 05 94 12 2a f0 00 	movb   $0x0,0xf02a1294
f01038f2:	c6 05 95 12 2a f0 8e 	movb   $0x8e,0xf02a1295
f01038f9:	c1 e8 10             	shr    $0x10,%eax
f01038fc:	66 a3 96 12 2a f0    	mov    %ax,0xf02a1296
	SETGATE(idt[T_DEVICE], 0, GD_KT, device_entry, 0);
f0103902:	b8 76 43 10 f0       	mov    $0xf0104376,%eax
f0103907:	66 a3 98 12 2a f0    	mov    %ax,0xf02a1298
f010390d:	66 c7 05 9a 12 2a f0 	movw   $0x8,0xf02a129a
f0103914:	08 00 
f0103916:	c6 05 9c 12 2a f0 00 	movb   $0x0,0xf02a129c
f010391d:	c6 05 9d 12 2a f0 8e 	movb   $0x8e,0xf02a129d
f0103924:	c1 e8 10             	shr    $0x10,%eax
f0103927:	66 a3 9e 12 2a f0    	mov    %ax,0xf02a129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt_entry, 0);
f010392d:	b8 80 43 10 f0       	mov    $0xf0104380,%eax
f0103932:	66 a3 a0 12 2a f0    	mov    %ax,0xf02a12a0
f0103938:	66 c7 05 a2 12 2a f0 	movw   $0x8,0xf02a12a2
f010393f:	08 00 
f0103941:	c6 05 a4 12 2a f0 00 	movb   $0x0,0xf02a12a4
f0103948:	c6 05 a5 12 2a f0 8e 	movb   $0x8e,0xf02a12a5
f010394f:	c1 e8 10             	shr    $0x10,%eax
f0103952:	66 a3 a6 12 2a f0    	mov    %ax,0xf02a12a6
	SETGATE(idt[T_TSS], 0, GD_KT, tss_entry, 0);
f0103958:	b8 88 43 10 f0       	mov    $0xf0104388,%eax
f010395d:	66 a3 b0 12 2a f0    	mov    %ax,0xf02a12b0
f0103963:	66 c7 05 b2 12 2a f0 	movw   $0x8,0xf02a12b2
f010396a:	08 00 
f010396c:	c6 05 b4 12 2a f0 00 	movb   $0x0,0xf02a12b4
f0103973:	c6 05 b5 12 2a f0 8e 	movb   $0x8e,0xf02a12b5
f010397a:	c1 e8 10             	shr    $0x10,%eax
f010397d:	66 a3 b6 12 2a f0    	mov    %ax,0xf02a12b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, segnp_entry, 0);
f0103983:	b8 90 43 10 f0       	mov    $0xf0104390,%eax
f0103988:	66 a3 b8 12 2a f0    	mov    %ax,0xf02a12b8
f010398e:	66 c7 05 ba 12 2a f0 	movw   $0x8,0xf02a12ba
f0103995:	08 00 
f0103997:	c6 05 bc 12 2a f0 00 	movb   $0x0,0xf02a12bc
f010399e:	c6 05 bd 12 2a f0 8e 	movb   $0x8e,0xf02a12bd
f01039a5:	c1 e8 10             	shr    $0x10,%eax
f01039a8:	66 a3 be 12 2a f0    	mov    %ax,0xf02a12be
	SETGATE(idt[T_STACK], 0, GD_KT, stack_entry, 0);
f01039ae:	b8 98 43 10 f0       	mov    $0xf0104398,%eax
f01039b3:	66 a3 c0 12 2a f0    	mov    %ax,0xf02a12c0
f01039b9:	66 c7 05 c2 12 2a f0 	movw   $0x8,0xf02a12c2
f01039c0:	08 00 
f01039c2:	c6 05 c4 12 2a f0 00 	movb   $0x0,0xf02a12c4
f01039c9:	c6 05 c5 12 2a f0 8e 	movb   $0x8e,0xf02a12c5
f01039d0:	c1 e8 10             	shr    $0x10,%eax
f01039d3:	66 a3 c6 12 2a f0    	mov    %ax,0xf02a12c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt_entry, 0);
f01039d9:	b8 a0 43 10 f0       	mov    $0xf01043a0,%eax
f01039de:	66 a3 c8 12 2a f0    	mov    %ax,0xf02a12c8
f01039e4:	66 c7 05 ca 12 2a f0 	movw   $0x8,0xf02a12ca
f01039eb:	08 00 
f01039ed:	c6 05 cc 12 2a f0 00 	movb   $0x0,0xf02a12cc
f01039f4:	c6 05 cd 12 2a f0 8e 	movb   $0x8e,0xf02a12cd
f01039fb:	c1 e8 10             	shr    $0x10,%eax
f01039fe:	66 a3 ce 12 2a f0    	mov    %ax,0xf02a12ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt_entry, 0);
f0103a04:	b8 a8 43 10 f0       	mov    $0xf01043a8,%eax
f0103a09:	66 a3 d0 12 2a f0    	mov    %ax,0xf02a12d0
f0103a0f:	66 c7 05 d2 12 2a f0 	movw   $0x8,0xf02a12d2
f0103a16:	08 00 
f0103a18:	c6 05 d4 12 2a f0 00 	movb   $0x0,0xf02a12d4
f0103a1f:	c6 05 d5 12 2a f0 8e 	movb   $0x8e,0xf02a12d5
f0103a26:	c1 e8 10             	shr    $0x10,%eax
f0103a29:	66 a3 d6 12 2a f0    	mov    %ax,0xf02a12d6
	SETGATE(idt[T_FPERR], 0, GD_KT, fperr_entry, 0);
f0103a2f:	b8 ac 43 10 f0       	mov    $0xf01043ac,%eax
f0103a34:	66 a3 e0 12 2a f0    	mov    %ax,0xf02a12e0
f0103a3a:	66 c7 05 e2 12 2a f0 	movw   $0x8,0xf02a12e2
f0103a41:	08 00 
f0103a43:	c6 05 e4 12 2a f0 00 	movb   $0x0,0xf02a12e4
f0103a4a:	c6 05 e5 12 2a f0 8e 	movb   $0x8e,0xf02a12e5
f0103a51:	c1 e8 10             	shr    $0x10,%eax
f0103a54:	66 a3 e6 12 2a f0    	mov    %ax,0xf02a12e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, align_entry, 0);
f0103a5a:	b8 b2 43 10 f0       	mov    $0xf01043b2,%eax
f0103a5f:	66 a3 e8 12 2a f0    	mov    %ax,0xf02a12e8
f0103a65:	66 c7 05 ea 12 2a f0 	movw   $0x8,0xf02a12ea
f0103a6c:	08 00 
f0103a6e:	c6 05 ec 12 2a f0 00 	movb   $0x0,0xf02a12ec
f0103a75:	c6 05 ed 12 2a f0 8e 	movb   $0x8e,0xf02a12ed
f0103a7c:	c1 e8 10             	shr    $0x10,%eax
f0103a7f:	66 a3 ee 12 2a f0    	mov    %ax,0xf02a12ee
	SETGATE(idt[T_MCHK], 0, GD_KT, mchk_entry, 0);
f0103a85:	b8 b6 43 10 f0       	mov    $0xf01043b6,%eax
f0103a8a:	66 a3 f0 12 2a f0    	mov    %ax,0xf02a12f0
f0103a90:	66 c7 05 f2 12 2a f0 	movw   $0x8,0xf02a12f2
f0103a97:	08 00 
f0103a99:	c6 05 f4 12 2a f0 00 	movb   $0x0,0xf02a12f4
f0103aa0:	c6 05 f5 12 2a f0 8e 	movb   $0x8e,0xf02a12f5
f0103aa7:	c1 e8 10             	shr    $0x10,%eax
f0103aaa:	66 a3 f6 12 2a f0    	mov    %ax,0xf02a12f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr_entry, 0);
f0103ab0:	b8 bc 43 10 f0       	mov    $0xf01043bc,%eax
f0103ab5:	66 a3 f8 12 2a f0    	mov    %ax,0xf02a12f8
f0103abb:	66 c7 05 fa 12 2a f0 	movw   $0x8,0xf02a12fa
f0103ac2:	08 00 
f0103ac4:	c6 05 fc 12 2a f0 00 	movb   $0x0,0xf02a12fc
f0103acb:	c6 05 fd 12 2a f0 8e 	movb   $0x8e,0xf02a12fd
f0103ad2:	c1 e8 10             	shr    $0x10,%eax
f0103ad5:	66 a3 fe 12 2a f0    	mov    %ax,0xf02a12fe
	
	SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall_entry, 3);
f0103adb:	b8 c2 43 10 f0       	mov    $0xf01043c2,%eax
f0103ae0:	66 a3 e0 13 2a f0    	mov    %ax,0xf02a13e0
f0103ae6:	66 c7 05 e2 13 2a f0 	movw   $0x8,0xf02a13e2
f0103aed:	08 00 
f0103aef:	c6 05 e4 13 2a f0 00 	movb   $0x0,0xf02a13e4
f0103af6:	c6 05 e5 13 2a f0 ee 	movb   $0xee,0xf02a13e5
f0103afd:	c1 e8 10             	shr    $0x10,%eax
f0103b00:	66 a3 e6 13 2a f0    	mov    %ax,0xf02a13e6

	SETGATE(idt[32], 0, GD_KT, th32, 0);
f0103b06:	b8 c8 43 10 f0       	mov    $0xf01043c8,%eax
f0103b0b:	66 a3 60 13 2a f0    	mov    %ax,0xf02a1360
f0103b11:	66 c7 05 62 13 2a f0 	movw   $0x8,0xf02a1362
f0103b18:	08 00 
f0103b1a:	c6 05 64 13 2a f0 00 	movb   $0x0,0xf02a1364
f0103b21:	c6 05 65 13 2a f0 8e 	movb   $0x8e,0xf02a1365
f0103b28:	c1 e8 10             	shr    $0x10,%eax
f0103b2b:	66 a3 66 13 2a f0    	mov    %ax,0xf02a1366
    SETGATE(idt[33], 0, GD_KT, th33, 0);
f0103b31:	b8 ce 43 10 f0       	mov    $0xf01043ce,%eax
f0103b36:	66 a3 68 13 2a f0    	mov    %ax,0xf02a1368
f0103b3c:	66 c7 05 6a 13 2a f0 	movw   $0x8,0xf02a136a
f0103b43:	08 00 
f0103b45:	c6 05 6c 13 2a f0 00 	movb   $0x0,0xf02a136c
f0103b4c:	c6 05 6d 13 2a f0 8e 	movb   $0x8e,0xf02a136d
f0103b53:	c1 e8 10             	shr    $0x10,%eax
f0103b56:	66 a3 6e 13 2a f0    	mov    %ax,0xf02a136e
    SETGATE(idt[34], 0, GD_KT, th34, 0);
f0103b5c:	b8 d4 43 10 f0       	mov    $0xf01043d4,%eax
f0103b61:	66 a3 70 13 2a f0    	mov    %ax,0xf02a1370
f0103b67:	66 c7 05 72 13 2a f0 	movw   $0x8,0xf02a1372
f0103b6e:	08 00 
f0103b70:	c6 05 74 13 2a f0 00 	movb   $0x0,0xf02a1374
f0103b77:	c6 05 75 13 2a f0 8e 	movb   $0x8e,0xf02a1375
f0103b7e:	c1 e8 10             	shr    $0x10,%eax
f0103b81:	66 a3 76 13 2a f0    	mov    %ax,0xf02a1376
    SETGATE(idt[35], 0, GD_KT, th35, 0);
f0103b87:	b8 da 43 10 f0       	mov    $0xf01043da,%eax
f0103b8c:	66 a3 78 13 2a f0    	mov    %ax,0xf02a1378
f0103b92:	66 c7 05 7a 13 2a f0 	movw   $0x8,0xf02a137a
f0103b99:	08 00 
f0103b9b:	c6 05 7c 13 2a f0 00 	movb   $0x0,0xf02a137c
f0103ba2:	c6 05 7d 13 2a f0 8e 	movb   $0x8e,0xf02a137d
f0103ba9:	c1 e8 10             	shr    $0x10,%eax
f0103bac:	66 a3 7e 13 2a f0    	mov    %ax,0xf02a137e
    SETGATE(idt[36], 0, GD_KT, th36, 0);
f0103bb2:	b8 e0 43 10 f0       	mov    $0xf01043e0,%eax
f0103bb7:	66 a3 80 13 2a f0    	mov    %ax,0xf02a1380
f0103bbd:	66 c7 05 82 13 2a f0 	movw   $0x8,0xf02a1382
f0103bc4:	08 00 
f0103bc6:	c6 05 84 13 2a f0 00 	movb   $0x0,0xf02a1384
f0103bcd:	c6 05 85 13 2a f0 8e 	movb   $0x8e,0xf02a1385
f0103bd4:	c1 e8 10             	shr    $0x10,%eax
f0103bd7:	66 a3 86 13 2a f0    	mov    %ax,0xf02a1386
    SETGATE(idt[37], 0, GD_KT, th37, 0);
f0103bdd:	b8 e6 43 10 f0       	mov    $0xf01043e6,%eax
f0103be2:	66 a3 88 13 2a f0    	mov    %ax,0xf02a1388
f0103be8:	66 c7 05 8a 13 2a f0 	movw   $0x8,0xf02a138a
f0103bef:	08 00 
f0103bf1:	c6 05 8c 13 2a f0 00 	movb   $0x0,0xf02a138c
f0103bf8:	c6 05 8d 13 2a f0 8e 	movb   $0x8e,0xf02a138d
f0103bff:	c1 e8 10             	shr    $0x10,%eax
f0103c02:	66 a3 8e 13 2a f0    	mov    %ax,0xf02a138e
    SETGATE(idt[38], 0, GD_KT, th38, 0);
f0103c08:	b8 ec 43 10 f0       	mov    $0xf01043ec,%eax
f0103c0d:	66 a3 90 13 2a f0    	mov    %ax,0xf02a1390
f0103c13:	66 c7 05 92 13 2a f0 	movw   $0x8,0xf02a1392
f0103c1a:	08 00 
f0103c1c:	c6 05 94 13 2a f0 00 	movb   $0x0,0xf02a1394
f0103c23:	c6 05 95 13 2a f0 8e 	movb   $0x8e,0xf02a1395
f0103c2a:	c1 e8 10             	shr    $0x10,%eax
f0103c2d:	66 a3 96 13 2a f0    	mov    %ax,0xf02a1396
    SETGATE(idt[39], 0, GD_KT, th39, 0);
f0103c33:	b8 f2 43 10 f0       	mov    $0xf01043f2,%eax
f0103c38:	66 a3 98 13 2a f0    	mov    %ax,0xf02a1398
f0103c3e:	66 c7 05 9a 13 2a f0 	movw   $0x8,0xf02a139a
f0103c45:	08 00 
f0103c47:	c6 05 9c 13 2a f0 00 	movb   $0x0,0xf02a139c
f0103c4e:	c6 05 9d 13 2a f0 8e 	movb   $0x8e,0xf02a139d
f0103c55:	c1 e8 10             	shr    $0x10,%eax
f0103c58:	66 a3 9e 13 2a f0    	mov    %ax,0xf02a139e
    SETGATE(idt[40], 0, GD_KT, th40, 0);
f0103c5e:	b8 f8 43 10 f0       	mov    $0xf01043f8,%eax
f0103c63:	66 a3 a0 13 2a f0    	mov    %ax,0xf02a13a0
f0103c69:	66 c7 05 a2 13 2a f0 	movw   $0x8,0xf02a13a2
f0103c70:	08 00 
f0103c72:	c6 05 a4 13 2a f0 00 	movb   $0x0,0xf02a13a4
f0103c79:	c6 05 a5 13 2a f0 8e 	movb   $0x8e,0xf02a13a5
f0103c80:	c1 e8 10             	shr    $0x10,%eax
f0103c83:	66 a3 a6 13 2a f0    	mov    %ax,0xf02a13a6
    SETGATE(idt[41], 0, GD_KT, th41, 0);
f0103c89:	b8 fe 43 10 f0       	mov    $0xf01043fe,%eax
f0103c8e:	66 a3 a8 13 2a f0    	mov    %ax,0xf02a13a8
f0103c94:	66 c7 05 aa 13 2a f0 	movw   $0x8,0xf02a13aa
f0103c9b:	08 00 
f0103c9d:	c6 05 ac 13 2a f0 00 	movb   $0x0,0xf02a13ac
f0103ca4:	c6 05 ad 13 2a f0 8e 	movb   $0x8e,0xf02a13ad
f0103cab:	c1 e8 10             	shr    $0x10,%eax
f0103cae:	66 a3 ae 13 2a f0    	mov    %ax,0xf02a13ae
    SETGATE(idt[42], 0, GD_KT, th42, 0);
f0103cb4:	b8 04 44 10 f0       	mov    $0xf0104404,%eax
f0103cb9:	66 a3 b0 13 2a f0    	mov    %ax,0xf02a13b0
f0103cbf:	66 c7 05 b2 13 2a f0 	movw   $0x8,0xf02a13b2
f0103cc6:	08 00 
f0103cc8:	c6 05 b4 13 2a f0 00 	movb   $0x0,0xf02a13b4
f0103ccf:	c6 05 b5 13 2a f0 8e 	movb   $0x8e,0xf02a13b5
f0103cd6:	c1 e8 10             	shr    $0x10,%eax
f0103cd9:	66 a3 b6 13 2a f0    	mov    %ax,0xf02a13b6
    SETGATE(idt[43], 0, GD_KT, th43, 0);
f0103cdf:	b8 0a 44 10 f0       	mov    $0xf010440a,%eax
f0103ce4:	66 a3 b8 13 2a f0    	mov    %ax,0xf02a13b8
f0103cea:	66 c7 05 ba 13 2a f0 	movw   $0x8,0xf02a13ba
f0103cf1:	08 00 
f0103cf3:	c6 05 bc 13 2a f0 00 	movb   $0x0,0xf02a13bc
f0103cfa:	c6 05 bd 13 2a f0 8e 	movb   $0x8e,0xf02a13bd
f0103d01:	c1 e8 10             	shr    $0x10,%eax
f0103d04:	66 a3 be 13 2a f0    	mov    %ax,0xf02a13be
    SETGATE(idt[44], 0, GD_KT, th44, 0);
f0103d0a:	b8 10 44 10 f0       	mov    $0xf0104410,%eax
f0103d0f:	66 a3 c0 13 2a f0    	mov    %ax,0xf02a13c0
f0103d15:	66 c7 05 c2 13 2a f0 	movw   $0x8,0xf02a13c2
f0103d1c:	08 00 
f0103d1e:	c6 05 c4 13 2a f0 00 	movb   $0x0,0xf02a13c4
f0103d25:	c6 05 c5 13 2a f0 8e 	movb   $0x8e,0xf02a13c5
f0103d2c:	c1 e8 10             	shr    $0x10,%eax
f0103d2f:	66 a3 c6 13 2a f0    	mov    %ax,0xf02a13c6
    SETGATE(idt[45], 0, GD_KT, th45, 0);
f0103d35:	b8 16 44 10 f0       	mov    $0xf0104416,%eax
f0103d3a:	66 a3 c8 13 2a f0    	mov    %ax,0xf02a13c8
f0103d40:	66 c7 05 ca 13 2a f0 	movw   $0x8,0xf02a13ca
f0103d47:	08 00 
f0103d49:	c6 05 cc 13 2a f0 00 	movb   $0x0,0xf02a13cc
f0103d50:	c6 05 cd 13 2a f0 8e 	movb   $0x8e,0xf02a13cd
f0103d57:	c1 e8 10             	shr    $0x10,%eax
f0103d5a:	66 a3 ce 13 2a f0    	mov    %ax,0xf02a13ce
    SETGATE(idt[46], 0, GD_KT, th46, 0);
f0103d60:	b8 1c 44 10 f0       	mov    $0xf010441c,%eax
f0103d65:	66 a3 d0 13 2a f0    	mov    %ax,0xf02a13d0
f0103d6b:	66 c7 05 d2 13 2a f0 	movw   $0x8,0xf02a13d2
f0103d72:	08 00 
f0103d74:	c6 05 d4 13 2a f0 00 	movb   $0x0,0xf02a13d4
f0103d7b:	c6 05 d5 13 2a f0 8e 	movb   $0x8e,0xf02a13d5
f0103d82:	c1 e8 10             	shr    $0x10,%eax
f0103d85:	66 a3 d6 13 2a f0    	mov    %ax,0xf02a13d6
    SETGATE(idt[47], 0, GD_KT, th47, 0);
f0103d8b:	b8 22 44 10 f0       	mov    $0xf0104422,%eax
f0103d90:	66 a3 d8 13 2a f0    	mov    %ax,0xf02a13d8
f0103d96:	66 c7 05 da 13 2a f0 	movw   $0x8,0xf02a13da
f0103d9d:	08 00 
f0103d9f:	c6 05 dc 13 2a f0 00 	movb   $0x0,0xf02a13dc
f0103da6:	c6 05 dd 13 2a f0 8e 	movb   $0x8e,0xf02a13dd
f0103dad:	c1 e8 10             	shr    $0x10,%eax
f0103db0:	66 a3 de 13 2a f0    	mov    %ax,0xf02a13de
    
	// Per-CPU setup 
	trap_init_percpu();
f0103db6:	e8 45 f9 ff ff       	call   f0103700 <trap_init_percpu>
}
f0103dbb:	c9                   	leave  
f0103dbc:	c3                   	ret    

f0103dbd <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103dbd:	55                   	push   %ebp
f0103dbe:	89 e5                	mov    %esp,%ebp
f0103dc0:	53                   	push   %ebx
f0103dc1:	83 ec 0c             	sub    $0xc,%esp
f0103dc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103dc7:	ff 33                	pushl  (%ebx)
f0103dc9:	68 f2 7c 10 f0       	push   $0xf0107cf2
f0103dce:	e8 19 f9 ff ff       	call   f01036ec <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103dd3:	83 c4 08             	add    $0x8,%esp
f0103dd6:	ff 73 04             	pushl  0x4(%ebx)
f0103dd9:	68 01 7d 10 f0       	push   $0xf0107d01
f0103dde:	e8 09 f9 ff ff       	call   f01036ec <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103de3:	83 c4 08             	add    $0x8,%esp
f0103de6:	ff 73 08             	pushl  0x8(%ebx)
f0103de9:	68 10 7d 10 f0       	push   $0xf0107d10
f0103dee:	e8 f9 f8 ff ff       	call   f01036ec <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103df3:	83 c4 08             	add    $0x8,%esp
f0103df6:	ff 73 0c             	pushl  0xc(%ebx)
f0103df9:	68 1f 7d 10 f0       	push   $0xf0107d1f
f0103dfe:	e8 e9 f8 ff ff       	call   f01036ec <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e03:	83 c4 08             	add    $0x8,%esp
f0103e06:	ff 73 10             	pushl  0x10(%ebx)
f0103e09:	68 2e 7d 10 f0       	push   $0xf0107d2e
f0103e0e:	e8 d9 f8 ff ff       	call   f01036ec <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e13:	83 c4 08             	add    $0x8,%esp
f0103e16:	ff 73 14             	pushl  0x14(%ebx)
f0103e19:	68 3d 7d 10 f0       	push   $0xf0107d3d
f0103e1e:	e8 c9 f8 ff ff       	call   f01036ec <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e23:	83 c4 08             	add    $0x8,%esp
f0103e26:	ff 73 18             	pushl  0x18(%ebx)
f0103e29:	68 4c 7d 10 f0       	push   $0xf0107d4c
f0103e2e:	e8 b9 f8 ff ff       	call   f01036ec <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e33:	83 c4 08             	add    $0x8,%esp
f0103e36:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e39:	68 5b 7d 10 f0       	push   $0xf0107d5b
f0103e3e:	e8 a9 f8 ff ff       	call   f01036ec <cprintf>
}
f0103e43:	83 c4 10             	add    $0x10,%esp
f0103e46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e49:	c9                   	leave  
f0103e4a:	c3                   	ret    

f0103e4b <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e4b:	55                   	push   %ebp
f0103e4c:	89 e5                	mov    %esp,%ebp
f0103e4e:	56                   	push   %esi
f0103e4f:	53                   	push   %ebx
f0103e50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e53:	e8 a2 1e 00 00       	call   f0105cfa <cpunum>
f0103e58:	83 ec 04             	sub    $0x4,%esp
f0103e5b:	50                   	push   %eax
f0103e5c:	53                   	push   %ebx
f0103e5d:	68 bf 7d 10 f0       	push   $0xf0107dbf
f0103e62:	e8 85 f8 ff ff       	call   f01036ec <cprintf>
	print_regs(&tf->tf_regs);
f0103e67:	89 1c 24             	mov    %ebx,(%esp)
f0103e6a:	e8 4e ff ff ff       	call   f0103dbd <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e6f:	83 c4 08             	add    $0x8,%esp
f0103e72:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e76:	50                   	push   %eax
f0103e77:	68 dd 7d 10 f0       	push   $0xf0107ddd
f0103e7c:	e8 6b f8 ff ff       	call   f01036ec <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e81:	83 c4 08             	add    $0x8,%esp
f0103e84:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e88:	50                   	push   %eax
f0103e89:	68 f0 7d 10 f0       	push   $0xf0107df0
f0103e8e:	e8 59 f8 ff ff       	call   f01036ec <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e93:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103e96:	83 c4 10             	add    $0x10,%esp
f0103e99:	83 f8 13             	cmp    $0x13,%eax
f0103e9c:	77 09                	ja     f0103ea7 <print_trapframe+0x5c>
		return excnames[trapno];
f0103e9e:	8b 14 85 80 80 10 f0 	mov    -0xfef7f80(,%eax,4),%edx
f0103ea5:	eb 1f                	jmp    f0103ec6 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103ea7:	83 f8 30             	cmp    $0x30,%eax
f0103eaa:	74 15                	je     f0103ec1 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103eac:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103eaf:	83 fa 10             	cmp    $0x10,%edx
f0103eb2:	b9 89 7d 10 f0       	mov    $0xf0107d89,%ecx
f0103eb7:	ba 76 7d 10 f0       	mov    $0xf0107d76,%edx
f0103ebc:	0f 43 d1             	cmovae %ecx,%edx
f0103ebf:	eb 05                	jmp    f0103ec6 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103ec1:	ba 6a 7d 10 f0       	mov    $0xf0107d6a,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ec6:	83 ec 04             	sub    $0x4,%esp
f0103ec9:	52                   	push   %edx
f0103eca:	50                   	push   %eax
f0103ecb:	68 03 7e 10 f0       	push   $0xf0107e03
f0103ed0:	e8 17 f8 ff ff       	call   f01036ec <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ed5:	83 c4 10             	add    $0x10,%esp
f0103ed8:	3b 1d 60 1a 2a f0    	cmp    0xf02a1a60,%ebx
f0103ede:	75 1a                	jne    f0103efa <print_trapframe+0xaf>
f0103ee0:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ee4:	75 14                	jne    f0103efa <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103ee6:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ee9:	83 ec 08             	sub    $0x8,%esp
f0103eec:	50                   	push   %eax
f0103eed:	68 15 7e 10 f0       	push   $0xf0107e15
f0103ef2:	e8 f5 f7 ff ff       	call   f01036ec <cprintf>
f0103ef7:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103efa:	83 ec 08             	sub    $0x8,%esp
f0103efd:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f00:	68 24 7e 10 f0       	push   $0xf0107e24
f0103f05:	e8 e2 f7 ff ff       	call   f01036ec <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f0a:	83 c4 10             	add    $0x10,%esp
f0103f0d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f11:	75 49                	jne    f0103f5c <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f13:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f16:	89 c2                	mov    %eax,%edx
f0103f18:	83 e2 01             	and    $0x1,%edx
f0103f1b:	ba a3 7d 10 f0       	mov    $0xf0107da3,%edx
f0103f20:	b9 98 7d 10 f0       	mov    $0xf0107d98,%ecx
f0103f25:	0f 44 ca             	cmove  %edx,%ecx
f0103f28:	89 c2                	mov    %eax,%edx
f0103f2a:	83 e2 02             	and    $0x2,%edx
f0103f2d:	ba b5 7d 10 f0       	mov    $0xf0107db5,%edx
f0103f32:	be af 7d 10 f0       	mov    $0xf0107daf,%esi
f0103f37:	0f 45 d6             	cmovne %esi,%edx
f0103f3a:	83 e0 04             	and    $0x4,%eax
f0103f3d:	be 0a 7f 10 f0       	mov    $0xf0107f0a,%esi
f0103f42:	b8 ba 7d 10 f0       	mov    $0xf0107dba,%eax
f0103f47:	0f 44 c6             	cmove  %esi,%eax
f0103f4a:	51                   	push   %ecx
f0103f4b:	52                   	push   %edx
f0103f4c:	50                   	push   %eax
f0103f4d:	68 32 7e 10 f0       	push   $0xf0107e32
f0103f52:	e8 95 f7 ff ff       	call   f01036ec <cprintf>
f0103f57:	83 c4 10             	add    $0x10,%esp
f0103f5a:	eb 10                	jmp    f0103f6c <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f5c:	83 ec 0c             	sub    $0xc,%esp
f0103f5f:	68 26 73 10 f0       	push   $0xf0107326
f0103f64:	e8 83 f7 ff ff       	call   f01036ec <cprintf>
f0103f69:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f6c:	83 ec 08             	sub    $0x8,%esp
f0103f6f:	ff 73 30             	pushl  0x30(%ebx)
f0103f72:	68 41 7e 10 f0       	push   $0xf0107e41
f0103f77:	e8 70 f7 ff ff       	call   f01036ec <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f7c:	83 c4 08             	add    $0x8,%esp
f0103f7f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f83:	50                   	push   %eax
f0103f84:	68 50 7e 10 f0       	push   $0xf0107e50
f0103f89:	e8 5e f7 ff ff       	call   f01036ec <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f8e:	83 c4 08             	add    $0x8,%esp
f0103f91:	ff 73 38             	pushl  0x38(%ebx)
f0103f94:	68 63 7e 10 f0       	push   $0xf0107e63
f0103f99:	e8 4e f7 ff ff       	call   f01036ec <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f9e:	83 c4 10             	add    $0x10,%esp
f0103fa1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fa5:	74 25                	je     f0103fcc <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103fa7:	83 ec 08             	sub    $0x8,%esp
f0103faa:	ff 73 3c             	pushl  0x3c(%ebx)
f0103fad:	68 72 7e 10 f0       	push   $0xf0107e72
f0103fb2:	e8 35 f7 ff ff       	call   f01036ec <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103fb7:	83 c4 08             	add    $0x8,%esp
f0103fba:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103fbe:	50                   	push   %eax
f0103fbf:	68 81 7e 10 f0       	push   $0xf0107e81
f0103fc4:	e8 23 f7 ff ff       	call   f01036ec <cprintf>
f0103fc9:	83 c4 10             	add    $0x10,%esp
	}
}
f0103fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103fcf:	5b                   	pop    %ebx
f0103fd0:	5e                   	pop    %esi
f0103fd1:	5d                   	pop    %ebp
f0103fd2:	c3                   	ret    

f0103fd3 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103fd3:	55                   	push   %ebp
f0103fd4:	89 e5                	mov    %esp,%ebp
f0103fd6:	57                   	push   %edi
f0103fd7:	56                   	push   %esi
f0103fd8:	53                   	push   %ebx
f0103fd9:	83 ec 0c             	sub    $0xc,%esp
f0103fdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fdf:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 3) == 0)
f0103fe2:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fe6:	75 17                	jne    f0103fff <page_fault_handler+0x2c>
	{
		panic("Page fault in kernel mode\n");
f0103fe8:	83 ec 04             	sub    $0x4,%esp
f0103feb:	68 94 7e 10 f0       	push   $0xf0107e94
f0103ff0:	68 8e 01 00 00       	push   $0x18e
f0103ff5:	68 af 7e 10 f0       	push   $0xf0107eaf
f0103ffa:	e8 41 c0 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	
	if (curenv->env_pgfault_upcall)
f0103fff:	e8 f6 1c 00 00       	call   f0105cfa <cpunum>
f0104004:	6b c0 74             	imul   $0x74,%eax,%eax
f0104007:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f010400d:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104011:	0f 84 8b 00 00 00    	je     f01040a2 <page_fault_handler+0xcf>
	{
		uintptr_t cur_uxstacktop;
		struct UTrapframe *utf;
    	if ((tf->tf_esp >= UXSTACKTOP - PGSIZE) && (tf->tf_esp <= UXSTACKTOP -1))
f0104017:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010401a:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
    	{
    		cur_uxstacktop = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0104020:	83 e8 38             	sub    $0x38,%eax
f0104023:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104029:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f010402e:	0f 46 d0             	cmovbe %eax,%edx
f0104031:	89 d7                	mov    %edx,%edi
    	else
   		{
    		cur_uxstacktop = UXSTACKTOP - sizeof(struct UTrapframe);
    	}

    	user_mem_assert(curenv, (void *)cur_uxstacktop, 1, PTE_W);
f0104033:	e8 c2 1c 00 00       	call   f0105cfa <cpunum>
f0104038:	6a 02                	push   $0x2
f010403a:	6a 01                	push   $0x1
f010403c:	57                   	push   %edi
f010403d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104040:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104046:	e8 9a ed ff ff       	call   f0102de5 <user_mem_assert>
    	utf = (struct UTrapframe *)cur_uxstacktop;

    	utf->utf_fault_va = fault_va;
f010404b:	89 fa                	mov    %edi,%edx
f010404d:	89 37                	mov    %esi,(%edi)
    	utf->utf_err = tf->tf_err;
f010404f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104052:	89 47 04             	mov    %eax,0x4(%edi)
   		utf->utf_regs = tf->tf_regs;
f0104055:	8d 7f 08             	lea    0x8(%edi),%edi
f0104058:	b9 08 00 00 00       	mov    $0x8,%ecx
f010405d:	89 de                	mov    %ebx,%esi
f010405f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
   		utf->utf_eip = tf->tf_eip;
f0104061:	8b 43 30             	mov    0x30(%ebx),%eax
f0104064:	89 42 28             	mov    %eax,0x28(%edx)
    	utf->utf_eflags = tf->tf_eflags;
f0104067:	8b 43 38             	mov    0x38(%ebx),%eax
f010406a:	89 d7                	mov    %edx,%edi
f010406c:	89 42 2c             	mov    %eax,0x2c(%edx)
    	utf->utf_esp = tf->tf_esp;
f010406f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104072:	89 42 30             	mov    %eax,0x30(%edx)
    	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104075:	e8 80 1c 00 00       	call   f0105cfa <cpunum>
f010407a:	6b c0 74             	imul   $0x74,%eax,%eax
f010407d:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104083:	8b 40 64             	mov    0x64(%eax),%eax
f0104086:	89 43 30             	mov    %eax,0x30(%ebx)
    	tf->tf_esp = (uintptr_t)cur_uxstacktop;
f0104089:	89 7b 3c             	mov    %edi,0x3c(%ebx)
    	
    	env_run(curenv);
f010408c:	e8 69 1c 00 00       	call   f0105cfa <cpunum>
f0104091:	83 c4 04             	add    $0x4,%esp
f0104094:	6b c0 74             	imul   $0x74,%eax,%eax
f0104097:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f010409d:	e8 ce f3 ff ff       	call   f0103470 <env_run>
    }	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040a2:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040a5:	e8 50 1c 00 00       	call   f0105cfa <cpunum>
    	tf->tf_esp = (uintptr_t)cur_uxstacktop;
    	
    	env_run(curenv);
    }	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040aa:	57                   	push   %edi
f01040ab:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040ac:	6b c0 74             	imul   $0x74,%eax,%eax
    	tf->tf_esp = (uintptr_t)cur_uxstacktop;
    	
    	env_run(curenv);
    }	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040af:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01040b5:	ff 70 48             	pushl  0x48(%eax)
f01040b8:	68 54 80 10 f0       	push   $0xf0108054
f01040bd:	e8 2a f6 ff ff       	call   f01036ec <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01040c2:	89 1c 24             	mov    %ebx,(%esp)
f01040c5:	e8 81 fd ff ff       	call   f0103e4b <print_trapframe>
	env_destroy(curenv);
f01040ca:	e8 2b 1c 00 00       	call   f0105cfa <cpunum>
f01040cf:	83 c4 04             	add    $0x4,%esp
f01040d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d5:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f01040db:	e8 f1 f2 ff ff       	call   f01033d1 <env_destroy>
}
f01040e0:	83 c4 10             	add    $0x10,%esp
f01040e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040e6:	5b                   	pop    %ebx
f01040e7:	5e                   	pop    %esi
f01040e8:	5f                   	pop    %edi
f01040e9:	5d                   	pop    %ebp
f01040ea:	c3                   	ret    

f01040eb <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040eb:	55                   	push   %ebp
f01040ec:	89 e5                	mov    %esp,%ebp
f01040ee:	57                   	push   %edi
f01040ef:	56                   	push   %esi
f01040f0:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040f3:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01040f4:	83 3d 8c 1e 2a f0 00 	cmpl   $0x0,0xf02a1e8c
f01040fb:	74 01                	je     f01040fe <trap+0x13>
		asm volatile("hlt");
f01040fd:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01040fe:	e8 f7 1b 00 00       	call   f0105cfa <cpunum>
f0104103:	6b d0 74             	imul   $0x74,%eax,%edx
f0104106:	81 c2 20 20 2a f0    	add    $0xf02a2020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010410c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104111:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104115:	83 f8 02             	cmp    $0x2,%eax
f0104118:	75 10                	jne    f010412a <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010411a:	83 ec 0c             	sub    $0xc,%esp
f010411d:	68 c0 33 12 f0       	push   $0xf01233c0
f0104122:	e8 41 1e 00 00       	call   f0105f68 <spin_lock>
f0104127:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010412a:	9c                   	pushf  
f010412b:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010412c:	f6 c4 02             	test   $0x2,%ah
f010412f:	74 19                	je     f010414a <trap+0x5f>
f0104131:	68 bb 7e 10 f0       	push   $0xf0107ebb
f0104136:	68 5f 70 10 f0       	push   $0xf010705f
f010413b:	68 54 01 00 00       	push   $0x154
f0104140:	68 af 7e 10 f0       	push   $0xf0107eaf
f0104145:	e8 f6 be ff ff       	call   f0100040 <_panic>


	//cprintf("\nIncoming TRAP frame at %p\n", tf);
	
	if ((tf->tf_cs & 3) == 3) {
f010414a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010414e:	83 e0 03             	and    $0x3,%eax
f0104151:	66 83 f8 03          	cmp    $0x3,%ax
f0104155:	0f 85 a0 00 00 00    	jne    f01041fb <trap+0x110>
f010415b:	83 ec 0c             	sub    $0xc,%esp
f010415e:	68 c0 33 12 f0       	push   $0xf01233c0
f0104163:	e8 00 1e 00 00       	call   f0105f68 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104168:	e8 8d 1b 00 00       	call   f0105cfa <cpunum>
f010416d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104170:	83 c4 10             	add    $0x10,%esp
f0104173:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f010417a:	75 19                	jne    f0104195 <trap+0xaa>
f010417c:	68 d4 7e 10 f0       	push   $0xf0107ed4
f0104181:	68 5f 70 10 f0       	push   $0xf010705f
f0104186:	68 5f 01 00 00       	push   $0x15f
f010418b:	68 af 7e 10 f0       	push   $0xf0107eaf
f0104190:	e8 ab be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104195:	e8 60 1b 00 00       	call   f0105cfa <cpunum>
f010419a:	6b c0 74             	imul   $0x74,%eax,%eax
f010419d:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01041a3:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041a7:	75 2d                	jne    f01041d6 <trap+0xeb>
			env_free(curenv);
f01041a9:	e8 4c 1b 00 00       	call   f0105cfa <cpunum>
f01041ae:	83 ec 0c             	sub    $0xc,%esp
f01041b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b4:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f01041ba:	e8 6c f0 ff ff       	call   f010322b <env_free>
			curenv = NULL;
f01041bf:	e8 36 1b 00 00       	call   f0105cfa <cpunum>
f01041c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c7:	c7 80 28 20 2a f0 00 	movl   $0x0,-0xfd5dfd8(%eax)
f01041ce:	00 00 00 
			sched_yield();
f01041d1:	e8 37 03 00 00       	call   f010450d <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01041d6:	e8 1f 1b 00 00       	call   f0105cfa <cpunum>
f01041db:	6b c0 74             	imul   $0x74,%eax,%eax
f01041de:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01041e4:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041e9:	89 c7                	mov    %eax,%edi
f01041eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041ed:	e8 08 1b 00 00       	call   f0105cfa <cpunum>
f01041f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f5:	8b b0 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01041fb:	89 35 60 1a 2a f0    	mov    %esi,0xf02a1a60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104201:	8b 46 28             	mov    0x28(%esi),%eax
f0104204:	83 f8 27             	cmp    $0x27,%eax
f0104207:	75 1d                	jne    f0104226 <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f0104209:	83 ec 0c             	sub    $0xc,%esp
f010420c:	68 db 7e 10 f0       	push   $0xf0107edb
f0104211:	e8 d6 f4 ff ff       	call   f01036ec <cprintf>
		print_trapframe(tf);
f0104216:	89 34 24             	mov    %esi,(%esp)
f0104219:	e8 2d fc ff ff       	call   f0103e4b <print_trapframe>
f010421e:	83 c4 10             	add    $0x10,%esp
f0104221:	e9 ca 00 00 00       	jmp    f01042f0 <trap+0x205>
		return;
	}


	if (tf->tf_trapno == T_PGFLT) {
f0104226:	83 f8 0e             	cmp    $0xe,%eax
f0104229:	75 11                	jne    f010423c <trap+0x151>
        page_fault_handler(tf);
f010422b:	83 ec 0c             	sub    $0xc,%esp
f010422e:	56                   	push   %esi
f010422f:	e8 9f fd ff ff       	call   f0103fd3 <page_fault_handler>
f0104234:	83 c4 10             	add    $0x10,%esp
f0104237:	e9 b4 00 00 00       	jmp    f01042f0 <trap+0x205>
        return;
    }
    if (tf->tf_trapno == T_BRKPT) {
f010423c:	83 f8 03             	cmp    $0x3,%eax
f010423f:	75 11                	jne    f0104252 <trap+0x167>
        monitor(tf);
f0104241:	83 ec 0c             	sub    $0xc,%esp
f0104244:	56                   	push   %esi
f0104245:	e8 79 c7 ff ff       	call   f01009c3 <monitor>
f010424a:	83 c4 10             	add    $0x10,%esp
f010424d:	e9 9e 00 00 00       	jmp    f01042f0 <trap+0x205>
        return;
    }
    if (tf ->tf_trapno == T_SYSCALL) {
f0104252:	83 f8 30             	cmp    $0x30,%eax
f0104255:	75 21                	jne    f0104278 <trap+0x18d>
		tf->tf_regs.reg_eax  = syscall( tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx,
f0104257:	83 ec 08             	sub    $0x8,%esp
f010425a:	ff 76 04             	pushl  0x4(%esi)
f010425d:	ff 36                	pushl  (%esi)
f010425f:	ff 76 10             	pushl  0x10(%esi)
f0104262:	ff 76 18             	pushl  0x18(%esi)
f0104265:	ff 76 14             	pushl  0x14(%esi)
f0104268:	ff 76 1c             	pushl  0x1c(%esi)
f010426b:	e8 51 03 00 00       	call   f01045c1 <syscall>
f0104270:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104273:	83 c4 20             	add    $0x20,%esp
f0104276:	eb 78                	jmp    f01042f0 <trap+0x205>
	// LAB 6: Your code here.
	
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0104278:	83 f8 20             	cmp    $0x20,%eax
f010427b:	75 18                	jne    f0104295 <trap+0x1aa>
    {
    	lapic_eoi();
f010427d:	e8 c3 1b 00 00       	call   f0105e45 <lapic_eoi>
    	if (cpunum() == 0)
f0104282:	e8 73 1a 00 00       	call   f0105cfa <cpunum>
f0104287:	85 c0                	test   %eax,%eax
f0104289:	75 05                	jne    f0104290 <trap+0x1a5>
   		{
     		time_tick();
f010428b:	e8 12 25 00 00       	call   f01067a2 <time_tick>
   		}
        sched_yield();
f0104290:	e8 78 02 00 00       	call   f010450d <sched_yield>
   	}
	

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0104295:	83 f8 21             	cmp    $0x21,%eax
f0104298:	75 07                	jne    f01042a1 <trap+0x1b6>
   		kbd_intr();
f010429a:	e8 93 c3 ff ff       	call   f0100632 <kbd_intr>
f010429f:	eb 4f                	jmp    f01042f0 <trap+0x205>
   		return;
 	}

 	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f01042a1:	83 f8 24             	cmp    $0x24,%eax
f01042a4:	75 07                	jne    f01042ad <trap+0x1c2>
   		serial_intr();
f01042a6:	e8 6b c3 ff ff       	call   f0100616 <serial_intr>
f01042ab:	eb 43                	jmp    f01042f0 <trap+0x205>
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01042ad:	83 ec 0c             	sub    $0xc,%esp
f01042b0:	56                   	push   %esi
f01042b1:	e8 95 fb ff ff       	call   f0103e4b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01042b6:	83 c4 10             	add    $0x10,%esp
f01042b9:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042be:	75 17                	jne    f01042d7 <trap+0x1ec>
		panic("unhandled trap in kernel");
f01042c0:	83 ec 04             	sub    $0x4,%esp
f01042c3:	68 f8 7e 10 f0       	push   $0xf0107ef8
f01042c8:	68 3a 01 00 00       	push   $0x13a
f01042cd:	68 af 7e 10 f0       	push   $0xf0107eaf
f01042d2:	e8 69 bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01042d7:	e8 1e 1a 00 00       	call   f0105cfa <cpunum>
f01042dc:	83 ec 0c             	sub    $0xc,%esp
f01042df:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e2:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f01042e8:	e8 e4 f0 ff ff       	call   f01033d1 <env_destroy>
f01042ed:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01042f0:	e8 05 1a 00 00       	call   f0105cfa <cpunum>
f01042f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f8:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f01042ff:	74 2a                	je     f010432b <trap+0x240>
f0104301:	e8 f4 19 00 00       	call   f0105cfa <cpunum>
f0104306:	6b c0 74             	imul   $0x74,%eax,%eax
f0104309:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f010430f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104313:	75 16                	jne    f010432b <trap+0x240>
		env_run(curenv);
f0104315:	e8 e0 19 00 00       	call   f0105cfa <cpunum>
f010431a:	83 ec 0c             	sub    $0xc,%esp
f010431d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104320:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104326:	e8 45 f1 ff ff       	call   f0103470 <env_run>
	else
		sched_yield();
f010432b:	e8 dd 01 00 00       	call   f010450d <sched_yield>

f0104330 <divzero_entry>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	
	TRAPHANDLER_NOEC(divzero_entry, T_DIVIDE);
f0104330:	6a 00                	push   $0x0
f0104332:	6a 00                	push   $0x0
f0104334:	e9 ef 00 00 00       	jmp    f0104428 <_alltraps>
f0104339:	90                   	nop

f010433a <debug_entry>:
	TRAPHANDLER_NOEC(debug_entry, T_DEBUG);
f010433a:	6a 00                	push   $0x0
f010433c:	6a 01                	push   $0x1
f010433e:	e9 e5 00 00 00       	jmp    f0104428 <_alltraps>
f0104343:	90                   	nop

f0104344 <nmi_entry>:
	TRAPHANDLER_NOEC(nmi_entry, T_NMI);
f0104344:	6a 00                	push   $0x0
f0104346:	6a 02                	push   $0x2
f0104348:	e9 db 00 00 00       	jmp    f0104428 <_alltraps>
f010434d:	90                   	nop

f010434e <brkpt_entry>:
	TRAPHANDLER_NOEC(brkpt_entry, T_BRKPT);
f010434e:	6a 00                	push   $0x0
f0104350:	6a 03                	push   $0x3
f0104352:	e9 d1 00 00 00       	jmp    f0104428 <_alltraps>
f0104357:	90                   	nop

f0104358 <oflow_entry>:
	TRAPHANDLER_NOEC(oflow_entry, T_OFLOW);
f0104358:	6a 00                	push   $0x0
f010435a:	6a 04                	push   $0x4
f010435c:	e9 c7 00 00 00       	jmp    f0104428 <_alltraps>
f0104361:	90                   	nop

f0104362 <bound_entry>:
	TRAPHANDLER_NOEC(bound_entry, T_BOUND);
f0104362:	6a 00                	push   $0x0
f0104364:	6a 05                	push   $0x5
f0104366:	e9 bd 00 00 00       	jmp    f0104428 <_alltraps>
f010436b:	90                   	nop

f010436c <illop_entry>:
	TRAPHANDLER_NOEC(illop_entry, T_ILLOP);
f010436c:	6a 00                	push   $0x0
f010436e:	6a 06                	push   $0x6
f0104370:	e9 b3 00 00 00       	jmp    f0104428 <_alltraps>
f0104375:	90                   	nop

f0104376 <device_entry>:
	TRAPHANDLER_NOEC(device_entry, T_DEVICE);
f0104376:	6a 00                	push   $0x0
f0104378:	6a 07                	push   $0x7
f010437a:	e9 a9 00 00 00       	jmp    f0104428 <_alltraps>
f010437f:	90                   	nop

f0104380 <dblflt_entry>:
	TRAPHANDLER(dblflt_entry, T_DBLFLT);
f0104380:	6a 08                	push   $0x8
f0104382:	e9 a1 00 00 00       	jmp    f0104428 <_alltraps>
f0104387:	90                   	nop

f0104388 <tss_entry>:
	TRAPHANDLER(tss_entry, T_TSS);
f0104388:	6a 0a                	push   $0xa
f010438a:	e9 99 00 00 00       	jmp    f0104428 <_alltraps>
f010438f:	90                   	nop

f0104390 <segnp_entry>:
	TRAPHANDLER(segnp_entry, T_SEGNP);
f0104390:	6a 0b                	push   $0xb
f0104392:	e9 91 00 00 00       	jmp    f0104428 <_alltraps>
f0104397:	90                   	nop

f0104398 <stack_entry>:
	TRAPHANDLER(stack_entry, T_STACK);
f0104398:	6a 0c                	push   $0xc
f010439a:	e9 89 00 00 00       	jmp    f0104428 <_alltraps>
f010439f:	90                   	nop

f01043a0 <gpflt_entry>:
	TRAPHANDLER(gpflt_entry, T_GPFLT);
f01043a0:	6a 0d                	push   $0xd
f01043a2:	e9 81 00 00 00       	jmp    f0104428 <_alltraps>
f01043a7:	90                   	nop

f01043a8 <pgflt_entry>:
	TRAPHANDLER(pgflt_entry, T_PGFLT);
f01043a8:	6a 0e                	push   $0xe
f01043aa:	eb 7c                	jmp    f0104428 <_alltraps>

f01043ac <fperr_entry>:
	TRAPHANDLER_NOEC(fperr_entry, T_FPERR);
f01043ac:	6a 00                	push   $0x0
f01043ae:	6a 10                	push   $0x10
f01043b0:	eb 76                	jmp    f0104428 <_alltraps>

f01043b2 <align_entry>:
	TRAPHANDLER(align_entry, T_ALIGN);
f01043b2:	6a 11                	push   $0x11
f01043b4:	eb 72                	jmp    f0104428 <_alltraps>

f01043b6 <mchk_entry>:
	TRAPHANDLER_NOEC(mchk_entry, T_MCHK);
f01043b6:	6a 00                	push   $0x0
f01043b8:	6a 12                	push   $0x12
f01043ba:	eb 6c                	jmp    f0104428 <_alltraps>

f01043bc <simderr_entry>:
	TRAPHANDLER_NOEC(simderr_entry, T_SIMDERR);
f01043bc:	6a 00                	push   $0x0
f01043be:	6a 13                	push   $0x13
f01043c0:	eb 66                	jmp    f0104428 <_alltraps>

f01043c2 <syscall_entry>:
	
	TRAPHANDLER_NOEC(syscall_entry, T_SYSCALL);
f01043c2:	6a 00                	push   $0x0
f01043c4:	6a 30                	push   $0x30
f01043c6:	eb 60                	jmp    f0104428 <_alltraps>

f01043c8 <th32>:

	TRAPHANDLER_NOEC(th32, 32)
f01043c8:	6a 00                	push   $0x0
f01043ca:	6a 20                	push   $0x20
f01043cc:	eb 5a                	jmp    f0104428 <_alltraps>

f01043ce <th33>:
    TRAPHANDLER_NOEC(th33, 33)
f01043ce:	6a 00                	push   $0x0
f01043d0:	6a 21                	push   $0x21
f01043d2:	eb 54                	jmp    f0104428 <_alltraps>

f01043d4 <th34>:
    TRAPHANDLER_NOEC(th34, 34)
f01043d4:	6a 00                	push   $0x0
f01043d6:	6a 22                	push   $0x22
f01043d8:	eb 4e                	jmp    f0104428 <_alltraps>

f01043da <th35>:
    TRAPHANDLER_NOEC(th35, 35)
f01043da:	6a 00                	push   $0x0
f01043dc:	6a 23                	push   $0x23
f01043de:	eb 48                	jmp    f0104428 <_alltraps>

f01043e0 <th36>:
    TRAPHANDLER_NOEC(th36, 36)
f01043e0:	6a 00                	push   $0x0
f01043e2:	6a 24                	push   $0x24
f01043e4:	eb 42                	jmp    f0104428 <_alltraps>

f01043e6 <th37>:
    TRAPHANDLER_NOEC(th37, 37)
f01043e6:	6a 00                	push   $0x0
f01043e8:	6a 25                	push   $0x25
f01043ea:	eb 3c                	jmp    f0104428 <_alltraps>

f01043ec <th38>:
    TRAPHANDLER_NOEC(th38, 38)
f01043ec:	6a 00                	push   $0x0
f01043ee:	6a 26                	push   $0x26
f01043f0:	eb 36                	jmp    f0104428 <_alltraps>

f01043f2 <th39>:
    TRAPHANDLER_NOEC(th39, 39)
f01043f2:	6a 00                	push   $0x0
f01043f4:	6a 27                	push   $0x27
f01043f6:	eb 30                	jmp    f0104428 <_alltraps>

f01043f8 <th40>:
    TRAPHANDLER_NOEC(th40, 40)
f01043f8:	6a 00                	push   $0x0
f01043fa:	6a 28                	push   $0x28
f01043fc:	eb 2a                	jmp    f0104428 <_alltraps>

f01043fe <th41>:
    TRAPHANDLER_NOEC(th41, 41)
f01043fe:	6a 00                	push   $0x0
f0104400:	6a 29                	push   $0x29
f0104402:	eb 24                	jmp    f0104428 <_alltraps>

f0104404 <th42>:
    TRAPHANDLER_NOEC(th42, 42)
f0104404:	6a 00                	push   $0x0
f0104406:	6a 2a                	push   $0x2a
f0104408:	eb 1e                	jmp    f0104428 <_alltraps>

f010440a <th43>:
    TRAPHANDLER_NOEC(th43, 43)
f010440a:	6a 00                	push   $0x0
f010440c:	6a 2b                	push   $0x2b
f010440e:	eb 18                	jmp    f0104428 <_alltraps>

f0104410 <th44>:
    TRAPHANDLER_NOEC(th44, 44)
f0104410:	6a 00                	push   $0x0
f0104412:	6a 2c                	push   $0x2c
f0104414:	eb 12                	jmp    f0104428 <_alltraps>

f0104416 <th45>:
    TRAPHANDLER_NOEC(th45, 45)
f0104416:	6a 00                	push   $0x0
f0104418:	6a 2d                	push   $0x2d
f010441a:	eb 0c                	jmp    f0104428 <_alltraps>

f010441c <th46>:
    TRAPHANDLER_NOEC(th46, 46)
f010441c:	6a 00                	push   $0x0
f010441e:	6a 2e                	push   $0x2e
f0104420:	eb 06                	jmp    f0104428 <_alltraps>

f0104422 <th47>:
    TRAPHANDLER_NOEC(th47, 47)
f0104422:	6a 00                	push   $0x0
f0104424:	6a 2f                	push   $0x2f
f0104426:	eb 00                	jmp    f0104428 <_alltraps>

f0104428 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
	pushl %ds
f0104428:	1e                   	push   %ds
    pushl %es
f0104429:	06                   	push   %es
    pushal
f010442a:	60                   	pusha  
    movw $GD_KD, %ax
f010442b:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds
f010442f:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f0104431:	8e c0                	mov    %eax,%es
    pushl %esp
f0104433:	54                   	push   %esp
    call trap
f0104434:	e8 b2 fc ff ff       	call   f01040eb <trap>

f0104439 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104439:	55                   	push   %ebp
f010443a:	89 e5                	mov    %esp,%ebp
f010443c:	83 ec 08             	sub    $0x8,%esp
f010443f:	a1 48 12 2a f0       	mov    0xf02a1248,%eax
f0104444:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104447:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010444c:	8b 02                	mov    (%edx),%eax
f010444e:	83 e8 01             	sub    $0x1,%eax
f0104451:	83 f8 02             	cmp    $0x2,%eax
f0104454:	76 10                	jbe    f0104466 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104456:	83 c1 01             	add    $0x1,%ecx
f0104459:	83 c2 7c             	add    $0x7c,%edx
f010445c:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104462:	75 e8                	jne    f010444c <sched_halt+0x13>
f0104464:	eb 08                	jmp    f010446e <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104466:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010446c:	75 1f                	jne    f010448d <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f010446e:	83 ec 0c             	sub    $0xc,%esp
f0104471:	68 d0 80 10 f0       	push   $0xf01080d0
f0104476:	e8 71 f2 ff ff       	call   f01036ec <cprintf>
f010447b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010447e:	83 ec 0c             	sub    $0xc,%esp
f0104481:	6a 00                	push   $0x0
f0104483:	e8 3b c5 ff ff       	call   f01009c3 <monitor>
f0104488:	83 c4 10             	add    $0x10,%esp
f010448b:	eb f1                	jmp    f010447e <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010448d:	e8 68 18 00 00       	call   f0105cfa <cpunum>
f0104492:	6b c0 74             	imul   $0x74,%eax,%eax
f0104495:	c7 80 28 20 2a f0 00 	movl   $0x0,-0xfd5dfd8(%eax)
f010449c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010449f:	a1 b0 1e 2a f0       	mov    0xf02a1eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01044a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044a9:	77 12                	ja     f01044bd <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044ab:	50                   	push   %eax
f01044ac:	68 c8 6a 10 f0       	push   $0xf0106ac8
f01044b1:	6a 50                	push   $0x50
f01044b3:	68 f9 80 10 f0       	push   $0xf01080f9
f01044b8:	e8 83 bb ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01044bd:	05 00 00 00 10       	add    $0x10000000,%eax
f01044c2:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01044c5:	e8 30 18 00 00       	call   f0105cfa <cpunum>
f01044ca:	6b d0 74             	imul   $0x74,%eax,%edx
f01044cd:	81 c2 20 20 2a f0    	add    $0xf02a2020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01044d3:	b8 02 00 00 00       	mov    $0x2,%eax
f01044d8:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01044dc:	83 ec 0c             	sub    $0xc,%esp
f01044df:	68 c0 33 12 f0       	push   $0xf01233c0
f01044e4:	e8 1c 1b 00 00       	call   f0106005 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01044e9:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01044eb:	e8 0a 18 00 00       	call   f0105cfa <cpunum>
f01044f0:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01044f3:	8b 80 30 20 2a f0    	mov    -0xfd5dfd0(%eax),%eax
f01044f9:	bd 00 00 00 00       	mov    $0x0,%ebp
f01044fe:	89 c4                	mov    %eax,%esp
f0104500:	6a 00                	push   $0x0
f0104502:	6a 00                	push   $0x0
f0104504:	fb                   	sti    
f0104505:	f4                   	hlt    
f0104506:	eb fd                	jmp    f0104505 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104508:	83 c4 10             	add    $0x10,%esp
f010450b:	c9                   	leave  
f010450c:	c3                   	ret    

f010450d <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010450d:	55                   	push   %ebp
f010450e:	89 e5                	mov    %esp,%ebp
f0104510:	56                   	push   %esi
f0104511:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	int curenv_idx = 0;
	if(curenv != NULL)
f0104512:	e8 e3 17 00 00       	call   f0105cfa <cpunum>
f0104517:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv_idx = ENVX(curenv->env_id);
	else
		curenv_idx = 0;
f010451a:	b9 00 00 00 00       	mov    $0x0,%ecx
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	int curenv_idx = 0;
	if(curenv != NULL)
f010451f:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f0104526:	74 17                	je     f010453f <sched_yield+0x32>
		curenv_idx = ENVX(curenv->env_id);
f0104528:	e8 cd 17 00 00       	call   f0105cfa <cpunum>
f010452d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104530:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104536:	8b 48 48             	mov    0x48(%eax),%ecx
f0104539:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		curenv_idx = 0;
   	int i;
   	for (i = 0; i < NENV; ++i)
   	{
       	int j = (curenv_idx + i) % NENV;
       	if (envs[j].env_status == ENV_RUNNABLE)
f010453f:	8b 1d 48 12 2a f0    	mov    0xf02a1248,%ebx
f0104545:	89 ca                	mov    %ecx,%edx
f0104547:	81 c1 00 04 00 00    	add    $0x400,%ecx
f010454d:	89 d6                	mov    %edx,%esi
f010454f:	c1 fe 1f             	sar    $0x1f,%esi
f0104552:	c1 ee 16             	shr    $0x16,%esi
f0104555:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0104558:	25 ff 03 00 00       	and    $0x3ff,%eax
f010455d:	29 f0                	sub    %esi,%eax
f010455f:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104562:	01 d8                	add    %ebx,%eax
f0104564:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104568:	75 09                	jne    f0104573 <sched_yield+0x66>
       	{
           	env_run(envs + j);
f010456a:	83 ec 0c             	sub    $0xc,%esp
f010456d:	50                   	push   %eax
f010456e:	e8 fd ee ff ff       	call   f0103470 <env_run>
f0104573:	83 c2 01             	add    $0x1,%edx
	if(curenv != NULL)
		curenv_idx = ENVX(curenv->env_id);
	else
		curenv_idx = 0;
   	int i;
   	for (i = 0; i < NENV; ++i)
f0104576:	39 ca                	cmp    %ecx,%edx
f0104578:	75 d3                	jne    f010454d <sched_yield+0x40>
       	if (envs[j].env_status == ENV_RUNNABLE)
       	{
           	env_run(envs + j);
       	}
   	}
   	if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f010457a:	e8 7b 17 00 00       	call   f0105cfa <cpunum>
f010457f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104582:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f0104589:	74 2a                	je     f01045b5 <sched_yield+0xa8>
f010458b:	e8 6a 17 00 00       	call   f0105cfa <cpunum>
f0104590:	6b c0 74             	imul   $0x74,%eax,%eax
f0104593:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104599:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010459d:	75 16                	jne    f01045b5 <sched_yield+0xa8>
   	{
       	env_run(curenv);
f010459f:	e8 56 17 00 00       	call   f0105cfa <cpunum>
f01045a4:	83 ec 0c             	sub    $0xc,%esp
f01045a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01045aa:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f01045b0:	e8 bb ee ff ff       	call   f0103470 <env_run>
   	}

	// sched_halt never returns
	sched_halt();
f01045b5:	e8 7f fe ff ff       	call   f0104439 <sched_halt>
}
f01045ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01045bd:	5b                   	pop    %ebx
f01045be:	5e                   	pop    %esi
f01045bf:	5d                   	pop    %ebp
f01045c0:	c3                   	ret    

f01045c1 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01045c1:	55                   	push   %ebp
f01045c2:	89 e5                	mov    %esp,%ebp
f01045c4:	57                   	push   %edi
f01045c5:	56                   	push   %esi
f01045c6:	53                   	push   %ebx
f01045c7:	83 ec 1c             	sub    $0x1c,%esp
f01045ca:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int32_t ret = 0;
    switch (syscallno) 
f01045cd:	83 f8 0f             	cmp    $0xf,%eax
f01045d0:	0f 87 6e 05 00 00    	ja     f0104b44 <syscall+0x583>
f01045d6:	ff 24 85 0c 81 10 f0 	jmp    *-0xfef7ef4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(void *) s, len, PTE_U);
f01045dd:	e8 18 17 00 00       	call   f0105cfa <cpunum>
f01045e2:	6a 04                	push   $0x4
f01045e4:	ff 75 10             	pushl  0x10(%ebp)
f01045e7:	ff 75 0c             	pushl  0xc(%ebp)
f01045ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ed:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f01045f3:	e8 ed e7 ff ff       	call   f0102de5 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01045f8:	83 c4 0c             	add    $0xc,%esp
f01045fb:	ff 75 0c             	pushl  0xc(%ebp)
f01045fe:	ff 75 10             	pushl  0x10(%ebp)
f0104601:	68 06 81 10 f0       	push   $0xf0108106
f0104606:	e8 e1 f0 ff ff       	call   f01036ec <cprintf>
f010460b:	83 c4 10             	add    $0x10,%esp
	int32_t ret = 0;
    switch (syscallno) 
    {
        case SYS_cputs: 
            sys_cputs((char*)a1, a2);
            ret = 0;
f010460e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104613:	e9 38 05 00 00       	jmp    f0104b50 <syscall+0x58f>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104618:	e8 27 c0 ff ff       	call   f0100644 <cons_getc>
f010461d:	89 c3                	mov    %eax,%ebx
            sys_cputs((char*)a1, a2);
            ret = 0;
            break;
        case SYS_cgetc:
            ret = sys_cgetc();
            break;
f010461f:	e9 2c 05 00 00       	jmp    f0104b50 <syscall+0x58f>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104624:	e8 d1 16 00 00       	call   f0105cfa <cpunum>
f0104629:	6b c0 74             	imul   $0x74,%eax,%eax
f010462c:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104632:	8b 58 48             	mov    0x48(%eax),%ebx
        case SYS_cgetc:
            ret = sys_cgetc();
            break;
        case SYS_getenvid:
            ret = sys_getenvid();
            break;
f0104635:	e9 16 05 00 00       	jmp    f0104b50 <syscall+0x58f>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010463a:	83 ec 04             	sub    $0x4,%esp
f010463d:	6a 01                	push   $0x1
f010463f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104642:	50                   	push   %eax
f0104643:	ff 75 0c             	pushl  0xc(%ebp)
f0104646:	e8 4f e8 ff ff       	call   f0102e9a <envid2env>
f010464b:	83 c4 10             	add    $0x10,%esp
		return r;
f010464e:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104650:	85 c0                	test   %eax,%eax
f0104652:	0f 88 f8 04 00 00    	js     f0104b50 <syscall+0x58f>
		return r;
	env_destroy(e);
f0104658:	83 ec 0c             	sub    $0xc,%esp
f010465b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010465e:	e8 6e ed ff ff       	call   f01033d1 <env_destroy>
f0104663:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104666:	bb 00 00 00 00       	mov    $0x0,%ebx
f010466b:	e9 e0 04 00 00       	jmp    f0104b50 <syscall+0x58f>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104670:	e8 98 fe ff ff       	call   f010450d <sched_yield>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env * new_env;
	int i = env_alloc(&new_env, curenv->env_id);
f0104675:	e8 80 16 00 00       	call   f0105cfa <cpunum>
f010467a:	83 ec 08             	sub    $0x8,%esp
f010467d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104680:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104686:	ff 70 48             	pushl  0x48(%eax)
f0104689:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010468c:	50                   	push   %eax
f010468d:	e8 28 e9 ff ff       	call   f0102fba <env_alloc>
	if(i == 0){
f0104692:	83 c4 10             	add    $0x10,%esp
		new_env->env_status = ENV_NOT_RUNNABLE;
		memmove(&new_env->env_tf, &curenv->env_tf , sizeof(curenv->env_tf));
		new_env->env_tf.tf_regs.reg_eax = 0;
	}
	else {
		return i;
f0104695:	89 c3                	mov    %eax,%ebx
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env * new_env;
	int i = env_alloc(&new_env, curenv->env_id);
	if(i == 0){
f0104697:	85 c0                	test   %eax,%eax
f0104699:	0f 85 b1 04 00 00    	jne    f0104b50 <syscall+0x58f>
		new_env->env_type = ENV_TYPE_USER;
f010469f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046a2:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
		new_env->env_status = ENV_NOT_RUNNABLE;
f01046a9:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
		memmove(&new_env->env_tf, &curenv->env_tf , sizeof(curenv->env_tf));
f01046b0:	e8 45 16 00 00       	call   f0105cfa <cpunum>
f01046b5:	83 ec 04             	sub    $0x4,%esp
f01046b8:	6a 44                	push   $0x44
f01046ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01046bd:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f01046c3:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046c6:	e8 5c 10 00 00       	call   f0105727 <memmove>
		new_env->env_tf.tf_regs.reg_eax = 0;
f01046cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046ce:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	}
	else {
		return i;
	}	
	return new_env->env_id;
f01046d5:	8b 58 48             	mov    0x48(%eax),%ebx
f01046d8:	83 c4 10             	add    $0x10,%esp
f01046db:	e9 70 04 00 00       	jmp    f0104b50 <syscall+0x58f>
	// check whether the current environment has permission to set
	// envid's status.
	
	struct Env * env;
	int i;
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01046e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01046e3:	83 e8 02             	sub    $0x2,%eax
f01046e6:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01046eb:	75 2c                	jne    f0104719 <syscall+0x158>
	{
        return -E_INVAL;
    }
    
    i = envid2env(envid, &env,1);
f01046ed:	83 ec 04             	sub    $0x4,%esp
f01046f0:	6a 01                	push   $0x1
f01046f2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046f5:	50                   	push   %eax
f01046f6:	ff 75 0c             	pushl  0xc(%ebp)
f01046f9:	e8 9c e7 ff ff       	call   f0102e9a <envid2env>
    if (i)
f01046fe:	83 c4 10             	add    $0x10,%esp
    {
        return i;
f0104701:	89 c3                	mov    %eax,%ebx
	{
        return -E_INVAL;
    }
    
    i = envid2env(envid, &env,1);
    if (i)
f0104703:	85 c0                	test   %eax,%eax
f0104705:	0f 85 45 04 00 00    	jne    f0104b50 <syscall+0x58f>
    {
        return i;
    }
    env->env_status = status;	
f010470b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010470e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104711:	89 7a 54             	mov    %edi,0x54(%edx)
f0104714:	e9 37 04 00 00       	jmp    f0104b50 <syscall+0x58f>
	
	struct Env * env;
	int i;
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
	{
        return -E_INVAL;
f0104719:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010471e:	e9 2d 04 00 00       	jmp    f0104b50 <syscall+0x58f>
	int i;
	//if (((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & (~(PTE_SYSCALL))))
    //{
     //   return -E_INVAL;
    //}
    if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
f0104723:	8b 45 14             	mov    0x14(%ebp),%eax
f0104726:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010472b:	83 f8 05             	cmp    $0x5,%eax
f010472e:	75 73                	jne    f01047a3 <syscall+0x1e2>
		return -E_INVAL;
		
    if (va != ROUNDDOWN(va, PGSIZE) || (uintptr_t)va >= UTOP)
f0104730:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104737:	75 74                	jne    f01047ad <syscall+0x1ec>
f0104739:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104740:	77 6b                	ja     f01047ad <syscall+0x1ec>
    {
        return -E_INVAL;
    }
    i = envid2env(envid, &env, 1);
f0104742:	83 ec 04             	sub    $0x4,%esp
f0104745:	6a 01                	push   $0x1
f0104747:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010474a:	50                   	push   %eax
f010474b:	ff 75 0c             	pushl  0xc(%ebp)
f010474e:	e8 47 e7 ff ff       	call   f0102e9a <envid2env>
    if (i){
f0104753:	83 c4 10             	add    $0x10,%esp
        return i;
f0104756:	89 c3                	mov    %eax,%ebx
    if (va != ROUNDDOWN(va, PGSIZE) || (uintptr_t)va >= UTOP)
    {
        return -E_INVAL;
    }
    i = envid2env(envid, &env, 1);
    if (i){
f0104758:	85 c0                	test   %eax,%eax
f010475a:	0f 85 f0 03 00 00    	jne    f0104b50 <syscall+0x58f>
        return i;
    }
    struct PageInfo * p = page_alloc(ALLOC_ZERO);
f0104760:	83 ec 0c             	sub    $0xc,%esp
f0104763:	6a 01                	push   $0x1
f0104765:	e8 1a c8 ff ff       	call   f0100f84 <page_alloc>
f010476a:	89 c6                	mov    %eax,%esi
    if (p == NULL)
f010476c:	83 c4 10             	add    $0x10,%esp
f010476f:	85 c0                	test   %eax,%eax
f0104771:	74 44                	je     f01047b7 <syscall+0x1f6>
    {
        return -E_NO_MEM;
    }
    //p->pp_ref++;
    result = page_insert(env->env_pgdir, p, va, perm);
f0104773:	ff 75 14             	pushl  0x14(%ebp)
f0104776:	ff 75 10             	pushl  0x10(%ebp)
f0104779:	50                   	push   %eax
f010477a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010477d:	ff 70 60             	pushl  0x60(%eax)
f0104780:	e8 c1 ca ff ff       	call   f0101246 <page_insert>
    if (result != 0)
f0104785:	83 c4 10             	add    $0x10,%esp
    {
        page_free(p);
    }
    
    return result;
f0104788:	89 c3                	mov    %eax,%ebx
    {
        return -E_NO_MEM;
    }
    //p->pp_ref++;
    result = page_insert(env->env_pgdir, p, va, perm);
    if (result != 0)
f010478a:	85 c0                	test   %eax,%eax
f010478c:	0f 84 be 03 00 00    	je     f0104b50 <syscall+0x58f>
    {
        page_free(p);
f0104792:	83 ec 0c             	sub    $0xc,%esp
f0104795:	56                   	push   %esi
f0104796:	e8 60 c8 ff ff       	call   f0100ffb <page_free>
f010479b:	83 c4 10             	add    $0x10,%esp
f010479e:	e9 ad 03 00 00       	jmp    f0104b50 <syscall+0x58f>
	//if (((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & (~(PTE_SYSCALL))))
    //{
     //   return -E_INVAL;
    //}
    if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
		return -E_INVAL;
f01047a3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047a8:	e9 a3 03 00 00       	jmp    f0104b50 <syscall+0x58f>
		
    if (va != ROUNDDOWN(va, PGSIZE) || (uintptr_t)va >= UTOP)
    {
        return -E_INVAL;
f01047ad:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047b2:	e9 99 03 00 00       	jmp    f0104b50 <syscall+0x58f>
        return i;
    }
    struct PageInfo * p = page_alloc(ALLOC_ZERO);
    if (p == NULL)
    {
        return -E_NO_MEM;
f01047b7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01047bc:	e9 8f 03 00 00       	jmp    f0104b50 <syscall+0x58f>
	
	struct Env *srcenv, *dstenv;
	pte_t* pte;
	int error;
	int i;
	i = envid2env(srcenvid, &srcenv, 1);
f01047c1:	83 ec 04             	sub    $0x4,%esp
f01047c4:	6a 01                	push   $0x1
f01047c6:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01047c9:	50                   	push   %eax
f01047ca:	ff 75 0c             	pushl  0xc(%ebp)
f01047cd:	e8 c8 e6 ff ff       	call   f0102e9a <envid2env>
    if (i){
f01047d2:	83 c4 10             	add    $0x10,%esp
        return i;
f01047d5:	89 c3                	mov    %eax,%ebx
	struct Env *srcenv, *dstenv;
	pte_t* pte;
	int error;
	int i;
	i = envid2env(srcenvid, &srcenv, 1);
    if (i){
f01047d7:	85 c0                	test   %eax,%eax
f01047d9:	0f 85 71 03 00 00    	jne    f0104b50 <syscall+0x58f>
        return i;
    }
    
    i = envid2env(dstenvid, &dstenv, 1);
f01047df:	83 ec 04             	sub    $0x4,%esp
f01047e2:	6a 01                	push   $0x1
f01047e4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01047e7:	50                   	push   %eax
f01047e8:	ff 75 14             	pushl  0x14(%ebp)
f01047eb:	e8 aa e6 ff ff       	call   f0102e9a <envid2env>
    if (i){
f01047f0:	83 c4 10             	add    $0x10,%esp
        return i;
f01047f3:	89 c3                	mov    %eax,%ebx
    if (i){
        return i;
    }
    
    i = envid2env(dstenvid, &dstenv, 1);
    if (i){
f01047f5:	85 c0                	test   %eax,%eax
f01047f7:	0f 85 53 03 00 00    	jne    f0104b50 <syscall+0x58f>
        return i;
    }
    if (srcva != ROUNDDOWN(srcva, PGSIZE) || (uintptr_t)srcva >= UTOP )
f01047fd:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104804:	75 7b                	jne    f0104881 <syscall+0x2c0>
f0104806:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010480d:	77 72                	ja     f0104881 <syscall+0x2c0>
    {
        return -E_INVAL;
    }
    if (dstva != ROUNDDOWN(dstva, PGSIZE) || (uintptr_t)dstva >= UTOP)
f010480f:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104816:	75 73                	jne    f010488b <syscall+0x2ca>
f0104818:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010481f:	77 6a                	ja     f010488b <syscall+0x2ca>
    {
        return -E_INVAL;
    }
    
    struct PageInfo *p = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104821:	83 ec 04             	sub    $0x4,%esp
f0104824:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104827:	50                   	push   %eax
f0104828:	ff 75 10             	pushl  0x10(%ebp)
f010482b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010482e:	ff 70 60             	pushl  0x60(%eax)
f0104831:	e8 33 c9 ff ff       	call   f0101169 <page_lookup>
    
    if (!p)
f0104836:	83 c4 10             	add    $0x10,%esp
f0104839:	85 c0                	test   %eax,%eax
f010483b:	74 58                	je     f0104895 <syscall+0x2d4>
    {
        return -E_INVAL;
    }
    
    if (((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & (~(PTE_SYSCALL))) || ((perm & PTE_W) & (*pte)) != (perm & PTE_W))
f010483d:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104840:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104846:	83 fa 05             	cmp    $0x5,%edx
f0104849:	75 54                	jne    f010489f <syscall+0x2de>
f010484b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010484e:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104851:	23 0a                	and    (%edx),%ecx
f0104853:	89 ca                	mov    %ecx,%edx
f0104855:	33 55 1c             	xor    0x1c(%ebp),%edx
f0104858:	f6 c2 02             	test   $0x2,%dl
f010485b:	75 4c                	jne    f01048a9 <syscall+0x2e8>
    {
        return -E_INVAL;
    }
    
	if (( error = page_insert(dstenv->env_pgdir, p, dstva, perm)) < 0)
f010485d:	ff 75 1c             	pushl  0x1c(%ebp)
f0104860:	ff 75 18             	pushl  0x18(%ebp)
f0104863:	50                   	push   %eax
f0104864:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104867:	ff 70 60             	pushl  0x60(%eax)
f010486a:	e8 d7 c9 ff ff       	call   f0101246 <page_insert>
f010486f:	83 c4 10             	add    $0x10,%esp
f0104872:	85 c0                	test   %eax,%eax
f0104874:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104879:	0f 4e d8             	cmovle %eax,%ebx
f010487c:	e9 cf 02 00 00       	jmp    f0104b50 <syscall+0x58f>
    if (i){
        return i;
    }
    if (srcva != ROUNDDOWN(srcva, PGSIZE) || (uintptr_t)srcva >= UTOP )
    {
        return -E_INVAL;
f0104881:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104886:	e9 c5 02 00 00       	jmp    f0104b50 <syscall+0x58f>
    }
    if (dstva != ROUNDDOWN(dstva, PGSIZE) || (uintptr_t)dstva >= UTOP)
    {
        return -E_INVAL;
f010488b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104890:	e9 bb 02 00 00       	jmp    f0104b50 <syscall+0x58f>
    
    struct PageInfo *p = page_lookup(srcenv->env_pgdir, srcva, &pte);
    
    if (!p)
    {
        return -E_INVAL;
f0104895:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010489a:	e9 b1 02 00 00       	jmp    f0104b50 <syscall+0x58f>
    }
    
    if (((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & (~(PTE_SYSCALL))) || ((perm & PTE_W) & (*pte)) != (perm & PTE_W))
    {
        return -E_INVAL;
f010489f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048a4:	e9 a7 02 00 00       	jmp    f0104b50 <syscall+0x58f>
f01048a9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        	break;
        case SYS_page_alloc:
       		return sys_page_alloc(a1, (void *)a2, a3);
       		break;
        case SYS_page_map:
       		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f01048ae:	e9 9d 02 00 00       	jmp    f0104b50 <syscall+0x58f>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
    struct Env * env;
    int error;
  	error = envid2env(envid, &env, 1);
f01048b3:	83 ec 04             	sub    $0x4,%esp
f01048b6:	6a 01                	push   $0x1
f01048b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048bb:	50                   	push   %eax
f01048bc:	ff 75 0c             	pushl  0xc(%ebp)
f01048bf:	e8 d6 e5 ff ff       	call   f0102e9a <envid2env>
    if (error)
f01048c4:	83 c4 10             	add    $0x10,%esp
      return error;
f01048c7:	89 c3                	mov    %eax,%ebx
{
	// Hint: This function is a wrapper around page_remove().
    struct Env * env;
    int error;
  	error = envid2env(envid, &env, 1);
    if (error)
f01048c9:	85 c0                	test   %eax,%eax
f01048cb:	0f 85 7f 02 00 00    	jne    f0104b50 <syscall+0x58f>
      return error;

    if (va != ROUNDDOWN(va, PGSIZE) || (uintptr_t)va >= UTOP)
f01048d1:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048d8:	75 27                	jne    f0104901 <syscall+0x340>
f01048da:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048e1:	77 1e                	ja     f0104901 <syscall+0x340>
    {
        return -E_INVAL;
    }
    page_remove(env->env_pgdir, va);
f01048e3:	83 ec 08             	sub    $0x8,%esp
f01048e6:	ff 75 10             	pushl  0x10(%ebp)
f01048e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048ec:	ff 70 60             	pushl  0x60(%eax)
f01048ef:	e8 04 c9 ff ff       	call   f01011f8 <page_remove>
f01048f4:	83 c4 10             	add    $0x10,%esp
    return 0;
f01048f7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048fc:	e9 4f 02 00 00       	jmp    f0104b50 <syscall+0x58f>
    if (error)
      return error;

    if (va != ROUNDDOWN(va, PGSIZE) || (uintptr_t)va >= UTOP)
    {
        return -E_INVAL;
f0104901:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
       		break;
        case SYS_page_map:
       		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
       		break;
        case SYS_page_unmap:
       		return sys_page_unmap(a1, (void *) a2);	
f0104906:	e9 45 02 00 00       	jmp    f0104b50 <syscall+0x58f>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *env;
	int i; 
	i = envid2env(envid, &env,1);
f010490b:	83 ec 04             	sub    $0x4,%esp
f010490e:	6a 01                	push   $0x1
f0104910:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104913:	50                   	push   %eax
f0104914:	ff 75 0c             	pushl  0xc(%ebp)
f0104917:	e8 7e e5 ff ff       	call   f0102e9a <envid2env>
    if (i)
f010491c:	83 c4 10             	add    $0x10,%esp
f010491f:	85 c0                	test   %eax,%eax
f0104921:	75 09                	jne    f010492c <syscall+0x36b>
    {
        return i;
    }
    env->env_pgfault_upcall = func;
f0104923:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104926:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104929:	89 4a 64             	mov    %ecx,0x64(%edx)
       		break;
        case SYS_page_unmap:
       		return sys_page_unmap(a1, (void *) a2);	
       		break;
       	case SYS_env_set_pgfault_upcall:
       		return sys_env_set_pgfault_upcall(a1, (void *) a2);
f010492c:	89 c3                	mov    %eax,%ebx
f010492e:	e9 1d 02 00 00       	jmp    f0104b50 <syscall+0x58f>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * targetEnv;
	if (envid2env(envid, &targetEnv, 0))
f0104933:	83 ec 04             	sub    $0x4,%esp
f0104936:	6a 00                	push   $0x0
f0104938:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010493b:	50                   	push   %eax
f010493c:	ff 75 0c             	pushl  0xc(%ebp)
f010493f:	e8 56 e5 ff ff       	call   f0102e9a <envid2env>
f0104944:	89 c3                	mov    %eax,%ebx
f0104946:	83 c4 10             	add    $0x10,%esp
f0104949:	85 c0                	test   %eax,%eax
f010494b:	0f 85 0a 01 00 00    	jne    f0104a5b <syscall+0x49a>
		return -E_BAD_ENV;

	if(targetEnv->env_ipc_recving  == 0)
f0104951:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104954:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104958:	0f 84 07 01 00 00    	je     f0104a65 <syscall+0x4a4>
		return -E_IPC_NOT_RECV;

	if( (uint32_t)srcva < UTOP && ((uint32_t)srcva % PGSIZE != 0))
f010495e:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104965:	0f 87 b2 00 00 00    	ja     f0104a1d <syscall+0x45c>
f010496b:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104972:	0f 85 f7 00 00 00    	jne    f0104a6f <syscall+0x4ae>
	}

	// All the sender side checks are done.
	//Check for page_insert errors now and mark the destination environment ENV_RUNNABLE.

	if((uint32_t)targetEnv->env_ipc_dstva < UTOP && (uint32_t)srcva < UTOP)
f0104978:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f010497f:	0f 87 98 00 00 00    	ja     f0104a1d <syscall+0x45c>
	{
		//int r;

		if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
f0104985:	8b 45 18             	mov    0x18(%ebp),%eax
f0104988:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010498d:	83 f8 05             	cmp    $0x5,%eax
f0104990:	75 59                	jne    f01049eb <syscall+0x42a>
		{
			//cprintf("Permission failure\n");
			return -E_INVAL;
		}	
		pte_t * pte;
		struct PageInfo * pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104992:	e8 63 13 00 00       	call   f0105cfa <cpunum>
f0104997:	83 ec 04             	sub    $0x4,%esp
f010499a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010499d:	52                   	push   %edx
f010499e:	ff 75 14             	pushl  0x14(%ebp)
f01049a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a4:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01049aa:	ff 70 60             	pushl  0x60(%eax)
f01049ad:	e8 b7 c7 ff ff       	call   f0101169 <page_lookup>
		if(!pp)
f01049b2:	83 c4 10             	add    $0x10,%esp
f01049b5:	85 c0                	test   %eax,%eax
f01049b7:	74 3c                	je     f01049f5 <syscall+0x434>
			return -E_INVAL;
		if(!(perm & PTE_W && *pte & PTE_W))
f01049b9:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01049bd:	74 40                	je     f01049ff <syscall+0x43e>
f01049bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01049c2:	f6 02 02             	testb  $0x2,(%edx)
f01049c5:	74 42                	je     f0104a09 <syscall+0x448>
		{
			//cprintf("Permission failure in write\n");
			return -E_INVAL;
		}
		
		if((page_insert(targetEnv->env_pgdir, pp, targetEnv->env_ipc_dstva, perm)) < 0)
f01049c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01049ca:	ff 75 18             	pushl  0x18(%ebp)
f01049cd:	ff 72 6c             	pushl  0x6c(%edx)
f01049d0:	50                   	push   %eax
f01049d1:	ff 72 60             	pushl  0x60(%edx)
f01049d4:	e8 6d c8 ff ff       	call   f0101246 <page_insert>
f01049d9:	83 c4 10             	add    $0x10,%esp
f01049dc:	85 c0                	test   %eax,%eax
f01049de:	78 33                	js     f0104a13 <syscall+0x452>
			return -E_NO_MEM;	
		targetEnv->env_ipc_perm = perm;
f01049e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049e3:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01049e6:	89 48 78             	mov    %ecx,0x78(%eax)
f01049e9:	eb 39                	jmp    f0104a24 <syscall+0x463>
		//int r;

		if ((perm & PTE_U) != PTE_U || (perm & PTE_P) != PTE_P  || (perm & ~PTE_SYSCALL) != 0 )
		{
			//cprintf("Permission failure\n");
			return -E_INVAL;
f01049eb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049f0:	e9 5b 01 00 00       	jmp    f0104b50 <syscall+0x58f>
		}	
		pte_t * pte;
		struct PageInfo * pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if(!pp)
			return -E_INVAL;
f01049f5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049fa:	e9 51 01 00 00       	jmp    f0104b50 <syscall+0x58f>
		if(!(perm & PTE_W && *pte & PTE_W))
		{
			//cprintf("Permission failure in write\n");
			return -E_INVAL;
f01049ff:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a04:	e9 47 01 00 00       	jmp    f0104b50 <syscall+0x58f>
f0104a09:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a0e:	e9 3d 01 00 00       	jmp    f0104b50 <syscall+0x58f>
		}
		
		if((page_insert(targetEnv->env_pgdir, pp, targetEnv->env_ipc_dstva, perm)) < 0)
			return -E_NO_MEM;	
f0104a13:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104a18:	e9 33 01 00 00       	jmp    f0104b50 <syscall+0x58f>
		targetEnv->env_ipc_perm = perm;
	}
	else
		targetEnv->env_ipc_perm = 0;
f0104a1d:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	

	targetEnv->env_ipc_recving = false;
f0104a24:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104a27:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	targetEnv->env_ipc_value = value;
f0104a2b:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a2e:	89 46 70             	mov    %eax,0x70(%esi)
	targetEnv->env_ipc_from = curenv->env_id;
f0104a31:	e8 c4 12 00 00       	call   f0105cfa <cpunum>
f0104a36:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a39:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104a3f:	8b 40 48             	mov    0x48(%eax),%eax
f0104a42:	89 46 74             	mov    %eax,0x74(%esi)
	targetEnv->env_status = ENV_RUNNABLE;
f0104a45:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a48:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	targetEnv->env_tf.tf_regs.reg_eax = 0;
f0104a4f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104a56:	e9 f5 00 00 00       	jmp    f0104b50 <syscall+0x58f>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * targetEnv;
	if (envid2env(envid, &targetEnv, 0))
		return -E_BAD_ENV;
f0104a5b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104a60:	e9 eb 00 00 00       	jmp    f0104b50 <syscall+0x58f>

	if(targetEnv->env_ipc_recving  == 0)
		return -E_IPC_NOT_RECV;
f0104a65:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104a6a:	e9 e1 00 00 00       	jmp    f0104b50 <syscall+0x58f>

	if( (uint32_t)srcva < UTOP && ((uint32_t)srcva % PGSIZE != 0))
	{
		//cprintf("srcva:%x\n",srcva);
		return -E_INVAL;
f0104a6f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
       		break;
       	case SYS_env_set_pgfault_upcall:
       		return sys_env_set_pgfault_upcall(a1, (void *) a2);
       		break;	
       	case SYS_ipc_try_send:
       		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104a74:	e9 d7 00 00 00       	jmp    f0104b50 <syscall+0x58f>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void*)UTOP) {
f0104a79:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104a80:	77 0d                	ja     f0104a8f <syscall+0x4ce>
        if (dstva != ROUNDDOWN(dstva, PGSIZE)) {
f0104a82:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a89:	0f 85 bc 00 00 00    	jne    f0104b4b <syscall+0x58a>
            return -E_INVAL;
        }   
    }     
    curenv->env_ipc_recving = 1;
f0104a8f:	e8 66 12 00 00       	call   f0105cfa <cpunum>
f0104a94:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a97:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104a9d:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0104aa1:	e8 54 12 00 00       	call   f0105cfa <cpunum>
f0104aa6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa9:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104aaf:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    curenv->env_ipc_dstva = dstva;
f0104ab6:	e8 3f 12 00 00       	call   f0105cfa <cpunum>
f0104abb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104abe:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ac7:	89 48 6c             	mov    %ecx,0x6c(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104aca:	e8 3e fa ff ff       	call   f010450d <sched_yield>
       		break;
 		case SYS_ipc_recv:
       		return sys_ipc_recv((void *)a1);
       		break;	
       	case SYS_env_set_trapframe:
			return (int32_t)sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);	
f0104acf:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env * e;
	
	if(envid2env(envid, &e,1))
f0104ad2:	83 ec 04             	sub    $0x4,%esp
f0104ad5:	6a 01                	push   $0x1
f0104ad7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ada:	50                   	push   %eax
f0104adb:	ff 75 0c             	pushl  0xc(%ebp)
f0104ade:	e8 b7 e3 ff ff       	call   f0102e9a <envid2env>
f0104ae3:	89 c3                	mov    %eax,%ebx
f0104ae5:	83 c4 10             	add    $0x10,%esp
f0104ae8:	85 c0                	test   %eax,%eax
f0104aea:	75 18                	jne    f0104b04 <syscall+0x543>
		return -E_BAD_ENV;
	//memmove((void *) &e->env_tf, (void *) tf, sizeof(struct Trapframe));
	tf->tf_cs |= 0x3;
f0104aec:	66 83 4e 34 03       	orw    $0x3,0x34(%esi)
	tf->tf_eflags |= FL_IF;
f0104af1:	81 4e 38 00 02 00 00 	orl    $0x200,0x38(%esi)
	e->env_tf = *tf;
f0104af8:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104afd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b02:	eb 4c                	jmp    f0104b50 <syscall+0x58f>
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env * e;
	
	if(envid2env(envid, &e,1))
		return -E_BAD_ENV;
f0104b04:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
       		break;
 		case SYS_ipc_recv:
       		return sys_ipc_recv((void *)a1);
       		break;	
       	case SYS_env_set_trapframe:
			return (int32_t)sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);	
f0104b09:	eb 45                	jmp    f0104b50 <syscall+0x58f>
// Return the current time.
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
	return time_msec();
f0104b0b:	e8 c1 1c 00 00       	call   f01067d1 <time_msec>
f0104b10:	89 c3                	mov    %eax,%ebx
       		break;	
       	case SYS_env_set_trapframe:
			return (int32_t)sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);	
       		break;
       	case SYS_time_msec:
   			return (int32_t)sys_time_msec();	
f0104b12:	eb 3c                	jmp    f0104b50 <syscall+0x58f>
}

// Transmit a network packet
static int sys_net_xmit(uint8_t * addr, size_t length)
{
	user_mem_assert(curenv, addr, length, PTE_U);
f0104b14:	e8 e1 11 00 00       	call   f0105cfa <cpunum>
f0104b19:	6a 04                	push   $0x4
f0104b1b:	ff 75 10             	pushl  0x10(%ebp)
f0104b1e:	ff 75 0c             	pushl  0xc(%ebp)
f0104b21:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b24:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104b2a:	e8 b6 e2 ff ff       	call   f0102de5 <user_mem_assert>
	return e1000_xmit(addr, length);
f0104b2f:	83 c4 08             	add    $0x8,%esp
f0104b32:	ff 75 10             	pushl  0x10(%ebp)
f0104b35:	ff 75 0c             	pushl  0xc(%ebp)
f0104b38:	e8 b1 16 00 00       	call   f01061ee <e1000_xmit>
f0104b3d:	89 c3                	mov    %eax,%ebx
       		break;
       	case SYS_time_msec:
   			return (int32_t)sys_time_msec();	
       		break;
       	case SYS_net_xmit:
	   		return (int32_t)sys_net_xmit((uint8_t *)a1, (size_t)a2);	
f0104b3f:	83 c4 10             	add    $0x10,%esp
f0104b42:	eb 0c                	jmp    f0104b50 <syscall+0x58f>
       		break;			 		    
        default:
            ret = -E_INVAL;
f0104b44:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b49:	eb 05                	jmp    f0104b50 <syscall+0x58f>
       		break;	
       	case SYS_ipc_try_send:
       		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
       		break;
 		case SYS_ipc_recv:
       		return sys_ipc_recv((void *)a1);
f0104b4b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
            ret = -E_INVAL;
    }
    return ret;
    //panic("syscall not implemented");

}
f0104b50:	89 d8                	mov    %ebx,%eax
f0104b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b55:	5b                   	pop    %ebx
f0104b56:	5e                   	pop    %esi
f0104b57:	5f                   	pop    %edi
f0104b58:	5d                   	pop    %ebp
f0104b59:	c3                   	ret    

f0104b5a <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104b5a:	55                   	push   %ebp
f0104b5b:	89 e5                	mov    %esp,%ebp
f0104b5d:	57                   	push   %edi
f0104b5e:	56                   	push   %esi
f0104b5f:	53                   	push   %ebx
f0104b60:	83 ec 14             	sub    $0x14,%esp
f0104b63:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b66:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104b69:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104b6c:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104b6f:	8b 1a                	mov    (%edx),%ebx
f0104b71:	8b 01                	mov    (%ecx),%eax
f0104b73:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b76:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104b7d:	eb 7f                	jmp    f0104bfe <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b82:	01 d8                	add    %ebx,%eax
f0104b84:	89 c6                	mov    %eax,%esi
f0104b86:	c1 ee 1f             	shr    $0x1f,%esi
f0104b89:	01 c6                	add    %eax,%esi
f0104b8b:	d1 fe                	sar    %esi
f0104b8d:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104b90:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b93:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104b96:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104b98:	eb 03                	jmp    f0104b9d <stab_binsearch+0x43>
			m--;
f0104b9a:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104b9d:	39 c3                	cmp    %eax,%ebx
f0104b9f:	7f 0d                	jg     f0104bae <stab_binsearch+0x54>
f0104ba1:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ba5:	83 ea 0c             	sub    $0xc,%edx
f0104ba8:	39 f9                	cmp    %edi,%ecx
f0104baa:	75 ee                	jne    f0104b9a <stab_binsearch+0x40>
f0104bac:	eb 05                	jmp    f0104bb3 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104bae:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104bb1:	eb 4b                	jmp    f0104bfe <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104bb3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104bb6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104bb9:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104bbd:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104bc0:	76 11                	jbe    f0104bd3 <stab_binsearch+0x79>
			*region_left = m;
f0104bc2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104bc5:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104bc7:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104bca:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104bd1:	eb 2b                	jmp    f0104bfe <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104bd3:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104bd6:	73 14                	jae    f0104bec <stab_binsearch+0x92>
			*region_right = m - 1;
f0104bd8:	83 e8 01             	sub    $0x1,%eax
f0104bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104bde:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104be1:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104be3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104bea:	eb 12                	jmp    f0104bfe <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104bec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104bef:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104bf1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104bf5:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104bf7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104bfe:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c01:	0f 8e 78 ff ff ff    	jle    f0104b7f <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c07:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c0b:	75 0f                	jne    f0104c1c <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104c0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c10:	8b 00                	mov    (%eax),%eax
f0104c12:	83 e8 01             	sub    $0x1,%eax
f0104c15:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c18:	89 06                	mov    %eax,(%esi)
f0104c1a:	eb 2c                	jmp    f0104c48 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c1f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104c21:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c24:	8b 0e                	mov    (%esi),%ecx
f0104c26:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c29:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104c2c:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c2f:	eb 03                	jmp    f0104c34 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104c31:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c34:	39 c8                	cmp    %ecx,%eax
f0104c36:	7e 0b                	jle    f0104c43 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104c38:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104c3c:	83 ea 0c             	sub    $0xc,%edx
f0104c3f:	39 df                	cmp    %ebx,%edi
f0104c41:	75 ee                	jne    f0104c31 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104c43:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c46:	89 06                	mov    %eax,(%esi)
	}
}
f0104c48:	83 c4 14             	add    $0x14,%esp
f0104c4b:	5b                   	pop    %ebx
f0104c4c:	5e                   	pop    %esi
f0104c4d:	5f                   	pop    %edi
f0104c4e:	5d                   	pop    %ebp
f0104c4f:	c3                   	ret    

f0104c50 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104c50:	55                   	push   %ebp
f0104c51:	89 e5                	mov    %esp,%ebp
f0104c53:	57                   	push   %edi
f0104c54:	56                   	push   %esi
f0104c55:	53                   	push   %ebx
f0104c56:	83 ec 3c             	sub    $0x3c,%esp
f0104c59:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104c5f:	c7 03 4c 81 10 f0    	movl   $0xf010814c,(%ebx)
	info->eip_line = 0;
f0104c65:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104c6c:	c7 43 08 4c 81 10 f0 	movl   $0xf010814c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104c73:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104c7a:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104c7d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104c84:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104c8a:	0f 87 a3 00 00 00    	ja     f0104d33 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104c90:	e8 65 10 00 00       	call   f0105cfa <cpunum>
f0104c95:	6a 04                	push   $0x4
f0104c97:	6a 10                	push   $0x10
f0104c99:	68 00 00 20 00       	push   $0x200000
f0104c9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca1:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104ca7:	e8 b7 e0 ff ff       	call   f0102d63 <user_mem_check>
f0104cac:	83 c4 10             	add    $0x10,%esp
f0104caf:	85 c0                	test   %eax,%eax
f0104cb1:	0f 85 3e 02 00 00    	jne    f0104ef5 <debuginfo_eip+0x2a5>
			return -1;

		stabs = usd->stabs;
f0104cb7:	a1 00 00 20 00       	mov    0x200000,%eax
f0104cbc:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104cbf:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104cc5:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104ccb:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104cce:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104cd3:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if(user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
f0104cd6:	e8 1f 10 00 00       	call   f0105cfa <cpunum>
f0104cdb:	6a 04                	push   $0x4
f0104cdd:	89 f2                	mov    %esi,%edx
f0104cdf:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104ce2:	29 ca                	sub    %ecx,%edx
f0104ce4:	c1 fa 02             	sar    $0x2,%edx
f0104ce7:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104ced:	52                   	push   %edx
f0104cee:	51                   	push   %ecx
f0104cef:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cf2:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104cf8:	e8 66 e0 ff ff       	call   f0102d63 <user_mem_check>
f0104cfd:	83 c4 10             	add    $0x10,%esp
f0104d00:	85 c0                	test   %eax,%eax
f0104d02:	0f 85 f4 01 00 00    	jne    f0104efc <debuginfo_eip+0x2ac>
			return -1;
		
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f0104d08:	e8 ed 0f 00 00       	call   f0105cfa <cpunum>
f0104d0d:	6a 04                	push   $0x4
f0104d0f:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104d12:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104d15:	29 ca                	sub    %ecx,%edx
f0104d17:	52                   	push   %edx
f0104d18:	51                   	push   %ecx
f0104d19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d1c:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104d22:	e8 3c e0 ff ff       	call   f0102d63 <user_mem_check>
f0104d27:	83 c4 10             	add    $0x10,%esp
f0104d2a:	85 c0                	test   %eax,%eax
f0104d2c:	74 1f                	je     f0104d4d <debuginfo_eip+0xfd>
f0104d2e:	e9 d0 01 00 00       	jmp    f0104f03 <debuginfo_eip+0x2b3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d33:	c7 45 bc 89 80 11 f0 	movl   $0xf0118089,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104d3a:	c7 45 b8 c1 3d 11 f0 	movl   $0xf0113dc1,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104d41:	be c0 3d 11 f0       	mov    $0xf0113dc0,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104d46:	c7 45 c0 78 89 10 f0 	movl   $0xf0108978,-0x40(%ebp)
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d4d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104d50:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104d53:	0f 83 b1 01 00 00    	jae    f0104f0a <debuginfo_eip+0x2ba>
f0104d59:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104d5d:	0f 85 ae 01 00 00    	jne    f0104f11 <debuginfo_eip+0x2c1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104d63:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d6a:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104d6d:	c1 fe 02             	sar    $0x2,%esi
f0104d70:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104d76:	83 e8 01             	sub    $0x1,%eax
f0104d79:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104d7c:	83 ec 08             	sub    $0x8,%esp
f0104d7f:	57                   	push   %edi
f0104d80:	6a 64                	push   $0x64
f0104d82:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104d85:	89 d1                	mov    %edx,%ecx
f0104d87:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d8a:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104d8d:	89 f0                	mov    %esi,%eax
f0104d8f:	e8 c6 fd ff ff       	call   f0104b5a <stab_binsearch>
	if (lfile == 0)
f0104d94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d97:	83 c4 10             	add    $0x10,%esp
f0104d9a:	85 c0                	test   %eax,%eax
f0104d9c:	0f 84 76 01 00 00    	je     f0104f18 <debuginfo_eip+0x2c8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104da2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104da8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104dab:	83 ec 08             	sub    $0x8,%esp
f0104dae:	57                   	push   %edi
f0104daf:	6a 24                	push   $0x24
f0104db1:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104db4:	89 d1                	mov    %edx,%ecx
f0104db6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104db9:	89 f0                	mov    %esi,%eax
f0104dbb:	e8 9a fd ff ff       	call   f0104b5a <stab_binsearch>

	if (lfun <= rfun) {
f0104dc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104dc3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104dc6:	83 c4 10             	add    $0x10,%esp
f0104dc9:	39 d0                	cmp    %edx,%eax
f0104dcb:	7f 2e                	jg     f0104dfb <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104dcd:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104dd0:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104dd3:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104dd6:	8b 36                	mov    (%esi),%esi
f0104dd8:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104ddb:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104dde:	39 ce                	cmp    %ecx,%esi
f0104de0:	73 06                	jae    f0104de8 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104de2:	03 75 b8             	add    -0x48(%ebp),%esi
f0104de5:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104de8:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104deb:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104dee:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104df1:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104df3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104df6:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104df9:	eb 0f                	jmp    f0104e0a <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104dfb:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e01:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104e04:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e07:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e0a:	83 ec 08             	sub    $0x8,%esp
f0104e0d:	6a 3a                	push   $0x3a
f0104e0f:	ff 73 08             	pushl  0x8(%ebx)
f0104e12:	e8 a7 08 00 00       	call   f01056be <strfind>
f0104e17:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e1a:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e1d:	83 c4 08             	add    $0x8,%esp
f0104e20:	57                   	push   %edi
f0104e21:	6a 44                	push   $0x44
f0104e23:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e26:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e29:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104e2c:	89 f8                	mov    %edi,%eax
f0104e2e:	e8 27 fd ff ff       	call   f0104b5a <stab_binsearch>
	//cprintf("%d	%d",lline,rline);
	if(lline <= rline)
f0104e33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e36:	83 c4 10             	add    $0x10,%esp
f0104e39:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104e3c:	0f 8f dd 00 00 00    	jg     f0104f1f <debuginfo_eip+0x2cf>
		info->eip_line = stabs[lline].n_desc;
f0104e42:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e45:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104e48:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104e4c:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e52:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104e56:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e59:	eb 0a                	jmp    f0104e65 <debuginfo_eip+0x215>
f0104e5b:	83 e8 01             	sub    $0x1,%eax
f0104e5e:	83 ea 0c             	sub    $0xc,%edx
f0104e61:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104e65:	39 c7                	cmp    %eax,%edi
f0104e67:	7e 05                	jle    f0104e6e <debuginfo_eip+0x21e>
f0104e69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e6c:	eb 47                	jmp    f0104eb5 <debuginfo_eip+0x265>
	       && stabs[lline].n_type != N_SOL
f0104e6e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104e72:	80 f9 84             	cmp    $0x84,%cl
f0104e75:	75 0e                	jne    f0104e85 <debuginfo_eip+0x235>
f0104e77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e7a:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104e7e:	74 1c                	je     f0104e9c <debuginfo_eip+0x24c>
f0104e80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104e83:	eb 17                	jmp    f0104e9c <debuginfo_eip+0x24c>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104e85:	80 f9 64             	cmp    $0x64,%cl
f0104e88:	75 d1                	jne    f0104e5b <debuginfo_eip+0x20b>
f0104e8a:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104e8e:	74 cb                	je     f0104e5b <debuginfo_eip+0x20b>
f0104e90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e93:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104e97:	74 03                	je     f0104e9c <debuginfo_eip+0x24c>
f0104e99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104e9c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104e9f:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104ea2:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104ea5:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104ea8:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104eab:	29 f8                	sub    %edi,%eax
f0104ead:	39 c2                	cmp    %eax,%edx
f0104eaf:	73 04                	jae    f0104eb5 <debuginfo_eip+0x265>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104eb1:	01 fa                	add    %edi,%edx
f0104eb3:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104eb5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104eb8:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ebb:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ec0:	39 f2                	cmp    %esi,%edx
f0104ec2:	7d 67                	jge    f0104f2b <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
f0104ec4:	83 c2 01             	add    $0x1,%edx
f0104ec7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104eca:	89 d0                	mov    %edx,%eax
f0104ecc:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104ecf:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104ed2:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104ed5:	eb 04                	jmp    f0104edb <debuginfo_eip+0x28b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104ed7:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104edb:	39 c6                	cmp    %eax,%esi
f0104edd:	7e 47                	jle    f0104f26 <debuginfo_eip+0x2d6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104edf:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ee3:	83 c0 01             	add    $0x1,%eax
f0104ee6:	83 c2 0c             	add    $0xc,%edx
f0104ee9:	80 f9 a0             	cmp    $0xa0,%cl
f0104eec:	74 e9                	je     f0104ed7 <debuginfo_eip+0x287>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104eee:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ef3:	eb 36                	jmp    f0104f2b <debuginfo_eip+0x2db>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104efa:	eb 2f                	jmp    f0104f2b <debuginfo_eip+0x2db>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if(user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
			return -1;
f0104efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f01:	eb 28                	jmp    f0104f2b <debuginfo_eip+0x2db>
		
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
f0104f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f08:	eb 21                	jmp    f0104f2b <debuginfo_eip+0x2db>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f0f:	eb 1a                	jmp    f0104f2b <debuginfo_eip+0x2db>
f0104f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f16:	eb 13                	jmp    f0104f2b <debuginfo_eip+0x2db>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f1d:	eb 0c                	jmp    f0104f2b <debuginfo_eip+0x2db>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	//cprintf("%d	%d",lline,rline);
	if(lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;	
f0104f1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f24:	eb 05                	jmp    f0104f2b <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f26:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f2e:	5b                   	pop    %ebx
f0104f2f:	5e                   	pop    %esi
f0104f30:	5f                   	pop    %edi
f0104f31:	5d                   	pop    %ebp
f0104f32:	c3                   	ret    

f0104f33 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f33:	55                   	push   %ebp
f0104f34:	89 e5                	mov    %esp,%ebp
f0104f36:	57                   	push   %edi
f0104f37:	56                   	push   %esi
f0104f38:	53                   	push   %ebx
f0104f39:	83 ec 1c             	sub    $0x1c,%esp
f0104f3c:	89 c7                	mov    %eax,%edi
f0104f3e:	89 d6                	mov    %edx,%esi
f0104f40:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f43:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f46:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f49:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f4f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f54:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f57:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104f5a:	39 d3                	cmp    %edx,%ebx
f0104f5c:	72 05                	jb     f0104f63 <printnum+0x30>
f0104f5e:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104f61:	77 45                	ja     f0104fa8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f63:	83 ec 0c             	sub    $0xc,%esp
f0104f66:	ff 75 18             	pushl  0x18(%ebp)
f0104f69:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f6c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104f6f:	53                   	push   %ebx
f0104f70:	ff 75 10             	pushl  0x10(%ebp)
f0104f73:	83 ec 08             	sub    $0x8,%esp
f0104f76:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104f79:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f7c:	ff 75 dc             	pushl  -0x24(%ebp)
f0104f7f:	ff 75 d8             	pushl  -0x28(%ebp)
f0104f82:	e8 59 18 00 00       	call   f01067e0 <__udivdi3>
f0104f87:	83 c4 18             	add    $0x18,%esp
f0104f8a:	52                   	push   %edx
f0104f8b:	50                   	push   %eax
f0104f8c:	89 f2                	mov    %esi,%edx
f0104f8e:	89 f8                	mov    %edi,%eax
f0104f90:	e8 9e ff ff ff       	call   f0104f33 <printnum>
f0104f95:	83 c4 20             	add    $0x20,%esp
f0104f98:	eb 18                	jmp    f0104fb2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104f9a:	83 ec 08             	sub    $0x8,%esp
f0104f9d:	56                   	push   %esi
f0104f9e:	ff 75 18             	pushl  0x18(%ebp)
f0104fa1:	ff d7                	call   *%edi
f0104fa3:	83 c4 10             	add    $0x10,%esp
f0104fa6:	eb 03                	jmp    f0104fab <printnum+0x78>
f0104fa8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104fab:	83 eb 01             	sub    $0x1,%ebx
f0104fae:	85 db                	test   %ebx,%ebx
f0104fb0:	7f e8                	jg     f0104f9a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fb2:	83 ec 08             	sub    $0x8,%esp
f0104fb5:	56                   	push   %esi
f0104fb6:	83 ec 04             	sub    $0x4,%esp
f0104fb9:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fbc:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fbf:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fc2:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fc5:	e8 46 19 00 00       	call   f0106910 <__umoddi3>
f0104fca:	83 c4 14             	add    $0x14,%esp
f0104fcd:	0f be 80 56 81 10 f0 	movsbl -0xfef7eaa(%eax),%eax
f0104fd4:	50                   	push   %eax
f0104fd5:	ff d7                	call   *%edi
}
f0104fd7:	83 c4 10             	add    $0x10,%esp
f0104fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fdd:	5b                   	pop    %ebx
f0104fde:	5e                   	pop    %esi
f0104fdf:	5f                   	pop    %edi
f0104fe0:	5d                   	pop    %ebp
f0104fe1:	c3                   	ret    

f0104fe2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104fe2:	55                   	push   %ebp
f0104fe3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104fe5:	83 fa 01             	cmp    $0x1,%edx
f0104fe8:	7e 0e                	jle    f0104ff8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104fea:	8b 10                	mov    (%eax),%edx
f0104fec:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104fef:	89 08                	mov    %ecx,(%eax)
f0104ff1:	8b 02                	mov    (%edx),%eax
f0104ff3:	8b 52 04             	mov    0x4(%edx),%edx
f0104ff6:	eb 22                	jmp    f010501a <getuint+0x38>
	else if (lflag)
f0104ff8:	85 d2                	test   %edx,%edx
f0104ffa:	74 10                	je     f010500c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104ffc:	8b 10                	mov    (%eax),%edx
f0104ffe:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105001:	89 08                	mov    %ecx,(%eax)
f0105003:	8b 02                	mov    (%edx),%eax
f0105005:	ba 00 00 00 00       	mov    $0x0,%edx
f010500a:	eb 0e                	jmp    f010501a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010500c:	8b 10                	mov    (%eax),%edx
f010500e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105011:	89 08                	mov    %ecx,(%eax)
f0105013:	8b 02                	mov    (%edx),%eax
f0105015:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010501a:	5d                   	pop    %ebp
f010501b:	c3                   	ret    

f010501c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010501c:	55                   	push   %ebp
f010501d:	89 e5                	mov    %esp,%ebp
f010501f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105022:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105026:	8b 10                	mov    (%eax),%edx
f0105028:	3b 50 04             	cmp    0x4(%eax),%edx
f010502b:	73 0a                	jae    f0105037 <sprintputch+0x1b>
		*b->buf++ = ch;
f010502d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105030:	89 08                	mov    %ecx,(%eax)
f0105032:	8b 45 08             	mov    0x8(%ebp),%eax
f0105035:	88 02                	mov    %al,(%edx)
}
f0105037:	5d                   	pop    %ebp
f0105038:	c3                   	ret    

f0105039 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105039:	55                   	push   %ebp
f010503a:	89 e5                	mov    %esp,%ebp
f010503c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010503f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105042:	50                   	push   %eax
f0105043:	ff 75 10             	pushl  0x10(%ebp)
f0105046:	ff 75 0c             	pushl  0xc(%ebp)
f0105049:	ff 75 08             	pushl  0x8(%ebp)
f010504c:	e8 05 00 00 00       	call   f0105056 <vprintfmt>
	va_end(ap);
}
f0105051:	83 c4 10             	add    $0x10,%esp
f0105054:	c9                   	leave  
f0105055:	c3                   	ret    

f0105056 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105056:	55                   	push   %ebp
f0105057:	89 e5                	mov    %esp,%ebp
f0105059:	57                   	push   %edi
f010505a:	56                   	push   %esi
f010505b:	53                   	push   %ebx
f010505c:	83 ec 2c             	sub    $0x2c,%esp
f010505f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105062:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105065:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105068:	eb 12                	jmp    f010507c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010506a:	85 c0                	test   %eax,%eax
f010506c:	0f 84 89 03 00 00    	je     f01053fb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0105072:	83 ec 08             	sub    $0x8,%esp
f0105075:	53                   	push   %ebx
f0105076:	50                   	push   %eax
f0105077:	ff d6                	call   *%esi
f0105079:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010507c:	83 c7 01             	add    $0x1,%edi
f010507f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105083:	83 f8 25             	cmp    $0x25,%eax
f0105086:	75 e2                	jne    f010506a <vprintfmt+0x14>
f0105088:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010508c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105093:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010509a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01050a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01050a6:	eb 07                	jmp    f01050af <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01050ab:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050af:	8d 47 01             	lea    0x1(%edi),%eax
f01050b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01050b5:	0f b6 07             	movzbl (%edi),%eax
f01050b8:	0f b6 c8             	movzbl %al,%ecx
f01050bb:	83 e8 23             	sub    $0x23,%eax
f01050be:	3c 55                	cmp    $0x55,%al
f01050c0:	0f 87 1a 03 00 00    	ja     f01053e0 <vprintfmt+0x38a>
f01050c6:	0f b6 c0             	movzbl %al,%eax
f01050c9:	ff 24 85 a0 82 10 f0 	jmp    *-0xfef7d60(,%eax,4)
f01050d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01050d3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01050d7:	eb d6                	jmp    f01050af <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01050e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01050e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01050e7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01050eb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f01050ee:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01050f1:	83 fa 09             	cmp    $0x9,%edx
f01050f4:	77 39                	ja     f010512f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01050f6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01050f9:	eb e9                	jmp    f01050e4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01050fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01050fe:	8d 48 04             	lea    0x4(%eax),%ecx
f0105101:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105104:	8b 00                	mov    (%eax),%eax
f0105106:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105109:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010510c:	eb 27                	jmp    f0105135 <vprintfmt+0xdf>
f010510e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105111:	85 c0                	test   %eax,%eax
f0105113:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105118:	0f 49 c8             	cmovns %eax,%ecx
f010511b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010511e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105121:	eb 8c                	jmp    f01050af <vprintfmt+0x59>
f0105123:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105126:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010512d:	eb 80                	jmp    f01050af <vprintfmt+0x59>
f010512f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105132:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105135:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105139:	0f 89 70 ff ff ff    	jns    f01050af <vprintfmt+0x59>
				width = precision, precision = -1;
f010513f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105142:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105145:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010514c:	e9 5e ff ff ff       	jmp    f01050af <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105151:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105154:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105157:	e9 53 ff ff ff       	jmp    f01050af <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010515c:	8b 45 14             	mov    0x14(%ebp),%eax
f010515f:	8d 50 04             	lea    0x4(%eax),%edx
f0105162:	89 55 14             	mov    %edx,0x14(%ebp)
f0105165:	83 ec 08             	sub    $0x8,%esp
f0105168:	53                   	push   %ebx
f0105169:	ff 30                	pushl  (%eax)
f010516b:	ff d6                	call   *%esi
			break;
f010516d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105170:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105173:	e9 04 ff ff ff       	jmp    f010507c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105178:	8b 45 14             	mov    0x14(%ebp),%eax
f010517b:	8d 50 04             	lea    0x4(%eax),%edx
f010517e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105181:	8b 00                	mov    (%eax),%eax
f0105183:	99                   	cltd   
f0105184:	31 d0                	xor    %edx,%eax
f0105186:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105188:	83 f8 0f             	cmp    $0xf,%eax
f010518b:	7f 0b                	jg     f0105198 <vprintfmt+0x142>
f010518d:	8b 14 85 00 84 10 f0 	mov    -0xfef7c00(,%eax,4),%edx
f0105194:	85 d2                	test   %edx,%edx
f0105196:	75 18                	jne    f01051b0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105198:	50                   	push   %eax
f0105199:	68 6e 81 10 f0       	push   $0xf010816e
f010519e:	53                   	push   %ebx
f010519f:	56                   	push   %esi
f01051a0:	e8 94 fe ff ff       	call   f0105039 <printfmt>
f01051a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01051ab:	e9 cc fe ff ff       	jmp    f010507c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01051b0:	52                   	push   %edx
f01051b1:	68 71 70 10 f0       	push   $0xf0107071
f01051b6:	53                   	push   %ebx
f01051b7:	56                   	push   %esi
f01051b8:	e8 7c fe ff ff       	call   f0105039 <printfmt>
f01051bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051c3:	e9 b4 fe ff ff       	jmp    f010507c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01051c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01051cb:	8d 50 04             	lea    0x4(%eax),%edx
f01051ce:	89 55 14             	mov    %edx,0x14(%ebp)
f01051d1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01051d3:	85 ff                	test   %edi,%edi
f01051d5:	b8 67 81 10 f0       	mov    $0xf0108167,%eax
f01051da:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01051dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051e1:	0f 8e 94 00 00 00    	jle    f010527b <vprintfmt+0x225>
f01051e7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01051eb:	0f 84 98 00 00 00    	je     f0105289 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01051f1:	83 ec 08             	sub    $0x8,%esp
f01051f4:	ff 75 d0             	pushl  -0x30(%ebp)
f01051f7:	57                   	push   %edi
f01051f8:	e8 77 03 00 00       	call   f0105574 <strnlen>
f01051fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105200:	29 c1                	sub    %eax,%ecx
f0105202:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105205:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105208:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010520c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010520f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105212:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105214:	eb 0f                	jmp    f0105225 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105216:	83 ec 08             	sub    $0x8,%esp
f0105219:	53                   	push   %ebx
f010521a:	ff 75 e0             	pushl  -0x20(%ebp)
f010521d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010521f:	83 ef 01             	sub    $0x1,%edi
f0105222:	83 c4 10             	add    $0x10,%esp
f0105225:	85 ff                	test   %edi,%edi
f0105227:	7f ed                	jg     f0105216 <vprintfmt+0x1c0>
f0105229:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010522c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010522f:	85 c9                	test   %ecx,%ecx
f0105231:	b8 00 00 00 00       	mov    $0x0,%eax
f0105236:	0f 49 c1             	cmovns %ecx,%eax
f0105239:	29 c1                	sub    %eax,%ecx
f010523b:	89 75 08             	mov    %esi,0x8(%ebp)
f010523e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105241:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105244:	89 cb                	mov    %ecx,%ebx
f0105246:	eb 4d                	jmp    f0105295 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105248:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010524c:	74 1b                	je     f0105269 <vprintfmt+0x213>
f010524e:	0f be c0             	movsbl %al,%eax
f0105251:	83 e8 20             	sub    $0x20,%eax
f0105254:	83 f8 5e             	cmp    $0x5e,%eax
f0105257:	76 10                	jbe    f0105269 <vprintfmt+0x213>
					putch('?', putdat);
f0105259:	83 ec 08             	sub    $0x8,%esp
f010525c:	ff 75 0c             	pushl  0xc(%ebp)
f010525f:	6a 3f                	push   $0x3f
f0105261:	ff 55 08             	call   *0x8(%ebp)
f0105264:	83 c4 10             	add    $0x10,%esp
f0105267:	eb 0d                	jmp    f0105276 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105269:	83 ec 08             	sub    $0x8,%esp
f010526c:	ff 75 0c             	pushl  0xc(%ebp)
f010526f:	52                   	push   %edx
f0105270:	ff 55 08             	call   *0x8(%ebp)
f0105273:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105276:	83 eb 01             	sub    $0x1,%ebx
f0105279:	eb 1a                	jmp    f0105295 <vprintfmt+0x23f>
f010527b:	89 75 08             	mov    %esi,0x8(%ebp)
f010527e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105281:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105284:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105287:	eb 0c                	jmp    f0105295 <vprintfmt+0x23f>
f0105289:	89 75 08             	mov    %esi,0x8(%ebp)
f010528c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010528f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105292:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105295:	83 c7 01             	add    $0x1,%edi
f0105298:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010529c:	0f be d0             	movsbl %al,%edx
f010529f:	85 d2                	test   %edx,%edx
f01052a1:	74 23                	je     f01052c6 <vprintfmt+0x270>
f01052a3:	85 f6                	test   %esi,%esi
f01052a5:	78 a1                	js     f0105248 <vprintfmt+0x1f2>
f01052a7:	83 ee 01             	sub    $0x1,%esi
f01052aa:	79 9c                	jns    f0105248 <vprintfmt+0x1f2>
f01052ac:	89 df                	mov    %ebx,%edi
f01052ae:	8b 75 08             	mov    0x8(%ebp),%esi
f01052b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052b4:	eb 18                	jmp    f01052ce <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01052b6:	83 ec 08             	sub    $0x8,%esp
f01052b9:	53                   	push   %ebx
f01052ba:	6a 20                	push   $0x20
f01052bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01052be:	83 ef 01             	sub    $0x1,%edi
f01052c1:	83 c4 10             	add    $0x10,%esp
f01052c4:	eb 08                	jmp    f01052ce <vprintfmt+0x278>
f01052c6:	89 df                	mov    %ebx,%edi
f01052c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01052cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052ce:	85 ff                	test   %edi,%edi
f01052d0:	7f e4                	jg     f01052b6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052d5:	e9 a2 fd ff ff       	jmp    f010507c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01052da:	83 fa 01             	cmp    $0x1,%edx
f01052dd:	7e 16                	jle    f01052f5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01052df:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e2:	8d 50 08             	lea    0x8(%eax),%edx
f01052e5:	89 55 14             	mov    %edx,0x14(%ebp)
f01052e8:	8b 50 04             	mov    0x4(%eax),%edx
f01052eb:	8b 00                	mov    (%eax),%eax
f01052ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052f3:	eb 32                	jmp    f0105327 <vprintfmt+0x2d1>
	else if (lflag)
f01052f5:	85 d2                	test   %edx,%edx
f01052f7:	74 18                	je     f0105311 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01052f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01052fc:	8d 50 04             	lea    0x4(%eax),%edx
f01052ff:	89 55 14             	mov    %edx,0x14(%ebp)
f0105302:	8b 00                	mov    (%eax),%eax
f0105304:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105307:	89 c1                	mov    %eax,%ecx
f0105309:	c1 f9 1f             	sar    $0x1f,%ecx
f010530c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010530f:	eb 16                	jmp    f0105327 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105311:	8b 45 14             	mov    0x14(%ebp),%eax
f0105314:	8d 50 04             	lea    0x4(%eax),%edx
f0105317:	89 55 14             	mov    %edx,0x14(%ebp)
f010531a:	8b 00                	mov    (%eax),%eax
f010531c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010531f:	89 c1                	mov    %eax,%ecx
f0105321:	c1 f9 1f             	sar    $0x1f,%ecx
f0105324:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105327:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010532a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010532d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105332:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105336:	79 74                	jns    f01053ac <vprintfmt+0x356>
				putch('-', putdat);
f0105338:	83 ec 08             	sub    $0x8,%esp
f010533b:	53                   	push   %ebx
f010533c:	6a 2d                	push   $0x2d
f010533e:	ff d6                	call   *%esi
				num = -(long long) num;
f0105340:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105343:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105346:	f7 d8                	neg    %eax
f0105348:	83 d2 00             	adc    $0x0,%edx
f010534b:	f7 da                	neg    %edx
f010534d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105350:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105355:	eb 55                	jmp    f01053ac <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105357:	8d 45 14             	lea    0x14(%ebp),%eax
f010535a:	e8 83 fc ff ff       	call   f0104fe2 <getuint>
			base = 10;
f010535f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105364:	eb 46                	jmp    f01053ac <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105366:	8d 45 14             	lea    0x14(%ebp),%eax
f0105369:	e8 74 fc ff ff       	call   f0104fe2 <getuint>
		        base = 8;
f010536e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0105373:	eb 37                	jmp    f01053ac <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105375:	83 ec 08             	sub    $0x8,%esp
f0105378:	53                   	push   %ebx
f0105379:	6a 30                	push   $0x30
f010537b:	ff d6                	call   *%esi
			putch('x', putdat);
f010537d:	83 c4 08             	add    $0x8,%esp
f0105380:	53                   	push   %ebx
f0105381:	6a 78                	push   $0x78
f0105383:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105385:	8b 45 14             	mov    0x14(%ebp),%eax
f0105388:	8d 50 04             	lea    0x4(%eax),%edx
f010538b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010538e:	8b 00                	mov    (%eax),%eax
f0105390:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105395:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105398:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010539d:	eb 0d                	jmp    f01053ac <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010539f:	8d 45 14             	lea    0x14(%ebp),%eax
f01053a2:	e8 3b fc ff ff       	call   f0104fe2 <getuint>
			base = 16;
f01053a7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01053ac:	83 ec 0c             	sub    $0xc,%esp
f01053af:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01053b3:	57                   	push   %edi
f01053b4:	ff 75 e0             	pushl  -0x20(%ebp)
f01053b7:	51                   	push   %ecx
f01053b8:	52                   	push   %edx
f01053b9:	50                   	push   %eax
f01053ba:	89 da                	mov    %ebx,%edx
f01053bc:	89 f0                	mov    %esi,%eax
f01053be:	e8 70 fb ff ff       	call   f0104f33 <printnum>
			break;
f01053c3:	83 c4 20             	add    $0x20,%esp
f01053c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053c9:	e9 ae fc ff ff       	jmp    f010507c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01053ce:	83 ec 08             	sub    $0x8,%esp
f01053d1:	53                   	push   %ebx
f01053d2:	51                   	push   %ecx
f01053d3:	ff d6                	call   *%esi
			break;
f01053d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01053db:	e9 9c fc ff ff       	jmp    f010507c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01053e0:	83 ec 08             	sub    $0x8,%esp
f01053e3:	53                   	push   %ebx
f01053e4:	6a 25                	push   $0x25
f01053e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01053e8:	83 c4 10             	add    $0x10,%esp
f01053eb:	eb 03                	jmp    f01053f0 <vprintfmt+0x39a>
f01053ed:	83 ef 01             	sub    $0x1,%edi
f01053f0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01053f4:	75 f7                	jne    f01053ed <vprintfmt+0x397>
f01053f6:	e9 81 fc ff ff       	jmp    f010507c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01053fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053fe:	5b                   	pop    %ebx
f01053ff:	5e                   	pop    %esi
f0105400:	5f                   	pop    %edi
f0105401:	5d                   	pop    %ebp
f0105402:	c3                   	ret    

f0105403 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105403:	55                   	push   %ebp
f0105404:	89 e5                	mov    %esp,%ebp
f0105406:	83 ec 18             	sub    $0x18,%esp
f0105409:	8b 45 08             	mov    0x8(%ebp),%eax
f010540c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010540f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105412:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105416:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105419:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105420:	85 c0                	test   %eax,%eax
f0105422:	74 26                	je     f010544a <vsnprintf+0x47>
f0105424:	85 d2                	test   %edx,%edx
f0105426:	7e 22                	jle    f010544a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105428:	ff 75 14             	pushl  0x14(%ebp)
f010542b:	ff 75 10             	pushl  0x10(%ebp)
f010542e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105431:	50                   	push   %eax
f0105432:	68 1c 50 10 f0       	push   $0xf010501c
f0105437:	e8 1a fc ff ff       	call   f0105056 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010543c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010543f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105442:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105445:	83 c4 10             	add    $0x10,%esp
f0105448:	eb 05                	jmp    f010544f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010544a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010544f:	c9                   	leave  
f0105450:	c3                   	ret    

f0105451 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105451:	55                   	push   %ebp
f0105452:	89 e5                	mov    %esp,%ebp
f0105454:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105457:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010545a:	50                   	push   %eax
f010545b:	ff 75 10             	pushl  0x10(%ebp)
f010545e:	ff 75 0c             	pushl  0xc(%ebp)
f0105461:	ff 75 08             	pushl  0x8(%ebp)
f0105464:	e8 9a ff ff ff       	call   f0105403 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105469:	c9                   	leave  
f010546a:	c3                   	ret    

f010546b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010546b:	55                   	push   %ebp
f010546c:	89 e5                	mov    %esp,%ebp
f010546e:	57                   	push   %edi
f010546f:	56                   	push   %esi
f0105470:	53                   	push   %ebx
f0105471:	83 ec 0c             	sub    $0xc,%esp
f0105474:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105477:	85 c0                	test   %eax,%eax
f0105479:	74 11                	je     f010548c <readline+0x21>
		cprintf("%s", prompt);
f010547b:	83 ec 08             	sub    $0x8,%esp
f010547e:	50                   	push   %eax
f010547f:	68 71 70 10 f0       	push   $0xf0107071
f0105484:	e8 63 e2 ff ff       	call   f01036ec <cprintf>
f0105489:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f010548c:	83 ec 0c             	sub    $0xc,%esp
f010548f:	6a 00                	push   $0x0
f0105491:	e8 5f b3 ff ff       	call   f01007f5 <iscons>
f0105496:	89 c7                	mov    %eax,%edi
f0105498:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010549b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01054a0:	e8 3f b3 ff ff       	call   f01007e4 <getchar>
f01054a5:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01054a7:	85 c0                	test   %eax,%eax
f01054a9:	79 29                	jns    f01054d4 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01054ab:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01054b0:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01054b3:	0f 84 9b 00 00 00    	je     f0105554 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01054b9:	83 ec 08             	sub    $0x8,%esp
f01054bc:	53                   	push   %ebx
f01054bd:	68 5f 84 10 f0       	push   $0xf010845f
f01054c2:	e8 25 e2 ff ff       	call   f01036ec <cprintf>
f01054c7:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01054ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01054cf:	e9 80 00 00 00       	jmp    f0105554 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01054d4:	83 f8 08             	cmp    $0x8,%eax
f01054d7:	0f 94 c2             	sete   %dl
f01054da:	83 f8 7f             	cmp    $0x7f,%eax
f01054dd:	0f 94 c0             	sete   %al
f01054e0:	08 c2                	or     %al,%dl
f01054e2:	74 1a                	je     f01054fe <readline+0x93>
f01054e4:	85 f6                	test   %esi,%esi
f01054e6:	7e 16                	jle    f01054fe <readline+0x93>
			if (echoing)
f01054e8:	85 ff                	test   %edi,%edi
f01054ea:	74 0d                	je     f01054f9 <readline+0x8e>
				cputchar('\b');
f01054ec:	83 ec 0c             	sub    $0xc,%esp
f01054ef:	6a 08                	push   $0x8
f01054f1:	e8 de b2 ff ff       	call   f01007d4 <cputchar>
f01054f6:	83 c4 10             	add    $0x10,%esp
			i--;
f01054f9:	83 ee 01             	sub    $0x1,%esi
f01054fc:	eb a2                	jmp    f01054a0 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01054fe:	83 fb 1f             	cmp    $0x1f,%ebx
f0105501:	7e 26                	jle    f0105529 <readline+0xbe>
f0105503:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105509:	7f 1e                	jg     f0105529 <readline+0xbe>
			if (echoing)
f010550b:	85 ff                	test   %edi,%edi
f010550d:	74 0c                	je     f010551b <readline+0xb0>
				cputchar(c);
f010550f:	83 ec 0c             	sub    $0xc,%esp
f0105512:	53                   	push   %ebx
f0105513:	e8 bc b2 ff ff       	call   f01007d4 <cputchar>
f0105518:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010551b:	88 9e 80 1a 2a f0    	mov    %bl,-0xfd5e580(%esi)
f0105521:	8d 76 01             	lea    0x1(%esi),%esi
f0105524:	e9 77 ff ff ff       	jmp    f01054a0 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105529:	83 fb 0a             	cmp    $0xa,%ebx
f010552c:	74 09                	je     f0105537 <readline+0xcc>
f010552e:	83 fb 0d             	cmp    $0xd,%ebx
f0105531:	0f 85 69 ff ff ff    	jne    f01054a0 <readline+0x35>
			if (echoing)
f0105537:	85 ff                	test   %edi,%edi
f0105539:	74 0d                	je     f0105548 <readline+0xdd>
				cputchar('\n');
f010553b:	83 ec 0c             	sub    $0xc,%esp
f010553e:	6a 0a                	push   $0xa
f0105540:	e8 8f b2 ff ff       	call   f01007d4 <cputchar>
f0105545:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105548:	c6 86 80 1a 2a f0 00 	movb   $0x0,-0xfd5e580(%esi)
			return buf;
f010554f:	b8 80 1a 2a f0       	mov    $0xf02a1a80,%eax
		}
	}
}
f0105554:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105557:	5b                   	pop    %ebx
f0105558:	5e                   	pop    %esi
f0105559:	5f                   	pop    %edi
f010555a:	5d                   	pop    %ebp
f010555b:	c3                   	ret    

f010555c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010555c:	55                   	push   %ebp
f010555d:	89 e5                	mov    %esp,%ebp
f010555f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105562:	b8 00 00 00 00       	mov    $0x0,%eax
f0105567:	eb 03                	jmp    f010556c <strlen+0x10>
		n++;
f0105569:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010556c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105570:	75 f7                	jne    f0105569 <strlen+0xd>
		n++;
	return n;
}
f0105572:	5d                   	pop    %ebp
f0105573:	c3                   	ret    

f0105574 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105574:	55                   	push   %ebp
f0105575:	89 e5                	mov    %esp,%ebp
f0105577:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010557a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010557d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105582:	eb 03                	jmp    f0105587 <strnlen+0x13>
		n++;
f0105584:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105587:	39 c2                	cmp    %eax,%edx
f0105589:	74 08                	je     f0105593 <strnlen+0x1f>
f010558b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010558f:	75 f3                	jne    f0105584 <strnlen+0x10>
f0105591:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105593:	5d                   	pop    %ebp
f0105594:	c3                   	ret    

f0105595 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105595:	55                   	push   %ebp
f0105596:	89 e5                	mov    %esp,%ebp
f0105598:	53                   	push   %ebx
f0105599:	8b 45 08             	mov    0x8(%ebp),%eax
f010559c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010559f:	89 c2                	mov    %eax,%edx
f01055a1:	83 c2 01             	add    $0x1,%edx
f01055a4:	83 c1 01             	add    $0x1,%ecx
f01055a7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01055ab:	88 5a ff             	mov    %bl,-0x1(%edx)
f01055ae:	84 db                	test   %bl,%bl
f01055b0:	75 ef                	jne    f01055a1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01055b2:	5b                   	pop    %ebx
f01055b3:	5d                   	pop    %ebp
f01055b4:	c3                   	ret    

f01055b5 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01055b5:	55                   	push   %ebp
f01055b6:	89 e5                	mov    %esp,%ebp
f01055b8:	53                   	push   %ebx
f01055b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01055bc:	53                   	push   %ebx
f01055bd:	e8 9a ff ff ff       	call   f010555c <strlen>
f01055c2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01055c5:	ff 75 0c             	pushl  0xc(%ebp)
f01055c8:	01 d8                	add    %ebx,%eax
f01055ca:	50                   	push   %eax
f01055cb:	e8 c5 ff ff ff       	call   f0105595 <strcpy>
	return dst;
}
f01055d0:	89 d8                	mov    %ebx,%eax
f01055d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01055d5:	c9                   	leave  
f01055d6:	c3                   	ret    

f01055d7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01055d7:	55                   	push   %ebp
f01055d8:	89 e5                	mov    %esp,%ebp
f01055da:	56                   	push   %esi
f01055db:	53                   	push   %ebx
f01055dc:	8b 75 08             	mov    0x8(%ebp),%esi
f01055df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01055e2:	89 f3                	mov    %esi,%ebx
f01055e4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01055e7:	89 f2                	mov    %esi,%edx
f01055e9:	eb 0f                	jmp    f01055fa <strncpy+0x23>
		*dst++ = *src;
f01055eb:	83 c2 01             	add    $0x1,%edx
f01055ee:	0f b6 01             	movzbl (%ecx),%eax
f01055f1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01055f4:	80 39 01             	cmpb   $0x1,(%ecx)
f01055f7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01055fa:	39 da                	cmp    %ebx,%edx
f01055fc:	75 ed                	jne    f01055eb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01055fe:	89 f0                	mov    %esi,%eax
f0105600:	5b                   	pop    %ebx
f0105601:	5e                   	pop    %esi
f0105602:	5d                   	pop    %ebp
f0105603:	c3                   	ret    

f0105604 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105604:	55                   	push   %ebp
f0105605:	89 e5                	mov    %esp,%ebp
f0105607:	56                   	push   %esi
f0105608:	53                   	push   %ebx
f0105609:	8b 75 08             	mov    0x8(%ebp),%esi
f010560c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010560f:	8b 55 10             	mov    0x10(%ebp),%edx
f0105612:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105614:	85 d2                	test   %edx,%edx
f0105616:	74 21                	je     f0105639 <strlcpy+0x35>
f0105618:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010561c:	89 f2                	mov    %esi,%edx
f010561e:	eb 09                	jmp    f0105629 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105620:	83 c2 01             	add    $0x1,%edx
f0105623:	83 c1 01             	add    $0x1,%ecx
f0105626:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105629:	39 c2                	cmp    %eax,%edx
f010562b:	74 09                	je     f0105636 <strlcpy+0x32>
f010562d:	0f b6 19             	movzbl (%ecx),%ebx
f0105630:	84 db                	test   %bl,%bl
f0105632:	75 ec                	jne    f0105620 <strlcpy+0x1c>
f0105634:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105636:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105639:	29 f0                	sub    %esi,%eax
}
f010563b:	5b                   	pop    %ebx
f010563c:	5e                   	pop    %esi
f010563d:	5d                   	pop    %ebp
f010563e:	c3                   	ret    

f010563f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010563f:	55                   	push   %ebp
f0105640:	89 e5                	mov    %esp,%ebp
f0105642:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105645:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105648:	eb 06                	jmp    f0105650 <strcmp+0x11>
		p++, q++;
f010564a:	83 c1 01             	add    $0x1,%ecx
f010564d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105650:	0f b6 01             	movzbl (%ecx),%eax
f0105653:	84 c0                	test   %al,%al
f0105655:	74 04                	je     f010565b <strcmp+0x1c>
f0105657:	3a 02                	cmp    (%edx),%al
f0105659:	74 ef                	je     f010564a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010565b:	0f b6 c0             	movzbl %al,%eax
f010565e:	0f b6 12             	movzbl (%edx),%edx
f0105661:	29 d0                	sub    %edx,%eax
}
f0105663:	5d                   	pop    %ebp
f0105664:	c3                   	ret    

f0105665 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105665:	55                   	push   %ebp
f0105666:	89 e5                	mov    %esp,%ebp
f0105668:	53                   	push   %ebx
f0105669:	8b 45 08             	mov    0x8(%ebp),%eax
f010566c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010566f:	89 c3                	mov    %eax,%ebx
f0105671:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105674:	eb 06                	jmp    f010567c <strncmp+0x17>
		n--, p++, q++;
f0105676:	83 c0 01             	add    $0x1,%eax
f0105679:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010567c:	39 d8                	cmp    %ebx,%eax
f010567e:	74 15                	je     f0105695 <strncmp+0x30>
f0105680:	0f b6 08             	movzbl (%eax),%ecx
f0105683:	84 c9                	test   %cl,%cl
f0105685:	74 04                	je     f010568b <strncmp+0x26>
f0105687:	3a 0a                	cmp    (%edx),%cl
f0105689:	74 eb                	je     f0105676 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010568b:	0f b6 00             	movzbl (%eax),%eax
f010568e:	0f b6 12             	movzbl (%edx),%edx
f0105691:	29 d0                	sub    %edx,%eax
f0105693:	eb 05                	jmp    f010569a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105695:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010569a:	5b                   	pop    %ebx
f010569b:	5d                   	pop    %ebp
f010569c:	c3                   	ret    

f010569d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010569d:	55                   	push   %ebp
f010569e:	89 e5                	mov    %esp,%ebp
f01056a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01056a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01056a7:	eb 07                	jmp    f01056b0 <strchr+0x13>
		if (*s == c)
f01056a9:	38 ca                	cmp    %cl,%dl
f01056ab:	74 0f                	je     f01056bc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01056ad:	83 c0 01             	add    $0x1,%eax
f01056b0:	0f b6 10             	movzbl (%eax),%edx
f01056b3:	84 d2                	test   %dl,%dl
f01056b5:	75 f2                	jne    f01056a9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01056b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056bc:	5d                   	pop    %ebp
f01056bd:	c3                   	ret    

f01056be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01056be:	55                   	push   %ebp
f01056bf:	89 e5                	mov    %esp,%ebp
f01056c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01056c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01056c8:	eb 03                	jmp    f01056cd <strfind+0xf>
f01056ca:	83 c0 01             	add    $0x1,%eax
f01056cd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01056d0:	38 ca                	cmp    %cl,%dl
f01056d2:	74 04                	je     f01056d8 <strfind+0x1a>
f01056d4:	84 d2                	test   %dl,%dl
f01056d6:	75 f2                	jne    f01056ca <strfind+0xc>
			break;
	return (char *) s;
}
f01056d8:	5d                   	pop    %ebp
f01056d9:	c3                   	ret    

f01056da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01056da:	55                   	push   %ebp
f01056db:	89 e5                	mov    %esp,%ebp
f01056dd:	57                   	push   %edi
f01056de:	56                   	push   %esi
f01056df:	53                   	push   %ebx
f01056e0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01056e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01056e6:	85 c9                	test   %ecx,%ecx
f01056e8:	74 36                	je     f0105720 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01056ea:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01056f0:	75 28                	jne    f010571a <memset+0x40>
f01056f2:	f6 c1 03             	test   $0x3,%cl
f01056f5:	75 23                	jne    f010571a <memset+0x40>
		c &= 0xFF;
f01056f7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01056fb:	89 d3                	mov    %edx,%ebx
f01056fd:	c1 e3 08             	shl    $0x8,%ebx
f0105700:	89 d6                	mov    %edx,%esi
f0105702:	c1 e6 18             	shl    $0x18,%esi
f0105705:	89 d0                	mov    %edx,%eax
f0105707:	c1 e0 10             	shl    $0x10,%eax
f010570a:	09 f0                	or     %esi,%eax
f010570c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010570e:	89 d8                	mov    %ebx,%eax
f0105710:	09 d0                	or     %edx,%eax
f0105712:	c1 e9 02             	shr    $0x2,%ecx
f0105715:	fc                   	cld    
f0105716:	f3 ab                	rep stos %eax,%es:(%edi)
f0105718:	eb 06                	jmp    f0105720 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010571a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010571d:	fc                   	cld    
f010571e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105720:	89 f8                	mov    %edi,%eax
f0105722:	5b                   	pop    %ebx
f0105723:	5e                   	pop    %esi
f0105724:	5f                   	pop    %edi
f0105725:	5d                   	pop    %ebp
f0105726:	c3                   	ret    

f0105727 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105727:	55                   	push   %ebp
f0105728:	89 e5                	mov    %esp,%ebp
f010572a:	57                   	push   %edi
f010572b:	56                   	push   %esi
f010572c:	8b 45 08             	mov    0x8(%ebp),%eax
f010572f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105732:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105735:	39 c6                	cmp    %eax,%esi
f0105737:	73 35                	jae    f010576e <memmove+0x47>
f0105739:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010573c:	39 d0                	cmp    %edx,%eax
f010573e:	73 2e                	jae    f010576e <memmove+0x47>
		s += n;
		d += n;
f0105740:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105743:	89 d6                	mov    %edx,%esi
f0105745:	09 fe                	or     %edi,%esi
f0105747:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010574d:	75 13                	jne    f0105762 <memmove+0x3b>
f010574f:	f6 c1 03             	test   $0x3,%cl
f0105752:	75 0e                	jne    f0105762 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105754:	83 ef 04             	sub    $0x4,%edi
f0105757:	8d 72 fc             	lea    -0x4(%edx),%esi
f010575a:	c1 e9 02             	shr    $0x2,%ecx
f010575d:	fd                   	std    
f010575e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105760:	eb 09                	jmp    f010576b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105762:	83 ef 01             	sub    $0x1,%edi
f0105765:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105768:	fd                   	std    
f0105769:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010576b:	fc                   	cld    
f010576c:	eb 1d                	jmp    f010578b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010576e:	89 f2                	mov    %esi,%edx
f0105770:	09 c2                	or     %eax,%edx
f0105772:	f6 c2 03             	test   $0x3,%dl
f0105775:	75 0f                	jne    f0105786 <memmove+0x5f>
f0105777:	f6 c1 03             	test   $0x3,%cl
f010577a:	75 0a                	jne    f0105786 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010577c:	c1 e9 02             	shr    $0x2,%ecx
f010577f:	89 c7                	mov    %eax,%edi
f0105781:	fc                   	cld    
f0105782:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105784:	eb 05                	jmp    f010578b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105786:	89 c7                	mov    %eax,%edi
f0105788:	fc                   	cld    
f0105789:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010578b:	5e                   	pop    %esi
f010578c:	5f                   	pop    %edi
f010578d:	5d                   	pop    %ebp
f010578e:	c3                   	ret    

f010578f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010578f:	55                   	push   %ebp
f0105790:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105792:	ff 75 10             	pushl  0x10(%ebp)
f0105795:	ff 75 0c             	pushl  0xc(%ebp)
f0105798:	ff 75 08             	pushl  0x8(%ebp)
f010579b:	e8 87 ff ff ff       	call   f0105727 <memmove>
}
f01057a0:	c9                   	leave  
f01057a1:	c3                   	ret    

f01057a2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01057a2:	55                   	push   %ebp
f01057a3:	89 e5                	mov    %esp,%ebp
f01057a5:	56                   	push   %esi
f01057a6:	53                   	push   %ebx
f01057a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01057aa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057ad:	89 c6                	mov    %eax,%esi
f01057af:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01057b2:	eb 1a                	jmp    f01057ce <memcmp+0x2c>
		if (*s1 != *s2)
f01057b4:	0f b6 08             	movzbl (%eax),%ecx
f01057b7:	0f b6 1a             	movzbl (%edx),%ebx
f01057ba:	38 d9                	cmp    %bl,%cl
f01057bc:	74 0a                	je     f01057c8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01057be:	0f b6 c1             	movzbl %cl,%eax
f01057c1:	0f b6 db             	movzbl %bl,%ebx
f01057c4:	29 d8                	sub    %ebx,%eax
f01057c6:	eb 0f                	jmp    f01057d7 <memcmp+0x35>
		s1++, s2++;
f01057c8:	83 c0 01             	add    $0x1,%eax
f01057cb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01057ce:	39 f0                	cmp    %esi,%eax
f01057d0:	75 e2                	jne    f01057b4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01057d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057d7:	5b                   	pop    %ebx
f01057d8:	5e                   	pop    %esi
f01057d9:	5d                   	pop    %ebp
f01057da:	c3                   	ret    

f01057db <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01057db:	55                   	push   %ebp
f01057dc:	89 e5                	mov    %esp,%ebp
f01057de:	53                   	push   %ebx
f01057df:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01057e2:	89 c1                	mov    %eax,%ecx
f01057e4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01057e7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01057eb:	eb 0a                	jmp    f01057f7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01057ed:	0f b6 10             	movzbl (%eax),%edx
f01057f0:	39 da                	cmp    %ebx,%edx
f01057f2:	74 07                	je     f01057fb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01057f4:	83 c0 01             	add    $0x1,%eax
f01057f7:	39 c8                	cmp    %ecx,%eax
f01057f9:	72 f2                	jb     f01057ed <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01057fb:	5b                   	pop    %ebx
f01057fc:	5d                   	pop    %ebp
f01057fd:	c3                   	ret    

f01057fe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01057fe:	55                   	push   %ebp
f01057ff:	89 e5                	mov    %esp,%ebp
f0105801:	57                   	push   %edi
f0105802:	56                   	push   %esi
f0105803:	53                   	push   %ebx
f0105804:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105807:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010580a:	eb 03                	jmp    f010580f <strtol+0x11>
		s++;
f010580c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010580f:	0f b6 01             	movzbl (%ecx),%eax
f0105812:	3c 20                	cmp    $0x20,%al
f0105814:	74 f6                	je     f010580c <strtol+0xe>
f0105816:	3c 09                	cmp    $0x9,%al
f0105818:	74 f2                	je     f010580c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010581a:	3c 2b                	cmp    $0x2b,%al
f010581c:	75 0a                	jne    f0105828 <strtol+0x2a>
		s++;
f010581e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105821:	bf 00 00 00 00       	mov    $0x0,%edi
f0105826:	eb 11                	jmp    f0105839 <strtol+0x3b>
f0105828:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010582d:	3c 2d                	cmp    $0x2d,%al
f010582f:	75 08                	jne    f0105839 <strtol+0x3b>
		s++, neg = 1;
f0105831:	83 c1 01             	add    $0x1,%ecx
f0105834:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105839:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010583f:	75 15                	jne    f0105856 <strtol+0x58>
f0105841:	80 39 30             	cmpb   $0x30,(%ecx)
f0105844:	75 10                	jne    f0105856 <strtol+0x58>
f0105846:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010584a:	75 7c                	jne    f01058c8 <strtol+0xca>
		s += 2, base = 16;
f010584c:	83 c1 02             	add    $0x2,%ecx
f010584f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105854:	eb 16                	jmp    f010586c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105856:	85 db                	test   %ebx,%ebx
f0105858:	75 12                	jne    f010586c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010585a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010585f:	80 39 30             	cmpb   $0x30,(%ecx)
f0105862:	75 08                	jne    f010586c <strtol+0x6e>
		s++, base = 8;
f0105864:	83 c1 01             	add    $0x1,%ecx
f0105867:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010586c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105871:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105874:	0f b6 11             	movzbl (%ecx),%edx
f0105877:	8d 72 d0             	lea    -0x30(%edx),%esi
f010587a:	89 f3                	mov    %esi,%ebx
f010587c:	80 fb 09             	cmp    $0x9,%bl
f010587f:	77 08                	ja     f0105889 <strtol+0x8b>
			dig = *s - '0';
f0105881:	0f be d2             	movsbl %dl,%edx
f0105884:	83 ea 30             	sub    $0x30,%edx
f0105887:	eb 22                	jmp    f01058ab <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105889:	8d 72 9f             	lea    -0x61(%edx),%esi
f010588c:	89 f3                	mov    %esi,%ebx
f010588e:	80 fb 19             	cmp    $0x19,%bl
f0105891:	77 08                	ja     f010589b <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105893:	0f be d2             	movsbl %dl,%edx
f0105896:	83 ea 57             	sub    $0x57,%edx
f0105899:	eb 10                	jmp    f01058ab <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010589b:	8d 72 bf             	lea    -0x41(%edx),%esi
f010589e:	89 f3                	mov    %esi,%ebx
f01058a0:	80 fb 19             	cmp    $0x19,%bl
f01058a3:	77 16                	ja     f01058bb <strtol+0xbd>
			dig = *s - 'A' + 10;
f01058a5:	0f be d2             	movsbl %dl,%edx
f01058a8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01058ab:	3b 55 10             	cmp    0x10(%ebp),%edx
f01058ae:	7d 0b                	jge    f01058bb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01058b0:	83 c1 01             	add    $0x1,%ecx
f01058b3:	0f af 45 10          	imul   0x10(%ebp),%eax
f01058b7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01058b9:	eb b9                	jmp    f0105874 <strtol+0x76>

	if (endptr)
f01058bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01058bf:	74 0d                	je     f01058ce <strtol+0xd0>
		*endptr = (char *) s;
f01058c1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01058c4:	89 0e                	mov    %ecx,(%esi)
f01058c6:	eb 06                	jmp    f01058ce <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058c8:	85 db                	test   %ebx,%ebx
f01058ca:	74 98                	je     f0105864 <strtol+0x66>
f01058cc:	eb 9e                	jmp    f010586c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01058ce:	89 c2                	mov    %eax,%edx
f01058d0:	f7 da                	neg    %edx
f01058d2:	85 ff                	test   %edi,%edi
f01058d4:	0f 45 c2             	cmovne %edx,%eax
}
f01058d7:	5b                   	pop    %ebx
f01058d8:	5e                   	pop    %esi
f01058d9:	5f                   	pop    %edi
f01058da:	5d                   	pop    %ebp
f01058db:	c3                   	ret    

f01058dc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01058dc:	fa                   	cli    

	xorw    %ax, %ax
f01058dd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01058df:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01058e1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01058e3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01058e5:	0f 01 16             	lgdtl  (%esi)
f01058e8:	74 70                	je     f010595a <mpsearch1+0x3>
	movl    %cr0, %eax
f01058ea:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01058ed:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01058f1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01058f4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01058fa:	08 00                	or     %al,(%eax)

f01058fc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01058fc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105900:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105902:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105904:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105906:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010590a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010590c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010590e:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0105913:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105916:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105919:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010591e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105921:	8b 25 90 1e 2a f0    	mov    0xf02a1e90,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105927:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010592c:	b8 0d 02 10 f0       	mov    $0xf010020d,%eax
	call    *%eax
f0105931:	ff d0                	call   *%eax

f0105933 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105933:	eb fe                	jmp    f0105933 <spin>
f0105935:	8d 76 00             	lea    0x0(%esi),%esi

f0105938 <gdt>:
	...
f0105940:	ff                   	(bad)  
f0105941:	ff 00                	incl   (%eax)
f0105943:	00 00                	add    %al,(%eax)
f0105945:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010594c:	00                   	.byte 0x0
f010594d:	92                   	xchg   %eax,%edx
f010594e:	cf                   	iret   
	...

f0105950 <gdtdesc>:
f0105950:	17                   	pop    %ss
f0105951:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105956 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105956:	90                   	nop

f0105957 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105957:	55                   	push   %ebp
f0105958:	89 e5                	mov    %esp,%ebp
f010595a:	57                   	push   %edi
f010595b:	56                   	push   %esi
f010595c:	53                   	push   %ebx
f010595d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105960:	8b 0d ac 1e 2a f0    	mov    0xf02a1eac,%ecx
f0105966:	89 c3                	mov    %eax,%ebx
f0105968:	c1 eb 0c             	shr    $0xc,%ebx
f010596b:	39 cb                	cmp    %ecx,%ebx
f010596d:	72 12                	jb     f0105981 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010596f:	50                   	push   %eax
f0105970:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0105975:	6a 57                	push   $0x57
f0105977:	68 fd 85 10 f0       	push   $0xf01085fd
f010597c:	e8 bf a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105981:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105987:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105989:	89 c2                	mov    %eax,%edx
f010598b:	c1 ea 0c             	shr    $0xc,%edx
f010598e:	39 ca                	cmp    %ecx,%edx
f0105990:	72 12                	jb     f01059a4 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105992:	50                   	push   %eax
f0105993:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0105998:	6a 57                	push   $0x57
f010599a:	68 fd 85 10 f0       	push   $0xf01085fd
f010599f:	e8 9c a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059a4:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01059aa:	eb 2f                	jmp    f01059db <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01059ac:	83 ec 04             	sub    $0x4,%esp
f01059af:	6a 04                	push   $0x4
f01059b1:	68 0d 86 10 f0       	push   $0xf010860d
f01059b6:	53                   	push   %ebx
f01059b7:	e8 e6 fd ff ff       	call   f01057a2 <memcmp>
f01059bc:	83 c4 10             	add    $0x10,%esp
f01059bf:	85 c0                	test   %eax,%eax
f01059c1:	75 15                	jne    f01059d8 <mpsearch1+0x81>
f01059c3:	89 da                	mov    %ebx,%edx
f01059c5:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01059c8:	0f b6 0a             	movzbl (%edx),%ecx
f01059cb:	01 c8                	add    %ecx,%eax
f01059cd:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01059d0:	39 d7                	cmp    %edx,%edi
f01059d2:	75 f4                	jne    f01059c8 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01059d4:	84 c0                	test   %al,%al
f01059d6:	74 0e                	je     f01059e6 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01059d8:	83 c3 10             	add    $0x10,%ebx
f01059db:	39 f3                	cmp    %esi,%ebx
f01059dd:	72 cd                	jb     f01059ac <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01059df:	b8 00 00 00 00       	mov    $0x0,%eax
f01059e4:	eb 02                	jmp    f01059e8 <mpsearch1+0x91>
f01059e6:	89 d8                	mov    %ebx,%eax
}
f01059e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059eb:	5b                   	pop    %ebx
f01059ec:	5e                   	pop    %esi
f01059ed:	5f                   	pop    %edi
f01059ee:	5d                   	pop    %ebp
f01059ef:	c3                   	ret    

f01059f0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01059f0:	55                   	push   %ebp
f01059f1:	89 e5                	mov    %esp,%ebp
f01059f3:	57                   	push   %edi
f01059f4:	56                   	push   %esi
f01059f5:	53                   	push   %ebx
f01059f6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01059f9:	c7 05 c0 23 2a f0 20 	movl   $0xf02a2020,0xf02a23c0
f0105a00:	20 2a f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a03:	83 3d ac 1e 2a f0 00 	cmpl   $0x0,0xf02a1eac
f0105a0a:	75 16                	jne    f0105a22 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a0c:	68 00 04 00 00       	push   $0x400
f0105a11:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0105a16:	6a 6f                	push   $0x6f
f0105a18:	68 fd 85 10 f0       	push   $0xf01085fd
f0105a1d:	e8 1e a6 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105a22:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105a29:	85 c0                	test   %eax,%eax
f0105a2b:	74 16                	je     f0105a43 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105a2d:	c1 e0 04             	shl    $0x4,%eax
f0105a30:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a35:	e8 1d ff ff ff       	call   f0105957 <mpsearch1>
f0105a3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a3d:	85 c0                	test   %eax,%eax
f0105a3f:	75 3c                	jne    f0105a7d <mp_init+0x8d>
f0105a41:	eb 20                	jmp    f0105a63 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105a43:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105a4a:	c1 e0 0a             	shl    $0xa,%eax
f0105a4d:	2d 00 04 00 00       	sub    $0x400,%eax
f0105a52:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a57:	e8 fb fe ff ff       	call   f0105957 <mpsearch1>
f0105a5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a5f:	85 c0                	test   %eax,%eax
f0105a61:	75 1a                	jne    f0105a7d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105a63:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a68:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105a6d:	e8 e5 fe ff ff       	call   f0105957 <mpsearch1>
f0105a72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105a75:	85 c0                	test   %eax,%eax
f0105a77:	0f 84 5d 02 00 00    	je     f0105cda <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105a7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a80:	8b 70 04             	mov    0x4(%eax),%esi
f0105a83:	85 f6                	test   %esi,%esi
f0105a85:	74 06                	je     f0105a8d <mp_init+0x9d>
f0105a87:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105a8b:	74 15                	je     f0105aa2 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105a8d:	83 ec 0c             	sub    $0xc,%esp
f0105a90:	68 70 84 10 f0       	push   $0xf0108470
f0105a95:	e8 52 dc ff ff       	call   f01036ec <cprintf>
f0105a9a:	83 c4 10             	add    $0x10,%esp
f0105a9d:	e9 38 02 00 00       	jmp    f0105cda <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105aa2:	89 f0                	mov    %esi,%eax
f0105aa4:	c1 e8 0c             	shr    $0xc,%eax
f0105aa7:	3b 05 ac 1e 2a f0    	cmp    0xf02a1eac,%eax
f0105aad:	72 15                	jb     f0105ac4 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105aaf:	56                   	push   %esi
f0105ab0:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0105ab5:	68 90 00 00 00       	push   $0x90
f0105aba:	68 fd 85 10 f0       	push   $0xf01085fd
f0105abf:	e8 7c a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ac4:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105aca:	83 ec 04             	sub    $0x4,%esp
f0105acd:	6a 04                	push   $0x4
f0105acf:	68 12 86 10 f0       	push   $0xf0108612
f0105ad4:	53                   	push   %ebx
f0105ad5:	e8 c8 fc ff ff       	call   f01057a2 <memcmp>
f0105ada:	83 c4 10             	add    $0x10,%esp
f0105add:	85 c0                	test   %eax,%eax
f0105adf:	74 15                	je     f0105af6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105ae1:	83 ec 0c             	sub    $0xc,%esp
f0105ae4:	68 a0 84 10 f0       	push   $0xf01084a0
f0105ae9:	e8 fe db ff ff       	call   f01036ec <cprintf>
f0105aee:	83 c4 10             	add    $0x10,%esp
f0105af1:	e9 e4 01 00 00       	jmp    f0105cda <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105af6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105afa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105afe:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b01:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b06:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b0b:	eb 0d                	jmp    f0105b1a <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105b0d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105b14:	f0 
f0105b15:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b17:	83 c0 01             	add    $0x1,%eax
f0105b1a:	39 c7                	cmp    %eax,%edi
f0105b1c:	75 ef                	jne    f0105b0d <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b1e:	84 d2                	test   %dl,%dl
f0105b20:	74 15                	je     f0105b37 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105b22:	83 ec 0c             	sub    $0xc,%esp
f0105b25:	68 d4 84 10 f0       	push   $0xf01084d4
f0105b2a:	e8 bd db ff ff       	call   f01036ec <cprintf>
f0105b2f:	83 c4 10             	add    $0x10,%esp
f0105b32:	e9 a3 01 00 00       	jmp    f0105cda <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105b37:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105b3b:	3c 01                	cmp    $0x1,%al
f0105b3d:	74 1d                	je     f0105b5c <mp_init+0x16c>
f0105b3f:	3c 04                	cmp    $0x4,%al
f0105b41:	74 19                	je     f0105b5c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105b43:	83 ec 08             	sub    $0x8,%esp
f0105b46:	0f b6 c0             	movzbl %al,%eax
f0105b49:	50                   	push   %eax
f0105b4a:	68 f8 84 10 f0       	push   $0xf01084f8
f0105b4f:	e8 98 db ff ff       	call   f01036ec <cprintf>
f0105b54:	83 c4 10             	add    $0x10,%esp
f0105b57:	e9 7e 01 00 00       	jmp    f0105cda <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b5c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105b60:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b64:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b69:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105b6e:	01 ce                	add    %ecx,%esi
f0105b70:	eb 0d                	jmp    f0105b7f <mp_init+0x18f>
f0105b72:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105b79:	f0 
f0105b7a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b7c:	83 c0 01             	add    $0x1,%eax
f0105b7f:	39 c7                	cmp    %eax,%edi
f0105b81:	75 ef                	jne    f0105b72 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b83:	89 d0                	mov    %edx,%eax
f0105b85:	02 43 2a             	add    0x2a(%ebx),%al
f0105b88:	74 15                	je     f0105b9f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105b8a:	83 ec 0c             	sub    $0xc,%esp
f0105b8d:	68 18 85 10 f0       	push   $0xf0108518
f0105b92:	e8 55 db ff ff       	call   f01036ec <cprintf>
f0105b97:	83 c4 10             	add    $0x10,%esp
f0105b9a:	e9 3b 01 00 00       	jmp    f0105cda <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105b9f:	85 db                	test   %ebx,%ebx
f0105ba1:	0f 84 33 01 00 00    	je     f0105cda <mp_init+0x2ea>
		return;
	ismp = 1;
f0105ba7:	c7 05 00 20 2a f0 01 	movl   $0x1,0xf02a2000
f0105bae:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105bb1:	8b 43 24             	mov    0x24(%ebx),%eax
f0105bb4:	a3 00 30 2e f0       	mov    %eax,0xf02e3000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105bb9:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105bbc:	be 00 00 00 00       	mov    $0x0,%esi
f0105bc1:	e9 85 00 00 00       	jmp    f0105c4b <mp_init+0x25b>
		switch (*p) {
f0105bc6:	0f b6 07             	movzbl (%edi),%eax
f0105bc9:	84 c0                	test   %al,%al
f0105bcb:	74 06                	je     f0105bd3 <mp_init+0x1e3>
f0105bcd:	3c 04                	cmp    $0x4,%al
f0105bcf:	77 55                	ja     f0105c26 <mp_init+0x236>
f0105bd1:	eb 4e                	jmp    f0105c21 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105bd3:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105bd7:	74 11                	je     f0105bea <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105bd9:	6b 05 c4 23 2a f0 74 	imul   $0x74,0xf02a23c4,%eax
f0105be0:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f0105be5:	a3 c0 23 2a f0       	mov    %eax,0xf02a23c0
			if (ncpu < NCPU) {
f0105bea:	a1 c4 23 2a f0       	mov    0xf02a23c4,%eax
f0105bef:	83 f8 07             	cmp    $0x7,%eax
f0105bf2:	7f 13                	jg     f0105c07 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105bf4:	6b d0 74             	imul   $0x74,%eax,%edx
f0105bf7:	88 82 20 20 2a f0    	mov    %al,-0xfd5dfe0(%edx)
				ncpu++;
f0105bfd:	83 c0 01             	add    $0x1,%eax
f0105c00:	a3 c4 23 2a f0       	mov    %eax,0xf02a23c4
f0105c05:	eb 15                	jmp    f0105c1c <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c07:	83 ec 08             	sub    $0x8,%esp
f0105c0a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105c0e:	50                   	push   %eax
f0105c0f:	68 48 85 10 f0       	push   $0xf0108548
f0105c14:	e8 d3 da ff ff       	call   f01036ec <cprintf>
f0105c19:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105c1c:	83 c7 14             	add    $0x14,%edi
			continue;
f0105c1f:	eb 27                	jmp    f0105c48 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105c21:	83 c7 08             	add    $0x8,%edi
			continue;
f0105c24:	eb 22                	jmp    f0105c48 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c26:	83 ec 08             	sub    $0x8,%esp
f0105c29:	0f b6 c0             	movzbl %al,%eax
f0105c2c:	50                   	push   %eax
f0105c2d:	68 70 85 10 f0       	push   $0xf0108570
f0105c32:	e8 b5 da ff ff       	call   f01036ec <cprintf>
			ismp = 0;
f0105c37:	c7 05 00 20 2a f0 00 	movl   $0x0,0xf02a2000
f0105c3e:	00 00 00 
			i = conf->entry;
f0105c41:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105c45:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c48:	83 c6 01             	add    $0x1,%esi
f0105c4b:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105c4f:	39 c6                	cmp    %eax,%esi
f0105c51:	0f 82 6f ff ff ff    	jb     f0105bc6 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105c57:	a1 c0 23 2a f0       	mov    0xf02a23c0,%eax
f0105c5c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105c63:	83 3d 00 20 2a f0 00 	cmpl   $0x0,0xf02a2000
f0105c6a:	75 26                	jne    f0105c92 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105c6c:	c7 05 c4 23 2a f0 01 	movl   $0x1,0xf02a23c4
f0105c73:	00 00 00 
		lapicaddr = 0;
f0105c76:	c7 05 00 30 2e f0 00 	movl   $0x0,0xf02e3000
f0105c7d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105c80:	83 ec 0c             	sub    $0xc,%esp
f0105c83:	68 90 85 10 f0       	push   $0xf0108590
f0105c88:	e8 5f da ff ff       	call   f01036ec <cprintf>
		return;
f0105c8d:	83 c4 10             	add    $0x10,%esp
f0105c90:	eb 48                	jmp    f0105cda <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105c92:	83 ec 04             	sub    $0x4,%esp
f0105c95:	ff 35 c4 23 2a f0    	pushl  0xf02a23c4
f0105c9b:	0f b6 00             	movzbl (%eax),%eax
f0105c9e:	50                   	push   %eax
f0105c9f:	68 17 86 10 f0       	push   $0xf0108617
f0105ca4:	e8 43 da ff ff       	call   f01036ec <cprintf>

	if (mp->imcrp) {
f0105ca9:	83 c4 10             	add    $0x10,%esp
f0105cac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105caf:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105cb3:	74 25                	je     f0105cda <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105cb5:	83 ec 0c             	sub    $0xc,%esp
f0105cb8:	68 bc 85 10 f0       	push   $0xf01085bc
f0105cbd:	e8 2a da ff ff       	call   f01036ec <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105cc2:	ba 22 00 00 00       	mov    $0x22,%edx
f0105cc7:	b8 70 00 00 00       	mov    $0x70,%eax
f0105ccc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105ccd:	ba 23 00 00 00       	mov    $0x23,%edx
f0105cd2:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105cd3:	83 c8 01             	or     $0x1,%eax
f0105cd6:	ee                   	out    %al,(%dx)
f0105cd7:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cdd:	5b                   	pop    %ebx
f0105cde:	5e                   	pop    %esi
f0105cdf:	5f                   	pop    %edi
f0105ce0:	5d                   	pop    %ebp
f0105ce1:	c3                   	ret    

f0105ce2 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105ce2:	55                   	push   %ebp
f0105ce3:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105ce5:	8b 0d 04 30 2e f0    	mov    0xf02e3004,%ecx
f0105ceb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105cee:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105cf0:	a1 04 30 2e f0       	mov    0xf02e3004,%eax
f0105cf5:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105cf8:	5d                   	pop    %ebp
f0105cf9:	c3                   	ret    

f0105cfa <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105cfa:	55                   	push   %ebp
f0105cfb:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105cfd:	a1 04 30 2e f0       	mov    0xf02e3004,%eax
f0105d02:	85 c0                	test   %eax,%eax
f0105d04:	74 08                	je     f0105d0e <cpunum+0x14>
		return lapic[ID] >> 24;
f0105d06:	8b 40 20             	mov    0x20(%eax),%eax
f0105d09:	c1 e8 18             	shr    $0x18,%eax
f0105d0c:	eb 05                	jmp    f0105d13 <cpunum+0x19>
	return 0;
f0105d0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d13:	5d                   	pop    %ebp
f0105d14:	c3                   	ret    

f0105d15 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105d15:	a1 00 30 2e f0       	mov    0xf02e3000,%eax
f0105d1a:	85 c0                	test   %eax,%eax
f0105d1c:	0f 84 21 01 00 00    	je     f0105e43 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105d22:	55                   	push   %ebp
f0105d23:	89 e5                	mov    %esp,%ebp
f0105d25:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105d28:	68 00 10 00 00       	push   $0x1000
f0105d2d:	50                   	push   %eax
f0105d2e:	e8 79 b5 ff ff       	call   f01012ac <mmio_map_region>
f0105d33:	a3 04 30 2e f0       	mov    %eax,0xf02e3004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105d38:	ba 27 01 00 00       	mov    $0x127,%edx
f0105d3d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105d42:	e8 9b ff ff ff       	call   f0105ce2 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105d47:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105d4c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105d51:	e8 8c ff ff ff       	call   f0105ce2 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105d56:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105d5b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105d60:	e8 7d ff ff ff       	call   f0105ce2 <lapicw>
	lapicw(TICR, 10000000); 
f0105d65:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105d6a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105d6f:	e8 6e ff ff ff       	call   f0105ce2 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105d74:	e8 81 ff ff ff       	call   f0105cfa <cpunum>
f0105d79:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d7c:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f0105d81:	83 c4 10             	add    $0x10,%esp
f0105d84:	39 05 c0 23 2a f0    	cmp    %eax,0xf02a23c0
f0105d8a:	74 0f                	je     f0105d9b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105d8c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d91:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105d96:	e8 47 ff ff ff       	call   f0105ce2 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105d9b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105da0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105da5:	e8 38 ff ff ff       	call   f0105ce2 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105daa:	a1 04 30 2e f0       	mov    0xf02e3004,%eax
f0105daf:	8b 40 30             	mov    0x30(%eax),%eax
f0105db2:	c1 e8 10             	shr    $0x10,%eax
f0105db5:	3c 03                	cmp    $0x3,%al
f0105db7:	76 0f                	jbe    f0105dc8 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105db9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105dbe:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105dc3:	e8 1a ff ff ff       	call   f0105ce2 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105dc8:	ba 33 00 00 00       	mov    $0x33,%edx
f0105dcd:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105dd2:	e8 0b ff ff ff       	call   f0105ce2 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105dd7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ddc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105de1:	e8 fc fe ff ff       	call   f0105ce2 <lapicw>
	lapicw(ESR, 0);
f0105de6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105deb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105df0:	e8 ed fe ff ff       	call   f0105ce2 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105df5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dfa:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105dff:	e8 de fe ff ff       	call   f0105ce2 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105e04:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e09:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e0e:	e8 cf fe ff ff       	call   f0105ce2 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e13:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105e18:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e1d:	e8 c0 fe ff ff       	call   f0105ce2 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105e22:	8b 15 04 30 2e f0    	mov    0xf02e3004,%edx
f0105e28:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e2e:	f6 c4 10             	test   $0x10,%ah
f0105e31:	75 f5                	jne    f0105e28 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105e33:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e38:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e3d:	e8 a0 fe ff ff       	call   f0105ce2 <lapicw>
}
f0105e42:	c9                   	leave  
f0105e43:	f3 c3                	repz ret 

f0105e45 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105e45:	83 3d 04 30 2e f0 00 	cmpl   $0x0,0xf02e3004
f0105e4c:	74 13                	je     f0105e61 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105e4e:	55                   	push   %ebp
f0105e4f:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105e51:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e56:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e5b:	e8 82 fe ff ff       	call   f0105ce2 <lapicw>
}
f0105e60:	5d                   	pop    %ebp
f0105e61:	f3 c3                	repz ret 

f0105e63 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105e63:	55                   	push   %ebp
f0105e64:	89 e5                	mov    %esp,%ebp
f0105e66:	56                   	push   %esi
f0105e67:	53                   	push   %ebx
f0105e68:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105e6e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105e73:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105e78:	ee                   	out    %al,(%dx)
f0105e79:	ba 71 00 00 00       	mov    $0x71,%edx
f0105e7e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105e83:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e84:	83 3d ac 1e 2a f0 00 	cmpl   $0x0,0xf02a1eac
f0105e8b:	75 19                	jne    f0105ea6 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e8d:	68 67 04 00 00       	push   $0x467
f0105e92:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0105e97:	68 98 00 00 00       	push   $0x98
f0105e9c:	68 34 86 10 f0       	push   $0xf0108634
f0105ea1:	e8 9a a1 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105ea6:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105ead:	00 00 
	wrv[1] = addr >> 4;
f0105eaf:	89 d8                	mov    %ebx,%eax
f0105eb1:	c1 e8 04             	shr    $0x4,%eax
f0105eb4:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105eba:	c1 e6 18             	shl    $0x18,%esi
f0105ebd:	89 f2                	mov    %esi,%edx
f0105ebf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ec4:	e8 19 fe ff ff       	call   f0105ce2 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105ec9:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105ece:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ed3:	e8 0a fe ff ff       	call   f0105ce2 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105ed8:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105edd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ee2:	e8 fb fd ff ff       	call   f0105ce2 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ee7:	c1 eb 0c             	shr    $0xc,%ebx
f0105eea:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105eed:	89 f2                	mov    %esi,%edx
f0105eef:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ef4:	e8 e9 fd ff ff       	call   f0105ce2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ef9:	89 da                	mov    %ebx,%edx
f0105efb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f00:	e8 dd fd ff ff       	call   f0105ce2 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f05:	89 f2                	mov    %esi,%edx
f0105f07:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f0c:	e8 d1 fd ff ff       	call   f0105ce2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f11:	89 da                	mov    %ebx,%edx
f0105f13:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f18:	e8 c5 fd ff ff       	call   f0105ce2 <lapicw>
		microdelay(200);
	}
}
f0105f1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f20:	5b                   	pop    %ebx
f0105f21:	5e                   	pop    %esi
f0105f22:	5d                   	pop    %ebp
f0105f23:	c3                   	ret    

f0105f24 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105f24:	55                   	push   %ebp
f0105f25:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105f27:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f2a:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105f30:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f35:	e8 a8 fd ff ff       	call   f0105ce2 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105f3a:	8b 15 04 30 2e f0    	mov    0xf02e3004,%edx
f0105f40:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f46:	f6 c4 10             	test   $0x10,%ah
f0105f49:	75 f5                	jne    f0105f40 <lapic_ipi+0x1c>
		;
}
f0105f4b:	5d                   	pop    %ebp
f0105f4c:	c3                   	ret    

f0105f4d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105f4d:	55                   	push   %ebp
f0105f4e:	89 e5                	mov    %esp,%ebp
f0105f50:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105f53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105f59:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f5c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105f5f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105f66:	5d                   	pop    %ebp
f0105f67:	c3                   	ret    

f0105f68 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105f68:	55                   	push   %ebp
f0105f69:	89 e5                	mov    %esp,%ebp
f0105f6b:	56                   	push   %esi
f0105f6c:	53                   	push   %ebx
f0105f6d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f70:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105f73:	74 14                	je     f0105f89 <spin_lock+0x21>
f0105f75:	8b 73 08             	mov    0x8(%ebx),%esi
f0105f78:	e8 7d fd ff ff       	call   f0105cfa <cpunum>
f0105f7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f80:	05 20 20 2a f0       	add    $0xf02a2020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105f85:	39 c6                	cmp    %eax,%esi
f0105f87:	74 07                	je     f0105f90 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105f89:	ba 01 00 00 00       	mov    $0x1,%edx
f0105f8e:	eb 20                	jmp    f0105fb0 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105f90:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105f93:	e8 62 fd ff ff       	call   f0105cfa <cpunum>
f0105f98:	83 ec 0c             	sub    $0xc,%esp
f0105f9b:	53                   	push   %ebx
f0105f9c:	50                   	push   %eax
f0105f9d:	68 44 86 10 f0       	push   $0xf0108644
f0105fa2:	6a 41                	push   $0x41
f0105fa4:	68 a6 86 10 f0       	push   $0xf01086a6
f0105fa9:	e8 92 a0 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105fae:	f3 90                	pause  
f0105fb0:	89 d0                	mov    %edx,%eax
f0105fb2:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105fb5:	85 c0                	test   %eax,%eax
f0105fb7:	75 f5                	jne    f0105fae <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105fb9:	e8 3c fd ff ff       	call   f0105cfa <cpunum>
f0105fbe:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fc1:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f0105fc6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105fc9:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105fcc:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105fce:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fd3:	eb 0b                	jmp    f0105fe0 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105fd5:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105fd8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105fdb:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105fdd:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105fe0:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105fe6:	76 11                	jbe    f0105ff9 <spin_lock+0x91>
f0105fe8:	83 f8 09             	cmp    $0x9,%eax
f0105feb:	7e e8                	jle    f0105fd5 <spin_lock+0x6d>
f0105fed:	eb 0a                	jmp    f0105ff9 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105fef:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105ff6:	83 c0 01             	add    $0x1,%eax
f0105ff9:	83 f8 09             	cmp    $0x9,%eax
f0105ffc:	7e f1                	jle    f0105fef <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105ffe:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106001:	5b                   	pop    %ebx
f0106002:	5e                   	pop    %esi
f0106003:	5d                   	pop    %ebp
f0106004:	c3                   	ret    

f0106005 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106005:	55                   	push   %ebp
f0106006:	89 e5                	mov    %esp,%ebp
f0106008:	57                   	push   %edi
f0106009:	56                   	push   %esi
f010600a:	53                   	push   %ebx
f010600b:	83 ec 4c             	sub    $0x4c,%esp
f010600e:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106011:	83 3e 00             	cmpl   $0x0,(%esi)
f0106014:	74 18                	je     f010602e <spin_unlock+0x29>
f0106016:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106019:	e8 dc fc ff ff       	call   f0105cfa <cpunum>
f010601e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106021:	05 20 20 2a f0       	add    $0xf02a2020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106026:	39 c3                	cmp    %eax,%ebx
f0106028:	0f 84 a5 00 00 00    	je     f01060d3 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010602e:	83 ec 04             	sub    $0x4,%esp
f0106031:	6a 28                	push   $0x28
f0106033:	8d 46 0c             	lea    0xc(%esi),%eax
f0106036:	50                   	push   %eax
f0106037:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010603a:	53                   	push   %ebx
f010603b:	e8 e7 f6 ff ff       	call   f0105727 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106040:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106043:	0f b6 38             	movzbl (%eax),%edi
f0106046:	8b 76 04             	mov    0x4(%esi),%esi
f0106049:	e8 ac fc ff ff       	call   f0105cfa <cpunum>
f010604e:	57                   	push   %edi
f010604f:	56                   	push   %esi
f0106050:	50                   	push   %eax
f0106051:	68 70 86 10 f0       	push   $0xf0108670
f0106056:	e8 91 d6 ff ff       	call   f01036ec <cprintf>
f010605b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010605e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106061:	eb 54                	jmp    f01060b7 <spin_unlock+0xb2>
f0106063:	83 ec 08             	sub    $0x8,%esp
f0106066:	57                   	push   %edi
f0106067:	50                   	push   %eax
f0106068:	e8 e3 eb ff ff       	call   f0104c50 <debuginfo_eip>
f010606d:	83 c4 10             	add    $0x10,%esp
f0106070:	85 c0                	test   %eax,%eax
f0106072:	78 27                	js     f010609b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106074:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106076:	83 ec 04             	sub    $0x4,%esp
f0106079:	89 c2                	mov    %eax,%edx
f010607b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010607e:	52                   	push   %edx
f010607f:	ff 75 b0             	pushl  -0x50(%ebp)
f0106082:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106085:	ff 75 ac             	pushl  -0x54(%ebp)
f0106088:	ff 75 a8             	pushl  -0x58(%ebp)
f010608b:	50                   	push   %eax
f010608c:	68 b6 86 10 f0       	push   $0xf01086b6
f0106091:	e8 56 d6 ff ff       	call   f01036ec <cprintf>
f0106096:	83 c4 20             	add    $0x20,%esp
f0106099:	eb 12                	jmp    f01060ad <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010609b:	83 ec 08             	sub    $0x8,%esp
f010609e:	ff 36                	pushl  (%esi)
f01060a0:	68 cd 86 10 f0       	push   $0xf01086cd
f01060a5:	e8 42 d6 ff ff       	call   f01036ec <cprintf>
f01060aa:	83 c4 10             	add    $0x10,%esp
f01060ad:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01060b0:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01060b3:	39 c3                	cmp    %eax,%ebx
f01060b5:	74 08                	je     f01060bf <spin_unlock+0xba>
f01060b7:	89 de                	mov    %ebx,%esi
f01060b9:	8b 03                	mov    (%ebx),%eax
f01060bb:	85 c0                	test   %eax,%eax
f01060bd:	75 a4                	jne    f0106063 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01060bf:	83 ec 04             	sub    $0x4,%esp
f01060c2:	68 d5 86 10 f0       	push   $0xf01086d5
f01060c7:	6a 67                	push   $0x67
f01060c9:	68 a6 86 10 f0       	push   $0xf01086a6
f01060ce:	e8 6d 9f ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01060d3:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01060da:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01060e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01060e6:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01060e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01060ec:	5b                   	pop    %ebx
f01060ed:	5e                   	pop    %esi
f01060ee:	5f                   	pop    %edi
f01060ef:	5d                   	pop    %ebp
f01060f0:	c3                   	ret    

f01060f1 <e1000_attach>:
	e1000[E1000_TCTL] = VALUEATMASK(1, E1000_TCTL_EN) | VALUEATMASK(1, E1000_TCTL_PSP) | VALUEATMASK(0x10, E1000_TCTL_CT)
	| VALUEATMASK(0x40,E1000_TCTL_COLD);
	e1000[E1000_TIPG] = VALUEATMASK(10, E1000_TIPG_IPGT) | VALUEATMASK(8, E1000_TIPG_IPGR1) | VALUEATMASK(6, E1000_TIPG_IPGR2);
	
}
int e1000_attach(struct pci_func *pcif) {
f01060f1:	55                   	push   %ebp
f01060f2:	89 e5                	mov    %esp,%ebp
f01060f4:	53                   	push   %ebx
f01060f5:	83 ec 10             	sub    $0x10,%esp
f01060f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif); // enable PCI function
f01060fb:	53                   	push   %ebx
f01060fc:	e8 3f 05 00 00       	call   f0106640 <pci_func_enable>
	e1000 = mmio_map_region(pcif->reg_base[0], pcif->reg_size[0]); // create virtual memory mapping
f0106101:	83 c4 08             	add    $0x8,%esp
f0106104:	ff 73 2c             	pushl  0x2c(%ebx)
f0106107:	ff 73 14             	pushl  0x14(%ebx)
f010610a:	e8 9d b1 ff ff       	call   f01012ac <mmio_map_region>
f010610f:	a3 b8 1e 2a f0       	mov    %eax,0xf02a1eb8
 	assert(e1000[E1000_STATUS] == 0x80080783);
f0106114:	8b 50 08             	mov    0x8(%eax),%edx
f0106117:	83 c4 10             	add    $0x10,%esp
f010611a:	81 fa 83 07 08 80    	cmp    $0x80080783,%edx
f0106120:	74 16                	je     f0106138 <e1000_attach+0x47>
f0106122:	68 f0 86 10 f0       	push   $0xf01086f0
f0106127:	68 5f 70 10 f0       	push   $0xf010705f
f010612c:	6a 1f                	push   $0x1f
f010612e:	68 12 87 10 f0       	push   $0xf0108712
f0106133:	e8 08 9f ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106138:	ba 00 40 32 f0       	mov    $0xf0324000,%edx
f010613d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106143:	77 12                	ja     f0106157 <e1000_attach+0x66>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106145:	52                   	push   %edx
f0106146:	68 c8 6a 10 f0       	push   $0xf0106ac8
f010614b:	6a 12                	push   $0x12
f010614d:	68 12 87 10 f0       	push   $0xf0108712
f0106152:	e8 e9 9e ff ff       	call   f0100040 <_panic>
		tx_desc_buf[i].upper.fields.status = E1000_TXD_STAT_DD;
	}
}

static void e1000_init() {
	e1000[E1000_TDBAL] = PADDR(tx_desc_buf);
f0106157:	c7 80 00 38 00 00 00 	movl   $0x324000,0x3800(%eax)
f010615e:	40 32 00 
	e1000[E1000_TDBAH] = 0x0;
f0106161:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f0106168:	00 00 00 
	e1000[E1000_TDH] = 0x0;
f010616b:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f0106172:	00 00 00 
	e1000[E1000_TDT] = 0x0;
f0106175:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f010617c:	00 00 00 
	e1000[E1000_TDLEN] = TXRING_LEN * sizeof(struct e1000_tx_desc);
f010617f:	c7 80 08 38 00 00 00 	movl   $0x400,0x3808(%eax)
f0106186:	04 00 00 
	e1000[E1000_TCTL] = VALUEATMASK(1, E1000_TCTL_EN) | VALUEATMASK(1, E1000_TCTL_PSP) | VALUEATMASK(0x10, E1000_TCTL_CT)
f0106189:	c7 80 00 04 00 00 0a 	movl   $0x4010a,0x400(%eax)
f0106190:	01 04 00 
	| VALUEATMASK(0x40,E1000_TCTL_COLD);
	e1000[E1000_TIPG] = VALUEATMASK(10, E1000_TIPG_IPGT) | VALUEATMASK(8, E1000_TIPG_IPGR1) | VALUEATMASK(6, E1000_TIPG_IPGR2);
f0106193:	c7 80 10 04 00 00 0a 	movl   $0x60500a,0x410(%eax)
f010619a:	50 60 00 
f010619d:	b8 00 40 2e f0       	mov    $0xf02e4000,%eax
f01061a2:	bb 00 40 32 f0       	mov    $0xf0324000,%ebx
f01061a7:	ba 00 40 32 f0       	mov    $0xf0324000,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01061ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01061b1:	77 12                	ja     f01061c5 <e1000_attach+0xd4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01061b3:	50                   	push   %eax
f01061b4:	68 c8 6a 10 f0       	push   $0xf0106ac8
f01061b9:	6a 0c                	push   $0xc
f01061bb:	68 12 87 10 f0       	push   $0xf0108712
f01061c0:	e8 7b 9e ff ff       	call   f0100040 <_panic>

static void init_desc() {
	int i;
	for (i = 0; i < TXRING_LEN; i++)
	{
		tx_desc_buf[i].buffer_addr = PADDR(&tx_data_buf[i]);
f01061c5:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01061cb:	89 0a                	mov    %ecx,(%edx)
f01061cd:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
		tx_desc_buf[i].upper.fields.status = E1000_TXD_STAT_DD;
f01061d4:	c6 42 0c 01          	movb   $0x1,0xc(%edx)
f01061d8:	05 00 10 00 00       	add    $0x1000,%eax
f01061dd:	83 c2 10             	add    $0x10,%edx
struct e1000_tx_desc tx_desc_buf[TXRING_LEN] __attribute__ ((aligned (PGSIZE)));
struct e1000_data tx_data_buf[TXRING_LEN] __attribute__ ((aligned (PGSIZE)));

static void init_desc() {
	int i;
	for (i = 0; i < TXRING_LEN; i++)
f01061e0:	39 d8                	cmp    %ebx,%eax
f01061e2:	75 c8                	jne    f01061ac <e1000_attach+0xbb>
 	assert(e1000[E1000_STATUS] == 0x80080783);
 	//cprintf("E1000 status: %08x\n", e1000[E1000_STATUS]);
 	e1000_init();
 	init_desc();
 	return 0;
}
f01061e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01061e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01061ec:	c9                   	leave  
f01061ed:	c3                   	ret    

f01061ee <e1000_xmit>:

int e1000_xmit(uint8_t * addr, size_t length) {
f01061ee:	55                   	push   %ebp
f01061ef:	89 e5                	mov    %esp,%ebp
f01061f1:	56                   	push   %esi
f01061f2:	53                   	push   %ebx
f01061f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t tail = e1000[E1000_TDT];
f01061f6:	8b 15 b8 1e 2a f0    	mov    0xf02a1eb8,%edx
f01061fc:	8b 9a 18 38 00 00    	mov    0x3818(%edx),%ebx
	struct e1000_tx_desc * tail_desc = &tx_desc_buf[tail];
	if (tail_desc->upper.fields.status != E1000_TXD_STAT_DD)
f0106202:	89 da                	mov    %ebx,%edx
f0106204:	c1 e2 04             	shl    $0x4,%edx
f0106207:	80 ba 0c 40 32 f0 01 	cmpb   $0x1,-0xfcdbff4(%edx)
f010620e:	75 5e                	jne    f010626e <e1000_xmit+0x80>
	{
		return -1;
	}
	length = length >  DATA_SIZE ?  DATA_SIZE : length;
f0106210:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0106215:	be 00 10 00 00       	mov    $0x1000,%esi
f010621a:	0f 46 f0             	cmovbe %eax,%esi
	memmove(&tx_data_buf[tail], addr, length);
f010621d:	83 ec 04             	sub    $0x4,%esp
f0106220:	56                   	push   %esi
f0106221:	ff 75 08             	pushl  0x8(%ebp)
f0106224:	89 d8                	mov    %ebx,%eax
f0106226:	c1 e0 0c             	shl    $0xc,%eax
f0106229:	05 00 40 2e f0       	add    $0xf02e4000,%eax
f010622e:	50                   	push   %eax
f010622f:	e8 f3 f4 ff ff       	call   f0105727 <memmove>
	tail_desc->lower.flags.length = length;
f0106234:	89 d8                	mov    %ebx,%eax
f0106236:	c1 e0 04             	shl    $0x4,%eax
f0106239:	66 89 b0 08 40 32 f0 	mov    %si,-0xfcdbff8(%eax)
	tail_desc->upper.fields.status = 0;
f0106240:	c6 80 0c 40 32 f0 00 	movb   $0x0,-0xfcdbff4(%eax)
	{
		return -1;
	}
	length = length >  DATA_SIZE ?  DATA_SIZE : length;
	memmove(&tx_data_buf[tail], addr, length);
	tail_desc->lower.flags.length = length;
f0106247:	05 00 40 32 f0       	add    $0xf0324000,%eax
	tail_desc->upper.fields.status = 0;
	tail_desc->lower.data |=  (E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP);
f010624c:	81 48 08 00 00 00 09 	orl    $0x9000000,0x8(%eax)
	e1000[E1000_TDT] = (tail + 1) % TXRING_LEN;
f0106253:	83 c3 01             	add    $0x1,%ebx
f0106256:	83 e3 3f             	and    $0x3f,%ebx
f0106259:	a1 b8 1e 2a f0       	mov    0xf02a1eb8,%eax
f010625e:	89 98 18 38 00 00    	mov    %ebx,0x3818(%eax)
	
	return 0;
f0106264:	83 c4 10             	add    $0x10,%esp
f0106267:	b8 00 00 00 00       	mov    $0x0,%eax
f010626c:	eb 05                	jmp    f0106273 <e1000_xmit+0x85>
int e1000_xmit(uint8_t * addr, size_t length) {
	uint32_t tail = e1000[E1000_TDT];
	struct e1000_tx_desc * tail_desc = &tx_desc_buf[tail];
	if (tail_desc->upper.fields.status != E1000_TXD_STAT_DD)
	{
		return -1;
f010626e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	tail_desc->upper.fields.status = 0;
	tail_desc->lower.data |=  (E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP);
	e1000[E1000_TDT] = (tail + 1) % TXRING_LEN;
	
	return 0;
}
f0106273:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106276:	5b                   	pop    %ebx
f0106277:	5e                   	pop    %esi
f0106278:	5d                   	pop    %ebp
f0106279:	c3                   	ret    

f010627a <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f010627a:	55                   	push   %ebp
f010627b:	89 e5                	mov    %esp,%ebp
f010627d:	57                   	push   %edi
f010627e:	56                   	push   %esi
f010627f:	53                   	push   %ebx
f0106280:	83 ec 0c             	sub    $0xc,%esp
f0106283:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106286:	8b 45 10             	mov    0x10(%ebp),%eax
f0106289:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f010628c:	eb 3a                	jmp    f01062c8 <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f010628e:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f0106291:	75 32                	jne    f01062c5 <pci_attach_match+0x4b>
f0106293:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106296:	39 56 fc             	cmp    %edx,-0x4(%esi)
f0106299:	75 2a                	jne    f01062c5 <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f010629b:	83 ec 0c             	sub    $0xc,%esp
f010629e:	ff 75 14             	pushl  0x14(%ebp)
f01062a1:	ff d0                	call   *%eax
			if (r > 0)
f01062a3:	83 c4 10             	add    $0x10,%esp
f01062a6:	85 c0                	test   %eax,%eax
f01062a8:	7f 26                	jg     f01062d0 <pci_attach_match+0x56>
				return r;
			if (r < 0)
f01062aa:	85 c0                	test   %eax,%eax
f01062ac:	79 17                	jns    f01062c5 <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f01062ae:	83 ec 0c             	sub    $0xc,%esp
f01062b1:	50                   	push   %eax
f01062b2:	ff 36                	pushl  (%esi)
f01062b4:	ff 75 0c             	pushl  0xc(%ebp)
f01062b7:	57                   	push   %edi
f01062b8:	68 20 87 10 f0       	push   $0xf0108720
f01062bd:	e8 2a d4 ff ff       	call   f01036ec <cprintf>
f01062c2:	83 c4 20             	add    $0x20,%esp
f01062c5:	83 c3 0c             	add    $0xc,%ebx
f01062c8:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f01062ca:	8b 03                	mov    (%ebx),%eax
f01062cc:	85 c0                	test   %eax,%eax
f01062ce:	75 be                	jne    f010628e <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f01062d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062d3:	5b                   	pop    %ebx
f01062d4:	5e                   	pop    %esi
f01062d5:	5f                   	pop    %edi
f01062d6:	5d                   	pop    %ebp
f01062d7:	c3                   	ret    

f01062d8 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f01062d8:	55                   	push   %ebp
f01062d9:	89 e5                	mov    %esp,%ebp
f01062db:	53                   	push   %ebx
f01062dc:	83 ec 04             	sub    $0x4,%esp
f01062df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f01062e2:	3d ff 00 00 00       	cmp    $0xff,%eax
f01062e7:	76 16                	jbe    f01062ff <pci_conf1_set_addr+0x27>
f01062e9:	68 78 88 10 f0       	push   $0xf0108878
f01062ee:	68 5f 70 10 f0       	push   $0xf010705f
f01062f3:	6a 2c                	push   $0x2c
f01062f5:	68 82 88 10 f0       	push   $0xf0108882
f01062fa:	e8 41 9d ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f01062ff:	83 fa 1f             	cmp    $0x1f,%edx
f0106302:	76 16                	jbe    f010631a <pci_conf1_set_addr+0x42>
f0106304:	68 8d 88 10 f0       	push   $0xf010888d
f0106309:	68 5f 70 10 f0       	push   $0xf010705f
f010630e:	6a 2d                	push   $0x2d
f0106310:	68 82 88 10 f0       	push   $0xf0108882
f0106315:	e8 26 9d ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f010631a:	83 f9 07             	cmp    $0x7,%ecx
f010631d:	76 16                	jbe    f0106335 <pci_conf1_set_addr+0x5d>
f010631f:	68 96 88 10 f0       	push   $0xf0108896
f0106324:	68 5f 70 10 f0       	push   $0xf010705f
f0106329:	6a 2e                	push   $0x2e
f010632b:	68 82 88 10 f0       	push   $0xf0108882
f0106330:	e8 0b 9d ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f0106335:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f010633b:	76 16                	jbe    f0106353 <pci_conf1_set_addr+0x7b>
f010633d:	68 9f 88 10 f0       	push   $0xf010889f
f0106342:	68 5f 70 10 f0       	push   $0xf010705f
f0106347:	6a 2f                	push   $0x2f
f0106349:	68 82 88 10 f0       	push   $0xf0108882
f010634e:	e8 ed 9c ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f0106353:	f6 c3 03             	test   $0x3,%bl
f0106356:	74 16                	je     f010636e <pci_conf1_set_addr+0x96>
f0106358:	68 ac 88 10 f0       	push   $0xf01088ac
f010635d:	68 5f 70 10 f0       	push   $0xf010705f
f0106362:	6a 30                	push   $0x30
f0106364:	68 82 88 10 f0       	push   $0xf0108882
f0106369:	e8 d2 9c ff ff       	call   f0100040 <_panic>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f010636e:	c1 e1 08             	shl    $0x8,%ecx
f0106371:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f0106377:	09 cb                	or     %ecx,%ebx
f0106379:	c1 e2 0b             	shl    $0xb,%edx
f010637c:	09 d3                	or     %edx,%ebx
f010637e:	c1 e0 10             	shl    $0x10,%eax
f0106381:	09 d8                	or     %ebx,%eax
f0106383:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0106388:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0106389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010638c:	c9                   	leave  
f010638d:	c3                   	ret    

f010638e <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f010638e:	55                   	push   %ebp
f010638f:	89 e5                	mov    %esp,%ebp
f0106391:	53                   	push   %ebx
f0106392:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106395:	8b 48 08             	mov    0x8(%eax),%ecx
f0106398:	8b 58 04             	mov    0x4(%eax),%ebx
f010639b:	8b 00                	mov    (%eax),%eax
f010639d:	8b 40 04             	mov    0x4(%eax),%eax
f01063a0:	52                   	push   %edx
f01063a1:	89 da                	mov    %ebx,%edx
f01063a3:	e8 30 ff ff ff       	call   f01062d8 <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f01063a8:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01063ad:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f01063ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01063b1:	c9                   	leave  
f01063b2:	c3                   	ret    

f01063b3 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f01063b3:	55                   	push   %ebp
f01063b4:	89 e5                	mov    %esp,%ebp
f01063b6:	57                   	push   %edi
f01063b7:	56                   	push   %esi
f01063b8:	53                   	push   %ebx
f01063b9:	81 ec 00 01 00 00    	sub    $0x100,%esp
f01063bf:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f01063c1:	6a 48                	push   $0x48
f01063c3:	6a 00                	push   $0x0
f01063c5:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01063c8:	50                   	push   %eax
f01063c9:	e8 0c f3 ff ff       	call   f01056da <memset>
	df.bus = bus;
f01063ce:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01063d1:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01063d8:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f01063db:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f01063e2:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f01063e5:	ba 0c 00 00 00       	mov    $0xc,%edx
f01063ea:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01063ed:	e8 9c ff ff ff       	call   f010638e <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f01063f2:	89 c2                	mov    %eax,%edx
f01063f4:	c1 ea 10             	shr    $0x10,%edx
f01063f7:	83 e2 7f             	and    $0x7f,%edx
f01063fa:	83 fa 01             	cmp    $0x1,%edx
f01063fd:	0f 87 4b 01 00 00    	ja     f010654e <pci_scan_bus+0x19b>
			continue;

		totaldev++;
f0106403:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f010640a:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f0106410:	8d 75 a0             	lea    -0x60(%ebp),%esi
f0106413:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106418:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010641a:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f0106421:	00 00 00 
f0106424:	25 00 00 80 00       	and    $0x800000,%eax
f0106429:	83 f8 01             	cmp    $0x1,%eax
f010642c:	19 c0                	sbb    %eax,%eax
f010642e:	83 e0 f9             	and    $0xfffffff9,%eax
f0106431:	83 c0 08             	add    $0x8,%eax
f0106434:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f010643a:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106440:	e9 f7 00 00 00       	jmp    f010653c <pci_scan_bus+0x189>
		     f.func++) {
			struct pci_func af = f;
f0106445:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f010644b:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f0106451:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106456:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f0106458:	ba 00 00 00 00       	mov    $0x0,%edx
f010645d:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f0106463:	e8 26 ff ff ff       	call   f010638e <pci_conf_read>
f0106468:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f010646e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0106472:	0f 84 bd 00 00 00    	je     f0106535 <pci_scan_bus+0x182>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106478:	ba 3c 00 00 00       	mov    $0x3c,%edx
f010647d:	89 d8                	mov    %ebx,%eax
f010647f:	e8 0a ff ff ff       	call   f010638e <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f0106484:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0106487:	ba 08 00 00 00       	mov    $0x8,%edx
f010648c:	89 d8                	mov    %ebx,%eax
f010648e:	e8 fb fe ff ff       	call   f010638e <pci_conf_read>
f0106493:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f0106499:	89 c1                	mov    %eax,%ecx
f010649b:	c1 e9 18             	shr    $0x18,%ecx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f010649e:	be c0 88 10 f0       	mov    $0xf01088c0,%esi
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f01064a3:	83 f9 06             	cmp    $0x6,%ecx
f01064a6:	77 07                	ja     f01064af <pci_scan_bus+0xfc>
		class = pci_class[PCI_CLASS(f->dev_class)];
f01064a8:	8b 34 8d 34 89 10 f0 	mov    -0xfef76cc(,%ecx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01064af:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01064b5:	83 ec 08             	sub    $0x8,%esp
f01064b8:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f01064bc:	57                   	push   %edi
f01064bd:	56                   	push   %esi
f01064be:	c1 e8 10             	shr    $0x10,%eax
f01064c1:	0f b6 c0             	movzbl %al,%eax
f01064c4:	50                   	push   %eax
f01064c5:	51                   	push   %ecx
f01064c6:	89 d0                	mov    %edx,%eax
f01064c8:	c1 e8 10             	shr    $0x10,%eax
f01064cb:	50                   	push   %eax
f01064cc:	0f b7 d2             	movzwl %dx,%edx
f01064cf:	52                   	push   %edx
f01064d0:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f01064d6:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f01064dc:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f01064e2:	ff 70 04             	pushl  0x4(%eax)
f01064e5:	68 4c 87 10 f0       	push   $0xf010874c
f01064ea:	e8 fd d1 ff ff       	call   f01036ec <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f01064ef:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f01064f5:	83 c4 30             	add    $0x30,%esp
f01064f8:	53                   	push   %ebx
f01064f9:	68 0c 34 12 f0       	push   $0xf012340c
f01064fe:	89 c2                	mov    %eax,%edx
f0106500:	c1 ea 10             	shr    $0x10,%edx
f0106503:	0f b6 d2             	movzbl %dl,%edx
f0106506:	52                   	push   %edx
f0106507:	c1 e8 18             	shr    $0x18,%eax
f010650a:	50                   	push   %eax
f010650b:	e8 6a fd ff ff       	call   f010627a <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f0106510:	83 c4 10             	add    $0x10,%esp
f0106513:	85 c0                	test   %eax,%eax
f0106515:	75 1e                	jne    f0106535 <pci_scan_bus+0x182>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f0106517:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f010651d:	53                   	push   %ebx
f010651e:	68 f4 33 12 f0       	push   $0xf01233f4
f0106523:	89 c2                	mov    %eax,%edx
f0106525:	c1 ea 10             	shr    $0x10,%edx
f0106528:	52                   	push   %edx
f0106529:	0f b7 c0             	movzwl %ax,%eax
f010652c:	50                   	push   %eax
f010652d:	e8 48 fd ff ff       	call   f010627a <pci_attach_match>
f0106532:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0106535:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010653c:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f0106542:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f0106548:	0f 87 f7 fe ff ff    	ja     f0106445 <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f010654e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0106551:	83 c0 01             	add    $0x1,%eax
f0106554:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0106557:	83 f8 1f             	cmp    $0x1f,%eax
f010655a:	0f 86 85 fe ff ff    	jbe    f01063e5 <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0106560:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f0106566:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106569:	5b                   	pop    %ebx
f010656a:	5e                   	pop    %esi
f010656b:	5f                   	pop    %edi
f010656c:	5d                   	pop    %ebp
f010656d:	c3                   	ret    

f010656e <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f010656e:	55                   	push   %ebp
f010656f:	89 e5                	mov    %esp,%ebp
f0106571:	57                   	push   %edi
f0106572:	56                   	push   %esi
f0106573:	53                   	push   %ebx
f0106574:	83 ec 1c             	sub    $0x1c,%esp
f0106577:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f010657a:	ba 1c 00 00 00       	mov    $0x1c,%edx
f010657f:	89 d8                	mov    %ebx,%eax
f0106581:	e8 08 fe ff ff       	call   f010638e <pci_conf_read>
f0106586:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f0106588:	ba 18 00 00 00       	mov    $0x18,%edx
f010658d:	89 d8                	mov    %ebx,%eax
f010658f:	e8 fa fd ff ff       	call   f010638e <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0106594:	83 e7 0f             	and    $0xf,%edi
f0106597:	83 ff 01             	cmp    $0x1,%edi
f010659a:	75 1f                	jne    f01065bb <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f010659c:	ff 73 08             	pushl  0x8(%ebx)
f010659f:	ff 73 04             	pushl  0x4(%ebx)
f01065a2:	8b 03                	mov    (%ebx),%eax
f01065a4:	ff 70 04             	pushl  0x4(%eax)
f01065a7:	68 88 87 10 f0       	push   $0xf0108788
f01065ac:	e8 3b d1 ff ff       	call   f01036ec <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f01065b1:	83 c4 10             	add    $0x10,%esp
f01065b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01065b9:	eb 4e                	jmp    f0106609 <pci_bridge_attach+0x9b>
f01065bb:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f01065bd:	83 ec 04             	sub    $0x4,%esp
f01065c0:	6a 08                	push   $0x8
f01065c2:	6a 00                	push   $0x0
f01065c4:	8d 7d e0             	lea    -0x20(%ebp),%edi
f01065c7:	57                   	push   %edi
f01065c8:	e8 0d f1 ff ff       	call   f01056da <memset>
	nbus.parent_bridge = pcif;
f01065cd:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f01065d0:	89 f0                	mov    %esi,%eax
f01065d2:	0f b6 c4             	movzbl %ah,%eax
f01065d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f01065d8:	83 c4 08             	add    $0x8,%esp
f01065db:	89 f2                	mov    %esi,%edx
f01065dd:	c1 ea 10             	shr    $0x10,%edx
f01065e0:	0f b6 f2             	movzbl %dl,%esi
f01065e3:	56                   	push   %esi
f01065e4:	50                   	push   %eax
f01065e5:	ff 73 08             	pushl  0x8(%ebx)
f01065e8:	ff 73 04             	pushl  0x4(%ebx)
f01065eb:	8b 03                	mov    (%ebx),%eax
f01065ed:	ff 70 04             	pushl  0x4(%eax)
f01065f0:	68 bc 87 10 f0       	push   $0xf01087bc
f01065f5:	e8 f2 d0 ff ff       	call   f01036ec <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f01065fa:	83 c4 20             	add    $0x20,%esp
f01065fd:	89 f8                	mov    %edi,%eax
f01065ff:	e8 af fd ff ff       	call   f01063b3 <pci_scan_bus>
	return 1;
f0106604:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0106609:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010660c:	5b                   	pop    %ebx
f010660d:	5e                   	pop    %esi
f010660e:	5f                   	pop    %edi
f010660f:	5d                   	pop    %ebp
f0106610:	c3                   	ret    

f0106611 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f0106611:	55                   	push   %ebp
f0106612:	89 e5                	mov    %esp,%ebp
f0106614:	56                   	push   %esi
f0106615:	53                   	push   %ebx
f0106616:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106618:	8b 48 08             	mov    0x8(%eax),%ecx
f010661b:	8b 70 04             	mov    0x4(%eax),%esi
f010661e:	8b 00                	mov    (%eax),%eax
f0106620:	8b 40 04             	mov    0x4(%eax),%eax
f0106623:	83 ec 0c             	sub    $0xc,%esp
f0106626:	52                   	push   %edx
f0106627:	89 f2                	mov    %esi,%edx
f0106629:	e8 aa fc ff ff       	call   f01062d8 <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f010662e:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106633:	89 d8                	mov    %ebx,%eax
f0106635:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f0106636:	83 c4 10             	add    $0x10,%esp
f0106639:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010663c:	5b                   	pop    %ebx
f010663d:	5e                   	pop    %esi
f010663e:	5d                   	pop    %ebp
f010663f:	c3                   	ret    

f0106640 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0106640:	55                   	push   %ebp
f0106641:	89 e5                	mov    %esp,%ebp
f0106643:	57                   	push   %edi
f0106644:	56                   	push   %esi
f0106645:	53                   	push   %ebx
f0106646:	83 ec 1c             	sub    $0x1c,%esp
f0106649:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f010664c:	b9 07 00 00 00       	mov    $0x7,%ecx
f0106651:	ba 04 00 00 00       	mov    $0x4,%edx
f0106656:	89 f8                	mov    %edi,%eax
f0106658:	e8 b4 ff ff ff       	call   f0106611 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f010665d:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0106662:	89 f2                	mov    %esi,%edx
f0106664:	89 f8                	mov    %edi,%eax
f0106666:	e8 23 fd ff ff       	call   f010638e <pci_conf_read>
f010666b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f010666e:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0106673:	89 f2                	mov    %esi,%edx
f0106675:	89 f8                	mov    %edi,%eax
f0106677:	e8 95 ff ff ff       	call   f0106611 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f010667c:	89 f2                	mov    %esi,%edx
f010667e:	89 f8                	mov    %edi,%eax
f0106680:	e8 09 fd ff ff       	call   f010638e <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106685:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f010668a:	85 c0                	test   %eax,%eax
f010668c:	0f 84 a6 00 00 00    	je     f0106738 <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0106692:	8d 56 f0             	lea    -0x10(%esi),%edx
f0106695:	c1 ea 02             	shr    $0x2,%edx
f0106698:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f010669b:	a8 01                	test   $0x1,%al
f010669d:	75 2c                	jne    f01066cb <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f010669f:	89 c2                	mov    %eax,%edx
f01066a1:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f01066a4:	83 fa 04             	cmp    $0x4,%edx
f01066a7:	0f 94 c3             	sete   %bl
f01066aa:	0f b6 db             	movzbl %bl,%ebx
f01066ad:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f01066b4:	83 e0 f0             	and    $0xfffffff0,%eax
f01066b7:	89 c2                	mov    %eax,%edx
f01066b9:	f7 da                	neg    %edx
f01066bb:	21 c2                	and    %eax,%edx
f01066bd:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f01066c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01066c3:	83 e0 f0             	and    $0xfffffff0,%eax
f01066c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01066c9:	eb 1a                	jmp    f01066e5 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f01066cb:	83 e0 fc             	and    $0xfffffffc,%eax
f01066ce:	89 c2                	mov    %eax,%edx
f01066d0:	f7 da                	neg    %edx
f01066d2:	21 c2                	and    %eax,%edx
f01066d4:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f01066d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01066da:	83 e0 fc             	and    $0xfffffffc,%eax
f01066dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f01066e0:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f01066e5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01066e8:	89 f2                	mov    %esi,%edx
f01066ea:	89 f8                	mov    %edi,%eax
f01066ec:	e8 20 ff ff ff       	call   f0106611 <pci_conf_write>
f01066f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01066f4:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f01066f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01066fa:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f01066fd:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0106700:	89 48 2c             	mov    %ecx,0x2c(%eax)

		if (size && !base)
f0106703:	85 c9                	test   %ecx,%ecx
f0106705:	74 31                	je     f0106738 <pci_func_enable+0xf8>
f0106707:	85 d2                	test   %edx,%edx
f0106709:	75 2d                	jne    f0106738 <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f010670b:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f010670e:	83 ec 0c             	sub    $0xc,%esp
f0106711:	51                   	push   %ecx
f0106712:	52                   	push   %edx
f0106713:	ff 75 e0             	pushl  -0x20(%ebp)
f0106716:	89 c2                	mov    %eax,%edx
f0106718:	c1 ea 10             	shr    $0x10,%edx
f010671b:	52                   	push   %edx
f010671c:	0f b7 c0             	movzwl %ax,%eax
f010671f:	50                   	push   %eax
f0106720:	ff 77 08             	pushl  0x8(%edi)
f0106723:	ff 77 04             	pushl  0x4(%edi)
f0106726:	8b 07                	mov    (%edi),%eax
f0106728:	ff 70 04             	pushl  0x4(%eax)
f010672b:	68 ec 87 10 f0       	push   $0xf01087ec
f0106730:	e8 b7 cf ff ff       	call   f01036ec <cprintf>
f0106735:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0106738:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f010673a:	83 fe 27             	cmp    $0x27,%esi
f010673d:	0f 86 1f ff ff ff    	jbe    f0106662 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f0106743:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0106746:	83 ec 08             	sub    $0x8,%esp
f0106749:	89 c2                	mov    %eax,%edx
f010674b:	c1 ea 10             	shr    $0x10,%edx
f010674e:	52                   	push   %edx
f010674f:	0f b7 c0             	movzwl %ax,%eax
f0106752:	50                   	push   %eax
f0106753:	ff 77 08             	pushl  0x8(%edi)
f0106756:	ff 77 04             	pushl  0x4(%edi)
f0106759:	8b 07                	mov    (%edi),%eax
f010675b:	ff 70 04             	pushl  0x4(%eax)
f010675e:	68 48 88 10 f0       	push   $0xf0108848
f0106763:	e8 84 cf ff ff       	call   f01036ec <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0106768:	83 c4 20             	add    $0x20,%esp
f010676b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010676e:	5b                   	pop    %ebx
f010676f:	5e                   	pop    %esi
f0106770:	5f                   	pop    %edi
f0106771:	5d                   	pop    %ebp
f0106772:	c3                   	ret    

f0106773 <pci_init>:

int
pci_init(void)
{
f0106773:	55                   	push   %ebp
f0106774:	89 e5                	mov    %esp,%ebp
f0106776:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106779:	6a 08                	push   $0x8
f010677b:	6a 00                	push   $0x0
f010677d:	68 80 1e 2a f0       	push   $0xf02a1e80
f0106782:	e8 53 ef ff ff       	call   f01056da <memset>

	return pci_scan_bus(&root_bus);
f0106787:	b8 80 1e 2a f0       	mov    $0xf02a1e80,%eax
f010678c:	e8 22 fc ff ff       	call   f01063b3 <pci_scan_bus>
}
f0106791:	c9                   	leave  
f0106792:	c3                   	ret    

f0106793 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f0106793:	55                   	push   %ebp
f0106794:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f0106796:	c7 05 88 1e 2a f0 00 	movl   $0x0,0xf02a1e88
f010679d:	00 00 00 
}
f01067a0:	5d                   	pop    %ebp
f01067a1:	c3                   	ret    

f01067a2 <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f01067a2:	a1 88 1e 2a f0       	mov    0xf02a1e88,%eax
f01067a7:	83 c0 01             	add    $0x1,%eax
f01067aa:	a3 88 1e 2a f0       	mov    %eax,0xf02a1e88
	if (ticks * 10 < ticks)
f01067af:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01067b2:	01 d2                	add    %edx,%edx
f01067b4:	39 d0                	cmp    %edx,%eax
f01067b6:	76 17                	jbe    f01067cf <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f01067b8:	55                   	push   %ebp
f01067b9:	89 e5                	mov    %esp,%ebp
f01067bb:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f01067be:	68 50 89 10 f0       	push   $0xf0108950
f01067c3:	6a 13                	push   $0x13
f01067c5:	68 6b 89 10 f0       	push   $0xf010896b
f01067ca:	e8 71 98 ff ff       	call   f0100040 <_panic>
f01067cf:	f3 c3                	repz ret 

f01067d1 <time_msec>:
}

unsigned int
time_msec(void)
{
f01067d1:	55                   	push   %ebp
f01067d2:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f01067d4:	a1 88 1e 2a f0       	mov    0xf02a1e88,%eax
f01067d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01067dc:	01 c0                	add    %eax,%eax
}
f01067de:	5d                   	pop    %ebp
f01067df:	c3                   	ret    

f01067e0 <__udivdi3>:
f01067e0:	55                   	push   %ebp
f01067e1:	57                   	push   %edi
f01067e2:	56                   	push   %esi
f01067e3:	53                   	push   %ebx
f01067e4:	83 ec 1c             	sub    $0x1c,%esp
f01067e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01067eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01067ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01067f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01067f7:	85 f6                	test   %esi,%esi
f01067f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01067fd:	89 ca                	mov    %ecx,%edx
f01067ff:	89 f8                	mov    %edi,%eax
f0106801:	75 3d                	jne    f0106840 <__udivdi3+0x60>
f0106803:	39 cf                	cmp    %ecx,%edi
f0106805:	0f 87 c5 00 00 00    	ja     f01068d0 <__udivdi3+0xf0>
f010680b:	85 ff                	test   %edi,%edi
f010680d:	89 fd                	mov    %edi,%ebp
f010680f:	75 0b                	jne    f010681c <__udivdi3+0x3c>
f0106811:	b8 01 00 00 00       	mov    $0x1,%eax
f0106816:	31 d2                	xor    %edx,%edx
f0106818:	f7 f7                	div    %edi
f010681a:	89 c5                	mov    %eax,%ebp
f010681c:	89 c8                	mov    %ecx,%eax
f010681e:	31 d2                	xor    %edx,%edx
f0106820:	f7 f5                	div    %ebp
f0106822:	89 c1                	mov    %eax,%ecx
f0106824:	89 d8                	mov    %ebx,%eax
f0106826:	89 cf                	mov    %ecx,%edi
f0106828:	f7 f5                	div    %ebp
f010682a:	89 c3                	mov    %eax,%ebx
f010682c:	89 d8                	mov    %ebx,%eax
f010682e:	89 fa                	mov    %edi,%edx
f0106830:	83 c4 1c             	add    $0x1c,%esp
f0106833:	5b                   	pop    %ebx
f0106834:	5e                   	pop    %esi
f0106835:	5f                   	pop    %edi
f0106836:	5d                   	pop    %ebp
f0106837:	c3                   	ret    
f0106838:	90                   	nop
f0106839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106840:	39 ce                	cmp    %ecx,%esi
f0106842:	77 74                	ja     f01068b8 <__udivdi3+0xd8>
f0106844:	0f bd fe             	bsr    %esi,%edi
f0106847:	83 f7 1f             	xor    $0x1f,%edi
f010684a:	0f 84 98 00 00 00    	je     f01068e8 <__udivdi3+0x108>
f0106850:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106855:	89 f9                	mov    %edi,%ecx
f0106857:	89 c5                	mov    %eax,%ebp
f0106859:	29 fb                	sub    %edi,%ebx
f010685b:	d3 e6                	shl    %cl,%esi
f010685d:	89 d9                	mov    %ebx,%ecx
f010685f:	d3 ed                	shr    %cl,%ebp
f0106861:	89 f9                	mov    %edi,%ecx
f0106863:	d3 e0                	shl    %cl,%eax
f0106865:	09 ee                	or     %ebp,%esi
f0106867:	89 d9                	mov    %ebx,%ecx
f0106869:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010686d:	89 d5                	mov    %edx,%ebp
f010686f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106873:	d3 ed                	shr    %cl,%ebp
f0106875:	89 f9                	mov    %edi,%ecx
f0106877:	d3 e2                	shl    %cl,%edx
f0106879:	89 d9                	mov    %ebx,%ecx
f010687b:	d3 e8                	shr    %cl,%eax
f010687d:	09 c2                	or     %eax,%edx
f010687f:	89 d0                	mov    %edx,%eax
f0106881:	89 ea                	mov    %ebp,%edx
f0106883:	f7 f6                	div    %esi
f0106885:	89 d5                	mov    %edx,%ebp
f0106887:	89 c3                	mov    %eax,%ebx
f0106889:	f7 64 24 0c          	mull   0xc(%esp)
f010688d:	39 d5                	cmp    %edx,%ebp
f010688f:	72 10                	jb     f01068a1 <__udivdi3+0xc1>
f0106891:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106895:	89 f9                	mov    %edi,%ecx
f0106897:	d3 e6                	shl    %cl,%esi
f0106899:	39 c6                	cmp    %eax,%esi
f010689b:	73 07                	jae    f01068a4 <__udivdi3+0xc4>
f010689d:	39 d5                	cmp    %edx,%ebp
f010689f:	75 03                	jne    f01068a4 <__udivdi3+0xc4>
f01068a1:	83 eb 01             	sub    $0x1,%ebx
f01068a4:	31 ff                	xor    %edi,%edi
f01068a6:	89 d8                	mov    %ebx,%eax
f01068a8:	89 fa                	mov    %edi,%edx
f01068aa:	83 c4 1c             	add    $0x1c,%esp
f01068ad:	5b                   	pop    %ebx
f01068ae:	5e                   	pop    %esi
f01068af:	5f                   	pop    %edi
f01068b0:	5d                   	pop    %ebp
f01068b1:	c3                   	ret    
f01068b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01068b8:	31 ff                	xor    %edi,%edi
f01068ba:	31 db                	xor    %ebx,%ebx
f01068bc:	89 d8                	mov    %ebx,%eax
f01068be:	89 fa                	mov    %edi,%edx
f01068c0:	83 c4 1c             	add    $0x1c,%esp
f01068c3:	5b                   	pop    %ebx
f01068c4:	5e                   	pop    %esi
f01068c5:	5f                   	pop    %edi
f01068c6:	5d                   	pop    %ebp
f01068c7:	c3                   	ret    
f01068c8:	90                   	nop
f01068c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01068d0:	89 d8                	mov    %ebx,%eax
f01068d2:	f7 f7                	div    %edi
f01068d4:	31 ff                	xor    %edi,%edi
f01068d6:	89 c3                	mov    %eax,%ebx
f01068d8:	89 d8                	mov    %ebx,%eax
f01068da:	89 fa                	mov    %edi,%edx
f01068dc:	83 c4 1c             	add    $0x1c,%esp
f01068df:	5b                   	pop    %ebx
f01068e0:	5e                   	pop    %esi
f01068e1:	5f                   	pop    %edi
f01068e2:	5d                   	pop    %ebp
f01068e3:	c3                   	ret    
f01068e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01068e8:	39 ce                	cmp    %ecx,%esi
f01068ea:	72 0c                	jb     f01068f8 <__udivdi3+0x118>
f01068ec:	31 db                	xor    %ebx,%ebx
f01068ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01068f2:	0f 87 34 ff ff ff    	ja     f010682c <__udivdi3+0x4c>
f01068f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01068fd:	e9 2a ff ff ff       	jmp    f010682c <__udivdi3+0x4c>
f0106902:	66 90                	xchg   %ax,%ax
f0106904:	66 90                	xchg   %ax,%ax
f0106906:	66 90                	xchg   %ax,%ax
f0106908:	66 90                	xchg   %ax,%ax
f010690a:	66 90                	xchg   %ax,%ax
f010690c:	66 90                	xchg   %ax,%ax
f010690e:	66 90                	xchg   %ax,%ax

f0106910 <__umoddi3>:
f0106910:	55                   	push   %ebp
f0106911:	57                   	push   %edi
f0106912:	56                   	push   %esi
f0106913:	53                   	push   %ebx
f0106914:	83 ec 1c             	sub    $0x1c,%esp
f0106917:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010691b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010691f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106923:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106927:	85 d2                	test   %edx,%edx
f0106929:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010692d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106931:	89 f3                	mov    %esi,%ebx
f0106933:	89 3c 24             	mov    %edi,(%esp)
f0106936:	89 74 24 04          	mov    %esi,0x4(%esp)
f010693a:	75 1c                	jne    f0106958 <__umoddi3+0x48>
f010693c:	39 f7                	cmp    %esi,%edi
f010693e:	76 50                	jbe    f0106990 <__umoddi3+0x80>
f0106940:	89 c8                	mov    %ecx,%eax
f0106942:	89 f2                	mov    %esi,%edx
f0106944:	f7 f7                	div    %edi
f0106946:	89 d0                	mov    %edx,%eax
f0106948:	31 d2                	xor    %edx,%edx
f010694a:	83 c4 1c             	add    $0x1c,%esp
f010694d:	5b                   	pop    %ebx
f010694e:	5e                   	pop    %esi
f010694f:	5f                   	pop    %edi
f0106950:	5d                   	pop    %ebp
f0106951:	c3                   	ret    
f0106952:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106958:	39 f2                	cmp    %esi,%edx
f010695a:	89 d0                	mov    %edx,%eax
f010695c:	77 52                	ja     f01069b0 <__umoddi3+0xa0>
f010695e:	0f bd ea             	bsr    %edx,%ebp
f0106961:	83 f5 1f             	xor    $0x1f,%ebp
f0106964:	75 5a                	jne    f01069c0 <__umoddi3+0xb0>
f0106966:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010696a:	0f 82 e0 00 00 00    	jb     f0106a50 <__umoddi3+0x140>
f0106970:	39 0c 24             	cmp    %ecx,(%esp)
f0106973:	0f 86 d7 00 00 00    	jbe    f0106a50 <__umoddi3+0x140>
f0106979:	8b 44 24 08          	mov    0x8(%esp),%eax
f010697d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106981:	83 c4 1c             	add    $0x1c,%esp
f0106984:	5b                   	pop    %ebx
f0106985:	5e                   	pop    %esi
f0106986:	5f                   	pop    %edi
f0106987:	5d                   	pop    %ebp
f0106988:	c3                   	ret    
f0106989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106990:	85 ff                	test   %edi,%edi
f0106992:	89 fd                	mov    %edi,%ebp
f0106994:	75 0b                	jne    f01069a1 <__umoddi3+0x91>
f0106996:	b8 01 00 00 00       	mov    $0x1,%eax
f010699b:	31 d2                	xor    %edx,%edx
f010699d:	f7 f7                	div    %edi
f010699f:	89 c5                	mov    %eax,%ebp
f01069a1:	89 f0                	mov    %esi,%eax
f01069a3:	31 d2                	xor    %edx,%edx
f01069a5:	f7 f5                	div    %ebp
f01069a7:	89 c8                	mov    %ecx,%eax
f01069a9:	f7 f5                	div    %ebp
f01069ab:	89 d0                	mov    %edx,%eax
f01069ad:	eb 99                	jmp    f0106948 <__umoddi3+0x38>
f01069af:	90                   	nop
f01069b0:	89 c8                	mov    %ecx,%eax
f01069b2:	89 f2                	mov    %esi,%edx
f01069b4:	83 c4 1c             	add    $0x1c,%esp
f01069b7:	5b                   	pop    %ebx
f01069b8:	5e                   	pop    %esi
f01069b9:	5f                   	pop    %edi
f01069ba:	5d                   	pop    %ebp
f01069bb:	c3                   	ret    
f01069bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01069c0:	8b 34 24             	mov    (%esp),%esi
f01069c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01069c8:	89 e9                	mov    %ebp,%ecx
f01069ca:	29 ef                	sub    %ebp,%edi
f01069cc:	d3 e0                	shl    %cl,%eax
f01069ce:	89 f9                	mov    %edi,%ecx
f01069d0:	89 f2                	mov    %esi,%edx
f01069d2:	d3 ea                	shr    %cl,%edx
f01069d4:	89 e9                	mov    %ebp,%ecx
f01069d6:	09 c2                	or     %eax,%edx
f01069d8:	89 d8                	mov    %ebx,%eax
f01069da:	89 14 24             	mov    %edx,(%esp)
f01069dd:	89 f2                	mov    %esi,%edx
f01069df:	d3 e2                	shl    %cl,%edx
f01069e1:	89 f9                	mov    %edi,%ecx
f01069e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01069e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01069eb:	d3 e8                	shr    %cl,%eax
f01069ed:	89 e9                	mov    %ebp,%ecx
f01069ef:	89 c6                	mov    %eax,%esi
f01069f1:	d3 e3                	shl    %cl,%ebx
f01069f3:	89 f9                	mov    %edi,%ecx
f01069f5:	89 d0                	mov    %edx,%eax
f01069f7:	d3 e8                	shr    %cl,%eax
f01069f9:	89 e9                	mov    %ebp,%ecx
f01069fb:	09 d8                	or     %ebx,%eax
f01069fd:	89 d3                	mov    %edx,%ebx
f01069ff:	89 f2                	mov    %esi,%edx
f0106a01:	f7 34 24             	divl   (%esp)
f0106a04:	89 d6                	mov    %edx,%esi
f0106a06:	d3 e3                	shl    %cl,%ebx
f0106a08:	f7 64 24 04          	mull   0x4(%esp)
f0106a0c:	39 d6                	cmp    %edx,%esi
f0106a0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106a12:	89 d1                	mov    %edx,%ecx
f0106a14:	89 c3                	mov    %eax,%ebx
f0106a16:	72 08                	jb     f0106a20 <__umoddi3+0x110>
f0106a18:	75 11                	jne    f0106a2b <__umoddi3+0x11b>
f0106a1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106a1e:	73 0b                	jae    f0106a2b <__umoddi3+0x11b>
f0106a20:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106a24:	1b 14 24             	sbb    (%esp),%edx
f0106a27:	89 d1                	mov    %edx,%ecx
f0106a29:	89 c3                	mov    %eax,%ebx
f0106a2b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106a2f:	29 da                	sub    %ebx,%edx
f0106a31:	19 ce                	sbb    %ecx,%esi
f0106a33:	89 f9                	mov    %edi,%ecx
f0106a35:	89 f0                	mov    %esi,%eax
f0106a37:	d3 e0                	shl    %cl,%eax
f0106a39:	89 e9                	mov    %ebp,%ecx
f0106a3b:	d3 ea                	shr    %cl,%edx
f0106a3d:	89 e9                	mov    %ebp,%ecx
f0106a3f:	d3 ee                	shr    %cl,%esi
f0106a41:	09 d0                	or     %edx,%eax
f0106a43:	89 f2                	mov    %esi,%edx
f0106a45:	83 c4 1c             	add    $0x1c,%esp
f0106a48:	5b                   	pop    %ebx
f0106a49:	5e                   	pop    %esi
f0106a4a:	5f                   	pop    %edi
f0106a4b:	5d                   	pop    %ebp
f0106a4c:	c3                   	ret    
f0106a4d:	8d 76 00             	lea    0x0(%esi),%esi
f0106a50:	29 f9                	sub    %edi,%ecx
f0106a52:	19 d6                	sbb    %edx,%esi
f0106a54:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106a58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a5c:	e9 18 ff ff ff       	jmp    f0106979 <__umoddi3+0x69>
