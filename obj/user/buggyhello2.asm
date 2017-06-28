
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 6f 00 00 00       	call   8000b8 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800059:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800060:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800063:	e8 ce 00 00 00       	call   800136 <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x37>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	56                   	push   %esi
  800089:	53                   	push   %ebx
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 0a 00 00 00       	call   80009e <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a4:	e8 c7 04 00 00       	call   800570 <close_all>
	sys_env_destroy(0);
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 42 00 00 00       	call   8000f5 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c9:	89 c3                	mov    %eax,%ebx
  8000cb:	89 c7                	mov    %eax,%edi
  8000cd:	89 c6                	mov    %eax,%esi
  8000cf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e6:	89 d1                	mov    %edx,%ecx
  8000e8:	89 d3                	mov    %edx,%ebx
  8000ea:	89 d7                	mov    %edx,%edi
  8000ec:	89 d6                	mov    %edx,%esi
  8000ee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	b8 03 00 00 00       	mov    $0x3,%eax
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7e 17                	jle    80012e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	50                   	push   %eax
  80011b:	6a 03                	push   $0x3
  80011d:	68 98 22 80 00       	push   $0x802298
  800122:	6a 23                	push   $0x23
  800124:	68 b5 22 80 00       	push   $0x8022b5
  800129:	e8 cc 13 00 00       	call   8014fa <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 02 00 00 00       	mov    $0x2,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_yield>:

void
sys_yield(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	b8 0b 00 00 00       	mov    $0xb,%eax
  800165:	89 d1                	mov    %edx,%ecx
  800167:	89 d3                	mov    %edx,%ebx
  800169:	89 d7                	mov    %edx,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017d:	be 00 00 00 00       	mov    $0x0,%esi
  800182:	b8 04 00 00 00       	mov    $0x4,%eax
  800187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018a:	8b 55 08             	mov    0x8(%ebp),%edx
  80018d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800190:	89 f7                	mov    %esi,%edi
  800192:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800194:	85 c0                	test   %eax,%eax
  800196:	7e 17                	jle    8001af <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	50                   	push   %eax
  80019c:	6a 04                	push   $0x4
  80019e:	68 98 22 80 00       	push   $0x802298
  8001a3:	6a 23                	push   $0x23
  8001a5:	68 b5 22 80 00       	push   $0x8022b5
  8001aa:	e8 4b 13 00 00       	call   8014fa <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	7e 17                	jle    8001f1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	50                   	push   %eax
  8001de:	6a 05                	push   $0x5
  8001e0:	68 98 22 80 00       	push   $0x802298
  8001e5:	6a 23                	push   $0x23
  8001e7:	68 b5 22 80 00       	push   $0x8022b5
  8001ec:	e8 09 13 00 00       	call   8014fa <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5e                   	pop    %esi
  8001f6:	5f                   	pop    %edi
  8001f7:	5d                   	pop    %ebp
  8001f8:	c3                   	ret    

008001f9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	57                   	push   %edi
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800202:	bb 00 00 00 00       	mov    $0x0,%ebx
  800207:	b8 06 00 00 00       	mov    $0x6,%eax
  80020c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020f:	8b 55 08             	mov    0x8(%ebp),%edx
  800212:	89 df                	mov    %ebx,%edi
  800214:	89 de                	mov    %ebx,%esi
  800216:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800218:	85 c0                	test   %eax,%eax
  80021a:	7e 17                	jle    800233 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	50                   	push   %eax
  800220:	6a 06                	push   $0x6
  800222:	68 98 22 80 00       	push   $0x802298
  800227:	6a 23                	push   $0x23
  800229:	68 b5 22 80 00       	push   $0x8022b5
  80022e:	e8 c7 12 00 00       	call   8014fa <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800236:	5b                   	pop    %ebx
  800237:	5e                   	pop    %esi
  800238:	5f                   	pop    %edi
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	57                   	push   %edi
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800244:	bb 00 00 00 00       	mov    $0x0,%ebx
  800249:	b8 08 00 00 00       	mov    $0x8,%eax
  80024e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800251:	8b 55 08             	mov    0x8(%ebp),%edx
  800254:	89 df                	mov    %ebx,%edi
  800256:	89 de                	mov    %ebx,%esi
  800258:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80025a:	85 c0                	test   %eax,%eax
  80025c:	7e 17                	jle    800275 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	50                   	push   %eax
  800262:	6a 08                	push   $0x8
  800264:	68 98 22 80 00       	push   $0x802298
  800269:	6a 23                	push   $0x23
  80026b:	68 b5 22 80 00       	push   $0x8022b5
  800270:	e8 85 12 00 00       	call   8014fa <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800278:	5b                   	pop    %ebx
  800279:	5e                   	pop    %esi
  80027a:	5f                   	pop    %edi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    

0080027d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	57                   	push   %edi
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
  800283:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028b:	b8 09 00 00 00       	mov    $0x9,%eax
  800290:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800293:	8b 55 08             	mov    0x8(%ebp),%edx
  800296:	89 df                	mov    %ebx,%edi
  800298:	89 de                	mov    %ebx,%esi
  80029a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029c:	85 c0                	test   %eax,%eax
  80029e:	7e 17                	jle    8002b7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a0:	83 ec 0c             	sub    $0xc,%esp
  8002a3:	50                   	push   %eax
  8002a4:	6a 09                	push   $0x9
  8002a6:	68 98 22 80 00       	push   $0x802298
  8002ab:	6a 23                	push   $0x23
  8002ad:	68 b5 22 80 00       	push   $0x8022b5
  8002b2:	e8 43 12 00 00       	call   8014fa <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	57                   	push   %edi
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d8:	89 df                	mov    %ebx,%edi
  8002da:	89 de                	mov    %ebx,%esi
  8002dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 17                	jle    8002f9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0a                	push   $0xa
  8002e8:	68 98 22 80 00       	push   $0x802298
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 b5 22 80 00       	push   $0x8022b5
  8002f4:	e8 01 12 00 00       	call   8014fa <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	57                   	push   %edi
  800305:	56                   	push   %esi
  800306:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800307:	be 00 00 00 00       	mov    $0x0,%esi
  80030c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800311:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80031d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031f:	5b                   	pop    %ebx
  800320:	5e                   	pop    %esi
  800321:	5f                   	pop    %edi
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800332:	b8 0d 00 00 00       	mov    $0xd,%eax
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	89 cb                	mov    %ecx,%ebx
  80033c:	89 cf                	mov    %ecx,%edi
  80033e:	89 ce                	mov    %ecx,%esi
  800340:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800342:	85 c0                	test   %eax,%eax
  800344:	7e 17                	jle    80035d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800346:	83 ec 0c             	sub    $0xc,%esp
  800349:	50                   	push   %eax
  80034a:	6a 0d                	push   $0xd
  80034c:	68 98 22 80 00       	push   $0x802298
  800351:	6a 23                	push   $0x23
  800353:	68 b5 22 80 00       	push   $0x8022b5
  800358:	e8 9d 11 00 00       	call   8014fa <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80035d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	b8 0e 00 00 00       	mov    $0xe,%eax
  800375:	89 d1                	mov    %edx,%ecx
  800377:	89 d3                	mov    %edx,%ebx
  800379:	89 d7                	mov    %edx,%edi
  80037b:	89 d6                	mov    %edx,%esi
  80037d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800394:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800397:	8b 55 08             	mov    0x8(%ebp),%edx
  80039a:	89 df                	mov    %ebx,%edi
  80039c:	89 de                	mov    %ebx,%esi
  80039e:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  8003a0:	5b                   	pop    %ebx
  8003a1:	5e                   	pop    %esi
  8003a2:	5f                   	pop    %edi
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ab:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b0:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d7:	89 c2                	mov    %eax,%edx
  8003d9:	c1 ea 16             	shr    $0x16,%edx
  8003dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e3:	f6 c2 01             	test   $0x1,%dl
  8003e6:	74 11                	je     8003f9 <fd_alloc+0x2d>
  8003e8:	89 c2                	mov    %eax,%edx
  8003ea:	c1 ea 0c             	shr    $0xc,%edx
  8003ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f4:	f6 c2 01             	test   $0x1,%dl
  8003f7:	75 09                	jne    800402 <fd_alloc+0x36>
			*fd_store = fd;
  8003f9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 17                	jmp    800419 <fd_alloc+0x4d>
  800402:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800407:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040c:	75 c9                	jne    8003d7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80040e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800414:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800421:	83 f8 1f             	cmp    $0x1f,%eax
  800424:	77 36                	ja     80045c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800426:	c1 e0 0c             	shl    $0xc,%eax
  800429:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042e:	89 c2                	mov    %eax,%edx
  800430:	c1 ea 16             	shr    $0x16,%edx
  800433:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043a:	f6 c2 01             	test   $0x1,%dl
  80043d:	74 24                	je     800463 <fd_lookup+0x48>
  80043f:	89 c2                	mov    %eax,%edx
  800441:	c1 ea 0c             	shr    $0xc,%edx
  800444:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044b:	f6 c2 01             	test   $0x1,%dl
  80044e:	74 1a                	je     80046a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800450:	8b 55 0c             	mov    0xc(%ebp),%edx
  800453:	89 02                	mov    %eax,(%edx)
	return 0;
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	eb 13                	jmp    80046f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800461:	eb 0c                	jmp    80046f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800468:	eb 05                	jmp    80046f <fd_lookup+0x54>
  80046a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80046f:	5d                   	pop    %ebp
  800470:	c3                   	ret    

00800471 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047a:	ba 40 23 80 00       	mov    $0x802340,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80047f:	eb 13                	jmp    800494 <dev_lookup+0x23>
  800481:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800484:	39 08                	cmp    %ecx,(%eax)
  800486:	75 0c                	jne    800494 <dev_lookup+0x23>
			*dev = devtab[i];
  800488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	eb 2e                	jmp    8004c2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800494:	8b 02                	mov    (%edx),%eax
  800496:	85 c0                	test   %eax,%eax
  800498:	75 e7                	jne    800481 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80049a:	a1 08 40 80 00       	mov    0x804008,%eax
  80049f:	8b 40 48             	mov    0x48(%eax),%eax
  8004a2:	83 ec 04             	sub    $0x4,%esp
  8004a5:	51                   	push   %ecx
  8004a6:	50                   	push   %eax
  8004a7:	68 c4 22 80 00       	push   $0x8022c4
  8004ac:	e8 22 11 00 00       	call   8015d3 <cprintf>
	*dev = 0;
  8004b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	56                   	push   %esi
  8004c8:	53                   	push   %ebx
  8004c9:	83 ec 10             	sub    $0x10,%esp
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d5:	50                   	push   %eax
  8004d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004dc:	c1 e8 0c             	shr    $0xc,%eax
  8004df:	50                   	push   %eax
  8004e0:	e8 36 ff ff ff       	call   80041b <fd_lookup>
  8004e5:	83 c4 08             	add    $0x8,%esp
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	78 05                	js     8004f1 <fd_close+0x2d>
	    || fd != fd2)
  8004ec:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004ef:	74 0c                	je     8004fd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004f1:	84 db                	test   %bl,%bl
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	0f 44 c2             	cmove  %edx,%eax
  8004fb:	eb 41                	jmp    80053e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800503:	50                   	push   %eax
  800504:	ff 36                	pushl  (%esi)
  800506:	e8 66 ff ff ff       	call   800471 <dev_lookup>
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 1a                	js     80052e <fd_close+0x6a>
		if (dev->dev_close)
  800514:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800517:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80051a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80051f:	85 c0                	test   %eax,%eax
  800521:	74 0b                	je     80052e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800523:	83 ec 0c             	sub    $0xc,%esp
  800526:	56                   	push   %esi
  800527:	ff d0                	call   *%eax
  800529:	89 c3                	mov    %eax,%ebx
  80052b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	56                   	push   %esi
  800532:	6a 00                	push   $0x0
  800534:	e8 c0 fc ff ff       	call   8001f9 <sys_page_unmap>
	return r;
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	89 d8                	mov    %ebx,%eax
}
  80053e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800541:	5b                   	pop    %ebx
  800542:	5e                   	pop    %esi
  800543:	5d                   	pop    %ebp
  800544:	c3                   	ret    

00800545 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 c4 fe ff ff       	call   80041b <fd_lookup>
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	78 10                	js     80056e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	6a 01                	push   $0x1
  800563:	ff 75 f4             	pushl  -0xc(%ebp)
  800566:	e8 59 ff ff ff       	call   8004c4 <fd_close>
  80056b:	83 c4 10             	add    $0x10,%esp
}
  80056e:	c9                   	leave  
  80056f:	c3                   	ret    

00800570 <close_all>:

void
close_all(void)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	53                   	push   %ebx
  800574:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800577:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057c:	83 ec 0c             	sub    $0xc,%esp
  80057f:	53                   	push   %ebx
  800580:	e8 c0 ff ff ff       	call   800545 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800585:	83 c3 01             	add    $0x1,%ebx
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	83 fb 20             	cmp    $0x20,%ebx
  80058e:	75 ec                	jne    80057c <close_all+0xc>
		close(i);
}
  800590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	57                   	push   %edi
  800599:	56                   	push   %esi
  80059a:	53                   	push   %ebx
  80059b:	83 ec 2c             	sub    $0x2c,%esp
  80059e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a4:	50                   	push   %eax
  8005a5:	ff 75 08             	pushl  0x8(%ebp)
  8005a8:	e8 6e fe ff ff       	call   80041b <fd_lookup>
  8005ad:	83 c4 08             	add    $0x8,%esp
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	0f 88 c1 00 00 00    	js     800679 <dup+0xe4>
		return r;
	close(newfdnum);
  8005b8:	83 ec 0c             	sub    $0xc,%esp
  8005bb:	56                   	push   %esi
  8005bc:	e8 84 ff ff ff       	call   800545 <close>

	newfd = INDEX2FD(newfdnum);
  8005c1:	89 f3                	mov    %esi,%ebx
  8005c3:	c1 e3 0c             	shl    $0xc,%ebx
  8005c6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005cc:	83 c4 04             	add    $0x4,%esp
  8005cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d2:	e8 de fd ff ff       	call   8003b5 <fd2data>
  8005d7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005d9:	89 1c 24             	mov    %ebx,(%esp)
  8005dc:	e8 d4 fd ff ff       	call   8003b5 <fd2data>
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e7:	89 f8                	mov    %edi,%eax
  8005e9:	c1 e8 16             	shr    $0x16,%eax
  8005ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f3:	a8 01                	test   $0x1,%al
  8005f5:	74 37                	je     80062e <dup+0x99>
  8005f7:	89 f8                	mov    %edi,%eax
  8005f9:	c1 e8 0c             	shr    $0xc,%eax
  8005fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800603:	f6 c2 01             	test   $0x1,%dl
  800606:	74 26                	je     80062e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800608:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060f:	83 ec 0c             	sub    $0xc,%esp
  800612:	25 07 0e 00 00       	and    $0xe07,%eax
  800617:	50                   	push   %eax
  800618:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061b:	6a 00                	push   $0x0
  80061d:	57                   	push   %edi
  80061e:	6a 00                	push   $0x0
  800620:	e8 92 fb ff ff       	call   8001b7 <sys_page_map>
  800625:	89 c7                	mov    %eax,%edi
  800627:	83 c4 20             	add    $0x20,%esp
  80062a:	85 c0                	test   %eax,%eax
  80062c:	78 2e                	js     80065c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800631:	89 d0                	mov    %edx,%eax
  800633:	c1 e8 0c             	shr    $0xc,%eax
  800636:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063d:	83 ec 0c             	sub    $0xc,%esp
  800640:	25 07 0e 00 00       	and    $0xe07,%eax
  800645:	50                   	push   %eax
  800646:	53                   	push   %ebx
  800647:	6a 00                	push   $0x0
  800649:	52                   	push   %edx
  80064a:	6a 00                	push   $0x0
  80064c:	e8 66 fb ff ff       	call   8001b7 <sys_page_map>
  800651:	89 c7                	mov    %eax,%edi
  800653:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800656:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800658:	85 ff                	test   %edi,%edi
  80065a:	79 1d                	jns    800679 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 00                	push   $0x0
  800662:	e8 92 fb ff ff       	call   8001f9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066d:	6a 00                	push   $0x0
  80066f:	e8 85 fb ff ff       	call   8001f9 <sys_page_unmap>
	return r;
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	89 f8                	mov    %edi,%eax
}
  800679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067c:	5b                   	pop    %ebx
  80067d:	5e                   	pop    %esi
  80067e:	5f                   	pop    %edi
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	53                   	push   %ebx
  800685:	83 ec 14             	sub    $0x14,%esp
  800688:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80068e:	50                   	push   %eax
  80068f:	53                   	push   %ebx
  800690:	e8 86 fd ff ff       	call   80041b <fd_lookup>
  800695:	83 c4 08             	add    $0x8,%esp
  800698:	89 c2                	mov    %eax,%edx
  80069a:	85 c0                	test   %eax,%eax
  80069c:	78 6d                	js     80070b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a8:	ff 30                	pushl  (%eax)
  8006aa:	e8 c2 fd ff ff       	call   800471 <dev_lookup>
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	78 4c                	js     800702 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b9:	8b 42 08             	mov    0x8(%edx),%eax
  8006bc:	83 e0 03             	and    $0x3,%eax
  8006bf:	83 f8 01             	cmp    $0x1,%eax
  8006c2:	75 21                	jne    8006e5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c4:	a1 08 40 80 00       	mov    0x804008,%eax
  8006c9:	8b 40 48             	mov    0x48(%eax),%eax
  8006cc:	83 ec 04             	sub    $0x4,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	50                   	push   %eax
  8006d1:	68 05 23 80 00       	push   $0x802305
  8006d6:	e8 f8 0e 00 00       	call   8015d3 <cprintf>
		return -E_INVAL;
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006e3:	eb 26                	jmp    80070b <read+0x8a>
	}
	if (!dev->dev_read)
  8006e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e8:	8b 40 08             	mov    0x8(%eax),%eax
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	74 17                	je     800706 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ef:	83 ec 04             	sub    $0x4,%esp
  8006f2:	ff 75 10             	pushl  0x10(%ebp)
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	52                   	push   %edx
  8006f9:	ff d0                	call   *%eax
  8006fb:	89 c2                	mov    %eax,%edx
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 09                	jmp    80070b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800702:	89 c2                	mov    %eax,%edx
  800704:	eb 05                	jmp    80070b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800706:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80070b:	89 d0                	mov    %edx,%eax
  80070d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	57                   	push   %edi
  800716:	56                   	push   %esi
  800717:	53                   	push   %ebx
  800718:	83 ec 0c             	sub    $0xc,%esp
  80071b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800721:	bb 00 00 00 00       	mov    $0x0,%ebx
  800726:	eb 21                	jmp    800749 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800728:	83 ec 04             	sub    $0x4,%esp
  80072b:	89 f0                	mov    %esi,%eax
  80072d:	29 d8                	sub    %ebx,%eax
  80072f:	50                   	push   %eax
  800730:	89 d8                	mov    %ebx,%eax
  800732:	03 45 0c             	add    0xc(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	57                   	push   %edi
  800737:	e8 45 ff ff ff       	call   800681 <read>
		if (m < 0)
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 c0                	test   %eax,%eax
  800741:	78 10                	js     800753 <readn+0x41>
			return m;
		if (m == 0)
  800743:	85 c0                	test   %eax,%eax
  800745:	74 0a                	je     800751 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800747:	01 c3                	add    %eax,%ebx
  800749:	39 f3                	cmp    %esi,%ebx
  80074b:	72 db                	jb     800728 <readn+0x16>
  80074d:	89 d8                	mov    %ebx,%eax
  80074f:	eb 02                	jmp    800753 <readn+0x41>
  800751:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800753:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800756:	5b                   	pop    %ebx
  800757:	5e                   	pop    %esi
  800758:	5f                   	pop    %edi
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	83 ec 14             	sub    $0x14,%esp
  800762:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800765:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	53                   	push   %ebx
  80076a:	e8 ac fc ff ff       	call   80041b <fd_lookup>
  80076f:	83 c4 08             	add    $0x8,%esp
  800772:	89 c2                	mov    %eax,%edx
  800774:	85 c0                	test   %eax,%eax
  800776:	78 68                	js     8007e0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800782:	ff 30                	pushl  (%eax)
  800784:	e8 e8 fc ff ff       	call   800471 <dev_lookup>
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	85 c0                	test   %eax,%eax
  80078e:	78 47                	js     8007d7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800793:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800797:	75 21                	jne    8007ba <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800799:	a1 08 40 80 00       	mov    0x804008,%eax
  80079e:	8b 40 48             	mov    0x48(%eax),%eax
  8007a1:	83 ec 04             	sub    $0x4,%esp
  8007a4:	53                   	push   %ebx
  8007a5:	50                   	push   %eax
  8007a6:	68 21 23 80 00       	push   $0x802321
  8007ab:	e8 23 0e 00 00       	call   8015d3 <cprintf>
		return -E_INVAL;
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007b8:	eb 26                	jmp    8007e0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	74 17                	je     8007db <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c4:	83 ec 04             	sub    $0x4,%esp
  8007c7:	ff 75 10             	pushl  0x10(%ebp)
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	50                   	push   %eax
  8007ce:	ff d2                	call   *%edx
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	eb 09                	jmp    8007e0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	89 c2                	mov    %eax,%edx
  8007d9:	eb 05                	jmp    8007e0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007e0:	89 d0                	mov    %edx,%eax
  8007e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ed:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007f0:	50                   	push   %eax
  8007f1:	ff 75 08             	pushl  0x8(%ebp)
  8007f4:	e8 22 fc ff ff       	call   80041b <fd_lookup>
  8007f9:	83 c4 08             	add    $0x8,%esp
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	78 0e                	js     80080e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800800:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	83 ec 14             	sub    $0x14,%esp
  800817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	53                   	push   %ebx
  80081f:	e8 f7 fb ff ff       	call   80041b <fd_lookup>
  800824:	83 c4 08             	add    $0x8,%esp
  800827:	89 c2                	mov    %eax,%edx
  800829:	85 c0                	test   %eax,%eax
  80082b:	78 65                	js     800892 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800833:	50                   	push   %eax
  800834:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800837:	ff 30                	pushl  (%eax)
  800839:	e8 33 fc ff ff       	call   800471 <dev_lookup>
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	85 c0                	test   %eax,%eax
  800843:	78 44                	js     800889 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800848:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80084c:	75 21                	jne    80086f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80084e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800853:	8b 40 48             	mov    0x48(%eax),%eax
  800856:	83 ec 04             	sub    $0x4,%esp
  800859:	53                   	push   %ebx
  80085a:	50                   	push   %eax
  80085b:	68 e4 22 80 00       	push   $0x8022e4
  800860:	e8 6e 0d 00 00       	call   8015d3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80086d:	eb 23                	jmp    800892 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80086f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800872:	8b 52 18             	mov    0x18(%edx),%edx
  800875:	85 d2                	test   %edx,%edx
  800877:	74 14                	je     80088d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	ff 75 0c             	pushl  0xc(%ebp)
  80087f:	50                   	push   %eax
  800880:	ff d2                	call   *%edx
  800882:	89 c2                	mov    %eax,%edx
  800884:	83 c4 10             	add    $0x10,%esp
  800887:	eb 09                	jmp    800892 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800889:	89 c2                	mov    %eax,%edx
  80088b:	eb 05                	jmp    800892 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80088d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800892:	89 d0                	mov    %edx,%eax
  800894:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	83 ec 14             	sub    $0x14,%esp
  8008a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a6:	50                   	push   %eax
  8008a7:	ff 75 08             	pushl  0x8(%ebp)
  8008aa:	e8 6c fb ff ff       	call   80041b <fd_lookup>
  8008af:	83 c4 08             	add    $0x8,%esp
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	85 c0                	test   %eax,%eax
  8008b6:	78 58                	js     800910 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008be:	50                   	push   %eax
  8008bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c2:	ff 30                	pushl  (%eax)
  8008c4:	e8 a8 fb ff ff       	call   800471 <dev_lookup>
  8008c9:	83 c4 10             	add    $0x10,%esp
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 37                	js     800907 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d7:	74 32                	je     80090b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008dc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e3:	00 00 00 
	stat->st_isdir = 0;
  8008e6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ed:	00 00 00 
	stat->st_dev = dev;
  8008f0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8008fd:	ff 50 14             	call   *0x14(%eax)
  800900:	89 c2                	mov    %eax,%edx
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 09                	jmp    800910 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800907:	89 c2                	mov    %eax,%edx
  800909:	eb 05                	jmp    800910 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80090b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800910:	89 d0                	mov    %edx,%eax
  800912:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	6a 00                	push   $0x0
  800921:	ff 75 08             	pushl  0x8(%ebp)
  800924:	e8 e7 01 00 00       	call   800b10 <open>
  800929:	89 c3                	mov    %eax,%ebx
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	85 c0                	test   %eax,%eax
  800930:	78 1b                	js     80094d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800932:	83 ec 08             	sub    $0x8,%esp
  800935:	ff 75 0c             	pushl  0xc(%ebp)
  800938:	50                   	push   %eax
  800939:	e8 5b ff ff ff       	call   800899 <fstat>
  80093e:	89 c6                	mov    %eax,%esi
	close(fd);
  800940:	89 1c 24             	mov    %ebx,(%esp)
  800943:	e8 fd fb ff ff       	call   800545 <close>
	return r;
  800948:	83 c4 10             	add    $0x10,%esp
  80094b:	89 f0                	mov    %esi,%eax
}
  80094d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	89 c6                	mov    %eax,%esi
  80095b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80095d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800964:	75 12                	jne    800978 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800966:	83 ec 0c             	sub    $0xc,%esp
  800969:	6a 01                	push   $0x1
  80096b:	e8 f0 15 00 00       	call   801f60 <ipc_find_env>
  800970:	a3 00 40 80 00       	mov    %eax,0x804000
  800975:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800978:	6a 07                	push   $0x7
  80097a:	68 00 50 80 00       	push   $0x805000
  80097f:	56                   	push   %esi
  800980:	ff 35 00 40 80 00    	pushl  0x804000
  800986:	e8 81 15 00 00       	call   801f0c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80098b:	83 c4 0c             	add    $0xc,%esp
  80098e:	6a 00                	push   $0x0
  800990:	53                   	push   %ebx
  800991:	6a 00                	push   $0x0
  800993:	e8 07 15 00 00       	call   801e9f <ipc_recv>
}
  800998:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	b8 02 00 00 00       	mov    $0x2,%eax
  8009c2:	e8 8d ff ff ff       	call   800954 <fsipc>
}
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009da:	ba 00 00 00 00       	mov    $0x0,%edx
  8009df:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e4:	e8 6b ff ff ff       	call   800954 <fsipc>
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	83 ec 04             	sub    $0x4,%esp
  8009f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a00:	ba 00 00 00 00       	mov    $0x0,%edx
  800a05:	b8 05 00 00 00       	mov    $0x5,%eax
  800a0a:	e8 45 ff ff ff       	call   800954 <fsipc>
  800a0f:	85 c0                	test   %eax,%eax
  800a11:	78 2c                	js     800a3f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	68 00 50 80 00       	push   $0x805000
  800a1b:	53                   	push   %ebx
  800a1c:	e8 37 11 00 00       	call   801b58 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a21:	a1 80 50 80 00       	mov    0x805080,%eax
  800a26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a2c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a31:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a37:	83 c4 10             	add    $0x10,%esp
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	53                   	push   %ebx
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800a4e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a53:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a58:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a5b:	53                   	push   %ebx
  800a5c:	ff 75 0c             	pushl  0xc(%ebp)
  800a5f:	68 08 50 80 00       	push   $0x805008
  800a64:	e8 81 12 00 00       	call   801cea <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6f:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800a74:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800a7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a84:	e8 cb fe ff ff       	call   800954 <fsipc>
	//panic("devfile_write not implemented");
}
  800a89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab1:	e8 9e fe ff ff       	call   800954 <fsipc>
  800ab6:	89 c3                	mov    %eax,%ebx
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	78 4b                	js     800b07 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800abc:	39 c6                	cmp    %eax,%esi
  800abe:	73 16                	jae    800ad6 <devfile_read+0x48>
  800ac0:	68 54 23 80 00       	push   $0x802354
  800ac5:	68 5b 23 80 00       	push   $0x80235b
  800aca:	6a 7c                	push   $0x7c
  800acc:	68 70 23 80 00       	push   $0x802370
  800ad1:	e8 24 0a 00 00       	call   8014fa <_panic>
	assert(r <= PGSIZE);
  800ad6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800adb:	7e 16                	jle    800af3 <devfile_read+0x65>
  800add:	68 7b 23 80 00       	push   $0x80237b
  800ae2:	68 5b 23 80 00       	push   $0x80235b
  800ae7:	6a 7d                	push   $0x7d
  800ae9:	68 70 23 80 00       	push   $0x802370
  800aee:	e8 07 0a 00 00       	call   8014fa <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800af3:	83 ec 04             	sub    $0x4,%esp
  800af6:	50                   	push   %eax
  800af7:	68 00 50 80 00       	push   $0x805000
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	e8 e6 11 00 00       	call   801cea <memmove>
	return r;
  800b04:	83 c4 10             	add    $0x10,%esp
}
  800b07:	89 d8                	mov    %ebx,%eax
  800b09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	53                   	push   %ebx
  800b14:	83 ec 20             	sub    $0x20,%esp
  800b17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b1a:	53                   	push   %ebx
  800b1b:	e8 ff 0f 00 00       	call   801b1f <strlen>
  800b20:	83 c4 10             	add    $0x10,%esp
  800b23:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b28:	7f 67                	jg     800b91 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b30:	50                   	push   %eax
  800b31:	e8 96 f8 ff ff       	call   8003cc <fd_alloc>
  800b36:	83 c4 10             	add    $0x10,%esp
		return r;
  800b39:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	78 57                	js     800b96 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	53                   	push   %ebx
  800b43:	68 00 50 80 00       	push   $0x805000
  800b48:	e8 0b 10 00 00       	call   801b58 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b58:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5d:	e8 f2 fd ff ff       	call   800954 <fsipc>
  800b62:	89 c3                	mov    %eax,%ebx
  800b64:	83 c4 10             	add    $0x10,%esp
  800b67:	85 c0                	test   %eax,%eax
  800b69:	79 14                	jns    800b7f <open+0x6f>
		fd_close(fd, 0);
  800b6b:	83 ec 08             	sub    $0x8,%esp
  800b6e:	6a 00                	push   $0x0
  800b70:	ff 75 f4             	pushl  -0xc(%ebp)
  800b73:	e8 4c f9 ff ff       	call   8004c4 <fd_close>
		return r;
  800b78:	83 c4 10             	add    $0x10,%esp
  800b7b:	89 da                	mov    %ebx,%edx
  800b7d:	eb 17                	jmp    800b96 <open+0x86>
	}

	return fd2num(fd);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	ff 75 f4             	pushl  -0xc(%ebp)
  800b85:	e8 1b f8 ff ff       	call   8003a5 <fd2num>
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	eb 05                	jmp    800b96 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b91:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b96:	89 d0                	mov    %edx,%eax
  800b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bad:	e8 a2 fd ff ff       	call   800954 <fsipc>
}
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bba:	68 87 23 80 00       	push   $0x802387
  800bbf:	ff 75 0c             	pushl  0xc(%ebp)
  800bc2:	e8 91 0f 00 00       	call   801b58 <strcpy>
	return 0;
}
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 10             	sub    $0x10,%esp
  800bd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bd8:	53                   	push   %ebx
  800bd9:	e8 bb 13 00 00       	call   801f99 <pageref>
  800bde:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800be6:	83 f8 01             	cmp    $0x1,%eax
  800be9:	75 10                	jne    800bfb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	ff 73 0c             	pushl  0xc(%ebx)
  800bf1:	e8 c0 02 00 00       	call   800eb6 <nsipc_close>
  800bf6:	89 c2                	mov    %eax,%edx
  800bf8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bfb:	89 d0                	mov    %edx,%eax
  800bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c08:	6a 00                	push   $0x0
  800c0a:	ff 75 10             	pushl  0x10(%ebp)
  800c0d:	ff 75 0c             	pushl  0xc(%ebp)
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
  800c13:	ff 70 0c             	pushl  0xc(%eax)
  800c16:	e8 78 03 00 00       	call   800f93 <nsipc_send>
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c23:	6a 00                	push   $0x0
  800c25:	ff 75 10             	pushl  0x10(%ebp)
  800c28:	ff 75 0c             	pushl  0xc(%ebp)
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	ff 70 0c             	pushl  0xc(%eax)
  800c31:	e8 f1 02 00 00       	call   800f27 <nsipc_recv>
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c3e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c41:	52                   	push   %edx
  800c42:	50                   	push   %eax
  800c43:	e8 d3 f7 ff ff       	call   80041b <fd_lookup>
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	78 17                	js     800c66 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c52:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800c58:	39 08                	cmp    %ecx,(%eax)
  800c5a:	75 05                	jne    800c61 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c5c:	8b 40 0c             	mov    0xc(%eax),%eax
  800c5f:	eb 05                	jmp    800c66 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c61:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 1c             	sub    $0x1c,%esp
  800c70:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c75:	50                   	push   %eax
  800c76:	e8 51 f7 ff ff       	call   8003cc <fd_alloc>
  800c7b:	89 c3                	mov    %eax,%ebx
  800c7d:	83 c4 10             	add    $0x10,%esp
  800c80:	85 c0                	test   %eax,%eax
  800c82:	78 1b                	js     800c9f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c84:	83 ec 04             	sub    $0x4,%esp
  800c87:	68 07 04 00 00       	push   $0x407
  800c8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800c8f:	6a 00                	push   $0x0
  800c91:	e8 de f4 ff ff       	call   800174 <sys_page_alloc>
  800c96:	89 c3                	mov    %eax,%ebx
  800c98:	83 c4 10             	add    $0x10,%esp
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	79 10                	jns    800caf <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	56                   	push   %esi
  800ca3:	e8 0e 02 00 00       	call   800eb6 <nsipc_close>
		return r;
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	89 d8                	mov    %ebx,%eax
  800cad:	eb 24                	jmp    800cd3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800caf:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cc4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	e8 d5 f6 ff ff       	call   8003a5 <fd2num>
  800cd0:	83 c4 10             	add    $0x10,%esp
}
  800cd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	e8 50 ff ff ff       	call   800c38 <fd2sockid>
		return r;
  800ce8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	78 1f                	js     800d0d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cee:	83 ec 04             	sub    $0x4,%esp
  800cf1:	ff 75 10             	pushl  0x10(%ebp)
  800cf4:	ff 75 0c             	pushl  0xc(%ebp)
  800cf7:	50                   	push   %eax
  800cf8:	e8 12 01 00 00       	call   800e0f <nsipc_accept>
  800cfd:	83 c4 10             	add    $0x10,%esp
		return r;
  800d00:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	78 07                	js     800d0d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d06:	e8 5d ff ff ff       	call   800c68 <alloc_sockfd>
  800d0b:	89 c1                	mov    %eax,%ecx
}
  800d0d:	89 c8                	mov    %ecx,%eax
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    

00800d11 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	e8 19 ff ff ff       	call   800c38 <fd2sockid>
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 12                	js     800d35 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d23:	83 ec 04             	sub    $0x4,%esp
  800d26:	ff 75 10             	pushl  0x10(%ebp)
  800d29:	ff 75 0c             	pushl  0xc(%ebp)
  800d2c:	50                   	push   %eax
  800d2d:	e8 2d 01 00 00       	call   800e5f <nsipc_bind>
  800d32:	83 c4 10             	add    $0x10,%esp
}
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <shutdown>:

int
shutdown(int s, int how)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	e8 f3 fe ff ff       	call   800c38 <fd2sockid>
  800d45:	85 c0                	test   %eax,%eax
  800d47:	78 0f                	js     800d58 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d49:	83 ec 08             	sub    $0x8,%esp
  800d4c:	ff 75 0c             	pushl  0xc(%ebp)
  800d4f:	50                   	push   %eax
  800d50:	e8 3f 01 00 00       	call   800e94 <nsipc_shutdown>
  800d55:	83 c4 10             	add    $0x10,%esp
}
  800d58:	c9                   	leave  
  800d59:	c3                   	ret    

00800d5a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	e8 d0 fe ff ff       	call   800c38 <fd2sockid>
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	78 12                	js     800d7e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	ff 75 10             	pushl  0x10(%ebp)
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	50                   	push   %eax
  800d76:	e8 55 01 00 00       	call   800ed0 <nsipc_connect>
  800d7b:	83 c4 10             	add    $0x10,%esp
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <listen>:

int
listen(int s, int backlog)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	e8 aa fe ff ff       	call   800c38 <fd2sockid>
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	78 0f                	js     800da1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d92:	83 ec 08             	sub    $0x8,%esp
  800d95:	ff 75 0c             	pushl  0xc(%ebp)
  800d98:	50                   	push   %eax
  800d99:	e8 67 01 00 00       	call   800f05 <nsipc_listen>
  800d9e:	83 c4 10             	add    $0x10,%esp
}
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    

00800da3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800da9:	ff 75 10             	pushl  0x10(%ebp)
  800dac:	ff 75 0c             	pushl  0xc(%ebp)
  800daf:	ff 75 08             	pushl  0x8(%ebp)
  800db2:	e8 3a 02 00 00       	call   800ff1 <nsipc_socket>
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	78 05                	js     800dc3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dbe:	e8 a5 fe ff ff       	call   800c68 <alloc_sockfd>
}
  800dc3:	c9                   	leave  
  800dc4:	c3                   	ret    

00800dc5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dce:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dd5:	75 12                	jne    800de9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	6a 02                	push   $0x2
  800ddc:	e8 7f 11 00 00       	call   801f60 <ipc_find_env>
  800de1:	a3 04 40 80 00       	mov    %eax,0x804004
  800de6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800de9:	6a 07                	push   $0x7
  800deb:	68 00 60 80 00       	push   $0x806000
  800df0:	53                   	push   %ebx
  800df1:	ff 35 04 40 80 00    	pushl  0x804004
  800df7:	e8 10 11 00 00       	call   801f0c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dfc:	83 c4 0c             	add    $0xc,%esp
  800dff:	6a 00                	push   $0x0
  800e01:	6a 00                	push   $0x0
  800e03:	6a 00                	push   $0x0
  800e05:	e8 95 10 00 00       	call   801e9f <ipc_recv>
}
  800e0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e0d:	c9                   	leave  
  800e0e:	c3                   	ret    

00800e0f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e1f:	8b 06                	mov    (%esi),%eax
  800e21:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e26:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2b:	e8 95 ff ff ff       	call   800dc5 <nsipc>
  800e30:	89 c3                	mov    %eax,%ebx
  800e32:	85 c0                	test   %eax,%eax
  800e34:	78 20                	js     800e56 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	ff 35 10 60 80 00    	pushl  0x806010
  800e3f:	68 00 60 80 00       	push   $0x806000
  800e44:	ff 75 0c             	pushl  0xc(%ebp)
  800e47:	e8 9e 0e 00 00       	call   801cea <memmove>
		*addrlen = ret->ret_addrlen;
  800e4c:	a1 10 60 80 00       	mov    0x806010,%eax
  800e51:	89 06                	mov    %eax,(%esi)
  800e53:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e56:	89 d8                	mov    %ebx,%eax
  800e58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	53                   	push   %ebx
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e71:	53                   	push   %ebx
  800e72:	ff 75 0c             	pushl  0xc(%ebp)
  800e75:	68 04 60 80 00       	push   $0x806004
  800e7a:	e8 6b 0e 00 00       	call   801cea <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e7f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e85:	b8 02 00 00 00       	mov    $0x2,%eax
  800e8a:	e8 36 ff ff ff       	call   800dc5 <nsipc>
}
  800e8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800eaa:	b8 03 00 00 00       	mov    $0x3,%eax
  800eaf:	e8 11 ff ff ff       	call   800dc5 <nsipc>
}
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <nsipc_close>:

int
nsipc_close(int s)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ec4:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec9:	e8 f7 fe ff ff       	call   800dc5 <nsipc>
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
  800edd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ee2:	53                   	push   %ebx
  800ee3:	ff 75 0c             	pushl  0xc(%ebp)
  800ee6:	68 04 60 80 00       	push   $0x806004
  800eeb:	e8 fa 0d 00 00       	call   801cea <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ef0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ef6:	b8 05 00 00 00       	mov    $0x5,%eax
  800efb:	e8 c5 fe ff ff       	call   800dc5 <nsipc>
}
  800f00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f16:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f1b:	b8 06 00 00 00       	mov    $0x6,%eax
  800f20:	e8 a0 fe ff ff       	call   800dc5 <nsipc>
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f37:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800f40:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f45:	b8 07 00 00 00       	mov    $0x7,%eax
  800f4a:	e8 76 fe ff ff       	call   800dc5 <nsipc>
  800f4f:	89 c3                	mov    %eax,%ebx
  800f51:	85 c0                	test   %eax,%eax
  800f53:	78 35                	js     800f8a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f55:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f5a:	7f 04                	jg     800f60 <nsipc_recv+0x39>
  800f5c:	39 c6                	cmp    %eax,%esi
  800f5e:	7d 16                	jge    800f76 <nsipc_recv+0x4f>
  800f60:	68 93 23 80 00       	push   $0x802393
  800f65:	68 5b 23 80 00       	push   $0x80235b
  800f6a:	6a 62                	push   $0x62
  800f6c:	68 a8 23 80 00       	push   $0x8023a8
  800f71:	e8 84 05 00 00       	call   8014fa <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	50                   	push   %eax
  800f7a:	68 00 60 80 00       	push   $0x806000
  800f7f:	ff 75 0c             	pushl  0xc(%ebp)
  800f82:	e8 63 0d 00 00       	call   801cea <memmove>
  800f87:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f8a:	89 d8                	mov    %ebx,%eax
  800f8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	53                   	push   %ebx
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fa5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fab:	7e 16                	jle    800fc3 <nsipc_send+0x30>
  800fad:	68 b4 23 80 00       	push   $0x8023b4
  800fb2:	68 5b 23 80 00       	push   $0x80235b
  800fb7:	6a 6d                	push   $0x6d
  800fb9:	68 a8 23 80 00       	push   $0x8023a8
  800fbe:	e8 37 05 00 00       	call   8014fa <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fc3:	83 ec 04             	sub    $0x4,%esp
  800fc6:	53                   	push   %ebx
  800fc7:	ff 75 0c             	pushl  0xc(%ebp)
  800fca:	68 0c 60 80 00       	push   $0x80600c
  800fcf:	e8 16 0d 00 00       	call   801cea <memmove>
	nsipcbuf.send.req_size = size;
  800fd4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fda:	8b 45 14             	mov    0x14(%ebp),%eax
  800fdd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fe2:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe7:	e8 d9 fd ff ff       	call   800dc5 <nsipc>
}
  800fec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801002:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801007:	8b 45 10             	mov    0x10(%ebp),%eax
  80100a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80100f:	b8 09 00 00 00       	mov    $0x9,%eax
  801014:	e8 ac fd ff ff       	call   800dc5 <nsipc>
}
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	ff 75 08             	pushl  0x8(%ebp)
  801029:	e8 87 f3 ff ff       	call   8003b5 <fd2data>
  80102e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801030:	83 c4 08             	add    $0x8,%esp
  801033:	68 c0 23 80 00       	push   $0x8023c0
  801038:	53                   	push   %ebx
  801039:	e8 1a 0b 00 00       	call   801b58 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80103e:	8b 46 04             	mov    0x4(%esi),%eax
  801041:	2b 06                	sub    (%esi),%eax
  801043:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801049:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801050:	00 00 00 
	stat->st_dev = &devpipe;
  801053:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  80105a:	30 80 00 
	return 0;
}
  80105d:	b8 00 00 00 00       	mov    $0x0,%eax
  801062:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	53                   	push   %ebx
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801073:	53                   	push   %ebx
  801074:	6a 00                	push   $0x0
  801076:	e8 7e f1 ff ff       	call   8001f9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80107b:	89 1c 24             	mov    %ebx,(%esp)
  80107e:	e8 32 f3 ff ff       	call   8003b5 <fd2data>
  801083:	83 c4 08             	add    $0x8,%esp
  801086:	50                   	push   %eax
  801087:	6a 00                	push   $0x0
  801089:	e8 6b f1 ff ff       	call   8001f9 <sys_page_unmap>
}
  80108e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801091:	c9                   	leave  
  801092:	c3                   	ret    

00801093 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	83 ec 1c             	sub    $0x1c,%esp
  80109c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80109f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8010af:	e8 e5 0e 00 00       	call   801f99 <pageref>
  8010b4:	89 c3                	mov    %eax,%ebx
  8010b6:	89 3c 24             	mov    %edi,(%esp)
  8010b9:	e8 db 0e 00 00       	call   801f99 <pageref>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	39 c3                	cmp    %eax,%ebx
  8010c3:	0f 94 c1             	sete   %cl
  8010c6:	0f b6 c9             	movzbl %cl,%ecx
  8010c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010cc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010d2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010d5:	39 ce                	cmp    %ecx,%esi
  8010d7:	74 1b                	je     8010f4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010d9:	39 c3                	cmp    %eax,%ebx
  8010db:	75 c4                	jne    8010a1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010dd:	8b 42 58             	mov    0x58(%edx),%eax
  8010e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e3:	50                   	push   %eax
  8010e4:	56                   	push   %esi
  8010e5:	68 c7 23 80 00       	push   $0x8023c7
  8010ea:	e8 e4 04 00 00       	call   8015d3 <cprintf>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	eb ad                	jmp    8010a1 <_pipeisclosed+0xe>
	}
}
  8010f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 28             	sub    $0x28,%esp
  801108:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80110b:	56                   	push   %esi
  80110c:	e8 a4 f2 ff ff       	call   8003b5 <fd2data>
  801111:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	bf 00 00 00 00       	mov    $0x0,%edi
  80111b:	eb 4b                	jmp    801168 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80111d:	89 da                	mov    %ebx,%edx
  80111f:	89 f0                	mov    %esi,%eax
  801121:	e8 6d ff ff ff       	call   801093 <_pipeisclosed>
  801126:	85 c0                	test   %eax,%eax
  801128:	75 48                	jne    801172 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80112a:	e8 26 f0 ff ff       	call   800155 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80112f:	8b 43 04             	mov    0x4(%ebx),%eax
  801132:	8b 0b                	mov    (%ebx),%ecx
  801134:	8d 51 20             	lea    0x20(%ecx),%edx
  801137:	39 d0                	cmp    %edx,%eax
  801139:	73 e2                	jae    80111d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80113b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801142:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801145:	89 c2                	mov    %eax,%edx
  801147:	c1 fa 1f             	sar    $0x1f,%edx
  80114a:	89 d1                	mov    %edx,%ecx
  80114c:	c1 e9 1b             	shr    $0x1b,%ecx
  80114f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801152:	83 e2 1f             	and    $0x1f,%edx
  801155:	29 ca                	sub    %ecx,%edx
  801157:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80115b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80115f:	83 c0 01             	add    $0x1,%eax
  801162:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801165:	83 c7 01             	add    $0x1,%edi
  801168:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80116b:	75 c2                	jne    80112f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80116d:	8b 45 10             	mov    0x10(%ebp),%eax
  801170:	eb 05                	jmp    801177 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801172:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801177:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 18             	sub    $0x18,%esp
  801188:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80118b:	57                   	push   %edi
  80118c:	e8 24 f2 ff ff       	call   8003b5 <fd2data>
  801191:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119b:	eb 3d                	jmp    8011da <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80119d:	85 db                	test   %ebx,%ebx
  80119f:	74 04                	je     8011a5 <devpipe_read+0x26>
				return i;
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	eb 44                	jmp    8011e9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011a5:	89 f2                	mov    %esi,%edx
  8011a7:	89 f8                	mov    %edi,%eax
  8011a9:	e8 e5 fe ff ff       	call   801093 <_pipeisclosed>
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	75 32                	jne    8011e4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011b2:	e8 9e ef ff ff       	call   800155 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011b7:	8b 06                	mov    (%esi),%eax
  8011b9:	3b 46 04             	cmp    0x4(%esi),%eax
  8011bc:	74 df                	je     80119d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011be:	99                   	cltd   
  8011bf:	c1 ea 1b             	shr    $0x1b,%edx
  8011c2:	01 d0                	add    %edx,%eax
  8011c4:	83 e0 1f             	and    $0x1f,%eax
  8011c7:	29 d0                	sub    %edx,%eax
  8011c9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011d4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d7:	83 c3 01             	add    $0x1,%ebx
  8011da:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011dd:	75 d8                	jne    8011b7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011df:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e2:	eb 05                	jmp    8011e9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	56                   	push   %esi
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fc:	50                   	push   %eax
  8011fd:	e8 ca f1 ff ff       	call   8003cc <fd_alloc>
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	89 c2                	mov    %eax,%edx
  801207:	85 c0                	test   %eax,%eax
  801209:	0f 88 2c 01 00 00    	js     80133b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	68 07 04 00 00       	push   $0x407
  801217:	ff 75 f4             	pushl  -0xc(%ebp)
  80121a:	6a 00                	push   $0x0
  80121c:	e8 53 ef ff ff       	call   800174 <sys_page_alloc>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	89 c2                	mov    %eax,%edx
  801226:	85 c0                	test   %eax,%eax
  801228:	0f 88 0d 01 00 00    	js     80133b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80122e:	83 ec 0c             	sub    $0xc,%esp
  801231:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	e8 92 f1 ff ff       	call   8003cc <fd_alloc>
  80123a:	89 c3                	mov    %eax,%ebx
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	0f 88 e2 00 00 00    	js     801329 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	68 07 04 00 00       	push   $0x407
  80124f:	ff 75 f0             	pushl  -0x10(%ebp)
  801252:	6a 00                	push   $0x0
  801254:	e8 1b ef ff ff       	call   800174 <sys_page_alloc>
  801259:	89 c3                	mov    %eax,%ebx
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	85 c0                	test   %eax,%eax
  801260:	0f 88 c3 00 00 00    	js     801329 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	ff 75 f4             	pushl  -0xc(%ebp)
  80126c:	e8 44 f1 ff ff       	call   8003b5 <fd2data>
  801271:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801273:	83 c4 0c             	add    $0xc,%esp
  801276:	68 07 04 00 00       	push   $0x407
  80127b:	50                   	push   %eax
  80127c:	6a 00                	push   $0x0
  80127e:	e8 f1 ee ff ff       	call   800174 <sys_page_alloc>
  801283:	89 c3                	mov    %eax,%ebx
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	0f 88 89 00 00 00    	js     801319 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	ff 75 f0             	pushl  -0x10(%ebp)
  801296:	e8 1a f1 ff ff       	call   8003b5 <fd2data>
  80129b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012a2:	50                   	push   %eax
  8012a3:	6a 00                	push   $0x0
  8012a5:	56                   	push   %esi
  8012a6:	6a 00                	push   $0x0
  8012a8:	e8 0a ef ff ff       	call   8001b7 <sys_page_map>
  8012ad:	89 c3                	mov    %eax,%ebx
  8012af:	83 c4 20             	add    $0x20,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 55                	js     80130b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012b6:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012cb:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012e0:	83 ec 0c             	sub    $0xc,%esp
  8012e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e6:	e8 ba f0 ff ff       	call   8003a5 <fd2num>
  8012eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012f0:	83 c4 04             	add    $0x4,%esp
  8012f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f6:	e8 aa f0 ff ff       	call   8003a5 <fd2num>
  8012fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	ba 00 00 00 00       	mov    $0x0,%edx
  801309:	eb 30                	jmp    80133b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	56                   	push   %esi
  80130f:	6a 00                	push   $0x0
  801311:	e8 e3 ee ff ff       	call   8001f9 <sys_page_unmap>
  801316:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	ff 75 f0             	pushl  -0x10(%ebp)
  80131f:	6a 00                	push   $0x0
  801321:	e8 d3 ee ff ff       	call   8001f9 <sys_page_unmap>
  801326:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	ff 75 f4             	pushl  -0xc(%ebp)
  80132f:	6a 00                	push   $0x0
  801331:	e8 c3 ee ff ff       	call   8001f9 <sys_page_unmap>
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801340:	5b                   	pop    %ebx
  801341:	5e                   	pop    %esi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	ff 75 08             	pushl  0x8(%ebp)
  801351:	e8 c5 f0 ff ff       	call   80041b <fd_lookup>
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 18                	js     801375 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80135d:	83 ec 0c             	sub    $0xc,%esp
  801360:	ff 75 f4             	pushl  -0xc(%ebp)
  801363:	e8 4d f0 ff ff       	call   8003b5 <fd2data>
	return _pipeisclosed(fd, p);
  801368:	89 c2                	mov    %eax,%edx
  80136a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136d:	e8 21 fd ff ff       	call   801093 <_pipeisclosed>
  801372:	83 c4 10             	add    $0x10,%esp
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801387:	68 df 23 80 00       	push   $0x8023df
  80138c:	ff 75 0c             	pushl  0xc(%ebp)
  80138f:	e8 c4 07 00 00       	call   801b58 <strcpy>
	return 0;
}
  801394:	b8 00 00 00 00       	mov    $0x0,%eax
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	57                   	push   %edi
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b2:	eb 2d                	jmp    8013e1 <devcons_write+0x46>
		m = n - tot;
  8013b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013b9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013bc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013c1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013c4:	83 ec 04             	sub    $0x4,%esp
  8013c7:	53                   	push   %ebx
  8013c8:	03 45 0c             	add    0xc(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	57                   	push   %edi
  8013cd:	e8 18 09 00 00       	call   801cea <memmove>
		sys_cputs(buf, m);
  8013d2:	83 c4 08             	add    $0x8,%esp
  8013d5:	53                   	push   %ebx
  8013d6:	57                   	push   %edi
  8013d7:	e8 dc ec ff ff       	call   8000b8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013dc:	01 de                	add    %ebx,%esi
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	89 f0                	mov    %esi,%eax
  8013e3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013e6:	72 cc                	jb     8013b4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013eb:	5b                   	pop    %ebx
  8013ec:	5e                   	pop    %esi
  8013ed:	5f                   	pop    %edi
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ff:	74 2a                	je     80142b <devcons_read+0x3b>
  801401:	eb 05                	jmp    801408 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801403:	e8 4d ed ff ff       	call   800155 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801408:	e8 c9 ec ff ff       	call   8000d6 <sys_cgetc>
  80140d:	85 c0                	test   %eax,%eax
  80140f:	74 f2                	je     801403 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801411:	85 c0                	test   %eax,%eax
  801413:	78 16                	js     80142b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801415:	83 f8 04             	cmp    $0x4,%eax
  801418:	74 0c                	je     801426 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80141a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80141d:	88 02                	mov    %al,(%edx)
	return 1;
  80141f:	b8 01 00 00 00       	mov    $0x1,%eax
  801424:	eb 05                	jmp    80142b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801426:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801439:	6a 01                	push   $0x1
  80143b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	e8 74 ec ff ff       	call   8000b8 <sys_cputs>
}
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <getchar>:

int
getchar(void)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80144f:	6a 01                	push   $0x1
  801451:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	6a 00                	push   $0x0
  801457:	e8 25 f2 ff ff       	call   800681 <read>
	if (r < 0)
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 0f                	js     801472 <getchar+0x29>
		return r;
	if (r < 1)
  801463:	85 c0                	test   %eax,%eax
  801465:	7e 06                	jle    80146d <getchar+0x24>
		return -E_EOF;
	return c;
  801467:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80146b:	eb 05                	jmp    801472 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80146d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	ff 75 08             	pushl  0x8(%ebp)
  801481:	e8 95 ef ff ff       	call   80041b <fd_lookup>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 11                	js     80149e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801490:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801496:	39 10                	cmp    %edx,(%eax)
  801498:	0f 94 c0             	sete   %al
  80149b:	0f b6 c0             	movzbl %al,%eax
}
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <opencons>:

int
opencons(void)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	e8 1d ef ff ff       	call   8003cc <fd_alloc>
  8014af:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 3e                	js     8014f6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	68 07 04 00 00       	push   $0x407
  8014c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c3:	6a 00                	push   $0x0
  8014c5:	e8 aa ec ff ff       	call   800174 <sys_page_alloc>
  8014ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8014cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 23                	js     8014f6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014d3:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8014d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	50                   	push   %eax
  8014ec:	e8 b4 ee ff ff       	call   8003a5 <fd2num>
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	83 c4 10             	add    $0x10,%esp
}
  8014f6:	89 d0                	mov    %edx,%eax
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	56                   	push   %esi
  8014fe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ff:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801502:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801508:	e8 29 ec ff ff       	call   800136 <sys_getenvid>
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	ff 75 0c             	pushl  0xc(%ebp)
  801513:	ff 75 08             	pushl  0x8(%ebp)
  801516:	56                   	push   %esi
  801517:	50                   	push   %eax
  801518:	68 ec 23 80 00       	push   $0x8023ec
  80151d:	e8 b1 00 00 00       	call   8015d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801522:	83 c4 18             	add    $0x18,%esp
  801525:	53                   	push   %ebx
  801526:	ff 75 10             	pushl  0x10(%ebp)
  801529:	e8 54 00 00 00       	call   801582 <vcprintf>
	cprintf("\n");
  80152e:	c7 04 24 d8 23 80 00 	movl   $0x8023d8,(%esp)
  801535:	e8 99 00 00 00       	call   8015d3 <cprintf>
  80153a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80153d:	cc                   	int3   
  80153e:	eb fd                	jmp    80153d <_panic+0x43>

00801540 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	53                   	push   %ebx
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80154a:	8b 13                	mov    (%ebx),%edx
  80154c:	8d 42 01             	lea    0x1(%edx),%eax
  80154f:	89 03                	mov    %eax,(%ebx)
  801551:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801554:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801558:	3d ff 00 00 00       	cmp    $0xff,%eax
  80155d:	75 1a                	jne    801579 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	68 ff 00 00 00       	push   $0xff
  801567:	8d 43 08             	lea    0x8(%ebx),%eax
  80156a:	50                   	push   %eax
  80156b:	e8 48 eb ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  801570:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801576:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801579:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80157d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80158b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801592:	00 00 00 
	b.cnt = 0;
  801595:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80159c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80159f:	ff 75 0c             	pushl  0xc(%ebp)
  8015a2:	ff 75 08             	pushl  0x8(%ebp)
  8015a5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	68 40 15 80 00       	push   $0x801540
  8015b1:	e8 54 01 00 00       	call   80170a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015bf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	e8 ed ea ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  8015cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015dc:	50                   	push   %eax
  8015dd:	ff 75 08             	pushl  0x8(%ebp)
  8015e0:	e8 9d ff ff ff       	call   801582 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	57                   	push   %edi
  8015eb:	56                   	push   %esi
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 1c             	sub    $0x1c,%esp
  8015f0:	89 c7                	mov    %eax,%edi
  8015f2:	89 d6                	mov    %edx,%esi
  8015f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801600:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801603:	bb 00 00 00 00       	mov    $0x0,%ebx
  801608:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80160b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80160e:	39 d3                	cmp    %edx,%ebx
  801610:	72 05                	jb     801617 <printnum+0x30>
  801612:	39 45 10             	cmp    %eax,0x10(%ebp)
  801615:	77 45                	ja     80165c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801617:	83 ec 0c             	sub    $0xc,%esp
  80161a:	ff 75 18             	pushl  0x18(%ebp)
  80161d:	8b 45 14             	mov    0x14(%ebp),%eax
  801620:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801623:	53                   	push   %ebx
  801624:	ff 75 10             	pushl  0x10(%ebp)
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162d:	ff 75 e0             	pushl  -0x20(%ebp)
  801630:	ff 75 dc             	pushl  -0x24(%ebp)
  801633:	ff 75 d8             	pushl  -0x28(%ebp)
  801636:	e8 a5 09 00 00       	call   801fe0 <__udivdi3>
  80163b:	83 c4 18             	add    $0x18,%esp
  80163e:	52                   	push   %edx
  80163f:	50                   	push   %eax
  801640:	89 f2                	mov    %esi,%edx
  801642:	89 f8                	mov    %edi,%eax
  801644:	e8 9e ff ff ff       	call   8015e7 <printnum>
  801649:	83 c4 20             	add    $0x20,%esp
  80164c:	eb 18                	jmp    801666 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	56                   	push   %esi
  801652:	ff 75 18             	pushl  0x18(%ebp)
  801655:	ff d7                	call   *%edi
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 03                	jmp    80165f <printnum+0x78>
  80165c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80165f:	83 eb 01             	sub    $0x1,%ebx
  801662:	85 db                	test   %ebx,%ebx
  801664:	7f e8                	jg     80164e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	56                   	push   %esi
  80166a:	83 ec 04             	sub    $0x4,%esp
  80166d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801670:	ff 75 e0             	pushl  -0x20(%ebp)
  801673:	ff 75 dc             	pushl  -0x24(%ebp)
  801676:	ff 75 d8             	pushl  -0x28(%ebp)
  801679:	e8 92 0a 00 00       	call   802110 <__umoddi3>
  80167e:	83 c4 14             	add    $0x14,%esp
  801681:	0f be 80 0f 24 80 00 	movsbl 0x80240f(%eax),%eax
  801688:	50                   	push   %eax
  801689:	ff d7                	call   *%edi
}
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801691:	5b                   	pop    %ebx
  801692:	5e                   	pop    %esi
  801693:	5f                   	pop    %edi
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801699:	83 fa 01             	cmp    $0x1,%edx
  80169c:	7e 0e                	jle    8016ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80169e:	8b 10                	mov    (%eax),%edx
  8016a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016a3:	89 08                	mov    %ecx,(%eax)
  8016a5:	8b 02                	mov    (%edx),%eax
  8016a7:	8b 52 04             	mov    0x4(%edx),%edx
  8016aa:	eb 22                	jmp    8016ce <getuint+0x38>
	else if (lflag)
  8016ac:	85 d2                	test   %edx,%edx
  8016ae:	74 10                	je     8016c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016b0:	8b 10                	mov    (%eax),%edx
  8016b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b5:	89 08                	mov    %ecx,(%eax)
  8016b7:	8b 02                	mov    (%edx),%eax
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016be:	eb 0e                	jmp    8016ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016c0:	8b 10                	mov    (%eax),%edx
  8016c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016c5:	89 08                	mov    %ecx,(%eax)
  8016c7:	8b 02                	mov    (%edx),%eax
  8016c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016da:	8b 10                	mov    (%eax),%edx
  8016dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8016df:	73 0a                	jae    8016eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8016e1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016e4:	89 08                	mov    %ecx,(%eax)
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	88 02                	mov    %al,(%edx)
}
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016f6:	50                   	push   %eax
  8016f7:	ff 75 10             	pushl  0x10(%ebp)
  8016fa:	ff 75 0c             	pushl  0xc(%ebp)
  8016fd:	ff 75 08             	pushl  0x8(%ebp)
  801700:	e8 05 00 00 00       	call   80170a <vprintfmt>
	va_end(ap);
}
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	57                   	push   %edi
  80170e:	56                   	push   %esi
  80170f:	53                   	push   %ebx
  801710:	83 ec 2c             	sub    $0x2c,%esp
  801713:	8b 75 08             	mov    0x8(%ebp),%esi
  801716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801719:	8b 7d 10             	mov    0x10(%ebp),%edi
  80171c:	eb 12                	jmp    801730 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80171e:	85 c0                	test   %eax,%eax
  801720:	0f 84 89 03 00 00    	je     801aaf <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	53                   	push   %ebx
  80172a:	50                   	push   %eax
  80172b:	ff d6                	call   *%esi
  80172d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801730:	83 c7 01             	add    $0x1,%edi
  801733:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801737:	83 f8 25             	cmp    $0x25,%eax
  80173a:	75 e2                	jne    80171e <vprintfmt+0x14>
  80173c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801740:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801747:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80174e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801755:	ba 00 00 00 00       	mov    $0x0,%edx
  80175a:	eb 07                	jmp    801763 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80175f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801763:	8d 47 01             	lea    0x1(%edi),%eax
  801766:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801769:	0f b6 07             	movzbl (%edi),%eax
  80176c:	0f b6 c8             	movzbl %al,%ecx
  80176f:	83 e8 23             	sub    $0x23,%eax
  801772:	3c 55                	cmp    $0x55,%al
  801774:	0f 87 1a 03 00 00    	ja     801a94 <vprintfmt+0x38a>
  80177a:	0f b6 c0             	movzbl %al,%eax
  80177d:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  801784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801787:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80178b:	eb d6                	jmp    801763 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801790:	b8 00 00 00 00       	mov    $0x0,%eax
  801795:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801798:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80179b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80179f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017a2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017a5:	83 fa 09             	cmp    $0x9,%edx
  8017a8:	77 39                	ja     8017e3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017ad:	eb e9                	jmp    801798 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017af:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b2:	8d 48 04             	lea    0x4(%eax),%ecx
  8017b5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017b8:	8b 00                	mov    (%eax),%eax
  8017ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017c0:	eb 27                	jmp    8017e9 <vprintfmt+0xdf>
  8017c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017cc:	0f 49 c8             	cmovns %eax,%ecx
  8017cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017d5:	eb 8c                	jmp    801763 <vprintfmt+0x59>
  8017d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017e1:	eb 80                	jmp    801763 <vprintfmt+0x59>
  8017e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017ed:	0f 89 70 ff ff ff    	jns    801763 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801800:	e9 5e ff ff ff       	jmp    801763 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801805:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801808:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80180b:	e9 53 ff ff ff       	jmp    801763 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801810:	8b 45 14             	mov    0x14(%ebp),%eax
  801813:	8d 50 04             	lea    0x4(%eax),%edx
  801816:	89 55 14             	mov    %edx,0x14(%ebp)
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	53                   	push   %ebx
  80181d:	ff 30                	pushl  (%eax)
  80181f:	ff d6                	call   *%esi
			break;
  801821:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801824:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801827:	e9 04 ff ff ff       	jmp    801730 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80182c:	8b 45 14             	mov    0x14(%ebp),%eax
  80182f:	8d 50 04             	lea    0x4(%eax),%edx
  801832:	89 55 14             	mov    %edx,0x14(%ebp)
  801835:	8b 00                	mov    (%eax),%eax
  801837:	99                   	cltd   
  801838:	31 d0                	xor    %edx,%eax
  80183a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80183c:	83 f8 0f             	cmp    $0xf,%eax
  80183f:	7f 0b                	jg     80184c <vprintfmt+0x142>
  801841:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801848:	85 d2                	test   %edx,%edx
  80184a:	75 18                	jne    801864 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80184c:	50                   	push   %eax
  80184d:	68 27 24 80 00       	push   $0x802427
  801852:	53                   	push   %ebx
  801853:	56                   	push   %esi
  801854:	e8 94 fe ff ff       	call   8016ed <printfmt>
  801859:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80185f:	e9 cc fe ff ff       	jmp    801730 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801864:	52                   	push   %edx
  801865:	68 6d 23 80 00       	push   $0x80236d
  80186a:	53                   	push   %ebx
  80186b:	56                   	push   %esi
  80186c:	e8 7c fe ff ff       	call   8016ed <printfmt>
  801871:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801874:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801877:	e9 b4 fe ff ff       	jmp    801730 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80187c:	8b 45 14             	mov    0x14(%ebp),%eax
  80187f:	8d 50 04             	lea    0x4(%eax),%edx
  801882:	89 55 14             	mov    %edx,0x14(%ebp)
  801885:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801887:	85 ff                	test   %edi,%edi
  801889:	b8 20 24 80 00       	mov    $0x802420,%eax
  80188e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801891:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801895:	0f 8e 94 00 00 00    	jle    80192f <vprintfmt+0x225>
  80189b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80189f:	0f 84 98 00 00 00    	je     80193d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	ff 75 d0             	pushl  -0x30(%ebp)
  8018ab:	57                   	push   %edi
  8018ac:	e8 86 02 00 00       	call   801b37 <strnlen>
  8018b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018b4:	29 c1                	sub    %eax,%ecx
  8018b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018b9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018bc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018c6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c8:	eb 0f                	jmp    8018d9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	53                   	push   %ebx
  8018ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8018d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d3:	83 ef 01             	sub    $0x1,%edi
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	85 ff                	test   %edi,%edi
  8018db:	7f ed                	jg     8018ca <vprintfmt+0x1c0>
  8018dd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018e0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018e3:	85 c9                	test   %ecx,%ecx
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ea:	0f 49 c1             	cmovns %ecx,%eax
  8018ed:	29 c1                	sub    %eax,%ecx
  8018ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f8:	89 cb                	mov    %ecx,%ebx
  8018fa:	eb 4d                	jmp    801949 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018fc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801900:	74 1b                	je     80191d <vprintfmt+0x213>
  801902:	0f be c0             	movsbl %al,%eax
  801905:	83 e8 20             	sub    $0x20,%eax
  801908:	83 f8 5e             	cmp    $0x5e,%eax
  80190b:	76 10                	jbe    80191d <vprintfmt+0x213>
					putch('?', putdat);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	ff 75 0c             	pushl  0xc(%ebp)
  801913:	6a 3f                	push   $0x3f
  801915:	ff 55 08             	call   *0x8(%ebp)
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	eb 0d                	jmp    80192a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	ff 75 0c             	pushl  0xc(%ebp)
  801923:	52                   	push   %edx
  801924:	ff 55 08             	call   *0x8(%ebp)
  801927:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80192a:	83 eb 01             	sub    $0x1,%ebx
  80192d:	eb 1a                	jmp    801949 <vprintfmt+0x23f>
  80192f:	89 75 08             	mov    %esi,0x8(%ebp)
  801932:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801935:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801938:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193b:	eb 0c                	jmp    801949 <vprintfmt+0x23f>
  80193d:	89 75 08             	mov    %esi,0x8(%ebp)
  801940:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801943:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801946:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801949:	83 c7 01             	add    $0x1,%edi
  80194c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801950:	0f be d0             	movsbl %al,%edx
  801953:	85 d2                	test   %edx,%edx
  801955:	74 23                	je     80197a <vprintfmt+0x270>
  801957:	85 f6                	test   %esi,%esi
  801959:	78 a1                	js     8018fc <vprintfmt+0x1f2>
  80195b:	83 ee 01             	sub    $0x1,%esi
  80195e:	79 9c                	jns    8018fc <vprintfmt+0x1f2>
  801960:	89 df                	mov    %ebx,%edi
  801962:	8b 75 08             	mov    0x8(%ebp),%esi
  801965:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801968:	eb 18                	jmp    801982 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	53                   	push   %ebx
  80196e:	6a 20                	push   $0x20
  801970:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801972:	83 ef 01             	sub    $0x1,%edi
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	eb 08                	jmp    801982 <vprintfmt+0x278>
  80197a:	89 df                	mov    %ebx,%edi
  80197c:	8b 75 08             	mov    0x8(%ebp),%esi
  80197f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801982:	85 ff                	test   %edi,%edi
  801984:	7f e4                	jg     80196a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801986:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801989:	e9 a2 fd ff ff       	jmp    801730 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80198e:	83 fa 01             	cmp    $0x1,%edx
  801991:	7e 16                	jle    8019a9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801993:	8b 45 14             	mov    0x14(%ebp),%eax
  801996:	8d 50 08             	lea    0x8(%eax),%edx
  801999:	89 55 14             	mov    %edx,0x14(%ebp)
  80199c:	8b 50 04             	mov    0x4(%eax),%edx
  80199f:	8b 00                	mov    (%eax),%eax
  8019a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a7:	eb 32                	jmp    8019db <vprintfmt+0x2d1>
	else if (lflag)
  8019a9:	85 d2                	test   %edx,%edx
  8019ab:	74 18                	je     8019c5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b0:	8d 50 04             	lea    0x4(%eax),%edx
  8019b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b6:	8b 00                	mov    (%eax),%eax
  8019b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019bb:	89 c1                	mov    %eax,%ecx
  8019bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019c3:	eb 16                	jmp    8019db <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c8:	8d 50 04             	lea    0x4(%eax),%edx
  8019cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ce:	8b 00                	mov    (%eax),%eax
  8019d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d3:	89 c1                	mov    %eax,%ecx
  8019d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8019d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019de:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019ea:	79 74                	jns    801a60 <vprintfmt+0x356>
				putch('-', putdat);
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	53                   	push   %ebx
  8019f0:	6a 2d                	push   $0x2d
  8019f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8019f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019fa:	f7 d8                	neg    %eax
  8019fc:	83 d2 00             	adc    $0x0,%edx
  8019ff:	f7 da                	neg    %edx
  801a01:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a04:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a09:	eb 55                	jmp    801a60 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a0b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0e:	e8 83 fc ff ff       	call   801696 <getuint>
			base = 10;
  801a13:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a18:	eb 46                	jmp    801a60 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a1a:	8d 45 14             	lea    0x14(%ebp),%eax
  801a1d:	e8 74 fc ff ff       	call   801696 <getuint>
		        base = 8;
  801a22:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a27:	eb 37                	jmp    801a60 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	53                   	push   %ebx
  801a2d:	6a 30                	push   $0x30
  801a2f:	ff d6                	call   *%esi
			putch('x', putdat);
  801a31:	83 c4 08             	add    $0x8,%esp
  801a34:	53                   	push   %ebx
  801a35:	6a 78                	push   $0x78
  801a37:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a39:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3c:	8d 50 04             	lea    0x4(%eax),%edx
  801a3f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a42:	8b 00                	mov    (%eax),%eax
  801a44:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a49:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a4c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a51:	eb 0d                	jmp    801a60 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a53:	8d 45 14             	lea    0x14(%ebp),%eax
  801a56:	e8 3b fc ff ff       	call   801696 <getuint>
			base = 16;
  801a5b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a67:	57                   	push   %edi
  801a68:	ff 75 e0             	pushl  -0x20(%ebp)
  801a6b:	51                   	push   %ecx
  801a6c:	52                   	push   %edx
  801a6d:	50                   	push   %eax
  801a6e:	89 da                	mov    %ebx,%edx
  801a70:	89 f0                	mov    %esi,%eax
  801a72:	e8 70 fb ff ff       	call   8015e7 <printnum>
			break;
  801a77:	83 c4 20             	add    $0x20,%esp
  801a7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a7d:	e9 ae fc ff ff       	jmp    801730 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a82:	83 ec 08             	sub    $0x8,%esp
  801a85:	53                   	push   %ebx
  801a86:	51                   	push   %ecx
  801a87:	ff d6                	call   *%esi
			break;
  801a89:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a8c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a8f:	e9 9c fc ff ff       	jmp    801730 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a94:	83 ec 08             	sub    $0x8,%esp
  801a97:	53                   	push   %ebx
  801a98:	6a 25                	push   $0x25
  801a9a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	eb 03                	jmp    801aa4 <vprintfmt+0x39a>
  801aa1:	83 ef 01             	sub    $0x1,%edi
  801aa4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aa8:	75 f7                	jne    801aa1 <vprintfmt+0x397>
  801aaa:	e9 81 fc ff ff       	jmp    801730 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5f                   	pop    %edi
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 18             	sub    $0x18,%esp
  801abd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ac3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ac6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801aca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801acd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	74 26                	je     801afe <vsnprintf+0x47>
  801ad8:	85 d2                	test   %edx,%edx
  801ada:	7e 22                	jle    801afe <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801adc:	ff 75 14             	pushl  0x14(%ebp)
  801adf:	ff 75 10             	pushl  0x10(%ebp)
  801ae2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ae5:	50                   	push   %eax
  801ae6:	68 d0 16 80 00       	push   $0x8016d0
  801aeb:	e8 1a fc ff ff       	call   80170a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801af0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801af3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	eb 05                	jmp    801b03 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801afe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b0b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b0e:	50                   	push   %eax
  801b0f:	ff 75 10             	pushl  0x10(%ebp)
  801b12:	ff 75 0c             	pushl  0xc(%ebp)
  801b15:	ff 75 08             	pushl  0x8(%ebp)
  801b18:	e8 9a ff ff ff       	call   801ab7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2a:	eb 03                	jmp    801b2f <strlen+0x10>
		n++;
  801b2c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b2f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b33:	75 f7                	jne    801b2c <strlen+0xd>
		n++;
	return n;
}
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b40:	ba 00 00 00 00       	mov    $0x0,%edx
  801b45:	eb 03                	jmp    801b4a <strnlen+0x13>
		n++;
  801b47:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b4a:	39 c2                	cmp    %eax,%edx
  801b4c:	74 08                	je     801b56 <strnlen+0x1f>
  801b4e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b52:	75 f3                	jne    801b47 <strnlen+0x10>
  801b54:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	53                   	push   %ebx
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b62:	89 c2                	mov    %eax,%edx
  801b64:	83 c2 01             	add    $0x1,%edx
  801b67:	83 c1 01             	add    $0x1,%ecx
  801b6a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b6e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b71:	84 db                	test   %bl,%bl
  801b73:	75 ef                	jne    801b64 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b75:	5b                   	pop    %ebx
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	53                   	push   %ebx
  801b7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b7f:	53                   	push   %ebx
  801b80:	e8 9a ff ff ff       	call   801b1f <strlen>
  801b85:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b88:	ff 75 0c             	pushl  0xc(%ebp)
  801b8b:	01 d8                	add    %ebx,%eax
  801b8d:	50                   	push   %eax
  801b8e:	e8 c5 ff ff ff       	call   801b58 <strcpy>
	return dst;
}
  801b93:	89 d8                	mov    %ebx,%eax
  801b95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	56                   	push   %esi
  801b9e:	53                   	push   %ebx
  801b9f:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba5:	89 f3                	mov    %esi,%ebx
  801ba7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801baa:	89 f2                	mov    %esi,%edx
  801bac:	eb 0f                	jmp    801bbd <strncpy+0x23>
		*dst++ = *src;
  801bae:	83 c2 01             	add    $0x1,%edx
  801bb1:	0f b6 01             	movzbl (%ecx),%eax
  801bb4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb7:	80 39 01             	cmpb   $0x1,(%ecx)
  801bba:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bbd:	39 da                	cmp    %ebx,%edx
  801bbf:	75 ed                	jne    801bae <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bc1:	89 f0                	mov    %esi,%eax
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5d                   	pop    %ebp
  801bc6:	c3                   	ret    

00801bc7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	56                   	push   %esi
  801bcb:	53                   	push   %ebx
  801bcc:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd2:	8b 55 10             	mov    0x10(%ebp),%edx
  801bd5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd7:	85 d2                	test   %edx,%edx
  801bd9:	74 21                	je     801bfc <strlcpy+0x35>
  801bdb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bdf:	89 f2                	mov    %esi,%edx
  801be1:	eb 09                	jmp    801bec <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801be3:	83 c2 01             	add    $0x1,%edx
  801be6:	83 c1 01             	add    $0x1,%ecx
  801be9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bec:	39 c2                	cmp    %eax,%edx
  801bee:	74 09                	je     801bf9 <strlcpy+0x32>
  801bf0:	0f b6 19             	movzbl (%ecx),%ebx
  801bf3:	84 db                	test   %bl,%bl
  801bf5:	75 ec                	jne    801be3 <strlcpy+0x1c>
  801bf7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bf9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bfc:	29 f0                	sub    %esi,%eax
}
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c08:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c0b:	eb 06                	jmp    801c13 <strcmp+0x11>
		p++, q++;
  801c0d:	83 c1 01             	add    $0x1,%ecx
  801c10:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c13:	0f b6 01             	movzbl (%ecx),%eax
  801c16:	84 c0                	test   %al,%al
  801c18:	74 04                	je     801c1e <strcmp+0x1c>
  801c1a:	3a 02                	cmp    (%edx),%al
  801c1c:	74 ef                	je     801c0d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c1e:	0f b6 c0             	movzbl %al,%eax
  801c21:	0f b6 12             	movzbl (%edx),%edx
  801c24:	29 d0                	sub    %edx,%eax
}
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    

00801c28 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	53                   	push   %ebx
  801c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c32:	89 c3                	mov    %eax,%ebx
  801c34:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c37:	eb 06                	jmp    801c3f <strncmp+0x17>
		n--, p++, q++;
  801c39:	83 c0 01             	add    $0x1,%eax
  801c3c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c3f:	39 d8                	cmp    %ebx,%eax
  801c41:	74 15                	je     801c58 <strncmp+0x30>
  801c43:	0f b6 08             	movzbl (%eax),%ecx
  801c46:	84 c9                	test   %cl,%cl
  801c48:	74 04                	je     801c4e <strncmp+0x26>
  801c4a:	3a 0a                	cmp    (%edx),%cl
  801c4c:	74 eb                	je     801c39 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4e:	0f b6 00             	movzbl (%eax),%eax
  801c51:	0f b6 12             	movzbl (%edx),%edx
  801c54:	29 d0                	sub    %edx,%eax
  801c56:	eb 05                	jmp    801c5d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c58:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c5d:	5b                   	pop    %ebx
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c6a:	eb 07                	jmp    801c73 <strchr+0x13>
		if (*s == c)
  801c6c:	38 ca                	cmp    %cl,%dl
  801c6e:	74 0f                	je     801c7f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c70:	83 c0 01             	add    $0x1,%eax
  801c73:	0f b6 10             	movzbl (%eax),%edx
  801c76:	84 d2                	test   %dl,%dl
  801c78:	75 f2                	jne    801c6c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    

00801c81 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	8b 45 08             	mov    0x8(%ebp),%eax
  801c87:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c8b:	eb 03                	jmp    801c90 <strfind+0xf>
  801c8d:	83 c0 01             	add    $0x1,%eax
  801c90:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c93:	38 ca                	cmp    %cl,%dl
  801c95:	74 04                	je     801c9b <strfind+0x1a>
  801c97:	84 d2                	test   %dl,%dl
  801c99:	75 f2                	jne    801c8d <strfind+0xc>
			break;
	return (char *) s;
}
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	57                   	push   %edi
  801ca1:	56                   	push   %esi
  801ca2:	53                   	push   %ebx
  801ca3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca9:	85 c9                	test   %ecx,%ecx
  801cab:	74 36                	je     801ce3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cb3:	75 28                	jne    801cdd <memset+0x40>
  801cb5:	f6 c1 03             	test   $0x3,%cl
  801cb8:	75 23                	jne    801cdd <memset+0x40>
		c &= 0xFF;
  801cba:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cbe:	89 d3                	mov    %edx,%ebx
  801cc0:	c1 e3 08             	shl    $0x8,%ebx
  801cc3:	89 d6                	mov    %edx,%esi
  801cc5:	c1 e6 18             	shl    $0x18,%esi
  801cc8:	89 d0                	mov    %edx,%eax
  801cca:	c1 e0 10             	shl    $0x10,%eax
  801ccd:	09 f0                	or     %esi,%eax
  801ccf:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cd1:	89 d8                	mov    %ebx,%eax
  801cd3:	09 d0                	or     %edx,%eax
  801cd5:	c1 e9 02             	shr    $0x2,%ecx
  801cd8:	fc                   	cld    
  801cd9:	f3 ab                	rep stos %eax,%es:(%edi)
  801cdb:	eb 06                	jmp    801ce3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce0:	fc                   	cld    
  801ce1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ce3:	89 f8                	mov    %edi,%eax
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	57                   	push   %edi
  801cee:	56                   	push   %esi
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf8:	39 c6                	cmp    %eax,%esi
  801cfa:	73 35                	jae    801d31 <memmove+0x47>
  801cfc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cff:	39 d0                	cmp    %edx,%eax
  801d01:	73 2e                	jae    801d31 <memmove+0x47>
		s += n;
		d += n;
  801d03:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d06:	89 d6                	mov    %edx,%esi
  801d08:	09 fe                	or     %edi,%esi
  801d0a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d10:	75 13                	jne    801d25 <memmove+0x3b>
  801d12:	f6 c1 03             	test   $0x3,%cl
  801d15:	75 0e                	jne    801d25 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d17:	83 ef 04             	sub    $0x4,%edi
  801d1a:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d1d:	c1 e9 02             	shr    $0x2,%ecx
  801d20:	fd                   	std    
  801d21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d23:	eb 09                	jmp    801d2e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d25:	83 ef 01             	sub    $0x1,%edi
  801d28:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d2b:	fd                   	std    
  801d2c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d2e:	fc                   	cld    
  801d2f:	eb 1d                	jmp    801d4e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d31:	89 f2                	mov    %esi,%edx
  801d33:	09 c2                	or     %eax,%edx
  801d35:	f6 c2 03             	test   $0x3,%dl
  801d38:	75 0f                	jne    801d49 <memmove+0x5f>
  801d3a:	f6 c1 03             	test   $0x3,%cl
  801d3d:	75 0a                	jne    801d49 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d3f:	c1 e9 02             	shr    $0x2,%ecx
  801d42:	89 c7                	mov    %eax,%edi
  801d44:	fc                   	cld    
  801d45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d47:	eb 05                	jmp    801d4e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d49:	89 c7                	mov    %eax,%edi
  801d4b:	fc                   	cld    
  801d4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d55:	ff 75 10             	pushl  0x10(%ebp)
  801d58:	ff 75 0c             	pushl  0xc(%ebp)
  801d5b:	ff 75 08             	pushl  0x8(%ebp)
  801d5e:	e8 87 ff ff ff       	call   801cea <memmove>
}
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    

00801d65 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	56                   	push   %esi
  801d69:	53                   	push   %ebx
  801d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d70:	89 c6                	mov    %eax,%esi
  801d72:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d75:	eb 1a                	jmp    801d91 <memcmp+0x2c>
		if (*s1 != *s2)
  801d77:	0f b6 08             	movzbl (%eax),%ecx
  801d7a:	0f b6 1a             	movzbl (%edx),%ebx
  801d7d:	38 d9                	cmp    %bl,%cl
  801d7f:	74 0a                	je     801d8b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d81:	0f b6 c1             	movzbl %cl,%eax
  801d84:	0f b6 db             	movzbl %bl,%ebx
  801d87:	29 d8                	sub    %ebx,%eax
  801d89:	eb 0f                	jmp    801d9a <memcmp+0x35>
		s1++, s2++;
  801d8b:	83 c0 01             	add    $0x1,%eax
  801d8e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d91:	39 f0                	cmp    %esi,%eax
  801d93:	75 e2                	jne    801d77 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d9a:	5b                   	pop    %ebx
  801d9b:	5e                   	pop    %esi
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    

00801d9e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	53                   	push   %ebx
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801da5:	89 c1                	mov    %eax,%ecx
  801da7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801daa:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dae:	eb 0a                	jmp    801dba <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801db0:	0f b6 10             	movzbl (%eax),%edx
  801db3:	39 da                	cmp    %ebx,%edx
  801db5:	74 07                	je     801dbe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db7:	83 c0 01             	add    $0x1,%eax
  801dba:	39 c8                	cmp    %ecx,%eax
  801dbc:	72 f2                	jb     801db0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dbe:	5b                   	pop    %ebx
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    

00801dc1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	57                   	push   %edi
  801dc5:	56                   	push   %esi
  801dc6:	53                   	push   %ebx
  801dc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dcd:	eb 03                	jmp    801dd2 <strtol+0x11>
		s++;
  801dcf:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd2:	0f b6 01             	movzbl (%ecx),%eax
  801dd5:	3c 20                	cmp    $0x20,%al
  801dd7:	74 f6                	je     801dcf <strtol+0xe>
  801dd9:	3c 09                	cmp    $0x9,%al
  801ddb:	74 f2                	je     801dcf <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ddd:	3c 2b                	cmp    $0x2b,%al
  801ddf:	75 0a                	jne    801deb <strtol+0x2a>
		s++;
  801de1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801de4:	bf 00 00 00 00       	mov    $0x0,%edi
  801de9:	eb 11                	jmp    801dfc <strtol+0x3b>
  801deb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801df0:	3c 2d                	cmp    $0x2d,%al
  801df2:	75 08                	jne    801dfc <strtol+0x3b>
		s++, neg = 1;
  801df4:	83 c1 01             	add    $0x1,%ecx
  801df7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dfc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e02:	75 15                	jne    801e19 <strtol+0x58>
  801e04:	80 39 30             	cmpb   $0x30,(%ecx)
  801e07:	75 10                	jne    801e19 <strtol+0x58>
  801e09:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e0d:	75 7c                	jne    801e8b <strtol+0xca>
		s += 2, base = 16;
  801e0f:	83 c1 02             	add    $0x2,%ecx
  801e12:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e17:	eb 16                	jmp    801e2f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e19:	85 db                	test   %ebx,%ebx
  801e1b:	75 12                	jne    801e2f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e1d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e22:	80 39 30             	cmpb   $0x30,(%ecx)
  801e25:	75 08                	jne    801e2f <strtol+0x6e>
		s++, base = 8;
  801e27:	83 c1 01             	add    $0x1,%ecx
  801e2a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e34:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e37:	0f b6 11             	movzbl (%ecx),%edx
  801e3a:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e3d:	89 f3                	mov    %esi,%ebx
  801e3f:	80 fb 09             	cmp    $0x9,%bl
  801e42:	77 08                	ja     801e4c <strtol+0x8b>
			dig = *s - '0';
  801e44:	0f be d2             	movsbl %dl,%edx
  801e47:	83 ea 30             	sub    $0x30,%edx
  801e4a:	eb 22                	jmp    801e6e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e4c:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e4f:	89 f3                	mov    %esi,%ebx
  801e51:	80 fb 19             	cmp    $0x19,%bl
  801e54:	77 08                	ja     801e5e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e56:	0f be d2             	movsbl %dl,%edx
  801e59:	83 ea 57             	sub    $0x57,%edx
  801e5c:	eb 10                	jmp    801e6e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e5e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e61:	89 f3                	mov    %esi,%ebx
  801e63:	80 fb 19             	cmp    $0x19,%bl
  801e66:	77 16                	ja     801e7e <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e68:	0f be d2             	movsbl %dl,%edx
  801e6b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e6e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e71:	7d 0b                	jge    801e7e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e73:	83 c1 01             	add    $0x1,%ecx
  801e76:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e7a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e7c:	eb b9                	jmp    801e37 <strtol+0x76>

	if (endptr)
  801e7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e82:	74 0d                	je     801e91 <strtol+0xd0>
		*endptr = (char *) s;
  801e84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e87:	89 0e                	mov    %ecx,(%esi)
  801e89:	eb 06                	jmp    801e91 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	74 98                	je     801e27 <strtol+0x66>
  801e8f:	eb 9e                	jmp    801e2f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e91:	89 c2                	mov    %eax,%edx
  801e93:	f7 da                	neg    %edx
  801e95:	85 ff                	test   %edi,%edi
  801e97:	0f 45 c2             	cmovne %edx,%eax
}
  801e9a:	5b                   	pop    %ebx
  801e9b:	5e                   	pop    %esi
  801e9c:	5f                   	pop    %edi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	74 0e                	je     801ebf <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	50                   	push   %eax
  801eb5:	e8 6a e4 ff ff       	call   800324 <sys_ipc_recv>
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	eb 10                	jmp    801ecf <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	68 00 00 00 f0       	push   $0xf0000000
  801ec7:	e8 58 e4 ff ff       	call   800324 <sys_ipc_recv>
  801ecc:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	74 0e                	je     801ee1 <ipc_recv+0x42>
    	*from_env_store = 0;
  801ed3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ed9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801edf:	eb 24                	jmp    801f05 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ee1:	85 f6                	test   %esi,%esi
  801ee3:	74 0a                	je     801eef <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ee5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eea:	8b 40 74             	mov    0x74(%eax),%eax
  801eed:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801eef:	85 db                	test   %ebx,%ebx
  801ef1:	74 0a                	je     801efd <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801ef3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef8:	8b 40 78             	mov    0x78(%eax),%eax
  801efb:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801efd:	a1 08 40 80 00       	mov    0x804008,%eax
  801f02:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f1e:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f25:	0f 44 d8             	cmove  %eax,%ebx
  801f28:	eb 1c                	jmp    801f46 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f2a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f2d:	74 12                	je     801f41 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f2f:	50                   	push   %eax
  801f30:	68 20 27 80 00       	push   $0x802720
  801f35:	6a 4b                	push   $0x4b
  801f37:	68 38 27 80 00       	push   $0x802738
  801f3c:	e8 b9 f5 ff ff       	call   8014fa <_panic>
        }	
        sys_yield();
  801f41:	e8 0f e2 ff ff       	call   800155 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f46:	ff 75 14             	pushl  0x14(%ebp)
  801f49:	53                   	push   %ebx
  801f4a:	56                   	push   %esi
  801f4b:	57                   	push   %edi
  801f4c:	e8 b0 e3 ff ff       	call   800301 <sys_ipc_try_send>
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	85 c0                	test   %eax,%eax
  801f56:	75 d2                	jne    801f2a <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f74:	8b 52 50             	mov    0x50(%edx),%edx
  801f77:	39 ca                	cmp    %ecx,%edx
  801f79:	75 0d                	jne    801f88 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f83:	8b 40 48             	mov    0x48(%eax),%eax
  801f86:	eb 0f                	jmp    801f97 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f88:	83 c0 01             	add    $0x1,%eax
  801f8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f90:	75 d9                	jne    801f6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f97:	5d                   	pop    %ebp
  801f98:	c3                   	ret    

00801f99 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9f:	89 d0                	mov    %edx,%eax
  801fa1:	c1 e8 16             	shr    $0x16,%eax
  801fa4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb0:	f6 c1 01             	test   $0x1,%cl
  801fb3:	74 1d                	je     801fd2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb5:	c1 ea 0c             	shr    $0xc,%edx
  801fb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbf:	f6 c2 01             	test   $0x1,%dl
  801fc2:	74 0e                	je     801fd2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc4:	c1 ea 0c             	shr    $0xc,%edx
  801fc7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fce:	ef 
  801fcf:	0f b7 c0             	movzwl %ax,%eax
}
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
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
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
