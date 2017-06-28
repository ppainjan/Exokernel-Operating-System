
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 40 37 80 00       	push   $0x803740
  800060:	e8 93 0a 00 00       	call   800af8 <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 4f 37 80 00       	push   $0x80374f
  800084:	e8 6f 0a 00 00       	call   800af8 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 5d 37 80 00       	push   $0x80375d
  8000b0:	e8 c3 11 00 00       	call   801278 <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 62 37 80 00       	push   $0x803762
  8000dd:	e8 16 0a 00 00       	call   800af8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 73 37 80 00       	push   $0x803773
  8000fb:	e8 78 11 00 00       	call   801278 <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 67 37 80 00       	push   $0x803767
  80012b:	e8 c8 09 00 00       	call   800af8 <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 6f 37 80 00       	push   $0x80376f
  800151:	e8 22 11 00 00       	call   801278 <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 7b 37 80 00       	push   $0x80377b
  800180:	e8 73 09 00 00       	call   800af8 <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 60 80 00       	push   $0x80600c
  8001b3:	68 10 60 80 00       	push   $0x806010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 60 80 00       	mov    %eax,0x806008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 60 80 00       	mov    0x806008,%eax
  8001d2:	a3 04 60 80 00       	mov    %eax,0x806004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 60 80 00    	mov    0x806010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 60 80 00       	push   $0x80600c
  8001ea:	68 10 60 80 00       	push   $0x806010
  8001ef:	ff 35 0c 60 80 00    	pushl  0x80600c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 60 80 00       	mov    %eax,0x806008
	return c;
  8001ff:	a1 04 60 80 00       	mov    0x806004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 85 37 80 00       	push   $0x803785
  800278:	e8 7b 08 00 00       	call   800af8 <cprintf>
				exit();
  80027d:	e8 83 07 00 00       	call   800a05 <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 d8 38 80 00       	push   $0x8038d8
  8002ac:	e8 47 08 00 00       	call   800af8 <cprintf>
				exit();
  8002b1:	e8 4f 07 00 00       	call   800a05 <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0)
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 ac 20 00 00       	call   802372 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
    		{
       			cprintf("open %s for read: %e\n", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 99 37 80 00       	push   $0x803799
  8002db:	e8 18 08 00 00       	call   800af8 <cprintf>
       			exit();
  8002e0:	e8 20 07 00 00       	call   800a05 <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
    		}
    		if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
       			dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 fa 1a 00 00       	call   801df7 <dup>
       			close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 a2 1a 00 00       	call   801da7 <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>
			//panic("< redirection not implemented");
			

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 00 39 80 00       	push   $0x803900
  800328:	e8 cb 07 00 00       	call   800af8 <cprintf>
				exit();
  80032d:	e8 d3 06 00 00       	call   800a05 <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 2d 20 00 00       	call   802372 <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 af 37 80 00       	push   $0x8037af
  80035a:	e8 99 07 00 00       	call   800af8 <cprintf>
				exit();
  80035f:	e8 a1 06 00 00       	call   800a05 <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 7c 1a 00 00       	call   801df7 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 24 1a 00 00       	call   801da7 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 73 2d 00 00       	call   80310d <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 c5 37 80 00       	push   $0x8037c5
  8003aa:	e8 49 07 00 00       	call   800af8 <cprintf>
				exit();
  8003af:	e8 51 06 00 00       	call   800a05 <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 ce 37 80 00       	push   $0x8037ce
  8003d4:	e8 1f 07 00 00       	call   800af8 <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 bd 14 00 00       	call   80189e <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 db 37 80 00       	push   $0x8037db
  8003f0:	e8 03 07 00 00       	call   800af8 <cprintf>
				exit();
  8003f5:	e8 0b 06 00 00       	call   800a05 <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 e1 19 00 00       	call   801df7 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 83 19 00 00       	call   801da7 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 72 19 00 00       	call   801da7 <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 a4 19 00 00       	call   801df7 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 46 19 00 00       	call   801da7 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 35 19 00 00       	call   801da7 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 e4 37 80 00       	push   $0x8037e4
  80047d:	6a 7a                	push   $0x7a
  80047f:	68 00 38 80 00       	push   $0x803800
  800484:	e8 96 05 00 00       	call   800a1f <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 0a 38 80 00       	push   $0x80380a
  8004a7:	e8 4c 06 00 00       	call   800af8 <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 97 0c 00 00       	call   801170 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 28 64 80 00       	mov    0x806428,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 19 38 80 00       	push   $0x803819
  800501:	e8 f2 05 00 00       	call   800af8 <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 a1 38 80 00       	push   $0x8038a1
  800517:	e8 dc 05 00 00       	call   800af8 <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 60 37 80 00       	push   $0x803760
  800531:	e8 c2 05 00 00       	call   800af8 <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 de 1f 00 00       	call   802526 <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 27 38 80 00       	push   $0x803827
  800561:	e8 92 05 00 00       	call   800af8 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 67 18 00 00       	call   801dd2 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 28 64 80 00       	mov    0x806428,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 35 38 80 00       	push   $0x803835
  800582:	e8 71 05 00 00       	call   800af8 <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 00 2d 00 00       	call   803293 <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 28 64 80 00       	mov    0x806428,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 4a 38 80 00       	push   $0x80384a
  8005b4:	e8 3f 05 00 00       	call   800af8 <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 28 64 80 00       	mov    0x806428,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 60 38 80 00       	push   $0x803860
  8005db:	e8 18 05 00 00       	call   800af8 <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 a7 2c 00 00       	call   803293 <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 28 64 80 00       	mov    0x806428,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 4a 38 80 00       	push   $0x80384a
  800609:	e8 ea 04 00 00       	call   800af8 <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 ef 03 00 00       	call   800a05 <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 b5 17 00 00       	call   801dd2 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 28 39 80 00       	push   $0x803928
  800648:	e8 ab 04 00 00       	call   800af8 <cprintf>
	exit();
  80064d:	e8 b3 03 00 00       	call   800a05 <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 42 14 00 00       	call   801ab3 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 60 80 00 01 	addl   $0x1,0x806000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 26 14 00 00       	call   801ae3 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 c8 16 00 00       	call   801da7 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 86 1c 00 00       	call   802372 <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 7d 38 80 00       	push   $0x80387d
  8006ff:	68 2a 01 00 00       	push   $0x12a
  800704:	68 00 38 80 00       	push   $0x803800
  800709:	e8 11 03 00 00       	call   800a1f <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 89 38 80 00       	push   $0x803889
  800717:	68 90 38 80 00       	push   $0x803890
  80071c:	68 2b 01 00 00       	push   $0x12b
  800721:	68 00 38 80 00       	push   $0x803800
  800726:	e8 f4 02 00 00       	call   800a1f <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf a5 38 80 00       	mov    $0x8038a5,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 ed 08 00 00       	call   801044 <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 a8 38 80 00       	push   $0x8038a8
  800771:	e8 82 03 00 00       	call   800af8 <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 87 02 00 00       	call   800a05 <exit>
		}
		if (debug)
  80077e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 b1 38 80 00       	push   $0x8038b1
  800790:	e8 63 03 00 00       	call   800af8 <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 bb 38 80 00       	push   $0x8038bb
  8007ac:	e8 5f 1d 00 00       	call   802510 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 c1 38 80 00       	push   $0x8038c1
  8007c5:	e8 2e 03 00 00       	call   800af8 <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 cc 10 00 00       	call   80189e <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 db 37 80 00       	push   $0x8037db
  8007de:	68 42 01 00 00       	push   $0x142
  8007e3:	68 00 38 80 00       	push   $0x803800
  8007e8:	e8 32 02 00 00       	call   800a1f <_panic>
		if (debug)
  8007ed:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 ce 38 80 00       	push   $0x8038ce
  8007ff:	e8 f4 02 00 00       	call   800af8 <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 ec 01 00 00       	call   800a05 <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 69 2a 00 00       	call   803293 <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 49 39 80 00       	push   $0x803949
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 21 09 00 00       	call   801170 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 75 0a 00 00       	call   801302 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 20 0c 00 00       	call   8014b7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 91 0c 00 00       	call   801554 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 0d 0c 00 00       	call   8014d5 <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 b8 0b 00 00       	call   8014b7 <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 cc 15 00 00       	call   801ee3 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 3c 13 00 00       	call   801c7d <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 50 80 00    	mov    0x805000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 c4 12 00 00       	call   801c2e <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 ee 0b 00 00       	call   801573 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 50 80 00    	mov    0x805000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 5b 12 00 00       	call   801c07 <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8009c0:	c7 05 28 64 80 00 00 	movl   $0x0,0x806428
  8009c7:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8009ca:	e8 66 0b 00 00       	call   801535 <sys_getenvid>
  8009cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009d4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009dc:	a3 28 64 80 00       	mov    %eax,0x806428

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009e1:	85 db                	test   %ebx,%ebx
  8009e3:	7e 07                	jle    8009ec <libmain+0x37>
		binaryname = argv[0];
  8009e5:	8b 06                	mov    (%esi),%eax
  8009e7:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	umain(argc, argv);
  8009ec:	83 ec 08             	sub    $0x8,%esp
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	e8 61 fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009f6:	e8 0a 00 00 00       	call   800a05 <exit>
}
  8009fb:	83 c4 10             	add    $0x10,%esp
  8009fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a0b:	e8 c2 13 00 00       	call   801dd2 <close_all>
	sys_env_destroy(0);
  800a10:	83 ec 0c             	sub    $0xc,%esp
  800a13:	6a 00                	push   $0x0
  800a15:	e8 da 0a 00 00       	call   8014f4 <sys_env_destroy>
}
  800a1a:	83 c4 10             	add    $0x10,%esp
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a24:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a27:	8b 35 1c 50 80 00    	mov    0x80501c,%esi
  800a2d:	e8 03 0b 00 00       	call   801535 <sys_getenvid>
  800a32:	83 ec 0c             	sub    $0xc,%esp
  800a35:	ff 75 0c             	pushl  0xc(%ebp)
  800a38:	ff 75 08             	pushl  0x8(%ebp)
  800a3b:	56                   	push   %esi
  800a3c:	50                   	push   %eax
  800a3d:	68 60 39 80 00       	push   $0x803960
  800a42:	e8 b1 00 00 00       	call   800af8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a47:	83 c4 18             	add    $0x18,%esp
  800a4a:	53                   	push   %ebx
  800a4b:	ff 75 10             	pushl  0x10(%ebp)
  800a4e:	e8 54 00 00 00       	call   800aa7 <vcprintf>
	cprintf("\n");
  800a53:	c7 04 24 60 37 80 00 	movl   $0x803760,(%esp)
  800a5a:	e8 99 00 00 00       	call   800af8 <cprintf>
  800a5f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a62:	cc                   	int3   
  800a63:	eb fd                	jmp    800a62 <_panic+0x43>

00800a65 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	53                   	push   %ebx
  800a69:	83 ec 04             	sub    $0x4,%esp
  800a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a6f:	8b 13                	mov    (%ebx),%edx
  800a71:	8d 42 01             	lea    0x1(%edx),%eax
  800a74:	89 03                	mov    %eax,(%ebx)
  800a76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a79:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a7d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a82:	75 1a                	jne    800a9e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a84:	83 ec 08             	sub    $0x8,%esp
  800a87:	68 ff 00 00 00       	push   $0xff
  800a8c:	8d 43 08             	lea    0x8(%ebx),%eax
  800a8f:	50                   	push   %eax
  800a90:	e8 22 0a 00 00       	call   8014b7 <sys_cputs>
		b->idx = 0;
  800a95:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a9b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a9e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800ab0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ab7:	00 00 00 
	b.cnt = 0;
  800aba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ac1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ac4:	ff 75 0c             	pushl  0xc(%ebp)
  800ac7:	ff 75 08             	pushl  0x8(%ebp)
  800aca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ad0:	50                   	push   %eax
  800ad1:	68 65 0a 80 00       	push   $0x800a65
  800ad6:	e8 54 01 00 00       	call   800c2f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800adb:	83 c4 08             	add    $0x8,%esp
  800ade:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ae4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aea:	50                   	push   %eax
  800aeb:	e8 c7 09 00 00       	call   8014b7 <sys_cputs>

	return b.cnt;
}
  800af0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800afe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b01:	50                   	push   %eax
  800b02:	ff 75 08             	pushl  0x8(%ebp)
  800b05:	e8 9d ff ff ff       	call   800aa7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 1c             	sub    $0x1c,%esp
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b22:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b2d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b30:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b33:	39 d3                	cmp    %edx,%ebx
  800b35:	72 05                	jb     800b3c <printnum+0x30>
  800b37:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b3a:	77 45                	ja     800b81 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	ff 75 18             	pushl  0x18(%ebp)
  800b42:	8b 45 14             	mov    0x14(%ebp),%eax
  800b45:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b48:	53                   	push   %ebx
  800b49:	ff 75 10             	pushl  0x10(%ebp)
  800b4c:	83 ec 08             	sub    $0x8,%esp
  800b4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b52:	ff 75 e0             	pushl  -0x20(%ebp)
  800b55:	ff 75 dc             	pushl  -0x24(%ebp)
  800b58:	ff 75 d8             	pushl  -0x28(%ebp)
  800b5b:	e8 50 29 00 00       	call   8034b0 <__udivdi3>
  800b60:	83 c4 18             	add    $0x18,%esp
  800b63:	52                   	push   %edx
  800b64:	50                   	push   %eax
  800b65:	89 f2                	mov    %esi,%edx
  800b67:	89 f8                	mov    %edi,%eax
  800b69:	e8 9e ff ff ff       	call   800b0c <printnum>
  800b6e:	83 c4 20             	add    $0x20,%esp
  800b71:	eb 18                	jmp    800b8b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b73:	83 ec 08             	sub    $0x8,%esp
  800b76:	56                   	push   %esi
  800b77:	ff 75 18             	pushl  0x18(%ebp)
  800b7a:	ff d7                	call   *%edi
  800b7c:	83 c4 10             	add    $0x10,%esp
  800b7f:	eb 03                	jmp    800b84 <printnum+0x78>
  800b81:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b84:	83 eb 01             	sub    $0x1,%ebx
  800b87:	85 db                	test   %ebx,%ebx
  800b89:	7f e8                	jg     800b73 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b8b:	83 ec 08             	sub    $0x8,%esp
  800b8e:	56                   	push   %esi
  800b8f:	83 ec 04             	sub    $0x4,%esp
  800b92:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b95:	ff 75 e0             	pushl  -0x20(%ebp)
  800b98:	ff 75 dc             	pushl  -0x24(%ebp)
  800b9b:	ff 75 d8             	pushl  -0x28(%ebp)
  800b9e:	e8 3d 2a 00 00       	call   8035e0 <__umoddi3>
  800ba3:	83 c4 14             	add    $0x14,%esp
  800ba6:	0f be 80 83 39 80 00 	movsbl 0x803983(%eax),%eax
  800bad:	50                   	push   %eax
  800bae:	ff d7                	call   *%edi
}
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bbe:	83 fa 01             	cmp    $0x1,%edx
  800bc1:	7e 0e                	jle    800bd1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bc3:	8b 10                	mov    (%eax),%edx
  800bc5:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bc8:	89 08                	mov    %ecx,(%eax)
  800bca:	8b 02                	mov    (%edx),%eax
  800bcc:	8b 52 04             	mov    0x4(%edx),%edx
  800bcf:	eb 22                	jmp    800bf3 <getuint+0x38>
	else if (lflag)
  800bd1:	85 d2                	test   %edx,%edx
  800bd3:	74 10                	je     800be5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bd5:	8b 10                	mov    (%eax),%edx
  800bd7:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bda:	89 08                	mov    %ecx,(%eax)
  800bdc:	8b 02                	mov    (%edx),%eax
  800bde:	ba 00 00 00 00       	mov    $0x0,%edx
  800be3:	eb 0e                	jmp    800bf3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800be5:	8b 10                	mov    (%eax),%edx
  800be7:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bea:	89 08                	mov    %ecx,(%eax)
  800bec:	8b 02                	mov    (%edx),%eax
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bfb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bff:	8b 10                	mov    (%eax),%edx
  800c01:	3b 50 04             	cmp    0x4(%eax),%edx
  800c04:	73 0a                	jae    800c10 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c06:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c09:	89 08                	mov    %ecx,(%eax)
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	88 02                	mov    %al,(%edx)
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c18:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c1b:	50                   	push   %eax
  800c1c:	ff 75 10             	pushl  0x10(%ebp)
  800c1f:	ff 75 0c             	pushl  0xc(%ebp)
  800c22:	ff 75 08             	pushl  0x8(%ebp)
  800c25:	e8 05 00 00 00       	call   800c2f <vprintfmt>
	va_end(ap);
}
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 2c             	sub    $0x2c,%esp
  800c38:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c41:	eb 12                	jmp    800c55 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c43:	85 c0                	test   %eax,%eax
  800c45:	0f 84 89 03 00 00    	je     800fd4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c4b:	83 ec 08             	sub    $0x8,%esp
  800c4e:	53                   	push   %ebx
  800c4f:	50                   	push   %eax
  800c50:	ff d6                	call   *%esi
  800c52:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c55:	83 c7 01             	add    $0x1,%edi
  800c58:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c5c:	83 f8 25             	cmp    $0x25,%eax
  800c5f:	75 e2                	jne    800c43 <vprintfmt+0x14>
  800c61:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c65:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c6c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c73:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	eb 07                	jmp    800c88 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c81:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c84:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c88:	8d 47 01             	lea    0x1(%edi),%eax
  800c8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8e:	0f b6 07             	movzbl (%edi),%eax
  800c91:	0f b6 c8             	movzbl %al,%ecx
  800c94:	83 e8 23             	sub    $0x23,%eax
  800c97:	3c 55                	cmp    $0x55,%al
  800c99:	0f 87 1a 03 00 00    	ja     800fb9 <vprintfmt+0x38a>
  800c9f:	0f b6 c0             	movzbl %al,%eax
  800ca2:	ff 24 85 c0 3a 80 00 	jmp    *0x803ac0(,%eax,4)
  800ca9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cb0:	eb d6                	jmp    800c88 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cbd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cc0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cc4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cc7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cca:	83 fa 09             	cmp    $0x9,%edx
  800ccd:	77 39                	ja     800d08 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ccf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cd2:	eb e9                	jmp    800cbd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cd4:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd7:	8d 48 04             	lea    0x4(%eax),%ecx
  800cda:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cdd:	8b 00                	mov    (%eax),%eax
  800cdf:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ce5:	eb 27                	jmp    800d0e <vprintfmt+0xdf>
  800ce7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cea:	85 c0                	test   %eax,%eax
  800cec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf1:	0f 49 c8             	cmovns %eax,%ecx
  800cf4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cfa:	eb 8c                	jmp    800c88 <vprintfmt+0x59>
  800cfc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cff:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d06:	eb 80                	jmp    800c88 <vprintfmt+0x59>
  800d08:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d0b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d0e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d12:	0f 89 70 ff ff ff    	jns    800c88 <vprintfmt+0x59>
				width = precision, precision = -1;
  800d18:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d1e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d25:	e9 5e ff ff ff       	jmp    800c88 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d2a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d30:	e9 53 ff ff ff       	jmp    800c88 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d35:	8b 45 14             	mov    0x14(%ebp),%eax
  800d38:	8d 50 04             	lea    0x4(%eax),%edx
  800d3b:	89 55 14             	mov    %edx,0x14(%ebp)
  800d3e:	83 ec 08             	sub    $0x8,%esp
  800d41:	53                   	push   %ebx
  800d42:	ff 30                	pushl  (%eax)
  800d44:	ff d6                	call   *%esi
			break;
  800d46:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d4c:	e9 04 ff ff ff       	jmp    800c55 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d51:	8b 45 14             	mov    0x14(%ebp),%eax
  800d54:	8d 50 04             	lea    0x4(%eax),%edx
  800d57:	89 55 14             	mov    %edx,0x14(%ebp)
  800d5a:	8b 00                	mov    (%eax),%eax
  800d5c:	99                   	cltd   
  800d5d:	31 d0                	xor    %edx,%eax
  800d5f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d61:	83 f8 0f             	cmp    $0xf,%eax
  800d64:	7f 0b                	jg     800d71 <vprintfmt+0x142>
  800d66:	8b 14 85 20 3c 80 00 	mov    0x803c20(,%eax,4),%edx
  800d6d:	85 d2                	test   %edx,%edx
  800d6f:	75 18                	jne    800d89 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d71:	50                   	push   %eax
  800d72:	68 9b 39 80 00       	push   $0x80399b
  800d77:	53                   	push   %ebx
  800d78:	56                   	push   %esi
  800d79:	e8 94 fe ff ff       	call   800c12 <printfmt>
  800d7e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d84:	e9 cc fe ff ff       	jmp    800c55 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d89:	52                   	push   %edx
  800d8a:	68 a2 38 80 00       	push   $0x8038a2
  800d8f:	53                   	push   %ebx
  800d90:	56                   	push   %esi
  800d91:	e8 7c fe ff ff       	call   800c12 <printfmt>
  800d96:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d9c:	e9 b4 fe ff ff       	jmp    800c55 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800da1:	8b 45 14             	mov    0x14(%ebp),%eax
  800da4:	8d 50 04             	lea    0x4(%eax),%edx
  800da7:	89 55 14             	mov    %edx,0x14(%ebp)
  800daa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800dac:	85 ff                	test   %edi,%edi
  800dae:	b8 94 39 80 00       	mov    $0x803994,%eax
  800db3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800db6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dba:	0f 8e 94 00 00 00    	jle    800e54 <vprintfmt+0x225>
  800dc0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dc4:	0f 84 98 00 00 00    	je     800e62 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dca:	83 ec 08             	sub    $0x8,%esp
  800dcd:	ff 75 d0             	pushl  -0x30(%ebp)
  800dd0:	57                   	push   %edi
  800dd1:	e8 79 03 00 00       	call   80114f <strnlen>
  800dd6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dd9:	29 c1                	sub    %eax,%ecx
  800ddb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800dde:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800de1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800de5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800de8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800deb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ded:	eb 0f                	jmp    800dfe <vprintfmt+0x1cf>
					putch(padc, putdat);
  800def:	83 ec 08             	sub    $0x8,%esp
  800df2:	53                   	push   %ebx
  800df3:	ff 75 e0             	pushl  -0x20(%ebp)
  800df6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800df8:	83 ef 01             	sub    $0x1,%edi
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	85 ff                	test   %edi,%edi
  800e00:	7f ed                	jg     800def <vprintfmt+0x1c0>
  800e02:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e05:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e08:	85 c9                	test   %ecx,%ecx
  800e0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0f:	0f 49 c1             	cmovns %ecx,%eax
  800e12:	29 c1                	sub    %eax,%ecx
  800e14:	89 75 08             	mov    %esi,0x8(%ebp)
  800e17:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e1a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e1d:	89 cb                	mov    %ecx,%ebx
  800e1f:	eb 4d                	jmp    800e6e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e21:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e25:	74 1b                	je     800e42 <vprintfmt+0x213>
  800e27:	0f be c0             	movsbl %al,%eax
  800e2a:	83 e8 20             	sub    $0x20,%eax
  800e2d:	83 f8 5e             	cmp    $0x5e,%eax
  800e30:	76 10                	jbe    800e42 <vprintfmt+0x213>
					putch('?', putdat);
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	ff 75 0c             	pushl  0xc(%ebp)
  800e38:	6a 3f                	push   $0x3f
  800e3a:	ff 55 08             	call   *0x8(%ebp)
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	eb 0d                	jmp    800e4f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e42:	83 ec 08             	sub    $0x8,%esp
  800e45:	ff 75 0c             	pushl  0xc(%ebp)
  800e48:	52                   	push   %edx
  800e49:	ff 55 08             	call   *0x8(%ebp)
  800e4c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e4f:	83 eb 01             	sub    $0x1,%ebx
  800e52:	eb 1a                	jmp    800e6e <vprintfmt+0x23f>
  800e54:	89 75 08             	mov    %esi,0x8(%ebp)
  800e57:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e5a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e5d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e60:	eb 0c                	jmp    800e6e <vprintfmt+0x23f>
  800e62:	89 75 08             	mov    %esi,0x8(%ebp)
  800e65:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e68:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e6b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e6e:	83 c7 01             	add    $0x1,%edi
  800e71:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e75:	0f be d0             	movsbl %al,%edx
  800e78:	85 d2                	test   %edx,%edx
  800e7a:	74 23                	je     800e9f <vprintfmt+0x270>
  800e7c:	85 f6                	test   %esi,%esi
  800e7e:	78 a1                	js     800e21 <vprintfmt+0x1f2>
  800e80:	83 ee 01             	sub    $0x1,%esi
  800e83:	79 9c                	jns    800e21 <vprintfmt+0x1f2>
  800e85:	89 df                	mov    %ebx,%edi
  800e87:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e8d:	eb 18                	jmp    800ea7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	53                   	push   %ebx
  800e93:	6a 20                	push   $0x20
  800e95:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e97:	83 ef 01             	sub    $0x1,%edi
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	eb 08                	jmp    800ea7 <vprintfmt+0x278>
  800e9f:	89 df                	mov    %ebx,%edi
  800ea1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea7:	85 ff                	test   %edi,%edi
  800ea9:	7f e4                	jg     800e8f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800eab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800eae:	e9 a2 fd ff ff       	jmp    800c55 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800eb3:	83 fa 01             	cmp    $0x1,%edx
  800eb6:	7e 16                	jle    800ece <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebb:	8d 50 08             	lea    0x8(%eax),%edx
  800ebe:	89 55 14             	mov    %edx,0x14(%ebp)
  800ec1:	8b 50 04             	mov    0x4(%eax),%edx
  800ec4:	8b 00                	mov    (%eax),%eax
  800ec6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ecc:	eb 32                	jmp    800f00 <vprintfmt+0x2d1>
	else if (lflag)
  800ece:	85 d2                	test   %edx,%edx
  800ed0:	74 18                	je     800eea <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ed2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed5:	8d 50 04             	lea    0x4(%eax),%edx
  800ed8:	89 55 14             	mov    %edx,0x14(%ebp)
  800edb:	8b 00                	mov    (%eax),%eax
  800edd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ee0:	89 c1                	mov    %eax,%ecx
  800ee2:	c1 f9 1f             	sar    $0x1f,%ecx
  800ee5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ee8:	eb 16                	jmp    800f00 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800eea:	8b 45 14             	mov    0x14(%ebp),%eax
  800eed:	8d 50 04             	lea    0x4(%eax),%edx
  800ef0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ef3:	8b 00                	mov    (%eax),%eax
  800ef5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ef8:	89 c1                	mov    %eax,%ecx
  800efa:	c1 f9 1f             	sar    $0x1f,%ecx
  800efd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f00:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f03:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f06:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f0b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f0f:	79 74                	jns    800f85 <vprintfmt+0x356>
				putch('-', putdat);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	53                   	push   %ebx
  800f15:	6a 2d                	push   $0x2d
  800f17:	ff d6                	call   *%esi
				num = -(long long) num;
  800f19:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f1c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f1f:	f7 d8                	neg    %eax
  800f21:	83 d2 00             	adc    $0x0,%edx
  800f24:	f7 da                	neg    %edx
  800f26:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f29:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f2e:	eb 55                	jmp    800f85 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f30:	8d 45 14             	lea    0x14(%ebp),%eax
  800f33:	e8 83 fc ff ff       	call   800bbb <getuint>
			base = 10;
  800f38:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f3d:	eb 46                	jmp    800f85 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f3f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f42:	e8 74 fc ff ff       	call   800bbb <getuint>
		        base = 8;
  800f47:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800f4c:	eb 37                	jmp    800f85 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f4e:	83 ec 08             	sub    $0x8,%esp
  800f51:	53                   	push   %ebx
  800f52:	6a 30                	push   $0x30
  800f54:	ff d6                	call   *%esi
			putch('x', putdat);
  800f56:	83 c4 08             	add    $0x8,%esp
  800f59:	53                   	push   %ebx
  800f5a:	6a 78                	push   $0x78
  800f5c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f61:	8d 50 04             	lea    0x4(%eax),%edx
  800f64:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f67:	8b 00                	mov    (%eax),%eax
  800f69:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f6e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f71:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f76:	eb 0d                	jmp    800f85 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f78:	8d 45 14             	lea    0x14(%ebp),%eax
  800f7b:	e8 3b fc ff ff       	call   800bbb <getuint>
			base = 16;
  800f80:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f85:	83 ec 0c             	sub    $0xc,%esp
  800f88:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f8c:	57                   	push   %edi
  800f8d:	ff 75 e0             	pushl  -0x20(%ebp)
  800f90:	51                   	push   %ecx
  800f91:	52                   	push   %edx
  800f92:	50                   	push   %eax
  800f93:	89 da                	mov    %ebx,%edx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	e8 70 fb ff ff       	call   800b0c <printnum>
			break;
  800f9c:	83 c4 20             	add    $0x20,%esp
  800f9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fa2:	e9 ae fc ff ff       	jmp    800c55 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fa7:	83 ec 08             	sub    $0x8,%esp
  800faa:	53                   	push   %ebx
  800fab:	51                   	push   %ecx
  800fac:	ff d6                	call   *%esi
			break;
  800fae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fb4:	e9 9c fc ff ff       	jmp    800c55 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	53                   	push   %ebx
  800fbd:	6a 25                	push   $0x25
  800fbf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	eb 03                	jmp    800fc9 <vprintfmt+0x39a>
  800fc6:	83 ef 01             	sub    $0x1,%edi
  800fc9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fcd:	75 f7                	jne    800fc6 <vprintfmt+0x397>
  800fcf:	e9 81 fc ff ff       	jmp    800c55 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5f                   	pop    %edi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
  800fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fe8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800feb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ff2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	74 26                	je     801023 <vsnprintf+0x47>
  800ffd:	85 d2                	test   %edx,%edx
  800fff:	7e 22                	jle    801023 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801001:	ff 75 14             	pushl  0x14(%ebp)
  801004:	ff 75 10             	pushl  0x10(%ebp)
  801007:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	68 f5 0b 80 00       	push   $0x800bf5
  801010:	e8 1a fc ff ff       	call   800c2f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801015:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801018:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80101b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	eb 05                	jmp    801028 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801023:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801028:	c9                   	leave  
  801029:	c3                   	ret    

0080102a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801030:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801033:	50                   	push   %eax
  801034:	ff 75 10             	pushl  0x10(%ebp)
  801037:	ff 75 0c             	pushl  0xc(%ebp)
  80103a:	ff 75 08             	pushl  0x8(%ebp)
  80103d:	e8 9a ff ff ff       	call   800fdc <vsnprintf>
	va_end(ap);

	return rc;
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	57                   	push   %edi
  801048:	56                   	push   %esi
  801049:	53                   	push   %ebx
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801050:	85 c0                	test   %eax,%eax
  801052:	74 13                	je     801067 <readline+0x23>
		fprintf(1, "%s", prompt);
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	50                   	push   %eax
  801058:	68 a2 38 80 00       	push   $0x8038a2
  80105d:	6a 01                	push   $0x1
  80105f:	e8 95 14 00 00       	call   8024f9 <fprintf>
  801064:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	6a 00                	push   $0x0
  80106c:	e8 be f8 ff ff       	call   80092f <iscons>
  801071:	89 c7                	mov    %eax,%edi
  801073:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  801076:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80107b:	e8 84 f8 ff ff       	call   800904 <getchar>
  801080:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801082:	85 c0                	test   %eax,%eax
  801084:	79 29                	jns    8010af <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80108b:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80108e:	0f 84 9b 00 00 00    	je     80112f <readline+0xeb>
				cprintf("read error: %e\n", c);
  801094:	83 ec 08             	sub    $0x8,%esp
  801097:	53                   	push   %ebx
  801098:	68 7f 3c 80 00       	push   $0x803c7f
  80109d:	e8 56 fa ff ff       	call   800af8 <cprintf>
  8010a2:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010aa:	e9 80 00 00 00       	jmp    80112f <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010af:	83 f8 08             	cmp    $0x8,%eax
  8010b2:	0f 94 c2             	sete   %dl
  8010b5:	83 f8 7f             	cmp    $0x7f,%eax
  8010b8:	0f 94 c0             	sete   %al
  8010bb:	08 c2                	or     %al,%dl
  8010bd:	74 1a                	je     8010d9 <readline+0x95>
  8010bf:	85 f6                	test   %esi,%esi
  8010c1:	7e 16                	jle    8010d9 <readline+0x95>
			if (echoing)
  8010c3:	85 ff                	test   %edi,%edi
  8010c5:	74 0d                	je     8010d4 <readline+0x90>
				cputchar('\b');
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	6a 08                	push   $0x8
  8010cc:	e8 17 f8 ff ff       	call   8008e8 <cputchar>
  8010d1:	83 c4 10             	add    $0x10,%esp
			i--;
  8010d4:	83 ee 01             	sub    $0x1,%esi
  8010d7:	eb a2                	jmp    80107b <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010d9:	83 fb 1f             	cmp    $0x1f,%ebx
  8010dc:	7e 26                	jle    801104 <readline+0xc0>
  8010de:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010e4:	7f 1e                	jg     801104 <readline+0xc0>
			if (echoing)
  8010e6:	85 ff                	test   %edi,%edi
  8010e8:	74 0c                	je     8010f6 <readline+0xb2>
				cputchar(c);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	53                   	push   %ebx
  8010ee:	e8 f5 f7 ff ff       	call   8008e8 <cputchar>
  8010f3:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010f6:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
  8010fc:	8d 76 01             	lea    0x1(%esi),%esi
  8010ff:	e9 77 ff ff ff       	jmp    80107b <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801104:	83 fb 0a             	cmp    $0xa,%ebx
  801107:	74 09                	je     801112 <readline+0xce>
  801109:	83 fb 0d             	cmp    $0xd,%ebx
  80110c:	0f 85 69 ff ff ff    	jne    80107b <readline+0x37>
			if (echoing)
  801112:	85 ff                	test   %edi,%edi
  801114:	74 0d                	je     801123 <readline+0xdf>
				cputchar('\n');
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	6a 0a                	push   $0xa
  80111b:	e8 c8 f7 ff ff       	call   8008e8 <cputchar>
  801120:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801123:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  80112a:	b8 20 60 80 00       	mov    $0x806020,%eax
		}
	}
}
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80113d:	b8 00 00 00 00       	mov    $0x0,%eax
  801142:	eb 03                	jmp    801147 <strlen+0x10>
		n++;
  801144:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801147:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80114b:	75 f7                	jne    801144 <strlen+0xd>
		n++;
	return n;
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801155:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801158:	ba 00 00 00 00       	mov    $0x0,%edx
  80115d:	eb 03                	jmp    801162 <strnlen+0x13>
		n++;
  80115f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801162:	39 c2                	cmp    %eax,%edx
  801164:	74 08                	je     80116e <strnlen+0x1f>
  801166:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80116a:	75 f3                	jne    80115f <strnlen+0x10>
  80116c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	53                   	push   %ebx
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	83 c2 01             	add    $0x1,%edx
  80117f:	83 c1 01             	add    $0x1,%ecx
  801182:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801186:	88 5a ff             	mov    %bl,-0x1(%edx)
  801189:	84 db                	test   %bl,%bl
  80118b:	75 ef                	jne    80117c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80118d:	5b                   	pop    %ebx
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	53                   	push   %ebx
  801194:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801197:	53                   	push   %ebx
  801198:	e8 9a ff ff ff       	call   801137 <strlen>
  80119d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011a0:	ff 75 0c             	pushl  0xc(%ebp)
  8011a3:	01 d8                	add    %ebx,%eax
  8011a5:	50                   	push   %eax
  8011a6:	e8 c5 ff ff ff       	call   801170 <strcpy>
	return dst;
}
  8011ab:	89 d8                	mov    %ebx,%eax
  8011ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	56                   	push   %esi
  8011b6:	53                   	push   %ebx
  8011b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bd:	89 f3                	mov    %esi,%ebx
  8011bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011c2:	89 f2                	mov    %esi,%edx
  8011c4:	eb 0f                	jmp    8011d5 <strncpy+0x23>
		*dst++ = *src;
  8011c6:	83 c2 01             	add    $0x1,%edx
  8011c9:	0f b6 01             	movzbl (%ecx),%eax
  8011cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8011d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011d5:	39 da                	cmp    %ebx,%edx
  8011d7:	75 ed                	jne    8011c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011d9:	89 f0                	mov    %esi,%eax
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	56                   	push   %esi
  8011e3:	53                   	push   %ebx
  8011e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8011ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011ef:	85 d2                	test   %edx,%edx
  8011f1:	74 21                	je     801214 <strlcpy+0x35>
  8011f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011f7:	89 f2                	mov    %esi,%edx
  8011f9:	eb 09                	jmp    801204 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011fb:	83 c2 01             	add    $0x1,%edx
  8011fe:	83 c1 01             	add    $0x1,%ecx
  801201:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801204:	39 c2                	cmp    %eax,%edx
  801206:	74 09                	je     801211 <strlcpy+0x32>
  801208:	0f b6 19             	movzbl (%ecx),%ebx
  80120b:	84 db                	test   %bl,%bl
  80120d:	75 ec                	jne    8011fb <strlcpy+0x1c>
  80120f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801211:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801214:	29 f0                	sub    %esi,%eax
}
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801220:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801223:	eb 06                	jmp    80122b <strcmp+0x11>
		p++, q++;
  801225:	83 c1 01             	add    $0x1,%ecx
  801228:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80122b:	0f b6 01             	movzbl (%ecx),%eax
  80122e:	84 c0                	test   %al,%al
  801230:	74 04                	je     801236 <strcmp+0x1c>
  801232:	3a 02                	cmp    (%edx),%al
  801234:	74 ef                	je     801225 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801236:	0f b6 c0             	movzbl %al,%eax
  801239:	0f b6 12             	movzbl (%edx),%edx
  80123c:	29 d0                	sub    %edx,%eax
}
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
  801247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124a:	89 c3                	mov    %eax,%ebx
  80124c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80124f:	eb 06                	jmp    801257 <strncmp+0x17>
		n--, p++, q++;
  801251:	83 c0 01             	add    $0x1,%eax
  801254:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801257:	39 d8                	cmp    %ebx,%eax
  801259:	74 15                	je     801270 <strncmp+0x30>
  80125b:	0f b6 08             	movzbl (%eax),%ecx
  80125e:	84 c9                	test   %cl,%cl
  801260:	74 04                	je     801266 <strncmp+0x26>
  801262:	3a 0a                	cmp    (%edx),%cl
  801264:	74 eb                	je     801251 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801266:	0f b6 00             	movzbl (%eax),%eax
  801269:	0f b6 12             	movzbl (%edx),%edx
  80126c:	29 d0                	sub    %edx,%eax
  80126e:	eb 05                	jmp    801275 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801275:	5b                   	pop    %ebx
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	8b 45 08             	mov    0x8(%ebp),%eax
  80127e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801282:	eb 07                	jmp    80128b <strchr+0x13>
		if (*s == c)
  801284:	38 ca                	cmp    %cl,%dl
  801286:	74 0f                	je     801297 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801288:	83 c0 01             	add    $0x1,%eax
  80128b:	0f b6 10             	movzbl (%eax),%edx
  80128e:	84 d2                	test   %dl,%dl
  801290:	75 f2                	jne    801284 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
  80129f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012a3:	eb 03                	jmp    8012a8 <strfind+0xf>
  8012a5:	83 c0 01             	add    $0x1,%eax
  8012a8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012ab:	38 ca                	cmp    %cl,%dl
  8012ad:	74 04                	je     8012b3 <strfind+0x1a>
  8012af:	84 d2                	test   %dl,%dl
  8012b1:	75 f2                	jne    8012a5 <strfind+0xc>
			break;
	return (char *) s;
}
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
  8012bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012c1:	85 c9                	test   %ecx,%ecx
  8012c3:	74 36                	je     8012fb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012cb:	75 28                	jne    8012f5 <memset+0x40>
  8012cd:	f6 c1 03             	test   $0x3,%cl
  8012d0:	75 23                	jne    8012f5 <memset+0x40>
		c &= 0xFF;
  8012d2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012d6:	89 d3                	mov    %edx,%ebx
  8012d8:	c1 e3 08             	shl    $0x8,%ebx
  8012db:	89 d6                	mov    %edx,%esi
  8012dd:	c1 e6 18             	shl    $0x18,%esi
  8012e0:	89 d0                	mov    %edx,%eax
  8012e2:	c1 e0 10             	shl    $0x10,%eax
  8012e5:	09 f0                	or     %esi,%eax
  8012e7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012e9:	89 d8                	mov    %ebx,%eax
  8012eb:	09 d0                	or     %edx,%eax
  8012ed:	c1 e9 02             	shr    $0x2,%ecx
  8012f0:	fc                   	cld    
  8012f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8012f3:	eb 06                	jmp    8012fb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f8:	fc                   	cld    
  8012f9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012fb:	89 f8                	mov    %edi,%eax
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	57                   	push   %edi
  801306:	56                   	push   %esi
  801307:	8b 45 08             	mov    0x8(%ebp),%eax
  80130a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80130d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801310:	39 c6                	cmp    %eax,%esi
  801312:	73 35                	jae    801349 <memmove+0x47>
  801314:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801317:	39 d0                	cmp    %edx,%eax
  801319:	73 2e                	jae    801349 <memmove+0x47>
		s += n;
		d += n;
  80131b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80131e:	89 d6                	mov    %edx,%esi
  801320:	09 fe                	or     %edi,%esi
  801322:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801328:	75 13                	jne    80133d <memmove+0x3b>
  80132a:	f6 c1 03             	test   $0x3,%cl
  80132d:	75 0e                	jne    80133d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80132f:	83 ef 04             	sub    $0x4,%edi
  801332:	8d 72 fc             	lea    -0x4(%edx),%esi
  801335:	c1 e9 02             	shr    $0x2,%ecx
  801338:	fd                   	std    
  801339:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80133b:	eb 09                	jmp    801346 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80133d:	83 ef 01             	sub    $0x1,%edi
  801340:	8d 72 ff             	lea    -0x1(%edx),%esi
  801343:	fd                   	std    
  801344:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801346:	fc                   	cld    
  801347:	eb 1d                	jmp    801366 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801349:	89 f2                	mov    %esi,%edx
  80134b:	09 c2                	or     %eax,%edx
  80134d:	f6 c2 03             	test   $0x3,%dl
  801350:	75 0f                	jne    801361 <memmove+0x5f>
  801352:	f6 c1 03             	test   $0x3,%cl
  801355:	75 0a                	jne    801361 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801357:	c1 e9 02             	shr    $0x2,%ecx
  80135a:	89 c7                	mov    %eax,%edi
  80135c:	fc                   	cld    
  80135d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80135f:	eb 05                	jmp    801366 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801361:	89 c7                	mov    %eax,%edi
  801363:	fc                   	cld    
  801364:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80136d:	ff 75 10             	pushl  0x10(%ebp)
  801370:	ff 75 0c             	pushl  0xc(%ebp)
  801373:	ff 75 08             	pushl  0x8(%ebp)
  801376:	e8 87 ff ff ff       	call   801302 <memmove>
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	56                   	push   %esi
  801381:	53                   	push   %ebx
  801382:	8b 45 08             	mov    0x8(%ebp),%eax
  801385:	8b 55 0c             	mov    0xc(%ebp),%edx
  801388:	89 c6                	mov    %eax,%esi
  80138a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80138d:	eb 1a                	jmp    8013a9 <memcmp+0x2c>
		if (*s1 != *s2)
  80138f:	0f b6 08             	movzbl (%eax),%ecx
  801392:	0f b6 1a             	movzbl (%edx),%ebx
  801395:	38 d9                	cmp    %bl,%cl
  801397:	74 0a                	je     8013a3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801399:	0f b6 c1             	movzbl %cl,%eax
  80139c:	0f b6 db             	movzbl %bl,%ebx
  80139f:	29 d8                	sub    %ebx,%eax
  8013a1:	eb 0f                	jmp    8013b2 <memcmp+0x35>
		s1++, s2++;
  8013a3:	83 c0 01             	add    $0x1,%eax
  8013a6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013a9:	39 f0                	cmp    %esi,%eax
  8013ab:	75 e2                	jne    80138f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b2:	5b                   	pop    %ebx
  8013b3:	5e                   	pop    %esi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	53                   	push   %ebx
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013bd:	89 c1                	mov    %eax,%ecx
  8013bf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013c2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013c6:	eb 0a                	jmp    8013d2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013c8:	0f b6 10             	movzbl (%eax),%edx
  8013cb:	39 da                	cmp    %ebx,%edx
  8013cd:	74 07                	je     8013d6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013cf:	83 c0 01             	add    $0x1,%eax
  8013d2:	39 c8                	cmp    %ecx,%eax
  8013d4:	72 f2                	jb     8013c8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013d6:	5b                   	pop    %ebx
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	57                   	push   %edi
  8013dd:	56                   	push   %esi
  8013de:	53                   	push   %ebx
  8013df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013e5:	eb 03                	jmp    8013ea <strtol+0x11>
		s++;
  8013e7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013ea:	0f b6 01             	movzbl (%ecx),%eax
  8013ed:	3c 20                	cmp    $0x20,%al
  8013ef:	74 f6                	je     8013e7 <strtol+0xe>
  8013f1:	3c 09                	cmp    $0x9,%al
  8013f3:	74 f2                	je     8013e7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013f5:	3c 2b                	cmp    $0x2b,%al
  8013f7:	75 0a                	jne    801403 <strtol+0x2a>
		s++;
  8013f9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013fc:	bf 00 00 00 00       	mov    $0x0,%edi
  801401:	eb 11                	jmp    801414 <strtol+0x3b>
  801403:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801408:	3c 2d                	cmp    $0x2d,%al
  80140a:	75 08                	jne    801414 <strtol+0x3b>
		s++, neg = 1;
  80140c:	83 c1 01             	add    $0x1,%ecx
  80140f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801414:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80141a:	75 15                	jne    801431 <strtol+0x58>
  80141c:	80 39 30             	cmpb   $0x30,(%ecx)
  80141f:	75 10                	jne    801431 <strtol+0x58>
  801421:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801425:	75 7c                	jne    8014a3 <strtol+0xca>
		s += 2, base = 16;
  801427:	83 c1 02             	add    $0x2,%ecx
  80142a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80142f:	eb 16                	jmp    801447 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801431:	85 db                	test   %ebx,%ebx
  801433:	75 12                	jne    801447 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801435:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80143a:	80 39 30             	cmpb   $0x30,(%ecx)
  80143d:	75 08                	jne    801447 <strtol+0x6e>
		s++, base = 8;
  80143f:	83 c1 01             	add    $0x1,%ecx
  801442:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801447:	b8 00 00 00 00       	mov    $0x0,%eax
  80144c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80144f:	0f b6 11             	movzbl (%ecx),%edx
  801452:	8d 72 d0             	lea    -0x30(%edx),%esi
  801455:	89 f3                	mov    %esi,%ebx
  801457:	80 fb 09             	cmp    $0x9,%bl
  80145a:	77 08                	ja     801464 <strtol+0x8b>
			dig = *s - '0';
  80145c:	0f be d2             	movsbl %dl,%edx
  80145f:	83 ea 30             	sub    $0x30,%edx
  801462:	eb 22                	jmp    801486 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801464:	8d 72 9f             	lea    -0x61(%edx),%esi
  801467:	89 f3                	mov    %esi,%ebx
  801469:	80 fb 19             	cmp    $0x19,%bl
  80146c:	77 08                	ja     801476 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80146e:	0f be d2             	movsbl %dl,%edx
  801471:	83 ea 57             	sub    $0x57,%edx
  801474:	eb 10                	jmp    801486 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801476:	8d 72 bf             	lea    -0x41(%edx),%esi
  801479:	89 f3                	mov    %esi,%ebx
  80147b:	80 fb 19             	cmp    $0x19,%bl
  80147e:	77 16                	ja     801496 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801480:	0f be d2             	movsbl %dl,%edx
  801483:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801486:	3b 55 10             	cmp    0x10(%ebp),%edx
  801489:	7d 0b                	jge    801496 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80148b:	83 c1 01             	add    $0x1,%ecx
  80148e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801492:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801494:	eb b9                	jmp    80144f <strtol+0x76>

	if (endptr)
  801496:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80149a:	74 0d                	je     8014a9 <strtol+0xd0>
		*endptr = (char *) s;
  80149c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80149f:	89 0e                	mov    %ecx,(%esi)
  8014a1:	eb 06                	jmp    8014a9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014a3:	85 db                	test   %ebx,%ebx
  8014a5:	74 98                	je     80143f <strtol+0x66>
  8014a7:	eb 9e                	jmp    801447 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	f7 da                	neg    %edx
  8014ad:	85 ff                	test   %edi,%edi
  8014af:	0f 45 c2             	cmovne %edx,%eax
}
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5f                   	pop    %edi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	57                   	push   %edi
  8014bb:	56                   	push   %esi
  8014bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	89 c7                	mov    %eax,%edi
  8014cc:	89 c6                	mov    %eax,%esi
  8014ce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014d0:	5b                   	pop    %ebx
  8014d1:	5e                   	pop    %esi
  8014d2:	5f                   	pop    %edi
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    

008014d5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	57                   	push   %edi
  8014d9:	56                   	push   %esi
  8014da:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014db:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e5:	89 d1                	mov    %edx,%ecx
  8014e7:	89 d3                	mov    %edx,%ebx
  8014e9:	89 d7                	mov    %edx,%edi
  8014eb:	89 d6                	mov    %edx,%esi
  8014ed:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5f                   	pop    %edi
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	57                   	push   %edi
  8014f8:	56                   	push   %esi
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801502:	b8 03 00 00 00       	mov    $0x3,%eax
  801507:	8b 55 08             	mov    0x8(%ebp),%edx
  80150a:	89 cb                	mov    %ecx,%ebx
  80150c:	89 cf                	mov    %ecx,%edi
  80150e:	89 ce                	mov    %ecx,%esi
  801510:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801512:	85 c0                	test   %eax,%eax
  801514:	7e 17                	jle    80152d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801516:	83 ec 0c             	sub    $0xc,%esp
  801519:	50                   	push   %eax
  80151a:	6a 03                	push   $0x3
  80151c:	68 8f 3c 80 00       	push   $0x803c8f
  801521:	6a 23                	push   $0x23
  801523:	68 ac 3c 80 00       	push   $0x803cac
  801528:	e8 f2 f4 ff ff       	call   800a1f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80152d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5f                   	pop    %edi
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	57                   	push   %edi
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 02 00 00 00       	mov    $0x2,%eax
  801545:	89 d1                	mov    %edx,%ecx
  801547:	89 d3                	mov    %edx,%ebx
  801549:	89 d7                	mov    %edx,%edi
  80154b:	89 d6                	mov    %edx,%esi
  80154d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5f                   	pop    %edi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    

00801554 <sys_yield>:

void
sys_yield(void)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	57                   	push   %edi
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80155a:	ba 00 00 00 00       	mov    $0x0,%edx
  80155f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801564:	89 d1                	mov    %edx,%ecx
  801566:	89 d3                	mov    %edx,%ebx
  801568:	89 d7                	mov    %edx,%edi
  80156a:	89 d6                	mov    %edx,%esi
  80156c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	57                   	push   %edi
  801577:	56                   	push   %esi
  801578:	53                   	push   %ebx
  801579:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80157c:	be 00 00 00 00       	mov    $0x0,%esi
  801581:	b8 04 00 00 00       	mov    $0x4,%eax
  801586:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801589:	8b 55 08             	mov    0x8(%ebp),%edx
  80158c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80158f:	89 f7                	mov    %esi,%edi
  801591:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801593:	85 c0                	test   %eax,%eax
  801595:	7e 17                	jle    8015ae <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	50                   	push   %eax
  80159b:	6a 04                	push   $0x4
  80159d:	68 8f 3c 80 00       	push   $0x803c8f
  8015a2:	6a 23                	push   $0x23
  8015a4:	68 ac 3c 80 00       	push   $0x803cac
  8015a9:	e8 71 f4 ff ff       	call   800a1f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b1:	5b                   	pop    %ebx
  8015b2:	5e                   	pop    %esi
  8015b3:	5f                   	pop    %edi
  8015b4:	5d                   	pop    %ebp
  8015b5:	c3                   	ret    

008015b6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	57                   	push   %edi
  8015ba:	56                   	push   %esi
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015d0:	8b 75 18             	mov    0x18(%ebp),%esi
  8015d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	7e 17                	jle    8015f0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d9:	83 ec 0c             	sub    $0xc,%esp
  8015dc:	50                   	push   %eax
  8015dd:	6a 05                	push   $0x5
  8015df:	68 8f 3c 80 00       	push   $0x803c8f
  8015e4:	6a 23                	push   $0x23
  8015e6:	68 ac 3c 80 00       	push   $0x803cac
  8015eb:	e8 2f f4 ff ff       	call   800a1f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f3:	5b                   	pop    %ebx
  8015f4:	5e                   	pop    %esi
  8015f5:	5f                   	pop    %edi
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	57                   	push   %edi
  8015fc:	56                   	push   %esi
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801601:	bb 00 00 00 00       	mov    $0x0,%ebx
  801606:	b8 06 00 00 00       	mov    $0x6,%eax
  80160b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160e:	8b 55 08             	mov    0x8(%ebp),%edx
  801611:	89 df                	mov    %ebx,%edi
  801613:	89 de                	mov    %ebx,%esi
  801615:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801617:	85 c0                	test   %eax,%eax
  801619:	7e 17                	jle    801632 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	50                   	push   %eax
  80161f:	6a 06                	push   $0x6
  801621:	68 8f 3c 80 00       	push   $0x803c8f
  801626:	6a 23                	push   $0x23
  801628:	68 ac 3c 80 00       	push   $0x803cac
  80162d:	e8 ed f3 ff ff       	call   800a1f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801632:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5f                   	pop    %edi
  801638:	5d                   	pop    %ebp
  801639:	c3                   	ret    

0080163a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	57                   	push   %edi
  80163e:	56                   	push   %esi
  80163f:	53                   	push   %ebx
  801640:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801643:	bb 00 00 00 00       	mov    $0x0,%ebx
  801648:	b8 08 00 00 00       	mov    $0x8,%eax
  80164d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801650:	8b 55 08             	mov    0x8(%ebp),%edx
  801653:	89 df                	mov    %ebx,%edi
  801655:	89 de                	mov    %ebx,%esi
  801657:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801659:	85 c0                	test   %eax,%eax
  80165b:	7e 17                	jle    801674 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80165d:	83 ec 0c             	sub    $0xc,%esp
  801660:	50                   	push   %eax
  801661:	6a 08                	push   $0x8
  801663:	68 8f 3c 80 00       	push   $0x803c8f
  801668:	6a 23                	push   $0x23
  80166a:	68 ac 3c 80 00       	push   $0x803cac
  80166f:	e8 ab f3 ff ff       	call   800a1f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5f                   	pop    %edi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	57                   	push   %edi
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
  801682:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801685:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168a:	b8 09 00 00 00       	mov    $0x9,%eax
  80168f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801692:	8b 55 08             	mov    0x8(%ebp),%edx
  801695:	89 df                	mov    %ebx,%edi
  801697:	89 de                	mov    %ebx,%esi
  801699:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80169b:	85 c0                	test   %eax,%eax
  80169d:	7e 17                	jle    8016b6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80169f:	83 ec 0c             	sub    $0xc,%esp
  8016a2:	50                   	push   %eax
  8016a3:	6a 09                	push   $0x9
  8016a5:	68 8f 3c 80 00       	push   $0x803c8f
  8016aa:	6a 23                	push   $0x23
  8016ac:	68 ac 3c 80 00       	push   $0x803cac
  8016b1:	e8 69 f3 ff ff       	call   800a1f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b9:	5b                   	pop    %ebx
  8016ba:	5e                   	pop    %esi
  8016bb:	5f                   	pop    %edi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	57                   	push   %edi
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d7:	89 df                	mov    %ebx,%edi
  8016d9:	89 de                	mov    %ebx,%esi
  8016db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	7e 17                	jle    8016f8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016e1:	83 ec 0c             	sub    $0xc,%esp
  8016e4:	50                   	push   %eax
  8016e5:	6a 0a                	push   $0xa
  8016e7:	68 8f 3c 80 00       	push   $0x803c8f
  8016ec:	6a 23                	push   $0x23
  8016ee:	68 ac 3c 80 00       	push   $0x803cac
  8016f3:	e8 27 f3 ff ff       	call   800a1f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5e                   	pop    %esi
  8016fd:	5f                   	pop    %edi
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801706:	be 00 00 00 00       	mov    $0x0,%esi
  80170b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801713:	8b 55 08             	mov    0x8(%ebp),%edx
  801716:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801719:	8b 7d 14             	mov    0x14(%ebp),%edi
  80171c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5f                   	pop    %edi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	57                   	push   %edi
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80172c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801731:	b8 0d 00 00 00       	mov    $0xd,%eax
  801736:	8b 55 08             	mov    0x8(%ebp),%edx
  801739:	89 cb                	mov    %ecx,%ebx
  80173b:	89 cf                	mov    %ecx,%edi
  80173d:	89 ce                	mov    %ecx,%esi
  80173f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801741:	85 c0                	test   %eax,%eax
  801743:	7e 17                	jle    80175c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801745:	83 ec 0c             	sub    $0xc,%esp
  801748:	50                   	push   %eax
  801749:	6a 0d                	push   $0xd
  80174b:	68 8f 3c 80 00       	push   $0x803c8f
  801750:	6a 23                	push   $0x23
  801752:	68 ac 3c 80 00       	push   $0x803cac
  801757:	e8 c3 f2 ff ff       	call   800a1f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80175c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5f                   	pop    %edi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	57                   	push   %edi
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80176a:	ba 00 00 00 00       	mov    $0x0,%edx
  80176f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801774:	89 d1                	mov    %edx,%ecx
  801776:	89 d3                	mov    %edx,%ebx
  801778:	89 d7                	mov    %edx,%edi
  80177a:	89 d6                	mov    %edx,%esi
  80177c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5f                   	pop    %edi
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	57                   	push   %edi
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801789:	bb 00 00 00 00       	mov    $0x0,%ebx
  80178e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801796:	8b 55 08             	mov    0x8(%ebp),%edx
  801799:	89 df                	mov    %ebx,%edi
  80179b:	89 de                	mov    %ebx,%esi
  80179d:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5f                   	pop    %edi
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 04             	sub    $0x4,%esp
  8017ab:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  8017ae:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  8017b0:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  8017b4:	74 2e                	je     8017e4 <pgfault+0x40>
  8017b6:	89 c2                	mov    %eax,%edx
  8017b8:	c1 ea 16             	shr    $0x16,%edx
  8017bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017c2:	f6 c2 01             	test   $0x1,%dl
  8017c5:	74 1d                	je     8017e4 <pgfault+0x40>
  8017c7:	89 c2                	mov    %eax,%edx
  8017c9:	c1 ea 0c             	shr    $0xc,%edx
  8017cc:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8017d3:	f6 c1 01             	test   $0x1,%cl
  8017d6:	74 0c                	je     8017e4 <pgfault+0x40>
  8017d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017df:	f6 c6 08             	test   $0x8,%dh
  8017e2:	75 14                	jne    8017f8 <pgfault+0x54>
        panic("Not copy-on-write\n");
  8017e4:	83 ec 04             	sub    $0x4,%esp
  8017e7:	68 ba 3c 80 00       	push   $0x803cba
  8017ec:	6a 1d                	push   $0x1d
  8017ee:	68 cd 3c 80 00       	push   $0x803ccd
  8017f3:	e8 27 f2 ff ff       	call   800a1f <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8017f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017fd:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	6a 07                	push   $0x7
  801804:	68 00 f0 7f 00       	push   $0x7ff000
  801809:	6a 00                	push   $0x0
  80180b:	e8 63 fd ff ff       	call   801573 <sys_page_alloc>
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	79 14                	jns    80182b <pgfault+0x87>
		panic("page alloc failed \n");
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	68 d8 3c 80 00       	push   $0x803cd8
  80181f:	6a 28                	push   $0x28
  801821:	68 cd 3c 80 00       	push   $0x803ccd
  801826:	e8 f4 f1 ff ff       	call   800a1f <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	68 00 10 00 00       	push   $0x1000
  801833:	53                   	push   %ebx
  801834:	68 00 f0 7f 00       	push   $0x7ff000
  801839:	e8 2c fb ff ff       	call   80136a <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  80183e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801845:	53                   	push   %ebx
  801846:	6a 00                	push   $0x0
  801848:	68 00 f0 7f 00       	push   $0x7ff000
  80184d:	6a 00                	push   $0x0
  80184f:	e8 62 fd ff ff       	call   8015b6 <sys_page_map>
  801854:	83 c4 20             	add    $0x20,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	79 14                	jns    80186f <pgfault+0xcb>
        panic("page map failed \n");
  80185b:	83 ec 04             	sub    $0x4,%esp
  80185e:	68 ec 3c 80 00       	push   $0x803cec
  801863:	6a 2b                	push   $0x2b
  801865:	68 cd 3c 80 00       	push   $0x803ccd
  80186a:	e8 b0 f1 ff ff       	call   800a1f <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  80186f:	83 ec 08             	sub    $0x8,%esp
  801872:	68 00 f0 7f 00       	push   $0x7ff000
  801877:	6a 00                	push   $0x0
  801879:	e8 7a fd ff ff       	call   8015f8 <sys_page_unmap>
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	79 14                	jns    801899 <pgfault+0xf5>
        panic("page unmap failed\n");
  801885:	83 ec 04             	sub    $0x4,%esp
  801888:	68 fe 3c 80 00       	push   $0x803cfe
  80188d:	6a 2d                	push   $0x2d
  80188f:	68 cd 3c 80 00       	push   $0x803ccd
  801894:	e8 86 f1 ff ff       	call   800a1f <_panic>
	
	//panic("pgfault not implemented");
}
  801899:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	57                   	push   %edi
  8018a2:	56                   	push   %esi
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  8018a7:	68 a4 17 80 00       	push   $0x8017a4
  8018ac:	e8 31 1a 00 00       	call   8032e2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8018b1:	b8 07 00 00 00       	mov    $0x7,%eax
  8018b6:	cd 30                	int    $0x30
  8018b8:	89 c7                	mov    %eax,%edi
  8018ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	79 12                	jns    8018d6 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  8018c4:	50                   	push   %eax
  8018c5:	68 11 3d 80 00       	push   $0x803d11
  8018ca:	6a 7a                	push   $0x7a
  8018cc:	68 cd 3c 80 00       	push   $0x803ccd
  8018d1:	e8 49 f1 ff ff       	call   800a1f <_panic>
  8018d6:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	75 21                	jne    801900 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  8018df:	e8 51 fc ff ff       	call   801535 <sys_getenvid>
  8018e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018f1:	a3 28 64 80 00       	mov    %eax,0x806428
		return 0;
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fb:	e9 91 01 00 00       	jmp    801a91 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  801900:	89 d8                	mov    %ebx,%eax
  801902:	c1 e8 16             	shr    $0x16,%eax
  801905:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80190c:	a8 01                	test   $0x1,%al
  80190e:	0f 84 06 01 00 00    	je     801a1a <fork+0x17c>
  801914:	89 d8                	mov    %ebx,%eax
  801916:	c1 e8 0c             	shr    $0xc,%eax
  801919:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801920:	f6 c2 01             	test   $0x1,%dl
  801923:	0f 84 f1 00 00 00    	je     801a1a <fork+0x17c>
  801929:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801930:	f6 c2 04             	test   $0x4,%dl
  801933:	0f 84 e1 00 00 00    	je     801a1a <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  801939:	89 c6                	mov    %eax,%esi
  80193b:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  80193e:	89 f2                	mov    %esi,%edx
  801940:	c1 ea 16             	shr    $0x16,%edx
  801943:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  80194a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  801951:	f6 c6 04             	test   $0x4,%dh
  801954:	74 39                	je     80198f <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  801956:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	25 07 0e 00 00       	and    $0xe07,%eax
  801965:	50                   	push   %eax
  801966:	56                   	push   %esi
  801967:	ff 75 e4             	pushl  -0x1c(%ebp)
  80196a:	56                   	push   %esi
  80196b:	6a 00                	push   $0x0
  80196d:	e8 44 fc ff ff       	call   8015b6 <sys_page_map>
  801972:	83 c4 20             	add    $0x20,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	0f 89 9d 00 00 00    	jns    801a1a <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  80197d:	50                   	push   %eax
  80197e:	68 68 3d 80 00       	push   $0x803d68
  801983:	6a 4b                	push   $0x4b
  801985:	68 cd 3c 80 00       	push   $0x803ccd
  80198a:	e8 90 f0 ff ff       	call   800a1f <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  80198f:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801995:	74 59                	je     8019f0 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801997:	83 ec 0c             	sub    $0xc,%esp
  80199a:	68 05 08 00 00       	push   $0x805
  80199f:	56                   	push   %esi
  8019a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a3:	56                   	push   %esi
  8019a4:	6a 00                	push   $0x0
  8019a6:	e8 0b fc ff ff       	call   8015b6 <sys_page_map>
  8019ab:	83 c4 20             	add    $0x20,%esp
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	79 12                	jns    8019c4 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  8019b2:	50                   	push   %eax
  8019b3:	68 98 3d 80 00       	push   $0x803d98
  8019b8:	6a 50                	push   $0x50
  8019ba:	68 cd 3c 80 00       	push   $0x803ccd
  8019bf:	e8 5b f0 ff ff       	call   800a1f <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8019c4:	83 ec 0c             	sub    $0xc,%esp
  8019c7:	68 05 08 00 00       	push   $0x805
  8019cc:	56                   	push   %esi
  8019cd:	6a 00                	push   $0x0
  8019cf:	56                   	push   %esi
  8019d0:	6a 00                	push   $0x0
  8019d2:	e8 df fb ff ff       	call   8015b6 <sys_page_map>
  8019d7:	83 c4 20             	add    $0x20,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	79 3c                	jns    801a1a <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  8019de:	50                   	push   %eax
  8019df:	68 c0 3d 80 00       	push   $0x803dc0
  8019e4:	6a 53                	push   $0x53
  8019e6:	68 cd 3c 80 00       	push   $0x803ccd
  8019eb:	e8 2f f0 ff ff       	call   800a1f <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	6a 05                	push   $0x5
  8019f5:	56                   	push   %esi
  8019f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019f9:	56                   	push   %esi
  8019fa:	6a 00                	push   $0x0
  8019fc:	e8 b5 fb ff ff       	call   8015b6 <sys_page_map>
  801a01:	83 c4 20             	add    $0x20,%esp
  801a04:	85 c0                	test   %eax,%eax
  801a06:	79 12                	jns    801a1a <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  801a08:	50                   	push   %eax
  801a09:	68 e8 3d 80 00       	push   $0x803de8
  801a0e:	6a 58                	push   $0x58
  801a10:	68 cd 3c 80 00       	push   $0x803ccd
  801a15:	e8 05 f0 ff ff       	call   800a1f <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  801a1a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a20:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a26:	0f 85 d4 fe ff ff    	jne    801900 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  801a2c:	83 ec 04             	sub    $0x4,%esp
  801a2f:	6a 07                	push   $0x7
  801a31:	68 00 f0 bf ee       	push   $0xeebff000
  801a36:	57                   	push   %edi
  801a37:	e8 37 fb ff ff       	call   801573 <sys_page_alloc>
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	79 17                	jns    801a5a <fork+0x1bc>
        panic("page alloc failed\n");
  801a43:	83 ec 04             	sub    $0x4,%esp
  801a46:	68 23 3d 80 00       	push   $0x803d23
  801a4b:	68 87 00 00 00       	push   $0x87
  801a50:	68 cd 3c 80 00       	push   $0x803ccd
  801a55:	e8 c5 ef ff ff       	call   800a1f <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	68 51 33 80 00       	push   $0x803351
  801a62:	57                   	push   %edi
  801a63:	e8 56 fc ff ff       	call   8016be <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801a68:	83 c4 08             	add    $0x8,%esp
  801a6b:	6a 02                	push   $0x2
  801a6d:	57                   	push   %edi
  801a6e:	e8 c7 fb ff ff       	call   80163a <sys_env_set_status>
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	79 15                	jns    801a8f <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  801a7a:	50                   	push   %eax
  801a7b:	68 36 3d 80 00       	push   $0x803d36
  801a80:	68 8c 00 00 00       	push   $0x8c
  801a85:	68 cd 3c 80 00       	push   $0x803ccd
  801a8a:	e8 90 ef ff ff       	call   800a1f <_panic>

	return envid;
  801a8f:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  801a91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5f                   	pop    %edi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <sfork>:

// Challenge!
int
sfork(void)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a9f:	68 4f 3d 80 00       	push   $0x803d4f
  801aa4:	68 98 00 00 00       	push   $0x98
  801aa9:	68 cd 3c 80 00       	push   $0x803ccd
  801aae:	e8 6c ef ff ff       	call   800a1f <_panic>

00801ab3 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abc:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801abf:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801ac1:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ac4:	83 3a 01             	cmpl   $0x1,(%edx)
  801ac7:	7e 09                	jle    801ad2 <argstart+0x1f>
  801ac9:	ba 61 37 80 00       	mov    $0x803761,%edx
  801ace:	85 c9                	test   %ecx,%ecx
  801ad0:	75 05                	jne    801ad7 <argstart+0x24>
  801ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad7:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801ada:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    

00801ae3 <argnext>:

int
argnext(struct Argstate *args)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 04             	sub    $0x4,%esp
  801aea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801aed:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801af4:	8b 43 08             	mov    0x8(%ebx),%eax
  801af7:	85 c0                	test   %eax,%eax
  801af9:	74 6f                	je     801b6a <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801afb:	80 38 00             	cmpb   $0x0,(%eax)
  801afe:	75 4e                	jne    801b4e <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b00:	8b 0b                	mov    (%ebx),%ecx
  801b02:	83 39 01             	cmpl   $0x1,(%ecx)
  801b05:	74 55                	je     801b5c <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b07:	8b 53 04             	mov    0x4(%ebx),%edx
  801b0a:	8b 42 04             	mov    0x4(%edx),%eax
  801b0d:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b10:	75 4a                	jne    801b5c <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b12:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b16:	74 44                	je     801b5c <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b18:	83 c0 01             	add    $0x1,%eax
  801b1b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b1e:	83 ec 04             	sub    $0x4,%esp
  801b21:	8b 01                	mov    (%ecx),%eax
  801b23:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b2a:	50                   	push   %eax
  801b2b:	8d 42 08             	lea    0x8(%edx),%eax
  801b2e:	50                   	push   %eax
  801b2f:	83 c2 04             	add    $0x4,%edx
  801b32:	52                   	push   %edx
  801b33:	e8 ca f7 ff ff       	call   801302 <memmove>
		(*args->argc)--;
  801b38:	8b 03                	mov    (%ebx),%eax
  801b3a:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b3d:	8b 43 08             	mov    0x8(%ebx),%eax
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b46:	75 06                	jne    801b4e <argnext+0x6b>
  801b48:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b4c:	74 0e                	je     801b5c <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b4e:	8b 53 08             	mov    0x8(%ebx),%edx
  801b51:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b54:	83 c2 01             	add    $0x1,%edx
  801b57:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b5a:	eb 13                	jmp    801b6f <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b5c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b68:	eb 05                	jmp    801b6f <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	53                   	push   %ebx
  801b78:	83 ec 04             	sub    $0x4,%esp
  801b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b7e:	8b 43 08             	mov    0x8(%ebx),%eax
  801b81:	85 c0                	test   %eax,%eax
  801b83:	74 58                	je     801bdd <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b85:	80 38 00             	cmpb   $0x0,(%eax)
  801b88:	74 0c                	je     801b96 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b8a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b8d:	c7 43 08 61 37 80 00 	movl   $0x803761,0x8(%ebx)
  801b94:	eb 42                	jmp    801bd8 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b96:	8b 13                	mov    (%ebx),%edx
  801b98:	83 3a 01             	cmpl   $0x1,(%edx)
  801b9b:	7e 2d                	jle    801bca <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b9d:	8b 43 04             	mov    0x4(%ebx),%eax
  801ba0:	8b 48 04             	mov    0x4(%eax),%ecx
  801ba3:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801ba6:	83 ec 04             	sub    $0x4,%esp
  801ba9:	8b 12                	mov    (%edx),%edx
  801bab:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bb2:	52                   	push   %edx
  801bb3:	8d 50 08             	lea    0x8(%eax),%edx
  801bb6:	52                   	push   %edx
  801bb7:	83 c0 04             	add    $0x4,%eax
  801bba:	50                   	push   %eax
  801bbb:	e8 42 f7 ff ff       	call   801302 <memmove>
		(*args->argc)--;
  801bc0:	8b 03                	mov    (%ebx),%eax
  801bc2:	83 28 01             	subl   $0x1,(%eax)
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	eb 0e                	jmp    801bd8 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801bca:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bd1:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bd8:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bdb:	eb 05                	jmp    801be2 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bdd:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 08             	sub    $0x8,%esp
  801bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bf0:	8b 51 0c             	mov    0xc(%ecx),%edx
  801bf3:	89 d0                	mov    %edx,%eax
  801bf5:	85 d2                	test   %edx,%edx
  801bf7:	75 0c                	jne    801c05 <argvalue+0x1e>
  801bf9:	83 ec 0c             	sub    $0xc,%esp
  801bfc:	51                   	push   %ecx
  801bfd:	e8 72 ff ff ff       	call   801b74 <argnextvalue>
  801c02:	83 c4 10             	add    $0x10,%esp
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	05 00 00 00 30       	add    $0x30000000,%eax
  801c12:	c1 e8 0c             	shr    $0xc,%eax
}
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	05 00 00 00 30       	add    $0x30000000,%eax
  801c22:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c27:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c34:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c39:	89 c2                	mov    %eax,%edx
  801c3b:	c1 ea 16             	shr    $0x16,%edx
  801c3e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c45:	f6 c2 01             	test   $0x1,%dl
  801c48:	74 11                	je     801c5b <fd_alloc+0x2d>
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	c1 ea 0c             	shr    $0xc,%edx
  801c4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c56:	f6 c2 01             	test   $0x1,%dl
  801c59:	75 09                	jne    801c64 <fd_alloc+0x36>
			*fd_store = fd;
  801c5b:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c62:	eb 17                	jmp    801c7b <fd_alloc+0x4d>
  801c64:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c69:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c6e:	75 c9                	jne    801c39 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c70:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c76:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    

00801c7d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c83:	83 f8 1f             	cmp    $0x1f,%eax
  801c86:	77 36                	ja     801cbe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c88:	c1 e0 0c             	shl    $0xc,%eax
  801c8b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c90:	89 c2                	mov    %eax,%edx
  801c92:	c1 ea 16             	shr    $0x16,%edx
  801c95:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c9c:	f6 c2 01             	test   $0x1,%dl
  801c9f:	74 24                	je     801cc5 <fd_lookup+0x48>
  801ca1:	89 c2                	mov    %eax,%edx
  801ca3:	c1 ea 0c             	shr    $0xc,%edx
  801ca6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cad:	f6 c2 01             	test   $0x1,%dl
  801cb0:	74 1a                	je     801ccc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb5:	89 02                	mov    %eax,(%edx)
	return 0;
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbc:	eb 13                	jmp    801cd1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cc3:	eb 0c                	jmp    801cd1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cca:	eb 05                	jmp    801cd1 <fd_lookup+0x54>
  801ccc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	83 ec 08             	sub    $0x8,%esp
  801cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdc:	ba 90 3e 80 00       	mov    $0x803e90,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801ce1:	eb 13                	jmp    801cf6 <dev_lookup+0x23>
  801ce3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801ce6:	39 08                	cmp    %ecx,(%eax)
  801ce8:	75 0c                	jne    801cf6 <dev_lookup+0x23>
			*dev = devtab[i];
  801cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ced:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cef:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf4:	eb 2e                	jmp    801d24 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cf6:	8b 02                	mov    (%edx),%eax
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	75 e7                	jne    801ce3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cfc:	a1 28 64 80 00       	mov    0x806428,%eax
  801d01:	8b 40 48             	mov    0x48(%eax),%eax
  801d04:	83 ec 04             	sub    $0x4,%esp
  801d07:	51                   	push   %ecx
  801d08:	50                   	push   %eax
  801d09:	68 14 3e 80 00       	push   $0x803e14
  801d0e:	e8 e5 ed ff ff       	call   800af8 <cprintf>
	*dev = 0;
  801d13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	56                   	push   %esi
  801d2a:	53                   	push   %ebx
  801d2b:	83 ec 10             	sub    $0x10,%esp
  801d2e:	8b 75 08             	mov    0x8(%ebp),%esi
  801d31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d37:	50                   	push   %eax
  801d38:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d3e:	c1 e8 0c             	shr    $0xc,%eax
  801d41:	50                   	push   %eax
  801d42:	e8 36 ff ff ff       	call   801c7d <fd_lookup>
  801d47:	83 c4 08             	add    $0x8,%esp
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 05                	js     801d53 <fd_close+0x2d>
	    || fd != fd2)
  801d4e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d51:	74 0c                	je     801d5f <fd_close+0x39>
		return (must_exist ? r : 0);
  801d53:	84 db                	test   %bl,%bl
  801d55:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5a:	0f 44 c2             	cmove  %edx,%eax
  801d5d:	eb 41                	jmp    801da0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d5f:	83 ec 08             	sub    $0x8,%esp
  801d62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d65:	50                   	push   %eax
  801d66:	ff 36                	pushl  (%esi)
  801d68:	e8 66 ff ff ff       	call   801cd3 <dev_lookup>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	78 1a                	js     801d90 <fd_close+0x6a>
		if (dev->dev_close)
  801d76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d79:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d81:	85 c0                	test   %eax,%eax
  801d83:	74 0b                	je     801d90 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	56                   	push   %esi
  801d89:	ff d0                	call   *%eax
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d90:	83 ec 08             	sub    $0x8,%esp
  801d93:	56                   	push   %esi
  801d94:	6a 00                	push   $0x0
  801d96:	e8 5d f8 ff ff       	call   8015f8 <sys_page_unmap>
	return r;
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	89 d8                	mov    %ebx,%eax
}
  801da0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db0:	50                   	push   %eax
  801db1:	ff 75 08             	pushl  0x8(%ebp)
  801db4:	e8 c4 fe ff ff       	call   801c7d <fd_lookup>
  801db9:	83 c4 08             	add    $0x8,%esp
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 10                	js     801dd0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	6a 01                	push   $0x1
  801dc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc8:	e8 59 ff ff ff       	call   801d26 <fd_close>
  801dcd:	83 c4 10             	add    $0x10,%esp
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <close_all>:

void
close_all(void)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	53                   	push   %ebx
  801dd6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	53                   	push   %ebx
  801de2:	e8 c0 ff ff ff       	call   801da7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801de7:	83 c3 01             	add    $0x1,%ebx
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	83 fb 20             	cmp    $0x20,%ebx
  801df0:	75 ec                	jne    801dde <close_all+0xc>
		close(i);
}
  801df2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	57                   	push   %edi
  801dfb:	56                   	push   %esi
  801dfc:	53                   	push   %ebx
  801dfd:	83 ec 2c             	sub    $0x2c,%esp
  801e00:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e06:	50                   	push   %eax
  801e07:	ff 75 08             	pushl  0x8(%ebp)
  801e0a:	e8 6e fe ff ff       	call   801c7d <fd_lookup>
  801e0f:	83 c4 08             	add    $0x8,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	0f 88 c1 00 00 00    	js     801edb <dup+0xe4>
		return r;
	close(newfdnum);
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	56                   	push   %esi
  801e1e:	e8 84 ff ff ff       	call   801da7 <close>

	newfd = INDEX2FD(newfdnum);
  801e23:	89 f3                	mov    %esi,%ebx
  801e25:	c1 e3 0c             	shl    $0xc,%ebx
  801e28:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e2e:	83 c4 04             	add    $0x4,%esp
  801e31:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e34:	e8 de fd ff ff       	call   801c17 <fd2data>
  801e39:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e3b:	89 1c 24             	mov    %ebx,(%esp)
  801e3e:	e8 d4 fd ff ff       	call   801c17 <fd2data>
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e49:	89 f8                	mov    %edi,%eax
  801e4b:	c1 e8 16             	shr    $0x16,%eax
  801e4e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e55:	a8 01                	test   $0x1,%al
  801e57:	74 37                	je     801e90 <dup+0x99>
  801e59:	89 f8                	mov    %edi,%eax
  801e5b:	c1 e8 0c             	shr    $0xc,%eax
  801e5e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e65:	f6 c2 01             	test   $0x1,%dl
  801e68:	74 26                	je     801e90 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	25 07 0e 00 00       	and    $0xe07,%eax
  801e79:	50                   	push   %eax
  801e7a:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e7d:	6a 00                	push   $0x0
  801e7f:	57                   	push   %edi
  801e80:	6a 00                	push   $0x0
  801e82:	e8 2f f7 ff ff       	call   8015b6 <sys_page_map>
  801e87:	89 c7                	mov    %eax,%edi
  801e89:	83 c4 20             	add    $0x20,%esp
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 2e                	js     801ebe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e93:	89 d0                	mov    %edx,%eax
  801e95:	c1 e8 0c             	shr    $0xc,%eax
  801e98:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	25 07 0e 00 00       	and    $0xe07,%eax
  801ea7:	50                   	push   %eax
  801ea8:	53                   	push   %ebx
  801ea9:	6a 00                	push   $0x0
  801eab:	52                   	push   %edx
  801eac:	6a 00                	push   $0x0
  801eae:	e8 03 f7 ff ff       	call   8015b6 <sys_page_map>
  801eb3:	89 c7                	mov    %eax,%edi
  801eb5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801eb8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801eba:	85 ff                	test   %edi,%edi
  801ebc:	79 1d                	jns    801edb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ebe:	83 ec 08             	sub    $0x8,%esp
  801ec1:	53                   	push   %ebx
  801ec2:	6a 00                	push   $0x0
  801ec4:	e8 2f f7 ff ff       	call   8015f8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ec9:	83 c4 08             	add    $0x8,%esp
  801ecc:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ecf:	6a 00                	push   $0x0
  801ed1:	e8 22 f7 ff ff       	call   8015f8 <sys_page_unmap>
	return r;
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	89 f8                	mov    %edi,%eax
}
  801edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    

00801ee3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	53                   	push   %ebx
  801ee7:	83 ec 14             	sub    $0x14,%esp
  801eea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ef0:	50                   	push   %eax
  801ef1:	53                   	push   %ebx
  801ef2:	e8 86 fd ff ff       	call   801c7d <fd_lookup>
  801ef7:	83 c4 08             	add    $0x8,%esp
  801efa:	89 c2                	mov    %eax,%edx
  801efc:	85 c0                	test   %eax,%eax
  801efe:	78 6d                	js     801f6d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f00:	83 ec 08             	sub    $0x8,%esp
  801f03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f06:	50                   	push   %eax
  801f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0a:	ff 30                	pushl  (%eax)
  801f0c:	e8 c2 fd ff ff       	call   801cd3 <dev_lookup>
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 4c                	js     801f64 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f1b:	8b 42 08             	mov    0x8(%edx),%eax
  801f1e:	83 e0 03             	and    $0x3,%eax
  801f21:	83 f8 01             	cmp    $0x1,%eax
  801f24:	75 21                	jne    801f47 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f26:	a1 28 64 80 00       	mov    0x806428,%eax
  801f2b:	8b 40 48             	mov    0x48(%eax),%eax
  801f2e:	83 ec 04             	sub    $0x4,%esp
  801f31:	53                   	push   %ebx
  801f32:	50                   	push   %eax
  801f33:	68 55 3e 80 00       	push   $0x803e55
  801f38:	e8 bb eb ff ff       	call   800af8 <cprintf>
		return -E_INVAL;
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f45:	eb 26                	jmp    801f6d <read+0x8a>
	}
	if (!dev->dev_read)
  801f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4a:	8b 40 08             	mov    0x8(%eax),%eax
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	74 17                	je     801f68 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f51:	83 ec 04             	sub    $0x4,%esp
  801f54:	ff 75 10             	pushl  0x10(%ebp)
  801f57:	ff 75 0c             	pushl  0xc(%ebp)
  801f5a:	52                   	push   %edx
  801f5b:	ff d0                	call   *%eax
  801f5d:	89 c2                	mov    %eax,%edx
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	eb 09                	jmp    801f6d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f64:	89 c2                	mov    %eax,%edx
  801f66:	eb 05                	jmp    801f6d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f68:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f6d:	89 d0                	mov    %edx,%eax
  801f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f72:	c9                   	leave  
  801f73:	c3                   	ret    

00801f74 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	57                   	push   %edi
  801f78:	56                   	push   %esi
  801f79:	53                   	push   %ebx
  801f7a:	83 ec 0c             	sub    $0xc,%esp
  801f7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f80:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f83:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f88:	eb 21                	jmp    801fab <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f8a:	83 ec 04             	sub    $0x4,%esp
  801f8d:	89 f0                	mov    %esi,%eax
  801f8f:	29 d8                	sub    %ebx,%eax
  801f91:	50                   	push   %eax
  801f92:	89 d8                	mov    %ebx,%eax
  801f94:	03 45 0c             	add    0xc(%ebp),%eax
  801f97:	50                   	push   %eax
  801f98:	57                   	push   %edi
  801f99:	e8 45 ff ff ff       	call   801ee3 <read>
		if (m < 0)
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	78 10                	js     801fb5 <readn+0x41>
			return m;
		if (m == 0)
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	74 0a                	je     801fb3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fa9:	01 c3                	add    %eax,%ebx
  801fab:	39 f3                	cmp    %esi,%ebx
  801fad:	72 db                	jb     801f8a <readn+0x16>
  801faf:	89 d8                	mov    %ebx,%eax
  801fb1:	eb 02                	jmp    801fb5 <readn+0x41>
  801fb3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5f                   	pop    %edi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    

00801fbd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	53                   	push   %ebx
  801fc1:	83 ec 14             	sub    $0x14,%esp
  801fc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fca:	50                   	push   %eax
  801fcb:	53                   	push   %ebx
  801fcc:	e8 ac fc ff ff       	call   801c7d <fd_lookup>
  801fd1:	83 c4 08             	add    $0x8,%esp
  801fd4:	89 c2                	mov    %eax,%edx
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	78 68                	js     802042 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fda:	83 ec 08             	sub    $0x8,%esp
  801fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe4:	ff 30                	pushl  (%eax)
  801fe6:	e8 e8 fc ff ff       	call   801cd3 <dev_lookup>
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	78 47                	js     802039 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ff9:	75 21                	jne    80201c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ffb:	a1 28 64 80 00       	mov    0x806428,%eax
  802000:	8b 40 48             	mov    0x48(%eax),%eax
  802003:	83 ec 04             	sub    $0x4,%esp
  802006:	53                   	push   %ebx
  802007:	50                   	push   %eax
  802008:	68 71 3e 80 00       	push   $0x803e71
  80200d:	e8 e6 ea ff ff       	call   800af8 <cprintf>
		return -E_INVAL;
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80201a:	eb 26                	jmp    802042 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80201c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80201f:	8b 52 0c             	mov    0xc(%edx),%edx
  802022:	85 d2                	test   %edx,%edx
  802024:	74 17                	je     80203d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802026:	83 ec 04             	sub    $0x4,%esp
  802029:	ff 75 10             	pushl  0x10(%ebp)
  80202c:	ff 75 0c             	pushl  0xc(%ebp)
  80202f:	50                   	push   %eax
  802030:	ff d2                	call   *%edx
  802032:	89 c2                	mov    %eax,%edx
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	eb 09                	jmp    802042 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802039:	89 c2                	mov    %eax,%edx
  80203b:	eb 05                	jmp    802042 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80203d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802042:	89 d0                	mov    %edx,%eax
  802044:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802047:	c9                   	leave  
  802048:	c3                   	ret    

00802049 <seek>:

int
seek(int fdnum, off_t offset)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802052:	50                   	push   %eax
  802053:	ff 75 08             	pushl  0x8(%ebp)
  802056:	e8 22 fc ff ff       	call   801c7d <fd_lookup>
  80205b:	83 c4 08             	add    $0x8,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	78 0e                	js     802070 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802062:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802065:	8b 55 0c             	mov    0xc(%ebp),%edx
  802068:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80206b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	53                   	push   %ebx
  802076:	83 ec 14             	sub    $0x14,%esp
  802079:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80207c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80207f:	50                   	push   %eax
  802080:	53                   	push   %ebx
  802081:	e8 f7 fb ff ff       	call   801c7d <fd_lookup>
  802086:	83 c4 08             	add    $0x8,%esp
  802089:	89 c2                	mov    %eax,%edx
  80208b:	85 c0                	test   %eax,%eax
  80208d:	78 65                	js     8020f4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80208f:	83 ec 08             	sub    $0x8,%esp
  802092:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802095:	50                   	push   %eax
  802096:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802099:	ff 30                	pushl  (%eax)
  80209b:	e8 33 fc ff ff       	call   801cd3 <dev_lookup>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 44                	js     8020eb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020ae:	75 21                	jne    8020d1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020b0:	a1 28 64 80 00       	mov    0x806428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020b5:	8b 40 48             	mov    0x48(%eax),%eax
  8020b8:	83 ec 04             	sub    $0x4,%esp
  8020bb:	53                   	push   %ebx
  8020bc:	50                   	push   %eax
  8020bd:	68 34 3e 80 00       	push   $0x803e34
  8020c2:	e8 31 ea ff ff       	call   800af8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020c7:	83 c4 10             	add    $0x10,%esp
  8020ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020cf:	eb 23                	jmp    8020f4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d4:	8b 52 18             	mov    0x18(%edx),%edx
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	74 14                	je     8020ef <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020db:	83 ec 08             	sub    $0x8,%esp
  8020de:	ff 75 0c             	pushl  0xc(%ebp)
  8020e1:	50                   	push   %eax
  8020e2:	ff d2                	call   *%edx
  8020e4:	89 c2                	mov    %eax,%edx
  8020e6:	83 c4 10             	add    $0x10,%esp
  8020e9:	eb 09                	jmp    8020f4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020eb:	89 c2                	mov    %eax,%edx
  8020ed:	eb 05                	jmp    8020f4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020f4:	89 d0                	mov    %edx,%eax
  8020f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020f9:	c9                   	leave  
  8020fa:	c3                   	ret    

008020fb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	53                   	push   %ebx
  8020ff:	83 ec 14             	sub    $0x14,%esp
  802102:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802105:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802108:	50                   	push   %eax
  802109:	ff 75 08             	pushl  0x8(%ebp)
  80210c:	e8 6c fb ff ff       	call   801c7d <fd_lookup>
  802111:	83 c4 08             	add    $0x8,%esp
  802114:	89 c2                	mov    %eax,%edx
  802116:	85 c0                	test   %eax,%eax
  802118:	78 58                	js     802172 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80211a:	83 ec 08             	sub    $0x8,%esp
  80211d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802120:	50                   	push   %eax
  802121:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802124:	ff 30                	pushl  (%eax)
  802126:	e8 a8 fb ff ff       	call   801cd3 <dev_lookup>
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	85 c0                	test   %eax,%eax
  802130:	78 37                	js     802169 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802135:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802139:	74 32                	je     80216d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80213b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80213e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802145:	00 00 00 
	stat->st_isdir = 0;
  802148:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80214f:	00 00 00 
	stat->st_dev = dev;
  802152:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802158:	83 ec 08             	sub    $0x8,%esp
  80215b:	53                   	push   %ebx
  80215c:	ff 75 f0             	pushl  -0x10(%ebp)
  80215f:	ff 50 14             	call   *0x14(%eax)
  802162:	89 c2                	mov    %eax,%edx
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	eb 09                	jmp    802172 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802169:	89 c2                	mov    %eax,%edx
  80216b:	eb 05                	jmp    802172 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80216d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802172:	89 d0                	mov    %edx,%eax
  802174:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802177:	c9                   	leave  
  802178:	c3                   	ret    

00802179 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802179:	55                   	push   %ebp
  80217a:	89 e5                	mov    %esp,%ebp
  80217c:	56                   	push   %esi
  80217d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80217e:	83 ec 08             	sub    $0x8,%esp
  802181:	6a 00                	push   $0x0
  802183:	ff 75 08             	pushl  0x8(%ebp)
  802186:	e8 e7 01 00 00       	call   802372 <open>
  80218b:	89 c3                	mov    %eax,%ebx
  80218d:	83 c4 10             	add    $0x10,%esp
  802190:	85 c0                	test   %eax,%eax
  802192:	78 1b                	js     8021af <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802194:	83 ec 08             	sub    $0x8,%esp
  802197:	ff 75 0c             	pushl  0xc(%ebp)
  80219a:	50                   	push   %eax
  80219b:	e8 5b ff ff ff       	call   8020fb <fstat>
  8021a0:	89 c6                	mov    %eax,%esi
	close(fd);
  8021a2:	89 1c 24             	mov    %ebx,(%esp)
  8021a5:	e8 fd fb ff ff       	call   801da7 <close>
	return r;
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	89 f0                	mov    %esi,%eax
}
  8021af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b2:	5b                   	pop    %ebx
  8021b3:	5e                   	pop    %esi
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    

008021b6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	56                   	push   %esi
  8021ba:	53                   	push   %ebx
  8021bb:	89 c6                	mov    %eax,%esi
  8021bd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021bf:	83 3d 20 64 80 00 00 	cmpl   $0x0,0x806420
  8021c6:	75 12                	jne    8021da <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021c8:	83 ec 0c             	sub    $0xc,%esp
  8021cb:	6a 01                	push   $0x1
  8021cd:	e8 64 12 00 00       	call   803436 <ipc_find_env>
  8021d2:	a3 20 64 80 00       	mov    %eax,0x806420
  8021d7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021da:	6a 07                	push   $0x7
  8021dc:	68 00 70 80 00       	push   $0x807000
  8021e1:	56                   	push   %esi
  8021e2:	ff 35 20 64 80 00    	pushl  0x806420
  8021e8:	e8 f5 11 00 00       	call   8033e2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021ed:	83 c4 0c             	add    $0xc,%esp
  8021f0:	6a 00                	push   $0x0
  8021f2:	53                   	push   %ebx
  8021f3:	6a 00                	push   $0x0
  8021f5:	e8 7b 11 00 00       	call   803375 <ipc_recv>
}
  8021fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5d                   	pop    %ebp
  802200:	c3                   	ret    

00802201 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802207:	8b 45 08             	mov    0x8(%ebp),%eax
  80220a:	8b 40 0c             	mov    0xc(%eax),%eax
  80220d:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  802212:	8b 45 0c             	mov    0xc(%ebp),%eax
  802215:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80221a:	ba 00 00 00 00       	mov    $0x0,%edx
  80221f:	b8 02 00 00 00       	mov    $0x2,%eax
  802224:	e8 8d ff ff ff       	call   8021b6 <fsipc>
}
  802229:	c9                   	leave  
  80222a:	c3                   	ret    

0080222b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802231:	8b 45 08             	mov    0x8(%ebp),%eax
  802234:	8b 40 0c             	mov    0xc(%eax),%eax
  802237:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80223c:	ba 00 00 00 00       	mov    $0x0,%edx
  802241:	b8 06 00 00 00       	mov    $0x6,%eax
  802246:	e8 6b ff ff ff       	call   8021b6 <fsipc>
}
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	53                   	push   %ebx
  802251:	83 ec 04             	sub    $0x4,%esp
  802254:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802257:	8b 45 08             	mov    0x8(%ebp),%eax
  80225a:	8b 40 0c             	mov    0xc(%eax),%eax
  80225d:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802262:	ba 00 00 00 00       	mov    $0x0,%edx
  802267:	b8 05 00 00 00       	mov    $0x5,%eax
  80226c:	e8 45 ff ff ff       	call   8021b6 <fsipc>
  802271:	85 c0                	test   %eax,%eax
  802273:	78 2c                	js     8022a1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802275:	83 ec 08             	sub    $0x8,%esp
  802278:	68 00 70 80 00       	push   $0x807000
  80227d:	53                   	push   %ebx
  80227e:	e8 ed ee ff ff       	call   801170 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802283:	a1 80 70 80 00       	mov    0x807080,%eax
  802288:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80228e:	a1 84 70 80 00       	mov    0x807084,%eax
  802293:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802299:	83 c4 10             	add    $0x10,%esp
  80229c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022a4:	c9                   	leave  
  8022a5:	c3                   	ret    

008022a6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	53                   	push   %ebx
  8022aa:	83 ec 08             	sub    $0x8,%esp
  8022ad:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8022b0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8022b5:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8022ba:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8022bd:	53                   	push   %ebx
  8022be:	ff 75 0c             	pushl  0xc(%ebp)
  8022c1:	68 08 70 80 00       	push   $0x807008
  8022c6:	e8 37 f0 ff ff       	call   801302 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8022d1:	a3 00 70 80 00       	mov    %eax,0x807000
 	fsipcbuf.write.req_n = n;
  8022d6:	89 1d 04 70 80 00    	mov    %ebx,0x807004

 	return fsipc(FSREQ_WRITE, NULL);
  8022dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e1:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e6:	e8 cb fe ff ff       	call   8021b6 <fsipc>
	//panic("devfile_write not implemented");
}
  8022eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    

008022f0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	56                   	push   %esi
  8022f4:	53                   	push   %ebx
  8022f5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8022fe:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  802303:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802309:	ba 00 00 00 00       	mov    $0x0,%edx
  80230e:	b8 03 00 00 00       	mov    $0x3,%eax
  802313:	e8 9e fe ff ff       	call   8021b6 <fsipc>
  802318:	89 c3                	mov    %eax,%ebx
  80231a:	85 c0                	test   %eax,%eax
  80231c:	78 4b                	js     802369 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80231e:	39 c6                	cmp    %eax,%esi
  802320:	73 16                	jae    802338 <devfile_read+0x48>
  802322:	68 a4 3e 80 00       	push   $0x803ea4
  802327:	68 90 38 80 00       	push   $0x803890
  80232c:	6a 7c                	push   $0x7c
  80232e:	68 ab 3e 80 00       	push   $0x803eab
  802333:	e8 e7 e6 ff ff       	call   800a1f <_panic>
	assert(r <= PGSIZE);
  802338:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80233d:	7e 16                	jle    802355 <devfile_read+0x65>
  80233f:	68 b6 3e 80 00       	push   $0x803eb6
  802344:	68 90 38 80 00       	push   $0x803890
  802349:	6a 7d                	push   $0x7d
  80234b:	68 ab 3e 80 00       	push   $0x803eab
  802350:	e8 ca e6 ff ff       	call   800a1f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802355:	83 ec 04             	sub    $0x4,%esp
  802358:	50                   	push   %eax
  802359:	68 00 70 80 00       	push   $0x807000
  80235e:	ff 75 0c             	pushl  0xc(%ebp)
  802361:	e8 9c ef ff ff       	call   801302 <memmove>
	return r;
  802366:	83 c4 10             	add    $0x10,%esp
}
  802369:	89 d8                	mov    %ebx,%eax
  80236b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80236e:	5b                   	pop    %ebx
  80236f:	5e                   	pop    %esi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    

00802372 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802372:	55                   	push   %ebp
  802373:	89 e5                	mov    %esp,%ebp
  802375:	53                   	push   %ebx
  802376:	83 ec 20             	sub    $0x20,%esp
  802379:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80237c:	53                   	push   %ebx
  80237d:	e8 b5 ed ff ff       	call   801137 <strlen>
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80238a:	7f 67                	jg     8023f3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80238c:	83 ec 0c             	sub    $0xc,%esp
  80238f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802392:	50                   	push   %eax
  802393:	e8 96 f8 ff ff       	call   801c2e <fd_alloc>
  802398:	83 c4 10             	add    $0x10,%esp
		return r;
  80239b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80239d:	85 c0                	test   %eax,%eax
  80239f:	78 57                	js     8023f8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8023a1:	83 ec 08             	sub    $0x8,%esp
  8023a4:	53                   	push   %ebx
  8023a5:	68 00 70 80 00       	push   $0x807000
  8023aa:	e8 c1 ed ff ff       	call   801170 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b2:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bf:	e8 f2 fd ff ff       	call   8021b6 <fsipc>
  8023c4:	89 c3                	mov    %eax,%ebx
  8023c6:	83 c4 10             	add    $0x10,%esp
  8023c9:	85 c0                	test   %eax,%eax
  8023cb:	79 14                	jns    8023e1 <open+0x6f>
		fd_close(fd, 0);
  8023cd:	83 ec 08             	sub    $0x8,%esp
  8023d0:	6a 00                	push   $0x0
  8023d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8023d5:	e8 4c f9 ff ff       	call   801d26 <fd_close>
		return r;
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	89 da                	mov    %ebx,%edx
  8023df:	eb 17                	jmp    8023f8 <open+0x86>
	}

	return fd2num(fd);
  8023e1:	83 ec 0c             	sub    $0xc,%esp
  8023e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e7:	e8 1b f8 ff ff       	call   801c07 <fd2num>
  8023ec:	89 c2                	mov    %eax,%edx
  8023ee:	83 c4 10             	add    $0x10,%esp
  8023f1:	eb 05                	jmp    8023f8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023f3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023f8:	89 d0                	mov    %edx,%eax
  8023fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023fd:	c9                   	leave  
  8023fe:	c3                   	ret    

008023ff <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802405:	ba 00 00 00 00       	mov    $0x0,%edx
  80240a:	b8 08 00 00 00       	mov    $0x8,%eax
  80240f:	e8 a2 fd ff ff       	call   8021b6 <fsipc>
}
  802414:	c9                   	leave  
  802415:	c3                   	ret    

00802416 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802416:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80241a:	7e 37                	jle    802453 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80241c:	55                   	push   %ebp
  80241d:	89 e5                	mov    %esp,%ebp
  80241f:	53                   	push   %ebx
  802420:	83 ec 08             	sub    $0x8,%esp
  802423:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802425:	ff 70 04             	pushl  0x4(%eax)
  802428:	8d 40 10             	lea    0x10(%eax),%eax
  80242b:	50                   	push   %eax
  80242c:	ff 33                	pushl  (%ebx)
  80242e:	e8 8a fb ff ff       	call   801fbd <write>
		if (result > 0)
  802433:	83 c4 10             	add    $0x10,%esp
  802436:	85 c0                	test   %eax,%eax
  802438:	7e 03                	jle    80243d <writebuf+0x27>
			b->result += result;
  80243a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80243d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802440:	74 0d                	je     80244f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802442:	85 c0                	test   %eax,%eax
  802444:	ba 00 00 00 00       	mov    $0x0,%edx
  802449:	0f 4f c2             	cmovg  %edx,%eax
  80244c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80244f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802452:	c9                   	leave  
  802453:	f3 c3                	repz ret 

00802455 <putch>:

static void
putch(int ch, void *thunk)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	53                   	push   %ebx
  802459:	83 ec 04             	sub    $0x4,%esp
  80245c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80245f:	8b 53 04             	mov    0x4(%ebx),%edx
  802462:	8d 42 01             	lea    0x1(%edx),%eax
  802465:	89 43 04             	mov    %eax,0x4(%ebx)
  802468:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80246b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80246f:	3d 00 01 00 00       	cmp    $0x100,%eax
  802474:	75 0e                	jne    802484 <putch+0x2f>
		writebuf(b);
  802476:	89 d8                	mov    %ebx,%eax
  802478:	e8 99 ff ff ff       	call   802416 <writebuf>
		b->idx = 0;
  80247d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802484:	83 c4 04             	add    $0x4,%esp
  802487:	5b                   	pop    %ebx
  802488:	5d                   	pop    %ebp
  802489:	c3                   	ret    

0080248a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80248a:	55                   	push   %ebp
  80248b:	89 e5                	mov    %esp,%ebp
  80248d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802493:	8b 45 08             	mov    0x8(%ebp),%eax
  802496:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80249c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8024a3:	00 00 00 
	b.result = 0;
  8024a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024ad:	00 00 00 
	b.error = 1;
  8024b0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024b7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024ba:	ff 75 10             	pushl  0x10(%ebp)
  8024bd:	ff 75 0c             	pushl  0xc(%ebp)
  8024c0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024c6:	50                   	push   %eax
  8024c7:	68 55 24 80 00       	push   $0x802455
  8024cc:	e8 5e e7 ff ff       	call   800c2f <vprintfmt>
	if (b.idx > 0)
  8024d1:	83 c4 10             	add    $0x10,%esp
  8024d4:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024db:	7e 0b                	jle    8024e8 <vfprintf+0x5e>
		writebuf(&b);
  8024dd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024e3:	e8 2e ff ff ff       	call   802416 <writebuf>

	return (b.result ? b.result : b.error);
  8024e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024ee:	85 c0                	test   %eax,%eax
  8024f0:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024f7:	c9                   	leave  
  8024f8:	c3                   	ret    

008024f9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024f9:	55                   	push   %ebp
  8024fa:	89 e5                	mov    %esp,%ebp
  8024fc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024ff:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802502:	50                   	push   %eax
  802503:	ff 75 0c             	pushl  0xc(%ebp)
  802506:	ff 75 08             	pushl  0x8(%ebp)
  802509:	e8 7c ff ff ff       	call   80248a <vfprintf>
	va_end(ap);

	return cnt;
}
  80250e:	c9                   	leave  
  80250f:	c3                   	ret    

00802510 <printf>:

int
printf(const char *fmt, ...)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802516:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802519:	50                   	push   %eax
  80251a:	ff 75 08             	pushl  0x8(%ebp)
  80251d:	6a 01                	push   $0x1
  80251f:	e8 66 ff ff ff       	call   80248a <vfprintf>
	va_end(ap);

	return cnt;
}
  802524:	c9                   	leave  
  802525:	c3                   	ret    

00802526 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802526:	55                   	push   %ebp
  802527:	89 e5                	mov    %esp,%ebp
  802529:	57                   	push   %edi
  80252a:	56                   	push   %esi
  80252b:	53                   	push   %ebx
  80252c:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802532:	6a 00                	push   $0x0
  802534:	ff 75 08             	pushl  0x8(%ebp)
  802537:	e8 36 fe ff ff       	call   802372 <open>
  80253c:	89 c7                	mov    %eax,%edi
  80253e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802544:	83 c4 10             	add    $0x10,%esp
  802547:	85 c0                	test   %eax,%eax
  802549:	0f 88 a4 04 00 00    	js     8029f3 <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80254f:	83 ec 04             	sub    $0x4,%esp
  802552:	68 00 02 00 00       	push   $0x200
  802557:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80255d:	50                   	push   %eax
  80255e:	57                   	push   %edi
  80255f:	e8 10 fa ff ff       	call   801f74 <readn>
  802564:	83 c4 10             	add    $0x10,%esp
  802567:	3d 00 02 00 00       	cmp    $0x200,%eax
  80256c:	75 0c                	jne    80257a <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80256e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802575:	45 4c 46 
  802578:	74 33                	je     8025ad <spawn+0x87>
		close(fd);
  80257a:	83 ec 0c             	sub    $0xc,%esp
  80257d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802583:	e8 1f f8 ff ff       	call   801da7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802588:	83 c4 0c             	add    $0xc,%esp
  80258b:	68 7f 45 4c 46       	push   $0x464c457f
  802590:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802596:	68 c2 3e 80 00       	push   $0x803ec2
  80259b:	e8 58 e5 ff ff       	call   800af8 <cprintf>
		return -E_NOT_EXEC;
  8025a0:	83 c4 10             	add    $0x10,%esp
  8025a3:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8025a8:	e9 a6 04 00 00       	jmp    802a53 <spawn+0x52d>
  8025ad:	b8 07 00 00 00       	mov    $0x7,%eax
  8025b2:	cd 30                	int    $0x30
  8025b4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025ba:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025c0:	85 c0                	test   %eax,%eax
  8025c2:	0f 88 33 04 00 00    	js     8029fb <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025c8:	89 c6                	mov    %eax,%esi
  8025ca:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025d0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8025d3:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025d9:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025df:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025e6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025ec:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025f7:	be 00 00 00 00       	mov    $0x0,%esi
  8025fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025ff:	eb 13                	jmp    802614 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802601:	83 ec 0c             	sub    $0xc,%esp
  802604:	50                   	push   %eax
  802605:	e8 2d eb ff ff       	call   801137 <strlen>
  80260a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80260e:	83 c3 01             	add    $0x1,%ebx
  802611:	83 c4 10             	add    $0x10,%esp
  802614:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80261b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80261e:	85 c0                	test   %eax,%eax
  802620:	75 df                	jne    802601 <spawn+0xdb>
  802622:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802628:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80262e:	bf 00 10 40 00       	mov    $0x401000,%edi
  802633:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802635:	89 fa                	mov    %edi,%edx
  802637:	83 e2 fc             	and    $0xfffffffc,%edx
  80263a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802641:	29 c2                	sub    %eax,%edx
  802643:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802649:	8d 42 f8             	lea    -0x8(%edx),%eax
  80264c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802651:	0f 86 b4 03 00 00    	jbe    802a0b <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802657:	83 ec 04             	sub    $0x4,%esp
  80265a:	6a 07                	push   $0x7
  80265c:	68 00 00 40 00       	push   $0x400000
  802661:	6a 00                	push   $0x0
  802663:	e8 0b ef ff ff       	call   801573 <sys_page_alloc>
  802668:	83 c4 10             	add    $0x10,%esp
  80266b:	85 c0                	test   %eax,%eax
  80266d:	0f 88 9f 03 00 00    	js     802a12 <spawn+0x4ec>
  802673:	be 00 00 00 00       	mov    $0x0,%esi
  802678:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80267e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802681:	eb 30                	jmp    8026b3 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802683:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802689:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80268f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802692:	83 ec 08             	sub    $0x8,%esp
  802695:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802698:	57                   	push   %edi
  802699:	e8 d2 ea ff ff       	call   801170 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80269e:	83 c4 04             	add    $0x4,%esp
  8026a1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026a4:	e8 8e ea ff ff       	call   801137 <strlen>
  8026a9:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026ad:	83 c6 01             	add    $0x1,%esi
  8026b0:	83 c4 10             	add    $0x10,%esp
  8026b3:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8026b9:	7f c8                	jg     802683 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8026bb:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026c1:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026c7:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026ce:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026d4:	74 19                	je     8026ef <spawn+0x1c9>
  8026d6:	68 38 3f 80 00       	push   $0x803f38
  8026db:	68 90 38 80 00       	push   $0x803890
  8026e0:	68 f1 00 00 00       	push   $0xf1
  8026e5:	68 dc 3e 80 00       	push   $0x803edc
  8026ea:	e8 30 e3 ff ff       	call   800a1f <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026ef:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026f5:	89 f8                	mov    %edi,%eax
  8026f7:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026fc:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026ff:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802705:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802708:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80270e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802714:	83 ec 0c             	sub    $0xc,%esp
  802717:	6a 07                	push   $0x7
  802719:	68 00 d0 bf ee       	push   $0xeebfd000
  80271e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802724:	68 00 00 40 00       	push   $0x400000
  802729:	6a 00                	push   $0x0
  80272b:	e8 86 ee ff ff       	call   8015b6 <sys_page_map>
  802730:	89 c3                	mov    %eax,%ebx
  802732:	83 c4 20             	add    $0x20,%esp
  802735:	85 c0                	test   %eax,%eax
  802737:	0f 88 04 03 00 00    	js     802a41 <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80273d:	83 ec 08             	sub    $0x8,%esp
  802740:	68 00 00 40 00       	push   $0x400000
  802745:	6a 00                	push   $0x0
  802747:	e8 ac ee ff ff       	call   8015f8 <sys_page_unmap>
  80274c:	89 c3                	mov    %eax,%ebx
  80274e:	83 c4 10             	add    $0x10,%esp
  802751:	85 c0                	test   %eax,%eax
  802753:	0f 88 e8 02 00 00    	js     802a41 <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802759:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80275f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802766:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80276c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802773:	00 00 00 
  802776:	e9 88 01 00 00       	jmp    802903 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80277b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802781:	83 38 01             	cmpl   $0x1,(%eax)
  802784:	0f 85 6b 01 00 00    	jne    8028f5 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80278a:	89 c7                	mov    %eax,%edi
  80278c:	8b 40 18             	mov    0x18(%eax),%eax
  80278f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802795:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802798:	83 f8 01             	cmp    $0x1,%eax
  80279b:	19 c0                	sbb    %eax,%eax
  80279d:	83 e0 fe             	and    $0xfffffffe,%eax
  8027a0:	83 c0 07             	add    $0x7,%eax
  8027a3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027a9:	89 f8                	mov    %edi,%eax
  8027ab:	8b 7f 04             	mov    0x4(%edi),%edi
  8027ae:	89 f9                	mov    %edi,%ecx
  8027b0:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8027b6:	8b 78 10             	mov    0x10(%eax),%edi
  8027b9:	8b 50 14             	mov    0x14(%eax),%edx
  8027bc:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8027c2:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8027c5:	89 f0                	mov    %esi,%eax
  8027c7:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027cc:	74 14                	je     8027e2 <spawn+0x2bc>
		va -= i;
  8027ce:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027d0:	01 c2                	add    %eax,%edx
  8027d2:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8027d8:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027da:	29 c1                	sub    %eax,%ecx
  8027dc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027e7:	e9 f7 00 00 00       	jmp    8028e3 <spawn+0x3bd>
		if (i >= filesz) {
  8027ec:	39 df                	cmp    %ebx,%edi
  8027ee:	77 27                	ja     802817 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027f0:	83 ec 04             	sub    $0x4,%esp
  8027f3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027f9:	56                   	push   %esi
  8027fa:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802800:	e8 6e ed ff ff       	call   801573 <sys_page_alloc>
  802805:	83 c4 10             	add    $0x10,%esp
  802808:	85 c0                	test   %eax,%eax
  80280a:	0f 89 c7 00 00 00    	jns    8028d7 <spawn+0x3b1>
  802810:	89 c3                	mov    %eax,%ebx
  802812:	e9 09 02 00 00       	jmp    802a20 <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802817:	83 ec 04             	sub    $0x4,%esp
  80281a:	6a 07                	push   $0x7
  80281c:	68 00 00 40 00       	push   $0x400000
  802821:	6a 00                	push   $0x0
  802823:	e8 4b ed ff ff       	call   801573 <sys_page_alloc>
  802828:	83 c4 10             	add    $0x10,%esp
  80282b:	85 c0                	test   %eax,%eax
  80282d:	0f 88 e3 01 00 00    	js     802a16 <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802833:	83 ec 08             	sub    $0x8,%esp
  802836:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80283c:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802842:	50                   	push   %eax
  802843:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802849:	e8 fb f7 ff ff       	call   802049 <seek>
  80284e:	83 c4 10             	add    $0x10,%esp
  802851:	85 c0                	test   %eax,%eax
  802853:	0f 88 c1 01 00 00    	js     802a1a <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802859:	83 ec 04             	sub    $0x4,%esp
  80285c:	89 f8                	mov    %edi,%eax
  80285e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802864:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802869:	ba 00 10 00 00       	mov    $0x1000,%edx
  80286e:	0f 47 c2             	cmova  %edx,%eax
  802871:	50                   	push   %eax
  802872:	68 00 00 40 00       	push   $0x400000
  802877:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80287d:	e8 f2 f6 ff ff       	call   801f74 <readn>
  802882:	83 c4 10             	add    $0x10,%esp
  802885:	85 c0                	test   %eax,%eax
  802887:	0f 88 91 01 00 00    	js     802a1e <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80288d:	83 ec 0c             	sub    $0xc,%esp
  802890:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802896:	56                   	push   %esi
  802897:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80289d:	68 00 00 40 00       	push   $0x400000
  8028a2:	6a 00                	push   $0x0
  8028a4:	e8 0d ed ff ff       	call   8015b6 <sys_page_map>
  8028a9:	83 c4 20             	add    $0x20,%esp
  8028ac:	85 c0                	test   %eax,%eax
  8028ae:	79 15                	jns    8028c5 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8028b0:	50                   	push   %eax
  8028b1:	68 e8 3e 80 00       	push   $0x803ee8
  8028b6:	68 24 01 00 00       	push   $0x124
  8028bb:	68 dc 3e 80 00       	push   $0x803edc
  8028c0:	e8 5a e1 ff ff       	call   800a1f <_panic>
			sys_page_unmap(0, UTEMP);
  8028c5:	83 ec 08             	sub    $0x8,%esp
  8028c8:	68 00 00 40 00       	push   $0x400000
  8028cd:	6a 00                	push   $0x0
  8028cf:	e8 24 ed ff ff       	call   8015f8 <sys_page_unmap>
  8028d4:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028d7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028dd:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028e3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028e9:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8028ef:	0f 87 f7 fe ff ff    	ja     8027ec <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028f5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028fc:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802903:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80290a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802910:	0f 8c 65 fe ff ff    	jl     80277b <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802916:	83 ec 0c             	sub    $0xc,%esp
  802919:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80291f:	e8 83 f4 ff ff       	call   801da7 <close>
  802924:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  802927:	bb 00 00 00 00       	mov    $0x0,%ebx
  80292c:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
 	{
    	if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)) {
  802932:	89 d8                	mov    %ebx,%eax
  802934:	c1 e8 16             	shr    $0x16,%eax
  802937:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80293e:	a8 01                	test   $0x1,%al
  802940:	74 46                	je     802988 <spawn+0x462>
  802942:	89 d8                	mov    %ebx,%eax
  802944:	c1 e8 0c             	shr    $0xc,%eax
  802947:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80294e:	f6 c2 01             	test   $0x1,%dl
  802951:	74 35                	je     802988 <spawn+0x462>
  802953:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80295a:	f6 c2 04             	test   $0x4,%dl
  80295d:	74 29                	je     802988 <spawn+0x462>
  80295f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802966:	f6 c6 04             	test   $0x4,%dh
  802969:	74 1d                	je     802988 <spawn+0x462>
        	sys_page_map(0, (void*)i, child, (void*)i, (uvpt[PGNUM(i)] & PTE_SYSCALL));
  80296b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802972:	83 ec 0c             	sub    $0xc,%esp
  802975:	25 07 0e 00 00       	and    $0xe07,%eax
  80297a:	50                   	push   %eax
  80297b:	53                   	push   %ebx
  80297c:	56                   	push   %esi
  80297d:	53                   	push   %ebx
  80297e:	6a 00                	push   $0x0
  802980:	e8 31 ec ff ff       	call   8015b6 <sys_page_map>
  802985:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  802988:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80298e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802994:	75 9c                	jne    802932 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802996:	83 ec 08             	sub    $0x8,%esp
  802999:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80299f:	50                   	push   %eax
  8029a0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029a6:	e8 d1 ec ff ff       	call   80167c <sys_env_set_trapframe>
  8029ab:	83 c4 10             	add    $0x10,%esp
  8029ae:	85 c0                	test   %eax,%eax
  8029b0:	79 15                	jns    8029c7 <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  8029b2:	50                   	push   %eax
  8029b3:	68 05 3f 80 00       	push   $0x803f05
  8029b8:	68 85 00 00 00       	push   $0x85
  8029bd:	68 dc 3e 80 00       	push   $0x803edc
  8029c2:	e8 58 e0 ff ff       	call   800a1f <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029c7:	83 ec 08             	sub    $0x8,%esp
  8029ca:	6a 02                	push   $0x2
  8029cc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029d2:	e8 63 ec ff ff       	call   80163a <sys_env_set_status>
  8029d7:	83 c4 10             	add    $0x10,%esp
  8029da:	85 c0                	test   %eax,%eax
  8029dc:	79 25                	jns    802a03 <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  8029de:	50                   	push   %eax
  8029df:	68 1f 3f 80 00       	push   $0x803f1f
  8029e4:	68 88 00 00 00       	push   $0x88
  8029e9:	68 dc 3e 80 00       	push   $0x803edc
  8029ee:	e8 2c e0 ff ff       	call   800a1f <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029f3:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029f9:	eb 58                	jmp    802a53 <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029fb:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a01:	eb 50                	jmp    802a53 <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802a03:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a09:	eb 48                	jmp    802a53 <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a0b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802a10:	eb 41                	jmp    802a53 <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a12:	89 c3                	mov    %eax,%ebx
  802a14:	eb 3d                	jmp    802a53 <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a16:	89 c3                	mov    %eax,%ebx
  802a18:	eb 06                	jmp    802a20 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a1a:	89 c3                	mov    %eax,%ebx
  802a1c:	eb 02                	jmp    802a20 <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a1e:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a20:	83 ec 0c             	sub    $0xc,%esp
  802a23:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a29:	e8 c6 ea ff ff       	call   8014f4 <sys_env_destroy>
	close(fd);
  802a2e:	83 c4 04             	add    $0x4,%esp
  802a31:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a37:	e8 6b f3 ff ff       	call   801da7 <close>
	return r;
  802a3c:	83 c4 10             	add    $0x10,%esp
  802a3f:	eb 12                	jmp    802a53 <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a41:	83 ec 08             	sub    $0x8,%esp
  802a44:	68 00 00 40 00       	push   $0x400000
  802a49:	6a 00                	push   $0x0
  802a4b:	e8 a8 eb ff ff       	call   8015f8 <sys_page_unmap>
  802a50:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a53:	89 d8                	mov    %ebx,%eax
  802a55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a58:	5b                   	pop    %ebx
  802a59:	5e                   	pop    %esi
  802a5a:	5f                   	pop    %edi
  802a5b:	5d                   	pop    %ebp
  802a5c:	c3                   	ret    

00802a5d <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a5d:	55                   	push   %ebp
  802a5e:	89 e5                	mov    %esp,%ebp
  802a60:	56                   	push   %esi
  802a61:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a62:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a65:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a6a:	eb 03                	jmp    802a6f <spawnl+0x12>
		argc++;
  802a6c:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a6f:	83 c2 04             	add    $0x4,%edx
  802a72:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a76:	75 f4                	jne    802a6c <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a78:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a7f:	83 e2 f0             	and    $0xfffffff0,%edx
  802a82:	29 d4                	sub    %edx,%esp
  802a84:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a88:	c1 ea 02             	shr    $0x2,%edx
  802a8b:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a92:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a97:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a9e:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802aa5:	00 
  802aa6:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  802aad:	eb 0a                	jmp    802ab9 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802aaf:	83 c0 01             	add    $0x1,%eax
  802ab2:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802ab6:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802ab9:	39 d0                	cmp    %edx,%eax
  802abb:	75 f2                	jne    802aaf <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802abd:	83 ec 08             	sub    $0x8,%esp
  802ac0:	56                   	push   %esi
  802ac1:	ff 75 08             	pushl  0x8(%ebp)
  802ac4:	e8 5d fa ff ff       	call   802526 <spawn>
}
  802ac9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802acc:	5b                   	pop    %ebx
  802acd:	5e                   	pop    %esi
  802ace:	5d                   	pop    %ebp
  802acf:	c3                   	ret    

00802ad0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802ad0:	55                   	push   %ebp
  802ad1:	89 e5                	mov    %esp,%ebp
  802ad3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802ad6:	68 5e 3f 80 00       	push   $0x803f5e
  802adb:	ff 75 0c             	pushl  0xc(%ebp)
  802ade:	e8 8d e6 ff ff       	call   801170 <strcpy>
	return 0;
}
  802ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  802ae8:	c9                   	leave  
  802ae9:	c3                   	ret    

00802aea <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802aea:	55                   	push   %ebp
  802aeb:	89 e5                	mov    %esp,%ebp
  802aed:	53                   	push   %ebx
  802aee:	83 ec 10             	sub    $0x10,%esp
  802af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802af4:	53                   	push   %ebx
  802af5:	e8 75 09 00 00       	call   80346f <pageref>
  802afa:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802afd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802b02:	83 f8 01             	cmp    $0x1,%eax
  802b05:	75 10                	jne    802b17 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802b07:	83 ec 0c             	sub    $0xc,%esp
  802b0a:	ff 73 0c             	pushl  0xc(%ebx)
  802b0d:	e8 c0 02 00 00       	call   802dd2 <nsipc_close>
  802b12:	89 c2                	mov    %eax,%edx
  802b14:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802b17:	89 d0                	mov    %edx,%eax
  802b19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b1c:	c9                   	leave  
  802b1d:	c3                   	ret    

00802b1e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802b1e:	55                   	push   %ebp
  802b1f:	89 e5                	mov    %esp,%ebp
  802b21:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802b24:	6a 00                	push   $0x0
  802b26:	ff 75 10             	pushl  0x10(%ebp)
  802b29:	ff 75 0c             	pushl  0xc(%ebp)
  802b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  802b2f:	ff 70 0c             	pushl  0xc(%eax)
  802b32:	e8 78 03 00 00       	call   802eaf <nsipc_send>
}
  802b37:	c9                   	leave  
  802b38:	c3                   	ret    

00802b39 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802b39:	55                   	push   %ebp
  802b3a:	89 e5                	mov    %esp,%ebp
  802b3c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802b3f:	6a 00                	push   $0x0
  802b41:	ff 75 10             	pushl  0x10(%ebp)
  802b44:	ff 75 0c             	pushl  0xc(%ebp)
  802b47:	8b 45 08             	mov    0x8(%ebp),%eax
  802b4a:	ff 70 0c             	pushl  0xc(%eax)
  802b4d:	e8 f1 02 00 00       	call   802e43 <nsipc_recv>
}
  802b52:	c9                   	leave  
  802b53:	c3                   	ret    

00802b54 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802b54:	55                   	push   %ebp
  802b55:	89 e5                	mov    %esp,%ebp
  802b57:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802b5a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802b5d:	52                   	push   %edx
  802b5e:	50                   	push   %eax
  802b5f:	e8 19 f1 ff ff       	call   801c7d <fd_lookup>
  802b64:	83 c4 10             	add    $0x10,%esp
  802b67:	85 c0                	test   %eax,%eax
  802b69:	78 17                	js     802b82 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b6e:	8b 0d 3c 50 80 00    	mov    0x80503c,%ecx
  802b74:	39 08                	cmp    %ecx,(%eax)
  802b76:	75 05                	jne    802b7d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802b78:	8b 40 0c             	mov    0xc(%eax),%eax
  802b7b:	eb 05                	jmp    802b82 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802b7d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802b82:	c9                   	leave  
  802b83:	c3                   	ret    

00802b84 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802b84:	55                   	push   %ebp
  802b85:	89 e5                	mov    %esp,%ebp
  802b87:	56                   	push   %esi
  802b88:	53                   	push   %ebx
  802b89:	83 ec 1c             	sub    $0x1c,%esp
  802b8c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802b8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b91:	50                   	push   %eax
  802b92:	e8 97 f0 ff ff       	call   801c2e <fd_alloc>
  802b97:	89 c3                	mov    %eax,%ebx
  802b99:	83 c4 10             	add    $0x10,%esp
  802b9c:	85 c0                	test   %eax,%eax
  802b9e:	78 1b                	js     802bbb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802ba0:	83 ec 04             	sub    $0x4,%esp
  802ba3:	68 07 04 00 00       	push   $0x407
  802ba8:	ff 75 f4             	pushl  -0xc(%ebp)
  802bab:	6a 00                	push   $0x0
  802bad:	e8 c1 e9 ff ff       	call   801573 <sys_page_alloc>
  802bb2:	89 c3                	mov    %eax,%ebx
  802bb4:	83 c4 10             	add    $0x10,%esp
  802bb7:	85 c0                	test   %eax,%eax
  802bb9:	79 10                	jns    802bcb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802bbb:	83 ec 0c             	sub    $0xc,%esp
  802bbe:	56                   	push   %esi
  802bbf:	e8 0e 02 00 00       	call   802dd2 <nsipc_close>
		return r;
  802bc4:	83 c4 10             	add    $0x10,%esp
  802bc7:	89 d8                	mov    %ebx,%eax
  802bc9:	eb 24                	jmp    802bef <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802bcb:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  802bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bd4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bd9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802be0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802be3:	83 ec 0c             	sub    $0xc,%esp
  802be6:	50                   	push   %eax
  802be7:	e8 1b f0 ff ff       	call   801c07 <fd2num>
  802bec:	83 c4 10             	add    $0x10,%esp
}
  802bef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802bf2:	5b                   	pop    %ebx
  802bf3:	5e                   	pop    %esi
  802bf4:	5d                   	pop    %ebp
  802bf5:	c3                   	ret    

00802bf6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802bf6:	55                   	push   %ebp
  802bf7:	89 e5                	mov    %esp,%ebp
  802bf9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  802bff:	e8 50 ff ff ff       	call   802b54 <fd2sockid>
		return r;
  802c04:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c06:	85 c0                	test   %eax,%eax
  802c08:	78 1f                	js     802c29 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c0a:	83 ec 04             	sub    $0x4,%esp
  802c0d:	ff 75 10             	pushl  0x10(%ebp)
  802c10:	ff 75 0c             	pushl  0xc(%ebp)
  802c13:	50                   	push   %eax
  802c14:	e8 12 01 00 00       	call   802d2b <nsipc_accept>
  802c19:	83 c4 10             	add    $0x10,%esp
		return r;
  802c1c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c1e:	85 c0                	test   %eax,%eax
  802c20:	78 07                	js     802c29 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802c22:	e8 5d ff ff ff       	call   802b84 <alloc_sockfd>
  802c27:	89 c1                	mov    %eax,%ecx
}
  802c29:	89 c8                	mov    %ecx,%eax
  802c2b:	c9                   	leave  
  802c2c:	c3                   	ret    

00802c2d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802c2d:	55                   	push   %ebp
  802c2e:	89 e5                	mov    %esp,%ebp
  802c30:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c33:	8b 45 08             	mov    0x8(%ebp),%eax
  802c36:	e8 19 ff ff ff       	call   802b54 <fd2sockid>
  802c3b:	85 c0                	test   %eax,%eax
  802c3d:	78 12                	js     802c51 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802c3f:	83 ec 04             	sub    $0x4,%esp
  802c42:	ff 75 10             	pushl  0x10(%ebp)
  802c45:	ff 75 0c             	pushl  0xc(%ebp)
  802c48:	50                   	push   %eax
  802c49:	e8 2d 01 00 00       	call   802d7b <nsipc_bind>
  802c4e:	83 c4 10             	add    $0x10,%esp
}
  802c51:	c9                   	leave  
  802c52:	c3                   	ret    

00802c53 <shutdown>:

int
shutdown(int s, int how)
{
  802c53:	55                   	push   %ebp
  802c54:	89 e5                	mov    %esp,%ebp
  802c56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c59:	8b 45 08             	mov    0x8(%ebp),%eax
  802c5c:	e8 f3 fe ff ff       	call   802b54 <fd2sockid>
  802c61:	85 c0                	test   %eax,%eax
  802c63:	78 0f                	js     802c74 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802c65:	83 ec 08             	sub    $0x8,%esp
  802c68:	ff 75 0c             	pushl  0xc(%ebp)
  802c6b:	50                   	push   %eax
  802c6c:	e8 3f 01 00 00       	call   802db0 <nsipc_shutdown>
  802c71:	83 c4 10             	add    $0x10,%esp
}
  802c74:	c9                   	leave  
  802c75:	c3                   	ret    

00802c76 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802c76:	55                   	push   %ebp
  802c77:	89 e5                	mov    %esp,%ebp
  802c79:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  802c7f:	e8 d0 fe ff ff       	call   802b54 <fd2sockid>
  802c84:	85 c0                	test   %eax,%eax
  802c86:	78 12                	js     802c9a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802c88:	83 ec 04             	sub    $0x4,%esp
  802c8b:	ff 75 10             	pushl  0x10(%ebp)
  802c8e:	ff 75 0c             	pushl  0xc(%ebp)
  802c91:	50                   	push   %eax
  802c92:	e8 55 01 00 00       	call   802dec <nsipc_connect>
  802c97:	83 c4 10             	add    $0x10,%esp
}
  802c9a:	c9                   	leave  
  802c9b:	c3                   	ret    

00802c9c <listen>:

int
listen(int s, int backlog)
{
  802c9c:	55                   	push   %ebp
  802c9d:	89 e5                	mov    %esp,%ebp
  802c9f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  802ca5:	e8 aa fe ff ff       	call   802b54 <fd2sockid>
  802caa:	85 c0                	test   %eax,%eax
  802cac:	78 0f                	js     802cbd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802cae:	83 ec 08             	sub    $0x8,%esp
  802cb1:	ff 75 0c             	pushl  0xc(%ebp)
  802cb4:	50                   	push   %eax
  802cb5:	e8 67 01 00 00       	call   802e21 <nsipc_listen>
  802cba:	83 c4 10             	add    $0x10,%esp
}
  802cbd:	c9                   	leave  
  802cbe:	c3                   	ret    

00802cbf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802cbf:	55                   	push   %ebp
  802cc0:	89 e5                	mov    %esp,%ebp
  802cc2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802cc5:	ff 75 10             	pushl  0x10(%ebp)
  802cc8:	ff 75 0c             	pushl  0xc(%ebp)
  802ccb:	ff 75 08             	pushl  0x8(%ebp)
  802cce:	e8 3a 02 00 00       	call   802f0d <nsipc_socket>
  802cd3:	83 c4 10             	add    $0x10,%esp
  802cd6:	85 c0                	test   %eax,%eax
  802cd8:	78 05                	js     802cdf <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802cda:	e8 a5 fe ff ff       	call   802b84 <alloc_sockfd>
}
  802cdf:	c9                   	leave  
  802ce0:	c3                   	ret    

00802ce1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802ce1:	55                   	push   %ebp
  802ce2:	89 e5                	mov    %esp,%ebp
  802ce4:	53                   	push   %ebx
  802ce5:	83 ec 04             	sub    $0x4,%esp
  802ce8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802cea:	83 3d 24 64 80 00 00 	cmpl   $0x0,0x806424
  802cf1:	75 12                	jne    802d05 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802cf3:	83 ec 0c             	sub    $0xc,%esp
  802cf6:	6a 02                	push   $0x2
  802cf8:	e8 39 07 00 00       	call   803436 <ipc_find_env>
  802cfd:	a3 24 64 80 00       	mov    %eax,0x806424
  802d02:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802d05:	6a 07                	push   $0x7
  802d07:	68 00 80 80 00       	push   $0x808000
  802d0c:	53                   	push   %ebx
  802d0d:	ff 35 24 64 80 00    	pushl  0x806424
  802d13:	e8 ca 06 00 00       	call   8033e2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802d18:	83 c4 0c             	add    $0xc,%esp
  802d1b:	6a 00                	push   $0x0
  802d1d:	6a 00                	push   $0x0
  802d1f:	6a 00                	push   $0x0
  802d21:	e8 4f 06 00 00       	call   803375 <ipc_recv>
}
  802d26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d29:	c9                   	leave  
  802d2a:	c3                   	ret    

00802d2b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802d2b:	55                   	push   %ebp
  802d2c:	89 e5                	mov    %esp,%ebp
  802d2e:	56                   	push   %esi
  802d2f:	53                   	push   %ebx
  802d30:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802d33:	8b 45 08             	mov    0x8(%ebp),%eax
  802d36:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802d3b:	8b 06                	mov    (%esi),%eax
  802d3d:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802d42:	b8 01 00 00 00       	mov    $0x1,%eax
  802d47:	e8 95 ff ff ff       	call   802ce1 <nsipc>
  802d4c:	89 c3                	mov    %eax,%ebx
  802d4e:	85 c0                	test   %eax,%eax
  802d50:	78 20                	js     802d72 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802d52:	83 ec 04             	sub    $0x4,%esp
  802d55:	ff 35 10 80 80 00    	pushl  0x808010
  802d5b:	68 00 80 80 00       	push   $0x808000
  802d60:	ff 75 0c             	pushl  0xc(%ebp)
  802d63:	e8 9a e5 ff ff       	call   801302 <memmove>
		*addrlen = ret->ret_addrlen;
  802d68:	a1 10 80 80 00       	mov    0x808010,%eax
  802d6d:	89 06                	mov    %eax,(%esi)
  802d6f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802d72:	89 d8                	mov    %ebx,%eax
  802d74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d77:	5b                   	pop    %ebx
  802d78:	5e                   	pop    %esi
  802d79:	5d                   	pop    %ebp
  802d7a:	c3                   	ret    

00802d7b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802d7b:	55                   	push   %ebp
  802d7c:	89 e5                	mov    %esp,%ebp
  802d7e:	53                   	push   %ebx
  802d7f:	83 ec 08             	sub    $0x8,%esp
  802d82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802d85:	8b 45 08             	mov    0x8(%ebp),%eax
  802d88:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802d8d:	53                   	push   %ebx
  802d8e:	ff 75 0c             	pushl  0xc(%ebp)
  802d91:	68 04 80 80 00       	push   $0x808004
  802d96:	e8 67 e5 ff ff       	call   801302 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802d9b:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  802da1:	b8 02 00 00 00       	mov    $0x2,%eax
  802da6:	e8 36 ff ff ff       	call   802ce1 <nsipc>
}
  802dab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dae:	c9                   	leave  
  802daf:	c3                   	ret    

00802db0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802db0:	55                   	push   %ebp
  802db1:	89 e5                	mov    %esp,%ebp
  802db3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802db6:	8b 45 08             	mov    0x8(%ebp),%eax
  802db9:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  802dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802dc1:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  802dc6:	b8 03 00 00 00       	mov    $0x3,%eax
  802dcb:	e8 11 ff ff ff       	call   802ce1 <nsipc>
}
  802dd0:	c9                   	leave  
  802dd1:	c3                   	ret    

00802dd2 <nsipc_close>:

int
nsipc_close(int s)
{
  802dd2:	55                   	push   %ebp
  802dd3:	89 e5                	mov    %esp,%ebp
  802dd5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  802ddb:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  802de0:	b8 04 00 00 00       	mov    $0x4,%eax
  802de5:	e8 f7 fe ff ff       	call   802ce1 <nsipc>
}
  802dea:	c9                   	leave  
  802deb:	c3                   	ret    

00802dec <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802dec:	55                   	push   %ebp
  802ded:	89 e5                	mov    %esp,%ebp
  802def:	53                   	push   %ebx
  802df0:	83 ec 08             	sub    $0x8,%esp
  802df3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802df6:	8b 45 08             	mov    0x8(%ebp),%eax
  802df9:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802dfe:	53                   	push   %ebx
  802dff:	ff 75 0c             	pushl  0xc(%ebp)
  802e02:	68 04 80 80 00       	push   $0x808004
  802e07:	e8 f6 e4 ff ff       	call   801302 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802e0c:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802e12:	b8 05 00 00 00       	mov    $0x5,%eax
  802e17:	e8 c5 fe ff ff       	call   802ce1 <nsipc>
}
  802e1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e1f:	c9                   	leave  
  802e20:	c3                   	ret    

00802e21 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802e21:	55                   	push   %ebp
  802e22:	89 e5                	mov    %esp,%ebp
  802e24:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802e27:	8b 45 08             	mov    0x8(%ebp),%eax
  802e2a:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  802e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e32:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  802e37:	b8 06 00 00 00       	mov    $0x6,%eax
  802e3c:	e8 a0 fe ff ff       	call   802ce1 <nsipc>
}
  802e41:	c9                   	leave  
  802e42:	c3                   	ret    

00802e43 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802e43:	55                   	push   %ebp
  802e44:	89 e5                	mov    %esp,%ebp
  802e46:	56                   	push   %esi
  802e47:	53                   	push   %ebx
  802e48:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  802e4e:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  802e53:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  802e59:	8b 45 14             	mov    0x14(%ebp),%eax
  802e5c:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802e61:	b8 07 00 00 00       	mov    $0x7,%eax
  802e66:	e8 76 fe ff ff       	call   802ce1 <nsipc>
  802e6b:	89 c3                	mov    %eax,%ebx
  802e6d:	85 c0                	test   %eax,%eax
  802e6f:	78 35                	js     802ea6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802e71:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802e76:	7f 04                	jg     802e7c <nsipc_recv+0x39>
  802e78:	39 c6                	cmp    %eax,%esi
  802e7a:	7d 16                	jge    802e92 <nsipc_recv+0x4f>
  802e7c:	68 6a 3f 80 00       	push   $0x803f6a
  802e81:	68 90 38 80 00       	push   $0x803890
  802e86:	6a 62                	push   $0x62
  802e88:	68 7f 3f 80 00       	push   $0x803f7f
  802e8d:	e8 8d db ff ff       	call   800a1f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802e92:	83 ec 04             	sub    $0x4,%esp
  802e95:	50                   	push   %eax
  802e96:	68 00 80 80 00       	push   $0x808000
  802e9b:	ff 75 0c             	pushl  0xc(%ebp)
  802e9e:	e8 5f e4 ff ff       	call   801302 <memmove>
  802ea3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802ea6:	89 d8                	mov    %ebx,%eax
  802ea8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802eab:	5b                   	pop    %ebx
  802eac:	5e                   	pop    %esi
  802ead:	5d                   	pop    %ebp
  802eae:	c3                   	ret    

00802eaf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802eaf:	55                   	push   %ebp
  802eb0:	89 e5                	mov    %esp,%ebp
  802eb2:	53                   	push   %ebx
  802eb3:	83 ec 04             	sub    $0x4,%esp
  802eb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  802ebc:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  802ec1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802ec7:	7e 16                	jle    802edf <nsipc_send+0x30>
  802ec9:	68 8b 3f 80 00       	push   $0x803f8b
  802ece:	68 90 38 80 00       	push   $0x803890
  802ed3:	6a 6d                	push   $0x6d
  802ed5:	68 7f 3f 80 00       	push   $0x803f7f
  802eda:	e8 40 db ff ff       	call   800a1f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802edf:	83 ec 04             	sub    $0x4,%esp
  802ee2:	53                   	push   %ebx
  802ee3:	ff 75 0c             	pushl  0xc(%ebp)
  802ee6:	68 0c 80 80 00       	push   $0x80800c
  802eeb:	e8 12 e4 ff ff       	call   801302 <memmove>
	nsipcbuf.send.req_size = size;
  802ef0:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  802ef6:	8b 45 14             	mov    0x14(%ebp),%eax
  802ef9:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  802efe:	b8 08 00 00 00       	mov    $0x8,%eax
  802f03:	e8 d9 fd ff ff       	call   802ce1 <nsipc>
}
  802f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f0b:	c9                   	leave  
  802f0c:	c3                   	ret    

00802f0d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802f0d:	55                   	push   %ebp
  802f0e:	89 e5                	mov    %esp,%ebp
  802f10:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802f13:	8b 45 08             	mov    0x8(%ebp),%eax
  802f16:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  802f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f1e:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  802f23:	8b 45 10             	mov    0x10(%ebp),%eax
  802f26:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  802f2b:	b8 09 00 00 00       	mov    $0x9,%eax
  802f30:	e8 ac fd ff ff       	call   802ce1 <nsipc>
}
  802f35:	c9                   	leave  
  802f36:	c3                   	ret    

00802f37 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802f37:	55                   	push   %ebp
  802f38:	89 e5                	mov    %esp,%ebp
  802f3a:	56                   	push   %esi
  802f3b:	53                   	push   %ebx
  802f3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802f3f:	83 ec 0c             	sub    $0xc,%esp
  802f42:	ff 75 08             	pushl  0x8(%ebp)
  802f45:	e8 cd ec ff ff       	call   801c17 <fd2data>
  802f4a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802f4c:	83 c4 08             	add    $0x8,%esp
  802f4f:	68 97 3f 80 00       	push   $0x803f97
  802f54:	53                   	push   %ebx
  802f55:	e8 16 e2 ff ff       	call   801170 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802f5a:	8b 46 04             	mov    0x4(%esi),%eax
  802f5d:	2b 06                	sub    (%esi),%eax
  802f5f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802f65:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f6c:	00 00 00 
	stat->st_dev = &devpipe;
  802f6f:	c7 83 88 00 00 00 58 	movl   $0x805058,0x88(%ebx)
  802f76:	50 80 00 
	return 0;
}
  802f79:	b8 00 00 00 00       	mov    $0x0,%eax
  802f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f81:	5b                   	pop    %ebx
  802f82:	5e                   	pop    %esi
  802f83:	5d                   	pop    %ebp
  802f84:	c3                   	ret    

00802f85 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802f85:	55                   	push   %ebp
  802f86:	89 e5                	mov    %esp,%ebp
  802f88:	53                   	push   %ebx
  802f89:	83 ec 0c             	sub    $0xc,%esp
  802f8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802f8f:	53                   	push   %ebx
  802f90:	6a 00                	push   $0x0
  802f92:	e8 61 e6 ff ff       	call   8015f8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802f97:	89 1c 24             	mov    %ebx,(%esp)
  802f9a:	e8 78 ec ff ff       	call   801c17 <fd2data>
  802f9f:	83 c4 08             	add    $0x8,%esp
  802fa2:	50                   	push   %eax
  802fa3:	6a 00                	push   $0x0
  802fa5:	e8 4e e6 ff ff       	call   8015f8 <sys_page_unmap>
}
  802faa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fad:	c9                   	leave  
  802fae:	c3                   	ret    

00802faf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802faf:	55                   	push   %ebp
  802fb0:	89 e5                	mov    %esp,%ebp
  802fb2:	57                   	push   %edi
  802fb3:	56                   	push   %esi
  802fb4:	53                   	push   %ebx
  802fb5:	83 ec 1c             	sub    $0x1c,%esp
  802fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802fbb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802fbd:	a1 28 64 80 00       	mov    0x806428,%eax
  802fc2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802fc5:	83 ec 0c             	sub    $0xc,%esp
  802fc8:	ff 75 e0             	pushl  -0x20(%ebp)
  802fcb:	e8 9f 04 00 00       	call   80346f <pageref>
  802fd0:	89 c3                	mov    %eax,%ebx
  802fd2:	89 3c 24             	mov    %edi,(%esp)
  802fd5:	e8 95 04 00 00       	call   80346f <pageref>
  802fda:	83 c4 10             	add    $0x10,%esp
  802fdd:	39 c3                	cmp    %eax,%ebx
  802fdf:	0f 94 c1             	sete   %cl
  802fe2:	0f b6 c9             	movzbl %cl,%ecx
  802fe5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802fe8:	8b 15 28 64 80 00    	mov    0x806428,%edx
  802fee:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802ff1:	39 ce                	cmp    %ecx,%esi
  802ff3:	74 1b                	je     803010 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802ff5:	39 c3                	cmp    %eax,%ebx
  802ff7:	75 c4                	jne    802fbd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802ff9:	8b 42 58             	mov    0x58(%edx),%eax
  802ffc:	ff 75 e4             	pushl  -0x1c(%ebp)
  802fff:	50                   	push   %eax
  803000:	56                   	push   %esi
  803001:	68 9e 3f 80 00       	push   $0x803f9e
  803006:	e8 ed da ff ff       	call   800af8 <cprintf>
  80300b:	83 c4 10             	add    $0x10,%esp
  80300e:	eb ad                	jmp    802fbd <_pipeisclosed+0xe>
	}
}
  803010:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803013:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803016:	5b                   	pop    %ebx
  803017:	5e                   	pop    %esi
  803018:	5f                   	pop    %edi
  803019:	5d                   	pop    %ebp
  80301a:	c3                   	ret    

0080301b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80301b:	55                   	push   %ebp
  80301c:	89 e5                	mov    %esp,%ebp
  80301e:	57                   	push   %edi
  80301f:	56                   	push   %esi
  803020:	53                   	push   %ebx
  803021:	83 ec 28             	sub    $0x28,%esp
  803024:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803027:	56                   	push   %esi
  803028:	e8 ea eb ff ff       	call   801c17 <fd2data>
  80302d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80302f:	83 c4 10             	add    $0x10,%esp
  803032:	bf 00 00 00 00       	mov    $0x0,%edi
  803037:	eb 4b                	jmp    803084 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803039:	89 da                	mov    %ebx,%edx
  80303b:	89 f0                	mov    %esi,%eax
  80303d:	e8 6d ff ff ff       	call   802faf <_pipeisclosed>
  803042:	85 c0                	test   %eax,%eax
  803044:	75 48                	jne    80308e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803046:	e8 09 e5 ff ff       	call   801554 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80304b:	8b 43 04             	mov    0x4(%ebx),%eax
  80304e:	8b 0b                	mov    (%ebx),%ecx
  803050:	8d 51 20             	lea    0x20(%ecx),%edx
  803053:	39 d0                	cmp    %edx,%eax
  803055:	73 e2                	jae    803039 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803057:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80305a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80305e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803061:	89 c2                	mov    %eax,%edx
  803063:	c1 fa 1f             	sar    $0x1f,%edx
  803066:	89 d1                	mov    %edx,%ecx
  803068:	c1 e9 1b             	shr    $0x1b,%ecx
  80306b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80306e:	83 e2 1f             	and    $0x1f,%edx
  803071:	29 ca                	sub    %ecx,%edx
  803073:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803077:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80307b:	83 c0 01             	add    $0x1,%eax
  80307e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803081:	83 c7 01             	add    $0x1,%edi
  803084:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803087:	75 c2                	jne    80304b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803089:	8b 45 10             	mov    0x10(%ebp),%eax
  80308c:	eb 05                	jmp    803093 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80308e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803096:	5b                   	pop    %ebx
  803097:	5e                   	pop    %esi
  803098:	5f                   	pop    %edi
  803099:	5d                   	pop    %ebp
  80309a:	c3                   	ret    

0080309b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80309b:	55                   	push   %ebp
  80309c:	89 e5                	mov    %esp,%ebp
  80309e:	57                   	push   %edi
  80309f:	56                   	push   %esi
  8030a0:	53                   	push   %ebx
  8030a1:	83 ec 18             	sub    $0x18,%esp
  8030a4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8030a7:	57                   	push   %edi
  8030a8:	e8 6a eb ff ff       	call   801c17 <fd2data>
  8030ad:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030af:	83 c4 10             	add    $0x10,%esp
  8030b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8030b7:	eb 3d                	jmp    8030f6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8030b9:	85 db                	test   %ebx,%ebx
  8030bb:	74 04                	je     8030c1 <devpipe_read+0x26>
				return i;
  8030bd:	89 d8                	mov    %ebx,%eax
  8030bf:	eb 44                	jmp    803105 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8030c1:	89 f2                	mov    %esi,%edx
  8030c3:	89 f8                	mov    %edi,%eax
  8030c5:	e8 e5 fe ff ff       	call   802faf <_pipeisclosed>
  8030ca:	85 c0                	test   %eax,%eax
  8030cc:	75 32                	jne    803100 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8030ce:	e8 81 e4 ff ff       	call   801554 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8030d3:	8b 06                	mov    (%esi),%eax
  8030d5:	3b 46 04             	cmp    0x4(%esi),%eax
  8030d8:	74 df                	je     8030b9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8030da:	99                   	cltd   
  8030db:	c1 ea 1b             	shr    $0x1b,%edx
  8030de:	01 d0                	add    %edx,%eax
  8030e0:	83 e0 1f             	and    $0x1f,%eax
  8030e3:	29 d0                	sub    %edx,%eax
  8030e5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8030ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030ed:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8030f0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030f3:	83 c3 01             	add    $0x1,%ebx
  8030f6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8030f9:	75 d8                	jne    8030d3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8030fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8030fe:	eb 05                	jmp    803105 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803100:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803108:	5b                   	pop    %ebx
  803109:	5e                   	pop    %esi
  80310a:	5f                   	pop    %edi
  80310b:	5d                   	pop    %ebp
  80310c:	c3                   	ret    

0080310d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80310d:	55                   	push   %ebp
  80310e:	89 e5                	mov    %esp,%ebp
  803110:	56                   	push   %esi
  803111:	53                   	push   %ebx
  803112:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803115:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803118:	50                   	push   %eax
  803119:	e8 10 eb ff ff       	call   801c2e <fd_alloc>
  80311e:	83 c4 10             	add    $0x10,%esp
  803121:	89 c2                	mov    %eax,%edx
  803123:	85 c0                	test   %eax,%eax
  803125:	0f 88 2c 01 00 00    	js     803257 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80312b:	83 ec 04             	sub    $0x4,%esp
  80312e:	68 07 04 00 00       	push   $0x407
  803133:	ff 75 f4             	pushl  -0xc(%ebp)
  803136:	6a 00                	push   $0x0
  803138:	e8 36 e4 ff ff       	call   801573 <sys_page_alloc>
  80313d:	83 c4 10             	add    $0x10,%esp
  803140:	89 c2                	mov    %eax,%edx
  803142:	85 c0                	test   %eax,%eax
  803144:	0f 88 0d 01 00 00    	js     803257 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80314a:	83 ec 0c             	sub    $0xc,%esp
  80314d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803150:	50                   	push   %eax
  803151:	e8 d8 ea ff ff       	call   801c2e <fd_alloc>
  803156:	89 c3                	mov    %eax,%ebx
  803158:	83 c4 10             	add    $0x10,%esp
  80315b:	85 c0                	test   %eax,%eax
  80315d:	0f 88 e2 00 00 00    	js     803245 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803163:	83 ec 04             	sub    $0x4,%esp
  803166:	68 07 04 00 00       	push   $0x407
  80316b:	ff 75 f0             	pushl  -0x10(%ebp)
  80316e:	6a 00                	push   $0x0
  803170:	e8 fe e3 ff ff       	call   801573 <sys_page_alloc>
  803175:	89 c3                	mov    %eax,%ebx
  803177:	83 c4 10             	add    $0x10,%esp
  80317a:	85 c0                	test   %eax,%eax
  80317c:	0f 88 c3 00 00 00    	js     803245 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803182:	83 ec 0c             	sub    $0xc,%esp
  803185:	ff 75 f4             	pushl  -0xc(%ebp)
  803188:	e8 8a ea ff ff       	call   801c17 <fd2data>
  80318d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80318f:	83 c4 0c             	add    $0xc,%esp
  803192:	68 07 04 00 00       	push   $0x407
  803197:	50                   	push   %eax
  803198:	6a 00                	push   $0x0
  80319a:	e8 d4 e3 ff ff       	call   801573 <sys_page_alloc>
  80319f:	89 c3                	mov    %eax,%ebx
  8031a1:	83 c4 10             	add    $0x10,%esp
  8031a4:	85 c0                	test   %eax,%eax
  8031a6:	0f 88 89 00 00 00    	js     803235 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031ac:	83 ec 0c             	sub    $0xc,%esp
  8031af:	ff 75 f0             	pushl  -0x10(%ebp)
  8031b2:	e8 60 ea ff ff       	call   801c17 <fd2data>
  8031b7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8031be:	50                   	push   %eax
  8031bf:	6a 00                	push   $0x0
  8031c1:	56                   	push   %esi
  8031c2:	6a 00                	push   $0x0
  8031c4:	e8 ed e3 ff ff       	call   8015b6 <sys_page_map>
  8031c9:	89 c3                	mov    %eax,%ebx
  8031cb:	83 c4 20             	add    $0x20,%esp
  8031ce:	85 c0                	test   %eax,%eax
  8031d0:	78 55                	js     803227 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8031d2:	8b 15 58 50 80 00    	mov    0x805058,%edx
  8031d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031db:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8031dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031e0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8031e7:	8b 15 58 50 80 00    	mov    0x805058,%edx
  8031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031f0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8031f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031f5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8031fc:	83 ec 0c             	sub    $0xc,%esp
  8031ff:	ff 75 f4             	pushl  -0xc(%ebp)
  803202:	e8 00 ea ff ff       	call   801c07 <fd2num>
  803207:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80320a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80320c:	83 c4 04             	add    $0x4,%esp
  80320f:	ff 75 f0             	pushl  -0x10(%ebp)
  803212:	e8 f0 e9 ff ff       	call   801c07 <fd2num>
  803217:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80321a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80321d:	83 c4 10             	add    $0x10,%esp
  803220:	ba 00 00 00 00       	mov    $0x0,%edx
  803225:	eb 30                	jmp    803257 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803227:	83 ec 08             	sub    $0x8,%esp
  80322a:	56                   	push   %esi
  80322b:	6a 00                	push   $0x0
  80322d:	e8 c6 e3 ff ff       	call   8015f8 <sys_page_unmap>
  803232:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803235:	83 ec 08             	sub    $0x8,%esp
  803238:	ff 75 f0             	pushl  -0x10(%ebp)
  80323b:	6a 00                	push   $0x0
  80323d:	e8 b6 e3 ff ff       	call   8015f8 <sys_page_unmap>
  803242:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803245:	83 ec 08             	sub    $0x8,%esp
  803248:	ff 75 f4             	pushl  -0xc(%ebp)
  80324b:	6a 00                	push   $0x0
  80324d:	e8 a6 e3 ff ff       	call   8015f8 <sys_page_unmap>
  803252:	83 c4 10             	add    $0x10,%esp
  803255:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803257:	89 d0                	mov    %edx,%eax
  803259:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80325c:	5b                   	pop    %ebx
  80325d:	5e                   	pop    %esi
  80325e:	5d                   	pop    %ebp
  80325f:	c3                   	ret    

00803260 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803260:	55                   	push   %ebp
  803261:	89 e5                	mov    %esp,%ebp
  803263:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803266:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803269:	50                   	push   %eax
  80326a:	ff 75 08             	pushl  0x8(%ebp)
  80326d:	e8 0b ea ff ff       	call   801c7d <fd_lookup>
  803272:	83 c4 10             	add    $0x10,%esp
  803275:	85 c0                	test   %eax,%eax
  803277:	78 18                	js     803291 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803279:	83 ec 0c             	sub    $0xc,%esp
  80327c:	ff 75 f4             	pushl  -0xc(%ebp)
  80327f:	e8 93 e9 ff ff       	call   801c17 <fd2data>
	return _pipeisclosed(fd, p);
  803284:	89 c2                	mov    %eax,%edx
  803286:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803289:	e8 21 fd ff ff       	call   802faf <_pipeisclosed>
  80328e:	83 c4 10             	add    $0x10,%esp
}
  803291:	c9                   	leave  
  803292:	c3                   	ret    

00803293 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  803293:	55                   	push   %ebp
  803294:	89 e5                	mov    %esp,%ebp
  803296:	56                   	push   %esi
  803297:	53                   	push   %ebx
  803298:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80329b:	85 f6                	test   %esi,%esi
  80329d:	75 16                	jne    8032b5 <wait+0x22>
  80329f:	68 b6 3f 80 00       	push   $0x803fb6
  8032a4:	68 90 38 80 00       	push   $0x803890
  8032a9:	6a 09                	push   $0x9
  8032ab:	68 c1 3f 80 00       	push   $0x803fc1
  8032b0:	e8 6a d7 ff ff       	call   800a1f <_panic>
	e = &envs[ENVX(envid)];
  8032b5:	89 f3                	mov    %esi,%ebx
  8032b7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8032bd:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8032c0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8032c6:	eb 05                	jmp    8032cd <wait+0x3a>
		sys_yield();
  8032c8:	e8 87 e2 ff ff       	call   801554 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8032cd:	8b 43 48             	mov    0x48(%ebx),%eax
  8032d0:	39 c6                	cmp    %eax,%esi
  8032d2:	75 07                	jne    8032db <wait+0x48>
  8032d4:	8b 43 54             	mov    0x54(%ebx),%eax
  8032d7:	85 c0                	test   %eax,%eax
  8032d9:	75 ed                	jne    8032c8 <wait+0x35>
		sys_yield();
}
  8032db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032de:	5b                   	pop    %ebx
  8032df:	5e                   	pop    %esi
  8032e0:	5d                   	pop    %ebp
  8032e1:	c3                   	ret    

008032e2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8032e2:	55                   	push   %ebp
  8032e3:	89 e5                	mov    %esp,%ebp
  8032e5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8032e8:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  8032ef:	75 2c                	jne    80331d <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8032f1:	83 ec 04             	sub    $0x4,%esp
  8032f4:	6a 07                	push   $0x7
  8032f6:	68 00 f0 bf ee       	push   $0xeebff000
  8032fb:	6a 00                	push   $0x0
  8032fd:	e8 71 e2 ff ff       	call   801573 <sys_page_alloc>
  803302:	83 c4 10             	add    $0x10,%esp
  803305:	85 c0                	test   %eax,%eax
  803307:	79 14                	jns    80331d <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  803309:	83 ec 04             	sub    $0x4,%esp
  80330c:	68 cc 3f 80 00       	push   $0x803fcc
  803311:	6a 22                	push   $0x22
  803313:	68 e3 3f 80 00       	push   $0x803fe3
  803318:	e8 02 d7 ff ff       	call   800a1f <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  80331d:	8b 45 08             	mov    0x8(%ebp),%eax
  803320:	a3 00 90 80 00       	mov    %eax,0x809000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  803325:	83 ec 08             	sub    $0x8,%esp
  803328:	68 51 33 80 00       	push   $0x803351
  80332d:	6a 00                	push   $0x0
  80332f:	e8 8a e3 ff ff       	call   8016be <sys_env_set_pgfault_upcall>
  803334:	83 c4 10             	add    $0x10,%esp
  803337:	85 c0                	test   %eax,%eax
  803339:	79 14                	jns    80334f <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  80333b:	83 ec 04             	sub    $0x4,%esp
  80333e:	68 f4 3f 80 00       	push   $0x803ff4
  803343:	6a 27                	push   $0x27
  803345:	68 e3 3f 80 00       	push   $0x803fe3
  80334a:	e8 d0 d6 ff ff       	call   800a1f <_panic>
    
}
  80334f:	c9                   	leave  
  803350:	c3                   	ret    

00803351 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803351:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803352:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  803357:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803359:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  80335c:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  803360:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  803365:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  803369:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80336b:	83 c4 08             	add    $0x8,%esp
	popal
  80336e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  80336f:	83 c4 04             	add    $0x4,%esp
	popfl
  803372:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  803373:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  803374:	c3                   	ret    

00803375 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803375:	55                   	push   %ebp
  803376:	89 e5                	mov    %esp,%ebp
  803378:	56                   	push   %esi
  803379:	53                   	push   %ebx
  80337a:	8b 75 08             	mov    0x8(%ebp),%esi
  80337d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803380:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  803383:	85 c0                	test   %eax,%eax
  803385:	74 0e                	je     803395 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  803387:	83 ec 0c             	sub    $0xc,%esp
  80338a:	50                   	push   %eax
  80338b:	e8 93 e3 ff ff       	call   801723 <sys_ipc_recv>
  803390:	83 c4 10             	add    $0x10,%esp
  803393:	eb 10                	jmp    8033a5 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  803395:	83 ec 0c             	sub    $0xc,%esp
  803398:	68 00 00 00 f0       	push   $0xf0000000
  80339d:	e8 81 e3 ff ff       	call   801723 <sys_ipc_recv>
  8033a2:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8033a5:	85 c0                	test   %eax,%eax
  8033a7:	74 0e                	je     8033b7 <ipc_recv+0x42>
    	*from_env_store = 0;
  8033a9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8033af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8033b5:	eb 24                	jmp    8033db <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8033b7:	85 f6                	test   %esi,%esi
  8033b9:	74 0a                	je     8033c5 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8033bb:	a1 28 64 80 00       	mov    0x806428,%eax
  8033c0:	8b 40 74             	mov    0x74(%eax),%eax
  8033c3:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8033c5:	85 db                	test   %ebx,%ebx
  8033c7:	74 0a                	je     8033d3 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8033c9:	a1 28 64 80 00       	mov    0x806428,%eax
  8033ce:	8b 40 78             	mov    0x78(%eax),%eax
  8033d1:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8033d3:	a1 28 64 80 00       	mov    0x806428,%eax
  8033d8:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8033db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8033de:	5b                   	pop    %ebx
  8033df:	5e                   	pop    %esi
  8033e0:	5d                   	pop    %ebp
  8033e1:	c3                   	ret    

008033e2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8033e2:	55                   	push   %ebp
  8033e3:	89 e5                	mov    %esp,%ebp
  8033e5:	57                   	push   %edi
  8033e6:	56                   	push   %esi
  8033e7:	53                   	push   %ebx
  8033e8:	83 ec 0c             	sub    $0xc,%esp
  8033eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8033ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8033f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8033f4:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8033f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8033fb:	0f 44 d8             	cmove  %eax,%ebx
  8033fe:	eb 1c                	jmp    80341c <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  803400:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803403:	74 12                	je     803417 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  803405:	50                   	push   %eax
  803406:	68 18 40 80 00       	push   $0x804018
  80340b:	6a 4b                	push   $0x4b
  80340d:	68 30 40 80 00       	push   $0x804030
  803412:	e8 08 d6 ff ff       	call   800a1f <_panic>
        }	
        sys_yield();
  803417:	e8 38 e1 ff ff       	call   801554 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80341c:	ff 75 14             	pushl  0x14(%ebp)
  80341f:	53                   	push   %ebx
  803420:	56                   	push   %esi
  803421:	57                   	push   %edi
  803422:	e8 d9 e2 ff ff       	call   801700 <sys_ipc_try_send>
  803427:	83 c4 10             	add    $0x10,%esp
  80342a:	85 c0                	test   %eax,%eax
  80342c:	75 d2                	jne    803400 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80342e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803431:	5b                   	pop    %ebx
  803432:	5e                   	pop    %esi
  803433:	5f                   	pop    %edi
  803434:	5d                   	pop    %ebp
  803435:	c3                   	ret    

00803436 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803436:	55                   	push   %ebp
  803437:	89 e5                	mov    %esp,%ebp
  803439:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80343c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803441:	6b d0 7c             	imul   $0x7c,%eax,%edx
  803444:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80344a:	8b 52 50             	mov    0x50(%edx),%edx
  80344d:	39 ca                	cmp    %ecx,%edx
  80344f:	75 0d                	jne    80345e <ipc_find_env+0x28>
			return envs[i].env_id;
  803451:	6b c0 7c             	imul   $0x7c,%eax,%eax
  803454:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803459:	8b 40 48             	mov    0x48(%eax),%eax
  80345c:	eb 0f                	jmp    80346d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80345e:	83 c0 01             	add    $0x1,%eax
  803461:	3d 00 04 00 00       	cmp    $0x400,%eax
  803466:	75 d9                	jne    803441 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803468:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80346d:	5d                   	pop    %ebp
  80346e:	c3                   	ret    

0080346f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80346f:	55                   	push   %ebp
  803470:	89 e5                	mov    %esp,%ebp
  803472:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803475:	89 d0                	mov    %edx,%eax
  803477:	c1 e8 16             	shr    $0x16,%eax
  80347a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803481:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803486:	f6 c1 01             	test   $0x1,%cl
  803489:	74 1d                	je     8034a8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80348b:	c1 ea 0c             	shr    $0xc,%edx
  80348e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803495:	f6 c2 01             	test   $0x1,%dl
  803498:	74 0e                	je     8034a8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80349a:	c1 ea 0c             	shr    $0xc,%edx
  80349d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8034a4:	ef 
  8034a5:	0f b7 c0             	movzwl %ax,%eax
}
  8034a8:	5d                   	pop    %ebp
  8034a9:	c3                   	ret    
  8034aa:	66 90                	xchg   %ax,%ax
  8034ac:	66 90                	xchg   %ax,%ax
  8034ae:	66 90                	xchg   %ax,%ax

008034b0 <__udivdi3>:
  8034b0:	55                   	push   %ebp
  8034b1:	57                   	push   %edi
  8034b2:	56                   	push   %esi
  8034b3:	53                   	push   %ebx
  8034b4:	83 ec 1c             	sub    $0x1c,%esp
  8034b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8034bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8034bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8034c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8034c7:	85 f6                	test   %esi,%esi
  8034c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8034cd:	89 ca                	mov    %ecx,%edx
  8034cf:	89 f8                	mov    %edi,%eax
  8034d1:	75 3d                	jne    803510 <__udivdi3+0x60>
  8034d3:	39 cf                	cmp    %ecx,%edi
  8034d5:	0f 87 c5 00 00 00    	ja     8035a0 <__udivdi3+0xf0>
  8034db:	85 ff                	test   %edi,%edi
  8034dd:	89 fd                	mov    %edi,%ebp
  8034df:	75 0b                	jne    8034ec <__udivdi3+0x3c>
  8034e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8034e6:	31 d2                	xor    %edx,%edx
  8034e8:	f7 f7                	div    %edi
  8034ea:	89 c5                	mov    %eax,%ebp
  8034ec:	89 c8                	mov    %ecx,%eax
  8034ee:	31 d2                	xor    %edx,%edx
  8034f0:	f7 f5                	div    %ebp
  8034f2:	89 c1                	mov    %eax,%ecx
  8034f4:	89 d8                	mov    %ebx,%eax
  8034f6:	89 cf                	mov    %ecx,%edi
  8034f8:	f7 f5                	div    %ebp
  8034fa:	89 c3                	mov    %eax,%ebx
  8034fc:	89 d8                	mov    %ebx,%eax
  8034fe:	89 fa                	mov    %edi,%edx
  803500:	83 c4 1c             	add    $0x1c,%esp
  803503:	5b                   	pop    %ebx
  803504:	5e                   	pop    %esi
  803505:	5f                   	pop    %edi
  803506:	5d                   	pop    %ebp
  803507:	c3                   	ret    
  803508:	90                   	nop
  803509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803510:	39 ce                	cmp    %ecx,%esi
  803512:	77 74                	ja     803588 <__udivdi3+0xd8>
  803514:	0f bd fe             	bsr    %esi,%edi
  803517:	83 f7 1f             	xor    $0x1f,%edi
  80351a:	0f 84 98 00 00 00    	je     8035b8 <__udivdi3+0x108>
  803520:	bb 20 00 00 00       	mov    $0x20,%ebx
  803525:	89 f9                	mov    %edi,%ecx
  803527:	89 c5                	mov    %eax,%ebp
  803529:	29 fb                	sub    %edi,%ebx
  80352b:	d3 e6                	shl    %cl,%esi
  80352d:	89 d9                	mov    %ebx,%ecx
  80352f:	d3 ed                	shr    %cl,%ebp
  803531:	89 f9                	mov    %edi,%ecx
  803533:	d3 e0                	shl    %cl,%eax
  803535:	09 ee                	or     %ebp,%esi
  803537:	89 d9                	mov    %ebx,%ecx
  803539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80353d:	89 d5                	mov    %edx,%ebp
  80353f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803543:	d3 ed                	shr    %cl,%ebp
  803545:	89 f9                	mov    %edi,%ecx
  803547:	d3 e2                	shl    %cl,%edx
  803549:	89 d9                	mov    %ebx,%ecx
  80354b:	d3 e8                	shr    %cl,%eax
  80354d:	09 c2                	or     %eax,%edx
  80354f:	89 d0                	mov    %edx,%eax
  803551:	89 ea                	mov    %ebp,%edx
  803553:	f7 f6                	div    %esi
  803555:	89 d5                	mov    %edx,%ebp
  803557:	89 c3                	mov    %eax,%ebx
  803559:	f7 64 24 0c          	mull   0xc(%esp)
  80355d:	39 d5                	cmp    %edx,%ebp
  80355f:	72 10                	jb     803571 <__udivdi3+0xc1>
  803561:	8b 74 24 08          	mov    0x8(%esp),%esi
  803565:	89 f9                	mov    %edi,%ecx
  803567:	d3 e6                	shl    %cl,%esi
  803569:	39 c6                	cmp    %eax,%esi
  80356b:	73 07                	jae    803574 <__udivdi3+0xc4>
  80356d:	39 d5                	cmp    %edx,%ebp
  80356f:	75 03                	jne    803574 <__udivdi3+0xc4>
  803571:	83 eb 01             	sub    $0x1,%ebx
  803574:	31 ff                	xor    %edi,%edi
  803576:	89 d8                	mov    %ebx,%eax
  803578:	89 fa                	mov    %edi,%edx
  80357a:	83 c4 1c             	add    $0x1c,%esp
  80357d:	5b                   	pop    %ebx
  80357e:	5e                   	pop    %esi
  80357f:	5f                   	pop    %edi
  803580:	5d                   	pop    %ebp
  803581:	c3                   	ret    
  803582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803588:	31 ff                	xor    %edi,%edi
  80358a:	31 db                	xor    %ebx,%ebx
  80358c:	89 d8                	mov    %ebx,%eax
  80358e:	89 fa                	mov    %edi,%edx
  803590:	83 c4 1c             	add    $0x1c,%esp
  803593:	5b                   	pop    %ebx
  803594:	5e                   	pop    %esi
  803595:	5f                   	pop    %edi
  803596:	5d                   	pop    %ebp
  803597:	c3                   	ret    
  803598:	90                   	nop
  803599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035a0:	89 d8                	mov    %ebx,%eax
  8035a2:	f7 f7                	div    %edi
  8035a4:	31 ff                	xor    %edi,%edi
  8035a6:	89 c3                	mov    %eax,%ebx
  8035a8:	89 d8                	mov    %ebx,%eax
  8035aa:	89 fa                	mov    %edi,%edx
  8035ac:	83 c4 1c             	add    $0x1c,%esp
  8035af:	5b                   	pop    %ebx
  8035b0:	5e                   	pop    %esi
  8035b1:	5f                   	pop    %edi
  8035b2:	5d                   	pop    %ebp
  8035b3:	c3                   	ret    
  8035b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035b8:	39 ce                	cmp    %ecx,%esi
  8035ba:	72 0c                	jb     8035c8 <__udivdi3+0x118>
  8035bc:	31 db                	xor    %ebx,%ebx
  8035be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8035c2:	0f 87 34 ff ff ff    	ja     8034fc <__udivdi3+0x4c>
  8035c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8035cd:	e9 2a ff ff ff       	jmp    8034fc <__udivdi3+0x4c>
  8035d2:	66 90                	xchg   %ax,%ax
  8035d4:	66 90                	xchg   %ax,%ax
  8035d6:	66 90                	xchg   %ax,%ax
  8035d8:	66 90                	xchg   %ax,%ax
  8035da:	66 90                	xchg   %ax,%ax
  8035dc:	66 90                	xchg   %ax,%ax
  8035de:	66 90                	xchg   %ax,%ax

008035e0 <__umoddi3>:
  8035e0:	55                   	push   %ebp
  8035e1:	57                   	push   %edi
  8035e2:	56                   	push   %esi
  8035e3:	53                   	push   %ebx
  8035e4:	83 ec 1c             	sub    $0x1c,%esp
  8035e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8035eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8035ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8035f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8035f7:	85 d2                	test   %edx,%edx
  8035f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8035fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803601:	89 f3                	mov    %esi,%ebx
  803603:	89 3c 24             	mov    %edi,(%esp)
  803606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80360a:	75 1c                	jne    803628 <__umoddi3+0x48>
  80360c:	39 f7                	cmp    %esi,%edi
  80360e:	76 50                	jbe    803660 <__umoddi3+0x80>
  803610:	89 c8                	mov    %ecx,%eax
  803612:	89 f2                	mov    %esi,%edx
  803614:	f7 f7                	div    %edi
  803616:	89 d0                	mov    %edx,%eax
  803618:	31 d2                	xor    %edx,%edx
  80361a:	83 c4 1c             	add    $0x1c,%esp
  80361d:	5b                   	pop    %ebx
  80361e:	5e                   	pop    %esi
  80361f:	5f                   	pop    %edi
  803620:	5d                   	pop    %ebp
  803621:	c3                   	ret    
  803622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803628:	39 f2                	cmp    %esi,%edx
  80362a:	89 d0                	mov    %edx,%eax
  80362c:	77 52                	ja     803680 <__umoddi3+0xa0>
  80362e:	0f bd ea             	bsr    %edx,%ebp
  803631:	83 f5 1f             	xor    $0x1f,%ebp
  803634:	75 5a                	jne    803690 <__umoddi3+0xb0>
  803636:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80363a:	0f 82 e0 00 00 00    	jb     803720 <__umoddi3+0x140>
  803640:	39 0c 24             	cmp    %ecx,(%esp)
  803643:	0f 86 d7 00 00 00    	jbe    803720 <__umoddi3+0x140>
  803649:	8b 44 24 08          	mov    0x8(%esp),%eax
  80364d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803651:	83 c4 1c             	add    $0x1c,%esp
  803654:	5b                   	pop    %ebx
  803655:	5e                   	pop    %esi
  803656:	5f                   	pop    %edi
  803657:	5d                   	pop    %ebp
  803658:	c3                   	ret    
  803659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803660:	85 ff                	test   %edi,%edi
  803662:	89 fd                	mov    %edi,%ebp
  803664:	75 0b                	jne    803671 <__umoddi3+0x91>
  803666:	b8 01 00 00 00       	mov    $0x1,%eax
  80366b:	31 d2                	xor    %edx,%edx
  80366d:	f7 f7                	div    %edi
  80366f:	89 c5                	mov    %eax,%ebp
  803671:	89 f0                	mov    %esi,%eax
  803673:	31 d2                	xor    %edx,%edx
  803675:	f7 f5                	div    %ebp
  803677:	89 c8                	mov    %ecx,%eax
  803679:	f7 f5                	div    %ebp
  80367b:	89 d0                	mov    %edx,%eax
  80367d:	eb 99                	jmp    803618 <__umoddi3+0x38>
  80367f:	90                   	nop
  803680:	89 c8                	mov    %ecx,%eax
  803682:	89 f2                	mov    %esi,%edx
  803684:	83 c4 1c             	add    $0x1c,%esp
  803687:	5b                   	pop    %ebx
  803688:	5e                   	pop    %esi
  803689:	5f                   	pop    %edi
  80368a:	5d                   	pop    %ebp
  80368b:	c3                   	ret    
  80368c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803690:	8b 34 24             	mov    (%esp),%esi
  803693:	bf 20 00 00 00       	mov    $0x20,%edi
  803698:	89 e9                	mov    %ebp,%ecx
  80369a:	29 ef                	sub    %ebp,%edi
  80369c:	d3 e0                	shl    %cl,%eax
  80369e:	89 f9                	mov    %edi,%ecx
  8036a0:	89 f2                	mov    %esi,%edx
  8036a2:	d3 ea                	shr    %cl,%edx
  8036a4:	89 e9                	mov    %ebp,%ecx
  8036a6:	09 c2                	or     %eax,%edx
  8036a8:	89 d8                	mov    %ebx,%eax
  8036aa:	89 14 24             	mov    %edx,(%esp)
  8036ad:	89 f2                	mov    %esi,%edx
  8036af:	d3 e2                	shl    %cl,%edx
  8036b1:	89 f9                	mov    %edi,%ecx
  8036b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8036b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8036bb:	d3 e8                	shr    %cl,%eax
  8036bd:	89 e9                	mov    %ebp,%ecx
  8036bf:	89 c6                	mov    %eax,%esi
  8036c1:	d3 e3                	shl    %cl,%ebx
  8036c3:	89 f9                	mov    %edi,%ecx
  8036c5:	89 d0                	mov    %edx,%eax
  8036c7:	d3 e8                	shr    %cl,%eax
  8036c9:	89 e9                	mov    %ebp,%ecx
  8036cb:	09 d8                	or     %ebx,%eax
  8036cd:	89 d3                	mov    %edx,%ebx
  8036cf:	89 f2                	mov    %esi,%edx
  8036d1:	f7 34 24             	divl   (%esp)
  8036d4:	89 d6                	mov    %edx,%esi
  8036d6:	d3 e3                	shl    %cl,%ebx
  8036d8:	f7 64 24 04          	mull   0x4(%esp)
  8036dc:	39 d6                	cmp    %edx,%esi
  8036de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8036e2:	89 d1                	mov    %edx,%ecx
  8036e4:	89 c3                	mov    %eax,%ebx
  8036e6:	72 08                	jb     8036f0 <__umoddi3+0x110>
  8036e8:	75 11                	jne    8036fb <__umoddi3+0x11b>
  8036ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8036ee:	73 0b                	jae    8036fb <__umoddi3+0x11b>
  8036f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8036f4:	1b 14 24             	sbb    (%esp),%edx
  8036f7:	89 d1                	mov    %edx,%ecx
  8036f9:	89 c3                	mov    %eax,%ebx
  8036fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8036ff:	29 da                	sub    %ebx,%edx
  803701:	19 ce                	sbb    %ecx,%esi
  803703:	89 f9                	mov    %edi,%ecx
  803705:	89 f0                	mov    %esi,%eax
  803707:	d3 e0                	shl    %cl,%eax
  803709:	89 e9                	mov    %ebp,%ecx
  80370b:	d3 ea                	shr    %cl,%edx
  80370d:	89 e9                	mov    %ebp,%ecx
  80370f:	d3 ee                	shr    %cl,%esi
  803711:	09 d0                	or     %edx,%eax
  803713:	89 f2                	mov    %esi,%edx
  803715:	83 c4 1c             	add    $0x1c,%esp
  803718:	5b                   	pop    %ebx
  803719:	5e                   	pop    %esi
  80371a:	5f                   	pop    %edi
  80371b:	5d                   	pop    %ebp
  80371c:	c3                   	ret    
  80371d:	8d 76 00             	lea    0x0(%esi),%esi
  803720:	29 f9                	sub    %edi,%ecx
  803722:	19 d6                	sbb    %edx,%esi
  803724:	89 74 24 04          	mov    %esi,0x4(%esp)
  803728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80372c:	e9 18 ff ff ff       	jmp    803649 <__umoddi3+0x69>
