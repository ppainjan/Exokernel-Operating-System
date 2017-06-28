
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 6f 00 00 00       	call   8000b4 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800055:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80005c:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x37>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 c7 04 00 00       	call   80056c <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 6a 22 80 00       	push   $0x80226a
  80011e:	6a 23                	push   $0x23
  800120:	68 87 22 80 00       	push   $0x802287
  800125:	e8 cc 13 00 00       	call   8014f6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 6a 22 80 00       	push   $0x80226a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 87 22 80 00       	push   $0x802287
  8001a6:	e8 4b 13 00 00       	call   8014f6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 6a 22 80 00       	push   $0x80226a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 87 22 80 00       	push   $0x802287
  8001e8:	e8 09 13 00 00       	call   8014f6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 6a 22 80 00       	push   $0x80226a
  800223:	6a 23                	push   $0x23
  800225:	68 87 22 80 00       	push   $0x802287
  80022a:	e8 c7 12 00 00       	call   8014f6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 6a 22 80 00       	push   $0x80226a
  800265:	6a 23                	push   $0x23
  800267:	68 87 22 80 00       	push   $0x802287
  80026c:	e8 85 12 00 00       	call   8014f6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 6a 22 80 00       	push   $0x80226a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 87 22 80 00       	push   $0x802287
  8002ae:	e8 43 12 00 00       	call   8014f6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 6a 22 80 00       	push   $0x80226a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 87 22 80 00       	push   $0x802287
  8002f0:	e8 01 12 00 00       	call   8014f6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 6a 22 80 00       	push   $0x80226a
  80034d:	6a 23                	push   $0x23
  80034f:	68 87 22 80 00       	push   $0x802287
  800354:	e8 9d 11 00 00       	call   8014f6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800371:	89 d1                	mov    %edx,%ecx
  800373:	89 d3                	mov    %edx,%ebx
  800375:	89 d7                	mov    %edx,%edi
  800377:	89 d6                	mov    %edx,%esi
  800379:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800386:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800390:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800393:	8b 55 08             	mov    0x8(%ebp),%edx
  800396:	89 df                	mov    %ebx,%edi
  800398:	89 de                	mov    %ebx,%esi
  80039a:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  80039c:	5b                   	pop    %ebx
  80039d:	5e                   	pop    %esi
  80039e:	5f                   	pop    %edi
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ac:	c1 e8 0c             	shr    $0xc,%eax
}
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d3:	89 c2                	mov    %eax,%edx
  8003d5:	c1 ea 16             	shr    $0x16,%edx
  8003d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003df:	f6 c2 01             	test   $0x1,%dl
  8003e2:	74 11                	je     8003f5 <fd_alloc+0x2d>
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 0c             	shr    $0xc,%edx
  8003e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	75 09                	jne    8003fe <fd_alloc+0x36>
			*fd_store = fd;
  8003f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 17                	jmp    800415 <fd_alloc+0x4d>
  8003fe:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800403:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800408:	75 c9                	jne    8003d3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80040a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800410:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80041d:	83 f8 1f             	cmp    $0x1f,%eax
  800420:	77 36                	ja     800458 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800422:	c1 e0 0c             	shl    $0xc,%eax
  800425:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	c1 ea 16             	shr    $0x16,%edx
  80042f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800436:	f6 c2 01             	test   $0x1,%dl
  800439:	74 24                	je     80045f <fd_lookup+0x48>
  80043b:	89 c2                	mov    %eax,%edx
  80043d:	c1 ea 0c             	shr    $0xc,%edx
  800440:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800447:	f6 c2 01             	test   $0x1,%dl
  80044a:	74 1a                	je     800466 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044f:	89 02                	mov    %eax,(%edx)
	return 0;
  800451:	b8 00 00 00 00       	mov    $0x0,%eax
  800456:	eb 13                	jmp    80046b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800458:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045d:	eb 0c                	jmp    80046b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800464:	eb 05                	jmp    80046b <fd_lookup+0x54>
  800466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    

0080046d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800476:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80047b:	eb 13                	jmp    800490 <dev_lookup+0x23>
  80047d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800480:	39 08                	cmp    %ecx,(%eax)
  800482:	75 0c                	jne    800490 <dev_lookup+0x23>
			*dev = devtab[i];
  800484:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800487:	89 01                	mov    %eax,(%ecx)
			return 0;
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	eb 2e                	jmp    8004be <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800490:	8b 02                	mov    (%edx),%eax
  800492:	85 c0                	test   %eax,%eax
  800494:	75 e7                	jne    80047d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800496:	a1 08 40 80 00       	mov    0x804008,%eax
  80049b:	8b 40 48             	mov    0x48(%eax),%eax
  80049e:	83 ec 04             	sub    $0x4,%esp
  8004a1:	51                   	push   %ecx
  8004a2:	50                   	push   %eax
  8004a3:	68 98 22 80 00       	push   $0x802298
  8004a8:	e8 22 11 00 00       	call   8015cf <cprintf>
	*dev = 0;
  8004ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004be:	c9                   	leave  
  8004bf:	c3                   	ret    

008004c0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	56                   	push   %esi
  8004c4:	53                   	push   %ebx
  8004c5:	83 ec 10             	sub    $0x10,%esp
  8004c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d1:	50                   	push   %eax
  8004d2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d8:	c1 e8 0c             	shr    $0xc,%eax
  8004db:	50                   	push   %eax
  8004dc:	e8 36 ff ff ff       	call   800417 <fd_lookup>
  8004e1:	83 c4 08             	add    $0x8,%esp
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	78 05                	js     8004ed <fd_close+0x2d>
	    || fd != fd2)
  8004e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004eb:	74 0c                	je     8004f9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004ed:	84 db                	test   %bl,%bl
  8004ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f4:	0f 44 c2             	cmove  %edx,%eax
  8004f7:	eb 41                	jmp    80053a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ff:	50                   	push   %eax
  800500:	ff 36                	pushl  (%esi)
  800502:	e8 66 ff ff ff       	call   80046d <dev_lookup>
  800507:	89 c3                	mov    %eax,%ebx
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 1a                	js     80052a <fd_close+0x6a>
		if (dev->dev_close)
  800510:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800513:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800516:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80051b:	85 c0                	test   %eax,%eax
  80051d:	74 0b                	je     80052a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80051f:	83 ec 0c             	sub    $0xc,%esp
  800522:	56                   	push   %esi
  800523:	ff d0                	call   *%eax
  800525:	89 c3                	mov    %eax,%ebx
  800527:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	56                   	push   %esi
  80052e:	6a 00                	push   $0x0
  800530:	e8 c0 fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	89 d8                	mov    %ebx,%eax
}
  80053a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80053d:	5b                   	pop    %ebx
  80053e:	5e                   	pop    %esi
  80053f:	5d                   	pop    %ebp
  800540:	c3                   	ret    

00800541 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 c4 fe ff ff       	call   800417 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	78 10                	js     80056a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	6a 01                	push   $0x1
  80055f:	ff 75 f4             	pushl  -0xc(%ebp)
  800562:	e8 59 ff ff ff       	call   8004c0 <fd_close>
  800567:	83 c4 10             	add    $0x10,%esp
}
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <close_all>:

void
close_all(void)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	53                   	push   %ebx
  800570:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800573:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	53                   	push   %ebx
  80057c:	e8 c0 ff ff ff       	call   800541 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800581:	83 c3 01             	add    $0x1,%ebx
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	83 fb 20             	cmp    $0x20,%ebx
  80058a:	75 ec                	jne    800578 <close_all+0xc>
		close(i);
}
  80058c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	57                   	push   %edi
  800595:	56                   	push   %esi
  800596:	53                   	push   %ebx
  800597:	83 ec 2c             	sub    $0x2c,%esp
  80059a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80059d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a0:	50                   	push   %eax
  8005a1:	ff 75 08             	pushl  0x8(%ebp)
  8005a4:	e8 6e fe ff ff       	call   800417 <fd_lookup>
  8005a9:	83 c4 08             	add    $0x8,%esp
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	0f 88 c1 00 00 00    	js     800675 <dup+0xe4>
		return r;
	close(newfdnum);
  8005b4:	83 ec 0c             	sub    $0xc,%esp
  8005b7:	56                   	push   %esi
  8005b8:	e8 84 ff ff ff       	call   800541 <close>

	newfd = INDEX2FD(newfdnum);
  8005bd:	89 f3                	mov    %esi,%ebx
  8005bf:	c1 e3 0c             	shl    $0xc,%ebx
  8005c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c8:	83 c4 04             	add    $0x4,%esp
  8005cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ce:	e8 de fd ff ff       	call   8003b1 <fd2data>
  8005d3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005d5:	89 1c 24             	mov    %ebx,(%esp)
  8005d8:	e8 d4 fd ff ff       	call   8003b1 <fd2data>
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e3:	89 f8                	mov    %edi,%eax
  8005e5:	c1 e8 16             	shr    $0x16,%eax
  8005e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ef:	a8 01                	test   $0x1,%al
  8005f1:	74 37                	je     80062a <dup+0x99>
  8005f3:	89 f8                	mov    %edi,%eax
  8005f5:	c1 e8 0c             	shr    $0xc,%eax
  8005f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ff:	f6 c2 01             	test   $0x1,%dl
  800602:	74 26                	je     80062a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800604:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	25 07 0e 00 00       	and    $0xe07,%eax
  800613:	50                   	push   %eax
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	57                   	push   %edi
  80061a:	6a 00                	push   $0x0
  80061c:	e8 92 fb ff ff       	call   8001b3 <sys_page_map>
  800621:	89 c7                	mov    %eax,%edi
  800623:	83 c4 20             	add    $0x20,%esp
  800626:	85 c0                	test   %eax,%eax
  800628:	78 2e                	js     800658 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062d:	89 d0                	mov    %edx,%eax
  80062f:	c1 e8 0c             	shr    $0xc,%eax
  800632:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800639:	83 ec 0c             	sub    $0xc,%esp
  80063c:	25 07 0e 00 00       	and    $0xe07,%eax
  800641:	50                   	push   %eax
  800642:	53                   	push   %ebx
  800643:	6a 00                	push   $0x0
  800645:	52                   	push   %edx
  800646:	6a 00                	push   $0x0
  800648:	e8 66 fb ff ff       	call   8001b3 <sys_page_map>
  80064d:	89 c7                	mov    %eax,%edi
  80064f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800652:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800654:	85 ff                	test   %edi,%edi
  800656:	79 1d                	jns    800675 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 00                	push   $0x0
  80065e:	e8 92 fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	ff 75 d4             	pushl  -0x2c(%ebp)
  800669:	6a 00                	push   $0x0
  80066b:	e8 85 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	89 f8                	mov    %edi,%eax
}
  800675:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800678:	5b                   	pop    %ebx
  800679:	5e                   	pop    %esi
  80067a:	5f                   	pop    %edi
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	53                   	push   %ebx
  800681:	83 ec 14             	sub    $0x14,%esp
  800684:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800687:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80068a:	50                   	push   %eax
  80068b:	53                   	push   %ebx
  80068c:	e8 86 fd ff ff       	call   800417 <fd_lookup>
  800691:	83 c4 08             	add    $0x8,%esp
  800694:	89 c2                	mov    %eax,%edx
  800696:	85 c0                	test   %eax,%eax
  800698:	78 6d                	js     800707 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a0:	50                   	push   %eax
  8006a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a4:	ff 30                	pushl  (%eax)
  8006a6:	e8 c2 fd ff ff       	call   80046d <dev_lookup>
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	78 4c                	js     8006fe <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b5:	8b 42 08             	mov    0x8(%edx),%eax
  8006b8:	83 e0 03             	and    $0x3,%eax
  8006bb:	83 f8 01             	cmp    $0x1,%eax
  8006be:	75 21                	jne    8006e1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8006c5:	8b 40 48             	mov    0x48(%eax),%eax
  8006c8:	83 ec 04             	sub    $0x4,%esp
  8006cb:	53                   	push   %ebx
  8006cc:	50                   	push   %eax
  8006cd:	68 d9 22 80 00       	push   $0x8022d9
  8006d2:	e8 f8 0e 00 00       	call   8015cf <cprintf>
		return -E_INVAL;
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006df:	eb 26                	jmp    800707 <read+0x8a>
	}
	if (!dev->dev_read)
  8006e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e4:	8b 40 08             	mov    0x8(%eax),%eax
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	74 17                	je     800702 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006eb:	83 ec 04             	sub    $0x4,%esp
  8006ee:	ff 75 10             	pushl  0x10(%ebp)
  8006f1:	ff 75 0c             	pushl  0xc(%ebp)
  8006f4:	52                   	push   %edx
  8006f5:	ff d0                	call   *%eax
  8006f7:	89 c2                	mov    %eax,%edx
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 09                	jmp    800707 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fe:	89 c2                	mov    %eax,%edx
  800700:	eb 05                	jmp    800707 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800702:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800707:	89 d0                	mov    %edx,%eax
  800709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    

0080070e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	57                   	push   %edi
  800712:	56                   	push   %esi
  800713:	53                   	push   %ebx
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800722:	eb 21                	jmp    800745 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800724:	83 ec 04             	sub    $0x4,%esp
  800727:	89 f0                	mov    %esi,%eax
  800729:	29 d8                	sub    %ebx,%eax
  80072b:	50                   	push   %eax
  80072c:	89 d8                	mov    %ebx,%eax
  80072e:	03 45 0c             	add    0xc(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	57                   	push   %edi
  800733:	e8 45 ff ff ff       	call   80067d <read>
		if (m < 0)
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 10                	js     80074f <readn+0x41>
			return m;
		if (m == 0)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 0a                	je     80074d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800743:	01 c3                	add    %eax,%ebx
  800745:	39 f3                	cmp    %esi,%ebx
  800747:	72 db                	jb     800724 <readn+0x16>
  800749:	89 d8                	mov    %ebx,%eax
  80074b:	eb 02                	jmp    80074f <readn+0x41>
  80074d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80074f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800752:	5b                   	pop    %ebx
  800753:	5e                   	pop    %esi
  800754:	5f                   	pop    %edi
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	83 ec 14             	sub    $0x14,%esp
  80075e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800761:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	53                   	push   %ebx
  800766:	e8 ac fc ff ff       	call   800417 <fd_lookup>
  80076b:	83 c4 08             	add    $0x8,%esp
  80076e:	89 c2                	mov    %eax,%edx
  800770:	85 c0                	test   %eax,%eax
  800772:	78 68                	js     8007dc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077a:	50                   	push   %eax
  80077b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077e:	ff 30                	pushl  (%eax)
  800780:	e8 e8 fc ff ff       	call   80046d <dev_lookup>
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	85 c0                	test   %eax,%eax
  80078a:	78 47                	js     8007d3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800793:	75 21                	jne    8007b6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800795:	a1 08 40 80 00       	mov    0x804008,%eax
  80079a:	8b 40 48             	mov    0x48(%eax),%eax
  80079d:	83 ec 04             	sub    $0x4,%esp
  8007a0:	53                   	push   %ebx
  8007a1:	50                   	push   %eax
  8007a2:	68 f5 22 80 00       	push   $0x8022f5
  8007a7:	e8 23 0e 00 00       	call   8015cf <cprintf>
		return -E_INVAL;
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007b4:	eb 26                	jmp    8007dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	74 17                	je     8007d7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c0:	83 ec 04             	sub    $0x4,%esp
  8007c3:	ff 75 10             	pushl  0x10(%ebp)
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	50                   	push   %eax
  8007ca:	ff d2                	call   *%edx
  8007cc:	89 c2                	mov    %eax,%edx
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	eb 09                	jmp    8007dc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	eb 05                	jmp    8007dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007dc:	89 d0                	mov    %edx,%eax
  8007de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007ec:	50                   	push   %eax
  8007ed:	ff 75 08             	pushl  0x8(%ebp)
  8007f0:	e8 22 fc ff ff       	call   800417 <fd_lookup>
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	85 c0                	test   %eax,%eax
  8007fa:	78 0e                	js     80080a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	83 ec 14             	sub    $0x14,%esp
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800816:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800819:	50                   	push   %eax
  80081a:	53                   	push   %ebx
  80081b:	e8 f7 fb ff ff       	call   800417 <fd_lookup>
  800820:	83 c4 08             	add    $0x8,%esp
  800823:	89 c2                	mov    %eax,%edx
  800825:	85 c0                	test   %eax,%eax
  800827:	78 65                	js     80088e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082f:	50                   	push   %eax
  800830:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800833:	ff 30                	pushl  (%eax)
  800835:	e8 33 fc ff ff       	call   80046d <dev_lookup>
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	85 c0                	test   %eax,%eax
  80083f:	78 44                	js     800885 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800841:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800844:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800848:	75 21                	jne    80086b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80084a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80084f:	8b 40 48             	mov    0x48(%eax),%eax
  800852:	83 ec 04             	sub    $0x4,%esp
  800855:	53                   	push   %ebx
  800856:	50                   	push   %eax
  800857:	68 b8 22 80 00       	push   $0x8022b8
  80085c:	e8 6e 0d 00 00       	call   8015cf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800869:	eb 23                	jmp    80088e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80086b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80086e:	8b 52 18             	mov    0x18(%edx),%edx
  800871:	85 d2                	test   %edx,%edx
  800873:	74 14                	je     800889 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	ff 75 0c             	pushl  0xc(%ebp)
  80087b:	50                   	push   %eax
  80087c:	ff d2                	call   *%edx
  80087e:	89 c2                	mov    %eax,%edx
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	eb 09                	jmp    80088e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	89 c2                	mov    %eax,%edx
  800887:	eb 05                	jmp    80088e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800889:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80088e:	89 d0                	mov    %edx,%eax
  800890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	83 ec 14             	sub    $0x14,%esp
  80089c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a2:	50                   	push   %eax
  8008a3:	ff 75 08             	pushl  0x8(%ebp)
  8008a6:	e8 6c fb ff ff       	call   800417 <fd_lookup>
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	89 c2                	mov    %eax,%edx
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	78 58                	js     80090c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ba:	50                   	push   %eax
  8008bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008be:	ff 30                	pushl  (%eax)
  8008c0:	e8 a8 fb ff ff       	call   80046d <dev_lookup>
  8008c5:	83 c4 10             	add    $0x10,%esp
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	78 37                	js     800903 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d3:	74 32                	je     800907 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008df:	00 00 00 
	stat->st_isdir = 0;
  8008e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e9:	00 00 00 
	stat->st_dev = dev;
  8008ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	53                   	push   %ebx
  8008f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8008f9:	ff 50 14             	call   *0x14(%eax)
  8008fc:	89 c2                	mov    %eax,%edx
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	eb 09                	jmp    80090c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800903:	89 c2                	mov    %eax,%edx
  800905:	eb 05                	jmp    80090c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800907:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80090c:	89 d0                	mov    %edx,%eax
  80090e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800918:	83 ec 08             	sub    $0x8,%esp
  80091b:	6a 00                	push   $0x0
  80091d:	ff 75 08             	pushl  0x8(%ebp)
  800920:	e8 e7 01 00 00       	call   800b0c <open>
  800925:	89 c3                	mov    %eax,%ebx
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	85 c0                	test   %eax,%eax
  80092c:	78 1b                	js     800949 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	ff 75 0c             	pushl  0xc(%ebp)
  800934:	50                   	push   %eax
  800935:	e8 5b ff ff ff       	call   800895 <fstat>
  80093a:	89 c6                	mov    %eax,%esi
	close(fd);
  80093c:	89 1c 24             	mov    %ebx,(%esp)
  80093f:	e8 fd fb ff ff       	call   800541 <close>
	return r;
  800944:	83 c4 10             	add    $0x10,%esp
  800947:	89 f0                	mov    %esi,%eax
}
  800949:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	89 c6                	mov    %eax,%esi
  800957:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800959:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800960:	75 12                	jne    800974 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800962:	83 ec 0c             	sub    $0xc,%esp
  800965:	6a 01                	push   $0x1
  800967:	e8 f0 15 00 00       	call   801f5c <ipc_find_env>
  80096c:	a3 00 40 80 00       	mov    %eax,0x804000
  800971:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800974:	6a 07                	push   $0x7
  800976:	68 00 50 80 00       	push   $0x805000
  80097b:	56                   	push   %esi
  80097c:	ff 35 00 40 80 00    	pushl  0x804000
  800982:	e8 81 15 00 00       	call   801f08 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800987:	83 c4 0c             	add    $0xc,%esp
  80098a:	6a 00                	push   $0x0
  80098c:	53                   	push   %ebx
  80098d:	6a 00                	push   $0x0
  80098f:	e8 07 15 00 00       	call   801e9b <ipc_recv>
}
  800994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009af:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b9:	b8 02 00 00 00       	mov    $0x2,%eax
  8009be:	e8 8d ff ff ff       	call   800950 <fsipc>
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009db:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e0:	e8 6b ff ff ff       	call   800950 <fsipc>
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	53                   	push   %ebx
  8009eb:	83 ec 04             	sub    $0x4,%esp
  8009ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800a01:	b8 05 00 00 00       	mov    $0x5,%eax
  800a06:	e8 45 ff ff ff       	call   800950 <fsipc>
  800a0b:	85 c0                	test   %eax,%eax
  800a0d:	78 2c                	js     800a3b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	68 00 50 80 00       	push   $0x805000
  800a17:	53                   	push   %ebx
  800a18:	e8 37 11 00 00       	call   801b54 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a1d:	a1 80 50 80 00       	mov    0x805080,%eax
  800a22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a28:	a1 84 50 80 00       	mov    0x805084,%eax
  800a2d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a4a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a4f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a54:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a57:	53                   	push   %ebx
  800a58:	ff 75 0c             	pushl  0xc(%ebp)
  800a5b:	68 08 50 80 00       	push   $0x805008
  800a60:	e8 81 12 00 00       	call   801ce6 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6b:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a70:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800a76:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a80:	e8 cb fe ff ff       	call   800950 <fsipc>
	//panic("devfile_write not implemented");
}
  800a85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a88:	c9                   	leave  
  800a89:	c3                   	ret    

00800a8a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8b 40 0c             	mov    0xc(%eax),%eax
  800a98:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a9d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa8:	b8 03 00 00 00       	mov    $0x3,%eax
  800aad:	e8 9e fe ff ff       	call   800950 <fsipc>
  800ab2:	89 c3                	mov    %eax,%ebx
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	78 4b                	js     800b03 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab8:	39 c6                	cmp    %eax,%esi
  800aba:	73 16                	jae    800ad2 <devfile_read+0x48>
  800abc:	68 28 23 80 00       	push   $0x802328
  800ac1:	68 2f 23 80 00       	push   $0x80232f
  800ac6:	6a 7c                	push   $0x7c
  800ac8:	68 44 23 80 00       	push   $0x802344
  800acd:	e8 24 0a 00 00       	call   8014f6 <_panic>
	assert(r <= PGSIZE);
  800ad2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad7:	7e 16                	jle    800aef <devfile_read+0x65>
  800ad9:	68 4f 23 80 00       	push   $0x80234f
  800ade:	68 2f 23 80 00       	push   $0x80232f
  800ae3:	6a 7d                	push   $0x7d
  800ae5:	68 44 23 80 00       	push   $0x802344
  800aea:	e8 07 0a 00 00       	call   8014f6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aef:	83 ec 04             	sub    $0x4,%esp
  800af2:	50                   	push   %eax
  800af3:	68 00 50 80 00       	push   $0x805000
  800af8:	ff 75 0c             	pushl  0xc(%ebp)
  800afb:	e8 e6 11 00 00       	call   801ce6 <memmove>
	return r;
  800b00:	83 c4 10             	add    $0x10,%esp
}
  800b03:	89 d8                	mov    %ebx,%eax
  800b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	53                   	push   %ebx
  800b10:	83 ec 20             	sub    $0x20,%esp
  800b13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b16:	53                   	push   %ebx
  800b17:	e8 ff 0f 00 00       	call   801b1b <strlen>
  800b1c:	83 c4 10             	add    $0x10,%esp
  800b1f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b24:	7f 67                	jg     800b8d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2c:	50                   	push   %eax
  800b2d:	e8 96 f8 ff ff       	call   8003c8 <fd_alloc>
  800b32:	83 c4 10             	add    $0x10,%esp
		return r;
  800b35:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b37:	85 c0                	test   %eax,%eax
  800b39:	78 57                	js     800b92 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b3b:	83 ec 08             	sub    $0x8,%esp
  800b3e:	53                   	push   %ebx
  800b3f:	68 00 50 80 00       	push   $0x805000
  800b44:	e8 0b 10 00 00       	call   801b54 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b54:	b8 01 00 00 00       	mov    $0x1,%eax
  800b59:	e8 f2 fd ff ff       	call   800950 <fsipc>
  800b5e:	89 c3                	mov    %eax,%ebx
  800b60:	83 c4 10             	add    $0x10,%esp
  800b63:	85 c0                	test   %eax,%eax
  800b65:	79 14                	jns    800b7b <open+0x6f>
		fd_close(fd, 0);
  800b67:	83 ec 08             	sub    $0x8,%esp
  800b6a:	6a 00                	push   $0x0
  800b6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6f:	e8 4c f9 ff ff       	call   8004c0 <fd_close>
		return r;
  800b74:	83 c4 10             	add    $0x10,%esp
  800b77:	89 da                	mov    %ebx,%edx
  800b79:	eb 17                	jmp    800b92 <open+0x86>
	}

	return fd2num(fd);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b81:	e8 1b f8 ff ff       	call   8003a1 <fd2num>
  800b86:	89 c2                	mov    %eax,%edx
  800b88:	83 c4 10             	add    $0x10,%esp
  800b8b:	eb 05                	jmp    800b92 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b8d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b92:	89 d0                	mov    %edx,%eax
  800b94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba9:	e8 a2 fd ff ff       	call   800950 <fsipc>
}
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bb6:	68 5b 23 80 00       	push   $0x80235b
  800bbb:	ff 75 0c             	pushl  0xc(%ebp)
  800bbe:	e8 91 0f 00 00       	call   801b54 <strcpy>
	return 0;
}
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 10             	sub    $0x10,%esp
  800bd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bd4:	53                   	push   %ebx
  800bd5:	e8 bb 13 00 00       	call   801f95 <pageref>
  800bda:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800be2:	83 f8 01             	cmp    $0x1,%eax
  800be5:	75 10                	jne    800bf7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	ff 73 0c             	pushl  0xc(%ebx)
  800bed:	e8 c0 02 00 00       	call   800eb2 <nsipc_close>
  800bf2:	89 c2                	mov    %eax,%edx
  800bf4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bf7:	89 d0                	mov    %edx,%eax
  800bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c04:	6a 00                	push   $0x0
  800c06:	ff 75 10             	pushl  0x10(%ebp)
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	ff 70 0c             	pushl  0xc(%eax)
  800c12:	e8 78 03 00 00       	call   800f8f <nsipc_send>
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c1f:	6a 00                	push   $0x0
  800c21:	ff 75 10             	pushl  0x10(%ebp)
  800c24:	ff 75 0c             	pushl  0xc(%ebp)
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	ff 70 0c             	pushl  0xc(%eax)
  800c2d:	e8 f1 02 00 00       	call   800f23 <nsipc_recv>
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c3a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c3d:	52                   	push   %edx
  800c3e:	50                   	push   %eax
  800c3f:	e8 d3 f7 ff ff       	call   800417 <fd_lookup>
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	85 c0                	test   %eax,%eax
  800c49:	78 17                	js     800c62 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c54:	39 08                	cmp    %ecx,(%eax)
  800c56:	75 05                	jne    800c5d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c58:	8b 40 0c             	mov    0xc(%eax),%eax
  800c5b:	eb 05                	jmp    800c62 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c5d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 1c             	sub    $0x1c,%esp
  800c6c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c71:	50                   	push   %eax
  800c72:	e8 51 f7 ff ff       	call   8003c8 <fd_alloc>
  800c77:	89 c3                	mov    %eax,%ebx
  800c79:	83 c4 10             	add    $0x10,%esp
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	78 1b                	js     800c9b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c80:	83 ec 04             	sub    $0x4,%esp
  800c83:	68 07 04 00 00       	push   $0x407
  800c88:	ff 75 f4             	pushl  -0xc(%ebp)
  800c8b:	6a 00                	push   $0x0
  800c8d:	e8 de f4 ff ff       	call   800170 <sys_page_alloc>
  800c92:	89 c3                	mov    %eax,%ebx
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	85 c0                	test   %eax,%eax
  800c99:	79 10                	jns    800cab <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	56                   	push   %esi
  800c9f:	e8 0e 02 00 00       	call   800eb2 <nsipc_close>
		return r;
  800ca4:	83 c4 10             	add    $0x10,%esp
  800ca7:	89 d8                	mov    %ebx,%eax
  800ca9:	eb 24                	jmp    800ccf <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cab:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cc0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	e8 d5 f6 ff ff       	call   8003a1 <fd2num>
  800ccc:	83 c4 10             	add    $0x10,%esp
}
  800ccf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	e8 50 ff ff ff       	call   800c34 <fd2sockid>
		return r;
  800ce4:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	78 1f                	js     800d09 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cea:	83 ec 04             	sub    $0x4,%esp
  800ced:	ff 75 10             	pushl  0x10(%ebp)
  800cf0:	ff 75 0c             	pushl  0xc(%ebp)
  800cf3:	50                   	push   %eax
  800cf4:	e8 12 01 00 00       	call   800e0b <nsipc_accept>
  800cf9:	83 c4 10             	add    $0x10,%esp
		return r;
  800cfc:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	78 07                	js     800d09 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d02:	e8 5d ff ff ff       	call   800c64 <alloc_sockfd>
  800d07:	89 c1                	mov    %eax,%ecx
}
  800d09:	89 c8                	mov    %ecx,%eax
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	e8 19 ff ff ff       	call   800c34 <fd2sockid>
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	78 12                	js     800d31 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d1f:	83 ec 04             	sub    $0x4,%esp
  800d22:	ff 75 10             	pushl  0x10(%ebp)
  800d25:	ff 75 0c             	pushl  0xc(%ebp)
  800d28:	50                   	push   %eax
  800d29:	e8 2d 01 00 00       	call   800e5b <nsipc_bind>
  800d2e:	83 c4 10             	add    $0x10,%esp
}
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <shutdown>:

int
shutdown(int s, int how)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	e8 f3 fe ff ff       	call   800c34 <fd2sockid>
  800d41:	85 c0                	test   %eax,%eax
  800d43:	78 0f                	js     800d54 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d45:	83 ec 08             	sub    $0x8,%esp
  800d48:	ff 75 0c             	pushl  0xc(%ebp)
  800d4b:	50                   	push   %eax
  800d4c:	e8 3f 01 00 00       	call   800e90 <nsipc_shutdown>
  800d51:	83 c4 10             	add    $0x10,%esp
}
  800d54:	c9                   	leave  
  800d55:	c3                   	ret    

00800d56 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	e8 d0 fe ff ff       	call   800c34 <fd2sockid>
  800d64:	85 c0                	test   %eax,%eax
  800d66:	78 12                	js     800d7a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d68:	83 ec 04             	sub    $0x4,%esp
  800d6b:	ff 75 10             	pushl  0x10(%ebp)
  800d6e:	ff 75 0c             	pushl  0xc(%ebp)
  800d71:	50                   	push   %eax
  800d72:	e8 55 01 00 00       	call   800ecc <nsipc_connect>
  800d77:	83 c4 10             	add    $0x10,%esp
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <listen>:

int
listen(int s, int backlog)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	e8 aa fe ff ff       	call   800c34 <fd2sockid>
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	78 0f                	js     800d9d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d8e:	83 ec 08             	sub    $0x8,%esp
  800d91:	ff 75 0c             	pushl  0xc(%ebp)
  800d94:	50                   	push   %eax
  800d95:	e8 67 01 00 00       	call   800f01 <nsipc_listen>
  800d9a:	83 c4 10             	add    $0x10,%esp
}
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    

00800d9f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800da5:	ff 75 10             	pushl  0x10(%ebp)
  800da8:	ff 75 0c             	pushl  0xc(%ebp)
  800dab:	ff 75 08             	pushl  0x8(%ebp)
  800dae:	e8 3a 02 00 00       	call   800fed <nsipc_socket>
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	85 c0                	test   %eax,%eax
  800db8:	78 05                	js     800dbf <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dba:	e8 a5 fe ff ff       	call   800c64 <alloc_sockfd>
}
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 04             	sub    $0x4,%esp
  800dc8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dca:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dd1:	75 12                	jne    800de5 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	6a 02                	push   $0x2
  800dd8:	e8 7f 11 00 00       	call   801f5c <ipc_find_env>
  800ddd:	a3 04 40 80 00       	mov    %eax,0x804004
  800de2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800de5:	6a 07                	push   $0x7
  800de7:	68 00 60 80 00       	push   $0x806000
  800dec:	53                   	push   %ebx
  800ded:	ff 35 04 40 80 00    	pushl  0x804004
  800df3:	e8 10 11 00 00       	call   801f08 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800df8:	83 c4 0c             	add    $0xc,%esp
  800dfb:	6a 00                	push   $0x0
  800dfd:	6a 00                	push   $0x0
  800dff:	6a 00                	push   $0x0
  800e01:	e8 95 10 00 00       	call   801e9b <ipc_recv>
}
  800e06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e09:	c9                   	leave  
  800e0a:	c3                   	ret    

00800e0b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e1b:	8b 06                	mov    (%esi),%eax
  800e1d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e22:	b8 01 00 00 00       	mov    $0x1,%eax
  800e27:	e8 95 ff ff ff       	call   800dc1 <nsipc>
  800e2c:	89 c3                	mov    %eax,%ebx
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	78 20                	js     800e52 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	ff 35 10 60 80 00    	pushl  0x806010
  800e3b:	68 00 60 80 00       	push   $0x806000
  800e40:	ff 75 0c             	pushl  0xc(%ebp)
  800e43:	e8 9e 0e 00 00       	call   801ce6 <memmove>
		*addrlen = ret->ret_addrlen;
  800e48:	a1 10 60 80 00       	mov    0x806010,%eax
  800e4d:	89 06                	mov    %eax,(%esi)
  800e4f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e52:	89 d8                	mov    %ebx,%eax
  800e54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
  800e68:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e6d:	53                   	push   %ebx
  800e6e:	ff 75 0c             	pushl  0xc(%ebp)
  800e71:	68 04 60 80 00       	push   $0x806004
  800e76:	e8 6b 0e 00 00       	call   801ce6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e7b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e81:	b8 02 00 00 00       	mov    $0x2,%eax
  800e86:	e8 36 ff ff ff       	call   800dc1 <nsipc>
}
  800e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    

00800e90 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ea6:	b8 03 00 00 00       	mov    $0x3,%eax
  800eab:	e8 11 ff ff ff       	call   800dc1 <nsipc>
}
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <nsipc_close>:

int
nsipc_close(int s)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ec0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec5:	e8 f7 fe ff ff       	call   800dc1 <nsipc>
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ede:	53                   	push   %ebx
  800edf:	ff 75 0c             	pushl  0xc(%ebp)
  800ee2:	68 04 60 80 00       	push   $0x806004
  800ee7:	e8 fa 0d 00 00       	call   801ce6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eec:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ef2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef7:	e8 c5 fe ff ff       	call   800dc1 <nsipc>
}
  800efc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f12:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f17:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1c:	e8 a0 fe ff ff       	call   800dc1 <nsipc>
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f33:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f39:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f41:	b8 07 00 00 00       	mov    $0x7,%eax
  800f46:	e8 76 fe ff ff       	call   800dc1 <nsipc>
  800f4b:	89 c3                	mov    %eax,%ebx
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 35                	js     800f86 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f51:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f56:	7f 04                	jg     800f5c <nsipc_recv+0x39>
  800f58:	39 c6                	cmp    %eax,%esi
  800f5a:	7d 16                	jge    800f72 <nsipc_recv+0x4f>
  800f5c:	68 67 23 80 00       	push   $0x802367
  800f61:	68 2f 23 80 00       	push   $0x80232f
  800f66:	6a 62                	push   $0x62
  800f68:	68 7c 23 80 00       	push   $0x80237c
  800f6d:	e8 84 05 00 00       	call   8014f6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	50                   	push   %eax
  800f76:	68 00 60 80 00       	push   $0x806000
  800f7b:	ff 75 0c             	pushl  0xc(%ebp)
  800f7e:	e8 63 0d 00 00       	call   801ce6 <memmove>
  800f83:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f86:	89 d8                	mov    %ebx,%eax
  800f88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	53                   	push   %ebx
  800f93:	83 ec 04             	sub    $0x4,%esp
  800f96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fa1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fa7:	7e 16                	jle    800fbf <nsipc_send+0x30>
  800fa9:	68 88 23 80 00       	push   $0x802388
  800fae:	68 2f 23 80 00       	push   $0x80232f
  800fb3:	6a 6d                	push   $0x6d
  800fb5:	68 7c 23 80 00       	push   $0x80237c
  800fba:	e8 37 05 00 00       	call   8014f6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fbf:	83 ec 04             	sub    $0x4,%esp
  800fc2:	53                   	push   %ebx
  800fc3:	ff 75 0c             	pushl  0xc(%ebp)
  800fc6:	68 0c 60 80 00       	push   $0x80600c
  800fcb:	e8 16 0d 00 00       	call   801ce6 <memmove>
	nsipcbuf.send.req_size = size;
  800fd0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fd6:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fde:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe3:	e8 d9 fd ff ff       	call   800dc1 <nsipc>
}
  800fe8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800feb:	c9                   	leave  
  800fec:	c3                   	ret    

00800fed <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffe:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801003:	8b 45 10             	mov    0x10(%ebp),%eax
  801006:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80100b:	b8 09 00 00 00       	mov    $0x9,%eax
  801010:	e8 ac fd ff ff       	call   800dc1 <nsipc>
}
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
  80101c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	ff 75 08             	pushl  0x8(%ebp)
  801025:	e8 87 f3 ff ff       	call   8003b1 <fd2data>
  80102a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80102c:	83 c4 08             	add    $0x8,%esp
  80102f:	68 94 23 80 00       	push   $0x802394
  801034:	53                   	push   %ebx
  801035:	e8 1a 0b 00 00       	call   801b54 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80103a:	8b 46 04             	mov    0x4(%esi),%eax
  80103d:	2b 06                	sub    (%esi),%eax
  80103f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801045:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80104c:	00 00 00 
	stat->st_dev = &devpipe;
  80104f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801056:	30 80 00 
	return 0;
}
  801059:	b8 00 00 00 00       	mov    $0x0,%eax
  80105e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	53                   	push   %ebx
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80106f:	53                   	push   %ebx
  801070:	6a 00                	push   $0x0
  801072:	e8 7e f1 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801077:	89 1c 24             	mov    %ebx,(%esp)
  80107a:	e8 32 f3 ff ff       	call   8003b1 <fd2data>
  80107f:	83 c4 08             	add    $0x8,%esp
  801082:	50                   	push   %eax
  801083:	6a 00                	push   $0x0
  801085:	e8 6b f1 ff ff       	call   8001f5 <sys_page_unmap>
}
  80108a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	57                   	push   %edi
  801093:	56                   	push   %esi
  801094:	53                   	push   %ebx
  801095:	83 ec 1c             	sub    $0x1c,%esp
  801098:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80109b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80109d:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8010ab:	e8 e5 0e 00 00       	call   801f95 <pageref>
  8010b0:	89 c3                	mov    %eax,%ebx
  8010b2:	89 3c 24             	mov    %edi,(%esp)
  8010b5:	e8 db 0e 00 00       	call   801f95 <pageref>
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	39 c3                	cmp    %eax,%ebx
  8010bf:	0f 94 c1             	sete   %cl
  8010c2:	0f b6 c9             	movzbl %cl,%ecx
  8010c5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010c8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010ce:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010d1:	39 ce                	cmp    %ecx,%esi
  8010d3:	74 1b                	je     8010f0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010d5:	39 c3                	cmp    %eax,%ebx
  8010d7:	75 c4                	jne    80109d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010d9:	8b 42 58             	mov    0x58(%edx),%eax
  8010dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010df:	50                   	push   %eax
  8010e0:	56                   	push   %esi
  8010e1:	68 9b 23 80 00       	push   $0x80239b
  8010e6:	e8 e4 04 00 00       	call   8015cf <cprintf>
  8010eb:	83 c4 10             	add    $0x10,%esp
  8010ee:	eb ad                	jmp    80109d <_pipeisclosed+0xe>
	}
}
  8010f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f6:	5b                   	pop    %ebx
  8010f7:	5e                   	pop    %esi
  8010f8:	5f                   	pop    %edi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 28             	sub    $0x28,%esp
  801104:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801107:	56                   	push   %esi
  801108:	e8 a4 f2 ff ff       	call   8003b1 <fd2data>
  80110d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	bf 00 00 00 00       	mov    $0x0,%edi
  801117:	eb 4b                	jmp    801164 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801119:	89 da                	mov    %ebx,%edx
  80111b:	89 f0                	mov    %esi,%eax
  80111d:	e8 6d ff ff ff       	call   80108f <_pipeisclosed>
  801122:	85 c0                	test   %eax,%eax
  801124:	75 48                	jne    80116e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801126:	e8 26 f0 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80112b:	8b 43 04             	mov    0x4(%ebx),%eax
  80112e:	8b 0b                	mov    (%ebx),%ecx
  801130:	8d 51 20             	lea    0x20(%ecx),%edx
  801133:	39 d0                	cmp    %edx,%eax
  801135:	73 e2                	jae    801119 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801137:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80113e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801141:	89 c2                	mov    %eax,%edx
  801143:	c1 fa 1f             	sar    $0x1f,%edx
  801146:	89 d1                	mov    %edx,%ecx
  801148:	c1 e9 1b             	shr    $0x1b,%ecx
  80114b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80114e:	83 e2 1f             	and    $0x1f,%edx
  801151:	29 ca                	sub    %ecx,%edx
  801153:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801157:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80115b:	83 c0 01             	add    $0x1,%eax
  80115e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801161:	83 c7 01             	add    $0x1,%edi
  801164:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801167:	75 c2                	jne    80112b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801169:	8b 45 10             	mov    0x10(%ebp),%eax
  80116c:	eb 05                	jmp    801173 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80116e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 18             	sub    $0x18,%esp
  801184:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801187:	57                   	push   %edi
  801188:	e8 24 f2 ff ff       	call   8003b1 <fd2data>
  80118d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	bb 00 00 00 00       	mov    $0x0,%ebx
  801197:	eb 3d                	jmp    8011d6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801199:	85 db                	test   %ebx,%ebx
  80119b:	74 04                	je     8011a1 <devpipe_read+0x26>
				return i;
  80119d:	89 d8                	mov    %ebx,%eax
  80119f:	eb 44                	jmp    8011e5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011a1:	89 f2                	mov    %esi,%edx
  8011a3:	89 f8                	mov    %edi,%eax
  8011a5:	e8 e5 fe ff ff       	call   80108f <_pipeisclosed>
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	75 32                	jne    8011e0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011ae:	e8 9e ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011b3:	8b 06                	mov    (%esi),%eax
  8011b5:	3b 46 04             	cmp    0x4(%esi),%eax
  8011b8:	74 df                	je     801199 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ba:	99                   	cltd   
  8011bb:	c1 ea 1b             	shr    $0x1b,%edx
  8011be:	01 d0                	add    %edx,%eax
  8011c0:	83 e0 1f             	and    $0x1f,%eax
  8011c3:	29 d0                	sub    %edx,%eax
  8011c5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011d0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d3:	83 c3 01             	add    $0x1,%ebx
  8011d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011d9:	75 d8                	jne    8011b3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011db:	8b 45 10             	mov    0x10(%ebp),%eax
  8011de:	eb 05                	jmp    8011e5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	56                   	push   %esi
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	e8 ca f1 ff ff       	call   8003c8 <fd_alloc>
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	89 c2                	mov    %eax,%edx
  801203:	85 c0                	test   %eax,%eax
  801205:	0f 88 2c 01 00 00    	js     801337 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	68 07 04 00 00       	push   $0x407
  801213:	ff 75 f4             	pushl  -0xc(%ebp)
  801216:	6a 00                	push   $0x0
  801218:	e8 53 ef ff ff       	call   800170 <sys_page_alloc>
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	89 c2                	mov    %eax,%edx
  801222:	85 c0                	test   %eax,%eax
  801224:	0f 88 0d 01 00 00    	js     801337 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	e8 92 f1 ff ff       	call   8003c8 <fd_alloc>
  801236:	89 c3                	mov    %eax,%ebx
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	0f 88 e2 00 00 00    	js     801325 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	68 07 04 00 00       	push   $0x407
  80124b:	ff 75 f0             	pushl  -0x10(%ebp)
  80124e:	6a 00                	push   $0x0
  801250:	e8 1b ef ff ff       	call   800170 <sys_page_alloc>
  801255:	89 c3                	mov    %eax,%ebx
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	0f 88 c3 00 00 00    	js     801325 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	ff 75 f4             	pushl  -0xc(%ebp)
  801268:	e8 44 f1 ff ff       	call   8003b1 <fd2data>
  80126d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126f:	83 c4 0c             	add    $0xc,%esp
  801272:	68 07 04 00 00       	push   $0x407
  801277:	50                   	push   %eax
  801278:	6a 00                	push   $0x0
  80127a:	e8 f1 ee ff ff       	call   800170 <sys_page_alloc>
  80127f:	89 c3                	mov    %eax,%ebx
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	0f 88 89 00 00 00    	js     801315 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128c:	83 ec 0c             	sub    $0xc,%esp
  80128f:	ff 75 f0             	pushl  -0x10(%ebp)
  801292:	e8 1a f1 ff ff       	call   8003b1 <fd2data>
  801297:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80129e:	50                   	push   %eax
  80129f:	6a 00                	push   $0x0
  8012a1:	56                   	push   %esi
  8012a2:	6a 00                	push   $0x0
  8012a4:	e8 0a ef ff ff       	call   8001b3 <sys_page_map>
  8012a9:	89 c3                	mov    %eax,%ebx
  8012ab:	83 c4 20             	add    $0x20,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 55                	js     801307 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012b2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012c7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012dc:	83 ec 0c             	sub    $0xc,%esp
  8012df:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e2:	e8 ba f0 ff ff       	call   8003a1 <fd2num>
  8012e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ea:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012ec:	83 c4 04             	add    $0x4,%esp
  8012ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f2:	e8 aa f0 ff ff       	call   8003a1 <fd2num>
  8012f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	ba 00 00 00 00       	mov    $0x0,%edx
  801305:	eb 30                	jmp    801337 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	56                   	push   %esi
  80130b:	6a 00                	push   $0x0
  80130d:	e8 e3 ee ff ff       	call   8001f5 <sys_page_unmap>
  801312:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	ff 75 f0             	pushl  -0x10(%ebp)
  80131b:	6a 00                	push   $0x0
  80131d:	e8 d3 ee ff ff       	call   8001f5 <sys_page_unmap>
  801322:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	ff 75 f4             	pushl  -0xc(%ebp)
  80132b:	6a 00                	push   $0x0
  80132d:	e8 c3 ee ff ff       	call   8001f5 <sys_page_unmap>
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801337:	89 d0                	mov    %edx,%eax
  801339:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	ff 75 08             	pushl  0x8(%ebp)
  80134d:	e8 c5 f0 ff ff       	call   800417 <fd_lookup>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 18                	js     801371 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	ff 75 f4             	pushl  -0xc(%ebp)
  80135f:	e8 4d f0 ff ff       	call   8003b1 <fd2data>
	return _pipeisclosed(fd, p);
  801364:	89 c2                	mov    %eax,%edx
  801366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801369:	e8 21 fd ff ff       	call   80108f <_pipeisclosed>
  80136e:	83 c4 10             	add    $0x10,%esp
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801383:	68 b3 23 80 00       	push   $0x8023b3
  801388:	ff 75 0c             	pushl  0xc(%ebp)
  80138b:	e8 c4 07 00 00       	call   801b54 <strcpy>
	return 0;
}
  801390:	b8 00 00 00 00       	mov    $0x0,%eax
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	57                   	push   %edi
  80139b:	56                   	push   %esi
  80139c:	53                   	push   %ebx
  80139d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ae:	eb 2d                	jmp    8013dd <devcons_write+0x46>
		m = n - tot;
  8013b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013b5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013b8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013bd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013c0:	83 ec 04             	sub    $0x4,%esp
  8013c3:	53                   	push   %ebx
  8013c4:	03 45 0c             	add    0xc(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	57                   	push   %edi
  8013c9:	e8 18 09 00 00       	call   801ce6 <memmove>
		sys_cputs(buf, m);
  8013ce:	83 c4 08             	add    $0x8,%esp
  8013d1:	53                   	push   %ebx
  8013d2:	57                   	push   %edi
  8013d3:	e8 dc ec ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d8:	01 de                	add    %ebx,%esi
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	89 f0                	mov    %esi,%eax
  8013df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013e2:	72 cc                	jb     8013b0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5f                   	pop    %edi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013fb:	74 2a                	je     801427 <devcons_read+0x3b>
  8013fd:	eb 05                	jmp    801404 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013ff:	e8 4d ed ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801404:	e8 c9 ec ff ff       	call   8000d2 <sys_cgetc>
  801409:	85 c0                	test   %eax,%eax
  80140b:	74 f2                	je     8013ff <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 16                	js     801427 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801411:	83 f8 04             	cmp    $0x4,%eax
  801414:	74 0c                	je     801422 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801416:	8b 55 0c             	mov    0xc(%ebp),%edx
  801419:	88 02                	mov    %al,(%edx)
	return 1;
  80141b:	b8 01 00 00 00       	mov    $0x1,%eax
  801420:	eb 05                	jmp    801427 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801422:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801435:	6a 01                	push   $0x1
  801437:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	e8 74 ec ff ff       	call   8000b4 <sys_cputs>
}
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <getchar>:

int
getchar(void)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80144b:	6a 01                	push   $0x1
  80144d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	6a 00                	push   $0x0
  801453:	e8 25 f2 ff ff       	call   80067d <read>
	if (r < 0)
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 0f                	js     80146e <getchar+0x29>
		return r;
	if (r < 1)
  80145f:	85 c0                	test   %eax,%eax
  801461:	7e 06                	jle    801469 <getchar+0x24>
		return -E_EOF;
	return c;
  801463:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801467:	eb 05                	jmp    80146e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801469:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	ff 75 08             	pushl  0x8(%ebp)
  80147d:	e8 95 ef ff ff       	call   800417 <fd_lookup>
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 11                	js     80149a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801492:	39 10                	cmp    %edx,(%eax)
  801494:	0f 94 c0             	sete   %al
  801497:	0f b6 c0             	movzbl %al,%eax
}
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <opencons>:

int
opencons(void)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	e8 1d ef ff ff       	call   8003c8 <fd_alloc>
  8014ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ae:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 3e                	js     8014f2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	68 07 04 00 00       	push   $0x407
  8014bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bf:	6a 00                	push   $0x0
  8014c1:	e8 aa ec ff ff       	call   800170 <sys_page_alloc>
  8014c6:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 23                	js     8014f2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014cf:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	50                   	push   %eax
  8014e8:	e8 b4 ee ff ff       	call   8003a1 <fd2num>
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	83 c4 10             	add    $0x10,%esp
}
  8014f2:	89 d0                	mov    %edx,%eax
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	56                   	push   %esi
  8014fa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014fb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014fe:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801504:	e8 29 ec ff ff       	call   800132 <sys_getenvid>
  801509:	83 ec 0c             	sub    $0xc,%esp
  80150c:	ff 75 0c             	pushl  0xc(%ebp)
  80150f:	ff 75 08             	pushl  0x8(%ebp)
  801512:	56                   	push   %esi
  801513:	50                   	push   %eax
  801514:	68 c0 23 80 00       	push   $0x8023c0
  801519:	e8 b1 00 00 00       	call   8015cf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80151e:	83 c4 18             	add    $0x18,%esp
  801521:	53                   	push   %ebx
  801522:	ff 75 10             	pushl  0x10(%ebp)
  801525:	e8 54 00 00 00       	call   80157e <vcprintf>
	cprintf("\n");
  80152a:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801531:	e8 99 00 00 00       	call   8015cf <cprintf>
  801536:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801539:	cc                   	int3   
  80153a:	eb fd                	jmp    801539 <_panic+0x43>

0080153c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801546:	8b 13                	mov    (%ebx),%edx
  801548:	8d 42 01             	lea    0x1(%edx),%eax
  80154b:	89 03                	mov    %eax,(%ebx)
  80154d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801550:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801554:	3d ff 00 00 00       	cmp    $0xff,%eax
  801559:	75 1a                	jne    801575 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	68 ff 00 00 00       	push   $0xff
  801563:	8d 43 08             	lea    0x8(%ebx),%eax
  801566:	50                   	push   %eax
  801567:	e8 48 eb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  80156c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801572:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801575:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801579:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801587:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80158e:	00 00 00 
	b.cnt = 0;
  801591:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801598:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	ff 75 08             	pushl  0x8(%ebp)
  8015a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	68 3c 15 80 00       	push   $0x80153c
  8015ad:	e8 54 01 00 00       	call   801706 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b2:	83 c4 08             	add    $0x8,%esp
  8015b5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015bb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	e8 ed ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8015c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015d5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015d8:	50                   	push   %eax
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 9d ff ff ff       	call   80157e <vcprintf>
	va_end(ap);

	return cnt;
}
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	57                   	push   %edi
  8015e7:	56                   	push   %esi
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 1c             	sub    $0x1c,%esp
  8015ec:	89 c7                	mov    %eax,%edi
  8015ee:	89 d6                	mov    %edx,%esi
  8015f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801604:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801607:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80160a:	39 d3                	cmp    %edx,%ebx
  80160c:	72 05                	jb     801613 <printnum+0x30>
  80160e:	39 45 10             	cmp    %eax,0x10(%ebp)
  801611:	77 45                	ja     801658 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801613:	83 ec 0c             	sub    $0xc,%esp
  801616:	ff 75 18             	pushl  0x18(%ebp)
  801619:	8b 45 14             	mov    0x14(%ebp),%eax
  80161c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80161f:	53                   	push   %ebx
  801620:	ff 75 10             	pushl  0x10(%ebp)
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	ff 75 e4             	pushl  -0x1c(%ebp)
  801629:	ff 75 e0             	pushl  -0x20(%ebp)
  80162c:	ff 75 dc             	pushl  -0x24(%ebp)
  80162f:	ff 75 d8             	pushl  -0x28(%ebp)
  801632:	e8 99 09 00 00       	call   801fd0 <__udivdi3>
  801637:	83 c4 18             	add    $0x18,%esp
  80163a:	52                   	push   %edx
  80163b:	50                   	push   %eax
  80163c:	89 f2                	mov    %esi,%edx
  80163e:	89 f8                	mov    %edi,%eax
  801640:	e8 9e ff ff ff       	call   8015e3 <printnum>
  801645:	83 c4 20             	add    $0x20,%esp
  801648:	eb 18                	jmp    801662 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	56                   	push   %esi
  80164e:	ff 75 18             	pushl  0x18(%ebp)
  801651:	ff d7                	call   *%edi
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	eb 03                	jmp    80165b <printnum+0x78>
  801658:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80165b:	83 eb 01             	sub    $0x1,%ebx
  80165e:	85 db                	test   %ebx,%ebx
  801660:	7f e8                	jg     80164a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	56                   	push   %esi
  801666:	83 ec 04             	sub    $0x4,%esp
  801669:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166c:	ff 75 e0             	pushl  -0x20(%ebp)
  80166f:	ff 75 dc             	pushl  -0x24(%ebp)
  801672:	ff 75 d8             	pushl  -0x28(%ebp)
  801675:	e8 86 0a 00 00       	call   802100 <__umoddi3>
  80167a:	83 c4 14             	add    $0x14,%esp
  80167d:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801684:	50                   	push   %eax
  801685:	ff d7                	call   *%edi
}
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5f                   	pop    %edi
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801695:	83 fa 01             	cmp    $0x1,%edx
  801698:	7e 0e                	jle    8016a8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80169a:	8b 10                	mov    (%eax),%edx
  80169c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80169f:	89 08                	mov    %ecx,(%eax)
  8016a1:	8b 02                	mov    (%edx),%eax
  8016a3:	8b 52 04             	mov    0x4(%edx),%edx
  8016a6:	eb 22                	jmp    8016ca <getuint+0x38>
	else if (lflag)
  8016a8:	85 d2                	test   %edx,%edx
  8016aa:	74 10                	je     8016bc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016ac:	8b 10                	mov    (%eax),%edx
  8016ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b1:	89 08                	mov    %ecx,(%eax)
  8016b3:	8b 02                	mov    (%edx),%eax
  8016b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ba:	eb 0e                	jmp    8016ca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016bc:	8b 10                	mov    (%eax),%edx
  8016be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016c1:	89 08                	mov    %ecx,(%eax)
  8016c3:	8b 02                	mov    (%edx),%eax
  8016c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016d6:	8b 10                	mov    (%eax),%edx
  8016d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8016db:	73 0a                	jae    8016e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016e0:	89 08                	mov    %ecx,(%eax)
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	88 02                	mov    %al,(%edx)
}
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016f2:	50                   	push   %eax
  8016f3:	ff 75 10             	pushl  0x10(%ebp)
  8016f6:	ff 75 0c             	pushl  0xc(%ebp)
  8016f9:	ff 75 08             	pushl  0x8(%ebp)
  8016fc:	e8 05 00 00 00       	call   801706 <vprintfmt>
	va_end(ap);
}
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	57                   	push   %edi
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	83 ec 2c             	sub    $0x2c,%esp
  80170f:	8b 75 08             	mov    0x8(%ebp),%esi
  801712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801715:	8b 7d 10             	mov    0x10(%ebp),%edi
  801718:	eb 12                	jmp    80172c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80171a:	85 c0                	test   %eax,%eax
  80171c:	0f 84 89 03 00 00    	je     801aab <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801722:	83 ec 08             	sub    $0x8,%esp
  801725:	53                   	push   %ebx
  801726:	50                   	push   %eax
  801727:	ff d6                	call   *%esi
  801729:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80172c:	83 c7 01             	add    $0x1,%edi
  80172f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801733:	83 f8 25             	cmp    $0x25,%eax
  801736:	75 e2                	jne    80171a <vprintfmt+0x14>
  801738:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80173c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801743:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80174a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801751:	ba 00 00 00 00       	mov    $0x0,%edx
  801756:	eb 07                	jmp    80175f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801758:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80175b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175f:	8d 47 01             	lea    0x1(%edi),%eax
  801762:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801765:	0f b6 07             	movzbl (%edi),%eax
  801768:	0f b6 c8             	movzbl %al,%ecx
  80176b:	83 e8 23             	sub    $0x23,%eax
  80176e:	3c 55                	cmp    $0x55,%al
  801770:	0f 87 1a 03 00 00    	ja     801a90 <vprintfmt+0x38a>
  801776:	0f b6 c0             	movzbl %al,%eax
  801779:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801780:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801783:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801787:	eb d6                	jmp    80175f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
  801791:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801794:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801797:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80179b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80179e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017a1:	83 fa 09             	cmp    $0x9,%edx
  8017a4:	77 39                	ja     8017df <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017a9:	eb e9                	jmp    801794 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ae:	8d 48 04             	lea    0x4(%eax),%ecx
  8017b1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017b4:	8b 00                	mov    (%eax),%eax
  8017b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017bc:	eb 27                	jmp    8017e5 <vprintfmt+0xdf>
  8017be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c8:	0f 49 c8             	cmovns %eax,%ecx
  8017cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017d1:	eb 8c                	jmp    80175f <vprintfmt+0x59>
  8017d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017dd:	eb 80                	jmp    80175f <vprintfmt+0x59>
  8017df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e9:	0f 89 70 ff ff ff    	jns    80175f <vprintfmt+0x59>
				width = precision, precision = -1;
  8017ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017fc:	e9 5e ff ff ff       	jmp    80175f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801801:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801804:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801807:	e9 53 ff ff ff       	jmp    80175f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80180c:	8b 45 14             	mov    0x14(%ebp),%eax
  80180f:	8d 50 04             	lea    0x4(%eax),%edx
  801812:	89 55 14             	mov    %edx,0x14(%ebp)
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	53                   	push   %ebx
  801819:	ff 30                	pushl  (%eax)
  80181b:	ff d6                	call   *%esi
			break;
  80181d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801820:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801823:	e9 04 ff ff ff       	jmp    80172c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801828:	8b 45 14             	mov    0x14(%ebp),%eax
  80182b:	8d 50 04             	lea    0x4(%eax),%edx
  80182e:	89 55 14             	mov    %edx,0x14(%ebp)
  801831:	8b 00                	mov    (%eax),%eax
  801833:	99                   	cltd   
  801834:	31 d0                	xor    %edx,%eax
  801836:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801838:	83 f8 0f             	cmp    $0xf,%eax
  80183b:	7f 0b                	jg     801848 <vprintfmt+0x142>
  80183d:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801844:	85 d2                	test   %edx,%edx
  801846:	75 18                	jne    801860 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801848:	50                   	push   %eax
  801849:	68 fb 23 80 00       	push   $0x8023fb
  80184e:	53                   	push   %ebx
  80184f:	56                   	push   %esi
  801850:	e8 94 fe ff ff       	call   8016e9 <printfmt>
  801855:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801858:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80185b:	e9 cc fe ff ff       	jmp    80172c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801860:	52                   	push   %edx
  801861:	68 41 23 80 00       	push   $0x802341
  801866:	53                   	push   %ebx
  801867:	56                   	push   %esi
  801868:	e8 7c fe ff ff       	call   8016e9 <printfmt>
  80186d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801870:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801873:	e9 b4 fe ff ff       	jmp    80172c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801878:	8b 45 14             	mov    0x14(%ebp),%eax
  80187b:	8d 50 04             	lea    0x4(%eax),%edx
  80187e:	89 55 14             	mov    %edx,0x14(%ebp)
  801881:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801883:	85 ff                	test   %edi,%edi
  801885:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80188a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80188d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801891:	0f 8e 94 00 00 00    	jle    80192b <vprintfmt+0x225>
  801897:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80189b:	0f 84 98 00 00 00    	je     801939 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	ff 75 d0             	pushl  -0x30(%ebp)
  8018a7:	57                   	push   %edi
  8018a8:	e8 86 02 00 00       	call   801b33 <strnlen>
  8018ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018b0:	29 c1                	sub    %eax,%ecx
  8018b2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018b5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018b8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018bf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018c2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c4:	eb 0f                	jmp    8018d5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	53                   	push   %ebx
  8018ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8018cd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018cf:	83 ef 01             	sub    $0x1,%edi
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	85 ff                	test   %edi,%edi
  8018d7:	7f ed                	jg     8018c6 <vprintfmt+0x1c0>
  8018d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018dc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018df:	85 c9                	test   %ecx,%ecx
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e6:	0f 49 c1             	cmovns %ecx,%eax
  8018e9:	29 c1                	sub    %eax,%ecx
  8018eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f4:	89 cb                	mov    %ecx,%ebx
  8018f6:	eb 4d                	jmp    801945 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018fc:	74 1b                	je     801919 <vprintfmt+0x213>
  8018fe:	0f be c0             	movsbl %al,%eax
  801901:	83 e8 20             	sub    $0x20,%eax
  801904:	83 f8 5e             	cmp    $0x5e,%eax
  801907:	76 10                	jbe    801919 <vprintfmt+0x213>
					putch('?', putdat);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	ff 75 0c             	pushl  0xc(%ebp)
  80190f:	6a 3f                	push   $0x3f
  801911:	ff 55 08             	call   *0x8(%ebp)
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	eb 0d                	jmp    801926 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801919:	83 ec 08             	sub    $0x8,%esp
  80191c:	ff 75 0c             	pushl  0xc(%ebp)
  80191f:	52                   	push   %edx
  801920:	ff 55 08             	call   *0x8(%ebp)
  801923:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801926:	83 eb 01             	sub    $0x1,%ebx
  801929:	eb 1a                	jmp    801945 <vprintfmt+0x23f>
  80192b:	89 75 08             	mov    %esi,0x8(%ebp)
  80192e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801931:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801934:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801937:	eb 0c                	jmp    801945 <vprintfmt+0x23f>
  801939:	89 75 08             	mov    %esi,0x8(%ebp)
  80193c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80193f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801942:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801945:	83 c7 01             	add    $0x1,%edi
  801948:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80194c:	0f be d0             	movsbl %al,%edx
  80194f:	85 d2                	test   %edx,%edx
  801951:	74 23                	je     801976 <vprintfmt+0x270>
  801953:	85 f6                	test   %esi,%esi
  801955:	78 a1                	js     8018f8 <vprintfmt+0x1f2>
  801957:	83 ee 01             	sub    $0x1,%esi
  80195a:	79 9c                	jns    8018f8 <vprintfmt+0x1f2>
  80195c:	89 df                	mov    %ebx,%edi
  80195e:	8b 75 08             	mov    0x8(%ebp),%esi
  801961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801964:	eb 18                	jmp    80197e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	53                   	push   %ebx
  80196a:	6a 20                	push   $0x20
  80196c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80196e:	83 ef 01             	sub    $0x1,%edi
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	eb 08                	jmp    80197e <vprintfmt+0x278>
  801976:	89 df                	mov    %ebx,%edi
  801978:	8b 75 08             	mov    0x8(%ebp),%esi
  80197b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80197e:	85 ff                	test   %edi,%edi
  801980:	7f e4                	jg     801966 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801982:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801985:	e9 a2 fd ff ff       	jmp    80172c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80198a:	83 fa 01             	cmp    $0x1,%edx
  80198d:	7e 16                	jle    8019a5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80198f:	8b 45 14             	mov    0x14(%ebp),%eax
  801992:	8d 50 08             	lea    0x8(%eax),%edx
  801995:	89 55 14             	mov    %edx,0x14(%ebp)
  801998:	8b 50 04             	mov    0x4(%eax),%edx
  80199b:	8b 00                	mov    (%eax),%eax
  80199d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a3:	eb 32                	jmp    8019d7 <vprintfmt+0x2d1>
	else if (lflag)
  8019a5:	85 d2                	test   %edx,%edx
  8019a7:	74 18                	je     8019c1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ac:	8d 50 04             	lea    0x4(%eax),%edx
  8019af:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b2:	8b 00                	mov    (%eax),%eax
  8019b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b7:	89 c1                	mov    %eax,%ecx
  8019b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8019bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019bf:	eb 16                	jmp    8019d7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c4:	8d 50 04             	lea    0x4(%eax),%edx
  8019c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ca:	8b 00                	mov    (%eax),%eax
  8019cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019cf:	89 c1                	mov    %eax,%ecx
  8019d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8019d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019da:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019e6:	79 74                	jns    801a5c <vprintfmt+0x356>
				putch('-', putdat);
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	53                   	push   %ebx
  8019ec:	6a 2d                	push   $0x2d
  8019ee:	ff d6                	call   *%esi
				num = -(long long) num;
  8019f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019f6:	f7 d8                	neg    %eax
  8019f8:	83 d2 00             	adc    $0x0,%edx
  8019fb:	f7 da                	neg    %edx
  8019fd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a00:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a05:	eb 55                	jmp    801a5c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a07:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0a:	e8 83 fc ff ff       	call   801692 <getuint>
			base = 10;
  801a0f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a14:	eb 46                	jmp    801a5c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a16:	8d 45 14             	lea    0x14(%ebp),%eax
  801a19:	e8 74 fc ff ff       	call   801692 <getuint>
		        base = 8;
  801a1e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a23:	eb 37                	jmp    801a5c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	53                   	push   %ebx
  801a29:	6a 30                	push   $0x30
  801a2b:	ff d6                	call   *%esi
			putch('x', putdat);
  801a2d:	83 c4 08             	add    $0x8,%esp
  801a30:	53                   	push   %ebx
  801a31:	6a 78                	push   $0x78
  801a33:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a35:	8b 45 14             	mov    0x14(%ebp),%eax
  801a38:	8d 50 04             	lea    0x4(%eax),%edx
  801a3b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a3e:	8b 00                	mov    (%eax),%eax
  801a40:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a45:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a48:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a4d:	eb 0d                	jmp    801a5c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a4f:	8d 45 14             	lea    0x14(%ebp),%eax
  801a52:	e8 3b fc ff ff       	call   801692 <getuint>
			base = 16;
  801a57:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a63:	57                   	push   %edi
  801a64:	ff 75 e0             	pushl  -0x20(%ebp)
  801a67:	51                   	push   %ecx
  801a68:	52                   	push   %edx
  801a69:	50                   	push   %eax
  801a6a:	89 da                	mov    %ebx,%edx
  801a6c:	89 f0                	mov    %esi,%eax
  801a6e:	e8 70 fb ff ff       	call   8015e3 <printnum>
			break;
  801a73:	83 c4 20             	add    $0x20,%esp
  801a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a79:	e9 ae fc ff ff       	jmp    80172c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	53                   	push   %ebx
  801a82:	51                   	push   %ecx
  801a83:	ff d6                	call   *%esi
			break;
  801a85:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a8b:	e9 9c fc ff ff       	jmp    80172c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a90:	83 ec 08             	sub    $0x8,%esp
  801a93:	53                   	push   %ebx
  801a94:	6a 25                	push   $0x25
  801a96:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	eb 03                	jmp    801aa0 <vprintfmt+0x39a>
  801a9d:	83 ef 01             	sub    $0x1,%edi
  801aa0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aa4:	75 f7                	jne    801a9d <vprintfmt+0x397>
  801aa6:	e9 81 fc ff ff       	jmp    80172c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aae:	5b                   	pop    %ebx
  801aaf:	5e                   	pop    %esi
  801ab0:	5f                   	pop    %edi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	83 ec 18             	sub    $0x18,%esp
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801abf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ac2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	74 26                	je     801afa <vsnprintf+0x47>
  801ad4:	85 d2                	test   %edx,%edx
  801ad6:	7e 22                	jle    801afa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad8:	ff 75 14             	pushl  0x14(%ebp)
  801adb:	ff 75 10             	pushl  0x10(%ebp)
  801ade:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ae1:	50                   	push   %eax
  801ae2:	68 cc 16 80 00       	push   $0x8016cc
  801ae7:	e8 1a fc ff ff       	call   801706 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	eb 05                	jmp    801aff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801afa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b07:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b0a:	50                   	push   %eax
  801b0b:	ff 75 10             	pushl  0x10(%ebp)
  801b0e:	ff 75 0c             	pushl  0xc(%ebp)
  801b11:	ff 75 08             	pushl  0x8(%ebp)
  801b14:	e8 9a ff ff ff       	call   801ab3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b21:	b8 00 00 00 00       	mov    $0x0,%eax
  801b26:	eb 03                	jmp    801b2b <strlen+0x10>
		n++;
  801b28:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b2b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b2f:	75 f7                	jne    801b28 <strlen+0xd>
		n++;
	return n;
}
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b39:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b41:	eb 03                	jmp    801b46 <strnlen+0x13>
		n++;
  801b43:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b46:	39 c2                	cmp    %eax,%edx
  801b48:	74 08                	je     801b52 <strnlen+0x1f>
  801b4a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b4e:	75 f3                	jne    801b43 <strnlen+0x10>
  801b50:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	53                   	push   %ebx
  801b58:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b5e:	89 c2                	mov    %eax,%edx
  801b60:	83 c2 01             	add    $0x1,%edx
  801b63:	83 c1 01             	add    $0x1,%ecx
  801b66:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b6a:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b6d:	84 db                	test   %bl,%bl
  801b6f:	75 ef                	jne    801b60 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b71:	5b                   	pop    %ebx
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	53                   	push   %ebx
  801b78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b7b:	53                   	push   %ebx
  801b7c:	e8 9a ff ff ff       	call   801b1b <strlen>
  801b81:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b84:	ff 75 0c             	pushl  0xc(%ebp)
  801b87:	01 d8                	add    %ebx,%eax
  801b89:	50                   	push   %eax
  801b8a:	e8 c5 ff ff ff       	call   801b54 <strcpy>
	return dst;
}
  801b8f:	89 d8                	mov    %ebx,%eax
  801b91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba1:	89 f3                	mov    %esi,%ebx
  801ba3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba6:	89 f2                	mov    %esi,%edx
  801ba8:	eb 0f                	jmp    801bb9 <strncpy+0x23>
		*dst++ = *src;
  801baa:	83 c2 01             	add    $0x1,%edx
  801bad:	0f b6 01             	movzbl (%ecx),%eax
  801bb0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb3:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb9:	39 da                	cmp    %ebx,%edx
  801bbb:	75 ed                	jne    801baa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bbd:	89 f0                	mov    %esi,%eax
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bce:	8b 55 10             	mov    0x10(%ebp),%edx
  801bd1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd3:	85 d2                	test   %edx,%edx
  801bd5:	74 21                	je     801bf8 <strlcpy+0x35>
  801bd7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bdb:	89 f2                	mov    %esi,%edx
  801bdd:	eb 09                	jmp    801be8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bdf:	83 c2 01             	add    $0x1,%edx
  801be2:	83 c1 01             	add    $0x1,%ecx
  801be5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be8:	39 c2                	cmp    %eax,%edx
  801bea:	74 09                	je     801bf5 <strlcpy+0x32>
  801bec:	0f b6 19             	movzbl (%ecx),%ebx
  801bef:	84 db                	test   %bl,%bl
  801bf1:	75 ec                	jne    801bdf <strlcpy+0x1c>
  801bf3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bf5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf8:	29 f0                	sub    %esi,%eax
}
  801bfa:	5b                   	pop    %ebx
  801bfb:	5e                   	pop    %esi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c04:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c07:	eb 06                	jmp    801c0f <strcmp+0x11>
		p++, q++;
  801c09:	83 c1 01             	add    $0x1,%ecx
  801c0c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c0f:	0f b6 01             	movzbl (%ecx),%eax
  801c12:	84 c0                	test   %al,%al
  801c14:	74 04                	je     801c1a <strcmp+0x1c>
  801c16:	3a 02                	cmp    (%edx),%al
  801c18:	74 ef                	je     801c09 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c1a:	0f b6 c0             	movzbl %al,%eax
  801c1d:	0f b6 12             	movzbl (%edx),%edx
  801c20:	29 d0                	sub    %edx,%eax
}
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    

00801c24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	53                   	push   %ebx
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2e:	89 c3                	mov    %eax,%ebx
  801c30:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c33:	eb 06                	jmp    801c3b <strncmp+0x17>
		n--, p++, q++;
  801c35:	83 c0 01             	add    $0x1,%eax
  801c38:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c3b:	39 d8                	cmp    %ebx,%eax
  801c3d:	74 15                	je     801c54 <strncmp+0x30>
  801c3f:	0f b6 08             	movzbl (%eax),%ecx
  801c42:	84 c9                	test   %cl,%cl
  801c44:	74 04                	je     801c4a <strncmp+0x26>
  801c46:	3a 0a                	cmp    (%edx),%cl
  801c48:	74 eb                	je     801c35 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4a:	0f b6 00             	movzbl (%eax),%eax
  801c4d:	0f b6 12             	movzbl (%edx),%edx
  801c50:	29 d0                	sub    %edx,%eax
  801c52:	eb 05                	jmp    801c59 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c54:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c59:	5b                   	pop    %ebx
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c62:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c66:	eb 07                	jmp    801c6f <strchr+0x13>
		if (*s == c)
  801c68:	38 ca                	cmp    %cl,%dl
  801c6a:	74 0f                	je     801c7b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c6c:	83 c0 01             	add    $0x1,%eax
  801c6f:	0f b6 10             	movzbl (%eax),%edx
  801c72:	84 d2                	test   %dl,%dl
  801c74:	75 f2                	jne    801c68 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    

00801c7d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c87:	eb 03                	jmp    801c8c <strfind+0xf>
  801c89:	83 c0 01             	add    $0x1,%eax
  801c8c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c8f:	38 ca                	cmp    %cl,%dl
  801c91:	74 04                	je     801c97 <strfind+0x1a>
  801c93:	84 d2                	test   %dl,%dl
  801c95:	75 f2                	jne    801c89 <strfind+0xc>
			break;
	return (char *) s;
}
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	57                   	push   %edi
  801c9d:	56                   	push   %esi
  801c9e:	53                   	push   %ebx
  801c9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca5:	85 c9                	test   %ecx,%ecx
  801ca7:	74 36                	je     801cdf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801caf:	75 28                	jne    801cd9 <memset+0x40>
  801cb1:	f6 c1 03             	test   $0x3,%cl
  801cb4:	75 23                	jne    801cd9 <memset+0x40>
		c &= 0xFF;
  801cb6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cba:	89 d3                	mov    %edx,%ebx
  801cbc:	c1 e3 08             	shl    $0x8,%ebx
  801cbf:	89 d6                	mov    %edx,%esi
  801cc1:	c1 e6 18             	shl    $0x18,%esi
  801cc4:	89 d0                	mov    %edx,%eax
  801cc6:	c1 e0 10             	shl    $0x10,%eax
  801cc9:	09 f0                	or     %esi,%eax
  801ccb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ccd:	89 d8                	mov    %ebx,%eax
  801ccf:	09 d0                	or     %edx,%eax
  801cd1:	c1 e9 02             	shr    $0x2,%ecx
  801cd4:	fc                   	cld    
  801cd5:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd7:	eb 06                	jmp    801cdf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdc:	fc                   	cld    
  801cdd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf4:	39 c6                	cmp    %eax,%esi
  801cf6:	73 35                	jae    801d2d <memmove+0x47>
  801cf8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cfb:	39 d0                	cmp    %edx,%eax
  801cfd:	73 2e                	jae    801d2d <memmove+0x47>
		s += n;
		d += n;
  801cff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d02:	89 d6                	mov    %edx,%esi
  801d04:	09 fe                	or     %edi,%esi
  801d06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d0c:	75 13                	jne    801d21 <memmove+0x3b>
  801d0e:	f6 c1 03             	test   $0x3,%cl
  801d11:	75 0e                	jne    801d21 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d13:	83 ef 04             	sub    $0x4,%edi
  801d16:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d19:	c1 e9 02             	shr    $0x2,%ecx
  801d1c:	fd                   	std    
  801d1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d1f:	eb 09                	jmp    801d2a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d21:	83 ef 01             	sub    $0x1,%edi
  801d24:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d27:	fd                   	std    
  801d28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d2a:	fc                   	cld    
  801d2b:	eb 1d                	jmp    801d4a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	09 c2                	or     %eax,%edx
  801d31:	f6 c2 03             	test   $0x3,%dl
  801d34:	75 0f                	jne    801d45 <memmove+0x5f>
  801d36:	f6 c1 03             	test   $0x3,%cl
  801d39:	75 0a                	jne    801d45 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d3b:	c1 e9 02             	shr    $0x2,%ecx
  801d3e:	89 c7                	mov    %eax,%edi
  801d40:	fc                   	cld    
  801d41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d43:	eb 05                	jmp    801d4a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d45:	89 c7                	mov    %eax,%edi
  801d47:	fc                   	cld    
  801d48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d4a:	5e                   	pop    %esi
  801d4b:	5f                   	pop    %edi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d51:	ff 75 10             	pushl  0x10(%ebp)
  801d54:	ff 75 0c             	pushl  0xc(%ebp)
  801d57:	ff 75 08             	pushl  0x8(%ebp)
  801d5a:	e8 87 ff ff ff       	call   801ce6 <memmove>
}
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    

00801d61 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	56                   	push   %esi
  801d65:	53                   	push   %ebx
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
  801d69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6c:	89 c6                	mov    %eax,%esi
  801d6e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d71:	eb 1a                	jmp    801d8d <memcmp+0x2c>
		if (*s1 != *s2)
  801d73:	0f b6 08             	movzbl (%eax),%ecx
  801d76:	0f b6 1a             	movzbl (%edx),%ebx
  801d79:	38 d9                	cmp    %bl,%cl
  801d7b:	74 0a                	je     801d87 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d7d:	0f b6 c1             	movzbl %cl,%eax
  801d80:	0f b6 db             	movzbl %bl,%ebx
  801d83:	29 d8                	sub    %ebx,%eax
  801d85:	eb 0f                	jmp    801d96 <memcmp+0x35>
		s1++, s2++;
  801d87:	83 c0 01             	add    $0x1,%eax
  801d8a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8d:	39 f0                	cmp    %esi,%eax
  801d8f:	75 e2                	jne    801d73 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d96:	5b                   	pop    %ebx
  801d97:	5e                   	pop    %esi
  801d98:	5d                   	pop    %ebp
  801d99:	c3                   	ret    

00801d9a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	53                   	push   %ebx
  801d9e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801da1:	89 c1                	mov    %eax,%ecx
  801da3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801daa:	eb 0a                	jmp    801db6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dac:	0f b6 10             	movzbl (%eax),%edx
  801daf:	39 da                	cmp    %ebx,%edx
  801db1:	74 07                	je     801dba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db3:	83 c0 01             	add    $0x1,%eax
  801db6:	39 c8                	cmp    %ecx,%eax
  801db8:	72 f2                	jb     801dac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dba:	5b                   	pop    %ebx
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    

00801dbd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	57                   	push   %edi
  801dc1:	56                   	push   %esi
  801dc2:	53                   	push   %ebx
  801dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc9:	eb 03                	jmp    801dce <strtol+0x11>
		s++;
  801dcb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dce:	0f b6 01             	movzbl (%ecx),%eax
  801dd1:	3c 20                	cmp    $0x20,%al
  801dd3:	74 f6                	je     801dcb <strtol+0xe>
  801dd5:	3c 09                	cmp    $0x9,%al
  801dd7:	74 f2                	je     801dcb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd9:	3c 2b                	cmp    $0x2b,%al
  801ddb:	75 0a                	jne    801de7 <strtol+0x2a>
		s++;
  801ddd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801de0:	bf 00 00 00 00       	mov    $0x0,%edi
  801de5:	eb 11                	jmp    801df8 <strtol+0x3b>
  801de7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dec:	3c 2d                	cmp    $0x2d,%al
  801dee:	75 08                	jne    801df8 <strtol+0x3b>
		s++, neg = 1;
  801df0:	83 c1 01             	add    $0x1,%ecx
  801df3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfe:	75 15                	jne    801e15 <strtol+0x58>
  801e00:	80 39 30             	cmpb   $0x30,(%ecx)
  801e03:	75 10                	jne    801e15 <strtol+0x58>
  801e05:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e09:	75 7c                	jne    801e87 <strtol+0xca>
		s += 2, base = 16;
  801e0b:	83 c1 02             	add    $0x2,%ecx
  801e0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e13:	eb 16                	jmp    801e2b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e15:	85 db                	test   %ebx,%ebx
  801e17:	75 12                	jne    801e2b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e19:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e1e:	80 39 30             	cmpb   $0x30,(%ecx)
  801e21:	75 08                	jne    801e2b <strtol+0x6e>
		s++, base = 8;
  801e23:	83 c1 01             	add    $0x1,%ecx
  801e26:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e30:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e33:	0f b6 11             	movzbl (%ecx),%edx
  801e36:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e39:	89 f3                	mov    %esi,%ebx
  801e3b:	80 fb 09             	cmp    $0x9,%bl
  801e3e:	77 08                	ja     801e48 <strtol+0x8b>
			dig = *s - '0';
  801e40:	0f be d2             	movsbl %dl,%edx
  801e43:	83 ea 30             	sub    $0x30,%edx
  801e46:	eb 22                	jmp    801e6a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e48:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e4b:	89 f3                	mov    %esi,%ebx
  801e4d:	80 fb 19             	cmp    $0x19,%bl
  801e50:	77 08                	ja     801e5a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e52:	0f be d2             	movsbl %dl,%edx
  801e55:	83 ea 57             	sub    $0x57,%edx
  801e58:	eb 10                	jmp    801e6a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e5a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e5d:	89 f3                	mov    %esi,%ebx
  801e5f:	80 fb 19             	cmp    $0x19,%bl
  801e62:	77 16                	ja     801e7a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e64:	0f be d2             	movsbl %dl,%edx
  801e67:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e6a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e6d:	7d 0b                	jge    801e7a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e6f:	83 c1 01             	add    $0x1,%ecx
  801e72:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e76:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e78:	eb b9                	jmp    801e33 <strtol+0x76>

	if (endptr)
  801e7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e7e:	74 0d                	je     801e8d <strtol+0xd0>
		*endptr = (char *) s;
  801e80:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e83:	89 0e                	mov    %ecx,(%esi)
  801e85:	eb 06                	jmp    801e8d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e87:	85 db                	test   %ebx,%ebx
  801e89:	74 98                	je     801e23 <strtol+0x66>
  801e8b:	eb 9e                	jmp    801e2b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e8d:	89 c2                	mov    %eax,%edx
  801e8f:	f7 da                	neg    %edx
  801e91:	85 ff                	test   %edi,%edi
  801e93:	0f 45 c2             	cmovne %edx,%eax
}
  801e96:	5b                   	pop    %ebx
  801e97:	5e                   	pop    %esi
  801e98:	5f                   	pop    %edi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	56                   	push   %esi
  801e9f:	53                   	push   %ebx
  801ea0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	74 0e                	je     801ebb <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801ead:	83 ec 0c             	sub    $0xc,%esp
  801eb0:	50                   	push   %eax
  801eb1:	e8 6a e4 ff ff       	call   800320 <sys_ipc_recv>
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	eb 10                	jmp    801ecb <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801ebb:	83 ec 0c             	sub    $0xc,%esp
  801ebe:	68 00 00 00 f0       	push   $0xf0000000
  801ec3:	e8 58 e4 ff ff       	call   800320 <sys_ipc_recv>
  801ec8:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	74 0e                	je     801edd <ipc_recv+0x42>
    	*from_env_store = 0;
  801ecf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ed5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801edb:	eb 24                	jmp    801f01 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801edd:	85 f6                	test   %esi,%esi
  801edf:	74 0a                	je     801eeb <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ee1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee6:	8b 40 74             	mov    0x74(%eax),%eax
  801ee9:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801eeb:	85 db                	test   %ebx,%ebx
  801eed:	74 0a                	je     801ef9 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801eef:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef4:	8b 40 78             	mov    0x78(%eax),%eax
  801ef7:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801ef9:	a1 08 40 80 00       	mov    0x804008,%eax
  801efe:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5e                   	pop    %esi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	57                   	push   %edi
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f1a:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f21:	0f 44 d8             	cmove  %eax,%ebx
  801f24:	eb 1c                	jmp    801f42 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f26:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f29:	74 12                	je     801f3d <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f2b:	50                   	push   %eax
  801f2c:	68 e0 26 80 00       	push   $0x8026e0
  801f31:	6a 4b                	push   $0x4b
  801f33:	68 f8 26 80 00       	push   $0x8026f8
  801f38:	e8 b9 f5 ff ff       	call   8014f6 <_panic>
        }	
        sys_yield();
  801f3d:	e8 0f e2 ff ff       	call   800151 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f42:	ff 75 14             	pushl  0x14(%ebp)
  801f45:	53                   	push   %ebx
  801f46:	56                   	push   %esi
  801f47:	57                   	push   %edi
  801f48:	e8 b0 e3 ff ff       	call   8002fd <sys_ipc_try_send>
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	75 d2                	jne    801f26 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f57:	5b                   	pop    %ebx
  801f58:	5e                   	pop    %esi
  801f59:	5f                   	pop    %edi
  801f5a:	5d                   	pop    %ebp
  801f5b:	c3                   	ret    

00801f5c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f67:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f70:	8b 52 50             	mov    0x50(%edx),%edx
  801f73:	39 ca                	cmp    %ecx,%edx
  801f75:	75 0d                	jne    801f84 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f77:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f7f:	8b 40 48             	mov    0x48(%eax),%eax
  801f82:	eb 0f                	jmp    801f93 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f84:	83 c0 01             	add    $0x1,%eax
  801f87:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f8c:	75 d9                	jne    801f67 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9b:	89 d0                	mov    %edx,%eax
  801f9d:	c1 e8 16             	shr    $0x16,%eax
  801fa0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fac:	f6 c1 01             	test   $0x1,%cl
  801faf:	74 1d                	je     801fce <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb1:	c1 ea 0c             	shr    $0xc,%edx
  801fb4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbb:	f6 c2 01             	test   $0x1,%dl
  801fbe:	74 0e                	je     801fce <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc0:	c1 ea 0c             	shr    $0xc,%edx
  801fc3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fca:	ef 
  801fcb:	0f b7 c0             	movzwl %ax,%eax
}
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    

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
