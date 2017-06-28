
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800049:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800050:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800053:	e8 ce 00 00 00       	call   800126 <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 db                	test   %ebx,%ebx
  80006c:	7e 07                	jle    800075 <libmain+0x37>
		binaryname = argv[0];
  80006e:	8b 06                	mov    (%esi),%eax
  800070:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800075:	83 ec 08             	sub    $0x8,%esp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	e8 b4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007f:	e8 0a 00 00 00       	call   80008e <exit>
}
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008a:	5b                   	pop    %ebx
  80008b:	5e                   	pop    %esi
  80008c:	5d                   	pop    %ebp
  80008d:	c3                   	ret    

0080008e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008e:	55                   	push   %ebp
  80008f:	89 e5                	mov    %esp,%ebp
  800091:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800094:	e8 c7 04 00 00       	call   800560 <close_all>
	sys_env_destroy(0);
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	6a 00                	push   $0x0
  80009e:	e8 42 00 00 00       	call   8000e5 <sys_env_destroy>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	89 cb                	mov    %ecx,%ebx
  8000fd:	89 cf                	mov    %ecx,%edi
  8000ff:	89 ce                	mov    %ecx,%esi
  800101:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7e 17                	jle    80011e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	50                   	push   %eax
  80010b:	6a 03                	push   $0x3
  80010d:	68 6a 22 80 00       	push   $0x80226a
  800112:	6a 23                	push   $0x23
  800114:	68 87 22 80 00       	push   $0x802287
  800119:	e8 cc 13 00 00       	call   8014ea <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5f                   	pop    %edi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	57                   	push   %edi
  80012a:	56                   	push   %esi
  80012b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012c:	ba 00 00 00 00       	mov    $0x0,%edx
  800131:	b8 02 00 00 00       	mov    $0x2,%eax
  800136:	89 d1                	mov    %edx,%ecx
  800138:	89 d3                	mov    %edx,%ebx
  80013a:	89 d7                	mov    %edx,%edi
  80013c:	89 d6                	mov    %edx,%esi
  80013e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5f                   	pop    %edi
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    

00800145 <sys_yield>:

void
sys_yield(void)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	57                   	push   %edi
  800149:	56                   	push   %esi
  80014a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014b:	ba 00 00 00 00       	mov    $0x0,%edx
  800150:	b8 0b 00 00 00       	mov    $0xb,%eax
  800155:	89 d1                	mov    %edx,%ecx
  800157:	89 d3                	mov    %edx,%ebx
  800159:	89 d7                	mov    %edx,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	57                   	push   %edi
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016d:	be 00 00 00 00       	mov    $0x0,%esi
  800172:	b8 04 00 00 00       	mov    $0x4,%eax
  800177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017a:	8b 55 08             	mov    0x8(%ebp),%edx
  80017d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800180:	89 f7                	mov    %esi,%edi
  800182:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	7e 17                	jle    80019f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	6a 04                	push   $0x4
  80018e:	68 6a 22 80 00       	push   $0x80226a
  800193:	6a 23                	push   $0x23
  800195:	68 87 22 80 00       	push   $0x802287
  80019a:	e8 4b 13 00 00       	call   8014ea <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a2:	5b                   	pop    %ebx
  8001a3:	5e                   	pop    %esi
  8001a4:	5f                   	pop    %edi
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	7e 17                	jle    8001e1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	50                   	push   %eax
  8001ce:	6a 05                	push   $0x5
  8001d0:	68 6a 22 80 00       	push   $0x80226a
  8001d5:	6a 23                	push   $0x23
  8001d7:	68 87 22 80 00       	push   $0x802287
  8001dc:	e8 09 13 00 00       	call   8014ea <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5f                   	pop    %edi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	89 df                	mov    %ebx,%edi
  800204:	89 de                	mov    %ebx,%esi
  800206:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800208:	85 c0                	test   %eax,%eax
  80020a:	7e 17                	jle    800223 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	6a 06                	push   $0x6
  800212:	68 6a 22 80 00       	push   $0x80226a
  800217:	6a 23                	push   $0x23
  800219:	68 87 22 80 00       	push   $0x802287
  80021e:	e8 c7 12 00 00       	call   8014ea <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5f                   	pop    %edi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800234:	bb 00 00 00 00       	mov    $0x0,%ebx
  800239:	b8 08 00 00 00       	mov    $0x8,%eax
  80023e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800241:	8b 55 08             	mov    0x8(%ebp),%edx
  800244:	89 df                	mov    %ebx,%edi
  800246:	89 de                	mov    %ebx,%esi
  800248:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024a:	85 c0                	test   %eax,%eax
  80024c:	7e 17                	jle    800265 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	50                   	push   %eax
  800252:	6a 08                	push   $0x8
  800254:	68 6a 22 80 00       	push   $0x80226a
  800259:	6a 23                	push   $0x23
  80025b:	68 87 22 80 00       	push   $0x802287
  800260:	e8 85 12 00 00       	call   8014ea <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800268:	5b                   	pop    %ebx
  800269:	5e                   	pop    %esi
  80026a:	5f                   	pop    %edi
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	57                   	push   %edi
  800271:	56                   	push   %esi
  800272:	53                   	push   %ebx
  800273:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800276:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027b:	b8 09 00 00 00       	mov    $0x9,%eax
  800280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  800286:	89 df                	mov    %ebx,%edi
  800288:	89 de                	mov    %ebx,%esi
  80028a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028c:	85 c0                	test   %eax,%eax
  80028e:	7e 17                	jle    8002a7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800290:	83 ec 0c             	sub    $0xc,%esp
  800293:	50                   	push   %eax
  800294:	6a 09                	push   $0x9
  800296:	68 6a 22 80 00       	push   $0x80226a
  80029b:	6a 23                	push   $0x23
  80029d:	68 87 22 80 00       	push   $0x802287
  8002a2:	e8 43 12 00 00       	call   8014ea <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 17                	jle    8002e9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	50                   	push   %eax
  8002d6:	6a 0a                	push   $0xa
  8002d8:	68 6a 22 80 00       	push   $0x80226a
  8002dd:	6a 23                	push   $0x23
  8002df:	68 87 22 80 00       	push   $0x802287
  8002e4:	e8 01 12 00 00       	call   8014ea <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	57                   	push   %edi
  8002f5:	56                   	push   %esi
  8002f6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f7:	be 00 00 00 00       	mov    $0x0,%esi
  8002fc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800322:	b8 0d 00 00 00       	mov    $0xd,%eax
  800327:	8b 55 08             	mov    0x8(%ebp),%edx
  80032a:	89 cb                	mov    %ecx,%ebx
  80032c:	89 cf                	mov    %ecx,%edi
  80032e:	89 ce                	mov    %ecx,%esi
  800330:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800332:	85 c0                	test   %eax,%eax
  800334:	7e 17                	jle    80034d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800336:	83 ec 0c             	sub    $0xc,%esp
  800339:	50                   	push   %eax
  80033a:	6a 0d                	push   $0xd
  80033c:	68 6a 22 80 00       	push   $0x80226a
  800341:	6a 23                	push   $0x23
  800343:	68 87 22 80 00       	push   $0x802287
  800348:	e8 9d 11 00 00       	call   8014ea <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035b:	ba 00 00 00 00       	mov    $0x0,%edx
  800360:	b8 0e 00 00 00       	mov    $0xe,%eax
  800365:	89 d1                	mov    %edx,%ecx
  800367:	89 d3                	mov    %edx,%ebx
  800369:	89 d7                	mov    %edx,%edi
  80036b:	89 d6                	mov    %edx,%esi
  80036d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	57                   	push   %edi
  800378:	56                   	push   %esi
  800379:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800384:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800387:	8b 55 08             	mov    0x8(%ebp),%edx
  80038a:	89 df                	mov    %ebx,%edi
  80038c:	89 de                	mov    %ebx,%esi
  80038e:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a0:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ab:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c7:	89 c2                	mov    %eax,%edx
  8003c9:	c1 ea 16             	shr    $0x16,%edx
  8003cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d3:	f6 c2 01             	test   $0x1,%dl
  8003d6:	74 11                	je     8003e9 <fd_alloc+0x2d>
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 0c             	shr    $0xc,%edx
  8003dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	75 09                	jne    8003f2 <fd_alloc+0x36>
			*fd_store = fd;
  8003e9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f0:	eb 17                	jmp    800409 <fd_alloc+0x4d>
  8003f2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003fc:	75 c9                	jne    8003c7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800404:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800411:	83 f8 1f             	cmp    $0x1f,%eax
  800414:	77 36                	ja     80044c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800416:	c1 e0 0c             	shl    $0xc,%eax
  800419:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041e:	89 c2                	mov    %eax,%edx
  800420:	c1 ea 16             	shr    $0x16,%edx
  800423:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042a:	f6 c2 01             	test   $0x1,%dl
  80042d:	74 24                	je     800453 <fd_lookup+0x48>
  80042f:	89 c2                	mov    %eax,%edx
  800431:	c1 ea 0c             	shr    $0xc,%edx
  800434:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043b:	f6 c2 01             	test   $0x1,%dl
  80043e:	74 1a                	je     80045a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800440:	8b 55 0c             	mov    0xc(%ebp),%edx
  800443:	89 02                	mov    %eax,(%edx)
	return 0;
  800445:	b8 00 00 00 00       	mov    $0x0,%eax
  80044a:	eb 13                	jmp    80045f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800451:	eb 0c                	jmp    80045f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800458:	eb 05                	jmp    80045f <fd_lookup+0x54>
  80045a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045f:	5d                   	pop    %ebp
  800460:	c3                   	ret    

00800461 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80046a:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046f:	eb 13                	jmp    800484 <dev_lookup+0x23>
  800471:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800474:	39 08                	cmp    %ecx,(%eax)
  800476:	75 0c                	jne    800484 <dev_lookup+0x23>
			*dev = devtab[i];
  800478:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80047b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	eb 2e                	jmp    8004b2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800484:	8b 02                	mov    (%edx),%eax
  800486:	85 c0                	test   %eax,%eax
  800488:	75 e7                	jne    800471 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048a:	a1 08 40 80 00       	mov    0x804008,%eax
  80048f:	8b 40 48             	mov    0x48(%eax),%eax
  800492:	83 ec 04             	sub    $0x4,%esp
  800495:	51                   	push   %ecx
  800496:	50                   	push   %eax
  800497:	68 98 22 80 00       	push   $0x802298
  80049c:	e8 22 11 00 00       	call   8015c3 <cprintf>
	*dev = 0;
  8004a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b2:	c9                   	leave  
  8004b3:	c3                   	ret    

008004b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
  8004b9:	83 ec 10             	sub    $0x10,%esp
  8004bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c5:	50                   	push   %eax
  8004c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004cc:	c1 e8 0c             	shr    $0xc,%eax
  8004cf:	50                   	push   %eax
  8004d0:	e8 36 ff ff ff       	call   80040b <fd_lookup>
  8004d5:	83 c4 08             	add    $0x8,%esp
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	78 05                	js     8004e1 <fd_close+0x2d>
	    || fd != fd2)
  8004dc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004df:	74 0c                	je     8004ed <fd_close+0x39>
		return (must_exist ? r : 0);
  8004e1:	84 db                	test   %bl,%bl
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	0f 44 c2             	cmove  %edx,%eax
  8004eb:	eb 41                	jmp    80052e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f3:	50                   	push   %eax
  8004f4:	ff 36                	pushl  (%esi)
  8004f6:	e8 66 ff ff ff       	call   800461 <dev_lookup>
  8004fb:	89 c3                	mov    %eax,%ebx
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 1a                	js     80051e <fd_close+0x6a>
		if (dev->dev_close)
  800504:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800507:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80050a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050f:	85 c0                	test   %eax,%eax
  800511:	74 0b                	je     80051e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800513:	83 ec 0c             	sub    $0xc,%esp
  800516:	56                   	push   %esi
  800517:	ff d0                	call   *%eax
  800519:	89 c3                	mov    %eax,%ebx
  80051b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	56                   	push   %esi
  800522:	6a 00                	push   $0x0
  800524:	e8 c0 fc ff ff       	call   8001e9 <sys_page_unmap>
	return r;
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	89 d8                	mov    %ebx,%eax
}
  80052e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800531:	5b                   	pop    %ebx
  800532:	5e                   	pop    %esi
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    

00800535 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80053b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053e:	50                   	push   %eax
  80053f:	ff 75 08             	pushl  0x8(%ebp)
  800542:	e8 c4 fe ff ff       	call   80040b <fd_lookup>
  800547:	83 c4 08             	add    $0x8,%esp
  80054a:	85 c0                	test   %eax,%eax
  80054c:	78 10                	js     80055e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	6a 01                	push   $0x1
  800553:	ff 75 f4             	pushl  -0xc(%ebp)
  800556:	e8 59 ff ff ff       	call   8004b4 <fd_close>
  80055b:	83 c4 10             	add    $0x10,%esp
}
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <close_all>:

void
close_all(void)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	53                   	push   %ebx
  800564:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800567:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056c:	83 ec 0c             	sub    $0xc,%esp
  80056f:	53                   	push   %ebx
  800570:	e8 c0 ff ff ff       	call   800535 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800575:	83 c3 01             	add    $0x1,%ebx
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	83 fb 20             	cmp    $0x20,%ebx
  80057e:	75 ec                	jne    80056c <close_all+0xc>
		close(i);
}
  800580:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800583:	c9                   	leave  
  800584:	c3                   	ret    

00800585 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800585:	55                   	push   %ebp
  800586:	89 e5                	mov    %esp,%ebp
  800588:	57                   	push   %edi
  800589:	56                   	push   %esi
  80058a:	53                   	push   %ebx
  80058b:	83 ec 2c             	sub    $0x2c,%esp
  80058e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800591:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800594:	50                   	push   %eax
  800595:	ff 75 08             	pushl  0x8(%ebp)
  800598:	e8 6e fe ff ff       	call   80040b <fd_lookup>
  80059d:	83 c4 08             	add    $0x8,%esp
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	0f 88 c1 00 00 00    	js     800669 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a8:	83 ec 0c             	sub    $0xc,%esp
  8005ab:	56                   	push   %esi
  8005ac:	e8 84 ff ff ff       	call   800535 <close>

	newfd = INDEX2FD(newfdnum);
  8005b1:	89 f3                	mov    %esi,%ebx
  8005b3:	c1 e3 0c             	shl    $0xc,%ebx
  8005b6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005bc:	83 c4 04             	add    $0x4,%esp
  8005bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c2:	e8 de fd ff ff       	call   8003a5 <fd2data>
  8005c7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c9:	89 1c 24             	mov    %ebx,(%esp)
  8005cc:	e8 d4 fd ff ff       	call   8003a5 <fd2data>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d7:	89 f8                	mov    %edi,%eax
  8005d9:	c1 e8 16             	shr    $0x16,%eax
  8005dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e3:	a8 01                	test   $0x1,%al
  8005e5:	74 37                	je     80061e <dup+0x99>
  8005e7:	89 f8                	mov    %edi,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f3:	f6 c2 01             	test   $0x1,%dl
  8005f6:	74 26                	je     80061e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	25 07 0e 00 00       	and    $0xe07,%eax
  800607:	50                   	push   %eax
  800608:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060b:	6a 00                	push   $0x0
  80060d:	57                   	push   %edi
  80060e:	6a 00                	push   $0x0
  800610:	e8 92 fb ff ff       	call   8001a7 <sys_page_map>
  800615:	89 c7                	mov    %eax,%edi
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	85 c0                	test   %eax,%eax
  80061c:	78 2e                	js     80064c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800621:	89 d0                	mov    %edx,%eax
  800623:	c1 e8 0c             	shr    $0xc,%eax
  800626:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	25 07 0e 00 00       	and    $0xe07,%eax
  800635:	50                   	push   %eax
  800636:	53                   	push   %ebx
  800637:	6a 00                	push   $0x0
  800639:	52                   	push   %edx
  80063a:	6a 00                	push   $0x0
  80063c:	e8 66 fb ff ff       	call   8001a7 <sys_page_map>
  800641:	89 c7                	mov    %eax,%edi
  800643:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800646:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800648:	85 ff                	test   %edi,%edi
  80064a:	79 1d                	jns    800669 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 00                	push   $0x0
  800652:	e8 92 fb ff ff       	call   8001e9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065d:	6a 00                	push   $0x0
  80065f:	e8 85 fb ff ff       	call   8001e9 <sys_page_unmap>
	return r;
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	89 f8                	mov    %edi,%eax
}
  800669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5e                   	pop    %esi
  80066e:	5f                   	pop    %edi
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	53                   	push   %ebx
  800675:	83 ec 14             	sub    $0x14,%esp
  800678:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067e:	50                   	push   %eax
  80067f:	53                   	push   %ebx
  800680:	e8 86 fd ff ff       	call   80040b <fd_lookup>
  800685:	83 c4 08             	add    $0x8,%esp
  800688:	89 c2                	mov    %eax,%edx
  80068a:	85 c0                	test   %eax,%eax
  80068c:	78 6d                	js     8006fb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800694:	50                   	push   %eax
  800695:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800698:	ff 30                	pushl  (%eax)
  80069a:	e8 c2 fd ff ff       	call   800461 <dev_lookup>
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	78 4c                	js     8006f2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a9:	8b 42 08             	mov    0x8(%edx),%eax
  8006ac:	83 e0 03             	and    $0x3,%eax
  8006af:	83 f8 01             	cmp    $0x1,%eax
  8006b2:	75 21                	jne    8006d5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b4:	a1 08 40 80 00       	mov    0x804008,%eax
  8006b9:	8b 40 48             	mov    0x48(%eax),%eax
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	50                   	push   %eax
  8006c1:	68 d9 22 80 00       	push   $0x8022d9
  8006c6:	e8 f8 0e 00 00       	call   8015c3 <cprintf>
		return -E_INVAL;
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d3:	eb 26                	jmp    8006fb <read+0x8a>
	}
	if (!dev->dev_read)
  8006d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d8:	8b 40 08             	mov    0x8(%eax),%eax
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	74 17                	je     8006f6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006df:	83 ec 04             	sub    $0x4,%esp
  8006e2:	ff 75 10             	pushl  0x10(%ebp)
  8006e5:	ff 75 0c             	pushl  0xc(%ebp)
  8006e8:	52                   	push   %edx
  8006e9:	ff d0                	call   *%eax
  8006eb:	89 c2                	mov    %eax,%edx
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	eb 09                	jmp    8006fb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f2:	89 c2                	mov    %eax,%edx
  8006f4:	eb 05                	jmp    8006fb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006fb:	89 d0                	mov    %edx,%eax
  8006fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	57                   	push   %edi
  800706:	56                   	push   %esi
  800707:	53                   	push   %ebx
  800708:	83 ec 0c             	sub    $0xc,%esp
  80070b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800711:	bb 00 00 00 00       	mov    $0x0,%ebx
  800716:	eb 21                	jmp    800739 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800718:	83 ec 04             	sub    $0x4,%esp
  80071b:	89 f0                	mov    %esi,%eax
  80071d:	29 d8                	sub    %ebx,%eax
  80071f:	50                   	push   %eax
  800720:	89 d8                	mov    %ebx,%eax
  800722:	03 45 0c             	add    0xc(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	57                   	push   %edi
  800727:	e8 45 ff ff ff       	call   800671 <read>
		if (m < 0)
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	85 c0                	test   %eax,%eax
  800731:	78 10                	js     800743 <readn+0x41>
			return m;
		if (m == 0)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 0a                	je     800741 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800737:	01 c3                	add    %eax,%ebx
  800739:	39 f3                	cmp    %esi,%ebx
  80073b:	72 db                	jb     800718 <readn+0x16>
  80073d:	89 d8                	mov    %ebx,%eax
  80073f:	eb 02                	jmp    800743 <readn+0x41>
  800741:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800743:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800746:	5b                   	pop    %ebx
  800747:	5e                   	pop    %esi
  800748:	5f                   	pop    %edi
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	53                   	push   %ebx
  80074f:	83 ec 14             	sub    $0x14,%esp
  800752:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800755:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	53                   	push   %ebx
  80075a:	e8 ac fc ff ff       	call   80040b <fd_lookup>
  80075f:	83 c4 08             	add    $0x8,%esp
  800762:	89 c2                	mov    %eax,%edx
  800764:	85 c0                	test   %eax,%eax
  800766:	78 68                	js     8007d0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076e:	50                   	push   %eax
  80076f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800772:	ff 30                	pushl  (%eax)
  800774:	e8 e8 fc ff ff       	call   800461 <dev_lookup>
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	85 c0                	test   %eax,%eax
  80077e:	78 47                	js     8007c7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800780:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800783:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800787:	75 21                	jne    8007aa <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800789:	a1 08 40 80 00       	mov    0x804008,%eax
  80078e:	8b 40 48             	mov    0x48(%eax),%eax
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	53                   	push   %ebx
  800795:	50                   	push   %eax
  800796:	68 f5 22 80 00       	push   $0x8022f5
  80079b:	e8 23 0e 00 00       	call   8015c3 <cprintf>
		return -E_INVAL;
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a8:	eb 26                	jmp    8007d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	74 17                	je     8007cb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b4:	83 ec 04             	sub    $0x4,%esp
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	50                   	push   %eax
  8007be:	ff d2                	call   *%edx
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	eb 09                	jmp    8007d0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	eb 05                	jmp    8007d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007d0:	89 d0                	mov    %edx,%eax
  8007d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007dd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 08             	pushl  0x8(%ebp)
  8007e4:	e8 22 fc ff ff       	call   80040b <fd_lookup>
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	78 0e                	js     8007fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	83 ec 14             	sub    $0x14,%esp
  800807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080d:	50                   	push   %eax
  80080e:	53                   	push   %ebx
  80080f:	e8 f7 fb ff ff       	call   80040b <fd_lookup>
  800814:	83 c4 08             	add    $0x8,%esp
  800817:	89 c2                	mov    %eax,%edx
  800819:	85 c0                	test   %eax,%eax
  80081b:	78 65                	js     800882 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800823:	50                   	push   %eax
  800824:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800827:	ff 30                	pushl  (%eax)
  800829:	e8 33 fc ff ff       	call   800461 <dev_lookup>
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	85 c0                	test   %eax,%eax
  800833:	78 44                	js     800879 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800835:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800838:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80083c:	75 21                	jne    80085f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800843:	8b 40 48             	mov    0x48(%eax),%eax
  800846:	83 ec 04             	sub    $0x4,%esp
  800849:	53                   	push   %ebx
  80084a:	50                   	push   %eax
  80084b:	68 b8 22 80 00       	push   $0x8022b8
  800850:	e8 6e 0d 00 00       	call   8015c3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80085d:	eb 23                	jmp    800882 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800862:	8b 52 18             	mov    0x18(%edx),%edx
  800865:	85 d2                	test   %edx,%edx
  800867:	74 14                	je     80087d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	ff 75 0c             	pushl  0xc(%ebp)
  80086f:	50                   	push   %eax
  800870:	ff d2                	call   *%edx
  800872:	89 c2                	mov    %eax,%edx
  800874:	83 c4 10             	add    $0x10,%esp
  800877:	eb 09                	jmp    800882 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800879:	89 c2                	mov    %eax,%edx
  80087b:	eb 05                	jmp    800882 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80087d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800882:	89 d0                	mov    %edx,%eax
  800884:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	83 ec 14             	sub    $0x14,%esp
  800890:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800893:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800896:	50                   	push   %eax
  800897:	ff 75 08             	pushl  0x8(%ebp)
  80089a:	e8 6c fb ff ff       	call   80040b <fd_lookup>
  80089f:	83 c4 08             	add    $0x8,%esp
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	78 58                	js     800900 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ae:	50                   	push   %eax
  8008af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b2:	ff 30                	pushl  (%eax)
  8008b4:	e8 a8 fb ff ff       	call   800461 <dev_lookup>
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	78 37                	js     8008f7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c7:	74 32                	je     8008fb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008cc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d3:	00 00 00 
	stat->st_isdir = 0;
  8008d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008dd:	00 00 00 
	stat->st_dev = dev;
  8008e0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e6:	83 ec 08             	sub    $0x8,%esp
  8008e9:	53                   	push   %ebx
  8008ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ed:	ff 50 14             	call   *0x14(%eax)
  8008f0:	89 c2                	mov    %eax,%edx
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	eb 09                	jmp    800900 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f7:	89 c2                	mov    %eax,%edx
  8008f9:	eb 05                	jmp    800900 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800900:	89 d0                	mov    %edx,%eax
  800902:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	6a 00                	push   $0x0
  800911:	ff 75 08             	pushl  0x8(%ebp)
  800914:	e8 e7 01 00 00       	call   800b00 <open>
  800919:	89 c3                	mov    %eax,%ebx
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	85 c0                	test   %eax,%eax
  800920:	78 1b                	js     80093d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800922:	83 ec 08             	sub    $0x8,%esp
  800925:	ff 75 0c             	pushl  0xc(%ebp)
  800928:	50                   	push   %eax
  800929:	e8 5b ff ff ff       	call   800889 <fstat>
  80092e:	89 c6                	mov    %eax,%esi
	close(fd);
  800930:	89 1c 24             	mov    %ebx,(%esp)
  800933:	e8 fd fb ff ff       	call   800535 <close>
	return r;
  800938:	83 c4 10             	add    $0x10,%esp
  80093b:	89 f0                	mov    %esi,%eax
}
  80093d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	89 c6                	mov    %eax,%esi
  80094b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80094d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800954:	75 12                	jne    800968 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800956:	83 ec 0c             	sub    $0xc,%esp
  800959:	6a 01                	push   $0x1
  80095b:	e8 f0 15 00 00       	call   801f50 <ipc_find_env>
  800960:	a3 00 40 80 00       	mov    %eax,0x804000
  800965:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800968:	6a 07                	push   $0x7
  80096a:	68 00 50 80 00       	push   $0x805000
  80096f:	56                   	push   %esi
  800970:	ff 35 00 40 80 00    	pushl  0x804000
  800976:	e8 81 15 00 00       	call   801efc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80097b:	83 c4 0c             	add    $0xc,%esp
  80097e:	6a 00                	push   $0x0
  800980:	53                   	push   %ebx
  800981:	6a 00                	push   $0x0
  800983:	e8 07 15 00 00       	call   801e8f <ipc_recv>
}
  800988:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 40 0c             	mov    0xc(%eax),%eax
  80099b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ad:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b2:	e8 8d ff ff ff       	call   800944 <fsipc>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d4:	e8 6b ff ff ff       	call   800944 <fsipc>
}
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	83 ec 04             	sub    $0x4,%esp
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009eb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009fa:	e8 45 ff ff ff       	call   800944 <fsipc>
  8009ff:	85 c0                	test   %eax,%eax
  800a01:	78 2c                	js     800a2f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a03:	83 ec 08             	sub    $0x8,%esp
  800a06:	68 00 50 80 00       	push   $0x805000
  800a0b:	53                   	push   %ebx
  800a0c:	e8 37 11 00 00       	call   801b48 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a11:	a1 80 50 80 00       	mov    0x805080,%eax
  800a16:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a1c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a21:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a27:	83 c4 10             	add    $0x10,%esp
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	53                   	push   %ebx
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a3e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a43:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a48:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4b:	53                   	push   %ebx
  800a4c:	ff 75 0c             	pushl  0xc(%ebp)
  800a4f:	68 08 50 80 00       	push   $0x805008
  800a54:	e8 81 12 00 00       	call   801cda <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5f:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a64:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800a6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a74:	e8 cb fe ff ff       	call   800944 <fsipc>
	//panic("devfile_write not implemented");
}
  800a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a91:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9c:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa1:	e8 9e fe ff ff       	call   800944 <fsipc>
  800aa6:	89 c3                	mov    %eax,%ebx
  800aa8:	85 c0                	test   %eax,%eax
  800aaa:	78 4b                	js     800af7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aac:	39 c6                	cmp    %eax,%esi
  800aae:	73 16                	jae    800ac6 <devfile_read+0x48>
  800ab0:	68 28 23 80 00       	push   $0x802328
  800ab5:	68 2f 23 80 00       	push   $0x80232f
  800aba:	6a 7c                	push   $0x7c
  800abc:	68 44 23 80 00       	push   $0x802344
  800ac1:	e8 24 0a 00 00       	call   8014ea <_panic>
	assert(r <= PGSIZE);
  800ac6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acb:	7e 16                	jle    800ae3 <devfile_read+0x65>
  800acd:	68 4f 23 80 00       	push   $0x80234f
  800ad2:	68 2f 23 80 00       	push   $0x80232f
  800ad7:	6a 7d                	push   $0x7d
  800ad9:	68 44 23 80 00       	push   $0x802344
  800ade:	e8 07 0a 00 00       	call   8014ea <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae3:	83 ec 04             	sub    $0x4,%esp
  800ae6:	50                   	push   %eax
  800ae7:	68 00 50 80 00       	push   $0x805000
  800aec:	ff 75 0c             	pushl  0xc(%ebp)
  800aef:	e8 e6 11 00 00       	call   801cda <memmove>
	return r;
  800af4:	83 c4 10             	add    $0x10,%esp
}
  800af7:	89 d8                	mov    %ebx,%eax
  800af9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	53                   	push   %ebx
  800b04:	83 ec 20             	sub    $0x20,%esp
  800b07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0a:	53                   	push   %ebx
  800b0b:	e8 ff 0f 00 00       	call   801b0f <strlen>
  800b10:	83 c4 10             	add    $0x10,%esp
  800b13:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b18:	7f 67                	jg     800b81 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b20:	50                   	push   %eax
  800b21:	e8 96 f8 ff ff       	call   8003bc <fd_alloc>
  800b26:	83 c4 10             	add    $0x10,%esp
		return r;
  800b29:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	78 57                	js     800b86 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	53                   	push   %ebx
  800b33:	68 00 50 80 00       	push   $0x805000
  800b38:	e8 0b 10 00 00       	call   801b48 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b40:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	e8 f2 fd ff ff       	call   800944 <fsipc>
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	85 c0                	test   %eax,%eax
  800b59:	79 14                	jns    800b6f <open+0x6f>
		fd_close(fd, 0);
  800b5b:	83 ec 08             	sub    $0x8,%esp
  800b5e:	6a 00                	push   $0x0
  800b60:	ff 75 f4             	pushl  -0xc(%ebp)
  800b63:	e8 4c f9 ff ff       	call   8004b4 <fd_close>
		return r;
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	89 da                	mov    %ebx,%edx
  800b6d:	eb 17                	jmp    800b86 <open+0x86>
	}

	return fd2num(fd);
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	ff 75 f4             	pushl  -0xc(%ebp)
  800b75:	e8 1b f8 ff ff       	call   800395 <fd2num>
  800b7a:	89 c2                	mov    %eax,%edx
  800b7c:	83 c4 10             	add    $0x10,%esp
  800b7f:	eb 05                	jmp    800b86 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b81:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b86:	89 d0                	mov    %edx,%eax
  800b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9d:	e8 a2 fd ff ff       	call   800944 <fsipc>
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800baa:	68 5b 23 80 00       	push   $0x80235b
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	e8 91 0f 00 00       	call   801b48 <strcpy>
	return 0;
}
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 10             	sub    $0x10,%esp
  800bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc8:	53                   	push   %ebx
  800bc9:	e8 bb 13 00 00       	call   801f89 <pageref>
  800bce:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd6:	83 f8 01             	cmp    $0x1,%eax
  800bd9:	75 10                	jne    800beb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	ff 73 0c             	pushl  0xc(%ebx)
  800be1:	e8 c0 02 00 00       	call   800ea6 <nsipc_close>
  800be6:	89 c2                	mov    %eax,%edx
  800be8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800beb:	89 d0                	mov    %edx,%eax
  800bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf8:	6a 00                	push   $0x0
  800bfa:	ff 75 10             	pushl  0x10(%ebp)
  800bfd:	ff 75 0c             	pushl  0xc(%ebp)
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	ff 70 0c             	pushl  0xc(%eax)
  800c06:	e8 78 03 00 00       	call   800f83 <nsipc_send>
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c13:	6a 00                	push   $0x0
  800c15:	ff 75 10             	pushl  0x10(%ebp)
  800c18:	ff 75 0c             	pushl  0xc(%ebp)
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	ff 70 0c             	pushl  0xc(%eax)
  800c21:	e8 f1 02 00 00       	call   800f17 <nsipc_recv>
}
  800c26:	c9                   	leave  
  800c27:	c3                   	ret    

00800c28 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c31:	52                   	push   %edx
  800c32:	50                   	push   %eax
  800c33:	e8 d3 f7 ff ff       	call   80040b <fd_lookup>
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	78 17                	js     800c56 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c42:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c48:	39 08                	cmp    %ecx,(%eax)
  800c4a:	75 05                	jne    800c51 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c4c:	8b 40 0c             	mov    0xc(%eax),%eax
  800c4f:	eb 05                	jmp    800c56 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c51:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c56:	c9                   	leave  
  800c57:	c3                   	ret    

00800c58 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 1c             	sub    $0x1c,%esp
  800c60:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c65:	50                   	push   %eax
  800c66:	e8 51 f7 ff ff       	call   8003bc <fd_alloc>
  800c6b:	89 c3                	mov    %eax,%ebx
  800c6d:	83 c4 10             	add    $0x10,%esp
  800c70:	85 c0                	test   %eax,%eax
  800c72:	78 1b                	js     800c8f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c74:	83 ec 04             	sub    $0x4,%esp
  800c77:	68 07 04 00 00       	push   $0x407
  800c7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800c7f:	6a 00                	push   $0x0
  800c81:	e8 de f4 ff ff       	call   800164 <sys_page_alloc>
  800c86:	89 c3                	mov    %eax,%ebx
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	79 10                	jns    800c9f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	56                   	push   %esi
  800c93:	e8 0e 02 00 00       	call   800ea6 <nsipc_close>
		return r;
  800c98:	83 c4 10             	add    $0x10,%esp
  800c9b:	89 d8                	mov    %ebx,%eax
  800c9d:	eb 24                	jmp    800cc3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cad:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	e8 d5 f6 ff ff       	call   800395 <fd2num>
  800cc0:	83 c4 10             	add    $0x10,%esp
}
  800cc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	e8 50 ff ff ff       	call   800c28 <fd2sockid>
		return r;
  800cd8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	78 1f                	js     800cfd <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cde:	83 ec 04             	sub    $0x4,%esp
  800ce1:	ff 75 10             	pushl  0x10(%ebp)
  800ce4:	ff 75 0c             	pushl  0xc(%ebp)
  800ce7:	50                   	push   %eax
  800ce8:	e8 12 01 00 00       	call   800dff <nsipc_accept>
  800ced:	83 c4 10             	add    $0x10,%esp
		return r;
  800cf0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	78 07                	js     800cfd <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf6:	e8 5d ff ff ff       	call   800c58 <alloc_sockfd>
  800cfb:	89 c1                	mov    %eax,%ecx
}
  800cfd:	89 c8                	mov    %ecx,%eax
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	e8 19 ff ff ff       	call   800c28 <fd2sockid>
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	78 12                	js     800d25 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d13:	83 ec 04             	sub    $0x4,%esp
  800d16:	ff 75 10             	pushl  0x10(%ebp)
  800d19:	ff 75 0c             	pushl  0xc(%ebp)
  800d1c:	50                   	push   %eax
  800d1d:	e8 2d 01 00 00       	call   800e4f <nsipc_bind>
  800d22:	83 c4 10             	add    $0x10,%esp
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <shutdown>:

int
shutdown(int s, int how)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	e8 f3 fe ff ff       	call   800c28 <fd2sockid>
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 0f                	js     800d48 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d39:	83 ec 08             	sub    $0x8,%esp
  800d3c:	ff 75 0c             	pushl  0xc(%ebp)
  800d3f:	50                   	push   %eax
  800d40:	e8 3f 01 00 00       	call   800e84 <nsipc_shutdown>
  800d45:	83 c4 10             	add    $0x10,%esp
}
  800d48:	c9                   	leave  
  800d49:	c3                   	ret    

00800d4a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	e8 d0 fe ff ff       	call   800c28 <fd2sockid>
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	78 12                	js     800d6e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d5c:	83 ec 04             	sub    $0x4,%esp
  800d5f:	ff 75 10             	pushl  0x10(%ebp)
  800d62:	ff 75 0c             	pushl  0xc(%ebp)
  800d65:	50                   	push   %eax
  800d66:	e8 55 01 00 00       	call   800ec0 <nsipc_connect>
  800d6b:	83 c4 10             	add    $0x10,%esp
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <listen>:

int
listen(int s, int backlog)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	e8 aa fe ff ff       	call   800c28 <fd2sockid>
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	78 0f                	js     800d91 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d82:	83 ec 08             	sub    $0x8,%esp
  800d85:	ff 75 0c             	pushl  0xc(%ebp)
  800d88:	50                   	push   %eax
  800d89:	e8 67 01 00 00       	call   800ef5 <nsipc_listen>
  800d8e:	83 c4 10             	add    $0x10,%esp
}
  800d91:	c9                   	leave  
  800d92:	c3                   	ret    

00800d93 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d99:	ff 75 10             	pushl  0x10(%ebp)
  800d9c:	ff 75 0c             	pushl  0xc(%ebp)
  800d9f:	ff 75 08             	pushl  0x8(%ebp)
  800da2:	e8 3a 02 00 00       	call   800fe1 <nsipc_socket>
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	85 c0                	test   %eax,%eax
  800dac:	78 05                	js     800db3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dae:	e8 a5 fe ff ff       	call   800c58 <alloc_sockfd>
}
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    

00800db5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	53                   	push   %ebx
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dbe:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc5:	75 12                	jne    800dd9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	6a 02                	push   $0x2
  800dcc:	e8 7f 11 00 00       	call   801f50 <ipc_find_env>
  800dd1:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd9:	6a 07                	push   $0x7
  800ddb:	68 00 60 80 00       	push   $0x806000
  800de0:	53                   	push   %ebx
  800de1:	ff 35 04 40 80 00    	pushl  0x804004
  800de7:	e8 10 11 00 00       	call   801efc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dec:	83 c4 0c             	add    $0xc,%esp
  800def:	6a 00                	push   $0x0
  800df1:	6a 00                	push   $0x0
  800df3:	6a 00                	push   $0x0
  800df5:	e8 95 10 00 00       	call   801e8f <ipc_recv>
}
  800dfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfd:	c9                   	leave  
  800dfe:	c3                   	ret    

00800dff <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0f:	8b 06                	mov    (%esi),%eax
  800e11:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e16:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1b:	e8 95 ff ff ff       	call   800db5 <nsipc>
  800e20:	89 c3                	mov    %eax,%ebx
  800e22:	85 c0                	test   %eax,%eax
  800e24:	78 20                	js     800e46 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	ff 35 10 60 80 00    	pushl  0x806010
  800e2f:	68 00 60 80 00       	push   $0x806000
  800e34:	ff 75 0c             	pushl  0xc(%ebp)
  800e37:	e8 9e 0e 00 00       	call   801cda <memmove>
		*addrlen = ret->ret_addrlen;
  800e3c:	a1 10 60 80 00       	mov    0x806010,%eax
  800e41:	89 06                	mov    %eax,(%esi)
  800e43:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e46:	89 d8                	mov    %ebx,%eax
  800e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	53                   	push   %ebx
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e61:	53                   	push   %ebx
  800e62:	ff 75 0c             	pushl  0xc(%ebp)
  800e65:	68 04 60 80 00       	push   $0x806004
  800e6a:	e8 6b 0e 00 00       	call   801cda <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e6f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e75:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7a:	e8 36 ff ff ff       	call   800db5 <nsipc>
}
  800e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e95:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9f:	e8 11 ff ff ff       	call   800db5 <nsipc>
}
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb4:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb9:	e8 f7 fe ff ff       	call   800db5 <nsipc>
}
  800ebe:	c9                   	leave  
  800ebf:	c3                   	ret    

00800ec0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed2:	53                   	push   %ebx
  800ed3:	ff 75 0c             	pushl  0xc(%ebp)
  800ed6:	68 04 60 80 00       	push   $0x806004
  800edb:	e8 fa 0d 00 00       	call   801cda <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee6:	b8 05 00 00 00       	mov    $0x5,%eax
  800eeb:	e8 c5 fe ff ff       	call   800db5 <nsipc>
}
  800ef0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
  800efe:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f06:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f0b:	b8 06 00 00 00       	mov    $0x6,%eax
  800f10:	e8 a0 fe ff ff       	call   800db5 <nsipc>
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
  800f1c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f27:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800f30:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f35:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3a:	e8 76 fe ff ff       	call   800db5 <nsipc>
  800f3f:	89 c3                	mov    %eax,%ebx
  800f41:	85 c0                	test   %eax,%eax
  800f43:	78 35                	js     800f7a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f45:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f4a:	7f 04                	jg     800f50 <nsipc_recv+0x39>
  800f4c:	39 c6                	cmp    %eax,%esi
  800f4e:	7d 16                	jge    800f66 <nsipc_recv+0x4f>
  800f50:	68 67 23 80 00       	push   $0x802367
  800f55:	68 2f 23 80 00       	push   $0x80232f
  800f5a:	6a 62                	push   $0x62
  800f5c:	68 7c 23 80 00       	push   $0x80237c
  800f61:	e8 84 05 00 00       	call   8014ea <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	50                   	push   %eax
  800f6a:	68 00 60 80 00       	push   $0x806000
  800f6f:	ff 75 0c             	pushl  0xc(%ebp)
  800f72:	e8 63 0d 00 00       	call   801cda <memmove>
  800f77:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f7a:	89 d8                	mov    %ebx,%eax
  800f7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	53                   	push   %ebx
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f90:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f95:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9b:	7e 16                	jle    800fb3 <nsipc_send+0x30>
  800f9d:	68 88 23 80 00       	push   $0x802388
  800fa2:	68 2f 23 80 00       	push   $0x80232f
  800fa7:	6a 6d                	push   $0x6d
  800fa9:	68 7c 23 80 00       	push   $0x80237c
  800fae:	e8 37 05 00 00       	call   8014ea <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	53                   	push   %ebx
  800fb7:	ff 75 0c             	pushl  0xc(%ebp)
  800fba:	68 0c 60 80 00       	push   $0x80600c
  800fbf:	e8 16 0d 00 00       	call   801cda <memmove>
	nsipcbuf.send.req_size = size;
  800fc4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fca:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd2:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd7:	e8 d9 fd ff ff       	call   800db5 <nsipc>
}
  800fdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fea:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffa:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fff:	b8 09 00 00 00       	mov    $0x9,%eax
  801004:	e8 ac fd ff ff       	call   800db5 <nsipc>
}
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	ff 75 08             	pushl  0x8(%ebp)
  801019:	e8 87 f3 ff ff       	call   8003a5 <fd2data>
  80101e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801020:	83 c4 08             	add    $0x8,%esp
  801023:	68 94 23 80 00       	push   $0x802394
  801028:	53                   	push   %ebx
  801029:	e8 1a 0b 00 00       	call   801b48 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102e:	8b 46 04             	mov    0x4(%esi),%eax
  801031:	2b 06                	sub    (%esi),%eax
  801033:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801039:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801040:	00 00 00 
	stat->st_dev = &devpipe;
  801043:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80104a:	30 80 00 
	return 0;
}
  80104d:	b8 00 00 00 00       	mov    $0x0,%eax
  801052:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	53                   	push   %ebx
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801063:	53                   	push   %ebx
  801064:	6a 00                	push   $0x0
  801066:	e8 7e f1 ff ff       	call   8001e9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106b:	89 1c 24             	mov    %ebx,(%esp)
  80106e:	e8 32 f3 ff ff       	call   8003a5 <fd2data>
  801073:	83 c4 08             	add    $0x8,%esp
  801076:	50                   	push   %eax
  801077:	6a 00                	push   $0x0
  801079:	e8 6b f1 ff ff       	call   8001e9 <sys_page_unmap>
}
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 1c             	sub    $0x1c,%esp
  80108c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80108f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801091:	a1 08 40 80 00       	mov    0x804008,%eax
  801096:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	ff 75 e0             	pushl  -0x20(%ebp)
  80109f:	e8 e5 0e 00 00       	call   801f89 <pageref>
  8010a4:	89 c3                	mov    %eax,%ebx
  8010a6:	89 3c 24             	mov    %edi,(%esp)
  8010a9:	e8 db 0e 00 00       	call   801f89 <pageref>
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	39 c3                	cmp    %eax,%ebx
  8010b3:	0f 94 c1             	sete   %cl
  8010b6:	0f b6 c9             	movzbl %cl,%ecx
  8010b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010bc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c5:	39 ce                	cmp    %ecx,%esi
  8010c7:	74 1b                	je     8010e4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010c9:	39 c3                	cmp    %eax,%ebx
  8010cb:	75 c4                	jne    801091 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010cd:	8b 42 58             	mov    0x58(%edx),%eax
  8010d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d3:	50                   	push   %eax
  8010d4:	56                   	push   %esi
  8010d5:	68 9b 23 80 00       	push   $0x80239b
  8010da:	e8 e4 04 00 00       	call   8015c3 <cprintf>
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	eb ad                	jmp    801091 <_pipeisclosed+0xe>
	}
}
  8010e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5e                   	pop    %esi
  8010ec:	5f                   	pop    %edi
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	57                   	push   %edi
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 28             	sub    $0x28,%esp
  8010f8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010fb:	56                   	push   %esi
  8010fc:	e8 a4 f2 ff ff       	call   8003a5 <fd2data>
  801101:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	bf 00 00 00 00       	mov    $0x0,%edi
  80110b:	eb 4b                	jmp    801158 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80110d:	89 da                	mov    %ebx,%edx
  80110f:	89 f0                	mov    %esi,%eax
  801111:	e8 6d ff ff ff       	call   801083 <_pipeisclosed>
  801116:	85 c0                	test   %eax,%eax
  801118:	75 48                	jne    801162 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80111a:	e8 26 f0 ff ff       	call   800145 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80111f:	8b 43 04             	mov    0x4(%ebx),%eax
  801122:	8b 0b                	mov    (%ebx),%ecx
  801124:	8d 51 20             	lea    0x20(%ecx),%edx
  801127:	39 d0                	cmp    %edx,%eax
  801129:	73 e2                	jae    80110d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80112b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801132:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 fa 1f             	sar    $0x1f,%edx
  80113a:	89 d1                	mov    %edx,%ecx
  80113c:	c1 e9 1b             	shr    $0x1b,%ecx
  80113f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801142:	83 e2 1f             	and    $0x1f,%edx
  801145:	29 ca                	sub    %ecx,%edx
  801147:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80114b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114f:	83 c0 01             	add    $0x1,%eax
  801152:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801155:	83 c7 01             	add    $0x1,%edi
  801158:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80115b:	75 c2                	jne    80111f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80115d:	8b 45 10             	mov    0x10(%ebp),%eax
  801160:	eb 05                	jmp    801167 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801162:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116a:	5b                   	pop    %ebx
  80116b:	5e                   	pop    %esi
  80116c:	5f                   	pop    %edi
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	57                   	push   %edi
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 18             	sub    $0x18,%esp
  801178:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80117b:	57                   	push   %edi
  80117c:	e8 24 f2 ff ff       	call   8003a5 <fd2data>
  801181:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118b:	eb 3d                	jmp    8011ca <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80118d:	85 db                	test   %ebx,%ebx
  80118f:	74 04                	je     801195 <devpipe_read+0x26>
				return i;
  801191:	89 d8                	mov    %ebx,%eax
  801193:	eb 44                	jmp    8011d9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801195:	89 f2                	mov    %esi,%edx
  801197:	89 f8                	mov    %edi,%eax
  801199:	e8 e5 fe ff ff       	call   801083 <_pipeisclosed>
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	75 32                	jne    8011d4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a2:	e8 9e ef ff ff       	call   800145 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a7:	8b 06                	mov    (%esi),%eax
  8011a9:	3b 46 04             	cmp    0x4(%esi),%eax
  8011ac:	74 df                	je     80118d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ae:	99                   	cltd   
  8011af:	c1 ea 1b             	shr    $0x1b,%edx
  8011b2:	01 d0                	add    %edx,%eax
  8011b4:	83 e0 1f             	and    $0x1f,%eax
  8011b7:	29 d0                	sub    %edx,%eax
  8011b9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c7:	83 c3 01             	add    $0x1,%ebx
  8011ca:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011cd:	75 d8                	jne    8011a7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d2:	eb 05                	jmp    8011d9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ec:	50                   	push   %eax
  8011ed:	e8 ca f1 ff ff       	call   8003bc <fd_alloc>
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	0f 88 2c 01 00 00    	js     80132b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	68 07 04 00 00       	push   $0x407
  801207:	ff 75 f4             	pushl  -0xc(%ebp)
  80120a:	6a 00                	push   $0x0
  80120c:	e8 53 ef ff ff       	call   800164 <sys_page_alloc>
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	89 c2                	mov    %eax,%edx
  801216:	85 c0                	test   %eax,%eax
  801218:	0f 88 0d 01 00 00    	js     80132b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80121e:	83 ec 0c             	sub    $0xc,%esp
  801221:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	e8 92 f1 ff ff       	call   8003bc <fd_alloc>
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	0f 88 e2 00 00 00    	js     801319 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	68 07 04 00 00       	push   $0x407
  80123f:	ff 75 f0             	pushl  -0x10(%ebp)
  801242:	6a 00                	push   $0x0
  801244:	e8 1b ef ff ff       	call   800164 <sys_page_alloc>
  801249:	89 c3                	mov    %eax,%ebx
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	0f 88 c3 00 00 00    	js     801319 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801256:	83 ec 0c             	sub    $0xc,%esp
  801259:	ff 75 f4             	pushl  -0xc(%ebp)
  80125c:	e8 44 f1 ff ff       	call   8003a5 <fd2data>
  801261:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801263:	83 c4 0c             	add    $0xc,%esp
  801266:	68 07 04 00 00       	push   $0x407
  80126b:	50                   	push   %eax
  80126c:	6a 00                	push   $0x0
  80126e:	e8 f1 ee ff ff       	call   800164 <sys_page_alloc>
  801273:	89 c3                	mov    %eax,%ebx
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	0f 88 89 00 00 00    	js     801309 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801280:	83 ec 0c             	sub    $0xc,%esp
  801283:	ff 75 f0             	pushl  -0x10(%ebp)
  801286:	e8 1a f1 ff ff       	call   8003a5 <fd2data>
  80128b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801292:	50                   	push   %eax
  801293:	6a 00                	push   $0x0
  801295:	56                   	push   %esi
  801296:	6a 00                	push   $0x0
  801298:	e8 0a ef ff ff       	call   8001a7 <sys_page_map>
  80129d:	89 c3                	mov    %eax,%ebx
  80129f:	83 c4 20             	add    $0x20,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 55                	js     8012fb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012af:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012d0:	83 ec 0c             	sub    $0xc,%esp
  8012d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d6:	e8 ba f0 ff ff       	call   800395 <fd2num>
  8012db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012de:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e0:	83 c4 04             	add    $0x4,%esp
  8012e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e6:	e8 aa f0 ff ff       	call   800395 <fd2num>
  8012eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ee:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f9:	eb 30                	jmp    80132b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	56                   	push   %esi
  8012ff:	6a 00                	push   $0x0
  801301:	e8 e3 ee ff ff       	call   8001e9 <sys_page_unmap>
  801306:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	ff 75 f0             	pushl  -0x10(%ebp)
  80130f:	6a 00                	push   $0x0
  801311:	e8 d3 ee ff ff       	call   8001e9 <sys_page_unmap>
  801316:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	ff 75 f4             	pushl  -0xc(%ebp)
  80131f:	6a 00                	push   $0x0
  801321:	e8 c3 ee ff ff       	call   8001e9 <sys_page_unmap>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	ff 75 08             	pushl  0x8(%ebp)
  801341:	e8 c5 f0 ff ff       	call   80040b <fd_lookup>
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 18                	js     801365 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80134d:	83 ec 0c             	sub    $0xc,%esp
  801350:	ff 75 f4             	pushl  -0xc(%ebp)
  801353:	e8 4d f0 ff ff       	call   8003a5 <fd2data>
	return _pipeisclosed(fd, p);
  801358:	89 c2                	mov    %eax,%edx
  80135a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135d:	e8 21 fd ff ff       	call   801083 <_pipeisclosed>
  801362:	83 c4 10             	add    $0x10,%esp
}
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80136a:	b8 00 00 00 00       	mov    $0x0,%eax
  80136f:	5d                   	pop    %ebp
  801370:	c3                   	ret    

00801371 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801377:	68 b3 23 80 00       	push   $0x8023b3
  80137c:	ff 75 0c             	pushl  0xc(%ebp)
  80137f:	e8 c4 07 00 00       	call   801b48 <strcpy>
	return 0;
}
  801384:	b8 00 00 00 00       	mov    $0x0,%eax
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	57                   	push   %edi
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801397:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a2:	eb 2d                	jmp    8013d1 <devcons_write+0x46>
		m = n - tot;
  8013a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013a9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013ac:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013b1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	53                   	push   %ebx
  8013b8:	03 45 0c             	add    0xc(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	57                   	push   %edi
  8013bd:	e8 18 09 00 00       	call   801cda <memmove>
		sys_cputs(buf, m);
  8013c2:	83 c4 08             	add    $0x8,%esp
  8013c5:	53                   	push   %ebx
  8013c6:	57                   	push   %edi
  8013c7:	e8 dc ec ff ff       	call   8000a8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013cc:	01 de                	add    %ebx,%esi
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	89 f0                	mov    %esi,%eax
  8013d3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d6:	72 cc                	jb     8013a4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5f                   	pop    %edi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ef:	74 2a                	je     80141b <devcons_read+0x3b>
  8013f1:	eb 05                	jmp    8013f8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f3:	e8 4d ed ff ff       	call   800145 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f8:	e8 c9 ec ff ff       	call   8000c6 <sys_cgetc>
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	74 f2                	je     8013f3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801401:	85 c0                	test   %eax,%eax
  801403:	78 16                	js     80141b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801405:	83 f8 04             	cmp    $0x4,%eax
  801408:	74 0c                	je     801416 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80140a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140d:	88 02                	mov    %al,(%edx)
	return 1;
  80140f:	b8 01 00 00 00       	mov    $0x1,%eax
  801414:	eb 05                	jmp    80141b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801429:	6a 01                	push   $0x1
  80142b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	e8 74 ec ff ff       	call   8000a8 <sys_cputs>
}
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <getchar>:

int
getchar(void)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80143f:	6a 01                	push   $0x1
  801441:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	6a 00                	push   $0x0
  801447:	e8 25 f2 ff ff       	call   800671 <read>
	if (r < 0)
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 0f                	js     801462 <getchar+0x29>
		return r;
	if (r < 1)
  801453:	85 c0                	test   %eax,%eax
  801455:	7e 06                	jle    80145d <getchar+0x24>
		return -E_EOF;
	return c;
  801457:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80145b:	eb 05                	jmp    801462 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80145d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	ff 75 08             	pushl  0x8(%ebp)
  801471:	e8 95 ef ff ff       	call   80040b <fd_lookup>
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 11                	js     80148e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801480:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801486:	39 10                	cmp    %edx,(%eax)
  801488:	0f 94 c0             	sete   %al
  80148b:	0f b6 c0             	movzbl %al,%eax
}
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <opencons>:

int
opencons(void)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	e8 1d ef ff ff       	call   8003bc <fd_alloc>
  80149f:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 3e                	js     8014e6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a8:	83 ec 04             	sub    $0x4,%esp
  8014ab:	68 07 04 00 00       	push   $0x407
  8014b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b3:	6a 00                	push   $0x0
  8014b5:	e8 aa ec ff ff       	call   800164 <sys_page_alloc>
  8014ba:	83 c4 10             	add    $0x10,%esp
		return r;
  8014bd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 23                	js     8014e6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	50                   	push   %eax
  8014dc:	e8 b4 ee ff ff       	call   800395 <fd2num>
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	83 c4 10             	add    $0x10,%esp
}
  8014e6:	89 d0                	mov    %edx,%eax
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ef:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f8:	e8 29 ec ff ff       	call   800126 <sys_getenvid>
  8014fd:	83 ec 0c             	sub    $0xc,%esp
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	ff 75 08             	pushl  0x8(%ebp)
  801506:	56                   	push   %esi
  801507:	50                   	push   %eax
  801508:	68 c0 23 80 00       	push   $0x8023c0
  80150d:	e8 b1 00 00 00       	call   8015c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801512:	83 c4 18             	add    $0x18,%esp
  801515:	53                   	push   %ebx
  801516:	ff 75 10             	pushl  0x10(%ebp)
  801519:	e8 54 00 00 00       	call   801572 <vcprintf>
	cprintf("\n");
  80151e:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  801525:	e8 99 00 00 00       	call   8015c3 <cprintf>
  80152a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80152d:	cc                   	int3   
  80152e:	eb fd                	jmp    80152d <_panic+0x43>

00801530 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 04             	sub    $0x4,%esp
  801537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80153a:	8b 13                	mov    (%ebx),%edx
  80153c:	8d 42 01             	lea    0x1(%edx),%eax
  80153f:	89 03                	mov    %eax,(%ebx)
  801541:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801544:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801548:	3d ff 00 00 00       	cmp    $0xff,%eax
  80154d:	75 1a                	jne    801569 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	68 ff 00 00 00       	push   $0xff
  801557:	8d 43 08             	lea    0x8(%ebx),%eax
  80155a:	50                   	push   %eax
  80155b:	e8 48 eb ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  801560:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801566:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801569:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80156d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801570:	c9                   	leave  
  801571:	c3                   	ret    

00801572 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80157b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801582:	00 00 00 
	b.cnt = 0;
  801585:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80158c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80158f:	ff 75 0c             	pushl  0xc(%ebp)
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	68 30 15 80 00       	push   $0x801530
  8015a1:	e8 54 01 00 00       	call   8016fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	e8 ed ea ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  8015bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015cc:	50                   	push   %eax
  8015cd:	ff 75 08             	pushl  0x8(%ebp)
  8015d0:	e8 9d ff ff ff       	call   801572 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 1c             	sub    $0x1c,%esp
  8015e0:	89 c7                	mov    %eax,%edi
  8015e2:	89 d6                	mov    %edx,%esi
  8015e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015fb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015fe:	39 d3                	cmp    %edx,%ebx
  801600:	72 05                	jb     801607 <printnum+0x30>
  801602:	39 45 10             	cmp    %eax,0x10(%ebp)
  801605:	77 45                	ja     80164c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	ff 75 18             	pushl  0x18(%ebp)
  80160d:	8b 45 14             	mov    0x14(%ebp),%eax
  801610:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801613:	53                   	push   %ebx
  801614:	ff 75 10             	pushl  0x10(%ebp)
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161d:	ff 75 e0             	pushl  -0x20(%ebp)
  801620:	ff 75 dc             	pushl  -0x24(%ebp)
  801623:	ff 75 d8             	pushl  -0x28(%ebp)
  801626:	e8 a5 09 00 00       	call   801fd0 <__udivdi3>
  80162b:	83 c4 18             	add    $0x18,%esp
  80162e:	52                   	push   %edx
  80162f:	50                   	push   %eax
  801630:	89 f2                	mov    %esi,%edx
  801632:	89 f8                	mov    %edi,%eax
  801634:	e8 9e ff ff ff       	call   8015d7 <printnum>
  801639:	83 c4 20             	add    $0x20,%esp
  80163c:	eb 18                	jmp    801656 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	56                   	push   %esi
  801642:	ff 75 18             	pushl  0x18(%ebp)
  801645:	ff d7                	call   *%edi
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 03                	jmp    80164f <printnum+0x78>
  80164c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80164f:	83 eb 01             	sub    $0x1,%ebx
  801652:	85 db                	test   %ebx,%ebx
  801654:	7f e8                	jg     80163e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	56                   	push   %esi
  80165a:	83 ec 04             	sub    $0x4,%esp
  80165d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801660:	ff 75 e0             	pushl  -0x20(%ebp)
  801663:	ff 75 dc             	pushl  -0x24(%ebp)
  801666:	ff 75 d8             	pushl  -0x28(%ebp)
  801669:	e8 92 0a 00 00       	call   802100 <__umoddi3>
  80166e:	83 c4 14             	add    $0x14,%esp
  801671:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801678:	50                   	push   %eax
  801679:	ff d7                	call   *%edi
}
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801689:	83 fa 01             	cmp    $0x1,%edx
  80168c:	7e 0e                	jle    80169c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80168e:	8b 10                	mov    (%eax),%edx
  801690:	8d 4a 08             	lea    0x8(%edx),%ecx
  801693:	89 08                	mov    %ecx,(%eax)
  801695:	8b 02                	mov    (%edx),%eax
  801697:	8b 52 04             	mov    0x4(%edx),%edx
  80169a:	eb 22                	jmp    8016be <getuint+0x38>
	else if (lflag)
  80169c:	85 d2                	test   %edx,%edx
  80169e:	74 10                	je     8016b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016a0:	8b 10                	mov    (%eax),%edx
  8016a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a5:	89 08                	mov    %ecx,(%eax)
  8016a7:	8b 02                	mov    (%edx),%eax
  8016a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ae:	eb 0e                	jmp    8016be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016b0:	8b 10                	mov    (%eax),%edx
  8016b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b5:	89 08                	mov    %ecx,(%eax)
  8016b7:	8b 02                	mov    (%edx),%eax
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016ca:	8b 10                	mov    (%eax),%edx
  8016cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8016cf:	73 0a                	jae    8016db <sprintputch+0x1b>
		*b->buf++ = ch;
  8016d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d4:	89 08                	mov    %ecx,(%eax)
  8016d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d9:	88 02                	mov    %al,(%edx)
}
  8016db:	5d                   	pop    %ebp
  8016dc:	c3                   	ret    

008016dd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e6:	50                   	push   %eax
  8016e7:	ff 75 10             	pushl  0x10(%ebp)
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	ff 75 08             	pushl  0x8(%ebp)
  8016f0:	e8 05 00 00 00       	call   8016fa <vprintfmt>
	va_end(ap);
}
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 2c             	sub    $0x2c,%esp
  801703:	8b 75 08             	mov    0x8(%ebp),%esi
  801706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801709:	8b 7d 10             	mov    0x10(%ebp),%edi
  80170c:	eb 12                	jmp    801720 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80170e:	85 c0                	test   %eax,%eax
  801710:	0f 84 89 03 00 00    	je     801a9f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801716:	83 ec 08             	sub    $0x8,%esp
  801719:	53                   	push   %ebx
  80171a:	50                   	push   %eax
  80171b:	ff d6                	call   *%esi
  80171d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801720:	83 c7 01             	add    $0x1,%edi
  801723:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801727:	83 f8 25             	cmp    $0x25,%eax
  80172a:	75 e2                	jne    80170e <vprintfmt+0x14>
  80172c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801730:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801737:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80173e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801745:	ba 00 00 00 00       	mov    $0x0,%edx
  80174a:	eb 07                	jmp    801753 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80174f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801753:	8d 47 01             	lea    0x1(%edi),%eax
  801756:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801759:	0f b6 07             	movzbl (%edi),%eax
  80175c:	0f b6 c8             	movzbl %al,%ecx
  80175f:	83 e8 23             	sub    $0x23,%eax
  801762:	3c 55                	cmp    $0x55,%al
  801764:	0f 87 1a 03 00 00    	ja     801a84 <vprintfmt+0x38a>
  80176a:	0f b6 c0             	movzbl %al,%eax
  80176d:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801777:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80177b:	eb d6                	jmp    801753 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
  801785:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801788:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80178b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80178f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801792:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801795:	83 fa 09             	cmp    $0x9,%edx
  801798:	77 39                	ja     8017d3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80179a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80179d:	eb e9                	jmp    801788 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80179f:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a2:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017a8:	8b 00                	mov    (%eax),%eax
  8017aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017b0:	eb 27                	jmp    8017d9 <vprintfmt+0xdf>
  8017b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017bc:	0f 49 c8             	cmovns %eax,%ecx
  8017bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c5:	eb 8c                	jmp    801753 <vprintfmt+0x59>
  8017c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017ca:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017d1:	eb 80                	jmp    801753 <vprintfmt+0x59>
  8017d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017dd:	0f 89 70 ff ff ff    	jns    801753 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017e9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f0:	e9 5e ff ff ff       	jmp    801753 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017fb:	e9 53 ff ff ff       	jmp    801753 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801800:	8b 45 14             	mov    0x14(%ebp),%eax
  801803:	8d 50 04             	lea    0x4(%eax),%edx
  801806:	89 55 14             	mov    %edx,0x14(%ebp)
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	53                   	push   %ebx
  80180d:	ff 30                	pushl  (%eax)
  80180f:	ff d6                	call   *%esi
			break;
  801811:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801814:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801817:	e9 04 ff ff ff       	jmp    801720 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80181c:	8b 45 14             	mov    0x14(%ebp),%eax
  80181f:	8d 50 04             	lea    0x4(%eax),%edx
  801822:	89 55 14             	mov    %edx,0x14(%ebp)
  801825:	8b 00                	mov    (%eax),%eax
  801827:	99                   	cltd   
  801828:	31 d0                	xor    %edx,%eax
  80182a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80182c:	83 f8 0f             	cmp    $0xf,%eax
  80182f:	7f 0b                	jg     80183c <vprintfmt+0x142>
  801831:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801838:	85 d2                	test   %edx,%edx
  80183a:	75 18                	jne    801854 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80183c:	50                   	push   %eax
  80183d:	68 fb 23 80 00       	push   $0x8023fb
  801842:	53                   	push   %ebx
  801843:	56                   	push   %esi
  801844:	e8 94 fe ff ff       	call   8016dd <printfmt>
  801849:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80184f:	e9 cc fe ff ff       	jmp    801720 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801854:	52                   	push   %edx
  801855:	68 41 23 80 00       	push   $0x802341
  80185a:	53                   	push   %ebx
  80185b:	56                   	push   %esi
  80185c:	e8 7c fe ff ff       	call   8016dd <printfmt>
  801861:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801864:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801867:	e9 b4 fe ff ff       	jmp    801720 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80186c:	8b 45 14             	mov    0x14(%ebp),%eax
  80186f:	8d 50 04             	lea    0x4(%eax),%edx
  801872:	89 55 14             	mov    %edx,0x14(%ebp)
  801875:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801877:	85 ff                	test   %edi,%edi
  801879:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80187e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801881:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801885:	0f 8e 94 00 00 00    	jle    80191f <vprintfmt+0x225>
  80188b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80188f:	0f 84 98 00 00 00    	je     80192d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	ff 75 d0             	pushl  -0x30(%ebp)
  80189b:	57                   	push   %edi
  80189c:	e8 86 02 00 00       	call   801b27 <strnlen>
  8018a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a4:	29 c1                	sub    %eax,%ecx
  8018a6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b8:	eb 0f                	jmp    8018c9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	53                   	push   %ebx
  8018be:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c3:	83 ef 01             	sub    $0x1,%edi
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 ff                	test   %edi,%edi
  8018cb:	7f ed                	jg     8018ba <vprintfmt+0x1c0>
  8018cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018d0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d3:	85 c9                	test   %ecx,%ecx
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018da:	0f 49 c1             	cmovns %ecx,%eax
  8018dd:	29 c1                	sub    %eax,%ecx
  8018df:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e8:	89 cb                	mov    %ecx,%ebx
  8018ea:	eb 4d                	jmp    801939 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018f0:	74 1b                	je     80190d <vprintfmt+0x213>
  8018f2:	0f be c0             	movsbl %al,%eax
  8018f5:	83 e8 20             	sub    $0x20,%eax
  8018f8:	83 f8 5e             	cmp    $0x5e,%eax
  8018fb:	76 10                	jbe    80190d <vprintfmt+0x213>
					putch('?', putdat);
  8018fd:	83 ec 08             	sub    $0x8,%esp
  801900:	ff 75 0c             	pushl  0xc(%ebp)
  801903:	6a 3f                	push   $0x3f
  801905:	ff 55 08             	call   *0x8(%ebp)
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	eb 0d                	jmp    80191a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	ff 75 0c             	pushl  0xc(%ebp)
  801913:	52                   	push   %edx
  801914:	ff 55 08             	call   *0x8(%ebp)
  801917:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80191a:	83 eb 01             	sub    $0x1,%ebx
  80191d:	eb 1a                	jmp    801939 <vprintfmt+0x23f>
  80191f:	89 75 08             	mov    %esi,0x8(%ebp)
  801922:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801925:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801928:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80192b:	eb 0c                	jmp    801939 <vprintfmt+0x23f>
  80192d:	89 75 08             	mov    %esi,0x8(%ebp)
  801930:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801933:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801936:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801939:	83 c7 01             	add    $0x1,%edi
  80193c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801940:	0f be d0             	movsbl %al,%edx
  801943:	85 d2                	test   %edx,%edx
  801945:	74 23                	je     80196a <vprintfmt+0x270>
  801947:	85 f6                	test   %esi,%esi
  801949:	78 a1                	js     8018ec <vprintfmt+0x1f2>
  80194b:	83 ee 01             	sub    $0x1,%esi
  80194e:	79 9c                	jns    8018ec <vprintfmt+0x1f2>
  801950:	89 df                	mov    %ebx,%edi
  801952:	8b 75 08             	mov    0x8(%ebp),%esi
  801955:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801958:	eb 18                	jmp    801972 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80195a:	83 ec 08             	sub    $0x8,%esp
  80195d:	53                   	push   %ebx
  80195e:	6a 20                	push   $0x20
  801960:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801962:	83 ef 01             	sub    $0x1,%edi
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	eb 08                	jmp    801972 <vprintfmt+0x278>
  80196a:	89 df                	mov    %ebx,%edi
  80196c:	8b 75 08             	mov    0x8(%ebp),%esi
  80196f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801972:	85 ff                	test   %edi,%edi
  801974:	7f e4                	jg     80195a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801976:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801979:	e9 a2 fd ff ff       	jmp    801720 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80197e:	83 fa 01             	cmp    $0x1,%edx
  801981:	7e 16                	jle    801999 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801983:	8b 45 14             	mov    0x14(%ebp),%eax
  801986:	8d 50 08             	lea    0x8(%eax),%edx
  801989:	89 55 14             	mov    %edx,0x14(%ebp)
  80198c:	8b 50 04             	mov    0x4(%eax),%edx
  80198f:	8b 00                	mov    (%eax),%eax
  801991:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801994:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801997:	eb 32                	jmp    8019cb <vprintfmt+0x2d1>
	else if (lflag)
  801999:	85 d2                	test   %edx,%edx
  80199b:	74 18                	je     8019b5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80199d:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a0:	8d 50 04             	lea    0x4(%eax),%edx
  8019a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a6:	8b 00                	mov    (%eax),%eax
  8019a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ab:	89 c1                	mov    %eax,%ecx
  8019ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b3:	eb 16                	jmp    8019cb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b8:	8d 50 04             	lea    0x4(%eax),%edx
  8019bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8019be:	8b 00                	mov    (%eax),%eax
  8019c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c3:	89 c1                	mov    %eax,%ecx
  8019c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019da:	79 74                	jns    801a50 <vprintfmt+0x356>
				putch('-', putdat);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	53                   	push   %ebx
  8019e0:	6a 2d                	push   $0x2d
  8019e2:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019ea:	f7 d8                	neg    %eax
  8019ec:	83 d2 00             	adc    $0x0,%edx
  8019ef:	f7 da                	neg    %edx
  8019f1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019f9:	eb 55                	jmp    801a50 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8019fe:	e8 83 fc ff ff       	call   801686 <getuint>
			base = 10;
  801a03:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a08:	eb 46                	jmp    801a50 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a0a:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0d:	e8 74 fc ff ff       	call   801686 <getuint>
		        base = 8;
  801a12:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a17:	eb 37                	jmp    801a50 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a19:	83 ec 08             	sub    $0x8,%esp
  801a1c:	53                   	push   %ebx
  801a1d:	6a 30                	push   $0x30
  801a1f:	ff d6                	call   *%esi
			putch('x', putdat);
  801a21:	83 c4 08             	add    $0x8,%esp
  801a24:	53                   	push   %ebx
  801a25:	6a 78                	push   $0x78
  801a27:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a29:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2c:	8d 50 04             	lea    0x4(%eax),%edx
  801a2f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a32:	8b 00                	mov    (%eax),%eax
  801a34:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a39:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a3c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a41:	eb 0d                	jmp    801a50 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a43:	8d 45 14             	lea    0x14(%ebp),%eax
  801a46:	e8 3b fc ff ff       	call   801686 <getuint>
			base = 16;
  801a4b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a57:	57                   	push   %edi
  801a58:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5b:	51                   	push   %ecx
  801a5c:	52                   	push   %edx
  801a5d:	50                   	push   %eax
  801a5e:	89 da                	mov    %ebx,%edx
  801a60:	89 f0                	mov    %esi,%eax
  801a62:	e8 70 fb ff ff       	call   8015d7 <printnum>
			break;
  801a67:	83 c4 20             	add    $0x20,%esp
  801a6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6d:	e9 ae fc ff ff       	jmp    801720 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a72:	83 ec 08             	sub    $0x8,%esp
  801a75:	53                   	push   %ebx
  801a76:	51                   	push   %ecx
  801a77:	ff d6                	call   *%esi
			break;
  801a79:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a7f:	e9 9c fc ff ff       	jmp    801720 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a84:	83 ec 08             	sub    $0x8,%esp
  801a87:	53                   	push   %ebx
  801a88:	6a 25                	push   $0x25
  801a8a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	eb 03                	jmp    801a94 <vprintfmt+0x39a>
  801a91:	83 ef 01             	sub    $0x1,%edi
  801a94:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a98:	75 f7                	jne    801a91 <vprintfmt+0x397>
  801a9a:	e9 81 fc ff ff       	jmp    801720 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa2:	5b                   	pop    %ebx
  801aa3:	5e                   	pop    %esi
  801aa4:	5f                   	pop    %edi
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 18             	sub    $0x18,%esp
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801aba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801abd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	74 26                	je     801aee <vsnprintf+0x47>
  801ac8:	85 d2                	test   %edx,%edx
  801aca:	7e 22                	jle    801aee <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801acc:	ff 75 14             	pushl  0x14(%ebp)
  801acf:	ff 75 10             	pushl  0x10(%ebp)
  801ad2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad5:	50                   	push   %eax
  801ad6:	68 c0 16 80 00       	push   $0x8016c0
  801adb:	e8 1a fc ff ff       	call   8016fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	eb 05                	jmp    801af3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801afb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801afe:	50                   	push   %eax
  801aff:	ff 75 10             	pushl  0x10(%ebp)
  801b02:	ff 75 0c             	pushl  0xc(%ebp)
  801b05:	ff 75 08             	pushl  0x8(%ebp)
  801b08:	e8 9a ff ff ff       	call   801aa7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1a:	eb 03                	jmp    801b1f <strlen+0x10>
		n++;
  801b1c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b23:	75 f7                	jne    801b1c <strlen+0xd>
		n++;
	return n;
}
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b30:	ba 00 00 00 00       	mov    $0x0,%edx
  801b35:	eb 03                	jmp    801b3a <strnlen+0x13>
		n++;
  801b37:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3a:	39 c2                	cmp    %eax,%edx
  801b3c:	74 08                	je     801b46 <strnlen+0x1f>
  801b3e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b42:	75 f3                	jne    801b37 <strnlen+0x10>
  801b44:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	53                   	push   %ebx
  801b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b52:	89 c2                	mov    %eax,%edx
  801b54:	83 c2 01             	add    $0x1,%edx
  801b57:	83 c1 01             	add    $0x1,%ecx
  801b5a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b5e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b61:	84 db                	test   %bl,%bl
  801b63:	75 ef                	jne    801b54 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b65:	5b                   	pop    %ebx
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	53                   	push   %ebx
  801b6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b6f:	53                   	push   %ebx
  801b70:	e8 9a ff ff ff       	call   801b0f <strlen>
  801b75:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b78:	ff 75 0c             	pushl  0xc(%ebp)
  801b7b:	01 d8                	add    %ebx,%eax
  801b7d:	50                   	push   %eax
  801b7e:	e8 c5 ff ff ff       	call   801b48 <strcpy>
	return dst;
}
  801b83:	89 d8                	mov    %ebx,%eax
  801b85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	56                   	push   %esi
  801b8e:	53                   	push   %ebx
  801b8f:	8b 75 08             	mov    0x8(%ebp),%esi
  801b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b95:	89 f3                	mov    %esi,%ebx
  801b97:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b9a:	89 f2                	mov    %esi,%edx
  801b9c:	eb 0f                	jmp    801bad <strncpy+0x23>
		*dst++ = *src;
  801b9e:	83 c2 01             	add    $0x1,%edx
  801ba1:	0f b6 01             	movzbl (%ecx),%eax
  801ba4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba7:	80 39 01             	cmpb   $0x1,(%ecx)
  801baa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bad:	39 da                	cmp    %ebx,%edx
  801baf:	75 ed                	jne    801b9e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb1:	89 f0                	mov    %esi,%eax
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5d                   	pop    %ebp
  801bb6:	c3                   	ret    

00801bb7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	56                   	push   %esi
  801bbb:	53                   	push   %ebx
  801bbc:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc2:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc7:	85 d2                	test   %edx,%edx
  801bc9:	74 21                	je     801bec <strlcpy+0x35>
  801bcb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bcf:	89 f2                	mov    %esi,%edx
  801bd1:	eb 09                	jmp    801bdc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd3:	83 c2 01             	add    $0x1,%edx
  801bd6:	83 c1 01             	add    $0x1,%ecx
  801bd9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bdc:	39 c2                	cmp    %eax,%edx
  801bde:	74 09                	je     801be9 <strlcpy+0x32>
  801be0:	0f b6 19             	movzbl (%ecx),%ebx
  801be3:	84 db                	test   %bl,%bl
  801be5:	75 ec                	jne    801bd3 <strlcpy+0x1c>
  801be7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bec:	29 f0                	sub    %esi,%eax
}
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bfb:	eb 06                	jmp    801c03 <strcmp+0x11>
		p++, q++;
  801bfd:	83 c1 01             	add    $0x1,%ecx
  801c00:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c03:	0f b6 01             	movzbl (%ecx),%eax
  801c06:	84 c0                	test   %al,%al
  801c08:	74 04                	je     801c0e <strcmp+0x1c>
  801c0a:	3a 02                	cmp    (%edx),%al
  801c0c:	74 ef                	je     801bfd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0e:	0f b6 c0             	movzbl %al,%eax
  801c11:	0f b6 12             	movzbl (%edx),%edx
  801c14:	29 d0                	sub    %edx,%eax
}
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	53                   	push   %ebx
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c27:	eb 06                	jmp    801c2f <strncmp+0x17>
		n--, p++, q++;
  801c29:	83 c0 01             	add    $0x1,%eax
  801c2c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c2f:	39 d8                	cmp    %ebx,%eax
  801c31:	74 15                	je     801c48 <strncmp+0x30>
  801c33:	0f b6 08             	movzbl (%eax),%ecx
  801c36:	84 c9                	test   %cl,%cl
  801c38:	74 04                	je     801c3e <strncmp+0x26>
  801c3a:	3a 0a                	cmp    (%edx),%cl
  801c3c:	74 eb                	je     801c29 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3e:	0f b6 00             	movzbl (%eax),%eax
  801c41:	0f b6 12             	movzbl (%edx),%edx
  801c44:	29 d0                	sub    %edx,%eax
  801c46:	eb 05                	jmp    801c4d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c48:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c4d:	5b                   	pop    %ebx
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c5a:	eb 07                	jmp    801c63 <strchr+0x13>
		if (*s == c)
  801c5c:	38 ca                	cmp    %cl,%dl
  801c5e:	74 0f                	je     801c6f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c60:	83 c0 01             	add    $0x1,%eax
  801c63:	0f b6 10             	movzbl (%eax),%edx
  801c66:	84 d2                	test   %dl,%dl
  801c68:	75 f2                	jne    801c5c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c7b:	eb 03                	jmp    801c80 <strfind+0xf>
  801c7d:	83 c0 01             	add    $0x1,%eax
  801c80:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c83:	38 ca                	cmp    %cl,%dl
  801c85:	74 04                	je     801c8b <strfind+0x1a>
  801c87:	84 d2                	test   %dl,%dl
  801c89:	75 f2                	jne    801c7d <strfind+0xc>
			break;
	return (char *) s;
}
  801c8b:	5d                   	pop    %ebp
  801c8c:	c3                   	ret    

00801c8d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	57                   	push   %edi
  801c91:	56                   	push   %esi
  801c92:	53                   	push   %ebx
  801c93:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c99:	85 c9                	test   %ecx,%ecx
  801c9b:	74 36                	je     801cd3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca3:	75 28                	jne    801ccd <memset+0x40>
  801ca5:	f6 c1 03             	test   $0x3,%cl
  801ca8:	75 23                	jne    801ccd <memset+0x40>
		c &= 0xFF;
  801caa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cae:	89 d3                	mov    %edx,%ebx
  801cb0:	c1 e3 08             	shl    $0x8,%ebx
  801cb3:	89 d6                	mov    %edx,%esi
  801cb5:	c1 e6 18             	shl    $0x18,%esi
  801cb8:	89 d0                	mov    %edx,%eax
  801cba:	c1 e0 10             	shl    $0x10,%eax
  801cbd:	09 f0                	or     %esi,%eax
  801cbf:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cc1:	89 d8                	mov    %ebx,%eax
  801cc3:	09 d0                	or     %edx,%eax
  801cc5:	c1 e9 02             	shr    $0x2,%ecx
  801cc8:	fc                   	cld    
  801cc9:	f3 ab                	rep stos %eax,%es:(%edi)
  801ccb:	eb 06                	jmp    801cd3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd0:	fc                   	cld    
  801cd1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd3:	89 f8                	mov    %edi,%eax
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    

00801cda <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	57                   	push   %edi
  801cde:	56                   	push   %esi
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce8:	39 c6                	cmp    %eax,%esi
  801cea:	73 35                	jae    801d21 <memmove+0x47>
  801cec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cef:	39 d0                	cmp    %edx,%eax
  801cf1:	73 2e                	jae    801d21 <memmove+0x47>
		s += n;
		d += n;
  801cf3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf6:	89 d6                	mov    %edx,%esi
  801cf8:	09 fe                	or     %edi,%esi
  801cfa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d00:	75 13                	jne    801d15 <memmove+0x3b>
  801d02:	f6 c1 03             	test   $0x3,%cl
  801d05:	75 0e                	jne    801d15 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d07:	83 ef 04             	sub    $0x4,%edi
  801d0a:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d0d:	c1 e9 02             	shr    $0x2,%ecx
  801d10:	fd                   	std    
  801d11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d13:	eb 09                	jmp    801d1e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d15:	83 ef 01             	sub    $0x1,%edi
  801d18:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d1b:	fd                   	std    
  801d1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d1e:	fc                   	cld    
  801d1f:	eb 1d                	jmp    801d3e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d21:	89 f2                	mov    %esi,%edx
  801d23:	09 c2                	or     %eax,%edx
  801d25:	f6 c2 03             	test   $0x3,%dl
  801d28:	75 0f                	jne    801d39 <memmove+0x5f>
  801d2a:	f6 c1 03             	test   $0x3,%cl
  801d2d:	75 0a                	jne    801d39 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d2f:	c1 e9 02             	shr    $0x2,%ecx
  801d32:	89 c7                	mov    %eax,%edi
  801d34:	fc                   	cld    
  801d35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d37:	eb 05                	jmp    801d3e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d39:	89 c7                	mov    %eax,%edi
  801d3b:	fc                   	cld    
  801d3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    

00801d42 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d45:	ff 75 10             	pushl  0x10(%ebp)
  801d48:	ff 75 0c             	pushl  0xc(%ebp)
  801d4b:	ff 75 08             	pushl  0x8(%ebp)
  801d4e:	e8 87 ff ff ff       	call   801cda <memmove>
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	56                   	push   %esi
  801d59:	53                   	push   %ebx
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d60:	89 c6                	mov    %eax,%esi
  801d62:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d65:	eb 1a                	jmp    801d81 <memcmp+0x2c>
		if (*s1 != *s2)
  801d67:	0f b6 08             	movzbl (%eax),%ecx
  801d6a:	0f b6 1a             	movzbl (%edx),%ebx
  801d6d:	38 d9                	cmp    %bl,%cl
  801d6f:	74 0a                	je     801d7b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d71:	0f b6 c1             	movzbl %cl,%eax
  801d74:	0f b6 db             	movzbl %bl,%ebx
  801d77:	29 d8                	sub    %ebx,%eax
  801d79:	eb 0f                	jmp    801d8a <memcmp+0x35>
		s1++, s2++;
  801d7b:	83 c0 01             	add    $0x1,%eax
  801d7e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d81:	39 f0                	cmp    %esi,%eax
  801d83:	75 e2                	jne    801d67 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	53                   	push   %ebx
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d95:	89 c1                	mov    %eax,%ecx
  801d97:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9e:	eb 0a                	jmp    801daa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da0:	0f b6 10             	movzbl (%eax),%edx
  801da3:	39 da                	cmp    %ebx,%edx
  801da5:	74 07                	je     801dae <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da7:	83 c0 01             	add    $0x1,%eax
  801daa:	39 c8                	cmp    %ecx,%eax
  801dac:	72 f2                	jb     801da0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dae:	5b                   	pop    %ebx
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	57                   	push   %edi
  801db5:	56                   	push   %esi
  801db6:	53                   	push   %ebx
  801db7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbd:	eb 03                	jmp    801dc2 <strtol+0x11>
		s++;
  801dbf:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc2:	0f b6 01             	movzbl (%ecx),%eax
  801dc5:	3c 20                	cmp    $0x20,%al
  801dc7:	74 f6                	je     801dbf <strtol+0xe>
  801dc9:	3c 09                	cmp    $0x9,%al
  801dcb:	74 f2                	je     801dbf <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dcd:	3c 2b                	cmp    $0x2b,%al
  801dcf:	75 0a                	jne    801ddb <strtol+0x2a>
		s++;
  801dd1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd4:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd9:	eb 11                	jmp    801dec <strtol+0x3b>
  801ddb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de0:	3c 2d                	cmp    $0x2d,%al
  801de2:	75 08                	jne    801dec <strtol+0x3b>
		s++, neg = 1;
  801de4:	83 c1 01             	add    $0x1,%ecx
  801de7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dec:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df2:	75 15                	jne    801e09 <strtol+0x58>
  801df4:	80 39 30             	cmpb   $0x30,(%ecx)
  801df7:	75 10                	jne    801e09 <strtol+0x58>
  801df9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dfd:	75 7c                	jne    801e7b <strtol+0xca>
		s += 2, base = 16;
  801dff:	83 c1 02             	add    $0x2,%ecx
  801e02:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e07:	eb 16                	jmp    801e1f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e09:	85 db                	test   %ebx,%ebx
  801e0b:	75 12                	jne    801e1f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e0d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e12:	80 39 30             	cmpb   $0x30,(%ecx)
  801e15:	75 08                	jne    801e1f <strtol+0x6e>
		s++, base = 8;
  801e17:	83 c1 01             	add    $0x1,%ecx
  801e1a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e24:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e27:	0f b6 11             	movzbl (%ecx),%edx
  801e2a:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e2d:	89 f3                	mov    %esi,%ebx
  801e2f:	80 fb 09             	cmp    $0x9,%bl
  801e32:	77 08                	ja     801e3c <strtol+0x8b>
			dig = *s - '0';
  801e34:	0f be d2             	movsbl %dl,%edx
  801e37:	83 ea 30             	sub    $0x30,%edx
  801e3a:	eb 22                	jmp    801e5e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e3c:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e3f:	89 f3                	mov    %esi,%ebx
  801e41:	80 fb 19             	cmp    $0x19,%bl
  801e44:	77 08                	ja     801e4e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e46:	0f be d2             	movsbl %dl,%edx
  801e49:	83 ea 57             	sub    $0x57,%edx
  801e4c:	eb 10                	jmp    801e5e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e4e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e51:	89 f3                	mov    %esi,%ebx
  801e53:	80 fb 19             	cmp    $0x19,%bl
  801e56:	77 16                	ja     801e6e <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e58:	0f be d2             	movsbl %dl,%edx
  801e5b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e5e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e61:	7d 0b                	jge    801e6e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e63:	83 c1 01             	add    $0x1,%ecx
  801e66:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e6a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e6c:	eb b9                	jmp    801e27 <strtol+0x76>

	if (endptr)
  801e6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e72:	74 0d                	je     801e81 <strtol+0xd0>
		*endptr = (char *) s;
  801e74:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e77:	89 0e                	mov    %ecx,(%esi)
  801e79:	eb 06                	jmp    801e81 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e7b:	85 db                	test   %ebx,%ebx
  801e7d:	74 98                	je     801e17 <strtol+0x66>
  801e7f:	eb 9e                	jmp    801e1f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e81:	89 c2                	mov    %eax,%edx
  801e83:	f7 da                	neg    %edx
  801e85:	85 ff                	test   %edi,%edi
  801e87:	0f 45 c2             	cmovne %edx,%eax
}
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	56                   	push   %esi
  801e93:	53                   	push   %ebx
  801e94:	8b 75 08             	mov    0x8(%ebp),%esi
  801e97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	74 0e                	je     801eaf <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801ea1:	83 ec 0c             	sub    $0xc,%esp
  801ea4:	50                   	push   %eax
  801ea5:	e8 6a e4 ff ff       	call   800314 <sys_ipc_recv>
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	eb 10                	jmp    801ebf <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801eaf:	83 ec 0c             	sub    $0xc,%esp
  801eb2:	68 00 00 00 f0       	push   $0xf0000000
  801eb7:	e8 58 e4 ff ff       	call   800314 <sys_ipc_recv>
  801ebc:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	74 0e                	je     801ed1 <ipc_recv+0x42>
    	*from_env_store = 0;
  801ec3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ec9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801ecf:	eb 24                	jmp    801ef5 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ed1:	85 f6                	test   %esi,%esi
  801ed3:	74 0a                	je     801edf <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ed5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eda:	8b 40 74             	mov    0x74(%eax),%eax
  801edd:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801edf:	85 db                	test   %ebx,%ebx
  801ee1:	74 0a                	je     801eed <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801ee3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee8:	8b 40 78             	mov    0x78(%eax),%eax
  801eeb:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801eed:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801ef5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

00801efc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	57                   	push   %edi
  801f00:	56                   	push   %esi
  801f01:	53                   	push   %ebx
  801f02:	83 ec 0c             	sub    $0xc,%esp
  801f05:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f08:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f0e:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f15:	0f 44 d8             	cmove  %eax,%ebx
  801f18:	eb 1c                	jmp    801f36 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f1a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1d:	74 12                	je     801f31 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f1f:	50                   	push   %eax
  801f20:	68 e0 26 80 00       	push   $0x8026e0
  801f25:	6a 4b                	push   $0x4b
  801f27:	68 f8 26 80 00       	push   $0x8026f8
  801f2c:	e8 b9 f5 ff ff       	call   8014ea <_panic>
        }	
        sys_yield();
  801f31:	e8 0f e2 ff ff       	call   800145 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f36:	ff 75 14             	pushl  0x14(%ebp)
  801f39:	53                   	push   %ebx
  801f3a:	56                   	push   %esi
  801f3b:	57                   	push   %edi
  801f3c:	e8 b0 e3 ff ff       	call   8002f1 <sys_ipc_try_send>
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	85 c0                	test   %eax,%eax
  801f46:	75 d2                	jne    801f1a <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4b:	5b                   	pop    %ebx
  801f4c:	5e                   	pop    %esi
  801f4d:	5f                   	pop    %edi
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f56:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f5e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f64:	8b 52 50             	mov    0x50(%edx),%edx
  801f67:	39 ca                	cmp    %ecx,%edx
  801f69:	75 0d                	jne    801f78 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f6b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f73:	8b 40 48             	mov    0x48(%eax),%eax
  801f76:	eb 0f                	jmp    801f87 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f78:	83 c0 01             	add    $0x1,%eax
  801f7b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f80:	75 d9                	jne    801f5b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    

00801f89 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8f:	89 d0                	mov    %edx,%eax
  801f91:	c1 e8 16             	shr    $0x16,%eax
  801f94:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa0:	f6 c1 01             	test   $0x1,%cl
  801fa3:	74 1d                	je     801fc2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa5:	c1 ea 0c             	shr    $0xc,%edx
  801fa8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801faf:	f6 c2 01             	test   $0x1,%dl
  801fb2:	74 0e                	je     801fc2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb4:	c1 ea 0c             	shr    $0xc,%edx
  801fb7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fbe:	ef 
  801fbf:	0f b7 c0             	movzwl %ax,%eax
}
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    
  801fc4:	66 90                	xchg   %ax,%ax
  801fc6:	66 90                	xchg   %ax,%ax
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
