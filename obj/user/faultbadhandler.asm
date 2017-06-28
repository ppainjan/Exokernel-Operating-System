
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 44 01 00 00       	call   80018b <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 80 02 00 00       	call   8002d6 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800070:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800077:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80007a:	e8 ce 00 00 00       	call   80014d <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 db                	test   %ebx,%ebx
  800093:	7e 07                	jle    80009c <libmain+0x37>
		binaryname = argv[0];
  800095:	8b 06                	mov    (%esi),%eax
  800097:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009c:	83 ec 08             	sub    $0x8,%esp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	e8 8d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a6:	e8 0a 00 00 00       	call   8000b5 <exit>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    

008000b5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000bb:	e8 c7 04 00 00       	call   800587 <close_all>
	sys_env_destroy(0);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	6a 00                	push   $0x0
  8000c5:	e8 42 00 00 00       	call   80010c <sys_env_destroy>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    

008000cf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e0:	89 c3                	mov    %eax,%ebx
  8000e2:	89 c7                	mov    %eax,%edi
  8000e4:	89 c6                	mov    %eax,%esi
  8000e6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fd:	89 d1                	mov    %edx,%ecx
  8000ff:	89 d3                	mov    %edx,%ebx
  800101:	89 d7                	mov    %edx,%edi
  800103:	89 d6                	mov    %edx,%esi
  800105:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5f                   	pop    %edi
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    

0080010c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	57                   	push   %edi
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800115:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011a:	b8 03 00 00 00       	mov    $0x3,%eax
  80011f:	8b 55 08             	mov    0x8(%ebp),%edx
  800122:	89 cb                	mov    %ecx,%ebx
  800124:	89 cf                	mov    %ecx,%edi
  800126:	89 ce                	mov    %ecx,%esi
  800128:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7e 17                	jle    800145 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012e:	83 ec 0c             	sub    $0xc,%esp
  800131:	50                   	push   %eax
  800132:	6a 03                	push   $0x3
  800134:	68 8a 22 80 00       	push   $0x80228a
  800139:	6a 23                	push   $0x23
  80013b:	68 a7 22 80 00       	push   $0x8022a7
  800140:	e8 cc 13 00 00       	call   801511 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 02 00 00 00       	mov    $0x2,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_yield>:

void
sys_yield(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800172:	ba 00 00 00 00       	mov    $0x0,%edx
  800177:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017c:	89 d1                	mov    %edx,%ecx
  80017e:	89 d3                	mov    %edx,%ebx
  800180:	89 d7                	mov    %edx,%edi
  800182:	89 d6                	mov    %edx,%esi
  800184:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800186:	5b                   	pop    %ebx
  800187:	5e                   	pop    %esi
  800188:	5f                   	pop    %edi
  800189:	5d                   	pop    %ebp
  80018a:	c3                   	ret    

0080018b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	57                   	push   %edi
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800194:	be 00 00 00 00       	mov    $0x0,%esi
  800199:	b8 04 00 00 00       	mov    $0x4,%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	89 f7                	mov    %esi,%edi
  8001a9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ab:	85 c0                	test   %eax,%eax
  8001ad:	7e 17                	jle    8001c6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	50                   	push   %eax
  8001b3:	6a 04                	push   $0x4
  8001b5:	68 8a 22 80 00       	push   $0x80228a
  8001ba:	6a 23                	push   $0x23
  8001bc:	68 a7 22 80 00       	push   $0x8022a7
  8001c1:	e8 4b 13 00 00       	call   801511 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c9:	5b                   	pop    %ebx
  8001ca:	5e                   	pop    %esi
  8001cb:	5f                   	pop    %edi
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    

008001ce <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	57                   	push   %edi
  8001d2:	56                   	push   %esi
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001df:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ed:	85 c0                	test   %eax,%eax
  8001ef:	7e 17                	jle    800208 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	50                   	push   %eax
  8001f5:	6a 05                	push   $0x5
  8001f7:	68 8a 22 80 00       	push   $0x80228a
  8001fc:	6a 23                	push   $0x23
  8001fe:	68 a7 22 80 00       	push   $0x8022a7
  800203:	e8 09 13 00 00       	call   801511 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    

00800210 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	b8 06 00 00 00       	mov    $0x6,%eax
  800223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800226:	8b 55 08             	mov    0x8(%ebp),%edx
  800229:	89 df                	mov    %ebx,%edi
  80022b:	89 de                	mov    %ebx,%esi
  80022d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80022f:	85 c0                	test   %eax,%eax
  800231:	7e 17                	jle    80024a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800233:	83 ec 0c             	sub    $0xc,%esp
  800236:	50                   	push   %eax
  800237:	6a 06                	push   $0x6
  800239:	68 8a 22 80 00       	push   $0x80228a
  80023e:	6a 23                	push   $0x23
  800240:	68 a7 22 80 00       	push   $0x8022a7
  800245:	e8 c7 12 00 00       	call   801511 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800260:	b8 08 00 00 00       	mov    $0x8,%eax
  800265:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800268:	8b 55 08             	mov    0x8(%ebp),%edx
  80026b:	89 df                	mov    %ebx,%edi
  80026d:	89 de                	mov    %ebx,%esi
  80026f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800271:	85 c0                	test   %eax,%eax
  800273:	7e 17                	jle    80028c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	50                   	push   %eax
  800279:	6a 08                	push   $0x8
  80027b:	68 8a 22 80 00       	push   $0x80228a
  800280:	6a 23                	push   $0x23
  800282:	68 a7 22 80 00       	push   $0x8022a7
  800287:	e8 85 12 00 00       	call   801511 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028f:	5b                   	pop    %ebx
  800290:	5e                   	pop    %esi
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ad:	89 df                	mov    %ebx,%edi
  8002af:	89 de                	mov    %ebx,%esi
  8002b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b3:	85 c0                	test   %eax,%eax
  8002b5:	7e 17                	jle    8002ce <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	50                   	push   %eax
  8002bb:	6a 09                	push   $0x9
  8002bd:	68 8a 22 80 00       	push   $0x80228a
  8002c2:	6a 23                	push   $0x23
  8002c4:	68 a7 22 80 00       	push   $0x8022a7
  8002c9:	e8 43 12 00 00       	call   801511 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	89 df                	mov    %ebx,%edi
  8002f1:	89 de                	mov    %ebx,%esi
  8002f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7e 17                	jle    800310 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	83 ec 0c             	sub    $0xc,%esp
  8002fc:	50                   	push   %eax
  8002fd:	6a 0a                	push   $0xa
  8002ff:	68 8a 22 80 00       	push   $0x80228a
  800304:	6a 23                	push   $0x23
  800306:	68 a7 22 80 00       	push   $0x8022a7
  80030b:	e8 01 12 00 00       	call   801511 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031e:	be 00 00 00 00       	mov    $0x0,%esi
  800323:	b8 0c 00 00 00       	mov    $0xc,%eax
  800328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
  80032e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800331:	8b 7d 14             	mov    0x14(%ebp),%edi
  800334:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800336:	5b                   	pop    %ebx
  800337:	5e                   	pop    %esi
  800338:	5f                   	pop    %edi
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800344:	b9 00 00 00 00       	mov    $0x0,%ecx
  800349:	b8 0d 00 00 00       	mov    $0xd,%eax
  80034e:	8b 55 08             	mov    0x8(%ebp),%edx
  800351:	89 cb                	mov    %ecx,%ebx
  800353:	89 cf                	mov    %ecx,%edi
  800355:	89 ce                	mov    %ecx,%esi
  800357:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	7e 17                	jle    800374 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035d:	83 ec 0c             	sub    $0xc,%esp
  800360:	50                   	push   %eax
  800361:	6a 0d                	push   $0xd
  800363:	68 8a 22 80 00       	push   $0x80228a
  800368:	6a 23                	push   $0x23
  80036a:	68 a7 22 80 00       	push   $0x8022a7
  80036f:	e8 9d 11 00 00       	call   801511 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800374:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	b8 0e 00 00 00       	mov    $0xe,%eax
  80038c:	89 d1                	mov    %edx,%ecx
  80038e:	89 d3                	mov    %edx,%ebx
  800390:	89 d7                	mov    %edx,%edi
  800392:	89 d6                	mov    %edx,%esi
  800394:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800396:	5b                   	pop    %ebx
  800397:	5e                   	pop    %esi
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b1:	89 df                	mov    %ebx,%edi
  8003b3:	89 de                	mov    %ebx,%esi
  8003b5:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  8003b7:	5b                   	pop    %ebx
  8003b8:	5e                   	pop    %esi
  8003b9:	5f                   	pop    %edi
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003dc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 16             	shr    $0x16,%edx
  8003f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 11                	je     800410 <fd_alloc+0x2d>
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 0c             	shr    $0xc,%edx
  800404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	75 09                	jne    800419 <fd_alloc+0x36>
			*fd_store = fd;
  800410:	89 01                	mov    %eax,(%ecx)
			return 0;
  800412:	b8 00 00 00 00       	mov    $0x0,%eax
  800417:	eb 17                	jmp    800430 <fd_alloc+0x4d>
  800419:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80041e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800423:	75 c9                	jne    8003ee <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800425:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80042b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800438:	83 f8 1f             	cmp    $0x1f,%eax
  80043b:	77 36                	ja     800473 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80043d:	c1 e0 0c             	shl    $0xc,%eax
  800440:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800445:	89 c2                	mov    %eax,%edx
  800447:	c1 ea 16             	shr    $0x16,%edx
  80044a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800451:	f6 c2 01             	test   $0x1,%dl
  800454:	74 24                	je     80047a <fd_lookup+0x48>
  800456:	89 c2                	mov    %eax,%edx
  800458:	c1 ea 0c             	shr    $0xc,%edx
  80045b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800462:	f6 c2 01             	test   $0x1,%dl
  800465:	74 1a                	je     800481 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800467:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046a:	89 02                	mov    %eax,(%edx)
	return 0;
  80046c:	b8 00 00 00 00       	mov    $0x0,%eax
  800471:	eb 13                	jmp    800486 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800478:	eb 0c                	jmp    800486 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80047a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047f:	eb 05                	jmp    800486 <fd_lookup+0x54>
  800481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800486:	5d                   	pop    %ebp
  800487:	c3                   	ret    

00800488 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800491:	ba 34 23 80 00       	mov    $0x802334,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800496:	eb 13                	jmp    8004ab <dev_lookup+0x23>
  800498:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80049b:	39 08                	cmp    %ecx,(%eax)
  80049d:	75 0c                	jne    8004ab <dev_lookup+0x23>
			*dev = devtab[i];
  80049f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a9:	eb 2e                	jmp    8004d9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004ab:	8b 02                	mov    (%edx),%eax
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	75 e7                	jne    800498 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8004b6:	8b 40 48             	mov    0x48(%eax),%eax
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	51                   	push   %ecx
  8004bd:	50                   	push   %eax
  8004be:	68 b8 22 80 00       	push   $0x8022b8
  8004c3:	e8 22 11 00 00       	call   8015ea <cprintf>
	*dev = 0;
  8004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004d9:	c9                   	leave  
  8004da:	c3                   	ret    

008004db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	56                   	push   %esi
  8004df:	53                   	push   %ebx
  8004e0:	83 ec 10             	sub    $0x10,%esp
  8004e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ec:	50                   	push   %eax
  8004ed:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f3:	c1 e8 0c             	shr    $0xc,%eax
  8004f6:	50                   	push   %eax
  8004f7:	e8 36 ff ff ff       	call   800432 <fd_lookup>
  8004fc:	83 c4 08             	add    $0x8,%esp
  8004ff:	85 c0                	test   %eax,%eax
  800501:	78 05                	js     800508 <fd_close+0x2d>
	    || fd != fd2)
  800503:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800506:	74 0c                	je     800514 <fd_close+0x39>
		return (must_exist ? r : 0);
  800508:	84 db                	test   %bl,%bl
  80050a:	ba 00 00 00 00       	mov    $0x0,%edx
  80050f:	0f 44 c2             	cmove  %edx,%eax
  800512:	eb 41                	jmp    800555 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80051a:	50                   	push   %eax
  80051b:	ff 36                	pushl  (%esi)
  80051d:	e8 66 ff ff ff       	call   800488 <dev_lookup>
  800522:	89 c3                	mov    %eax,%ebx
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 1a                	js     800545 <fd_close+0x6a>
		if (dev->dev_close)
  80052b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80052e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800531:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800536:	85 c0                	test   %eax,%eax
  800538:	74 0b                	je     800545 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80053a:	83 ec 0c             	sub    $0xc,%esp
  80053d:	56                   	push   %esi
  80053e:	ff d0                	call   *%eax
  800540:	89 c3                	mov    %eax,%ebx
  800542:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	56                   	push   %esi
  800549:	6a 00                	push   $0x0
  80054b:	e8 c0 fc ff ff       	call   800210 <sys_page_unmap>
	return r;
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	89 d8                	mov    %ebx,%eax
}
  800555:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800558:	5b                   	pop    %ebx
  800559:	5e                   	pop    %esi
  80055a:	5d                   	pop    %ebp
  80055b:	c3                   	ret    

0080055c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800565:	50                   	push   %eax
  800566:	ff 75 08             	pushl  0x8(%ebp)
  800569:	e8 c4 fe ff ff       	call   800432 <fd_lookup>
  80056e:	83 c4 08             	add    $0x8,%esp
  800571:	85 c0                	test   %eax,%eax
  800573:	78 10                	js     800585 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	6a 01                	push   $0x1
  80057a:	ff 75 f4             	pushl  -0xc(%ebp)
  80057d:	e8 59 ff ff ff       	call   8004db <fd_close>
  800582:	83 c4 10             	add    $0x10,%esp
}
  800585:	c9                   	leave  
  800586:	c3                   	ret    

00800587 <close_all>:

void
close_all(void)
{
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  80058a:	53                   	push   %ebx
  80058b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80058e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800593:	83 ec 0c             	sub    $0xc,%esp
  800596:	53                   	push   %ebx
  800597:	e8 c0 ff ff ff       	call   80055c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80059c:	83 c3 01             	add    $0x1,%ebx
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	83 fb 20             	cmp    $0x20,%ebx
  8005a5:	75 ec                	jne    800593 <close_all+0xc>
		close(i);
}
  8005a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005aa:	c9                   	leave  
  8005ab:	c3                   	ret    

008005ac <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	57                   	push   %edi
  8005b0:	56                   	push   %esi
  8005b1:	53                   	push   %ebx
  8005b2:	83 ec 2c             	sub    $0x2c,%esp
  8005b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005bb:	50                   	push   %eax
  8005bc:	ff 75 08             	pushl  0x8(%ebp)
  8005bf:	e8 6e fe ff ff       	call   800432 <fd_lookup>
  8005c4:	83 c4 08             	add    $0x8,%esp
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	0f 88 c1 00 00 00    	js     800690 <dup+0xe4>
		return r;
	close(newfdnum);
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	56                   	push   %esi
  8005d3:	e8 84 ff ff ff       	call   80055c <close>

	newfd = INDEX2FD(newfdnum);
  8005d8:	89 f3                	mov    %esi,%ebx
  8005da:	c1 e3 0c             	shl    $0xc,%ebx
  8005dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005e3:	83 c4 04             	add    $0x4,%esp
  8005e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e9:	e8 de fd ff ff       	call   8003cc <fd2data>
  8005ee:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005f0:	89 1c 24             	mov    %ebx,(%esp)
  8005f3:	e8 d4 fd ff ff       	call   8003cc <fd2data>
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fe:	89 f8                	mov    %edi,%eax
  800600:	c1 e8 16             	shr    $0x16,%eax
  800603:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80060a:	a8 01                	test   $0x1,%al
  80060c:	74 37                	je     800645 <dup+0x99>
  80060e:	89 f8                	mov    %edi,%eax
  800610:	c1 e8 0c             	shr    $0xc,%eax
  800613:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80061a:	f6 c2 01             	test   $0x1,%dl
  80061d:	74 26                	je     800645 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	25 07 0e 00 00       	and    $0xe07,%eax
  80062e:	50                   	push   %eax
  80062f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800632:	6a 00                	push   $0x0
  800634:	57                   	push   %edi
  800635:	6a 00                	push   $0x0
  800637:	e8 92 fb ff ff       	call   8001ce <sys_page_map>
  80063c:	89 c7                	mov    %eax,%edi
  80063e:	83 c4 20             	add    $0x20,%esp
  800641:	85 c0                	test   %eax,%eax
  800643:	78 2e                	js     800673 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800645:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800648:	89 d0                	mov    %edx,%eax
  80064a:	c1 e8 0c             	shr    $0xc,%eax
  80064d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	25 07 0e 00 00       	and    $0xe07,%eax
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	6a 00                	push   $0x0
  800660:	52                   	push   %edx
  800661:	6a 00                	push   $0x0
  800663:	e8 66 fb ff ff       	call   8001ce <sys_page_map>
  800668:	89 c7                	mov    %eax,%edi
  80066a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80066d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80066f:	85 ff                	test   %edi,%edi
  800671:	79 1d                	jns    800690 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 00                	push   $0x0
  800679:	e8 92 fb ff ff       	call   800210 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80067e:	83 c4 08             	add    $0x8,%esp
  800681:	ff 75 d4             	pushl  -0x2c(%ebp)
  800684:	6a 00                	push   $0x0
  800686:	e8 85 fb ff ff       	call   800210 <sys_page_unmap>
	return r;
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	89 f8                	mov    %edi,%eax
}
  800690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	53                   	push   %ebx
  80069c:	83 ec 14             	sub    $0x14,%esp
  80069f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	53                   	push   %ebx
  8006a7:	e8 86 fd ff ff       	call   800432 <fd_lookup>
  8006ac:	83 c4 08             	add    $0x8,%esp
  8006af:	89 c2                	mov    %eax,%edx
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	78 6d                	js     800722 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006bf:	ff 30                	pushl  (%eax)
  8006c1:	e8 c2 fd ff ff       	call   800488 <dev_lookup>
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	78 4c                	js     800719 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006d0:	8b 42 08             	mov    0x8(%edx),%eax
  8006d3:	83 e0 03             	and    $0x3,%eax
  8006d6:	83 f8 01             	cmp    $0x1,%eax
  8006d9:	75 21                	jne    8006fc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006db:	a1 08 40 80 00       	mov    0x804008,%eax
  8006e0:	8b 40 48             	mov    0x48(%eax),%eax
  8006e3:	83 ec 04             	sub    $0x4,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	50                   	push   %eax
  8006e8:	68 f9 22 80 00       	push   $0x8022f9
  8006ed:	e8 f8 0e 00 00       	call   8015ea <cprintf>
		return -E_INVAL;
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006fa:	eb 26                	jmp    800722 <read+0x8a>
	}
	if (!dev->dev_read)
  8006fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ff:	8b 40 08             	mov    0x8(%eax),%eax
  800702:	85 c0                	test   %eax,%eax
  800704:	74 17                	je     80071d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800706:	83 ec 04             	sub    $0x4,%esp
  800709:	ff 75 10             	pushl  0x10(%ebp)
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	52                   	push   %edx
  800710:	ff d0                	call   *%eax
  800712:	89 c2                	mov    %eax,%edx
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 09                	jmp    800722 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	89 c2                	mov    %eax,%edx
  80071b:	eb 05                	jmp    800722 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80071d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800722:	89 d0                	mov    %edx,%eax
  800724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800727:	c9                   	leave  
  800728:	c3                   	ret    

00800729 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	57                   	push   %edi
  80072d:	56                   	push   %esi
  80072e:	53                   	push   %ebx
  80072f:	83 ec 0c             	sub    $0xc,%esp
  800732:	8b 7d 08             	mov    0x8(%ebp),%edi
  800735:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800738:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073d:	eb 21                	jmp    800760 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073f:	83 ec 04             	sub    $0x4,%esp
  800742:	89 f0                	mov    %esi,%eax
  800744:	29 d8                	sub    %ebx,%eax
  800746:	50                   	push   %eax
  800747:	89 d8                	mov    %ebx,%eax
  800749:	03 45 0c             	add    0xc(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	57                   	push   %edi
  80074e:	e8 45 ff ff ff       	call   800698 <read>
		if (m < 0)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	85 c0                	test   %eax,%eax
  800758:	78 10                	js     80076a <readn+0x41>
			return m;
		if (m == 0)
  80075a:	85 c0                	test   %eax,%eax
  80075c:	74 0a                	je     800768 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80075e:	01 c3                	add    %eax,%ebx
  800760:	39 f3                	cmp    %esi,%ebx
  800762:	72 db                	jb     80073f <readn+0x16>
  800764:	89 d8                	mov    %ebx,%eax
  800766:	eb 02                	jmp    80076a <readn+0x41>
  800768:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80076a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5f                   	pop    %edi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	53                   	push   %ebx
  800776:	83 ec 14             	sub    $0x14,%esp
  800779:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80077c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	53                   	push   %ebx
  800781:	e8 ac fc ff ff       	call   800432 <fd_lookup>
  800786:	83 c4 08             	add    $0x8,%esp
  800789:	89 c2                	mov    %eax,%edx
  80078b:	85 c0                	test   %eax,%eax
  80078d:	78 68                	js     8007f7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800795:	50                   	push   %eax
  800796:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800799:	ff 30                	pushl  (%eax)
  80079b:	e8 e8 fc ff ff       	call   800488 <dev_lookup>
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	78 47                	js     8007ee <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ae:	75 21                	jne    8007d1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8007b5:	8b 40 48             	mov    0x48(%eax),%eax
  8007b8:	83 ec 04             	sub    $0x4,%esp
  8007bb:	53                   	push   %ebx
  8007bc:	50                   	push   %eax
  8007bd:	68 15 23 80 00       	push   $0x802315
  8007c2:	e8 23 0e 00 00       	call   8015ea <cprintf>
		return -E_INVAL;
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007cf:	eb 26                	jmp    8007f7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	74 17                	je     8007f2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007db:	83 ec 04             	sub    $0x4,%esp
  8007de:	ff 75 10             	pushl  0x10(%ebp)
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	50                   	push   %eax
  8007e5:	ff d2                	call   *%edx
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	eb 09                	jmp    8007f7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	eb 05                	jmp    8007f7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007f7:	89 d0                	mov    %edx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800804:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800807:	50                   	push   %eax
  800808:	ff 75 08             	pushl  0x8(%ebp)
  80080b:	e8 22 fc ff ff       	call   800432 <fd_lookup>
  800810:	83 c4 08             	add    $0x8,%esp
  800813:	85 c0                	test   %eax,%eax
  800815:	78 0e                	js     800825 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800817:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	83 ec 14             	sub    $0x14,%esp
  80082e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800831:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800834:	50                   	push   %eax
  800835:	53                   	push   %ebx
  800836:	e8 f7 fb ff ff       	call   800432 <fd_lookup>
  80083b:	83 c4 08             	add    $0x8,%esp
  80083e:	89 c2                	mov    %eax,%edx
  800840:	85 c0                	test   %eax,%eax
  800842:	78 65                	js     8008a9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084a:	50                   	push   %eax
  80084b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084e:	ff 30                	pushl  (%eax)
  800850:	e8 33 fc ff ff       	call   800488 <dev_lookup>
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	85 c0                	test   %eax,%eax
  80085a:	78 44                	js     8008a0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80085c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800863:	75 21                	jne    800886 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800865:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80086a:	8b 40 48             	mov    0x48(%eax),%eax
  80086d:	83 ec 04             	sub    $0x4,%esp
  800870:	53                   	push   %ebx
  800871:	50                   	push   %eax
  800872:	68 d8 22 80 00       	push   $0x8022d8
  800877:	e8 6e 0d 00 00       	call   8015ea <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80087c:	83 c4 10             	add    $0x10,%esp
  80087f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800884:	eb 23                	jmp    8008a9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800886:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800889:	8b 52 18             	mov    0x18(%edx),%edx
  80088c:	85 d2                	test   %edx,%edx
  80088e:	74 14                	je     8008a4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	ff 75 0c             	pushl  0xc(%ebp)
  800896:	50                   	push   %eax
  800897:	ff d2                	call   *%edx
  800899:	89 c2                	mov    %eax,%edx
  80089b:	83 c4 10             	add    $0x10,%esp
  80089e:	eb 09                	jmp    8008a9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	eb 05                	jmp    8008a9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	83 ec 14             	sub    $0x14,%esp
  8008b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008bd:	50                   	push   %eax
  8008be:	ff 75 08             	pushl  0x8(%ebp)
  8008c1:	e8 6c fb ff ff       	call   800432 <fd_lookup>
  8008c6:	83 c4 08             	add    $0x8,%esp
  8008c9:	89 c2                	mov    %eax,%edx
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 58                	js     800927 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d5:	50                   	push   %eax
  8008d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d9:	ff 30                	pushl  (%eax)
  8008db:	e8 a8 fb ff ff       	call   800488 <dev_lookup>
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	78 37                	js     80091e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ee:	74 32                	je     800922 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008fa:	00 00 00 
	stat->st_isdir = 0;
  8008fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800904:	00 00 00 
	stat->st_dev = dev;
  800907:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	53                   	push   %ebx
  800911:	ff 75 f0             	pushl  -0x10(%ebp)
  800914:	ff 50 14             	call   *0x14(%eax)
  800917:	89 c2                	mov    %eax,%edx
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	eb 09                	jmp    800927 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80091e:	89 c2                	mov    %eax,%edx
  800920:	eb 05                	jmp    800927 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800922:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800927:	89 d0                	mov    %edx,%eax
  800929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	6a 00                	push   $0x0
  800938:	ff 75 08             	pushl  0x8(%ebp)
  80093b:	e8 e7 01 00 00       	call   800b27 <open>
  800940:	89 c3                	mov    %eax,%ebx
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	85 c0                	test   %eax,%eax
  800947:	78 1b                	js     800964 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800949:	83 ec 08             	sub    $0x8,%esp
  80094c:	ff 75 0c             	pushl  0xc(%ebp)
  80094f:	50                   	push   %eax
  800950:	e8 5b ff ff ff       	call   8008b0 <fstat>
  800955:	89 c6                	mov    %eax,%esi
	close(fd);
  800957:	89 1c 24             	mov    %ebx,(%esp)
  80095a:	e8 fd fb ff ff       	call   80055c <close>
	return r;
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	89 f0                	mov    %esi,%eax
}
  800964:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	89 c6                	mov    %eax,%esi
  800972:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800974:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80097b:	75 12                	jne    80098f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80097d:	83 ec 0c             	sub    $0xc,%esp
  800980:	6a 01                	push   $0x1
  800982:	e8 f0 15 00 00       	call   801f77 <ipc_find_env>
  800987:	a3 00 40 80 00       	mov    %eax,0x804000
  80098c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80098f:	6a 07                	push   $0x7
  800991:	68 00 50 80 00       	push   $0x805000
  800996:	56                   	push   %esi
  800997:	ff 35 00 40 80 00    	pushl  0x804000
  80099d:	e8 81 15 00 00       	call   801f23 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009a2:	83 c4 0c             	add    $0xc,%esp
  8009a5:	6a 00                	push   $0x0
  8009a7:	53                   	push   %ebx
  8009a8:	6a 00                	push   $0x0
  8009aa:	e8 07 15 00 00       	call   801eb6 <ipc_recv>
}
  8009af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ca:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d9:	e8 8d ff ff ff       	call   80096b <fsipc>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8009fb:	e8 6b ff ff ff       	call   80096b <fsipc>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	53                   	push   %ebx
  800a06:	83 ec 04             	sub    $0x4,%esp
  800a09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a12:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a17:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1c:	b8 05 00 00 00       	mov    $0x5,%eax
  800a21:	e8 45 ff ff ff       	call   80096b <fsipc>
  800a26:	85 c0                	test   %eax,%eax
  800a28:	78 2c                	js     800a56 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	68 00 50 80 00       	push   $0x805000
  800a32:	53                   	push   %ebx
  800a33:	e8 37 11 00 00       	call   801b6f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a38:	a1 80 50 80 00       	mov    0x805080,%eax
  800a3d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a43:	a1 84 50 80 00       	mov    0x805084,%eax
  800a48:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a4e:	83 c4 10             	add    $0x10,%esp
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a65:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a6a:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a6f:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a72:	53                   	push   %ebx
  800a73:	ff 75 0c             	pushl  0xc(%ebp)
  800a76:	68 08 50 80 00       	push   $0x805008
  800a7b:	e8 81 12 00 00       	call   801d01 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 40 0c             	mov    0xc(%eax),%eax
  800a86:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a8b:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 04 00 00 00       	mov    $0x4,%eax
  800a9b:	e8 cb fe ff ff       	call   80096b <fsipc>
	//panic("devfile_write not implemented");
}
  800aa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ab8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800abe:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac8:	e8 9e fe ff ff       	call   80096b <fsipc>
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	78 4b                	js     800b1e <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ad3:	39 c6                	cmp    %eax,%esi
  800ad5:	73 16                	jae    800aed <devfile_read+0x48>
  800ad7:	68 48 23 80 00       	push   $0x802348
  800adc:	68 4f 23 80 00       	push   $0x80234f
  800ae1:	6a 7c                	push   $0x7c
  800ae3:	68 64 23 80 00       	push   $0x802364
  800ae8:	e8 24 0a 00 00       	call   801511 <_panic>
	assert(r <= PGSIZE);
  800aed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800af2:	7e 16                	jle    800b0a <devfile_read+0x65>
  800af4:	68 6f 23 80 00       	push   $0x80236f
  800af9:	68 4f 23 80 00       	push   $0x80234f
  800afe:	6a 7d                	push   $0x7d
  800b00:	68 64 23 80 00       	push   $0x802364
  800b05:	e8 07 0a 00 00       	call   801511 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b0a:	83 ec 04             	sub    $0x4,%esp
  800b0d:	50                   	push   %eax
  800b0e:	68 00 50 80 00       	push   $0x805000
  800b13:	ff 75 0c             	pushl  0xc(%ebp)
  800b16:	e8 e6 11 00 00       	call   801d01 <memmove>
	return r;
  800b1b:	83 c4 10             	add    $0x10,%esp
}
  800b1e:	89 d8                	mov    %ebx,%eax
  800b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 20             	sub    $0x20,%esp
  800b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b31:	53                   	push   %ebx
  800b32:	e8 ff 0f 00 00       	call   801b36 <strlen>
  800b37:	83 c4 10             	add    $0x10,%esp
  800b3a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b3f:	7f 67                	jg     800ba8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b47:	50                   	push   %eax
  800b48:	e8 96 f8 ff ff       	call   8003e3 <fd_alloc>
  800b4d:	83 c4 10             	add    $0x10,%esp
		return r;
  800b50:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b52:	85 c0                	test   %eax,%eax
  800b54:	78 57                	js     800bad <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b56:	83 ec 08             	sub    $0x8,%esp
  800b59:	53                   	push   %ebx
  800b5a:	68 00 50 80 00       	push   $0x805000
  800b5f:	e8 0b 10 00 00       	call   801b6f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b67:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b74:	e8 f2 fd ff ff       	call   80096b <fsipc>
  800b79:	89 c3                	mov    %eax,%ebx
  800b7b:	83 c4 10             	add    $0x10,%esp
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	79 14                	jns    800b96 <open+0x6f>
		fd_close(fd, 0);
  800b82:	83 ec 08             	sub    $0x8,%esp
  800b85:	6a 00                	push   $0x0
  800b87:	ff 75 f4             	pushl  -0xc(%ebp)
  800b8a:	e8 4c f9 ff ff       	call   8004db <fd_close>
		return r;
  800b8f:	83 c4 10             	add    $0x10,%esp
  800b92:	89 da                	mov    %ebx,%edx
  800b94:	eb 17                	jmp    800bad <open+0x86>
	}

	return fd2num(fd);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	ff 75 f4             	pushl  -0xc(%ebp)
  800b9c:	e8 1b f8 ff ff       	call   8003bc <fd2num>
  800ba1:	89 c2                	mov    %eax,%edx
  800ba3:	83 c4 10             	add    $0x10,%esp
  800ba6:	eb 05                	jmp    800bad <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ba8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bad:	89 d0                	mov    %edx,%eax
  800baf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc4:	e8 a2 fd ff ff       	call   80096b <fsipc>
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bd1:	68 7b 23 80 00       	push   $0x80237b
  800bd6:	ff 75 0c             	pushl  0xc(%ebp)
  800bd9:	e8 91 0f 00 00       	call   801b6f <strcpy>
	return 0;
}
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	53                   	push   %ebx
  800be9:	83 ec 10             	sub    $0x10,%esp
  800bec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bef:	53                   	push   %ebx
  800bf0:	e8 bb 13 00 00       	call   801fb0 <pageref>
  800bf5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bfd:	83 f8 01             	cmp    $0x1,%eax
  800c00:	75 10                	jne    800c12 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	ff 73 0c             	pushl  0xc(%ebx)
  800c08:	e8 c0 02 00 00       	call   800ecd <nsipc_close>
  800c0d:	89 c2                	mov    %eax,%edx
  800c0f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c1f:	6a 00                	push   $0x0
  800c21:	ff 75 10             	pushl  0x10(%ebp)
  800c24:	ff 75 0c             	pushl  0xc(%ebp)
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	ff 70 0c             	pushl  0xc(%eax)
  800c2d:	e8 78 03 00 00       	call   800faa <nsipc_send>
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c3a:	6a 00                	push   $0x0
  800c3c:	ff 75 10             	pushl  0x10(%ebp)
  800c3f:	ff 75 0c             	pushl  0xc(%ebp)
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	ff 70 0c             	pushl  0xc(%eax)
  800c48:	e8 f1 02 00 00       	call   800f3e <nsipc_recv>
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c55:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c58:	52                   	push   %edx
  800c59:	50                   	push   %eax
  800c5a:	e8 d3 f7 ff ff       	call   800432 <fd_lookup>
  800c5f:	83 c4 10             	add    $0x10,%esp
  800c62:	85 c0                	test   %eax,%eax
  800c64:	78 17                	js     800c7d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c69:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c6f:	39 08                	cmp    %ecx,(%eax)
  800c71:	75 05                	jne    800c78 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c73:	8b 40 0c             	mov    0xc(%eax),%eax
  800c76:	eb 05                	jmp    800c7d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c78:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c7d:	c9                   	leave  
  800c7e:	c3                   	ret    

00800c7f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 1c             	sub    $0x1c,%esp
  800c87:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c8c:	50                   	push   %eax
  800c8d:	e8 51 f7 ff ff       	call   8003e3 <fd_alloc>
  800c92:	89 c3                	mov    %eax,%ebx
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	85 c0                	test   %eax,%eax
  800c99:	78 1b                	js     800cb6 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c9b:	83 ec 04             	sub    $0x4,%esp
  800c9e:	68 07 04 00 00       	push   $0x407
  800ca3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ca6:	6a 00                	push   $0x0
  800ca8:	e8 de f4 ff ff       	call   80018b <sys_page_alloc>
  800cad:	89 c3                	mov    %eax,%ebx
  800caf:	83 c4 10             	add    $0x10,%esp
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	79 10                	jns    800cc6 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	56                   	push   %esi
  800cba:	e8 0e 02 00 00       	call   800ecd <nsipc_close>
		return r;
  800cbf:	83 c4 10             	add    $0x10,%esp
  800cc2:	89 d8                	mov    %ebx,%eax
  800cc4:	eb 24                	jmp    800cea <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cc6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccf:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cdb:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	e8 d5 f6 ff ff       	call   8003bc <fd2num>
  800ce7:	83 c4 10             	add    $0x10,%esp
}
  800cea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	e8 50 ff ff ff       	call   800c4f <fd2sockid>
		return r;
  800cff:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	78 1f                	js     800d24 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d05:	83 ec 04             	sub    $0x4,%esp
  800d08:	ff 75 10             	pushl  0x10(%ebp)
  800d0b:	ff 75 0c             	pushl  0xc(%ebp)
  800d0e:	50                   	push   %eax
  800d0f:	e8 12 01 00 00       	call   800e26 <nsipc_accept>
  800d14:	83 c4 10             	add    $0x10,%esp
		return r;
  800d17:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	78 07                	js     800d24 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d1d:	e8 5d ff ff ff       	call   800c7f <alloc_sockfd>
  800d22:	89 c1                	mov    %eax,%ecx
}
  800d24:	89 c8                	mov    %ecx,%eax
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	e8 19 ff ff ff       	call   800c4f <fd2sockid>
  800d36:	85 c0                	test   %eax,%eax
  800d38:	78 12                	js     800d4c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d3a:	83 ec 04             	sub    $0x4,%esp
  800d3d:	ff 75 10             	pushl  0x10(%ebp)
  800d40:	ff 75 0c             	pushl  0xc(%ebp)
  800d43:	50                   	push   %eax
  800d44:	e8 2d 01 00 00       	call   800e76 <nsipc_bind>
  800d49:	83 c4 10             	add    $0x10,%esp
}
  800d4c:	c9                   	leave  
  800d4d:	c3                   	ret    

00800d4e <shutdown>:

int
shutdown(int s, int how)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	e8 f3 fe ff ff       	call   800c4f <fd2sockid>
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	78 0f                	js     800d6f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d60:	83 ec 08             	sub    $0x8,%esp
  800d63:	ff 75 0c             	pushl  0xc(%ebp)
  800d66:	50                   	push   %eax
  800d67:	e8 3f 01 00 00       	call   800eab <nsipc_shutdown>
  800d6c:	83 c4 10             	add    $0x10,%esp
}
  800d6f:	c9                   	leave  
  800d70:	c3                   	ret    

00800d71 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	e8 d0 fe ff ff       	call   800c4f <fd2sockid>
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	78 12                	js     800d95 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	ff 75 10             	pushl  0x10(%ebp)
  800d89:	ff 75 0c             	pushl  0xc(%ebp)
  800d8c:	50                   	push   %eax
  800d8d:	e8 55 01 00 00       	call   800ee7 <nsipc_connect>
  800d92:	83 c4 10             	add    $0x10,%esp
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <listen>:

int
listen(int s, int backlog)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	e8 aa fe ff ff       	call   800c4f <fd2sockid>
  800da5:	85 c0                	test   %eax,%eax
  800da7:	78 0f                	js     800db8 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800da9:	83 ec 08             	sub    $0x8,%esp
  800dac:	ff 75 0c             	pushl  0xc(%ebp)
  800daf:	50                   	push   %eax
  800db0:	e8 67 01 00 00       	call   800f1c <nsipc_listen>
  800db5:	83 c4 10             	add    $0x10,%esp
}
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    

00800dba <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dc0:	ff 75 10             	pushl  0x10(%ebp)
  800dc3:	ff 75 0c             	pushl  0xc(%ebp)
  800dc6:	ff 75 08             	pushl  0x8(%ebp)
  800dc9:	e8 3a 02 00 00       	call   801008 <nsipc_socket>
  800dce:	83 c4 10             	add    $0x10,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	78 05                	js     800dda <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dd5:	e8 a5 fe ff ff       	call   800c7f <alloc_sockfd>
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 04             	sub    $0x4,%esp
  800de3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800de5:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dec:	75 12                	jne    800e00 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	6a 02                	push   $0x2
  800df3:	e8 7f 11 00 00       	call   801f77 <ipc_find_env>
  800df8:	a3 04 40 80 00       	mov    %eax,0x804004
  800dfd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e00:	6a 07                	push   $0x7
  800e02:	68 00 60 80 00       	push   $0x806000
  800e07:	53                   	push   %ebx
  800e08:	ff 35 04 40 80 00    	pushl  0x804004
  800e0e:	e8 10 11 00 00       	call   801f23 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e13:	83 c4 0c             	add    $0xc,%esp
  800e16:	6a 00                	push   $0x0
  800e18:	6a 00                	push   $0x0
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 95 10 00 00       	call   801eb6 <ipc_recv>
}
  800e21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e24:	c9                   	leave  
  800e25:	c3                   	ret    

00800e26 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e36:	8b 06                	mov    (%esi),%eax
  800e38:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e42:	e8 95 ff ff ff       	call   800ddc <nsipc>
  800e47:	89 c3                	mov    %eax,%ebx
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	78 20                	js     800e6d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	ff 35 10 60 80 00    	pushl  0x806010
  800e56:	68 00 60 80 00       	push   $0x806000
  800e5b:	ff 75 0c             	pushl  0xc(%ebp)
  800e5e:	e8 9e 0e 00 00       	call   801d01 <memmove>
		*addrlen = ret->ret_addrlen;
  800e63:	a1 10 60 80 00       	mov    0x806010,%eax
  800e68:	89 06                	mov    %eax,(%esi)
  800e6a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e6d:	89 d8                	mov    %ebx,%eax
  800e6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 08             	sub    $0x8,%esp
  800e7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e88:	53                   	push   %ebx
  800e89:	ff 75 0c             	pushl  0xc(%ebp)
  800e8c:	68 04 60 80 00       	push   $0x806004
  800e91:	e8 6b 0e 00 00       	call   801d01 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e96:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e9c:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea1:	e8 36 ff ff ff       	call   800ddc <nsipc>
}
  800ea6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    

00800eab <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ec1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec6:	e8 11 ff ff ff       	call   800ddc <nsipc>
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    

00800ecd <nsipc_close>:

int
nsipc_close(int s)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800edb:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee0:	e8 f7 fe ff ff       	call   800ddc <nsipc>
}
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 08             	sub    $0x8,%esp
  800eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ef9:	53                   	push   %ebx
  800efa:	ff 75 0c             	pushl  0xc(%ebp)
  800efd:	68 04 60 80 00       	push   $0x806004
  800f02:	e8 fa 0d 00 00       	call   801d01 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f07:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f0d:	b8 05 00 00 00       	mov    $0x5,%eax
  800f12:	e8 c5 fe ff ff       	call   800ddc <nsipc>
}
  800f17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f32:	b8 06 00 00 00       	mov    $0x6,%eax
  800f37:	e8 a0 fe ff ff       	call   800ddc <nsipc>
}
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
  800f49:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f4e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f54:	8b 45 14             	mov    0x14(%ebp),%eax
  800f57:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f5c:	b8 07 00 00 00       	mov    $0x7,%eax
  800f61:	e8 76 fe ff ff       	call   800ddc <nsipc>
  800f66:	89 c3                	mov    %eax,%ebx
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	78 35                	js     800fa1 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f6c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f71:	7f 04                	jg     800f77 <nsipc_recv+0x39>
  800f73:	39 c6                	cmp    %eax,%esi
  800f75:	7d 16                	jge    800f8d <nsipc_recv+0x4f>
  800f77:	68 87 23 80 00       	push   $0x802387
  800f7c:	68 4f 23 80 00       	push   $0x80234f
  800f81:	6a 62                	push   $0x62
  800f83:	68 9c 23 80 00       	push   $0x80239c
  800f88:	e8 84 05 00 00       	call   801511 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	50                   	push   %eax
  800f91:	68 00 60 80 00       	push   $0x806000
  800f96:	ff 75 0c             	pushl  0xc(%ebp)
  800f99:	e8 63 0d 00 00       	call   801d01 <memmove>
  800f9e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fa1:	89 d8                	mov    %ebx,%eax
  800fa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	53                   	push   %ebx
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb7:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fbc:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fc2:	7e 16                	jle    800fda <nsipc_send+0x30>
  800fc4:	68 a8 23 80 00       	push   $0x8023a8
  800fc9:	68 4f 23 80 00       	push   $0x80234f
  800fce:	6a 6d                	push   $0x6d
  800fd0:	68 9c 23 80 00       	push   $0x80239c
  800fd5:	e8 37 05 00 00       	call   801511 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fda:	83 ec 04             	sub    $0x4,%esp
  800fdd:	53                   	push   %ebx
  800fde:	ff 75 0c             	pushl  0xc(%ebp)
  800fe1:	68 0c 60 80 00       	push   $0x80600c
  800fe6:	e8 16 0d 00 00       	call   801d01 <memmove>
	nsipcbuf.send.req_size = size;
  800feb:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800ff1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800ff9:	b8 08 00 00 00       	mov    $0x8,%eax
  800ffe:	e8 d9 fd ff ff       	call   800ddc <nsipc>
}
  801003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
  801011:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801016:	8b 45 0c             	mov    0xc(%ebp),%eax
  801019:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80101e:	8b 45 10             	mov    0x10(%ebp),%eax
  801021:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801026:	b8 09 00 00 00       	mov    $0x9,%eax
  80102b:	e8 ac fd ff ff       	call   800ddc <nsipc>
}
  801030:	c9                   	leave  
  801031:	c3                   	ret    

00801032 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	ff 75 08             	pushl  0x8(%ebp)
  801040:	e8 87 f3 ff ff       	call   8003cc <fd2data>
  801045:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801047:	83 c4 08             	add    $0x8,%esp
  80104a:	68 b4 23 80 00       	push   $0x8023b4
  80104f:	53                   	push   %ebx
  801050:	e8 1a 0b 00 00       	call   801b6f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801055:	8b 46 04             	mov    0x4(%esi),%eax
  801058:	2b 06                	sub    (%esi),%eax
  80105a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801060:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801067:	00 00 00 
	stat->st_dev = &devpipe;
  80106a:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801071:	30 80 00 
	return 0;
}
  801074:	b8 00 00 00 00       	mov    $0x0,%eax
  801079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	53                   	push   %ebx
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80108a:	53                   	push   %ebx
  80108b:	6a 00                	push   $0x0
  80108d:	e8 7e f1 ff ff       	call   800210 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801092:	89 1c 24             	mov    %ebx,(%esp)
  801095:	e8 32 f3 ff ff       	call   8003cc <fd2data>
  80109a:	83 c4 08             	add    $0x8,%esp
  80109d:	50                   	push   %eax
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 6b f1 ff ff       	call   800210 <sys_page_unmap>
}
  8010a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	57                   	push   %edi
  8010ae:	56                   	push   %esi
  8010af:	53                   	push   %ebx
  8010b0:	83 ec 1c             	sub    $0x1c,%esp
  8010b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010b6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010bd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8010c6:	e8 e5 0e 00 00       	call   801fb0 <pageref>
  8010cb:	89 c3                	mov    %eax,%ebx
  8010cd:	89 3c 24             	mov    %edi,(%esp)
  8010d0:	e8 db 0e 00 00       	call   801fb0 <pageref>
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	39 c3                	cmp    %eax,%ebx
  8010da:	0f 94 c1             	sete   %cl
  8010dd:	0f b6 c9             	movzbl %cl,%ecx
  8010e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010e3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010e9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010ec:	39 ce                	cmp    %ecx,%esi
  8010ee:	74 1b                	je     80110b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010f0:	39 c3                	cmp    %eax,%ebx
  8010f2:	75 c4                	jne    8010b8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010f4:	8b 42 58             	mov    0x58(%edx),%eax
  8010f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fa:	50                   	push   %eax
  8010fb:	56                   	push   %esi
  8010fc:	68 bb 23 80 00       	push   $0x8023bb
  801101:	e8 e4 04 00 00       	call   8015ea <cprintf>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	eb ad                	jmp    8010b8 <_pipeisclosed+0xe>
	}
}
  80110b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	83 ec 28             	sub    $0x28,%esp
  80111f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801122:	56                   	push   %esi
  801123:	e8 a4 f2 ff ff       	call   8003cc <fd2data>
  801128:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80112a:	83 c4 10             	add    $0x10,%esp
  80112d:	bf 00 00 00 00       	mov    $0x0,%edi
  801132:	eb 4b                	jmp    80117f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801134:	89 da                	mov    %ebx,%edx
  801136:	89 f0                	mov    %esi,%eax
  801138:	e8 6d ff ff ff       	call   8010aa <_pipeisclosed>
  80113d:	85 c0                	test   %eax,%eax
  80113f:	75 48                	jne    801189 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801141:	e8 26 f0 ff ff       	call   80016c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801146:	8b 43 04             	mov    0x4(%ebx),%eax
  801149:	8b 0b                	mov    (%ebx),%ecx
  80114b:	8d 51 20             	lea    0x20(%ecx),%edx
  80114e:	39 d0                	cmp    %edx,%eax
  801150:	73 e2                	jae    801134 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801152:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801155:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801159:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	c1 fa 1f             	sar    $0x1f,%edx
  801161:	89 d1                	mov    %edx,%ecx
  801163:	c1 e9 1b             	shr    $0x1b,%ecx
  801166:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801169:	83 e2 1f             	and    $0x1f,%edx
  80116c:	29 ca                	sub    %ecx,%edx
  80116e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801176:	83 c0 01             	add    $0x1,%eax
  801179:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80117c:	83 c7 01             	add    $0x1,%edi
  80117f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801182:	75 c2                	jne    801146 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801184:	8b 45 10             	mov    0x10(%ebp),%eax
  801187:	eb 05                	jmp    80118e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80118e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	57                   	push   %edi
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	83 ec 18             	sub    $0x18,%esp
  80119f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011a2:	57                   	push   %edi
  8011a3:	e8 24 f2 ff ff       	call   8003cc <fd2data>
  8011a8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011aa:	83 c4 10             	add    $0x10,%esp
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	eb 3d                	jmp    8011f1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011b4:	85 db                	test   %ebx,%ebx
  8011b6:	74 04                	je     8011bc <devpipe_read+0x26>
				return i;
  8011b8:	89 d8                	mov    %ebx,%eax
  8011ba:	eb 44                	jmp    801200 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011bc:	89 f2                	mov    %esi,%edx
  8011be:	89 f8                	mov    %edi,%eax
  8011c0:	e8 e5 fe ff ff       	call   8010aa <_pipeisclosed>
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	75 32                	jne    8011fb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011c9:	e8 9e ef ff ff       	call   80016c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011ce:	8b 06                	mov    (%esi),%eax
  8011d0:	3b 46 04             	cmp    0x4(%esi),%eax
  8011d3:	74 df                	je     8011b4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011d5:	99                   	cltd   
  8011d6:	c1 ea 1b             	shr    $0x1b,%edx
  8011d9:	01 d0                	add    %edx,%eax
  8011db:	83 e0 1f             	and    $0x1f,%eax
  8011de:	29 d0                	sub    %edx,%eax
  8011e0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011eb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ee:	83 c3 01             	add    $0x1,%ebx
  8011f1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011f4:	75 d8                	jne    8011ce <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f9:	eb 05                	jmp    801200 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801210:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	e8 ca f1 ff ff       	call   8003e3 <fd_alloc>
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	85 c0                	test   %eax,%eax
  801220:	0f 88 2c 01 00 00    	js     801352 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801226:	83 ec 04             	sub    $0x4,%esp
  801229:	68 07 04 00 00       	push   $0x407
  80122e:	ff 75 f4             	pushl  -0xc(%ebp)
  801231:	6a 00                	push   $0x0
  801233:	e8 53 ef ff ff       	call   80018b <sys_page_alloc>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	85 c0                	test   %eax,%eax
  80123f:	0f 88 0d 01 00 00    	js     801352 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	e8 92 f1 ff ff       	call   8003e3 <fd_alloc>
  801251:	89 c3                	mov    %eax,%ebx
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	0f 88 e2 00 00 00    	js     801340 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	68 07 04 00 00       	push   $0x407
  801266:	ff 75 f0             	pushl  -0x10(%ebp)
  801269:	6a 00                	push   $0x0
  80126b:	e8 1b ef ff ff       	call   80018b <sys_page_alloc>
  801270:	89 c3                	mov    %eax,%ebx
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	0f 88 c3 00 00 00    	js     801340 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	ff 75 f4             	pushl  -0xc(%ebp)
  801283:	e8 44 f1 ff ff       	call   8003cc <fd2data>
  801288:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128a:	83 c4 0c             	add    $0xc,%esp
  80128d:	68 07 04 00 00       	push   $0x407
  801292:	50                   	push   %eax
  801293:	6a 00                	push   $0x0
  801295:	e8 f1 ee ff ff       	call   80018b <sys_page_alloc>
  80129a:	89 c3                	mov    %eax,%ebx
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	0f 88 89 00 00 00    	js     801330 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a7:	83 ec 0c             	sub    $0xc,%esp
  8012aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ad:	e8 1a f1 ff ff       	call   8003cc <fd2data>
  8012b2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012b9:	50                   	push   %eax
  8012ba:	6a 00                	push   $0x0
  8012bc:	56                   	push   %esi
  8012bd:	6a 00                	push   $0x0
  8012bf:	e8 0a ef ff ff       	call   8001ce <sys_page_map>
  8012c4:	89 c3                	mov    %eax,%ebx
  8012c6:	83 c4 20             	add    $0x20,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	78 55                	js     801322 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012cd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012db:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012e2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012eb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012f7:	83 ec 0c             	sub    $0xc,%esp
  8012fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fd:	e8 ba f0 ff ff       	call   8003bc <fd2num>
  801302:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801305:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801307:	83 c4 04             	add    $0x4,%esp
  80130a:	ff 75 f0             	pushl  -0x10(%ebp)
  80130d:	e8 aa f0 ff ff       	call   8003bc <fd2num>
  801312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801315:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	ba 00 00 00 00       	mov    $0x0,%edx
  801320:	eb 30                	jmp    801352 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	56                   	push   %esi
  801326:	6a 00                	push   $0x0
  801328:	e8 e3 ee ff ff       	call   800210 <sys_page_unmap>
  80132d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	ff 75 f0             	pushl  -0x10(%ebp)
  801336:	6a 00                	push   $0x0
  801338:	e8 d3 ee ff ff       	call   800210 <sys_page_unmap>
  80133d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	ff 75 f4             	pushl  -0xc(%ebp)
  801346:	6a 00                	push   $0x0
  801348:	e8 c3 ee ff ff       	call   800210 <sys_page_unmap>
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801352:	89 d0                	mov    %edx,%eax
  801354:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5d                   	pop    %ebp
  80135a:	c3                   	ret    

0080135b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801361:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801364:	50                   	push   %eax
  801365:	ff 75 08             	pushl  0x8(%ebp)
  801368:	e8 c5 f0 ff ff       	call   800432 <fd_lookup>
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	78 18                	js     80138c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801374:	83 ec 0c             	sub    $0xc,%esp
  801377:	ff 75 f4             	pushl  -0xc(%ebp)
  80137a:	e8 4d f0 ff ff       	call   8003cc <fd2data>
	return _pipeisclosed(fd, p);
  80137f:	89 c2                	mov    %eax,%edx
  801381:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801384:	e8 21 fd ff ff       	call   8010aa <_pipeisclosed>
  801389:	83 c4 10             	add    $0x10,%esp
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801391:	b8 00 00 00 00       	mov    $0x0,%eax
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80139e:	68 d3 23 80 00       	push   $0x8023d3
  8013a3:	ff 75 0c             	pushl  0xc(%ebp)
  8013a6:	e8 c4 07 00 00       	call   801b6f <strcpy>
	return 0;
}
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	57                   	push   %edi
  8013b6:	56                   	push   %esi
  8013b7:	53                   	push   %ebx
  8013b8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013be:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013c3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c9:	eb 2d                	jmp    8013f8 <devcons_write+0x46>
		m = n - tot;
  8013cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ce:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013d0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013d3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013d8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	53                   	push   %ebx
  8013df:	03 45 0c             	add    0xc(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	57                   	push   %edi
  8013e4:	e8 18 09 00 00       	call   801d01 <memmove>
		sys_cputs(buf, m);
  8013e9:	83 c4 08             	add    $0x8,%esp
  8013ec:	53                   	push   %ebx
  8013ed:	57                   	push   %edi
  8013ee:	e8 dc ec ff ff       	call   8000cf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013f3:	01 de                	add    %ebx,%esi
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	89 f0                	mov    %esi,%eax
  8013fa:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013fd:	72 cc                	jb     8013cb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801402:	5b                   	pop    %ebx
  801403:	5e                   	pop    %esi
  801404:	5f                   	pop    %edi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801412:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801416:	74 2a                	je     801442 <devcons_read+0x3b>
  801418:	eb 05                	jmp    80141f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80141a:	e8 4d ed ff ff       	call   80016c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80141f:	e8 c9 ec ff ff       	call   8000ed <sys_cgetc>
  801424:	85 c0                	test   %eax,%eax
  801426:	74 f2                	je     80141a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 16                	js     801442 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80142c:	83 f8 04             	cmp    $0x4,%eax
  80142f:	74 0c                	je     80143d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801431:	8b 55 0c             	mov    0xc(%ebp),%edx
  801434:	88 02                	mov    %al,(%edx)
	return 1;
  801436:	b8 01 00 00 00       	mov    $0x1,%eax
  80143b:	eb 05                	jmp    801442 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80144a:	8b 45 08             	mov    0x8(%ebp),%eax
  80144d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801450:	6a 01                	push   $0x1
  801452:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801455:	50                   	push   %eax
  801456:	e8 74 ec ff ff       	call   8000cf <sys_cputs>
}
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <getchar>:

int
getchar(void)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801466:	6a 01                	push   $0x1
  801468:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80146b:	50                   	push   %eax
  80146c:	6a 00                	push   $0x0
  80146e:	e8 25 f2 ff ff       	call   800698 <read>
	if (r < 0)
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 0f                	js     801489 <getchar+0x29>
		return r;
	if (r < 1)
  80147a:	85 c0                	test   %eax,%eax
  80147c:	7e 06                	jle    801484 <getchar+0x24>
		return -E_EOF;
	return c;
  80147e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801482:	eb 05                	jmp    801489 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801484:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	ff 75 08             	pushl  0x8(%ebp)
  801498:	e8 95 ef ff ff       	call   800432 <fd_lookup>
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 11                	js     8014b5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014ad:	39 10                	cmp    %edx,(%eax)
  8014af:	0f 94 c0             	sete   %al
  8014b2:	0f b6 c0             	movzbl %al,%eax
}
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <opencons>:

int
opencons(void)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	e8 1d ef ff ff       	call   8003e3 <fd_alloc>
  8014c6:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 3e                	js     80150d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	68 07 04 00 00       	push   $0x407
  8014d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014da:	6a 00                	push   $0x0
  8014dc:	e8 aa ec ff ff       	call   80018b <sys_page_alloc>
  8014e1:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 23                	js     80150d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014ea:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	50                   	push   %eax
  801503:	e8 b4 ee ff ff       	call   8003bc <fd2num>
  801508:	89 c2                	mov    %eax,%edx
  80150a:	83 c4 10             	add    $0x10,%esp
}
  80150d:	89 d0                	mov    %edx,%eax
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801516:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801519:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80151f:	e8 29 ec ff ff       	call   80014d <sys_getenvid>
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	ff 75 0c             	pushl  0xc(%ebp)
  80152a:	ff 75 08             	pushl  0x8(%ebp)
  80152d:	56                   	push   %esi
  80152e:	50                   	push   %eax
  80152f:	68 e0 23 80 00       	push   $0x8023e0
  801534:	e8 b1 00 00 00       	call   8015ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801539:	83 c4 18             	add    $0x18,%esp
  80153c:	53                   	push   %ebx
  80153d:	ff 75 10             	pushl  0x10(%ebp)
  801540:	e8 54 00 00 00       	call   801599 <vcprintf>
	cprintf("\n");
  801545:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  80154c:	e8 99 00 00 00       	call   8015ea <cprintf>
  801551:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801554:	cc                   	int3   
  801555:	eb fd                	jmp    801554 <_panic+0x43>

00801557 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	53                   	push   %ebx
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801561:	8b 13                	mov    (%ebx),%edx
  801563:	8d 42 01             	lea    0x1(%edx),%eax
  801566:	89 03                	mov    %eax,(%ebx)
  801568:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80156f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801574:	75 1a                	jne    801590 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	68 ff 00 00 00       	push   $0xff
  80157e:	8d 43 08             	lea    0x8(%ebx),%eax
  801581:	50                   	push   %eax
  801582:	e8 48 eb ff ff       	call   8000cf <sys_cputs>
		b->idx = 0;
  801587:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80158d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801590:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801594:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801597:	c9                   	leave  
  801598:	c3                   	ret    

00801599 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015a9:	00 00 00 
	b.cnt = 0;
  8015ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015b6:	ff 75 0c             	pushl  0xc(%ebp)
  8015b9:	ff 75 08             	pushl  0x8(%ebp)
  8015bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	68 57 15 80 00       	push   $0x801557
  8015c8:	e8 54 01 00 00       	call   801721 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015cd:	83 c4 08             	add    $0x8,%esp
  8015d0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	e8 ed ea ff ff       	call   8000cf <sys_cputs>

	return b.cnt;
}
  8015e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015f3:	50                   	push   %eax
  8015f4:	ff 75 08             	pushl  0x8(%ebp)
  8015f7:	e8 9d ff ff ff       	call   801599 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	57                   	push   %edi
  801602:	56                   	push   %esi
  801603:	53                   	push   %ebx
  801604:	83 ec 1c             	sub    $0x1c,%esp
  801607:	89 c7                	mov    %eax,%edi
  801609:	89 d6                	mov    %edx,%esi
  80160b:	8b 45 08             	mov    0x8(%ebp),%eax
  80160e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801614:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801617:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80161a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801622:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801625:	39 d3                	cmp    %edx,%ebx
  801627:	72 05                	jb     80162e <printnum+0x30>
  801629:	39 45 10             	cmp    %eax,0x10(%ebp)
  80162c:	77 45                	ja     801673 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80162e:	83 ec 0c             	sub    $0xc,%esp
  801631:	ff 75 18             	pushl  0x18(%ebp)
  801634:	8b 45 14             	mov    0x14(%ebp),%eax
  801637:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80163a:	53                   	push   %ebx
  80163b:	ff 75 10             	pushl  0x10(%ebp)
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	ff 75 e4             	pushl  -0x1c(%ebp)
  801644:	ff 75 e0             	pushl  -0x20(%ebp)
  801647:	ff 75 dc             	pushl  -0x24(%ebp)
  80164a:	ff 75 d8             	pushl  -0x28(%ebp)
  80164d:	e8 9e 09 00 00       	call   801ff0 <__udivdi3>
  801652:	83 c4 18             	add    $0x18,%esp
  801655:	52                   	push   %edx
  801656:	50                   	push   %eax
  801657:	89 f2                	mov    %esi,%edx
  801659:	89 f8                	mov    %edi,%eax
  80165b:	e8 9e ff ff ff       	call   8015fe <printnum>
  801660:	83 c4 20             	add    $0x20,%esp
  801663:	eb 18                	jmp    80167d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	56                   	push   %esi
  801669:	ff 75 18             	pushl  0x18(%ebp)
  80166c:	ff d7                	call   *%edi
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb 03                	jmp    801676 <printnum+0x78>
  801673:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801676:	83 eb 01             	sub    $0x1,%ebx
  801679:	85 db                	test   %ebx,%ebx
  80167b:	7f e8                	jg     801665 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	56                   	push   %esi
  801681:	83 ec 04             	sub    $0x4,%esp
  801684:	ff 75 e4             	pushl  -0x1c(%ebp)
  801687:	ff 75 e0             	pushl  -0x20(%ebp)
  80168a:	ff 75 dc             	pushl  -0x24(%ebp)
  80168d:	ff 75 d8             	pushl  -0x28(%ebp)
  801690:	e8 8b 0a 00 00       	call   802120 <__umoddi3>
  801695:	83 c4 14             	add    $0x14,%esp
  801698:	0f be 80 03 24 80 00 	movsbl 0x802403(%eax),%eax
  80169f:	50                   	push   %eax
  8016a0:	ff d7                	call   *%edi
}
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5f                   	pop    %edi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016b0:	83 fa 01             	cmp    $0x1,%edx
  8016b3:	7e 0e                	jle    8016c3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016b5:	8b 10                	mov    (%eax),%edx
  8016b7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016ba:	89 08                	mov    %ecx,(%eax)
  8016bc:	8b 02                	mov    (%edx),%eax
  8016be:	8b 52 04             	mov    0x4(%edx),%edx
  8016c1:	eb 22                	jmp    8016e5 <getuint+0x38>
	else if (lflag)
  8016c3:	85 d2                	test   %edx,%edx
  8016c5:	74 10                	je     8016d7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016c7:	8b 10                	mov    (%eax),%edx
  8016c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016cc:	89 08                	mov    %ecx,(%eax)
  8016ce:	8b 02                	mov    (%edx),%eax
  8016d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d5:	eb 0e                	jmp    8016e5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016d7:	8b 10                	mov    (%eax),%edx
  8016d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016dc:	89 08                	mov    %ecx,(%eax)
  8016de:	8b 02                	mov    (%edx),%eax
  8016e0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016f1:	8b 10                	mov    (%eax),%edx
  8016f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8016f6:	73 0a                	jae    801702 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016fb:	89 08                	mov    %ecx,(%eax)
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	88 02                	mov    %al,(%edx)
}
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80170a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80170d:	50                   	push   %eax
  80170e:	ff 75 10             	pushl  0x10(%ebp)
  801711:	ff 75 0c             	pushl  0xc(%ebp)
  801714:	ff 75 08             	pushl  0x8(%ebp)
  801717:	e8 05 00 00 00       	call   801721 <vprintfmt>
	va_end(ap);
}
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	57                   	push   %edi
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	83 ec 2c             	sub    $0x2c,%esp
  80172a:	8b 75 08             	mov    0x8(%ebp),%esi
  80172d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801730:	8b 7d 10             	mov    0x10(%ebp),%edi
  801733:	eb 12                	jmp    801747 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801735:	85 c0                	test   %eax,%eax
  801737:	0f 84 89 03 00 00    	je     801ac6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	53                   	push   %ebx
  801741:	50                   	push   %eax
  801742:	ff d6                	call   *%esi
  801744:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801747:	83 c7 01             	add    $0x1,%edi
  80174a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80174e:	83 f8 25             	cmp    $0x25,%eax
  801751:	75 e2                	jne    801735 <vprintfmt+0x14>
  801753:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801757:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80175e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801765:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80176c:	ba 00 00 00 00       	mov    $0x0,%edx
  801771:	eb 07                	jmp    80177a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801773:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801776:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177a:	8d 47 01             	lea    0x1(%edi),%eax
  80177d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801780:	0f b6 07             	movzbl (%edi),%eax
  801783:	0f b6 c8             	movzbl %al,%ecx
  801786:	83 e8 23             	sub    $0x23,%eax
  801789:	3c 55                	cmp    $0x55,%al
  80178b:	0f 87 1a 03 00 00    	ja     801aab <vprintfmt+0x38a>
  801791:	0f b6 c0             	movzbl %al,%eax
  801794:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80179b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80179e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017a2:	eb d6                	jmp    80177a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017af:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017b2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017b6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017b9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017bc:	83 fa 09             	cmp    $0x9,%edx
  8017bf:	77 39                	ja     8017fa <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017c1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017c4:	eb e9                	jmp    8017af <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8017cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017cf:	8b 00                	mov    (%eax),%eax
  8017d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017d7:	eb 27                	jmp    801800 <vprintfmt+0xdf>
  8017d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017e3:	0f 49 c8             	cmovns %eax,%ecx
  8017e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ec:	eb 8c                	jmp    80177a <vprintfmt+0x59>
  8017ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017f1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017f8:	eb 80                	jmp    80177a <vprintfmt+0x59>
  8017fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801800:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801804:	0f 89 70 ff ff ff    	jns    80177a <vprintfmt+0x59>
				width = precision, precision = -1;
  80180a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80180d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801810:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801817:	e9 5e ff ff ff       	jmp    80177a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80181c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801822:	e9 53 ff ff ff       	jmp    80177a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801827:	8b 45 14             	mov    0x14(%ebp),%eax
  80182a:	8d 50 04             	lea    0x4(%eax),%edx
  80182d:	89 55 14             	mov    %edx,0x14(%ebp)
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	53                   	push   %ebx
  801834:	ff 30                	pushl  (%eax)
  801836:	ff d6                	call   *%esi
			break;
  801838:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80183e:	e9 04 ff ff ff       	jmp    801747 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801843:	8b 45 14             	mov    0x14(%ebp),%eax
  801846:	8d 50 04             	lea    0x4(%eax),%edx
  801849:	89 55 14             	mov    %edx,0x14(%ebp)
  80184c:	8b 00                	mov    (%eax),%eax
  80184e:	99                   	cltd   
  80184f:	31 d0                	xor    %edx,%eax
  801851:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801853:	83 f8 0f             	cmp    $0xf,%eax
  801856:	7f 0b                	jg     801863 <vprintfmt+0x142>
  801858:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80185f:	85 d2                	test   %edx,%edx
  801861:	75 18                	jne    80187b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801863:	50                   	push   %eax
  801864:	68 1b 24 80 00       	push   $0x80241b
  801869:	53                   	push   %ebx
  80186a:	56                   	push   %esi
  80186b:	e8 94 fe ff ff       	call   801704 <printfmt>
  801870:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801873:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801876:	e9 cc fe ff ff       	jmp    801747 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80187b:	52                   	push   %edx
  80187c:	68 61 23 80 00       	push   $0x802361
  801881:	53                   	push   %ebx
  801882:	56                   	push   %esi
  801883:	e8 7c fe ff ff       	call   801704 <printfmt>
  801888:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80188e:	e9 b4 fe ff ff       	jmp    801747 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801893:	8b 45 14             	mov    0x14(%ebp),%eax
  801896:	8d 50 04             	lea    0x4(%eax),%edx
  801899:	89 55 14             	mov    %edx,0x14(%ebp)
  80189c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80189e:	85 ff                	test   %edi,%edi
  8018a0:	b8 14 24 80 00       	mov    $0x802414,%eax
  8018a5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018ac:	0f 8e 94 00 00 00    	jle    801946 <vprintfmt+0x225>
  8018b2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018b6:	0f 84 98 00 00 00    	je     801954 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8018c2:	57                   	push   %edi
  8018c3:	e8 86 02 00 00       	call   801b4e <strnlen>
  8018c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018cb:	29 c1                	sub    %eax,%ecx
  8018cd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018d0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018d3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018da:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018dd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018df:	eb 0f                	jmp    8018f0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	53                   	push   %ebx
  8018e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8018e8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ea:	83 ef 01             	sub    $0x1,%edi
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 ff                	test   %edi,%edi
  8018f2:	7f ed                	jg     8018e1 <vprintfmt+0x1c0>
  8018f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018f7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018fa:	85 c9                	test   %ecx,%ecx
  8018fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801901:	0f 49 c1             	cmovns %ecx,%eax
  801904:	29 c1                	sub    %eax,%ecx
  801906:	89 75 08             	mov    %esi,0x8(%ebp)
  801909:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80190c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80190f:	89 cb                	mov    %ecx,%ebx
  801911:	eb 4d                	jmp    801960 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801913:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801917:	74 1b                	je     801934 <vprintfmt+0x213>
  801919:	0f be c0             	movsbl %al,%eax
  80191c:	83 e8 20             	sub    $0x20,%eax
  80191f:	83 f8 5e             	cmp    $0x5e,%eax
  801922:	76 10                	jbe    801934 <vprintfmt+0x213>
					putch('?', putdat);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	ff 75 0c             	pushl  0xc(%ebp)
  80192a:	6a 3f                	push   $0x3f
  80192c:	ff 55 08             	call   *0x8(%ebp)
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	eb 0d                	jmp    801941 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	ff 75 0c             	pushl  0xc(%ebp)
  80193a:	52                   	push   %edx
  80193b:	ff 55 08             	call   *0x8(%ebp)
  80193e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801941:	83 eb 01             	sub    $0x1,%ebx
  801944:	eb 1a                	jmp    801960 <vprintfmt+0x23f>
  801946:	89 75 08             	mov    %esi,0x8(%ebp)
  801949:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80194c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80194f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801952:	eb 0c                	jmp    801960 <vprintfmt+0x23f>
  801954:	89 75 08             	mov    %esi,0x8(%ebp)
  801957:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80195a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80195d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801960:	83 c7 01             	add    $0x1,%edi
  801963:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801967:	0f be d0             	movsbl %al,%edx
  80196a:	85 d2                	test   %edx,%edx
  80196c:	74 23                	je     801991 <vprintfmt+0x270>
  80196e:	85 f6                	test   %esi,%esi
  801970:	78 a1                	js     801913 <vprintfmt+0x1f2>
  801972:	83 ee 01             	sub    $0x1,%esi
  801975:	79 9c                	jns    801913 <vprintfmt+0x1f2>
  801977:	89 df                	mov    %ebx,%edi
  801979:	8b 75 08             	mov    0x8(%ebp),%esi
  80197c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80197f:	eb 18                	jmp    801999 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801981:	83 ec 08             	sub    $0x8,%esp
  801984:	53                   	push   %ebx
  801985:	6a 20                	push   $0x20
  801987:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801989:	83 ef 01             	sub    $0x1,%edi
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	eb 08                	jmp    801999 <vprintfmt+0x278>
  801991:	89 df                	mov    %ebx,%edi
  801993:	8b 75 08             	mov    0x8(%ebp),%esi
  801996:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801999:	85 ff                	test   %edi,%edi
  80199b:	7f e4                	jg     801981 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80199d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019a0:	e9 a2 fd ff ff       	jmp    801747 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019a5:	83 fa 01             	cmp    $0x1,%edx
  8019a8:	7e 16                	jle    8019c0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ad:	8d 50 08             	lea    0x8(%eax),%edx
  8019b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b3:	8b 50 04             	mov    0x4(%eax),%edx
  8019b6:	8b 00                	mov    (%eax),%eax
  8019b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019be:	eb 32                	jmp    8019f2 <vprintfmt+0x2d1>
	else if (lflag)
  8019c0:	85 d2                	test   %edx,%edx
  8019c2:	74 18                	je     8019dc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c7:	8d 50 04             	lea    0x4(%eax),%edx
  8019ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8019cd:	8b 00                	mov    (%eax),%eax
  8019cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d2:	89 c1                	mov    %eax,%ecx
  8019d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8019d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019da:	eb 16                	jmp    8019f2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019df:	8d 50 04             	lea    0x4(%eax),%edx
  8019e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e5:	8b 00                	mov    (%eax),%eax
  8019e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ea:	89 c1                	mov    %eax,%ecx
  8019ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a01:	79 74                	jns    801a77 <vprintfmt+0x356>
				putch('-', putdat);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	53                   	push   %ebx
  801a07:	6a 2d                	push   $0x2d
  801a09:	ff d6                	call   *%esi
				num = -(long long) num;
  801a0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a11:	f7 d8                	neg    %eax
  801a13:	83 d2 00             	adc    $0x0,%edx
  801a16:	f7 da                	neg    %edx
  801a18:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a1b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a20:	eb 55                	jmp    801a77 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a22:	8d 45 14             	lea    0x14(%ebp),%eax
  801a25:	e8 83 fc ff ff       	call   8016ad <getuint>
			base = 10;
  801a2a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a2f:	eb 46                	jmp    801a77 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a31:	8d 45 14             	lea    0x14(%ebp),%eax
  801a34:	e8 74 fc ff ff       	call   8016ad <getuint>
		        base = 8;
  801a39:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a3e:	eb 37                	jmp    801a77 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	53                   	push   %ebx
  801a44:	6a 30                	push   $0x30
  801a46:	ff d6                	call   *%esi
			putch('x', putdat);
  801a48:	83 c4 08             	add    $0x8,%esp
  801a4b:	53                   	push   %ebx
  801a4c:	6a 78                	push   $0x78
  801a4e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a50:	8b 45 14             	mov    0x14(%ebp),%eax
  801a53:	8d 50 04             	lea    0x4(%eax),%edx
  801a56:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a59:	8b 00                	mov    (%eax),%eax
  801a5b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a60:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a63:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a68:	eb 0d                	jmp    801a77 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a6a:	8d 45 14             	lea    0x14(%ebp),%eax
  801a6d:	e8 3b fc ff ff       	call   8016ad <getuint>
			base = 16;
  801a72:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a7e:	57                   	push   %edi
  801a7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801a82:	51                   	push   %ecx
  801a83:	52                   	push   %edx
  801a84:	50                   	push   %eax
  801a85:	89 da                	mov    %ebx,%edx
  801a87:	89 f0                	mov    %esi,%eax
  801a89:	e8 70 fb ff ff       	call   8015fe <printnum>
			break;
  801a8e:	83 c4 20             	add    $0x20,%esp
  801a91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a94:	e9 ae fc ff ff       	jmp    801747 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a99:	83 ec 08             	sub    $0x8,%esp
  801a9c:	53                   	push   %ebx
  801a9d:	51                   	push   %ecx
  801a9e:	ff d6                	call   *%esi
			break;
  801aa0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aa3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aa6:	e9 9c fc ff ff       	jmp    801747 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	53                   	push   %ebx
  801aaf:	6a 25                	push   $0x25
  801ab1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	eb 03                	jmp    801abb <vprintfmt+0x39a>
  801ab8:	83 ef 01             	sub    $0x1,%edi
  801abb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801abf:	75 f7                	jne    801ab8 <vprintfmt+0x397>
  801ac1:	e9 81 fc ff ff       	jmp    801747 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5f                   	pop    %edi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 18             	sub    $0x18,%esp
  801ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ada:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801add:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ae1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ae4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	74 26                	je     801b15 <vsnprintf+0x47>
  801aef:	85 d2                	test   %edx,%edx
  801af1:	7e 22                	jle    801b15 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801af3:	ff 75 14             	pushl  0x14(%ebp)
  801af6:	ff 75 10             	pushl  0x10(%ebp)
  801af9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801afc:	50                   	push   %eax
  801afd:	68 e7 16 80 00       	push   $0x8016e7
  801b02:	e8 1a fc ff ff       	call   801721 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b0a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	eb 05                	jmp    801b1a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b22:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b25:	50                   	push   %eax
  801b26:	ff 75 10             	pushl  0x10(%ebp)
  801b29:	ff 75 0c             	pushl  0xc(%ebp)
  801b2c:	ff 75 08             	pushl  0x8(%ebp)
  801b2f:	e8 9a ff ff ff       	call   801ace <vsnprintf>
	va_end(ap);

	return rc;
}
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b41:	eb 03                	jmp    801b46 <strlen+0x10>
		n++;
  801b43:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b46:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b4a:	75 f7                	jne    801b43 <strlen+0xd>
		n++;
	return n;
}
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b54:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b57:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5c:	eb 03                	jmp    801b61 <strnlen+0x13>
		n++;
  801b5e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b61:	39 c2                	cmp    %eax,%edx
  801b63:	74 08                	je     801b6d <strnlen+0x1f>
  801b65:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b69:	75 f3                	jne    801b5e <strnlen+0x10>
  801b6b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	53                   	push   %ebx
  801b73:	8b 45 08             	mov    0x8(%ebp),%eax
  801b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b79:	89 c2                	mov    %eax,%edx
  801b7b:	83 c2 01             	add    $0x1,%edx
  801b7e:	83 c1 01             	add    $0x1,%ecx
  801b81:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b85:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b88:	84 db                	test   %bl,%bl
  801b8a:	75 ef                	jne    801b7b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b8c:	5b                   	pop    %ebx
  801b8d:	5d                   	pop    %ebp
  801b8e:	c3                   	ret    

00801b8f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	53                   	push   %ebx
  801b93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b96:	53                   	push   %ebx
  801b97:	e8 9a ff ff ff       	call   801b36 <strlen>
  801b9c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ba2:	01 d8                	add    %ebx,%eax
  801ba4:	50                   	push   %eax
  801ba5:	e8 c5 ff ff ff       	call   801b6f <strcpy>
	return dst;
}
  801baa:	89 d8                	mov    %ebx,%eax
  801bac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801baf:	c9                   	leave  
  801bb0:	c3                   	ret    

00801bb1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbc:	89 f3                	mov    %esi,%ebx
  801bbe:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc1:	89 f2                	mov    %esi,%edx
  801bc3:	eb 0f                	jmp    801bd4 <strncpy+0x23>
		*dst++ = *src;
  801bc5:	83 c2 01             	add    $0x1,%edx
  801bc8:	0f b6 01             	movzbl (%ecx),%eax
  801bcb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bce:	80 39 01             	cmpb   $0x1,(%ecx)
  801bd1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd4:	39 da                	cmp    %ebx,%edx
  801bd6:	75 ed                	jne    801bc5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bd8:	89 f0                	mov    %esi,%eax
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	8b 75 08             	mov    0x8(%ebp),%esi
  801be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be9:	8b 55 10             	mov    0x10(%ebp),%edx
  801bec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bee:	85 d2                	test   %edx,%edx
  801bf0:	74 21                	je     801c13 <strlcpy+0x35>
  801bf2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bf6:	89 f2                	mov    %esi,%edx
  801bf8:	eb 09                	jmp    801c03 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bfa:	83 c2 01             	add    $0x1,%edx
  801bfd:	83 c1 01             	add    $0x1,%ecx
  801c00:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c03:	39 c2                	cmp    %eax,%edx
  801c05:	74 09                	je     801c10 <strlcpy+0x32>
  801c07:	0f b6 19             	movzbl (%ecx),%ebx
  801c0a:	84 db                	test   %bl,%bl
  801c0c:	75 ec                	jne    801bfa <strlcpy+0x1c>
  801c0e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c10:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c13:	29 f0                	sub    %esi,%eax
}
  801c15:	5b                   	pop    %ebx
  801c16:	5e                   	pop    %esi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c22:	eb 06                	jmp    801c2a <strcmp+0x11>
		p++, q++;
  801c24:	83 c1 01             	add    $0x1,%ecx
  801c27:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c2a:	0f b6 01             	movzbl (%ecx),%eax
  801c2d:	84 c0                	test   %al,%al
  801c2f:	74 04                	je     801c35 <strcmp+0x1c>
  801c31:	3a 02                	cmp    (%edx),%al
  801c33:	74 ef                	je     801c24 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c35:	0f b6 c0             	movzbl %al,%eax
  801c38:	0f b6 12             	movzbl (%edx),%edx
  801c3b:	29 d0                	sub    %edx,%eax
}
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	53                   	push   %ebx
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c49:	89 c3                	mov    %eax,%ebx
  801c4b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c4e:	eb 06                	jmp    801c56 <strncmp+0x17>
		n--, p++, q++;
  801c50:	83 c0 01             	add    $0x1,%eax
  801c53:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c56:	39 d8                	cmp    %ebx,%eax
  801c58:	74 15                	je     801c6f <strncmp+0x30>
  801c5a:	0f b6 08             	movzbl (%eax),%ecx
  801c5d:	84 c9                	test   %cl,%cl
  801c5f:	74 04                	je     801c65 <strncmp+0x26>
  801c61:	3a 0a                	cmp    (%edx),%cl
  801c63:	74 eb                	je     801c50 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c65:	0f b6 00             	movzbl (%eax),%eax
  801c68:	0f b6 12             	movzbl (%edx),%edx
  801c6b:	29 d0                	sub    %edx,%eax
  801c6d:	eb 05                	jmp    801c74 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c74:	5b                   	pop    %ebx
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c81:	eb 07                	jmp    801c8a <strchr+0x13>
		if (*s == c)
  801c83:	38 ca                	cmp    %cl,%dl
  801c85:	74 0f                	je     801c96 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c87:	83 c0 01             	add    $0x1,%eax
  801c8a:	0f b6 10             	movzbl (%eax),%edx
  801c8d:	84 d2                	test   %dl,%dl
  801c8f:	75 f2                	jne    801c83 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca2:	eb 03                	jmp    801ca7 <strfind+0xf>
  801ca4:	83 c0 01             	add    $0x1,%eax
  801ca7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801caa:	38 ca                	cmp    %cl,%dl
  801cac:	74 04                	je     801cb2 <strfind+0x1a>
  801cae:	84 d2                	test   %dl,%dl
  801cb0:	75 f2                	jne    801ca4 <strfind+0xc>
			break;
	return (char *) s;
}
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	57                   	push   %edi
  801cb8:	56                   	push   %esi
  801cb9:	53                   	push   %ebx
  801cba:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cc0:	85 c9                	test   %ecx,%ecx
  801cc2:	74 36                	je     801cfa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cca:	75 28                	jne    801cf4 <memset+0x40>
  801ccc:	f6 c1 03             	test   $0x3,%cl
  801ccf:	75 23                	jne    801cf4 <memset+0x40>
		c &= 0xFF;
  801cd1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cd5:	89 d3                	mov    %edx,%ebx
  801cd7:	c1 e3 08             	shl    $0x8,%ebx
  801cda:	89 d6                	mov    %edx,%esi
  801cdc:	c1 e6 18             	shl    $0x18,%esi
  801cdf:	89 d0                	mov    %edx,%eax
  801ce1:	c1 e0 10             	shl    $0x10,%eax
  801ce4:	09 f0                	or     %esi,%eax
  801ce6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	09 d0                	or     %edx,%eax
  801cec:	c1 e9 02             	shr    $0x2,%ecx
  801cef:	fc                   	cld    
  801cf0:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf2:	eb 06                	jmp    801cfa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf7:	fc                   	cld    
  801cf8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cfa:	89 f8                	mov    %edi,%eax
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5f                   	pop    %edi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	57                   	push   %edi
  801d05:	56                   	push   %esi
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d0f:	39 c6                	cmp    %eax,%esi
  801d11:	73 35                	jae    801d48 <memmove+0x47>
  801d13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d16:	39 d0                	cmp    %edx,%eax
  801d18:	73 2e                	jae    801d48 <memmove+0x47>
		s += n;
		d += n;
  801d1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1d:	89 d6                	mov    %edx,%esi
  801d1f:	09 fe                	or     %edi,%esi
  801d21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d27:	75 13                	jne    801d3c <memmove+0x3b>
  801d29:	f6 c1 03             	test   $0x3,%cl
  801d2c:	75 0e                	jne    801d3c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d2e:	83 ef 04             	sub    $0x4,%edi
  801d31:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d34:	c1 e9 02             	shr    $0x2,%ecx
  801d37:	fd                   	std    
  801d38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3a:	eb 09                	jmp    801d45 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d3c:	83 ef 01             	sub    $0x1,%edi
  801d3f:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d42:	fd                   	std    
  801d43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d45:	fc                   	cld    
  801d46:	eb 1d                	jmp    801d65 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d48:	89 f2                	mov    %esi,%edx
  801d4a:	09 c2                	or     %eax,%edx
  801d4c:	f6 c2 03             	test   $0x3,%dl
  801d4f:	75 0f                	jne    801d60 <memmove+0x5f>
  801d51:	f6 c1 03             	test   $0x3,%cl
  801d54:	75 0a                	jne    801d60 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d56:	c1 e9 02             	shr    $0x2,%ecx
  801d59:	89 c7                	mov    %eax,%edi
  801d5b:	fc                   	cld    
  801d5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d5e:	eb 05                	jmp    801d65 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d60:	89 c7                	mov    %eax,%edi
  801d62:	fc                   	cld    
  801d63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d6c:	ff 75 10             	pushl  0x10(%ebp)
  801d6f:	ff 75 0c             	pushl  0xc(%ebp)
  801d72:	ff 75 08             	pushl  0x8(%ebp)
  801d75:	e8 87 ff ff ff       	call   801d01 <memmove>
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	56                   	push   %esi
  801d80:	53                   	push   %ebx
  801d81:	8b 45 08             	mov    0x8(%ebp),%eax
  801d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d87:	89 c6                	mov    %eax,%esi
  801d89:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8c:	eb 1a                	jmp    801da8 <memcmp+0x2c>
		if (*s1 != *s2)
  801d8e:	0f b6 08             	movzbl (%eax),%ecx
  801d91:	0f b6 1a             	movzbl (%edx),%ebx
  801d94:	38 d9                	cmp    %bl,%cl
  801d96:	74 0a                	je     801da2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d98:	0f b6 c1             	movzbl %cl,%eax
  801d9b:	0f b6 db             	movzbl %bl,%ebx
  801d9e:	29 d8                	sub    %ebx,%eax
  801da0:	eb 0f                	jmp    801db1 <memcmp+0x35>
		s1++, s2++;
  801da2:	83 c0 01             	add    $0x1,%eax
  801da5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da8:	39 f0                	cmp    %esi,%eax
  801daa:	75 e2                	jne    801d8e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	53                   	push   %ebx
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dbc:	89 c1                	mov    %eax,%ecx
  801dbe:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dc5:	eb 0a                	jmp    801dd1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc7:	0f b6 10             	movzbl (%eax),%edx
  801dca:	39 da                	cmp    %ebx,%edx
  801dcc:	74 07                	je     801dd5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dce:	83 c0 01             	add    $0x1,%eax
  801dd1:	39 c8                	cmp    %ecx,%eax
  801dd3:	72 f2                	jb     801dc7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dd5:	5b                   	pop    %ebx
  801dd6:	5d                   	pop    %ebp
  801dd7:	c3                   	ret    

00801dd8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	57                   	push   %edi
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801de4:	eb 03                	jmp    801de9 <strtol+0x11>
		s++;
  801de6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801de9:	0f b6 01             	movzbl (%ecx),%eax
  801dec:	3c 20                	cmp    $0x20,%al
  801dee:	74 f6                	je     801de6 <strtol+0xe>
  801df0:	3c 09                	cmp    $0x9,%al
  801df2:	74 f2                	je     801de6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801df4:	3c 2b                	cmp    $0x2b,%al
  801df6:	75 0a                	jne    801e02 <strtol+0x2a>
		s++;
  801df8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dfb:	bf 00 00 00 00       	mov    $0x0,%edi
  801e00:	eb 11                	jmp    801e13 <strtol+0x3b>
  801e02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e07:	3c 2d                	cmp    $0x2d,%al
  801e09:	75 08                	jne    801e13 <strtol+0x3b>
		s++, neg = 1;
  801e0b:	83 c1 01             	add    $0x1,%ecx
  801e0e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e13:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e19:	75 15                	jne    801e30 <strtol+0x58>
  801e1b:	80 39 30             	cmpb   $0x30,(%ecx)
  801e1e:	75 10                	jne    801e30 <strtol+0x58>
  801e20:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e24:	75 7c                	jne    801ea2 <strtol+0xca>
		s += 2, base = 16;
  801e26:	83 c1 02             	add    $0x2,%ecx
  801e29:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e2e:	eb 16                	jmp    801e46 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e30:	85 db                	test   %ebx,%ebx
  801e32:	75 12                	jne    801e46 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e34:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e39:	80 39 30             	cmpb   $0x30,(%ecx)
  801e3c:	75 08                	jne    801e46 <strtol+0x6e>
		s++, base = 8;
  801e3e:	83 c1 01             	add    $0x1,%ecx
  801e41:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e4e:	0f b6 11             	movzbl (%ecx),%edx
  801e51:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e54:	89 f3                	mov    %esi,%ebx
  801e56:	80 fb 09             	cmp    $0x9,%bl
  801e59:	77 08                	ja     801e63 <strtol+0x8b>
			dig = *s - '0';
  801e5b:	0f be d2             	movsbl %dl,%edx
  801e5e:	83 ea 30             	sub    $0x30,%edx
  801e61:	eb 22                	jmp    801e85 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e63:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e66:	89 f3                	mov    %esi,%ebx
  801e68:	80 fb 19             	cmp    $0x19,%bl
  801e6b:	77 08                	ja     801e75 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e6d:	0f be d2             	movsbl %dl,%edx
  801e70:	83 ea 57             	sub    $0x57,%edx
  801e73:	eb 10                	jmp    801e85 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e75:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e78:	89 f3                	mov    %esi,%ebx
  801e7a:	80 fb 19             	cmp    $0x19,%bl
  801e7d:	77 16                	ja     801e95 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e7f:	0f be d2             	movsbl %dl,%edx
  801e82:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e85:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e88:	7d 0b                	jge    801e95 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e8a:	83 c1 01             	add    $0x1,%ecx
  801e8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e91:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e93:	eb b9                	jmp    801e4e <strtol+0x76>

	if (endptr)
  801e95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e99:	74 0d                	je     801ea8 <strtol+0xd0>
		*endptr = (char *) s;
  801e9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e9e:	89 0e                	mov    %ecx,(%esi)
  801ea0:	eb 06                	jmp    801ea8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ea2:	85 db                	test   %ebx,%ebx
  801ea4:	74 98                	je     801e3e <strtol+0x66>
  801ea6:	eb 9e                	jmp    801e46 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	f7 da                	neg    %edx
  801eac:	85 ff                	test   %edi,%edi
  801eae:	0f 45 c2             	cmovne %edx,%eax
}
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    

00801eb6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	56                   	push   %esi
  801eba:	53                   	push   %ebx
  801ebb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	74 0e                	je     801ed6 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801ec8:	83 ec 0c             	sub    $0xc,%esp
  801ecb:	50                   	push   %eax
  801ecc:	e8 6a e4 ff ff       	call   80033b <sys_ipc_recv>
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	eb 10                	jmp    801ee6 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801ed6:	83 ec 0c             	sub    $0xc,%esp
  801ed9:	68 00 00 00 f0       	push   $0xf0000000
  801ede:	e8 58 e4 ff ff       	call   80033b <sys_ipc_recv>
  801ee3:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	74 0e                	je     801ef8 <ipc_recv+0x42>
    	*from_env_store = 0;
  801eea:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ef0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801ef6:	eb 24                	jmp    801f1c <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ef8:	85 f6                	test   %esi,%esi
  801efa:	74 0a                	je     801f06 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801efc:	a1 08 40 80 00       	mov    0x804008,%eax
  801f01:	8b 40 74             	mov    0x74(%eax),%eax
  801f04:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801f06:	85 db                	test   %ebx,%ebx
  801f08:	74 0a                	je     801f14 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801f0a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f0f:	8b 40 78             	mov    0x78(%eax),%eax
  801f12:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801f14:	a1 08 40 80 00       	mov    0x804008,%eax
  801f19:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    

00801f23 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	57                   	push   %edi
  801f27:	56                   	push   %esi
  801f28:	53                   	push   %ebx
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f35:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f3c:	0f 44 d8             	cmove  %eax,%ebx
  801f3f:	eb 1c                	jmp    801f5d <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f41:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f44:	74 12                	je     801f58 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f46:	50                   	push   %eax
  801f47:	68 00 27 80 00       	push   $0x802700
  801f4c:	6a 4b                	push   $0x4b
  801f4e:	68 18 27 80 00       	push   $0x802718
  801f53:	e8 b9 f5 ff ff       	call   801511 <_panic>
        }	
        sys_yield();
  801f58:	e8 0f e2 ff ff       	call   80016c <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f5d:	ff 75 14             	pushl  0x14(%ebp)
  801f60:	53                   	push   %ebx
  801f61:	56                   	push   %esi
  801f62:	57                   	push   %edi
  801f63:	e8 b0 e3 ff ff       	call   800318 <sys_ipc_try_send>
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	75 d2                	jne    801f41 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f72:	5b                   	pop    %ebx
  801f73:	5e                   	pop    %esi
  801f74:	5f                   	pop    %edi
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f82:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f85:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8b:	8b 52 50             	mov    0x50(%edx),%edx
  801f8e:	39 ca                	cmp    %ecx,%edx
  801f90:	75 0d                	jne    801f9f <ipc_find_env+0x28>
			return envs[i].env_id;
  801f92:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f95:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9a:	8b 40 48             	mov    0x48(%eax),%eax
  801f9d:	eb 0f                	jmp    801fae <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f9f:	83 c0 01             	add    $0x1,%eax
  801fa2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa7:	75 d9                	jne    801f82 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    

00801fb0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb6:	89 d0                	mov    %edx,%eax
  801fb8:	c1 e8 16             	shr    $0x16,%eax
  801fbb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fc2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc7:	f6 c1 01             	test   $0x1,%cl
  801fca:	74 1d                	je     801fe9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fcc:	c1 ea 0c             	shr    $0xc,%edx
  801fcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd6:	f6 c2 01             	test   $0x1,%dl
  801fd9:	74 0e                	je     801fe9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdb:	c1 ea 0c             	shr    $0xc,%edx
  801fde:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe5:	ef 
  801fe6:	0f b7 c0             	movzwl %ax,%eax
}
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    
  801feb:	66 90                	xchg   %ax,%ax
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
