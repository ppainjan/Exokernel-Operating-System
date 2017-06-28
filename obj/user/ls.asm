
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 42 27 80 00       	push   $0x802742
  80005f:	e8 b9 19 00 00       	call   801a1d <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 a8 27 80 00       	mov    $0x8027a8,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 d5 08 00 00       	call   800953 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba a8 27 80 00       	mov    $0x8027a8,%edx
  80008b:	b8 40 27 80 00       	mov    $0x802740,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 4b 27 80 00       	push   $0x80274b
  80009d:	e8 7b 19 00 00       	call   801a1d <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 d9 2b 80 00       	push   $0x802bd9
  8000b0:	e8 68 19 00 00       	call   801a1d <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 40 27 80 00       	push   $0x802740
  8000cf:	e8 49 19 00 00       	call   801a1d <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 a7 27 80 00       	push   $0x8027a7
  8000df:	e8 39 19 00 00       	call   801a1d <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 7a 17 00 00       	call   80187f <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 50 27 80 00       	push   $0x802750
  800118:	6a 1d                	push   $0x1d
  80011a:	68 5c 27 80 00       	push   $0x80275c
  80011f:	e8 0a 02 00 00       	call   80032e <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 1d 13 00 00       	call   801481 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 66 27 80 00       	push   $0x802766
  800178:	6a 22                	push   $0x22
  80017a:	68 5c 27 80 00       	push   $0x80275c
  80017f:	e8 aa 01 00 00       	call   80032e <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 ac 27 80 00       	push   $0x8027ac
  800192:	6a 24                	push   $0x24
  800194:	68 5c 27 80 00       	push   $0x80275c
  800199:	e8 90 01 00 00       	call   80032e <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 c6 14 00 00       	call   801686 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 81 27 80 00       	push   $0x802781
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 5c 27 80 00       	push   $0x80275c
  8001d8:	e8 51 01 00 00       	call   80032e <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 8d 27 80 00       	push   $0x80278d
  800225:	e8 f3 17 00 00       	call   801a1d <printf>
	exit();
  80022a:	e8 e5 00 00 00       	call   800314 <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 73 0d 00 00       	call   800fc0 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 74 0d 00 00       	call   800ff0 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 a8 27 80 00       	push   $0x8027a8
  800296:	68 40 27 80 00       	push   $0x802740
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8002cf:	c7 05 20 44 80 00 00 	movl   $0x0,0x804420
  8002d6:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8002d9:	e8 73 0a 00 00       	call   800d51 <sys_getenvid>
  8002de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002eb:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f0:	85 db                	test   %ebx,%ebx
  8002f2:	7e 07                	jle    8002fb <libmain+0x37>
		binaryname = argv[0];
  8002f4:	8b 06                	mov    (%esi),%eax
  8002f6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
  800300:	e8 2f ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  800305:	e8 0a 00 00 00       	call   800314 <exit>
}
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80031a:	e8 c0 0f 00 00       	call   8012df <close_all>
	sys_env_destroy(0);
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	6a 00                	push   $0x0
  800324:	e8 e7 09 00 00       	call   800d10 <sys_env_destroy>
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800333:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800336:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80033c:	e8 10 0a 00 00       	call   800d51 <sys_getenvid>
  800341:	83 ec 0c             	sub    $0xc,%esp
  800344:	ff 75 0c             	pushl  0xc(%ebp)
  800347:	ff 75 08             	pushl  0x8(%ebp)
  80034a:	56                   	push   %esi
  80034b:	50                   	push   %eax
  80034c:	68 d8 27 80 00       	push   $0x8027d8
  800351:	e8 b1 00 00 00       	call   800407 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800356:	83 c4 18             	add    $0x18,%esp
  800359:	53                   	push   %ebx
  80035a:	ff 75 10             	pushl  0x10(%ebp)
  80035d:	e8 54 00 00 00       	call   8003b6 <vcprintf>
	cprintf("\n");
  800362:	c7 04 24 a7 27 80 00 	movl   $0x8027a7,(%esp)
  800369:	e8 99 00 00 00       	call   800407 <cprintf>
  80036e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800371:	cc                   	int3   
  800372:	eb fd                	jmp    800371 <_panic+0x43>

00800374 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	53                   	push   %ebx
  800378:	83 ec 04             	sub    $0x4,%esp
  80037b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037e:	8b 13                	mov    (%ebx),%edx
  800380:	8d 42 01             	lea    0x1(%edx),%eax
  800383:	89 03                	mov    %eax,(%ebx)
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80038c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800391:	75 1a                	jne    8003ad <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800393:	83 ec 08             	sub    $0x8,%esp
  800396:	68 ff 00 00 00       	push   $0xff
  80039b:	8d 43 08             	lea    0x8(%ebx),%eax
  80039e:	50                   	push   %eax
  80039f:	e8 2f 09 00 00       	call   800cd3 <sys_cputs>
		b->idx = 0;
  8003a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003aa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c6:	00 00 00 
	b.cnt = 0;
  8003c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d3:	ff 75 0c             	pushl  0xc(%ebp)
  8003d6:	ff 75 08             	pushl  0x8(%ebp)
  8003d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003df:	50                   	push   %eax
  8003e0:	68 74 03 80 00       	push   $0x800374
  8003e5:	e8 54 01 00 00       	call   80053e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ea:	83 c4 08             	add    $0x8,%esp
  8003ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f9:	50                   	push   %eax
  8003fa:	e8 d4 08 00 00       	call   800cd3 <sys_cputs>

	return b.cnt;
}
  8003ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800405:	c9                   	leave  
  800406:	c3                   	ret    

00800407 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80040d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800410:	50                   	push   %eax
  800411:	ff 75 08             	pushl  0x8(%ebp)
  800414:	e8 9d ff ff ff       	call   8003b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800419:	c9                   	leave  
  80041a:	c3                   	ret    

0080041b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	57                   	push   %edi
  80041f:	56                   	push   %esi
  800420:	53                   	push   %ebx
  800421:	83 ec 1c             	sub    $0x1c,%esp
  800424:	89 c7                	mov    %eax,%edi
  800426:	89 d6                	mov    %edx,%esi
  800428:	8b 45 08             	mov    0x8(%ebp),%eax
  80042b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800431:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800434:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800437:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80043f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800442:	39 d3                	cmp    %edx,%ebx
  800444:	72 05                	jb     80044b <printnum+0x30>
  800446:	39 45 10             	cmp    %eax,0x10(%ebp)
  800449:	77 45                	ja     800490 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044b:	83 ec 0c             	sub    $0xc,%esp
  80044e:	ff 75 18             	pushl  0x18(%ebp)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800457:	53                   	push   %ebx
  800458:	ff 75 10             	pushl  0x10(%ebp)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800461:	ff 75 e0             	pushl  -0x20(%ebp)
  800464:	ff 75 dc             	pushl  -0x24(%ebp)
  800467:	ff 75 d8             	pushl  -0x28(%ebp)
  80046a:	e8 41 20 00 00       	call   8024b0 <__udivdi3>
  80046f:	83 c4 18             	add    $0x18,%esp
  800472:	52                   	push   %edx
  800473:	50                   	push   %eax
  800474:	89 f2                	mov    %esi,%edx
  800476:	89 f8                	mov    %edi,%eax
  800478:	e8 9e ff ff ff       	call   80041b <printnum>
  80047d:	83 c4 20             	add    $0x20,%esp
  800480:	eb 18                	jmp    80049a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	56                   	push   %esi
  800486:	ff 75 18             	pushl  0x18(%ebp)
  800489:	ff d7                	call   *%edi
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	eb 03                	jmp    800493 <printnum+0x78>
  800490:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800493:	83 eb 01             	sub    $0x1,%ebx
  800496:	85 db                	test   %ebx,%ebx
  800498:	7f e8                	jg     800482 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	56                   	push   %esi
  80049e:	83 ec 04             	sub    $0x4,%esp
  8004a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8004aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ad:	e8 2e 21 00 00       	call   8025e0 <__umoddi3>
  8004b2:	83 c4 14             	add    $0x14,%esp
  8004b5:	0f be 80 fb 27 80 00 	movsbl 0x8027fb(%eax),%eax
  8004bc:	50                   	push   %eax
  8004bd:	ff d7                	call   *%edi
}
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c5:	5b                   	pop    %ebx
  8004c6:	5e                   	pop    %esi
  8004c7:	5f                   	pop    %edi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004cd:	83 fa 01             	cmp    $0x1,%edx
  8004d0:	7e 0e                	jle    8004e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d7:	89 08                	mov    %ecx,(%eax)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	8b 52 04             	mov    0x4(%edx),%edx
  8004de:	eb 22                	jmp    800502 <getuint+0x38>
	else if (lflag)
  8004e0:	85 d2                	test   %edx,%edx
  8004e2:	74 10                	je     8004f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e4:	8b 10                	mov    (%eax),%edx
  8004e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e9:	89 08                	mov    %ecx,(%eax)
  8004eb:	8b 02                	mov    (%edx),%eax
  8004ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f2:	eb 0e                	jmp    800502 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f9:	89 08                	mov    %ecx,(%eax)
  8004fb:	8b 02                	mov    (%edx),%eax
  8004fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80050a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050e:	8b 10                	mov    (%eax),%edx
  800510:	3b 50 04             	cmp    0x4(%eax),%edx
  800513:	73 0a                	jae    80051f <sprintputch+0x1b>
		*b->buf++ = ch;
  800515:	8d 4a 01             	lea    0x1(%edx),%ecx
  800518:	89 08                	mov    %ecx,(%eax)
  80051a:	8b 45 08             	mov    0x8(%ebp),%eax
  80051d:	88 02                	mov    %al,(%edx)
}
  80051f:	5d                   	pop    %ebp
  800520:	c3                   	ret    

00800521 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800527:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80052a:	50                   	push   %eax
  80052b:	ff 75 10             	pushl  0x10(%ebp)
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	ff 75 08             	pushl  0x8(%ebp)
  800534:	e8 05 00 00 00       	call   80053e <vprintfmt>
	va_end(ap);
}
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	57                   	push   %edi
  800542:	56                   	push   %esi
  800543:	53                   	push   %ebx
  800544:	83 ec 2c             	sub    $0x2c,%esp
  800547:	8b 75 08             	mov    0x8(%ebp),%esi
  80054a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800550:	eb 12                	jmp    800564 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 84 89 03 00 00    	je     8008e3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	50                   	push   %eax
  80055f:	ff d6                	call   *%esi
  800561:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	83 f8 25             	cmp    $0x25,%eax
  80056e:	75 e2                	jne    800552 <vprintfmt+0x14>
  800570:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800574:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80057b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800582:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	eb 07                	jmp    800597 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800593:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8d 47 01             	lea    0x1(%edi),%eax
  80059a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059d:	0f b6 07             	movzbl (%edi),%eax
  8005a0:	0f b6 c8             	movzbl %al,%ecx
  8005a3:	83 e8 23             	sub    $0x23,%eax
  8005a6:	3c 55                	cmp    $0x55,%al
  8005a8:	0f 87 1a 03 00 00    	ja     8008c8 <vprintfmt+0x38a>
  8005ae:	0f b6 c0             	movzbl %al,%eax
  8005b1:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005bf:	eb d6                	jmp    800597 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005d3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005d6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005d9:	83 fa 09             	cmp    $0x9,%edx
  8005dc:	77 39                	ja     800617 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e1:	eb e9                	jmp    8005cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f4:	eb 27                	jmp    80061d <vprintfmt+0xdf>
  8005f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800600:	0f 49 c8             	cmovns %eax,%ecx
  800603:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800609:	eb 8c                	jmp    800597 <vprintfmt+0x59>
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80060e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800615:	eb 80                	jmp    800597 <vprintfmt+0x59>
  800617:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80061d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800621:	0f 89 70 ff ff ff    	jns    800597 <vprintfmt+0x59>
				width = precision, precision = -1;
  800627:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80062a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800634:	e9 5e ff ff ff       	jmp    800597 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800639:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80063f:	e9 53 ff ff ff       	jmp    800597 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	ff 30                	pushl  (%eax)
  800653:	ff d6                	call   *%esi
			break;
  800655:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80065b:	e9 04 ff ff ff       	jmp    800564 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	99                   	cltd   
  80066c:	31 d0                	xor    %edx,%eax
  80066e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800670:	83 f8 0f             	cmp    $0xf,%eax
  800673:	7f 0b                	jg     800680 <vprintfmt+0x142>
  800675:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  80067c:	85 d2                	test   %edx,%edx
  80067e:	75 18                	jne    800698 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800680:	50                   	push   %eax
  800681:	68 13 28 80 00       	push   $0x802813
  800686:	53                   	push   %ebx
  800687:	56                   	push   %esi
  800688:	e8 94 fe ff ff       	call   800521 <printfmt>
  80068d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800693:	e9 cc fe ff ff       	jmp    800564 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800698:	52                   	push   %edx
  800699:	68 d9 2b 80 00       	push   $0x802bd9
  80069e:	53                   	push   %ebx
  80069f:	56                   	push   %esi
  8006a0:	e8 7c fe ff ff       	call   800521 <printfmt>
  8006a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ab:	e9 b4 fe ff ff       	jmp    800564 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006bb:	85 ff                	test   %edi,%edi
  8006bd:	b8 0c 28 80 00       	mov    $0x80280c,%eax
  8006c2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c9:	0f 8e 94 00 00 00    	jle    800763 <vprintfmt+0x225>
  8006cf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006d3:	0f 84 98 00 00 00    	je     800771 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	ff 75 d0             	pushl  -0x30(%ebp)
  8006df:	57                   	push   %edi
  8006e0:	e8 86 02 00 00       	call   80096b <strnlen>
  8006e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e8:	29 c1                	sub    %eax,%ecx
  8006ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006ed:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006fa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	eb 0f                	jmp    80070d <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	ff 75 e0             	pushl  -0x20(%ebp)
  800705:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800707:	83 ef 01             	sub    $0x1,%edi
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	85 ff                	test   %edi,%edi
  80070f:	7f ed                	jg     8006fe <vprintfmt+0x1c0>
  800711:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800714:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800717:	85 c9                	test   %ecx,%ecx
  800719:	b8 00 00 00 00       	mov    $0x0,%eax
  80071e:	0f 49 c1             	cmovns %ecx,%eax
  800721:	29 c1                	sub    %eax,%ecx
  800723:	89 75 08             	mov    %esi,0x8(%ebp)
  800726:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800729:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072c:	89 cb                	mov    %ecx,%ebx
  80072e:	eb 4d                	jmp    80077d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800730:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800734:	74 1b                	je     800751 <vprintfmt+0x213>
  800736:	0f be c0             	movsbl %al,%eax
  800739:	83 e8 20             	sub    $0x20,%eax
  80073c:	83 f8 5e             	cmp    $0x5e,%eax
  80073f:	76 10                	jbe    800751 <vprintfmt+0x213>
					putch('?', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	ff 75 0c             	pushl  0xc(%ebp)
  800747:	6a 3f                	push   $0x3f
  800749:	ff 55 08             	call   *0x8(%ebp)
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 0d                	jmp    80075e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	52                   	push   %edx
  800758:	ff 55 08             	call   *0x8(%ebp)
  80075b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075e:	83 eb 01             	sub    $0x1,%ebx
  800761:	eb 1a                	jmp    80077d <vprintfmt+0x23f>
  800763:	89 75 08             	mov    %esi,0x8(%ebp)
  800766:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800769:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076f:	eb 0c                	jmp    80077d <vprintfmt+0x23f>
  800771:	89 75 08             	mov    %esi,0x8(%ebp)
  800774:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800777:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077d:	83 c7 01             	add    $0x1,%edi
  800780:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800784:	0f be d0             	movsbl %al,%edx
  800787:	85 d2                	test   %edx,%edx
  800789:	74 23                	je     8007ae <vprintfmt+0x270>
  80078b:	85 f6                	test   %esi,%esi
  80078d:	78 a1                	js     800730 <vprintfmt+0x1f2>
  80078f:	83 ee 01             	sub    $0x1,%esi
  800792:	79 9c                	jns    800730 <vprintfmt+0x1f2>
  800794:	89 df                	mov    %ebx,%edi
  800796:	8b 75 08             	mov    0x8(%ebp),%esi
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079c:	eb 18                	jmp    8007b6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	53                   	push   %ebx
  8007a2:	6a 20                	push   $0x20
  8007a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a6:	83 ef 01             	sub    $0x1,%edi
  8007a9:	83 c4 10             	add    $0x10,%esp
  8007ac:	eb 08                	jmp    8007b6 <vprintfmt+0x278>
  8007ae:	89 df                	mov    %ebx,%edi
  8007b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b6:	85 ff                	test   %edi,%edi
  8007b8:	7f e4                	jg     80079e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bd:	e9 a2 fd ff ff       	jmp    800564 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c2:	83 fa 01             	cmp    $0x1,%edx
  8007c5:	7e 16                	jle    8007dd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 50 08             	lea    0x8(%eax),%edx
  8007cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d0:	8b 50 04             	mov    0x4(%eax),%edx
  8007d3:	8b 00                	mov    (%eax),%eax
  8007d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007db:	eb 32                	jmp    80080f <vprintfmt+0x2d1>
	else if (lflag)
  8007dd:	85 d2                	test   %edx,%edx
  8007df:	74 18                	je     8007f9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 50 04             	lea    0x4(%eax),%edx
  8007e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ea:	8b 00                	mov    (%eax),%eax
  8007ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ef:	89 c1                	mov    %eax,%ecx
  8007f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f7:	eb 16                	jmp    80080f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800807:	89 c1                	mov    %eax,%ecx
  800809:	c1 f9 1f             	sar    $0x1f,%ecx
  80080c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800812:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800815:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80081e:	79 74                	jns    800894 <vprintfmt+0x356>
				putch('-', putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	6a 2d                	push   $0x2d
  800826:	ff d6                	call   *%esi
				num = -(long long) num;
  800828:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80082b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80082e:	f7 d8                	neg    %eax
  800830:	83 d2 00             	adc    $0x0,%edx
  800833:	f7 da                	neg    %edx
  800835:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800838:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80083d:	eb 55                	jmp    800894 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
  800842:	e8 83 fc ff ff       	call   8004ca <getuint>
			base = 10;
  800847:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80084c:	eb 46                	jmp    800894 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
  800851:	e8 74 fc ff ff       	call   8004ca <getuint>
		        base = 8;
  800856:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80085b:	eb 37                	jmp    800894 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 30                	push   $0x30
  800863:	ff d6                	call   *%esi
			putch('x', putdat);
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 78                	push   $0x78
  80086b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8d 50 04             	lea    0x4(%eax),%edx
  800873:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800876:	8b 00                	mov    (%eax),%eax
  800878:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800880:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800885:	eb 0d                	jmp    800894 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800887:	8d 45 14             	lea    0x14(%ebp),%eax
  80088a:	e8 3b fc ff ff       	call   8004ca <getuint>
			base = 16;
  80088f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800894:	83 ec 0c             	sub    $0xc,%esp
  800897:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80089b:	57                   	push   %edi
  80089c:	ff 75 e0             	pushl  -0x20(%ebp)
  80089f:	51                   	push   %ecx
  8008a0:	52                   	push   %edx
  8008a1:	50                   	push   %eax
  8008a2:	89 da                	mov    %ebx,%edx
  8008a4:	89 f0                	mov    %esi,%eax
  8008a6:	e8 70 fb ff ff       	call   80041b <printnum>
			break;
  8008ab:	83 c4 20             	add    $0x20,%esp
  8008ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b1:	e9 ae fc ff ff       	jmp    800564 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	51                   	push   %ecx
  8008bb:	ff d6                	call   *%esi
			break;
  8008bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c3:	e9 9c fc ff ff       	jmp    800564 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	53                   	push   %ebx
  8008cc:	6a 25                	push   $0x25
  8008ce:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	eb 03                	jmp    8008d8 <vprintfmt+0x39a>
  8008d5:	83 ef 01             	sub    $0x1,%edi
  8008d8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008dc:	75 f7                	jne    8008d5 <vprintfmt+0x397>
  8008de:	e9 81 fc ff ff       	jmp    800564 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	83 ec 18             	sub    $0x18,%esp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800901:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800908:	85 c0                	test   %eax,%eax
  80090a:	74 26                	je     800932 <vsnprintf+0x47>
  80090c:	85 d2                	test   %edx,%edx
  80090e:	7e 22                	jle    800932 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800910:	ff 75 14             	pushl  0x14(%ebp)
  800913:	ff 75 10             	pushl  0x10(%ebp)
  800916:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800919:	50                   	push   %eax
  80091a:	68 04 05 80 00       	push   $0x800504
  80091f:	e8 1a fc ff ff       	call   80053e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800924:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800927:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	eb 05                	jmp    800937 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800932:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80093f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800942:	50                   	push   %eax
  800943:	ff 75 10             	pushl  0x10(%ebp)
  800946:	ff 75 0c             	pushl  0xc(%ebp)
  800949:	ff 75 08             	pushl  0x8(%ebp)
  80094c:	e8 9a ff ff ff       	call   8008eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
  80095e:	eb 03                	jmp    800963 <strlen+0x10>
		n++;
  800960:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800963:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800967:	75 f7                	jne    800960 <strlen+0xd>
		n++;
	return n;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800971:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800974:	ba 00 00 00 00       	mov    $0x0,%edx
  800979:	eb 03                	jmp    80097e <strnlen+0x13>
		n++;
  80097b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097e:	39 c2                	cmp    %eax,%edx
  800980:	74 08                	je     80098a <strnlen+0x1f>
  800982:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800986:	75 f3                	jne    80097b <strnlen+0x10>
  800988:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800996:	89 c2                	mov    %eax,%edx
  800998:	83 c2 01             	add    $0x1,%edx
  80099b:	83 c1 01             	add    $0x1,%ecx
  80099e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a5:	84 db                	test   %bl,%bl
  8009a7:	75 ef                	jne    800998 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	53                   	push   %ebx
  8009b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b3:	53                   	push   %ebx
  8009b4:	e8 9a ff ff ff       	call   800953 <strlen>
  8009b9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009bc:	ff 75 0c             	pushl  0xc(%ebp)
  8009bf:	01 d8                	add    %ebx,%eax
  8009c1:	50                   	push   %eax
  8009c2:	e8 c5 ff ff ff       	call   80098c <strcpy>
	return dst;
}
  8009c7:	89 d8                	mov    %ebx,%eax
  8009c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d9:	89 f3                	mov    %esi,%ebx
  8009db:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009de:	89 f2                	mov    %esi,%edx
  8009e0:	eb 0f                	jmp    8009f1 <strncpy+0x23>
		*dst++ = *src;
  8009e2:	83 c2 01             	add    $0x1,%edx
  8009e5:	0f b6 01             	movzbl (%ecx),%eax
  8009e8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009eb:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ee:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f1:	39 da                	cmp    %ebx,%edx
  8009f3:	75 ed                	jne    8009e2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f5:	89 f0                	mov    %esi,%eax
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 75 08             	mov    0x8(%ebp),%esi
  800a03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a06:	8b 55 10             	mov    0x10(%ebp),%edx
  800a09:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a0b:	85 d2                	test   %edx,%edx
  800a0d:	74 21                	je     800a30 <strlcpy+0x35>
  800a0f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a13:	89 f2                	mov    %esi,%edx
  800a15:	eb 09                	jmp    800a20 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a17:	83 c2 01             	add    $0x1,%edx
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a20:	39 c2                	cmp    %eax,%edx
  800a22:	74 09                	je     800a2d <strlcpy+0x32>
  800a24:	0f b6 19             	movzbl (%ecx),%ebx
  800a27:	84 db                	test   %bl,%bl
  800a29:	75 ec                	jne    800a17 <strlcpy+0x1c>
  800a2b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a2d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a30:	29 f0                	sub    %esi,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3f:	eb 06                	jmp    800a47 <strcmp+0x11>
		p++, q++;
  800a41:	83 c1 01             	add    $0x1,%ecx
  800a44:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a47:	0f b6 01             	movzbl (%ecx),%eax
  800a4a:	84 c0                	test   %al,%al
  800a4c:	74 04                	je     800a52 <strcmp+0x1c>
  800a4e:	3a 02                	cmp    (%edx),%al
  800a50:	74 ef                	je     800a41 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a52:	0f b6 c0             	movzbl %al,%eax
  800a55:	0f b6 12             	movzbl (%edx),%edx
  800a58:	29 d0                	sub    %edx,%eax
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a66:	89 c3                	mov    %eax,%ebx
  800a68:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6b:	eb 06                	jmp    800a73 <strncmp+0x17>
		n--, p++, q++;
  800a6d:	83 c0 01             	add    $0x1,%eax
  800a70:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a73:	39 d8                	cmp    %ebx,%eax
  800a75:	74 15                	je     800a8c <strncmp+0x30>
  800a77:	0f b6 08             	movzbl (%eax),%ecx
  800a7a:	84 c9                	test   %cl,%cl
  800a7c:	74 04                	je     800a82 <strncmp+0x26>
  800a7e:	3a 0a                	cmp    (%edx),%cl
  800a80:	74 eb                	je     800a6d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a82:	0f b6 00             	movzbl (%eax),%eax
  800a85:	0f b6 12             	movzbl (%edx),%edx
  800a88:	29 d0                	sub    %edx,%eax
  800a8a:	eb 05                	jmp    800a91 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9e:	eb 07                	jmp    800aa7 <strchr+0x13>
		if (*s == c)
  800aa0:	38 ca                	cmp    %cl,%dl
  800aa2:	74 0f                	je     800ab3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	0f b6 10             	movzbl (%eax),%edx
  800aaa:	84 d2                	test   %dl,%dl
  800aac:	75 f2                	jne    800aa0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abf:	eb 03                	jmp    800ac4 <strfind+0xf>
  800ac1:	83 c0 01             	add    $0x1,%eax
  800ac4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac7:	38 ca                	cmp    %cl,%dl
  800ac9:	74 04                	je     800acf <strfind+0x1a>
  800acb:	84 d2                	test   %dl,%dl
  800acd:	75 f2                	jne    800ac1 <strfind+0xc>
			break;
	return (char *) s;
}
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ada:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800add:	85 c9                	test   %ecx,%ecx
  800adf:	74 36                	je     800b17 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae7:	75 28                	jne    800b11 <memset+0x40>
  800ae9:	f6 c1 03             	test   $0x3,%cl
  800aec:	75 23                	jne    800b11 <memset+0x40>
		c &= 0xFF;
  800aee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af2:	89 d3                	mov    %edx,%ebx
  800af4:	c1 e3 08             	shl    $0x8,%ebx
  800af7:	89 d6                	mov    %edx,%esi
  800af9:	c1 e6 18             	shl    $0x18,%esi
  800afc:	89 d0                	mov    %edx,%eax
  800afe:	c1 e0 10             	shl    $0x10,%eax
  800b01:	09 f0                	or     %esi,%eax
  800b03:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b05:	89 d8                	mov    %ebx,%eax
  800b07:	09 d0                	or     %edx,%eax
  800b09:	c1 e9 02             	shr    $0x2,%ecx
  800b0c:	fc                   	cld    
  800b0d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b0f:	eb 06                	jmp    800b17 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b14:	fc                   	cld    
  800b15:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b17:	89 f8                	mov    %edi,%eax
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b2c:	39 c6                	cmp    %eax,%esi
  800b2e:	73 35                	jae    800b65 <memmove+0x47>
  800b30:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b33:	39 d0                	cmp    %edx,%eax
  800b35:	73 2e                	jae    800b65 <memmove+0x47>
		s += n;
		d += n;
  800b37:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	09 fe                	or     %edi,%esi
  800b3e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b44:	75 13                	jne    800b59 <memmove+0x3b>
  800b46:	f6 c1 03             	test   $0x3,%cl
  800b49:	75 0e                	jne    800b59 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b4b:	83 ef 04             	sub    $0x4,%edi
  800b4e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b51:	c1 e9 02             	shr    $0x2,%ecx
  800b54:	fd                   	std    
  800b55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b57:	eb 09                	jmp    800b62 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b59:	83 ef 01             	sub    $0x1,%edi
  800b5c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b5f:	fd                   	std    
  800b60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b62:	fc                   	cld    
  800b63:	eb 1d                	jmp    800b82 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b65:	89 f2                	mov    %esi,%edx
  800b67:	09 c2                	or     %eax,%edx
  800b69:	f6 c2 03             	test   $0x3,%dl
  800b6c:	75 0f                	jne    800b7d <memmove+0x5f>
  800b6e:	f6 c1 03             	test   $0x3,%cl
  800b71:	75 0a                	jne    800b7d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b73:	c1 e9 02             	shr    $0x2,%ecx
  800b76:	89 c7                	mov    %eax,%edi
  800b78:	fc                   	cld    
  800b79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7b:	eb 05                	jmp    800b82 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b7d:	89 c7                	mov    %eax,%edi
  800b7f:	fc                   	cld    
  800b80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b89:	ff 75 10             	pushl  0x10(%ebp)
  800b8c:	ff 75 0c             	pushl  0xc(%ebp)
  800b8f:	ff 75 08             	pushl  0x8(%ebp)
  800b92:	e8 87 ff ff ff       	call   800b1e <memmove>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba4:	89 c6                	mov    %eax,%esi
  800ba6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba9:	eb 1a                	jmp    800bc5 <memcmp+0x2c>
		if (*s1 != *s2)
  800bab:	0f b6 08             	movzbl (%eax),%ecx
  800bae:	0f b6 1a             	movzbl (%edx),%ebx
  800bb1:	38 d9                	cmp    %bl,%cl
  800bb3:	74 0a                	je     800bbf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bb5:	0f b6 c1             	movzbl %cl,%eax
  800bb8:	0f b6 db             	movzbl %bl,%ebx
  800bbb:	29 d8                	sub    %ebx,%eax
  800bbd:	eb 0f                	jmp    800bce <memcmp+0x35>
		s1++, s2++;
  800bbf:	83 c0 01             	add    $0x1,%eax
  800bc2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc5:	39 f0                	cmp    %esi,%eax
  800bc7:	75 e2                	jne    800bab <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	53                   	push   %ebx
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bd9:	89 c1                	mov    %eax,%ecx
  800bdb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bde:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be2:	eb 0a                	jmp    800bee <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be4:	0f b6 10             	movzbl (%eax),%edx
  800be7:	39 da                	cmp    %ebx,%edx
  800be9:	74 07                	je     800bf2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800beb:	83 c0 01             	add    $0x1,%eax
  800bee:	39 c8                	cmp    %ecx,%eax
  800bf0:	72 f2                	jb     800be4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c01:	eb 03                	jmp    800c06 <strtol+0x11>
		s++;
  800c03:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c06:	0f b6 01             	movzbl (%ecx),%eax
  800c09:	3c 20                	cmp    $0x20,%al
  800c0b:	74 f6                	je     800c03 <strtol+0xe>
  800c0d:	3c 09                	cmp    $0x9,%al
  800c0f:	74 f2                	je     800c03 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c11:	3c 2b                	cmp    $0x2b,%al
  800c13:	75 0a                	jne    800c1f <strtol+0x2a>
		s++;
  800c15:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c18:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1d:	eb 11                	jmp    800c30 <strtol+0x3b>
  800c1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c24:	3c 2d                	cmp    $0x2d,%al
  800c26:	75 08                	jne    800c30 <strtol+0x3b>
		s++, neg = 1;
  800c28:	83 c1 01             	add    $0x1,%ecx
  800c2b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c36:	75 15                	jne    800c4d <strtol+0x58>
  800c38:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3b:	75 10                	jne    800c4d <strtol+0x58>
  800c3d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c41:	75 7c                	jne    800cbf <strtol+0xca>
		s += 2, base = 16;
  800c43:	83 c1 02             	add    $0x2,%ecx
  800c46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4b:	eb 16                	jmp    800c63 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c4d:	85 db                	test   %ebx,%ebx
  800c4f:	75 12                	jne    800c63 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c51:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c56:	80 39 30             	cmpb   $0x30,(%ecx)
  800c59:	75 08                	jne    800c63 <strtol+0x6e>
		s++, base = 8;
  800c5b:	83 c1 01             	add    $0x1,%ecx
  800c5e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
  800c68:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6b:	0f b6 11             	movzbl (%ecx),%edx
  800c6e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	80 fb 09             	cmp    $0x9,%bl
  800c76:	77 08                	ja     800c80 <strtol+0x8b>
			dig = *s - '0';
  800c78:	0f be d2             	movsbl %dl,%edx
  800c7b:	83 ea 30             	sub    $0x30,%edx
  800c7e:	eb 22                	jmp    800ca2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c80:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c83:	89 f3                	mov    %esi,%ebx
  800c85:	80 fb 19             	cmp    $0x19,%bl
  800c88:	77 08                	ja     800c92 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c8a:	0f be d2             	movsbl %dl,%edx
  800c8d:	83 ea 57             	sub    $0x57,%edx
  800c90:	eb 10                	jmp    800ca2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c92:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c95:	89 f3                	mov    %esi,%ebx
  800c97:	80 fb 19             	cmp    $0x19,%bl
  800c9a:	77 16                	ja     800cb2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c9c:	0f be d2             	movsbl %dl,%edx
  800c9f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ca2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ca5:	7d 0b                	jge    800cb2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ca7:	83 c1 01             	add    $0x1,%ecx
  800caa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cae:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cb0:	eb b9                	jmp    800c6b <strtol+0x76>

	if (endptr)
  800cb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb6:	74 0d                	je     800cc5 <strtol+0xd0>
		*endptr = (char *) s;
  800cb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbb:	89 0e                	mov    %ecx,(%esi)
  800cbd:	eb 06                	jmp    800cc5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cbf:	85 db                	test   %ebx,%ebx
  800cc1:	74 98                	je     800c5b <strtol+0x66>
  800cc3:	eb 9e                	jmp    800c63 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cc5:	89 c2                	mov    %eax,%edx
  800cc7:	f7 da                	neg    %edx
  800cc9:	85 ff                	test   %edi,%edi
  800ccb:	0f 45 c2             	cmovne %edx,%eax
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 c3                	mov    %eax,%ebx
  800ce6:	89 c7                	mov    %eax,%edi
  800ce8:	89 c6                	mov    %eax,%esi
  800cea:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfc:	b8 01 00 00 00       	mov    $0x1,%eax
  800d01:	89 d1                	mov    %edx,%ecx
  800d03:	89 d3                	mov    %edx,%ebx
  800d05:	89 d7                	mov    %edx,%edi
  800d07:	89 d6                	mov    %edx,%esi
  800d09:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 cb                	mov    %ecx,%ebx
  800d28:	89 cf                	mov    %ecx,%edi
  800d2a:	89 ce                	mov    %ecx,%esi
  800d2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7e 17                	jle    800d49 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	6a 03                	push   $0x3
  800d38:	68 ff 2a 80 00       	push   $0x802aff
  800d3d:	6a 23                	push   $0x23
  800d3f:	68 1c 2b 80 00       	push   $0x802b1c
  800d44:	e8 e5 f5 ff ff       	call   80032e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5c:	b8 02 00 00 00       	mov    $0x2,%eax
  800d61:	89 d1                	mov    %edx,%ecx
  800d63:	89 d3                	mov    %edx,%ebx
  800d65:	89 d7                	mov    %edx,%edi
  800d67:	89 d6                	mov    %edx,%esi
  800d69:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_yield>:

void
sys_yield(void)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d80:	89 d1                	mov    %edx,%ecx
  800d82:	89 d3                	mov    %edx,%ebx
  800d84:	89 d7                	mov    %edx,%edi
  800d86:	89 d6                	mov    %edx,%esi
  800d88:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d98:	be 00 00 00 00       	mov    $0x0,%esi
  800d9d:	b8 04 00 00 00       	mov    $0x4,%eax
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dab:	89 f7                	mov    %esi,%edi
  800dad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 17                	jle    800dca <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	50                   	push   %eax
  800db7:	6a 04                	push   $0x4
  800db9:	68 ff 2a 80 00       	push   $0x802aff
  800dbe:	6a 23                	push   $0x23
  800dc0:	68 1c 2b 80 00       	push   $0x802b1c
  800dc5:	e8 64 f5 ff ff       	call   80032e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	b8 05 00 00 00       	mov    $0x5,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dec:	8b 75 18             	mov    0x18(%ebp),%esi
  800def:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 17                	jle    800e0c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	50                   	push   %eax
  800df9:	6a 05                	push   $0x5
  800dfb:	68 ff 2a 80 00       	push   $0x802aff
  800e00:	6a 23                	push   $0x23
  800e02:	68 1c 2b 80 00       	push   $0x802b1c
  800e07:	e8 22 f5 ff ff       	call   80032e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e22:	b8 06 00 00 00       	mov    $0x6,%eax
  800e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 df                	mov    %ebx,%edi
  800e2f:	89 de                	mov    %ebx,%esi
  800e31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e33:	85 c0                	test   %eax,%eax
  800e35:	7e 17                	jle    800e4e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	50                   	push   %eax
  800e3b:	6a 06                	push   $0x6
  800e3d:	68 ff 2a 80 00       	push   $0x802aff
  800e42:	6a 23                	push   $0x23
  800e44:	68 1c 2b 80 00       	push   $0x802b1c
  800e49:	e8 e0 f4 ff ff       	call   80032e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e64:	b8 08 00 00 00       	mov    $0x8,%eax
  800e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 df                	mov    %ebx,%edi
  800e71:	89 de                	mov    %ebx,%esi
  800e73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 17                	jle    800e90 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	6a 08                	push   $0x8
  800e7f:	68 ff 2a 80 00       	push   $0x802aff
  800e84:	6a 23                	push   $0x23
  800e86:	68 1c 2b 80 00       	push   $0x802b1c
  800e8b:	e8 9e f4 ff ff       	call   80032e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea6:	b8 09 00 00 00       	mov    $0x9,%eax
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	89 df                	mov    %ebx,%edi
  800eb3:	89 de                	mov    %ebx,%esi
  800eb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 17                	jle    800ed2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	50                   	push   %eax
  800ebf:	6a 09                	push   $0x9
  800ec1:	68 ff 2a 80 00       	push   $0x802aff
  800ec6:	6a 23                	push   $0x23
  800ec8:	68 1c 2b 80 00       	push   $0x802b1c
  800ecd:	e8 5c f4 ff ff       	call   80032e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef3:	89 df                	mov    %ebx,%edi
  800ef5:	89 de                	mov    %ebx,%esi
  800ef7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7e 17                	jle    800f14 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efd:	83 ec 0c             	sub    $0xc,%esp
  800f00:	50                   	push   %eax
  800f01:	6a 0a                	push   $0xa
  800f03:	68 ff 2a 80 00       	push   $0x802aff
  800f08:	6a 23                	push   $0x23
  800f0a:	68 1c 2b 80 00       	push   $0x802b1c
  800f0f:	e8 1a f4 ff ff       	call   80032e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f22:	be 00 00 00 00       	mov    $0x0,%esi
  800f27:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f38:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f3a:	5b                   	pop    %ebx
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	57                   	push   %edi
  800f43:	56                   	push   %esi
  800f44:	53                   	push   %ebx
  800f45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	89 cb                	mov    %ecx,%ebx
  800f57:	89 cf                	mov    %ecx,%edi
  800f59:	89 ce                	mov    %ecx,%esi
  800f5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	7e 17                	jle    800f78 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	50                   	push   %eax
  800f65:	6a 0d                	push   $0xd
  800f67:	68 ff 2a 80 00       	push   $0x802aff
  800f6c:	6a 23                	push   $0x23
  800f6e:	68 1c 2b 80 00       	push   $0x802b1c
  800f73:	e8 b6 f3 ff ff       	call   80032e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7b:	5b                   	pop    %ebx
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f86:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f90:	89 d1                	mov    %edx,%ecx
  800f92:	89 d3                	mov    %edx,%ebx
  800f94:	89 d7                	mov    %edx,%edi
  800f96:	89 d6                	mov    %edx,%esi
  800f98:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800faa:	b8 0f 00 00 00       	mov    $0xf,%eax
  800faf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb5:	89 df                	mov    %ebx,%edi
  800fb7:	89 de                	mov    %ebx,%esi
  800fb9:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fcc:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fce:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fd1:	83 3a 01             	cmpl   $0x1,(%edx)
  800fd4:	7e 09                	jle    800fdf <argstart+0x1f>
  800fd6:	ba a8 27 80 00       	mov    $0x8027a8,%edx
  800fdb:	85 c9                	test   %ecx,%ecx
  800fdd:	75 05                	jne    800fe4 <argstart+0x24>
  800fdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe4:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fe7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <argnext>:

int
argnext(struct Argstate *args)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800ffa:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801001:	8b 43 08             	mov    0x8(%ebx),%eax
  801004:	85 c0                	test   %eax,%eax
  801006:	74 6f                	je     801077 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801008:	80 38 00             	cmpb   $0x0,(%eax)
  80100b:	75 4e                	jne    80105b <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80100d:	8b 0b                	mov    (%ebx),%ecx
  80100f:	83 39 01             	cmpl   $0x1,(%ecx)
  801012:	74 55                	je     801069 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801014:	8b 53 04             	mov    0x4(%ebx),%edx
  801017:	8b 42 04             	mov    0x4(%edx),%eax
  80101a:	80 38 2d             	cmpb   $0x2d,(%eax)
  80101d:	75 4a                	jne    801069 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80101f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801023:	74 44                	je     801069 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801025:	83 c0 01             	add    $0x1,%eax
  801028:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	8b 01                	mov    (%ecx),%eax
  801030:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801037:	50                   	push   %eax
  801038:	8d 42 08             	lea    0x8(%edx),%eax
  80103b:	50                   	push   %eax
  80103c:	83 c2 04             	add    $0x4,%edx
  80103f:	52                   	push   %edx
  801040:	e8 d9 fa ff ff       	call   800b1e <memmove>
		(*args->argc)--;
  801045:	8b 03                	mov    (%ebx),%eax
  801047:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80104a:	8b 43 08             	mov    0x8(%ebx),%eax
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	80 38 2d             	cmpb   $0x2d,(%eax)
  801053:	75 06                	jne    80105b <argnext+0x6b>
  801055:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801059:	74 0e                	je     801069 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80105b:	8b 53 08             	mov    0x8(%ebx),%edx
  80105e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801061:	83 c2 01             	add    $0x1,%edx
  801064:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801067:	eb 13                	jmp    80107c <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801069:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801070:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801075:	eb 05                	jmp    80107c <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801077:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	53                   	push   %ebx
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80108b:	8b 43 08             	mov    0x8(%ebx),%eax
  80108e:	85 c0                	test   %eax,%eax
  801090:	74 58                	je     8010ea <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801092:	80 38 00             	cmpb   $0x0,(%eax)
  801095:	74 0c                	je     8010a3 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801097:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80109a:	c7 43 08 a8 27 80 00 	movl   $0x8027a8,0x8(%ebx)
  8010a1:	eb 42                	jmp    8010e5 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8010a3:	8b 13                	mov    (%ebx),%edx
  8010a5:	83 3a 01             	cmpl   $0x1,(%edx)
  8010a8:	7e 2d                	jle    8010d7 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8010aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8010ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8010b0:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	8b 12                	mov    (%edx),%edx
  8010b8:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8010bf:	52                   	push   %edx
  8010c0:	8d 50 08             	lea    0x8(%eax),%edx
  8010c3:	52                   	push   %edx
  8010c4:	83 c0 04             	add    $0x4,%eax
  8010c7:	50                   	push   %eax
  8010c8:	e8 51 fa ff ff       	call   800b1e <memmove>
		(*args->argc)--;
  8010cd:	8b 03                	mov    (%ebx),%eax
  8010cf:	83 28 01             	subl   $0x1,(%eax)
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	eb 0e                	jmp    8010e5 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8010d7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010de:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010e5:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010e8:	eb 05                	jmp    8010ef <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f2:	c9                   	leave  
  8010f3:	c3                   	ret    

008010f4 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	83 ec 08             	sub    $0x8,%esp
  8010fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010fd:	8b 51 0c             	mov    0xc(%ecx),%edx
  801100:	89 d0                	mov    %edx,%eax
  801102:	85 d2                	test   %edx,%edx
  801104:	75 0c                	jne    801112 <argvalue+0x1e>
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	51                   	push   %ecx
  80110a:	e8 72 ff ff ff       	call   801081 <argnextvalue>
  80110f:	83 c4 10             	add    $0x10,%esp
}
  801112:	c9                   	leave  
  801113:	c3                   	ret    

00801114 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
  80111a:	05 00 00 00 30       	add    $0x30000000,%eax
  80111f:	c1 e8 0c             	shr    $0xc,%eax
}
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
  80112a:	05 00 00 00 30       	add    $0x30000000,%eax
  80112f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801134:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801141:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801146:	89 c2                	mov    %eax,%edx
  801148:	c1 ea 16             	shr    $0x16,%edx
  80114b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801152:	f6 c2 01             	test   $0x1,%dl
  801155:	74 11                	je     801168 <fd_alloc+0x2d>
  801157:	89 c2                	mov    %eax,%edx
  801159:	c1 ea 0c             	shr    $0xc,%edx
  80115c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801163:	f6 c2 01             	test   $0x1,%dl
  801166:	75 09                	jne    801171 <fd_alloc+0x36>
			*fd_store = fd;
  801168:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
  80116f:	eb 17                	jmp    801188 <fd_alloc+0x4d>
  801171:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801176:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117b:	75 c9                	jne    801146 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801183:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801190:	83 f8 1f             	cmp    $0x1f,%eax
  801193:	77 36                	ja     8011cb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801195:	c1 e0 0c             	shl    $0xc,%eax
  801198:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	c1 ea 16             	shr    $0x16,%edx
  8011a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	74 24                	je     8011d2 <fd_lookup+0x48>
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	c1 ea 0c             	shr    $0xc,%edx
  8011b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ba:	f6 c2 01             	test   $0x1,%dl
  8011bd:	74 1a                	je     8011d9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c2:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c9:	eb 13                	jmp    8011de <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d0:	eb 0c                	jmp    8011de <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d7:	eb 05                	jmp    8011de <fd_lookup+0x54>
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e9:	ba ac 2b 80 00       	mov    $0x802bac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ee:	eb 13                	jmp    801203 <dev_lookup+0x23>
  8011f0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011f3:	39 08                	cmp    %ecx,(%eax)
  8011f5:	75 0c                	jne    801203 <dev_lookup+0x23>
			*dev = devtab[i];
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801201:	eb 2e                	jmp    801231 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801203:	8b 02                	mov    (%edx),%eax
  801205:	85 c0                	test   %eax,%eax
  801207:	75 e7                	jne    8011f0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801209:	a1 20 44 80 00       	mov    0x804420,%eax
  80120e:	8b 40 48             	mov    0x48(%eax),%eax
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	51                   	push   %ecx
  801215:	50                   	push   %eax
  801216:	68 2c 2b 80 00       	push   $0x802b2c
  80121b:	e8 e7 f1 ff ff       	call   800407 <cprintf>
	*dev = 0;
  801220:	8b 45 0c             	mov    0xc(%ebp),%eax
  801223:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801231:	c9                   	leave  
  801232:	c3                   	ret    

00801233 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	83 ec 10             	sub    $0x10,%esp
  80123b:	8b 75 08             	mov    0x8(%ebp),%esi
  80123e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80124b:	c1 e8 0c             	shr    $0xc,%eax
  80124e:	50                   	push   %eax
  80124f:	e8 36 ff ff ff       	call   80118a <fd_lookup>
  801254:	83 c4 08             	add    $0x8,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	78 05                	js     801260 <fd_close+0x2d>
	    || fd != fd2)
  80125b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80125e:	74 0c                	je     80126c <fd_close+0x39>
		return (must_exist ? r : 0);
  801260:	84 db                	test   %bl,%bl
  801262:	ba 00 00 00 00       	mov    $0x0,%edx
  801267:	0f 44 c2             	cmove  %edx,%eax
  80126a:	eb 41                	jmp    8012ad <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	ff 36                	pushl  (%esi)
  801275:	e8 66 ff ff ff       	call   8011e0 <dev_lookup>
  80127a:	89 c3                	mov    %eax,%ebx
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 1a                	js     80129d <fd_close+0x6a>
		if (dev->dev_close)
  801283:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801286:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801289:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80128e:	85 c0                	test   %eax,%eax
  801290:	74 0b                	je     80129d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801292:	83 ec 0c             	sub    $0xc,%esp
  801295:	56                   	push   %esi
  801296:	ff d0                	call   *%eax
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	56                   	push   %esi
  8012a1:	6a 00                	push   $0x0
  8012a3:	e8 6c fb ff ff       	call   800e14 <sys_page_unmap>
	return r;
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	89 d8                	mov    %ebx,%eax
}
  8012ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	ff 75 08             	pushl  0x8(%ebp)
  8012c1:	e8 c4 fe ff ff       	call   80118a <fd_lookup>
  8012c6:	83 c4 08             	add    $0x8,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	78 10                	js     8012dd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	6a 01                	push   $0x1
  8012d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d5:	e8 59 ff ff ff       	call   801233 <fd_close>
  8012da:	83 c4 10             	add    $0x10,%esp
}
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <close_all>:

void
close_all(void)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	53                   	push   %ebx
  8012e3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012eb:	83 ec 0c             	sub    $0xc,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	e8 c0 ff ff ff       	call   8012b4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f4:	83 c3 01             	add    $0x1,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	83 fb 20             	cmp    $0x20,%ebx
  8012fd:	75 ec                	jne    8012eb <close_all+0xc>
		close(i);
}
  8012ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801302:	c9                   	leave  
  801303:	c3                   	ret    

00801304 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	57                   	push   %edi
  801308:	56                   	push   %esi
  801309:	53                   	push   %ebx
  80130a:	83 ec 2c             	sub    $0x2c,%esp
  80130d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801310:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	ff 75 08             	pushl  0x8(%ebp)
  801317:	e8 6e fe ff ff       	call   80118a <fd_lookup>
  80131c:	83 c4 08             	add    $0x8,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	0f 88 c1 00 00 00    	js     8013e8 <dup+0xe4>
		return r;
	close(newfdnum);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	56                   	push   %esi
  80132b:	e8 84 ff ff ff       	call   8012b4 <close>

	newfd = INDEX2FD(newfdnum);
  801330:	89 f3                	mov    %esi,%ebx
  801332:	c1 e3 0c             	shl    $0xc,%ebx
  801335:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80133b:	83 c4 04             	add    $0x4,%esp
  80133e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801341:	e8 de fd ff ff       	call   801124 <fd2data>
  801346:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801348:	89 1c 24             	mov    %ebx,(%esp)
  80134b:	e8 d4 fd ff ff       	call   801124 <fd2data>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801356:	89 f8                	mov    %edi,%eax
  801358:	c1 e8 16             	shr    $0x16,%eax
  80135b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801362:	a8 01                	test   $0x1,%al
  801364:	74 37                	je     80139d <dup+0x99>
  801366:	89 f8                	mov    %edi,%eax
  801368:	c1 e8 0c             	shr    $0xc,%eax
  80136b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801372:	f6 c2 01             	test   $0x1,%dl
  801375:	74 26                	je     80139d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801377:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137e:	83 ec 0c             	sub    $0xc,%esp
  801381:	25 07 0e 00 00       	and    $0xe07,%eax
  801386:	50                   	push   %eax
  801387:	ff 75 d4             	pushl  -0x2c(%ebp)
  80138a:	6a 00                	push   $0x0
  80138c:	57                   	push   %edi
  80138d:	6a 00                	push   $0x0
  80138f:	e8 3e fa ff ff       	call   800dd2 <sys_page_map>
  801394:	89 c7                	mov    %eax,%edi
  801396:	83 c4 20             	add    $0x20,%esp
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 2e                	js     8013cb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a0:	89 d0                	mov    %edx,%eax
  8013a2:	c1 e8 0c             	shr    $0xc,%eax
  8013a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b4:	50                   	push   %eax
  8013b5:	53                   	push   %ebx
  8013b6:	6a 00                	push   $0x0
  8013b8:	52                   	push   %edx
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 12 fa ff ff       	call   800dd2 <sys_page_map>
  8013c0:	89 c7                	mov    %eax,%edi
  8013c2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013c5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c7:	85 ff                	test   %edi,%edi
  8013c9:	79 1d                	jns    8013e8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	53                   	push   %ebx
  8013cf:	6a 00                	push   $0x0
  8013d1:	e8 3e fa ff ff       	call   800e14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d6:	83 c4 08             	add    $0x8,%esp
  8013d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 31 fa ff ff       	call   800e14 <sys_page_unmap>
	return r;
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	89 f8                	mov    %edi,%eax
}
  8013e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013eb:	5b                   	pop    %ebx
  8013ec:	5e                   	pop    %esi
  8013ed:	5f                   	pop    %edi
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 14             	sub    $0x14,%esp
  8013f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	53                   	push   %ebx
  8013ff:	e8 86 fd ff ff       	call   80118a <fd_lookup>
  801404:	83 c4 08             	add    $0x8,%esp
  801407:	89 c2                	mov    %eax,%edx
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 6d                	js     80147a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801417:	ff 30                	pushl  (%eax)
  801419:	e8 c2 fd ff ff       	call   8011e0 <dev_lookup>
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 4c                	js     801471 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801425:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801428:	8b 42 08             	mov    0x8(%edx),%eax
  80142b:	83 e0 03             	and    $0x3,%eax
  80142e:	83 f8 01             	cmp    $0x1,%eax
  801431:	75 21                	jne    801454 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801433:	a1 20 44 80 00       	mov    0x804420,%eax
  801438:	8b 40 48             	mov    0x48(%eax),%eax
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	53                   	push   %ebx
  80143f:	50                   	push   %eax
  801440:	68 70 2b 80 00       	push   $0x802b70
  801445:	e8 bd ef ff ff       	call   800407 <cprintf>
		return -E_INVAL;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801452:	eb 26                	jmp    80147a <read+0x8a>
	}
	if (!dev->dev_read)
  801454:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801457:	8b 40 08             	mov    0x8(%eax),%eax
  80145a:	85 c0                	test   %eax,%eax
  80145c:	74 17                	je     801475 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80145e:	83 ec 04             	sub    $0x4,%esp
  801461:	ff 75 10             	pushl  0x10(%ebp)
  801464:	ff 75 0c             	pushl  0xc(%ebp)
  801467:	52                   	push   %edx
  801468:	ff d0                	call   *%eax
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	eb 09                	jmp    80147a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801471:	89 c2                	mov    %eax,%edx
  801473:	eb 05                	jmp    80147a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801475:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80147a:	89 d0                	mov    %edx,%eax
  80147c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	57                   	push   %edi
  801485:	56                   	push   %esi
  801486:	53                   	push   %ebx
  801487:	83 ec 0c             	sub    $0xc,%esp
  80148a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801490:	bb 00 00 00 00       	mov    $0x0,%ebx
  801495:	eb 21                	jmp    8014b8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	89 f0                	mov    %esi,%eax
  80149c:	29 d8                	sub    %ebx,%eax
  80149e:	50                   	push   %eax
  80149f:	89 d8                	mov    %ebx,%eax
  8014a1:	03 45 0c             	add    0xc(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	57                   	push   %edi
  8014a6:	e8 45 ff ff ff       	call   8013f0 <read>
		if (m < 0)
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 10                	js     8014c2 <readn+0x41>
			return m;
		if (m == 0)
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	74 0a                	je     8014c0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b6:	01 c3                	add    %eax,%ebx
  8014b8:	39 f3                	cmp    %esi,%ebx
  8014ba:	72 db                	jb     801497 <readn+0x16>
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	eb 02                	jmp    8014c2 <readn+0x41>
  8014c0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c5:	5b                   	pop    %ebx
  8014c6:	5e                   	pop    %esi
  8014c7:	5f                   	pop    %edi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 14             	sub    $0x14,%esp
  8014d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	53                   	push   %ebx
  8014d9:	e8 ac fc ff ff       	call   80118a <fd_lookup>
  8014de:	83 c4 08             	add    $0x8,%esp
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 68                	js     80154f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f1:	ff 30                	pushl  (%eax)
  8014f3:	e8 e8 fc ff ff       	call   8011e0 <dev_lookup>
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 47                	js     801546 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801506:	75 21                	jne    801529 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801508:	a1 20 44 80 00       	mov    0x804420,%eax
  80150d:	8b 40 48             	mov    0x48(%eax),%eax
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	53                   	push   %ebx
  801514:	50                   	push   %eax
  801515:	68 8c 2b 80 00       	push   $0x802b8c
  80151a:	e8 e8 ee ff ff       	call   800407 <cprintf>
		return -E_INVAL;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801527:	eb 26                	jmp    80154f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801529:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152c:	8b 52 0c             	mov    0xc(%edx),%edx
  80152f:	85 d2                	test   %edx,%edx
  801531:	74 17                	je     80154a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	ff 75 10             	pushl  0x10(%ebp)
  801539:	ff 75 0c             	pushl  0xc(%ebp)
  80153c:	50                   	push   %eax
  80153d:	ff d2                	call   *%edx
  80153f:	89 c2                	mov    %eax,%edx
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	eb 09                	jmp    80154f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801546:	89 c2                	mov    %eax,%edx
  801548:	eb 05                	jmp    80154f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80154a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80154f:	89 d0                	mov    %edx,%eax
  801551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <seek>:

int
seek(int fdnum, off_t offset)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	ff 75 08             	pushl  0x8(%ebp)
  801563:	e8 22 fc ff ff       	call   80118a <fd_lookup>
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 0e                	js     80157d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80156f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801572:	8b 55 0c             	mov    0xc(%ebp),%edx
  801575:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801578:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	53                   	push   %ebx
  801583:	83 ec 14             	sub    $0x14,%esp
  801586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801589:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158c:	50                   	push   %eax
  80158d:	53                   	push   %ebx
  80158e:	e8 f7 fb ff ff       	call   80118a <fd_lookup>
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	89 c2                	mov    %eax,%edx
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 65                	js     801601 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a6:	ff 30                	pushl  (%eax)
  8015a8:	e8 33 fc ff ff       	call   8011e0 <dev_lookup>
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 44                	js     8015f8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015bb:	75 21                	jne    8015de <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015bd:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c2:	8b 40 48             	mov    0x48(%eax),%eax
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	50                   	push   %eax
  8015ca:	68 4c 2b 80 00       	push   $0x802b4c
  8015cf:	e8 33 ee ff ff       	call   800407 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015dc:	eb 23                	jmp    801601 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e1:	8b 52 18             	mov    0x18(%edx),%edx
  8015e4:	85 d2                	test   %edx,%edx
  8015e6:	74 14                	je     8015fc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ee:	50                   	push   %eax
  8015ef:	ff d2                	call   *%edx
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	eb 09                	jmp    801601 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	eb 05                	jmp    801601 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801601:	89 d0                	mov    %edx,%eax
  801603:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	53                   	push   %ebx
  80160c:	83 ec 14             	sub    $0x14,%esp
  80160f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801612:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	ff 75 08             	pushl  0x8(%ebp)
  801619:	e8 6c fb ff ff       	call   80118a <fd_lookup>
  80161e:	83 c4 08             	add    $0x8,%esp
  801621:	89 c2                	mov    %eax,%edx
  801623:	85 c0                	test   %eax,%eax
  801625:	78 58                	js     80167f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	ff 30                	pushl  (%eax)
  801633:	e8 a8 fb ff ff       	call   8011e0 <dev_lookup>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 37                	js     801676 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80163f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801642:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801646:	74 32                	je     80167a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801648:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80164b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801652:	00 00 00 
	stat->st_isdir = 0;
  801655:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165c:	00 00 00 
	stat->st_dev = dev;
  80165f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	53                   	push   %ebx
  801669:	ff 75 f0             	pushl  -0x10(%ebp)
  80166c:	ff 50 14             	call   *0x14(%eax)
  80166f:	89 c2                	mov    %eax,%edx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	eb 09                	jmp    80167f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801676:	89 c2                	mov    %eax,%edx
  801678:	eb 05                	jmp    80167f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80167a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80167f:	89 d0                	mov    %edx,%eax
  801681:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	6a 00                	push   $0x0
  801690:	ff 75 08             	pushl  0x8(%ebp)
  801693:	e8 e7 01 00 00       	call   80187f <open>
  801698:	89 c3                	mov    %eax,%ebx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 1b                	js     8016bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	ff 75 0c             	pushl  0xc(%ebp)
  8016a7:	50                   	push   %eax
  8016a8:	e8 5b ff ff ff       	call   801608 <fstat>
  8016ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8016af:	89 1c 24             	mov    %ebx,(%esp)
  8016b2:	e8 fd fb ff ff       	call   8012b4 <close>
	return r;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	89 f0                	mov    %esi,%eax
}
  8016bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	89 c6                	mov    %eax,%esi
  8016ca:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d3:	75 12                	jne    8016e7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d5:	83 ec 0c             	sub    $0xc,%esp
  8016d8:	6a 01                	push   $0x1
  8016da:	e8 5b 0d 00 00       	call   80243a <ipc_find_env>
  8016df:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e7:	6a 07                	push   $0x7
  8016e9:	68 00 50 80 00       	push   $0x805000
  8016ee:	56                   	push   %esi
  8016ef:	ff 35 00 40 80 00    	pushl  0x804000
  8016f5:	e8 ec 0c 00 00       	call   8023e6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016fa:	83 c4 0c             	add    $0xc,%esp
  8016fd:	6a 00                	push   $0x0
  8016ff:	53                   	push   %ebx
  801700:	6a 00                	push   $0x0
  801702:	e8 72 0c 00 00       	call   802379 <ipc_recv>
}
  801707:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	8b 40 0c             	mov    0xc(%eax),%eax
  80171a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80171f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801722:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801727:	ba 00 00 00 00       	mov    $0x0,%edx
  80172c:	b8 02 00 00 00       	mov    $0x2,%eax
  801731:	e8 8d ff ff ff       	call   8016c3 <fsipc>
}
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 06 00 00 00       	mov    $0x6,%eax
  801753:	e8 6b ff ff ff       	call   8016c3 <fsipc>
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 04             	sub    $0x4,%esp
  801761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801764:	8b 45 08             	mov    0x8(%ebp),%eax
  801767:	8b 40 0c             	mov    0xc(%eax),%eax
  80176a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	b8 05 00 00 00       	mov    $0x5,%eax
  801779:	e8 45 ff ff ff       	call   8016c3 <fsipc>
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 2c                	js     8017ae <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801782:	83 ec 08             	sub    $0x8,%esp
  801785:	68 00 50 80 00       	push   $0x805000
  80178a:	53                   	push   %ebx
  80178b:	e8 fc f1 ff ff       	call   80098c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801790:	a1 80 50 80 00       	mov    0x805080,%eax
  801795:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179b:	a1 84 50 80 00       	mov    0x805084,%eax
  8017a0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8017bd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017c2:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017c7:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017ca:	53                   	push   %ebx
  8017cb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ce:	68 08 50 80 00       	push   $0x805008
  8017d3:	e8 46 f3 ff ff       	call   800b1e <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	8b 40 0c             	mov    0xc(%eax),%eax
  8017de:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8017e3:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8017e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f3:	e8 cb fe ff ff       	call   8016c3 <fsipc>
	//panic("devfile_write not implemented");
}
  8017f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	8b 40 0c             	mov    0xc(%eax),%eax
  80180b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801810:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	b8 03 00 00 00       	mov    $0x3,%eax
  801820:	e8 9e fe ff ff       	call   8016c3 <fsipc>
  801825:	89 c3                	mov    %eax,%ebx
  801827:	85 c0                	test   %eax,%eax
  801829:	78 4b                	js     801876 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80182b:	39 c6                	cmp    %eax,%esi
  80182d:	73 16                	jae    801845 <devfile_read+0x48>
  80182f:	68 c0 2b 80 00       	push   $0x802bc0
  801834:	68 c7 2b 80 00       	push   $0x802bc7
  801839:	6a 7c                	push   $0x7c
  80183b:	68 dc 2b 80 00       	push   $0x802bdc
  801840:	e8 e9 ea ff ff       	call   80032e <_panic>
	assert(r <= PGSIZE);
  801845:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80184a:	7e 16                	jle    801862 <devfile_read+0x65>
  80184c:	68 e7 2b 80 00       	push   $0x802be7
  801851:	68 c7 2b 80 00       	push   $0x802bc7
  801856:	6a 7d                	push   $0x7d
  801858:	68 dc 2b 80 00       	push   $0x802bdc
  80185d:	e8 cc ea ff ff       	call   80032e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801862:	83 ec 04             	sub    $0x4,%esp
  801865:	50                   	push   %eax
  801866:	68 00 50 80 00       	push   $0x805000
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	e8 ab f2 ff ff       	call   800b1e <memmove>
	return r;
  801873:	83 c4 10             	add    $0x10,%esp
}
  801876:	89 d8                	mov    %ebx,%eax
  801878:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	53                   	push   %ebx
  801883:	83 ec 20             	sub    $0x20,%esp
  801886:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801889:	53                   	push   %ebx
  80188a:	e8 c4 f0 ff ff       	call   800953 <strlen>
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801897:	7f 67                	jg     801900 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	e8 96 f8 ff ff       	call   80113b <fd_alloc>
  8018a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 57                	js     801905 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ae:	83 ec 08             	sub    $0x8,%esp
  8018b1:	53                   	push   %ebx
  8018b2:	68 00 50 80 00       	push   $0x805000
  8018b7:	e8 d0 f0 ff ff       	call   80098c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018cc:	e8 f2 fd ff ff       	call   8016c3 <fsipc>
  8018d1:	89 c3                	mov    %eax,%ebx
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	79 14                	jns    8018ee <open+0x6f>
		fd_close(fd, 0);
  8018da:	83 ec 08             	sub    $0x8,%esp
  8018dd:	6a 00                	push   $0x0
  8018df:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e2:	e8 4c f9 ff ff       	call   801233 <fd_close>
		return r;
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	89 da                	mov    %ebx,%edx
  8018ec:	eb 17                	jmp    801905 <open+0x86>
	}

	return fd2num(fd);
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f4:	e8 1b f8 ff ff       	call   801114 <fd2num>
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	eb 05                	jmp    801905 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801900:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801905:	89 d0                	mov    %edx,%eax
  801907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801912:	ba 00 00 00 00       	mov    $0x0,%edx
  801917:	b8 08 00 00 00       	mov    $0x8,%eax
  80191c:	e8 a2 fd ff ff       	call   8016c3 <fsipc>
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801923:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801927:	7e 37                	jle    801960 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	53                   	push   %ebx
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801932:	ff 70 04             	pushl  0x4(%eax)
  801935:	8d 40 10             	lea    0x10(%eax),%eax
  801938:	50                   	push   %eax
  801939:	ff 33                	pushl  (%ebx)
  80193b:	e8 8a fb ff ff       	call   8014ca <write>
		if (result > 0)
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	7e 03                	jle    80194a <writebuf+0x27>
			b->result += result;
  801947:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80194a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80194d:	74 0d                	je     80195c <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80194f:	85 c0                	test   %eax,%eax
  801951:	ba 00 00 00 00       	mov    $0x0,%edx
  801956:	0f 4f c2             	cmovg  %edx,%eax
  801959:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80195c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195f:	c9                   	leave  
  801960:	f3 c3                	repz ret 

00801962 <putch>:

static void
putch(int ch, void *thunk)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	83 ec 04             	sub    $0x4,%esp
  801969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80196c:	8b 53 04             	mov    0x4(%ebx),%edx
  80196f:	8d 42 01             	lea    0x1(%edx),%eax
  801972:	89 43 04             	mov    %eax,0x4(%ebx)
  801975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801978:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80197c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801981:	75 0e                	jne    801991 <putch+0x2f>
		writebuf(b);
  801983:	89 d8                	mov    %ebx,%eax
  801985:	e8 99 ff ff ff       	call   801923 <writebuf>
		b->idx = 0;
  80198a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801991:	83 c4 04             	add    $0x4,%esp
  801994:	5b                   	pop    %ebx
  801995:	5d                   	pop    %ebp
  801996:	c3                   	ret    

00801997 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019a9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019b0:	00 00 00 
	b.result = 0;
  8019b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019ba:	00 00 00 
	b.error = 1;
  8019bd:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019c4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019c7:	ff 75 10             	pushl  0x10(%ebp)
  8019ca:	ff 75 0c             	pushl  0xc(%ebp)
  8019cd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019d3:	50                   	push   %eax
  8019d4:	68 62 19 80 00       	push   $0x801962
  8019d9:	e8 60 eb ff ff       	call   80053e <vprintfmt>
	if (b.idx > 0)
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019e8:	7e 0b                	jle    8019f5 <vfprintf+0x5e>
		writebuf(&b);
  8019ea:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019f0:	e8 2e ff ff ff       	call   801923 <writebuf>

	return (b.result ? b.result : b.error);
  8019f5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a0c:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a0f:	50                   	push   %eax
  801a10:	ff 75 0c             	pushl  0xc(%ebp)
  801a13:	ff 75 08             	pushl  0x8(%ebp)
  801a16:	e8 7c ff ff ff       	call   801997 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <printf>:

int
printf(const char *fmt, ...)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a23:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a26:	50                   	push   %eax
  801a27:	ff 75 08             	pushl  0x8(%ebp)
  801a2a:	6a 01                	push   $0x1
  801a2c:	e8 66 ff ff ff       	call   801997 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a39:	68 f3 2b 80 00       	push   $0x802bf3
  801a3e:	ff 75 0c             	pushl  0xc(%ebp)
  801a41:	e8 46 ef ff ff       	call   80098c <strcpy>
	return 0;
}
  801a46:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4b:	c9                   	leave  
  801a4c:	c3                   	ret    

00801a4d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	53                   	push   %ebx
  801a51:	83 ec 10             	sub    $0x10,%esp
  801a54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a57:	53                   	push   %ebx
  801a58:	e8 16 0a 00 00       	call   802473 <pageref>
  801a5d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a60:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a65:	83 f8 01             	cmp    $0x1,%eax
  801a68:	75 10                	jne    801a7a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	ff 73 0c             	pushl  0xc(%ebx)
  801a70:	e8 c0 02 00 00       	call   801d35 <nsipc_close>
  801a75:	89 c2                	mov    %eax,%edx
  801a77:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a7a:	89 d0                	mov    %edx,%eax
  801a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a87:	6a 00                	push   $0x0
  801a89:	ff 75 10             	pushl  0x10(%ebp)
  801a8c:	ff 75 0c             	pushl  0xc(%ebp)
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	ff 70 0c             	pushl  0xc(%eax)
  801a95:	e8 78 03 00 00       	call   801e12 <nsipc_send>
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801aa2:	6a 00                	push   $0x0
  801aa4:	ff 75 10             	pushl  0x10(%ebp)
  801aa7:	ff 75 0c             	pushl  0xc(%ebp)
  801aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801aad:	ff 70 0c             	pushl  0xc(%eax)
  801ab0:	e8 f1 02 00 00       	call   801da6 <nsipc_recv>
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801abd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ac0:	52                   	push   %edx
  801ac1:	50                   	push   %eax
  801ac2:	e8 c3 f6 ff ff       	call   80118a <fd_lookup>
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 17                	js     801ae5 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad1:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801ad7:	39 08                	cmp    %ecx,(%eax)
  801ad9:	75 05                	jne    801ae0 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801adb:	8b 40 0c             	mov    0xc(%eax),%eax
  801ade:	eb 05                	jmp    801ae5 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ae0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	56                   	push   %esi
  801aeb:	53                   	push   %ebx
  801aec:	83 ec 1c             	sub    $0x1c,%esp
  801aef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801af1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af4:	50                   	push   %eax
  801af5:	e8 41 f6 ff ff       	call   80113b <fd_alloc>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 1b                	js     801b1e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b03:	83 ec 04             	sub    $0x4,%esp
  801b06:	68 07 04 00 00       	push   $0x407
  801b0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b0e:	6a 00                	push   $0x0
  801b10:	e8 7a f2 ff ff       	call   800d8f <sys_page_alloc>
  801b15:	89 c3                	mov    %eax,%ebx
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	79 10                	jns    801b2e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	56                   	push   %esi
  801b22:	e8 0e 02 00 00       	call   801d35 <nsipc_close>
		return r;
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	89 d8                	mov    %ebx,%eax
  801b2c:	eb 24                	jmp    801b52 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b2e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b37:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b43:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	50                   	push   %eax
  801b4a:	e8 c5 f5 ff ff       	call   801114 <fd2num>
  801b4f:	83 c4 10             	add    $0x10,%esp
}
  801b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	e8 50 ff ff ff       	call   801ab7 <fd2sockid>
		return r;
  801b67:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 1f                	js     801b8c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b6d:	83 ec 04             	sub    $0x4,%esp
  801b70:	ff 75 10             	pushl  0x10(%ebp)
  801b73:	ff 75 0c             	pushl  0xc(%ebp)
  801b76:	50                   	push   %eax
  801b77:	e8 12 01 00 00       	call   801c8e <nsipc_accept>
  801b7c:	83 c4 10             	add    $0x10,%esp
		return r;
  801b7f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b81:	85 c0                	test   %eax,%eax
  801b83:	78 07                	js     801b8c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b85:	e8 5d ff ff ff       	call   801ae7 <alloc_sockfd>
  801b8a:	89 c1                	mov    %eax,%ecx
}
  801b8c:	89 c8                	mov    %ecx,%eax
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	e8 19 ff ff ff       	call   801ab7 <fd2sockid>
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	78 12                	js     801bb4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ba2:	83 ec 04             	sub    $0x4,%esp
  801ba5:	ff 75 10             	pushl  0x10(%ebp)
  801ba8:	ff 75 0c             	pushl  0xc(%ebp)
  801bab:	50                   	push   %eax
  801bac:	e8 2d 01 00 00       	call   801cde <nsipc_bind>
  801bb1:	83 c4 10             	add    $0x10,%esp
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <shutdown>:

int
shutdown(int s, int how)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	e8 f3 fe ff ff       	call   801ab7 <fd2sockid>
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 0f                	js     801bd7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bc8:	83 ec 08             	sub    $0x8,%esp
  801bcb:	ff 75 0c             	pushl  0xc(%ebp)
  801bce:	50                   	push   %eax
  801bcf:	e8 3f 01 00 00       	call   801d13 <nsipc_shutdown>
  801bd4:	83 c4 10             	add    $0x10,%esp
}
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	e8 d0 fe ff ff       	call   801ab7 <fd2sockid>
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 12                	js     801bfd <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801beb:	83 ec 04             	sub    $0x4,%esp
  801bee:	ff 75 10             	pushl  0x10(%ebp)
  801bf1:	ff 75 0c             	pushl  0xc(%ebp)
  801bf4:	50                   	push   %eax
  801bf5:	e8 55 01 00 00       	call   801d4f <nsipc_connect>
  801bfa:	83 c4 10             	add    $0x10,%esp
}
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <listen>:

int
listen(int s, int backlog)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c05:	8b 45 08             	mov    0x8(%ebp),%eax
  801c08:	e8 aa fe ff ff       	call   801ab7 <fd2sockid>
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	78 0f                	js     801c20 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c11:	83 ec 08             	sub    $0x8,%esp
  801c14:	ff 75 0c             	pushl  0xc(%ebp)
  801c17:	50                   	push   %eax
  801c18:	e8 67 01 00 00       	call   801d84 <nsipc_listen>
  801c1d:	83 c4 10             	add    $0x10,%esp
}
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c28:	ff 75 10             	pushl  0x10(%ebp)
  801c2b:	ff 75 0c             	pushl  0xc(%ebp)
  801c2e:	ff 75 08             	pushl  0x8(%ebp)
  801c31:	e8 3a 02 00 00       	call   801e70 <nsipc_socket>
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 05                	js     801c42 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c3d:	e8 a5 fe ff ff       	call   801ae7 <alloc_sockfd>
}
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	53                   	push   %ebx
  801c48:	83 ec 04             	sub    $0x4,%esp
  801c4b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c4d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c54:	75 12                	jne    801c68 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c56:	83 ec 0c             	sub    $0xc,%esp
  801c59:	6a 02                	push   $0x2
  801c5b:	e8 da 07 00 00       	call   80243a <ipc_find_env>
  801c60:	a3 04 40 80 00       	mov    %eax,0x804004
  801c65:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c68:	6a 07                	push   $0x7
  801c6a:	68 00 60 80 00       	push   $0x806000
  801c6f:	53                   	push   %ebx
  801c70:	ff 35 04 40 80 00    	pushl  0x804004
  801c76:	e8 6b 07 00 00       	call   8023e6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c7b:	83 c4 0c             	add    $0xc,%esp
  801c7e:	6a 00                	push   $0x0
  801c80:	6a 00                	push   $0x0
  801c82:	6a 00                	push   $0x0
  801c84:	e8 f0 06 00 00       	call   802379 <ipc_recv>
}
  801c89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	56                   	push   %esi
  801c92:	53                   	push   %ebx
  801c93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c96:	8b 45 08             	mov    0x8(%ebp),%eax
  801c99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c9e:	8b 06                	mov    (%esi),%eax
  801ca0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ca5:	b8 01 00 00 00       	mov    $0x1,%eax
  801caa:	e8 95 ff ff ff       	call   801c44 <nsipc>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	78 20                	js     801cd5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cb5:	83 ec 04             	sub    $0x4,%esp
  801cb8:	ff 35 10 60 80 00    	pushl  0x806010
  801cbe:	68 00 60 80 00       	push   $0x806000
  801cc3:	ff 75 0c             	pushl  0xc(%ebp)
  801cc6:	e8 53 ee ff ff       	call   800b1e <memmove>
		*addrlen = ret->ret_addrlen;
  801ccb:	a1 10 60 80 00       	mov    0x806010,%eax
  801cd0:	89 06                	mov    %eax,(%esi)
  801cd2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cd5:	89 d8                	mov    %ebx,%eax
  801cd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	53                   	push   %ebx
  801ce2:	83 ec 08             	sub    $0x8,%esp
  801ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cf0:	53                   	push   %ebx
  801cf1:	ff 75 0c             	pushl  0xc(%ebp)
  801cf4:	68 04 60 80 00       	push   $0x806004
  801cf9:	e8 20 ee ff ff       	call   800b1e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cfe:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d04:	b8 02 00 00 00       	mov    $0x2,%eax
  801d09:	e8 36 ff ff ff       	call   801c44 <nsipc>
}
  801d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d24:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d29:	b8 03 00 00 00       	mov    $0x3,%eax
  801d2e:	e8 11 ff ff ff       	call   801c44 <nsipc>
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <nsipc_close>:

int
nsipc_close(int s)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d43:	b8 04 00 00 00       	mov    $0x4,%eax
  801d48:	e8 f7 fe ff ff       	call   801c44 <nsipc>
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	53                   	push   %ebx
  801d53:	83 ec 08             	sub    $0x8,%esp
  801d56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d61:	53                   	push   %ebx
  801d62:	ff 75 0c             	pushl  0xc(%ebp)
  801d65:	68 04 60 80 00       	push   $0x806004
  801d6a:	e8 af ed ff ff       	call   800b1e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d6f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d75:	b8 05 00 00 00       	mov    $0x5,%eax
  801d7a:	e8 c5 fe ff ff       	call   801c44 <nsipc>
}
  801d7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    

00801d84 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d95:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d9a:	b8 06 00 00 00       	mov    $0x6,%eax
  801d9f:	e8 a0 fe ff ff       	call   801c44 <nsipc>
}
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	56                   	push   %esi
  801daa:	53                   	push   %ebx
  801dab:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801db6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dbc:	8b 45 14             	mov    0x14(%ebp),%eax
  801dbf:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dc4:	b8 07 00 00 00       	mov    $0x7,%eax
  801dc9:	e8 76 fe ff ff       	call   801c44 <nsipc>
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 35                	js     801e09 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801dd4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dd9:	7f 04                	jg     801ddf <nsipc_recv+0x39>
  801ddb:	39 c6                	cmp    %eax,%esi
  801ddd:	7d 16                	jge    801df5 <nsipc_recv+0x4f>
  801ddf:	68 ff 2b 80 00       	push   $0x802bff
  801de4:	68 c7 2b 80 00       	push   $0x802bc7
  801de9:	6a 62                	push   $0x62
  801deb:	68 14 2c 80 00       	push   $0x802c14
  801df0:	e8 39 e5 ff ff       	call   80032e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	50                   	push   %eax
  801df9:	68 00 60 80 00       	push   $0x806000
  801dfe:	ff 75 0c             	pushl  0xc(%ebp)
  801e01:	e8 18 ed ff ff       	call   800b1e <memmove>
  801e06:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e09:	89 d8                	mov    %ebx,%eax
  801e0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5e                   	pop    %esi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	53                   	push   %ebx
  801e16:	83 ec 04             	sub    $0x4,%esp
  801e19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e24:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e2a:	7e 16                	jle    801e42 <nsipc_send+0x30>
  801e2c:	68 20 2c 80 00       	push   $0x802c20
  801e31:	68 c7 2b 80 00       	push   $0x802bc7
  801e36:	6a 6d                	push   $0x6d
  801e38:	68 14 2c 80 00       	push   $0x802c14
  801e3d:	e8 ec e4 ff ff       	call   80032e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e42:	83 ec 04             	sub    $0x4,%esp
  801e45:	53                   	push   %ebx
  801e46:	ff 75 0c             	pushl  0xc(%ebp)
  801e49:	68 0c 60 80 00       	push   $0x80600c
  801e4e:	e8 cb ec ff ff       	call   800b1e <memmove>
	nsipcbuf.send.req_size = size;
  801e53:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e59:	8b 45 14             	mov    0x14(%ebp),%eax
  801e5c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e61:	b8 08 00 00 00       	mov    $0x8,%eax
  801e66:	e8 d9 fd ff ff       	call   801c44 <nsipc>
}
  801e6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e76:	8b 45 08             	mov    0x8(%ebp),%eax
  801e79:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e81:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e86:	8b 45 10             	mov    0x10(%ebp),%eax
  801e89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e8e:	b8 09 00 00 00       	mov    $0x9,%eax
  801e93:	e8 ac fd ff ff       	call   801c44 <nsipc>
}
  801e98:	c9                   	leave  
  801e99:	c3                   	ret    

00801e9a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	56                   	push   %esi
  801e9e:	53                   	push   %ebx
  801e9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ea2:	83 ec 0c             	sub    $0xc,%esp
  801ea5:	ff 75 08             	pushl  0x8(%ebp)
  801ea8:	e8 77 f2 ff ff       	call   801124 <fd2data>
  801ead:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801eaf:	83 c4 08             	add    $0x8,%esp
  801eb2:	68 2c 2c 80 00       	push   $0x802c2c
  801eb7:	53                   	push   %ebx
  801eb8:	e8 cf ea ff ff       	call   80098c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ebd:	8b 46 04             	mov    0x4(%esi),%eax
  801ec0:	2b 06                	sub    (%esi),%eax
  801ec2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ec8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ecf:	00 00 00 
	stat->st_dev = &devpipe;
  801ed2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ed9:	30 80 00 
	return 0;
}
  801edc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee4:	5b                   	pop    %ebx
  801ee5:	5e                   	pop    %esi
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    

00801ee8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	53                   	push   %ebx
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ef2:	53                   	push   %ebx
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 1a ef ff ff       	call   800e14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801efa:	89 1c 24             	mov    %ebx,(%esp)
  801efd:	e8 22 f2 ff ff       	call   801124 <fd2data>
  801f02:	83 c4 08             	add    $0x8,%esp
  801f05:	50                   	push   %eax
  801f06:	6a 00                	push   $0x0
  801f08:	e8 07 ef ff ff       	call   800e14 <sys_page_unmap>
}
  801f0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	57                   	push   %edi
  801f16:	56                   	push   %esi
  801f17:	53                   	push   %ebx
  801f18:	83 ec 1c             	sub    $0x1c,%esp
  801f1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f1e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f20:	a1 20 44 80 00       	mov    0x804420,%eax
  801f25:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	ff 75 e0             	pushl  -0x20(%ebp)
  801f2e:	e8 40 05 00 00       	call   802473 <pageref>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	89 3c 24             	mov    %edi,(%esp)
  801f38:	e8 36 05 00 00       	call   802473 <pageref>
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	39 c3                	cmp    %eax,%ebx
  801f42:	0f 94 c1             	sete   %cl
  801f45:	0f b6 c9             	movzbl %cl,%ecx
  801f48:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f4b:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801f51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f54:	39 ce                	cmp    %ecx,%esi
  801f56:	74 1b                	je     801f73 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f58:	39 c3                	cmp    %eax,%ebx
  801f5a:	75 c4                	jne    801f20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f5c:	8b 42 58             	mov    0x58(%edx),%eax
  801f5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f62:	50                   	push   %eax
  801f63:	56                   	push   %esi
  801f64:	68 33 2c 80 00       	push   $0x802c33
  801f69:	e8 99 e4 ff ff       	call   800407 <cprintf>
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	eb ad                	jmp    801f20 <_pipeisclosed+0xe>
	}
}
  801f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f79:	5b                   	pop    %ebx
  801f7a:	5e                   	pop    %esi
  801f7b:	5f                   	pop    %edi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 28             	sub    $0x28,%esp
  801f87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f8a:	56                   	push   %esi
  801f8b:	e8 94 f1 ff ff       	call   801124 <fd2data>
  801f90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	bf 00 00 00 00       	mov    $0x0,%edi
  801f9a:	eb 4b                	jmp    801fe7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f9c:	89 da                	mov    %ebx,%edx
  801f9e:	89 f0                	mov    %esi,%eax
  801fa0:	e8 6d ff ff ff       	call   801f12 <_pipeisclosed>
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	75 48                	jne    801ff1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fa9:	e8 c2 ed ff ff       	call   800d70 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fae:	8b 43 04             	mov    0x4(%ebx),%eax
  801fb1:	8b 0b                	mov    (%ebx),%ecx
  801fb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801fb6:	39 d0                	cmp    %edx,%eax
  801fb8:	73 e2                	jae    801f9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fbd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fc1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fc4:	89 c2                	mov    %eax,%edx
  801fc6:	c1 fa 1f             	sar    $0x1f,%edx
  801fc9:	89 d1                	mov    %edx,%ecx
  801fcb:	c1 e9 1b             	shr    $0x1b,%ecx
  801fce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fd1:	83 e2 1f             	and    $0x1f,%edx
  801fd4:	29 ca                	sub    %ecx,%edx
  801fd6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fde:	83 c0 01             	add    $0x1,%eax
  801fe1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe4:	83 c7 01             	add    $0x1,%edi
  801fe7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fea:	75 c2                	jne    801fae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fec:	8b 45 10             	mov    0x10(%ebp),%eax
  801fef:	eb 05                	jmp    801ff6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ff1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 18             	sub    $0x18,%esp
  802007:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80200a:	57                   	push   %edi
  80200b:	e8 14 f1 ff ff       	call   801124 <fd2data>
  802010:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80201a:	eb 3d                	jmp    802059 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80201c:	85 db                	test   %ebx,%ebx
  80201e:	74 04                	je     802024 <devpipe_read+0x26>
				return i;
  802020:	89 d8                	mov    %ebx,%eax
  802022:	eb 44                	jmp    802068 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802024:	89 f2                	mov    %esi,%edx
  802026:	89 f8                	mov    %edi,%eax
  802028:	e8 e5 fe ff ff       	call   801f12 <_pipeisclosed>
  80202d:	85 c0                	test   %eax,%eax
  80202f:	75 32                	jne    802063 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802031:	e8 3a ed ff ff       	call   800d70 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802036:	8b 06                	mov    (%esi),%eax
  802038:	3b 46 04             	cmp    0x4(%esi),%eax
  80203b:	74 df                	je     80201c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80203d:	99                   	cltd   
  80203e:	c1 ea 1b             	shr    $0x1b,%edx
  802041:	01 d0                	add    %edx,%eax
  802043:	83 e0 1f             	and    $0x1f,%eax
  802046:	29 d0                	sub    %edx,%eax
  802048:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80204d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802050:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802053:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802056:	83 c3 01             	add    $0x1,%ebx
  802059:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80205c:	75 d8                	jne    802036 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80205e:	8b 45 10             	mov    0x10(%ebp),%eax
  802061:	eb 05                	jmp    802068 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802063:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802068:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206b:	5b                   	pop    %ebx
  80206c:	5e                   	pop    %esi
  80206d:	5f                   	pop    %edi
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    

00802070 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	56                   	push   %esi
  802074:	53                   	push   %ebx
  802075:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802078:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207b:	50                   	push   %eax
  80207c:	e8 ba f0 ff ff       	call   80113b <fd_alloc>
  802081:	83 c4 10             	add    $0x10,%esp
  802084:	89 c2                	mov    %eax,%edx
  802086:	85 c0                	test   %eax,%eax
  802088:	0f 88 2c 01 00 00    	js     8021ba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208e:	83 ec 04             	sub    $0x4,%esp
  802091:	68 07 04 00 00       	push   $0x407
  802096:	ff 75 f4             	pushl  -0xc(%ebp)
  802099:	6a 00                	push   $0x0
  80209b:	e8 ef ec ff ff       	call   800d8f <sys_page_alloc>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	89 c2                	mov    %eax,%edx
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	0f 88 0d 01 00 00    	js     8021ba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020ad:	83 ec 0c             	sub    $0xc,%esp
  8020b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020b3:	50                   	push   %eax
  8020b4:	e8 82 f0 ff ff       	call   80113b <fd_alloc>
  8020b9:	89 c3                	mov    %eax,%ebx
  8020bb:	83 c4 10             	add    $0x10,%esp
  8020be:	85 c0                	test   %eax,%eax
  8020c0:	0f 88 e2 00 00 00    	js     8021a8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c6:	83 ec 04             	sub    $0x4,%esp
  8020c9:	68 07 04 00 00       	push   $0x407
  8020ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d1:	6a 00                	push   $0x0
  8020d3:	e8 b7 ec ff ff       	call   800d8f <sys_page_alloc>
  8020d8:	89 c3                	mov    %eax,%ebx
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	0f 88 c3 00 00 00    	js     8021a8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020e5:	83 ec 0c             	sub    $0xc,%esp
  8020e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020eb:	e8 34 f0 ff ff       	call   801124 <fd2data>
  8020f0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f2:	83 c4 0c             	add    $0xc,%esp
  8020f5:	68 07 04 00 00       	push   $0x407
  8020fa:	50                   	push   %eax
  8020fb:	6a 00                	push   $0x0
  8020fd:	e8 8d ec ff ff       	call   800d8f <sys_page_alloc>
  802102:	89 c3                	mov    %eax,%ebx
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	85 c0                	test   %eax,%eax
  802109:	0f 88 89 00 00 00    	js     802198 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80210f:	83 ec 0c             	sub    $0xc,%esp
  802112:	ff 75 f0             	pushl  -0x10(%ebp)
  802115:	e8 0a f0 ff ff       	call   801124 <fd2data>
  80211a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802121:	50                   	push   %eax
  802122:	6a 00                	push   $0x0
  802124:	56                   	push   %esi
  802125:	6a 00                	push   $0x0
  802127:	e8 a6 ec ff ff       	call   800dd2 <sys_page_map>
  80212c:	89 c3                	mov    %eax,%ebx
  80212e:	83 c4 20             	add    $0x20,%esp
  802131:	85 c0                	test   %eax,%eax
  802133:	78 55                	js     80218a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802135:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80213b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802140:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802143:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80214a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802150:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802153:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802155:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802158:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80215f:	83 ec 0c             	sub    $0xc,%esp
  802162:	ff 75 f4             	pushl  -0xc(%ebp)
  802165:	e8 aa ef ff ff       	call   801114 <fd2num>
  80216a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80216d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80216f:	83 c4 04             	add    $0x4,%esp
  802172:	ff 75 f0             	pushl  -0x10(%ebp)
  802175:	e8 9a ef ff ff       	call   801114 <fd2num>
  80217a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80217d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802180:	83 c4 10             	add    $0x10,%esp
  802183:	ba 00 00 00 00       	mov    $0x0,%edx
  802188:	eb 30                	jmp    8021ba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80218a:	83 ec 08             	sub    $0x8,%esp
  80218d:	56                   	push   %esi
  80218e:	6a 00                	push   $0x0
  802190:	e8 7f ec ff ff       	call   800e14 <sys_page_unmap>
  802195:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802198:	83 ec 08             	sub    $0x8,%esp
  80219b:	ff 75 f0             	pushl  -0x10(%ebp)
  80219e:	6a 00                	push   $0x0
  8021a0:	e8 6f ec ff ff       	call   800e14 <sys_page_unmap>
  8021a5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021a8:	83 ec 08             	sub    $0x8,%esp
  8021ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ae:	6a 00                	push   $0x0
  8021b0:	e8 5f ec ff ff       	call   800e14 <sys_page_unmap>
  8021b5:	83 c4 10             	add    $0x10,%esp
  8021b8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5d                   	pop    %ebp
  8021c2:	c3                   	ret    

008021c3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021cc:	50                   	push   %eax
  8021cd:	ff 75 08             	pushl  0x8(%ebp)
  8021d0:	e8 b5 ef ff ff       	call   80118a <fd_lookup>
  8021d5:	83 c4 10             	add    $0x10,%esp
  8021d8:	85 c0                	test   %eax,%eax
  8021da:	78 18                	js     8021f4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021dc:	83 ec 0c             	sub    $0xc,%esp
  8021df:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e2:	e8 3d ef ff ff       	call   801124 <fd2data>
	return _pipeisclosed(fd, p);
  8021e7:	89 c2                	mov    %eax,%edx
  8021e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ec:	e8 21 fd ff ff       	call   801f12 <_pipeisclosed>
  8021f1:	83 c4 10             	add    $0x10,%esp
}
  8021f4:	c9                   	leave  
  8021f5:	c3                   	ret    

008021f6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802206:	68 4b 2c 80 00       	push   $0x802c4b
  80220b:	ff 75 0c             	pushl  0xc(%ebp)
  80220e:	e8 79 e7 ff ff       	call   80098c <strcpy>
	return 0;
}
  802213:	b8 00 00 00 00       	mov    $0x0,%eax
  802218:	c9                   	leave  
  802219:	c3                   	ret    

0080221a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
  80221d:	57                   	push   %edi
  80221e:	56                   	push   %esi
  80221f:	53                   	push   %ebx
  802220:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802226:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80222b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802231:	eb 2d                	jmp    802260 <devcons_write+0x46>
		m = n - tot;
  802233:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802236:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802238:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80223b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802240:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802243:	83 ec 04             	sub    $0x4,%esp
  802246:	53                   	push   %ebx
  802247:	03 45 0c             	add    0xc(%ebp),%eax
  80224a:	50                   	push   %eax
  80224b:	57                   	push   %edi
  80224c:	e8 cd e8 ff ff       	call   800b1e <memmove>
		sys_cputs(buf, m);
  802251:	83 c4 08             	add    $0x8,%esp
  802254:	53                   	push   %ebx
  802255:	57                   	push   %edi
  802256:	e8 78 ea ff ff       	call   800cd3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80225b:	01 de                	add    %ebx,%esi
  80225d:	83 c4 10             	add    $0x10,%esp
  802260:	89 f0                	mov    %esi,%eax
  802262:	3b 75 10             	cmp    0x10(%ebp),%esi
  802265:	72 cc                	jb     802233 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80226a:	5b                   	pop    %ebx
  80226b:	5e                   	pop    %esi
  80226c:	5f                   	pop    %edi
  80226d:	5d                   	pop    %ebp
  80226e:	c3                   	ret    

0080226f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80226f:	55                   	push   %ebp
  802270:	89 e5                	mov    %esp,%ebp
  802272:	83 ec 08             	sub    $0x8,%esp
  802275:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80227a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80227e:	74 2a                	je     8022aa <devcons_read+0x3b>
  802280:	eb 05                	jmp    802287 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802282:	e8 e9 ea ff ff       	call   800d70 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802287:	e8 65 ea ff ff       	call   800cf1 <sys_cgetc>
  80228c:	85 c0                	test   %eax,%eax
  80228e:	74 f2                	je     802282 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802290:	85 c0                	test   %eax,%eax
  802292:	78 16                	js     8022aa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802294:	83 f8 04             	cmp    $0x4,%eax
  802297:	74 0c                	je     8022a5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802299:	8b 55 0c             	mov    0xc(%ebp),%edx
  80229c:	88 02                	mov    %al,(%edx)
	return 1;
  80229e:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a3:	eb 05                	jmp    8022aa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022a5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022aa:	c9                   	leave  
  8022ab:	c3                   	ret    

008022ac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022ac:	55                   	push   %ebp
  8022ad:	89 e5                	mov    %esp,%ebp
  8022af:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022b8:	6a 01                	push   $0x1
  8022ba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022bd:	50                   	push   %eax
  8022be:	e8 10 ea ff ff       	call   800cd3 <sys_cputs>
}
  8022c3:	83 c4 10             	add    $0x10,%esp
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <getchar>:

int
getchar(void)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022ce:	6a 01                	push   $0x1
  8022d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022d3:	50                   	push   %eax
  8022d4:	6a 00                	push   $0x0
  8022d6:	e8 15 f1 ff ff       	call   8013f0 <read>
	if (r < 0)
  8022db:	83 c4 10             	add    $0x10,%esp
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	78 0f                	js     8022f1 <getchar+0x29>
		return r;
	if (r < 1)
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	7e 06                	jle    8022ec <getchar+0x24>
		return -E_EOF;
	return c;
  8022e6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022ea:	eb 05                	jmp    8022f1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022ec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fc:	50                   	push   %eax
  8022fd:	ff 75 08             	pushl  0x8(%ebp)
  802300:	e8 85 ee ff ff       	call   80118a <fd_lookup>
  802305:	83 c4 10             	add    $0x10,%esp
  802308:	85 c0                	test   %eax,%eax
  80230a:	78 11                	js     80231d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80230c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802315:	39 10                	cmp    %edx,(%eax)
  802317:	0f 94 c0             	sete   %al
  80231a:	0f b6 c0             	movzbl %al,%eax
}
  80231d:	c9                   	leave  
  80231e:	c3                   	ret    

0080231f <opencons>:

int
opencons(void)
{
  80231f:	55                   	push   %ebp
  802320:	89 e5                	mov    %esp,%ebp
  802322:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802325:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802328:	50                   	push   %eax
  802329:	e8 0d ee ff ff       	call   80113b <fd_alloc>
  80232e:	83 c4 10             	add    $0x10,%esp
		return r;
  802331:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802333:	85 c0                	test   %eax,%eax
  802335:	78 3e                	js     802375 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802337:	83 ec 04             	sub    $0x4,%esp
  80233a:	68 07 04 00 00       	push   $0x407
  80233f:	ff 75 f4             	pushl  -0xc(%ebp)
  802342:	6a 00                	push   $0x0
  802344:	e8 46 ea ff ff       	call   800d8f <sys_page_alloc>
  802349:	83 c4 10             	add    $0x10,%esp
		return r;
  80234c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80234e:	85 c0                	test   %eax,%eax
  802350:	78 23                	js     802375 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802352:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80235d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802360:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802367:	83 ec 0c             	sub    $0xc,%esp
  80236a:	50                   	push   %eax
  80236b:	e8 a4 ed ff ff       	call   801114 <fd2num>
  802370:	89 c2                	mov    %eax,%edx
  802372:	83 c4 10             	add    $0x10,%esp
}
  802375:	89 d0                	mov    %edx,%eax
  802377:	c9                   	leave  
  802378:	c3                   	ret    

00802379 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	56                   	push   %esi
  80237d:	53                   	push   %ebx
  80237e:	8b 75 08             	mov    0x8(%ebp),%esi
  802381:	8b 45 0c             	mov    0xc(%ebp),%eax
  802384:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802387:	85 c0                	test   %eax,%eax
  802389:	74 0e                	je     802399 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  80238b:	83 ec 0c             	sub    $0xc,%esp
  80238e:	50                   	push   %eax
  80238f:	e8 ab eb ff ff       	call   800f3f <sys_ipc_recv>
  802394:	83 c4 10             	add    $0x10,%esp
  802397:	eb 10                	jmp    8023a9 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802399:	83 ec 0c             	sub    $0xc,%esp
  80239c:	68 00 00 00 f0       	push   $0xf0000000
  8023a1:	e8 99 eb ff ff       	call   800f3f <sys_ipc_recv>
  8023a6:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	74 0e                	je     8023bb <ipc_recv+0x42>
    	*from_env_store = 0;
  8023ad:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8023b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8023b9:	eb 24                	jmp    8023df <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8023bb:	85 f6                	test   %esi,%esi
  8023bd:	74 0a                	je     8023c9 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8023bf:	a1 20 44 80 00       	mov    0x804420,%eax
  8023c4:	8b 40 74             	mov    0x74(%eax),%eax
  8023c7:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8023c9:	85 db                	test   %ebx,%ebx
  8023cb:	74 0a                	je     8023d7 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8023cd:	a1 20 44 80 00       	mov    0x804420,%eax
  8023d2:	8b 40 78             	mov    0x78(%eax),%eax
  8023d5:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8023d7:	a1 20 44 80 00       	mov    0x804420,%eax
  8023dc:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8023df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023e2:	5b                   	pop    %ebx
  8023e3:	5e                   	pop    %esi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    

008023e6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023e6:	55                   	push   %ebp
  8023e7:	89 e5                	mov    %esp,%ebp
  8023e9:	57                   	push   %edi
  8023ea:	56                   	push   %esi
  8023eb:	53                   	push   %ebx
  8023ec:	83 ec 0c             	sub    $0xc,%esp
  8023ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8023f8:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8023fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8023ff:	0f 44 d8             	cmove  %eax,%ebx
  802402:	eb 1c                	jmp    802420 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802404:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802407:	74 12                	je     80241b <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802409:	50                   	push   %eax
  80240a:	68 57 2c 80 00       	push   $0x802c57
  80240f:	6a 4b                	push   $0x4b
  802411:	68 6f 2c 80 00       	push   $0x802c6f
  802416:	e8 13 df ff ff       	call   80032e <_panic>
        }	
        sys_yield();
  80241b:	e8 50 e9 ff ff       	call   800d70 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802420:	ff 75 14             	pushl  0x14(%ebp)
  802423:	53                   	push   %ebx
  802424:	56                   	push   %esi
  802425:	57                   	push   %edi
  802426:	e8 f1 ea ff ff       	call   800f1c <sys_ipc_try_send>
  80242b:	83 c4 10             	add    $0x10,%esp
  80242e:	85 c0                	test   %eax,%eax
  802430:	75 d2                	jne    802404 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802435:	5b                   	pop    %ebx
  802436:	5e                   	pop    %esi
  802437:	5f                   	pop    %edi
  802438:	5d                   	pop    %ebp
  802439:	c3                   	ret    

0080243a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
  80243d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802440:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802445:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802448:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80244e:	8b 52 50             	mov    0x50(%edx),%edx
  802451:	39 ca                	cmp    %ecx,%edx
  802453:	75 0d                	jne    802462 <ipc_find_env+0x28>
			return envs[i].env_id;
  802455:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802458:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80245d:	8b 40 48             	mov    0x48(%eax),%eax
  802460:	eb 0f                	jmp    802471 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802462:	83 c0 01             	add    $0x1,%eax
  802465:	3d 00 04 00 00       	cmp    $0x400,%eax
  80246a:	75 d9                	jne    802445 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80246c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    

00802473 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802473:	55                   	push   %ebp
  802474:	89 e5                	mov    %esp,%ebp
  802476:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802479:	89 d0                	mov    %edx,%eax
  80247b:	c1 e8 16             	shr    $0x16,%eax
  80247e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802485:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80248a:	f6 c1 01             	test   $0x1,%cl
  80248d:	74 1d                	je     8024ac <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80248f:	c1 ea 0c             	shr    $0xc,%edx
  802492:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802499:	f6 c2 01             	test   $0x1,%dl
  80249c:	74 0e                	je     8024ac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80249e:	c1 ea 0c             	shr    $0xc,%edx
  8024a1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024a8:	ef 
  8024a9:	0f b7 c0             	movzwl %ax,%eax
}
  8024ac:	5d                   	pop    %ebp
  8024ad:	c3                   	ret    
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__udivdi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 f6                	test   %esi,%esi
  8024c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024cd:	89 ca                	mov    %ecx,%edx
  8024cf:	89 f8                	mov    %edi,%eax
  8024d1:	75 3d                	jne    802510 <__udivdi3+0x60>
  8024d3:	39 cf                	cmp    %ecx,%edi
  8024d5:	0f 87 c5 00 00 00    	ja     8025a0 <__udivdi3+0xf0>
  8024db:	85 ff                	test   %edi,%edi
  8024dd:	89 fd                	mov    %edi,%ebp
  8024df:	75 0b                	jne    8024ec <__udivdi3+0x3c>
  8024e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e6:	31 d2                	xor    %edx,%edx
  8024e8:	f7 f7                	div    %edi
  8024ea:	89 c5                	mov    %eax,%ebp
  8024ec:	89 c8                	mov    %ecx,%eax
  8024ee:	31 d2                	xor    %edx,%edx
  8024f0:	f7 f5                	div    %ebp
  8024f2:	89 c1                	mov    %eax,%ecx
  8024f4:	89 d8                	mov    %ebx,%eax
  8024f6:	89 cf                	mov    %ecx,%edi
  8024f8:	f7 f5                	div    %ebp
  8024fa:	89 c3                	mov    %eax,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	39 ce                	cmp    %ecx,%esi
  802512:	77 74                	ja     802588 <__udivdi3+0xd8>
  802514:	0f bd fe             	bsr    %esi,%edi
  802517:	83 f7 1f             	xor    $0x1f,%edi
  80251a:	0f 84 98 00 00 00    	je     8025b8 <__udivdi3+0x108>
  802520:	bb 20 00 00 00       	mov    $0x20,%ebx
  802525:	89 f9                	mov    %edi,%ecx
  802527:	89 c5                	mov    %eax,%ebp
  802529:	29 fb                	sub    %edi,%ebx
  80252b:	d3 e6                	shl    %cl,%esi
  80252d:	89 d9                	mov    %ebx,%ecx
  80252f:	d3 ed                	shr    %cl,%ebp
  802531:	89 f9                	mov    %edi,%ecx
  802533:	d3 e0                	shl    %cl,%eax
  802535:	09 ee                	or     %ebp,%esi
  802537:	89 d9                	mov    %ebx,%ecx
  802539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80253d:	89 d5                	mov    %edx,%ebp
  80253f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802543:	d3 ed                	shr    %cl,%ebp
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e2                	shl    %cl,%edx
  802549:	89 d9                	mov    %ebx,%ecx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	09 c2                	or     %eax,%edx
  80254f:	89 d0                	mov    %edx,%eax
  802551:	89 ea                	mov    %ebp,%edx
  802553:	f7 f6                	div    %esi
  802555:	89 d5                	mov    %edx,%ebp
  802557:	89 c3                	mov    %eax,%ebx
  802559:	f7 64 24 0c          	mull   0xc(%esp)
  80255d:	39 d5                	cmp    %edx,%ebp
  80255f:	72 10                	jb     802571 <__udivdi3+0xc1>
  802561:	8b 74 24 08          	mov    0x8(%esp),%esi
  802565:	89 f9                	mov    %edi,%ecx
  802567:	d3 e6                	shl    %cl,%esi
  802569:	39 c6                	cmp    %eax,%esi
  80256b:	73 07                	jae    802574 <__udivdi3+0xc4>
  80256d:	39 d5                	cmp    %edx,%ebp
  80256f:	75 03                	jne    802574 <__udivdi3+0xc4>
  802571:	83 eb 01             	sub    $0x1,%ebx
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 d8                	mov    %ebx,%eax
  802578:	89 fa                	mov    %edi,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	31 ff                	xor    %edi,%edi
  80258a:	31 db                	xor    %ebx,%ebx
  80258c:	89 d8                	mov    %ebx,%eax
  80258e:	89 fa                	mov    %edi,%edx
  802590:	83 c4 1c             	add    $0x1c,%esp
  802593:	5b                   	pop    %ebx
  802594:	5e                   	pop    %esi
  802595:	5f                   	pop    %edi
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    
  802598:	90                   	nop
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	89 d8                	mov    %ebx,%eax
  8025a2:	f7 f7                	div    %edi
  8025a4:	31 ff                	xor    %edi,%edi
  8025a6:	89 c3                	mov    %eax,%ebx
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	89 fa                	mov    %edi,%edx
  8025ac:	83 c4 1c             	add    $0x1c,%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5f                   	pop    %edi
  8025b2:	5d                   	pop    %ebp
  8025b3:	c3                   	ret    
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	39 ce                	cmp    %ecx,%esi
  8025ba:	72 0c                	jb     8025c8 <__udivdi3+0x118>
  8025bc:	31 db                	xor    %ebx,%ebx
  8025be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025c2:	0f 87 34 ff ff ff    	ja     8024fc <__udivdi3+0x4c>
  8025c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025cd:	e9 2a ff ff ff       	jmp    8024fc <__udivdi3+0x4c>
  8025d2:	66 90                	xchg   %ax,%ax
  8025d4:	66 90                	xchg   %ax,%ax
  8025d6:	66 90                	xchg   %ax,%ax
  8025d8:	66 90                	xchg   %ax,%ax
  8025da:	66 90                	xchg   %ax,%ax
  8025dc:	66 90                	xchg   %ax,%ax
  8025de:	66 90                	xchg   %ax,%ax

008025e0 <__umoddi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	53                   	push   %ebx
  8025e4:	83 ec 1c             	sub    $0x1c,%esp
  8025e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025f7:	85 d2                	test   %edx,%edx
  8025f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802601:	89 f3                	mov    %esi,%ebx
  802603:	89 3c 24             	mov    %edi,(%esp)
  802606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80260a:	75 1c                	jne    802628 <__umoddi3+0x48>
  80260c:	39 f7                	cmp    %esi,%edi
  80260e:	76 50                	jbe    802660 <__umoddi3+0x80>
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	f7 f7                	div    %edi
  802616:	89 d0                	mov    %edx,%eax
  802618:	31 d2                	xor    %edx,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	39 f2                	cmp    %esi,%edx
  80262a:	89 d0                	mov    %edx,%eax
  80262c:	77 52                	ja     802680 <__umoddi3+0xa0>
  80262e:	0f bd ea             	bsr    %edx,%ebp
  802631:	83 f5 1f             	xor    $0x1f,%ebp
  802634:	75 5a                	jne    802690 <__umoddi3+0xb0>
  802636:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80263a:	0f 82 e0 00 00 00    	jb     802720 <__umoddi3+0x140>
  802640:	39 0c 24             	cmp    %ecx,(%esp)
  802643:	0f 86 d7 00 00 00    	jbe    802720 <__umoddi3+0x140>
  802649:	8b 44 24 08          	mov    0x8(%esp),%eax
  80264d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802651:	83 c4 1c             	add    $0x1c,%esp
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5f                   	pop    %edi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	85 ff                	test   %edi,%edi
  802662:	89 fd                	mov    %edi,%ebp
  802664:	75 0b                	jne    802671 <__umoddi3+0x91>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f7                	div    %edi
  80266f:	89 c5                	mov    %eax,%ebp
  802671:	89 f0                	mov    %esi,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f5                	div    %ebp
  802677:	89 c8                	mov    %ecx,%eax
  802679:	f7 f5                	div    %ebp
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	eb 99                	jmp    802618 <__umoddi3+0x38>
  80267f:	90                   	nop
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	83 c4 1c             	add    $0x1c,%esp
  802687:	5b                   	pop    %ebx
  802688:	5e                   	pop    %esi
  802689:	5f                   	pop    %edi
  80268a:	5d                   	pop    %ebp
  80268b:	c3                   	ret    
  80268c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802690:	8b 34 24             	mov    (%esp),%esi
  802693:	bf 20 00 00 00       	mov    $0x20,%edi
  802698:	89 e9                	mov    %ebp,%ecx
  80269a:	29 ef                	sub    %ebp,%edi
  80269c:	d3 e0                	shl    %cl,%eax
  80269e:	89 f9                	mov    %edi,%ecx
  8026a0:	89 f2                	mov    %esi,%edx
  8026a2:	d3 ea                	shr    %cl,%edx
  8026a4:	89 e9                	mov    %ebp,%ecx
  8026a6:	09 c2                	or     %eax,%edx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 14 24             	mov    %edx,(%esp)
  8026ad:	89 f2                	mov    %esi,%edx
  8026af:	d3 e2                	shl    %cl,%edx
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	89 e9                	mov    %ebp,%ecx
  8026bf:	89 c6                	mov    %eax,%esi
  8026c1:	d3 e3                	shl    %cl,%ebx
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 d0                	mov    %edx,%eax
  8026c7:	d3 e8                	shr    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	09 d8                	or     %ebx,%eax
  8026cd:	89 d3                	mov    %edx,%ebx
  8026cf:	89 f2                	mov    %esi,%edx
  8026d1:	f7 34 24             	divl   (%esp)
  8026d4:	89 d6                	mov    %edx,%esi
  8026d6:	d3 e3                	shl    %cl,%ebx
  8026d8:	f7 64 24 04          	mull   0x4(%esp)
  8026dc:	39 d6                	cmp    %edx,%esi
  8026de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026e2:	89 d1                	mov    %edx,%ecx
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	72 08                	jb     8026f0 <__umoddi3+0x110>
  8026e8:	75 11                	jne    8026fb <__umoddi3+0x11b>
  8026ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ee:	73 0b                	jae    8026fb <__umoddi3+0x11b>
  8026f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026f4:	1b 14 24             	sbb    (%esp),%edx
  8026f7:	89 d1                	mov    %edx,%ecx
  8026f9:	89 c3                	mov    %eax,%ebx
  8026fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026ff:	29 da                	sub    %ebx,%edx
  802701:	19 ce                	sbb    %ecx,%esi
  802703:	89 f9                	mov    %edi,%ecx
  802705:	89 f0                	mov    %esi,%eax
  802707:	d3 e0                	shl    %cl,%eax
  802709:	89 e9                	mov    %ebp,%ecx
  80270b:	d3 ea                	shr    %cl,%edx
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	d3 ee                	shr    %cl,%esi
  802711:	09 d0                	or     %edx,%eax
  802713:	89 f2                	mov    %esi,%edx
  802715:	83 c4 1c             	add    $0x1c,%esp
  802718:	5b                   	pop    %ebx
  802719:	5e                   	pop    %esi
  80271a:	5f                   	pop    %edi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    
  80271d:	8d 76 00             	lea    0x0(%esi),%esi
  802720:	29 f9                	sub    %edi,%ecx
  802722:	19 d6                	sbb    %edx,%esi
  802724:	89 74 24 04          	mov    %esi,0x4(%esp)
  802728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80272c:	e9 18 ff ff ff       	jmp    802649 <__umoddi3+0x69>
