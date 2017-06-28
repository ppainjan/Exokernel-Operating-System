
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800045:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80004c:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80004f:	e8 ce 00 00 00       	call   800122 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800061:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 db                	test   %ebx,%ebx
  800068:	7e 07                	jle    800071 <libmain+0x37>
		binaryname = argv[0];
  80006a:	8b 06                	mov    (%esi),%eax
  80006c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800071:	83 ec 08             	sub    $0x8,%esp
  800074:	56                   	push   %esi
  800075:	53                   	push   %ebx
  800076:	e8 b8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007b:	e8 0a 00 00 00       	call   80008a <exit>
}
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    

0080008a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800090:	e8 c7 04 00 00       	call   80055c <close_all>
	sys_env_destroy(0);
  800095:	83 ec 0c             	sub    $0xc,%esp
  800098:	6a 00                	push   $0x0
  80009a:	e8 42 00 00 00       	call   8000e1 <sys_env_destroy>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	89 cb                	mov    %ecx,%ebx
  8000f9:	89 cf                	mov    %ecx,%edi
  8000fb:	89 ce                	mov    %ecx,%esi
  8000fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7e 17                	jle    80011a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	50                   	push   %eax
  800107:	6a 03                	push   $0x3
  800109:	68 6a 22 80 00       	push   $0x80226a
  80010e:	6a 23                	push   $0x23
  800110:	68 87 22 80 00       	push   $0x802287
  800115:	e8 cc 13 00 00       	call   8014e6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011d:	5b                   	pop    %ebx
  80011e:	5e                   	pop    %esi
  80011f:	5f                   	pop    %edi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	57                   	push   %edi
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800128:	ba 00 00 00 00       	mov    $0x0,%edx
  80012d:	b8 02 00 00 00       	mov    $0x2,%eax
  800132:	89 d1                	mov    %edx,%ecx
  800134:	89 d3                	mov    %edx,%ebx
  800136:	89 d7                	mov    %edx,%edi
  800138:	89 d6                	mov    %edx,%esi
  80013a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013c:	5b                   	pop    %ebx
  80013d:	5e                   	pop    %esi
  80013e:	5f                   	pop    %edi
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <sys_yield>:

void
sys_yield(void)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	57                   	push   %edi
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800147:	ba 00 00 00 00       	mov    $0x0,%edx
  80014c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800151:	89 d1                	mov    %edx,%ecx
  800153:	89 d3                	mov    %edx,%ebx
  800155:	89 d7                	mov    %edx,%edi
  800157:	89 d6                	mov    %edx,%esi
  800159:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5f                   	pop    %edi
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800169:	be 00 00 00 00       	mov    $0x0,%esi
  80016e:	b8 04 00 00 00       	mov    $0x4,%eax
  800173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017c:	89 f7                	mov    %esi,%edi
  80017e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800180:	85 c0                	test   %eax,%eax
  800182:	7e 17                	jle    80019b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	50                   	push   %eax
  800188:	6a 04                	push   $0x4
  80018a:	68 6a 22 80 00       	push   $0x80226a
  80018f:	6a 23                	push   $0x23
  800191:	68 87 22 80 00       	push   $0x802287
  800196:	e8 4b 13 00 00       	call   8014e6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	7e 17                	jle    8001dd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c6:	83 ec 0c             	sub    $0xc,%esp
  8001c9:	50                   	push   %eax
  8001ca:	6a 05                	push   $0x5
  8001cc:	68 6a 22 80 00       	push   $0x80226a
  8001d1:	6a 23                	push   $0x23
  8001d3:	68 87 22 80 00       	push   $0x802287
  8001d8:	e8 09 13 00 00       	call   8014e6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	89 df                	mov    %ebx,%edi
  800200:	89 de                	mov    %ebx,%esi
  800202:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 17                	jle    80021f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	83 ec 0c             	sub    $0xc,%esp
  80020b:	50                   	push   %eax
  80020c:	6a 06                	push   $0x6
  80020e:	68 6a 22 80 00       	push   $0x80226a
  800213:	6a 23                	push   $0x23
  800215:	68 87 22 80 00       	push   $0x802287
  80021a:	e8 c7 12 00 00       	call   8014e6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800222:	5b                   	pop    %ebx
  800223:	5e                   	pop    %esi
  800224:	5f                   	pop    %edi
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	b8 08 00 00 00       	mov    $0x8,%eax
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	89 df                	mov    %ebx,%edi
  800242:	89 de                	mov    %ebx,%esi
  800244:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800246:	85 c0                	test   %eax,%eax
  800248:	7e 17                	jle    800261 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	50                   	push   %eax
  80024e:	6a 08                	push   $0x8
  800250:	68 6a 22 80 00       	push   $0x80226a
  800255:	6a 23                	push   $0x23
  800257:	68 87 22 80 00       	push   $0x802287
  80025c:	e8 85 12 00 00       	call   8014e6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800264:	5b                   	pop    %ebx
  800265:	5e                   	pop    %esi
  800266:	5f                   	pop    %edi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800272:	bb 00 00 00 00       	mov    $0x0,%ebx
  800277:	b8 09 00 00 00       	mov    $0x9,%eax
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	89 df                	mov    %ebx,%edi
  800284:	89 de                	mov    %ebx,%esi
  800286:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800288:	85 c0                	test   %eax,%eax
  80028a:	7e 17                	jle    8002a3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	50                   	push   %eax
  800290:	6a 09                	push   $0x9
  800292:	68 6a 22 80 00       	push   $0x80226a
  800297:	6a 23                	push   $0x23
  800299:	68 87 22 80 00       	push   $0x802287
  80029e:	e8 43 12 00 00       	call   8014e6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5e                   	pop    %esi
  8002a8:	5f                   	pop    %edi
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c4:	89 df                	mov    %ebx,%edi
  8002c6:	89 de                	mov    %ebx,%esi
  8002c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	7e 17                	jle    8002e5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	50                   	push   %eax
  8002d2:	6a 0a                	push   $0xa
  8002d4:	68 6a 22 80 00       	push   $0x80226a
  8002d9:	6a 23                	push   $0x23
  8002db:	68 87 22 80 00       	push   $0x802287
  8002e0:	e8 01 12 00 00       	call   8014e6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e8:	5b                   	pop    %ebx
  8002e9:	5e                   	pop    %esi
  8002ea:	5f                   	pop    %edi
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f3:	be 00 00 00 00       	mov    $0x0,%esi
  8002f8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800306:	8b 7d 14             	mov    0x14(%ebp),%edi
  800309:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030b:	5b                   	pop    %ebx
  80030c:	5e                   	pop    %esi
  80030d:	5f                   	pop    %edi
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800319:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
  800326:	89 cb                	mov    %ecx,%ebx
  800328:	89 cf                	mov    %ecx,%edi
  80032a:	89 ce                	mov    %ecx,%esi
  80032c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032e:	85 c0                	test   %eax,%eax
  800330:	7e 17                	jle    800349 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800332:	83 ec 0c             	sub    $0xc,%esp
  800335:	50                   	push   %eax
  800336:	6a 0d                	push   $0xd
  800338:	68 6a 22 80 00       	push   $0x80226a
  80033d:	6a 23                	push   $0x23
  80033f:	68 87 22 80 00       	push   $0x802287
  800344:	e8 9d 11 00 00       	call   8014e6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800349:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034c:	5b                   	pop    %ebx
  80034d:	5e                   	pop    %esi
  80034e:	5f                   	pop    %edi
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	57                   	push   %edi
  800355:	56                   	push   %esi
  800356:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800357:	ba 00 00 00 00       	mov    $0x0,%edx
  80035c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800361:	89 d1                	mov    %edx,%ecx
  800363:	89 d3                	mov    %edx,%ebx
  800365:	89 d7                	mov    %edx,%edi
  800367:	89 d6                	mov    %edx,%esi
  800369:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036b:	5b                   	pop    %ebx
  80036c:	5e                   	pop    %esi
  80036d:	5f                   	pop    %edi
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800376:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800380:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800383:	8b 55 08             	mov    0x8(%ebp),%edx
  800386:	89 df                	mov    %ebx,%edi
  800388:	89 de                	mov    %ebx,%esi
  80038a:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	05 00 00 00 30       	add    $0x30000000,%eax
  80039c:	c1 e8 0c             	shr    $0xc,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c3:	89 c2                	mov    %eax,%edx
  8003c5:	c1 ea 16             	shr    $0x16,%edx
  8003c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003cf:	f6 c2 01             	test   $0x1,%dl
  8003d2:	74 11                	je     8003e5 <fd_alloc+0x2d>
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 0c             	shr    $0xc,%edx
  8003d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	75 09                	jne    8003ee <fd_alloc+0x36>
			*fd_store = fd;
  8003e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ec:	eb 17                	jmp    800405 <fd_alloc+0x4d>
  8003ee:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f8:	75 c9                	jne    8003c3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800400:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040d:	83 f8 1f             	cmp    $0x1f,%eax
  800410:	77 36                	ja     800448 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800412:	c1 e0 0c             	shl    $0xc,%eax
  800415:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 ea 16             	shr    $0x16,%edx
  80041f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800426:	f6 c2 01             	test   $0x1,%dl
  800429:	74 24                	je     80044f <fd_lookup+0x48>
  80042b:	89 c2                	mov    %eax,%edx
  80042d:	c1 ea 0c             	shr    $0xc,%edx
  800430:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	74 1a                	je     800456 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043f:	89 02                	mov    %eax,(%edx)
	return 0;
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	eb 13                	jmp    80045b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044d:	eb 0c                	jmp    80045b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800454:	eb 05                	jmp    80045b <fd_lookup+0x54>
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800466:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046b:	eb 13                	jmp    800480 <dev_lookup+0x23>
  80046d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800470:	39 08                	cmp    %ecx,(%eax)
  800472:	75 0c                	jne    800480 <dev_lookup+0x23>
			*dev = devtab[i];
  800474:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800477:	89 01                	mov    %eax,(%ecx)
			return 0;
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
  80047e:	eb 2e                	jmp    8004ae <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800480:	8b 02                	mov    (%edx),%eax
  800482:	85 c0                	test   %eax,%eax
  800484:	75 e7                	jne    80046d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800486:	a1 08 40 80 00       	mov    0x804008,%eax
  80048b:	8b 40 48             	mov    0x48(%eax),%eax
  80048e:	83 ec 04             	sub    $0x4,%esp
  800491:	51                   	push   %ecx
  800492:	50                   	push   %eax
  800493:	68 98 22 80 00       	push   $0x802298
  800498:	e8 22 11 00 00       	call   8015bf <cprintf>
	*dev = 0;
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 10             	sub    $0x10,%esp
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c1:	50                   	push   %eax
  8004c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c8:	c1 e8 0c             	shr    $0xc,%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 36 ff ff ff       	call   800407 <fd_lookup>
  8004d1:	83 c4 08             	add    $0x8,%esp
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 05                	js     8004dd <fd_close+0x2d>
	    || fd != fd2)
  8004d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004db:	74 0c                	je     8004e9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004dd:	84 db                	test   %bl,%bl
  8004df:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e4:	0f 44 c2             	cmove  %edx,%eax
  8004e7:	eb 41                	jmp    80052a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 36                	pushl  (%esi)
  8004f2:	e8 66 ff ff ff       	call   80045d <dev_lookup>
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 1a                	js     80051a <fd_close+0x6a>
		if (dev->dev_close)
  800500:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800503:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800506:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050b:	85 c0                	test   %eax,%eax
  80050d:	74 0b                	je     80051a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80050f:	83 ec 0c             	sub    $0xc,%esp
  800512:	56                   	push   %esi
  800513:	ff d0                	call   *%eax
  800515:	89 c3                	mov    %eax,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	56                   	push   %esi
  80051e:	6a 00                	push   $0x0
  800520:	e8 c0 fc ff ff       	call   8001e5 <sys_page_unmap>
	return r;
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	89 d8                	mov    %ebx,%eax
}
  80052a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052d:	5b                   	pop    %ebx
  80052e:	5e                   	pop    %esi
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800537:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053a:	50                   	push   %eax
  80053b:	ff 75 08             	pushl  0x8(%ebp)
  80053e:	e8 c4 fe ff ff       	call   800407 <fd_lookup>
  800543:	83 c4 08             	add    $0x8,%esp
  800546:	85 c0                	test   %eax,%eax
  800548:	78 10                	js     80055a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	6a 01                	push   $0x1
  80054f:	ff 75 f4             	pushl  -0xc(%ebp)
  800552:	e8 59 ff ff ff       	call   8004b0 <fd_close>
  800557:	83 c4 10             	add    $0x10,%esp
}
  80055a:	c9                   	leave  
  80055b:	c3                   	ret    

0080055c <close_all>:

void
close_all(void)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	53                   	push   %ebx
  800560:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800563:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	53                   	push   %ebx
  80056c:	e8 c0 ff ff ff       	call   800531 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800571:	83 c3 01             	add    $0x1,%ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	83 fb 20             	cmp    $0x20,%ebx
  80057a:	75 ec                	jne    800568 <close_all+0xc>
		close(i);
}
  80057c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 2c             	sub    $0x2c,%esp
  80058a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800590:	50                   	push   %eax
  800591:	ff 75 08             	pushl  0x8(%ebp)
  800594:	e8 6e fe ff ff       	call   800407 <fd_lookup>
  800599:	83 c4 08             	add    $0x8,%esp
  80059c:	85 c0                	test   %eax,%eax
  80059e:	0f 88 c1 00 00 00    	js     800665 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	56                   	push   %esi
  8005a8:	e8 84 ff ff ff       	call   800531 <close>

	newfd = INDEX2FD(newfdnum);
  8005ad:	89 f3                	mov    %esi,%ebx
  8005af:	c1 e3 0c             	shl    $0xc,%ebx
  8005b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b8:	83 c4 04             	add    $0x4,%esp
  8005bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005be:	e8 de fd ff ff       	call   8003a1 <fd2data>
  8005c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c5:	89 1c 24             	mov    %ebx,(%esp)
  8005c8:	e8 d4 fd ff ff       	call   8003a1 <fd2data>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d3:	89 f8                	mov    %edi,%eax
  8005d5:	c1 e8 16             	shr    $0x16,%eax
  8005d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005df:	a8 01                	test   $0x1,%al
  8005e1:	74 37                	je     80061a <dup+0x99>
  8005e3:	89 f8                	mov    %edi,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ef:	f6 c2 01             	test   $0x1,%dl
  8005f2:	74 26                	je     80061a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	25 07 0e 00 00       	and    $0xe07,%eax
  800603:	50                   	push   %eax
  800604:	ff 75 d4             	pushl  -0x2c(%ebp)
  800607:	6a 00                	push   $0x0
  800609:	57                   	push   %edi
  80060a:	6a 00                	push   $0x0
  80060c:	e8 92 fb ff ff       	call   8001a3 <sys_page_map>
  800611:	89 c7                	mov    %eax,%edi
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	85 c0                	test   %eax,%eax
  800618:	78 2e                	js     800648 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061d:	89 d0                	mov    %edx,%eax
  80061f:	c1 e8 0c             	shr    $0xc,%eax
  800622:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800629:	83 ec 0c             	sub    $0xc,%esp
  80062c:	25 07 0e 00 00       	and    $0xe07,%eax
  800631:	50                   	push   %eax
  800632:	53                   	push   %ebx
  800633:	6a 00                	push   $0x0
  800635:	52                   	push   %edx
  800636:	6a 00                	push   $0x0
  800638:	e8 66 fb ff ff       	call   8001a3 <sys_page_map>
  80063d:	89 c7                	mov    %eax,%edi
  80063f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800642:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800644:	85 ff                	test   %edi,%edi
  800646:	79 1d                	jns    800665 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 00                	push   $0x0
  80064e:	e8 92 fb ff ff       	call   8001e5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	ff 75 d4             	pushl  -0x2c(%ebp)
  800659:	6a 00                	push   $0x0
  80065b:	e8 85 fb ff ff       	call   8001e5 <sys_page_unmap>
	return r;
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	89 f8                	mov    %edi,%eax
}
  800665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800668:	5b                   	pop    %ebx
  800669:	5e                   	pop    %esi
  80066a:	5f                   	pop    %edi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	53                   	push   %ebx
  800671:	83 ec 14             	sub    $0x14,%esp
  800674:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800677:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	53                   	push   %ebx
  80067c:	e8 86 fd ff ff       	call   800407 <fd_lookup>
  800681:	83 c4 08             	add    $0x8,%esp
  800684:	89 c2                	mov    %eax,%edx
  800686:	85 c0                	test   %eax,%eax
  800688:	78 6d                	js     8006f7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800690:	50                   	push   %eax
  800691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800694:	ff 30                	pushl  (%eax)
  800696:	e8 c2 fd ff ff       	call   80045d <dev_lookup>
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	78 4c                	js     8006ee <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a5:	8b 42 08             	mov    0x8(%edx),%eax
  8006a8:	83 e0 03             	and    $0x3,%eax
  8006ab:	83 f8 01             	cmp    $0x1,%eax
  8006ae:	75 21                	jne    8006d1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8006b5:	8b 40 48             	mov    0x48(%eax),%eax
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	50                   	push   %eax
  8006bd:	68 d9 22 80 00       	push   $0x8022d9
  8006c2:	e8 f8 0e 00 00       	call   8015bf <cprintf>
		return -E_INVAL;
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006cf:	eb 26                	jmp    8006f7 <read+0x8a>
	}
	if (!dev->dev_read)
  8006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d4:	8b 40 08             	mov    0x8(%eax),%eax
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 17                	je     8006f2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006db:	83 ec 04             	sub    $0x4,%esp
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	ff 75 0c             	pushl  0xc(%ebp)
  8006e4:	52                   	push   %edx
  8006e5:	ff d0                	call   *%eax
  8006e7:	89 c2                	mov    %eax,%edx
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb 09                	jmp    8006f7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ee:	89 c2                	mov    %eax,%edx
  8006f0:	eb 05                	jmp    8006f7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f7:	89 d0                	mov    %edx,%eax
  8006f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	57                   	push   %edi
  800702:	56                   	push   %esi
  800703:	53                   	push   %ebx
  800704:	83 ec 0c             	sub    $0xc,%esp
  800707:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800712:	eb 21                	jmp    800735 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	89 f0                	mov    %esi,%eax
  800719:	29 d8                	sub    %ebx,%eax
  80071b:	50                   	push   %eax
  80071c:	89 d8                	mov    %ebx,%eax
  80071e:	03 45 0c             	add    0xc(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	57                   	push   %edi
  800723:	e8 45 ff ff ff       	call   80066d <read>
		if (m < 0)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 10                	js     80073f <readn+0x41>
			return m;
		if (m == 0)
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 0a                	je     80073d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800733:	01 c3                	add    %eax,%ebx
  800735:	39 f3                	cmp    %esi,%ebx
  800737:	72 db                	jb     800714 <readn+0x16>
  800739:	89 d8                	mov    %ebx,%eax
  80073b:	eb 02                	jmp    80073f <readn+0x41>
  80073d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	83 ec 14             	sub    $0x14,%esp
  80074e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800751:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800754:	50                   	push   %eax
  800755:	53                   	push   %ebx
  800756:	e8 ac fc ff ff       	call   800407 <fd_lookup>
  80075b:	83 c4 08             	add    $0x8,%esp
  80075e:	89 c2                	mov    %eax,%edx
  800760:	85 c0                	test   %eax,%eax
  800762:	78 68                	js     8007cc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076e:	ff 30                	pushl  (%eax)
  800770:	e8 e8 fc ff ff       	call   80045d <dev_lookup>
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 c0                	test   %eax,%eax
  80077a:	78 47                	js     8007c3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800783:	75 21                	jne    8007a6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800785:	a1 08 40 80 00       	mov    0x804008,%eax
  80078a:	8b 40 48             	mov    0x48(%eax),%eax
  80078d:	83 ec 04             	sub    $0x4,%esp
  800790:	53                   	push   %ebx
  800791:	50                   	push   %eax
  800792:	68 f5 22 80 00       	push   $0x8022f5
  800797:	e8 23 0e 00 00       	call   8015bf <cprintf>
		return -E_INVAL;
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a4:	eb 26                	jmp    8007cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 17                	je     8007c7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b0:	83 ec 04             	sub    $0x4,%esp
  8007b3:	ff 75 10             	pushl  0x10(%ebp)
  8007b6:	ff 75 0c             	pushl  0xc(%ebp)
  8007b9:	50                   	push   %eax
  8007ba:	ff d2                	call   *%edx
  8007bc:	89 c2                	mov    %eax,%edx
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 09                	jmp    8007cc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	eb 05                	jmp    8007cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007cc:	89 d0                	mov    %edx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	ff 75 08             	pushl  0x8(%ebp)
  8007e0:	e8 22 fc ff ff       	call   800407 <fd_lookup>
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	78 0e                	js     8007fa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	83 ec 14             	sub    $0x14,%esp
  800803:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800806:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800809:	50                   	push   %eax
  80080a:	53                   	push   %ebx
  80080b:	e8 f7 fb ff ff       	call   800407 <fd_lookup>
  800810:	83 c4 08             	add    $0x8,%esp
  800813:	89 c2                	mov    %eax,%edx
  800815:	85 c0                	test   %eax,%eax
  800817:	78 65                	js     80087e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800823:	ff 30                	pushl  (%eax)
  800825:	e8 33 fc ff ff       	call   80045d <dev_lookup>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	85 c0                	test   %eax,%eax
  80082f:	78 44                	js     800875 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800834:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800838:	75 21                	jne    80085b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083f:	8b 40 48             	mov    0x48(%eax),%eax
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	53                   	push   %ebx
  800846:	50                   	push   %eax
  800847:	68 b8 22 80 00       	push   $0x8022b8
  80084c:	e8 6e 0d 00 00       	call   8015bf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800859:	eb 23                	jmp    80087e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085e:	8b 52 18             	mov    0x18(%edx),%edx
  800861:	85 d2                	test   %edx,%edx
  800863:	74 14                	je     800879 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	ff 75 0c             	pushl  0xc(%ebp)
  80086b:	50                   	push   %eax
  80086c:	ff d2                	call   *%edx
  80086e:	89 c2                	mov    %eax,%edx
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	eb 09                	jmp    80087e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800875:	89 c2                	mov    %eax,%edx
  800877:	eb 05                	jmp    80087e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800879:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087e:	89 d0                	mov    %edx,%eax
  800880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	83 ec 14             	sub    $0x14,%esp
  80088c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800892:	50                   	push   %eax
  800893:	ff 75 08             	pushl  0x8(%ebp)
  800896:	e8 6c fb ff ff       	call   800407 <fd_lookup>
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	78 58                	js     8008fc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ae:	ff 30                	pushl  (%eax)
  8008b0:	e8 a8 fb ff ff       	call   80045d <dev_lookup>
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	78 37                	js     8008f3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c3:	74 32                	je     8008f7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cf:	00 00 00 
	stat->st_isdir = 0;
  8008d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d9:	00 00 00 
	stat->st_dev = dev;
  8008dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e9:	ff 50 14             	call   *0x14(%eax)
  8008ec:	89 c2                	mov    %eax,%edx
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	eb 09                	jmp    8008fc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	eb 05                	jmp    8008fc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	6a 00                	push   $0x0
  80090d:	ff 75 08             	pushl  0x8(%ebp)
  800910:	e8 e7 01 00 00       	call   800afc <open>
  800915:	89 c3                	mov    %eax,%ebx
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 1b                	js     800939 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	ff 75 0c             	pushl  0xc(%ebp)
  800924:	50                   	push   %eax
  800925:	e8 5b ff ff ff       	call   800885 <fstat>
  80092a:	89 c6                	mov    %eax,%esi
	close(fd);
  80092c:	89 1c 24             	mov    %ebx,(%esp)
  80092f:	e8 fd fb ff ff       	call   800531 <close>
	return r;
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	89 f0                	mov    %esi,%eax
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	89 c6                	mov    %eax,%esi
  800947:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800949:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800950:	75 12                	jne    800964 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800952:	83 ec 0c             	sub    $0xc,%esp
  800955:	6a 01                	push   $0x1
  800957:	e8 f0 15 00 00       	call   801f4c <ipc_find_env>
  80095c:	a3 00 40 80 00       	mov    %eax,0x804000
  800961:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800964:	6a 07                	push   $0x7
  800966:	68 00 50 80 00       	push   $0x805000
  80096b:	56                   	push   %esi
  80096c:	ff 35 00 40 80 00    	pushl  0x804000
  800972:	e8 81 15 00 00       	call   801ef8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800977:	83 c4 0c             	add    $0xc,%esp
  80097a:	6a 00                	push   $0x0
  80097c:	53                   	push   %ebx
  80097d:	6a 00                	push   $0x0
  80097f:	e8 07 15 00 00       	call   801e8b <ipc_recv>
}
  800984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 40 0c             	mov    0xc(%eax),%eax
  800997:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ae:	e8 8d ff ff ff       	call   800940 <fsipc>
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d0:	e8 6b ff ff ff       	call   800940 <fsipc>
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	83 ec 04             	sub    $0x4,%esp
  8009de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f6:	e8 45 ff ff ff       	call   800940 <fsipc>
  8009fb:	85 c0                	test   %eax,%eax
  8009fd:	78 2c                	js     800a2b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	68 00 50 80 00       	push   $0x805000
  800a07:	53                   	push   %ebx
  800a08:	e8 37 11 00 00       	call   801b44 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0d:	a1 80 50 80 00       	mov    0x805080,%eax
  800a12:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a18:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a23:	83 c4 10             	add    $0x10,%esp
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	83 ec 08             	sub    $0x8,%esp
  800a37:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a3a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a3f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a44:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a47:	53                   	push   %ebx
  800a48:	ff 75 0c             	pushl  0xc(%ebp)
  800a4b:	68 08 50 80 00       	push   $0x805008
  800a50:	e8 81 12 00 00       	call   801cd6 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5b:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a60:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800a66:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a70:	e8 cb fe ff ff       	call   800940 <fsipc>
	//panic("devfile_write not implemented");
}
  800a75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	8b 40 0c             	mov    0xc(%eax),%eax
  800a88:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a93:	ba 00 00 00 00       	mov    $0x0,%edx
  800a98:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9d:	e8 9e fe ff ff       	call   800940 <fsipc>
  800aa2:	89 c3                	mov    %eax,%ebx
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	78 4b                	js     800af3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa8:	39 c6                	cmp    %eax,%esi
  800aaa:	73 16                	jae    800ac2 <devfile_read+0x48>
  800aac:	68 28 23 80 00       	push   $0x802328
  800ab1:	68 2f 23 80 00       	push   $0x80232f
  800ab6:	6a 7c                	push   $0x7c
  800ab8:	68 44 23 80 00       	push   $0x802344
  800abd:	e8 24 0a 00 00       	call   8014e6 <_panic>
	assert(r <= PGSIZE);
  800ac2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac7:	7e 16                	jle    800adf <devfile_read+0x65>
  800ac9:	68 4f 23 80 00       	push   $0x80234f
  800ace:	68 2f 23 80 00       	push   $0x80232f
  800ad3:	6a 7d                	push   $0x7d
  800ad5:	68 44 23 80 00       	push   $0x802344
  800ada:	e8 07 0a 00 00       	call   8014e6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800adf:	83 ec 04             	sub    $0x4,%esp
  800ae2:	50                   	push   %eax
  800ae3:	68 00 50 80 00       	push   $0x805000
  800ae8:	ff 75 0c             	pushl  0xc(%ebp)
  800aeb:	e8 e6 11 00 00       	call   801cd6 <memmove>
	return r;
  800af0:	83 c4 10             	add    $0x10,%esp
}
  800af3:	89 d8                	mov    %ebx,%eax
  800af5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	53                   	push   %ebx
  800b00:	83 ec 20             	sub    $0x20,%esp
  800b03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b06:	53                   	push   %ebx
  800b07:	e8 ff 0f 00 00       	call   801b0b <strlen>
  800b0c:	83 c4 10             	add    $0x10,%esp
  800b0f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b14:	7f 67                	jg     800b7d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b16:	83 ec 0c             	sub    $0xc,%esp
  800b19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1c:	50                   	push   %eax
  800b1d:	e8 96 f8 ff ff       	call   8003b8 <fd_alloc>
  800b22:	83 c4 10             	add    $0x10,%esp
		return r;
  800b25:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	78 57                	js     800b82 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2b:	83 ec 08             	sub    $0x8,%esp
  800b2e:	53                   	push   %ebx
  800b2f:	68 00 50 80 00       	push   $0x805000
  800b34:	e8 0b 10 00 00       	call   801b44 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b44:	b8 01 00 00 00       	mov    $0x1,%eax
  800b49:	e8 f2 fd ff ff       	call   800940 <fsipc>
  800b4e:	89 c3                	mov    %eax,%ebx
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	85 c0                	test   %eax,%eax
  800b55:	79 14                	jns    800b6b <open+0x6f>
		fd_close(fd, 0);
  800b57:	83 ec 08             	sub    $0x8,%esp
  800b5a:	6a 00                	push   $0x0
  800b5c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5f:	e8 4c f9 ff ff       	call   8004b0 <fd_close>
		return r;
  800b64:	83 c4 10             	add    $0x10,%esp
  800b67:	89 da                	mov    %ebx,%edx
  800b69:	eb 17                	jmp    800b82 <open+0x86>
	}

	return fd2num(fd);
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b71:	e8 1b f8 ff ff       	call   800391 <fd2num>
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	83 c4 10             	add    $0x10,%esp
  800b7b:	eb 05                	jmp    800b82 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b82:	89 d0                	mov    %edx,%eax
  800b84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 08 00 00 00       	mov    $0x8,%eax
  800b99:	e8 a2 fd ff ff       	call   800940 <fsipc>
}
  800b9e:	c9                   	leave  
  800b9f:	c3                   	ret    

00800ba0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba6:	68 5b 23 80 00       	push   $0x80235b
  800bab:	ff 75 0c             	pushl  0xc(%ebp)
  800bae:	e8 91 0f 00 00       	call   801b44 <strcpy>
	return 0;
}
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 10             	sub    $0x10,%esp
  800bc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc4:	53                   	push   %ebx
  800bc5:	e8 bb 13 00 00       	call   801f85 <pageref>
  800bca:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd2:	83 f8 01             	cmp    $0x1,%eax
  800bd5:	75 10                	jne    800be7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	ff 73 0c             	pushl  0xc(%ebx)
  800bdd:	e8 c0 02 00 00       	call   800ea2 <nsipc_close>
  800be2:	89 c2                	mov    %eax,%edx
  800be4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be7:	89 d0                	mov    %edx,%eax
  800be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf4:	6a 00                	push   $0x0
  800bf6:	ff 75 10             	pushl  0x10(%ebp)
  800bf9:	ff 75 0c             	pushl  0xc(%ebp)
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	ff 70 0c             	pushl  0xc(%eax)
  800c02:	e8 78 03 00 00       	call   800f7f <nsipc_send>
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c0f:	6a 00                	push   $0x0
  800c11:	ff 75 10             	pushl  0x10(%ebp)
  800c14:	ff 75 0c             	pushl  0xc(%ebp)
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	ff 70 0c             	pushl  0xc(%eax)
  800c1d:	e8 f1 02 00 00       	call   800f13 <nsipc_recv>
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2d:	52                   	push   %edx
  800c2e:	50                   	push   %eax
  800c2f:	e8 d3 f7 ff ff       	call   800407 <fd_lookup>
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	85 c0                	test   %eax,%eax
  800c39:	78 17                	js     800c52 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c44:	39 08                	cmp    %ecx,(%eax)
  800c46:	75 05                	jne    800c4d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c48:	8b 40 0c             	mov    0xc(%eax),%eax
  800c4b:	eb 05                	jmp    800c52 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c4d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 1c             	sub    $0x1c,%esp
  800c5c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c61:	50                   	push   %eax
  800c62:	e8 51 f7 ff ff       	call   8003b8 <fd_alloc>
  800c67:	89 c3                	mov    %eax,%ebx
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	78 1b                	js     800c8b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c70:	83 ec 04             	sub    $0x4,%esp
  800c73:	68 07 04 00 00       	push   $0x407
  800c78:	ff 75 f4             	pushl  -0xc(%ebp)
  800c7b:	6a 00                	push   $0x0
  800c7d:	e8 de f4 ff ff       	call   800160 <sys_page_alloc>
  800c82:	89 c3                	mov    %eax,%ebx
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	85 c0                	test   %eax,%eax
  800c89:	79 10                	jns    800c9b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	56                   	push   %esi
  800c8f:	e8 0e 02 00 00       	call   800ea2 <nsipc_close>
		return r;
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	89 d8                	mov    %ebx,%eax
  800c99:	eb 24                	jmp    800cbf <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c9b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	e8 d5 f6 ff ff       	call   800391 <fd2num>
  800cbc:	83 c4 10             	add    $0x10,%esp
}
  800cbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	e8 50 ff ff ff       	call   800c24 <fd2sockid>
		return r;
  800cd4:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	78 1f                	js     800cf9 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cda:	83 ec 04             	sub    $0x4,%esp
  800cdd:	ff 75 10             	pushl  0x10(%ebp)
  800ce0:	ff 75 0c             	pushl  0xc(%ebp)
  800ce3:	50                   	push   %eax
  800ce4:	e8 12 01 00 00       	call   800dfb <nsipc_accept>
  800ce9:	83 c4 10             	add    $0x10,%esp
		return r;
  800cec:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	78 07                	js     800cf9 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf2:	e8 5d ff ff ff       	call   800c54 <alloc_sockfd>
  800cf7:	89 c1                	mov    %eax,%ecx
}
  800cf9:	89 c8                	mov    %ecx,%eax
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    

00800cfd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	e8 19 ff ff ff       	call   800c24 <fd2sockid>
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	78 12                	js     800d21 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d0f:	83 ec 04             	sub    $0x4,%esp
  800d12:	ff 75 10             	pushl  0x10(%ebp)
  800d15:	ff 75 0c             	pushl  0xc(%ebp)
  800d18:	50                   	push   %eax
  800d19:	e8 2d 01 00 00       	call   800e4b <nsipc_bind>
  800d1e:	83 c4 10             	add    $0x10,%esp
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <shutdown>:

int
shutdown(int s, int how)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	e8 f3 fe ff ff       	call   800c24 <fd2sockid>
  800d31:	85 c0                	test   %eax,%eax
  800d33:	78 0f                	js     800d44 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d35:	83 ec 08             	sub    $0x8,%esp
  800d38:	ff 75 0c             	pushl  0xc(%ebp)
  800d3b:	50                   	push   %eax
  800d3c:	e8 3f 01 00 00       	call   800e80 <nsipc_shutdown>
  800d41:	83 c4 10             	add    $0x10,%esp
}
  800d44:	c9                   	leave  
  800d45:	c3                   	ret    

00800d46 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	e8 d0 fe ff ff       	call   800c24 <fd2sockid>
  800d54:	85 c0                	test   %eax,%eax
  800d56:	78 12                	js     800d6a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d58:	83 ec 04             	sub    $0x4,%esp
  800d5b:	ff 75 10             	pushl  0x10(%ebp)
  800d5e:	ff 75 0c             	pushl  0xc(%ebp)
  800d61:	50                   	push   %eax
  800d62:	e8 55 01 00 00       	call   800ebc <nsipc_connect>
  800d67:	83 c4 10             	add    $0x10,%esp
}
  800d6a:	c9                   	leave  
  800d6b:	c3                   	ret    

00800d6c <listen>:

int
listen(int s, int backlog)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	e8 aa fe ff ff       	call   800c24 <fd2sockid>
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	78 0f                	js     800d8d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d7e:	83 ec 08             	sub    $0x8,%esp
  800d81:	ff 75 0c             	pushl  0xc(%ebp)
  800d84:	50                   	push   %eax
  800d85:	e8 67 01 00 00       	call   800ef1 <nsipc_listen>
  800d8a:	83 c4 10             	add    $0x10,%esp
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d95:	ff 75 10             	pushl  0x10(%ebp)
  800d98:	ff 75 0c             	pushl  0xc(%ebp)
  800d9b:	ff 75 08             	pushl  0x8(%ebp)
  800d9e:	e8 3a 02 00 00       	call   800fdd <nsipc_socket>
  800da3:	83 c4 10             	add    $0x10,%esp
  800da6:	85 c0                	test   %eax,%eax
  800da8:	78 05                	js     800daf <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800daa:	e8 a5 fe ff ff       	call   800c54 <alloc_sockfd>
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	53                   	push   %ebx
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dba:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc1:	75 12                	jne    800dd5 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	6a 02                	push   $0x2
  800dc8:	e8 7f 11 00 00       	call   801f4c <ipc_find_env>
  800dcd:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd5:	6a 07                	push   $0x7
  800dd7:	68 00 60 80 00       	push   $0x806000
  800ddc:	53                   	push   %ebx
  800ddd:	ff 35 04 40 80 00    	pushl  0x804004
  800de3:	e8 10 11 00 00       	call   801ef8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800de8:	83 c4 0c             	add    $0xc,%esp
  800deb:	6a 00                	push   $0x0
  800ded:	6a 00                	push   $0x0
  800def:	6a 00                	push   $0x0
  800df1:	e8 95 10 00 00       	call   801e8b <ipc_recv>
}
  800df6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0b:	8b 06                	mov    (%esi),%eax
  800e0d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e12:	b8 01 00 00 00       	mov    $0x1,%eax
  800e17:	e8 95 ff ff ff       	call   800db1 <nsipc>
  800e1c:	89 c3                	mov    %eax,%ebx
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	78 20                	js     800e42 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e22:	83 ec 04             	sub    $0x4,%esp
  800e25:	ff 35 10 60 80 00    	pushl  0x806010
  800e2b:	68 00 60 80 00       	push   $0x806000
  800e30:	ff 75 0c             	pushl  0xc(%ebp)
  800e33:	e8 9e 0e 00 00       	call   801cd6 <memmove>
		*addrlen = ret->ret_addrlen;
  800e38:	a1 10 60 80 00       	mov    0x806010,%eax
  800e3d:	89 06                	mov    %eax,(%esi)
  800e3f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e42:	89 d8                	mov    %ebx,%eax
  800e44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5d:	53                   	push   %ebx
  800e5e:	ff 75 0c             	pushl  0xc(%ebp)
  800e61:	68 04 60 80 00       	push   $0x806004
  800e66:	e8 6b 0e 00 00       	call   801cd6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e6b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e71:	b8 02 00 00 00       	mov    $0x2,%eax
  800e76:	e8 36 ff ff ff       	call   800db1 <nsipc>
}
  800e7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e91:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e96:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9b:	e8 11 ff ff ff       	call   800db1 <nsipc>
}
  800ea0:	c9                   	leave  
  800ea1:	c3                   	ret    

00800ea2 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eab:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb5:	e8 f7 fe ff ff       	call   800db1 <nsipc>
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 08             	sub    $0x8,%esp
  800ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ece:	53                   	push   %ebx
  800ecf:	ff 75 0c             	pushl  0xc(%ebp)
  800ed2:	68 04 60 80 00       	push   $0x806004
  800ed7:	e8 fa 0d 00 00       	call   801cd6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800edc:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee7:	e8 c5 fe ff ff       	call   800db1 <nsipc>
}
  800eec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    

00800ef1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f02:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f07:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0c:	e8 a0 fe ff ff       	call   800db1 <nsipc>
}
  800f11:	c9                   	leave  
  800f12:	c3                   	ret    

00800f13 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f23:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f29:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f31:	b8 07 00 00 00       	mov    $0x7,%eax
  800f36:	e8 76 fe ff ff       	call   800db1 <nsipc>
  800f3b:	89 c3                	mov    %eax,%ebx
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 35                	js     800f76 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f41:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f46:	7f 04                	jg     800f4c <nsipc_recv+0x39>
  800f48:	39 c6                	cmp    %eax,%esi
  800f4a:	7d 16                	jge    800f62 <nsipc_recv+0x4f>
  800f4c:	68 67 23 80 00       	push   $0x802367
  800f51:	68 2f 23 80 00       	push   $0x80232f
  800f56:	6a 62                	push   $0x62
  800f58:	68 7c 23 80 00       	push   $0x80237c
  800f5d:	e8 84 05 00 00       	call   8014e6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	50                   	push   %eax
  800f66:	68 00 60 80 00       	push   $0x806000
  800f6b:	ff 75 0c             	pushl  0xc(%ebp)
  800f6e:	e8 63 0d 00 00       	call   801cd6 <memmove>
  800f73:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f76:	89 d8                	mov    %ebx,%eax
  800f78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7b:	5b                   	pop    %ebx
  800f7c:	5e                   	pop    %esi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	53                   	push   %ebx
  800f83:	83 ec 04             	sub    $0x4,%esp
  800f86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f91:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f97:	7e 16                	jle    800faf <nsipc_send+0x30>
  800f99:	68 88 23 80 00       	push   $0x802388
  800f9e:	68 2f 23 80 00       	push   $0x80232f
  800fa3:	6a 6d                	push   $0x6d
  800fa5:	68 7c 23 80 00       	push   $0x80237c
  800faa:	e8 37 05 00 00       	call   8014e6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	53                   	push   %ebx
  800fb3:	ff 75 0c             	pushl  0xc(%ebp)
  800fb6:	68 0c 60 80 00       	push   $0x80600c
  800fbb:	e8 16 0d 00 00       	call   801cd6 <memmove>
	nsipcbuf.send.req_size = size;
  800fc0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc6:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fce:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd3:	e8 d9 fd ff ff       	call   800db1 <nsipc>
}
  800fd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800feb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fee:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ffb:	b8 09 00 00 00       	mov    $0x9,%eax
  801000:	e8 ac fd ff ff       	call   800db1 <nsipc>
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	ff 75 08             	pushl  0x8(%ebp)
  801015:	e8 87 f3 ff ff       	call   8003a1 <fd2data>
  80101a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101c:	83 c4 08             	add    $0x8,%esp
  80101f:	68 94 23 80 00       	push   $0x802394
  801024:	53                   	push   %ebx
  801025:	e8 1a 0b 00 00       	call   801b44 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102a:	8b 46 04             	mov    0x4(%esi),%eax
  80102d:	2b 06                	sub    (%esi),%eax
  80102f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801035:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103c:	00 00 00 
	stat->st_dev = &devpipe;
  80103f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801046:	30 80 00 
	return 0;
}
  801049:	b8 00 00 00 00       	mov    $0x0,%eax
  80104e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	53                   	push   %ebx
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80105f:	53                   	push   %ebx
  801060:	6a 00                	push   $0x0
  801062:	e8 7e f1 ff ff       	call   8001e5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801067:	89 1c 24             	mov    %ebx,(%esp)
  80106a:	e8 32 f3 ff ff       	call   8003a1 <fd2data>
  80106f:	83 c4 08             	add    $0x8,%esp
  801072:	50                   	push   %eax
  801073:	6a 00                	push   $0x0
  801075:	e8 6b f1 ff ff       	call   8001e5 <sys_page_unmap>
}
  80107a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	57                   	push   %edi
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	83 ec 1c             	sub    $0x1c,%esp
  801088:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80108b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80108d:	a1 08 40 80 00       	mov    0x804008,%eax
  801092:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	ff 75 e0             	pushl  -0x20(%ebp)
  80109b:	e8 e5 0e 00 00       	call   801f85 <pageref>
  8010a0:	89 c3                	mov    %eax,%ebx
  8010a2:	89 3c 24             	mov    %edi,(%esp)
  8010a5:	e8 db 0e 00 00       	call   801f85 <pageref>
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	39 c3                	cmp    %eax,%ebx
  8010af:	0f 94 c1             	sete   %cl
  8010b2:	0f b6 c9             	movzbl %cl,%ecx
  8010b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010b8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010be:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c1:	39 ce                	cmp    %ecx,%esi
  8010c3:	74 1b                	je     8010e0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010c5:	39 c3                	cmp    %eax,%ebx
  8010c7:	75 c4                	jne    80108d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c9:	8b 42 58             	mov    0x58(%edx),%eax
  8010cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010cf:	50                   	push   %eax
  8010d0:	56                   	push   %esi
  8010d1:	68 9b 23 80 00       	push   $0x80239b
  8010d6:	e8 e4 04 00 00       	call   8015bf <cprintf>
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	eb ad                	jmp    80108d <_pipeisclosed+0xe>
	}
}
  8010e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 28             	sub    $0x28,%esp
  8010f4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f7:	56                   	push   %esi
  8010f8:	e8 a4 f2 ff ff       	call   8003a1 <fd2data>
  8010fd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	bf 00 00 00 00       	mov    $0x0,%edi
  801107:	eb 4b                	jmp    801154 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801109:	89 da                	mov    %ebx,%edx
  80110b:	89 f0                	mov    %esi,%eax
  80110d:	e8 6d ff ff ff       	call   80107f <_pipeisclosed>
  801112:	85 c0                	test   %eax,%eax
  801114:	75 48                	jne    80115e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801116:	e8 26 f0 ff ff       	call   800141 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80111b:	8b 43 04             	mov    0x4(%ebx),%eax
  80111e:	8b 0b                	mov    (%ebx),%ecx
  801120:	8d 51 20             	lea    0x20(%ecx),%edx
  801123:	39 d0                	cmp    %edx,%eax
  801125:	73 e2                	jae    801109 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801131:	89 c2                	mov    %eax,%edx
  801133:	c1 fa 1f             	sar    $0x1f,%edx
  801136:	89 d1                	mov    %edx,%ecx
  801138:	c1 e9 1b             	shr    $0x1b,%ecx
  80113b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113e:	83 e2 1f             	and    $0x1f,%edx
  801141:	29 ca                	sub    %ecx,%edx
  801143:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801147:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114b:	83 c0 01             	add    $0x1,%eax
  80114e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801151:	83 c7 01             	add    $0x1,%edi
  801154:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801157:	75 c2                	jne    80111b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801159:	8b 45 10             	mov    0x10(%ebp),%eax
  80115c:	eb 05                	jmp    801163 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80115e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801163:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5f                   	pop    %edi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	57                   	push   %edi
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	83 ec 18             	sub    $0x18,%esp
  801174:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801177:	57                   	push   %edi
  801178:	e8 24 f2 ff ff       	call   8003a1 <fd2data>
  80117d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	bb 00 00 00 00       	mov    $0x0,%ebx
  801187:	eb 3d                	jmp    8011c6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801189:	85 db                	test   %ebx,%ebx
  80118b:	74 04                	je     801191 <devpipe_read+0x26>
				return i;
  80118d:	89 d8                	mov    %ebx,%eax
  80118f:	eb 44                	jmp    8011d5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801191:	89 f2                	mov    %esi,%edx
  801193:	89 f8                	mov    %edi,%eax
  801195:	e8 e5 fe ff ff       	call   80107f <_pipeisclosed>
  80119a:	85 c0                	test   %eax,%eax
  80119c:	75 32                	jne    8011d0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80119e:	e8 9e ef ff ff       	call   800141 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a3:	8b 06                	mov    (%esi),%eax
  8011a5:	3b 46 04             	cmp    0x4(%esi),%eax
  8011a8:	74 df                	je     801189 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011aa:	99                   	cltd   
  8011ab:	c1 ea 1b             	shr    $0x1b,%edx
  8011ae:	01 d0                	add    %edx,%eax
  8011b0:	83 e0 1f             	and    $0x1f,%eax
  8011b3:	29 d0                	sub    %edx,%eax
  8011b5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c3:	83 c3 01             	add    $0x1,%ebx
  8011c6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011c9:	75 d8                	jne    8011a3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ce:	eb 05                	jmp    8011d5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	56                   	push   %esi
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	e8 ca f1 ff ff       	call   8003b8 <fd_alloc>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	0f 88 2c 01 00 00    	js     801327 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	68 07 04 00 00       	push   $0x407
  801203:	ff 75 f4             	pushl  -0xc(%ebp)
  801206:	6a 00                	push   $0x0
  801208:	e8 53 ef ff ff       	call   800160 <sys_page_alloc>
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	89 c2                	mov    %eax,%edx
  801212:	85 c0                	test   %eax,%eax
  801214:	0f 88 0d 01 00 00    	js     801327 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80121a:	83 ec 0c             	sub    $0xc,%esp
  80121d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	e8 92 f1 ff ff       	call   8003b8 <fd_alloc>
  801226:	89 c3                	mov    %eax,%ebx
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	0f 88 e2 00 00 00    	js     801315 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	68 07 04 00 00       	push   $0x407
  80123b:	ff 75 f0             	pushl  -0x10(%ebp)
  80123e:	6a 00                	push   $0x0
  801240:	e8 1b ef ff ff       	call   800160 <sys_page_alloc>
  801245:	89 c3                	mov    %eax,%ebx
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	0f 88 c3 00 00 00    	js     801315 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	ff 75 f4             	pushl  -0xc(%ebp)
  801258:	e8 44 f1 ff ff       	call   8003a1 <fd2data>
  80125d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125f:	83 c4 0c             	add    $0xc,%esp
  801262:	68 07 04 00 00       	push   $0x407
  801267:	50                   	push   %eax
  801268:	6a 00                	push   $0x0
  80126a:	e8 f1 ee ff ff       	call   800160 <sys_page_alloc>
  80126f:	89 c3                	mov    %eax,%ebx
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	0f 88 89 00 00 00    	js     801305 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127c:	83 ec 0c             	sub    $0xc,%esp
  80127f:	ff 75 f0             	pushl  -0x10(%ebp)
  801282:	e8 1a f1 ff ff       	call   8003a1 <fd2data>
  801287:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128e:	50                   	push   %eax
  80128f:	6a 00                	push   $0x0
  801291:	56                   	push   %esi
  801292:	6a 00                	push   $0x0
  801294:	e8 0a ef ff ff       	call   8001a3 <sys_page_map>
  801299:	89 c3                	mov    %eax,%ebx
  80129b:	83 c4 20             	add    $0x20,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 55                	js     8012f7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ab:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012cc:	83 ec 0c             	sub    $0xc,%esp
  8012cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d2:	e8 ba f0 ff ff       	call   800391 <fd2num>
  8012d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012da:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012dc:	83 c4 04             	add    $0x4,%esp
  8012df:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e2:	e8 aa f0 ff ff       	call   800391 <fd2num>
  8012e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ea:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f5:	eb 30                	jmp    801327 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	56                   	push   %esi
  8012fb:	6a 00                	push   $0x0
  8012fd:	e8 e3 ee ff ff       	call   8001e5 <sys_page_unmap>
  801302:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	ff 75 f0             	pushl  -0x10(%ebp)
  80130b:	6a 00                	push   $0x0
  80130d:	e8 d3 ee ff ff       	call   8001e5 <sys_page_unmap>
  801312:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	ff 75 f4             	pushl  -0xc(%ebp)
  80131b:	6a 00                	push   $0x0
  80131d:	e8 c3 ee ff ff       	call   8001e5 <sys_page_unmap>
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801327:	89 d0                	mov    %edx,%eax
  801329:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5e                   	pop    %esi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	ff 75 08             	pushl  0x8(%ebp)
  80133d:	e8 c5 f0 ff ff       	call   800407 <fd_lookup>
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	78 18                	js     801361 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	ff 75 f4             	pushl  -0xc(%ebp)
  80134f:	e8 4d f0 ff ff       	call   8003a1 <fd2data>
	return _pipeisclosed(fd, p);
  801354:	89 c2                	mov    %eax,%edx
  801356:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801359:	e8 21 fd ff ff       	call   80107f <_pipeisclosed>
  80135e:	83 c4 10             	add    $0x10,%esp
}
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801366:	b8 00 00 00 00       	mov    $0x0,%eax
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801373:	68 b3 23 80 00       	push   $0x8023b3
  801378:	ff 75 0c             	pushl  0xc(%ebp)
  80137b:	e8 c4 07 00 00       	call   801b44 <strcpy>
	return 0;
}
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	57                   	push   %edi
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801393:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801398:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139e:	eb 2d                	jmp    8013cd <devcons_write+0x46>
		m = n - tot;
  8013a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013a5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013a8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013ad:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b0:	83 ec 04             	sub    $0x4,%esp
  8013b3:	53                   	push   %ebx
  8013b4:	03 45 0c             	add    0xc(%ebp),%eax
  8013b7:	50                   	push   %eax
  8013b8:	57                   	push   %edi
  8013b9:	e8 18 09 00 00       	call   801cd6 <memmove>
		sys_cputs(buf, m);
  8013be:	83 c4 08             	add    $0x8,%esp
  8013c1:	53                   	push   %ebx
  8013c2:	57                   	push   %edi
  8013c3:	e8 dc ec ff ff       	call   8000a4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c8:	01 de                	add    %ebx,%esi
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	89 f0                	mov    %esi,%eax
  8013cf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d2:	72 cc                	jb     8013a0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d7:	5b                   	pop    %ebx
  8013d8:	5e                   	pop    %esi
  8013d9:	5f                   	pop    %edi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013eb:	74 2a                	je     801417 <devcons_read+0x3b>
  8013ed:	eb 05                	jmp    8013f4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013ef:	e8 4d ed ff ff       	call   800141 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f4:	e8 c9 ec ff ff       	call   8000c2 <sys_cgetc>
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	74 f2                	je     8013ef <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 16                	js     801417 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801401:	83 f8 04             	cmp    $0x4,%eax
  801404:	74 0c                	je     801412 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801406:	8b 55 0c             	mov    0xc(%ebp),%edx
  801409:	88 02                	mov    %al,(%edx)
	return 1;
  80140b:	b8 01 00 00 00       	mov    $0x1,%eax
  801410:	eb 05                	jmp    801417 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801412:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801417:	c9                   	leave  
  801418:	c3                   	ret    

00801419 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
  801422:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801425:	6a 01                	push   $0x1
  801427:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	e8 74 ec ff ff       	call   8000a4 <sys_cputs>
}
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <getchar>:

int
getchar(void)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80143b:	6a 01                	push   $0x1
  80143d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	6a 00                	push   $0x0
  801443:	e8 25 f2 ff ff       	call   80066d <read>
	if (r < 0)
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 0f                	js     80145e <getchar+0x29>
		return r;
	if (r < 1)
  80144f:	85 c0                	test   %eax,%eax
  801451:	7e 06                	jle    801459 <getchar+0x24>
		return -E_EOF;
	return c;
  801453:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801457:	eb 05                	jmp    80145e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801459:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	ff 75 08             	pushl  0x8(%ebp)
  80146d:	e8 95 ef ff ff       	call   800407 <fd_lookup>
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 11                	js     80148a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801479:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801482:	39 10                	cmp    %edx,(%eax)
  801484:	0f 94 c0             	sete   %al
  801487:	0f b6 c0             	movzbl %al,%eax
}
  80148a:	c9                   	leave  
  80148b:	c3                   	ret    

0080148c <opencons>:

int
opencons(void)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801492:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	e8 1d ef ff ff       	call   8003b8 <fd_alloc>
  80149b:	83 c4 10             	add    $0x10,%esp
		return r;
  80149e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 3e                	js     8014e2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	68 07 04 00 00       	push   $0x407
  8014ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8014af:	6a 00                	push   $0x0
  8014b1:	e8 aa ec ff ff       	call   800160 <sys_page_alloc>
  8014b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 23                	js     8014e2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014bf:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	50                   	push   %eax
  8014d8:	e8 b4 ee ff ff       	call   800391 <fd2num>
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	83 c4 10             	add    $0x10,%esp
}
  8014e2:	89 d0                	mov    %edx,%eax
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014eb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ee:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f4:	e8 29 ec ff ff       	call   800122 <sys_getenvid>
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	ff 75 0c             	pushl  0xc(%ebp)
  8014ff:	ff 75 08             	pushl  0x8(%ebp)
  801502:	56                   	push   %esi
  801503:	50                   	push   %eax
  801504:	68 c0 23 80 00       	push   $0x8023c0
  801509:	e8 b1 00 00 00       	call   8015bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80150e:	83 c4 18             	add    $0x18,%esp
  801511:	53                   	push   %ebx
  801512:	ff 75 10             	pushl  0x10(%ebp)
  801515:	e8 54 00 00 00       	call   80156e <vcprintf>
	cprintf("\n");
  80151a:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801521:	e8 99 00 00 00       	call   8015bf <cprintf>
  801526:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801529:	cc                   	int3   
  80152a:	eb fd                	jmp    801529 <_panic+0x43>

0080152c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	53                   	push   %ebx
  801530:	83 ec 04             	sub    $0x4,%esp
  801533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801536:	8b 13                	mov    (%ebx),%edx
  801538:	8d 42 01             	lea    0x1(%edx),%eax
  80153b:	89 03                	mov    %eax,(%ebx)
  80153d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801540:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801544:	3d ff 00 00 00       	cmp    $0xff,%eax
  801549:	75 1a                	jne    801565 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	68 ff 00 00 00       	push   $0xff
  801553:	8d 43 08             	lea    0x8(%ebx),%eax
  801556:	50                   	push   %eax
  801557:	e8 48 eb ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  80155c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801562:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801565:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801577:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80157e:	00 00 00 
	b.cnt = 0;
  801581:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801588:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80158b:	ff 75 0c             	pushl  0xc(%ebp)
  80158e:	ff 75 08             	pushl  0x8(%ebp)
  801591:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	68 2c 15 80 00       	push   $0x80152c
  80159d:	e8 54 01 00 00       	call   8016f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a2:	83 c4 08             	add    $0x8,%esp
  8015a5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	e8 ed ea ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  8015b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c8:	50                   	push   %eax
  8015c9:	ff 75 08             	pushl  0x8(%ebp)
  8015cc:	e8 9d ff ff ff       	call   80156e <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	57                   	push   %edi
  8015d7:	56                   	push   %esi
  8015d8:	53                   	push   %ebx
  8015d9:	83 ec 1c             	sub    $0x1c,%esp
  8015dc:	89 c7                	mov    %eax,%edi
  8015de:	89 d6                	mov    %edx,%esi
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015fa:	39 d3                	cmp    %edx,%ebx
  8015fc:	72 05                	jb     801603 <printnum+0x30>
  8015fe:	39 45 10             	cmp    %eax,0x10(%ebp)
  801601:	77 45                	ja     801648 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	ff 75 18             	pushl  0x18(%ebp)
  801609:	8b 45 14             	mov    0x14(%ebp),%eax
  80160c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80160f:	53                   	push   %ebx
  801610:	ff 75 10             	pushl  0x10(%ebp)
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	ff 75 e4             	pushl  -0x1c(%ebp)
  801619:	ff 75 e0             	pushl  -0x20(%ebp)
  80161c:	ff 75 dc             	pushl  -0x24(%ebp)
  80161f:	ff 75 d8             	pushl  -0x28(%ebp)
  801622:	e8 99 09 00 00       	call   801fc0 <__udivdi3>
  801627:	83 c4 18             	add    $0x18,%esp
  80162a:	52                   	push   %edx
  80162b:	50                   	push   %eax
  80162c:	89 f2                	mov    %esi,%edx
  80162e:	89 f8                	mov    %edi,%eax
  801630:	e8 9e ff ff ff       	call   8015d3 <printnum>
  801635:	83 c4 20             	add    $0x20,%esp
  801638:	eb 18                	jmp    801652 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	56                   	push   %esi
  80163e:	ff 75 18             	pushl  0x18(%ebp)
  801641:	ff d7                	call   *%edi
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	eb 03                	jmp    80164b <printnum+0x78>
  801648:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80164b:	83 eb 01             	sub    $0x1,%ebx
  80164e:	85 db                	test   %ebx,%ebx
  801650:	7f e8                	jg     80163a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	56                   	push   %esi
  801656:	83 ec 04             	sub    $0x4,%esp
  801659:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165c:	ff 75 e0             	pushl  -0x20(%ebp)
  80165f:	ff 75 dc             	pushl  -0x24(%ebp)
  801662:	ff 75 d8             	pushl  -0x28(%ebp)
  801665:	e8 86 0a 00 00       	call   8020f0 <__umoddi3>
  80166a:	83 c4 14             	add    $0x14,%esp
  80166d:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801674:	50                   	push   %eax
  801675:	ff d7                	call   *%edi
}
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5f                   	pop    %edi
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801685:	83 fa 01             	cmp    $0x1,%edx
  801688:	7e 0e                	jle    801698 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80168a:	8b 10                	mov    (%eax),%edx
  80168c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80168f:	89 08                	mov    %ecx,(%eax)
  801691:	8b 02                	mov    (%edx),%eax
  801693:	8b 52 04             	mov    0x4(%edx),%edx
  801696:	eb 22                	jmp    8016ba <getuint+0x38>
	else if (lflag)
  801698:	85 d2                	test   %edx,%edx
  80169a:	74 10                	je     8016ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80169c:	8b 10                	mov    (%eax),%edx
  80169e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a1:	89 08                	mov    %ecx,(%eax)
  8016a3:	8b 02                	mov    (%edx),%eax
  8016a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016aa:	eb 0e                	jmp    8016ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016ac:	8b 10                	mov    (%eax),%edx
  8016ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b1:	89 08                	mov    %ecx,(%eax)
  8016b3:	8b 02                	mov    (%edx),%eax
  8016b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016c6:	8b 10                	mov    (%eax),%edx
  8016c8:	3b 50 04             	cmp    0x4(%eax),%edx
  8016cb:	73 0a                	jae    8016d7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016cd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d0:	89 08                	mov    %ecx,(%eax)
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	88 02                	mov    %al,(%edx)
}
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016df:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e2:	50                   	push   %eax
  8016e3:	ff 75 10             	pushl  0x10(%ebp)
  8016e6:	ff 75 0c             	pushl  0xc(%ebp)
  8016e9:	ff 75 08             	pushl  0x8(%ebp)
  8016ec:	e8 05 00 00 00       	call   8016f6 <vprintfmt>
	va_end(ap);
}
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 2c             	sub    $0x2c,%esp
  8016ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801702:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801705:	8b 7d 10             	mov    0x10(%ebp),%edi
  801708:	eb 12                	jmp    80171c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80170a:	85 c0                	test   %eax,%eax
  80170c:	0f 84 89 03 00 00    	je     801a9b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	53                   	push   %ebx
  801716:	50                   	push   %eax
  801717:	ff d6                	call   *%esi
  801719:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80171c:	83 c7 01             	add    $0x1,%edi
  80171f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801723:	83 f8 25             	cmp    $0x25,%eax
  801726:	75 e2                	jne    80170a <vprintfmt+0x14>
  801728:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80172c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801733:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80173a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801741:	ba 00 00 00 00       	mov    $0x0,%edx
  801746:	eb 07                	jmp    80174f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801748:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80174b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174f:	8d 47 01             	lea    0x1(%edi),%eax
  801752:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801755:	0f b6 07             	movzbl (%edi),%eax
  801758:	0f b6 c8             	movzbl %al,%ecx
  80175b:	83 e8 23             	sub    $0x23,%eax
  80175e:	3c 55                	cmp    $0x55,%al
  801760:	0f 87 1a 03 00 00    	ja     801a80 <vprintfmt+0x38a>
  801766:	0f b6 c0             	movzbl %al,%eax
  801769:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801773:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801777:	eb d6                	jmp    80174f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
  801781:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801784:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801787:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80178b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80178e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801791:	83 fa 09             	cmp    $0x9,%edx
  801794:	77 39                	ja     8017cf <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801796:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801799:	eb e9                	jmp    801784 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80179b:	8b 45 14             	mov    0x14(%ebp),%eax
  80179e:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017a4:	8b 00                	mov    (%eax),%eax
  8017a6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017ac:	eb 27                	jmp    8017d5 <vprintfmt+0xdf>
  8017ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017b8:	0f 49 c8             	cmovns %eax,%ecx
  8017bb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c1:	eb 8c                	jmp    80174f <vprintfmt+0x59>
  8017c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017cd:	eb 80                	jmp    80174f <vprintfmt+0x59>
  8017cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017d9:	0f 89 70 ff ff ff    	jns    80174f <vprintfmt+0x59>
				width = precision, precision = -1;
  8017df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ec:	e9 5e ff ff ff       	jmp    80174f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017f7:	e9 53 ff ff ff       	jmp    80174f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ff:	8d 50 04             	lea    0x4(%eax),%edx
  801802:	89 55 14             	mov    %edx,0x14(%ebp)
  801805:	83 ec 08             	sub    $0x8,%esp
  801808:	53                   	push   %ebx
  801809:	ff 30                	pushl  (%eax)
  80180b:	ff d6                	call   *%esi
			break;
  80180d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801810:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801813:	e9 04 ff ff ff       	jmp    80171c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801818:	8b 45 14             	mov    0x14(%ebp),%eax
  80181b:	8d 50 04             	lea    0x4(%eax),%edx
  80181e:	89 55 14             	mov    %edx,0x14(%ebp)
  801821:	8b 00                	mov    (%eax),%eax
  801823:	99                   	cltd   
  801824:	31 d0                	xor    %edx,%eax
  801826:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801828:	83 f8 0f             	cmp    $0xf,%eax
  80182b:	7f 0b                	jg     801838 <vprintfmt+0x142>
  80182d:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801834:	85 d2                	test   %edx,%edx
  801836:	75 18                	jne    801850 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801838:	50                   	push   %eax
  801839:	68 fb 23 80 00       	push   $0x8023fb
  80183e:	53                   	push   %ebx
  80183f:	56                   	push   %esi
  801840:	e8 94 fe ff ff       	call   8016d9 <printfmt>
  801845:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801848:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80184b:	e9 cc fe ff ff       	jmp    80171c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801850:	52                   	push   %edx
  801851:	68 41 23 80 00       	push   $0x802341
  801856:	53                   	push   %ebx
  801857:	56                   	push   %esi
  801858:	e8 7c fe ff ff       	call   8016d9 <printfmt>
  80185d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801860:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801863:	e9 b4 fe ff ff       	jmp    80171c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801868:	8b 45 14             	mov    0x14(%ebp),%eax
  80186b:	8d 50 04             	lea    0x4(%eax),%edx
  80186e:	89 55 14             	mov    %edx,0x14(%ebp)
  801871:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801873:	85 ff                	test   %edi,%edi
  801875:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80187a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80187d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801881:	0f 8e 94 00 00 00    	jle    80191b <vprintfmt+0x225>
  801887:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80188b:	0f 84 98 00 00 00    	je     801929 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	ff 75 d0             	pushl  -0x30(%ebp)
  801897:	57                   	push   %edi
  801898:	e8 86 02 00 00       	call   801b23 <strnlen>
  80189d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a0:	29 c1                	sub    %eax,%ecx
  8018a2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018a5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018a8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018af:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b4:	eb 0f                	jmp    8018c5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018b6:	83 ec 08             	sub    $0x8,%esp
  8018b9:	53                   	push   %ebx
  8018ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8018bd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018bf:	83 ef 01             	sub    $0x1,%edi
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	85 ff                	test   %edi,%edi
  8018c7:	7f ed                	jg     8018b6 <vprintfmt+0x1c0>
  8018c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018cc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018cf:	85 c9                	test   %ecx,%ecx
  8018d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d6:	0f 49 c1             	cmovns %ecx,%eax
  8018d9:	29 c1                	sub    %eax,%ecx
  8018db:	89 75 08             	mov    %esi,0x8(%ebp)
  8018de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e4:	89 cb                	mov    %ecx,%ebx
  8018e6:	eb 4d                	jmp    801935 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ec:	74 1b                	je     801909 <vprintfmt+0x213>
  8018ee:	0f be c0             	movsbl %al,%eax
  8018f1:	83 e8 20             	sub    $0x20,%eax
  8018f4:	83 f8 5e             	cmp    $0x5e,%eax
  8018f7:	76 10                	jbe    801909 <vprintfmt+0x213>
					putch('?', putdat);
  8018f9:	83 ec 08             	sub    $0x8,%esp
  8018fc:	ff 75 0c             	pushl  0xc(%ebp)
  8018ff:	6a 3f                	push   $0x3f
  801901:	ff 55 08             	call   *0x8(%ebp)
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	eb 0d                	jmp    801916 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	ff 75 0c             	pushl  0xc(%ebp)
  80190f:	52                   	push   %edx
  801910:	ff 55 08             	call   *0x8(%ebp)
  801913:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801916:	83 eb 01             	sub    $0x1,%ebx
  801919:	eb 1a                	jmp    801935 <vprintfmt+0x23f>
  80191b:	89 75 08             	mov    %esi,0x8(%ebp)
  80191e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801921:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801924:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801927:	eb 0c                	jmp    801935 <vprintfmt+0x23f>
  801929:	89 75 08             	mov    %esi,0x8(%ebp)
  80192c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80192f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801932:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801935:	83 c7 01             	add    $0x1,%edi
  801938:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80193c:	0f be d0             	movsbl %al,%edx
  80193f:	85 d2                	test   %edx,%edx
  801941:	74 23                	je     801966 <vprintfmt+0x270>
  801943:	85 f6                	test   %esi,%esi
  801945:	78 a1                	js     8018e8 <vprintfmt+0x1f2>
  801947:	83 ee 01             	sub    $0x1,%esi
  80194a:	79 9c                	jns    8018e8 <vprintfmt+0x1f2>
  80194c:	89 df                	mov    %ebx,%edi
  80194e:	8b 75 08             	mov    0x8(%ebp),%esi
  801951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801954:	eb 18                	jmp    80196e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801956:	83 ec 08             	sub    $0x8,%esp
  801959:	53                   	push   %ebx
  80195a:	6a 20                	push   $0x20
  80195c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80195e:	83 ef 01             	sub    $0x1,%edi
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	eb 08                	jmp    80196e <vprintfmt+0x278>
  801966:	89 df                	mov    %ebx,%edi
  801968:	8b 75 08             	mov    0x8(%ebp),%esi
  80196b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80196e:	85 ff                	test   %edi,%edi
  801970:	7f e4                	jg     801956 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801972:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801975:	e9 a2 fd ff ff       	jmp    80171c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80197a:	83 fa 01             	cmp    $0x1,%edx
  80197d:	7e 16                	jle    801995 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80197f:	8b 45 14             	mov    0x14(%ebp),%eax
  801982:	8d 50 08             	lea    0x8(%eax),%edx
  801985:	89 55 14             	mov    %edx,0x14(%ebp)
  801988:	8b 50 04             	mov    0x4(%eax),%edx
  80198b:	8b 00                	mov    (%eax),%eax
  80198d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801990:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801993:	eb 32                	jmp    8019c7 <vprintfmt+0x2d1>
	else if (lflag)
  801995:	85 d2                	test   %edx,%edx
  801997:	74 18                	je     8019b1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801999:	8b 45 14             	mov    0x14(%ebp),%eax
  80199c:	8d 50 04             	lea    0x4(%eax),%edx
  80199f:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a2:	8b 00                	mov    (%eax),%eax
  8019a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a7:	89 c1                	mov    %eax,%ecx
  8019a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019af:	eb 16                	jmp    8019c7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b4:	8d 50 04             	lea    0x4(%eax),%edx
  8019b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ba:	8b 00                	mov    (%eax),%eax
  8019bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019bf:	89 c1                	mov    %eax,%ecx
  8019c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019d6:	79 74                	jns    801a4c <vprintfmt+0x356>
				putch('-', putdat);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	53                   	push   %ebx
  8019dc:	6a 2d                	push   $0x2d
  8019de:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019e6:	f7 d8                	neg    %eax
  8019e8:	83 d2 00             	adc    $0x0,%edx
  8019eb:	f7 da                	neg    %edx
  8019ed:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019f5:	eb 55                	jmp    801a4c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8019fa:	e8 83 fc ff ff       	call   801682 <getuint>
			base = 10;
  8019ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a04:	eb 46                	jmp    801a4c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a06:	8d 45 14             	lea    0x14(%ebp),%eax
  801a09:	e8 74 fc ff ff       	call   801682 <getuint>
		        base = 8;
  801a0e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a13:	eb 37                	jmp    801a4c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	53                   	push   %ebx
  801a19:	6a 30                	push   $0x30
  801a1b:	ff d6                	call   *%esi
			putch('x', putdat);
  801a1d:	83 c4 08             	add    $0x8,%esp
  801a20:	53                   	push   %ebx
  801a21:	6a 78                	push   $0x78
  801a23:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a25:	8b 45 14             	mov    0x14(%ebp),%eax
  801a28:	8d 50 04             	lea    0x4(%eax),%edx
  801a2b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a2e:	8b 00                	mov    (%eax),%eax
  801a30:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a35:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a38:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a3d:	eb 0d                	jmp    801a4c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a3f:	8d 45 14             	lea    0x14(%ebp),%eax
  801a42:	e8 3b fc ff ff       	call   801682 <getuint>
			base = 16;
  801a47:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a53:	57                   	push   %edi
  801a54:	ff 75 e0             	pushl  -0x20(%ebp)
  801a57:	51                   	push   %ecx
  801a58:	52                   	push   %edx
  801a59:	50                   	push   %eax
  801a5a:	89 da                	mov    %ebx,%edx
  801a5c:	89 f0                	mov    %esi,%eax
  801a5e:	e8 70 fb ff ff       	call   8015d3 <printnum>
			break;
  801a63:	83 c4 20             	add    $0x20,%esp
  801a66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a69:	e9 ae fc ff ff       	jmp    80171c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	53                   	push   %ebx
  801a72:	51                   	push   %ecx
  801a73:	ff d6                	call   *%esi
			break;
  801a75:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a7b:	e9 9c fc ff ff       	jmp    80171c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a80:	83 ec 08             	sub    $0x8,%esp
  801a83:	53                   	push   %ebx
  801a84:	6a 25                	push   $0x25
  801a86:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	eb 03                	jmp    801a90 <vprintfmt+0x39a>
  801a8d:	83 ef 01             	sub    $0x1,%edi
  801a90:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a94:	75 f7                	jne    801a8d <vprintfmt+0x397>
  801a96:	e9 81 fc ff ff       	jmp    80171c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5f                   	pop    %edi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	83 ec 18             	sub    $0x18,%esp
  801aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ab9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	74 26                	je     801aea <vsnprintf+0x47>
  801ac4:	85 d2                	test   %edx,%edx
  801ac6:	7e 22                	jle    801aea <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ac8:	ff 75 14             	pushl  0x14(%ebp)
  801acb:	ff 75 10             	pushl  0x10(%ebp)
  801ace:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad1:	50                   	push   %eax
  801ad2:	68 bc 16 80 00       	push   $0x8016bc
  801ad7:	e8 1a fc ff ff       	call   8016f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801adc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801adf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	eb 05                	jmp    801aef <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801afa:	50                   	push   %eax
  801afb:	ff 75 10             	pushl  0x10(%ebp)
  801afe:	ff 75 0c             	pushl  0xc(%ebp)
  801b01:	ff 75 08             	pushl  0x8(%ebp)
  801b04:	e8 9a ff ff ff       	call   801aa3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
  801b16:	eb 03                	jmp    801b1b <strlen+0x10>
		n++;
  801b18:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b1f:	75 f7                	jne    801b18 <strlen+0xd>
		n++;
	return n;
}
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b29:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b31:	eb 03                	jmp    801b36 <strnlen+0x13>
		n++;
  801b33:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b36:	39 c2                	cmp    %eax,%edx
  801b38:	74 08                	je     801b42 <strnlen+0x1f>
  801b3a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b3e:	75 f3                	jne    801b33 <strnlen+0x10>
  801b40:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	53                   	push   %ebx
  801b48:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	83 c2 01             	add    $0x1,%edx
  801b53:	83 c1 01             	add    $0x1,%ecx
  801b56:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b5a:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b5d:	84 db                	test   %bl,%bl
  801b5f:	75 ef                	jne    801b50 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b61:	5b                   	pop    %ebx
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    

00801b64 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	53                   	push   %ebx
  801b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b6b:	53                   	push   %ebx
  801b6c:	e8 9a ff ff ff       	call   801b0b <strlen>
  801b71:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b74:	ff 75 0c             	pushl  0xc(%ebp)
  801b77:	01 d8                	add    %ebx,%eax
  801b79:	50                   	push   %eax
  801b7a:	e8 c5 ff ff ff       	call   801b44 <strcpy>
	return dst;
}
  801b7f:	89 d8                	mov    %ebx,%eax
  801b81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	56                   	push   %esi
  801b8a:	53                   	push   %ebx
  801b8b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b91:	89 f3                	mov    %esi,%ebx
  801b93:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b96:	89 f2                	mov    %esi,%edx
  801b98:	eb 0f                	jmp    801ba9 <strncpy+0x23>
		*dst++ = *src;
  801b9a:	83 c2 01             	add    $0x1,%edx
  801b9d:	0f b6 01             	movzbl (%ecx),%eax
  801ba0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba3:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba9:	39 da                	cmp    %ebx,%edx
  801bab:	75 ed                	jne    801b9a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bad:	89 f0                	mov    %esi,%eax
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbe:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc3:	85 d2                	test   %edx,%edx
  801bc5:	74 21                	je     801be8 <strlcpy+0x35>
  801bc7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bcb:	89 f2                	mov    %esi,%edx
  801bcd:	eb 09                	jmp    801bd8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bcf:	83 c2 01             	add    $0x1,%edx
  801bd2:	83 c1 01             	add    $0x1,%ecx
  801bd5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bd8:	39 c2                	cmp    %eax,%edx
  801bda:	74 09                	je     801be5 <strlcpy+0x32>
  801bdc:	0f b6 19             	movzbl (%ecx),%ebx
  801bdf:	84 db                	test   %bl,%bl
  801be1:	75 ec                	jne    801bcf <strlcpy+0x1c>
  801be3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801be8:	29 f0                	sub    %esi,%eax
}
  801bea:	5b                   	pop    %ebx
  801beb:	5e                   	pop    %esi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf7:	eb 06                	jmp    801bff <strcmp+0x11>
		p++, q++;
  801bf9:	83 c1 01             	add    $0x1,%ecx
  801bfc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bff:	0f b6 01             	movzbl (%ecx),%eax
  801c02:	84 c0                	test   %al,%al
  801c04:	74 04                	je     801c0a <strcmp+0x1c>
  801c06:	3a 02                	cmp    (%edx),%al
  801c08:	74 ef                	je     801bf9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0a:	0f b6 c0             	movzbl %al,%eax
  801c0d:	0f b6 12             	movzbl (%edx),%edx
  801c10:	29 d0                	sub    %edx,%eax
}
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	53                   	push   %ebx
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1e:	89 c3                	mov    %eax,%ebx
  801c20:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c23:	eb 06                	jmp    801c2b <strncmp+0x17>
		n--, p++, q++;
  801c25:	83 c0 01             	add    $0x1,%eax
  801c28:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c2b:	39 d8                	cmp    %ebx,%eax
  801c2d:	74 15                	je     801c44 <strncmp+0x30>
  801c2f:	0f b6 08             	movzbl (%eax),%ecx
  801c32:	84 c9                	test   %cl,%cl
  801c34:	74 04                	je     801c3a <strncmp+0x26>
  801c36:	3a 0a                	cmp    (%edx),%cl
  801c38:	74 eb                	je     801c25 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3a:	0f b6 00             	movzbl (%eax),%eax
  801c3d:	0f b6 12             	movzbl (%edx),%edx
  801c40:	29 d0                	sub    %edx,%eax
  801c42:	eb 05                	jmp    801c49 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c49:	5b                   	pop    %ebx
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c56:	eb 07                	jmp    801c5f <strchr+0x13>
		if (*s == c)
  801c58:	38 ca                	cmp    %cl,%dl
  801c5a:	74 0f                	je     801c6b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c5c:	83 c0 01             	add    $0x1,%eax
  801c5f:	0f b6 10             	movzbl (%eax),%edx
  801c62:	84 d2                	test   %dl,%dl
  801c64:	75 f2                	jne    801c58 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	8b 45 08             	mov    0x8(%ebp),%eax
  801c73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c77:	eb 03                	jmp    801c7c <strfind+0xf>
  801c79:	83 c0 01             	add    $0x1,%eax
  801c7c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c7f:	38 ca                	cmp    %cl,%dl
  801c81:	74 04                	je     801c87 <strfind+0x1a>
  801c83:	84 d2                	test   %dl,%dl
  801c85:	75 f2                	jne    801c79 <strfind+0xc>
			break;
	return (char *) s;
}
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	57                   	push   %edi
  801c8d:	56                   	push   %esi
  801c8e:	53                   	push   %ebx
  801c8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c95:	85 c9                	test   %ecx,%ecx
  801c97:	74 36                	je     801ccf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c9f:	75 28                	jne    801cc9 <memset+0x40>
  801ca1:	f6 c1 03             	test   $0x3,%cl
  801ca4:	75 23                	jne    801cc9 <memset+0x40>
		c &= 0xFF;
  801ca6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801caa:	89 d3                	mov    %edx,%ebx
  801cac:	c1 e3 08             	shl    $0x8,%ebx
  801caf:	89 d6                	mov    %edx,%esi
  801cb1:	c1 e6 18             	shl    $0x18,%esi
  801cb4:	89 d0                	mov    %edx,%eax
  801cb6:	c1 e0 10             	shl    $0x10,%eax
  801cb9:	09 f0                	or     %esi,%eax
  801cbb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cbd:	89 d8                	mov    %ebx,%eax
  801cbf:	09 d0                	or     %edx,%eax
  801cc1:	c1 e9 02             	shr    $0x2,%ecx
  801cc4:	fc                   	cld    
  801cc5:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc7:	eb 06                	jmp    801ccf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccc:	fc                   	cld    
  801ccd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ccf:	89 f8                	mov    %edi,%eax
  801cd1:	5b                   	pop    %ebx
  801cd2:	5e                   	pop    %esi
  801cd3:	5f                   	pop    %edi
  801cd4:	5d                   	pop    %ebp
  801cd5:	c3                   	ret    

00801cd6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	57                   	push   %edi
  801cda:	56                   	push   %esi
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce4:	39 c6                	cmp    %eax,%esi
  801ce6:	73 35                	jae    801d1d <memmove+0x47>
  801ce8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ceb:	39 d0                	cmp    %edx,%eax
  801ced:	73 2e                	jae    801d1d <memmove+0x47>
		s += n;
		d += n;
  801cef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf2:	89 d6                	mov    %edx,%esi
  801cf4:	09 fe                	or     %edi,%esi
  801cf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cfc:	75 13                	jne    801d11 <memmove+0x3b>
  801cfe:	f6 c1 03             	test   $0x3,%cl
  801d01:	75 0e                	jne    801d11 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d03:	83 ef 04             	sub    $0x4,%edi
  801d06:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d09:	c1 e9 02             	shr    $0x2,%ecx
  801d0c:	fd                   	std    
  801d0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d0f:	eb 09                	jmp    801d1a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d11:	83 ef 01             	sub    $0x1,%edi
  801d14:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d17:	fd                   	std    
  801d18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d1a:	fc                   	cld    
  801d1b:	eb 1d                	jmp    801d3a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1d:	89 f2                	mov    %esi,%edx
  801d1f:	09 c2                	or     %eax,%edx
  801d21:	f6 c2 03             	test   $0x3,%dl
  801d24:	75 0f                	jne    801d35 <memmove+0x5f>
  801d26:	f6 c1 03             	test   $0x3,%cl
  801d29:	75 0a                	jne    801d35 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d2b:	c1 e9 02             	shr    $0x2,%ecx
  801d2e:	89 c7                	mov    %eax,%edi
  801d30:	fc                   	cld    
  801d31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d33:	eb 05                	jmp    801d3a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d35:	89 c7                	mov    %eax,%edi
  801d37:	fc                   	cld    
  801d38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d41:	ff 75 10             	pushl  0x10(%ebp)
  801d44:	ff 75 0c             	pushl  0xc(%ebp)
  801d47:	ff 75 08             	pushl  0x8(%ebp)
  801d4a:	e8 87 ff ff ff       	call   801cd6 <memmove>
}
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	56                   	push   %esi
  801d55:	53                   	push   %ebx
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5c:	89 c6                	mov    %eax,%esi
  801d5e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d61:	eb 1a                	jmp    801d7d <memcmp+0x2c>
		if (*s1 != *s2)
  801d63:	0f b6 08             	movzbl (%eax),%ecx
  801d66:	0f b6 1a             	movzbl (%edx),%ebx
  801d69:	38 d9                	cmp    %bl,%cl
  801d6b:	74 0a                	je     801d77 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d6d:	0f b6 c1             	movzbl %cl,%eax
  801d70:	0f b6 db             	movzbl %bl,%ebx
  801d73:	29 d8                	sub    %ebx,%eax
  801d75:	eb 0f                	jmp    801d86 <memcmp+0x35>
		s1++, s2++;
  801d77:	83 c0 01             	add    $0x1,%eax
  801d7a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7d:	39 f0                	cmp    %esi,%eax
  801d7f:	75 e2                	jne    801d63 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d86:	5b                   	pop    %ebx
  801d87:	5e                   	pop    %esi
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    

00801d8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	53                   	push   %ebx
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d91:	89 c1                	mov    %eax,%ecx
  801d93:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d96:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9a:	eb 0a                	jmp    801da6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9c:	0f b6 10             	movzbl (%eax),%edx
  801d9f:	39 da                	cmp    %ebx,%edx
  801da1:	74 07                	je     801daa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da3:	83 c0 01             	add    $0x1,%eax
  801da6:	39 c8                	cmp    %ecx,%eax
  801da8:	72 f2                	jb     801d9c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801daa:	5b                   	pop    %ebx
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	57                   	push   %edi
  801db1:	56                   	push   %esi
  801db2:	53                   	push   %ebx
  801db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db9:	eb 03                	jmp    801dbe <strtol+0x11>
		s++;
  801dbb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbe:	0f b6 01             	movzbl (%ecx),%eax
  801dc1:	3c 20                	cmp    $0x20,%al
  801dc3:	74 f6                	je     801dbb <strtol+0xe>
  801dc5:	3c 09                	cmp    $0x9,%al
  801dc7:	74 f2                	je     801dbb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dc9:	3c 2b                	cmp    $0x2b,%al
  801dcb:	75 0a                	jne    801dd7 <strtol+0x2a>
		s++;
  801dcd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd0:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd5:	eb 11                	jmp    801de8 <strtol+0x3b>
  801dd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ddc:	3c 2d                	cmp    $0x2d,%al
  801dde:	75 08                	jne    801de8 <strtol+0x3b>
		s++, neg = 1;
  801de0:	83 c1 01             	add    $0x1,%ecx
  801de3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dee:	75 15                	jne    801e05 <strtol+0x58>
  801df0:	80 39 30             	cmpb   $0x30,(%ecx)
  801df3:	75 10                	jne    801e05 <strtol+0x58>
  801df5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801df9:	75 7c                	jne    801e77 <strtol+0xca>
		s += 2, base = 16;
  801dfb:	83 c1 02             	add    $0x2,%ecx
  801dfe:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e03:	eb 16                	jmp    801e1b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e05:	85 db                	test   %ebx,%ebx
  801e07:	75 12                	jne    801e1b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e09:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e0e:	80 39 30             	cmpb   $0x30,(%ecx)
  801e11:	75 08                	jne    801e1b <strtol+0x6e>
		s++, base = 8;
  801e13:	83 c1 01             	add    $0x1,%ecx
  801e16:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e20:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e23:	0f b6 11             	movzbl (%ecx),%edx
  801e26:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e29:	89 f3                	mov    %esi,%ebx
  801e2b:	80 fb 09             	cmp    $0x9,%bl
  801e2e:	77 08                	ja     801e38 <strtol+0x8b>
			dig = *s - '0';
  801e30:	0f be d2             	movsbl %dl,%edx
  801e33:	83 ea 30             	sub    $0x30,%edx
  801e36:	eb 22                	jmp    801e5a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e38:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e3b:	89 f3                	mov    %esi,%ebx
  801e3d:	80 fb 19             	cmp    $0x19,%bl
  801e40:	77 08                	ja     801e4a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e42:	0f be d2             	movsbl %dl,%edx
  801e45:	83 ea 57             	sub    $0x57,%edx
  801e48:	eb 10                	jmp    801e5a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e4a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e4d:	89 f3                	mov    %esi,%ebx
  801e4f:	80 fb 19             	cmp    $0x19,%bl
  801e52:	77 16                	ja     801e6a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e54:	0f be d2             	movsbl %dl,%edx
  801e57:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e5a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e5d:	7d 0b                	jge    801e6a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e5f:	83 c1 01             	add    $0x1,%ecx
  801e62:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e66:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e68:	eb b9                	jmp    801e23 <strtol+0x76>

	if (endptr)
  801e6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e6e:	74 0d                	je     801e7d <strtol+0xd0>
		*endptr = (char *) s;
  801e70:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e73:	89 0e                	mov    %ecx,(%esi)
  801e75:	eb 06                	jmp    801e7d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e77:	85 db                	test   %ebx,%ebx
  801e79:	74 98                	je     801e13 <strtol+0x66>
  801e7b:	eb 9e                	jmp    801e1b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e7d:	89 c2                	mov    %eax,%edx
  801e7f:	f7 da                	neg    %edx
  801e81:	85 ff                	test   %edi,%edi
  801e83:	0f 45 c2             	cmovne %edx,%eax
}
  801e86:	5b                   	pop    %ebx
  801e87:	5e                   	pop    %esi
  801e88:	5f                   	pop    %edi
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    

00801e8b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	56                   	push   %esi
  801e8f:	53                   	push   %ebx
  801e90:	8b 75 08             	mov    0x8(%ebp),%esi
  801e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	74 0e                	je     801eab <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801e9d:	83 ec 0c             	sub    $0xc,%esp
  801ea0:	50                   	push   %eax
  801ea1:	e8 6a e4 ff ff       	call   800310 <sys_ipc_recv>
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	eb 10                	jmp    801ebb <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801eab:	83 ec 0c             	sub    $0xc,%esp
  801eae:	68 00 00 00 f0       	push   $0xf0000000
  801eb3:	e8 58 e4 ff ff       	call   800310 <sys_ipc_recv>
  801eb8:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	74 0e                	je     801ecd <ipc_recv+0x42>
    	*from_env_store = 0;
  801ebf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ec5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801ecb:	eb 24                	jmp    801ef1 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ecd:	85 f6                	test   %esi,%esi
  801ecf:	74 0a                	je     801edb <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ed1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed6:	8b 40 74             	mov    0x74(%eax),%eax
  801ed9:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801edb:	85 db                	test   %ebx,%ebx
  801edd:	74 0a                	je     801ee9 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801edf:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee4:	8b 40 78             	mov    0x78(%eax),%eax
  801ee7:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801ee9:	a1 08 40 80 00       	mov    0x804008,%eax
  801eee:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801ef1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	57                   	push   %edi
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	83 ec 0c             	sub    $0xc,%esp
  801f01:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f0a:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f11:	0f 44 d8             	cmove  %eax,%ebx
  801f14:	eb 1c                	jmp    801f32 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f16:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f19:	74 12                	je     801f2d <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f1b:	50                   	push   %eax
  801f1c:	68 e0 26 80 00       	push   $0x8026e0
  801f21:	6a 4b                	push   $0x4b
  801f23:	68 f8 26 80 00       	push   $0x8026f8
  801f28:	e8 b9 f5 ff ff       	call   8014e6 <_panic>
        }	
        sys_yield();
  801f2d:	e8 0f e2 ff ff       	call   800141 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f32:	ff 75 14             	pushl  0x14(%ebp)
  801f35:	53                   	push   %ebx
  801f36:	56                   	push   %esi
  801f37:	57                   	push   %edi
  801f38:	e8 b0 e3 ff ff       	call   8002ed <sys_ipc_try_send>
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	75 d2                	jne    801f16 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    

00801f4c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f57:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f5a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f60:	8b 52 50             	mov    0x50(%edx),%edx
  801f63:	39 ca                	cmp    %ecx,%edx
  801f65:	75 0d                	jne    801f74 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f67:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6f:	8b 40 48             	mov    0x48(%eax),%eax
  801f72:	eb 0f                	jmp    801f83 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f74:	83 c0 01             	add    $0x1,%eax
  801f77:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7c:	75 d9                	jne    801f57 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f83:	5d                   	pop    %ebp
  801f84:	c3                   	ret    

00801f85 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8b:	89 d0                	mov    %edx,%eax
  801f8d:	c1 e8 16             	shr    $0x16,%eax
  801f90:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9c:	f6 c1 01             	test   $0x1,%cl
  801f9f:	74 1d                	je     801fbe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa1:	c1 ea 0c             	shr    $0xc,%edx
  801fa4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fab:	f6 c2 01             	test   $0x1,%dl
  801fae:	74 0e                	je     801fbe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb0:	c1 ea 0c             	shr    $0xc,%edx
  801fb3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fba:	ef 
  801fbb:	0f b7 c0             	movzwl %ax,%eax
}
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
