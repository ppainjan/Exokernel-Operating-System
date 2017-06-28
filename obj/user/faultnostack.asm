
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 ab 03 80 00       	push   $0x8003ab
  80003e:	6a 00                	push   $0x0
  800040:	e8 80 02 00 00       	call   8002c5 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005f:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800066:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 ce 00 00 00       	call   80013c <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x37>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 eb 04 00 00       	call   80059a <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 42 00 00 00       	call   8000fb <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	89 c3                	mov    %eax,%ebx
  8000d1:	89 c7                	mov    %eax,%edi
  8000d3:	89 c6                	mov    %eax,%esi
  8000d5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ec:	89 d1                	mov    %edx,%ecx
  8000ee:	89 d3                	mov    %edx,%ebx
  8000f0:	89 d7                	mov    %edx,%edi
  8000f2:	89 d6                	mov    %edx,%esi
  8000f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800104:	b9 00 00 00 00       	mov    $0x0,%ecx
  800109:	b8 03 00 00 00       	mov    $0x3,%eax
  80010e:	8b 55 08             	mov    0x8(%ebp),%edx
  800111:	89 cb                	mov    %ecx,%ebx
  800113:	89 cf                	mov    %ecx,%edi
  800115:	89 ce                	mov    %ecx,%esi
  800117:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800119:	85 c0                	test   %eax,%eax
  80011b:	7e 17                	jle    800134 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	50                   	push   %eax
  800121:	6a 03                	push   $0x3
  800123:	68 0a 23 80 00       	push   $0x80230a
  800128:	6a 23                	push   $0x23
  80012a:	68 27 23 80 00       	push   $0x802327
  80012f:	e8 f0 13 00 00       	call   801524 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 02 00 00 00       	mov    $0x2,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_yield>:

void
sys_yield(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
  800180:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800183:	be 00 00 00 00       	mov    $0x0,%esi
  800188:	b8 04 00 00 00       	mov    $0x4,%eax
  80018d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800190:	8b 55 08             	mov    0x8(%ebp),%edx
  800193:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800196:	89 f7                	mov    %esi,%edi
  800198:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80019a:	85 c0                	test   %eax,%eax
  80019c:	7e 17                	jle    8001b5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	50                   	push   %eax
  8001a2:	6a 04                	push   $0x4
  8001a4:	68 0a 23 80 00       	push   $0x80230a
  8001a9:	6a 23                	push   $0x23
  8001ab:	68 27 23 80 00       	push   $0x802327
  8001b0:	e8 6f 13 00 00       	call   801524 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b8:	5b                   	pop    %ebx
  8001b9:	5e                   	pop    %esi
  8001ba:	5f                   	pop    %edi
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001dc:	85 c0                	test   %eax,%eax
  8001de:	7e 17                	jle    8001f7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e0:	83 ec 0c             	sub    $0xc,%esp
  8001e3:	50                   	push   %eax
  8001e4:	6a 05                	push   $0x5
  8001e6:	68 0a 23 80 00       	push   $0x80230a
  8001eb:	6a 23                	push   $0x23
  8001ed:	68 27 23 80 00       	push   $0x802327
  8001f2:	e8 2d 13 00 00       	call   801524 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5f                   	pop    %edi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	57                   	push   %edi
  800203:	56                   	push   %esi
  800204:	53                   	push   %ebx
  800205:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	b8 06 00 00 00       	mov    $0x6,%eax
  800212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800215:	8b 55 08             	mov    0x8(%ebp),%edx
  800218:	89 df                	mov    %ebx,%edi
  80021a:	89 de                	mov    %ebx,%esi
  80021c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021e:	85 c0                	test   %eax,%eax
  800220:	7e 17                	jle    800239 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	50                   	push   %eax
  800226:	6a 06                	push   $0x6
  800228:	68 0a 23 80 00       	push   $0x80230a
  80022d:	6a 23                	push   $0x23
  80022f:	68 27 23 80 00       	push   $0x802327
  800234:	e8 eb 12 00 00       	call   801524 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023c:	5b                   	pop    %ebx
  80023d:	5e                   	pop    %esi
  80023e:	5f                   	pop    %edi
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	57                   	push   %edi
  800245:	56                   	push   %esi
  800246:	53                   	push   %ebx
  800247:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024f:	b8 08 00 00 00       	mov    $0x8,%eax
  800254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800257:	8b 55 08             	mov    0x8(%ebp),%edx
  80025a:	89 df                	mov    %ebx,%edi
  80025c:	89 de                	mov    %ebx,%esi
  80025e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7e 17                	jle    80027b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	50                   	push   %eax
  800268:	6a 08                	push   $0x8
  80026a:	68 0a 23 80 00       	push   $0x80230a
  80026f:	6a 23                	push   $0x23
  800271:	68 27 23 80 00       	push   $0x802327
  800276:	e8 a9 12 00 00       	call   801524 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800291:	b8 09 00 00 00       	mov    $0x9,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 df                	mov    %ebx,%edi
  80029e:	89 de                	mov    %ebx,%esi
  8002a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	7e 17                	jle    8002bd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a6:	83 ec 0c             	sub    $0xc,%esp
  8002a9:	50                   	push   %eax
  8002aa:	6a 09                	push   $0x9
  8002ac:	68 0a 23 80 00       	push   $0x80230a
  8002b1:	6a 23                	push   $0x23
  8002b3:	68 27 23 80 00       	push   $0x802327
  8002b8:	e8 67 12 00 00       	call   801524 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	89 df                	mov    %ebx,%edi
  8002e0:	89 de                	mov    %ebx,%esi
  8002e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7e 17                	jle    8002ff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	50                   	push   %eax
  8002ec:	6a 0a                	push   $0xa
  8002ee:	68 0a 23 80 00       	push   $0x80230a
  8002f3:	6a 23                	push   $0x23
  8002f5:	68 27 23 80 00       	push   $0x802327
  8002fa:	e8 25 12 00 00       	call   801524 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	57                   	push   %edi
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030d:	be 00 00 00 00       	mov    $0x0,%esi
  800312:	b8 0c 00 00 00       	mov    $0xc,%eax
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031a:	8b 55 08             	mov    0x8(%ebp),%edx
  80031d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800320:	8b 7d 14             	mov    0x14(%ebp),%edi
  800323:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	57                   	push   %edi
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
  800330:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800333:	b9 00 00 00 00       	mov    $0x0,%ecx
  800338:	b8 0d 00 00 00       	mov    $0xd,%eax
  80033d:	8b 55 08             	mov    0x8(%ebp),%edx
  800340:	89 cb                	mov    %ecx,%ebx
  800342:	89 cf                	mov    %ecx,%edi
  800344:	89 ce                	mov    %ecx,%esi
  800346:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800348:	85 c0                	test   %eax,%eax
  80034a:	7e 17                	jle    800363 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034c:	83 ec 0c             	sub    $0xc,%esp
  80034f:	50                   	push   %eax
  800350:	6a 0d                	push   $0xd
  800352:	68 0a 23 80 00       	push   $0x80230a
  800357:	6a 23                	push   $0x23
  800359:	68 27 23 80 00       	push   $0x802327
  80035e:	e8 c1 11 00 00       	call   801524 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800363:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800366:	5b                   	pop    %ebx
  800367:	5e                   	pop    %esi
  800368:	5f                   	pop    %edi
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	b8 0e 00 00 00       	mov    $0xe,%eax
  80037b:	89 d1                	mov    %edx,%ecx
  80037d:	89 d3                	mov    %edx,%ebx
  80037f:	89 d7                	mov    %edx,%edi
  800381:	89 d6                	mov    %edx,%esi
  800383:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	57                   	push   %edi
  80038e:	56                   	push   %esi
  80038f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800390:	bb 00 00 00 00       	mov    $0x0,%ebx
  800395:	b8 0f 00 00 00       	mov    $0xf,%eax
  80039a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	89 df                	mov    %ebx,%edi
  8003a2:	89 de                	mov    %ebx,%esi
  8003a4:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  8003a6:	5b                   	pop    %ebx
  8003a7:	5e                   	pop    %esi
  8003a8:	5f                   	pop    %edi
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003ab:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003ac:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8003b1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003b3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8003b6:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8003ba:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8003bf:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8003c3:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8003c5:	83 c4 08             	add    $0x8,%esp
	popal
  8003c8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8003c9:	83 c4 04             	add    $0x4,%esp
	popfl
  8003cc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8003cd:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003ce:	c3                   	ret    

008003cf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d5:	05 00 00 00 30       	add    $0x30000000,%eax
  8003da:	c1 e8 0c             	shr    $0xc,%eax
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e5:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003ef:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003f4:	5d                   	pop    %ebp
  8003f5:	c3                   	ret    

008003f6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800401:	89 c2                	mov    %eax,%edx
  800403:	c1 ea 16             	shr    $0x16,%edx
  800406:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040d:	f6 c2 01             	test   $0x1,%dl
  800410:	74 11                	je     800423 <fd_alloc+0x2d>
  800412:	89 c2                	mov    %eax,%edx
  800414:	c1 ea 0c             	shr    $0xc,%edx
  800417:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041e:	f6 c2 01             	test   $0x1,%dl
  800421:	75 09                	jne    80042c <fd_alloc+0x36>
			*fd_store = fd;
  800423:	89 01                	mov    %eax,(%ecx)
			return 0;
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	eb 17                	jmp    800443 <fd_alloc+0x4d>
  80042c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800431:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800436:	75 c9                	jne    800401 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800438:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80043e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80044b:	83 f8 1f             	cmp    $0x1f,%eax
  80044e:	77 36                	ja     800486 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800450:	c1 e0 0c             	shl    $0xc,%eax
  800453:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800458:	89 c2                	mov    %eax,%edx
  80045a:	c1 ea 16             	shr    $0x16,%edx
  80045d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800464:	f6 c2 01             	test   $0x1,%dl
  800467:	74 24                	je     80048d <fd_lookup+0x48>
  800469:	89 c2                	mov    %eax,%edx
  80046b:	c1 ea 0c             	shr    $0xc,%edx
  80046e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800475:	f6 c2 01             	test   $0x1,%dl
  800478:	74 1a                	je     800494 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80047a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047d:	89 02                	mov    %eax,(%edx)
	return 0;
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	eb 13                	jmp    800499 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800486:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80048b:	eb 0c                	jmp    800499 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80048d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800492:	eb 05                	jmp    800499 <fd_lookup+0x54>
  800494:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800499:	5d                   	pop    %ebp
  80049a:	c3                   	ret    

0080049b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a4:	ba b4 23 80 00       	mov    $0x8023b4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004a9:	eb 13                	jmp    8004be <dev_lookup+0x23>
  8004ab:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004ae:	39 08                	cmp    %ecx,(%eax)
  8004b0:	75 0c                	jne    8004be <dev_lookup+0x23>
			*dev = devtab[i];
  8004b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bc:	eb 2e                	jmp    8004ec <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004be:	8b 02                	mov    (%edx),%eax
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	75 e7                	jne    8004ab <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c4:	a1 08 40 80 00       	mov    0x804008,%eax
  8004c9:	8b 40 48             	mov    0x48(%eax),%eax
  8004cc:	83 ec 04             	sub    $0x4,%esp
  8004cf:	51                   	push   %ecx
  8004d0:	50                   	push   %eax
  8004d1:	68 38 23 80 00       	push   $0x802338
  8004d6:	e8 22 11 00 00       	call   8015fd <cprintf>
	*dev = 0;
  8004db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    

008004ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	56                   	push   %esi
  8004f2:	53                   	push   %ebx
  8004f3:	83 ec 10             	sub    $0x10,%esp
  8004f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ff:	50                   	push   %eax
  800500:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800506:	c1 e8 0c             	shr    $0xc,%eax
  800509:	50                   	push   %eax
  80050a:	e8 36 ff ff ff       	call   800445 <fd_lookup>
  80050f:	83 c4 08             	add    $0x8,%esp
  800512:	85 c0                	test   %eax,%eax
  800514:	78 05                	js     80051b <fd_close+0x2d>
	    || fd != fd2)
  800516:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800519:	74 0c                	je     800527 <fd_close+0x39>
		return (must_exist ? r : 0);
  80051b:	84 db                	test   %bl,%bl
  80051d:	ba 00 00 00 00       	mov    $0x0,%edx
  800522:	0f 44 c2             	cmove  %edx,%eax
  800525:	eb 41                	jmp    800568 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80052d:	50                   	push   %eax
  80052e:	ff 36                	pushl  (%esi)
  800530:	e8 66 ff ff ff       	call   80049b <dev_lookup>
  800535:	89 c3                	mov    %eax,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	85 c0                	test   %eax,%eax
  80053c:	78 1a                	js     800558 <fd_close+0x6a>
		if (dev->dev_close)
  80053e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800541:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800549:	85 c0                	test   %eax,%eax
  80054b:	74 0b                	je     800558 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	56                   	push   %esi
  800551:	ff d0                	call   *%eax
  800553:	89 c3                	mov    %eax,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	56                   	push   %esi
  80055c:	6a 00                	push   $0x0
  80055e:	e8 9c fc ff ff       	call   8001ff <sys_page_unmap>
	return r;
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	89 d8                	mov    %ebx,%eax
}
  800568:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80056b:	5b                   	pop    %ebx
  80056c:	5e                   	pop    %esi
  80056d:	5d                   	pop    %ebp
  80056e:	c3                   	ret    

0080056f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800575:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800578:	50                   	push   %eax
  800579:	ff 75 08             	pushl  0x8(%ebp)
  80057c:	e8 c4 fe ff ff       	call   800445 <fd_lookup>
  800581:	83 c4 08             	add    $0x8,%esp
  800584:	85 c0                	test   %eax,%eax
  800586:	78 10                	js     800598 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	6a 01                	push   $0x1
  80058d:	ff 75 f4             	pushl  -0xc(%ebp)
  800590:	e8 59 ff ff ff       	call   8004ee <fd_close>
  800595:	83 c4 10             	add    $0x10,%esp
}
  800598:	c9                   	leave  
  800599:	c3                   	ret    

0080059a <close_all>:

void
close_all(void)
{
  80059a:	55                   	push   %ebp
  80059b:	89 e5                	mov    %esp,%ebp
  80059d:	53                   	push   %ebx
  80059e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	e8 c0 ff ff ff       	call   80056f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005af:	83 c3 01             	add    $0x1,%ebx
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	83 fb 20             	cmp    $0x20,%ebx
  8005b8:	75 ec                	jne    8005a6 <close_all+0xc>
		close(i);
}
  8005ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005bd:	c9                   	leave  
  8005be:	c3                   	ret    

008005bf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	57                   	push   %edi
  8005c3:	56                   	push   %esi
  8005c4:	53                   	push   %ebx
  8005c5:	83 ec 2c             	sub    $0x2c,%esp
  8005c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ce:	50                   	push   %eax
  8005cf:	ff 75 08             	pushl  0x8(%ebp)
  8005d2:	e8 6e fe ff ff       	call   800445 <fd_lookup>
  8005d7:	83 c4 08             	add    $0x8,%esp
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	0f 88 c1 00 00 00    	js     8006a3 <dup+0xe4>
		return r;
	close(newfdnum);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	56                   	push   %esi
  8005e6:	e8 84 ff ff ff       	call   80056f <close>

	newfd = INDEX2FD(newfdnum);
  8005eb:	89 f3                	mov    %esi,%ebx
  8005ed:	c1 e3 0c             	shl    $0xc,%ebx
  8005f0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005f6:	83 c4 04             	add    $0x4,%esp
  8005f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005fc:	e8 de fd ff ff       	call   8003df <fd2data>
  800601:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800603:	89 1c 24             	mov    %ebx,(%esp)
  800606:	e8 d4 fd ff ff       	call   8003df <fd2data>
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800611:	89 f8                	mov    %edi,%eax
  800613:	c1 e8 16             	shr    $0x16,%eax
  800616:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80061d:	a8 01                	test   $0x1,%al
  80061f:	74 37                	je     800658 <dup+0x99>
  800621:	89 f8                	mov    %edi,%eax
  800623:	c1 e8 0c             	shr    $0xc,%eax
  800626:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80062d:	f6 c2 01             	test   $0x1,%dl
  800630:	74 26                	je     800658 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800632:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800639:	83 ec 0c             	sub    $0xc,%esp
  80063c:	25 07 0e 00 00       	and    $0xe07,%eax
  800641:	50                   	push   %eax
  800642:	ff 75 d4             	pushl  -0x2c(%ebp)
  800645:	6a 00                	push   $0x0
  800647:	57                   	push   %edi
  800648:	6a 00                	push   $0x0
  80064a:	e8 6e fb ff ff       	call   8001bd <sys_page_map>
  80064f:	89 c7                	mov    %eax,%edi
  800651:	83 c4 20             	add    $0x20,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 2e                	js     800686 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800658:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065b:	89 d0                	mov    %edx,%eax
  80065d:	c1 e8 0c             	shr    $0xc,%eax
  800660:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800667:	83 ec 0c             	sub    $0xc,%esp
  80066a:	25 07 0e 00 00       	and    $0xe07,%eax
  80066f:	50                   	push   %eax
  800670:	53                   	push   %ebx
  800671:	6a 00                	push   $0x0
  800673:	52                   	push   %edx
  800674:	6a 00                	push   $0x0
  800676:	e8 42 fb ff ff       	call   8001bd <sys_page_map>
  80067b:	89 c7                	mov    %eax,%edi
  80067d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800680:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800682:	85 ff                	test   %edi,%edi
  800684:	79 1d                	jns    8006a3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 00                	push   $0x0
  80068c:	e8 6e fb ff ff       	call   8001ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  800691:	83 c4 08             	add    $0x8,%esp
  800694:	ff 75 d4             	pushl  -0x2c(%ebp)
  800697:	6a 00                	push   $0x0
  800699:	e8 61 fb ff ff       	call   8001ff <sys_page_unmap>
	return r;
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	89 f8                	mov    %edi,%eax
}
  8006a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a6:	5b                   	pop    %ebx
  8006a7:	5e                   	pop    %esi
  8006a8:	5f                   	pop    %edi
  8006a9:	5d                   	pop    %ebp
  8006aa:	c3                   	ret    

008006ab <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	53                   	push   %ebx
  8006af:	83 ec 14             	sub    $0x14,%esp
  8006b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006b8:	50                   	push   %eax
  8006b9:	53                   	push   %ebx
  8006ba:	e8 86 fd ff ff       	call   800445 <fd_lookup>
  8006bf:	83 c4 08             	add    $0x8,%esp
  8006c2:	89 c2                	mov    %eax,%edx
  8006c4:	85 c0                	test   %eax,%eax
  8006c6:	78 6d                	js     800735 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ce:	50                   	push   %eax
  8006cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d2:	ff 30                	pushl  (%eax)
  8006d4:	e8 c2 fd ff ff       	call   80049b <dev_lookup>
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	78 4c                	js     80072c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006e3:	8b 42 08             	mov    0x8(%edx),%eax
  8006e6:	83 e0 03             	and    $0x3,%eax
  8006e9:	83 f8 01             	cmp    $0x1,%eax
  8006ec:	75 21                	jne    80070f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8006f3:	8b 40 48             	mov    0x48(%eax),%eax
  8006f6:	83 ec 04             	sub    $0x4,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	50                   	push   %eax
  8006fb:	68 79 23 80 00       	push   $0x802379
  800700:	e8 f8 0e 00 00       	call   8015fd <cprintf>
		return -E_INVAL;
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80070d:	eb 26                	jmp    800735 <read+0x8a>
	}
	if (!dev->dev_read)
  80070f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800712:	8b 40 08             	mov    0x8(%eax),%eax
  800715:	85 c0                	test   %eax,%eax
  800717:	74 17                	je     800730 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800719:	83 ec 04             	sub    $0x4,%esp
  80071c:	ff 75 10             	pushl  0x10(%ebp)
  80071f:	ff 75 0c             	pushl  0xc(%ebp)
  800722:	52                   	push   %edx
  800723:	ff d0                	call   *%eax
  800725:	89 c2                	mov    %eax,%edx
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	eb 09                	jmp    800735 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072c:	89 c2                	mov    %eax,%edx
  80072e:	eb 05                	jmp    800735 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800730:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800735:	89 d0                	mov    %edx,%eax
  800737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	57                   	push   %edi
  800740:	56                   	push   %esi
  800741:	53                   	push   %ebx
  800742:	83 ec 0c             	sub    $0xc,%esp
  800745:	8b 7d 08             	mov    0x8(%ebp),%edi
  800748:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80074b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800750:	eb 21                	jmp    800773 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800752:	83 ec 04             	sub    $0x4,%esp
  800755:	89 f0                	mov    %esi,%eax
  800757:	29 d8                	sub    %ebx,%eax
  800759:	50                   	push   %eax
  80075a:	89 d8                	mov    %ebx,%eax
  80075c:	03 45 0c             	add    0xc(%ebp),%eax
  80075f:	50                   	push   %eax
  800760:	57                   	push   %edi
  800761:	e8 45 ff ff ff       	call   8006ab <read>
		if (m < 0)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	85 c0                	test   %eax,%eax
  80076b:	78 10                	js     80077d <readn+0x41>
			return m;
		if (m == 0)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 0a                	je     80077b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800771:	01 c3                	add    %eax,%ebx
  800773:	39 f3                	cmp    %esi,%ebx
  800775:	72 db                	jb     800752 <readn+0x16>
  800777:	89 d8                	mov    %ebx,%eax
  800779:	eb 02                	jmp    80077d <readn+0x41>
  80077b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80077d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5f                   	pop    %edi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	53                   	push   %ebx
  800789:	83 ec 14             	sub    $0x14,%esp
  80078c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	53                   	push   %ebx
  800794:	e8 ac fc ff ff       	call   800445 <fd_lookup>
  800799:	83 c4 08             	add    $0x8,%esp
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 68                	js     80080a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a8:	50                   	push   %eax
  8007a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ac:	ff 30                	pushl  (%eax)
  8007ae:	e8 e8 fc ff ff       	call   80049b <dev_lookup>
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	78 47                	js     800801 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c1:	75 21                	jne    8007e4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8007c8:	8b 40 48             	mov    0x48(%eax),%eax
  8007cb:	83 ec 04             	sub    $0x4,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	50                   	push   %eax
  8007d0:	68 95 23 80 00       	push   $0x802395
  8007d5:	e8 23 0e 00 00       	call   8015fd <cprintf>
		return -E_INVAL;
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007e2:	eb 26                	jmp    80080a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	74 17                	je     800805 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ee:	83 ec 04             	sub    $0x4,%esp
  8007f1:	ff 75 10             	pushl  0x10(%ebp)
  8007f4:	ff 75 0c             	pushl  0xc(%ebp)
  8007f7:	50                   	push   %eax
  8007f8:	ff d2                	call   *%edx
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	eb 09                	jmp    80080a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800801:	89 c2                	mov    %eax,%edx
  800803:	eb 05                	jmp    80080a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800805:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80080a:	89 d0                	mov    %edx,%eax
  80080c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080f:	c9                   	leave  
  800810:	c3                   	ret    

00800811 <seek>:

int
seek(int fdnum, off_t offset)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800817:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80081a:	50                   	push   %eax
  80081b:	ff 75 08             	pushl  0x8(%ebp)
  80081e:	e8 22 fc ff ff       	call   800445 <fd_lookup>
  800823:	83 c4 08             	add    $0x8,%esp
  800826:	85 c0                	test   %eax,%eax
  800828:	78 0e                	js     800838 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80082a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	53                   	push   %ebx
  800849:	e8 f7 fb ff ff       	call   800445 <fd_lookup>
  80084e:	83 c4 08             	add    $0x8,%esp
  800851:	89 c2                	mov    %eax,%edx
  800853:	85 c0                	test   %eax,%eax
  800855:	78 65                	js     8008bc <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085d:	50                   	push   %eax
  80085e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800861:	ff 30                	pushl  (%eax)
  800863:	e8 33 fc ff ff       	call   80049b <dev_lookup>
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	85 c0                	test   %eax,%eax
  80086d:	78 44                	js     8008b3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80086f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800872:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800876:	75 21                	jne    800899 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800878:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80087d:	8b 40 48             	mov    0x48(%eax),%eax
  800880:	83 ec 04             	sub    $0x4,%esp
  800883:	53                   	push   %ebx
  800884:	50                   	push   %eax
  800885:	68 58 23 80 00       	push   $0x802358
  80088a:	e8 6e 0d 00 00       	call   8015fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800897:	eb 23                	jmp    8008bc <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800899:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80089c:	8b 52 18             	mov    0x18(%edx),%edx
  80089f:	85 d2                	test   %edx,%edx
  8008a1:	74 14                	je     8008b7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	50                   	push   %eax
  8008aa:	ff d2                	call   *%edx
  8008ac:	89 c2                	mov    %eax,%edx
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	eb 09                	jmp    8008bc <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b3:	89 c2                	mov    %eax,%edx
  8008b5:	eb 05                	jmp    8008bc <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008bc:	89 d0                	mov    %edx,%eax
  8008be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	83 ec 14             	sub    $0x14,%esp
  8008ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008d0:	50                   	push   %eax
  8008d1:	ff 75 08             	pushl  0x8(%ebp)
  8008d4:	e8 6c fb ff ff       	call   800445 <fd_lookup>
  8008d9:	83 c4 08             	add    $0x8,%esp
  8008dc:	89 c2                	mov    %eax,%edx
  8008de:	85 c0                	test   %eax,%eax
  8008e0:	78 58                	js     80093a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e8:	50                   	push   %eax
  8008e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ec:	ff 30                	pushl  (%eax)
  8008ee:	e8 a8 fb ff ff       	call   80049b <dev_lookup>
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	78 37                	js     800931 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800901:	74 32                	je     800935 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800903:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800906:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80090d:	00 00 00 
	stat->st_isdir = 0;
  800910:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800917:	00 00 00 
	stat->st_dev = dev;
  80091a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800920:	83 ec 08             	sub    $0x8,%esp
  800923:	53                   	push   %ebx
  800924:	ff 75 f0             	pushl  -0x10(%ebp)
  800927:	ff 50 14             	call   *0x14(%eax)
  80092a:	89 c2                	mov    %eax,%edx
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	eb 09                	jmp    80093a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800931:	89 c2                	mov    %eax,%edx
  800933:	eb 05                	jmp    80093a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800935:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80093a:	89 d0                	mov    %edx,%eax
  80093c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800946:	83 ec 08             	sub    $0x8,%esp
  800949:	6a 00                	push   $0x0
  80094b:	ff 75 08             	pushl  0x8(%ebp)
  80094e:	e8 e7 01 00 00       	call   800b3a <open>
  800953:	89 c3                	mov    %eax,%ebx
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	85 c0                	test   %eax,%eax
  80095a:	78 1b                	js     800977 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80095c:	83 ec 08             	sub    $0x8,%esp
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	50                   	push   %eax
  800963:	e8 5b ff ff ff       	call   8008c3 <fstat>
  800968:	89 c6                	mov    %eax,%esi
	close(fd);
  80096a:	89 1c 24             	mov    %ebx,(%esp)
  80096d:	e8 fd fb ff ff       	call   80056f <close>
	return r;
  800972:	83 c4 10             	add    $0x10,%esp
  800975:	89 f0                	mov    %esi,%eax
}
  800977:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	56                   	push   %esi
  800982:	53                   	push   %ebx
  800983:	89 c6                	mov    %eax,%esi
  800985:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800987:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80098e:	75 12                	jne    8009a2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800990:	83 ec 0c             	sub    $0xc,%esp
  800993:	6a 01                	push   $0x1
  800995:	e8 5f 16 00 00       	call   801ff9 <ipc_find_env>
  80099a:	a3 00 40 80 00       	mov    %eax,0x804000
  80099f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009a2:	6a 07                	push   $0x7
  8009a4:	68 00 50 80 00       	push   $0x805000
  8009a9:	56                   	push   %esi
  8009aa:	ff 35 00 40 80 00    	pushl  0x804000
  8009b0:	e8 f0 15 00 00       	call   801fa5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009b5:	83 c4 0c             	add    $0xc,%esp
  8009b8:	6a 00                	push   $0x0
  8009ba:	53                   	push   %ebx
  8009bb:	6a 00                	push   $0x0
  8009bd:	e8 76 15 00 00       	call   801f38 <ipc_recv>
}
  8009c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e7:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ec:	e8 8d ff ff ff       	call   80097e <fsipc>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ff:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
  800a09:	b8 06 00 00 00       	mov    $0x6,%eax
  800a0e:	e8 6b ff ff ff       	call   80097e <fsipc>
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	83 ec 04             	sub    $0x4,%esp
  800a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 40 0c             	mov    0xc(%eax),%eax
  800a25:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800a34:	e8 45 ff ff ff       	call   80097e <fsipc>
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	78 2c                	js     800a69 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	68 00 50 80 00       	push   $0x805000
  800a45:	53                   	push   %ebx
  800a46:	e8 37 11 00 00       	call   801b82 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a4b:	a1 80 50 80 00       	mov    0x805080,%eax
  800a50:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a56:	a1 84 50 80 00       	mov    0x805084,%eax
  800a5b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	53                   	push   %ebx
  800a72:	83 ec 08             	sub    $0x8,%esp
  800a75:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a78:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a7d:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a82:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a85:	53                   	push   %ebx
  800a86:	ff 75 0c             	pushl  0xc(%ebp)
  800a89:	68 08 50 80 00       	push   $0x805008
  800a8e:	e8 81 12 00 00       	call   801d14 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8b 40 0c             	mov    0xc(%eax),%eax
  800a99:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a9e:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 04 00 00 00       	mov    $0x4,%eax
  800aae:	e8 cb fe ff ff       	call   80097e <fsipc>
	//panic("devfile_write not implemented");
}
  800ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 40 0c             	mov    0xc(%eax),%eax
  800ac6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800acb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	b8 03 00 00 00       	mov    $0x3,%eax
  800adb:	e8 9e fe ff ff       	call   80097e <fsipc>
  800ae0:	89 c3                	mov    %eax,%ebx
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	78 4b                	js     800b31 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ae6:	39 c6                	cmp    %eax,%esi
  800ae8:	73 16                	jae    800b00 <devfile_read+0x48>
  800aea:	68 c8 23 80 00       	push   $0x8023c8
  800aef:	68 cf 23 80 00       	push   $0x8023cf
  800af4:	6a 7c                	push   $0x7c
  800af6:	68 e4 23 80 00       	push   $0x8023e4
  800afb:	e8 24 0a 00 00       	call   801524 <_panic>
	assert(r <= PGSIZE);
  800b00:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b05:	7e 16                	jle    800b1d <devfile_read+0x65>
  800b07:	68 ef 23 80 00       	push   $0x8023ef
  800b0c:	68 cf 23 80 00       	push   $0x8023cf
  800b11:	6a 7d                	push   $0x7d
  800b13:	68 e4 23 80 00       	push   $0x8023e4
  800b18:	e8 07 0a 00 00       	call   801524 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b1d:	83 ec 04             	sub    $0x4,%esp
  800b20:	50                   	push   %eax
  800b21:	68 00 50 80 00       	push   $0x805000
  800b26:	ff 75 0c             	pushl  0xc(%ebp)
  800b29:	e8 e6 11 00 00       	call   801d14 <memmove>
	return r;
  800b2e:	83 c4 10             	add    $0x10,%esp
}
  800b31:	89 d8                	mov    %ebx,%eax
  800b33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	53                   	push   %ebx
  800b3e:	83 ec 20             	sub    $0x20,%esp
  800b41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b44:	53                   	push   %ebx
  800b45:	e8 ff 0f 00 00       	call   801b49 <strlen>
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b52:	7f 67                	jg     800bbb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b5a:	50                   	push   %eax
  800b5b:	e8 96 f8 ff ff       	call   8003f6 <fd_alloc>
  800b60:	83 c4 10             	add    $0x10,%esp
		return r;
  800b63:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	78 57                	js     800bc0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	53                   	push   %ebx
  800b6d:	68 00 50 80 00       	push   $0x805000
  800b72:	e8 0b 10 00 00       	call   801b82 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b82:	b8 01 00 00 00       	mov    $0x1,%eax
  800b87:	e8 f2 fd ff ff       	call   80097e <fsipc>
  800b8c:	89 c3                	mov    %eax,%ebx
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	85 c0                	test   %eax,%eax
  800b93:	79 14                	jns    800ba9 <open+0x6f>
		fd_close(fd, 0);
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	6a 00                	push   $0x0
  800b9a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b9d:	e8 4c f9 ff ff       	call   8004ee <fd_close>
		return r;
  800ba2:	83 c4 10             	add    $0x10,%esp
  800ba5:	89 da                	mov    %ebx,%edx
  800ba7:	eb 17                	jmp    800bc0 <open+0x86>
	}

	return fd2num(fd);
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	ff 75 f4             	pushl  -0xc(%ebp)
  800baf:	e8 1b f8 ff ff       	call   8003cf <fd2num>
  800bb4:	89 c2                	mov    %eax,%edx
  800bb6:	83 c4 10             	add    $0x10,%esp
  800bb9:	eb 05                	jmp    800bc0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bbb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bc0:	89 d0                	mov    %edx,%eax
  800bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd7:	e8 a2 fd ff ff       	call   80097e <fsipc>
}
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800be4:	68 fb 23 80 00       	push   $0x8023fb
  800be9:	ff 75 0c             	pushl  0xc(%ebp)
  800bec:	e8 91 0f 00 00       	call   801b82 <strcpy>
	return 0;
}
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 10             	sub    $0x10,%esp
  800bff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c02:	53                   	push   %ebx
  800c03:	e8 2a 14 00 00       	call   802032 <pageref>
  800c08:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c10:	83 f8 01             	cmp    $0x1,%eax
  800c13:	75 10                	jne    800c25 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	ff 73 0c             	pushl  0xc(%ebx)
  800c1b:	e8 c0 02 00 00       	call   800ee0 <nsipc_close>
  800c20:	89 c2                	mov    %eax,%edx
  800c22:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c25:	89 d0                	mov    %edx,%eax
  800c27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c32:	6a 00                	push   $0x0
  800c34:	ff 75 10             	pushl  0x10(%ebp)
  800c37:	ff 75 0c             	pushl  0xc(%ebp)
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	ff 70 0c             	pushl  0xc(%eax)
  800c40:	e8 78 03 00 00       	call   800fbd <nsipc_send>
}
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c4d:	6a 00                	push   $0x0
  800c4f:	ff 75 10             	pushl  0x10(%ebp)
  800c52:	ff 75 0c             	pushl  0xc(%ebp)
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	ff 70 0c             	pushl  0xc(%eax)
  800c5b:	e8 f1 02 00 00       	call   800f51 <nsipc_recv>
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c68:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c6b:	52                   	push   %edx
  800c6c:	50                   	push   %eax
  800c6d:	e8 d3 f7 ff ff       	call   800445 <fd_lookup>
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	85 c0                	test   %eax,%eax
  800c77:	78 17                	js     800c90 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c82:	39 08                	cmp    %ecx,(%eax)
  800c84:	75 05                	jne    800c8b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c86:	8b 40 0c             	mov    0xc(%eax),%eax
  800c89:	eb 05                	jmp    800c90 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c8b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 1c             	sub    $0x1c,%esp
  800c9a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c9f:	50                   	push   %eax
  800ca0:	e8 51 f7 ff ff       	call   8003f6 <fd_alloc>
  800ca5:	89 c3                	mov    %eax,%ebx
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	85 c0                	test   %eax,%eax
  800cac:	78 1b                	js     800cc9 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cae:	83 ec 04             	sub    $0x4,%esp
  800cb1:	68 07 04 00 00       	push   $0x407
  800cb6:	ff 75 f4             	pushl  -0xc(%ebp)
  800cb9:	6a 00                	push   $0x0
  800cbb:	e8 ba f4 ff ff       	call   80017a <sys_page_alloc>
  800cc0:	89 c3                	mov    %eax,%ebx
  800cc2:	83 c4 10             	add    $0x10,%esp
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	79 10                	jns    800cd9 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	56                   	push   %esi
  800ccd:	e8 0e 02 00 00       	call   800ee0 <nsipc_close>
		return r;
  800cd2:	83 c4 10             	add    $0x10,%esp
  800cd5:	89 d8                	mov    %ebx,%eax
  800cd7:	eb 24                	jmp    800cfd <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cd9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cee:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	50                   	push   %eax
  800cf5:	e8 d5 f6 ff ff       	call   8003cf <fd2num>
  800cfa:	83 c4 10             	add    $0x10,%esp
}
  800cfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	e8 50 ff ff ff       	call   800c62 <fd2sockid>
		return r;
  800d12:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	78 1f                	js     800d37 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d18:	83 ec 04             	sub    $0x4,%esp
  800d1b:	ff 75 10             	pushl  0x10(%ebp)
  800d1e:	ff 75 0c             	pushl  0xc(%ebp)
  800d21:	50                   	push   %eax
  800d22:	e8 12 01 00 00       	call   800e39 <nsipc_accept>
  800d27:	83 c4 10             	add    $0x10,%esp
		return r;
  800d2a:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	78 07                	js     800d37 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d30:	e8 5d ff ff ff       	call   800c92 <alloc_sockfd>
  800d35:	89 c1                	mov    %eax,%ecx
}
  800d37:	89 c8                	mov    %ecx,%eax
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	e8 19 ff ff ff       	call   800c62 <fd2sockid>
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	78 12                	js     800d5f <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d4d:	83 ec 04             	sub    $0x4,%esp
  800d50:	ff 75 10             	pushl  0x10(%ebp)
  800d53:	ff 75 0c             	pushl  0xc(%ebp)
  800d56:	50                   	push   %eax
  800d57:	e8 2d 01 00 00       	call   800e89 <nsipc_bind>
  800d5c:	83 c4 10             	add    $0x10,%esp
}
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    

00800d61 <shutdown>:

int
shutdown(int s, int how)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	e8 f3 fe ff ff       	call   800c62 <fd2sockid>
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	78 0f                	js     800d82 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d73:	83 ec 08             	sub    $0x8,%esp
  800d76:	ff 75 0c             	pushl  0xc(%ebp)
  800d79:	50                   	push   %eax
  800d7a:	e8 3f 01 00 00       	call   800ebe <nsipc_shutdown>
  800d7f:	83 c4 10             	add    $0x10,%esp
}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	e8 d0 fe ff ff       	call   800c62 <fd2sockid>
  800d92:	85 c0                	test   %eax,%eax
  800d94:	78 12                	js     800da8 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	ff 75 10             	pushl  0x10(%ebp)
  800d9c:	ff 75 0c             	pushl  0xc(%ebp)
  800d9f:	50                   	push   %eax
  800da0:	e8 55 01 00 00       	call   800efa <nsipc_connect>
  800da5:	83 c4 10             	add    $0x10,%esp
}
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <listen>:

int
listen(int s, int backlog)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	e8 aa fe ff ff       	call   800c62 <fd2sockid>
  800db8:	85 c0                	test   %eax,%eax
  800dba:	78 0f                	js     800dcb <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dbc:	83 ec 08             	sub    $0x8,%esp
  800dbf:	ff 75 0c             	pushl  0xc(%ebp)
  800dc2:	50                   	push   %eax
  800dc3:	e8 67 01 00 00       	call   800f2f <nsipc_listen>
  800dc8:	83 c4 10             	add    $0x10,%esp
}
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    

00800dcd <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dd3:	ff 75 10             	pushl  0x10(%ebp)
  800dd6:	ff 75 0c             	pushl  0xc(%ebp)
  800dd9:	ff 75 08             	pushl  0x8(%ebp)
  800ddc:	e8 3a 02 00 00       	call   80101b <nsipc_socket>
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	85 c0                	test   %eax,%eax
  800de6:	78 05                	js     800ded <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800de8:	e8 a5 fe ff ff       	call   800c92 <alloc_sockfd>
}
  800ded:	c9                   	leave  
  800dee:	c3                   	ret    

00800def <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	53                   	push   %ebx
  800df3:	83 ec 04             	sub    $0x4,%esp
  800df6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800df8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dff:	75 12                	jne    800e13 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	6a 02                	push   $0x2
  800e06:	e8 ee 11 00 00       	call   801ff9 <ipc_find_env>
  800e0b:	a3 04 40 80 00       	mov    %eax,0x804004
  800e10:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e13:	6a 07                	push   $0x7
  800e15:	68 00 60 80 00       	push   $0x806000
  800e1a:	53                   	push   %ebx
  800e1b:	ff 35 04 40 80 00    	pushl  0x804004
  800e21:	e8 7f 11 00 00       	call   801fa5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e26:	83 c4 0c             	add    $0xc,%esp
  800e29:	6a 00                	push   $0x0
  800e2b:	6a 00                	push   $0x0
  800e2d:	6a 00                	push   $0x0
  800e2f:	e8 04 11 00 00       	call   801f38 <ipc_recv>
}
  800e34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e37:	c9                   	leave  
  800e38:	c3                   	ret    

00800e39 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e49:	8b 06                	mov    (%esi),%eax
  800e4b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e50:	b8 01 00 00 00       	mov    $0x1,%eax
  800e55:	e8 95 ff ff ff       	call   800def <nsipc>
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	78 20                	js     800e80 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e60:	83 ec 04             	sub    $0x4,%esp
  800e63:	ff 35 10 60 80 00    	pushl  0x806010
  800e69:	68 00 60 80 00       	push   $0x806000
  800e6e:	ff 75 0c             	pushl  0xc(%ebp)
  800e71:	e8 9e 0e 00 00       	call   801d14 <memmove>
		*addrlen = ret->ret_addrlen;
  800e76:	a1 10 60 80 00       	mov    0x806010,%eax
  800e7b:	89 06                	mov    %eax,(%esi)
  800e7d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 08             	sub    $0x8,%esp
  800e90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e9b:	53                   	push   %ebx
  800e9c:	ff 75 0c             	pushl  0xc(%ebp)
  800e9f:	68 04 60 80 00       	push   $0x806004
  800ea4:	e8 6b 0e 00 00       	call   801d14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ea9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800eaf:	b8 02 00 00 00       	mov    $0x2,%eax
  800eb4:	e8 36 ff ff ff       	call   800def <nsipc>
}
  800eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	e8 11 ff ff ff       	call   800def <nsipc>
}
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <nsipc_close>:

int
nsipc_close(int s)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eee:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef3:	e8 f7 fe ff ff       	call   800def <nsipc>
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	53                   	push   %ebx
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f04:	8b 45 08             	mov    0x8(%ebp),%eax
  800f07:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f0c:	53                   	push   %ebx
  800f0d:	ff 75 0c             	pushl  0xc(%ebp)
  800f10:	68 04 60 80 00       	push   $0x806004
  800f15:	e8 fa 0d 00 00       	call   801d14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f1a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f20:	b8 05 00 00 00       	mov    $0x5,%eax
  800f25:	e8 c5 fe ff ff       	call   800def <nsipc>
}
  800f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f40:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f45:	b8 06 00 00 00       	mov    $0x6,%eax
  800f4a:	e8 a0 fe ff ff       	call   800def <nsipc>
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	56                   	push   %esi
  800f55:	53                   	push   %ebx
  800f56:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f61:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f67:	8b 45 14             	mov    0x14(%ebp),%eax
  800f6a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f6f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f74:	e8 76 fe ff ff       	call   800def <nsipc>
  800f79:	89 c3                	mov    %eax,%ebx
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 35                	js     800fb4 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f7f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f84:	7f 04                	jg     800f8a <nsipc_recv+0x39>
  800f86:	39 c6                	cmp    %eax,%esi
  800f88:	7d 16                	jge    800fa0 <nsipc_recv+0x4f>
  800f8a:	68 07 24 80 00       	push   $0x802407
  800f8f:	68 cf 23 80 00       	push   $0x8023cf
  800f94:	6a 62                	push   $0x62
  800f96:	68 1c 24 80 00       	push   $0x80241c
  800f9b:	e8 84 05 00 00       	call   801524 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fa0:	83 ec 04             	sub    $0x4,%esp
  800fa3:	50                   	push   %eax
  800fa4:	68 00 60 80 00       	push   $0x806000
  800fa9:	ff 75 0c             	pushl  0xc(%ebp)
  800fac:	e8 63 0d 00 00       	call   801d14 <memmove>
  800fb1:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fb4:	89 d8                	mov    %ebx,%eax
  800fb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 04             	sub    $0x4,%esp
  800fc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fca:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fcf:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fd5:	7e 16                	jle    800fed <nsipc_send+0x30>
  800fd7:	68 28 24 80 00       	push   $0x802428
  800fdc:	68 cf 23 80 00       	push   $0x8023cf
  800fe1:	6a 6d                	push   $0x6d
  800fe3:	68 1c 24 80 00       	push   $0x80241c
  800fe8:	e8 37 05 00 00       	call   801524 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fed:	83 ec 04             	sub    $0x4,%esp
  800ff0:	53                   	push   %ebx
  800ff1:	ff 75 0c             	pushl  0xc(%ebp)
  800ff4:	68 0c 60 80 00       	push   $0x80600c
  800ff9:	e8 16 0d 00 00       	call   801d14 <memmove>
	nsipcbuf.send.req_size = size;
  800ffe:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801004:	8b 45 14             	mov    0x14(%ebp),%eax
  801007:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80100c:	b8 08 00 00 00       	mov    $0x8,%eax
  801011:	e8 d9 fd ff ff       	call   800def <nsipc>
}
  801016:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801029:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102c:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801031:	8b 45 10             	mov    0x10(%ebp),%eax
  801034:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801039:	b8 09 00 00 00       	mov    $0x9,%eax
  80103e:	e8 ac fd ff ff       	call   800def <nsipc>
}
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	56                   	push   %esi
  801049:	53                   	push   %ebx
  80104a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	ff 75 08             	pushl  0x8(%ebp)
  801053:	e8 87 f3 ff ff       	call   8003df <fd2data>
  801058:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80105a:	83 c4 08             	add    $0x8,%esp
  80105d:	68 34 24 80 00       	push   $0x802434
  801062:	53                   	push   %ebx
  801063:	e8 1a 0b 00 00       	call   801b82 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801068:	8b 46 04             	mov    0x4(%esi),%eax
  80106b:	2b 06                	sub    (%esi),%eax
  80106d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801073:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80107a:	00 00 00 
	stat->st_dev = &devpipe;
  80107d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801084:	30 80 00 
	return 0;
}
  801087:	b8 00 00 00 00       	mov    $0x0,%eax
  80108c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	53                   	push   %ebx
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80109d:	53                   	push   %ebx
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 5a f1 ff ff       	call   8001ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010a5:	89 1c 24             	mov    %ebx,(%esp)
  8010a8:	e8 32 f3 ff ff       	call   8003df <fd2data>
  8010ad:	83 c4 08             	add    $0x8,%esp
  8010b0:	50                   	push   %eax
  8010b1:	6a 00                	push   $0x0
  8010b3:	e8 47 f1 ff ff       	call   8001ff <sys_page_unmap>
}
  8010b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bb:	c9                   	leave  
  8010bc:	c3                   	ret    

008010bd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	57                   	push   %edi
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 1c             	sub    $0x1c,%esp
  8010c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010c9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010cb:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8010d9:	e8 54 0f 00 00       	call   802032 <pageref>
  8010de:	89 c3                	mov    %eax,%ebx
  8010e0:	89 3c 24             	mov    %edi,(%esp)
  8010e3:	e8 4a 0f 00 00       	call   802032 <pageref>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	39 c3                	cmp    %eax,%ebx
  8010ed:	0f 94 c1             	sete   %cl
  8010f0:	0f b6 c9             	movzbl %cl,%ecx
  8010f3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010f6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010fc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010ff:	39 ce                	cmp    %ecx,%esi
  801101:	74 1b                	je     80111e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801103:	39 c3                	cmp    %eax,%ebx
  801105:	75 c4                	jne    8010cb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801107:	8b 42 58             	mov    0x58(%edx),%eax
  80110a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110d:	50                   	push   %eax
  80110e:	56                   	push   %esi
  80110f:	68 3b 24 80 00       	push   $0x80243b
  801114:	e8 e4 04 00 00       	call   8015fd <cprintf>
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	eb ad                	jmp    8010cb <_pipeisclosed+0xe>
	}
}
  80111e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	57                   	push   %edi
  80112d:	56                   	push   %esi
  80112e:	53                   	push   %ebx
  80112f:	83 ec 28             	sub    $0x28,%esp
  801132:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801135:	56                   	push   %esi
  801136:	e8 a4 f2 ff ff       	call   8003df <fd2data>
  80113b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	bf 00 00 00 00       	mov    $0x0,%edi
  801145:	eb 4b                	jmp    801192 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801147:	89 da                	mov    %ebx,%edx
  801149:	89 f0                	mov    %esi,%eax
  80114b:	e8 6d ff ff ff       	call   8010bd <_pipeisclosed>
  801150:	85 c0                	test   %eax,%eax
  801152:	75 48                	jne    80119c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801154:	e8 02 f0 ff ff       	call   80015b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801159:	8b 43 04             	mov    0x4(%ebx),%eax
  80115c:	8b 0b                	mov    (%ebx),%ecx
  80115e:	8d 51 20             	lea    0x20(%ecx),%edx
  801161:	39 d0                	cmp    %edx,%eax
  801163:	73 e2                	jae    801147 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801168:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80116c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80116f:	89 c2                	mov    %eax,%edx
  801171:	c1 fa 1f             	sar    $0x1f,%edx
  801174:	89 d1                	mov    %edx,%ecx
  801176:	c1 e9 1b             	shr    $0x1b,%ecx
  801179:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80117c:	83 e2 1f             	and    $0x1f,%edx
  80117f:	29 ca                	sub    %ecx,%edx
  801181:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801185:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801189:	83 c0 01             	add    $0x1,%eax
  80118c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118f:	83 c7 01             	add    $0x1,%edi
  801192:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801195:	75 c2                	jne    801159 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801197:	8b 45 10             	mov    0x10(%ebp),%eax
  80119a:	eb 05                	jmp    8011a1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	57                   	push   %edi
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 18             	sub    $0x18,%esp
  8011b2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011b5:	57                   	push   %edi
  8011b6:	e8 24 f2 ff ff       	call   8003df <fd2data>
  8011bb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c5:	eb 3d                	jmp    801204 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011c7:	85 db                	test   %ebx,%ebx
  8011c9:	74 04                	je     8011cf <devpipe_read+0x26>
				return i;
  8011cb:	89 d8                	mov    %ebx,%eax
  8011cd:	eb 44                	jmp    801213 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011cf:	89 f2                	mov    %esi,%edx
  8011d1:	89 f8                	mov    %edi,%eax
  8011d3:	e8 e5 fe ff ff       	call   8010bd <_pipeisclosed>
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	75 32                	jne    80120e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011dc:	e8 7a ef ff ff       	call   80015b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011e1:	8b 06                	mov    (%esi),%eax
  8011e3:	3b 46 04             	cmp    0x4(%esi),%eax
  8011e6:	74 df                	je     8011c7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011e8:	99                   	cltd   
  8011e9:	c1 ea 1b             	shr    $0x1b,%edx
  8011ec:	01 d0                	add    %edx,%eax
  8011ee:	83 e0 1f             	and    $0x1f,%eax
  8011f1:	29 d0                	sub    %edx,%eax
  8011f3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011fe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801201:	83 c3 01             	add    $0x1,%ebx
  801204:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801207:	75 d8                	jne    8011e1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801209:	8b 45 10             	mov    0x10(%ebp),%eax
  80120c:	eb 05                	jmp    801213 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801223:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801226:	50                   	push   %eax
  801227:	e8 ca f1 ff ff       	call   8003f6 <fd_alloc>
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	89 c2                	mov    %eax,%edx
  801231:	85 c0                	test   %eax,%eax
  801233:	0f 88 2c 01 00 00    	js     801365 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	68 07 04 00 00       	push   $0x407
  801241:	ff 75 f4             	pushl  -0xc(%ebp)
  801244:	6a 00                	push   $0x0
  801246:	e8 2f ef ff ff       	call   80017a <sys_page_alloc>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	89 c2                	mov    %eax,%edx
  801250:	85 c0                	test   %eax,%eax
  801252:	0f 88 0d 01 00 00    	js     801365 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801258:	83 ec 0c             	sub    $0xc,%esp
  80125b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	e8 92 f1 ff ff       	call   8003f6 <fd_alloc>
  801264:	89 c3                	mov    %eax,%ebx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	0f 88 e2 00 00 00    	js     801353 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801271:	83 ec 04             	sub    $0x4,%esp
  801274:	68 07 04 00 00       	push   $0x407
  801279:	ff 75 f0             	pushl  -0x10(%ebp)
  80127c:	6a 00                	push   $0x0
  80127e:	e8 f7 ee ff ff       	call   80017a <sys_page_alloc>
  801283:	89 c3                	mov    %eax,%ebx
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	0f 88 c3 00 00 00    	js     801353 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	ff 75 f4             	pushl  -0xc(%ebp)
  801296:	e8 44 f1 ff ff       	call   8003df <fd2data>
  80129b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80129d:	83 c4 0c             	add    $0xc,%esp
  8012a0:	68 07 04 00 00       	push   $0x407
  8012a5:	50                   	push   %eax
  8012a6:	6a 00                	push   $0x0
  8012a8:	e8 cd ee ff ff       	call   80017a <sys_page_alloc>
  8012ad:	89 c3                	mov    %eax,%ebx
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	0f 88 89 00 00 00    	js     801343 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c0:	e8 1a f1 ff ff       	call   8003df <fd2data>
  8012c5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012cc:	50                   	push   %eax
  8012cd:	6a 00                	push   $0x0
  8012cf:	56                   	push   %esi
  8012d0:	6a 00                	push   $0x0
  8012d2:	e8 e6 ee ff ff       	call   8001bd <sys_page_map>
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	83 c4 20             	add    $0x20,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 55                	js     801335 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012e0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012f5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801303:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80130a:	83 ec 0c             	sub    $0xc,%esp
  80130d:	ff 75 f4             	pushl  -0xc(%ebp)
  801310:	e8 ba f0 ff ff       	call   8003cf <fd2num>
  801315:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801318:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80131a:	83 c4 04             	add    $0x4,%esp
  80131d:	ff 75 f0             	pushl  -0x10(%ebp)
  801320:	e8 aa f0 ff ff       	call   8003cf <fd2num>
  801325:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801328:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	ba 00 00 00 00       	mov    $0x0,%edx
  801333:	eb 30                	jmp    801365 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	56                   	push   %esi
  801339:	6a 00                	push   $0x0
  80133b:	e8 bf ee ff ff       	call   8001ff <sys_page_unmap>
  801340:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	ff 75 f0             	pushl  -0x10(%ebp)
  801349:	6a 00                	push   $0x0
  80134b:	e8 af ee ff ff       	call   8001ff <sys_page_unmap>
  801350:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	ff 75 f4             	pushl  -0xc(%ebp)
  801359:	6a 00                	push   $0x0
  80135b:	e8 9f ee ff ff       	call   8001ff <sys_page_unmap>
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801365:	89 d0                	mov    %edx,%eax
  801367:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    

0080136e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801374:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	ff 75 08             	pushl  0x8(%ebp)
  80137b:	e8 c5 f0 ff ff       	call   800445 <fd_lookup>
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 18                	js     80139f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801387:	83 ec 0c             	sub    $0xc,%esp
  80138a:	ff 75 f4             	pushl  -0xc(%ebp)
  80138d:	e8 4d f0 ff ff       	call   8003df <fd2data>
	return _pipeisclosed(fd, p);
  801392:	89 c2                	mov    %eax,%edx
  801394:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801397:	e8 21 fd ff ff       	call   8010bd <_pipeisclosed>
  80139c:	83 c4 10             	add    $0x10,%esp
}
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013b1:	68 53 24 80 00       	push   $0x802453
  8013b6:	ff 75 0c             	pushl  0xc(%ebp)
  8013b9:	e8 c4 07 00 00       	call   801b82 <strcpy>
	return 0;
}
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	57                   	push   %edi
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013d6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013dc:	eb 2d                	jmp    80140b <devcons_write+0x46>
		m = n - tot;
  8013de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013e3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013e6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013eb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	53                   	push   %ebx
  8013f2:	03 45 0c             	add    0xc(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	57                   	push   %edi
  8013f7:	e8 18 09 00 00       	call   801d14 <memmove>
		sys_cputs(buf, m);
  8013fc:	83 c4 08             	add    $0x8,%esp
  8013ff:	53                   	push   %ebx
  801400:	57                   	push   %edi
  801401:	e8 b8 ec ff ff       	call   8000be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801406:	01 de                	add    %ebx,%esi
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	89 f0                	mov    %esi,%eax
  80140d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801410:	72 cc                	jb     8013de <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801412:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801415:	5b                   	pop    %ebx
  801416:	5e                   	pop    %esi
  801417:	5f                   	pop    %edi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    

0080141a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801425:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801429:	74 2a                	je     801455 <devcons_read+0x3b>
  80142b:	eb 05                	jmp    801432 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80142d:	e8 29 ed ff ff       	call   80015b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801432:	e8 a5 ec ff ff       	call   8000dc <sys_cgetc>
  801437:	85 c0                	test   %eax,%eax
  801439:	74 f2                	je     80142d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 16                	js     801455 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80143f:	83 f8 04             	cmp    $0x4,%eax
  801442:	74 0c                	je     801450 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801444:	8b 55 0c             	mov    0xc(%ebp),%edx
  801447:	88 02                	mov    %al,(%edx)
	return 1;
  801449:	b8 01 00 00 00       	mov    $0x1,%eax
  80144e:	eb 05                	jmp    801455 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801450:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801463:	6a 01                	push   $0x1
  801465:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	e8 50 ec ff ff       	call   8000be <sys_cputs>
}
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <getchar>:

int
getchar(void)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801479:	6a 01                	push   $0x1
  80147b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	6a 00                	push   $0x0
  801481:	e8 25 f2 ff ff       	call   8006ab <read>
	if (r < 0)
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 0f                	js     80149c <getchar+0x29>
		return r;
	if (r < 1)
  80148d:	85 c0                	test   %eax,%eax
  80148f:	7e 06                	jle    801497 <getchar+0x24>
		return -E_EOF;
	return c;
  801491:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801495:	eb 05                	jmp    80149c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801497:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	ff 75 08             	pushl  0x8(%ebp)
  8014ab:	e8 95 ef ff ff       	call   800445 <fd_lookup>
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 11                	js     8014c8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ba:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c0:	39 10                	cmp    %edx,(%eax)
  8014c2:	0f 94 c0             	sete   %al
  8014c5:	0f b6 c0             	movzbl %al,%eax
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <opencons>:

int
opencons(void)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	e8 1d ef ff ff       	call   8003f6 <fd_alloc>
  8014d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8014dc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 3e                	js     801520 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	68 07 04 00 00       	push   $0x407
  8014ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ed:	6a 00                	push   $0x0
  8014ef:	e8 86 ec ff ff       	call   80017a <sys_page_alloc>
  8014f4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014f7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 23                	js     801520 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014fd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801506:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	50                   	push   %eax
  801516:	e8 b4 ee ff ff       	call   8003cf <fd2num>
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	83 c4 10             	add    $0x10,%esp
}
  801520:	89 d0                	mov    %edx,%eax
  801522:	c9                   	leave  
  801523:	c3                   	ret    

00801524 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	56                   	push   %esi
  801528:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801529:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80152c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801532:	e8 05 ec ff ff       	call   80013c <sys_getenvid>
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	ff 75 0c             	pushl  0xc(%ebp)
  80153d:	ff 75 08             	pushl  0x8(%ebp)
  801540:	56                   	push   %esi
  801541:	50                   	push   %eax
  801542:	68 60 24 80 00       	push   $0x802460
  801547:	e8 b1 00 00 00       	call   8015fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80154c:	83 c4 18             	add    $0x18,%esp
  80154f:	53                   	push   %ebx
  801550:	ff 75 10             	pushl  0x10(%ebp)
  801553:	e8 54 00 00 00       	call   8015ac <vcprintf>
	cprintf("\n");
  801558:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  80155f:	e8 99 00 00 00       	call   8015fd <cprintf>
  801564:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801567:	cc                   	int3   
  801568:	eb fd                	jmp    801567 <_panic+0x43>

0080156a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801574:	8b 13                	mov    (%ebx),%edx
  801576:	8d 42 01             	lea    0x1(%edx),%eax
  801579:	89 03                	mov    %eax,(%ebx)
  80157b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80157e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801582:	3d ff 00 00 00       	cmp    $0xff,%eax
  801587:	75 1a                	jne    8015a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	68 ff 00 00 00       	push   $0xff
  801591:	8d 43 08             	lea    0x8(%ebx),%eax
  801594:	50                   	push   %eax
  801595:	e8 24 eb ff ff       	call   8000be <sys_cputs>
		b->idx = 0;
  80159a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015bc:	00 00 00 
	b.cnt = 0;
  8015bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015c9:	ff 75 0c             	pushl  0xc(%ebp)
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	68 6a 15 80 00       	push   $0x80156a
  8015db:	e8 54 01 00 00       	call   801734 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015e0:	83 c4 08             	add    $0x8,%esp
  8015e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	e8 c9 ea ff ff       	call   8000be <sys_cputs>

	return b.cnt;
}
  8015f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801603:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801606:	50                   	push   %eax
  801607:	ff 75 08             	pushl  0x8(%ebp)
  80160a:	e8 9d ff ff ff       	call   8015ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80160f:	c9                   	leave  
  801610:	c3                   	ret    

00801611 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	57                   	push   %edi
  801615:	56                   	push   %esi
  801616:	53                   	push   %ebx
  801617:	83 ec 1c             	sub    $0x1c,%esp
  80161a:	89 c7                	mov    %eax,%edi
  80161c:	89 d6                	mov    %edx,%esi
  80161e:	8b 45 08             	mov    0x8(%ebp),%eax
  801621:	8b 55 0c             	mov    0xc(%ebp),%edx
  801624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801627:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80162a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80162d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801632:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801635:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801638:	39 d3                	cmp    %edx,%ebx
  80163a:	72 05                	jb     801641 <printnum+0x30>
  80163c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80163f:	77 45                	ja     801686 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	ff 75 18             	pushl  0x18(%ebp)
  801647:	8b 45 14             	mov    0x14(%ebp),%eax
  80164a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80164d:	53                   	push   %ebx
  80164e:	ff 75 10             	pushl  0x10(%ebp)
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 e4             	pushl  -0x1c(%ebp)
  801657:	ff 75 e0             	pushl  -0x20(%ebp)
  80165a:	ff 75 dc             	pushl  -0x24(%ebp)
  80165d:	ff 75 d8             	pushl  -0x28(%ebp)
  801660:	e8 0b 0a 00 00       	call   802070 <__udivdi3>
  801665:	83 c4 18             	add    $0x18,%esp
  801668:	52                   	push   %edx
  801669:	50                   	push   %eax
  80166a:	89 f2                	mov    %esi,%edx
  80166c:	89 f8                	mov    %edi,%eax
  80166e:	e8 9e ff ff ff       	call   801611 <printnum>
  801673:	83 c4 20             	add    $0x20,%esp
  801676:	eb 18                	jmp    801690 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	56                   	push   %esi
  80167c:	ff 75 18             	pushl  0x18(%ebp)
  80167f:	ff d7                	call   *%edi
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	eb 03                	jmp    801689 <printnum+0x78>
  801686:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801689:	83 eb 01             	sub    $0x1,%ebx
  80168c:	85 db                	test   %ebx,%ebx
  80168e:	7f e8                	jg     801678 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	56                   	push   %esi
  801694:	83 ec 04             	sub    $0x4,%esp
  801697:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169a:	ff 75 e0             	pushl  -0x20(%ebp)
  80169d:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8016a3:	e8 f8 0a 00 00       	call   8021a0 <__umoddi3>
  8016a8:	83 c4 14             	add    $0x14,%esp
  8016ab:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8016b2:	50                   	push   %eax
  8016b3:	ff d7                	call   *%edi
}
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016c3:	83 fa 01             	cmp    $0x1,%edx
  8016c6:	7e 0e                	jle    8016d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016c8:	8b 10                	mov    (%eax),%edx
  8016ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016cd:	89 08                	mov    %ecx,(%eax)
  8016cf:	8b 02                	mov    (%edx),%eax
  8016d1:	8b 52 04             	mov    0x4(%edx),%edx
  8016d4:	eb 22                	jmp    8016f8 <getuint+0x38>
	else if (lflag)
  8016d6:	85 d2                	test   %edx,%edx
  8016d8:	74 10                	je     8016ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016da:	8b 10                	mov    (%eax),%edx
  8016dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016df:	89 08                	mov    %ecx,(%eax)
  8016e1:	8b 02                	mov    (%edx),%eax
  8016e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e8:	eb 0e                	jmp    8016f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016ea:	8b 10                	mov    (%eax),%edx
  8016ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016ef:	89 08                	mov    %ecx,(%eax)
  8016f1:	8b 02                	mov    (%edx),%eax
  8016f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801700:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801704:	8b 10                	mov    (%eax),%edx
  801706:	3b 50 04             	cmp    0x4(%eax),%edx
  801709:	73 0a                	jae    801715 <sprintputch+0x1b>
		*b->buf++ = ch;
  80170b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80170e:	89 08                	mov    %ecx,(%eax)
  801710:	8b 45 08             	mov    0x8(%ebp),%eax
  801713:	88 02                	mov    %al,(%edx)
}
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80171d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801720:	50                   	push   %eax
  801721:	ff 75 10             	pushl  0x10(%ebp)
  801724:	ff 75 0c             	pushl  0xc(%ebp)
  801727:	ff 75 08             	pushl  0x8(%ebp)
  80172a:	e8 05 00 00 00       	call   801734 <vprintfmt>
	va_end(ap);
}
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	57                   	push   %edi
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	83 ec 2c             	sub    $0x2c,%esp
  80173d:	8b 75 08             	mov    0x8(%ebp),%esi
  801740:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801743:	8b 7d 10             	mov    0x10(%ebp),%edi
  801746:	eb 12                	jmp    80175a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801748:	85 c0                	test   %eax,%eax
  80174a:	0f 84 89 03 00 00    	je     801ad9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	53                   	push   %ebx
  801754:	50                   	push   %eax
  801755:	ff d6                	call   *%esi
  801757:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80175a:	83 c7 01             	add    $0x1,%edi
  80175d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801761:	83 f8 25             	cmp    $0x25,%eax
  801764:	75 e2                	jne    801748 <vprintfmt+0x14>
  801766:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80176a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801771:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801778:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	eb 07                	jmp    80178d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801786:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801789:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178d:	8d 47 01             	lea    0x1(%edi),%eax
  801790:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801793:	0f b6 07             	movzbl (%edi),%eax
  801796:	0f b6 c8             	movzbl %al,%ecx
  801799:	83 e8 23             	sub    $0x23,%eax
  80179c:	3c 55                	cmp    $0x55,%al
  80179e:	0f 87 1a 03 00 00    	ja     801abe <vprintfmt+0x38a>
  8017a4:	0f b6 c0             	movzbl %al,%eax
  8017a7:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8017ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017b5:	eb d6                	jmp    80178d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017cf:	83 fa 09             	cmp    $0x9,%edx
  8017d2:	77 39                	ja     80180d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017d7:	eb e9                	jmp    8017c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8017df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017e2:	8b 00                	mov    (%eax),%eax
  8017e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017ea:	eb 27                	jmp    801813 <vprintfmt+0xdf>
  8017ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017f6:	0f 49 c8             	cmovns %eax,%ecx
  8017f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ff:	eb 8c                	jmp    80178d <vprintfmt+0x59>
  801801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801804:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80180b:	eb 80                	jmp    80178d <vprintfmt+0x59>
  80180d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801810:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801813:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801817:	0f 89 70 ff ff ff    	jns    80178d <vprintfmt+0x59>
				width = precision, precision = -1;
  80181d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801820:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801823:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80182a:	e9 5e ff ff ff       	jmp    80178d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80182f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801832:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801835:	e9 53 ff ff ff       	jmp    80178d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80183a:	8b 45 14             	mov    0x14(%ebp),%eax
  80183d:	8d 50 04             	lea    0x4(%eax),%edx
  801840:	89 55 14             	mov    %edx,0x14(%ebp)
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	53                   	push   %ebx
  801847:	ff 30                	pushl  (%eax)
  801849:	ff d6                	call   *%esi
			break;
  80184b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801851:	e9 04 ff ff ff       	jmp    80175a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801856:	8b 45 14             	mov    0x14(%ebp),%eax
  801859:	8d 50 04             	lea    0x4(%eax),%edx
  80185c:	89 55 14             	mov    %edx,0x14(%ebp)
  80185f:	8b 00                	mov    (%eax),%eax
  801861:	99                   	cltd   
  801862:	31 d0                	xor    %edx,%eax
  801864:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801866:	83 f8 0f             	cmp    $0xf,%eax
  801869:	7f 0b                	jg     801876 <vprintfmt+0x142>
  80186b:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  801872:	85 d2                	test   %edx,%edx
  801874:	75 18                	jne    80188e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801876:	50                   	push   %eax
  801877:	68 9b 24 80 00       	push   $0x80249b
  80187c:	53                   	push   %ebx
  80187d:	56                   	push   %esi
  80187e:	e8 94 fe ff ff       	call   801717 <printfmt>
  801883:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801886:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801889:	e9 cc fe ff ff       	jmp    80175a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80188e:	52                   	push   %edx
  80188f:	68 e1 23 80 00       	push   $0x8023e1
  801894:	53                   	push   %ebx
  801895:	56                   	push   %esi
  801896:	e8 7c fe ff ff       	call   801717 <printfmt>
  80189b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018a1:	e9 b4 fe ff ff       	jmp    80175a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a9:	8d 50 04             	lea    0x4(%eax),%edx
  8018ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8018af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018b1:	85 ff                	test   %edi,%edi
  8018b3:	b8 94 24 80 00       	mov    $0x802494,%eax
  8018b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018bf:	0f 8e 94 00 00 00    	jle    801959 <vprintfmt+0x225>
  8018c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018c9:	0f 84 98 00 00 00    	je     801967 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8018d5:	57                   	push   %edi
  8018d6:	e8 86 02 00 00       	call   801b61 <strnlen>
  8018db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018de:	29 c1                	sub    %eax,%ecx
  8018e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018f2:	eb 0f                	jmp    801903 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	53                   	push   %ebx
  8018f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018fd:	83 ef 01             	sub    $0x1,%edi
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	85 ff                	test   %edi,%edi
  801905:	7f ed                	jg     8018f4 <vprintfmt+0x1c0>
  801907:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80190a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80190d:	85 c9                	test   %ecx,%ecx
  80190f:	b8 00 00 00 00       	mov    $0x0,%eax
  801914:	0f 49 c1             	cmovns %ecx,%eax
  801917:	29 c1                	sub    %eax,%ecx
  801919:	89 75 08             	mov    %esi,0x8(%ebp)
  80191c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80191f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801922:	89 cb                	mov    %ecx,%ebx
  801924:	eb 4d                	jmp    801973 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801926:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80192a:	74 1b                	je     801947 <vprintfmt+0x213>
  80192c:	0f be c0             	movsbl %al,%eax
  80192f:	83 e8 20             	sub    $0x20,%eax
  801932:	83 f8 5e             	cmp    $0x5e,%eax
  801935:	76 10                	jbe    801947 <vprintfmt+0x213>
					putch('?', putdat);
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	ff 75 0c             	pushl  0xc(%ebp)
  80193d:	6a 3f                	push   $0x3f
  80193f:	ff 55 08             	call   *0x8(%ebp)
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	eb 0d                	jmp    801954 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	ff 75 0c             	pushl  0xc(%ebp)
  80194d:	52                   	push   %edx
  80194e:	ff 55 08             	call   *0x8(%ebp)
  801951:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801954:	83 eb 01             	sub    $0x1,%ebx
  801957:	eb 1a                	jmp    801973 <vprintfmt+0x23f>
  801959:	89 75 08             	mov    %esi,0x8(%ebp)
  80195c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80195f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801962:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801965:	eb 0c                	jmp    801973 <vprintfmt+0x23f>
  801967:	89 75 08             	mov    %esi,0x8(%ebp)
  80196a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80196d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801970:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801973:	83 c7 01             	add    $0x1,%edi
  801976:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80197a:	0f be d0             	movsbl %al,%edx
  80197d:	85 d2                	test   %edx,%edx
  80197f:	74 23                	je     8019a4 <vprintfmt+0x270>
  801981:	85 f6                	test   %esi,%esi
  801983:	78 a1                	js     801926 <vprintfmt+0x1f2>
  801985:	83 ee 01             	sub    $0x1,%esi
  801988:	79 9c                	jns    801926 <vprintfmt+0x1f2>
  80198a:	89 df                	mov    %ebx,%edi
  80198c:	8b 75 08             	mov    0x8(%ebp),%esi
  80198f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801992:	eb 18                	jmp    8019ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	53                   	push   %ebx
  801998:	6a 20                	push   $0x20
  80199a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80199c:	83 ef 01             	sub    $0x1,%edi
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	eb 08                	jmp    8019ac <vprintfmt+0x278>
  8019a4:	89 df                	mov    %ebx,%edi
  8019a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8019a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ac:	85 ff                	test   %edi,%edi
  8019ae:	7f e4                	jg     801994 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019b3:	e9 a2 fd ff ff       	jmp    80175a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019b8:	83 fa 01             	cmp    $0x1,%edx
  8019bb:	7e 16                	jle    8019d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c0:	8d 50 08             	lea    0x8(%eax),%edx
  8019c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c6:	8b 50 04             	mov    0x4(%eax),%edx
  8019c9:	8b 00                	mov    (%eax),%eax
  8019cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019d1:	eb 32                	jmp    801a05 <vprintfmt+0x2d1>
	else if (lflag)
  8019d3:	85 d2                	test   %edx,%edx
  8019d5:	74 18                	je     8019ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019da:	8d 50 04             	lea    0x4(%eax),%edx
  8019dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e0:	8b 00                	mov    (%eax),%eax
  8019e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019e5:	89 c1                	mov    %eax,%ecx
  8019e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019ed:	eb 16                	jmp    801a05 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f2:	8d 50 04             	lea    0x4(%eax),%edx
  8019f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019f8:	8b 00                	mov    (%eax),%eax
  8019fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019fd:	89 c1                	mov    %eax,%ecx
  8019ff:	c1 f9 1f             	sar    $0x1f,%ecx
  801a02:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a05:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a08:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a0b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a10:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a14:	79 74                	jns    801a8a <vprintfmt+0x356>
				putch('-', putdat);
  801a16:	83 ec 08             	sub    $0x8,%esp
  801a19:	53                   	push   %ebx
  801a1a:	6a 2d                	push   $0x2d
  801a1c:	ff d6                	call   *%esi
				num = -(long long) num;
  801a1e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a21:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a24:	f7 d8                	neg    %eax
  801a26:	83 d2 00             	adc    $0x0,%edx
  801a29:	f7 da                	neg    %edx
  801a2b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a2e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a33:	eb 55                	jmp    801a8a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a35:	8d 45 14             	lea    0x14(%ebp),%eax
  801a38:	e8 83 fc ff ff       	call   8016c0 <getuint>
			base = 10;
  801a3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a42:	eb 46                	jmp    801a8a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a44:	8d 45 14             	lea    0x14(%ebp),%eax
  801a47:	e8 74 fc ff ff       	call   8016c0 <getuint>
		        base = 8;
  801a4c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a51:	eb 37                	jmp    801a8a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	53                   	push   %ebx
  801a57:	6a 30                	push   $0x30
  801a59:	ff d6                	call   *%esi
			putch('x', putdat);
  801a5b:	83 c4 08             	add    $0x8,%esp
  801a5e:	53                   	push   %ebx
  801a5f:	6a 78                	push   $0x78
  801a61:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a63:	8b 45 14             	mov    0x14(%ebp),%eax
  801a66:	8d 50 04             	lea    0x4(%eax),%edx
  801a69:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a6c:	8b 00                	mov    (%eax),%eax
  801a6e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a73:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a76:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a7b:	eb 0d                	jmp    801a8a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a7d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a80:	e8 3b fc ff ff       	call   8016c0 <getuint>
			base = 16;
  801a85:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a91:	57                   	push   %edi
  801a92:	ff 75 e0             	pushl  -0x20(%ebp)
  801a95:	51                   	push   %ecx
  801a96:	52                   	push   %edx
  801a97:	50                   	push   %eax
  801a98:	89 da                	mov    %ebx,%edx
  801a9a:	89 f0                	mov    %esi,%eax
  801a9c:	e8 70 fb ff ff       	call   801611 <printnum>
			break;
  801aa1:	83 c4 20             	add    $0x20,%esp
  801aa4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801aa7:	e9 ae fc ff ff       	jmp    80175a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	53                   	push   %ebx
  801ab0:	51                   	push   %ecx
  801ab1:	ff d6                	call   *%esi
			break;
  801ab3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ab9:	e9 9c fc ff ff       	jmp    80175a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	53                   	push   %ebx
  801ac2:	6a 25                	push   $0x25
  801ac4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	eb 03                	jmp    801ace <vprintfmt+0x39a>
  801acb:	83 ef 01             	sub    $0x1,%edi
  801ace:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ad2:	75 f7                	jne    801acb <vprintfmt+0x397>
  801ad4:	e9 81 fc ff ff       	jmp    80175a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 18             	sub    $0x18,%esp
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801af0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801af4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801af7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801afe:	85 c0                	test   %eax,%eax
  801b00:	74 26                	je     801b28 <vsnprintf+0x47>
  801b02:	85 d2                	test   %edx,%edx
  801b04:	7e 22                	jle    801b28 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b06:	ff 75 14             	pushl  0x14(%ebp)
  801b09:	ff 75 10             	pushl  0x10(%ebp)
  801b0c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b0f:	50                   	push   %eax
  801b10:	68 fa 16 80 00       	push   $0x8016fa
  801b15:	e8 1a fc ff ff       	call   801734 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b1d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	eb 05                	jmp    801b2d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b35:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b38:	50                   	push   %eax
  801b39:	ff 75 10             	pushl  0x10(%ebp)
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	ff 75 08             	pushl  0x8(%ebp)
  801b42:	e8 9a ff ff ff       	call   801ae1 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b54:	eb 03                	jmp    801b59 <strlen+0x10>
		n++;
  801b56:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b59:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b5d:	75 f7                	jne    801b56 <strlen+0xd>
		n++;
	return n;
}
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b67:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6f:	eb 03                	jmp    801b74 <strnlen+0x13>
		n++;
  801b71:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b74:	39 c2                	cmp    %eax,%edx
  801b76:	74 08                	je     801b80 <strnlen+0x1f>
  801b78:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b7c:	75 f3                	jne    801b71 <strnlen+0x10>
  801b7e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b80:	5d                   	pop    %ebp
  801b81:	c3                   	ret    

00801b82 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	53                   	push   %ebx
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	83 c2 01             	add    $0x1,%edx
  801b91:	83 c1 01             	add    $0x1,%ecx
  801b94:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b98:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b9b:	84 db                	test   %bl,%bl
  801b9d:	75 ef                	jne    801b8e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b9f:	5b                   	pop    %ebx
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ba9:	53                   	push   %ebx
  801baa:	e8 9a ff ff ff       	call   801b49 <strlen>
  801baf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bb2:	ff 75 0c             	pushl  0xc(%ebp)
  801bb5:	01 d8                	add    %ebx,%eax
  801bb7:	50                   	push   %eax
  801bb8:	e8 c5 ff ff ff       	call   801b82 <strcpy>
	return dst;
}
  801bbd:	89 d8                	mov    %ebx,%eax
  801bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	56                   	push   %esi
  801bc8:	53                   	push   %ebx
  801bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcf:	89 f3                	mov    %esi,%ebx
  801bd1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd4:	89 f2                	mov    %esi,%edx
  801bd6:	eb 0f                	jmp    801be7 <strncpy+0x23>
		*dst++ = *src;
  801bd8:	83 c2 01             	add    $0x1,%edx
  801bdb:	0f b6 01             	movzbl (%ecx),%eax
  801bde:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be1:	80 39 01             	cmpb   $0x1,(%ecx)
  801be4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801be7:	39 da                	cmp    %ebx,%edx
  801be9:	75 ed                	jne    801bd8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801beb:	89 f0                	mov    %esi,%eax
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfc:	8b 55 10             	mov    0x10(%ebp),%edx
  801bff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c01:	85 d2                	test   %edx,%edx
  801c03:	74 21                	je     801c26 <strlcpy+0x35>
  801c05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c09:	89 f2                	mov    %esi,%edx
  801c0b:	eb 09                	jmp    801c16 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c0d:	83 c2 01             	add    $0x1,%edx
  801c10:	83 c1 01             	add    $0x1,%ecx
  801c13:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c16:	39 c2                	cmp    %eax,%edx
  801c18:	74 09                	je     801c23 <strlcpy+0x32>
  801c1a:	0f b6 19             	movzbl (%ecx),%ebx
  801c1d:	84 db                	test   %bl,%bl
  801c1f:	75 ec                	jne    801c0d <strlcpy+0x1c>
  801c21:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c26:	29 f0                	sub    %esi,%eax
}
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c35:	eb 06                	jmp    801c3d <strcmp+0x11>
		p++, q++;
  801c37:	83 c1 01             	add    $0x1,%ecx
  801c3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c3d:	0f b6 01             	movzbl (%ecx),%eax
  801c40:	84 c0                	test   %al,%al
  801c42:	74 04                	je     801c48 <strcmp+0x1c>
  801c44:	3a 02                	cmp    (%edx),%al
  801c46:	74 ef                	je     801c37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c48:	0f b6 c0             	movzbl %al,%eax
  801c4b:	0f b6 12             	movzbl (%edx),%edx
  801c4e:	29 d0                	sub    %edx,%eax
}
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	53                   	push   %ebx
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c61:	eb 06                	jmp    801c69 <strncmp+0x17>
		n--, p++, q++;
  801c63:	83 c0 01             	add    $0x1,%eax
  801c66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c69:	39 d8                	cmp    %ebx,%eax
  801c6b:	74 15                	je     801c82 <strncmp+0x30>
  801c6d:	0f b6 08             	movzbl (%eax),%ecx
  801c70:	84 c9                	test   %cl,%cl
  801c72:	74 04                	je     801c78 <strncmp+0x26>
  801c74:	3a 0a                	cmp    (%edx),%cl
  801c76:	74 eb                	je     801c63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c78:	0f b6 00             	movzbl (%eax),%eax
  801c7b:	0f b6 12             	movzbl (%edx),%edx
  801c7e:	29 d0                	sub    %edx,%eax
  801c80:	eb 05                	jmp    801c87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c87:	5b                   	pop    %ebx
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c94:	eb 07                	jmp    801c9d <strchr+0x13>
		if (*s == c)
  801c96:	38 ca                	cmp    %cl,%dl
  801c98:	74 0f                	je     801ca9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c9a:	83 c0 01             	add    $0x1,%eax
  801c9d:	0f b6 10             	movzbl (%eax),%edx
  801ca0:	84 d2                	test   %dl,%dl
  801ca2:	75 f2                	jne    801c96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb5:	eb 03                	jmp    801cba <strfind+0xf>
  801cb7:	83 c0 01             	add    $0x1,%eax
  801cba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cbd:	38 ca                	cmp    %cl,%dl
  801cbf:	74 04                	je     801cc5 <strfind+0x1a>
  801cc1:	84 d2                	test   %dl,%dl
  801cc3:	75 f2                	jne    801cb7 <strfind+0xc>
			break;
	return (char *) s;
}
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	57                   	push   %edi
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cd3:	85 c9                	test   %ecx,%ecx
  801cd5:	74 36                	je     801d0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cd7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cdd:	75 28                	jne    801d07 <memset+0x40>
  801cdf:	f6 c1 03             	test   $0x3,%cl
  801ce2:	75 23                	jne    801d07 <memset+0x40>
		c &= 0xFF;
  801ce4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ce8:	89 d3                	mov    %edx,%ebx
  801cea:	c1 e3 08             	shl    $0x8,%ebx
  801ced:	89 d6                	mov    %edx,%esi
  801cef:	c1 e6 18             	shl    $0x18,%esi
  801cf2:	89 d0                	mov    %edx,%eax
  801cf4:	c1 e0 10             	shl    $0x10,%eax
  801cf7:	09 f0                	or     %esi,%eax
  801cf9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cfb:	89 d8                	mov    %ebx,%eax
  801cfd:	09 d0                	or     %edx,%eax
  801cff:	c1 e9 02             	shr    $0x2,%ecx
  801d02:	fc                   	cld    
  801d03:	f3 ab                	rep stos %eax,%es:(%edi)
  801d05:	eb 06                	jmp    801d0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0a:	fc                   	cld    
  801d0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d0d:	89 f8                	mov    %edi,%eax
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	57                   	push   %edi
  801d18:	56                   	push   %esi
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d22:	39 c6                	cmp    %eax,%esi
  801d24:	73 35                	jae    801d5b <memmove+0x47>
  801d26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d29:	39 d0                	cmp    %edx,%eax
  801d2b:	73 2e                	jae    801d5b <memmove+0x47>
		s += n;
		d += n;
  801d2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d30:	89 d6                	mov    %edx,%esi
  801d32:	09 fe                	or     %edi,%esi
  801d34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d3a:	75 13                	jne    801d4f <memmove+0x3b>
  801d3c:	f6 c1 03             	test   $0x3,%cl
  801d3f:	75 0e                	jne    801d4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d41:	83 ef 04             	sub    $0x4,%edi
  801d44:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d47:	c1 e9 02             	shr    $0x2,%ecx
  801d4a:	fd                   	std    
  801d4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d4d:	eb 09                	jmp    801d58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d4f:	83 ef 01             	sub    $0x1,%edi
  801d52:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d55:	fd                   	std    
  801d56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d58:	fc                   	cld    
  801d59:	eb 1d                	jmp    801d78 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d5b:	89 f2                	mov    %esi,%edx
  801d5d:	09 c2                	or     %eax,%edx
  801d5f:	f6 c2 03             	test   $0x3,%dl
  801d62:	75 0f                	jne    801d73 <memmove+0x5f>
  801d64:	f6 c1 03             	test   $0x3,%cl
  801d67:	75 0a                	jne    801d73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d69:	c1 e9 02             	shr    $0x2,%ecx
  801d6c:	89 c7                	mov    %eax,%edi
  801d6e:	fc                   	cld    
  801d6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d71:	eb 05                	jmp    801d78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d73:	89 c7                	mov    %eax,%edi
  801d75:	fc                   	cld    
  801d76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    

00801d7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d7f:	ff 75 10             	pushl  0x10(%ebp)
  801d82:	ff 75 0c             	pushl  0xc(%ebp)
  801d85:	ff 75 08             	pushl  0x8(%ebp)
  801d88:	e8 87 ff ff ff       	call   801d14 <memmove>
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9a:	89 c6                	mov    %eax,%esi
  801d9c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d9f:	eb 1a                	jmp    801dbb <memcmp+0x2c>
		if (*s1 != *s2)
  801da1:	0f b6 08             	movzbl (%eax),%ecx
  801da4:	0f b6 1a             	movzbl (%edx),%ebx
  801da7:	38 d9                	cmp    %bl,%cl
  801da9:	74 0a                	je     801db5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801dab:	0f b6 c1             	movzbl %cl,%eax
  801dae:	0f b6 db             	movzbl %bl,%ebx
  801db1:	29 d8                	sub    %ebx,%eax
  801db3:	eb 0f                	jmp    801dc4 <memcmp+0x35>
		s1++, s2++;
  801db5:	83 c0 01             	add    $0x1,%eax
  801db8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dbb:	39 f0                	cmp    %esi,%eax
  801dbd:	75 e2                	jne    801da1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc4:	5b                   	pop    %ebx
  801dc5:	5e                   	pop    %esi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	53                   	push   %ebx
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dcf:	89 c1                	mov    %eax,%ecx
  801dd1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dd4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dd8:	eb 0a                	jmp    801de4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dda:	0f b6 10             	movzbl (%eax),%edx
  801ddd:	39 da                	cmp    %ebx,%edx
  801ddf:	74 07                	je     801de8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801de1:	83 c0 01             	add    $0x1,%eax
  801de4:	39 c8                	cmp    %ecx,%eax
  801de6:	72 f2                	jb     801dda <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801de8:	5b                   	pop    %ebx
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	57                   	push   %edi
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801df4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801df7:	eb 03                	jmp    801dfc <strtol+0x11>
		s++;
  801df9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dfc:	0f b6 01             	movzbl (%ecx),%eax
  801dff:	3c 20                	cmp    $0x20,%al
  801e01:	74 f6                	je     801df9 <strtol+0xe>
  801e03:	3c 09                	cmp    $0x9,%al
  801e05:	74 f2                	je     801df9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e07:	3c 2b                	cmp    $0x2b,%al
  801e09:	75 0a                	jne    801e15 <strtol+0x2a>
		s++;
  801e0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e0e:	bf 00 00 00 00       	mov    $0x0,%edi
  801e13:	eb 11                	jmp    801e26 <strtol+0x3b>
  801e15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e1a:	3c 2d                	cmp    $0x2d,%al
  801e1c:	75 08                	jne    801e26 <strtol+0x3b>
		s++, neg = 1;
  801e1e:	83 c1 01             	add    $0x1,%ecx
  801e21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e2c:	75 15                	jne    801e43 <strtol+0x58>
  801e2e:	80 39 30             	cmpb   $0x30,(%ecx)
  801e31:	75 10                	jne    801e43 <strtol+0x58>
  801e33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e37:	75 7c                	jne    801eb5 <strtol+0xca>
		s += 2, base = 16;
  801e39:	83 c1 02             	add    $0x2,%ecx
  801e3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e41:	eb 16                	jmp    801e59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e43:	85 db                	test   %ebx,%ebx
  801e45:	75 12                	jne    801e59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e4c:	80 39 30             	cmpb   $0x30,(%ecx)
  801e4f:	75 08                	jne    801e59 <strtol+0x6e>
		s++, base = 8;
  801e51:	83 c1 01             	add    $0x1,%ecx
  801e54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e59:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e61:	0f b6 11             	movzbl (%ecx),%edx
  801e64:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e67:	89 f3                	mov    %esi,%ebx
  801e69:	80 fb 09             	cmp    $0x9,%bl
  801e6c:	77 08                	ja     801e76 <strtol+0x8b>
			dig = *s - '0';
  801e6e:	0f be d2             	movsbl %dl,%edx
  801e71:	83 ea 30             	sub    $0x30,%edx
  801e74:	eb 22                	jmp    801e98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e76:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e79:	89 f3                	mov    %esi,%ebx
  801e7b:	80 fb 19             	cmp    $0x19,%bl
  801e7e:	77 08                	ja     801e88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e80:	0f be d2             	movsbl %dl,%edx
  801e83:	83 ea 57             	sub    $0x57,%edx
  801e86:	eb 10                	jmp    801e98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e88:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e8b:	89 f3                	mov    %esi,%ebx
  801e8d:	80 fb 19             	cmp    $0x19,%bl
  801e90:	77 16                	ja     801ea8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e92:	0f be d2             	movsbl %dl,%edx
  801e95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e98:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e9b:	7d 0b                	jge    801ea8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e9d:	83 c1 01             	add    $0x1,%ecx
  801ea0:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ea4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ea6:	eb b9                	jmp    801e61 <strtol+0x76>

	if (endptr)
  801ea8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eac:	74 0d                	je     801ebb <strtol+0xd0>
		*endptr = (char *) s;
  801eae:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb1:	89 0e                	mov    %ecx,(%esi)
  801eb3:	eb 06                	jmp    801ebb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eb5:	85 db                	test   %ebx,%ebx
  801eb7:	74 98                	je     801e51 <strtol+0x66>
  801eb9:	eb 9e                	jmp    801e59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ebb:	89 c2                	mov    %eax,%edx
  801ebd:	f7 da                	neg    %edx
  801ebf:	85 ff                	test   %edi,%edi
  801ec1:	0f 45 c2             	cmovne %edx,%eax
}
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ecf:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801ed6:	75 2c                	jne    801f04 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	6a 07                	push   $0x7
  801edd:	68 00 f0 bf ee       	push   $0xeebff000
  801ee2:	6a 00                	push   $0x0
  801ee4:	e8 91 e2 ff ff       	call   80017a <sys_page_alloc>
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	85 c0                	test   %eax,%eax
  801eee:	79 14                	jns    801f04 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  801ef0:	83 ec 04             	sub    $0x4,%esp
  801ef3:	68 7f 27 80 00       	push   $0x80277f
  801ef8:	6a 22                	push   $0x22
  801efa:	68 96 27 80 00       	push   $0x802796
  801eff:	e8 20 f6 ff ff       	call   801524 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f0c:	83 ec 08             	sub    $0x8,%esp
  801f0f:	68 ab 03 80 00       	push   $0x8003ab
  801f14:	6a 00                	push   $0x0
  801f16:	e8 aa e3 ff ff       	call   8002c5 <sys_env_set_pgfault_upcall>
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	79 14                	jns    801f36 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  801f22:	83 ec 04             	sub    $0x4,%esp
  801f25:	68 a4 27 80 00       	push   $0x8027a4
  801f2a:	6a 27                	push   $0x27
  801f2c:	68 96 27 80 00       	push   $0x802796
  801f31:	e8 ee f5 ff ff       	call   801524 <_panic>
    
}
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801f46:	85 c0                	test   %eax,%eax
  801f48:	74 0e                	je     801f58 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801f4a:	83 ec 0c             	sub    $0xc,%esp
  801f4d:	50                   	push   %eax
  801f4e:	e8 d7 e3 ff ff       	call   80032a <sys_ipc_recv>
  801f53:	83 c4 10             	add    $0x10,%esp
  801f56:	eb 10                	jmp    801f68 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801f58:	83 ec 0c             	sub    $0xc,%esp
  801f5b:	68 00 00 00 f0       	push   $0xf0000000
  801f60:	e8 c5 e3 ff ff       	call   80032a <sys_ipc_recv>
  801f65:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	74 0e                	je     801f7a <ipc_recv+0x42>
    	*from_env_store = 0;
  801f6c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801f72:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801f78:	eb 24                	jmp    801f9e <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801f7a:	85 f6                	test   %esi,%esi
  801f7c:	74 0a                	je     801f88 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801f7e:	a1 08 40 80 00       	mov    0x804008,%eax
  801f83:	8b 40 74             	mov    0x74(%eax),%eax
  801f86:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801f88:	85 db                	test   %ebx,%ebx
  801f8a:	74 0a                	je     801f96 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801f8c:	a1 08 40 80 00       	mov    0x804008,%eax
  801f91:	8b 40 78             	mov    0x78(%eax),%eax
  801f94:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801f96:	a1 08 40 80 00       	mov    0x804008,%eax
  801f9b:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    

00801fa5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	57                   	push   %edi
  801fa9:	56                   	push   %esi
  801faa:	53                   	push   %ebx
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801fb7:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fbe:	0f 44 d8             	cmove  %eax,%ebx
  801fc1:	eb 1c                	jmp    801fdf <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801fc3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fc6:	74 12                	je     801fda <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801fc8:	50                   	push   %eax
  801fc9:	68 c8 27 80 00       	push   $0x8027c8
  801fce:	6a 4b                	push   $0x4b
  801fd0:	68 e0 27 80 00       	push   $0x8027e0
  801fd5:	e8 4a f5 ff ff       	call   801524 <_panic>
        }	
        sys_yield();
  801fda:	e8 7c e1 ff ff       	call   80015b <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fdf:	ff 75 14             	pushl  0x14(%ebp)
  801fe2:	53                   	push   %ebx
  801fe3:	56                   	push   %esi
  801fe4:	57                   	push   %edi
  801fe5:	e8 1d e3 ff ff       	call   800307 <sys_ipc_try_send>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	85 c0                	test   %eax,%eax
  801fef:	75 d2                	jne    801fc3 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802004:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802007:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80200d:	8b 52 50             	mov    0x50(%edx),%edx
  802010:	39 ca                	cmp    %ecx,%edx
  802012:	75 0d                	jne    802021 <ipc_find_env+0x28>
			return envs[i].env_id;
  802014:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802017:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80201c:	8b 40 48             	mov    0x48(%eax),%eax
  80201f:	eb 0f                	jmp    802030 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802021:	83 c0 01             	add    $0x1,%eax
  802024:	3d 00 04 00 00       	cmp    $0x400,%eax
  802029:	75 d9                	jne    802004 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802038:	89 d0                	mov    %edx,%eax
  80203a:	c1 e8 16             	shr    $0x16,%eax
  80203d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802049:	f6 c1 01             	test   $0x1,%cl
  80204c:	74 1d                	je     80206b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80204e:	c1 ea 0c             	shr    $0xc,%edx
  802051:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802058:	f6 c2 01             	test   $0x1,%dl
  80205b:	74 0e                	je     80206b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205d:	c1 ea 0c             	shr    $0xc,%edx
  802060:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802067:	ef 
  802068:	0f b7 c0             	movzwl %ax,%eax
}
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    
  80206d:	66 90                	xchg   %ax,%ax
  80206f:	90                   	nop

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
