
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004d:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800054:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800057:	e8 ce 00 00 00       	call   80012a <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 db                	test   %ebx,%ebx
  800070:	7e 07                	jle    800079 <libmain+0x37>
		binaryname = argv[0];
  800072:	8b 06                	mov    (%esi),%eax
  800074:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	e8 b0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800083:	e8 0a 00 00 00       	call   800092 <exit>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    

00800092 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800098:	e8 c7 04 00 00       	call   800564 <close_all>
	sys_env_destroy(0);
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 6a 22 80 00       	push   $0x80226a
  800116:	6a 23                	push   $0x23
  800118:	68 87 22 80 00       	push   $0x802287
  80011d:	e8 cc 13 00 00       	call   8014ee <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0b 00 00 00       	mov    $0xb,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 6a 22 80 00       	push   $0x80226a
  800197:	6a 23                	push   $0x23
  800199:	68 87 22 80 00       	push   $0x802287
  80019e:	e8 4b 13 00 00       	call   8014ee <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 6a 22 80 00       	push   $0x80226a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 87 22 80 00       	push   $0x802287
  8001e0:	e8 09 13 00 00       	call   8014ee <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 6a 22 80 00       	push   $0x80226a
  80021b:	6a 23                	push   $0x23
  80021d:	68 87 22 80 00       	push   $0x802287
  800222:	e8 c7 12 00 00       	call   8014ee <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 6a 22 80 00       	push   $0x80226a
  80025d:	6a 23                	push   $0x23
  80025f:	68 87 22 80 00       	push   $0x802287
  800264:	e8 85 12 00 00       	call   8014ee <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 6a 22 80 00       	push   $0x80226a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 87 22 80 00       	push   $0x802287
  8002a6:	e8 43 12 00 00       	call   8014ee <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	89 df                	mov    %ebx,%edi
  8002ce:	89 de                	mov    %ebx,%esi
  8002d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	7e 17                	jle    8002ed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d6:	83 ec 0c             	sub    $0xc,%esp
  8002d9:	50                   	push   %eax
  8002da:	6a 0a                	push   $0xa
  8002dc:	68 6a 22 80 00       	push   $0x80226a
  8002e1:	6a 23                	push   $0x23
  8002e3:	68 87 22 80 00       	push   $0x802287
  8002e8:	e8 01 12 00 00       	call   8014ee <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fb:	be 00 00 00 00       	mov    $0x0,%esi
  800300:	b8 0c 00 00 00       	mov    $0xc,%eax
  800305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800311:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800321:	b9 00 00 00 00       	mov    $0x0,%ecx
  800326:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
  80032e:	89 cb                	mov    %ecx,%ebx
  800330:	89 cf                	mov    %ecx,%edi
  800332:	89 ce                	mov    %ecx,%esi
  800334:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800336:	85 c0                	test   %eax,%eax
  800338:	7e 17                	jle    800351 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033a:	83 ec 0c             	sub    $0xc,%esp
  80033d:	50                   	push   %eax
  80033e:	6a 0d                	push   $0xd
  800340:	68 6a 22 80 00       	push   $0x80226a
  800345:	6a 23                	push   $0x23
  800347:	68 87 22 80 00       	push   $0x802287
  80034c:	e8 9d 11 00 00       	call   8014ee <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800354:	5b                   	pop    %ebx
  800355:	5e                   	pop    %esi
  800356:	5f                   	pop    %edi
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	57                   	push   %edi
  80035d:	56                   	push   %esi
  80035e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035f:	ba 00 00 00 00       	mov    $0x0,%edx
  800364:	b8 0e 00 00 00       	mov    $0xe,%eax
  800369:	89 d1                	mov    %edx,%ecx
  80036b:	89 d3                	mov    %edx,%ebx
  80036d:	89 d7                	mov    %edx,%edi
  80036f:	89 d6                	mov    %edx,%esi
  800371:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	57                   	push   %edi
  80037c:	56                   	push   %esi
  80037d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800383:	b8 0f 00 00 00       	mov    $0xf,%eax
  800388:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038b:	8b 55 08             	mov    0x8(%ebp),%edx
  80038e:	89 df                	mov    %ebx,%edi
  800390:	89 de                	mov    %ebx,%esi
  800392:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800394:	5b                   	pop    %ebx
  800395:	5e                   	pop    %esi
  800396:	5f                   	pop    %edi
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80039c:	8b 45 08             	mov    0x8(%ebp),%eax
  80039f:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a4:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8003af:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003cb:	89 c2                	mov    %eax,%edx
  8003cd:	c1 ea 16             	shr    $0x16,%edx
  8003d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d7:	f6 c2 01             	test   $0x1,%dl
  8003da:	74 11                	je     8003ed <fd_alloc+0x2d>
  8003dc:	89 c2                	mov    %eax,%edx
  8003de:	c1 ea 0c             	shr    $0xc,%edx
  8003e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e8:	f6 c2 01             	test   $0x1,%dl
  8003eb:	75 09                	jne    8003f6 <fd_alloc+0x36>
			*fd_store = fd;
  8003ed:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f4:	eb 17                	jmp    80040d <fd_alloc+0x4d>
  8003f6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003fb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800400:	75 c9                	jne    8003cb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800402:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800408:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800415:	83 f8 1f             	cmp    $0x1f,%eax
  800418:	77 36                	ja     800450 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80041a:	c1 e0 0c             	shl    $0xc,%eax
  80041d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800422:	89 c2                	mov    %eax,%edx
  800424:	c1 ea 16             	shr    $0x16,%edx
  800427:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042e:	f6 c2 01             	test   $0x1,%dl
  800431:	74 24                	je     800457 <fd_lookup+0x48>
  800433:	89 c2                	mov    %eax,%edx
  800435:	c1 ea 0c             	shr    $0xc,%edx
  800438:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043f:	f6 c2 01             	test   $0x1,%dl
  800442:	74 1a                	je     80045e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800444:	8b 55 0c             	mov    0xc(%ebp),%edx
  800447:	89 02                	mov    %eax,(%edx)
	return 0;
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	eb 13                	jmp    800463 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800450:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800455:	eb 0c                	jmp    800463 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045c:	eb 05                	jmp    800463 <fd_lookup+0x54>
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800463:	5d                   	pop    %ebp
  800464:	c3                   	ret    

00800465 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80046e:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800473:	eb 13                	jmp    800488 <dev_lookup+0x23>
  800475:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800478:	39 08                	cmp    %ecx,(%eax)
  80047a:	75 0c                	jne    800488 <dev_lookup+0x23>
			*dev = devtab[i];
  80047c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80047f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800481:	b8 00 00 00 00       	mov    $0x0,%eax
  800486:	eb 2e                	jmp    8004b6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800488:	8b 02                	mov    (%edx),%eax
  80048a:	85 c0                	test   %eax,%eax
  80048c:	75 e7                	jne    800475 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048e:	a1 08 40 80 00       	mov    0x804008,%eax
  800493:	8b 40 48             	mov    0x48(%eax),%eax
  800496:	83 ec 04             	sub    $0x4,%esp
  800499:	51                   	push   %ecx
  80049a:	50                   	push   %eax
  80049b:	68 98 22 80 00       	push   $0x802298
  8004a0:	e8 22 11 00 00       	call   8015c7 <cprintf>
	*dev = 0;
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    

008004b8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	56                   	push   %esi
  8004bc:	53                   	push   %ebx
  8004bd:	83 ec 10             	sub    $0x10,%esp
  8004c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c9:	50                   	push   %eax
  8004ca:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d0:	c1 e8 0c             	shr    $0xc,%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 36 ff ff ff       	call   80040f <fd_lookup>
  8004d9:	83 c4 08             	add    $0x8,%esp
  8004dc:	85 c0                	test   %eax,%eax
  8004de:	78 05                	js     8004e5 <fd_close+0x2d>
	    || fd != fd2)
  8004e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e3:	74 0c                	je     8004f1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004e5:	84 db                	test   %bl,%bl
  8004e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ec:	0f 44 c2             	cmove  %edx,%eax
  8004ef:	eb 41                	jmp    800532 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f7:	50                   	push   %eax
  8004f8:	ff 36                	pushl  (%esi)
  8004fa:	e8 66 ff ff ff       	call   800465 <dev_lookup>
  8004ff:	89 c3                	mov    %eax,%ebx
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 1a                	js     800522 <fd_close+0x6a>
		if (dev->dev_close)
  800508:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80050b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80050e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800513:	85 c0                	test   %eax,%eax
  800515:	74 0b                	je     800522 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800517:	83 ec 0c             	sub    $0xc,%esp
  80051a:	56                   	push   %esi
  80051b:	ff d0                	call   *%eax
  80051d:	89 c3                	mov    %eax,%ebx
  80051f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	56                   	push   %esi
  800526:	6a 00                	push   $0x0
  800528:	e8 c0 fc ff ff       	call   8001ed <sys_page_unmap>
	return r;
  80052d:	83 c4 10             	add    $0x10,%esp
  800530:	89 d8                	mov    %ebx,%eax
}
  800532:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800535:	5b                   	pop    %ebx
  800536:	5e                   	pop    %esi
  800537:	5d                   	pop    %ebp
  800538:	c3                   	ret    

00800539 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80053f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800542:	50                   	push   %eax
  800543:	ff 75 08             	pushl  0x8(%ebp)
  800546:	e8 c4 fe ff ff       	call   80040f <fd_lookup>
  80054b:	83 c4 08             	add    $0x8,%esp
  80054e:	85 c0                	test   %eax,%eax
  800550:	78 10                	js     800562 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	6a 01                	push   $0x1
  800557:	ff 75 f4             	pushl  -0xc(%ebp)
  80055a:	e8 59 ff ff ff       	call   8004b8 <fd_close>
  80055f:	83 c4 10             	add    $0x10,%esp
}
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <close_all>:

void
close_all(void)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	53                   	push   %ebx
  800568:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80056b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800570:	83 ec 0c             	sub    $0xc,%esp
  800573:	53                   	push   %ebx
  800574:	e8 c0 ff ff ff       	call   800539 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800579:	83 c3 01             	add    $0x1,%ebx
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	83 fb 20             	cmp    $0x20,%ebx
  800582:	75 ec                	jne    800570 <close_all+0xc>
		close(i);
}
  800584:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800587:	c9                   	leave  
  800588:	c3                   	ret    

00800589 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
  80058c:	57                   	push   %edi
  80058d:	56                   	push   %esi
  80058e:	53                   	push   %ebx
  80058f:	83 ec 2c             	sub    $0x2c,%esp
  800592:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800595:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800598:	50                   	push   %eax
  800599:	ff 75 08             	pushl  0x8(%ebp)
  80059c:	e8 6e fe ff ff       	call   80040f <fd_lookup>
  8005a1:	83 c4 08             	add    $0x8,%esp
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	0f 88 c1 00 00 00    	js     80066d <dup+0xe4>
		return r;
	close(newfdnum);
  8005ac:	83 ec 0c             	sub    $0xc,%esp
  8005af:	56                   	push   %esi
  8005b0:	e8 84 ff ff ff       	call   800539 <close>

	newfd = INDEX2FD(newfdnum);
  8005b5:	89 f3                	mov    %esi,%ebx
  8005b7:	c1 e3 0c             	shl    $0xc,%ebx
  8005ba:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c0:	83 c4 04             	add    $0x4,%esp
  8005c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c6:	e8 de fd ff ff       	call   8003a9 <fd2data>
  8005cb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005cd:	89 1c 24             	mov    %ebx,(%esp)
  8005d0:	e8 d4 fd ff ff       	call   8003a9 <fd2data>
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005db:	89 f8                	mov    %edi,%eax
  8005dd:	c1 e8 16             	shr    $0x16,%eax
  8005e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e7:	a8 01                	test   $0x1,%al
  8005e9:	74 37                	je     800622 <dup+0x99>
  8005eb:	89 f8                	mov    %edi,%eax
  8005ed:	c1 e8 0c             	shr    $0xc,%eax
  8005f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f7:	f6 c2 01             	test   $0x1,%dl
  8005fa:	74 26                	je     800622 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	25 07 0e 00 00       	and    $0xe07,%eax
  80060b:	50                   	push   %eax
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	57                   	push   %edi
  800612:	6a 00                	push   $0x0
  800614:	e8 92 fb ff ff       	call   8001ab <sys_page_map>
  800619:	89 c7                	mov    %eax,%edi
  80061b:	83 c4 20             	add    $0x20,%esp
  80061e:	85 c0                	test   %eax,%eax
  800620:	78 2e                	js     800650 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800622:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800625:	89 d0                	mov    %edx,%eax
  800627:	c1 e8 0c             	shr    $0xc,%eax
  80062a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800631:	83 ec 0c             	sub    $0xc,%esp
  800634:	25 07 0e 00 00       	and    $0xe07,%eax
  800639:	50                   	push   %eax
  80063a:	53                   	push   %ebx
  80063b:	6a 00                	push   $0x0
  80063d:	52                   	push   %edx
  80063e:	6a 00                	push   $0x0
  800640:	e8 66 fb ff ff       	call   8001ab <sys_page_map>
  800645:	89 c7                	mov    %eax,%edi
  800647:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80064a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80064c:	85 ff                	test   %edi,%edi
  80064e:	79 1d                	jns    80066d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	53                   	push   %ebx
  800654:	6a 00                	push   $0x0
  800656:	e8 92 fb ff ff       	call   8001ed <sys_page_unmap>
	sys_page_unmap(0, nva);
  80065b:	83 c4 08             	add    $0x8,%esp
  80065e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800661:	6a 00                	push   $0x0
  800663:	e8 85 fb ff ff       	call   8001ed <sys_page_unmap>
	return r;
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	89 f8                	mov    %edi,%eax
}
  80066d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800670:	5b                   	pop    %ebx
  800671:	5e                   	pop    %esi
  800672:	5f                   	pop    %edi
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	53                   	push   %ebx
  800679:	83 ec 14             	sub    $0x14,%esp
  80067c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800682:	50                   	push   %eax
  800683:	53                   	push   %ebx
  800684:	e8 86 fd ff ff       	call   80040f <fd_lookup>
  800689:	83 c4 08             	add    $0x8,%esp
  80068c:	89 c2                	mov    %eax,%edx
  80068e:	85 c0                	test   %eax,%eax
  800690:	78 6d                	js     8006ff <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800698:	50                   	push   %eax
  800699:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069c:	ff 30                	pushl  (%eax)
  80069e:	e8 c2 fd ff ff       	call   800465 <dev_lookup>
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	78 4c                	js     8006f6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006ad:	8b 42 08             	mov    0x8(%edx),%eax
  8006b0:	83 e0 03             	and    $0x3,%eax
  8006b3:	83 f8 01             	cmp    $0x1,%eax
  8006b6:	75 21                	jne    8006d9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8006bd:	8b 40 48             	mov    0x48(%eax),%eax
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	50                   	push   %eax
  8006c5:	68 d9 22 80 00       	push   $0x8022d9
  8006ca:	e8 f8 0e 00 00       	call   8015c7 <cprintf>
		return -E_INVAL;
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d7:	eb 26                	jmp    8006ff <read+0x8a>
	}
	if (!dev->dev_read)
  8006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dc:	8b 40 08             	mov    0x8(%eax),%eax
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 17                	je     8006fa <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e3:	83 ec 04             	sub    $0x4,%esp
  8006e6:	ff 75 10             	pushl  0x10(%ebp)
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	52                   	push   %edx
  8006ed:	ff d0                	call   *%eax
  8006ef:	89 c2                	mov    %eax,%edx
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	eb 09                	jmp    8006ff <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f6:	89 c2                	mov    %eax,%edx
  8006f8:	eb 05                	jmp    8006ff <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ff:	89 d0                	mov    %edx,%eax
  800701:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	57                   	push   %edi
  80070a:	56                   	push   %esi
  80070b:	53                   	push   %ebx
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800712:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800715:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071a:	eb 21                	jmp    80073d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071c:	83 ec 04             	sub    $0x4,%esp
  80071f:	89 f0                	mov    %esi,%eax
  800721:	29 d8                	sub    %ebx,%eax
  800723:	50                   	push   %eax
  800724:	89 d8                	mov    %ebx,%eax
  800726:	03 45 0c             	add    0xc(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	57                   	push   %edi
  80072b:	e8 45 ff ff ff       	call   800675 <read>
		if (m < 0)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	85 c0                	test   %eax,%eax
  800735:	78 10                	js     800747 <readn+0x41>
			return m;
		if (m == 0)
  800737:	85 c0                	test   %eax,%eax
  800739:	74 0a                	je     800745 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80073b:	01 c3                	add    %eax,%ebx
  80073d:	39 f3                	cmp    %esi,%ebx
  80073f:	72 db                	jb     80071c <readn+0x16>
  800741:	89 d8                	mov    %ebx,%eax
  800743:	eb 02                	jmp    800747 <readn+0x41>
  800745:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800747:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5e                   	pop    %esi
  80074c:	5f                   	pop    %edi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	83 ec 14             	sub    $0x14,%esp
  800756:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800759:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80075c:	50                   	push   %eax
  80075d:	53                   	push   %ebx
  80075e:	e8 ac fc ff ff       	call   80040f <fd_lookup>
  800763:	83 c4 08             	add    $0x8,%esp
  800766:	89 c2                	mov    %eax,%edx
  800768:	85 c0                	test   %eax,%eax
  80076a:	78 68                	js     8007d4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800772:	50                   	push   %eax
  800773:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800776:	ff 30                	pushl  (%eax)
  800778:	e8 e8 fc ff ff       	call   800465 <dev_lookup>
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	85 c0                	test   %eax,%eax
  800782:	78 47                	js     8007cb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800784:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800787:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80078b:	75 21                	jne    8007ae <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80078d:	a1 08 40 80 00       	mov    0x804008,%eax
  800792:	8b 40 48             	mov    0x48(%eax),%eax
  800795:	83 ec 04             	sub    $0x4,%esp
  800798:	53                   	push   %ebx
  800799:	50                   	push   %eax
  80079a:	68 f5 22 80 00       	push   $0x8022f5
  80079f:	e8 23 0e 00 00       	call   8015c7 <cprintf>
		return -E_INVAL;
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007ac:	eb 26                	jmp    8007d4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b4:	85 d2                	test   %edx,%edx
  8007b6:	74 17                	je     8007cf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b8:	83 ec 04             	sub    $0x4,%esp
  8007bb:	ff 75 10             	pushl  0x10(%ebp)
  8007be:	ff 75 0c             	pushl  0xc(%ebp)
  8007c1:	50                   	push   %eax
  8007c2:	ff d2                	call   *%edx
  8007c4:	89 c2                	mov    %eax,%edx
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	eb 09                	jmp    8007d4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	eb 05                	jmp    8007d4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007d4:	89 d0                	mov    %edx,%eax
  8007d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <seek>:

int
seek(int fdnum, off_t offset)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e4:	50                   	push   %eax
  8007e5:	ff 75 08             	pushl  0x8(%ebp)
  8007e8:	e8 22 fc ff ff       	call   80040f <fd_lookup>
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 0e                	js     800802 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	83 ec 14             	sub    $0x14,%esp
  80080b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800811:	50                   	push   %eax
  800812:	53                   	push   %ebx
  800813:	e8 f7 fb ff ff       	call   80040f <fd_lookup>
  800818:	83 c4 08             	add    $0x8,%esp
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	85 c0                	test   %eax,%eax
  80081f:	78 65                	js     800886 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800821:	83 ec 08             	sub    $0x8,%esp
  800824:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800827:	50                   	push   %eax
  800828:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082b:	ff 30                	pushl  (%eax)
  80082d:	e8 33 fc ff ff       	call   800465 <dev_lookup>
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	85 c0                	test   %eax,%eax
  800837:	78 44                	js     80087d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800840:	75 21                	jne    800863 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800842:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800847:	8b 40 48             	mov    0x48(%eax),%eax
  80084a:	83 ec 04             	sub    $0x4,%esp
  80084d:	53                   	push   %ebx
  80084e:	50                   	push   %eax
  80084f:	68 b8 22 80 00       	push   $0x8022b8
  800854:	e8 6e 0d 00 00       	call   8015c7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800861:	eb 23                	jmp    800886 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800863:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800866:	8b 52 18             	mov    0x18(%edx),%edx
  800869:	85 d2                	test   %edx,%edx
  80086b:	74 14                	je     800881 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	ff 75 0c             	pushl  0xc(%ebp)
  800873:	50                   	push   %eax
  800874:	ff d2                	call   *%edx
  800876:	89 c2                	mov    %eax,%edx
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	eb 09                	jmp    800886 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087d:	89 c2                	mov    %eax,%edx
  80087f:	eb 05                	jmp    800886 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800881:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800886:	89 d0                	mov    %edx,%eax
  800888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	53                   	push   %ebx
  800891:	83 ec 14             	sub    $0x14,%esp
  800894:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800897:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80089a:	50                   	push   %eax
  80089b:	ff 75 08             	pushl  0x8(%ebp)
  80089e:	e8 6c fb ff ff       	call   80040f <fd_lookup>
  8008a3:	83 c4 08             	add    $0x8,%esp
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	78 58                	js     800904 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b2:	50                   	push   %eax
  8008b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b6:	ff 30                	pushl  (%eax)
  8008b8:	e8 a8 fb ff ff       	call   800465 <dev_lookup>
  8008bd:	83 c4 10             	add    $0x10,%esp
  8008c0:	85 c0                	test   %eax,%eax
  8008c2:	78 37                	js     8008fb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008cb:	74 32                	je     8008ff <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008cd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d7:	00 00 00 
	stat->st_isdir = 0;
  8008da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e1:	00 00 00 
	stat->st_dev = dev;
  8008e4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	53                   	push   %ebx
  8008ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8008f1:	ff 50 14             	call   *0x14(%eax)
  8008f4:	89 c2                	mov    %eax,%edx
  8008f6:	83 c4 10             	add    $0x10,%esp
  8008f9:	eb 09                	jmp    800904 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008fb:	89 c2                	mov    %eax,%edx
  8008fd:	eb 05                	jmp    800904 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800904:	89 d0                	mov    %edx,%eax
  800906:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	6a 00                	push   $0x0
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 e7 01 00 00       	call   800b04 <open>
  80091d:	89 c3                	mov    %eax,%ebx
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	85 c0                	test   %eax,%eax
  800924:	78 1b                	js     800941 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800926:	83 ec 08             	sub    $0x8,%esp
  800929:	ff 75 0c             	pushl  0xc(%ebp)
  80092c:	50                   	push   %eax
  80092d:	e8 5b ff ff ff       	call   80088d <fstat>
  800932:	89 c6                	mov    %eax,%esi
	close(fd);
  800934:	89 1c 24             	mov    %ebx,(%esp)
  800937:	e8 fd fb ff ff       	call   800539 <close>
	return r;
  80093c:	83 c4 10             	add    $0x10,%esp
  80093f:	89 f0                	mov    %esi,%eax
}
  800941:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	89 c6                	mov    %eax,%esi
  80094f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800951:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800958:	75 12                	jne    80096c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80095a:	83 ec 0c             	sub    $0xc,%esp
  80095d:	6a 01                	push   $0x1
  80095f:	e8 f0 15 00 00       	call   801f54 <ipc_find_env>
  800964:	a3 00 40 80 00       	mov    %eax,0x804000
  800969:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80096c:	6a 07                	push   $0x7
  80096e:	68 00 50 80 00       	push   $0x805000
  800973:	56                   	push   %esi
  800974:	ff 35 00 40 80 00    	pushl  0x804000
  80097a:	e8 81 15 00 00       	call   801f00 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80097f:	83 c4 0c             	add    $0xc,%esp
  800982:	6a 00                	push   $0x0
  800984:	53                   	push   %ebx
  800985:	6a 00                	push   $0x0
  800987:	e8 07 15 00 00       	call   801e93 <ipc_recv>
}
  80098c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 40 0c             	mov    0xc(%eax),%eax
  80099f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b1:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b6:	e8 8d ff ff ff       	call   800948 <fsipc>
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d3:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d8:	e8 6b ff ff ff       	call   800948 <fsipc>
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	83 ec 04             	sub    $0x4,%esp
  8009e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ef:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8009fe:	e8 45 ff ff ff       	call   800948 <fsipc>
  800a03:	85 c0                	test   %eax,%eax
  800a05:	78 2c                	js     800a33 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a07:	83 ec 08             	sub    $0x8,%esp
  800a0a:	68 00 50 80 00       	push   $0x805000
  800a0f:	53                   	push   %ebx
  800a10:	e8 37 11 00 00       	call   801b4c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a15:	a1 80 50 80 00       	mov    0x805080,%eax
  800a1a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a20:	a1 84 50 80 00       	mov    0x805084,%eax
  800a25:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a2b:	83 c4 10             	add    $0x10,%esp
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	83 ec 08             	sub    $0x8,%esp
  800a3f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a42:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a47:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a4c:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4f:	53                   	push   %ebx
  800a50:	ff 75 0c             	pushl  0xc(%ebp)
  800a53:	68 08 50 80 00       	push   $0x805008
  800a58:	e8 81 12 00 00       	call   801cde <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 40 0c             	mov    0xc(%eax),%eax
  800a63:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a68:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	b8 04 00 00 00       	mov    $0x4,%eax
  800a78:	e8 cb fe ff ff       	call   800948 <fsipc>
	//panic("devfile_write not implemented");
}
  800a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a90:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a95:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa5:	e8 9e fe ff ff       	call   800948 <fsipc>
  800aaa:	89 c3                	mov    %eax,%ebx
  800aac:	85 c0                	test   %eax,%eax
  800aae:	78 4b                	js     800afb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab0:	39 c6                	cmp    %eax,%esi
  800ab2:	73 16                	jae    800aca <devfile_read+0x48>
  800ab4:	68 28 23 80 00       	push   $0x802328
  800ab9:	68 2f 23 80 00       	push   $0x80232f
  800abe:	6a 7c                	push   $0x7c
  800ac0:	68 44 23 80 00       	push   $0x802344
  800ac5:	e8 24 0a 00 00       	call   8014ee <_panic>
	assert(r <= PGSIZE);
  800aca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acf:	7e 16                	jle    800ae7 <devfile_read+0x65>
  800ad1:	68 4f 23 80 00       	push   $0x80234f
  800ad6:	68 2f 23 80 00       	push   $0x80232f
  800adb:	6a 7d                	push   $0x7d
  800add:	68 44 23 80 00       	push   $0x802344
  800ae2:	e8 07 0a 00 00       	call   8014ee <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae7:	83 ec 04             	sub    $0x4,%esp
  800aea:	50                   	push   %eax
  800aeb:	68 00 50 80 00       	push   $0x805000
  800af0:	ff 75 0c             	pushl  0xc(%ebp)
  800af3:	e8 e6 11 00 00       	call   801cde <memmove>
	return r;
  800af8:	83 c4 10             	add    $0x10,%esp
}
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	83 ec 20             	sub    $0x20,%esp
  800b0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0e:	53                   	push   %ebx
  800b0f:	e8 ff 0f 00 00       	call   801b13 <strlen>
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1c:	7f 67                	jg     800b85 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b24:	50                   	push   %eax
  800b25:	e8 96 f8 ff ff       	call   8003c0 <fd_alloc>
  800b2a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	78 57                	js     800b8a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b33:	83 ec 08             	sub    $0x8,%esp
  800b36:	53                   	push   %ebx
  800b37:	68 00 50 80 00       	push   $0x805000
  800b3c:	e8 0b 10 00 00       	call   801b4c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b51:	e8 f2 fd ff ff       	call   800948 <fsipc>
  800b56:	89 c3                	mov    %eax,%ebx
  800b58:	83 c4 10             	add    $0x10,%esp
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	79 14                	jns    800b73 <open+0x6f>
		fd_close(fd, 0);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	6a 00                	push   $0x0
  800b64:	ff 75 f4             	pushl  -0xc(%ebp)
  800b67:	e8 4c f9 ff ff       	call   8004b8 <fd_close>
		return r;
  800b6c:	83 c4 10             	add    $0x10,%esp
  800b6f:	89 da                	mov    %ebx,%edx
  800b71:	eb 17                	jmp    800b8a <open+0x86>
	}

	return fd2num(fd);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	ff 75 f4             	pushl  -0xc(%ebp)
  800b79:	e8 1b f8 ff ff       	call   800399 <fd2num>
  800b7e:	89 c2                	mov    %eax,%edx
  800b80:	83 c4 10             	add    $0x10,%esp
  800b83:	eb 05                	jmp    800b8a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b85:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b8a:	89 d0                	mov    %edx,%eax
  800b8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba1:	e8 a2 fd ff ff       	call   800948 <fsipc>
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bae:	68 5b 23 80 00       	push   $0x80235b
  800bb3:	ff 75 0c             	pushl  0xc(%ebp)
  800bb6:	e8 91 0f 00 00       	call   801b4c <strcpy>
	return 0;
}
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    

00800bc2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 10             	sub    $0x10,%esp
  800bc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bcc:	53                   	push   %ebx
  800bcd:	e8 bb 13 00 00       	call   801f8d <pageref>
  800bd2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bda:	83 f8 01             	cmp    $0x1,%eax
  800bdd:	75 10                	jne    800bef <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	ff 73 0c             	pushl  0xc(%ebx)
  800be5:	e8 c0 02 00 00       	call   800eaa <nsipc_close>
  800bea:	89 c2                	mov    %eax,%edx
  800bec:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bef:	89 d0                	mov    %edx,%eax
  800bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf4:	c9                   	leave  
  800bf5:	c3                   	ret    

00800bf6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bfc:	6a 00                	push   $0x0
  800bfe:	ff 75 10             	pushl  0x10(%ebp)
  800c01:	ff 75 0c             	pushl  0xc(%ebp)
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	ff 70 0c             	pushl  0xc(%eax)
  800c0a:	e8 78 03 00 00       	call   800f87 <nsipc_send>
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c17:	6a 00                	push   $0x0
  800c19:	ff 75 10             	pushl  0x10(%ebp)
  800c1c:	ff 75 0c             	pushl  0xc(%ebp)
  800c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c22:	ff 70 0c             	pushl  0xc(%eax)
  800c25:	e8 f1 02 00 00       	call   800f1b <nsipc_recv>
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c32:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c35:	52                   	push   %edx
  800c36:	50                   	push   %eax
  800c37:	e8 d3 f7 ff ff       	call   80040f <fd_lookup>
  800c3c:	83 c4 10             	add    $0x10,%esp
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	78 17                	js     800c5a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c46:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c4c:	39 08                	cmp    %ecx,(%eax)
  800c4e:	75 05                	jne    800c55 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c50:	8b 40 0c             	mov    0xc(%eax),%eax
  800c53:	eb 05                	jmp    800c5a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c55:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 1c             	sub    $0x1c,%esp
  800c64:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c69:	50                   	push   %eax
  800c6a:	e8 51 f7 ff ff       	call   8003c0 <fd_alloc>
  800c6f:	89 c3                	mov    %eax,%ebx
  800c71:	83 c4 10             	add    $0x10,%esp
  800c74:	85 c0                	test   %eax,%eax
  800c76:	78 1b                	js     800c93 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c78:	83 ec 04             	sub    $0x4,%esp
  800c7b:	68 07 04 00 00       	push   $0x407
  800c80:	ff 75 f4             	pushl  -0xc(%ebp)
  800c83:	6a 00                	push   $0x0
  800c85:	e8 de f4 ff ff       	call   800168 <sys_page_alloc>
  800c8a:	89 c3                	mov    %eax,%ebx
  800c8c:	83 c4 10             	add    $0x10,%esp
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	79 10                	jns    800ca3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	56                   	push   %esi
  800c97:	e8 0e 02 00 00       	call   800eaa <nsipc_close>
		return r;
  800c9c:	83 c4 10             	add    $0x10,%esp
  800c9f:	89 d8                	mov    %ebx,%eax
  800ca1:	eb 24                	jmp    800cc7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cac:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	e8 d5 f6 ff ff       	call   800399 <fd2num>
  800cc4:	83 c4 10             	add    $0x10,%esp
}
  800cc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	e8 50 ff ff ff       	call   800c2c <fd2sockid>
		return r;
  800cdc:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	78 1f                	js     800d01 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce2:	83 ec 04             	sub    $0x4,%esp
  800ce5:	ff 75 10             	pushl  0x10(%ebp)
  800ce8:	ff 75 0c             	pushl  0xc(%ebp)
  800ceb:	50                   	push   %eax
  800cec:	e8 12 01 00 00       	call   800e03 <nsipc_accept>
  800cf1:	83 c4 10             	add    $0x10,%esp
		return r;
  800cf4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	78 07                	js     800d01 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cfa:	e8 5d ff ff ff       	call   800c5c <alloc_sockfd>
  800cff:	89 c1                	mov    %eax,%ecx
}
  800d01:	89 c8                	mov    %ecx,%eax
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	e8 19 ff ff ff       	call   800c2c <fd2sockid>
  800d13:	85 c0                	test   %eax,%eax
  800d15:	78 12                	js     800d29 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d17:	83 ec 04             	sub    $0x4,%esp
  800d1a:	ff 75 10             	pushl  0x10(%ebp)
  800d1d:	ff 75 0c             	pushl  0xc(%ebp)
  800d20:	50                   	push   %eax
  800d21:	e8 2d 01 00 00       	call   800e53 <nsipc_bind>
  800d26:	83 c4 10             	add    $0x10,%esp
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <shutdown>:

int
shutdown(int s, int how)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	e8 f3 fe ff ff       	call   800c2c <fd2sockid>
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	78 0f                	js     800d4c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d3d:	83 ec 08             	sub    $0x8,%esp
  800d40:	ff 75 0c             	pushl  0xc(%ebp)
  800d43:	50                   	push   %eax
  800d44:	e8 3f 01 00 00       	call   800e88 <nsipc_shutdown>
  800d49:	83 c4 10             	add    $0x10,%esp
}
  800d4c:	c9                   	leave  
  800d4d:	c3                   	ret    

00800d4e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	e8 d0 fe ff ff       	call   800c2c <fd2sockid>
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	78 12                	js     800d72 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	ff 75 10             	pushl  0x10(%ebp)
  800d66:	ff 75 0c             	pushl  0xc(%ebp)
  800d69:	50                   	push   %eax
  800d6a:	e8 55 01 00 00       	call   800ec4 <nsipc_connect>
  800d6f:	83 c4 10             	add    $0x10,%esp
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <listen>:

int
listen(int s, int backlog)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	e8 aa fe ff ff       	call   800c2c <fd2sockid>
  800d82:	85 c0                	test   %eax,%eax
  800d84:	78 0f                	js     800d95 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d86:	83 ec 08             	sub    $0x8,%esp
  800d89:	ff 75 0c             	pushl  0xc(%ebp)
  800d8c:	50                   	push   %eax
  800d8d:	e8 67 01 00 00       	call   800ef9 <nsipc_listen>
  800d92:	83 c4 10             	add    $0x10,%esp
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d9d:	ff 75 10             	pushl  0x10(%ebp)
  800da0:	ff 75 0c             	pushl  0xc(%ebp)
  800da3:	ff 75 08             	pushl  0x8(%ebp)
  800da6:	e8 3a 02 00 00       	call   800fe5 <nsipc_socket>
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	85 c0                	test   %eax,%eax
  800db0:	78 05                	js     800db7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800db2:	e8 a5 fe ff ff       	call   800c5c <alloc_sockfd>
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 04             	sub    $0x4,%esp
  800dc0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dc2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc9:	75 12                	jne    800ddd <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	6a 02                	push   $0x2
  800dd0:	e8 7f 11 00 00       	call   801f54 <ipc_find_env>
  800dd5:	a3 04 40 80 00       	mov    %eax,0x804004
  800dda:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800ddd:	6a 07                	push   $0x7
  800ddf:	68 00 60 80 00       	push   $0x806000
  800de4:	53                   	push   %ebx
  800de5:	ff 35 04 40 80 00    	pushl  0x804004
  800deb:	e8 10 11 00 00       	call   801f00 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800df0:	83 c4 0c             	add    $0xc,%esp
  800df3:	6a 00                	push   $0x0
  800df5:	6a 00                	push   $0x0
  800df7:	6a 00                	push   $0x0
  800df9:	e8 95 10 00 00       	call   801e93 <ipc_recv>
}
  800dfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e13:	8b 06                	mov    (%esi),%eax
  800e15:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1f:	e8 95 ff ff ff       	call   800db9 <nsipc>
  800e24:	89 c3                	mov    %eax,%ebx
  800e26:	85 c0                	test   %eax,%eax
  800e28:	78 20                	js     800e4a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	ff 35 10 60 80 00    	pushl  0x806010
  800e33:	68 00 60 80 00       	push   $0x806000
  800e38:	ff 75 0c             	pushl  0xc(%ebp)
  800e3b:	e8 9e 0e 00 00       	call   801cde <memmove>
		*addrlen = ret->ret_addrlen;
  800e40:	a1 10 60 80 00       	mov    0x806010,%eax
  800e45:	89 06                	mov    %eax,(%esi)
  800e47:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e4a:	89 d8                	mov    %ebx,%eax
  800e4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e65:	53                   	push   %ebx
  800e66:	ff 75 0c             	pushl  0xc(%ebp)
  800e69:	68 04 60 80 00       	push   $0x806004
  800e6e:	e8 6b 0e 00 00       	call   801cde <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e73:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e79:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7e:	e8 36 ff ff ff       	call   800db9 <nsipc>
}
  800e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e99:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e9e:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea3:	e8 11 ff ff ff       	call   800db9 <nsipc>
}
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <nsipc_close>:

int
nsipc_close(int s)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb8:	b8 04 00 00 00       	mov    $0x4,%eax
  800ebd:	e8 f7 fe ff ff       	call   800db9 <nsipc>
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 08             	sub    $0x8,%esp
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed6:	53                   	push   %ebx
  800ed7:	ff 75 0c             	pushl  0xc(%ebp)
  800eda:	68 04 60 80 00       	push   $0x806004
  800edf:	e8 fa 0d 00 00       	call   801cde <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eea:	b8 05 00 00 00       	mov    $0x5,%eax
  800eef:	e8 c5 fe ff ff       	call   800db9 <nsipc>
}
  800ef4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef7:	c9                   	leave  
  800ef8:	c3                   	ret    

00800ef9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f0f:	b8 06 00 00 00       	mov    $0x6,%eax
  800f14:	e8 a0 fe ff ff       	call   800db9 <nsipc>
}
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f2b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f31:	8b 45 14             	mov    0x14(%ebp),%eax
  800f34:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f39:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3e:	e8 76 fe ff ff       	call   800db9 <nsipc>
  800f43:	89 c3                	mov    %eax,%ebx
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 35                	js     800f7e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f49:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f4e:	7f 04                	jg     800f54 <nsipc_recv+0x39>
  800f50:	39 c6                	cmp    %eax,%esi
  800f52:	7d 16                	jge    800f6a <nsipc_recv+0x4f>
  800f54:	68 67 23 80 00       	push   $0x802367
  800f59:	68 2f 23 80 00       	push   $0x80232f
  800f5e:	6a 62                	push   $0x62
  800f60:	68 7c 23 80 00       	push   $0x80237c
  800f65:	e8 84 05 00 00       	call   8014ee <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f6a:	83 ec 04             	sub    $0x4,%esp
  800f6d:	50                   	push   %eax
  800f6e:	68 00 60 80 00       	push   $0x806000
  800f73:	ff 75 0c             	pushl  0xc(%ebp)
  800f76:	e8 63 0d 00 00       	call   801cde <memmove>
  800f7b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f7e:	89 d8                	mov    %ebx,%eax
  800f80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	53                   	push   %ebx
  800f8b:	83 ec 04             	sub    $0x4,%esp
  800f8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f99:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9f:	7e 16                	jle    800fb7 <nsipc_send+0x30>
  800fa1:	68 88 23 80 00       	push   $0x802388
  800fa6:	68 2f 23 80 00       	push   $0x80232f
  800fab:	6a 6d                	push   $0x6d
  800fad:	68 7c 23 80 00       	push   $0x80237c
  800fb2:	e8 37 05 00 00       	call   8014ee <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	53                   	push   %ebx
  800fbb:	ff 75 0c             	pushl  0xc(%ebp)
  800fbe:	68 0c 60 80 00       	push   $0x80600c
  800fc3:	e8 16 0d 00 00       	call   801cde <memmove>
	nsipcbuf.send.req_size = size;
  800fc8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fce:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd6:	b8 08 00 00 00       	mov    $0x8,%eax
  800fdb:	e8 d9 fd ff ff       	call   800db9 <nsipc>
}
  800fe0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800feb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ffb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801003:	b8 09 00 00 00       	mov    $0x9,%eax
  801008:	e8 ac fd ff ff       	call   800db9 <nsipc>
}
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    

0080100f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	ff 75 08             	pushl  0x8(%ebp)
  80101d:	e8 87 f3 ff ff       	call   8003a9 <fd2data>
  801022:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801024:	83 c4 08             	add    $0x8,%esp
  801027:	68 94 23 80 00       	push   $0x802394
  80102c:	53                   	push   %ebx
  80102d:	e8 1a 0b 00 00       	call   801b4c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801032:	8b 46 04             	mov    0x4(%esi),%eax
  801035:	2b 06                	sub    (%esi),%eax
  801037:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801044:	00 00 00 
	stat->st_dev = &devpipe;
  801047:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80104e:	30 80 00 
	return 0;
}
  801051:	b8 00 00 00 00       	mov    $0x0,%eax
  801056:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801059:	5b                   	pop    %ebx
  80105a:	5e                   	pop    %esi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	53                   	push   %ebx
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801067:	53                   	push   %ebx
  801068:	6a 00                	push   $0x0
  80106a:	e8 7e f1 ff ff       	call   8001ed <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106f:	89 1c 24             	mov    %ebx,(%esp)
  801072:	e8 32 f3 ff ff       	call   8003a9 <fd2data>
  801077:	83 c4 08             	add    $0x8,%esp
  80107a:	50                   	push   %eax
  80107b:	6a 00                	push   $0x0
  80107d:	e8 6b f1 ff ff       	call   8001ed <sys_page_unmap>
}
  801082:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	57                   	push   %edi
  80108b:	56                   	push   %esi
  80108c:	53                   	push   %ebx
  80108d:	83 ec 1c             	sub    $0x1c,%esp
  801090:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801093:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801095:	a1 08 40 80 00       	mov    0x804008,%eax
  80109a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a3:	e8 e5 0e 00 00       	call   801f8d <pageref>
  8010a8:	89 c3                	mov    %eax,%ebx
  8010aa:	89 3c 24             	mov    %edi,(%esp)
  8010ad:	e8 db 0e 00 00       	call   801f8d <pageref>
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	39 c3                	cmp    %eax,%ebx
  8010b7:	0f 94 c1             	sete   %cl
  8010ba:	0f b6 c9             	movzbl %cl,%ecx
  8010bd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010c0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c9:	39 ce                	cmp    %ecx,%esi
  8010cb:	74 1b                	je     8010e8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010cd:	39 c3                	cmp    %eax,%ebx
  8010cf:	75 c4                	jne    801095 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010d1:	8b 42 58             	mov    0x58(%edx),%eax
  8010d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d7:	50                   	push   %eax
  8010d8:	56                   	push   %esi
  8010d9:	68 9b 23 80 00       	push   $0x80239b
  8010de:	e8 e4 04 00 00       	call   8015c7 <cprintf>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	eb ad                	jmp    801095 <_pipeisclosed+0xe>
	}
}
  8010e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5f                   	pop    %edi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 28             	sub    $0x28,%esp
  8010fc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010ff:	56                   	push   %esi
  801100:	e8 a4 f2 ff ff       	call   8003a9 <fd2data>
  801105:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	bf 00 00 00 00       	mov    $0x0,%edi
  80110f:	eb 4b                	jmp    80115c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801111:	89 da                	mov    %ebx,%edx
  801113:	89 f0                	mov    %esi,%eax
  801115:	e8 6d ff ff ff       	call   801087 <_pipeisclosed>
  80111a:	85 c0                	test   %eax,%eax
  80111c:	75 48                	jne    801166 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80111e:	e8 26 f0 ff ff       	call   800149 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801123:	8b 43 04             	mov    0x4(%ebx),%eax
  801126:	8b 0b                	mov    (%ebx),%ecx
  801128:	8d 51 20             	lea    0x20(%ecx),%edx
  80112b:	39 d0                	cmp    %edx,%eax
  80112d:	73 e2                	jae    801111 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80112f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801132:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801136:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801139:	89 c2                	mov    %eax,%edx
  80113b:	c1 fa 1f             	sar    $0x1f,%edx
  80113e:	89 d1                	mov    %edx,%ecx
  801140:	c1 e9 1b             	shr    $0x1b,%ecx
  801143:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801146:	83 e2 1f             	and    $0x1f,%edx
  801149:	29 ca                	sub    %ecx,%edx
  80114b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80114f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801153:	83 c0 01             	add    $0x1,%eax
  801156:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801159:	83 c7 01             	add    $0x1,%edi
  80115c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80115f:	75 c2                	jne    801123 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801161:	8b 45 10             	mov    0x10(%ebp),%eax
  801164:	eb 05                	jmp    80116b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 18             	sub    $0x18,%esp
  80117c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80117f:	57                   	push   %edi
  801180:	e8 24 f2 ff ff       	call   8003a9 <fd2data>
  801185:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118f:	eb 3d                	jmp    8011ce <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801191:	85 db                	test   %ebx,%ebx
  801193:	74 04                	je     801199 <devpipe_read+0x26>
				return i;
  801195:	89 d8                	mov    %ebx,%eax
  801197:	eb 44                	jmp    8011dd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801199:	89 f2                	mov    %esi,%edx
  80119b:	89 f8                	mov    %edi,%eax
  80119d:	e8 e5 fe ff ff       	call   801087 <_pipeisclosed>
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	75 32                	jne    8011d8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a6:	e8 9e ef ff ff       	call   800149 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011ab:	8b 06                	mov    (%esi),%eax
  8011ad:	3b 46 04             	cmp    0x4(%esi),%eax
  8011b0:	74 df                	je     801191 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b2:	99                   	cltd   
  8011b3:	c1 ea 1b             	shr    $0x1b,%edx
  8011b6:	01 d0                	add    %edx,%eax
  8011b8:	83 e0 1f             	and    $0x1f,%eax
  8011bb:	29 d0                	sub    %edx,%eax
  8011bd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011cb:	83 c3 01             	add    $0x1,%ebx
  8011ce:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011d1:	75 d8                	jne    8011ab <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d6:	eb 05                	jmp    8011dd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	56                   	push   %esi
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	e8 ca f1 ff ff       	call   8003c0 <fd_alloc>
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	0f 88 2c 01 00 00    	js     80132f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801203:	83 ec 04             	sub    $0x4,%esp
  801206:	68 07 04 00 00       	push   $0x407
  80120b:	ff 75 f4             	pushl  -0xc(%ebp)
  80120e:	6a 00                	push   $0x0
  801210:	e8 53 ef ff ff       	call   800168 <sys_page_alloc>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	89 c2                	mov    %eax,%edx
  80121a:	85 c0                	test   %eax,%eax
  80121c:	0f 88 0d 01 00 00    	js     80132f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801222:	83 ec 0c             	sub    $0xc,%esp
  801225:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	e8 92 f1 ff ff       	call   8003c0 <fd_alloc>
  80122e:	89 c3                	mov    %eax,%ebx
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	0f 88 e2 00 00 00    	js     80131d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	68 07 04 00 00       	push   $0x407
  801243:	ff 75 f0             	pushl  -0x10(%ebp)
  801246:	6a 00                	push   $0x0
  801248:	e8 1b ef ff ff       	call   800168 <sys_page_alloc>
  80124d:	89 c3                	mov    %eax,%ebx
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	85 c0                	test   %eax,%eax
  801254:	0f 88 c3 00 00 00    	js     80131d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80125a:	83 ec 0c             	sub    $0xc,%esp
  80125d:	ff 75 f4             	pushl  -0xc(%ebp)
  801260:	e8 44 f1 ff ff       	call   8003a9 <fd2data>
  801265:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801267:	83 c4 0c             	add    $0xc,%esp
  80126a:	68 07 04 00 00       	push   $0x407
  80126f:	50                   	push   %eax
  801270:	6a 00                	push   $0x0
  801272:	e8 f1 ee ff ff       	call   800168 <sys_page_alloc>
  801277:	89 c3                	mov    %eax,%ebx
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	85 c0                	test   %eax,%eax
  80127e:	0f 88 89 00 00 00    	js     80130d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	ff 75 f0             	pushl  -0x10(%ebp)
  80128a:	e8 1a f1 ff ff       	call   8003a9 <fd2data>
  80128f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801296:	50                   	push   %eax
  801297:	6a 00                	push   $0x0
  801299:	56                   	push   %esi
  80129a:	6a 00                	push   $0x0
  80129c:	e8 0a ef ff ff       	call   8001ab <sys_page_map>
  8012a1:	89 c3                	mov    %eax,%ebx
  8012a3:	83 c4 20             	add    $0x20,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 55                	js     8012ff <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012aa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012bf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012d4:	83 ec 0c             	sub    $0xc,%esp
  8012d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012da:	e8 ba f0 ff ff       	call   800399 <fd2num>
  8012df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e4:	83 c4 04             	add    $0x4,%esp
  8012e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ea:	e8 aa f0 ff ff       	call   800399 <fd2num>
  8012ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fd:	eb 30                	jmp    80132f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	56                   	push   %esi
  801303:	6a 00                	push   $0x0
  801305:	e8 e3 ee ff ff       	call   8001ed <sys_page_unmap>
  80130a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	ff 75 f0             	pushl  -0x10(%ebp)
  801313:	6a 00                	push   $0x0
  801315:	e8 d3 ee ff ff       	call   8001ed <sys_page_unmap>
  80131a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	ff 75 f4             	pushl  -0xc(%ebp)
  801323:	6a 00                	push   $0x0
  801325:	e8 c3 ee ff ff       	call   8001ed <sys_page_unmap>
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80132f:	89 d0                	mov    %edx,%eax
  801331:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	ff 75 08             	pushl  0x8(%ebp)
  801345:	e8 c5 f0 ff ff       	call   80040f <fd_lookup>
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 18                	js     801369 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	ff 75 f4             	pushl  -0xc(%ebp)
  801357:	e8 4d f0 ff ff       	call   8003a9 <fd2data>
	return _pipeisclosed(fd, p);
  80135c:	89 c2                	mov    %eax,%edx
  80135e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801361:	e8 21 fd ff ff       	call   801087 <_pipeisclosed>
  801366:	83 c4 10             	add    $0x10,%esp
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80137b:	68 b3 23 80 00       	push   $0x8023b3
  801380:	ff 75 0c             	pushl  0xc(%ebp)
  801383:	e8 c4 07 00 00       	call   801b4c <strcpy>
	return 0;
}
  801388:	b8 00 00 00 00       	mov    $0x0,%eax
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	57                   	push   %edi
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
  801395:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a6:	eb 2d                	jmp    8013d5 <devcons_write+0x46>
		m = n - tot;
  8013a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ab:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013ad:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013b0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013b5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	03 45 0c             	add    0xc(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	57                   	push   %edi
  8013c1:	e8 18 09 00 00       	call   801cde <memmove>
		sys_cputs(buf, m);
  8013c6:	83 c4 08             	add    $0x8,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	57                   	push   %edi
  8013cb:	e8 dc ec ff ff       	call   8000ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d0:	01 de                	add    %ebx,%esi
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013da:	72 cc                	jb     8013a8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5e                   	pop    %esi
  8013e1:	5f                   	pop    %edi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f3:	74 2a                	je     80141f <devcons_read+0x3b>
  8013f5:	eb 05                	jmp    8013fc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f7:	e8 4d ed ff ff       	call   800149 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013fc:	e8 c9 ec ff ff       	call   8000ca <sys_cgetc>
  801401:	85 c0                	test   %eax,%eax
  801403:	74 f2                	je     8013f7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801405:	85 c0                	test   %eax,%eax
  801407:	78 16                	js     80141f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801409:	83 f8 04             	cmp    $0x4,%eax
  80140c:	74 0c                	je     80141a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80140e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801411:	88 02                	mov    %al,(%edx)
	return 1;
  801413:	b8 01 00 00 00       	mov    $0x1,%eax
  801418:	eb 05                	jmp    80141f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80142d:	6a 01                	push   $0x1
  80142f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	e8 74 ec ff ff       	call   8000ac <sys_cputs>
}
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <getchar>:

int
getchar(void)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801443:	6a 01                	push   $0x1
  801445:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	6a 00                	push   $0x0
  80144b:	e8 25 f2 ff ff       	call   800675 <read>
	if (r < 0)
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 0f                	js     801466 <getchar+0x29>
		return r;
	if (r < 1)
  801457:	85 c0                	test   %eax,%eax
  801459:	7e 06                	jle    801461 <getchar+0x24>
		return -E_EOF;
	return c;
  80145b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80145f:	eb 05                	jmp    801466 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801461:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	ff 75 08             	pushl  0x8(%ebp)
  801475:	e8 95 ef ff ff       	call   80040f <fd_lookup>
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 11                	js     801492 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801481:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801484:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80148a:	39 10                	cmp    %edx,(%eax)
  80148c:	0f 94 c0             	sete   %al
  80148f:	0f b6 c0             	movzbl %al,%eax
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <opencons>:

int
opencons(void)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80149a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	e8 1d ef ff ff       	call   8003c0 <fd_alloc>
  8014a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 3e                	js     8014ea <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ac:	83 ec 04             	sub    $0x4,%esp
  8014af:	68 07 04 00 00       	push   $0x407
  8014b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b7:	6a 00                	push   $0x0
  8014b9:	e8 aa ec ff ff       	call   800168 <sys_page_alloc>
  8014be:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 23                	js     8014ea <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014dc:	83 ec 0c             	sub    $0xc,%esp
  8014df:	50                   	push   %eax
  8014e0:	e8 b4 ee ff ff       	call   800399 <fd2num>
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	83 c4 10             	add    $0x10,%esp
}
  8014ea:	89 d0                	mov    %edx,%eax
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	56                   	push   %esi
  8014f2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014fc:	e8 29 ec ff ff       	call   80012a <sys_getenvid>
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	ff 75 0c             	pushl  0xc(%ebp)
  801507:	ff 75 08             	pushl  0x8(%ebp)
  80150a:	56                   	push   %esi
  80150b:	50                   	push   %eax
  80150c:	68 c0 23 80 00       	push   $0x8023c0
  801511:	e8 b1 00 00 00       	call   8015c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801516:	83 c4 18             	add    $0x18,%esp
  801519:	53                   	push   %ebx
  80151a:	ff 75 10             	pushl  0x10(%ebp)
  80151d:	e8 54 00 00 00       	call   801576 <vcprintf>
	cprintf("\n");
  801522:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801529:	e8 99 00 00 00       	call   8015c7 <cprintf>
  80152e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801531:	cc                   	int3   
  801532:	eb fd                	jmp    801531 <_panic+0x43>

00801534 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80153e:	8b 13                	mov    (%ebx),%edx
  801540:	8d 42 01             	lea    0x1(%edx),%eax
  801543:	89 03                	mov    %eax,(%ebx)
  801545:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801548:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80154c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801551:	75 1a                	jne    80156d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801553:	83 ec 08             	sub    $0x8,%esp
  801556:	68 ff 00 00 00       	push   $0xff
  80155b:	8d 43 08             	lea    0x8(%ebx),%eax
  80155e:	50                   	push   %eax
  80155f:	e8 48 eb ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  801564:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80156a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80156d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80157f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801586:	00 00 00 
	b.cnt = 0;
  801589:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801590:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801593:	ff 75 0c             	pushl  0xc(%ebp)
  801596:	ff 75 08             	pushl  0x8(%ebp)
  801599:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	68 34 15 80 00       	push   $0x801534
  8015a5:	e8 54 01 00 00       	call   8016fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	e8 ed ea ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8015bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015d0:	50                   	push   %eax
  8015d1:	ff 75 08             	pushl  0x8(%ebp)
  8015d4:	e8 9d ff ff ff       	call   801576 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	57                   	push   %edi
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 1c             	sub    $0x1c,%esp
  8015e4:	89 c7                	mov    %eax,%edi
  8015e6:	89 d6                	mov    %edx,%esi
  8015e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801602:	39 d3                	cmp    %edx,%ebx
  801604:	72 05                	jb     80160b <printnum+0x30>
  801606:	39 45 10             	cmp    %eax,0x10(%ebp)
  801609:	77 45                	ja     801650 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	ff 75 18             	pushl  0x18(%ebp)
  801611:	8b 45 14             	mov    0x14(%ebp),%eax
  801614:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801617:	53                   	push   %ebx
  801618:	ff 75 10             	pushl  0x10(%ebp)
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801621:	ff 75 e0             	pushl  -0x20(%ebp)
  801624:	ff 75 dc             	pushl  -0x24(%ebp)
  801627:	ff 75 d8             	pushl  -0x28(%ebp)
  80162a:	e8 a1 09 00 00       	call   801fd0 <__udivdi3>
  80162f:	83 c4 18             	add    $0x18,%esp
  801632:	52                   	push   %edx
  801633:	50                   	push   %eax
  801634:	89 f2                	mov    %esi,%edx
  801636:	89 f8                	mov    %edi,%eax
  801638:	e8 9e ff ff ff       	call   8015db <printnum>
  80163d:	83 c4 20             	add    $0x20,%esp
  801640:	eb 18                	jmp    80165a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	56                   	push   %esi
  801646:	ff 75 18             	pushl  0x18(%ebp)
  801649:	ff d7                	call   *%edi
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	eb 03                	jmp    801653 <printnum+0x78>
  801650:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801653:	83 eb 01             	sub    $0x1,%ebx
  801656:	85 db                	test   %ebx,%ebx
  801658:	7f e8                	jg     801642 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	56                   	push   %esi
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	ff 75 e4             	pushl  -0x1c(%ebp)
  801664:	ff 75 e0             	pushl  -0x20(%ebp)
  801667:	ff 75 dc             	pushl  -0x24(%ebp)
  80166a:	ff 75 d8             	pushl  -0x28(%ebp)
  80166d:	e8 8e 0a 00 00       	call   802100 <__umoddi3>
  801672:	83 c4 14             	add    $0x14,%esp
  801675:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  80167c:	50                   	push   %eax
  80167d:	ff d7                	call   *%edi
}
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80168d:	83 fa 01             	cmp    $0x1,%edx
  801690:	7e 0e                	jle    8016a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801692:	8b 10                	mov    (%eax),%edx
  801694:	8d 4a 08             	lea    0x8(%edx),%ecx
  801697:	89 08                	mov    %ecx,(%eax)
  801699:	8b 02                	mov    (%edx),%eax
  80169b:	8b 52 04             	mov    0x4(%edx),%edx
  80169e:	eb 22                	jmp    8016c2 <getuint+0x38>
	else if (lflag)
  8016a0:	85 d2                	test   %edx,%edx
  8016a2:	74 10                	je     8016b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016a4:	8b 10                	mov    (%eax),%edx
  8016a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a9:	89 08                	mov    %ecx,(%eax)
  8016ab:	8b 02                	mov    (%edx),%eax
  8016ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b2:	eb 0e                	jmp    8016c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016b4:	8b 10                	mov    (%eax),%edx
  8016b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b9:	89 08                	mov    %ecx,(%eax)
  8016bb:	8b 02                	mov    (%edx),%eax
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016ca:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016ce:	8b 10                	mov    (%eax),%edx
  8016d0:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d3:	73 0a                	jae    8016df <sprintputch+0x1b>
		*b->buf++ = ch;
  8016d5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d8:	89 08                	mov    %ecx,(%eax)
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	88 02                	mov    %al,(%edx)
}
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ea:	50                   	push   %eax
  8016eb:	ff 75 10             	pushl  0x10(%ebp)
  8016ee:	ff 75 0c             	pushl  0xc(%ebp)
  8016f1:	ff 75 08             	pushl  0x8(%ebp)
  8016f4:	e8 05 00 00 00       	call   8016fe <vprintfmt>
	va_end(ap);
}
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	83 ec 2c             	sub    $0x2c,%esp
  801707:	8b 75 08             	mov    0x8(%ebp),%esi
  80170a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801710:	eb 12                	jmp    801724 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801712:	85 c0                	test   %eax,%eax
  801714:	0f 84 89 03 00 00    	je     801aa3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	53                   	push   %ebx
  80171e:	50                   	push   %eax
  80171f:	ff d6                	call   *%esi
  801721:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801724:	83 c7 01             	add    $0x1,%edi
  801727:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80172b:	83 f8 25             	cmp    $0x25,%eax
  80172e:	75 e2                	jne    801712 <vprintfmt+0x14>
  801730:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801734:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80173b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801742:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	eb 07                	jmp    801757 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801750:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801753:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801757:	8d 47 01             	lea    0x1(%edi),%eax
  80175a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80175d:	0f b6 07             	movzbl (%edi),%eax
  801760:	0f b6 c8             	movzbl %al,%ecx
  801763:	83 e8 23             	sub    $0x23,%eax
  801766:	3c 55                	cmp    $0x55,%al
  801768:	0f 87 1a 03 00 00    	ja     801a88 <vprintfmt+0x38a>
  80176e:	0f b6 c0             	movzbl %al,%eax
  801771:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80177b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80177f:	eb d6                	jmp    801757 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
  801789:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80178c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80178f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801793:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801796:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801799:	83 fa 09             	cmp    $0x9,%edx
  80179c:	77 39                	ja     8017d7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80179e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017a1:	eb e9                	jmp    80178c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017ac:	8b 00                	mov    (%eax),%eax
  8017ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017b4:	eb 27                	jmp    8017dd <vprintfmt+0xdf>
  8017b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c0:	0f 49 c8             	cmovns %eax,%ecx
  8017c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c9:	eb 8c                	jmp    801757 <vprintfmt+0x59>
  8017cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017d5:	eb 80                	jmp    801757 <vprintfmt+0x59>
  8017d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017da:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e1:	0f 89 70 ff ff ff    	jns    801757 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f4:	e9 5e ff ff ff       	jmp    801757 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017ff:	e9 53 ff ff ff       	jmp    801757 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801804:	8b 45 14             	mov    0x14(%ebp),%eax
  801807:	8d 50 04             	lea    0x4(%eax),%edx
  80180a:	89 55 14             	mov    %edx,0x14(%ebp)
  80180d:	83 ec 08             	sub    $0x8,%esp
  801810:	53                   	push   %ebx
  801811:	ff 30                	pushl  (%eax)
  801813:	ff d6                	call   *%esi
			break;
  801815:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80181b:	e9 04 ff ff ff       	jmp    801724 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801820:	8b 45 14             	mov    0x14(%ebp),%eax
  801823:	8d 50 04             	lea    0x4(%eax),%edx
  801826:	89 55 14             	mov    %edx,0x14(%ebp)
  801829:	8b 00                	mov    (%eax),%eax
  80182b:	99                   	cltd   
  80182c:	31 d0                	xor    %edx,%eax
  80182e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801830:	83 f8 0f             	cmp    $0xf,%eax
  801833:	7f 0b                	jg     801840 <vprintfmt+0x142>
  801835:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80183c:	85 d2                	test   %edx,%edx
  80183e:	75 18                	jne    801858 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801840:	50                   	push   %eax
  801841:	68 fb 23 80 00       	push   $0x8023fb
  801846:	53                   	push   %ebx
  801847:	56                   	push   %esi
  801848:	e8 94 fe ff ff       	call   8016e1 <printfmt>
  80184d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801853:	e9 cc fe ff ff       	jmp    801724 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801858:	52                   	push   %edx
  801859:	68 41 23 80 00       	push   $0x802341
  80185e:	53                   	push   %ebx
  80185f:	56                   	push   %esi
  801860:	e8 7c fe ff ff       	call   8016e1 <printfmt>
  801865:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801868:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186b:	e9 b4 fe ff ff       	jmp    801724 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801870:	8b 45 14             	mov    0x14(%ebp),%eax
  801873:	8d 50 04             	lea    0x4(%eax),%edx
  801876:	89 55 14             	mov    %edx,0x14(%ebp)
  801879:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80187b:	85 ff                	test   %edi,%edi
  80187d:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801882:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801885:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801889:	0f 8e 94 00 00 00    	jle    801923 <vprintfmt+0x225>
  80188f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801893:	0f 84 98 00 00 00    	je     801931 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801899:	83 ec 08             	sub    $0x8,%esp
  80189c:	ff 75 d0             	pushl  -0x30(%ebp)
  80189f:	57                   	push   %edi
  8018a0:	e8 86 02 00 00       	call   801b2b <strnlen>
  8018a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a8:	29 c1                	sub    %eax,%ecx
  8018aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018ad:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018b0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018ba:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018bc:	eb 0f                	jmp    8018cd <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c7:	83 ef 01             	sub    $0x1,%edi
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	85 ff                	test   %edi,%edi
  8018cf:	7f ed                	jg     8018be <vprintfmt+0x1c0>
  8018d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018d4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d7:	85 c9                	test   %ecx,%ecx
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018de:	0f 49 c1             	cmovns %ecx,%eax
  8018e1:	29 c1                	sub    %eax,%ecx
  8018e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ec:	89 cb                	mov    %ecx,%ebx
  8018ee:	eb 4d                	jmp    80193d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018f4:	74 1b                	je     801911 <vprintfmt+0x213>
  8018f6:	0f be c0             	movsbl %al,%eax
  8018f9:	83 e8 20             	sub    $0x20,%eax
  8018fc:	83 f8 5e             	cmp    $0x5e,%eax
  8018ff:	76 10                	jbe    801911 <vprintfmt+0x213>
					putch('?', putdat);
  801901:	83 ec 08             	sub    $0x8,%esp
  801904:	ff 75 0c             	pushl  0xc(%ebp)
  801907:	6a 3f                	push   $0x3f
  801909:	ff 55 08             	call   *0x8(%ebp)
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	eb 0d                	jmp    80191e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	ff 75 0c             	pushl  0xc(%ebp)
  801917:	52                   	push   %edx
  801918:	ff 55 08             	call   *0x8(%ebp)
  80191b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80191e:	83 eb 01             	sub    $0x1,%ebx
  801921:	eb 1a                	jmp    80193d <vprintfmt+0x23f>
  801923:	89 75 08             	mov    %esi,0x8(%ebp)
  801926:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801929:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80192f:	eb 0c                	jmp    80193d <vprintfmt+0x23f>
  801931:	89 75 08             	mov    %esi,0x8(%ebp)
  801934:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801937:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80193a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193d:	83 c7 01             	add    $0x1,%edi
  801940:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801944:	0f be d0             	movsbl %al,%edx
  801947:	85 d2                	test   %edx,%edx
  801949:	74 23                	je     80196e <vprintfmt+0x270>
  80194b:	85 f6                	test   %esi,%esi
  80194d:	78 a1                	js     8018f0 <vprintfmt+0x1f2>
  80194f:	83 ee 01             	sub    $0x1,%esi
  801952:	79 9c                	jns    8018f0 <vprintfmt+0x1f2>
  801954:	89 df                	mov    %ebx,%edi
  801956:	8b 75 08             	mov    0x8(%ebp),%esi
  801959:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195c:	eb 18                	jmp    801976 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	53                   	push   %ebx
  801962:	6a 20                	push   $0x20
  801964:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801966:	83 ef 01             	sub    $0x1,%edi
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	eb 08                	jmp    801976 <vprintfmt+0x278>
  80196e:	89 df                	mov    %ebx,%edi
  801970:	8b 75 08             	mov    0x8(%ebp),%esi
  801973:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801976:	85 ff                	test   %edi,%edi
  801978:	7f e4                	jg     80195e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197d:	e9 a2 fd ff ff       	jmp    801724 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801982:	83 fa 01             	cmp    $0x1,%edx
  801985:	7e 16                	jle    80199d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801987:	8b 45 14             	mov    0x14(%ebp),%eax
  80198a:	8d 50 08             	lea    0x8(%eax),%edx
  80198d:	89 55 14             	mov    %edx,0x14(%ebp)
  801990:	8b 50 04             	mov    0x4(%eax),%edx
  801993:	8b 00                	mov    (%eax),%eax
  801995:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801998:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80199b:	eb 32                	jmp    8019cf <vprintfmt+0x2d1>
	else if (lflag)
  80199d:	85 d2                	test   %edx,%edx
  80199f:	74 18                	je     8019b9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a4:	8d 50 04             	lea    0x4(%eax),%edx
  8019a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8019aa:	8b 00                	mov    (%eax),%eax
  8019ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019af:	89 c1                	mov    %eax,%ecx
  8019b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b7:	eb 16                	jmp    8019cf <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bc:	8d 50 04             	lea    0x4(%eax),%edx
  8019bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c2:	8b 00                	mov    (%eax),%eax
  8019c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c7:	89 c1                	mov    %eax,%ecx
  8019c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8019cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019de:	79 74                	jns    801a54 <vprintfmt+0x356>
				putch('-', putdat);
  8019e0:	83 ec 08             	sub    $0x8,%esp
  8019e3:	53                   	push   %ebx
  8019e4:	6a 2d                	push   $0x2d
  8019e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019ee:	f7 d8                	neg    %eax
  8019f0:	83 d2 00             	adc    $0x0,%edx
  8019f3:	f7 da                	neg    %edx
  8019f5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019fd:	eb 55                	jmp    801a54 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019ff:	8d 45 14             	lea    0x14(%ebp),%eax
  801a02:	e8 83 fc ff ff       	call   80168a <getuint>
			base = 10;
  801a07:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a0c:	eb 46                	jmp    801a54 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a0e:	8d 45 14             	lea    0x14(%ebp),%eax
  801a11:	e8 74 fc ff ff       	call   80168a <getuint>
		        base = 8;
  801a16:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a1b:	eb 37                	jmp    801a54 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a1d:	83 ec 08             	sub    $0x8,%esp
  801a20:	53                   	push   %ebx
  801a21:	6a 30                	push   $0x30
  801a23:	ff d6                	call   *%esi
			putch('x', putdat);
  801a25:	83 c4 08             	add    $0x8,%esp
  801a28:	53                   	push   %ebx
  801a29:	6a 78                	push   $0x78
  801a2b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a30:	8d 50 04             	lea    0x4(%eax),%edx
  801a33:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a36:	8b 00                	mov    (%eax),%eax
  801a38:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a3d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a40:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a45:	eb 0d                	jmp    801a54 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a47:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4a:	e8 3b fc ff ff       	call   80168a <getuint>
			base = 16;
  801a4f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a5b:	57                   	push   %edi
  801a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5f:	51                   	push   %ecx
  801a60:	52                   	push   %edx
  801a61:	50                   	push   %eax
  801a62:	89 da                	mov    %ebx,%edx
  801a64:	89 f0                	mov    %esi,%eax
  801a66:	e8 70 fb ff ff       	call   8015db <printnum>
			break;
  801a6b:	83 c4 20             	add    $0x20,%esp
  801a6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a71:	e9 ae fc ff ff       	jmp    801724 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a76:	83 ec 08             	sub    $0x8,%esp
  801a79:	53                   	push   %ebx
  801a7a:	51                   	push   %ecx
  801a7b:	ff d6                	call   *%esi
			break;
  801a7d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a83:	e9 9c fc ff ff       	jmp    801724 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a88:	83 ec 08             	sub    $0x8,%esp
  801a8b:	53                   	push   %ebx
  801a8c:	6a 25                	push   $0x25
  801a8e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	eb 03                	jmp    801a98 <vprintfmt+0x39a>
  801a95:	83 ef 01             	sub    $0x1,%edi
  801a98:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a9c:	75 f7                	jne    801a95 <vprintfmt+0x397>
  801a9e:	e9 81 fc ff ff       	jmp    801724 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	83 ec 18             	sub    $0x18,%esp
  801ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801abe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	74 26                	je     801af2 <vsnprintf+0x47>
  801acc:	85 d2                	test   %edx,%edx
  801ace:	7e 22                	jle    801af2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad0:	ff 75 14             	pushl  0x14(%ebp)
  801ad3:	ff 75 10             	pushl  0x10(%ebp)
  801ad6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad9:	50                   	push   %eax
  801ada:	68 c4 16 80 00       	push   $0x8016c4
  801adf:	e8 1a fc ff ff       	call   8016fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	eb 05                	jmp    801af7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801aff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b02:	50                   	push   %eax
  801b03:	ff 75 10             	pushl  0x10(%ebp)
  801b06:	ff 75 0c             	pushl  0xc(%ebp)
  801b09:	ff 75 08             	pushl  0x8(%ebp)
  801b0c:	e8 9a ff ff ff       	call   801aab <vsnprintf>
	va_end(ap);

	return rc;
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	eb 03                	jmp    801b23 <strlen+0x10>
		n++;
  801b20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b27:	75 f7                	jne    801b20 <strlen+0xd>
		n++;
	return n;
}
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b31:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b34:	ba 00 00 00 00       	mov    $0x0,%edx
  801b39:	eb 03                	jmp    801b3e <strnlen+0x13>
		n++;
  801b3b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3e:	39 c2                	cmp    %eax,%edx
  801b40:	74 08                	je     801b4a <strnlen+0x1f>
  801b42:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b46:	75 f3                	jne    801b3b <strnlen+0x10>
  801b48:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b56:	89 c2                	mov    %eax,%edx
  801b58:	83 c2 01             	add    $0x1,%edx
  801b5b:	83 c1 01             	add    $0x1,%ecx
  801b5e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b62:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b65:	84 db                	test   %bl,%bl
  801b67:	75 ef                	jne    801b58 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b69:	5b                   	pop    %ebx
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	53                   	push   %ebx
  801b70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b73:	53                   	push   %ebx
  801b74:	e8 9a ff ff ff       	call   801b13 <strlen>
  801b79:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b7c:	ff 75 0c             	pushl  0xc(%ebp)
  801b7f:	01 d8                	add    %ebx,%eax
  801b81:	50                   	push   %eax
  801b82:	e8 c5 ff ff ff       	call   801b4c <strcpy>
	return dst;
}
  801b87:	89 d8                	mov    %ebx,%eax
  801b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	8b 75 08             	mov    0x8(%ebp),%esi
  801b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b99:	89 f3                	mov    %esi,%ebx
  801b9b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b9e:	89 f2                	mov    %esi,%edx
  801ba0:	eb 0f                	jmp    801bb1 <strncpy+0x23>
		*dst++ = *src;
  801ba2:	83 c2 01             	add    $0x1,%edx
  801ba5:	0f b6 01             	movzbl (%ecx),%eax
  801ba8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bab:	80 39 01             	cmpb   $0x1,(%ecx)
  801bae:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb1:	39 da                	cmp    %ebx,%edx
  801bb3:	75 ed                	jne    801ba2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb5:	89 f0                	mov    %esi,%eax
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	56                   	push   %esi
  801bbf:	53                   	push   %ebx
  801bc0:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc6:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bcb:	85 d2                	test   %edx,%edx
  801bcd:	74 21                	je     801bf0 <strlcpy+0x35>
  801bcf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd3:	89 f2                	mov    %esi,%edx
  801bd5:	eb 09                	jmp    801be0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd7:	83 c2 01             	add    $0x1,%edx
  801bda:	83 c1 01             	add    $0x1,%ecx
  801bdd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be0:	39 c2                	cmp    %eax,%edx
  801be2:	74 09                	je     801bed <strlcpy+0x32>
  801be4:	0f b6 19             	movzbl (%ecx),%ebx
  801be7:	84 db                	test   %bl,%bl
  801be9:	75 ec                	jne    801bd7 <strlcpy+0x1c>
  801beb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf0:	29 f0                	sub    %esi,%eax
}
  801bf2:	5b                   	pop    %ebx
  801bf3:	5e                   	pop    %esi
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bff:	eb 06                	jmp    801c07 <strcmp+0x11>
		p++, q++;
  801c01:	83 c1 01             	add    $0x1,%ecx
  801c04:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c07:	0f b6 01             	movzbl (%ecx),%eax
  801c0a:	84 c0                	test   %al,%al
  801c0c:	74 04                	je     801c12 <strcmp+0x1c>
  801c0e:	3a 02                	cmp    (%edx),%al
  801c10:	74 ef                	je     801c01 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c12:	0f b6 c0             	movzbl %al,%eax
  801c15:	0f b6 12             	movzbl (%edx),%edx
  801c18:	29 d0                	sub    %edx,%eax
}
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    

00801c1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	53                   	push   %ebx
  801c20:	8b 45 08             	mov    0x8(%ebp),%eax
  801c23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c2b:	eb 06                	jmp    801c33 <strncmp+0x17>
		n--, p++, q++;
  801c2d:	83 c0 01             	add    $0x1,%eax
  801c30:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c33:	39 d8                	cmp    %ebx,%eax
  801c35:	74 15                	je     801c4c <strncmp+0x30>
  801c37:	0f b6 08             	movzbl (%eax),%ecx
  801c3a:	84 c9                	test   %cl,%cl
  801c3c:	74 04                	je     801c42 <strncmp+0x26>
  801c3e:	3a 0a                	cmp    (%edx),%cl
  801c40:	74 eb                	je     801c2d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c42:	0f b6 00             	movzbl (%eax),%eax
  801c45:	0f b6 12             	movzbl (%edx),%edx
  801c48:	29 d0                	sub    %edx,%eax
  801c4a:	eb 05                	jmp    801c51 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c51:	5b                   	pop    %ebx
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    

00801c54 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c5e:	eb 07                	jmp    801c67 <strchr+0x13>
		if (*s == c)
  801c60:	38 ca                	cmp    %cl,%dl
  801c62:	74 0f                	je     801c73 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c64:	83 c0 01             	add    $0x1,%eax
  801c67:	0f b6 10             	movzbl (%eax),%edx
  801c6a:	84 d2                	test   %dl,%dl
  801c6c:	75 f2                	jne    801c60 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c7f:	eb 03                	jmp    801c84 <strfind+0xf>
  801c81:	83 c0 01             	add    $0x1,%eax
  801c84:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c87:	38 ca                	cmp    %cl,%dl
  801c89:	74 04                	je     801c8f <strfind+0x1a>
  801c8b:	84 d2                	test   %dl,%dl
  801c8d:	75 f2                	jne    801c81 <strfind+0xc>
			break;
	return (char *) s;
}
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	57                   	push   %edi
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c9d:	85 c9                	test   %ecx,%ecx
  801c9f:	74 36                	je     801cd7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca7:	75 28                	jne    801cd1 <memset+0x40>
  801ca9:	f6 c1 03             	test   $0x3,%cl
  801cac:	75 23                	jne    801cd1 <memset+0x40>
		c &= 0xFF;
  801cae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb2:	89 d3                	mov    %edx,%ebx
  801cb4:	c1 e3 08             	shl    $0x8,%ebx
  801cb7:	89 d6                	mov    %edx,%esi
  801cb9:	c1 e6 18             	shl    $0x18,%esi
  801cbc:	89 d0                	mov    %edx,%eax
  801cbe:	c1 e0 10             	shl    $0x10,%eax
  801cc1:	09 f0                	or     %esi,%eax
  801cc3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cc5:	89 d8                	mov    %ebx,%eax
  801cc7:	09 d0                	or     %edx,%eax
  801cc9:	c1 e9 02             	shr    $0x2,%ecx
  801ccc:	fc                   	cld    
  801ccd:	f3 ab                	rep stos %eax,%es:(%edi)
  801ccf:	eb 06                	jmp    801cd7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd4:	fc                   	cld    
  801cd5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd7:	89 f8                	mov    %edi,%eax
  801cd9:	5b                   	pop    %ebx
  801cda:	5e                   	pop    %esi
  801cdb:	5f                   	pop    %edi
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cec:	39 c6                	cmp    %eax,%esi
  801cee:	73 35                	jae    801d25 <memmove+0x47>
  801cf0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf3:	39 d0                	cmp    %edx,%eax
  801cf5:	73 2e                	jae    801d25 <memmove+0x47>
		s += n;
		d += n;
  801cf7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cfa:	89 d6                	mov    %edx,%esi
  801cfc:	09 fe                	or     %edi,%esi
  801cfe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d04:	75 13                	jne    801d19 <memmove+0x3b>
  801d06:	f6 c1 03             	test   $0x3,%cl
  801d09:	75 0e                	jne    801d19 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d0b:	83 ef 04             	sub    $0x4,%edi
  801d0e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d11:	c1 e9 02             	shr    $0x2,%ecx
  801d14:	fd                   	std    
  801d15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d17:	eb 09                	jmp    801d22 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d19:	83 ef 01             	sub    $0x1,%edi
  801d1c:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d1f:	fd                   	std    
  801d20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d22:	fc                   	cld    
  801d23:	eb 1d                	jmp    801d42 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d25:	89 f2                	mov    %esi,%edx
  801d27:	09 c2                	or     %eax,%edx
  801d29:	f6 c2 03             	test   $0x3,%dl
  801d2c:	75 0f                	jne    801d3d <memmove+0x5f>
  801d2e:	f6 c1 03             	test   $0x3,%cl
  801d31:	75 0a                	jne    801d3d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d33:	c1 e9 02             	shr    $0x2,%ecx
  801d36:	89 c7                	mov    %eax,%edi
  801d38:	fc                   	cld    
  801d39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3b:	eb 05                	jmp    801d42 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d3d:	89 c7                	mov    %eax,%edi
  801d3f:	fc                   	cld    
  801d40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    

00801d46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d49:	ff 75 10             	pushl  0x10(%ebp)
  801d4c:	ff 75 0c             	pushl  0xc(%ebp)
  801d4f:	ff 75 08             	pushl  0x8(%ebp)
  801d52:	e8 87 ff ff ff       	call   801cde <memmove>
}
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    

00801d59 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d61:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d64:	89 c6                	mov    %eax,%esi
  801d66:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d69:	eb 1a                	jmp    801d85 <memcmp+0x2c>
		if (*s1 != *s2)
  801d6b:	0f b6 08             	movzbl (%eax),%ecx
  801d6e:	0f b6 1a             	movzbl (%edx),%ebx
  801d71:	38 d9                	cmp    %bl,%cl
  801d73:	74 0a                	je     801d7f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d75:	0f b6 c1             	movzbl %cl,%eax
  801d78:	0f b6 db             	movzbl %bl,%ebx
  801d7b:	29 d8                	sub    %ebx,%eax
  801d7d:	eb 0f                	jmp    801d8e <memcmp+0x35>
		s1++, s2++;
  801d7f:	83 c0 01             	add    $0x1,%eax
  801d82:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d85:	39 f0                	cmp    %esi,%eax
  801d87:	75 e2                	jne    801d6b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	53                   	push   %ebx
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d99:	89 c1                	mov    %eax,%ecx
  801d9b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da2:	eb 0a                	jmp    801dae <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da4:	0f b6 10             	movzbl (%eax),%edx
  801da7:	39 da                	cmp    %ebx,%edx
  801da9:	74 07                	je     801db2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dab:	83 c0 01             	add    $0x1,%eax
  801dae:	39 c8                	cmp    %ecx,%eax
  801db0:	72 f2                	jb     801da4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db2:	5b                   	pop    %ebx
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	57                   	push   %edi
  801db9:	56                   	push   %esi
  801dba:	53                   	push   %ebx
  801dbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc1:	eb 03                	jmp    801dc6 <strtol+0x11>
		s++;
  801dc3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc6:	0f b6 01             	movzbl (%ecx),%eax
  801dc9:	3c 20                	cmp    $0x20,%al
  801dcb:	74 f6                	je     801dc3 <strtol+0xe>
  801dcd:	3c 09                	cmp    $0x9,%al
  801dcf:	74 f2                	je     801dc3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd1:	3c 2b                	cmp    $0x2b,%al
  801dd3:	75 0a                	jne    801ddf <strtol+0x2a>
		s++;
  801dd5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd8:	bf 00 00 00 00       	mov    $0x0,%edi
  801ddd:	eb 11                	jmp    801df0 <strtol+0x3b>
  801ddf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de4:	3c 2d                	cmp    $0x2d,%al
  801de6:	75 08                	jne    801df0 <strtol+0x3b>
		s++, neg = 1;
  801de8:	83 c1 01             	add    $0x1,%ecx
  801deb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df6:	75 15                	jne    801e0d <strtol+0x58>
  801df8:	80 39 30             	cmpb   $0x30,(%ecx)
  801dfb:	75 10                	jne    801e0d <strtol+0x58>
  801dfd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e01:	75 7c                	jne    801e7f <strtol+0xca>
		s += 2, base = 16;
  801e03:	83 c1 02             	add    $0x2,%ecx
  801e06:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e0b:	eb 16                	jmp    801e23 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e0d:	85 db                	test   %ebx,%ebx
  801e0f:	75 12                	jne    801e23 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e11:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e16:	80 39 30             	cmpb   $0x30,(%ecx)
  801e19:	75 08                	jne    801e23 <strtol+0x6e>
		s++, base = 8;
  801e1b:	83 c1 01             	add    $0x1,%ecx
  801e1e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e23:	b8 00 00 00 00       	mov    $0x0,%eax
  801e28:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e2b:	0f b6 11             	movzbl (%ecx),%edx
  801e2e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e31:	89 f3                	mov    %esi,%ebx
  801e33:	80 fb 09             	cmp    $0x9,%bl
  801e36:	77 08                	ja     801e40 <strtol+0x8b>
			dig = *s - '0';
  801e38:	0f be d2             	movsbl %dl,%edx
  801e3b:	83 ea 30             	sub    $0x30,%edx
  801e3e:	eb 22                	jmp    801e62 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e40:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e43:	89 f3                	mov    %esi,%ebx
  801e45:	80 fb 19             	cmp    $0x19,%bl
  801e48:	77 08                	ja     801e52 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e4a:	0f be d2             	movsbl %dl,%edx
  801e4d:	83 ea 57             	sub    $0x57,%edx
  801e50:	eb 10                	jmp    801e62 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e52:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e55:	89 f3                	mov    %esi,%ebx
  801e57:	80 fb 19             	cmp    $0x19,%bl
  801e5a:	77 16                	ja     801e72 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e5c:	0f be d2             	movsbl %dl,%edx
  801e5f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e62:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e65:	7d 0b                	jge    801e72 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e67:	83 c1 01             	add    $0x1,%ecx
  801e6a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e6e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e70:	eb b9                	jmp    801e2b <strtol+0x76>

	if (endptr)
  801e72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e76:	74 0d                	je     801e85 <strtol+0xd0>
		*endptr = (char *) s;
  801e78:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e7b:	89 0e                	mov    %ecx,(%esi)
  801e7d:	eb 06                	jmp    801e85 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e7f:	85 db                	test   %ebx,%ebx
  801e81:	74 98                	je     801e1b <strtol+0x66>
  801e83:	eb 9e                	jmp    801e23 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e85:	89 c2                	mov    %eax,%edx
  801e87:	f7 da                	neg    %edx
  801e89:	85 ff                	test   %edi,%edi
  801e8b:	0f 45 c2             	cmovne %edx,%eax
}
  801e8e:	5b                   	pop    %ebx
  801e8f:	5e                   	pop    %esi
  801e90:	5f                   	pop    %edi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    

00801e93 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	56                   	push   %esi
  801e97:	53                   	push   %ebx
  801e98:	8b 75 08             	mov    0x8(%ebp),%esi
  801e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	74 0e                	je     801eb3 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	50                   	push   %eax
  801ea9:	e8 6a e4 ff ff       	call   800318 <sys_ipc_recv>
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	eb 10                	jmp    801ec3 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801eb3:	83 ec 0c             	sub    $0xc,%esp
  801eb6:	68 00 00 00 f0       	push   $0xf0000000
  801ebb:	e8 58 e4 ff ff       	call   800318 <sys_ipc_recv>
  801ec0:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	74 0e                	je     801ed5 <ipc_recv+0x42>
    	*from_env_store = 0;
  801ec7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ecd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801ed3:	eb 24                	jmp    801ef9 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ed5:	85 f6                	test   %esi,%esi
  801ed7:	74 0a                	je     801ee3 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ed9:	a1 08 40 80 00       	mov    0x804008,%eax
  801ede:	8b 40 74             	mov    0x74(%eax),%eax
  801ee1:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801ee3:	85 db                	test   %ebx,%ebx
  801ee5:	74 0a                	je     801ef1 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801ee7:	a1 08 40 80 00       	mov    0x804008,%eax
  801eec:	8b 40 78             	mov    0x78(%eax),%eax
  801eef:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801ef1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801ef9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	53                   	push   %ebx
  801f06:	83 ec 0c             	sub    $0xc,%esp
  801f09:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f12:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f19:	0f 44 d8             	cmove  %eax,%ebx
  801f1c:	eb 1c                	jmp    801f3a <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f1e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f21:	74 12                	je     801f35 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f23:	50                   	push   %eax
  801f24:	68 e0 26 80 00       	push   $0x8026e0
  801f29:	6a 4b                	push   $0x4b
  801f2b:	68 f8 26 80 00       	push   $0x8026f8
  801f30:	e8 b9 f5 ff ff       	call   8014ee <_panic>
        }	
        sys_yield();
  801f35:	e8 0f e2 ff ff       	call   800149 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f3a:	ff 75 14             	pushl  0x14(%ebp)
  801f3d:	53                   	push   %ebx
  801f3e:	56                   	push   %esi
  801f3f:	57                   	push   %edi
  801f40:	e8 b0 e3 ff ff       	call   8002f5 <sys_ipc_try_send>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	75 d2                	jne    801f1e <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f5a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f62:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f68:	8b 52 50             	mov    0x50(%edx),%edx
  801f6b:	39 ca                	cmp    %ecx,%edx
  801f6d:	75 0d                	jne    801f7c <ipc_find_env+0x28>
			return envs[i].env_id;
  801f6f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f72:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f77:	8b 40 48             	mov    0x48(%eax),%eax
  801f7a:	eb 0f                	jmp    801f8b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7c:	83 c0 01             	add    $0x1,%eax
  801f7f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f84:	75 d9                	jne    801f5f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    

00801f8d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f93:	89 d0                	mov    %edx,%eax
  801f95:	c1 e8 16             	shr    $0x16,%eax
  801f98:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa4:	f6 c1 01             	test   $0x1,%cl
  801fa7:	74 1d                	je     801fc6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa9:	c1 ea 0c             	shr    $0xc,%edx
  801fac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb3:	f6 c2 01             	test   $0x1,%dl
  801fb6:	74 0e                	je     801fc6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb8:	c1 ea 0c             	shr    $0xc,%edx
  801fbb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc2:	ef 
  801fc3:	0f b7 c0             	movzwl %ax,%eax
}
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
