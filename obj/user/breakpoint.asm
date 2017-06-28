
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800044:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80004b:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80004e:	e8 ce 00 00 00       	call   800121 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 db                	test   %ebx,%ebx
  800067:	7e 07                	jle    800070 <libmain+0x37>
		binaryname = argv[0];
  800069:	8b 06                	mov    (%esi),%eax
  80006b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	56                   	push   %esi
  800074:	53                   	push   %ebx
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 0a 00 00 00       	call   800089 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800085:	5b                   	pop    %ebx
  800086:	5e                   	pop    %esi
  800087:	5d                   	pop    %ebp
  800088:	c3                   	ret    

00800089 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008f:	e8 c7 04 00 00       	call   80055b <close_all>
	sys_env_destroy(0);
  800094:	83 ec 0c             	sub    $0xc,%esp
  800097:	6a 00                	push   $0x0
  800099:	e8 42 00 00 00       	call   8000e0 <sys_env_destroy>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	89 c3                	mov    %eax,%ebx
  8000b6:	89 c7                	mov    %eax,%edi
  8000b8:	89 c6                	mov    %eax,%esi
  8000ba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 d1                	mov    %edx,%ecx
  8000d3:	89 d3                	mov    %edx,%ebx
  8000d5:	89 d7                	mov    %edx,%edi
  8000d7:	89 d6                	mov    %edx,%esi
  8000d9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 cb                	mov    %ecx,%ebx
  8000f8:	89 cf                	mov    %ecx,%edi
  8000fa:	89 ce                	mov    %ecx,%esi
  8000fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fe:	85 c0                	test   %eax,%eax
  800100:	7e 17                	jle    800119 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	50                   	push   %eax
  800106:	6a 03                	push   $0x3
  800108:	68 6a 22 80 00       	push   $0x80226a
  80010d:	6a 23                	push   $0x23
  80010f:	68 87 22 80 00       	push   $0x802287
  800114:	e8 cc 13 00 00       	call   8014e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5e                   	pop    %esi
  80011e:	5f                   	pop    %edi
  80011f:	5d                   	pop    %ebp
  800120:	c3                   	ret    

00800121 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	57                   	push   %edi
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800127:	ba 00 00 00 00       	mov    $0x0,%edx
  80012c:	b8 02 00 00 00       	mov    $0x2,%eax
  800131:	89 d1                	mov    %edx,%ecx
  800133:	89 d3                	mov    %edx,%ebx
  800135:	89 d7                	mov    %edx,%edi
  800137:	89 d6                	mov    %edx,%esi
  800139:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_yield>:

void
sys_yield(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	be 00 00 00 00       	mov    $0x0,%esi
  80016d:	b8 04 00 00 00       	mov    $0x4,%eax
  800172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800175:	8b 55 08             	mov    0x8(%ebp),%edx
  800178:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017b:	89 f7                	mov    %esi,%edi
  80017d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017f:	85 c0                	test   %eax,%eax
  800181:	7e 17                	jle    80019a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	50                   	push   %eax
  800187:	6a 04                	push   $0x4
  800189:	68 6a 22 80 00       	push   $0x80226a
  80018e:	6a 23                	push   $0x23
  800190:	68 87 22 80 00       	push   $0x802287
  800195:	e8 4b 13 00 00       	call   8014e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019d:	5b                   	pop    %ebx
  80019e:	5e                   	pop    %esi
  80019f:	5f                   	pop    %edi
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    

008001a2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bc:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c1:	85 c0                	test   %eax,%eax
  8001c3:	7e 17                	jle    8001dc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c5:	83 ec 0c             	sub    $0xc,%esp
  8001c8:	50                   	push   %eax
  8001c9:	6a 05                	push   $0x5
  8001cb:	68 6a 22 80 00       	push   $0x80226a
  8001d0:	6a 23                	push   $0x23
  8001d2:	68 87 22 80 00       	push   $0x802287
  8001d7:	e8 09 13 00 00       	call   8014e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5f                   	pop    %edi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	89 df                	mov    %ebx,%edi
  8001ff:	89 de                	mov    %ebx,%esi
  800201:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800203:	85 c0                	test   %eax,%eax
  800205:	7e 17                	jle    80021e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	50                   	push   %eax
  80020b:	6a 06                	push   $0x6
  80020d:	68 6a 22 80 00       	push   $0x80226a
  800212:	6a 23                	push   $0x23
  800214:	68 87 22 80 00       	push   $0x802287
  800219:	e8 c7 12 00 00       	call   8014e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800221:	5b                   	pop    %ebx
  800222:	5e                   	pop    %esi
  800223:	5f                   	pop    %edi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	57                   	push   %edi
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800234:	b8 08 00 00 00       	mov    $0x8,%eax
  800239:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023c:	8b 55 08             	mov    0x8(%ebp),%edx
  80023f:	89 df                	mov    %ebx,%edi
  800241:	89 de                	mov    %ebx,%esi
  800243:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800245:	85 c0                	test   %eax,%eax
  800247:	7e 17                	jle    800260 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	50                   	push   %eax
  80024d:	6a 08                	push   $0x8
  80024f:	68 6a 22 80 00       	push   $0x80226a
  800254:	6a 23                	push   $0x23
  800256:	68 87 22 80 00       	push   $0x802287
  80025b:	e8 85 12 00 00       	call   8014e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800271:	bb 00 00 00 00       	mov    $0x0,%ebx
  800276:	b8 09 00 00 00       	mov    $0x9,%eax
  80027b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027e:	8b 55 08             	mov    0x8(%ebp),%edx
  800281:	89 df                	mov    %ebx,%edi
  800283:	89 de                	mov    %ebx,%esi
  800285:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800287:	85 c0                	test   %eax,%eax
  800289:	7e 17                	jle    8002a2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028b:	83 ec 0c             	sub    $0xc,%esp
  80028e:	50                   	push   %eax
  80028f:	6a 09                	push   $0x9
  800291:	68 6a 22 80 00       	push   $0x80226a
  800296:	6a 23                	push   $0x23
  800298:	68 87 22 80 00       	push   $0x802287
  80029d:	e8 43 12 00 00       	call   8014e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a5:	5b                   	pop    %ebx
  8002a6:	5e                   	pop    %esi
  8002a7:	5f                   	pop    %edi
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	89 df                	mov    %ebx,%edi
  8002c5:	89 de                	mov    %ebx,%esi
  8002c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c9:	85 c0                	test   %eax,%eax
  8002cb:	7e 17                	jle    8002e4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	50                   	push   %eax
  8002d1:	6a 0a                	push   $0xa
  8002d3:	68 6a 22 80 00       	push   $0x80226a
  8002d8:	6a 23                	push   $0x23
  8002da:	68 87 22 80 00       	push   $0x802287
  8002df:	e8 01 12 00 00       	call   8014e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	57                   	push   %edi
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f2:	be 00 00 00 00       	mov    $0x0,%esi
  8002f7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800305:	8b 7d 14             	mov    0x14(%ebp),%edi
  800308:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800318:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800322:	8b 55 08             	mov    0x8(%ebp),%edx
  800325:	89 cb                	mov    %ecx,%ebx
  800327:	89 cf                	mov    %ecx,%edi
  800329:	89 ce                	mov    %ecx,%esi
  80032b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032d:	85 c0                	test   %eax,%eax
  80032f:	7e 17                	jle    800348 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800331:	83 ec 0c             	sub    $0xc,%esp
  800334:	50                   	push   %eax
  800335:	6a 0d                	push   $0xd
  800337:	68 6a 22 80 00       	push   $0x80226a
  80033c:	6a 23                	push   $0x23
  80033e:	68 87 22 80 00       	push   $0x802287
  800343:	e8 9d 11 00 00       	call   8014e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800348:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034b:	5b                   	pop    %ebx
  80034c:	5e                   	pop    %esi
  80034d:	5f                   	pop    %edi
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800360:	89 d1                	mov    %edx,%ecx
  800362:	89 d3                	mov    %edx,%ebx
  800364:	89 d7                	mov    %edx,%edi
  800366:	89 d6                	mov    %edx,%esi
  800368:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	57                   	push   %edi
  800373:	56                   	push   %esi
  800374:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800375:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80037f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800382:	8b 55 08             	mov    0x8(%ebp),%edx
  800385:	89 df                	mov    %ebx,%edi
  800387:	89 de                	mov    %ebx,%esi
  800389:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5f                   	pop    %edi
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800393:	8b 45 08             	mov    0x8(%ebp),%eax
  800396:	05 00 00 00 30       	add    $0x30000000,%eax
  80039b:	c1 e8 0c             	shr    $0xc,%eax
}
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c2:	89 c2                	mov    %eax,%edx
  8003c4:	c1 ea 16             	shr    $0x16,%edx
  8003c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ce:	f6 c2 01             	test   $0x1,%dl
  8003d1:	74 11                	je     8003e4 <fd_alloc+0x2d>
  8003d3:	89 c2                	mov    %eax,%edx
  8003d5:	c1 ea 0c             	shr    $0xc,%edx
  8003d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003df:	f6 c2 01             	test   $0x1,%dl
  8003e2:	75 09                	jne    8003ed <fd_alloc+0x36>
			*fd_store = fd;
  8003e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003eb:	eb 17                	jmp    800404 <fd_alloc+0x4d>
  8003ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f7:	75 c9                	jne    8003c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040c:	83 f8 1f             	cmp    $0x1f,%eax
  80040f:	77 36                	ja     800447 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800411:	c1 e0 0c             	shl    $0xc,%eax
  800414:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800419:	89 c2                	mov    %eax,%edx
  80041b:	c1 ea 16             	shr    $0x16,%edx
  80041e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800425:	f6 c2 01             	test   $0x1,%dl
  800428:	74 24                	je     80044e <fd_lookup+0x48>
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	c1 ea 0c             	shr    $0xc,%edx
  80042f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800436:	f6 c2 01             	test   $0x1,%dl
  800439:	74 1a                	je     800455 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043e:	89 02                	mov    %eax,(%edx)
	return 0;
  800440:	b8 00 00 00 00       	mov    $0x0,%eax
  800445:	eb 13                	jmp    80045a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800447:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044c:	eb 0c                	jmp    80045a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800453:	eb 05                	jmp    80045a <fd_lookup+0x54>
  800455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    

0080045c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800465:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046a:	eb 13                	jmp    80047f <dev_lookup+0x23>
  80046c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80046f:	39 08                	cmp    %ecx,(%eax)
  800471:	75 0c                	jne    80047f <dev_lookup+0x23>
			*dev = devtab[i];
  800473:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800476:	89 01                	mov    %eax,(%ecx)
			return 0;
  800478:	b8 00 00 00 00       	mov    $0x0,%eax
  80047d:	eb 2e                	jmp    8004ad <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80047f:	8b 02                	mov    (%edx),%eax
  800481:	85 c0                	test   %eax,%eax
  800483:	75 e7                	jne    80046c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800485:	a1 08 40 80 00       	mov    0x804008,%eax
  80048a:	8b 40 48             	mov    0x48(%eax),%eax
  80048d:	83 ec 04             	sub    $0x4,%esp
  800490:	51                   	push   %ecx
  800491:	50                   	push   %eax
  800492:	68 98 22 80 00       	push   $0x802298
  800497:	e8 22 11 00 00       	call   8015be <cprintf>
	*dev = 0;
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ad:	c9                   	leave  
  8004ae:	c3                   	ret    

008004af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	56                   	push   %esi
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 10             	sub    $0x10,%esp
  8004b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c0:	50                   	push   %eax
  8004c1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c7:	c1 e8 0c             	shr    $0xc,%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 36 ff ff ff       	call   800406 <fd_lookup>
  8004d0:	83 c4 08             	add    $0x8,%esp
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	78 05                	js     8004dc <fd_close+0x2d>
	    || fd != fd2)
  8004d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004da:	74 0c                	je     8004e8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004dc:	84 db                	test   %bl,%bl
  8004de:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e3:	0f 44 c2             	cmove  %edx,%eax
  8004e6:	eb 41                	jmp    800529 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	ff 36                	pushl  (%esi)
  8004f1:	e8 66 ff ff ff       	call   80045c <dev_lookup>
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 1a                	js     800519 <fd_close+0x6a>
		if (dev->dev_close)
  8004ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800502:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800505:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050a:	85 c0                	test   %eax,%eax
  80050c:	74 0b                	je     800519 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80050e:	83 ec 0c             	sub    $0xc,%esp
  800511:	56                   	push   %esi
  800512:	ff d0                	call   *%eax
  800514:	89 c3                	mov    %eax,%ebx
  800516:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	56                   	push   %esi
  80051d:	6a 00                	push   $0x0
  80051f:	e8 c0 fc ff ff       	call   8001e4 <sys_page_unmap>
	return r;
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	89 d8                	mov    %ebx,%eax
}
  800529:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052c:	5b                   	pop    %ebx
  80052d:	5e                   	pop    %esi
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800539:	50                   	push   %eax
  80053a:	ff 75 08             	pushl  0x8(%ebp)
  80053d:	e8 c4 fe ff ff       	call   800406 <fd_lookup>
  800542:	83 c4 08             	add    $0x8,%esp
  800545:	85 c0                	test   %eax,%eax
  800547:	78 10                	js     800559 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	6a 01                	push   $0x1
  80054e:	ff 75 f4             	pushl  -0xc(%ebp)
  800551:	e8 59 ff ff ff       	call   8004af <fd_close>
  800556:	83 c4 10             	add    $0x10,%esp
}
  800559:	c9                   	leave  
  80055a:	c3                   	ret    

0080055b <close_all>:

void
close_all(void)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	53                   	push   %ebx
  80055f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800562:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	53                   	push   %ebx
  80056b:	e8 c0 ff ff ff       	call   800530 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800570:	83 c3 01             	add    $0x1,%ebx
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	83 fb 20             	cmp    $0x20,%ebx
  800579:	75 ec                	jne    800567 <close_all+0xc>
		close(i);
}
  80057b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057e:	c9                   	leave  
  80057f:	c3                   	ret    

00800580 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 2c             	sub    $0x2c,%esp
  800589:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058f:	50                   	push   %eax
  800590:	ff 75 08             	pushl  0x8(%ebp)
  800593:	e8 6e fe ff ff       	call   800406 <fd_lookup>
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	85 c0                	test   %eax,%eax
  80059d:	0f 88 c1 00 00 00    	js     800664 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a3:	83 ec 0c             	sub    $0xc,%esp
  8005a6:	56                   	push   %esi
  8005a7:	e8 84 ff ff ff       	call   800530 <close>

	newfd = INDEX2FD(newfdnum);
  8005ac:	89 f3                	mov    %esi,%ebx
  8005ae:	c1 e3 0c             	shl    $0xc,%ebx
  8005b1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b7:	83 c4 04             	add    $0x4,%esp
  8005ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005bd:	e8 de fd ff ff       	call   8003a0 <fd2data>
  8005c2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c4:	89 1c 24             	mov    %ebx,(%esp)
  8005c7:	e8 d4 fd ff ff       	call   8003a0 <fd2data>
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d2:	89 f8                	mov    %edi,%eax
  8005d4:	c1 e8 16             	shr    $0x16,%eax
  8005d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005de:	a8 01                	test   $0x1,%al
  8005e0:	74 37                	je     800619 <dup+0x99>
  8005e2:	89 f8                	mov    %edi,%eax
  8005e4:	c1 e8 0c             	shr    $0xc,%eax
  8005e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ee:	f6 c2 01             	test   $0x1,%dl
  8005f1:	74 26                	je     800619 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	25 07 0e 00 00       	and    $0xe07,%eax
  800602:	50                   	push   %eax
  800603:	ff 75 d4             	pushl  -0x2c(%ebp)
  800606:	6a 00                	push   $0x0
  800608:	57                   	push   %edi
  800609:	6a 00                	push   $0x0
  80060b:	e8 92 fb ff ff       	call   8001a2 <sys_page_map>
  800610:	89 c7                	mov    %eax,%edi
  800612:	83 c4 20             	add    $0x20,%esp
  800615:	85 c0                	test   %eax,%eax
  800617:	78 2e                	js     800647 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800619:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061c:	89 d0                	mov    %edx,%eax
  80061e:	c1 e8 0c             	shr    $0xc,%eax
  800621:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800628:	83 ec 0c             	sub    $0xc,%esp
  80062b:	25 07 0e 00 00       	and    $0xe07,%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	6a 00                	push   $0x0
  800634:	52                   	push   %edx
  800635:	6a 00                	push   $0x0
  800637:	e8 66 fb ff ff       	call   8001a2 <sys_page_map>
  80063c:	89 c7                	mov    %eax,%edi
  80063e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800641:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800643:	85 ff                	test   %edi,%edi
  800645:	79 1d                	jns    800664 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 00                	push   $0x0
  80064d:	e8 92 fb ff ff       	call   8001e4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	ff 75 d4             	pushl  -0x2c(%ebp)
  800658:	6a 00                	push   $0x0
  80065a:	e8 85 fb ff ff       	call   8001e4 <sys_page_unmap>
	return r;
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	89 f8                	mov    %edi,%eax
}
  800664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800667:	5b                   	pop    %ebx
  800668:	5e                   	pop    %esi
  800669:	5f                   	pop    %edi
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	53                   	push   %ebx
  800670:	83 ec 14             	sub    $0x14,%esp
  800673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800679:	50                   	push   %eax
  80067a:	53                   	push   %ebx
  80067b:	e8 86 fd ff ff       	call   800406 <fd_lookup>
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	89 c2                	mov    %eax,%edx
  800685:	85 c0                	test   %eax,%eax
  800687:	78 6d                	js     8006f6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80068f:	50                   	push   %eax
  800690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800693:	ff 30                	pushl  (%eax)
  800695:	e8 c2 fd ff ff       	call   80045c <dev_lookup>
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	85 c0                	test   %eax,%eax
  80069f:	78 4c                	js     8006ed <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a4:	8b 42 08             	mov    0x8(%edx),%eax
  8006a7:	83 e0 03             	and    $0x3,%eax
  8006aa:	83 f8 01             	cmp    $0x1,%eax
  8006ad:	75 21                	jne    8006d0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006af:	a1 08 40 80 00       	mov    0x804008,%eax
  8006b4:	8b 40 48             	mov    0x48(%eax),%eax
  8006b7:	83 ec 04             	sub    $0x4,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	50                   	push   %eax
  8006bc:	68 d9 22 80 00       	push   $0x8022d9
  8006c1:	e8 f8 0e 00 00       	call   8015be <cprintf>
		return -E_INVAL;
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006ce:	eb 26                	jmp    8006f6 <read+0x8a>
	}
	if (!dev->dev_read)
  8006d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d3:	8b 40 08             	mov    0x8(%eax),%eax
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	74 17                	je     8006f1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	ff 75 10             	pushl  0x10(%ebp)
  8006e0:	ff 75 0c             	pushl  0xc(%ebp)
  8006e3:	52                   	push   %edx
  8006e4:	ff d0                	call   *%eax
  8006e6:	89 c2                	mov    %eax,%edx
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb 09                	jmp    8006f6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ed:	89 c2                	mov    %eax,%edx
  8006ef:	eb 05                	jmp    8006f6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f6:	89 d0                	mov    %edx,%eax
  8006f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	57                   	push   %edi
  800701:	56                   	push   %esi
  800702:	53                   	push   %ebx
  800703:	83 ec 0c             	sub    $0xc,%esp
  800706:	8b 7d 08             	mov    0x8(%ebp),%edi
  800709:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800711:	eb 21                	jmp    800734 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800713:	83 ec 04             	sub    $0x4,%esp
  800716:	89 f0                	mov    %esi,%eax
  800718:	29 d8                	sub    %ebx,%eax
  80071a:	50                   	push   %eax
  80071b:	89 d8                	mov    %ebx,%eax
  80071d:	03 45 0c             	add    0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	57                   	push   %edi
  800722:	e8 45 ff ff ff       	call   80066c <read>
		if (m < 0)
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 10                	js     80073e <readn+0x41>
			return m;
		if (m == 0)
  80072e:	85 c0                	test   %eax,%eax
  800730:	74 0a                	je     80073c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800732:	01 c3                	add    %eax,%ebx
  800734:	39 f3                	cmp    %esi,%ebx
  800736:	72 db                	jb     800713 <readn+0x16>
  800738:	89 d8                	mov    %ebx,%eax
  80073a:	eb 02                	jmp    80073e <readn+0x41>
  80073c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5f                   	pop    %edi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	53                   	push   %ebx
  80074a:	83 ec 14             	sub    $0x14,%esp
  80074d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	53                   	push   %ebx
  800755:	e8 ac fc ff ff       	call   800406 <fd_lookup>
  80075a:	83 c4 08             	add    $0x8,%esp
  80075d:	89 c2                	mov    %eax,%edx
  80075f:	85 c0                	test   %eax,%eax
  800761:	78 68                	js     8007cb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076d:	ff 30                	pushl  (%eax)
  80076f:	e8 e8 fc ff ff       	call   80045c <dev_lookup>
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	85 c0                	test   %eax,%eax
  800779:	78 47                	js     8007c2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800782:	75 21                	jne    8007a5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800784:	a1 08 40 80 00       	mov    0x804008,%eax
  800789:	8b 40 48             	mov    0x48(%eax),%eax
  80078c:	83 ec 04             	sub    $0x4,%esp
  80078f:	53                   	push   %ebx
  800790:	50                   	push   %eax
  800791:	68 f5 22 80 00       	push   $0x8022f5
  800796:	e8 23 0e 00 00       	call   8015be <cprintf>
		return -E_INVAL;
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a3:	eb 26                	jmp    8007cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	74 17                	je     8007c6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007af:	83 ec 04             	sub    $0x4,%esp
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	50                   	push   %eax
  8007b9:	ff d2                	call   *%edx
  8007bb:	89 c2                	mov    %eax,%edx
  8007bd:	83 c4 10             	add    $0x10,%esp
  8007c0:	eb 09                	jmp    8007cb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	eb 05                	jmp    8007cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007cb:	89 d0                	mov    %edx,%eax
  8007cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007db:	50                   	push   %eax
  8007dc:	ff 75 08             	pushl  0x8(%ebp)
  8007df:	e8 22 fc ff ff       	call   800406 <fd_lookup>
  8007e4:	83 c4 08             	add    $0x8,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 0e                	js     8007f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 14             	sub    $0x14,%esp
  800802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800805:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	53                   	push   %ebx
  80080a:	e8 f7 fb ff ff       	call   800406 <fd_lookup>
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	89 c2                	mov    %eax,%edx
  800814:	85 c0                	test   %eax,%eax
  800816:	78 65                	js     80087d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081e:	50                   	push   %eax
  80081f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800822:	ff 30                	pushl  (%eax)
  800824:	e8 33 fc ff ff       	call   80045c <dev_lookup>
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	85 c0                	test   %eax,%eax
  80082e:	78 44                	js     800874 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800830:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800833:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800837:	75 21                	jne    80085a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800839:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083e:	8b 40 48             	mov    0x48(%eax),%eax
  800841:	83 ec 04             	sub    $0x4,%esp
  800844:	53                   	push   %ebx
  800845:	50                   	push   %eax
  800846:	68 b8 22 80 00       	push   $0x8022b8
  80084b:	e8 6e 0d 00 00       	call   8015be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800850:	83 c4 10             	add    $0x10,%esp
  800853:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800858:	eb 23                	jmp    80087d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085d:	8b 52 18             	mov    0x18(%edx),%edx
  800860:	85 d2                	test   %edx,%edx
  800862:	74 14                	je     800878 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	50                   	push   %eax
  80086b:	ff d2                	call   *%edx
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	eb 09                	jmp    80087d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800874:	89 c2                	mov    %eax,%edx
  800876:	eb 05                	jmp    80087d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800878:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087d:	89 d0                	mov    %edx,%eax
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	53                   	push   %ebx
  800888:	83 ec 14             	sub    $0x14,%esp
  80088b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800891:	50                   	push   %eax
  800892:	ff 75 08             	pushl  0x8(%ebp)
  800895:	e8 6c fb ff ff       	call   800406 <fd_lookup>
  80089a:	83 c4 08             	add    $0x8,%esp
  80089d:	89 c2                	mov    %eax,%edx
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	78 58                	js     8008fb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a9:	50                   	push   %eax
  8008aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ad:	ff 30                	pushl  (%eax)
  8008af:	e8 a8 fb ff ff       	call   80045c <dev_lookup>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	78 37                	js     8008f2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c2:	74 32                	je     8008f6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ce:	00 00 00 
	stat->st_isdir = 0;
  8008d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d8:	00 00 00 
	stat->st_dev = dev;
  8008db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e8:	ff 50 14             	call   *0x14(%eax)
  8008eb:	89 c2                	mov    %eax,%edx
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	eb 09                	jmp    8008fb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f2:	89 c2                	mov    %eax,%edx
  8008f4:	eb 05                	jmp    8008fb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	6a 00                	push   $0x0
  80090c:	ff 75 08             	pushl  0x8(%ebp)
  80090f:	e8 e7 01 00 00       	call   800afb <open>
  800914:	89 c3                	mov    %eax,%ebx
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	85 c0                	test   %eax,%eax
  80091b:	78 1b                	js     800938 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	ff 75 0c             	pushl  0xc(%ebp)
  800923:	50                   	push   %eax
  800924:	e8 5b ff ff ff       	call   800884 <fstat>
  800929:	89 c6                	mov    %eax,%esi
	close(fd);
  80092b:	89 1c 24             	mov    %ebx,(%esp)
  80092e:	e8 fd fb ff ff       	call   800530 <close>
	return r;
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	89 f0                	mov    %esi,%eax
}
  800938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	89 c6                	mov    %eax,%esi
  800946:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800948:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80094f:	75 12                	jne    800963 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800951:	83 ec 0c             	sub    $0xc,%esp
  800954:	6a 01                	push   $0x1
  800956:	e8 f0 15 00 00       	call   801f4b <ipc_find_env>
  80095b:	a3 00 40 80 00       	mov    %eax,0x804000
  800960:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800963:	6a 07                	push   $0x7
  800965:	68 00 50 80 00       	push   $0x805000
  80096a:	56                   	push   %esi
  80096b:	ff 35 00 40 80 00    	pushl  0x804000
  800971:	e8 81 15 00 00       	call   801ef7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800976:	83 c4 0c             	add    $0xc,%esp
  800979:	6a 00                	push   $0x0
  80097b:	53                   	push   %ebx
  80097c:	6a 00                	push   $0x0
  80097e:	e8 07 15 00 00       	call   801e8a <ipc_recv>
}
  800983:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 40 0c             	mov    0xc(%eax),%eax
  800996:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ad:	e8 8d ff ff ff       	call   80093f <fsipc>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8009cf:	e8 6b ff ff ff       	call   80093f <fsipc>
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	53                   	push   %ebx
  8009da:	83 ec 04             	sub    $0x4,%esp
  8009dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f5:	e8 45 ff ff ff       	call   80093f <fsipc>
  8009fa:	85 c0                	test   %eax,%eax
  8009fc:	78 2c                	js     800a2a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	68 00 50 80 00       	push   $0x805000
  800a06:	53                   	push   %ebx
  800a07:	e8 37 11 00 00       	call   801b43 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0c:	a1 80 50 80 00       	mov    0x805080,%eax
  800a11:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a17:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a22:	83 c4 10             	add    $0x10,%esp
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a39:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a3e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a43:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a46:	53                   	push   %ebx
  800a47:	ff 75 0c             	pushl  0xc(%ebp)
  800a4a:	68 08 50 80 00       	push   $0x805008
  800a4f:	e8 81 12 00 00       	call   801cd5 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5a:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a5f:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a6f:	e8 cb fe ff ff       	call   80093f <fsipc>
	//panic("devfile_write not implemented");
}
  800a74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 40 0c             	mov    0xc(%eax),%eax
  800a87:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a92:	ba 00 00 00 00       	mov    $0x0,%edx
  800a97:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9c:	e8 9e fe ff ff       	call   80093f <fsipc>
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	78 4b                	js     800af2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa7:	39 c6                	cmp    %eax,%esi
  800aa9:	73 16                	jae    800ac1 <devfile_read+0x48>
  800aab:	68 28 23 80 00       	push   $0x802328
  800ab0:	68 2f 23 80 00       	push   $0x80232f
  800ab5:	6a 7c                	push   $0x7c
  800ab7:	68 44 23 80 00       	push   $0x802344
  800abc:	e8 24 0a 00 00       	call   8014e5 <_panic>
	assert(r <= PGSIZE);
  800ac1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac6:	7e 16                	jle    800ade <devfile_read+0x65>
  800ac8:	68 4f 23 80 00       	push   $0x80234f
  800acd:	68 2f 23 80 00       	push   $0x80232f
  800ad2:	6a 7d                	push   $0x7d
  800ad4:	68 44 23 80 00       	push   $0x802344
  800ad9:	e8 07 0a 00 00       	call   8014e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ade:	83 ec 04             	sub    $0x4,%esp
  800ae1:	50                   	push   %eax
  800ae2:	68 00 50 80 00       	push   $0x805000
  800ae7:	ff 75 0c             	pushl  0xc(%ebp)
  800aea:	e8 e6 11 00 00       	call   801cd5 <memmove>
	return r;
  800aef:	83 c4 10             	add    $0x10,%esp
}
  800af2:	89 d8                	mov    %ebx,%eax
  800af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	83 ec 20             	sub    $0x20,%esp
  800b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b05:	53                   	push   %ebx
  800b06:	e8 ff 0f 00 00       	call   801b0a <strlen>
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b13:	7f 67                	jg     800b7c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b15:	83 ec 0c             	sub    $0xc,%esp
  800b18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1b:	50                   	push   %eax
  800b1c:	e8 96 f8 ff ff       	call   8003b7 <fd_alloc>
  800b21:	83 c4 10             	add    $0x10,%esp
		return r;
  800b24:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b26:	85 c0                	test   %eax,%eax
  800b28:	78 57                	js     800b81 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2a:	83 ec 08             	sub    $0x8,%esp
  800b2d:	53                   	push   %ebx
  800b2e:	68 00 50 80 00       	push   $0x805000
  800b33:	e8 0b 10 00 00       	call   801b43 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b43:	b8 01 00 00 00       	mov    $0x1,%eax
  800b48:	e8 f2 fd ff ff       	call   80093f <fsipc>
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	85 c0                	test   %eax,%eax
  800b54:	79 14                	jns    800b6a <open+0x6f>
		fd_close(fd, 0);
  800b56:	83 ec 08             	sub    $0x8,%esp
  800b59:	6a 00                	push   $0x0
  800b5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5e:	e8 4c f9 ff ff       	call   8004af <fd_close>
		return r;
  800b63:	83 c4 10             	add    $0x10,%esp
  800b66:	89 da                	mov    %ebx,%edx
  800b68:	eb 17                	jmp    800b81 <open+0x86>
	}

	return fd2num(fd);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b70:	e8 1b f8 ff ff       	call   800390 <fd2num>
  800b75:	89 c2                	mov    %eax,%edx
  800b77:	83 c4 10             	add    $0x10,%esp
  800b7a:	eb 05                	jmp    800b81 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b81:	89 d0                	mov    %edx,%eax
  800b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 08 00 00 00       	mov    $0x8,%eax
  800b98:	e8 a2 fd ff ff       	call   80093f <fsipc>
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba5:	68 5b 23 80 00       	push   $0x80235b
  800baa:	ff 75 0c             	pushl  0xc(%ebp)
  800bad:	e8 91 0f 00 00       	call   801b43 <strcpy>
	return 0;
}
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 10             	sub    $0x10,%esp
  800bc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc3:	53                   	push   %ebx
  800bc4:	e8 bb 13 00 00       	call   801f84 <pageref>
  800bc9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bcc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd1:	83 f8 01             	cmp    $0x1,%eax
  800bd4:	75 10                	jne    800be6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd6:	83 ec 0c             	sub    $0xc,%esp
  800bd9:	ff 73 0c             	pushl  0xc(%ebx)
  800bdc:	e8 c0 02 00 00       	call   800ea1 <nsipc_close>
  800be1:	89 c2                	mov    %eax,%edx
  800be3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be6:	89 d0                	mov    %edx,%eax
  800be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf3:	6a 00                	push   $0x0
  800bf5:	ff 75 10             	pushl  0x10(%ebp)
  800bf8:	ff 75 0c             	pushl  0xc(%ebp)
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfe:	ff 70 0c             	pushl  0xc(%eax)
  800c01:	e8 78 03 00 00       	call   800f7e <nsipc_send>
}
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c0e:	6a 00                	push   $0x0
  800c10:	ff 75 10             	pushl  0x10(%ebp)
  800c13:	ff 75 0c             	pushl  0xc(%ebp)
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	ff 70 0c             	pushl  0xc(%eax)
  800c1c:	e8 f1 02 00 00       	call   800f12 <nsipc_recv>
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c29:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2c:	52                   	push   %edx
  800c2d:	50                   	push   %eax
  800c2e:	e8 d3 f7 ff ff       	call   800406 <fd_lookup>
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	85 c0                	test   %eax,%eax
  800c38:	78 17                	js     800c51 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c43:	39 08                	cmp    %ecx,(%eax)
  800c45:	75 05                	jne    800c4c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c47:	8b 40 0c             	mov    0xc(%eax),%eax
  800c4a:	eb 05                	jmp    800c51 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c4c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c51:	c9                   	leave  
  800c52:	c3                   	ret    

00800c53 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 1c             	sub    $0x1c,%esp
  800c5b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c60:	50                   	push   %eax
  800c61:	e8 51 f7 ff ff       	call   8003b7 <fd_alloc>
  800c66:	89 c3                	mov    %eax,%ebx
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	78 1b                	js     800c8a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c6f:	83 ec 04             	sub    $0x4,%esp
  800c72:	68 07 04 00 00       	push   $0x407
  800c77:	ff 75 f4             	pushl  -0xc(%ebp)
  800c7a:	6a 00                	push   $0x0
  800c7c:	e8 de f4 ff ff       	call   80015f <sys_page_alloc>
  800c81:	89 c3                	mov    %eax,%ebx
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	85 c0                	test   %eax,%eax
  800c88:	79 10                	jns    800c9a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	56                   	push   %esi
  800c8e:	e8 0e 02 00 00       	call   800ea1 <nsipc_close>
		return r;
  800c93:	83 c4 10             	add    $0x10,%esp
  800c96:	89 d8                	mov    %ebx,%eax
  800c98:	eb 24                	jmp    800cbe <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c9a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800caf:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	e8 d5 f6 ff ff       	call   800390 <fd2num>
  800cbb:	83 c4 10             	add    $0x10,%esp
}
  800cbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	e8 50 ff ff ff       	call   800c23 <fd2sockid>
		return r;
  800cd3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	78 1f                	js     800cf8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cd9:	83 ec 04             	sub    $0x4,%esp
  800cdc:	ff 75 10             	pushl  0x10(%ebp)
  800cdf:	ff 75 0c             	pushl  0xc(%ebp)
  800ce2:	50                   	push   %eax
  800ce3:	e8 12 01 00 00       	call   800dfa <nsipc_accept>
  800ce8:	83 c4 10             	add    $0x10,%esp
		return r;
  800ceb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	78 07                	js     800cf8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf1:	e8 5d ff ff ff       	call   800c53 <alloc_sockfd>
  800cf6:	89 c1                	mov    %eax,%ecx
}
  800cf8:	89 c8                	mov    %ecx,%eax
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	e8 19 ff ff ff       	call   800c23 <fd2sockid>
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	78 12                	js     800d20 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d0e:	83 ec 04             	sub    $0x4,%esp
  800d11:	ff 75 10             	pushl  0x10(%ebp)
  800d14:	ff 75 0c             	pushl  0xc(%ebp)
  800d17:	50                   	push   %eax
  800d18:	e8 2d 01 00 00       	call   800e4a <nsipc_bind>
  800d1d:	83 c4 10             	add    $0x10,%esp
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <shutdown>:

int
shutdown(int s, int how)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	e8 f3 fe ff ff       	call   800c23 <fd2sockid>
  800d30:	85 c0                	test   %eax,%eax
  800d32:	78 0f                	js     800d43 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d34:	83 ec 08             	sub    $0x8,%esp
  800d37:	ff 75 0c             	pushl  0xc(%ebp)
  800d3a:	50                   	push   %eax
  800d3b:	e8 3f 01 00 00       	call   800e7f <nsipc_shutdown>
  800d40:	83 c4 10             	add    $0x10,%esp
}
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	e8 d0 fe ff ff       	call   800c23 <fd2sockid>
  800d53:	85 c0                	test   %eax,%eax
  800d55:	78 12                	js     800d69 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d57:	83 ec 04             	sub    $0x4,%esp
  800d5a:	ff 75 10             	pushl  0x10(%ebp)
  800d5d:	ff 75 0c             	pushl  0xc(%ebp)
  800d60:	50                   	push   %eax
  800d61:	e8 55 01 00 00       	call   800ebb <nsipc_connect>
  800d66:	83 c4 10             	add    $0x10,%esp
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <listen>:

int
listen(int s, int backlog)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	e8 aa fe ff ff       	call   800c23 <fd2sockid>
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	78 0f                	js     800d8c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d7d:	83 ec 08             	sub    $0x8,%esp
  800d80:	ff 75 0c             	pushl  0xc(%ebp)
  800d83:	50                   	push   %eax
  800d84:	e8 67 01 00 00       	call   800ef0 <nsipc_listen>
  800d89:	83 c4 10             	add    $0x10,%esp
}
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    

00800d8e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d94:	ff 75 10             	pushl  0x10(%ebp)
  800d97:	ff 75 0c             	pushl  0xc(%ebp)
  800d9a:	ff 75 08             	pushl  0x8(%ebp)
  800d9d:	e8 3a 02 00 00       	call   800fdc <nsipc_socket>
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	78 05                	js     800dae <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da9:	e8 a5 fe ff ff       	call   800c53 <alloc_sockfd>
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	53                   	push   %ebx
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc0:	75 12                	jne    800dd4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	6a 02                	push   $0x2
  800dc7:	e8 7f 11 00 00       	call   801f4b <ipc_find_env>
  800dcc:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd4:	6a 07                	push   $0x7
  800dd6:	68 00 60 80 00       	push   $0x806000
  800ddb:	53                   	push   %ebx
  800ddc:	ff 35 04 40 80 00    	pushl  0x804004
  800de2:	e8 10 11 00 00       	call   801ef7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800de7:	83 c4 0c             	add    $0xc,%esp
  800dea:	6a 00                	push   $0x0
  800dec:	6a 00                	push   $0x0
  800dee:	6a 00                	push   $0x0
  800df0:	e8 95 10 00 00       	call   801e8a <ipc_recv>
}
  800df5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    

00800dfa <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0a:	8b 06                	mov    (%esi),%eax
  800e0c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e11:	b8 01 00 00 00       	mov    $0x1,%eax
  800e16:	e8 95 ff ff ff       	call   800db0 <nsipc>
  800e1b:	89 c3                	mov    %eax,%ebx
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	78 20                	js     800e41 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	ff 35 10 60 80 00    	pushl  0x806010
  800e2a:	68 00 60 80 00       	push   $0x806000
  800e2f:	ff 75 0c             	pushl  0xc(%ebp)
  800e32:	e8 9e 0e 00 00       	call   801cd5 <memmove>
		*addrlen = ret->ret_addrlen;
  800e37:	a1 10 60 80 00       	mov    0x806010,%eax
  800e3c:	89 06                	mov    %eax,(%esi)
  800e3e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e41:	89 d8                	mov    %ebx,%eax
  800e43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 08             	sub    $0x8,%esp
  800e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5c:	53                   	push   %ebx
  800e5d:	ff 75 0c             	pushl  0xc(%ebp)
  800e60:	68 04 60 80 00       	push   $0x806004
  800e65:	e8 6b 0e 00 00       	call   801cd5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e6a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e70:	b8 02 00 00 00       	mov    $0x2,%eax
  800e75:	e8 36 ff ff ff       	call   800db0 <nsipc>
}
  800e7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e90:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e95:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9a:	e8 11 ff ff ff       	call   800db0 <nsipc>
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eaf:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb4:	e8 f7 fe ff ff       	call   800db0 <nsipc>
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ecd:	53                   	push   %ebx
  800ece:	ff 75 0c             	pushl  0xc(%ebp)
  800ed1:	68 04 60 80 00       	push   $0x806004
  800ed6:	e8 fa 0d 00 00       	call   801cd5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800edb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee1:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee6:	e8 c5 fe ff ff       	call   800db0 <nsipc>
}
  800eeb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eee:	c9                   	leave  
  800eef:	c3                   	ret    

00800ef0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800efe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f01:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f06:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0b:	e8 a0 fe ff ff       	call   800db0 <nsipc>
}
  800f10:	c9                   	leave  
  800f11:	c3                   	ret    

00800f12 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	56                   	push   %esi
  800f16:	53                   	push   %ebx
  800f17:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f22:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f28:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f30:	b8 07 00 00 00       	mov    $0x7,%eax
  800f35:	e8 76 fe ff ff       	call   800db0 <nsipc>
  800f3a:	89 c3                	mov    %eax,%ebx
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	78 35                	js     800f75 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f40:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f45:	7f 04                	jg     800f4b <nsipc_recv+0x39>
  800f47:	39 c6                	cmp    %eax,%esi
  800f49:	7d 16                	jge    800f61 <nsipc_recv+0x4f>
  800f4b:	68 67 23 80 00       	push   $0x802367
  800f50:	68 2f 23 80 00       	push   $0x80232f
  800f55:	6a 62                	push   $0x62
  800f57:	68 7c 23 80 00       	push   $0x80237c
  800f5c:	e8 84 05 00 00       	call   8014e5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	50                   	push   %eax
  800f65:	68 00 60 80 00       	push   $0x806000
  800f6a:	ff 75 0c             	pushl  0xc(%ebp)
  800f6d:	e8 63 0d 00 00       	call   801cd5 <memmove>
  800f72:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f75:	89 d8                	mov    %ebx,%eax
  800f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	53                   	push   %ebx
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f90:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f96:	7e 16                	jle    800fae <nsipc_send+0x30>
  800f98:	68 88 23 80 00       	push   $0x802388
  800f9d:	68 2f 23 80 00       	push   $0x80232f
  800fa2:	6a 6d                	push   $0x6d
  800fa4:	68 7c 23 80 00       	push   $0x80237c
  800fa9:	e8 37 05 00 00       	call   8014e5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	53                   	push   %ebx
  800fb2:	ff 75 0c             	pushl  0xc(%ebp)
  800fb5:	68 0c 60 80 00       	push   $0x80600c
  800fba:	e8 16 0d 00 00       	call   801cd5 <memmove>
	nsipcbuf.send.req_size = size;
  800fbf:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fcd:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd2:	e8 d9 fd ff ff       	call   800db0 <nsipc>
}
  800fd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fed:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ffa:	b8 09 00 00 00       	mov    $0x9,%eax
  800fff:	e8 ac fd ff ff       	call   800db0 <nsipc>
}
  801004:	c9                   	leave  
  801005:	c3                   	ret    

00801006 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	e8 87 f3 ff ff       	call   8003a0 <fd2data>
  801019:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101b:	83 c4 08             	add    $0x8,%esp
  80101e:	68 94 23 80 00       	push   $0x802394
  801023:	53                   	push   %ebx
  801024:	e8 1a 0b 00 00       	call   801b43 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801029:	8b 46 04             	mov    0x4(%esi),%eax
  80102c:	2b 06                	sub    (%esi),%eax
  80102e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801034:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103b:	00 00 00 
	stat->st_dev = &devpipe;
  80103e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801045:	30 80 00 
	return 0;
}
  801048:	b8 00 00 00 00       	mov    $0x0,%eax
  80104d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80105e:	53                   	push   %ebx
  80105f:	6a 00                	push   $0x0
  801061:	e8 7e f1 ff ff       	call   8001e4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801066:	89 1c 24             	mov    %ebx,(%esp)
  801069:	e8 32 f3 ff ff       	call   8003a0 <fd2data>
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	50                   	push   %eax
  801072:	6a 00                	push   $0x0
  801074:	e8 6b f1 ff ff       	call   8001e4 <sys_page_unmap>
}
  801079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107c:	c9                   	leave  
  80107d:	c3                   	ret    

0080107e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 1c             	sub    $0x1c,%esp
  801087:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80108a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80108c:	a1 08 40 80 00       	mov    0x804008,%eax
  801091:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	ff 75 e0             	pushl  -0x20(%ebp)
  80109a:	e8 e5 0e 00 00       	call   801f84 <pageref>
  80109f:	89 c3                	mov    %eax,%ebx
  8010a1:	89 3c 24             	mov    %edi,(%esp)
  8010a4:	e8 db 0e 00 00       	call   801f84 <pageref>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	39 c3                	cmp    %eax,%ebx
  8010ae:	0f 94 c1             	sete   %cl
  8010b1:	0f b6 c9             	movzbl %cl,%ecx
  8010b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010b7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010bd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c0:	39 ce                	cmp    %ecx,%esi
  8010c2:	74 1b                	je     8010df <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010c4:	39 c3                	cmp    %eax,%ebx
  8010c6:	75 c4                	jne    80108c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c8:	8b 42 58             	mov    0x58(%edx),%eax
  8010cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ce:	50                   	push   %eax
  8010cf:	56                   	push   %esi
  8010d0:	68 9b 23 80 00       	push   $0x80239b
  8010d5:	e8 e4 04 00 00       	call   8015be <cprintf>
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	eb ad                	jmp    80108c <_pipeisclosed+0xe>
	}
}
  8010df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	57                   	push   %edi
  8010ee:	56                   	push   %esi
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 28             	sub    $0x28,%esp
  8010f3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f6:	56                   	push   %esi
  8010f7:	e8 a4 f2 ff ff       	call   8003a0 <fd2data>
  8010fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	bf 00 00 00 00       	mov    $0x0,%edi
  801106:	eb 4b                	jmp    801153 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801108:	89 da                	mov    %ebx,%edx
  80110a:	89 f0                	mov    %esi,%eax
  80110c:	e8 6d ff ff ff       	call   80107e <_pipeisclosed>
  801111:	85 c0                	test   %eax,%eax
  801113:	75 48                	jne    80115d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801115:	e8 26 f0 ff ff       	call   800140 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80111a:	8b 43 04             	mov    0x4(%ebx),%eax
  80111d:	8b 0b                	mov    (%ebx),%ecx
  80111f:	8d 51 20             	lea    0x20(%ecx),%edx
  801122:	39 d0                	cmp    %edx,%eax
  801124:	73 e2                	jae    801108 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801126:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801129:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801130:	89 c2                	mov    %eax,%edx
  801132:	c1 fa 1f             	sar    $0x1f,%edx
  801135:	89 d1                	mov    %edx,%ecx
  801137:	c1 e9 1b             	shr    $0x1b,%ecx
  80113a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113d:	83 e2 1f             	and    $0x1f,%edx
  801140:	29 ca                	sub    %ecx,%edx
  801142:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801146:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114a:	83 c0 01             	add    $0x1,%eax
  80114d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801150:	83 c7 01             	add    $0x1,%edi
  801153:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801156:	75 c2                	jne    80111a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801158:	8b 45 10             	mov    0x10(%ebp),%eax
  80115b:	eb 05                	jmp    801162 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 18             	sub    $0x18,%esp
  801173:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801176:	57                   	push   %edi
  801177:	e8 24 f2 ff ff       	call   8003a0 <fd2data>
  80117c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	bb 00 00 00 00       	mov    $0x0,%ebx
  801186:	eb 3d                	jmp    8011c5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801188:	85 db                	test   %ebx,%ebx
  80118a:	74 04                	je     801190 <devpipe_read+0x26>
				return i;
  80118c:	89 d8                	mov    %ebx,%eax
  80118e:	eb 44                	jmp    8011d4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801190:	89 f2                	mov    %esi,%edx
  801192:	89 f8                	mov    %edi,%eax
  801194:	e8 e5 fe ff ff       	call   80107e <_pipeisclosed>
  801199:	85 c0                	test   %eax,%eax
  80119b:	75 32                	jne    8011cf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80119d:	e8 9e ef ff ff       	call   800140 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a2:	8b 06                	mov    (%esi),%eax
  8011a4:	3b 46 04             	cmp    0x4(%esi),%eax
  8011a7:	74 df                	je     801188 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a9:	99                   	cltd   
  8011aa:	c1 ea 1b             	shr    $0x1b,%edx
  8011ad:	01 d0                	add    %edx,%eax
  8011af:	83 e0 1f             	and    $0x1f,%eax
  8011b2:	29 d0                	sub    %edx,%eax
  8011b4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011bf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c2:	83 c3 01             	add    $0x1,%ebx
  8011c5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011c8:	75 d8                	jne    8011a2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8011cd:	eb 05                	jmp    8011d4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011cf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	e8 ca f1 ff ff       	call   8003b7 <fd_alloc>
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	89 c2                	mov    %eax,%edx
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	0f 88 2c 01 00 00    	js     801326 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	68 07 04 00 00       	push   $0x407
  801202:	ff 75 f4             	pushl  -0xc(%ebp)
  801205:	6a 00                	push   $0x0
  801207:	e8 53 ef ff ff       	call   80015f <sys_page_alloc>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	89 c2                	mov    %eax,%edx
  801211:	85 c0                	test   %eax,%eax
  801213:	0f 88 0d 01 00 00    	js     801326 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	e8 92 f1 ff ff       	call   8003b7 <fd_alloc>
  801225:	89 c3                	mov    %eax,%ebx
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	0f 88 e2 00 00 00    	js     801314 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801232:	83 ec 04             	sub    $0x4,%esp
  801235:	68 07 04 00 00       	push   $0x407
  80123a:	ff 75 f0             	pushl  -0x10(%ebp)
  80123d:	6a 00                	push   $0x0
  80123f:	e8 1b ef ff ff       	call   80015f <sys_page_alloc>
  801244:	89 c3                	mov    %eax,%ebx
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	0f 88 c3 00 00 00    	js     801314 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	ff 75 f4             	pushl  -0xc(%ebp)
  801257:	e8 44 f1 ff ff       	call   8003a0 <fd2data>
  80125c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125e:	83 c4 0c             	add    $0xc,%esp
  801261:	68 07 04 00 00       	push   $0x407
  801266:	50                   	push   %eax
  801267:	6a 00                	push   $0x0
  801269:	e8 f1 ee ff ff       	call   80015f <sys_page_alloc>
  80126e:	89 c3                	mov    %eax,%ebx
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	0f 88 89 00 00 00    	js     801304 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	ff 75 f0             	pushl  -0x10(%ebp)
  801281:	e8 1a f1 ff ff       	call   8003a0 <fd2data>
  801286:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128d:	50                   	push   %eax
  80128e:	6a 00                	push   $0x0
  801290:	56                   	push   %esi
  801291:	6a 00                	push   $0x0
  801293:	e8 0a ef ff ff       	call   8001a2 <sys_page_map>
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	83 c4 20             	add    $0x20,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 55                	js     8012f6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012aa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012af:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d1:	e8 ba f0 ff ff       	call   800390 <fd2num>
  8012d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012db:	83 c4 04             	add    $0x4,%esp
  8012de:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e1:	e8 aa f0 ff ff       	call   800390 <fd2num>
  8012e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f4:	eb 30                	jmp    801326 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	56                   	push   %esi
  8012fa:	6a 00                	push   $0x0
  8012fc:	e8 e3 ee ff ff       	call   8001e4 <sys_page_unmap>
  801301:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	ff 75 f0             	pushl  -0x10(%ebp)
  80130a:	6a 00                	push   $0x0
  80130c:	e8 d3 ee ff ff       	call   8001e4 <sys_page_unmap>
  801311:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	ff 75 f4             	pushl  -0xc(%ebp)
  80131a:	6a 00                	push   $0x0
  80131c:	e8 c3 ee ff ff       	call   8001e4 <sys_page_unmap>
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801326:	89 d0                	mov    %edx,%eax
  801328:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 75 08             	pushl  0x8(%ebp)
  80133c:	e8 c5 f0 ff ff       	call   800406 <fd_lookup>
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 18                	js     801360 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801348:	83 ec 0c             	sub    $0xc,%esp
  80134b:	ff 75 f4             	pushl  -0xc(%ebp)
  80134e:	e8 4d f0 ff ff       	call   8003a0 <fd2data>
	return _pipeisclosed(fd, p);
  801353:	89 c2                	mov    %eax,%edx
  801355:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801358:	e8 21 fd ff ff       	call   80107e <_pipeisclosed>
  80135d:	83 c4 10             	add    $0x10,%esp
}
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801365:	b8 00 00 00 00       	mov    $0x0,%eax
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801372:	68 b3 23 80 00       	push   $0x8023b3
  801377:	ff 75 0c             	pushl  0xc(%ebp)
  80137a:	e8 c4 07 00 00       	call   801b43 <strcpy>
	return 0;
}
  80137f:	b8 00 00 00 00       	mov    $0x0,%eax
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	57                   	push   %edi
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801392:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801397:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139d:	eb 2d                	jmp    8013cc <devcons_write+0x46>
		m = n - tot;
  80139f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013a4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013a7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013ac:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013af:	83 ec 04             	sub    $0x4,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	03 45 0c             	add    0xc(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	57                   	push   %edi
  8013b8:	e8 18 09 00 00       	call   801cd5 <memmove>
		sys_cputs(buf, m);
  8013bd:	83 c4 08             	add    $0x8,%esp
  8013c0:	53                   	push   %ebx
  8013c1:	57                   	push   %edi
  8013c2:	e8 dc ec ff ff       	call   8000a3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c7:	01 de                	add    %ebx,%esi
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	89 f0                	mov    %esi,%eax
  8013ce:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d1:	72 cc                	jb     80139f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ea:	74 2a                	je     801416 <devcons_read+0x3b>
  8013ec:	eb 05                	jmp    8013f3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013ee:	e8 4d ed ff ff       	call   800140 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f3:	e8 c9 ec ff ff       	call   8000c1 <sys_cgetc>
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	74 f2                	je     8013ee <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 16                	js     801416 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801400:	83 f8 04             	cmp    $0x4,%eax
  801403:	74 0c                	je     801411 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801405:	8b 55 0c             	mov    0xc(%ebp),%edx
  801408:	88 02                	mov    %al,(%edx)
	return 1;
  80140a:	b8 01 00 00 00       	mov    $0x1,%eax
  80140f:	eb 05                	jmp    801416 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801411:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801416:	c9                   	leave  
  801417:	c3                   	ret    

00801418 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801424:	6a 01                	push   $0x1
  801426:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801429:	50                   	push   %eax
  80142a:	e8 74 ec ff ff       	call   8000a3 <sys_cputs>
}
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <getchar>:

int
getchar(void)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80143a:	6a 01                	push   $0x1
  80143c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	6a 00                	push   $0x0
  801442:	e8 25 f2 ff ff       	call   80066c <read>
	if (r < 0)
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 0f                	js     80145d <getchar+0x29>
		return r;
	if (r < 1)
  80144e:	85 c0                	test   %eax,%eax
  801450:	7e 06                	jle    801458 <getchar+0x24>
		return -E_EOF;
	return c;
  801452:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801456:	eb 05                	jmp    80145d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801458:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    

0080145f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	ff 75 08             	pushl  0x8(%ebp)
  80146c:	e8 95 ef ff ff       	call   800406 <fd_lookup>
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	78 11                	js     801489 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801481:	39 10                	cmp    %edx,(%eax)
  801483:	0f 94 c0             	sete   %al
  801486:	0f b6 c0             	movzbl %al,%eax
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <opencons>:

int
opencons(void)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	e8 1d ef ff ff       	call   8003b7 <fd_alloc>
  80149a:	83 c4 10             	add    $0x10,%esp
		return r;
  80149d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 3e                	js     8014e1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	68 07 04 00 00       	push   $0x407
  8014ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ae:	6a 00                	push   $0x0
  8014b0:	e8 aa ec ff ff       	call   80015f <sys_page_alloc>
  8014b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 23                	js     8014e1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014be:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	50                   	push   %eax
  8014d7:	e8 b4 ee ff ff       	call   800390 <fd2num>
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	83 c4 10             	add    $0x10,%esp
}
  8014e1:	89 d0                	mov    %edx,%eax
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ed:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f3:	e8 29 ec ff ff       	call   800121 <sys_getenvid>
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	ff 75 0c             	pushl  0xc(%ebp)
  8014fe:	ff 75 08             	pushl  0x8(%ebp)
  801501:	56                   	push   %esi
  801502:	50                   	push   %eax
  801503:	68 c0 23 80 00       	push   $0x8023c0
  801508:	e8 b1 00 00 00       	call   8015be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80150d:	83 c4 18             	add    $0x18,%esp
  801510:	53                   	push   %ebx
  801511:	ff 75 10             	pushl  0x10(%ebp)
  801514:	e8 54 00 00 00       	call   80156d <vcprintf>
	cprintf("\n");
  801519:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801520:	e8 99 00 00 00       	call   8015be <cprintf>
  801525:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801528:	cc                   	int3   
  801529:	eb fd                	jmp    801528 <_panic+0x43>

0080152b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801535:	8b 13                	mov    (%ebx),%edx
  801537:	8d 42 01             	lea    0x1(%edx),%eax
  80153a:	89 03                	mov    %eax,(%ebx)
  80153c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801543:	3d ff 00 00 00       	cmp    $0xff,%eax
  801548:	75 1a                	jne    801564 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	68 ff 00 00 00       	push   $0xff
  801552:	8d 43 08             	lea    0x8(%ebx),%eax
  801555:	50                   	push   %eax
  801556:	e8 48 eb ff ff       	call   8000a3 <sys_cputs>
		b->idx = 0;
  80155b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801561:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801564:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801576:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80157d:	00 00 00 
	b.cnt = 0;
  801580:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801587:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80158a:	ff 75 0c             	pushl  0xc(%ebp)
  80158d:	ff 75 08             	pushl  0x8(%ebp)
  801590:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	68 2b 15 80 00       	push   $0x80152b
  80159c:	e8 54 01 00 00       	call   8016f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	e8 ed ea ff ff       	call   8000a3 <sys_cputs>

	return b.cnt;
}
  8015b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c7:	50                   	push   %eax
  8015c8:	ff 75 08             	pushl  0x8(%ebp)
  8015cb:	e8 9d ff ff ff       	call   80156d <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	57                   	push   %edi
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 1c             	sub    $0x1c,%esp
  8015db:	89 c7                	mov    %eax,%edi
  8015dd:	89 d6                	mov    %edx,%esi
  8015df:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015f9:	39 d3                	cmp    %edx,%ebx
  8015fb:	72 05                	jb     801602 <printnum+0x30>
  8015fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  801600:	77 45                	ja     801647 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801602:	83 ec 0c             	sub    $0xc,%esp
  801605:	ff 75 18             	pushl  0x18(%ebp)
  801608:	8b 45 14             	mov    0x14(%ebp),%eax
  80160b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80160e:	53                   	push   %ebx
  80160f:	ff 75 10             	pushl  0x10(%ebp)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	ff 75 e4             	pushl  -0x1c(%ebp)
  801618:	ff 75 e0             	pushl  -0x20(%ebp)
  80161b:	ff 75 dc             	pushl  -0x24(%ebp)
  80161e:	ff 75 d8             	pushl  -0x28(%ebp)
  801621:	e8 9a 09 00 00       	call   801fc0 <__udivdi3>
  801626:	83 c4 18             	add    $0x18,%esp
  801629:	52                   	push   %edx
  80162a:	50                   	push   %eax
  80162b:	89 f2                	mov    %esi,%edx
  80162d:	89 f8                	mov    %edi,%eax
  80162f:	e8 9e ff ff ff       	call   8015d2 <printnum>
  801634:	83 c4 20             	add    $0x20,%esp
  801637:	eb 18                	jmp    801651 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	56                   	push   %esi
  80163d:	ff 75 18             	pushl  0x18(%ebp)
  801640:	ff d7                	call   *%edi
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	eb 03                	jmp    80164a <printnum+0x78>
  801647:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80164a:	83 eb 01             	sub    $0x1,%ebx
  80164d:	85 db                	test   %ebx,%ebx
  80164f:	7f e8                	jg     801639 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	56                   	push   %esi
  801655:	83 ec 04             	sub    $0x4,%esp
  801658:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165b:	ff 75 e0             	pushl  -0x20(%ebp)
  80165e:	ff 75 dc             	pushl  -0x24(%ebp)
  801661:	ff 75 d8             	pushl  -0x28(%ebp)
  801664:	e8 87 0a 00 00       	call   8020f0 <__umoddi3>
  801669:	83 c4 14             	add    $0x14,%esp
  80166c:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801673:	50                   	push   %eax
  801674:	ff d7                	call   *%edi
}
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5f                   	pop    %edi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801684:	83 fa 01             	cmp    $0x1,%edx
  801687:	7e 0e                	jle    801697 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801689:	8b 10                	mov    (%eax),%edx
  80168b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80168e:	89 08                	mov    %ecx,(%eax)
  801690:	8b 02                	mov    (%edx),%eax
  801692:	8b 52 04             	mov    0x4(%edx),%edx
  801695:	eb 22                	jmp    8016b9 <getuint+0x38>
	else if (lflag)
  801697:	85 d2                	test   %edx,%edx
  801699:	74 10                	je     8016ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80169b:	8b 10                	mov    (%eax),%edx
  80169d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a0:	89 08                	mov    %ecx,(%eax)
  8016a2:	8b 02                	mov    (%edx),%eax
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a9:	eb 0e                	jmp    8016b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016ab:	8b 10                	mov    (%eax),%edx
  8016ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b0:	89 08                	mov    %ecx,(%eax)
  8016b2:	8b 02                	mov    (%edx),%eax
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016c5:	8b 10                	mov    (%eax),%edx
  8016c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8016ca:	73 0a                	jae    8016d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016cf:	89 08                	mov    %ecx,(%eax)
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	88 02                	mov    %al,(%edx)
}
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e1:	50                   	push   %eax
  8016e2:	ff 75 10             	pushl  0x10(%ebp)
  8016e5:	ff 75 0c             	pushl  0xc(%ebp)
  8016e8:	ff 75 08             	pushl  0x8(%ebp)
  8016eb:	e8 05 00 00 00       	call   8016f5 <vprintfmt>
	va_end(ap);
}
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	57                   	push   %edi
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 2c             	sub    $0x2c,%esp
  8016fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801704:	8b 7d 10             	mov    0x10(%ebp),%edi
  801707:	eb 12                	jmp    80171b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801709:	85 c0                	test   %eax,%eax
  80170b:	0f 84 89 03 00 00    	je     801a9a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	53                   	push   %ebx
  801715:	50                   	push   %eax
  801716:	ff d6                	call   *%esi
  801718:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80171b:	83 c7 01             	add    $0x1,%edi
  80171e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801722:	83 f8 25             	cmp    $0x25,%eax
  801725:	75 e2                	jne    801709 <vprintfmt+0x14>
  801727:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80172b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801732:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801739:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801740:	ba 00 00 00 00       	mov    $0x0,%edx
  801745:	eb 07                	jmp    80174e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801747:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80174a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174e:	8d 47 01             	lea    0x1(%edi),%eax
  801751:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801754:	0f b6 07             	movzbl (%edi),%eax
  801757:	0f b6 c8             	movzbl %al,%ecx
  80175a:	83 e8 23             	sub    $0x23,%eax
  80175d:	3c 55                	cmp    $0x55,%al
  80175f:	0f 87 1a 03 00 00    	ja     801a7f <vprintfmt+0x38a>
  801765:	0f b6 c0             	movzbl %al,%eax
  801768:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80176f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801772:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801776:	eb d6                	jmp    80174e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177b:	b8 00 00 00 00       	mov    $0x0,%eax
  801780:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801783:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801786:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80178a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80178d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801790:	83 fa 09             	cmp    $0x9,%edx
  801793:	77 39                	ja     8017ce <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801795:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801798:	eb e9                	jmp    801783 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80179a:	8b 45 14             	mov    0x14(%ebp),%eax
  80179d:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017a3:	8b 00                	mov    (%eax),%eax
  8017a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017ab:	eb 27                	jmp    8017d4 <vprintfmt+0xdf>
  8017ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017b7:	0f 49 c8             	cmovns %eax,%ecx
  8017ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c0:	eb 8c                	jmp    80174e <vprintfmt+0x59>
  8017c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017cc:	eb 80                	jmp    80174e <vprintfmt+0x59>
  8017ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017d8:	0f 89 70 ff ff ff    	jns    80174e <vprintfmt+0x59>
				width = precision, precision = -1;
  8017de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017eb:	e9 5e ff ff ff       	jmp    80174e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017f6:	e9 53 ff ff ff       	jmp    80174e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fe:	8d 50 04             	lea    0x4(%eax),%edx
  801801:	89 55 14             	mov    %edx,0x14(%ebp)
  801804:	83 ec 08             	sub    $0x8,%esp
  801807:	53                   	push   %ebx
  801808:	ff 30                	pushl  (%eax)
  80180a:	ff d6                	call   *%esi
			break;
  80180c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801812:	e9 04 ff ff ff       	jmp    80171b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801817:	8b 45 14             	mov    0x14(%ebp),%eax
  80181a:	8d 50 04             	lea    0x4(%eax),%edx
  80181d:	89 55 14             	mov    %edx,0x14(%ebp)
  801820:	8b 00                	mov    (%eax),%eax
  801822:	99                   	cltd   
  801823:	31 d0                	xor    %edx,%eax
  801825:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801827:	83 f8 0f             	cmp    $0xf,%eax
  80182a:	7f 0b                	jg     801837 <vprintfmt+0x142>
  80182c:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801833:	85 d2                	test   %edx,%edx
  801835:	75 18                	jne    80184f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801837:	50                   	push   %eax
  801838:	68 fb 23 80 00       	push   $0x8023fb
  80183d:	53                   	push   %ebx
  80183e:	56                   	push   %esi
  80183f:	e8 94 fe ff ff       	call   8016d8 <printfmt>
  801844:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80184a:	e9 cc fe ff ff       	jmp    80171b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80184f:	52                   	push   %edx
  801850:	68 41 23 80 00       	push   $0x802341
  801855:	53                   	push   %ebx
  801856:	56                   	push   %esi
  801857:	e8 7c fe ff ff       	call   8016d8 <printfmt>
  80185c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801862:	e9 b4 fe ff ff       	jmp    80171b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801867:	8b 45 14             	mov    0x14(%ebp),%eax
  80186a:	8d 50 04             	lea    0x4(%eax),%edx
  80186d:	89 55 14             	mov    %edx,0x14(%ebp)
  801870:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801872:	85 ff                	test   %edi,%edi
  801874:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801879:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80187c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801880:	0f 8e 94 00 00 00    	jle    80191a <vprintfmt+0x225>
  801886:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80188a:	0f 84 98 00 00 00    	je     801928 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	ff 75 d0             	pushl  -0x30(%ebp)
  801896:	57                   	push   %edi
  801897:	e8 86 02 00 00       	call   801b22 <strnlen>
  80189c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80189f:	29 c1                	sub    %eax,%ecx
  8018a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b3:	eb 0f                	jmp    8018c4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018b5:	83 ec 08             	sub    $0x8,%esp
  8018b8:	53                   	push   %ebx
  8018b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8018bc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018be:	83 ef 01             	sub    $0x1,%edi
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	85 ff                	test   %edi,%edi
  8018c6:	7f ed                	jg     8018b5 <vprintfmt+0x1c0>
  8018c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018ce:	85 c9                	test   %ecx,%ecx
  8018d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d5:	0f 49 c1             	cmovns %ecx,%eax
  8018d8:	29 c1                	sub    %eax,%ecx
  8018da:	89 75 08             	mov    %esi,0x8(%ebp)
  8018dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e3:	89 cb                	mov    %ecx,%ebx
  8018e5:	eb 4d                	jmp    801934 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018eb:	74 1b                	je     801908 <vprintfmt+0x213>
  8018ed:	0f be c0             	movsbl %al,%eax
  8018f0:	83 e8 20             	sub    $0x20,%eax
  8018f3:	83 f8 5e             	cmp    $0x5e,%eax
  8018f6:	76 10                	jbe    801908 <vprintfmt+0x213>
					putch('?', putdat);
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	ff 75 0c             	pushl  0xc(%ebp)
  8018fe:	6a 3f                	push   $0x3f
  801900:	ff 55 08             	call   *0x8(%ebp)
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	eb 0d                	jmp    801915 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	ff 75 0c             	pushl  0xc(%ebp)
  80190e:	52                   	push   %edx
  80190f:	ff 55 08             	call   *0x8(%ebp)
  801912:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801915:	83 eb 01             	sub    $0x1,%ebx
  801918:	eb 1a                	jmp    801934 <vprintfmt+0x23f>
  80191a:	89 75 08             	mov    %esi,0x8(%ebp)
  80191d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801920:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801923:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801926:	eb 0c                	jmp    801934 <vprintfmt+0x23f>
  801928:	89 75 08             	mov    %esi,0x8(%ebp)
  80192b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80192e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801931:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801934:	83 c7 01             	add    $0x1,%edi
  801937:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80193b:	0f be d0             	movsbl %al,%edx
  80193e:	85 d2                	test   %edx,%edx
  801940:	74 23                	je     801965 <vprintfmt+0x270>
  801942:	85 f6                	test   %esi,%esi
  801944:	78 a1                	js     8018e7 <vprintfmt+0x1f2>
  801946:	83 ee 01             	sub    $0x1,%esi
  801949:	79 9c                	jns    8018e7 <vprintfmt+0x1f2>
  80194b:	89 df                	mov    %ebx,%edi
  80194d:	8b 75 08             	mov    0x8(%ebp),%esi
  801950:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801953:	eb 18                	jmp    80196d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	53                   	push   %ebx
  801959:	6a 20                	push   $0x20
  80195b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80195d:	83 ef 01             	sub    $0x1,%edi
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	eb 08                	jmp    80196d <vprintfmt+0x278>
  801965:	89 df                	mov    %ebx,%edi
  801967:	8b 75 08             	mov    0x8(%ebp),%esi
  80196a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80196d:	85 ff                	test   %edi,%edi
  80196f:	7f e4                	jg     801955 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801971:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801974:	e9 a2 fd ff ff       	jmp    80171b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801979:	83 fa 01             	cmp    $0x1,%edx
  80197c:	7e 16                	jle    801994 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80197e:	8b 45 14             	mov    0x14(%ebp),%eax
  801981:	8d 50 08             	lea    0x8(%eax),%edx
  801984:	89 55 14             	mov    %edx,0x14(%ebp)
  801987:	8b 50 04             	mov    0x4(%eax),%edx
  80198a:	8b 00                	mov    (%eax),%eax
  80198c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80198f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801992:	eb 32                	jmp    8019c6 <vprintfmt+0x2d1>
	else if (lflag)
  801994:	85 d2                	test   %edx,%edx
  801996:	74 18                	je     8019b0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801998:	8b 45 14             	mov    0x14(%ebp),%eax
  80199b:	8d 50 04             	lea    0x4(%eax),%edx
  80199e:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a1:	8b 00                	mov    (%eax),%eax
  8019a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a6:	89 c1                	mov    %eax,%ecx
  8019a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019ae:	eb 16                	jmp    8019c6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b3:	8d 50 04             	lea    0x4(%eax),%edx
  8019b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b9:	8b 00                	mov    (%eax),%eax
  8019bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019be:	89 c1                	mov    %eax,%ecx
  8019c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019d5:	79 74                	jns    801a4b <vprintfmt+0x356>
				putch('-', putdat);
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	53                   	push   %ebx
  8019db:	6a 2d                	push   $0x2d
  8019dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8019df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019e5:	f7 d8                	neg    %eax
  8019e7:	83 d2 00             	adc    $0x0,%edx
  8019ea:	f7 da                	neg    %edx
  8019ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019f4:	eb 55                	jmp    801a4b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f9:	e8 83 fc ff ff       	call   801681 <getuint>
			base = 10;
  8019fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a03:	eb 46                	jmp    801a4b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a05:	8d 45 14             	lea    0x14(%ebp),%eax
  801a08:	e8 74 fc ff ff       	call   801681 <getuint>
		        base = 8;
  801a0d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a12:	eb 37                	jmp    801a4b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a14:	83 ec 08             	sub    $0x8,%esp
  801a17:	53                   	push   %ebx
  801a18:	6a 30                	push   $0x30
  801a1a:	ff d6                	call   *%esi
			putch('x', putdat);
  801a1c:	83 c4 08             	add    $0x8,%esp
  801a1f:	53                   	push   %ebx
  801a20:	6a 78                	push   $0x78
  801a22:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a24:	8b 45 14             	mov    0x14(%ebp),%eax
  801a27:	8d 50 04             	lea    0x4(%eax),%edx
  801a2a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a2d:	8b 00                	mov    (%eax),%eax
  801a2f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a34:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a37:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a3c:	eb 0d                	jmp    801a4b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a3e:	8d 45 14             	lea    0x14(%ebp),%eax
  801a41:	e8 3b fc ff ff       	call   801681 <getuint>
			base = 16;
  801a46:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a52:	57                   	push   %edi
  801a53:	ff 75 e0             	pushl  -0x20(%ebp)
  801a56:	51                   	push   %ecx
  801a57:	52                   	push   %edx
  801a58:	50                   	push   %eax
  801a59:	89 da                	mov    %ebx,%edx
  801a5b:	89 f0                	mov    %esi,%eax
  801a5d:	e8 70 fb ff ff       	call   8015d2 <printnum>
			break;
  801a62:	83 c4 20             	add    $0x20,%esp
  801a65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a68:	e9 ae fc ff ff       	jmp    80171b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a6d:	83 ec 08             	sub    $0x8,%esp
  801a70:	53                   	push   %ebx
  801a71:	51                   	push   %ecx
  801a72:	ff d6                	call   *%esi
			break;
  801a74:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a7a:	e9 9c fc ff ff       	jmp    80171b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	53                   	push   %ebx
  801a83:	6a 25                	push   $0x25
  801a85:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	eb 03                	jmp    801a8f <vprintfmt+0x39a>
  801a8c:	83 ef 01             	sub    $0x1,%edi
  801a8f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a93:	75 f7                	jne    801a8c <vprintfmt+0x397>
  801a95:	e9 81 fc ff ff       	jmp    80171b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5f                   	pop    %edi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	83 ec 18             	sub    $0x18,%esp
  801aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ab8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	74 26                	je     801ae9 <vsnprintf+0x47>
  801ac3:	85 d2                	test   %edx,%edx
  801ac5:	7e 22                	jle    801ae9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ac7:	ff 75 14             	pushl  0x14(%ebp)
  801aca:	ff 75 10             	pushl  0x10(%ebp)
  801acd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad0:	50                   	push   %eax
  801ad1:	68 bb 16 80 00       	push   $0x8016bb
  801ad6:	e8 1a fc ff ff       	call   8016f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801adb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ade:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	eb 05                	jmp    801aee <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ae9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801af9:	50                   	push   %eax
  801afa:	ff 75 10             	pushl  0x10(%ebp)
  801afd:	ff 75 0c             	pushl  0xc(%ebp)
  801b00:	ff 75 08             	pushl  0x8(%ebp)
  801b03:	e8 9a ff ff ff       	call   801aa2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
  801b15:	eb 03                	jmp    801b1a <strlen+0x10>
		n++;
  801b17:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b1e:	75 f7                	jne    801b17 <strlen+0xd>
		n++;
	return n;
}
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b28:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b30:	eb 03                	jmp    801b35 <strnlen+0x13>
		n++;
  801b32:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b35:	39 c2                	cmp    %eax,%edx
  801b37:	74 08                	je     801b41 <strnlen+0x1f>
  801b39:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b3d:	75 f3                	jne    801b32 <strnlen+0x10>
  801b3f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	53                   	push   %ebx
  801b47:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b4d:	89 c2                	mov    %eax,%edx
  801b4f:	83 c2 01             	add    $0x1,%edx
  801b52:	83 c1 01             	add    $0x1,%ecx
  801b55:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b59:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b5c:	84 db                	test   %bl,%bl
  801b5e:	75 ef                	jne    801b4f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b60:	5b                   	pop    %ebx
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	53                   	push   %ebx
  801b67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b6a:	53                   	push   %ebx
  801b6b:	e8 9a ff ff ff       	call   801b0a <strlen>
  801b70:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b73:	ff 75 0c             	pushl  0xc(%ebp)
  801b76:	01 d8                	add    %ebx,%eax
  801b78:	50                   	push   %eax
  801b79:	e8 c5 ff ff ff       	call   801b43 <strcpy>
	return dst;
}
  801b7e:	89 d8                	mov    %ebx,%eax
  801b80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b90:	89 f3                	mov    %esi,%ebx
  801b92:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b95:	89 f2                	mov    %esi,%edx
  801b97:	eb 0f                	jmp    801ba8 <strncpy+0x23>
		*dst++ = *src;
  801b99:	83 c2 01             	add    $0x1,%edx
  801b9c:	0f b6 01             	movzbl (%ecx),%eax
  801b9f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba2:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba8:	39 da                	cmp    %ebx,%edx
  801baa:	75 ed                	jne    801b99 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bac:	89 f0                	mov    %esi,%eax
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	8b 75 08             	mov    0x8(%ebp),%esi
  801bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbd:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc2:	85 d2                	test   %edx,%edx
  801bc4:	74 21                	je     801be7 <strlcpy+0x35>
  801bc6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bca:	89 f2                	mov    %esi,%edx
  801bcc:	eb 09                	jmp    801bd7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bce:	83 c2 01             	add    $0x1,%edx
  801bd1:	83 c1 01             	add    $0x1,%ecx
  801bd4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bd7:	39 c2                	cmp    %eax,%edx
  801bd9:	74 09                	je     801be4 <strlcpy+0x32>
  801bdb:	0f b6 19             	movzbl (%ecx),%ebx
  801bde:	84 db                	test   %bl,%bl
  801be0:	75 ec                	jne    801bce <strlcpy+0x1c>
  801be2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801be7:	29 f0                	sub    %esi,%eax
}
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf6:	eb 06                	jmp    801bfe <strcmp+0x11>
		p++, q++;
  801bf8:	83 c1 01             	add    $0x1,%ecx
  801bfb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bfe:	0f b6 01             	movzbl (%ecx),%eax
  801c01:	84 c0                	test   %al,%al
  801c03:	74 04                	je     801c09 <strcmp+0x1c>
  801c05:	3a 02                	cmp    (%edx),%al
  801c07:	74 ef                	je     801bf8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c09:	0f b6 c0             	movzbl %al,%eax
  801c0c:	0f b6 12             	movzbl (%edx),%edx
  801c0f:	29 d0                	sub    %edx,%eax
}
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	53                   	push   %ebx
  801c17:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1d:	89 c3                	mov    %eax,%ebx
  801c1f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c22:	eb 06                	jmp    801c2a <strncmp+0x17>
		n--, p++, q++;
  801c24:	83 c0 01             	add    $0x1,%eax
  801c27:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c2a:	39 d8                	cmp    %ebx,%eax
  801c2c:	74 15                	je     801c43 <strncmp+0x30>
  801c2e:	0f b6 08             	movzbl (%eax),%ecx
  801c31:	84 c9                	test   %cl,%cl
  801c33:	74 04                	je     801c39 <strncmp+0x26>
  801c35:	3a 0a                	cmp    (%edx),%cl
  801c37:	74 eb                	je     801c24 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c39:	0f b6 00             	movzbl (%eax),%eax
  801c3c:	0f b6 12             	movzbl (%edx),%edx
  801c3f:	29 d0                	sub    %edx,%eax
  801c41:	eb 05                	jmp    801c48 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c48:	5b                   	pop    %ebx
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c55:	eb 07                	jmp    801c5e <strchr+0x13>
		if (*s == c)
  801c57:	38 ca                	cmp    %cl,%dl
  801c59:	74 0f                	je     801c6a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c5b:	83 c0 01             	add    $0x1,%eax
  801c5e:	0f b6 10             	movzbl (%eax),%edx
  801c61:	84 d2                	test   %dl,%dl
  801c63:	75 f2                	jne    801c57 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c76:	eb 03                	jmp    801c7b <strfind+0xf>
  801c78:	83 c0 01             	add    $0x1,%eax
  801c7b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c7e:	38 ca                	cmp    %cl,%dl
  801c80:	74 04                	je     801c86 <strfind+0x1a>
  801c82:	84 d2                	test   %dl,%dl
  801c84:	75 f2                	jne    801c78 <strfind+0xc>
			break;
	return (char *) s;
}
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    

00801c88 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	57                   	push   %edi
  801c8c:	56                   	push   %esi
  801c8d:	53                   	push   %ebx
  801c8e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c94:	85 c9                	test   %ecx,%ecx
  801c96:	74 36                	je     801cce <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c98:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c9e:	75 28                	jne    801cc8 <memset+0x40>
  801ca0:	f6 c1 03             	test   $0x3,%cl
  801ca3:	75 23                	jne    801cc8 <memset+0x40>
		c &= 0xFF;
  801ca5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ca9:	89 d3                	mov    %edx,%ebx
  801cab:	c1 e3 08             	shl    $0x8,%ebx
  801cae:	89 d6                	mov    %edx,%esi
  801cb0:	c1 e6 18             	shl    $0x18,%esi
  801cb3:	89 d0                	mov    %edx,%eax
  801cb5:	c1 e0 10             	shl    $0x10,%eax
  801cb8:	09 f0                	or     %esi,%eax
  801cba:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cbc:	89 d8                	mov    %ebx,%eax
  801cbe:	09 d0                	or     %edx,%eax
  801cc0:	c1 e9 02             	shr    $0x2,%ecx
  801cc3:	fc                   	cld    
  801cc4:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc6:	eb 06                	jmp    801cce <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccb:	fc                   	cld    
  801ccc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cce:	89 f8                	mov    %edi,%eax
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	57                   	push   %edi
  801cd9:	56                   	push   %esi
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce3:	39 c6                	cmp    %eax,%esi
  801ce5:	73 35                	jae    801d1c <memmove+0x47>
  801ce7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cea:	39 d0                	cmp    %edx,%eax
  801cec:	73 2e                	jae    801d1c <memmove+0x47>
		s += n;
		d += n;
  801cee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf1:	89 d6                	mov    %edx,%esi
  801cf3:	09 fe                	or     %edi,%esi
  801cf5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cfb:	75 13                	jne    801d10 <memmove+0x3b>
  801cfd:	f6 c1 03             	test   $0x3,%cl
  801d00:	75 0e                	jne    801d10 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d02:	83 ef 04             	sub    $0x4,%edi
  801d05:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d08:	c1 e9 02             	shr    $0x2,%ecx
  801d0b:	fd                   	std    
  801d0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d0e:	eb 09                	jmp    801d19 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d10:	83 ef 01             	sub    $0x1,%edi
  801d13:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d16:	fd                   	std    
  801d17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d19:	fc                   	cld    
  801d1a:	eb 1d                	jmp    801d39 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1c:	89 f2                	mov    %esi,%edx
  801d1e:	09 c2                	or     %eax,%edx
  801d20:	f6 c2 03             	test   $0x3,%dl
  801d23:	75 0f                	jne    801d34 <memmove+0x5f>
  801d25:	f6 c1 03             	test   $0x3,%cl
  801d28:	75 0a                	jne    801d34 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d2a:	c1 e9 02             	shr    $0x2,%ecx
  801d2d:	89 c7                	mov    %eax,%edi
  801d2f:	fc                   	cld    
  801d30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d32:	eb 05                	jmp    801d39 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d34:	89 c7                	mov    %eax,%edi
  801d36:	fc                   	cld    
  801d37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d39:	5e                   	pop    %esi
  801d3a:	5f                   	pop    %edi
  801d3b:	5d                   	pop    %ebp
  801d3c:	c3                   	ret    

00801d3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d40:	ff 75 10             	pushl  0x10(%ebp)
  801d43:	ff 75 0c             	pushl  0xc(%ebp)
  801d46:	ff 75 08             	pushl  0x8(%ebp)
  801d49:	e8 87 ff ff ff       	call   801cd5 <memmove>
}
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
  801d58:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5b:	89 c6                	mov    %eax,%esi
  801d5d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d60:	eb 1a                	jmp    801d7c <memcmp+0x2c>
		if (*s1 != *s2)
  801d62:	0f b6 08             	movzbl (%eax),%ecx
  801d65:	0f b6 1a             	movzbl (%edx),%ebx
  801d68:	38 d9                	cmp    %bl,%cl
  801d6a:	74 0a                	je     801d76 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d6c:	0f b6 c1             	movzbl %cl,%eax
  801d6f:	0f b6 db             	movzbl %bl,%ebx
  801d72:	29 d8                	sub    %ebx,%eax
  801d74:	eb 0f                	jmp    801d85 <memcmp+0x35>
		s1++, s2++;
  801d76:	83 c0 01             	add    $0x1,%eax
  801d79:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7c:	39 f0                	cmp    %esi,%eax
  801d7e:	75 e2                	jne    801d62 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d85:	5b                   	pop    %ebx
  801d86:	5e                   	pop    %esi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	53                   	push   %ebx
  801d8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d90:	89 c1                	mov    %eax,%ecx
  801d92:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d95:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d99:	eb 0a                	jmp    801da5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9b:	0f b6 10             	movzbl (%eax),%edx
  801d9e:	39 da                	cmp    %ebx,%edx
  801da0:	74 07                	je     801da9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da2:	83 c0 01             	add    $0x1,%eax
  801da5:	39 c8                	cmp    %ecx,%eax
  801da7:	72 f2                	jb     801d9b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801da9:	5b                   	pop    %ebx
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    

00801dac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	57                   	push   %edi
  801db0:	56                   	push   %esi
  801db1:	53                   	push   %ebx
  801db2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db8:	eb 03                	jmp    801dbd <strtol+0x11>
		s++;
  801dba:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbd:	0f b6 01             	movzbl (%ecx),%eax
  801dc0:	3c 20                	cmp    $0x20,%al
  801dc2:	74 f6                	je     801dba <strtol+0xe>
  801dc4:	3c 09                	cmp    $0x9,%al
  801dc6:	74 f2                	je     801dba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dc8:	3c 2b                	cmp    $0x2b,%al
  801dca:	75 0a                	jne    801dd6 <strtol+0x2a>
		s++;
  801dcc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dcf:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd4:	eb 11                	jmp    801de7 <strtol+0x3b>
  801dd6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ddb:	3c 2d                	cmp    $0x2d,%al
  801ddd:	75 08                	jne    801de7 <strtol+0x3b>
		s++, neg = 1;
  801ddf:	83 c1 01             	add    $0x1,%ecx
  801de2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ded:	75 15                	jne    801e04 <strtol+0x58>
  801def:	80 39 30             	cmpb   $0x30,(%ecx)
  801df2:	75 10                	jne    801e04 <strtol+0x58>
  801df4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801df8:	75 7c                	jne    801e76 <strtol+0xca>
		s += 2, base = 16;
  801dfa:	83 c1 02             	add    $0x2,%ecx
  801dfd:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e02:	eb 16                	jmp    801e1a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e04:	85 db                	test   %ebx,%ebx
  801e06:	75 12                	jne    801e1a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e08:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e0d:	80 39 30             	cmpb   $0x30,(%ecx)
  801e10:	75 08                	jne    801e1a <strtol+0x6e>
		s++, base = 8;
  801e12:	83 c1 01             	add    $0x1,%ecx
  801e15:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e22:	0f b6 11             	movzbl (%ecx),%edx
  801e25:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e28:	89 f3                	mov    %esi,%ebx
  801e2a:	80 fb 09             	cmp    $0x9,%bl
  801e2d:	77 08                	ja     801e37 <strtol+0x8b>
			dig = *s - '0';
  801e2f:	0f be d2             	movsbl %dl,%edx
  801e32:	83 ea 30             	sub    $0x30,%edx
  801e35:	eb 22                	jmp    801e59 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e37:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e3a:	89 f3                	mov    %esi,%ebx
  801e3c:	80 fb 19             	cmp    $0x19,%bl
  801e3f:	77 08                	ja     801e49 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e41:	0f be d2             	movsbl %dl,%edx
  801e44:	83 ea 57             	sub    $0x57,%edx
  801e47:	eb 10                	jmp    801e59 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e49:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e4c:	89 f3                	mov    %esi,%ebx
  801e4e:	80 fb 19             	cmp    $0x19,%bl
  801e51:	77 16                	ja     801e69 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e53:	0f be d2             	movsbl %dl,%edx
  801e56:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e59:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e5c:	7d 0b                	jge    801e69 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e5e:	83 c1 01             	add    $0x1,%ecx
  801e61:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e65:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e67:	eb b9                	jmp    801e22 <strtol+0x76>

	if (endptr)
  801e69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e6d:	74 0d                	je     801e7c <strtol+0xd0>
		*endptr = (char *) s;
  801e6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e72:	89 0e                	mov    %ecx,(%esi)
  801e74:	eb 06                	jmp    801e7c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e76:	85 db                	test   %ebx,%ebx
  801e78:	74 98                	je     801e12 <strtol+0x66>
  801e7a:	eb 9e                	jmp    801e1a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	f7 da                	neg    %edx
  801e80:	85 ff                	test   %edi,%edi
  801e82:	0f 45 c2             	cmovne %edx,%eax
}
  801e85:	5b                   	pop    %ebx
  801e86:	5e                   	pop    %esi
  801e87:	5f                   	pop    %edi
  801e88:	5d                   	pop    %ebp
  801e89:	c3                   	ret    

00801e8a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	8b 75 08             	mov    0x8(%ebp),%esi
  801e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	74 0e                	je     801eaa <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	50                   	push   %eax
  801ea0:	e8 6a e4 ff ff       	call   80030f <sys_ipc_recv>
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	eb 10                	jmp    801eba <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	68 00 00 00 f0       	push   $0xf0000000
  801eb2:	e8 58 e4 ff ff       	call   80030f <sys_ipc_recv>
  801eb7:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	74 0e                	je     801ecc <ipc_recv+0x42>
    	*from_env_store = 0;
  801ebe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ec4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801eca:	eb 24                	jmp    801ef0 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ecc:	85 f6                	test   %esi,%esi
  801ece:	74 0a                	je     801eda <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ed0:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed5:	8b 40 74             	mov    0x74(%eax),%eax
  801ed8:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801eda:	85 db                	test   %ebx,%ebx
  801edc:	74 0a                	je     801ee8 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801ede:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee3:	8b 40 78             	mov    0x78(%eax),%eax
  801ee6:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801ee8:	a1 08 40 80 00       	mov    0x804008,%eax
  801eed:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801ef0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    

00801ef7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	57                   	push   %edi
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f09:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f10:	0f 44 d8             	cmove  %eax,%ebx
  801f13:	eb 1c                	jmp    801f31 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f15:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f18:	74 12                	je     801f2c <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f1a:	50                   	push   %eax
  801f1b:	68 e0 26 80 00       	push   $0x8026e0
  801f20:	6a 4b                	push   $0x4b
  801f22:	68 f8 26 80 00       	push   $0x8026f8
  801f27:	e8 b9 f5 ff ff       	call   8014e5 <_panic>
        }	
        sys_yield();
  801f2c:	e8 0f e2 ff ff       	call   800140 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f31:	ff 75 14             	pushl  0x14(%ebp)
  801f34:	53                   	push   %ebx
  801f35:	56                   	push   %esi
  801f36:	57                   	push   %edi
  801f37:	e8 b0 e3 ff ff       	call   8002ec <sys_ipc_try_send>
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	75 d2                	jne    801f15 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5f                   	pop    %edi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f51:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f56:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f59:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5f:	8b 52 50             	mov    0x50(%edx),%edx
  801f62:	39 ca                	cmp    %ecx,%edx
  801f64:	75 0d                	jne    801f73 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f66:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6e:	8b 40 48             	mov    0x48(%eax),%eax
  801f71:	eb 0f                	jmp    801f82 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f73:	83 c0 01             	add    $0x1,%eax
  801f76:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7b:	75 d9                	jne    801f56 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8a:	89 d0                	mov    %edx,%eax
  801f8c:	c1 e8 16             	shr    $0x16,%eax
  801f8f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f96:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9b:	f6 c1 01             	test   $0x1,%cl
  801f9e:	74 1d                	je     801fbd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa0:	c1 ea 0c             	shr    $0xc,%edx
  801fa3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801faa:	f6 c2 01             	test   $0x1,%dl
  801fad:	74 0e                	je     801fbd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801faf:	c1 ea 0c             	shr    $0xc,%edx
  801fb2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb9:	ef 
  801fba:	0f b7 c0             	movzwl %ax,%eax
}
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    
  801fbf:	90                   	nop

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
