
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 6f 00 00 00       	call   8000b1 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800059:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80005c:	e8 ce 00 00 00       	call   80012f <sys_getenvid>
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x37>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009d:	e8 c7 04 00 00       	call   800569 <close_all>
	sys_env_destroy(0);
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	6a 00                	push   $0x0
  8000a7:	e8 42 00 00 00       	call   8000ee <sys_env_destroy>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	57                   	push   %edi
  8000b5:	56                   	push   %esi
  8000b6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	89 c3                	mov    %eax,%ebx
  8000c4:	89 c7                	mov    %eax,%edi
  8000c6:	89 c6                	mov    %eax,%esi
  8000c8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
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
  8000d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000da:	b8 01 00 00 00       	mov    $0x1,%eax
  8000df:	89 d1                	mov    %edx,%ecx
  8000e1:	89 d3                	mov    %edx,%ebx
  8000e3:	89 d7                	mov    %edx,%edi
  8000e5:	89 d6                	mov    %edx,%esi
  8000e7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	8b 55 08             	mov    0x8(%ebp),%edx
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7e 17                	jle    800127 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	50                   	push   %eax
  800114:	6a 03                	push   $0x3
  800116:	68 6a 22 80 00       	push   $0x80226a
  80011b:	6a 23                	push   $0x23
  80011d:	68 87 22 80 00       	push   $0x802287
  800122:	e8 cc 13 00 00       	call   8014f3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 02 00 00 00       	mov    $0x2,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_yield>:

void
sys_yield(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
  800173:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800176:	be 00 00 00 00       	mov    $0x0,%esi
  80017b:	b8 04 00 00 00       	mov    $0x4,%eax
  800180:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800183:	8b 55 08             	mov    0x8(%ebp),%edx
  800186:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800189:	89 f7                	mov    %esi,%edi
  80018b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	7e 17                	jle    8001a8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	6a 04                	push   $0x4
  800197:	68 6a 22 80 00       	push   $0x80226a
  80019c:	6a 23                	push   $0x23
  80019e:	68 87 22 80 00       	push   $0x802287
  8001a3:	e8 4b 13 00 00       	call   8014f3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ca:	8b 75 18             	mov    0x18(%ebp),%esi
  8001cd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cf:	85 c0                	test   %eax,%eax
  8001d1:	7e 17                	jle    8001ea <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	50                   	push   %eax
  8001d7:	6a 05                	push   $0x5
  8001d9:	68 6a 22 80 00       	push   $0x80226a
  8001de:	6a 23                	push   $0x23
  8001e0:	68 87 22 80 00       	push   $0x802287
  8001e5:	e8 09 13 00 00       	call   8014f3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ed:	5b                   	pop    %ebx
  8001ee:	5e                   	pop    %esi
  8001ef:	5f                   	pop    %edi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	57                   	push   %edi
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800200:	b8 06 00 00 00       	mov    $0x6,%eax
  800205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800208:	8b 55 08             	mov    0x8(%ebp),%edx
  80020b:	89 df                	mov    %ebx,%edi
  80020d:	89 de                	mov    %ebx,%esi
  80020f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800211:	85 c0                	test   %eax,%eax
  800213:	7e 17                	jle    80022c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	6a 06                	push   $0x6
  80021b:	68 6a 22 80 00       	push   $0x80226a
  800220:	6a 23                	push   $0x23
  800222:	68 87 22 80 00       	push   $0x802287
  800227:	e8 c7 12 00 00       	call   8014f3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	b8 08 00 00 00       	mov    $0x8,%eax
  800247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	89 df                	mov    %ebx,%edi
  80024f:	89 de                	mov    %ebx,%esi
  800251:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800253:	85 c0                	test   %eax,%eax
  800255:	7e 17                	jle    80026e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	50                   	push   %eax
  80025b:	6a 08                	push   $0x8
  80025d:	68 6a 22 80 00       	push   $0x80226a
  800262:	6a 23                	push   $0x23
  800264:	68 87 22 80 00       	push   $0x802287
  800269:	e8 85 12 00 00       	call   8014f3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	57                   	push   %edi
  80027a:	56                   	push   %esi
  80027b:	53                   	push   %ebx
  80027c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800284:	b8 09 00 00 00       	mov    $0x9,%eax
  800289:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028c:	8b 55 08             	mov    0x8(%ebp),%edx
  80028f:	89 df                	mov    %ebx,%edi
  800291:	89 de                	mov    %ebx,%esi
  800293:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800295:	85 c0                	test   %eax,%eax
  800297:	7e 17                	jle    8002b0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800299:	83 ec 0c             	sub    $0xc,%esp
  80029c:	50                   	push   %eax
  80029d:	6a 09                	push   $0x9
  80029f:	68 6a 22 80 00       	push   $0x80226a
  8002a4:	6a 23                	push   $0x23
  8002a6:	68 87 22 80 00       	push   $0x802287
  8002ab:	e8 43 12 00 00       	call   8014f3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 df                	mov    %ebx,%edi
  8002d3:	89 de                	mov    %ebx,%esi
  8002d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	7e 17                	jle    8002f2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	50                   	push   %eax
  8002df:	6a 0a                	push   $0xa
  8002e1:	68 6a 22 80 00       	push   $0x80226a
  8002e6:	6a 23                	push   $0x23
  8002e8:	68 87 22 80 00       	push   $0x802287
  8002ed:	e8 01 12 00 00       	call   8014f3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	57                   	push   %edi
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800300:	be 00 00 00 00       	mov    $0x0,%esi
  800305:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030d:	8b 55 08             	mov    0x8(%ebp),%edx
  800310:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800313:	8b 7d 14             	mov    0x14(%ebp),%edi
  800316:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800326:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800330:	8b 55 08             	mov    0x8(%ebp),%edx
  800333:	89 cb                	mov    %ecx,%ebx
  800335:	89 cf                	mov    %ecx,%edi
  800337:	89 ce                	mov    %ecx,%esi
  800339:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033b:	85 c0                	test   %eax,%eax
  80033d:	7e 17                	jle    800356 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033f:	83 ec 0c             	sub    $0xc,%esp
  800342:	50                   	push   %eax
  800343:	6a 0d                	push   $0xd
  800345:	68 6a 22 80 00       	push   $0x80226a
  80034a:	6a 23                	push   $0x23
  80034c:	68 87 22 80 00       	push   $0x802287
  800351:	e8 9d 11 00 00       	call   8014f3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800356:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5f                   	pop    %edi
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800364:	ba 00 00 00 00       	mov    $0x0,%edx
  800369:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036e:	89 d1                	mov    %edx,%ecx
  800370:	89 d3                	mov    %edx,%ebx
  800372:	89 d7                	mov    %edx,%edi
  800374:	89 d6                	mov    %edx,%esi
  800376:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800378:	5b                   	pop    %ebx
  800379:	5e                   	pop    %esi
  80037a:	5f                   	pop    %edi
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800383:	bb 00 00 00 00       	mov    $0x0,%ebx
  800388:	b8 0f 00 00 00       	mov    $0xf,%eax
  80038d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	89 df                	mov    %ebx,%edi
  800395:	89 de                	mov    %ebx,%esi
  800397:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800399:	5b                   	pop    %ebx
  80039a:	5e                   	pop    %esi
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a9:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003be:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003cb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 11                	je     8003f2 <fd_alloc+0x2d>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	75 09                	jne    8003fb <fd_alloc+0x36>
			*fd_store = fd;
  8003f2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f9:	eb 17                	jmp    800412 <fd_alloc+0x4d>
  8003fb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800400:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800405:	75 c9                	jne    8003d0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800407:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80040d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800412:	5d                   	pop    %ebp
  800413:	c3                   	ret    

00800414 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80041a:	83 f8 1f             	cmp    $0x1f,%eax
  80041d:	77 36                	ja     800455 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80041f:	c1 e0 0c             	shl    $0xc,%eax
  800422:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800427:	89 c2                	mov    %eax,%edx
  800429:	c1 ea 16             	shr    $0x16,%edx
  80042c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800433:	f6 c2 01             	test   $0x1,%dl
  800436:	74 24                	je     80045c <fd_lookup+0x48>
  800438:	89 c2                	mov    %eax,%edx
  80043a:	c1 ea 0c             	shr    $0xc,%edx
  80043d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800444:	f6 c2 01             	test   $0x1,%dl
  800447:	74 1a                	je     800463 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800449:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044c:	89 02                	mov    %eax,(%edx)
	return 0;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	eb 13                	jmp    800468 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045a:	eb 0c                	jmp    800468 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800461:	eb 05                	jmp    800468 <fd_lookup+0x54>
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    

0080046a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800473:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800478:	eb 13                	jmp    80048d <dev_lookup+0x23>
  80047a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80047d:	39 08                	cmp    %ecx,(%eax)
  80047f:	75 0c                	jne    80048d <dev_lookup+0x23>
			*dev = devtab[i];
  800481:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800484:	89 01                	mov    %eax,(%ecx)
			return 0;
  800486:	b8 00 00 00 00       	mov    $0x0,%eax
  80048b:	eb 2e                	jmp    8004bb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80048d:	8b 02                	mov    (%edx),%eax
  80048f:	85 c0                	test   %eax,%eax
  800491:	75 e7                	jne    80047a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800493:	a1 08 40 80 00       	mov    0x804008,%eax
  800498:	8b 40 48             	mov    0x48(%eax),%eax
  80049b:	83 ec 04             	sub    $0x4,%esp
  80049e:	51                   	push   %ecx
  80049f:	50                   	push   %eax
  8004a0:	68 98 22 80 00       	push   $0x802298
  8004a5:	e8 22 11 00 00       	call   8015cc <cprintf>
	*dev = 0;
  8004aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004bb:	c9                   	leave  
  8004bc:	c3                   	ret    

008004bd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	56                   	push   %esi
  8004c1:	53                   	push   %ebx
  8004c2:	83 ec 10             	sub    $0x10,%esp
  8004c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ce:	50                   	push   %eax
  8004cf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d5:	c1 e8 0c             	shr    $0xc,%eax
  8004d8:	50                   	push   %eax
  8004d9:	e8 36 ff ff ff       	call   800414 <fd_lookup>
  8004de:	83 c4 08             	add    $0x8,%esp
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	78 05                	js     8004ea <fd_close+0x2d>
	    || fd != fd2)
  8004e5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e8:	74 0c                	je     8004f6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004ea:	84 db                	test   %bl,%bl
  8004ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f1:	0f 44 c2             	cmove  %edx,%eax
  8004f4:	eb 41                	jmp    800537 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004fc:	50                   	push   %eax
  8004fd:	ff 36                	pushl  (%esi)
  8004ff:	e8 66 ff ff ff       	call   80046a <dev_lookup>
  800504:	89 c3                	mov    %eax,%ebx
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 1a                	js     800527 <fd_close+0x6a>
		if (dev->dev_close)
  80050d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800510:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800513:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800518:	85 c0                	test   %eax,%eax
  80051a:	74 0b                	je     800527 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	56                   	push   %esi
  800520:	ff d0                	call   *%eax
  800522:	89 c3                	mov    %eax,%ebx
  800524:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	56                   	push   %esi
  80052b:	6a 00                	push   $0x0
  80052d:	e8 c0 fc ff ff       	call   8001f2 <sys_page_unmap>
	return r;
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	89 d8                	mov    %ebx,%eax
}
  800537:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80053a:	5b                   	pop    %ebx
  80053b:	5e                   	pop    %esi
  80053c:	5d                   	pop    %ebp
  80053d:	c3                   	ret    

0080053e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800544:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800547:	50                   	push   %eax
  800548:	ff 75 08             	pushl  0x8(%ebp)
  80054b:	e8 c4 fe ff ff       	call   800414 <fd_lookup>
  800550:	83 c4 08             	add    $0x8,%esp
  800553:	85 c0                	test   %eax,%eax
  800555:	78 10                	js     800567 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	6a 01                	push   $0x1
  80055c:	ff 75 f4             	pushl  -0xc(%ebp)
  80055f:	e8 59 ff ff ff       	call   8004bd <fd_close>
  800564:	83 c4 10             	add    $0x10,%esp
}
  800567:	c9                   	leave  
  800568:	c3                   	ret    

00800569 <close_all>:

void
close_all(void)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	53                   	push   %ebx
  80056d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800570:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800575:	83 ec 0c             	sub    $0xc,%esp
  800578:	53                   	push   %ebx
  800579:	e8 c0 ff ff ff       	call   80053e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80057e:	83 c3 01             	add    $0x1,%ebx
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	83 fb 20             	cmp    $0x20,%ebx
  800587:	75 ec                	jne    800575 <close_all+0xc>
		close(i);
}
  800589:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80058c:	c9                   	leave  
  80058d:	c3                   	ret    

0080058e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80058e:	55                   	push   %ebp
  80058f:	89 e5                	mov    %esp,%ebp
  800591:	57                   	push   %edi
  800592:	56                   	push   %esi
  800593:	53                   	push   %ebx
  800594:	83 ec 2c             	sub    $0x2c,%esp
  800597:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80059a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80059d:	50                   	push   %eax
  80059e:	ff 75 08             	pushl  0x8(%ebp)
  8005a1:	e8 6e fe ff ff       	call   800414 <fd_lookup>
  8005a6:	83 c4 08             	add    $0x8,%esp
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	0f 88 c1 00 00 00    	js     800672 <dup+0xe4>
		return r;
	close(newfdnum);
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	56                   	push   %esi
  8005b5:	e8 84 ff ff ff       	call   80053e <close>

	newfd = INDEX2FD(newfdnum);
  8005ba:	89 f3                	mov    %esi,%ebx
  8005bc:	c1 e3 0c             	shl    $0xc,%ebx
  8005bf:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c5:	83 c4 04             	add    $0x4,%esp
  8005c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005cb:	e8 de fd ff ff       	call   8003ae <fd2data>
  8005d0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005d2:	89 1c 24             	mov    %ebx,(%esp)
  8005d5:	e8 d4 fd ff ff       	call   8003ae <fd2data>
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e0:	89 f8                	mov    %edi,%eax
  8005e2:	c1 e8 16             	shr    $0x16,%eax
  8005e5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ec:	a8 01                	test   $0x1,%al
  8005ee:	74 37                	je     800627 <dup+0x99>
  8005f0:	89 f8                	mov    %edi,%eax
  8005f2:	c1 e8 0c             	shr    $0xc,%eax
  8005f5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005fc:	f6 c2 01             	test   $0x1,%dl
  8005ff:	74 26                	je     800627 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800601:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	25 07 0e 00 00       	and    $0xe07,%eax
  800610:	50                   	push   %eax
  800611:	ff 75 d4             	pushl  -0x2c(%ebp)
  800614:	6a 00                	push   $0x0
  800616:	57                   	push   %edi
  800617:	6a 00                	push   $0x0
  800619:	e8 92 fb ff ff       	call   8001b0 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
  800623:	85 c0                	test   %eax,%eax
  800625:	78 2e                	js     800655 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800627:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062a:	89 d0                	mov    %edx,%eax
  80062c:	c1 e8 0c             	shr    $0xc,%eax
  80062f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800636:	83 ec 0c             	sub    $0xc,%esp
  800639:	25 07 0e 00 00       	and    $0xe07,%eax
  80063e:	50                   	push   %eax
  80063f:	53                   	push   %ebx
  800640:	6a 00                	push   $0x0
  800642:	52                   	push   %edx
  800643:	6a 00                	push   $0x0
  800645:	e8 66 fb ff ff       	call   8001b0 <sys_page_map>
  80064a:	89 c7                	mov    %eax,%edi
  80064c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80064f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800651:	85 ff                	test   %edi,%edi
  800653:	79 1d                	jns    800672 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 00                	push   $0x0
  80065b:	e8 92 fb ff ff       	call   8001f2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800660:	83 c4 08             	add    $0x8,%esp
  800663:	ff 75 d4             	pushl  -0x2c(%ebp)
  800666:	6a 00                	push   $0x0
  800668:	e8 85 fb ff ff       	call   8001f2 <sys_page_unmap>
	return r;
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	89 f8                	mov    %edi,%eax
}
  800672:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800675:	5b                   	pop    %ebx
  800676:	5e                   	pop    %esi
  800677:	5f                   	pop    %edi
  800678:	5d                   	pop    %ebp
  800679:	c3                   	ret    

0080067a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	53                   	push   %ebx
  80067e:	83 ec 14             	sub    $0x14,%esp
  800681:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800684:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800687:	50                   	push   %eax
  800688:	53                   	push   %ebx
  800689:	e8 86 fd ff ff       	call   800414 <fd_lookup>
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	89 c2                	mov    %eax,%edx
  800693:	85 c0                	test   %eax,%eax
  800695:	78 6d                	js     800704 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80069d:	50                   	push   %eax
  80069e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a1:	ff 30                	pushl  (%eax)
  8006a3:	e8 c2 fd ff ff       	call   80046a <dev_lookup>
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	78 4c                	js     8006fb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b2:	8b 42 08             	mov    0x8(%edx),%eax
  8006b5:	83 e0 03             	and    $0x3,%eax
  8006b8:	83 f8 01             	cmp    $0x1,%eax
  8006bb:	75 21                	jne    8006de <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006bd:	a1 08 40 80 00       	mov    0x804008,%eax
  8006c2:	8b 40 48             	mov    0x48(%eax),%eax
  8006c5:	83 ec 04             	sub    $0x4,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	50                   	push   %eax
  8006ca:	68 d9 22 80 00       	push   $0x8022d9
  8006cf:	e8 f8 0e 00 00       	call   8015cc <cprintf>
		return -E_INVAL;
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006dc:	eb 26                	jmp    800704 <read+0x8a>
	}
	if (!dev->dev_read)
  8006de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e1:	8b 40 08             	mov    0x8(%eax),%eax
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 17                	je     8006ff <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	ff 75 0c             	pushl  0xc(%ebp)
  8006f1:	52                   	push   %edx
  8006f2:	ff d0                	call   *%eax
  8006f4:	89 c2                	mov    %eax,%edx
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	eb 09                	jmp    800704 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fb:	89 c2                	mov    %eax,%edx
  8006fd:	eb 05                	jmp    800704 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800704:	89 d0                	mov    %edx,%eax
  800706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	57                   	push   %edi
  80070f:	56                   	push   %esi
  800710:	53                   	push   %ebx
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	8b 7d 08             	mov    0x8(%ebp),%edi
  800717:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071f:	eb 21                	jmp    800742 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800721:	83 ec 04             	sub    $0x4,%esp
  800724:	89 f0                	mov    %esi,%eax
  800726:	29 d8                	sub    %ebx,%eax
  800728:	50                   	push   %eax
  800729:	89 d8                	mov    %ebx,%eax
  80072b:	03 45 0c             	add    0xc(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	57                   	push   %edi
  800730:	e8 45 ff ff ff       	call   80067a <read>
		if (m < 0)
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	85 c0                	test   %eax,%eax
  80073a:	78 10                	js     80074c <readn+0x41>
			return m;
		if (m == 0)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 0a                	je     80074a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800740:	01 c3                	add    %eax,%ebx
  800742:	39 f3                	cmp    %esi,%ebx
  800744:	72 db                	jb     800721 <readn+0x16>
  800746:	89 d8                	mov    %ebx,%eax
  800748:	eb 02                	jmp    80074c <readn+0x41>
  80074a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80074c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5f                   	pop    %edi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	83 ec 14             	sub    $0x14,%esp
  80075b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800761:	50                   	push   %eax
  800762:	53                   	push   %ebx
  800763:	e8 ac fc ff ff       	call   800414 <fd_lookup>
  800768:	83 c4 08             	add    $0x8,%esp
  80076b:	89 c2                	mov    %eax,%edx
  80076d:	85 c0                	test   %eax,%eax
  80076f:	78 68                	js     8007d9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077b:	ff 30                	pushl  (%eax)
  80077d:	e8 e8 fc ff ff       	call   80046a <dev_lookup>
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	85 c0                	test   %eax,%eax
  800787:	78 47                	js     8007d0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800789:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800790:	75 21                	jne    8007b3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800792:	a1 08 40 80 00       	mov    0x804008,%eax
  800797:	8b 40 48             	mov    0x48(%eax),%eax
  80079a:	83 ec 04             	sub    $0x4,%esp
  80079d:	53                   	push   %ebx
  80079e:	50                   	push   %eax
  80079f:	68 f5 22 80 00       	push   $0x8022f5
  8007a4:	e8 23 0e 00 00       	call   8015cc <cprintf>
		return -E_INVAL;
  8007a9:	83 c4 10             	add    $0x10,%esp
  8007ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007b1:	eb 26                	jmp    8007d9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b6:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	74 17                	je     8007d4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007bd:	83 ec 04             	sub    $0x4,%esp
  8007c0:	ff 75 10             	pushl  0x10(%ebp)
  8007c3:	ff 75 0c             	pushl  0xc(%ebp)
  8007c6:	50                   	push   %eax
  8007c7:	ff d2                	call   *%edx
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	eb 09                	jmp    8007d9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	eb 05                	jmp    8007d9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007d9:	89 d0                	mov    %edx,%eax
  8007db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	ff 75 08             	pushl  0x8(%ebp)
  8007ed:	e8 22 fc ff ff       	call   800414 <fd_lookup>
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	78 0e                	js     800807 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ff:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	83 ec 14             	sub    $0x14,%esp
  800810:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800813:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800816:	50                   	push   %eax
  800817:	53                   	push   %ebx
  800818:	e8 f7 fb ff ff       	call   800414 <fd_lookup>
  80081d:	83 c4 08             	add    $0x8,%esp
  800820:	89 c2                	mov    %eax,%edx
  800822:	85 c0                	test   %eax,%eax
  800824:	78 65                	js     80088b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082c:	50                   	push   %eax
  80082d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800830:	ff 30                	pushl  (%eax)
  800832:	e8 33 fc ff ff       	call   80046a <dev_lookup>
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	85 c0                	test   %eax,%eax
  80083c:	78 44                	js     800882 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800841:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800845:	75 21                	jne    800868 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800847:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80084c:	8b 40 48             	mov    0x48(%eax),%eax
  80084f:	83 ec 04             	sub    $0x4,%esp
  800852:	53                   	push   %ebx
  800853:	50                   	push   %eax
  800854:	68 b8 22 80 00       	push   $0x8022b8
  800859:	e8 6e 0d 00 00       	call   8015cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80085e:	83 c4 10             	add    $0x10,%esp
  800861:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800866:	eb 23                	jmp    80088b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800868:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80086b:	8b 52 18             	mov    0x18(%edx),%edx
  80086e:	85 d2                	test   %edx,%edx
  800870:	74 14                	je     800886 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	ff 75 0c             	pushl  0xc(%ebp)
  800878:	50                   	push   %eax
  800879:	ff d2                	call   *%edx
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	eb 09                	jmp    80088b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800882:	89 c2                	mov    %eax,%edx
  800884:	eb 05                	jmp    80088b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800886:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80088b:	89 d0                	mov    %edx,%eax
  80088d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	83 ec 14             	sub    $0x14,%esp
  800899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80089f:	50                   	push   %eax
  8008a0:	ff 75 08             	pushl  0x8(%ebp)
  8008a3:	e8 6c fb ff ff       	call   800414 <fd_lookup>
  8008a8:	83 c4 08             	add    $0x8,%esp
  8008ab:	89 c2                	mov    %eax,%edx
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	78 58                	js     800909 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b7:	50                   	push   %eax
  8008b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bb:	ff 30                	pushl  (%eax)
  8008bd:	e8 a8 fb ff ff       	call   80046a <dev_lookup>
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 37                	js     800900 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d0:	74 32                	je     800904 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008dc:	00 00 00 
	stat->st_isdir = 0;
  8008df:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e6:	00 00 00 
	stat->st_dev = dev;
  8008e9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	53                   	push   %ebx
  8008f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8008f6:	ff 50 14             	call   *0x14(%eax)
  8008f9:	89 c2                	mov    %eax,%edx
  8008fb:	83 c4 10             	add    $0x10,%esp
  8008fe:	eb 09                	jmp    800909 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800900:	89 c2                	mov    %eax,%edx
  800902:	eb 05                	jmp    800909 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800904:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800909:	89 d0                	mov    %edx,%eax
  80090b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	6a 00                	push   $0x0
  80091a:	ff 75 08             	pushl  0x8(%ebp)
  80091d:	e8 e7 01 00 00       	call   800b09 <open>
  800922:	89 c3                	mov    %eax,%ebx
  800924:	83 c4 10             	add    $0x10,%esp
  800927:	85 c0                	test   %eax,%eax
  800929:	78 1b                	js     800946 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	ff 75 0c             	pushl  0xc(%ebp)
  800931:	50                   	push   %eax
  800932:	e8 5b ff ff ff       	call   800892 <fstat>
  800937:	89 c6                	mov    %eax,%esi
	close(fd);
  800939:	89 1c 24             	mov    %ebx,(%esp)
  80093c:	e8 fd fb ff ff       	call   80053e <close>
	return r;
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	89 f0                	mov    %esi,%eax
}
  800946:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	89 c6                	mov    %eax,%esi
  800954:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800956:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80095d:	75 12                	jne    800971 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80095f:	83 ec 0c             	sub    $0xc,%esp
  800962:	6a 01                	push   $0x1
  800964:	e8 f0 15 00 00       	call   801f59 <ipc_find_env>
  800969:	a3 00 40 80 00       	mov    %eax,0x804000
  80096e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800971:	6a 07                	push   $0x7
  800973:	68 00 50 80 00       	push   $0x805000
  800978:	56                   	push   %esi
  800979:	ff 35 00 40 80 00    	pushl  0x804000
  80097f:	e8 81 15 00 00       	call   801f05 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800984:	83 c4 0c             	add    $0xc,%esp
  800987:	6a 00                	push   $0x0
  800989:	53                   	push   %ebx
  80098a:	6a 00                	push   $0x0
  80098c:	e8 07 15 00 00       	call   801e98 <ipc_recv>
}
  800991:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ac:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8009bb:	e8 8d ff ff ff       	call   80094d <fsipc>
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ce:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d8:	b8 06 00 00 00       	mov    $0x6,%eax
  8009dd:	e8 6b ff ff ff       	call   80094d <fsipc>
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	83 ec 04             	sub    $0x4,%esp
  8009eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	b8 05 00 00 00       	mov    $0x5,%eax
  800a03:	e8 45 ff ff ff       	call   80094d <fsipc>
  800a08:	85 c0                	test   %eax,%eax
  800a0a:	78 2c                	js     800a38 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a0c:	83 ec 08             	sub    $0x8,%esp
  800a0f:	68 00 50 80 00       	push   $0x805000
  800a14:	53                   	push   %ebx
  800a15:	e8 37 11 00 00       	call   801b51 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a1a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a1f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a25:	a1 84 50 80 00       	mov    0x805084,%eax
  800a2a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a30:	83 c4 10             	add    $0x10,%esp
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	53                   	push   %ebx
  800a41:	83 ec 08             	sub    $0x8,%esp
  800a44:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a47:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a4c:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a51:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a54:	53                   	push   %ebx
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	68 08 50 80 00       	push   $0x805008
  800a5d:	e8 81 12 00 00       	call   801ce3 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 40 0c             	mov    0xc(%eax),%eax
  800a68:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a6d:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 04 00 00 00       	mov    $0x4,%eax
  800a7d:	e8 cb fe ff ff       	call   80094d <fsipc>
	//panic("devfile_write not implemented");
}
  800a82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 40 0c             	mov    0xc(%eax),%eax
  800a95:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a9a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa5:	b8 03 00 00 00       	mov    $0x3,%eax
  800aaa:	e8 9e fe ff ff       	call   80094d <fsipc>
  800aaf:	89 c3                	mov    %eax,%ebx
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	78 4b                	js     800b00 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab5:	39 c6                	cmp    %eax,%esi
  800ab7:	73 16                	jae    800acf <devfile_read+0x48>
  800ab9:	68 28 23 80 00       	push   $0x802328
  800abe:	68 2f 23 80 00       	push   $0x80232f
  800ac3:	6a 7c                	push   $0x7c
  800ac5:	68 44 23 80 00       	push   $0x802344
  800aca:	e8 24 0a 00 00       	call   8014f3 <_panic>
	assert(r <= PGSIZE);
  800acf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad4:	7e 16                	jle    800aec <devfile_read+0x65>
  800ad6:	68 4f 23 80 00       	push   $0x80234f
  800adb:	68 2f 23 80 00       	push   $0x80232f
  800ae0:	6a 7d                	push   $0x7d
  800ae2:	68 44 23 80 00       	push   $0x802344
  800ae7:	e8 07 0a 00 00       	call   8014f3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aec:	83 ec 04             	sub    $0x4,%esp
  800aef:	50                   	push   %eax
  800af0:	68 00 50 80 00       	push   $0x805000
  800af5:	ff 75 0c             	pushl  0xc(%ebp)
  800af8:	e8 e6 11 00 00       	call   801ce3 <memmove>
	return r;
  800afd:	83 c4 10             	add    $0x10,%esp
}
  800b00:	89 d8                	mov    %ebx,%eax
  800b02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	53                   	push   %ebx
  800b0d:	83 ec 20             	sub    $0x20,%esp
  800b10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b13:	53                   	push   %ebx
  800b14:	e8 ff 0f 00 00       	call   801b18 <strlen>
  800b19:	83 c4 10             	add    $0x10,%esp
  800b1c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b21:	7f 67                	jg     800b8a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b29:	50                   	push   %eax
  800b2a:	e8 96 f8 ff ff       	call   8003c5 <fd_alloc>
  800b2f:	83 c4 10             	add    $0x10,%esp
		return r;
  800b32:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b34:	85 c0                	test   %eax,%eax
  800b36:	78 57                	js     800b8f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	53                   	push   %ebx
  800b3c:	68 00 50 80 00       	push   $0x805000
  800b41:	e8 0b 10 00 00       	call   801b51 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b49:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b51:	b8 01 00 00 00       	mov    $0x1,%eax
  800b56:	e8 f2 fd ff ff       	call   80094d <fsipc>
  800b5b:	89 c3                	mov    %eax,%ebx
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	85 c0                	test   %eax,%eax
  800b62:	79 14                	jns    800b78 <open+0x6f>
		fd_close(fd, 0);
  800b64:	83 ec 08             	sub    $0x8,%esp
  800b67:	6a 00                	push   $0x0
  800b69:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6c:	e8 4c f9 ff ff       	call   8004bd <fd_close>
		return r;
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	89 da                	mov    %ebx,%edx
  800b76:	eb 17                	jmp    800b8f <open+0x86>
	}

	return fd2num(fd);
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7e:	e8 1b f8 ff ff       	call   80039e <fd2num>
  800b83:	89 c2                	mov    %eax,%edx
  800b85:	83 c4 10             	add    $0x10,%esp
  800b88:	eb 05                	jmp    800b8f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b8a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba6:	e8 a2 fd ff ff       	call   80094d <fsipc>
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bb3:	68 5b 23 80 00       	push   $0x80235b
  800bb8:	ff 75 0c             	pushl  0xc(%ebp)
  800bbb:	e8 91 0f 00 00       	call   801b51 <strcpy>
	return 0;
}
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 10             	sub    $0x10,%esp
  800bce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bd1:	53                   	push   %ebx
  800bd2:	e8 bb 13 00 00       	call   801f92 <pageref>
  800bd7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bdf:	83 f8 01             	cmp    $0x1,%eax
  800be2:	75 10                	jne    800bf4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	ff 73 0c             	pushl  0xc(%ebx)
  800bea:	e8 c0 02 00 00       	call   800eaf <nsipc_close>
  800bef:	89 c2                	mov    %eax,%edx
  800bf1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bf4:	89 d0                	mov    %edx,%eax
  800bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c01:	6a 00                	push   $0x0
  800c03:	ff 75 10             	pushl  0x10(%ebp)
  800c06:	ff 75 0c             	pushl  0xc(%ebp)
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	ff 70 0c             	pushl  0xc(%eax)
  800c0f:	e8 78 03 00 00       	call   800f8c <nsipc_send>
}
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c1c:	6a 00                	push   $0x0
  800c1e:	ff 75 10             	pushl  0x10(%ebp)
  800c21:	ff 75 0c             	pushl  0xc(%ebp)
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	ff 70 0c             	pushl  0xc(%eax)
  800c2a:	e8 f1 02 00 00       	call   800f20 <nsipc_recv>
}
  800c2f:	c9                   	leave  
  800c30:	c3                   	ret    

00800c31 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c37:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c3a:	52                   	push   %edx
  800c3b:	50                   	push   %eax
  800c3c:	e8 d3 f7 ff ff       	call   800414 <fd_lookup>
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	85 c0                	test   %eax,%eax
  800c46:	78 17                	js     800c5f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c51:	39 08                	cmp    %ecx,(%eax)
  800c53:	75 05                	jne    800c5a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c55:	8b 40 0c             	mov    0xc(%eax),%eax
  800c58:	eb 05                	jmp    800c5f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c5a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    

00800c61 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 1c             	sub    $0x1c,%esp
  800c69:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c6e:	50                   	push   %eax
  800c6f:	e8 51 f7 ff ff       	call   8003c5 <fd_alloc>
  800c74:	89 c3                	mov    %eax,%ebx
  800c76:	83 c4 10             	add    $0x10,%esp
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	78 1b                	js     800c98 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c7d:	83 ec 04             	sub    $0x4,%esp
  800c80:	68 07 04 00 00       	push   $0x407
  800c85:	ff 75 f4             	pushl  -0xc(%ebp)
  800c88:	6a 00                	push   $0x0
  800c8a:	e8 de f4 ff ff       	call   80016d <sys_page_alloc>
  800c8f:	89 c3                	mov    %eax,%ebx
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	85 c0                	test   %eax,%eax
  800c96:	79 10                	jns    800ca8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	56                   	push   %esi
  800c9c:	e8 0e 02 00 00       	call   800eaf <nsipc_close>
		return r;
  800ca1:	83 c4 10             	add    $0x10,%esp
  800ca4:	89 d8                	mov    %ebx,%eax
  800ca6:	eb 24                	jmp    800ccc <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cbd:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	e8 d5 f6 ff ff       	call   80039e <fd2num>
  800cc9:	83 c4 10             	add    $0x10,%esp
}
  800ccc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	e8 50 ff ff ff       	call   800c31 <fd2sockid>
		return r;
  800ce1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	78 1f                	js     800d06 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce7:	83 ec 04             	sub    $0x4,%esp
  800cea:	ff 75 10             	pushl  0x10(%ebp)
  800ced:	ff 75 0c             	pushl  0xc(%ebp)
  800cf0:	50                   	push   %eax
  800cf1:	e8 12 01 00 00       	call   800e08 <nsipc_accept>
  800cf6:	83 c4 10             	add    $0x10,%esp
		return r;
  800cf9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	78 07                	js     800d06 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cff:	e8 5d ff ff ff       	call   800c61 <alloc_sockfd>
  800d04:	89 c1                	mov    %eax,%ecx
}
  800d06:	89 c8                	mov    %ecx,%eax
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	e8 19 ff ff ff       	call   800c31 <fd2sockid>
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	78 12                	js     800d2e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d1c:	83 ec 04             	sub    $0x4,%esp
  800d1f:	ff 75 10             	pushl  0x10(%ebp)
  800d22:	ff 75 0c             	pushl  0xc(%ebp)
  800d25:	50                   	push   %eax
  800d26:	e8 2d 01 00 00       	call   800e58 <nsipc_bind>
  800d2b:	83 c4 10             	add    $0x10,%esp
}
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <shutdown>:

int
shutdown(int s, int how)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	e8 f3 fe ff ff       	call   800c31 <fd2sockid>
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	78 0f                	js     800d51 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d42:	83 ec 08             	sub    $0x8,%esp
  800d45:	ff 75 0c             	pushl  0xc(%ebp)
  800d48:	50                   	push   %eax
  800d49:	e8 3f 01 00 00       	call   800e8d <nsipc_shutdown>
  800d4e:	83 c4 10             	add    $0x10,%esp
}
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	e8 d0 fe ff ff       	call   800c31 <fd2sockid>
  800d61:	85 c0                	test   %eax,%eax
  800d63:	78 12                	js     800d77 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d65:	83 ec 04             	sub    $0x4,%esp
  800d68:	ff 75 10             	pushl  0x10(%ebp)
  800d6b:	ff 75 0c             	pushl  0xc(%ebp)
  800d6e:	50                   	push   %eax
  800d6f:	e8 55 01 00 00       	call   800ec9 <nsipc_connect>
  800d74:	83 c4 10             	add    $0x10,%esp
}
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <listen>:

int
listen(int s, int backlog)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	e8 aa fe ff ff       	call   800c31 <fd2sockid>
  800d87:	85 c0                	test   %eax,%eax
  800d89:	78 0f                	js     800d9a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d8b:	83 ec 08             	sub    $0x8,%esp
  800d8e:	ff 75 0c             	pushl  0xc(%ebp)
  800d91:	50                   	push   %eax
  800d92:	e8 67 01 00 00       	call   800efe <nsipc_listen>
  800d97:	83 c4 10             	add    $0x10,%esp
}
  800d9a:	c9                   	leave  
  800d9b:	c3                   	ret    

00800d9c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800da2:	ff 75 10             	pushl  0x10(%ebp)
  800da5:	ff 75 0c             	pushl  0xc(%ebp)
  800da8:	ff 75 08             	pushl  0x8(%ebp)
  800dab:	e8 3a 02 00 00       	call   800fea <nsipc_socket>
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	78 05                	js     800dbc <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800db7:	e8 a5 fe ff ff       	call   800c61 <alloc_sockfd>
}
  800dbc:	c9                   	leave  
  800dbd:	c3                   	ret    

00800dbe <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dc7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dce:	75 12                	jne    800de2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	6a 02                	push   $0x2
  800dd5:	e8 7f 11 00 00       	call   801f59 <ipc_find_env>
  800dda:	a3 04 40 80 00       	mov    %eax,0x804004
  800ddf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800de2:	6a 07                	push   $0x7
  800de4:	68 00 60 80 00       	push   $0x806000
  800de9:	53                   	push   %ebx
  800dea:	ff 35 04 40 80 00    	pushl  0x804004
  800df0:	e8 10 11 00 00       	call   801f05 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800df5:	83 c4 0c             	add    $0xc,%esp
  800df8:	6a 00                	push   $0x0
  800dfa:	6a 00                	push   $0x0
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 95 10 00 00       	call   801e98 <ipc_recv>
}
  800e03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e18:	8b 06                	mov    (%esi),%eax
  800e1a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e24:	e8 95 ff ff ff       	call   800dbe <nsipc>
  800e29:	89 c3                	mov    %eax,%ebx
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	78 20                	js     800e4f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e2f:	83 ec 04             	sub    $0x4,%esp
  800e32:	ff 35 10 60 80 00    	pushl  0x806010
  800e38:	68 00 60 80 00       	push   $0x806000
  800e3d:	ff 75 0c             	pushl  0xc(%ebp)
  800e40:	e8 9e 0e 00 00       	call   801ce3 <memmove>
		*addrlen = ret->ret_addrlen;
  800e45:	a1 10 60 80 00       	mov    0x806010,%eax
  800e4a:	89 06                	mov    %eax,(%esi)
  800e4c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e4f:	89 d8                	mov    %ebx,%eax
  800e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e6a:	53                   	push   %ebx
  800e6b:	ff 75 0c             	pushl  0xc(%ebp)
  800e6e:	68 04 60 80 00       	push   $0x806004
  800e73:	e8 6b 0e 00 00       	call   801ce3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e78:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e83:	e8 36 ff ff ff       	call   800dbe <nsipc>
}
  800e88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8b:	c9                   	leave  
  800e8c:	c3                   	ret    

00800e8d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ea3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea8:	e8 11 ff ff ff       	call   800dbe <nsipc>
}
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    

00800eaf <nsipc_close>:

int
nsipc_close(int s)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ebd:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec2:	e8 f7 fe ff ff       	call   800dbe <nsipc>
}
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 08             	sub    $0x8,%esp
  800ed0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800edb:	53                   	push   %ebx
  800edc:	ff 75 0c             	pushl  0xc(%ebp)
  800edf:	68 04 60 80 00       	push   $0x806004
  800ee4:	e8 fa 0d 00 00       	call   801ce3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eef:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef4:	e8 c5 fe ff ff       	call   800dbe <nsipc>
}
  800ef9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    

00800efe <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f04:	8b 45 08             	mov    0x8(%ebp),%eax
  800f07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f14:	b8 06 00 00 00       	mov    $0x6,%eax
  800f19:	e8 a0 fe ff ff       	call   800dbe <nsipc>
}
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f30:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f36:	8b 45 14             	mov    0x14(%ebp),%eax
  800f39:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f3e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f43:	e8 76 fe ff ff       	call   800dbe <nsipc>
  800f48:	89 c3                	mov    %eax,%ebx
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	78 35                	js     800f83 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f4e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f53:	7f 04                	jg     800f59 <nsipc_recv+0x39>
  800f55:	39 c6                	cmp    %eax,%esi
  800f57:	7d 16                	jge    800f6f <nsipc_recv+0x4f>
  800f59:	68 67 23 80 00       	push   $0x802367
  800f5e:	68 2f 23 80 00       	push   $0x80232f
  800f63:	6a 62                	push   $0x62
  800f65:	68 7c 23 80 00       	push   $0x80237c
  800f6a:	e8 84 05 00 00       	call   8014f3 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f6f:	83 ec 04             	sub    $0x4,%esp
  800f72:	50                   	push   %eax
  800f73:	68 00 60 80 00       	push   $0x806000
  800f78:	ff 75 0c             	pushl  0xc(%ebp)
  800f7b:	e8 63 0d 00 00       	call   801ce3 <memmove>
  800f80:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f83:	89 d8                	mov    %ebx,%eax
  800f85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f9e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fa4:	7e 16                	jle    800fbc <nsipc_send+0x30>
  800fa6:	68 88 23 80 00       	push   $0x802388
  800fab:	68 2f 23 80 00       	push   $0x80232f
  800fb0:	6a 6d                	push   $0x6d
  800fb2:	68 7c 23 80 00       	push   $0x80237c
  800fb7:	e8 37 05 00 00       	call   8014f3 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	53                   	push   %ebx
  800fc0:	ff 75 0c             	pushl  0xc(%ebp)
  800fc3:	68 0c 60 80 00       	push   $0x80600c
  800fc8:	e8 16 0d 00 00       	call   801ce3 <memmove>
	nsipcbuf.send.req_size = size;
  800fcd:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe0:	e8 d9 fd ff ff       	call   800dbe <nsipc>
}
  800fe5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffb:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801000:	8b 45 10             	mov    0x10(%ebp),%eax
  801003:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801008:	b8 09 00 00 00       	mov    $0x9,%eax
  80100d:	e8 ac fd ff ff       	call   800dbe <nsipc>
}
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
  801019:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	ff 75 08             	pushl  0x8(%ebp)
  801022:	e8 87 f3 ff ff       	call   8003ae <fd2data>
  801027:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801029:	83 c4 08             	add    $0x8,%esp
  80102c:	68 94 23 80 00       	push   $0x802394
  801031:	53                   	push   %ebx
  801032:	e8 1a 0b 00 00       	call   801b51 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801037:	8b 46 04             	mov    0x4(%esi),%eax
  80103a:	2b 06                	sub    (%esi),%eax
  80103c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801042:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801049:	00 00 00 
	stat->st_dev = &devpipe;
  80104c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801053:	30 80 00 
	return 0;
}
  801056:	b8 00 00 00 00       	mov    $0x0,%eax
  80105b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	53                   	push   %ebx
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80106c:	53                   	push   %ebx
  80106d:	6a 00                	push   $0x0
  80106f:	e8 7e f1 ff ff       	call   8001f2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801074:	89 1c 24             	mov    %ebx,(%esp)
  801077:	e8 32 f3 ff ff       	call   8003ae <fd2data>
  80107c:	83 c4 08             	add    $0x8,%esp
  80107f:	50                   	push   %eax
  801080:	6a 00                	push   $0x0
  801082:	e8 6b f1 ff ff       	call   8001f2 <sys_page_unmap>
}
  801087:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
  801092:	83 ec 1c             	sub    $0x1c,%esp
  801095:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801098:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80109a:	a1 08 40 80 00       	mov    0x804008,%eax
  80109f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a8:	e8 e5 0e 00 00       	call   801f92 <pageref>
  8010ad:	89 c3                	mov    %eax,%ebx
  8010af:	89 3c 24             	mov    %edi,(%esp)
  8010b2:	e8 db 0e 00 00       	call   801f92 <pageref>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	39 c3                	cmp    %eax,%ebx
  8010bc:	0f 94 c1             	sete   %cl
  8010bf:	0f b6 c9             	movzbl %cl,%ecx
  8010c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010c5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010cb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010ce:	39 ce                	cmp    %ecx,%esi
  8010d0:	74 1b                	je     8010ed <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010d2:	39 c3                	cmp    %eax,%ebx
  8010d4:	75 c4                	jne    80109a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010d6:	8b 42 58             	mov    0x58(%edx),%eax
  8010d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010dc:	50                   	push   %eax
  8010dd:	56                   	push   %esi
  8010de:	68 9b 23 80 00       	push   $0x80239b
  8010e3:	e8 e4 04 00 00       	call   8015cc <cprintf>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	eb ad                	jmp    80109a <_pipeisclosed+0xe>
	}
}
  8010ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 28             	sub    $0x28,%esp
  801101:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801104:	56                   	push   %esi
  801105:	e8 a4 f2 ff ff       	call   8003ae <fd2data>
  80110a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	bf 00 00 00 00       	mov    $0x0,%edi
  801114:	eb 4b                	jmp    801161 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801116:	89 da                	mov    %ebx,%edx
  801118:	89 f0                	mov    %esi,%eax
  80111a:	e8 6d ff ff ff       	call   80108c <_pipeisclosed>
  80111f:	85 c0                	test   %eax,%eax
  801121:	75 48                	jne    80116b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801123:	e8 26 f0 ff ff       	call   80014e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801128:	8b 43 04             	mov    0x4(%ebx),%eax
  80112b:	8b 0b                	mov    (%ebx),%ecx
  80112d:	8d 51 20             	lea    0x20(%ecx),%edx
  801130:	39 d0                	cmp    %edx,%eax
  801132:	73 e2                	jae    801116 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801134:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801137:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80113b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80113e:	89 c2                	mov    %eax,%edx
  801140:	c1 fa 1f             	sar    $0x1f,%edx
  801143:	89 d1                	mov    %edx,%ecx
  801145:	c1 e9 1b             	shr    $0x1b,%ecx
  801148:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80114b:	83 e2 1f             	and    $0x1f,%edx
  80114e:	29 ca                	sub    %ecx,%edx
  801150:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801154:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801158:	83 c0 01             	add    $0x1,%eax
  80115b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80115e:	83 c7 01             	add    $0x1,%edi
  801161:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801164:	75 c2                	jne    801128 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801166:	8b 45 10             	mov    0x10(%ebp),%eax
  801169:	eb 05                	jmp    801170 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 18             	sub    $0x18,%esp
  801181:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801184:	57                   	push   %edi
  801185:	e8 24 f2 ff ff       	call   8003ae <fd2data>
  80118a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801194:	eb 3d                	jmp    8011d3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801196:	85 db                	test   %ebx,%ebx
  801198:	74 04                	je     80119e <devpipe_read+0x26>
				return i;
  80119a:	89 d8                	mov    %ebx,%eax
  80119c:	eb 44                	jmp    8011e2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80119e:	89 f2                	mov    %esi,%edx
  8011a0:	89 f8                	mov    %edi,%eax
  8011a2:	e8 e5 fe ff ff       	call   80108c <_pipeisclosed>
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	75 32                	jne    8011dd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011ab:	e8 9e ef ff ff       	call   80014e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011b0:	8b 06                	mov    (%esi),%eax
  8011b2:	3b 46 04             	cmp    0x4(%esi),%eax
  8011b5:	74 df                	je     801196 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b7:	99                   	cltd   
  8011b8:	c1 ea 1b             	shr    $0x1b,%edx
  8011bb:	01 d0                	add    %edx,%eax
  8011bd:	83 e0 1f             	and    $0x1f,%eax
  8011c0:	29 d0                	sub    %edx,%eax
  8011c2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ca:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011cd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d0:	83 c3 01             	add    $0x1,%ebx
  8011d3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011d6:	75 d8                	jne    8011b0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8011db:	eb 05                	jmp    8011e2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011dd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	56                   	push   %esi
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	e8 ca f1 ff ff       	call   8003c5 <fd_alloc>
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	85 c0                	test   %eax,%eax
  801202:	0f 88 2c 01 00 00    	js     801334 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	68 07 04 00 00       	push   $0x407
  801210:	ff 75 f4             	pushl  -0xc(%ebp)
  801213:	6a 00                	push   $0x0
  801215:	e8 53 ef ff ff       	call   80016d <sys_page_alloc>
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	85 c0                	test   %eax,%eax
  801221:	0f 88 0d 01 00 00    	js     801334 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801227:	83 ec 0c             	sub    $0xc,%esp
  80122a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	e8 92 f1 ff ff       	call   8003c5 <fd_alloc>
  801233:	89 c3                	mov    %eax,%ebx
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	0f 88 e2 00 00 00    	js     801322 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	68 07 04 00 00       	push   $0x407
  801248:	ff 75 f0             	pushl  -0x10(%ebp)
  80124b:	6a 00                	push   $0x0
  80124d:	e8 1b ef ff ff       	call   80016d <sys_page_alloc>
  801252:	89 c3                	mov    %eax,%ebx
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	0f 88 c3 00 00 00    	js     801322 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80125f:	83 ec 0c             	sub    $0xc,%esp
  801262:	ff 75 f4             	pushl  -0xc(%ebp)
  801265:	e8 44 f1 ff ff       	call   8003ae <fd2data>
  80126a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126c:	83 c4 0c             	add    $0xc,%esp
  80126f:	68 07 04 00 00       	push   $0x407
  801274:	50                   	push   %eax
  801275:	6a 00                	push   $0x0
  801277:	e8 f1 ee ff ff       	call   80016d <sys_page_alloc>
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	0f 88 89 00 00 00    	js     801312 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801289:	83 ec 0c             	sub    $0xc,%esp
  80128c:	ff 75 f0             	pushl  -0x10(%ebp)
  80128f:	e8 1a f1 ff ff       	call   8003ae <fd2data>
  801294:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80129b:	50                   	push   %eax
  80129c:	6a 00                	push   $0x0
  80129e:	56                   	push   %esi
  80129f:	6a 00                	push   $0x0
  8012a1:	e8 0a ef ff ff       	call   8001b0 <sys_page_map>
  8012a6:	89 c3                	mov    %eax,%ebx
  8012a8:	83 c4 20             	add    $0x20,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 55                	js     801304 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012af:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012c4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8012df:	e8 ba f0 ff ff       	call   80039e <fd2num>
  8012e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e9:	83 c4 04             	add    $0x4,%esp
  8012ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ef:	e8 aa f0 ff ff       	call   80039e <fd2num>
  8012f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801302:	eb 30                	jmp    801334 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	56                   	push   %esi
  801308:	6a 00                	push   $0x0
  80130a:	e8 e3 ee ff ff       	call   8001f2 <sys_page_unmap>
  80130f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	ff 75 f0             	pushl  -0x10(%ebp)
  801318:	6a 00                	push   $0x0
  80131a:	e8 d3 ee ff ff       	call   8001f2 <sys_page_unmap>
  80131f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	ff 75 f4             	pushl  -0xc(%ebp)
  801328:	6a 00                	push   $0x0
  80132a:	e8 c3 ee ff ff       	call   8001f2 <sys_page_unmap>
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801334:	89 d0                	mov    %edx,%eax
  801336:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	ff 75 08             	pushl  0x8(%ebp)
  80134a:	e8 c5 f0 ff ff       	call   800414 <fd_lookup>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 18                	js     80136e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801356:	83 ec 0c             	sub    $0xc,%esp
  801359:	ff 75 f4             	pushl  -0xc(%ebp)
  80135c:	e8 4d f0 ff ff       	call   8003ae <fd2data>
	return _pipeisclosed(fd, p);
  801361:	89 c2                	mov    %eax,%edx
  801363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801366:	e8 21 fd ff ff       	call   80108c <_pipeisclosed>
  80136b:	83 c4 10             	add    $0x10,%esp
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801380:	68 b3 23 80 00       	push   $0x8023b3
  801385:	ff 75 0c             	pushl  0xc(%ebp)
  801388:	e8 c4 07 00 00       	call   801b51 <strcpy>
	return 0;
}
  80138d:	b8 00 00 00 00       	mov    $0x0,%eax
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	57                   	push   %edi
  801398:	56                   	push   %esi
  801399:	53                   	push   %ebx
  80139a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ab:	eb 2d                	jmp    8013da <devcons_write+0x46>
		m = n - tot;
  8013ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013b2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013b5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013ba:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	53                   	push   %ebx
  8013c1:	03 45 0c             	add    0xc(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	57                   	push   %edi
  8013c6:	e8 18 09 00 00       	call   801ce3 <memmove>
		sys_cputs(buf, m);
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	53                   	push   %ebx
  8013cf:	57                   	push   %edi
  8013d0:	e8 dc ec ff ff       	call   8000b1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d5:	01 de                	add    %ebx,%esi
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	89 f0                	mov    %esi,%eax
  8013dc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013df:	72 cc                	jb     8013ad <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5e                   	pop    %esi
  8013e6:	5f                   	pop    %edi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f8:	74 2a                	je     801424 <devcons_read+0x3b>
  8013fa:	eb 05                	jmp    801401 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013fc:	e8 4d ed ff ff       	call   80014e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801401:	e8 c9 ec ff ff       	call   8000cf <sys_cgetc>
  801406:	85 c0                	test   %eax,%eax
  801408:	74 f2                	je     8013fc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 16                	js     801424 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80140e:	83 f8 04             	cmp    $0x4,%eax
  801411:	74 0c                	je     80141f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801413:	8b 55 0c             	mov    0xc(%ebp),%edx
  801416:	88 02                	mov    %al,(%edx)
	return 1;
  801418:	b8 01 00 00 00       	mov    $0x1,%eax
  80141d:	eb 05                	jmp    801424 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80141f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801432:	6a 01                	push   $0x1
  801434:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801437:	50                   	push   %eax
  801438:	e8 74 ec ff ff       	call   8000b1 <sys_cputs>
}
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	c9                   	leave  
  801441:	c3                   	ret    

00801442 <getchar>:

int
getchar(void)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801448:	6a 01                	push   $0x1
  80144a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	6a 00                	push   $0x0
  801450:	e8 25 f2 ff ff       	call   80067a <read>
	if (r < 0)
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 0f                	js     80146b <getchar+0x29>
		return r;
	if (r < 1)
  80145c:	85 c0                	test   %eax,%eax
  80145e:	7e 06                	jle    801466 <getchar+0x24>
		return -E_EOF;
	return c;
  801460:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801464:	eb 05                	jmp    80146b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801466:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	ff 75 08             	pushl  0x8(%ebp)
  80147a:	e8 95 ef ff ff       	call   800414 <fd_lookup>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 11                	js     801497 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801486:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801489:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80148f:	39 10                	cmp    %edx,(%eax)
  801491:	0f 94 c0             	sete   %al
  801494:	0f b6 c0             	movzbl %al,%eax
}
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <opencons>:

int
opencons(void)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80149f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a2:	50                   	push   %eax
  8014a3:	e8 1d ef ff ff       	call   8003c5 <fd_alloc>
  8014a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ab:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 3e                	js     8014ef <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b1:	83 ec 04             	sub    $0x4,%esp
  8014b4:	68 07 04 00 00       	push   $0x407
  8014b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bc:	6a 00                	push   $0x0
  8014be:	e8 aa ec ff ff       	call   80016d <sys_page_alloc>
  8014c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 23                	js     8014ef <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014cc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	50                   	push   %eax
  8014e5:	e8 b4 ee ff ff       	call   80039e <fd2num>
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	83 c4 10             	add    $0x10,%esp
}
  8014ef:	89 d0                	mov    %edx,%eax
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014fb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801501:	e8 29 ec ff ff       	call   80012f <sys_getenvid>
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	ff 75 0c             	pushl  0xc(%ebp)
  80150c:	ff 75 08             	pushl  0x8(%ebp)
  80150f:	56                   	push   %esi
  801510:	50                   	push   %eax
  801511:	68 c0 23 80 00       	push   $0x8023c0
  801516:	e8 b1 00 00 00       	call   8015cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80151b:	83 c4 18             	add    $0x18,%esp
  80151e:	53                   	push   %ebx
  80151f:	ff 75 10             	pushl  0x10(%ebp)
  801522:	e8 54 00 00 00       	call   80157b <vcprintf>
	cprintf("\n");
  801527:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  80152e:	e8 99 00 00 00       	call   8015cc <cprintf>
  801533:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801536:	cc                   	int3   
  801537:	eb fd                	jmp    801536 <_panic+0x43>

00801539 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	53                   	push   %ebx
  80153d:	83 ec 04             	sub    $0x4,%esp
  801540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801543:	8b 13                	mov    (%ebx),%edx
  801545:	8d 42 01             	lea    0x1(%edx),%eax
  801548:	89 03                	mov    %eax,(%ebx)
  80154a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80154d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801551:	3d ff 00 00 00       	cmp    $0xff,%eax
  801556:	75 1a                	jne    801572 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	68 ff 00 00 00       	push   $0xff
  801560:	8d 43 08             	lea    0x8(%ebx),%eax
  801563:	50                   	push   %eax
  801564:	e8 48 eb ff ff       	call   8000b1 <sys_cputs>
		b->idx = 0;
  801569:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80156f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801572:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801576:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801584:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80158b:	00 00 00 
	b.cnt = 0;
  80158e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801595:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801598:	ff 75 0c             	pushl  0xc(%ebp)
  80159b:	ff 75 08             	pushl  0x8(%ebp)
  80159e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	68 39 15 80 00       	push   $0x801539
  8015aa:	e8 54 01 00 00       	call   801703 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015be:	50                   	push   %eax
  8015bf:	e8 ed ea ff ff       	call   8000b1 <sys_cputs>

	return b.cnt;
}
  8015c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015d5:	50                   	push   %eax
  8015d6:	ff 75 08             	pushl  0x8(%ebp)
  8015d9:	e8 9d ff ff ff       	call   80157b <vcprintf>
	va_end(ap);

	return cnt;
}
  8015de:	c9                   	leave  
  8015df:	c3                   	ret    

008015e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	57                   	push   %edi
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 1c             	sub    $0x1c,%esp
  8015e9:	89 c7                	mov    %eax,%edi
  8015eb:	89 d6                	mov    %edx,%esi
  8015ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801601:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801604:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801607:	39 d3                	cmp    %edx,%ebx
  801609:	72 05                	jb     801610 <printnum+0x30>
  80160b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80160e:	77 45                	ja     801655 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	ff 75 18             	pushl  0x18(%ebp)
  801616:	8b 45 14             	mov    0x14(%ebp),%eax
  801619:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80161c:	53                   	push   %ebx
  80161d:	ff 75 10             	pushl  0x10(%ebp)
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	ff 75 e4             	pushl  -0x1c(%ebp)
  801626:	ff 75 e0             	pushl  -0x20(%ebp)
  801629:	ff 75 dc             	pushl  -0x24(%ebp)
  80162c:	ff 75 d8             	pushl  -0x28(%ebp)
  80162f:	e8 9c 09 00 00       	call   801fd0 <__udivdi3>
  801634:	83 c4 18             	add    $0x18,%esp
  801637:	52                   	push   %edx
  801638:	50                   	push   %eax
  801639:	89 f2                	mov    %esi,%edx
  80163b:	89 f8                	mov    %edi,%eax
  80163d:	e8 9e ff ff ff       	call   8015e0 <printnum>
  801642:	83 c4 20             	add    $0x20,%esp
  801645:	eb 18                	jmp    80165f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	56                   	push   %esi
  80164b:	ff 75 18             	pushl  0x18(%ebp)
  80164e:	ff d7                	call   *%edi
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	eb 03                	jmp    801658 <printnum+0x78>
  801655:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801658:	83 eb 01             	sub    $0x1,%ebx
  80165b:	85 db                	test   %ebx,%ebx
  80165d:	7f e8                	jg     801647 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	56                   	push   %esi
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	ff 75 e4             	pushl  -0x1c(%ebp)
  801669:	ff 75 e0             	pushl  -0x20(%ebp)
  80166c:	ff 75 dc             	pushl  -0x24(%ebp)
  80166f:	ff 75 d8             	pushl  -0x28(%ebp)
  801672:	e8 89 0a 00 00       	call   802100 <__umoddi3>
  801677:	83 c4 14             	add    $0x14,%esp
  80167a:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801681:	50                   	push   %eax
  801682:	ff d7                	call   *%edi
}
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	5f                   	pop    %edi
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801692:	83 fa 01             	cmp    $0x1,%edx
  801695:	7e 0e                	jle    8016a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801697:	8b 10                	mov    (%eax),%edx
  801699:	8d 4a 08             	lea    0x8(%edx),%ecx
  80169c:	89 08                	mov    %ecx,(%eax)
  80169e:	8b 02                	mov    (%edx),%eax
  8016a0:	8b 52 04             	mov    0x4(%edx),%edx
  8016a3:	eb 22                	jmp    8016c7 <getuint+0x38>
	else if (lflag)
  8016a5:	85 d2                	test   %edx,%edx
  8016a7:	74 10                	je     8016b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016a9:	8b 10                	mov    (%eax),%edx
  8016ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016ae:	89 08                	mov    %ecx,(%eax)
  8016b0:	8b 02                	mov    (%edx),%eax
  8016b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b7:	eb 0e                	jmp    8016c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016b9:	8b 10                	mov    (%eax),%edx
  8016bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016be:	89 08                	mov    %ecx,(%eax)
  8016c0:	8b 02                	mov    (%edx),%eax
  8016c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016d3:	8b 10                	mov    (%eax),%edx
  8016d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d8:	73 0a                	jae    8016e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016dd:	89 08                	mov    %ecx,(%eax)
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	88 02                	mov    %al,(%edx)
}
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ef:	50                   	push   %eax
  8016f0:	ff 75 10             	pushl  0x10(%ebp)
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	ff 75 08             	pushl  0x8(%ebp)
  8016f9:	e8 05 00 00 00       	call   801703 <vprintfmt>
	va_end(ap);
}
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	57                   	push   %edi
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	83 ec 2c             	sub    $0x2c,%esp
  80170c:	8b 75 08             	mov    0x8(%ebp),%esi
  80170f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801712:	8b 7d 10             	mov    0x10(%ebp),%edi
  801715:	eb 12                	jmp    801729 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801717:	85 c0                	test   %eax,%eax
  801719:	0f 84 89 03 00 00    	je     801aa8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	53                   	push   %ebx
  801723:	50                   	push   %eax
  801724:	ff d6                	call   *%esi
  801726:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801729:	83 c7 01             	add    $0x1,%edi
  80172c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801730:	83 f8 25             	cmp    $0x25,%eax
  801733:	75 e2                	jne    801717 <vprintfmt+0x14>
  801735:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801739:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801740:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801747:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	eb 07                	jmp    80175c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801755:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801758:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175c:	8d 47 01             	lea    0x1(%edi),%eax
  80175f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801762:	0f b6 07             	movzbl (%edi),%eax
  801765:	0f b6 c8             	movzbl %al,%ecx
  801768:	83 e8 23             	sub    $0x23,%eax
  80176b:	3c 55                	cmp    $0x55,%al
  80176d:	0f 87 1a 03 00 00    	ja     801a8d <vprintfmt+0x38a>
  801773:	0f b6 c0             	movzbl %al,%eax
  801776:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80177d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801780:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801784:	eb d6                	jmp    80175c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
  80178e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801791:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801794:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801798:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80179b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80179e:	83 fa 09             	cmp    $0x9,%edx
  8017a1:	77 39                	ja     8017dc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017a6:	eb e9                	jmp    801791 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8017ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017b1:	8b 00                	mov    (%eax),%eax
  8017b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017b9:	eb 27                	jmp    8017e2 <vprintfmt+0xdf>
  8017bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c5:	0f 49 c8             	cmovns %eax,%ecx
  8017c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ce:	eb 8c                	jmp    80175c <vprintfmt+0x59>
  8017d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017da:	eb 80                	jmp    80175c <vprintfmt+0x59>
  8017dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017df:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e6:	0f 89 70 ff ff ff    	jns    80175c <vprintfmt+0x59>
				width = precision, precision = -1;
  8017ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f9:	e9 5e ff ff ff       	jmp    80175c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017fe:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801804:	e9 53 ff ff ff       	jmp    80175c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801809:	8b 45 14             	mov    0x14(%ebp),%eax
  80180c:	8d 50 04             	lea    0x4(%eax),%edx
  80180f:	89 55 14             	mov    %edx,0x14(%ebp)
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	53                   	push   %ebx
  801816:	ff 30                	pushl  (%eax)
  801818:	ff d6                	call   *%esi
			break;
  80181a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801820:	e9 04 ff ff ff       	jmp    801729 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801825:	8b 45 14             	mov    0x14(%ebp),%eax
  801828:	8d 50 04             	lea    0x4(%eax),%edx
  80182b:	89 55 14             	mov    %edx,0x14(%ebp)
  80182e:	8b 00                	mov    (%eax),%eax
  801830:	99                   	cltd   
  801831:	31 d0                	xor    %edx,%eax
  801833:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801835:	83 f8 0f             	cmp    $0xf,%eax
  801838:	7f 0b                	jg     801845 <vprintfmt+0x142>
  80183a:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801841:	85 d2                	test   %edx,%edx
  801843:	75 18                	jne    80185d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801845:	50                   	push   %eax
  801846:	68 fb 23 80 00       	push   $0x8023fb
  80184b:	53                   	push   %ebx
  80184c:	56                   	push   %esi
  80184d:	e8 94 fe ff ff       	call   8016e6 <printfmt>
  801852:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801858:	e9 cc fe ff ff       	jmp    801729 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80185d:	52                   	push   %edx
  80185e:	68 41 23 80 00       	push   $0x802341
  801863:	53                   	push   %ebx
  801864:	56                   	push   %esi
  801865:	e8 7c fe ff ff       	call   8016e6 <printfmt>
  80186a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801870:	e9 b4 fe ff ff       	jmp    801729 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801875:	8b 45 14             	mov    0x14(%ebp),%eax
  801878:	8d 50 04             	lea    0x4(%eax),%edx
  80187b:	89 55 14             	mov    %edx,0x14(%ebp)
  80187e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801880:	85 ff                	test   %edi,%edi
  801882:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801887:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80188a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80188e:	0f 8e 94 00 00 00    	jle    801928 <vprintfmt+0x225>
  801894:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801898:	0f 84 98 00 00 00    	je     801936 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80189e:	83 ec 08             	sub    $0x8,%esp
  8018a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8018a4:	57                   	push   %edi
  8018a5:	e8 86 02 00 00       	call   801b30 <strnlen>
  8018aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018ad:	29 c1                	sub    %eax,%ecx
  8018af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018bf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c1:	eb 0f                	jmp    8018d2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	53                   	push   %ebx
  8018c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018cc:	83 ef 01             	sub    $0x1,%edi
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 ff                	test   %edi,%edi
  8018d4:	7f ed                	jg     8018c3 <vprintfmt+0x1c0>
  8018d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018dc:	85 c9                	test   %ecx,%ecx
  8018de:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e3:	0f 49 c1             	cmovns %ecx,%eax
  8018e6:	29 c1                	sub    %eax,%ecx
  8018e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8018eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f1:	89 cb                	mov    %ecx,%ebx
  8018f3:	eb 4d                	jmp    801942 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018f9:	74 1b                	je     801916 <vprintfmt+0x213>
  8018fb:	0f be c0             	movsbl %al,%eax
  8018fe:	83 e8 20             	sub    $0x20,%eax
  801901:	83 f8 5e             	cmp    $0x5e,%eax
  801904:	76 10                	jbe    801916 <vprintfmt+0x213>
					putch('?', putdat);
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	ff 75 0c             	pushl  0xc(%ebp)
  80190c:	6a 3f                	push   $0x3f
  80190e:	ff 55 08             	call   *0x8(%ebp)
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	eb 0d                	jmp    801923 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	ff 75 0c             	pushl  0xc(%ebp)
  80191c:	52                   	push   %edx
  80191d:	ff 55 08             	call   *0x8(%ebp)
  801920:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801923:	83 eb 01             	sub    $0x1,%ebx
  801926:	eb 1a                	jmp    801942 <vprintfmt+0x23f>
  801928:	89 75 08             	mov    %esi,0x8(%ebp)
  80192b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80192e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801931:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801934:	eb 0c                	jmp    801942 <vprintfmt+0x23f>
  801936:	89 75 08             	mov    %esi,0x8(%ebp)
  801939:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80193c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80193f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801942:	83 c7 01             	add    $0x1,%edi
  801945:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801949:	0f be d0             	movsbl %al,%edx
  80194c:	85 d2                	test   %edx,%edx
  80194e:	74 23                	je     801973 <vprintfmt+0x270>
  801950:	85 f6                	test   %esi,%esi
  801952:	78 a1                	js     8018f5 <vprintfmt+0x1f2>
  801954:	83 ee 01             	sub    $0x1,%esi
  801957:	79 9c                	jns    8018f5 <vprintfmt+0x1f2>
  801959:	89 df                	mov    %ebx,%edi
  80195b:	8b 75 08             	mov    0x8(%ebp),%esi
  80195e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801961:	eb 18                	jmp    80197b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	53                   	push   %ebx
  801967:	6a 20                	push   $0x20
  801969:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80196b:	83 ef 01             	sub    $0x1,%edi
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	eb 08                	jmp    80197b <vprintfmt+0x278>
  801973:	89 df                	mov    %ebx,%edi
  801975:	8b 75 08             	mov    0x8(%ebp),%esi
  801978:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80197b:	85 ff                	test   %edi,%edi
  80197d:	7f e4                	jg     801963 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801982:	e9 a2 fd ff ff       	jmp    801729 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801987:	83 fa 01             	cmp    $0x1,%edx
  80198a:	7e 16                	jle    8019a2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80198c:	8b 45 14             	mov    0x14(%ebp),%eax
  80198f:	8d 50 08             	lea    0x8(%eax),%edx
  801992:	89 55 14             	mov    %edx,0x14(%ebp)
  801995:	8b 50 04             	mov    0x4(%eax),%edx
  801998:	8b 00                	mov    (%eax),%eax
  80199a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a0:	eb 32                	jmp    8019d4 <vprintfmt+0x2d1>
	else if (lflag)
  8019a2:	85 d2                	test   %edx,%edx
  8019a4:	74 18                	je     8019be <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a9:	8d 50 04             	lea    0x4(%eax),%edx
  8019ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8019af:	8b 00                	mov    (%eax),%eax
  8019b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b4:	89 c1                	mov    %eax,%ecx
  8019b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019bc:	eb 16                	jmp    8019d4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019be:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c1:	8d 50 04             	lea    0x4(%eax),%edx
  8019c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c7:	8b 00                	mov    (%eax),%eax
  8019c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019cc:	89 c1                	mov    %eax,%ecx
  8019ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8019d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019da:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019e3:	79 74                	jns    801a59 <vprintfmt+0x356>
				putch('-', putdat);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	53                   	push   %ebx
  8019e9:	6a 2d                	push   $0x2d
  8019eb:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019f3:	f7 d8                	neg    %eax
  8019f5:	83 d2 00             	adc    $0x0,%edx
  8019f8:	f7 da                	neg    %edx
  8019fa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a02:	eb 55                	jmp    801a59 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a04:	8d 45 14             	lea    0x14(%ebp),%eax
  801a07:	e8 83 fc ff ff       	call   80168f <getuint>
			base = 10;
  801a0c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a11:	eb 46                	jmp    801a59 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a13:	8d 45 14             	lea    0x14(%ebp),%eax
  801a16:	e8 74 fc ff ff       	call   80168f <getuint>
		        base = 8;
  801a1b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a20:	eb 37                	jmp    801a59 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	53                   	push   %ebx
  801a26:	6a 30                	push   $0x30
  801a28:	ff d6                	call   *%esi
			putch('x', putdat);
  801a2a:	83 c4 08             	add    $0x8,%esp
  801a2d:	53                   	push   %ebx
  801a2e:	6a 78                	push   $0x78
  801a30:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a32:	8b 45 14             	mov    0x14(%ebp),%eax
  801a35:	8d 50 04             	lea    0x4(%eax),%edx
  801a38:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a3b:	8b 00                	mov    (%eax),%eax
  801a3d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a42:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a45:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a4a:	eb 0d                	jmp    801a59 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a4c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4f:	e8 3b fc ff ff       	call   80168f <getuint>
			base = 16;
  801a54:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a60:	57                   	push   %edi
  801a61:	ff 75 e0             	pushl  -0x20(%ebp)
  801a64:	51                   	push   %ecx
  801a65:	52                   	push   %edx
  801a66:	50                   	push   %eax
  801a67:	89 da                	mov    %ebx,%edx
  801a69:	89 f0                	mov    %esi,%eax
  801a6b:	e8 70 fb ff ff       	call   8015e0 <printnum>
			break;
  801a70:	83 c4 20             	add    $0x20,%esp
  801a73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a76:	e9 ae fc ff ff       	jmp    801729 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a7b:	83 ec 08             	sub    $0x8,%esp
  801a7e:	53                   	push   %ebx
  801a7f:	51                   	push   %ecx
  801a80:	ff d6                	call   *%esi
			break;
  801a82:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a88:	e9 9c fc ff ff       	jmp    801729 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a8d:	83 ec 08             	sub    $0x8,%esp
  801a90:	53                   	push   %ebx
  801a91:	6a 25                	push   $0x25
  801a93:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	eb 03                	jmp    801a9d <vprintfmt+0x39a>
  801a9a:	83 ef 01             	sub    $0x1,%edi
  801a9d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aa1:	75 f7                	jne    801a9a <vprintfmt+0x397>
  801aa3:	e9 81 fc ff ff       	jmp    801729 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5f                   	pop    %edi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 18             	sub    $0x18,%esp
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801abf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801acd:	85 c0                	test   %eax,%eax
  801acf:	74 26                	je     801af7 <vsnprintf+0x47>
  801ad1:	85 d2                	test   %edx,%edx
  801ad3:	7e 22                	jle    801af7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad5:	ff 75 14             	pushl  0x14(%ebp)
  801ad8:	ff 75 10             	pushl  0x10(%ebp)
  801adb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	68 c9 16 80 00       	push   $0x8016c9
  801ae4:	e8 1a fc ff ff       	call   801703 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	eb 05                	jmp    801afc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b04:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b07:	50                   	push   %eax
  801b08:	ff 75 10             	pushl  0x10(%ebp)
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	ff 75 08             	pushl  0x8(%ebp)
  801b11:	e8 9a ff ff ff       	call   801ab0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b23:	eb 03                	jmp    801b28 <strlen+0x10>
		n++;
  801b25:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b28:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b2c:	75 f7                	jne    801b25 <strlen+0xd>
		n++;
	return n;
}
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b36:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b39:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3e:	eb 03                	jmp    801b43 <strnlen+0x13>
		n++;
  801b40:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b43:	39 c2                	cmp    %eax,%edx
  801b45:	74 08                	je     801b4f <strnlen+0x1f>
  801b47:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b4b:	75 f3                	jne    801b40 <strnlen+0x10>
  801b4d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	53                   	push   %ebx
  801b55:	8b 45 08             	mov    0x8(%ebp),%eax
  801b58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b5b:	89 c2                	mov    %eax,%edx
  801b5d:	83 c2 01             	add    $0x1,%edx
  801b60:	83 c1 01             	add    $0x1,%ecx
  801b63:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b67:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b6a:	84 db                	test   %bl,%bl
  801b6c:	75 ef                	jne    801b5d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b6e:	5b                   	pop    %ebx
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	53                   	push   %ebx
  801b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b78:	53                   	push   %ebx
  801b79:	e8 9a ff ff ff       	call   801b18 <strlen>
  801b7e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	01 d8                	add    %ebx,%eax
  801b86:	50                   	push   %eax
  801b87:	e8 c5 ff ff ff       	call   801b51 <strcpy>
	return dst;
}
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9e:	89 f3                	mov    %esi,%ebx
  801ba0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba3:	89 f2                	mov    %esi,%edx
  801ba5:	eb 0f                	jmp    801bb6 <strncpy+0x23>
		*dst++ = *src;
  801ba7:	83 c2 01             	add    $0x1,%edx
  801baa:	0f b6 01             	movzbl (%ecx),%eax
  801bad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb0:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb6:	39 da                	cmp    %ebx,%edx
  801bb8:	75 ed                	jne    801ba7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bba:	89 f0                	mov    %esi,%eax
  801bbc:	5b                   	pop    %ebx
  801bbd:	5e                   	pop    %esi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcb:	8b 55 10             	mov    0x10(%ebp),%edx
  801bce:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd0:	85 d2                	test   %edx,%edx
  801bd2:	74 21                	je     801bf5 <strlcpy+0x35>
  801bd4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd8:	89 f2                	mov    %esi,%edx
  801bda:	eb 09                	jmp    801be5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bdc:	83 c2 01             	add    $0x1,%edx
  801bdf:	83 c1 01             	add    $0x1,%ecx
  801be2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be5:	39 c2                	cmp    %eax,%edx
  801be7:	74 09                	je     801bf2 <strlcpy+0x32>
  801be9:	0f b6 19             	movzbl (%ecx),%ebx
  801bec:	84 db                	test   %bl,%bl
  801bee:	75 ec                	jne    801bdc <strlcpy+0x1c>
  801bf0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bf2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf5:	29 f0                	sub    %esi,%eax
}
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c04:	eb 06                	jmp    801c0c <strcmp+0x11>
		p++, q++;
  801c06:	83 c1 01             	add    $0x1,%ecx
  801c09:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c0c:	0f b6 01             	movzbl (%ecx),%eax
  801c0f:	84 c0                	test   %al,%al
  801c11:	74 04                	je     801c17 <strcmp+0x1c>
  801c13:	3a 02                	cmp    (%edx),%al
  801c15:	74 ef                	je     801c06 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c17:	0f b6 c0             	movzbl %al,%eax
  801c1a:	0f b6 12             	movzbl (%edx),%edx
  801c1d:	29 d0                	sub    %edx,%eax
}
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	53                   	push   %ebx
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2b:	89 c3                	mov    %eax,%ebx
  801c2d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c30:	eb 06                	jmp    801c38 <strncmp+0x17>
		n--, p++, q++;
  801c32:	83 c0 01             	add    $0x1,%eax
  801c35:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c38:	39 d8                	cmp    %ebx,%eax
  801c3a:	74 15                	je     801c51 <strncmp+0x30>
  801c3c:	0f b6 08             	movzbl (%eax),%ecx
  801c3f:	84 c9                	test   %cl,%cl
  801c41:	74 04                	je     801c47 <strncmp+0x26>
  801c43:	3a 0a                	cmp    (%edx),%cl
  801c45:	74 eb                	je     801c32 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c47:	0f b6 00             	movzbl (%eax),%eax
  801c4a:	0f b6 12             	movzbl (%edx),%edx
  801c4d:	29 d0                	sub    %edx,%eax
  801c4f:	eb 05                	jmp    801c56 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c51:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c56:	5b                   	pop    %ebx
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c63:	eb 07                	jmp    801c6c <strchr+0x13>
		if (*s == c)
  801c65:	38 ca                	cmp    %cl,%dl
  801c67:	74 0f                	je     801c78 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c69:	83 c0 01             	add    $0x1,%eax
  801c6c:	0f b6 10             	movzbl (%eax),%edx
  801c6f:	84 d2                	test   %dl,%dl
  801c71:	75 f2                	jne    801c65 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c84:	eb 03                	jmp    801c89 <strfind+0xf>
  801c86:	83 c0 01             	add    $0x1,%eax
  801c89:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c8c:	38 ca                	cmp    %cl,%dl
  801c8e:	74 04                	je     801c94 <strfind+0x1a>
  801c90:	84 d2                	test   %dl,%dl
  801c92:	75 f2                	jne    801c86 <strfind+0xc>
			break;
	return (char *) s;
}
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	57                   	push   %edi
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca2:	85 c9                	test   %ecx,%ecx
  801ca4:	74 36                	je     801cdc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cac:	75 28                	jne    801cd6 <memset+0x40>
  801cae:	f6 c1 03             	test   $0x3,%cl
  801cb1:	75 23                	jne    801cd6 <memset+0x40>
		c &= 0xFF;
  801cb3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb7:	89 d3                	mov    %edx,%ebx
  801cb9:	c1 e3 08             	shl    $0x8,%ebx
  801cbc:	89 d6                	mov    %edx,%esi
  801cbe:	c1 e6 18             	shl    $0x18,%esi
  801cc1:	89 d0                	mov    %edx,%eax
  801cc3:	c1 e0 10             	shl    $0x10,%eax
  801cc6:	09 f0                	or     %esi,%eax
  801cc8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cca:	89 d8                	mov    %ebx,%eax
  801ccc:	09 d0                	or     %edx,%eax
  801cce:	c1 e9 02             	shr    $0x2,%ecx
  801cd1:	fc                   	cld    
  801cd2:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd4:	eb 06                	jmp    801cdc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd9:	fc                   	cld    
  801cda:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cdc:	89 f8                	mov    %edi,%eax
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5f                   	pop    %edi
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	57                   	push   %edi
  801ce7:	56                   	push   %esi
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf1:	39 c6                	cmp    %eax,%esi
  801cf3:	73 35                	jae    801d2a <memmove+0x47>
  801cf5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf8:	39 d0                	cmp    %edx,%eax
  801cfa:	73 2e                	jae    801d2a <memmove+0x47>
		s += n;
		d += n;
  801cfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cff:	89 d6                	mov    %edx,%esi
  801d01:	09 fe                	or     %edi,%esi
  801d03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d09:	75 13                	jne    801d1e <memmove+0x3b>
  801d0b:	f6 c1 03             	test   $0x3,%cl
  801d0e:	75 0e                	jne    801d1e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d10:	83 ef 04             	sub    $0x4,%edi
  801d13:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d16:	c1 e9 02             	shr    $0x2,%ecx
  801d19:	fd                   	std    
  801d1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d1c:	eb 09                	jmp    801d27 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d1e:	83 ef 01             	sub    $0x1,%edi
  801d21:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d24:	fd                   	std    
  801d25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d27:	fc                   	cld    
  801d28:	eb 1d                	jmp    801d47 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2a:	89 f2                	mov    %esi,%edx
  801d2c:	09 c2                	or     %eax,%edx
  801d2e:	f6 c2 03             	test   $0x3,%dl
  801d31:	75 0f                	jne    801d42 <memmove+0x5f>
  801d33:	f6 c1 03             	test   $0x3,%cl
  801d36:	75 0a                	jne    801d42 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d38:	c1 e9 02             	shr    $0x2,%ecx
  801d3b:	89 c7                	mov    %eax,%edi
  801d3d:	fc                   	cld    
  801d3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d40:	eb 05                	jmp    801d47 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d42:	89 c7                	mov    %eax,%edi
  801d44:	fc                   	cld    
  801d45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d47:	5e                   	pop    %esi
  801d48:	5f                   	pop    %edi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d4e:	ff 75 10             	pushl  0x10(%ebp)
  801d51:	ff 75 0c             	pushl  0xc(%ebp)
  801d54:	ff 75 08             	pushl  0x8(%ebp)
  801d57:	e8 87 ff ff ff       	call   801ce3 <memmove>
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	8b 45 08             	mov    0x8(%ebp),%eax
  801d66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d69:	89 c6                	mov    %eax,%esi
  801d6b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d6e:	eb 1a                	jmp    801d8a <memcmp+0x2c>
		if (*s1 != *s2)
  801d70:	0f b6 08             	movzbl (%eax),%ecx
  801d73:	0f b6 1a             	movzbl (%edx),%ebx
  801d76:	38 d9                	cmp    %bl,%cl
  801d78:	74 0a                	je     801d84 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d7a:	0f b6 c1             	movzbl %cl,%eax
  801d7d:	0f b6 db             	movzbl %bl,%ebx
  801d80:	29 d8                	sub    %ebx,%eax
  801d82:	eb 0f                	jmp    801d93 <memcmp+0x35>
		s1++, s2++;
  801d84:	83 c0 01             	add    $0x1,%eax
  801d87:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8a:	39 f0                	cmp    %esi,%eax
  801d8c:	75 e2                	jne    801d70 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	53                   	push   %ebx
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d9e:	89 c1                	mov    %eax,%ecx
  801da0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da7:	eb 0a                	jmp    801db3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da9:	0f b6 10             	movzbl (%eax),%edx
  801dac:	39 da                	cmp    %ebx,%edx
  801dae:	74 07                	je     801db7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db0:	83 c0 01             	add    $0x1,%eax
  801db3:	39 c8                	cmp    %ecx,%eax
  801db5:	72 f2                	jb     801da9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db7:	5b                   	pop    %ebx
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    

00801dba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	57                   	push   %edi
  801dbe:	56                   	push   %esi
  801dbf:	53                   	push   %ebx
  801dc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc6:	eb 03                	jmp    801dcb <strtol+0x11>
		s++;
  801dc8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dcb:	0f b6 01             	movzbl (%ecx),%eax
  801dce:	3c 20                	cmp    $0x20,%al
  801dd0:	74 f6                	je     801dc8 <strtol+0xe>
  801dd2:	3c 09                	cmp    $0x9,%al
  801dd4:	74 f2                	je     801dc8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd6:	3c 2b                	cmp    $0x2b,%al
  801dd8:	75 0a                	jne    801de4 <strtol+0x2a>
		s++;
  801dda:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ddd:	bf 00 00 00 00       	mov    $0x0,%edi
  801de2:	eb 11                	jmp    801df5 <strtol+0x3b>
  801de4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de9:	3c 2d                	cmp    $0x2d,%al
  801deb:	75 08                	jne    801df5 <strtol+0x3b>
		s++, neg = 1;
  801ded:	83 c1 01             	add    $0x1,%ecx
  801df0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfb:	75 15                	jne    801e12 <strtol+0x58>
  801dfd:	80 39 30             	cmpb   $0x30,(%ecx)
  801e00:	75 10                	jne    801e12 <strtol+0x58>
  801e02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e06:	75 7c                	jne    801e84 <strtol+0xca>
		s += 2, base = 16;
  801e08:	83 c1 02             	add    $0x2,%ecx
  801e0b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e10:	eb 16                	jmp    801e28 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e12:	85 db                	test   %ebx,%ebx
  801e14:	75 12                	jne    801e28 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e16:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e1b:	80 39 30             	cmpb   $0x30,(%ecx)
  801e1e:	75 08                	jne    801e28 <strtol+0x6e>
		s++, base = 8;
  801e20:	83 c1 01             	add    $0x1,%ecx
  801e23:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e28:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e30:	0f b6 11             	movzbl (%ecx),%edx
  801e33:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e36:	89 f3                	mov    %esi,%ebx
  801e38:	80 fb 09             	cmp    $0x9,%bl
  801e3b:	77 08                	ja     801e45 <strtol+0x8b>
			dig = *s - '0';
  801e3d:	0f be d2             	movsbl %dl,%edx
  801e40:	83 ea 30             	sub    $0x30,%edx
  801e43:	eb 22                	jmp    801e67 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e45:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e48:	89 f3                	mov    %esi,%ebx
  801e4a:	80 fb 19             	cmp    $0x19,%bl
  801e4d:	77 08                	ja     801e57 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e4f:	0f be d2             	movsbl %dl,%edx
  801e52:	83 ea 57             	sub    $0x57,%edx
  801e55:	eb 10                	jmp    801e67 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e57:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e5a:	89 f3                	mov    %esi,%ebx
  801e5c:	80 fb 19             	cmp    $0x19,%bl
  801e5f:	77 16                	ja     801e77 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e61:	0f be d2             	movsbl %dl,%edx
  801e64:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e67:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e6a:	7d 0b                	jge    801e77 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e6c:	83 c1 01             	add    $0x1,%ecx
  801e6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e73:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e75:	eb b9                	jmp    801e30 <strtol+0x76>

	if (endptr)
  801e77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e7b:	74 0d                	je     801e8a <strtol+0xd0>
		*endptr = (char *) s;
  801e7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e80:	89 0e                	mov    %ecx,(%esi)
  801e82:	eb 06                	jmp    801e8a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e84:	85 db                	test   %ebx,%ebx
  801e86:	74 98                	je     801e20 <strtol+0x66>
  801e88:	eb 9e                	jmp    801e28 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e8a:	89 c2                	mov    %eax,%edx
  801e8c:	f7 da                	neg    %edx
  801e8e:	85 ff                	test   %edi,%edi
  801e90:	0f 45 c2             	cmovne %edx,%eax
}
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	56                   	push   %esi
  801e9c:	53                   	push   %ebx
  801e9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	74 0e                	je     801eb8 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	50                   	push   %eax
  801eae:	e8 6a e4 ff ff       	call   80031d <sys_ipc_recv>
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	eb 10                	jmp    801ec8 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801eb8:	83 ec 0c             	sub    $0xc,%esp
  801ebb:	68 00 00 00 f0       	push   $0xf0000000
  801ec0:	e8 58 e4 ff ff       	call   80031d <sys_ipc_recv>
  801ec5:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	74 0e                	je     801eda <ipc_recv+0x42>
    	*from_env_store = 0;
  801ecc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ed2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801ed8:	eb 24                	jmp    801efe <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801eda:	85 f6                	test   %esi,%esi
  801edc:	74 0a                	je     801ee8 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ede:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee3:	8b 40 74             	mov    0x74(%eax),%eax
  801ee6:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801ee8:	85 db                	test   %ebx,%ebx
  801eea:	74 0a                	je     801ef6 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801eec:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef1:	8b 40 78             	mov    0x78(%eax),%eax
  801ef4:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801ef6:	a1 08 40 80 00       	mov    0x804008,%eax
  801efb:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801efe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f01:	5b                   	pop    %ebx
  801f02:	5e                   	pop    %esi
  801f03:	5d                   	pop    %ebp
  801f04:	c3                   	ret    

00801f05 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	57                   	push   %edi
  801f09:	56                   	push   %esi
  801f0a:	53                   	push   %ebx
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f11:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f17:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f1e:	0f 44 d8             	cmove  %eax,%ebx
  801f21:	eb 1c                	jmp    801f3f <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f23:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f26:	74 12                	je     801f3a <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f28:	50                   	push   %eax
  801f29:	68 e0 26 80 00       	push   $0x8026e0
  801f2e:	6a 4b                	push   $0x4b
  801f30:	68 f8 26 80 00       	push   $0x8026f8
  801f35:	e8 b9 f5 ff ff       	call   8014f3 <_panic>
        }	
        sys_yield();
  801f3a:	e8 0f e2 ff ff       	call   80014e <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f3f:	ff 75 14             	pushl  0x14(%ebp)
  801f42:	53                   	push   %ebx
  801f43:	56                   	push   %esi
  801f44:	57                   	push   %edi
  801f45:	e8 b0 e3 ff ff       	call   8002fa <sys_ipc_try_send>
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	75 d2                	jne    801f23 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f64:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f67:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f6d:	8b 52 50             	mov    0x50(%edx),%edx
  801f70:	39 ca                	cmp    %ecx,%edx
  801f72:	75 0d                	jne    801f81 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f74:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f77:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f7c:	8b 40 48             	mov    0x48(%eax),%eax
  801f7f:	eb 0f                	jmp    801f90 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f81:	83 c0 01             	add    $0x1,%eax
  801f84:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f89:	75 d9                	jne    801f64 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f98:	89 d0                	mov    %edx,%eax
  801f9a:	c1 e8 16             	shr    $0x16,%eax
  801f9d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa9:	f6 c1 01             	test   $0x1,%cl
  801fac:	74 1d                	je     801fcb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fae:	c1 ea 0c             	shr    $0xc,%edx
  801fb1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb8:	f6 c2 01             	test   $0x1,%dl
  801fbb:	74 0e                	je     801fcb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fbd:	c1 ea 0c             	shr    $0xc,%edx
  801fc0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc7:	ef 
  801fc8:	0f b7 c0             	movzwl %ax,%eax
}
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

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
