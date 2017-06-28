
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 f7 19 00 00       	call   801a28 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 e0 3c 80 00       	push   $0x803ce0
  8000b7:	e8 af 1a 00 00       	call   801b6b <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 f7 3c 80 00       	push   $0x803cf7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 07 3d 80 00       	push   $0x803d07
  8000e0:	e8 ad 19 00 00       	call   801a92 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 10 3d 80 00       	push   $0x803d10
  80010b:	68 1d 3d 80 00       	push   $0x803d1d
  800110:	6a 44                	push   $0x44
  800112:	68 07 3d 80 00       	push   $0x803d07
  800117:	e8 76 19 00 00       	call   801a92 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 10 3d 80 00       	push   $0x803d10
  8001cf:	68 1d 3d 80 00       	push   $0x803d1d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 07 3d 80 00       	push   $0x803d07
  8001db:	e8 b2 18 00 00       	call   801a92 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 34 3d 80 00       	push   $0x803d34
  80029f:	6a 27                	push   $0x27
  8002a1:	68 88 3e 80 00       	push   $0x803e88
  8002a6:	e8 e7 17 00 00       	call   801a92 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 64 3d 80 00       	push   $0x803d64
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 88 3e 80 00       	push   $0x803e88
  8002c6:	e8 c7 17 00 00       	call   801a92 <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc (0, addr, (PTE_U | PTE_P | PTE_W ));
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 15 22 00 00       	call   8024f3 <sys_page_alloc>
 	if (r < 0)
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
   		panic("In bc_pgfault sys_page_alloc failed- %e\n", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 88 3d 80 00       	push   $0x803d88
  8002eb:	6a 37                	push   $0x37
  8002ed:	68 88 3e 80 00       	push   $0x803e88
  8002f2:	e8 9b 17 00 00       	call   801a92 <_panic>
   	r = ide_read(blockno * BLKSECTS, addr, BLKSECTS);	
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	6a 08                	push   $0x8
  8002fc:	53                   	push   %ebx
  8002fd:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800304:	50                   	push   %eax
  800305:	e8 e2 fd ff ff       	call   8000ec <ide_read>
 	if (r < 0)
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 12                	jns    800323 <bc_pgfault+0xaf>
   		panic("In bc_pgfault ide_read failed- %e \n", r);
  800311:	50                   	push   %eax
  800312:	68 b4 3d 80 00       	push   $0x803db4
  800317:	6a 3a                	push   $0x3a
  800319:	68 88 3e 80 00       	push   $0x803e88
  80031e:	e8 6f 17 00 00       	call   801a92 <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800323:	89 d8                	mov    %ebx,%eax
  800325:	c1 e8 0c             	shr    $0xc,%eax
  800328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	25 07 0e 00 00       	and    $0xe07,%eax
  800337:	50                   	push   %eax
  800338:	53                   	push   %ebx
  800339:	6a 00                	push   $0x0
  80033b:	53                   	push   %ebx
  80033c:	6a 00                	push   $0x0
  80033e:	e8 f3 21 00 00       	call   802536 <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 d8 3d 80 00       	push   $0x803dd8
  800350:	6a 3f                	push   $0x3f
  800352:	68 88 3e 80 00       	push   $0x803e88
  800357:	e8 36 17 00 00       	call   801a92 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80035c:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800363:	74 22                	je     800387 <bc_pgfault+0x113>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	56                   	push   %esi
  800369:	e8 5a 03 00 00       	call   8006c8 <block_is_free>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	84 c0                	test   %al,%al
  800373:	74 12                	je     800387 <bc_pgfault+0x113>
		panic("reading free block %08x\n", blockno);
  800375:	56                   	push   %esi
  800376:	68 90 3e 80 00       	push   $0x803e90
  80037b:	6a 45                	push   $0x45
  80037d:	68 88 3e 80 00       	push   $0x803e88
  800382:	e8 0b 17 00 00       	call   801a92 <_panic>
}
  800387:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800397:	85 c0                	test   %eax,%eax
  800399:	74 0f                	je     8003aa <diskaddr+0x1c>
  80039b:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 17                	je     8003bc <diskaddr+0x2e>
  8003a5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003a8:	72 12                	jb     8003bc <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003aa:	50                   	push   %eax
  8003ab:	68 f8 3d 80 00       	push   $0x803df8
  8003b0:	6a 09                	push   $0x9
  8003b2:	68 88 3e 80 00       	push   $0x803e88
  8003b7:	e8 d6 16 00 00       	call   801a92 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003bc:	05 00 00 01 00       	add    $0x10000,%eax
  8003c1:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003cc:	89 d0                	mov    %edx,%eax
  8003ce:	c1 e8 16             	shr    $0x16,%eax
  8003d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	f6 c1 01             	test   $0x1,%cl
  8003e0:	74 0d                	je     8003ef <va_is_mapped+0x29>
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003ec:	83 e0 01             	and    $0x1,%eax
  8003ef:	83 e0 01             	and    $0x1,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c1 e8 0c             	shr    $0xc,%eax
  8003fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800404:	c1 e8 06             	shr    $0x6,%eax
  800407:	83 e0 01             	and    $0x1,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
  800411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r ;
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800414:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041a:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80041f:	76 12                	jbe    800433 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800421:	53                   	push   %ebx
  800422:	68 a9 3e 80 00       	push   $0x803ea9
  800427:	6a 55                	push   $0x55
  800429:	68 88 3e 80 00       	push   $0x803e88
  80042e:	e8 5f 16 00 00       	call   801a92 <_panic>

	// LAB 5: Your code here.
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
  800433:	83 ec 0c             	sub    $0xc,%esp
  800436:	53                   	push   %ebx
  800437:	e8 8a ff ff ff       	call   8003c6 <va_is_mapped>
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	84 c0                	test   %al,%al
  800441:	0f 84 82 00 00 00    	je     8004c9 <flush_block+0xbd>
  800447:	83 ec 0c             	sub    $0xc,%esp
  80044a:	53                   	push   %ebx
  80044b:	e8 a4 ff ff ff       	call   8003f4 <va_is_dirty>
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	84 c0                	test   %al,%al
  800455:	74 72                	je     8004c9 <flush_block+0xbd>
		addr = ROUNDDOWN(addr, PGSIZE);
  800457:	89 de                	mov    %ebx,%esi
  800459:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		r = ide_write(blockno * BLKSECTS, addr, BLKSECTS);
  80045f:	83 ec 04             	sub    $0x4,%esp
  800462:	6a 08                	push   $0x8
  800464:	56                   	push   %esi
  800465:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  80046b:	c1 eb 0c             	shr    $0xc,%ebx
  80046e:	c1 e3 03             	shl    $0x3,%ebx
  800471:	53                   	push   %ebx
  800472:	e8 39 fd ff ff       	call   8001b0 <ide_write>
   		if ( r < 0)
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	85 c0                	test   %eax,%eax
  80047c:	79 12                	jns    800490 <flush_block+0x84>
     		panic("In flush_block ide_write failed-%e\n", r);
  80047e:	50                   	push   %eax
  80047f:	68 1c 3e 80 00       	push   $0x803e1c
  800484:	6a 5c                	push   $0x5c
  800486:	68 88 3e 80 00       	push   $0x803e88
  80048b:	e8 02 16 00 00       	call   801a92 <_panic>
     	r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);	
  800490:	89 f0                	mov    %esi,%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80049c:	83 ec 0c             	sub    $0xc,%esp
  80049f:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a4:	50                   	push   %eax
  8004a5:	56                   	push   %esi
  8004a6:	6a 00                	push   $0x0
  8004a8:	56                   	push   %esi
  8004a9:	6a 00                	push   $0x0
  8004ab:	e8 86 20 00 00       	call   802536 <sys_page_map>
   		if (r < 0)
  8004b0:	83 c4 20             	add    $0x20,%esp
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	79 12                	jns    8004c9 <flush_block+0xbd>
     	panic("in flush_block, sys_page_map: %e", r);
  8004b7:	50                   	push   %eax
  8004b8:	68 40 3e 80 00       	push   $0x803e40
  8004bd:	6a 5f                	push   $0x5f
  8004bf:	68 88 3e 80 00       	push   $0x803e88
  8004c4:	e8 c9 15 00 00       	call   801a92 <_panic>
 	}
 	return;
 	//panic("flush_block not implemented");
}
  8004c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004cc:	5b                   	pop    %ebx
  8004cd:	5e                   	pop    %esi
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004d9:	68 74 02 80 00       	push   $0x800274
  8004de:	e8 41 22 00 00       	call   802724 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ea:	e8 9f fe ff ff       	call   80038e <diskaddr>
  8004ef:	83 c4 0c             	add    $0xc,%esp
  8004f2:	68 08 01 00 00       	push   $0x108
  8004f7:	50                   	push   %eax
  8004f8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004fe:	50                   	push   %eax
  8004ff:	e8 7e 1d 00 00       	call   802282 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800504:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80050b:	e8 7e fe ff ff       	call   80038e <diskaddr>
  800510:	83 c4 08             	add    $0x8,%esp
  800513:	68 c4 3e 80 00       	push   $0x803ec4
  800518:	50                   	push   %eax
  800519:	e8 d2 1b 00 00       	call   8020f0 <strcpy>
	flush_block(diskaddr(1));
  80051e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800525:	e8 64 fe ff ff       	call   80038e <diskaddr>
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	e8 da fe ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800532:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800539:	e8 50 fe ff ff       	call   80038e <diskaddr>
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	e8 80 fe ff ff       	call   8003c6 <va_is_mapped>
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	84 c0                	test   %al,%al
  80054b:	75 16                	jne    800563 <bc_init+0x93>
  80054d:	68 e6 3e 80 00       	push   $0x803ee6
  800552:	68 1d 3d 80 00       	push   $0x803d1d
  800557:	6a 72                	push   $0x72
  800559:	68 88 3e 80 00       	push   $0x803e88
  80055e:	e8 2f 15 00 00       	call   801a92 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800563:	83 ec 0c             	sub    $0xc,%esp
  800566:	6a 01                	push   $0x1
  800568:	e8 21 fe ff ff       	call   80038e <diskaddr>
  80056d:	89 04 24             	mov    %eax,(%esp)
  800570:	e8 7f fe ff ff       	call   8003f4 <va_is_dirty>
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	84 c0                	test   %al,%al
  80057a:	74 16                	je     800592 <bc_init+0xc2>
  80057c:	68 cb 3e 80 00       	push   $0x803ecb
  800581:	68 1d 3d 80 00       	push   $0x803d1d
  800586:	6a 73                	push   $0x73
  800588:	68 88 3e 80 00       	push   $0x803e88
  80058d:	e8 00 15 00 00       	call   801a92 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800592:	83 ec 0c             	sub    $0xc,%esp
  800595:	6a 01                	push   $0x1
  800597:	e8 f2 fd ff ff       	call   80038e <diskaddr>
  80059c:	83 c4 08             	add    $0x8,%esp
  80059f:	50                   	push   %eax
  8005a0:	6a 00                	push   $0x0
  8005a2:	e8 d1 1f 00 00       	call   802578 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ae:	e8 db fd ff ff       	call   80038e <diskaddr>
  8005b3:	89 04 24             	mov    %eax,(%esp)
  8005b6:	e8 0b fe ff ff       	call   8003c6 <va_is_mapped>
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	84 c0                	test   %al,%al
  8005c0:	74 16                	je     8005d8 <bc_init+0x108>
  8005c2:	68 e5 3e 80 00       	push   $0x803ee5
  8005c7:	68 1d 3d 80 00       	push   $0x803d1d
  8005cc:	6a 77                	push   $0x77
  8005ce:	68 88 3e 80 00       	push   $0x803e88
  8005d3:	e8 ba 14 00 00       	call   801a92 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	6a 01                	push   $0x1
  8005dd:	e8 ac fd ff ff       	call   80038e <diskaddr>
  8005e2:	83 c4 08             	add    $0x8,%esp
  8005e5:	68 c4 3e 80 00       	push   $0x803ec4
  8005ea:	50                   	push   %eax
  8005eb:	e8 aa 1b 00 00       	call   80219a <strcmp>
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	74 16                	je     80060d <bc_init+0x13d>
  8005f7:	68 64 3e 80 00       	push   $0x803e64
  8005fc:	68 1d 3d 80 00       	push   $0x803d1d
  800601:	6a 7a                	push   $0x7a
  800603:	68 88 3e 80 00       	push   $0x803e88
  800608:	e8 85 14 00 00       	call   801a92 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80060d:	83 ec 0c             	sub    $0xc,%esp
  800610:	6a 01                	push   $0x1
  800612:	e8 77 fd ff ff       	call   80038e <diskaddr>
  800617:	83 c4 0c             	add    $0xc,%esp
  80061a:	68 08 01 00 00       	push   $0x108
  80061f:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800625:	52                   	push   %edx
  800626:	50                   	push   %eax
  800627:	e8 56 1c 00 00       	call   802282 <memmove>
	flush_block(diskaddr(1));
  80062c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800633:	e8 56 fd ff ff       	call   80038e <diskaddr>
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	e8 cc fd ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  800640:	c7 04 24 00 3f 80 00 	movl   $0x803f00,(%esp)
  800647:	e8 1f 15 00 00       	call   801b6b <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80064c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800653:	e8 36 fd ff ff       	call   80038e <diskaddr>
  800658:	83 c4 0c             	add    $0xc,%esp
  80065b:	68 08 01 00 00       	push   $0x108
  800660:	50                   	push   %eax
  800661:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800667:	50                   	push   %eax
  800668:	e8 15 1c 00 00       	call   802282 <memmove>
}
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	c9                   	leave  
  800671:	c3                   	ret    

00800672 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800678:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80067d:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800683:	74 14                	je     800699 <check_super+0x27>
		panic("bad file system magic number");
  800685:	83 ec 04             	sub    $0x4,%esp
  800688:	68 15 3f 80 00       	push   $0x803f15
  80068d:	6a 0f                	push   $0xf
  80068f:	68 32 3f 80 00       	push   $0x803f32
  800694:	e8 f9 13 00 00       	call   801a92 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800699:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8006a0:	76 14                	jbe    8006b6 <check_super+0x44>
		panic("file system is too large");
  8006a2:	83 ec 04             	sub    $0x4,%esp
  8006a5:	68 3a 3f 80 00       	push   $0x803f3a
  8006aa:	6a 12                	push   $0x12
  8006ac:	68 32 3f 80 00       	push   $0x803f32
  8006b1:	e8 dc 13 00 00       	call   801a92 <_panic>

	cprintf("superblock is good\n");
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	68 53 3f 80 00       	push   $0x803f53
  8006be:	e8 a8 14 00 00       	call   801b6b <cprintf>
}
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	53                   	push   %ebx
  8006cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006cf:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8006d5:	85 d2                	test   %edx,%edx
  8006d7:	74 24                	je     8006fd <block_is_free+0x35>
		return 0;
  8006d9:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006de:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006e1:	76 1f                	jbe    800702 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006e3:	89 cb                	mov    %ecx,%ebx
  8006e5:	c1 eb 05             	shr    $0x5,%ebx
  8006e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8006ed:	d3 e0                	shl    %cl,%eax
  8006ef:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8006f5:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8006f8:	0f 95 c0             	setne  %al
  8006fb:	eb 05                	jmp    800702 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800702:	5b                   	pop    %ebx
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 04             	sub    $0x4,%esp
  80070c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80070f:	85 c9                	test   %ecx,%ecx
  800711:	75 14                	jne    800727 <free_block+0x22>
		panic("attempt to free zero block");
  800713:	83 ec 04             	sub    $0x4,%esp
  800716:	68 67 3f 80 00       	push   $0x803f67
  80071b:	6a 2d                	push   $0x2d
  80071d:	68 32 3f 80 00       	push   $0x803f32
  800722:	e8 6b 13 00 00       	call   801a92 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800727:	89 cb                	mov    %ecx,%ebx
  800729:	c1 eb 05             	shr    $0x5,%ebx
  80072c:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800732:	b8 01 00 00 00       	mov    $0x1,%eax
  800737:	d3 e0                	shl    %cl,%eax
  800739:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  80073c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	57                   	push   %edi
  800745:	56                   	push   %esi
  800746:	53                   	push   %ebx
  800747:	83 ec 0c             	sub    $0xc,%esp
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	uint32_t blockno;
	for (blockno = 0; blockno < super->s_nblocks; blockno++) {
  80074a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80074f:	8b 70 04             	mov    0x4(%eax),%esi
		if (bitmap[blockno / 32] & (1 << (blockno % 32))) {
  800752:	8b 3d 08 a0 80 00    	mov    0x80a008,%edi
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	uint32_t blockno;
	for (blockno = 0; blockno < super->s_nblocks; blockno++) {
  800758:	bb 00 00 00 00       	mov    $0x0,%ebx
  80075d:	89 d9                	mov    %ebx,%ecx
  80075f:	eb 39                	jmp    80079a <alloc_block+0x59>
		if (bitmap[blockno / 32] & (1 << (blockno % 32))) {
  800761:	89 c8                	mov    %ecx,%eax
  800763:	c1 e8 05             	shr    $0x5,%eax
  800766:	8d 14 87             	lea    (%edi,%eax,4),%edx
  800769:	8b 02                	mov    (%edx),%eax
  80076b:	bb 01 00 00 00       	mov    $0x1,%ebx
  800770:	d3 e3                	shl    %cl,%ebx
  800772:	85 c3                	test   %eax,%ebx
  800774:	74 21                	je     800797 <alloc_block+0x56>
  800776:	89 df                	mov    %ebx,%edi
  800778:	89 cb                	mov    %ecx,%ebx
  80077a:	89 f9                	mov    %edi,%ecx
			bitmap[blockno / 32] &= ~(1 << (blockno % 32));
  80077c:	f7 d1                	not    %ecx
  80077e:	21 c8                	and    %ecx,%eax
  800780:	89 02                	mov    %eax,(%edx)
			flush_block(bitmap);
  800782:	83 ec 0c             	sub    $0xc,%esp
  800785:	ff 35 08 a0 80 00    	pushl  0x80a008
  80078b:	e8 7c fc ff ff       	call   80040c <flush_block>
			return blockno;
  800790:	89 d8                	mov    %ebx,%eax
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 0c                	jmp    8007a3 <alloc_block+0x62>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	uint32_t blockno;
	for (blockno = 0; blockno < super->s_nblocks; blockno++) {
  800797:	83 c1 01             	add    $0x1,%ecx
  80079a:	39 f1                	cmp    %esi,%ecx
  80079c:	75 c3                	jne    800761 <alloc_block+0x20>
			bitmap[blockno / 32] &= ~(1 << (blockno % 32));
			flush_block(bitmap);
			return blockno;
		}
	}
	return -E_NO_DISK;
  80079e:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8007a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5f                   	pop    %edi
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	57                   	push   %edi
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	83 ec 1c             	sub    $0x1c,%esp
  8007b4:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 5: Your code here.
	uint32_t i;

	if (filebno >= NDIRECT + NINDIRECT)
  8007b7:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8007bd:	77 75                	ja     800834 <file_block_walk+0x89>
		return -E_INVAL;

	// direct block
	if (filebno < NDIRECT) {
  8007bf:	83 fa 09             	cmp    $0x9,%edx
  8007c2:	77 10                	ja     8007d4 <file_block_walk+0x29>
		*ppdiskbno = &(f->f_direct[filebno]);
  8007c4:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007cb:	89 01                	mov    %eax,(%ecx)
		return 0;
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d2:	eb 6c                	jmp    800840 <file_block_walk+0x95>
  8007d4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007d7:	89 d3                	mov    %edx,%ebx
  8007d9:	89 c6                	mov    %eax,%esi
	}

	// indirect block
	if (f->f_indirect == 0) {
  8007db:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  8007e2:	75 2f                	jne    800813 <file_block_walk+0x68>
		if (alloc == 0)
  8007e4:	89 f8                	mov    %edi,%eax
  8007e6:	84 c0                	test   %al,%al
  8007e8:	74 51                	je     80083b <file_block_walk+0x90>
			return -E_NOT_FOUND;
		if ((i = alloc_block()) < 0)
  8007ea:	e8 52 ff ff ff       	call   800741 <alloc_block>
  8007ef:	89 c7                	mov    %eax,%edi
			return i; // -E_NO_DISK

		memset(diskaddr(i), 0, BLKSIZE);
  8007f1:	83 ec 0c             	sub    $0xc,%esp
  8007f4:	50                   	push   %eax
  8007f5:	e8 94 fb ff ff       	call   80038e <diskaddr>
  8007fa:	83 c4 0c             	add    $0xc,%esp
  8007fd:	68 00 10 00 00       	push   $0x1000
  800802:	6a 00                	push   $0x0
  800804:	50                   	push   %eax
  800805:	e8 2b 1a 00 00       	call   802235 <memset>
		f->f_indirect = i;
  80080a:	89 be b0 00 00 00    	mov    %edi,0xb0(%esi)
  800810:	83 c4 10             	add    $0x10,%esp
	}
	*ppdiskbno = &((uint32_t *) diskaddr(f->f_indirect))[filebno - NDIRECT];
  800813:	83 ec 0c             	sub    $0xc,%esp
  800816:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  80081c:	e8 6d fb ff ff       	call   80038e <diskaddr>
  800821:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800825:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800828:	89 03                	mov    %eax,(%ebx)
	return 0;       
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
  800832:	eb 0c                	jmp    800840 <file_block_walk+0x95>
{
	// LAB 5: Your code here.
	uint32_t i;

	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800834:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800839:	eb 05                	jmp    800840 <file_block_walk+0x95>
	}

	// indirect block
	if (f->f_indirect == 0) {
		if (alloc == 0)
			return -E_NOT_FOUND;
  80083b:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
	}
	*ppdiskbno = &((uint32_t *) diskaddr(f->f_indirect))[filebno - NDIRECT];
	return 0;       
       
	//panic("file_block_walk not implemented");
}
  800840:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5f                   	pop    %edi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80084d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800852:	8b 70 04             	mov    0x4(%eax),%esi
  800855:	bb 00 00 00 00       	mov    $0x0,%ebx
  80085a:	eb 29                	jmp    800885 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  80085c:	8d 43 02             	lea    0x2(%ebx),%eax
  80085f:	50                   	push   %eax
  800860:	e8 63 fe ff ff       	call   8006c8 <block_is_free>
  800865:	83 c4 04             	add    $0x4,%esp
  800868:	84 c0                	test   %al,%al
  80086a:	74 16                	je     800882 <check_bitmap+0x3a>
  80086c:	68 82 3f 80 00       	push   $0x803f82
  800871:	68 1d 3d 80 00       	push   $0x803d1d
  800876:	6a 58                	push   $0x58
  800878:	68 32 3f 80 00       	push   $0x803f32
  80087d:	e8 10 12 00 00       	call   801a92 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800882:	83 c3 01             	add    $0x1,%ebx
  800885:	89 d8                	mov    %ebx,%eax
  800887:	c1 e0 0f             	shl    $0xf,%eax
  80088a:	39 f0                	cmp    %esi,%eax
  80088c:	72 ce                	jb     80085c <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80088e:	83 ec 0c             	sub    $0xc,%esp
  800891:	6a 00                	push   $0x0
  800893:	e8 30 fe ff ff       	call   8006c8 <block_is_free>
  800898:	83 c4 10             	add    $0x10,%esp
  80089b:	84 c0                	test   %al,%al
  80089d:	74 16                	je     8008b5 <check_bitmap+0x6d>
  80089f:	68 96 3f 80 00       	push   $0x803f96
  8008a4:	68 1d 3d 80 00       	push   $0x803d1d
  8008a9:	6a 5b                	push   $0x5b
  8008ab:	68 32 3f 80 00       	push   $0x803f32
  8008b0:	e8 dd 11 00 00       	call   801a92 <_panic>
	assert(!block_is_free(1));
  8008b5:	83 ec 0c             	sub    $0xc,%esp
  8008b8:	6a 01                	push   $0x1
  8008ba:	e8 09 fe ff ff       	call   8006c8 <block_is_free>
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	84 c0                	test   %al,%al
  8008c4:	74 16                	je     8008dc <check_bitmap+0x94>
  8008c6:	68 a8 3f 80 00       	push   $0x803fa8
  8008cb:	68 1d 3d 80 00       	push   $0x803d1d
  8008d0:	6a 5c                	push   $0x5c
  8008d2:	68 32 3f 80 00       	push   $0x803f32
  8008d7:	e8 b6 11 00 00       	call   801a92 <_panic>

	cprintf("bitmap is good\n");
  8008dc:	83 ec 0c             	sub    $0xc,%esp
  8008df:	68 ba 3f 80 00       	push   $0x803fba
  8008e4:	e8 82 12 00 00       	call   801b6b <cprintf>
}
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ef:	5b                   	pop    %ebx
  8008f0:	5e                   	pop    %esi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  8008f9:	e8 61 f7 ff ff       	call   80005f <ide_probe_disk1>
  8008fe:	84 c0                	test   %al,%al
  800900:	74 0f                	je     800911 <fs_init+0x1e>
               ide_set_disk(1);
  800902:	83 ec 0c             	sub    $0xc,%esp
  800905:	6a 01                	push   $0x1
  800907:	e8 b7 f7 ff ff       	call   8000c3 <ide_set_disk>
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	eb 0d                	jmp    80091e <fs_init+0x2b>
       else
               ide_set_disk(0);
  800911:	83 ec 0c             	sub    $0xc,%esp
  800914:	6a 00                	push   $0x0
  800916:	e8 a8 f7 ff ff       	call   8000c3 <ide_set_disk>
  80091b:	83 c4 10             	add    $0x10,%esp
	bc_init();
  80091e:	e8 ad fb ff ff       	call   8004d0 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800923:	83 ec 0c             	sub    $0xc,%esp
  800926:	6a 01                	push   $0x1
  800928:	e8 61 fa ff ff       	call   80038e <diskaddr>
  80092d:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800932:	e8 3b fd ff ff       	call   800672 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800937:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80093e:	e8 4b fa ff ff       	call   80038e <diskaddr>
  800943:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  800948:	e8 fb fe ff ff       	call   800848 <check_bitmap>
	
}
  80094d:	83 c4 10             	add    $0x10,%esp
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 24             	sub    $0x24,%esp
	// LAB 5: Your code here.
    int alloc, r;
	uint32_t *blockno;

	if ((r = file_block_walk(f, filebno, &blockno, 1)) < 0)
  800958:	6a 01                	push   $0x1
  80095a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  80095d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	e8 43 fe ff ff       	call   8007ab <file_block_walk>
  800968:	83 c4 10             	add    $0x10,%esp
  80096b:	85 c0                	test   %eax,%eax
  80096d:	78 30                	js     80099f <file_get_block+0x4d>
		return r;

	// block doesn't exist
	if (*blockno == 0) {
  80096f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800972:	83 38 00             	cmpl   $0x0,(%eax)
  800975:	75 0e                	jne    800985 <file_get_block+0x33>
		if ((alloc = alloc_block()) < 0)
  800977:	e8 c5 fd ff ff       	call   800741 <alloc_block>
  80097c:	85 c0                	test   %eax,%eax
  80097e:	78 1f                	js     80099f <file_get_block+0x4d>
			return alloc;
		*blockno = alloc;
  800980:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800983:	89 02                	mov    %eax,(%edx)
	}
	*blk = (char *) diskaddr(*blockno);
  800985:	83 ec 0c             	sub    $0xc,%esp
  800988:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098b:	ff 30                	pushl  (%eax)
  80098d:	e8 fc f9 ff ff       	call   80038e <diskaddr>
  800992:	8b 55 10             	mov    0x10(%ebp),%edx
  800995:	89 02                	mov    %eax,(%edx)

	return 0;
  800997:	83 c4 10             	add    $0x10,%esp
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
    
    //panic("file_get_block not implemented");
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8009ad:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  8009b3:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  8009b9:	eb 03                	jmp    8009be <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8009bb:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8009be:	80 38 2f             	cmpb   $0x2f,(%eax)
  8009c1:	74 f8                	je     8009bb <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8009c3:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  8009c9:	83 c1 08             	add    $0x8,%ecx
  8009cc:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  8009d2:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  8009d9:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  8009df:	85 c9                	test   %ecx,%ecx
  8009e1:	74 06                	je     8009e9 <walk_path+0x48>
		*pdir = 0;
  8009e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8009e9:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  8009ef:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8009fa:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a00:	e9 5f 01 00 00       	jmp    800b64 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a05:	83 c7 01             	add    $0x1,%edi
  800a08:	eb 02                	jmp    800a0c <walk_path+0x6b>
  800a0a:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a0c:	0f b6 17             	movzbl (%edi),%edx
  800a0f:	80 fa 2f             	cmp    $0x2f,%dl
  800a12:	74 04                	je     800a18 <walk_path+0x77>
  800a14:	84 d2                	test   %dl,%dl
  800a16:	75 ed                	jne    800a05 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a18:	89 fb                	mov    %edi,%ebx
  800a1a:	29 c3                	sub    %eax,%ebx
  800a1c:	83 fb 7f             	cmp    $0x7f,%ebx
  800a1f:	0f 8f 69 01 00 00    	jg     800b8e <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a25:	83 ec 04             	sub    $0x4,%esp
  800a28:	53                   	push   %ebx
  800a29:	50                   	push   %eax
  800a2a:	56                   	push   %esi
  800a2b:	e8 52 18 00 00       	call   802282 <memmove>
		name[path - p] = '\0';
  800a30:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a37:	00 
  800a38:	83 c4 10             	add    $0x10,%esp
  800a3b:	eb 03                	jmp    800a40 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a3d:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a40:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a43:	74 f8                	je     800a3d <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800a45:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800a4b:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800a52:	0f 85 3d 01 00 00    	jne    800b95 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800a58:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800a5e:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800a63:	74 19                	je     800a7e <walk_path+0xdd>
  800a65:	68 ca 3f 80 00       	push   $0x803fca
  800a6a:	68 1d 3d 80 00       	push   $0x803d1d
  800a6f:	68 db 00 00 00       	push   $0xdb
  800a74:	68 32 3f 80 00       	push   $0x803f32
  800a79:	e8 14 10 00 00       	call   801a92 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800a7e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800a84:	85 c0                	test   %eax,%eax
  800a86:	0f 48 c2             	cmovs  %edx,%eax
  800a89:	c1 f8 0c             	sar    $0xc,%eax
  800a8c:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800a92:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800a99:	00 00 00 
  800a9c:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800aa2:	eb 5e                	jmp    800b02 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800aa4:	83 ec 04             	sub    $0x4,%esp
  800aa7:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800aad:	50                   	push   %eax
  800aae:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800ab4:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800aba:	e8 93 fe ff ff       	call   800952 <file_get_block>
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	0f 88 ee 00 00 00    	js     800bb8 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800aca:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800ad0:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800ad6:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	e8 b4 16 00 00       	call   80219a <strcmp>
  800ae6:	83 c4 10             	add    $0x10,%esp
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	0f 84 ab 00 00 00    	je     800b9c <walk_path+0x1fb>
  800af1:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800af7:	39 fb                	cmp    %edi,%ebx
  800af9:	75 db                	jne    800ad6 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800afb:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b02:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b08:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b0e:	75 94                	jne    800aa4 <walk_path+0x103>
  800b10:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b16:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b1b:	80 3f 00             	cmpb   $0x0,(%edi)
  800b1e:	0f 85 a3 00 00 00    	jne    800bc7 <walk_path+0x226>
				if (pdir)
  800b24:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	74 08                	je     800b36 <walk_path+0x195>
					*pdir = dir;
  800b2e:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b34:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b3a:	74 15                	je     800b51 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800b3c:	83 ec 08             	sub    $0x8,%esp
  800b3f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b45:	50                   	push   %eax
  800b46:	ff 75 08             	pushl  0x8(%ebp)
  800b49:	e8 a2 15 00 00       	call   8020f0 <strcpy>
  800b4e:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800b51:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b57:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800b5d:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800b62:	eb 63                	jmp    800bc7 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b64:	80 38 00             	cmpb   $0x0,(%eax)
  800b67:	0f 85 9d fe ff ff    	jne    800a0a <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800b6d:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b73:	85 c0                	test   %eax,%eax
  800b75:	74 02                	je     800b79 <walk_path+0x1d8>
		*pdir = dir;
  800b77:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800b79:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b7f:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b85:	89 08                	mov    %ecx,(%eax)
	return 0;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	eb 39                	jmp    800bc7 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800b8e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800b93:	eb 32                	jmp    800bc7 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800b95:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800b9a:	eb 2b                	jmp    800bc7 <walk_path+0x226>
  800b9c:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800ba2:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800ba8:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800bae:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800bb4:	89 f8                	mov    %edi,%eax
  800bb6:	eb ac                	jmp    800b64 <walk_path+0x1c3>
  800bb8:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800bbe:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800bc1:	0f 84 4f ff ff ff    	je     800b16 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800bc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800bd5:	6a 00                	push   $0x0
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	e8 ba fd ff ff       	call   8009a1 <walk_path>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 2c             	sub    $0x2c,%esp
  800bf2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bf5:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c06:	39 ca                	cmp    %ecx,%edx
  800c08:	7e 7c                	jle    800c86 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c0a:	29 ca                	sub    %ecx,%edx
  800c0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0f:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c13:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c16:	89 ce                	mov    %ecx,%esi
  800c18:	01 d1                	add    %edx,%ecx
  800c1a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c1d:	eb 5d                	jmp    800c7c <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c1f:	83 ec 04             	sub    $0x4,%esp
  800c22:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c25:	50                   	push   %eax
  800c26:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c2c:	85 f6                	test   %esi,%esi
  800c2e:	0f 49 c6             	cmovns %esi,%eax
  800c31:	c1 f8 0c             	sar    $0xc,%eax
  800c34:	50                   	push   %eax
  800c35:	ff 75 08             	pushl  0x8(%ebp)
  800c38:	e8 15 fd ff ff       	call   800952 <file_get_block>
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	85 c0                	test   %eax,%eax
  800c42:	78 42                	js     800c86 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800c44:	89 f2                	mov    %esi,%edx
  800c46:	c1 fa 1f             	sar    $0x1f,%edx
  800c49:	c1 ea 14             	shr    $0x14,%edx
  800c4c:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800c4f:	25 ff 0f 00 00       	and    $0xfff,%eax
  800c54:	29 d0                	sub    %edx,%eax
  800c56:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800c59:	29 da                	sub    %ebx,%edx
  800c5b:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800c60:	29 c3                	sub    %eax,%ebx
  800c62:	39 da                	cmp    %ebx,%edx
  800c64:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800c67:	83 ec 04             	sub    $0x4,%esp
  800c6a:	53                   	push   %ebx
  800c6b:	03 45 e4             	add    -0x1c(%ebp),%eax
  800c6e:	50                   	push   %eax
  800c6f:	57                   	push   %edi
  800c70:	e8 0d 16 00 00       	call   802282 <memmove>
		pos += bn;
  800c75:	01 de                	add    %ebx,%esi
		buf += bn;
  800c77:	01 df                	add    %ebx,%edi
  800c79:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800c7c:	89 f3                	mov    %esi,%ebx
  800c7e:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800c81:	77 9c                	ja     800c1f <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800c83:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 2c             	sub    $0x2c,%esp
  800c97:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800c9a:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800ca0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800ca3:	0f 8e a7 00 00 00    	jle    800d50 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800ca9:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800caf:	05 ff 0f 00 00       	add    $0xfff,%eax
  800cb4:	0f 49 f8             	cmovns %eax,%edi
  800cb7:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800cba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbd:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc5:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800ccb:	0f 49 c2             	cmovns %edx,%eax
  800cce:	c1 f8 0c             	sar    $0xc,%eax
  800cd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800cd4:	89 c3                	mov    %eax,%ebx
  800cd6:	eb 39                	jmp    800d11 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	6a 00                	push   $0x0
  800cdd:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800ce0:	89 da                	mov    %ebx,%edx
  800ce2:	89 f0                	mov    %esi,%eax
  800ce4:	e8 c2 fa ff ff       	call   8007ab <file_block_walk>
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	85 c0                	test   %eax,%eax
  800cee:	78 4d                	js     800d3d <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800cf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cf3:	8b 00                	mov    (%eax),%eax
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	74 15                	je     800d0e <file_set_size+0x80>
		free_block(*ptr);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	e8 03 fa ff ff       	call   800705 <free_block>
		*ptr = 0;
  800d02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d05:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d0b:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d0e:	83 c3 01             	add    $0x1,%ebx
  800d11:	39 df                	cmp    %ebx,%edi
  800d13:	77 c3                	ja     800cd8 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d15:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d19:	77 35                	ja     800d50 <file_set_size+0xc2>
  800d1b:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d21:	85 c0                	test   %eax,%eax
  800d23:	74 2b                	je     800d50 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	e8 d7 f9 ff ff       	call   800705 <free_block>
		f->f_indirect = 0;
  800d2e:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d35:	00 00 00 
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	eb 13                	jmp    800d50 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d3d:	83 ec 08             	sub    $0x8,%esp
  800d40:	50                   	push   %eax
  800d41:	68 e7 3f 80 00       	push   $0x803fe7
  800d46:	e8 20 0e 00 00       	call   801b6b <cprintf>
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	eb be                	jmp    800d0e <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d53:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	56                   	push   %esi
  800d5d:	e8 aa f6 ff ff       	call   80040c <flush_block>
	return 0;
}
  800d62:	b8 00 00 00 00       	mov    $0x0,%eax
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 2c             	sub    $0x2c,%esp
  800d78:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d7b:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800d7e:	89 f0                	mov    %esi,%eax
  800d80:	03 45 10             	add    0x10(%ebp),%eax
  800d83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800d86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d89:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800d8f:	76 72                	jbe    800e03 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800d91:	83 ec 08             	sub    $0x8,%esp
  800d94:	50                   	push   %eax
  800d95:	51                   	push   %ecx
  800d96:	e8 f3 fe ff ff       	call   800c8e <file_set_size>
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	79 61                	jns    800e03 <file_write+0x94>
  800da2:	eb 69                	jmp    800e0d <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800daa:	50                   	push   %eax
  800dab:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800db1:	85 f6                	test   %esi,%esi
  800db3:	0f 49 c6             	cmovns %esi,%eax
  800db6:	c1 f8 0c             	sar    $0xc,%eax
  800db9:	50                   	push   %eax
  800dba:	ff 75 08             	pushl  0x8(%ebp)
  800dbd:	e8 90 fb ff ff       	call   800952 <file_get_block>
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	78 44                	js     800e0d <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dc9:	89 f2                	mov    %esi,%edx
  800dcb:	c1 fa 1f             	sar    $0x1f,%edx
  800dce:	c1 ea 14             	shr    $0x14,%edx
  800dd1:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800dd4:	25 ff 0f 00 00       	and    $0xfff,%eax
  800dd9:	29 d0                	sub    %edx,%eax
  800ddb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800dde:	29 d9                	sub    %ebx,%ecx
  800de0:	89 cb                	mov    %ecx,%ebx
  800de2:	ba 00 10 00 00       	mov    $0x1000,%edx
  800de7:	29 c2                	sub    %eax,%edx
  800de9:	39 d1                	cmp    %edx,%ecx
  800deb:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	53                   	push   %ebx
  800df2:	57                   	push   %edi
  800df3:	03 45 e4             	add    -0x1c(%ebp),%eax
  800df6:	50                   	push   %eax
  800df7:	e8 86 14 00 00       	call   802282 <memmove>
		pos += bn;
  800dfc:	01 de                	add    %ebx,%esi
		buf += bn;
  800dfe:	01 df                	add    %ebx,%edi
  800e00:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e03:	89 f3                	mov    %esi,%ebx
  800e05:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e08:	77 9a                	ja     800da4 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e0a:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 10             	sub    $0x10,%esp
  800e1d:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e25:	eb 3c                	jmp    800e63 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	6a 00                	push   $0x0
  800e2c:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e2f:	89 da                	mov    %ebx,%edx
  800e31:	89 f0                	mov    %esi,%eax
  800e33:	e8 73 f9 ff ff       	call   8007ab <file_block_walk>
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	78 21                	js     800e60 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e42:	85 c0                	test   %eax,%eax
  800e44:	74 1a                	je     800e60 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e46:	8b 00                	mov    (%eax),%eax
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	74 14                	je     800e60 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	50                   	push   %eax
  800e50:	e8 39 f5 ff ff       	call   80038e <diskaddr>
  800e55:	89 04 24             	mov    %eax,(%esp)
  800e58:	e8 af f5 ff ff       	call   80040c <flush_block>
  800e5d:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e60:	83 c3 01             	add    $0x1,%ebx
  800e63:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800e69:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800e6f:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800e75:	85 c9                	test   %ecx,%ecx
  800e77:	0f 49 c1             	cmovns %ecx,%eax
  800e7a:	c1 f8 0c             	sar    $0xc,%eax
  800e7d:	39 c3                	cmp    %eax,%ebx
  800e7f:	7c a6                	jl     800e27 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800e81:	83 ec 0c             	sub    $0xc,%esp
  800e84:	56                   	push   %esi
  800e85:	e8 82 f5 ff ff       	call   80040c <flush_block>
	if (f->f_indirect)
  800e8a:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	74 14                	je     800eab <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	50                   	push   %eax
  800e9b:	e8 ee f4 ff ff       	call   80038e <diskaddr>
  800ea0:	89 04 24             	mov    %eax,(%esp)
  800ea3:	e8 64 f5 ff ff       	call   80040c <flush_block>
  800ea8:	83 c4 10             	add    $0x10,%esp
}
  800eab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800ebe:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ec4:	50                   	push   %eax
  800ec5:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800ecb:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed4:	e8 c8 fa ff ff       	call   8009a1 <walk_path>
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	0f 84 d1 00 00 00    	je     800fb5 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800ee4:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ee7:	0f 85 0c 01 00 00    	jne    800ff9 <file_create+0x147>
  800eed:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800ef3:	85 f6                	test   %esi,%esi
  800ef5:	0f 84 c1 00 00 00    	je     800fbc <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800efb:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f01:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f06:	74 19                	je     800f21 <file_create+0x6f>
  800f08:	68 ca 3f 80 00       	push   $0x803fca
  800f0d:	68 1d 3d 80 00       	push   $0x803d1d
  800f12:	68 f4 00 00 00       	push   $0xf4
  800f17:	68 32 3f 80 00       	push   $0x803f32
  800f1c:	e8 71 0b 00 00       	call   801a92 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f21:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f27:	85 c0                	test   %eax,%eax
  800f29:	0f 48 c2             	cmovs  %edx,%eax
  800f2c:	c1 f8 0c             	sar    $0xc,%eax
  800f2f:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f35:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f3a:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f40:	eb 3b                	jmp    800f7d <file_create+0xcb>
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	57                   	push   %edi
  800f46:	53                   	push   %ebx
  800f47:	56                   	push   %esi
  800f48:	e8 05 fa ff ff       	call   800952 <file_get_block>
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	0f 88 a1 00 00 00    	js     800ff9 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800f58:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f5e:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800f64:	80 38 00             	cmpb   $0x0,(%eax)
  800f67:	75 08                	jne    800f71 <file_create+0xbf>
				*file = &f[j];
  800f69:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800f6f:	eb 52                	jmp    800fc3 <file_create+0x111>
  800f71:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800f76:	39 d0                	cmp    %edx,%eax
  800f78:	75 ea                	jne    800f64 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800f7a:	83 c3 01             	add    $0x1,%ebx
  800f7d:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800f83:	75 bd                	jne    800f42 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800f85:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800f8c:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	53                   	push   %ebx
  800f9a:	56                   	push   %esi
  800f9b:	e8 b2 f9 ff ff       	call   800952 <file_get_block>
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 52                	js     800ff9 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  800fa7:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fad:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fb3:	eb 0e                	jmp    800fc3 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800fb5:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800fba:	eb 3d                	jmp    800ff9 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800fbc:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800fc1:	eb 36                	jmp    800ff9 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  800fc3:	83 ec 08             	sub    $0x8,%esp
  800fc6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800fcc:	50                   	push   %eax
  800fcd:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  800fd3:	e8 18 11 00 00       	call   8020f0 <strcpy>
	*pf = f;
  800fd8:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800fde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe1:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  800fe3:	83 c4 04             	add    $0x4,%esp
  800fe6:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  800fec:	e8 24 fe ff ff       	call   800e15 <file_flush>
	return 0;
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	53                   	push   %ebx
  801005:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801008:	bb 01 00 00 00       	mov    $0x1,%ebx
  80100d:	eb 17                	jmp    801026 <fs_sync+0x25>
		flush_block(diskaddr(i));
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	53                   	push   %ebx
  801013:	e8 76 f3 ff ff       	call   80038e <diskaddr>
  801018:	89 04 24             	mov    %eax,(%esp)
  80101b:	e8 ec f3 ff ff       	call   80040c <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801020:	83 c3 01             	add    $0x1,%ebx
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80102b:	39 58 04             	cmp    %ebx,0x4(%eax)
  80102e:	77 df                	ja     80100f <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801030:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80103b:	e8 c1 ff ff ff       	call   801001 <fs_sync>
	return 0;
}
  801040:	b8 00 00 00 00       	mov    $0x0,%eax
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  80104f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801054:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801059:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80105b:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80105e:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801064:	83 c0 01             	add    $0x1,%eax
  801067:	83 c2 10             	add    $0x10,%edx
  80106a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80106f:	75 e8                	jne    801059 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80107b:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	89 d8                	mov    %ebx,%eax
  801085:	c1 e0 04             	shl    $0x4,%eax
  801088:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80108e:	e8 2d 20 00 00       	call   8030c0 <pageref>
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	74 07                	je     8010a1 <openfile_alloc+0x2e>
  80109a:	83 f8 01             	cmp    $0x1,%eax
  80109d:	74 20                	je     8010bf <openfile_alloc+0x4c>
  80109f:	eb 51                	jmp    8010f2 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010a1:	83 ec 04             	sub    $0x4,%esp
  8010a4:	6a 07                	push   $0x7
  8010a6:	89 d8                	mov    %ebx,%eax
  8010a8:	c1 e0 04             	shl    $0x4,%eax
  8010ab:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010b1:	6a 00                	push   $0x0
  8010b3:	e8 3b 14 00 00       	call   8024f3 <sys_page_alloc>
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 43                	js     801102 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8010bf:	c1 e3 04             	shl    $0x4,%ebx
  8010c2:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8010c8:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8010cf:	04 00 00 
			*o = &opentab[i];
  8010d2:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	68 00 10 00 00       	push   $0x1000
  8010dc:	6a 00                	push   $0x0
  8010de:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8010e4:	e8 4c 11 00 00       	call   802235 <memset>
			return (*o)->o_fileid;
  8010e9:	8b 06                	mov    (%esi),%eax
  8010eb:	8b 00                	mov    (%eax),%eax
  8010ed:	83 c4 10             	add    $0x10,%esp
  8010f0:	eb 10                	jmp    801102 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010f2:	83 c3 01             	add    $0x1,%ebx
  8010f5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8010fb:	75 83                	jne    801080 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  8010fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801102:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801105:	5b                   	pop    %ebx
  801106:	5e                   	pop    %esi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	57                   	push   %edi
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
  80110f:	83 ec 18             	sub    $0x18,%esp
  801112:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801115:	89 fb                	mov    %edi,%ebx
  801117:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80111d:	89 de                	mov    %ebx,%esi
  80111f:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801122:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801128:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80112e:	e8 8d 1f 00 00       	call   8030c0 <pageref>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	83 f8 01             	cmp    $0x1,%eax
  801139:	7e 17                	jle    801152 <openfile_lookup+0x49>
  80113b:	c1 e3 04             	shl    $0x4,%ebx
  80113e:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801144:	75 13                	jne    801159 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801146:	8b 45 10             	mov    0x10(%ebp),%eax
  801149:	89 30                	mov    %esi,(%eax)
	return 0;
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
  801150:	eb 0c                	jmp    80115e <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  801152:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801157:	eb 05                	jmp    80115e <openfile_lookup+0x55>
  801159:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80115e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5f                   	pop    %edi
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 10             	sub    $0x10,%esp
  80116e:	8b 75 08             	mov    0x8(%ebp),%esi
  801171:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_set_size %08x %08x %08x\n", envid, req->req_fileid, req->req_size);
  801174:	ff 73 04             	pushl  0x4(%ebx)
  801177:	ff 33                	pushl  (%ebx)
  801179:	56                   	push   %esi
  80117a:	68 04 40 80 00       	push   $0x804004
  80117f:	e8 e7 09 00 00       	call   801b6b <cprintf>
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801184:	83 c4 0c             	add    $0xc,%esp
  801187:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	ff 33                	pushl  (%ebx)
  80118d:	56                   	push   %esi
  80118e:	e8 76 ff ff ff       	call   801109 <openfile_lookup>
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	78 14                	js     8011ae <serve_set_size+0x48>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  80119a:	83 ec 08             	sub    $0x8,%esp
  80119d:	ff 73 04             	pushl  0x4(%ebx)
  8011a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a3:	ff 70 04             	pushl  0x4(%eax)
  8011a6:	e8 e3 fa ff ff       	call   800c8e <file_set_size>
  8011ab:	83 c4 10             	add    $0x10,%esp
}
  8011ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	56                   	push   %esi
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 10             	sub    $0x10,%esp
  8011bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fsreq_read *req = &ipc->read;
	struct Fsret_read *ret = &ipc->readRet;
	struct OpenFile *o;

	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
  8011c3:	ff 73 04             	pushl  0x4(%ebx)
  8011c6:	ff 33                	pushl  (%ebx)
  8011c8:	56                   	push   %esi
  8011c9:	68 9f 40 80 00       	push   $0x80409f
  8011ce:	e8 98 09 00 00       	call   801b6b <cprintf>

	// Lab 5: Your code here:
	int r;
	
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011d3:	83 c4 0c             	add    $0xc,%esp
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff 33                	pushl  (%ebx)
  8011dc:	56                   	push   %esi
  8011dd:	e8 27 ff ff ff       	call   801109 <openfile_lookup>
  8011e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8011e5:	89 c2                	mov    %eax,%edx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	int r;
	
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 2b                	js     801216 <serve_read+0x61>
		return r;

	int retbytes = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
  8011eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ee:	8b 50 0c             	mov    0xc(%eax),%edx
  8011f1:	ff 72 04             	pushl  0x4(%edx)
  8011f4:	ff 73 04             	pushl  0x4(%ebx)
  8011f7:	53                   	push   %ebx
  8011f8:	ff 70 04             	pushl  0x4(%eax)
  8011fb:	e8 e9 f9 ff ff       	call   800be9 <file_read>
	
	if(retbytes > 0)
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	7e 0d                	jle    801214 <serve_read+0x5f>
		 o->o_fd->fd_offset = o->o_fd->fd_offset + retbytes;
  801207:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120a:	8b 52 0c             	mov    0xc(%edx),%edx
  80120d:	01 42 04             	add    %eax,0x4(%edx)
	return retbytes;
  801210:	89 c2                	mov    %eax,%edx
  801212:	eb 02                	jmp    801216 <serve_read+0x61>
  801214:	89 c2                	mov    %eax,%edx
}
  801216:	89 d0                	mov    %edx,%eax
  801218:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80121b:	5b                   	pop    %ebx
  80121c:	5e                   	pop    %esi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 10             	sub    $0x10,%esp
  801227:	8b 75 08             	mov    0x8(%ebp),%esi
  80122a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
  80122d:	ff 73 04             	pushl  0x4(%ebx)
  801230:	ff 33                	pushl  (%ebx)
  801232:	56                   	push   %esi
  801233:	68 ba 40 80 00       	push   $0x8040ba
  801238:	e8 2e 09 00 00       	call   801b6b <cprintf>

	// LAB 5: Your code here.
	struct OpenFile *o;
	int r;
	
	if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80123d:	83 c4 0c             	add    $0xc,%esp
  801240:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801243:	50                   	push   %eax
  801244:	ff 33                	pushl  (%ebx)
  801246:	56                   	push   %esi
  801247:	e8 bd fe ff ff       	call   801109 <openfile_lookup>
  80124c:	83 c4 10             	add    $0x10,%esp
		return r;
  80124f:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	struct OpenFile *o;
	int r;
	
	if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801251:	85 c0                	test   %eax,%eax
  801253:	78 2e                	js     801283 <serve_write+0x64>
		return r;
	
	int retbytes = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
  801255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801258:	8b 50 0c             	mov    0xc(%eax),%edx
  80125b:	ff 72 04             	pushl  0x4(%edx)
  80125e:	ff 73 04             	pushl  0x4(%ebx)
  801261:	83 c3 08             	add    $0x8,%ebx
  801264:	53                   	push   %ebx
  801265:	ff 70 04             	pushl  0x4(%eax)
  801268:	e8 02 fb ff ff       	call   800d6f <file_write>
	
	if(retbytes > 0)
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	7e 0d                	jle    801281 <serve_write+0x62>
		 o->o_fd->fd_offset = o->o_fd->fd_offset + retbytes;
  801274:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801277:	8b 52 0c             	mov    0xc(%edx),%edx
  80127a:	01 42 04             	add    %eax,0x4(%edx)
	
	return retbytes;
  80127d:	89 c2                	mov    %eax,%edx
  80127f:	eb 02                	jmp    801283 <serve_write+0x64>
  801281:	89 c2                	mov    %eax,%edx
	//panic("serve_write not implemented");
}
  801283:	89 d0                	mov    %edx,%eax
  801285:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	56                   	push   %esi
  801290:	53                   	push   %ebx
  801291:	83 ec 14             	sub    $0x14,%esp
  801294:	8b 75 08             	mov    0x8(%ebp),%esi
  801297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fsret_stat *ret = &ipc->statRet;
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);
  80129a:	ff 33                	pushl  (%ebx)
  80129c:	56                   	push   %esi
  80129d:	68 d6 40 80 00       	push   $0x8040d6
  8012a2:	e8 c4 08 00 00       	call   801b6b <cprintf>

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012a7:	83 c4 0c             	add    $0xc,%esp
  8012aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	ff 33                	pushl  (%ebx)
  8012b0:	56                   	push   %esi
  8012b1:	e8 53 fe ff ff       	call   801109 <openfile_lookup>
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 3f                	js     8012fc <serve_stat+0x70>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c3:	ff 70 04             	pushl  0x4(%eax)
  8012c6:	53                   	push   %ebx
  8012c7:	e8 24 0e 00 00       	call   8020f0 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8012cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cf:	8b 50 04             	mov    0x4(%eax),%edx
  8012d2:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012d8:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012de:	8b 40 04             	mov    0x4(%eax),%eax
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012eb:	0f 94 c0             	sete   %al
  8012ee:	0f b6 c0             	movzbl %al,%eax
  8012f1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	56                   	push   %esi
  801307:	53                   	push   %ebx
  801308:	83 ec 14             	sub    $0x14,%esp
  80130b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80130e:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);
  801311:	ff 36                	pushl  (%esi)
  801313:	53                   	push   %ebx
  801314:	68 ec 40 80 00       	push   $0x8040ec
  801319:	e8 4d 08 00 00       	call   801b6b <cprintf>

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80131e:	83 c4 0c             	add    $0xc,%esp
  801321:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	ff 36                	pushl  (%esi)
  801327:	53                   	push   %ebx
  801328:	e8 dc fd ff ff       	call   801109 <openfile_lookup>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 16                	js     80134a <serve_flush+0x47>
		return r;
	file_flush(o->o_file);
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133a:	ff 70 04             	pushl  0x4(%eax)
  80133d:	e8 d3 fa ff ff       	call   800e15 <file_flush>
	return 0;
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80134a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	56                   	push   %esi
  801355:	53                   	push   %ebx
  801356:	81 ec 10 04 00 00    	sub    $0x410,%esp
  80135c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int fileid;
	int r;
	struct OpenFile *o;

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);
  80135f:	ff b6 00 04 00 00    	pushl  0x400(%esi)
  801365:	56                   	push   %esi
  801366:	ff 75 08             	pushl  0x8(%ebp)
  801369:	68 03 41 80 00       	push   $0x804103
  80136e:	e8 f8 07 00 00       	call   801b6b <cprintf>

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801373:	83 c4 0c             	add    $0xc,%esp
  801376:	68 00 04 00 00       	push   $0x400
  80137b:	56                   	push   %esi
  80137c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	e8 fa 0e 00 00       	call   802282 <memmove>
	path[MAXPATHLEN-1] = 0;
  801388:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80138c:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801392:	89 04 24             	mov    %eax,(%esp)
  801395:	e8 d9 fc ff ff       	call   801073 <openfile_alloc>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	79 1a                	jns    8013bb <serve_open+0x6a>
  8013a1:	89 c3                	mov    %eax,%ebx
		if (debug)
			cprintf("openfile_alloc failed: %e", r);
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	50                   	push   %eax
  8013a7:	68 1c 41 80 00       	push   $0x80411c
  8013ac:	e8 ba 07 00 00       	call   801b6b <cprintf>
		return r;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	89 d8                	mov    %ebx,%eax
  8013b6:	e9 62 01 00 00       	jmp    80151d <serve_open+0x1cc>
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8013bb:	f6 86 01 04 00 00 01 	testb  $0x1,0x401(%esi)
  8013c2:	74 45                	je     801409 <serve_open+0xb8>
		if ((r = file_create(path, &f)) < 0) {
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	e8 d8 fa ff ff       	call   800eb2 <file_create>
  8013da:	89 c3                	mov    %eax,%ebx
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	79 5d                	jns    801440 <serve_open+0xef>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8013e3:	f6 86 01 04 00 00 04 	testb  $0x4,0x401(%esi)
  8013ea:	75 05                	jne    8013f1 <serve_open+0xa0>
  8013ec:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8013ef:	74 18                	je     801409 <serve_open+0xb8>
				goto try_open;
			if (debug)
				cprintf("file_create failed: %e", r);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	53                   	push   %ebx
  8013f5:	68 36 41 80 00       	push   $0x804136
  8013fa:	e8 6c 07 00 00       	call   801b6b <cprintf>
			return r;
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	89 d8                	mov    %ebx,%eax
  801404:	e9 14 01 00 00       	jmp    80151d <serve_open+0x1cc>
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	e8 b0 f7 ff ff       	call   800bcf <file_open>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	79 18                	jns    801440 <serve_open+0xef>
			if (debug)
				cprintf("file_open failed: %e", r);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	50                   	push   %eax
  80142c:	68 4d 41 80 00       	push   $0x80414d
  801431:	e8 35 07 00 00       	call   801b6b <cprintf>
			return r;
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	89 d8                	mov    %ebx,%eax
  80143b:	e9 dd 00 00 00       	jmp    80151d <serve_open+0x1cc>
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801440:	f6 86 01 04 00 00 02 	testb  $0x2,0x401(%esi)
  801447:	74 31                	je     80147a <serve_open+0x129>
		if ((r = file_set_size(f, 0)) < 0) {
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	6a 00                	push   $0x0
  80144e:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801454:	e8 35 f8 ff ff       	call   800c8e <file_set_size>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	79 18                	jns    80147a <serve_open+0x129>
			if (debug)
				cprintf("file_set_size failed: %e", r);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	50                   	push   %eax
  801466:	68 62 41 80 00       	push   $0x804162
  80146b:	e8 fb 06 00 00       	call   801b6b <cprintf>
			return r;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	89 d8                	mov    %ebx,%eax
  801475:	e9 a3 00 00 00       	jmp    80151d <serve_open+0x1cc>
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	e8 3f f7 ff ff       	call   800bcf <file_open>
  801490:	89 c3                	mov    %eax,%ebx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	79 15                	jns    8014ae <serve_open+0x15d>
		if (debug)
			cprintf("file_open failed: %e", r);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	50                   	push   %eax
  80149d:	68 4d 41 80 00       	push   $0x80414d
  8014a2:	e8 c4 06 00 00       	call   801b6b <cprintf>
		return r;
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	89 d8                	mov    %ebx,%eax
  8014ac:	eb 6f                	jmp    80151d <serve_open+0x1cc>
	}

	// Save the file pointer
	o->o_file = f;
  8014ae:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8014b4:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8014ba:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8014bd:	8b 50 0c             	mov    0xc(%eax),%edx
  8014c0:	8b 08                	mov    (%eax),%ecx
  8014c2:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8014c5:	8b 48 0c             	mov    0xc(%eax),%ecx
  8014c8:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  8014ce:	83 e2 03             	and    $0x3,%edx
  8014d1:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8014d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d7:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8014dd:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8014df:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8014e5:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  8014eb:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	ff 70 0c             	pushl  0xc(%eax)
  8014f4:	68 7b 41 80 00       	push   $0x80417b
  8014f9:	e8 6d 06 00 00       	call   801b6b <cprintf>

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  8014fe:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801504:	8b 50 0c             	mov    0xc(%eax),%edx
  801507:	8b 45 10             	mov    0x10(%ebp),%eax
  80150a:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  80150c:	8b 45 14             	mov    0x14(%ebp),%eax
  80150f:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801520:	5b                   	pop    %ebx
  801521:	5e                   	pop    %esi
  801522:	5d                   	pop    %ebp
  801523:	c3                   	ret    

00801524 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	57                   	push   %edi
  801528:	56                   	push   %esi
  801529:	53                   	push   %ebx
  80152a:	83 ec 1c             	sub    $0x1c,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80152d:	8d 75 e0             	lea    -0x20(%ebp),%esi
  801530:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801533:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	56                   	push   %esi
  80153e:	ff 35 44 50 80 00    	pushl  0x805044
  801544:	57                   	push   %edi
  801545:	e8 6d 12 00 00       	call   8027b7 <ipc_recv>
  80154a:	89 c3                	mov    %eax,%ebx
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);
  80154c:	a1 44 50 80 00       	mov    0x805044,%eax
  801551:	89 c2                	mov    %eax,%edx
  801553:	c1 ea 0c             	shr    $0xc,%edx

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
  801556:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155d:	89 04 24             	mov    %eax,(%esp)
  801560:	52                   	push   %edx
  801561:	ff 75 e4             	pushl  -0x1c(%ebp)
  801564:	53                   	push   %ebx
  801565:	68 24 40 80 00       	push   $0x804024
  80156a:	e8 fc 05 00 00       	call   801b6b <cprintf>
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80156f:	83 c4 20             	add    $0x20,%esp
  801572:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
  801576:	75 15                	jne    80158d <serve+0x69>
			cprintf("Invalid request from %08x: no argument page\n",
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80157e:	68 4c 40 80 00       	push   $0x80404c
  801583:	e8 e3 05 00 00       	call   801b6b <cprintf>
				whom);
			continue; // just leave it hanging...
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	eb a6                	jmp    801533 <serve+0xf>
		}

		pg = NULL;
  80158d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		if (req == FSREQ_OPEN) {
  801594:	83 fb 01             	cmp    $0x1,%ebx
  801597:	75 18                	jne    8015b1 <serve+0x8d>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801599:	56                   	push   %esi
  80159a:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	ff 35 44 50 80 00    	pushl  0x805044
  8015a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a7:	e8 a5 fd ff ff       	call   801351 <serve_open>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 3c                	jmp    8015ed <serve+0xc9>
		} else if (req < NHANDLERS && handlers[req]) {
  8015b1:	83 fb 08             	cmp    $0x8,%ebx
  8015b4:	77 1e                	ja     8015d4 <serve+0xb0>
  8015b6:	8b 04 9d 20 50 80 00 	mov    0x805020(,%ebx,4),%eax
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	74 13                	je     8015d4 <serve+0xb0>
			r = handlers[req](whom, fsreq);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	ff 35 44 50 80 00    	pushl  0x805044
  8015ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015cd:	ff d0                	call   *%eax
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	eb 19                	jmp    8015ed <serve+0xc9>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8015d4:	83 ec 04             	sub    $0x4,%esp
  8015d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015da:	53                   	push   %ebx
  8015db:	68 7c 40 80 00       	push   $0x80407c
  8015e0:	e8 86 05 00 00       	call   801b6b <cprintf>
  8015e5:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8015e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8015ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f3:	50                   	push   %eax
  8015f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f7:	e8 28 12 00 00       	call   802824 <ipc_send>
		sys_page_unmap(0, fsreq);
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	ff 35 44 50 80 00    	pushl  0x805044
  801605:	6a 00                	push   $0x0
  801607:	e8 6c 0f 00 00       	call   802578 <sys_page_unmap>
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	e9 1f ff ff ff       	jmp    801533 <serve+0xf>

00801614 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80161a:	c7 05 60 90 80 00 97 	movl   $0x804197,0x809060
  801621:	41 80 00 
	cprintf("FS is running\n");
  801624:	68 9a 41 80 00       	push   $0x80419a
  801629:	e8 3d 05 00 00       	call   801b6b <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80162e:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801633:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801638:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80163a:	c7 04 24 a9 41 80 00 	movl   $0x8041a9,(%esp)
  801641:	e8 25 05 00 00       	call   801b6b <cprintf>

	serve_init();
  801646:	e8 fc f9 ff ff       	call   801047 <serve_init>
	fs_init();
  80164b:	e8 a3 f2 ff ff       	call   8008f3 <fs_init>
	serve();
  801650:	e8 cf fe ff ff       	call   801524 <serve>

00801655 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	53                   	push   %ebx
  801659:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80165c:	6a 07                	push   $0x7
  80165e:	68 00 10 00 00       	push   $0x1000
  801663:	6a 00                	push   $0x0
  801665:	e8 89 0e 00 00       	call   8024f3 <sys_page_alloc>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	79 12                	jns    801683 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801671:	50                   	push   %eax
  801672:	68 b8 41 80 00       	push   $0x8041b8
  801677:	6a 12                	push   $0x12
  801679:	68 cb 41 80 00       	push   $0x8041cb
  80167e:	e8 0f 04 00 00       	call   801a92 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801683:	83 ec 04             	sub    $0x4,%esp
  801686:	68 00 10 00 00       	push   $0x1000
  80168b:	ff 35 08 a0 80 00    	pushl  0x80a008
  801691:	68 00 10 00 00       	push   $0x1000
  801696:	e8 e7 0b 00 00       	call   802282 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80169b:	e8 a1 f0 ff ff       	call   800741 <alloc_block>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	79 12                	jns    8016b9 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016a7:	50                   	push   %eax
  8016a8:	68 d5 41 80 00       	push   $0x8041d5
  8016ad:	6a 17                	push   $0x17
  8016af:	68 cb 41 80 00       	push   $0x8041cb
  8016b4:	e8 d9 03 00 00       	call   801a92 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016b9:	8d 50 1f             	lea    0x1f(%eax),%edx
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	0f 49 d0             	cmovns %eax,%edx
  8016c1:	c1 fa 05             	sar    $0x5,%edx
  8016c4:	89 c3                	mov    %eax,%ebx
  8016c6:	c1 fb 1f             	sar    $0x1f,%ebx
  8016c9:	c1 eb 1b             	shr    $0x1b,%ebx
  8016cc:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8016cf:	83 e1 1f             	and    $0x1f,%ecx
  8016d2:	29 d9                	sub    %ebx,%ecx
  8016d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d9:	d3 e0                	shl    %cl,%eax
  8016db:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8016e2:	75 16                	jne    8016fa <fs_test+0xa5>
  8016e4:	68 e5 41 80 00       	push   $0x8041e5
  8016e9:	68 1d 3d 80 00       	push   $0x803d1d
  8016ee:	6a 19                	push   $0x19
  8016f0:	68 cb 41 80 00       	push   $0x8041cb
  8016f5:	e8 98 03 00 00       	call   801a92 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8016fa:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  801700:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801703:	74 16                	je     80171b <fs_test+0xc6>
  801705:	68 60 43 80 00       	push   $0x804360
  80170a:	68 1d 3d 80 00       	push   $0x803d1d
  80170f:	6a 1b                	push   $0x1b
  801711:	68 cb 41 80 00       	push   $0x8041cb
  801716:	e8 77 03 00 00       	call   801a92 <_panic>
	cprintf("alloc_block is good\n");
  80171b:	83 ec 0c             	sub    $0xc,%esp
  80171e:	68 00 42 80 00       	push   $0x804200
  801723:	e8 43 04 00 00       	call   801b6b <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801728:	83 c4 08             	add    $0x8,%esp
  80172b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	68 15 42 80 00       	push   $0x804215
  801734:	e8 96 f4 ff ff       	call   800bcf <file_open>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80173f:	74 1b                	je     80175c <fs_test+0x107>
  801741:	89 c2                	mov    %eax,%edx
  801743:	c1 ea 1f             	shr    $0x1f,%edx
  801746:	84 d2                	test   %dl,%dl
  801748:	74 12                	je     80175c <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80174a:	50                   	push   %eax
  80174b:	68 20 42 80 00       	push   $0x804220
  801750:	6a 1f                	push   $0x1f
  801752:	68 cb 41 80 00       	push   $0x8041cb
  801757:	e8 36 03 00 00       	call   801a92 <_panic>
	else if (r == 0)
  80175c:	85 c0                	test   %eax,%eax
  80175e:	75 14                	jne    801774 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801760:	83 ec 04             	sub    $0x4,%esp
  801763:	68 80 43 80 00       	push   $0x804380
  801768:	6a 21                	push   $0x21
  80176a:	68 cb 41 80 00       	push   $0x8041cb
  80176f:	e8 1e 03 00 00       	call   801a92 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177a:	50                   	push   %eax
  80177b:	68 39 42 80 00       	push   $0x804239
  801780:	e8 4a f4 ff ff       	call   800bcf <file_open>
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	79 12                	jns    80179e <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  80178c:	50                   	push   %eax
  80178d:	68 42 42 80 00       	push   $0x804242
  801792:	6a 23                	push   $0x23
  801794:	68 cb 41 80 00       	push   $0x8041cb
  801799:	e8 f4 02 00 00       	call   801a92 <_panic>
	cprintf("file_open is good\n");
  80179e:	83 ec 0c             	sub    $0xc,%esp
  8017a1:	68 59 42 80 00       	push   $0x804259
  8017a6:	e8 c0 03 00 00       	call   801b6b <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017ab:	83 c4 0c             	add    $0xc,%esp
  8017ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	6a 00                	push   $0x0
  8017b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b7:	e8 96 f1 ff ff       	call   800952 <file_get_block>
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	79 12                	jns    8017d5 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8017c3:	50                   	push   %eax
  8017c4:	68 6c 42 80 00       	push   $0x80426c
  8017c9:	6a 27                	push   $0x27
  8017cb:	68 cb 41 80 00       	push   $0x8041cb
  8017d0:	e8 bd 02 00 00       	call   801a92 <_panic>
	if (strcmp(blk, msg) != 0)
  8017d5:	83 ec 08             	sub    $0x8,%esp
  8017d8:	68 a0 43 80 00       	push   $0x8043a0
  8017dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e0:	e8 b5 09 00 00       	call   80219a <strcmp>
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	74 14                	je     801800 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8017ec:	83 ec 04             	sub    $0x4,%esp
  8017ef:	68 c8 43 80 00       	push   $0x8043c8
  8017f4:	6a 29                	push   $0x29
  8017f6:	68 cb 41 80 00       	push   $0x8041cb
  8017fb:	e8 92 02 00 00       	call   801a92 <_panic>
	cprintf("file_get_block is good\n");
  801800:	83 ec 0c             	sub    $0xc,%esp
  801803:	68 7f 42 80 00       	push   $0x80427f
  801808:	e8 5e 03 00 00       	call   801b6b <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801810:	0f b6 10             	movzbl (%eax),%edx
  801813:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801818:	c1 e8 0c             	shr    $0xc,%eax
  80181b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	a8 40                	test   $0x40,%al
  801827:	75 16                	jne    80183f <fs_test+0x1ea>
  801829:	68 98 42 80 00       	push   $0x804298
  80182e:	68 1d 3d 80 00       	push   $0x803d1d
  801833:	6a 2d                	push   $0x2d
  801835:	68 cb 41 80 00       	push   $0x8041cb
  80183a:	e8 53 02 00 00       	call   801a92 <_panic>
	file_flush(f);
  80183f:	83 ec 0c             	sub    $0xc,%esp
  801842:	ff 75 f4             	pushl  -0xc(%ebp)
  801845:	e8 cb f5 ff ff       	call   800e15 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80184a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184d:	c1 e8 0c             	shr    $0xc,%eax
  801850:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	a8 40                	test   $0x40,%al
  80185c:	74 16                	je     801874 <fs_test+0x21f>
  80185e:	68 97 42 80 00       	push   $0x804297
  801863:	68 1d 3d 80 00       	push   $0x803d1d
  801868:	6a 2f                	push   $0x2f
  80186a:	68 cb 41 80 00       	push   $0x8041cb
  80186f:	e8 1e 02 00 00       	call   801a92 <_panic>
	cprintf("file_flush is good\n");
  801874:	83 ec 0c             	sub    $0xc,%esp
  801877:	68 b3 42 80 00       	push   $0x8042b3
  80187c:	e8 ea 02 00 00       	call   801b6b <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801881:	83 c4 08             	add    $0x8,%esp
  801884:	6a 00                	push   $0x0
  801886:	ff 75 f4             	pushl  -0xc(%ebp)
  801889:	e8 00 f4 ff ff       	call   800c8e <file_set_size>
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	85 c0                	test   %eax,%eax
  801893:	79 12                	jns    8018a7 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801895:	50                   	push   %eax
  801896:	68 c7 42 80 00       	push   $0x8042c7
  80189b:	6a 33                	push   $0x33
  80189d:	68 cb 41 80 00       	push   $0x8041cb
  8018a2:	e8 eb 01 00 00       	call   801a92 <_panic>
	assert(f->f_direct[0] == 0);
  8018a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018aa:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018b1:	74 16                	je     8018c9 <fs_test+0x274>
  8018b3:	68 d9 42 80 00       	push   $0x8042d9
  8018b8:	68 1d 3d 80 00       	push   $0x803d1d
  8018bd:	6a 34                	push   $0x34
  8018bf:	68 cb 41 80 00       	push   $0x8041cb
  8018c4:	e8 c9 01 00 00       	call   801a92 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018c9:	c1 e8 0c             	shr    $0xc,%eax
  8018cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d3:	a8 40                	test   $0x40,%al
  8018d5:	74 16                	je     8018ed <fs_test+0x298>
  8018d7:	68 ed 42 80 00       	push   $0x8042ed
  8018dc:	68 1d 3d 80 00       	push   $0x803d1d
  8018e1:	6a 35                	push   $0x35
  8018e3:	68 cb 41 80 00       	push   $0x8041cb
  8018e8:	e8 a5 01 00 00       	call   801a92 <_panic>
	cprintf("file_truncate is good\n");
  8018ed:	83 ec 0c             	sub    $0xc,%esp
  8018f0:	68 07 43 80 00       	push   $0x804307
  8018f5:	e8 71 02 00 00       	call   801b6b <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8018fa:	c7 04 24 a0 43 80 00 	movl   $0x8043a0,(%esp)
  801901:	e8 b1 07 00 00       	call   8020b7 <strlen>
  801906:	83 c4 08             	add    $0x8,%esp
  801909:	50                   	push   %eax
  80190a:	ff 75 f4             	pushl  -0xc(%ebp)
  80190d:	e8 7c f3 ff ff       	call   800c8e <file_set_size>
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	85 c0                	test   %eax,%eax
  801917:	79 12                	jns    80192b <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801919:	50                   	push   %eax
  80191a:	68 1e 43 80 00       	push   $0x80431e
  80191f:	6a 39                	push   $0x39
  801921:	68 cb 41 80 00       	push   $0x8041cb
  801926:	e8 67 01 00 00       	call   801a92 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192e:	89 c2                	mov    %eax,%edx
  801930:	c1 ea 0c             	shr    $0xc,%edx
  801933:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80193a:	f6 c2 40             	test   $0x40,%dl
  80193d:	74 16                	je     801955 <fs_test+0x300>
  80193f:	68 ed 42 80 00       	push   $0x8042ed
  801944:	68 1d 3d 80 00       	push   $0x803d1d
  801949:	6a 3a                	push   $0x3a
  80194b:	68 cb 41 80 00       	push   $0x8041cb
  801950:	e8 3d 01 00 00       	call   801a92 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80195b:	52                   	push   %edx
  80195c:	6a 00                	push   $0x0
  80195e:	50                   	push   %eax
  80195f:	e8 ee ef ff ff       	call   800952 <file_get_block>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	79 12                	jns    80197d <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80196b:	50                   	push   %eax
  80196c:	68 32 43 80 00       	push   $0x804332
  801971:	6a 3c                	push   $0x3c
  801973:	68 cb 41 80 00       	push   $0x8041cb
  801978:	e8 15 01 00 00       	call   801a92 <_panic>
	strcpy(blk, msg);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	68 a0 43 80 00       	push   $0x8043a0
  801985:	ff 75 f0             	pushl  -0x10(%ebp)
  801988:	e8 63 07 00 00       	call   8020f0 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80198d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801990:	c1 e8 0c             	shr    $0xc,%eax
  801993:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	a8 40                	test   $0x40,%al
  80199f:	75 16                	jne    8019b7 <fs_test+0x362>
  8019a1:	68 98 42 80 00       	push   $0x804298
  8019a6:	68 1d 3d 80 00       	push   $0x803d1d
  8019ab:	6a 3e                	push   $0x3e
  8019ad:	68 cb 41 80 00       	push   $0x8041cb
  8019b2:	e8 db 00 00 00       	call   801a92 <_panic>
	file_flush(f);
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bd:	e8 53 f4 ff ff       	call   800e15 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c5:	c1 e8 0c             	shr    $0xc,%eax
  8019c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	a8 40                	test   $0x40,%al
  8019d4:	74 16                	je     8019ec <fs_test+0x397>
  8019d6:	68 97 42 80 00       	push   $0x804297
  8019db:	68 1d 3d 80 00       	push   $0x803d1d
  8019e0:	6a 40                	push   $0x40
  8019e2:	68 cb 41 80 00       	push   $0x8041cb
  8019e7:	e8 a6 00 00 00       	call   801a92 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ef:	c1 e8 0c             	shr    $0xc,%eax
  8019f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f9:	a8 40                	test   $0x40,%al
  8019fb:	74 16                	je     801a13 <fs_test+0x3be>
  8019fd:	68 ed 42 80 00       	push   $0x8042ed
  801a02:	68 1d 3d 80 00       	push   $0x803d1d
  801a07:	6a 41                	push   $0x41
  801a09:	68 cb 41 80 00       	push   $0x8041cb
  801a0e:	e8 7f 00 00 00       	call   801a92 <_panic>
	cprintf("file rewrite is good\n");
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	68 47 43 80 00       	push   $0x804347
  801a1b:	e8 4b 01 00 00       	call   801b6b <cprintf>
}
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a30:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  801a33:	c7 05 10 a0 80 00 00 	movl   $0x0,0x80a010
  801a3a:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  801a3d:	e8 73 0a 00 00       	call   8024b5 <sys_getenvid>
  801a42:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a47:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a4a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a4f:	a3 10 a0 80 00       	mov    %eax,0x80a010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a54:	85 db                	test   %ebx,%ebx
  801a56:	7e 07                	jle    801a5f <libmain+0x37>
		binaryname = argv[0];
  801a58:	8b 06                	mov    (%esi),%eax
  801a5a:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	e8 ab fb ff ff       	call   801614 <umain>

	// exit gracefully
	exit();
  801a69:	e8 0a 00 00 00       	call   801a78 <exit>
}
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801a7e:	e8 f9 0f 00 00       	call   802a7c <close_all>
	sys_env_destroy(0);
  801a83:	83 ec 0c             	sub    $0xc,%esp
  801a86:	6a 00                	push   $0x0
  801a88:	e8 e7 09 00 00       	call   802474 <sys_env_destroy>
}
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a97:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a9a:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801aa0:	e8 10 0a 00 00       	call   8024b5 <sys_getenvid>
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	ff 75 0c             	pushl  0xc(%ebp)
  801aab:	ff 75 08             	pushl  0x8(%ebp)
  801aae:	56                   	push   %esi
  801aaf:	50                   	push   %eax
  801ab0:	68 f8 43 80 00       	push   $0x8043f8
  801ab5:	e8 b1 00 00 00       	call   801b6b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801aba:	83 c4 18             	add    $0x18,%esp
  801abd:	53                   	push   %ebx
  801abe:	ff 75 10             	pushl  0x10(%ebp)
  801ac1:	e8 54 00 00 00       	call   801b1a <vcprintf>
	cprintf("\n");
  801ac6:	c7 04 24 c9 3e 80 00 	movl   $0x803ec9,(%esp)
  801acd:	e8 99 00 00 00       	call   801b6b <cprintf>
  801ad2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ad5:	cc                   	int3   
  801ad6:	eb fd                	jmp    801ad5 <_panic+0x43>

00801ad8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	53                   	push   %ebx
  801adc:	83 ec 04             	sub    $0x4,%esp
  801adf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801ae2:	8b 13                	mov    (%ebx),%edx
  801ae4:	8d 42 01             	lea    0x1(%edx),%eax
  801ae7:	89 03                	mov    %eax,(%ebx)
  801ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801af0:	3d ff 00 00 00       	cmp    $0xff,%eax
  801af5:	75 1a                	jne    801b11 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801af7:	83 ec 08             	sub    $0x8,%esp
  801afa:	68 ff 00 00 00       	push   $0xff
  801aff:	8d 43 08             	lea    0x8(%ebx),%eax
  801b02:	50                   	push   %eax
  801b03:	e8 2f 09 00 00       	call   802437 <sys_cputs>
		b->idx = 0;
  801b08:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b0e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b11:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b23:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b2a:	00 00 00 
	b.cnt = 0;
  801b2d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b34:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b37:	ff 75 0c             	pushl  0xc(%ebp)
  801b3a:	ff 75 08             	pushl  0x8(%ebp)
  801b3d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b43:	50                   	push   %eax
  801b44:	68 d8 1a 80 00       	push   $0x801ad8
  801b49:	e8 54 01 00 00       	call   801ca2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b4e:	83 c4 08             	add    $0x8,%esp
  801b51:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b57:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b5d:	50                   	push   %eax
  801b5e:	e8 d4 08 00 00       	call   802437 <sys_cputs>

	return b.cnt;
}
  801b63:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b71:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801b74:	50                   	push   %eax
  801b75:	ff 75 08             	pushl  0x8(%ebp)
  801b78:	e8 9d ff ff ff       	call   801b1a <vcprintf>
	va_end(ap);

	return cnt;
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	57                   	push   %edi
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 1c             	sub    $0x1c,%esp
  801b88:	89 c7                	mov    %eax,%edi
  801b8a:	89 d6                	mov    %edx,%esi
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b92:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b95:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801b98:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801ba3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801ba6:	39 d3                	cmp    %edx,%ebx
  801ba8:	72 05                	jb     801baf <printnum+0x30>
  801baa:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bad:	77 45                	ja     801bf4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801baf:	83 ec 0c             	sub    $0xc,%esp
  801bb2:	ff 75 18             	pushl  0x18(%ebp)
  801bb5:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bbb:	53                   	push   %ebx
  801bbc:	ff 75 10             	pushl  0x10(%ebp)
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bc5:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc8:	ff 75 dc             	pushl  -0x24(%ebp)
  801bcb:	ff 75 d8             	pushl  -0x28(%ebp)
  801bce:	e8 7d 1e 00 00       	call   803a50 <__udivdi3>
  801bd3:	83 c4 18             	add    $0x18,%esp
  801bd6:	52                   	push   %edx
  801bd7:	50                   	push   %eax
  801bd8:	89 f2                	mov    %esi,%edx
  801bda:	89 f8                	mov    %edi,%eax
  801bdc:	e8 9e ff ff ff       	call   801b7f <printnum>
  801be1:	83 c4 20             	add    $0x20,%esp
  801be4:	eb 18                	jmp    801bfe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801be6:	83 ec 08             	sub    $0x8,%esp
  801be9:	56                   	push   %esi
  801bea:	ff 75 18             	pushl  0x18(%ebp)
  801bed:	ff d7                	call   *%edi
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	eb 03                	jmp    801bf7 <printnum+0x78>
  801bf4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801bf7:	83 eb 01             	sub    $0x1,%ebx
  801bfa:	85 db                	test   %ebx,%ebx
  801bfc:	7f e8                	jg     801be6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801bfe:	83 ec 08             	sub    $0x8,%esp
  801c01:	56                   	push   %esi
  801c02:	83 ec 04             	sub    $0x4,%esp
  801c05:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c08:	ff 75 e0             	pushl  -0x20(%ebp)
  801c0b:	ff 75 dc             	pushl  -0x24(%ebp)
  801c0e:	ff 75 d8             	pushl  -0x28(%ebp)
  801c11:	e8 6a 1f 00 00       	call   803b80 <__umoddi3>
  801c16:	83 c4 14             	add    $0x14,%esp
  801c19:	0f be 80 1b 44 80 00 	movsbl 0x80441b(%eax),%eax
  801c20:	50                   	push   %eax
  801c21:	ff d7                	call   *%edi
}
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c29:	5b                   	pop    %ebx
  801c2a:	5e                   	pop    %esi
  801c2b:	5f                   	pop    %edi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c31:	83 fa 01             	cmp    $0x1,%edx
  801c34:	7e 0e                	jle    801c44 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c36:	8b 10                	mov    (%eax),%edx
  801c38:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c3b:	89 08                	mov    %ecx,(%eax)
  801c3d:	8b 02                	mov    (%edx),%eax
  801c3f:	8b 52 04             	mov    0x4(%edx),%edx
  801c42:	eb 22                	jmp    801c66 <getuint+0x38>
	else if (lflag)
  801c44:	85 d2                	test   %edx,%edx
  801c46:	74 10                	je     801c58 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c48:	8b 10                	mov    (%eax),%edx
  801c4a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c4d:	89 08                	mov    %ecx,(%eax)
  801c4f:	8b 02                	mov    (%edx),%eax
  801c51:	ba 00 00 00 00       	mov    $0x0,%edx
  801c56:	eb 0e                	jmp    801c66 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801c58:	8b 10                	mov    (%eax),%edx
  801c5a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c5d:	89 08                	mov    %ecx,(%eax)
  801c5f:	8b 02                	mov    (%edx),%eax
  801c61:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c6e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c72:	8b 10                	mov    (%eax),%edx
  801c74:	3b 50 04             	cmp    0x4(%eax),%edx
  801c77:	73 0a                	jae    801c83 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c79:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c7c:	89 08                	mov    %ecx,(%eax)
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	88 02                	mov    %al,(%edx)
}
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801c8b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801c8e:	50                   	push   %eax
  801c8f:	ff 75 10             	pushl  0x10(%ebp)
  801c92:	ff 75 0c             	pushl  0xc(%ebp)
  801c95:	ff 75 08             	pushl  0x8(%ebp)
  801c98:	e8 05 00 00 00       	call   801ca2 <vprintfmt>
	va_end(ap);
}
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 2c             	sub    $0x2c,%esp
  801cab:	8b 75 08             	mov    0x8(%ebp),%esi
  801cae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cb1:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cb4:	eb 12                	jmp    801cc8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	0f 84 89 03 00 00    	je     802047 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801cbe:	83 ec 08             	sub    $0x8,%esp
  801cc1:	53                   	push   %ebx
  801cc2:	50                   	push   %eax
  801cc3:	ff d6                	call   *%esi
  801cc5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801cc8:	83 c7 01             	add    $0x1,%edi
  801ccb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ccf:	83 f8 25             	cmp    $0x25,%eax
  801cd2:	75 e2                	jne    801cb6 <vprintfmt+0x14>
  801cd4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801cd8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801cdf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801ce6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801ced:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf2:	eb 07                	jmp    801cfb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cf4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801cf7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cfb:	8d 47 01             	lea    0x1(%edi),%eax
  801cfe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d01:	0f b6 07             	movzbl (%edi),%eax
  801d04:	0f b6 c8             	movzbl %al,%ecx
  801d07:	83 e8 23             	sub    $0x23,%eax
  801d0a:	3c 55                	cmp    $0x55,%al
  801d0c:	0f 87 1a 03 00 00    	ja     80202c <vprintfmt+0x38a>
  801d12:	0f b6 c0             	movzbl %al,%eax
  801d15:	ff 24 85 60 45 80 00 	jmp    *0x804560(,%eax,4)
  801d1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d1f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d23:	eb d6                	jmp    801cfb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d30:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d33:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801d37:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801d3a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801d3d:	83 fa 09             	cmp    $0x9,%edx
  801d40:	77 39                	ja     801d7b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d42:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d45:	eb e9                	jmp    801d30 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d47:	8b 45 14             	mov    0x14(%ebp),%eax
  801d4a:	8d 48 04             	lea    0x4(%eax),%ecx
  801d4d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801d50:	8b 00                	mov    (%eax),%eax
  801d52:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d58:	eb 27                	jmp    801d81 <vprintfmt+0xdf>
  801d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d64:	0f 49 c8             	cmovns %eax,%ecx
  801d67:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d6d:	eb 8c                	jmp    801cfb <vprintfmt+0x59>
  801d6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801d72:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801d79:	eb 80                	jmp    801cfb <vprintfmt+0x59>
  801d7b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d7e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801d81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d85:	0f 89 70 ff ff ff    	jns    801cfb <vprintfmt+0x59>
				width = precision, precision = -1;
  801d8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801d8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d91:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d98:	e9 5e ff ff ff       	jmp    801cfb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801d9d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801da3:	e9 53 ff ff ff       	jmp    801cfb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801da8:	8b 45 14             	mov    0x14(%ebp),%eax
  801dab:	8d 50 04             	lea    0x4(%eax),%edx
  801dae:	89 55 14             	mov    %edx,0x14(%ebp)
  801db1:	83 ec 08             	sub    $0x8,%esp
  801db4:	53                   	push   %ebx
  801db5:	ff 30                	pushl  (%eax)
  801db7:	ff d6                	call   *%esi
			break;
  801db9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dbc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801dbf:	e9 04 ff ff ff       	jmp    801cc8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801dc4:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc7:	8d 50 04             	lea    0x4(%eax),%edx
  801dca:	89 55 14             	mov    %edx,0x14(%ebp)
  801dcd:	8b 00                	mov    (%eax),%eax
  801dcf:	99                   	cltd   
  801dd0:	31 d0                	xor    %edx,%eax
  801dd2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801dd4:	83 f8 0f             	cmp    $0xf,%eax
  801dd7:	7f 0b                	jg     801de4 <vprintfmt+0x142>
  801dd9:	8b 14 85 c0 46 80 00 	mov    0x8046c0(,%eax,4),%edx
  801de0:	85 d2                	test   %edx,%edx
  801de2:	75 18                	jne    801dfc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801de4:	50                   	push   %eax
  801de5:	68 33 44 80 00       	push   $0x804433
  801dea:	53                   	push   %ebx
  801deb:	56                   	push   %esi
  801dec:	e8 94 fe ff ff       	call   801c85 <printfmt>
  801df1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801df4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801df7:	e9 cc fe ff ff       	jmp    801cc8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801dfc:	52                   	push   %edx
  801dfd:	68 2f 3d 80 00       	push   $0x803d2f
  801e02:	53                   	push   %ebx
  801e03:	56                   	push   %esi
  801e04:	e8 7c fe ff ff       	call   801c85 <printfmt>
  801e09:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e0f:	e9 b4 fe ff ff       	jmp    801cc8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e14:	8b 45 14             	mov    0x14(%ebp),%eax
  801e17:	8d 50 04             	lea    0x4(%eax),%edx
  801e1a:	89 55 14             	mov    %edx,0x14(%ebp)
  801e1d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e1f:	85 ff                	test   %edi,%edi
  801e21:	b8 2c 44 80 00       	mov    $0x80442c,%eax
  801e26:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e2d:	0f 8e 94 00 00 00    	jle    801ec7 <vprintfmt+0x225>
  801e33:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e37:	0f 84 98 00 00 00    	je     801ed5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	ff 75 d0             	pushl  -0x30(%ebp)
  801e43:	57                   	push   %edi
  801e44:	e8 86 02 00 00       	call   8020cf <strnlen>
  801e49:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e4c:	29 c1                	sub    %eax,%ecx
  801e4e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801e51:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e54:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e5b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e5e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e60:	eb 0f                	jmp    801e71 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801e62:	83 ec 08             	sub    $0x8,%esp
  801e65:	53                   	push   %ebx
  801e66:	ff 75 e0             	pushl  -0x20(%ebp)
  801e69:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e6b:	83 ef 01             	sub    $0x1,%edi
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 ff                	test   %edi,%edi
  801e73:	7f ed                	jg     801e62 <vprintfmt+0x1c0>
  801e75:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801e78:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e7b:	85 c9                	test   %ecx,%ecx
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e82:	0f 49 c1             	cmovns %ecx,%eax
  801e85:	29 c1                	sub    %eax,%ecx
  801e87:	89 75 08             	mov    %esi,0x8(%ebp)
  801e8a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e8d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e90:	89 cb                	mov    %ecx,%ebx
  801e92:	eb 4d                	jmp    801ee1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801e94:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801e98:	74 1b                	je     801eb5 <vprintfmt+0x213>
  801e9a:	0f be c0             	movsbl %al,%eax
  801e9d:	83 e8 20             	sub    $0x20,%eax
  801ea0:	83 f8 5e             	cmp    $0x5e,%eax
  801ea3:	76 10                	jbe    801eb5 <vprintfmt+0x213>
					putch('?', putdat);
  801ea5:	83 ec 08             	sub    $0x8,%esp
  801ea8:	ff 75 0c             	pushl  0xc(%ebp)
  801eab:	6a 3f                	push   $0x3f
  801ead:	ff 55 08             	call   *0x8(%ebp)
  801eb0:	83 c4 10             	add    $0x10,%esp
  801eb3:	eb 0d                	jmp    801ec2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801eb5:	83 ec 08             	sub    $0x8,%esp
  801eb8:	ff 75 0c             	pushl  0xc(%ebp)
  801ebb:	52                   	push   %edx
  801ebc:	ff 55 08             	call   *0x8(%ebp)
  801ebf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ec2:	83 eb 01             	sub    $0x1,%ebx
  801ec5:	eb 1a                	jmp    801ee1 <vprintfmt+0x23f>
  801ec7:	89 75 08             	mov    %esi,0x8(%ebp)
  801eca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ecd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ed0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ed3:	eb 0c                	jmp    801ee1 <vprintfmt+0x23f>
  801ed5:	89 75 08             	mov    %esi,0x8(%ebp)
  801ed8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801edb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ede:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ee1:	83 c7 01             	add    $0x1,%edi
  801ee4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ee8:	0f be d0             	movsbl %al,%edx
  801eeb:	85 d2                	test   %edx,%edx
  801eed:	74 23                	je     801f12 <vprintfmt+0x270>
  801eef:	85 f6                	test   %esi,%esi
  801ef1:	78 a1                	js     801e94 <vprintfmt+0x1f2>
  801ef3:	83 ee 01             	sub    $0x1,%esi
  801ef6:	79 9c                	jns    801e94 <vprintfmt+0x1f2>
  801ef8:	89 df                	mov    %ebx,%edi
  801efa:	8b 75 08             	mov    0x8(%ebp),%esi
  801efd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f00:	eb 18                	jmp    801f1a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f02:	83 ec 08             	sub    $0x8,%esp
  801f05:	53                   	push   %ebx
  801f06:	6a 20                	push   $0x20
  801f08:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f0a:	83 ef 01             	sub    $0x1,%edi
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	eb 08                	jmp    801f1a <vprintfmt+0x278>
  801f12:	89 df                	mov    %ebx,%edi
  801f14:	8b 75 08             	mov    0x8(%ebp),%esi
  801f17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f1a:	85 ff                	test   %edi,%edi
  801f1c:	7f e4                	jg     801f02 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f21:	e9 a2 fd ff ff       	jmp    801cc8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f26:	83 fa 01             	cmp    $0x1,%edx
  801f29:	7e 16                	jle    801f41 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801f2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2e:	8d 50 08             	lea    0x8(%eax),%edx
  801f31:	89 55 14             	mov    %edx,0x14(%ebp)
  801f34:	8b 50 04             	mov    0x4(%eax),%edx
  801f37:	8b 00                	mov    (%eax),%eax
  801f39:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f3c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f3f:	eb 32                	jmp    801f73 <vprintfmt+0x2d1>
	else if (lflag)
  801f41:	85 d2                	test   %edx,%edx
  801f43:	74 18                	je     801f5d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801f45:	8b 45 14             	mov    0x14(%ebp),%eax
  801f48:	8d 50 04             	lea    0x4(%eax),%edx
  801f4b:	89 55 14             	mov    %edx,0x14(%ebp)
  801f4e:	8b 00                	mov    (%eax),%eax
  801f50:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f53:	89 c1                	mov    %eax,%ecx
  801f55:	c1 f9 1f             	sar    $0x1f,%ecx
  801f58:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f5b:	eb 16                	jmp    801f73 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801f5d:	8b 45 14             	mov    0x14(%ebp),%eax
  801f60:	8d 50 04             	lea    0x4(%eax),%edx
  801f63:	89 55 14             	mov    %edx,0x14(%ebp)
  801f66:	8b 00                	mov    (%eax),%eax
  801f68:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f6b:	89 c1                	mov    %eax,%ecx
  801f6d:	c1 f9 1f             	sar    $0x1f,%ecx
  801f70:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f73:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f76:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801f79:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801f7e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f82:	79 74                	jns    801ff8 <vprintfmt+0x356>
				putch('-', putdat);
  801f84:	83 ec 08             	sub    $0x8,%esp
  801f87:	53                   	push   %ebx
  801f88:	6a 2d                	push   $0x2d
  801f8a:	ff d6                	call   *%esi
				num = -(long long) num;
  801f8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801f92:	f7 d8                	neg    %eax
  801f94:	83 d2 00             	adc    $0x0,%edx
  801f97:	f7 da                	neg    %edx
  801f99:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801f9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801fa1:	eb 55                	jmp    801ff8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801fa3:	8d 45 14             	lea    0x14(%ebp),%eax
  801fa6:	e8 83 fc ff ff       	call   801c2e <getuint>
			base = 10;
  801fab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801fb0:	eb 46                	jmp    801ff8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801fb2:	8d 45 14             	lea    0x14(%ebp),%eax
  801fb5:	e8 74 fc ff ff       	call   801c2e <getuint>
		        base = 8;
  801fba:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801fbf:	eb 37                	jmp    801ff8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801fc1:	83 ec 08             	sub    $0x8,%esp
  801fc4:	53                   	push   %ebx
  801fc5:	6a 30                	push   $0x30
  801fc7:	ff d6                	call   *%esi
			putch('x', putdat);
  801fc9:	83 c4 08             	add    $0x8,%esp
  801fcc:	53                   	push   %ebx
  801fcd:	6a 78                	push   $0x78
  801fcf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801fd1:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd4:	8d 50 04             	lea    0x4(%eax),%edx
  801fd7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801fda:	8b 00                	mov    (%eax),%eax
  801fdc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801fe1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801fe4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801fe9:	eb 0d                	jmp    801ff8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801feb:	8d 45 14             	lea    0x14(%ebp),%eax
  801fee:	e8 3b fc ff ff       	call   801c2e <getuint>
			base = 16;
  801ff3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ff8:	83 ec 0c             	sub    $0xc,%esp
  801ffb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801fff:	57                   	push   %edi
  802000:	ff 75 e0             	pushl  -0x20(%ebp)
  802003:	51                   	push   %ecx
  802004:	52                   	push   %edx
  802005:	50                   	push   %eax
  802006:	89 da                	mov    %ebx,%edx
  802008:	89 f0                	mov    %esi,%eax
  80200a:	e8 70 fb ff ff       	call   801b7f <printnum>
			break;
  80200f:	83 c4 20             	add    $0x20,%esp
  802012:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802015:	e9 ae fc ff ff       	jmp    801cc8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80201a:	83 ec 08             	sub    $0x8,%esp
  80201d:	53                   	push   %ebx
  80201e:	51                   	push   %ecx
  80201f:	ff d6                	call   *%esi
			break;
  802021:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802024:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  802027:	e9 9c fc ff ff       	jmp    801cc8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80202c:	83 ec 08             	sub    $0x8,%esp
  80202f:	53                   	push   %ebx
  802030:	6a 25                	push   $0x25
  802032:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	eb 03                	jmp    80203c <vprintfmt+0x39a>
  802039:	83 ef 01             	sub    $0x1,%edi
  80203c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802040:	75 f7                	jne    802039 <vprintfmt+0x397>
  802042:	e9 81 fc ff ff       	jmp    801cc8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  802047:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5e                   	pop    %esi
  80204c:	5f                   	pop    %edi
  80204d:	5d                   	pop    %ebp
  80204e:	c3                   	ret    

0080204f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	83 ec 18             	sub    $0x18,%esp
  802055:	8b 45 08             	mov    0x8(%ebp),%eax
  802058:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80205b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80205e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802062:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802065:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80206c:	85 c0                	test   %eax,%eax
  80206e:	74 26                	je     802096 <vsnprintf+0x47>
  802070:	85 d2                	test   %edx,%edx
  802072:	7e 22                	jle    802096 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802074:	ff 75 14             	pushl  0x14(%ebp)
  802077:	ff 75 10             	pushl  0x10(%ebp)
  80207a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80207d:	50                   	push   %eax
  80207e:	68 68 1c 80 00       	push   $0x801c68
  802083:	e8 1a fc ff ff       	call   801ca2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802088:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80208b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80208e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802091:	83 c4 10             	add    $0x10,%esp
  802094:	eb 05                	jmp    80209b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802096:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80209b:	c9                   	leave  
  80209c:	c3                   	ret    

0080209d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8020a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8020a6:	50                   	push   %eax
  8020a7:	ff 75 10             	pushl  0x10(%ebp)
  8020aa:	ff 75 0c             	pushl  0xc(%ebp)
  8020ad:	ff 75 08             	pushl  0x8(%ebp)
  8020b0:	e8 9a ff ff ff       	call   80204f <vsnprintf>
	va_end(ap);

	return rc;
}
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8020bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c2:	eb 03                	jmp    8020c7 <strlen+0x10>
		n++;
  8020c4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8020c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8020cb:	75 f7                	jne    8020c4 <strlen+0xd>
		n++;
	return n;
}
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    

008020cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8020cf:	55                   	push   %ebp
  8020d0:	89 e5                	mov    %esp,%ebp
  8020d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8020dd:	eb 03                	jmp    8020e2 <strnlen+0x13>
		n++;
  8020df:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020e2:	39 c2                	cmp    %eax,%edx
  8020e4:	74 08                	je     8020ee <strnlen+0x1f>
  8020e6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8020ea:	75 f3                	jne    8020df <strnlen+0x10>
  8020ec:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    

008020f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	53                   	push   %ebx
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8020fa:	89 c2                	mov    %eax,%edx
  8020fc:	83 c2 01             	add    $0x1,%edx
  8020ff:	83 c1 01             	add    $0x1,%ecx
  802102:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  802106:	88 5a ff             	mov    %bl,-0x1(%edx)
  802109:	84 db                	test   %bl,%bl
  80210b:	75 ef                	jne    8020fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80210d:	5b                   	pop    %ebx
  80210e:	5d                   	pop    %ebp
  80210f:	c3                   	ret    

00802110 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	53                   	push   %ebx
  802114:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802117:	53                   	push   %ebx
  802118:	e8 9a ff ff ff       	call   8020b7 <strlen>
  80211d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802120:	ff 75 0c             	pushl  0xc(%ebp)
  802123:	01 d8                	add    %ebx,%eax
  802125:	50                   	push   %eax
  802126:	e8 c5 ff ff ff       	call   8020f0 <strcpy>
	return dst;
}
  80212b:	89 d8                	mov    %ebx,%eax
  80212d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	56                   	push   %esi
  802136:	53                   	push   %ebx
  802137:	8b 75 08             	mov    0x8(%ebp),%esi
  80213a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80213d:	89 f3                	mov    %esi,%ebx
  80213f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802142:	89 f2                	mov    %esi,%edx
  802144:	eb 0f                	jmp    802155 <strncpy+0x23>
		*dst++ = *src;
  802146:	83 c2 01             	add    $0x1,%edx
  802149:	0f b6 01             	movzbl (%ecx),%eax
  80214c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80214f:	80 39 01             	cmpb   $0x1,(%ecx)
  802152:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802155:	39 da                	cmp    %ebx,%edx
  802157:	75 ed                	jne    802146 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802159:	89 f0                	mov    %esi,%eax
  80215b:	5b                   	pop    %ebx
  80215c:	5e                   	pop    %esi
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	8b 75 08             	mov    0x8(%ebp),%esi
  802167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80216a:	8b 55 10             	mov    0x10(%ebp),%edx
  80216d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80216f:	85 d2                	test   %edx,%edx
  802171:	74 21                	je     802194 <strlcpy+0x35>
  802173:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802177:	89 f2                	mov    %esi,%edx
  802179:	eb 09                	jmp    802184 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80217b:	83 c2 01             	add    $0x1,%edx
  80217e:	83 c1 01             	add    $0x1,%ecx
  802181:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802184:	39 c2                	cmp    %eax,%edx
  802186:	74 09                	je     802191 <strlcpy+0x32>
  802188:	0f b6 19             	movzbl (%ecx),%ebx
  80218b:	84 db                	test   %bl,%bl
  80218d:	75 ec                	jne    80217b <strlcpy+0x1c>
  80218f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802191:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802194:	29 f0                	sub    %esi,%eax
}
  802196:	5b                   	pop    %ebx
  802197:	5e                   	pop    %esi
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    

0080219a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8021a3:	eb 06                	jmp    8021ab <strcmp+0x11>
		p++, q++;
  8021a5:	83 c1 01             	add    $0x1,%ecx
  8021a8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8021ab:	0f b6 01             	movzbl (%ecx),%eax
  8021ae:	84 c0                	test   %al,%al
  8021b0:	74 04                	je     8021b6 <strcmp+0x1c>
  8021b2:	3a 02                	cmp    (%edx),%al
  8021b4:	74 ef                	je     8021a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8021b6:	0f b6 c0             	movzbl %al,%eax
  8021b9:	0f b6 12             	movzbl (%edx),%edx
  8021bc:	29 d0                	sub    %edx,%eax
}
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    

008021c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	53                   	push   %ebx
  8021c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8021cf:	eb 06                	jmp    8021d7 <strncmp+0x17>
		n--, p++, q++;
  8021d1:	83 c0 01             	add    $0x1,%eax
  8021d4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8021d7:	39 d8                	cmp    %ebx,%eax
  8021d9:	74 15                	je     8021f0 <strncmp+0x30>
  8021db:	0f b6 08             	movzbl (%eax),%ecx
  8021de:	84 c9                	test   %cl,%cl
  8021e0:	74 04                	je     8021e6 <strncmp+0x26>
  8021e2:	3a 0a                	cmp    (%edx),%cl
  8021e4:	74 eb                	je     8021d1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8021e6:	0f b6 00             	movzbl (%eax),%eax
  8021e9:	0f b6 12             	movzbl (%edx),%edx
  8021ec:	29 d0                	sub    %edx,%eax
  8021ee:	eb 05                	jmp    8021f5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8021f0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8021f5:	5b                   	pop    %ebx
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    

008021f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802202:	eb 07                	jmp    80220b <strchr+0x13>
		if (*s == c)
  802204:	38 ca                	cmp    %cl,%dl
  802206:	74 0f                	je     802217 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802208:	83 c0 01             	add    $0x1,%eax
  80220b:	0f b6 10             	movzbl (%eax),%edx
  80220e:	84 d2                	test   %dl,%dl
  802210:	75 f2                	jne    802204 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802212:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    

00802219 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	8b 45 08             	mov    0x8(%ebp),%eax
  80221f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802223:	eb 03                	jmp    802228 <strfind+0xf>
  802225:	83 c0 01             	add    $0x1,%eax
  802228:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80222b:	38 ca                	cmp    %cl,%dl
  80222d:	74 04                	je     802233 <strfind+0x1a>
  80222f:	84 d2                	test   %dl,%dl
  802231:	75 f2                	jne    802225 <strfind+0xc>
			break;
	return (char *) s;
}
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	57                   	push   %edi
  802239:	56                   	push   %esi
  80223a:	53                   	push   %ebx
  80223b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80223e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802241:	85 c9                	test   %ecx,%ecx
  802243:	74 36                	je     80227b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802245:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80224b:	75 28                	jne    802275 <memset+0x40>
  80224d:	f6 c1 03             	test   $0x3,%cl
  802250:	75 23                	jne    802275 <memset+0x40>
		c &= 0xFF;
  802252:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802256:	89 d3                	mov    %edx,%ebx
  802258:	c1 e3 08             	shl    $0x8,%ebx
  80225b:	89 d6                	mov    %edx,%esi
  80225d:	c1 e6 18             	shl    $0x18,%esi
  802260:	89 d0                	mov    %edx,%eax
  802262:	c1 e0 10             	shl    $0x10,%eax
  802265:	09 f0                	or     %esi,%eax
  802267:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802269:	89 d8                	mov    %ebx,%eax
  80226b:	09 d0                	or     %edx,%eax
  80226d:	c1 e9 02             	shr    $0x2,%ecx
  802270:	fc                   	cld    
  802271:	f3 ab                	rep stos %eax,%es:(%edi)
  802273:	eb 06                	jmp    80227b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802275:	8b 45 0c             	mov    0xc(%ebp),%eax
  802278:	fc                   	cld    
  802279:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80227b:	89 f8                	mov    %edi,%eax
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    

00802282 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	57                   	push   %edi
  802286:	56                   	push   %esi
  802287:	8b 45 08             	mov    0x8(%ebp),%eax
  80228a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80228d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802290:	39 c6                	cmp    %eax,%esi
  802292:	73 35                	jae    8022c9 <memmove+0x47>
  802294:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802297:	39 d0                	cmp    %edx,%eax
  802299:	73 2e                	jae    8022c9 <memmove+0x47>
		s += n;
		d += n;
  80229b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80229e:	89 d6                	mov    %edx,%esi
  8022a0:	09 fe                	or     %edi,%esi
  8022a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8022a8:	75 13                	jne    8022bd <memmove+0x3b>
  8022aa:	f6 c1 03             	test   $0x3,%cl
  8022ad:	75 0e                	jne    8022bd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8022af:	83 ef 04             	sub    $0x4,%edi
  8022b2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8022b5:	c1 e9 02             	shr    $0x2,%ecx
  8022b8:	fd                   	std    
  8022b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022bb:	eb 09                	jmp    8022c6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8022bd:	83 ef 01             	sub    $0x1,%edi
  8022c0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8022c3:	fd                   	std    
  8022c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8022c6:	fc                   	cld    
  8022c7:	eb 1d                	jmp    8022e6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022c9:	89 f2                	mov    %esi,%edx
  8022cb:	09 c2                	or     %eax,%edx
  8022cd:	f6 c2 03             	test   $0x3,%dl
  8022d0:	75 0f                	jne    8022e1 <memmove+0x5f>
  8022d2:	f6 c1 03             	test   $0x3,%cl
  8022d5:	75 0a                	jne    8022e1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8022d7:	c1 e9 02             	shr    $0x2,%ecx
  8022da:	89 c7                	mov    %eax,%edi
  8022dc:	fc                   	cld    
  8022dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022df:	eb 05                	jmp    8022e6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8022e1:	89 c7                	mov    %eax,%edi
  8022e3:	fc                   	cld    
  8022e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8022ed:	ff 75 10             	pushl  0x10(%ebp)
  8022f0:	ff 75 0c             	pushl  0xc(%ebp)
  8022f3:	ff 75 08             	pushl  0x8(%ebp)
  8022f6:	e8 87 ff ff ff       	call   802282 <memmove>
}
  8022fb:	c9                   	leave  
  8022fc:	c3                   	ret    

008022fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	56                   	push   %esi
  802301:	53                   	push   %ebx
  802302:	8b 45 08             	mov    0x8(%ebp),%eax
  802305:	8b 55 0c             	mov    0xc(%ebp),%edx
  802308:	89 c6                	mov    %eax,%esi
  80230a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80230d:	eb 1a                	jmp    802329 <memcmp+0x2c>
		if (*s1 != *s2)
  80230f:	0f b6 08             	movzbl (%eax),%ecx
  802312:	0f b6 1a             	movzbl (%edx),%ebx
  802315:	38 d9                	cmp    %bl,%cl
  802317:	74 0a                	je     802323 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802319:	0f b6 c1             	movzbl %cl,%eax
  80231c:	0f b6 db             	movzbl %bl,%ebx
  80231f:	29 d8                	sub    %ebx,%eax
  802321:	eb 0f                	jmp    802332 <memcmp+0x35>
		s1++, s2++;
  802323:	83 c0 01             	add    $0x1,%eax
  802326:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802329:	39 f0                	cmp    %esi,%eax
  80232b:	75 e2                	jne    80230f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80232d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802332:	5b                   	pop    %ebx
  802333:	5e                   	pop    %esi
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    

00802336 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	53                   	push   %ebx
  80233a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80233d:	89 c1                	mov    %eax,%ecx
  80233f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802342:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802346:	eb 0a                	jmp    802352 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802348:	0f b6 10             	movzbl (%eax),%edx
  80234b:	39 da                	cmp    %ebx,%edx
  80234d:	74 07                	je     802356 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80234f:	83 c0 01             	add    $0x1,%eax
  802352:	39 c8                	cmp    %ecx,%eax
  802354:	72 f2                	jb     802348 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802356:	5b                   	pop    %ebx
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    

00802359 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	57                   	push   %edi
  80235d:	56                   	push   %esi
  80235e:	53                   	push   %ebx
  80235f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802362:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802365:	eb 03                	jmp    80236a <strtol+0x11>
		s++;
  802367:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80236a:	0f b6 01             	movzbl (%ecx),%eax
  80236d:	3c 20                	cmp    $0x20,%al
  80236f:	74 f6                	je     802367 <strtol+0xe>
  802371:	3c 09                	cmp    $0x9,%al
  802373:	74 f2                	je     802367 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802375:	3c 2b                	cmp    $0x2b,%al
  802377:	75 0a                	jne    802383 <strtol+0x2a>
		s++;
  802379:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80237c:	bf 00 00 00 00       	mov    $0x0,%edi
  802381:	eb 11                	jmp    802394 <strtol+0x3b>
  802383:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802388:	3c 2d                	cmp    $0x2d,%al
  80238a:	75 08                	jne    802394 <strtol+0x3b>
		s++, neg = 1;
  80238c:	83 c1 01             	add    $0x1,%ecx
  80238f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802394:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80239a:	75 15                	jne    8023b1 <strtol+0x58>
  80239c:	80 39 30             	cmpb   $0x30,(%ecx)
  80239f:	75 10                	jne    8023b1 <strtol+0x58>
  8023a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8023a5:	75 7c                	jne    802423 <strtol+0xca>
		s += 2, base = 16;
  8023a7:	83 c1 02             	add    $0x2,%ecx
  8023aa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8023af:	eb 16                	jmp    8023c7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8023b1:	85 db                	test   %ebx,%ebx
  8023b3:	75 12                	jne    8023c7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8023b5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8023ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8023bd:	75 08                	jne    8023c7 <strtol+0x6e>
		s++, base = 8;
  8023bf:	83 c1 01             	add    $0x1,%ecx
  8023c2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8023c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8023cc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8023cf:	0f b6 11             	movzbl (%ecx),%edx
  8023d2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8023d5:	89 f3                	mov    %esi,%ebx
  8023d7:	80 fb 09             	cmp    $0x9,%bl
  8023da:	77 08                	ja     8023e4 <strtol+0x8b>
			dig = *s - '0';
  8023dc:	0f be d2             	movsbl %dl,%edx
  8023df:	83 ea 30             	sub    $0x30,%edx
  8023e2:	eb 22                	jmp    802406 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8023e4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8023e7:	89 f3                	mov    %esi,%ebx
  8023e9:	80 fb 19             	cmp    $0x19,%bl
  8023ec:	77 08                	ja     8023f6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8023ee:	0f be d2             	movsbl %dl,%edx
  8023f1:	83 ea 57             	sub    $0x57,%edx
  8023f4:	eb 10                	jmp    802406 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8023f6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8023f9:	89 f3                	mov    %esi,%ebx
  8023fb:	80 fb 19             	cmp    $0x19,%bl
  8023fe:	77 16                	ja     802416 <strtol+0xbd>
			dig = *s - 'A' + 10;
  802400:	0f be d2             	movsbl %dl,%edx
  802403:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  802406:	3b 55 10             	cmp    0x10(%ebp),%edx
  802409:	7d 0b                	jge    802416 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80240b:	83 c1 01             	add    $0x1,%ecx
  80240e:	0f af 45 10          	imul   0x10(%ebp),%eax
  802412:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802414:	eb b9                	jmp    8023cf <strtol+0x76>

	if (endptr)
  802416:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80241a:	74 0d                	je     802429 <strtol+0xd0>
		*endptr = (char *) s;
  80241c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80241f:	89 0e                	mov    %ecx,(%esi)
  802421:	eb 06                	jmp    802429 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802423:	85 db                	test   %ebx,%ebx
  802425:	74 98                	je     8023bf <strtol+0x66>
  802427:	eb 9e                	jmp    8023c7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802429:	89 c2                	mov    %eax,%edx
  80242b:	f7 da                	neg    %edx
  80242d:	85 ff                	test   %edi,%edi
  80242f:	0f 45 c2             	cmovne %edx,%eax
}
  802432:	5b                   	pop    %ebx
  802433:	5e                   	pop    %esi
  802434:	5f                   	pop    %edi
  802435:	5d                   	pop    %ebp
  802436:	c3                   	ret    

00802437 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	57                   	push   %edi
  80243b:	56                   	push   %esi
  80243c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80243d:	b8 00 00 00 00       	mov    $0x0,%eax
  802442:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802445:	8b 55 08             	mov    0x8(%ebp),%edx
  802448:	89 c3                	mov    %eax,%ebx
  80244a:	89 c7                	mov    %eax,%edi
  80244c:	89 c6                	mov    %eax,%esi
  80244e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802450:	5b                   	pop    %ebx
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    

00802455 <sys_cgetc>:

int
sys_cgetc(void)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	57                   	push   %edi
  802459:	56                   	push   %esi
  80245a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80245b:	ba 00 00 00 00       	mov    $0x0,%edx
  802460:	b8 01 00 00 00       	mov    $0x1,%eax
  802465:	89 d1                	mov    %edx,%ecx
  802467:	89 d3                	mov    %edx,%ebx
  802469:	89 d7                	mov    %edx,%edi
  80246b:	89 d6                	mov    %edx,%esi
  80246d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80246f:	5b                   	pop    %ebx
  802470:	5e                   	pop    %esi
  802471:	5f                   	pop    %edi
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    

00802474 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802474:	55                   	push   %ebp
  802475:	89 e5                	mov    %esp,%ebp
  802477:	57                   	push   %edi
  802478:	56                   	push   %esi
  802479:	53                   	push   %ebx
  80247a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80247d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802482:	b8 03 00 00 00       	mov    $0x3,%eax
  802487:	8b 55 08             	mov    0x8(%ebp),%edx
  80248a:	89 cb                	mov    %ecx,%ebx
  80248c:	89 cf                	mov    %ecx,%edi
  80248e:	89 ce                	mov    %ecx,%esi
  802490:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802492:	85 c0                	test   %eax,%eax
  802494:	7e 17                	jle    8024ad <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802496:	83 ec 0c             	sub    $0xc,%esp
  802499:	50                   	push   %eax
  80249a:	6a 03                	push   $0x3
  80249c:	68 1f 47 80 00       	push   $0x80471f
  8024a1:	6a 23                	push   $0x23
  8024a3:	68 3c 47 80 00       	push   $0x80473c
  8024a8:	e8 e5 f5 ff ff       	call   801a92 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8024ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b0:	5b                   	pop    %ebx
  8024b1:	5e                   	pop    %esi
  8024b2:	5f                   	pop    %edi
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    

008024b5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	57                   	push   %edi
  8024b9:	56                   	push   %esi
  8024ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8024c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8024c5:	89 d1                	mov    %edx,%ecx
  8024c7:	89 d3                	mov    %edx,%ebx
  8024c9:	89 d7                	mov    %edx,%edi
  8024cb:	89 d6                	mov    %edx,%esi
  8024cd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8024cf:	5b                   	pop    %ebx
  8024d0:	5e                   	pop    %esi
  8024d1:	5f                   	pop    %edi
  8024d2:	5d                   	pop    %ebp
  8024d3:	c3                   	ret    

008024d4 <sys_yield>:

void
sys_yield(void)
{
  8024d4:	55                   	push   %ebp
  8024d5:	89 e5                	mov    %esp,%ebp
  8024d7:	57                   	push   %edi
  8024d8:	56                   	push   %esi
  8024d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024da:	ba 00 00 00 00       	mov    $0x0,%edx
  8024df:	b8 0b 00 00 00       	mov    $0xb,%eax
  8024e4:	89 d1                	mov    %edx,%ecx
  8024e6:	89 d3                	mov    %edx,%ebx
  8024e8:	89 d7                	mov    %edx,%edi
  8024ea:	89 d6                	mov    %edx,%esi
  8024ec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8024ee:	5b                   	pop    %ebx
  8024ef:	5e                   	pop    %esi
  8024f0:	5f                   	pop    %edi
  8024f1:	5d                   	pop    %ebp
  8024f2:	c3                   	ret    

008024f3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8024f3:	55                   	push   %ebp
  8024f4:	89 e5                	mov    %esp,%ebp
  8024f6:	57                   	push   %edi
  8024f7:	56                   	push   %esi
  8024f8:	53                   	push   %ebx
  8024f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024fc:	be 00 00 00 00       	mov    $0x0,%esi
  802501:	b8 04 00 00 00       	mov    $0x4,%eax
  802506:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802509:	8b 55 08             	mov    0x8(%ebp),%edx
  80250c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80250f:	89 f7                	mov    %esi,%edi
  802511:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802513:	85 c0                	test   %eax,%eax
  802515:	7e 17                	jle    80252e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802517:	83 ec 0c             	sub    $0xc,%esp
  80251a:	50                   	push   %eax
  80251b:	6a 04                	push   $0x4
  80251d:	68 1f 47 80 00       	push   $0x80471f
  802522:	6a 23                	push   $0x23
  802524:	68 3c 47 80 00       	push   $0x80473c
  802529:	e8 64 f5 ff ff       	call   801a92 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80252e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5f                   	pop    %edi
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    

00802536 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802536:	55                   	push   %ebp
  802537:	89 e5                	mov    %esp,%ebp
  802539:	57                   	push   %edi
  80253a:	56                   	push   %esi
  80253b:	53                   	push   %ebx
  80253c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80253f:	b8 05 00 00 00       	mov    $0x5,%eax
  802544:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802547:	8b 55 08             	mov    0x8(%ebp),%edx
  80254a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80254d:	8b 7d 14             	mov    0x14(%ebp),%edi
  802550:	8b 75 18             	mov    0x18(%ebp),%esi
  802553:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802555:	85 c0                	test   %eax,%eax
  802557:	7e 17                	jle    802570 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802559:	83 ec 0c             	sub    $0xc,%esp
  80255c:	50                   	push   %eax
  80255d:	6a 05                	push   $0x5
  80255f:	68 1f 47 80 00       	push   $0x80471f
  802564:	6a 23                	push   $0x23
  802566:	68 3c 47 80 00       	push   $0x80473c
  80256b:	e8 22 f5 ff ff       	call   801a92 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802570:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802573:	5b                   	pop    %ebx
  802574:	5e                   	pop    %esi
  802575:	5f                   	pop    %edi
  802576:	5d                   	pop    %ebp
  802577:	c3                   	ret    

00802578 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802578:	55                   	push   %ebp
  802579:	89 e5                	mov    %esp,%ebp
  80257b:	57                   	push   %edi
  80257c:	56                   	push   %esi
  80257d:	53                   	push   %ebx
  80257e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802581:	bb 00 00 00 00       	mov    $0x0,%ebx
  802586:	b8 06 00 00 00       	mov    $0x6,%eax
  80258b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80258e:	8b 55 08             	mov    0x8(%ebp),%edx
  802591:	89 df                	mov    %ebx,%edi
  802593:	89 de                	mov    %ebx,%esi
  802595:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802597:	85 c0                	test   %eax,%eax
  802599:	7e 17                	jle    8025b2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80259b:	83 ec 0c             	sub    $0xc,%esp
  80259e:	50                   	push   %eax
  80259f:	6a 06                	push   $0x6
  8025a1:	68 1f 47 80 00       	push   $0x80471f
  8025a6:	6a 23                	push   $0x23
  8025a8:	68 3c 47 80 00       	push   $0x80473c
  8025ad:	e8 e0 f4 ff ff       	call   801a92 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8025b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025b5:	5b                   	pop    %ebx
  8025b6:	5e                   	pop    %esi
  8025b7:	5f                   	pop    %edi
  8025b8:	5d                   	pop    %ebp
  8025b9:	c3                   	ret    

008025ba <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8025ba:	55                   	push   %ebp
  8025bb:	89 e5                	mov    %esp,%ebp
  8025bd:	57                   	push   %edi
  8025be:	56                   	push   %esi
  8025bf:	53                   	push   %ebx
  8025c0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8025cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8025d3:	89 df                	mov    %ebx,%edi
  8025d5:	89 de                	mov    %ebx,%esi
  8025d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025d9:	85 c0                	test   %eax,%eax
  8025db:	7e 17                	jle    8025f4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025dd:	83 ec 0c             	sub    $0xc,%esp
  8025e0:	50                   	push   %eax
  8025e1:	6a 08                	push   $0x8
  8025e3:	68 1f 47 80 00       	push   $0x80471f
  8025e8:	6a 23                	push   $0x23
  8025ea:	68 3c 47 80 00       	push   $0x80473c
  8025ef:	e8 9e f4 ff ff       	call   801a92 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8025f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025f7:	5b                   	pop    %ebx
  8025f8:	5e                   	pop    %esi
  8025f9:	5f                   	pop    %edi
  8025fa:	5d                   	pop    %ebp
  8025fb:	c3                   	ret    

008025fc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8025fc:	55                   	push   %ebp
  8025fd:	89 e5                	mov    %esp,%ebp
  8025ff:	57                   	push   %edi
  802600:	56                   	push   %esi
  802601:	53                   	push   %ebx
  802602:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802605:	bb 00 00 00 00       	mov    $0x0,%ebx
  80260a:	b8 09 00 00 00       	mov    $0x9,%eax
  80260f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802612:	8b 55 08             	mov    0x8(%ebp),%edx
  802615:	89 df                	mov    %ebx,%edi
  802617:	89 de                	mov    %ebx,%esi
  802619:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80261b:	85 c0                	test   %eax,%eax
  80261d:	7e 17                	jle    802636 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80261f:	83 ec 0c             	sub    $0xc,%esp
  802622:	50                   	push   %eax
  802623:	6a 09                	push   $0x9
  802625:	68 1f 47 80 00       	push   $0x80471f
  80262a:	6a 23                	push   $0x23
  80262c:	68 3c 47 80 00       	push   $0x80473c
  802631:	e8 5c f4 ff ff       	call   801a92 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802639:	5b                   	pop    %ebx
  80263a:	5e                   	pop    %esi
  80263b:	5f                   	pop    %edi
  80263c:	5d                   	pop    %ebp
  80263d:	c3                   	ret    

0080263e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80263e:	55                   	push   %ebp
  80263f:	89 e5                	mov    %esp,%ebp
  802641:	57                   	push   %edi
  802642:	56                   	push   %esi
  802643:	53                   	push   %ebx
  802644:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802647:	bb 00 00 00 00       	mov    $0x0,%ebx
  80264c:	b8 0a 00 00 00       	mov    $0xa,%eax
  802651:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802654:	8b 55 08             	mov    0x8(%ebp),%edx
  802657:	89 df                	mov    %ebx,%edi
  802659:	89 de                	mov    %ebx,%esi
  80265b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80265d:	85 c0                	test   %eax,%eax
  80265f:	7e 17                	jle    802678 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802661:	83 ec 0c             	sub    $0xc,%esp
  802664:	50                   	push   %eax
  802665:	6a 0a                	push   $0xa
  802667:	68 1f 47 80 00       	push   $0x80471f
  80266c:	6a 23                	push   $0x23
  80266e:	68 3c 47 80 00       	push   $0x80473c
  802673:	e8 1a f4 ff ff       	call   801a92 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80267b:	5b                   	pop    %ebx
  80267c:	5e                   	pop    %esi
  80267d:	5f                   	pop    %edi
  80267e:	5d                   	pop    %ebp
  80267f:	c3                   	ret    

00802680 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	57                   	push   %edi
  802684:	56                   	push   %esi
  802685:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802686:	be 00 00 00 00       	mov    $0x0,%esi
  80268b:	b8 0c 00 00 00       	mov    $0xc,%eax
  802690:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802693:	8b 55 08             	mov    0x8(%ebp),%edx
  802696:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802699:	8b 7d 14             	mov    0x14(%ebp),%edi
  80269c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80269e:	5b                   	pop    %ebx
  80269f:	5e                   	pop    %esi
  8026a0:	5f                   	pop    %edi
  8026a1:	5d                   	pop    %ebp
  8026a2:	c3                   	ret    

008026a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8026a3:	55                   	push   %ebp
  8026a4:	89 e5                	mov    %esp,%ebp
  8026a6:	57                   	push   %edi
  8026a7:	56                   	push   %esi
  8026a8:	53                   	push   %ebx
  8026a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8026b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8026b9:	89 cb                	mov    %ecx,%ebx
  8026bb:	89 cf                	mov    %ecx,%edi
  8026bd:	89 ce                	mov    %ecx,%esi
  8026bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8026c1:	85 c0                	test   %eax,%eax
  8026c3:	7e 17                	jle    8026dc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026c5:	83 ec 0c             	sub    $0xc,%esp
  8026c8:	50                   	push   %eax
  8026c9:	6a 0d                	push   $0xd
  8026cb:	68 1f 47 80 00       	push   $0x80471f
  8026d0:	6a 23                	push   $0x23
  8026d2:	68 3c 47 80 00       	push   $0x80473c
  8026d7:	e8 b6 f3 ff ff       	call   801a92 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8026dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026df:	5b                   	pop    %ebx
  8026e0:	5e                   	pop    %esi
  8026e1:	5f                   	pop    %edi
  8026e2:	5d                   	pop    %ebp
  8026e3:	c3                   	ret    

008026e4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8026e4:	55                   	push   %ebp
  8026e5:	89 e5                	mov    %esp,%ebp
  8026e7:	57                   	push   %edi
  8026e8:	56                   	push   %esi
  8026e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8026ef:	b8 0e 00 00 00       	mov    $0xe,%eax
  8026f4:	89 d1                	mov    %edx,%ecx
  8026f6:	89 d3                	mov    %edx,%ebx
  8026f8:	89 d7                	mov    %edx,%edi
  8026fa:	89 d6                	mov    %edx,%esi
  8026fc:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8026fe:	5b                   	pop    %ebx
  8026ff:	5e                   	pop    %esi
  802700:	5f                   	pop    %edi
  802701:	5d                   	pop    %ebp
  802702:	c3                   	ret    

00802703 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  802703:	55                   	push   %ebp
  802704:	89 e5                	mov    %esp,%ebp
  802706:	57                   	push   %edi
  802707:	56                   	push   %esi
  802708:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802709:	bb 00 00 00 00       	mov    $0x0,%ebx
  80270e:	b8 0f 00 00 00       	mov    $0xf,%eax
  802713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802716:	8b 55 08             	mov    0x8(%ebp),%edx
  802719:	89 df                	mov    %ebx,%edi
  80271b:	89 de                	mov    %ebx,%esi
  80271d:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  80271f:	5b                   	pop    %ebx
  802720:	5e                   	pop    %esi
  802721:	5f                   	pop    %edi
  802722:	5d                   	pop    %ebp
  802723:	c3                   	ret    

00802724 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802724:	55                   	push   %ebp
  802725:	89 e5                	mov    %esp,%ebp
  802727:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80272a:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  802731:	75 2c                	jne    80275f <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802733:	83 ec 04             	sub    $0x4,%esp
  802736:	6a 07                	push   $0x7
  802738:	68 00 f0 bf ee       	push   $0xeebff000
  80273d:	6a 00                	push   $0x0
  80273f:	e8 af fd ff ff       	call   8024f3 <sys_page_alloc>
  802744:	83 c4 10             	add    $0x10,%esp
  802747:	85 c0                	test   %eax,%eax
  802749:	79 14                	jns    80275f <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  80274b:	83 ec 04             	sub    $0x4,%esp
  80274e:	68 4a 47 80 00       	push   $0x80474a
  802753:	6a 22                	push   $0x22
  802755:	68 61 47 80 00       	push   $0x804761
  80275a:	e8 33 f3 ff ff       	call   801a92 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  80275f:	8b 45 08             	mov    0x8(%ebp),%eax
  802762:	a3 14 a0 80 00       	mov    %eax,0x80a014
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802767:	83 ec 08             	sub    $0x8,%esp
  80276a:	68 93 27 80 00       	push   $0x802793
  80276f:	6a 00                	push   $0x0
  802771:	e8 c8 fe ff ff       	call   80263e <sys_env_set_pgfault_upcall>
  802776:	83 c4 10             	add    $0x10,%esp
  802779:	85 c0                	test   %eax,%eax
  80277b:	79 14                	jns    802791 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  80277d:	83 ec 04             	sub    $0x4,%esp
  802780:	68 70 47 80 00       	push   $0x804770
  802785:	6a 27                	push   $0x27
  802787:	68 61 47 80 00       	push   $0x804761
  80278c:	e8 01 f3 ff ff       	call   801a92 <_panic>
    
}
  802791:	c9                   	leave  
  802792:	c3                   	ret    

00802793 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802793:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802794:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802799:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80279b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  80279e:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8027a2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8027a7:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8027ab:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8027ad:	83 c4 08             	add    $0x8,%esp
	popal
  8027b0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8027b1:	83 c4 04             	add    $0x4,%esp
	popfl
  8027b4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8027b5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027b6:	c3                   	ret    

008027b7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027b7:	55                   	push   %ebp
  8027b8:	89 e5                	mov    %esp,%ebp
  8027ba:	56                   	push   %esi
  8027bb:	53                   	push   %ebx
  8027bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8027bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8027c5:	85 c0                	test   %eax,%eax
  8027c7:	74 0e                	je     8027d7 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8027c9:	83 ec 0c             	sub    $0xc,%esp
  8027cc:	50                   	push   %eax
  8027cd:	e8 d1 fe ff ff       	call   8026a3 <sys_ipc_recv>
  8027d2:	83 c4 10             	add    $0x10,%esp
  8027d5:	eb 10                	jmp    8027e7 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8027d7:	83 ec 0c             	sub    $0xc,%esp
  8027da:	68 00 00 00 f0       	push   $0xf0000000
  8027df:	e8 bf fe ff ff       	call   8026a3 <sys_ipc_recv>
  8027e4:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8027e7:	85 c0                	test   %eax,%eax
  8027e9:	74 0e                	je     8027f9 <ipc_recv+0x42>
    	*from_env_store = 0;
  8027eb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8027f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8027f7:	eb 24                	jmp    80281d <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8027f9:	85 f6                	test   %esi,%esi
  8027fb:	74 0a                	je     802807 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8027fd:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802802:	8b 40 74             	mov    0x74(%eax),%eax
  802805:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802807:	85 db                	test   %ebx,%ebx
  802809:	74 0a                	je     802815 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  80280b:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802810:	8b 40 78             	mov    0x78(%eax),%eax
  802813:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802815:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80281a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80281d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802820:	5b                   	pop    %ebx
  802821:	5e                   	pop    %esi
  802822:	5d                   	pop    %ebp
  802823:	c3                   	ret    

00802824 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802824:	55                   	push   %ebp
  802825:	89 e5                	mov    %esp,%ebp
  802827:	57                   	push   %edi
  802828:	56                   	push   %esi
  802829:	53                   	push   %ebx
  80282a:	83 ec 0c             	sub    $0xc,%esp
  80282d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802830:	8b 75 0c             	mov    0xc(%ebp),%esi
  802833:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802836:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802838:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80283d:	0f 44 d8             	cmove  %eax,%ebx
  802840:	eb 1c                	jmp    80285e <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802842:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802845:	74 12                	je     802859 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802847:	50                   	push   %eax
  802848:	68 93 47 80 00       	push   $0x804793
  80284d:	6a 4b                	push   $0x4b
  80284f:	68 ab 47 80 00       	push   $0x8047ab
  802854:	e8 39 f2 ff ff       	call   801a92 <_panic>
        }	
        sys_yield();
  802859:	e8 76 fc ff ff       	call   8024d4 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80285e:	ff 75 14             	pushl  0x14(%ebp)
  802861:	53                   	push   %ebx
  802862:	56                   	push   %esi
  802863:	57                   	push   %edi
  802864:	e8 17 fe ff ff       	call   802680 <sys_ipc_try_send>
  802869:	83 c4 10             	add    $0x10,%esp
  80286c:	85 c0                	test   %eax,%eax
  80286e:	75 d2                	jne    802842 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802870:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802873:	5b                   	pop    %ebx
  802874:	5e                   	pop    %esi
  802875:	5f                   	pop    %edi
  802876:	5d                   	pop    %ebp
  802877:	c3                   	ret    

00802878 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802878:	55                   	push   %ebp
  802879:	89 e5                	mov    %esp,%ebp
  80287b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80287e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802883:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802886:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80288c:	8b 52 50             	mov    0x50(%edx),%edx
  80288f:	39 ca                	cmp    %ecx,%edx
  802891:	75 0d                	jne    8028a0 <ipc_find_env+0x28>
			return envs[i].env_id;
  802893:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802896:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80289b:	8b 40 48             	mov    0x48(%eax),%eax
  80289e:	eb 0f                	jmp    8028af <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028a0:	83 c0 01             	add    $0x1,%eax
  8028a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028a8:	75 d9                	jne    802883 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028af:	5d                   	pop    %ebp
  8028b0:	c3                   	ret    

008028b1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8028b1:	55                   	push   %ebp
  8028b2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8028b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8028bc:	c1 e8 0c             	shr    $0xc,%eax
}
  8028bf:	5d                   	pop    %ebp
  8028c0:	c3                   	ret    

008028c1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8028c1:	55                   	push   %ebp
  8028c2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8028c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8028c7:	05 00 00 00 30       	add    $0x30000000,%eax
  8028cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8028d1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8028d6:	5d                   	pop    %ebp
  8028d7:	c3                   	ret    

008028d8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8028d8:	55                   	push   %ebp
  8028d9:	89 e5                	mov    %esp,%ebp
  8028db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028de:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8028e3:	89 c2                	mov    %eax,%edx
  8028e5:	c1 ea 16             	shr    $0x16,%edx
  8028e8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028ef:	f6 c2 01             	test   $0x1,%dl
  8028f2:	74 11                	je     802905 <fd_alloc+0x2d>
  8028f4:	89 c2                	mov    %eax,%edx
  8028f6:	c1 ea 0c             	shr    $0xc,%edx
  8028f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802900:	f6 c2 01             	test   $0x1,%dl
  802903:	75 09                	jne    80290e <fd_alloc+0x36>
			*fd_store = fd;
  802905:	89 01                	mov    %eax,(%ecx)
			return 0;
  802907:	b8 00 00 00 00       	mov    $0x0,%eax
  80290c:	eb 17                	jmp    802925 <fd_alloc+0x4d>
  80290e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802913:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802918:	75 c9                	jne    8028e3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80291a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802920:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802925:	5d                   	pop    %ebp
  802926:	c3                   	ret    

00802927 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802927:	55                   	push   %ebp
  802928:	89 e5                	mov    %esp,%ebp
  80292a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80292d:	83 f8 1f             	cmp    $0x1f,%eax
  802930:	77 36                	ja     802968 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802932:	c1 e0 0c             	shl    $0xc,%eax
  802935:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80293a:	89 c2                	mov    %eax,%edx
  80293c:	c1 ea 16             	shr    $0x16,%edx
  80293f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802946:	f6 c2 01             	test   $0x1,%dl
  802949:	74 24                	je     80296f <fd_lookup+0x48>
  80294b:	89 c2                	mov    %eax,%edx
  80294d:	c1 ea 0c             	shr    $0xc,%edx
  802950:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802957:	f6 c2 01             	test   $0x1,%dl
  80295a:	74 1a                	je     802976 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80295c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80295f:	89 02                	mov    %eax,(%edx)
	return 0;
  802961:	b8 00 00 00 00       	mov    $0x0,%eax
  802966:	eb 13                	jmp    80297b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802968:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80296d:	eb 0c                	jmp    80297b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80296f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802974:	eb 05                	jmp    80297b <fd_lookup+0x54>
  802976:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80297b:	5d                   	pop    %ebp
  80297c:	c3                   	ret    

0080297d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80297d:	55                   	push   %ebp
  80297e:	89 e5                	mov    %esp,%ebp
  802980:	83 ec 08             	sub    $0x8,%esp
  802983:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802986:	ba 38 48 80 00       	mov    $0x804838,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80298b:	eb 13                	jmp    8029a0 <dev_lookup+0x23>
  80298d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802990:	39 08                	cmp    %ecx,(%eax)
  802992:	75 0c                	jne    8029a0 <dev_lookup+0x23>
			*dev = devtab[i];
  802994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802997:	89 01                	mov    %eax,(%ecx)
			return 0;
  802999:	b8 00 00 00 00       	mov    $0x0,%eax
  80299e:	eb 2e                	jmp    8029ce <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8029a0:	8b 02                	mov    (%edx),%eax
  8029a2:	85 c0                	test   %eax,%eax
  8029a4:	75 e7                	jne    80298d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8029a6:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8029ab:	8b 40 48             	mov    0x48(%eax),%eax
  8029ae:	83 ec 04             	sub    $0x4,%esp
  8029b1:	51                   	push   %ecx
  8029b2:	50                   	push   %eax
  8029b3:	68 b8 47 80 00       	push   $0x8047b8
  8029b8:	e8 ae f1 ff ff       	call   801b6b <cprintf>
	*dev = 0;
  8029bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8029c6:	83 c4 10             	add    $0x10,%esp
  8029c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8029ce:	c9                   	leave  
  8029cf:	c3                   	ret    

008029d0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8029d0:	55                   	push   %ebp
  8029d1:	89 e5                	mov    %esp,%ebp
  8029d3:	56                   	push   %esi
  8029d4:	53                   	push   %ebx
  8029d5:	83 ec 10             	sub    $0x10,%esp
  8029d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8029db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8029de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029e1:	50                   	push   %eax
  8029e2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8029e8:	c1 e8 0c             	shr    $0xc,%eax
  8029eb:	50                   	push   %eax
  8029ec:	e8 36 ff ff ff       	call   802927 <fd_lookup>
  8029f1:	83 c4 08             	add    $0x8,%esp
  8029f4:	85 c0                	test   %eax,%eax
  8029f6:	78 05                	js     8029fd <fd_close+0x2d>
	    || fd != fd2)
  8029f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8029fb:	74 0c                	je     802a09 <fd_close+0x39>
		return (must_exist ? r : 0);
  8029fd:	84 db                	test   %bl,%bl
  8029ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802a04:	0f 44 c2             	cmove  %edx,%eax
  802a07:	eb 41                	jmp    802a4a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a09:	83 ec 08             	sub    $0x8,%esp
  802a0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a0f:	50                   	push   %eax
  802a10:	ff 36                	pushl  (%esi)
  802a12:	e8 66 ff ff ff       	call   80297d <dev_lookup>
  802a17:	89 c3                	mov    %eax,%ebx
  802a19:	83 c4 10             	add    $0x10,%esp
  802a1c:	85 c0                	test   %eax,%eax
  802a1e:	78 1a                	js     802a3a <fd_close+0x6a>
		if (dev->dev_close)
  802a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a23:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802a26:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a2b:	85 c0                	test   %eax,%eax
  802a2d:	74 0b                	je     802a3a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802a2f:	83 ec 0c             	sub    $0xc,%esp
  802a32:	56                   	push   %esi
  802a33:	ff d0                	call   *%eax
  802a35:	89 c3                	mov    %eax,%ebx
  802a37:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802a3a:	83 ec 08             	sub    $0x8,%esp
  802a3d:	56                   	push   %esi
  802a3e:	6a 00                	push   $0x0
  802a40:	e8 33 fb ff ff       	call   802578 <sys_page_unmap>
	return r;
  802a45:	83 c4 10             	add    $0x10,%esp
  802a48:	89 d8                	mov    %ebx,%eax
}
  802a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a4d:	5b                   	pop    %ebx
  802a4e:	5e                   	pop    %esi
  802a4f:	5d                   	pop    %ebp
  802a50:	c3                   	ret    

00802a51 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a51:	55                   	push   %ebp
  802a52:	89 e5                	mov    %esp,%ebp
  802a54:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a5a:	50                   	push   %eax
  802a5b:	ff 75 08             	pushl  0x8(%ebp)
  802a5e:	e8 c4 fe ff ff       	call   802927 <fd_lookup>
  802a63:	83 c4 08             	add    $0x8,%esp
  802a66:	85 c0                	test   %eax,%eax
  802a68:	78 10                	js     802a7a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802a6a:	83 ec 08             	sub    $0x8,%esp
  802a6d:	6a 01                	push   $0x1
  802a6f:	ff 75 f4             	pushl  -0xc(%ebp)
  802a72:	e8 59 ff ff ff       	call   8029d0 <fd_close>
  802a77:	83 c4 10             	add    $0x10,%esp
}
  802a7a:	c9                   	leave  
  802a7b:	c3                   	ret    

00802a7c <close_all>:

void
close_all(void)
{
  802a7c:	55                   	push   %ebp
  802a7d:	89 e5                	mov    %esp,%ebp
  802a7f:	53                   	push   %ebx
  802a80:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802a83:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802a88:	83 ec 0c             	sub    $0xc,%esp
  802a8b:	53                   	push   %ebx
  802a8c:	e8 c0 ff ff ff       	call   802a51 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802a91:	83 c3 01             	add    $0x1,%ebx
  802a94:	83 c4 10             	add    $0x10,%esp
  802a97:	83 fb 20             	cmp    $0x20,%ebx
  802a9a:	75 ec                	jne    802a88 <close_all+0xc>
		close(i);
}
  802a9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a9f:	c9                   	leave  
  802aa0:	c3                   	ret    

00802aa1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802aa1:	55                   	push   %ebp
  802aa2:	89 e5                	mov    %esp,%ebp
  802aa4:	57                   	push   %edi
  802aa5:	56                   	push   %esi
  802aa6:	53                   	push   %ebx
  802aa7:	83 ec 2c             	sub    $0x2c,%esp
  802aaa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802aad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ab0:	50                   	push   %eax
  802ab1:	ff 75 08             	pushl  0x8(%ebp)
  802ab4:	e8 6e fe ff ff       	call   802927 <fd_lookup>
  802ab9:	83 c4 08             	add    $0x8,%esp
  802abc:	85 c0                	test   %eax,%eax
  802abe:	0f 88 c1 00 00 00    	js     802b85 <dup+0xe4>
		return r;
	close(newfdnum);
  802ac4:	83 ec 0c             	sub    $0xc,%esp
  802ac7:	56                   	push   %esi
  802ac8:	e8 84 ff ff ff       	call   802a51 <close>

	newfd = INDEX2FD(newfdnum);
  802acd:	89 f3                	mov    %esi,%ebx
  802acf:	c1 e3 0c             	shl    $0xc,%ebx
  802ad2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802ad8:	83 c4 04             	add    $0x4,%esp
  802adb:	ff 75 e4             	pushl  -0x1c(%ebp)
  802ade:	e8 de fd ff ff       	call   8028c1 <fd2data>
  802ae3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802ae5:	89 1c 24             	mov    %ebx,(%esp)
  802ae8:	e8 d4 fd ff ff       	call   8028c1 <fd2data>
  802aed:	83 c4 10             	add    $0x10,%esp
  802af0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802af3:	89 f8                	mov    %edi,%eax
  802af5:	c1 e8 16             	shr    $0x16,%eax
  802af8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802aff:	a8 01                	test   $0x1,%al
  802b01:	74 37                	je     802b3a <dup+0x99>
  802b03:	89 f8                	mov    %edi,%eax
  802b05:	c1 e8 0c             	shr    $0xc,%eax
  802b08:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b0f:	f6 c2 01             	test   $0x1,%dl
  802b12:	74 26                	je     802b3a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b14:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b1b:	83 ec 0c             	sub    $0xc,%esp
  802b1e:	25 07 0e 00 00       	and    $0xe07,%eax
  802b23:	50                   	push   %eax
  802b24:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b27:	6a 00                	push   $0x0
  802b29:	57                   	push   %edi
  802b2a:	6a 00                	push   $0x0
  802b2c:	e8 05 fa ff ff       	call   802536 <sys_page_map>
  802b31:	89 c7                	mov    %eax,%edi
  802b33:	83 c4 20             	add    $0x20,%esp
  802b36:	85 c0                	test   %eax,%eax
  802b38:	78 2e                	js     802b68 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b3a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802b3d:	89 d0                	mov    %edx,%eax
  802b3f:	c1 e8 0c             	shr    $0xc,%eax
  802b42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b49:	83 ec 0c             	sub    $0xc,%esp
  802b4c:	25 07 0e 00 00       	and    $0xe07,%eax
  802b51:	50                   	push   %eax
  802b52:	53                   	push   %ebx
  802b53:	6a 00                	push   $0x0
  802b55:	52                   	push   %edx
  802b56:	6a 00                	push   $0x0
  802b58:	e8 d9 f9 ff ff       	call   802536 <sys_page_map>
  802b5d:	89 c7                	mov    %eax,%edi
  802b5f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802b62:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b64:	85 ff                	test   %edi,%edi
  802b66:	79 1d                	jns    802b85 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802b68:	83 ec 08             	sub    $0x8,%esp
  802b6b:	53                   	push   %ebx
  802b6c:	6a 00                	push   $0x0
  802b6e:	e8 05 fa ff ff       	call   802578 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802b73:	83 c4 08             	add    $0x8,%esp
  802b76:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b79:	6a 00                	push   $0x0
  802b7b:	e8 f8 f9 ff ff       	call   802578 <sys_page_unmap>
	return r;
  802b80:	83 c4 10             	add    $0x10,%esp
  802b83:	89 f8                	mov    %edi,%eax
}
  802b85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b88:	5b                   	pop    %ebx
  802b89:	5e                   	pop    %esi
  802b8a:	5f                   	pop    %edi
  802b8b:	5d                   	pop    %ebp
  802b8c:	c3                   	ret    

00802b8d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802b8d:	55                   	push   %ebp
  802b8e:	89 e5                	mov    %esp,%ebp
  802b90:	53                   	push   %ebx
  802b91:	83 ec 14             	sub    $0x14,%esp
  802b94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b9a:	50                   	push   %eax
  802b9b:	53                   	push   %ebx
  802b9c:	e8 86 fd ff ff       	call   802927 <fd_lookup>
  802ba1:	83 c4 08             	add    $0x8,%esp
  802ba4:	89 c2                	mov    %eax,%edx
  802ba6:	85 c0                	test   %eax,%eax
  802ba8:	78 6d                	js     802c17 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802baa:	83 ec 08             	sub    $0x8,%esp
  802bad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bb0:	50                   	push   %eax
  802bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bb4:	ff 30                	pushl  (%eax)
  802bb6:	e8 c2 fd ff ff       	call   80297d <dev_lookup>
  802bbb:	83 c4 10             	add    $0x10,%esp
  802bbe:	85 c0                	test   %eax,%eax
  802bc0:	78 4c                	js     802c0e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802bc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802bc5:	8b 42 08             	mov    0x8(%edx),%eax
  802bc8:	83 e0 03             	and    $0x3,%eax
  802bcb:	83 f8 01             	cmp    $0x1,%eax
  802bce:	75 21                	jne    802bf1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802bd0:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802bd5:	8b 40 48             	mov    0x48(%eax),%eax
  802bd8:	83 ec 04             	sub    $0x4,%esp
  802bdb:	53                   	push   %ebx
  802bdc:	50                   	push   %eax
  802bdd:	68 fc 47 80 00       	push   $0x8047fc
  802be2:	e8 84 ef ff ff       	call   801b6b <cprintf>
		return -E_INVAL;
  802be7:	83 c4 10             	add    $0x10,%esp
  802bea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802bef:	eb 26                	jmp    802c17 <read+0x8a>
	}
	if (!dev->dev_read)
  802bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bf4:	8b 40 08             	mov    0x8(%eax),%eax
  802bf7:	85 c0                	test   %eax,%eax
  802bf9:	74 17                	je     802c12 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802bfb:	83 ec 04             	sub    $0x4,%esp
  802bfe:	ff 75 10             	pushl  0x10(%ebp)
  802c01:	ff 75 0c             	pushl  0xc(%ebp)
  802c04:	52                   	push   %edx
  802c05:	ff d0                	call   *%eax
  802c07:	89 c2                	mov    %eax,%edx
  802c09:	83 c4 10             	add    $0x10,%esp
  802c0c:	eb 09                	jmp    802c17 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c0e:	89 c2                	mov    %eax,%edx
  802c10:	eb 05                	jmp    802c17 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c12:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802c17:	89 d0                	mov    %edx,%eax
  802c19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c1c:	c9                   	leave  
  802c1d:	c3                   	ret    

00802c1e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c1e:	55                   	push   %ebp
  802c1f:	89 e5                	mov    %esp,%ebp
  802c21:	57                   	push   %edi
  802c22:	56                   	push   %esi
  802c23:	53                   	push   %ebx
  802c24:	83 ec 0c             	sub    $0xc,%esp
  802c27:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c2a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c32:	eb 21                	jmp    802c55 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c34:	83 ec 04             	sub    $0x4,%esp
  802c37:	89 f0                	mov    %esi,%eax
  802c39:	29 d8                	sub    %ebx,%eax
  802c3b:	50                   	push   %eax
  802c3c:	89 d8                	mov    %ebx,%eax
  802c3e:	03 45 0c             	add    0xc(%ebp),%eax
  802c41:	50                   	push   %eax
  802c42:	57                   	push   %edi
  802c43:	e8 45 ff ff ff       	call   802b8d <read>
		if (m < 0)
  802c48:	83 c4 10             	add    $0x10,%esp
  802c4b:	85 c0                	test   %eax,%eax
  802c4d:	78 10                	js     802c5f <readn+0x41>
			return m;
		if (m == 0)
  802c4f:	85 c0                	test   %eax,%eax
  802c51:	74 0a                	je     802c5d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c53:	01 c3                	add    %eax,%ebx
  802c55:	39 f3                	cmp    %esi,%ebx
  802c57:	72 db                	jb     802c34 <readn+0x16>
  802c59:	89 d8                	mov    %ebx,%eax
  802c5b:	eb 02                	jmp    802c5f <readn+0x41>
  802c5d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c62:	5b                   	pop    %ebx
  802c63:	5e                   	pop    %esi
  802c64:	5f                   	pop    %edi
  802c65:	5d                   	pop    %ebp
  802c66:	c3                   	ret    

00802c67 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802c67:	55                   	push   %ebp
  802c68:	89 e5                	mov    %esp,%ebp
  802c6a:	53                   	push   %ebx
  802c6b:	83 ec 14             	sub    $0x14,%esp
  802c6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c74:	50                   	push   %eax
  802c75:	53                   	push   %ebx
  802c76:	e8 ac fc ff ff       	call   802927 <fd_lookup>
  802c7b:	83 c4 08             	add    $0x8,%esp
  802c7e:	89 c2                	mov    %eax,%edx
  802c80:	85 c0                	test   %eax,%eax
  802c82:	78 68                	js     802cec <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c84:	83 ec 08             	sub    $0x8,%esp
  802c87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c8a:	50                   	push   %eax
  802c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c8e:	ff 30                	pushl  (%eax)
  802c90:	e8 e8 fc ff ff       	call   80297d <dev_lookup>
  802c95:	83 c4 10             	add    $0x10,%esp
  802c98:	85 c0                	test   %eax,%eax
  802c9a:	78 47                	js     802ce3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c9f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802ca3:	75 21                	jne    802cc6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802ca5:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802caa:	8b 40 48             	mov    0x48(%eax),%eax
  802cad:	83 ec 04             	sub    $0x4,%esp
  802cb0:	53                   	push   %ebx
  802cb1:	50                   	push   %eax
  802cb2:	68 18 48 80 00       	push   $0x804818
  802cb7:	e8 af ee ff ff       	call   801b6b <cprintf>
		return -E_INVAL;
  802cbc:	83 c4 10             	add    $0x10,%esp
  802cbf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802cc4:	eb 26                	jmp    802cec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802cc9:	8b 52 0c             	mov    0xc(%edx),%edx
  802ccc:	85 d2                	test   %edx,%edx
  802cce:	74 17                	je     802ce7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802cd0:	83 ec 04             	sub    $0x4,%esp
  802cd3:	ff 75 10             	pushl  0x10(%ebp)
  802cd6:	ff 75 0c             	pushl  0xc(%ebp)
  802cd9:	50                   	push   %eax
  802cda:	ff d2                	call   *%edx
  802cdc:	89 c2                	mov    %eax,%edx
  802cde:	83 c4 10             	add    $0x10,%esp
  802ce1:	eb 09                	jmp    802cec <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ce3:	89 c2                	mov    %eax,%edx
  802ce5:	eb 05                	jmp    802cec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802ce7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802cec:	89 d0                	mov    %edx,%eax
  802cee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cf1:	c9                   	leave  
  802cf2:	c3                   	ret    

00802cf3 <seek>:

int
seek(int fdnum, off_t offset)
{
  802cf3:	55                   	push   %ebp
  802cf4:	89 e5                	mov    %esp,%ebp
  802cf6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802cf9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802cfc:	50                   	push   %eax
  802cfd:	ff 75 08             	pushl  0x8(%ebp)
  802d00:	e8 22 fc ff ff       	call   802927 <fd_lookup>
  802d05:	83 c4 08             	add    $0x8,%esp
  802d08:	85 c0                	test   %eax,%eax
  802d0a:	78 0e                	js     802d1a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d12:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d1a:	c9                   	leave  
  802d1b:	c3                   	ret    

00802d1c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d1c:	55                   	push   %ebp
  802d1d:	89 e5                	mov    %esp,%ebp
  802d1f:	53                   	push   %ebx
  802d20:	83 ec 14             	sub    $0x14,%esp
  802d23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d29:	50                   	push   %eax
  802d2a:	53                   	push   %ebx
  802d2b:	e8 f7 fb ff ff       	call   802927 <fd_lookup>
  802d30:	83 c4 08             	add    $0x8,%esp
  802d33:	89 c2                	mov    %eax,%edx
  802d35:	85 c0                	test   %eax,%eax
  802d37:	78 65                	js     802d9e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d39:	83 ec 08             	sub    $0x8,%esp
  802d3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d3f:	50                   	push   %eax
  802d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d43:	ff 30                	pushl  (%eax)
  802d45:	e8 33 fc ff ff       	call   80297d <dev_lookup>
  802d4a:	83 c4 10             	add    $0x10,%esp
  802d4d:	85 c0                	test   %eax,%eax
  802d4f:	78 44                	js     802d95 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d54:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d58:	75 21                	jne    802d7b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d5a:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d5f:	8b 40 48             	mov    0x48(%eax),%eax
  802d62:	83 ec 04             	sub    $0x4,%esp
  802d65:	53                   	push   %ebx
  802d66:	50                   	push   %eax
  802d67:	68 d8 47 80 00       	push   $0x8047d8
  802d6c:	e8 fa ed ff ff       	call   801b6b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802d71:	83 c4 10             	add    $0x10,%esp
  802d74:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d79:	eb 23                	jmp    802d9e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802d7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d7e:	8b 52 18             	mov    0x18(%edx),%edx
  802d81:	85 d2                	test   %edx,%edx
  802d83:	74 14                	je     802d99 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802d85:	83 ec 08             	sub    $0x8,%esp
  802d88:	ff 75 0c             	pushl  0xc(%ebp)
  802d8b:	50                   	push   %eax
  802d8c:	ff d2                	call   *%edx
  802d8e:	89 c2                	mov    %eax,%edx
  802d90:	83 c4 10             	add    $0x10,%esp
  802d93:	eb 09                	jmp    802d9e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d95:	89 c2                	mov    %eax,%edx
  802d97:	eb 05                	jmp    802d9e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802d99:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802d9e:	89 d0                	mov    %edx,%eax
  802da0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802da3:	c9                   	leave  
  802da4:	c3                   	ret    

00802da5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802da5:	55                   	push   %ebp
  802da6:	89 e5                	mov    %esp,%ebp
  802da8:	53                   	push   %ebx
  802da9:	83 ec 14             	sub    $0x14,%esp
  802dac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802daf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802db2:	50                   	push   %eax
  802db3:	ff 75 08             	pushl  0x8(%ebp)
  802db6:	e8 6c fb ff ff       	call   802927 <fd_lookup>
  802dbb:	83 c4 08             	add    $0x8,%esp
  802dbe:	89 c2                	mov    %eax,%edx
  802dc0:	85 c0                	test   %eax,%eax
  802dc2:	78 58                	js     802e1c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dc4:	83 ec 08             	sub    $0x8,%esp
  802dc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dca:	50                   	push   %eax
  802dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dce:	ff 30                	pushl  (%eax)
  802dd0:	e8 a8 fb ff ff       	call   80297d <dev_lookup>
  802dd5:	83 c4 10             	add    $0x10,%esp
  802dd8:	85 c0                	test   %eax,%eax
  802dda:	78 37                	js     802e13 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ddf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802de3:	74 32                	je     802e17 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802de5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802de8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802def:	00 00 00 
	stat->st_isdir = 0;
  802df2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802df9:	00 00 00 
	stat->st_dev = dev;
  802dfc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e02:	83 ec 08             	sub    $0x8,%esp
  802e05:	53                   	push   %ebx
  802e06:	ff 75 f0             	pushl  -0x10(%ebp)
  802e09:	ff 50 14             	call   *0x14(%eax)
  802e0c:	89 c2                	mov    %eax,%edx
  802e0e:	83 c4 10             	add    $0x10,%esp
  802e11:	eb 09                	jmp    802e1c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e13:	89 c2                	mov    %eax,%edx
  802e15:	eb 05                	jmp    802e1c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e17:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802e1c:	89 d0                	mov    %edx,%eax
  802e1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e21:	c9                   	leave  
  802e22:	c3                   	ret    

00802e23 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e23:	55                   	push   %ebp
  802e24:	89 e5                	mov    %esp,%ebp
  802e26:	56                   	push   %esi
  802e27:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e28:	83 ec 08             	sub    $0x8,%esp
  802e2b:	6a 00                	push   $0x0
  802e2d:	ff 75 08             	pushl  0x8(%ebp)
  802e30:	e8 e7 01 00 00       	call   80301c <open>
  802e35:	89 c3                	mov    %eax,%ebx
  802e37:	83 c4 10             	add    $0x10,%esp
  802e3a:	85 c0                	test   %eax,%eax
  802e3c:	78 1b                	js     802e59 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802e3e:	83 ec 08             	sub    $0x8,%esp
  802e41:	ff 75 0c             	pushl  0xc(%ebp)
  802e44:	50                   	push   %eax
  802e45:	e8 5b ff ff ff       	call   802da5 <fstat>
  802e4a:	89 c6                	mov    %eax,%esi
	close(fd);
  802e4c:	89 1c 24             	mov    %ebx,(%esp)
  802e4f:	e8 fd fb ff ff       	call   802a51 <close>
	return r;
  802e54:	83 c4 10             	add    $0x10,%esp
  802e57:	89 f0                	mov    %esi,%eax
}
  802e59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e5c:	5b                   	pop    %ebx
  802e5d:	5e                   	pop    %esi
  802e5e:	5d                   	pop    %ebp
  802e5f:	c3                   	ret    

00802e60 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802e60:	55                   	push   %ebp
  802e61:	89 e5                	mov    %esp,%ebp
  802e63:	56                   	push   %esi
  802e64:	53                   	push   %ebx
  802e65:	89 c6                	mov    %eax,%esi
  802e67:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802e69:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802e70:	75 12                	jne    802e84 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802e72:	83 ec 0c             	sub    $0xc,%esp
  802e75:	6a 01                	push   $0x1
  802e77:	e8 fc f9 ff ff       	call   802878 <ipc_find_env>
  802e7c:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802e81:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802e84:	6a 07                	push   $0x7
  802e86:	68 00 b0 80 00       	push   $0x80b000
  802e8b:	56                   	push   %esi
  802e8c:	ff 35 00 a0 80 00    	pushl  0x80a000
  802e92:	e8 8d f9 ff ff       	call   802824 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802e97:	83 c4 0c             	add    $0xc,%esp
  802e9a:	6a 00                	push   $0x0
  802e9c:	53                   	push   %ebx
  802e9d:	6a 00                	push   $0x0
  802e9f:	e8 13 f9 ff ff       	call   8027b7 <ipc_recv>
}
  802ea4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ea7:	5b                   	pop    %ebx
  802ea8:	5e                   	pop    %esi
  802ea9:	5d                   	pop    %ebp
  802eaa:	c3                   	ret    

00802eab <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802eab:	55                   	push   %ebp
  802eac:	89 e5                	mov    %esp,%ebp
  802eae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb4:	8b 40 0c             	mov    0xc(%eax),%eax
  802eb7:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ebf:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802ec4:	ba 00 00 00 00       	mov    $0x0,%edx
  802ec9:	b8 02 00 00 00       	mov    $0x2,%eax
  802ece:	e8 8d ff ff ff       	call   802e60 <fsipc>
}
  802ed3:	c9                   	leave  
  802ed4:	c3                   	ret    

00802ed5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802ed5:	55                   	push   %ebp
  802ed6:	89 e5                	mov    %esp,%ebp
  802ed8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802edb:	8b 45 08             	mov    0x8(%ebp),%eax
  802ede:	8b 40 0c             	mov    0xc(%eax),%eax
  802ee1:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802ee6:	ba 00 00 00 00       	mov    $0x0,%edx
  802eeb:	b8 06 00 00 00       	mov    $0x6,%eax
  802ef0:	e8 6b ff ff ff       	call   802e60 <fsipc>
}
  802ef5:	c9                   	leave  
  802ef6:	c3                   	ret    

00802ef7 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802ef7:	55                   	push   %ebp
  802ef8:	89 e5                	mov    %esp,%ebp
  802efa:	53                   	push   %ebx
  802efb:	83 ec 04             	sub    $0x4,%esp
  802efe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f01:	8b 45 08             	mov    0x8(%ebp),%eax
  802f04:	8b 40 0c             	mov    0xc(%eax),%eax
  802f07:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f0c:	ba 00 00 00 00       	mov    $0x0,%edx
  802f11:	b8 05 00 00 00       	mov    $0x5,%eax
  802f16:	e8 45 ff ff ff       	call   802e60 <fsipc>
  802f1b:	85 c0                	test   %eax,%eax
  802f1d:	78 2c                	js     802f4b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f1f:	83 ec 08             	sub    $0x8,%esp
  802f22:	68 00 b0 80 00       	push   $0x80b000
  802f27:	53                   	push   %ebx
  802f28:	e8 c3 f1 ff ff       	call   8020f0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f2d:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802f32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f38:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802f3d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f43:	83 c4 10             	add    $0x10,%esp
  802f46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f4e:	c9                   	leave  
  802f4f:	c3                   	ret    

00802f50 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f50:	55                   	push   %ebp
  802f51:	89 e5                	mov    %esp,%ebp
  802f53:	53                   	push   %ebx
  802f54:	83 ec 08             	sub    $0x8,%esp
  802f57:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  802f5a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802f5f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802f64:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  802f67:	53                   	push   %ebx
  802f68:	ff 75 0c             	pushl  0xc(%ebp)
  802f6b:	68 08 b0 80 00       	push   $0x80b008
  802f70:	e8 0d f3 ff ff       	call   802282 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802f75:	8b 45 08             	mov    0x8(%ebp),%eax
  802f78:	8b 40 0c             	mov    0xc(%eax),%eax
  802f7b:	a3 00 b0 80 00       	mov    %eax,0x80b000
 	fsipcbuf.write.req_n = n;
  802f80:	89 1d 04 b0 80 00    	mov    %ebx,0x80b004

 	return fsipc(FSREQ_WRITE, NULL);
  802f86:	ba 00 00 00 00       	mov    $0x0,%edx
  802f8b:	b8 04 00 00 00       	mov    $0x4,%eax
  802f90:	e8 cb fe ff ff       	call   802e60 <fsipc>
	//panic("devfile_write not implemented");
}
  802f95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f98:	c9                   	leave  
  802f99:	c3                   	ret    

00802f9a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802f9a:	55                   	push   %ebp
  802f9b:	89 e5                	mov    %esp,%ebp
  802f9d:	56                   	push   %esi
  802f9e:	53                   	push   %ebx
  802f9f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  802fa5:	8b 40 0c             	mov    0xc(%eax),%eax
  802fa8:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802fad:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  802fb8:	b8 03 00 00 00       	mov    $0x3,%eax
  802fbd:	e8 9e fe ff ff       	call   802e60 <fsipc>
  802fc2:	89 c3                	mov    %eax,%ebx
  802fc4:	85 c0                	test   %eax,%eax
  802fc6:	78 4b                	js     803013 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802fc8:	39 c6                	cmp    %eax,%esi
  802fca:	73 16                	jae    802fe2 <devfile_read+0x48>
  802fcc:	68 4c 48 80 00       	push   $0x80484c
  802fd1:	68 1d 3d 80 00       	push   $0x803d1d
  802fd6:	6a 7c                	push   $0x7c
  802fd8:	68 53 48 80 00       	push   $0x804853
  802fdd:	e8 b0 ea ff ff       	call   801a92 <_panic>
	assert(r <= PGSIZE);
  802fe2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802fe7:	7e 16                	jle    802fff <devfile_read+0x65>
  802fe9:	68 5e 48 80 00       	push   $0x80485e
  802fee:	68 1d 3d 80 00       	push   $0x803d1d
  802ff3:	6a 7d                	push   $0x7d
  802ff5:	68 53 48 80 00       	push   $0x804853
  802ffa:	e8 93 ea ff ff       	call   801a92 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802fff:	83 ec 04             	sub    $0x4,%esp
  803002:	50                   	push   %eax
  803003:	68 00 b0 80 00       	push   $0x80b000
  803008:	ff 75 0c             	pushl  0xc(%ebp)
  80300b:	e8 72 f2 ff ff       	call   802282 <memmove>
	return r;
  803010:	83 c4 10             	add    $0x10,%esp
}
  803013:	89 d8                	mov    %ebx,%eax
  803015:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803018:	5b                   	pop    %ebx
  803019:	5e                   	pop    %esi
  80301a:	5d                   	pop    %ebp
  80301b:	c3                   	ret    

0080301c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80301c:	55                   	push   %ebp
  80301d:	89 e5                	mov    %esp,%ebp
  80301f:	53                   	push   %ebx
  803020:	83 ec 20             	sub    $0x20,%esp
  803023:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  803026:	53                   	push   %ebx
  803027:	e8 8b f0 ff ff       	call   8020b7 <strlen>
  80302c:	83 c4 10             	add    $0x10,%esp
  80302f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803034:	7f 67                	jg     80309d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  803036:	83 ec 0c             	sub    $0xc,%esp
  803039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80303c:	50                   	push   %eax
  80303d:	e8 96 f8 ff ff       	call   8028d8 <fd_alloc>
  803042:	83 c4 10             	add    $0x10,%esp
		return r;
  803045:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  803047:	85 c0                	test   %eax,%eax
  803049:	78 57                	js     8030a2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80304b:	83 ec 08             	sub    $0x8,%esp
  80304e:	53                   	push   %ebx
  80304f:	68 00 b0 80 00       	push   $0x80b000
  803054:	e8 97 f0 ff ff       	call   8020f0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803059:	8b 45 0c             	mov    0xc(%ebp),%eax
  80305c:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803061:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803064:	b8 01 00 00 00       	mov    $0x1,%eax
  803069:	e8 f2 fd ff ff       	call   802e60 <fsipc>
  80306e:	89 c3                	mov    %eax,%ebx
  803070:	83 c4 10             	add    $0x10,%esp
  803073:	85 c0                	test   %eax,%eax
  803075:	79 14                	jns    80308b <open+0x6f>
		fd_close(fd, 0);
  803077:	83 ec 08             	sub    $0x8,%esp
  80307a:	6a 00                	push   $0x0
  80307c:	ff 75 f4             	pushl  -0xc(%ebp)
  80307f:	e8 4c f9 ff ff       	call   8029d0 <fd_close>
		return r;
  803084:	83 c4 10             	add    $0x10,%esp
  803087:	89 da                	mov    %ebx,%edx
  803089:	eb 17                	jmp    8030a2 <open+0x86>
	}

	return fd2num(fd);
  80308b:	83 ec 0c             	sub    $0xc,%esp
  80308e:	ff 75 f4             	pushl  -0xc(%ebp)
  803091:	e8 1b f8 ff ff       	call   8028b1 <fd2num>
  803096:	89 c2                	mov    %eax,%edx
  803098:	83 c4 10             	add    $0x10,%esp
  80309b:	eb 05                	jmp    8030a2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80309d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8030a2:	89 d0                	mov    %edx,%eax
  8030a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030a7:	c9                   	leave  
  8030a8:	c3                   	ret    

008030a9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8030a9:	55                   	push   %ebp
  8030aa:	89 e5                	mov    %esp,%ebp
  8030ac:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8030af:	ba 00 00 00 00       	mov    $0x0,%edx
  8030b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8030b9:	e8 a2 fd ff ff       	call   802e60 <fsipc>
}
  8030be:	c9                   	leave  
  8030bf:	c3                   	ret    

008030c0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8030c0:	55                   	push   %ebp
  8030c1:	89 e5                	mov    %esp,%ebp
  8030c3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030c6:	89 d0                	mov    %edx,%eax
  8030c8:	c1 e8 16             	shr    $0x16,%eax
  8030cb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030d2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030d7:	f6 c1 01             	test   $0x1,%cl
  8030da:	74 1d                	je     8030f9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8030dc:	c1 ea 0c             	shr    $0xc,%edx
  8030df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8030e6:	f6 c2 01             	test   $0x1,%dl
  8030e9:	74 0e                	je     8030f9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030eb:	c1 ea 0c             	shr    $0xc,%edx
  8030ee:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8030f5:	ef 
  8030f6:	0f b7 c0             	movzwl %ax,%eax
}
  8030f9:	5d                   	pop    %ebp
  8030fa:	c3                   	ret    

008030fb <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8030fb:	55                   	push   %ebp
  8030fc:	89 e5                	mov    %esp,%ebp
  8030fe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  803101:	68 6a 48 80 00       	push   $0x80486a
  803106:	ff 75 0c             	pushl  0xc(%ebp)
  803109:	e8 e2 ef ff ff       	call   8020f0 <strcpy>
	return 0;
}
  80310e:	b8 00 00 00 00       	mov    $0x0,%eax
  803113:	c9                   	leave  
  803114:	c3                   	ret    

00803115 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803115:	55                   	push   %ebp
  803116:	89 e5                	mov    %esp,%ebp
  803118:	53                   	push   %ebx
  803119:	83 ec 10             	sub    $0x10,%esp
  80311c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80311f:	53                   	push   %ebx
  803120:	e8 9b ff ff ff       	call   8030c0 <pageref>
  803125:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  803128:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80312d:	83 f8 01             	cmp    $0x1,%eax
  803130:	75 10                	jne    803142 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  803132:	83 ec 0c             	sub    $0xc,%esp
  803135:	ff 73 0c             	pushl  0xc(%ebx)
  803138:	e8 c0 02 00 00       	call   8033fd <nsipc_close>
  80313d:	89 c2                	mov    %eax,%edx
  80313f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  803142:	89 d0                	mov    %edx,%eax
  803144:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803147:	c9                   	leave  
  803148:	c3                   	ret    

00803149 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  803149:	55                   	push   %ebp
  80314a:	89 e5                	mov    %esp,%ebp
  80314c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80314f:	6a 00                	push   $0x0
  803151:	ff 75 10             	pushl  0x10(%ebp)
  803154:	ff 75 0c             	pushl  0xc(%ebp)
  803157:	8b 45 08             	mov    0x8(%ebp),%eax
  80315a:	ff 70 0c             	pushl  0xc(%eax)
  80315d:	e8 78 03 00 00       	call   8034da <nsipc_send>
}
  803162:	c9                   	leave  
  803163:	c3                   	ret    

00803164 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  803164:	55                   	push   %ebp
  803165:	89 e5                	mov    %esp,%ebp
  803167:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80316a:	6a 00                	push   $0x0
  80316c:	ff 75 10             	pushl  0x10(%ebp)
  80316f:	ff 75 0c             	pushl  0xc(%ebp)
  803172:	8b 45 08             	mov    0x8(%ebp),%eax
  803175:	ff 70 0c             	pushl  0xc(%eax)
  803178:	e8 f1 02 00 00       	call   80346e <nsipc_recv>
}
  80317d:	c9                   	leave  
  80317e:	c3                   	ret    

0080317f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80317f:	55                   	push   %ebp
  803180:	89 e5                	mov    %esp,%ebp
  803182:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  803185:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803188:	52                   	push   %edx
  803189:	50                   	push   %eax
  80318a:	e8 98 f7 ff ff       	call   802927 <fd_lookup>
  80318f:	83 c4 10             	add    $0x10,%esp
  803192:	85 c0                	test   %eax,%eax
  803194:	78 17                	js     8031ad <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  803196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803199:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  80319f:	39 08                	cmp    %ecx,(%eax)
  8031a1:	75 05                	jne    8031a8 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8031a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8031a6:	eb 05                	jmp    8031ad <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8031a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8031ad:	c9                   	leave  
  8031ae:	c3                   	ret    

008031af <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8031af:	55                   	push   %ebp
  8031b0:	89 e5                	mov    %esp,%ebp
  8031b2:	56                   	push   %esi
  8031b3:	53                   	push   %ebx
  8031b4:	83 ec 1c             	sub    $0x1c,%esp
  8031b7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8031b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031bc:	50                   	push   %eax
  8031bd:	e8 16 f7 ff ff       	call   8028d8 <fd_alloc>
  8031c2:	89 c3                	mov    %eax,%ebx
  8031c4:	83 c4 10             	add    $0x10,%esp
  8031c7:	85 c0                	test   %eax,%eax
  8031c9:	78 1b                	js     8031e6 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8031cb:	83 ec 04             	sub    $0x4,%esp
  8031ce:	68 07 04 00 00       	push   $0x407
  8031d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8031d6:	6a 00                	push   $0x0
  8031d8:	e8 16 f3 ff ff       	call   8024f3 <sys_page_alloc>
  8031dd:	89 c3                	mov    %eax,%ebx
  8031df:	83 c4 10             	add    $0x10,%esp
  8031e2:	85 c0                	test   %eax,%eax
  8031e4:	79 10                	jns    8031f6 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8031e6:	83 ec 0c             	sub    $0xc,%esp
  8031e9:	56                   	push   %esi
  8031ea:	e8 0e 02 00 00       	call   8033fd <nsipc_close>
		return r;
  8031ef:	83 c4 10             	add    $0x10,%esp
  8031f2:	89 d8                	mov    %ebx,%eax
  8031f4:	eb 24                	jmp    80321a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8031f6:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8031fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031ff:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  803201:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803204:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80320b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80320e:	83 ec 0c             	sub    $0xc,%esp
  803211:	50                   	push   %eax
  803212:	e8 9a f6 ff ff       	call   8028b1 <fd2num>
  803217:	83 c4 10             	add    $0x10,%esp
}
  80321a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80321d:	5b                   	pop    %ebx
  80321e:	5e                   	pop    %esi
  80321f:	5d                   	pop    %ebp
  803220:	c3                   	ret    

00803221 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803221:	55                   	push   %ebp
  803222:	89 e5                	mov    %esp,%ebp
  803224:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803227:	8b 45 08             	mov    0x8(%ebp),%eax
  80322a:	e8 50 ff ff ff       	call   80317f <fd2sockid>
		return r;
  80322f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  803231:	85 c0                	test   %eax,%eax
  803233:	78 1f                	js     803254 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803235:	83 ec 04             	sub    $0x4,%esp
  803238:	ff 75 10             	pushl  0x10(%ebp)
  80323b:	ff 75 0c             	pushl  0xc(%ebp)
  80323e:	50                   	push   %eax
  80323f:	e8 12 01 00 00       	call   803356 <nsipc_accept>
  803244:	83 c4 10             	add    $0x10,%esp
		return r;
  803247:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803249:	85 c0                	test   %eax,%eax
  80324b:	78 07                	js     803254 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80324d:	e8 5d ff ff ff       	call   8031af <alloc_sockfd>
  803252:	89 c1                	mov    %eax,%ecx
}
  803254:	89 c8                	mov    %ecx,%eax
  803256:	c9                   	leave  
  803257:	c3                   	ret    

00803258 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803258:	55                   	push   %ebp
  803259:	89 e5                	mov    %esp,%ebp
  80325b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80325e:	8b 45 08             	mov    0x8(%ebp),%eax
  803261:	e8 19 ff ff ff       	call   80317f <fd2sockid>
  803266:	85 c0                	test   %eax,%eax
  803268:	78 12                	js     80327c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80326a:	83 ec 04             	sub    $0x4,%esp
  80326d:	ff 75 10             	pushl  0x10(%ebp)
  803270:	ff 75 0c             	pushl  0xc(%ebp)
  803273:	50                   	push   %eax
  803274:	e8 2d 01 00 00       	call   8033a6 <nsipc_bind>
  803279:	83 c4 10             	add    $0x10,%esp
}
  80327c:	c9                   	leave  
  80327d:	c3                   	ret    

0080327e <shutdown>:

int
shutdown(int s, int how)
{
  80327e:	55                   	push   %ebp
  80327f:	89 e5                	mov    %esp,%ebp
  803281:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803284:	8b 45 08             	mov    0x8(%ebp),%eax
  803287:	e8 f3 fe ff ff       	call   80317f <fd2sockid>
  80328c:	85 c0                	test   %eax,%eax
  80328e:	78 0f                	js     80329f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  803290:	83 ec 08             	sub    $0x8,%esp
  803293:	ff 75 0c             	pushl  0xc(%ebp)
  803296:	50                   	push   %eax
  803297:	e8 3f 01 00 00       	call   8033db <nsipc_shutdown>
  80329c:	83 c4 10             	add    $0x10,%esp
}
  80329f:	c9                   	leave  
  8032a0:	c3                   	ret    

008032a1 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8032a1:	55                   	push   %ebp
  8032a2:	89 e5                	mov    %esp,%ebp
  8032a4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8032aa:	e8 d0 fe ff ff       	call   80317f <fd2sockid>
  8032af:	85 c0                	test   %eax,%eax
  8032b1:	78 12                	js     8032c5 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8032b3:	83 ec 04             	sub    $0x4,%esp
  8032b6:	ff 75 10             	pushl  0x10(%ebp)
  8032b9:	ff 75 0c             	pushl  0xc(%ebp)
  8032bc:	50                   	push   %eax
  8032bd:	e8 55 01 00 00       	call   803417 <nsipc_connect>
  8032c2:	83 c4 10             	add    $0x10,%esp
}
  8032c5:	c9                   	leave  
  8032c6:	c3                   	ret    

008032c7 <listen>:

int
listen(int s, int backlog)
{
  8032c7:	55                   	push   %ebp
  8032c8:	89 e5                	mov    %esp,%ebp
  8032ca:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8032d0:	e8 aa fe ff ff       	call   80317f <fd2sockid>
  8032d5:	85 c0                	test   %eax,%eax
  8032d7:	78 0f                	js     8032e8 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8032d9:	83 ec 08             	sub    $0x8,%esp
  8032dc:	ff 75 0c             	pushl  0xc(%ebp)
  8032df:	50                   	push   %eax
  8032e0:	e8 67 01 00 00       	call   80344c <nsipc_listen>
  8032e5:	83 c4 10             	add    $0x10,%esp
}
  8032e8:	c9                   	leave  
  8032e9:	c3                   	ret    

008032ea <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8032ea:	55                   	push   %ebp
  8032eb:	89 e5                	mov    %esp,%ebp
  8032ed:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8032f0:	ff 75 10             	pushl  0x10(%ebp)
  8032f3:	ff 75 0c             	pushl  0xc(%ebp)
  8032f6:	ff 75 08             	pushl  0x8(%ebp)
  8032f9:	e8 3a 02 00 00       	call   803538 <nsipc_socket>
  8032fe:	83 c4 10             	add    $0x10,%esp
  803301:	85 c0                	test   %eax,%eax
  803303:	78 05                	js     80330a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  803305:	e8 a5 fe ff ff       	call   8031af <alloc_sockfd>
}
  80330a:	c9                   	leave  
  80330b:	c3                   	ret    

0080330c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80330c:	55                   	push   %ebp
  80330d:	89 e5                	mov    %esp,%ebp
  80330f:	53                   	push   %ebx
  803310:	83 ec 04             	sub    $0x4,%esp
  803313:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  803315:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  80331c:	75 12                	jne    803330 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80331e:	83 ec 0c             	sub    $0xc,%esp
  803321:	6a 02                	push   $0x2
  803323:	e8 50 f5 ff ff       	call   802878 <ipc_find_env>
  803328:	a3 04 a0 80 00       	mov    %eax,0x80a004
  80332d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803330:	6a 07                	push   $0x7
  803332:	68 00 c0 80 00       	push   $0x80c000
  803337:	53                   	push   %ebx
  803338:	ff 35 04 a0 80 00    	pushl  0x80a004
  80333e:	e8 e1 f4 ff ff       	call   802824 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  803343:	83 c4 0c             	add    $0xc,%esp
  803346:	6a 00                	push   $0x0
  803348:	6a 00                	push   $0x0
  80334a:	6a 00                	push   $0x0
  80334c:	e8 66 f4 ff ff       	call   8027b7 <ipc_recv>
}
  803351:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803354:	c9                   	leave  
  803355:	c3                   	ret    

00803356 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803356:	55                   	push   %ebp
  803357:	89 e5                	mov    %esp,%ebp
  803359:	56                   	push   %esi
  80335a:	53                   	push   %ebx
  80335b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80335e:	8b 45 08             	mov    0x8(%ebp),%eax
  803361:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  803366:	8b 06                	mov    (%esi),%eax
  803368:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80336d:	b8 01 00 00 00       	mov    $0x1,%eax
  803372:	e8 95 ff ff ff       	call   80330c <nsipc>
  803377:	89 c3                	mov    %eax,%ebx
  803379:	85 c0                	test   %eax,%eax
  80337b:	78 20                	js     80339d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80337d:	83 ec 04             	sub    $0x4,%esp
  803380:	ff 35 10 c0 80 00    	pushl  0x80c010
  803386:	68 00 c0 80 00       	push   $0x80c000
  80338b:	ff 75 0c             	pushl  0xc(%ebp)
  80338e:	e8 ef ee ff ff       	call   802282 <memmove>
		*addrlen = ret->ret_addrlen;
  803393:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803398:	89 06                	mov    %eax,(%esi)
  80339a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80339d:	89 d8                	mov    %ebx,%eax
  80339f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8033a2:	5b                   	pop    %ebx
  8033a3:	5e                   	pop    %esi
  8033a4:	5d                   	pop    %ebp
  8033a5:	c3                   	ret    

008033a6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8033a6:	55                   	push   %ebp
  8033a7:	89 e5                	mov    %esp,%ebp
  8033a9:	53                   	push   %ebx
  8033aa:	83 ec 08             	sub    $0x8,%esp
  8033ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8033b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8033b3:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8033b8:	53                   	push   %ebx
  8033b9:	ff 75 0c             	pushl  0xc(%ebp)
  8033bc:	68 04 c0 80 00       	push   $0x80c004
  8033c1:	e8 bc ee ff ff       	call   802282 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8033c6:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  8033cc:	b8 02 00 00 00       	mov    $0x2,%eax
  8033d1:	e8 36 ff ff ff       	call   80330c <nsipc>
}
  8033d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033d9:	c9                   	leave  
  8033da:	c3                   	ret    

008033db <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8033db:	55                   	push   %ebp
  8033dc:	89 e5                	mov    %esp,%ebp
  8033de:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8033e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8033e4:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  8033e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033ec:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  8033f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8033f6:	e8 11 ff ff ff       	call   80330c <nsipc>
}
  8033fb:	c9                   	leave  
  8033fc:	c3                   	ret    

008033fd <nsipc_close>:

int
nsipc_close(int s)
{
  8033fd:	55                   	push   %ebp
  8033fe:	89 e5                	mov    %esp,%ebp
  803400:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803403:	8b 45 08             	mov    0x8(%ebp),%eax
  803406:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  80340b:	b8 04 00 00 00       	mov    $0x4,%eax
  803410:	e8 f7 fe ff ff       	call   80330c <nsipc>
}
  803415:	c9                   	leave  
  803416:	c3                   	ret    

00803417 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803417:	55                   	push   %ebp
  803418:	89 e5                	mov    %esp,%ebp
  80341a:	53                   	push   %ebx
  80341b:	83 ec 08             	sub    $0x8,%esp
  80341e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  803421:	8b 45 08             	mov    0x8(%ebp),%eax
  803424:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803429:	53                   	push   %ebx
  80342a:	ff 75 0c             	pushl  0xc(%ebp)
  80342d:	68 04 c0 80 00       	push   $0x80c004
  803432:	e8 4b ee ff ff       	call   802282 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  803437:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  80343d:	b8 05 00 00 00       	mov    $0x5,%eax
  803442:	e8 c5 fe ff ff       	call   80330c <nsipc>
}
  803447:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80344a:	c9                   	leave  
  80344b:	c3                   	ret    

0080344c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80344c:	55                   	push   %ebp
  80344d:	89 e5                	mov    %esp,%ebp
  80344f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  803452:	8b 45 08             	mov    0x8(%ebp),%eax
  803455:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  80345a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80345d:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  803462:	b8 06 00 00 00       	mov    $0x6,%eax
  803467:	e8 a0 fe ff ff       	call   80330c <nsipc>
}
  80346c:	c9                   	leave  
  80346d:	c3                   	ret    

0080346e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80346e:	55                   	push   %ebp
  80346f:	89 e5                	mov    %esp,%ebp
  803471:	56                   	push   %esi
  803472:	53                   	push   %ebx
  803473:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803476:	8b 45 08             	mov    0x8(%ebp),%eax
  803479:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  80347e:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  803484:	8b 45 14             	mov    0x14(%ebp),%eax
  803487:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80348c:	b8 07 00 00 00       	mov    $0x7,%eax
  803491:	e8 76 fe ff ff       	call   80330c <nsipc>
  803496:	89 c3                	mov    %eax,%ebx
  803498:	85 c0                	test   %eax,%eax
  80349a:	78 35                	js     8034d1 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80349c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8034a1:	7f 04                	jg     8034a7 <nsipc_recv+0x39>
  8034a3:	39 c6                	cmp    %eax,%esi
  8034a5:	7d 16                	jge    8034bd <nsipc_recv+0x4f>
  8034a7:	68 76 48 80 00       	push   $0x804876
  8034ac:	68 1d 3d 80 00       	push   $0x803d1d
  8034b1:	6a 62                	push   $0x62
  8034b3:	68 8b 48 80 00       	push   $0x80488b
  8034b8:	e8 d5 e5 ff ff       	call   801a92 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8034bd:	83 ec 04             	sub    $0x4,%esp
  8034c0:	50                   	push   %eax
  8034c1:	68 00 c0 80 00       	push   $0x80c000
  8034c6:	ff 75 0c             	pushl  0xc(%ebp)
  8034c9:	e8 b4 ed ff ff       	call   802282 <memmove>
  8034ce:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8034d1:	89 d8                	mov    %ebx,%eax
  8034d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8034d6:	5b                   	pop    %ebx
  8034d7:	5e                   	pop    %esi
  8034d8:	5d                   	pop    %ebp
  8034d9:	c3                   	ret    

008034da <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8034da:	55                   	push   %ebp
  8034db:	89 e5                	mov    %esp,%ebp
  8034dd:	53                   	push   %ebx
  8034de:	83 ec 04             	sub    $0x4,%esp
  8034e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8034e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8034e7:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  8034ec:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8034f2:	7e 16                	jle    80350a <nsipc_send+0x30>
  8034f4:	68 97 48 80 00       	push   $0x804897
  8034f9:	68 1d 3d 80 00       	push   $0x803d1d
  8034fe:	6a 6d                	push   $0x6d
  803500:	68 8b 48 80 00       	push   $0x80488b
  803505:	e8 88 e5 ff ff       	call   801a92 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80350a:	83 ec 04             	sub    $0x4,%esp
  80350d:	53                   	push   %ebx
  80350e:	ff 75 0c             	pushl  0xc(%ebp)
  803511:	68 0c c0 80 00       	push   $0x80c00c
  803516:	e8 67 ed ff ff       	call   802282 <memmove>
	nsipcbuf.send.req_size = size;
  80351b:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  803521:	8b 45 14             	mov    0x14(%ebp),%eax
  803524:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  803529:	b8 08 00 00 00       	mov    $0x8,%eax
  80352e:	e8 d9 fd ff ff       	call   80330c <nsipc>
}
  803533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803536:	c9                   	leave  
  803537:	c3                   	ret    

00803538 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  803538:	55                   	push   %ebp
  803539:	89 e5                	mov    %esp,%ebp
  80353b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80353e:	8b 45 08             	mov    0x8(%ebp),%eax
  803541:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  803546:	8b 45 0c             	mov    0xc(%ebp),%eax
  803549:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  80354e:	8b 45 10             	mov    0x10(%ebp),%eax
  803551:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  803556:	b8 09 00 00 00       	mov    $0x9,%eax
  80355b:	e8 ac fd ff ff       	call   80330c <nsipc>
}
  803560:	c9                   	leave  
  803561:	c3                   	ret    

00803562 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803562:	55                   	push   %ebp
  803563:	89 e5                	mov    %esp,%ebp
  803565:	56                   	push   %esi
  803566:	53                   	push   %ebx
  803567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80356a:	83 ec 0c             	sub    $0xc,%esp
  80356d:	ff 75 08             	pushl  0x8(%ebp)
  803570:	e8 4c f3 ff ff       	call   8028c1 <fd2data>
  803575:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803577:	83 c4 08             	add    $0x8,%esp
  80357a:	68 a3 48 80 00       	push   $0x8048a3
  80357f:	53                   	push   %ebx
  803580:	e8 6b eb ff ff       	call   8020f0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803585:	8b 46 04             	mov    0x4(%esi),%eax
  803588:	2b 06                	sub    (%esi),%eax
  80358a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803590:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803597:	00 00 00 
	stat->st_dev = &devpipe;
  80359a:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  8035a1:	90 80 00 
	return 0;
}
  8035a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8035a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8035ac:	5b                   	pop    %ebx
  8035ad:	5e                   	pop    %esi
  8035ae:	5d                   	pop    %ebp
  8035af:	c3                   	ret    

008035b0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8035b0:	55                   	push   %ebp
  8035b1:	89 e5                	mov    %esp,%ebp
  8035b3:	53                   	push   %ebx
  8035b4:	83 ec 0c             	sub    $0xc,%esp
  8035b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8035ba:	53                   	push   %ebx
  8035bb:	6a 00                	push   $0x0
  8035bd:	e8 b6 ef ff ff       	call   802578 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8035c2:	89 1c 24             	mov    %ebx,(%esp)
  8035c5:	e8 f7 f2 ff ff       	call   8028c1 <fd2data>
  8035ca:	83 c4 08             	add    $0x8,%esp
  8035cd:	50                   	push   %eax
  8035ce:	6a 00                	push   $0x0
  8035d0:	e8 a3 ef ff ff       	call   802578 <sys_page_unmap>
}
  8035d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8035d8:	c9                   	leave  
  8035d9:	c3                   	ret    

008035da <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8035da:	55                   	push   %ebp
  8035db:	89 e5                	mov    %esp,%ebp
  8035dd:	57                   	push   %edi
  8035de:	56                   	push   %esi
  8035df:	53                   	push   %ebx
  8035e0:	83 ec 1c             	sub    $0x1c,%esp
  8035e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8035e6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8035e8:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8035ed:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8035f0:	83 ec 0c             	sub    $0xc,%esp
  8035f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8035f6:	e8 c5 fa ff ff       	call   8030c0 <pageref>
  8035fb:	89 c3                	mov    %eax,%ebx
  8035fd:	89 3c 24             	mov    %edi,(%esp)
  803600:	e8 bb fa ff ff       	call   8030c0 <pageref>
  803605:	83 c4 10             	add    $0x10,%esp
  803608:	39 c3                	cmp    %eax,%ebx
  80360a:	0f 94 c1             	sete   %cl
  80360d:	0f b6 c9             	movzbl %cl,%ecx
  803610:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  803613:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  803619:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80361c:	39 ce                	cmp    %ecx,%esi
  80361e:	74 1b                	je     80363b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803620:	39 c3                	cmp    %eax,%ebx
  803622:	75 c4                	jne    8035e8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803624:	8b 42 58             	mov    0x58(%edx),%eax
  803627:	ff 75 e4             	pushl  -0x1c(%ebp)
  80362a:	50                   	push   %eax
  80362b:	56                   	push   %esi
  80362c:	68 aa 48 80 00       	push   $0x8048aa
  803631:	e8 35 e5 ff ff       	call   801b6b <cprintf>
  803636:	83 c4 10             	add    $0x10,%esp
  803639:	eb ad                	jmp    8035e8 <_pipeisclosed+0xe>
	}
}
  80363b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80363e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803641:	5b                   	pop    %ebx
  803642:	5e                   	pop    %esi
  803643:	5f                   	pop    %edi
  803644:	5d                   	pop    %ebp
  803645:	c3                   	ret    

00803646 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803646:	55                   	push   %ebp
  803647:	89 e5                	mov    %esp,%ebp
  803649:	57                   	push   %edi
  80364a:	56                   	push   %esi
  80364b:	53                   	push   %ebx
  80364c:	83 ec 28             	sub    $0x28,%esp
  80364f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803652:	56                   	push   %esi
  803653:	e8 69 f2 ff ff       	call   8028c1 <fd2data>
  803658:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80365a:	83 c4 10             	add    $0x10,%esp
  80365d:	bf 00 00 00 00       	mov    $0x0,%edi
  803662:	eb 4b                	jmp    8036af <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803664:	89 da                	mov    %ebx,%edx
  803666:	89 f0                	mov    %esi,%eax
  803668:	e8 6d ff ff ff       	call   8035da <_pipeisclosed>
  80366d:	85 c0                	test   %eax,%eax
  80366f:	75 48                	jne    8036b9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803671:	e8 5e ee ff ff       	call   8024d4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803676:	8b 43 04             	mov    0x4(%ebx),%eax
  803679:	8b 0b                	mov    (%ebx),%ecx
  80367b:	8d 51 20             	lea    0x20(%ecx),%edx
  80367e:	39 d0                	cmp    %edx,%eax
  803680:	73 e2                	jae    803664 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803682:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803685:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803689:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80368c:	89 c2                	mov    %eax,%edx
  80368e:	c1 fa 1f             	sar    $0x1f,%edx
  803691:	89 d1                	mov    %edx,%ecx
  803693:	c1 e9 1b             	shr    $0x1b,%ecx
  803696:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803699:	83 e2 1f             	and    $0x1f,%edx
  80369c:	29 ca                	sub    %ecx,%edx
  80369e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8036a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8036a6:	83 c0 01             	add    $0x1,%eax
  8036a9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8036ac:	83 c7 01             	add    $0x1,%edi
  8036af:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8036b2:	75 c2                	jne    803676 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8036b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8036b7:	eb 05                	jmp    8036be <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8036b9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8036be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036c1:	5b                   	pop    %ebx
  8036c2:	5e                   	pop    %esi
  8036c3:	5f                   	pop    %edi
  8036c4:	5d                   	pop    %ebp
  8036c5:	c3                   	ret    

008036c6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8036c6:	55                   	push   %ebp
  8036c7:	89 e5                	mov    %esp,%ebp
  8036c9:	57                   	push   %edi
  8036ca:	56                   	push   %esi
  8036cb:	53                   	push   %ebx
  8036cc:	83 ec 18             	sub    $0x18,%esp
  8036cf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8036d2:	57                   	push   %edi
  8036d3:	e8 e9 f1 ff ff       	call   8028c1 <fd2data>
  8036d8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8036da:	83 c4 10             	add    $0x10,%esp
  8036dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8036e2:	eb 3d                	jmp    803721 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8036e4:	85 db                	test   %ebx,%ebx
  8036e6:	74 04                	je     8036ec <devpipe_read+0x26>
				return i;
  8036e8:	89 d8                	mov    %ebx,%eax
  8036ea:	eb 44                	jmp    803730 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8036ec:	89 f2                	mov    %esi,%edx
  8036ee:	89 f8                	mov    %edi,%eax
  8036f0:	e8 e5 fe ff ff       	call   8035da <_pipeisclosed>
  8036f5:	85 c0                	test   %eax,%eax
  8036f7:	75 32                	jne    80372b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8036f9:	e8 d6 ed ff ff       	call   8024d4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8036fe:	8b 06                	mov    (%esi),%eax
  803700:	3b 46 04             	cmp    0x4(%esi),%eax
  803703:	74 df                	je     8036e4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803705:	99                   	cltd   
  803706:	c1 ea 1b             	shr    $0x1b,%edx
  803709:	01 d0                	add    %edx,%eax
  80370b:	83 e0 1f             	and    $0x1f,%eax
  80370e:	29 d0                	sub    %edx,%eax
  803710:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803715:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803718:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80371b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80371e:	83 c3 01             	add    $0x1,%ebx
  803721:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803724:	75 d8                	jne    8036fe <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803726:	8b 45 10             	mov    0x10(%ebp),%eax
  803729:	eb 05                	jmp    803730 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80372b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803730:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803733:	5b                   	pop    %ebx
  803734:	5e                   	pop    %esi
  803735:	5f                   	pop    %edi
  803736:	5d                   	pop    %ebp
  803737:	c3                   	ret    

00803738 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803738:	55                   	push   %ebp
  803739:	89 e5                	mov    %esp,%ebp
  80373b:	56                   	push   %esi
  80373c:	53                   	push   %ebx
  80373d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803743:	50                   	push   %eax
  803744:	e8 8f f1 ff ff       	call   8028d8 <fd_alloc>
  803749:	83 c4 10             	add    $0x10,%esp
  80374c:	89 c2                	mov    %eax,%edx
  80374e:	85 c0                	test   %eax,%eax
  803750:	0f 88 2c 01 00 00    	js     803882 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803756:	83 ec 04             	sub    $0x4,%esp
  803759:	68 07 04 00 00       	push   $0x407
  80375e:	ff 75 f4             	pushl  -0xc(%ebp)
  803761:	6a 00                	push   $0x0
  803763:	e8 8b ed ff ff       	call   8024f3 <sys_page_alloc>
  803768:	83 c4 10             	add    $0x10,%esp
  80376b:	89 c2                	mov    %eax,%edx
  80376d:	85 c0                	test   %eax,%eax
  80376f:	0f 88 0d 01 00 00    	js     803882 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803775:	83 ec 0c             	sub    $0xc,%esp
  803778:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80377b:	50                   	push   %eax
  80377c:	e8 57 f1 ff ff       	call   8028d8 <fd_alloc>
  803781:	89 c3                	mov    %eax,%ebx
  803783:	83 c4 10             	add    $0x10,%esp
  803786:	85 c0                	test   %eax,%eax
  803788:	0f 88 e2 00 00 00    	js     803870 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80378e:	83 ec 04             	sub    $0x4,%esp
  803791:	68 07 04 00 00       	push   $0x407
  803796:	ff 75 f0             	pushl  -0x10(%ebp)
  803799:	6a 00                	push   $0x0
  80379b:	e8 53 ed ff ff       	call   8024f3 <sys_page_alloc>
  8037a0:	89 c3                	mov    %eax,%ebx
  8037a2:	83 c4 10             	add    $0x10,%esp
  8037a5:	85 c0                	test   %eax,%eax
  8037a7:	0f 88 c3 00 00 00    	js     803870 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8037ad:	83 ec 0c             	sub    $0xc,%esp
  8037b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8037b3:	e8 09 f1 ff ff       	call   8028c1 <fd2data>
  8037b8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037ba:	83 c4 0c             	add    $0xc,%esp
  8037bd:	68 07 04 00 00       	push   $0x407
  8037c2:	50                   	push   %eax
  8037c3:	6a 00                	push   $0x0
  8037c5:	e8 29 ed ff ff       	call   8024f3 <sys_page_alloc>
  8037ca:	89 c3                	mov    %eax,%ebx
  8037cc:	83 c4 10             	add    $0x10,%esp
  8037cf:	85 c0                	test   %eax,%eax
  8037d1:	0f 88 89 00 00 00    	js     803860 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037d7:	83 ec 0c             	sub    $0xc,%esp
  8037da:	ff 75 f0             	pushl  -0x10(%ebp)
  8037dd:	e8 df f0 ff ff       	call   8028c1 <fd2data>
  8037e2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8037e9:	50                   	push   %eax
  8037ea:	6a 00                	push   $0x0
  8037ec:	56                   	push   %esi
  8037ed:	6a 00                	push   $0x0
  8037ef:	e8 42 ed ff ff       	call   802536 <sys_page_map>
  8037f4:	89 c3                	mov    %eax,%ebx
  8037f6:	83 c4 20             	add    $0x20,%esp
  8037f9:	85 c0                	test   %eax,%eax
  8037fb:	78 55                	js     803852 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8037fd:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803803:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803806:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80380b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803812:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803818:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80381b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80381d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803820:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803827:	83 ec 0c             	sub    $0xc,%esp
  80382a:	ff 75 f4             	pushl  -0xc(%ebp)
  80382d:	e8 7f f0 ff ff       	call   8028b1 <fd2num>
  803832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803835:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803837:	83 c4 04             	add    $0x4,%esp
  80383a:	ff 75 f0             	pushl  -0x10(%ebp)
  80383d:	e8 6f f0 ff ff       	call   8028b1 <fd2num>
  803842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803845:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803848:	83 c4 10             	add    $0x10,%esp
  80384b:	ba 00 00 00 00       	mov    $0x0,%edx
  803850:	eb 30                	jmp    803882 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803852:	83 ec 08             	sub    $0x8,%esp
  803855:	56                   	push   %esi
  803856:	6a 00                	push   $0x0
  803858:	e8 1b ed ff ff       	call   802578 <sys_page_unmap>
  80385d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803860:	83 ec 08             	sub    $0x8,%esp
  803863:	ff 75 f0             	pushl  -0x10(%ebp)
  803866:	6a 00                	push   $0x0
  803868:	e8 0b ed ff ff       	call   802578 <sys_page_unmap>
  80386d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803870:	83 ec 08             	sub    $0x8,%esp
  803873:	ff 75 f4             	pushl  -0xc(%ebp)
  803876:	6a 00                	push   $0x0
  803878:	e8 fb ec ff ff       	call   802578 <sys_page_unmap>
  80387d:	83 c4 10             	add    $0x10,%esp
  803880:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803882:	89 d0                	mov    %edx,%eax
  803884:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803887:	5b                   	pop    %ebx
  803888:	5e                   	pop    %esi
  803889:	5d                   	pop    %ebp
  80388a:	c3                   	ret    

0080388b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80388b:	55                   	push   %ebp
  80388c:	89 e5                	mov    %esp,%ebp
  80388e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803891:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803894:	50                   	push   %eax
  803895:	ff 75 08             	pushl  0x8(%ebp)
  803898:	e8 8a f0 ff ff       	call   802927 <fd_lookup>
  80389d:	83 c4 10             	add    $0x10,%esp
  8038a0:	85 c0                	test   %eax,%eax
  8038a2:	78 18                	js     8038bc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8038a4:	83 ec 0c             	sub    $0xc,%esp
  8038a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8038aa:	e8 12 f0 ff ff       	call   8028c1 <fd2data>
	return _pipeisclosed(fd, p);
  8038af:	89 c2                	mov    %eax,%edx
  8038b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038b4:	e8 21 fd ff ff       	call   8035da <_pipeisclosed>
  8038b9:	83 c4 10             	add    $0x10,%esp
}
  8038bc:	c9                   	leave  
  8038bd:	c3                   	ret    

008038be <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8038be:	55                   	push   %ebp
  8038bf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8038c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8038c6:	5d                   	pop    %ebp
  8038c7:	c3                   	ret    

008038c8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8038c8:	55                   	push   %ebp
  8038c9:	89 e5                	mov    %esp,%ebp
  8038cb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8038ce:	68 c2 48 80 00       	push   $0x8048c2
  8038d3:	ff 75 0c             	pushl  0xc(%ebp)
  8038d6:	e8 15 e8 ff ff       	call   8020f0 <strcpy>
	return 0;
}
  8038db:	b8 00 00 00 00       	mov    $0x0,%eax
  8038e0:	c9                   	leave  
  8038e1:	c3                   	ret    

008038e2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8038e2:	55                   	push   %ebp
  8038e3:	89 e5                	mov    %esp,%ebp
  8038e5:	57                   	push   %edi
  8038e6:	56                   	push   %esi
  8038e7:	53                   	push   %ebx
  8038e8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8038ee:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8038f3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8038f9:	eb 2d                	jmp    803928 <devcons_write+0x46>
		m = n - tot;
  8038fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8038fe:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803900:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803903:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803908:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80390b:	83 ec 04             	sub    $0x4,%esp
  80390e:	53                   	push   %ebx
  80390f:	03 45 0c             	add    0xc(%ebp),%eax
  803912:	50                   	push   %eax
  803913:	57                   	push   %edi
  803914:	e8 69 e9 ff ff       	call   802282 <memmove>
		sys_cputs(buf, m);
  803919:	83 c4 08             	add    $0x8,%esp
  80391c:	53                   	push   %ebx
  80391d:	57                   	push   %edi
  80391e:	e8 14 eb ff ff       	call   802437 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803923:	01 de                	add    %ebx,%esi
  803925:	83 c4 10             	add    $0x10,%esp
  803928:	89 f0                	mov    %esi,%eax
  80392a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80392d:	72 cc                	jb     8038fb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80392f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803932:	5b                   	pop    %ebx
  803933:	5e                   	pop    %esi
  803934:	5f                   	pop    %edi
  803935:	5d                   	pop    %ebp
  803936:	c3                   	ret    

00803937 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803937:	55                   	push   %ebp
  803938:	89 e5                	mov    %esp,%ebp
  80393a:	83 ec 08             	sub    $0x8,%esp
  80393d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803942:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803946:	74 2a                	je     803972 <devcons_read+0x3b>
  803948:	eb 05                	jmp    80394f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80394a:	e8 85 eb ff ff       	call   8024d4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80394f:	e8 01 eb ff ff       	call   802455 <sys_cgetc>
  803954:	85 c0                	test   %eax,%eax
  803956:	74 f2                	je     80394a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803958:	85 c0                	test   %eax,%eax
  80395a:	78 16                	js     803972 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80395c:	83 f8 04             	cmp    $0x4,%eax
  80395f:	74 0c                	je     80396d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803961:	8b 55 0c             	mov    0xc(%ebp),%edx
  803964:	88 02                	mov    %al,(%edx)
	return 1;
  803966:	b8 01 00 00 00       	mov    $0x1,%eax
  80396b:	eb 05                	jmp    803972 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80396d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803972:	c9                   	leave  
  803973:	c3                   	ret    

00803974 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803974:	55                   	push   %ebp
  803975:	89 e5                	mov    %esp,%ebp
  803977:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80397a:	8b 45 08             	mov    0x8(%ebp),%eax
  80397d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803980:	6a 01                	push   $0x1
  803982:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803985:	50                   	push   %eax
  803986:	e8 ac ea ff ff       	call   802437 <sys_cputs>
}
  80398b:	83 c4 10             	add    $0x10,%esp
  80398e:	c9                   	leave  
  80398f:	c3                   	ret    

00803990 <getchar>:

int
getchar(void)
{
  803990:	55                   	push   %ebp
  803991:	89 e5                	mov    %esp,%ebp
  803993:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803996:	6a 01                	push   $0x1
  803998:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80399b:	50                   	push   %eax
  80399c:	6a 00                	push   $0x0
  80399e:	e8 ea f1 ff ff       	call   802b8d <read>
	if (r < 0)
  8039a3:	83 c4 10             	add    $0x10,%esp
  8039a6:	85 c0                	test   %eax,%eax
  8039a8:	78 0f                	js     8039b9 <getchar+0x29>
		return r;
	if (r < 1)
  8039aa:	85 c0                	test   %eax,%eax
  8039ac:	7e 06                	jle    8039b4 <getchar+0x24>
		return -E_EOF;
	return c;
  8039ae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8039b2:	eb 05                	jmp    8039b9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8039b4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8039b9:	c9                   	leave  
  8039ba:	c3                   	ret    

008039bb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8039bb:	55                   	push   %ebp
  8039bc:	89 e5                	mov    %esp,%ebp
  8039be:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8039c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039c4:	50                   	push   %eax
  8039c5:	ff 75 08             	pushl  0x8(%ebp)
  8039c8:	e8 5a ef ff ff       	call   802927 <fd_lookup>
  8039cd:	83 c4 10             	add    $0x10,%esp
  8039d0:	85 c0                	test   %eax,%eax
  8039d2:	78 11                	js     8039e5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8039d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039d7:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  8039dd:	39 10                	cmp    %edx,(%eax)
  8039df:	0f 94 c0             	sete   %al
  8039e2:	0f b6 c0             	movzbl %al,%eax
}
  8039e5:	c9                   	leave  
  8039e6:	c3                   	ret    

008039e7 <opencons>:

int
opencons(void)
{
  8039e7:	55                   	push   %ebp
  8039e8:	89 e5                	mov    %esp,%ebp
  8039ea:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8039ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039f0:	50                   	push   %eax
  8039f1:	e8 e2 ee ff ff       	call   8028d8 <fd_alloc>
  8039f6:	83 c4 10             	add    $0x10,%esp
		return r;
  8039f9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8039fb:	85 c0                	test   %eax,%eax
  8039fd:	78 3e                	js     803a3d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8039ff:	83 ec 04             	sub    $0x4,%esp
  803a02:	68 07 04 00 00       	push   $0x407
  803a07:	ff 75 f4             	pushl  -0xc(%ebp)
  803a0a:	6a 00                	push   $0x0
  803a0c:	e8 e2 ea ff ff       	call   8024f3 <sys_page_alloc>
  803a11:	83 c4 10             	add    $0x10,%esp
		return r;
  803a14:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a16:	85 c0                	test   %eax,%eax
  803a18:	78 23                	js     803a3d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803a1a:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a23:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a28:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803a2f:	83 ec 0c             	sub    $0xc,%esp
  803a32:	50                   	push   %eax
  803a33:	e8 79 ee ff ff       	call   8028b1 <fd2num>
  803a38:	89 c2                	mov    %eax,%edx
  803a3a:	83 c4 10             	add    $0x10,%esp
}
  803a3d:	89 d0                	mov    %edx,%eax
  803a3f:	c9                   	leave  
  803a40:	c3                   	ret    
  803a41:	66 90                	xchg   %ax,%ax
  803a43:	66 90                	xchg   %ax,%ax
  803a45:	66 90                	xchg   %ax,%ax
  803a47:	66 90                	xchg   %ax,%ax
  803a49:	66 90                	xchg   %ax,%ax
  803a4b:	66 90                	xchg   %ax,%ax
  803a4d:	66 90                	xchg   %ax,%ax
  803a4f:	90                   	nop

00803a50 <__udivdi3>:
  803a50:	55                   	push   %ebp
  803a51:	57                   	push   %edi
  803a52:	56                   	push   %esi
  803a53:	53                   	push   %ebx
  803a54:	83 ec 1c             	sub    $0x1c,%esp
  803a57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  803a5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  803a5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803a63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803a67:	85 f6                	test   %esi,%esi
  803a69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803a6d:	89 ca                	mov    %ecx,%edx
  803a6f:	89 f8                	mov    %edi,%eax
  803a71:	75 3d                	jne    803ab0 <__udivdi3+0x60>
  803a73:	39 cf                	cmp    %ecx,%edi
  803a75:	0f 87 c5 00 00 00    	ja     803b40 <__udivdi3+0xf0>
  803a7b:	85 ff                	test   %edi,%edi
  803a7d:	89 fd                	mov    %edi,%ebp
  803a7f:	75 0b                	jne    803a8c <__udivdi3+0x3c>
  803a81:	b8 01 00 00 00       	mov    $0x1,%eax
  803a86:	31 d2                	xor    %edx,%edx
  803a88:	f7 f7                	div    %edi
  803a8a:	89 c5                	mov    %eax,%ebp
  803a8c:	89 c8                	mov    %ecx,%eax
  803a8e:	31 d2                	xor    %edx,%edx
  803a90:	f7 f5                	div    %ebp
  803a92:	89 c1                	mov    %eax,%ecx
  803a94:	89 d8                	mov    %ebx,%eax
  803a96:	89 cf                	mov    %ecx,%edi
  803a98:	f7 f5                	div    %ebp
  803a9a:	89 c3                	mov    %eax,%ebx
  803a9c:	89 d8                	mov    %ebx,%eax
  803a9e:	89 fa                	mov    %edi,%edx
  803aa0:	83 c4 1c             	add    $0x1c,%esp
  803aa3:	5b                   	pop    %ebx
  803aa4:	5e                   	pop    %esi
  803aa5:	5f                   	pop    %edi
  803aa6:	5d                   	pop    %ebp
  803aa7:	c3                   	ret    
  803aa8:	90                   	nop
  803aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803ab0:	39 ce                	cmp    %ecx,%esi
  803ab2:	77 74                	ja     803b28 <__udivdi3+0xd8>
  803ab4:	0f bd fe             	bsr    %esi,%edi
  803ab7:	83 f7 1f             	xor    $0x1f,%edi
  803aba:	0f 84 98 00 00 00    	je     803b58 <__udivdi3+0x108>
  803ac0:	bb 20 00 00 00       	mov    $0x20,%ebx
  803ac5:	89 f9                	mov    %edi,%ecx
  803ac7:	89 c5                	mov    %eax,%ebp
  803ac9:	29 fb                	sub    %edi,%ebx
  803acb:	d3 e6                	shl    %cl,%esi
  803acd:	89 d9                	mov    %ebx,%ecx
  803acf:	d3 ed                	shr    %cl,%ebp
  803ad1:	89 f9                	mov    %edi,%ecx
  803ad3:	d3 e0                	shl    %cl,%eax
  803ad5:	09 ee                	or     %ebp,%esi
  803ad7:	89 d9                	mov    %ebx,%ecx
  803ad9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803add:	89 d5                	mov    %edx,%ebp
  803adf:	8b 44 24 08          	mov    0x8(%esp),%eax
  803ae3:	d3 ed                	shr    %cl,%ebp
  803ae5:	89 f9                	mov    %edi,%ecx
  803ae7:	d3 e2                	shl    %cl,%edx
  803ae9:	89 d9                	mov    %ebx,%ecx
  803aeb:	d3 e8                	shr    %cl,%eax
  803aed:	09 c2                	or     %eax,%edx
  803aef:	89 d0                	mov    %edx,%eax
  803af1:	89 ea                	mov    %ebp,%edx
  803af3:	f7 f6                	div    %esi
  803af5:	89 d5                	mov    %edx,%ebp
  803af7:	89 c3                	mov    %eax,%ebx
  803af9:	f7 64 24 0c          	mull   0xc(%esp)
  803afd:	39 d5                	cmp    %edx,%ebp
  803aff:	72 10                	jb     803b11 <__udivdi3+0xc1>
  803b01:	8b 74 24 08          	mov    0x8(%esp),%esi
  803b05:	89 f9                	mov    %edi,%ecx
  803b07:	d3 e6                	shl    %cl,%esi
  803b09:	39 c6                	cmp    %eax,%esi
  803b0b:	73 07                	jae    803b14 <__udivdi3+0xc4>
  803b0d:	39 d5                	cmp    %edx,%ebp
  803b0f:	75 03                	jne    803b14 <__udivdi3+0xc4>
  803b11:	83 eb 01             	sub    $0x1,%ebx
  803b14:	31 ff                	xor    %edi,%edi
  803b16:	89 d8                	mov    %ebx,%eax
  803b18:	89 fa                	mov    %edi,%edx
  803b1a:	83 c4 1c             	add    $0x1c,%esp
  803b1d:	5b                   	pop    %ebx
  803b1e:	5e                   	pop    %esi
  803b1f:	5f                   	pop    %edi
  803b20:	5d                   	pop    %ebp
  803b21:	c3                   	ret    
  803b22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803b28:	31 ff                	xor    %edi,%edi
  803b2a:	31 db                	xor    %ebx,%ebx
  803b2c:	89 d8                	mov    %ebx,%eax
  803b2e:	89 fa                	mov    %edi,%edx
  803b30:	83 c4 1c             	add    $0x1c,%esp
  803b33:	5b                   	pop    %ebx
  803b34:	5e                   	pop    %esi
  803b35:	5f                   	pop    %edi
  803b36:	5d                   	pop    %ebp
  803b37:	c3                   	ret    
  803b38:	90                   	nop
  803b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b40:	89 d8                	mov    %ebx,%eax
  803b42:	f7 f7                	div    %edi
  803b44:	31 ff                	xor    %edi,%edi
  803b46:	89 c3                	mov    %eax,%ebx
  803b48:	89 d8                	mov    %ebx,%eax
  803b4a:	89 fa                	mov    %edi,%edx
  803b4c:	83 c4 1c             	add    $0x1c,%esp
  803b4f:	5b                   	pop    %ebx
  803b50:	5e                   	pop    %esi
  803b51:	5f                   	pop    %edi
  803b52:	5d                   	pop    %ebp
  803b53:	c3                   	ret    
  803b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803b58:	39 ce                	cmp    %ecx,%esi
  803b5a:	72 0c                	jb     803b68 <__udivdi3+0x118>
  803b5c:	31 db                	xor    %ebx,%ebx
  803b5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803b62:	0f 87 34 ff ff ff    	ja     803a9c <__udivdi3+0x4c>
  803b68:	bb 01 00 00 00       	mov    $0x1,%ebx
  803b6d:	e9 2a ff ff ff       	jmp    803a9c <__udivdi3+0x4c>
  803b72:	66 90                	xchg   %ax,%ax
  803b74:	66 90                	xchg   %ax,%ax
  803b76:	66 90                	xchg   %ax,%ax
  803b78:	66 90                	xchg   %ax,%ax
  803b7a:	66 90                	xchg   %ax,%ax
  803b7c:	66 90                	xchg   %ax,%ax
  803b7e:	66 90                	xchg   %ax,%ax

00803b80 <__umoddi3>:
  803b80:	55                   	push   %ebp
  803b81:	57                   	push   %edi
  803b82:	56                   	push   %esi
  803b83:	53                   	push   %ebx
  803b84:	83 ec 1c             	sub    $0x1c,%esp
  803b87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803b8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803b8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803b97:	85 d2                	test   %edx,%edx
  803b99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803b9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803ba1:	89 f3                	mov    %esi,%ebx
  803ba3:	89 3c 24             	mov    %edi,(%esp)
  803ba6:	89 74 24 04          	mov    %esi,0x4(%esp)
  803baa:	75 1c                	jne    803bc8 <__umoddi3+0x48>
  803bac:	39 f7                	cmp    %esi,%edi
  803bae:	76 50                	jbe    803c00 <__umoddi3+0x80>
  803bb0:	89 c8                	mov    %ecx,%eax
  803bb2:	89 f2                	mov    %esi,%edx
  803bb4:	f7 f7                	div    %edi
  803bb6:	89 d0                	mov    %edx,%eax
  803bb8:	31 d2                	xor    %edx,%edx
  803bba:	83 c4 1c             	add    $0x1c,%esp
  803bbd:	5b                   	pop    %ebx
  803bbe:	5e                   	pop    %esi
  803bbf:	5f                   	pop    %edi
  803bc0:	5d                   	pop    %ebp
  803bc1:	c3                   	ret    
  803bc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803bc8:	39 f2                	cmp    %esi,%edx
  803bca:	89 d0                	mov    %edx,%eax
  803bcc:	77 52                	ja     803c20 <__umoddi3+0xa0>
  803bce:	0f bd ea             	bsr    %edx,%ebp
  803bd1:	83 f5 1f             	xor    $0x1f,%ebp
  803bd4:	75 5a                	jne    803c30 <__umoddi3+0xb0>
  803bd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803bda:	0f 82 e0 00 00 00    	jb     803cc0 <__umoddi3+0x140>
  803be0:	39 0c 24             	cmp    %ecx,(%esp)
  803be3:	0f 86 d7 00 00 00    	jbe    803cc0 <__umoddi3+0x140>
  803be9:	8b 44 24 08          	mov    0x8(%esp),%eax
  803bed:	8b 54 24 04          	mov    0x4(%esp),%edx
  803bf1:	83 c4 1c             	add    $0x1c,%esp
  803bf4:	5b                   	pop    %ebx
  803bf5:	5e                   	pop    %esi
  803bf6:	5f                   	pop    %edi
  803bf7:	5d                   	pop    %ebp
  803bf8:	c3                   	ret    
  803bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803c00:	85 ff                	test   %edi,%edi
  803c02:	89 fd                	mov    %edi,%ebp
  803c04:	75 0b                	jne    803c11 <__umoddi3+0x91>
  803c06:	b8 01 00 00 00       	mov    $0x1,%eax
  803c0b:	31 d2                	xor    %edx,%edx
  803c0d:	f7 f7                	div    %edi
  803c0f:	89 c5                	mov    %eax,%ebp
  803c11:	89 f0                	mov    %esi,%eax
  803c13:	31 d2                	xor    %edx,%edx
  803c15:	f7 f5                	div    %ebp
  803c17:	89 c8                	mov    %ecx,%eax
  803c19:	f7 f5                	div    %ebp
  803c1b:	89 d0                	mov    %edx,%eax
  803c1d:	eb 99                	jmp    803bb8 <__umoddi3+0x38>
  803c1f:	90                   	nop
  803c20:	89 c8                	mov    %ecx,%eax
  803c22:	89 f2                	mov    %esi,%edx
  803c24:	83 c4 1c             	add    $0x1c,%esp
  803c27:	5b                   	pop    %ebx
  803c28:	5e                   	pop    %esi
  803c29:	5f                   	pop    %edi
  803c2a:	5d                   	pop    %ebp
  803c2b:	c3                   	ret    
  803c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803c30:	8b 34 24             	mov    (%esp),%esi
  803c33:	bf 20 00 00 00       	mov    $0x20,%edi
  803c38:	89 e9                	mov    %ebp,%ecx
  803c3a:	29 ef                	sub    %ebp,%edi
  803c3c:	d3 e0                	shl    %cl,%eax
  803c3e:	89 f9                	mov    %edi,%ecx
  803c40:	89 f2                	mov    %esi,%edx
  803c42:	d3 ea                	shr    %cl,%edx
  803c44:	89 e9                	mov    %ebp,%ecx
  803c46:	09 c2                	or     %eax,%edx
  803c48:	89 d8                	mov    %ebx,%eax
  803c4a:	89 14 24             	mov    %edx,(%esp)
  803c4d:	89 f2                	mov    %esi,%edx
  803c4f:	d3 e2                	shl    %cl,%edx
  803c51:	89 f9                	mov    %edi,%ecx
  803c53:	89 54 24 04          	mov    %edx,0x4(%esp)
  803c57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803c5b:	d3 e8                	shr    %cl,%eax
  803c5d:	89 e9                	mov    %ebp,%ecx
  803c5f:	89 c6                	mov    %eax,%esi
  803c61:	d3 e3                	shl    %cl,%ebx
  803c63:	89 f9                	mov    %edi,%ecx
  803c65:	89 d0                	mov    %edx,%eax
  803c67:	d3 e8                	shr    %cl,%eax
  803c69:	89 e9                	mov    %ebp,%ecx
  803c6b:	09 d8                	or     %ebx,%eax
  803c6d:	89 d3                	mov    %edx,%ebx
  803c6f:	89 f2                	mov    %esi,%edx
  803c71:	f7 34 24             	divl   (%esp)
  803c74:	89 d6                	mov    %edx,%esi
  803c76:	d3 e3                	shl    %cl,%ebx
  803c78:	f7 64 24 04          	mull   0x4(%esp)
  803c7c:	39 d6                	cmp    %edx,%esi
  803c7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803c82:	89 d1                	mov    %edx,%ecx
  803c84:	89 c3                	mov    %eax,%ebx
  803c86:	72 08                	jb     803c90 <__umoddi3+0x110>
  803c88:	75 11                	jne    803c9b <__umoddi3+0x11b>
  803c8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803c8e:	73 0b                	jae    803c9b <__umoddi3+0x11b>
  803c90:	2b 44 24 04          	sub    0x4(%esp),%eax
  803c94:	1b 14 24             	sbb    (%esp),%edx
  803c97:	89 d1                	mov    %edx,%ecx
  803c99:	89 c3                	mov    %eax,%ebx
  803c9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  803c9f:	29 da                	sub    %ebx,%edx
  803ca1:	19 ce                	sbb    %ecx,%esi
  803ca3:	89 f9                	mov    %edi,%ecx
  803ca5:	89 f0                	mov    %esi,%eax
  803ca7:	d3 e0                	shl    %cl,%eax
  803ca9:	89 e9                	mov    %ebp,%ecx
  803cab:	d3 ea                	shr    %cl,%edx
  803cad:	89 e9                	mov    %ebp,%ecx
  803caf:	d3 ee                	shr    %cl,%esi
  803cb1:	09 d0                	or     %edx,%eax
  803cb3:	89 f2                	mov    %esi,%edx
  803cb5:	83 c4 1c             	add    $0x1c,%esp
  803cb8:	5b                   	pop    %ebx
  803cb9:	5e                   	pop    %esi
  803cba:	5f                   	pop    %edi
  803cbb:	5d                   	pop    %ebp
  803cbc:	c3                   	ret    
  803cbd:	8d 76 00             	lea    0x0(%esi),%esi
  803cc0:	29 f9                	sub    %edi,%ecx
  803cc2:	19 d6                	sbb    %edx,%esi
  803cc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  803cc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803ccc:	e9 18 ff ff ff       	jmp    803be9 <__umoddi3+0x69>
