
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 a9 0c 00 00       	call   800cf0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 8c 13 00 00       	call   8013e5 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 29 13 00 00       	call   801391 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 ab 12 00 00       	call   801324 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 40 28 80 00       	mov    $0x802840,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 4b 28 80 00       	push   $0x80284b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 65 28 80 00       	push   $0x802865
  8000b4:	e8 d9 05 00 00       	call   800692 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 00 2a 80 00       	push   $0x802a00
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 65 28 80 00       	push   $0x802865
  8000cc:	e8 c1 05 00 00       	call   800692 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 75 28 80 00       	mov    $0x802875,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 7e 28 80 00       	push   $0x80287e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 65 28 80 00       	push   $0x802865
  8000f1:	e8 9c 05 00 00       	call   800692 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 24 2a 80 00       	push   $0x802a24
  800119:	6a 27                	push   $0x27
  80011b:	68 65 28 80 00       	push   $0x802865
  800120:	e8 6d 05 00 00       	call   800692 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 96 28 80 00       	push   $0x802896
  80012d:	e8 39 06 00 00       	call   80076b <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 40 80 00    	call   *0x80401c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 aa 28 80 00       	push   $0x8028aa
  800154:	6a 2b                	push   $0x2b
  800156:	68 65 28 80 00       	push   $0x802865
  80015b:	e8 32 05 00 00       	call   800692 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 40 80 00    	pushl  0x804000
  800169:	e8 49 0b 00 00       	call   800cb7 <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 40 80 00    	pushl  0x804000
  80017f:	e8 33 0b 00 00       	call   800cb7 <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 54 2a 80 00       	push   $0x802a54
  80018f:	6a 2d                	push   $0x2d
  800191:	68 65 28 80 00       	push   $0x802865
  800196:	e8 f7 04 00 00       	call   800692 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 b8 28 80 00       	push   $0x8028b8
  8001a3:	e8 c3 05 00 00       	call   80076b <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 77 0c 00 00       	call   800e35 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 40 80 00    	call   *0x804010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 cb 28 80 00       	push   $0x8028cb
  8001df:	6a 32                	push   $0x32
  8001e1:	68 65 28 80 00       	push   $0x802865
  8001e6:	e8 a7 04 00 00       	call   800692 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 40 80 00    	pushl  0x804000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 9a 0b 00 00       	call   800d9a <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 d9 28 80 00       	push   $0x8028d9
  80020f:	6a 34                	push   $0x34
  800211:	68 65 28 80 00       	push   $0x802865
  800216:	e8 77 04 00 00       	call   800692 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 f7 28 80 00       	push   $0x8028f7
  800223:	e8 43 05 00 00       	call   80076b <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 0a 29 80 00       	push   $0x80290a
  800242:	6a 38                	push   $0x38
  800244:	68 65 28 80 00       	push   $0x802865
  800249:	e8 44 04 00 00       	call   800692 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 19 29 80 00       	push   $0x802919
  800256:	e8 10 05 00 00       	call   80076b <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 ee 0e 00 00       	call   801178 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 40 80 00    	call   *0x804010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 7c 2a 80 00       	push   $0x802a7c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 65 28 80 00       	push   $0x802865
  8002b8:	e8 d5 03 00 00       	call   800692 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 2d 29 80 00       	push   $0x80292d
  8002c5:	e8 a1 04 00 00       	call   80076b <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 43 29 80 00       	mov    $0x802943,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 4d 29 80 00       	push   $0x80294d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 65 28 80 00       	push   $0x802865
  8002ed:	e8 a0 03 00 00       	call   800692 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 40 80 00    	pushl  0x804000
  800301:	e8 b1 09 00 00       	call   800cb7 <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 40 80 00    	pushl  0x804000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 40 80 00    	pushl  0x804000
  800322:	e8 90 09 00 00       	call   800cb7 <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 66 29 80 00       	push   $0x802966
  800334:	6a 4b                	push   $0x4b
  800336:	68 65 28 80 00       	push   $0x802865
  80033b:	e8 52 03 00 00       	call   800692 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 75 29 80 00       	push   $0x802975
  800348:	e8 1e 04 00 00       	call   80076b <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 c8 0a 00 00       	call   800e35 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 40 80 00    	call   *0x804010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 b4 2a 80 00       	push   $0x802ab4
  800390:	6a 51                	push   $0x51
  800392:	68 65 28 80 00       	push   $0x802865
  800397:	e8 f6 02 00 00       	call   800692 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 40 80 00    	pushl  0x804000
  8003a5:	e8 0d 09 00 00       	call   800cb7 <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 d4 2a 80 00       	push   $0x802ad4
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 65 28 80 00       	push   $0x802865
  8003be:	e8 cf 02 00 00       	call   800692 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 40 80 00    	pushl  0x804000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 c2 09 00 00       	call   800d9a <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 0c 2b 80 00       	push   $0x802b0c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 65 28 80 00       	push   $0x802865
  8003ee:	e8 9f 02 00 00       	call   800692 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 3c 2b 80 00       	push   $0x802b3c
  8003fb:	e8 6b 03 00 00       	call   80076b <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 40 28 80 00       	push   $0x802840
  80040a:	e8 7a 17 00 00       	call   801b89 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 51 28 80 00       	push   $0x802851
  800426:	6a 5a                	push   $0x5a
  800428:	68 65 28 80 00       	push   $0x802865
  80042d:	e8 60 02 00 00       	call   800692 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 89 29 80 00       	push   $0x802989
  80043e:	6a 5c                	push   $0x5c
  800440:	68 65 28 80 00       	push   $0x802865
  800445:	e8 48 02 00 00       	call   800692 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 75 28 80 00       	push   $0x802875
  800454:	e8 30 17 00 00       	call   801b89 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 84 28 80 00       	push   $0x802884
  800466:	6a 5f                	push   $0x5f
  800468:	68 65 28 80 00       	push   $0x802865
  80046d:	e8 20 02 00 00       	call   800692 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 60 2b 80 00       	push   $0x802b60
  800498:	6a 62                	push   $0x62
  80049a:	68 65 28 80 00       	push   $0x802865
  80049f:	e8 ee 01 00 00       	call   800692 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 9c 28 80 00       	push   $0x80289c
  8004ac:	e8 ba 02 00 00       	call   80076b <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 a4 29 80 00       	push   $0x8029a4
  8004be:	e8 c6 16 00 00       	call   801b89 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 a9 29 80 00       	push   $0x8029a9
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 65 28 80 00       	push   $0x802865
  8004d9:	e8 b4 01 00 00       	call   800692 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 41 09 00 00       	call   800e35 <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 bd 12 00 00       	call   8017d4 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 b8 29 80 00       	push   $0x8029b8
  800528:	6a 6c                	push   $0x6c
  80052a:	68 65 28 80 00       	push   $0x802865
  80052f:	e8 5e 01 00 00       	call   800692 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 72 10 00 00       	call   8015be <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 a4 29 80 00       	push   $0x8029a4
  800556:	e8 2e 16 00 00       	call   801b89 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 ca 29 80 00       	push   $0x8029ca
  80056a:	6a 71                	push   $0x71
  80056c:	68 65 28 80 00       	push   $0x802865
  800571:	e8 1c 01 00 00       	call   800692 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 f5 11 00 00       	call   80178b <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 d8 29 80 00       	push   $0x8029d8
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 65 28 80 00       	push   $0x802865
  8005ae:	e8 df 00 00 00       	call   800692 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 88 2b 80 00       	push   $0x802b88
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 65 28 80 00       	push   $0x802865
  8005d0:	e8 bd 00 00 00       	call   800692 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 b4 2b 80 00       	push   $0x802bb4
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 65 28 80 00       	push   $0x802865
  8005f0:	e8 9d 00 00 00       	call   800692 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 ad 0f 00 00       	call   8015be <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 e9 29 80 00 	movl   $0x8029e9,(%esp)
  800618:	e8 4e 01 00 00       	call   80076b <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800633:	c7 05 08 50 80 00 00 	movl   $0x0,0x805008
  80063a:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80063d:	e8 73 0a 00 00       	call   8010b5 <sys_getenvid>
  800642:	25 ff 03 00 00       	and    $0x3ff,%eax
  800647:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80064a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80064f:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800654:	85 db                	test   %ebx,%ebx
  800656:	7e 07                	jle    80065f <libmain+0x37>
		binaryname = argv[0];
  800658:	8b 06                	mov    (%esi),%eax
  80065a:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	56                   	push   %esi
  800663:	53                   	push   %ebx
  800664:	e8 15 fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  800669:	e8 0a 00 00 00       	call   800678 <exit>
}
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800674:	5b                   	pop    %ebx
  800675:	5e                   	pop    %esi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80067e:	e8 66 0f 00 00       	call   8015e9 <close_all>
	sys_env_destroy(0);
  800683:	83 ec 0c             	sub    $0xc,%esp
  800686:	6a 00                	push   $0x0
  800688:	e8 e7 09 00 00       	call   801074 <sys_env_destroy>
}
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	c9                   	leave  
  800691:	c3                   	ret    

00800692 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	56                   	push   %esi
  800696:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800697:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80069a:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8006a0:	e8 10 0a 00 00       	call   8010b5 <sys_getenvid>
  8006a5:	83 ec 0c             	sub    $0xc,%esp
  8006a8:	ff 75 0c             	pushl  0xc(%ebp)
  8006ab:	ff 75 08             	pushl  0x8(%ebp)
  8006ae:	56                   	push   %esi
  8006af:	50                   	push   %eax
  8006b0:	68 0c 2c 80 00       	push   $0x802c0c
  8006b5:	e8 b1 00 00 00       	call   80076b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006ba:	83 c4 18             	add    $0x18,%esp
  8006bd:	53                   	push   %ebx
  8006be:	ff 75 10             	pushl  0x10(%ebp)
  8006c1:	e8 54 00 00 00       	call   80071a <vcprintf>
	cprintf("\n");
  8006c6:	c7 04 24 a4 30 80 00 	movl   $0x8030a4,(%esp)
  8006cd:	e8 99 00 00 00       	call   80076b <cprintf>
  8006d2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006d5:	cc                   	int3   
  8006d6:	eb fd                	jmp    8006d5 <_panic+0x43>

008006d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	53                   	push   %ebx
  8006dc:	83 ec 04             	sub    $0x4,%esp
  8006df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006e2:	8b 13                	mov    (%ebx),%edx
  8006e4:	8d 42 01             	lea    0x1(%edx),%eax
  8006e7:	89 03                	mov    %eax,(%ebx)
  8006e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006f5:	75 1a                	jne    800711 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	68 ff 00 00 00       	push   $0xff
  8006ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800702:	50                   	push   %eax
  800703:	e8 2f 09 00 00       	call   801037 <sys_cputs>
		b->idx = 0;
  800708:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80070e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800711:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800723:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80072a:	00 00 00 
	b.cnt = 0;
  80072d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800734:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	ff 75 08             	pushl  0x8(%ebp)
  80073d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	68 d8 06 80 00       	push   $0x8006d8
  800749:	e8 54 01 00 00       	call   8008a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80074e:	83 c4 08             	add    $0x8,%esp
  800751:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800757:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	e8 d4 08 00 00       	call   801037 <sys_cputs>

	return b.cnt;
}
  800763:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800771:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800774:	50                   	push   %eax
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 9d ff ff ff       	call   80071a <vcprintf>
	va_end(ap);

	return cnt;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	57                   	push   %edi
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	83 ec 1c             	sub    $0x1c,%esp
  800788:	89 c7                	mov    %eax,%edi
  80078a:	89 d6                	mov    %edx,%esi
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800792:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800795:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800798:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80079b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8007a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007a6:	39 d3                	cmp    %edx,%ebx
  8007a8:	72 05                	jb     8007af <printnum+0x30>
  8007aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007ad:	77 45                	ja     8007f4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007af:	83 ec 0c             	sub    $0xc,%esp
  8007b2:	ff 75 18             	pushl  0x18(%ebp)
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007bb:	53                   	push   %ebx
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8007cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8007ce:	e8 dd 1d 00 00       	call   8025b0 <__udivdi3>
  8007d3:	83 c4 18             	add    $0x18,%esp
  8007d6:	52                   	push   %edx
  8007d7:	50                   	push   %eax
  8007d8:	89 f2                	mov    %esi,%edx
  8007da:	89 f8                	mov    %edi,%eax
  8007dc:	e8 9e ff ff ff       	call   80077f <printnum>
  8007e1:	83 c4 20             	add    $0x20,%esp
  8007e4:	eb 18                	jmp    8007fe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	56                   	push   %esi
  8007ea:	ff 75 18             	pushl  0x18(%ebp)
  8007ed:	ff d7                	call   *%edi
  8007ef:	83 c4 10             	add    $0x10,%esp
  8007f2:	eb 03                	jmp    8007f7 <printnum+0x78>
  8007f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007f7:	83 eb 01             	sub    $0x1,%ebx
  8007fa:	85 db                	test   %ebx,%ebx
  8007fc:	7f e8                	jg     8007e6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	56                   	push   %esi
  800802:	83 ec 04             	sub    $0x4,%esp
  800805:	ff 75 e4             	pushl  -0x1c(%ebp)
  800808:	ff 75 e0             	pushl  -0x20(%ebp)
  80080b:	ff 75 dc             	pushl  -0x24(%ebp)
  80080e:	ff 75 d8             	pushl  -0x28(%ebp)
  800811:	e8 ca 1e 00 00       	call   8026e0 <__umoddi3>
  800816:	83 c4 14             	add    $0x14,%esp
  800819:	0f be 80 2f 2c 80 00 	movsbl 0x802c2f(%eax),%eax
  800820:	50                   	push   %eax
  800821:	ff d7                	call   *%edi
}
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5f                   	pop    %edi
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800831:	83 fa 01             	cmp    $0x1,%edx
  800834:	7e 0e                	jle    800844 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800836:	8b 10                	mov    (%eax),%edx
  800838:	8d 4a 08             	lea    0x8(%edx),%ecx
  80083b:	89 08                	mov    %ecx,(%eax)
  80083d:	8b 02                	mov    (%edx),%eax
  80083f:	8b 52 04             	mov    0x4(%edx),%edx
  800842:	eb 22                	jmp    800866 <getuint+0x38>
	else if (lflag)
  800844:	85 d2                	test   %edx,%edx
  800846:	74 10                	je     800858 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80084d:	89 08                	mov    %ecx,(%eax)
  80084f:	8b 02                	mov    (%edx),%eax
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
  800856:	eb 0e                	jmp    800866 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800858:	8b 10                	mov    (%eax),%edx
  80085a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80085d:	89 08                	mov    %ecx,(%eax)
  80085f:	8b 02                	mov    (%edx),%eax
  800861:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80086e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800872:	8b 10                	mov    (%eax),%edx
  800874:	3b 50 04             	cmp    0x4(%eax),%edx
  800877:	73 0a                	jae    800883 <sprintputch+0x1b>
		*b->buf++ = ch;
  800879:	8d 4a 01             	lea    0x1(%edx),%ecx
  80087c:	89 08                	mov    %ecx,(%eax)
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	88 02                	mov    %al,(%edx)
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80088e:	50                   	push   %eax
  80088f:	ff 75 10             	pushl  0x10(%ebp)
  800892:	ff 75 0c             	pushl  0xc(%ebp)
  800895:	ff 75 08             	pushl  0x8(%ebp)
  800898:	e8 05 00 00 00       	call   8008a2 <vprintfmt>
	va_end(ap);
}
  80089d:	83 c4 10             	add    $0x10,%esp
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	83 ec 2c             	sub    $0x2c,%esp
  8008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008b4:	eb 12                	jmp    8008c8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	0f 84 89 03 00 00    	je     800c47 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	50                   	push   %eax
  8008c3:	ff d6                	call   *%esi
  8008c5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c8:	83 c7 01             	add    $0x1,%edi
  8008cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008cf:	83 f8 25             	cmp    $0x25,%eax
  8008d2:	75 e2                	jne    8008b6 <vprintfmt+0x14>
  8008d4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f2:	eb 07                	jmp    8008fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008f7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8d 47 01             	lea    0x1(%edi),%eax
  8008fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800901:	0f b6 07             	movzbl (%edi),%eax
  800904:	0f b6 c8             	movzbl %al,%ecx
  800907:	83 e8 23             	sub    $0x23,%eax
  80090a:	3c 55                	cmp    $0x55,%al
  80090c:	0f 87 1a 03 00 00    	ja     800c2c <vprintfmt+0x38a>
  800912:	0f b6 c0             	movzbl %al,%eax
  800915:	ff 24 85 80 2d 80 00 	jmp    *0x802d80(,%eax,4)
  80091c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80091f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800923:	eb d6                	jmp    8008fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800930:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800933:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800937:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80093a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80093d:	83 fa 09             	cmp    $0x9,%edx
  800940:	77 39                	ja     80097b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800942:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800945:	eb e9                	jmp    800930 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	8d 48 04             	lea    0x4(%eax),%ecx
  80094d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800950:	8b 00                	mov    (%eax),%eax
  800952:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800955:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800958:	eb 27                	jmp    800981 <vprintfmt+0xdf>
  80095a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80095d:	85 c0                	test   %eax,%eax
  80095f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800964:	0f 49 c8             	cmovns %eax,%ecx
  800967:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096d:	eb 8c                	jmp    8008fb <vprintfmt+0x59>
  80096f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800972:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800979:	eb 80                	jmp    8008fb <vprintfmt+0x59>
  80097b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80097e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800981:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800985:	0f 89 70 ff ff ff    	jns    8008fb <vprintfmt+0x59>
				width = precision, precision = -1;
  80098b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80098e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800991:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800998:	e9 5e ff ff ff       	jmp    8008fb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80099d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009a3:	e9 53 ff ff ff       	jmp    8008fb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ab:	8d 50 04             	lea    0x4(%eax),%edx
  8009ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b1:	83 ec 08             	sub    $0x8,%esp
  8009b4:	53                   	push   %ebx
  8009b5:	ff 30                	pushl  (%eax)
  8009b7:	ff d6                	call   *%esi
			break;
  8009b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009bf:	e9 04 ff ff ff       	jmp    8008c8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cd:	8b 00                	mov    (%eax),%eax
  8009cf:	99                   	cltd   
  8009d0:	31 d0                	xor    %edx,%eax
  8009d2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009d4:	83 f8 0f             	cmp    $0xf,%eax
  8009d7:	7f 0b                	jg     8009e4 <vprintfmt+0x142>
  8009d9:	8b 14 85 e0 2e 80 00 	mov    0x802ee0(,%eax,4),%edx
  8009e0:	85 d2                	test   %edx,%edx
  8009e2:	75 18                	jne    8009fc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009e4:	50                   	push   %eax
  8009e5:	68 47 2c 80 00       	push   $0x802c47
  8009ea:	53                   	push   %ebx
  8009eb:	56                   	push   %esi
  8009ec:	e8 94 fe ff ff       	call   800885 <printfmt>
  8009f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009f7:	e9 cc fe ff ff       	jmp    8008c8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009fc:	52                   	push   %edx
  8009fd:	68 39 30 80 00       	push   $0x803039
  800a02:	53                   	push   %ebx
  800a03:	56                   	push   %esi
  800a04:	e8 7c fe ff ff       	call   800885 <printfmt>
  800a09:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a0f:	e9 b4 fe ff ff       	jmp    8008c8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a14:	8b 45 14             	mov    0x14(%ebp),%eax
  800a17:	8d 50 04             	lea    0x4(%eax),%edx
  800a1a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a1d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a1f:	85 ff                	test   %edi,%edi
  800a21:	b8 40 2c 80 00       	mov    $0x802c40,%eax
  800a26:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a2d:	0f 8e 94 00 00 00    	jle    800ac7 <vprintfmt+0x225>
  800a33:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a37:	0f 84 98 00 00 00    	je     800ad5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	ff 75 d0             	pushl  -0x30(%ebp)
  800a43:	57                   	push   %edi
  800a44:	e8 86 02 00 00       	call   800ccf <strnlen>
  800a49:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a4c:	29 c1                	sub    %eax,%ecx
  800a4e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a51:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a54:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a5b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a5e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a60:	eb 0f                	jmp    800a71 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a62:	83 ec 08             	sub    $0x8,%esp
  800a65:	53                   	push   %ebx
  800a66:	ff 75 e0             	pushl  -0x20(%ebp)
  800a69:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a6b:	83 ef 01             	sub    $0x1,%edi
  800a6e:	83 c4 10             	add    $0x10,%esp
  800a71:	85 ff                	test   %edi,%edi
  800a73:	7f ed                	jg     800a62 <vprintfmt+0x1c0>
  800a75:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a78:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a82:	0f 49 c1             	cmovns %ecx,%eax
  800a85:	29 c1                	sub    %eax,%ecx
  800a87:	89 75 08             	mov    %esi,0x8(%ebp)
  800a8a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a8d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a90:	89 cb                	mov    %ecx,%ebx
  800a92:	eb 4d                	jmp    800ae1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a94:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a98:	74 1b                	je     800ab5 <vprintfmt+0x213>
  800a9a:	0f be c0             	movsbl %al,%eax
  800a9d:	83 e8 20             	sub    $0x20,%eax
  800aa0:	83 f8 5e             	cmp    $0x5e,%eax
  800aa3:	76 10                	jbe    800ab5 <vprintfmt+0x213>
					putch('?', putdat);
  800aa5:	83 ec 08             	sub    $0x8,%esp
  800aa8:	ff 75 0c             	pushl  0xc(%ebp)
  800aab:	6a 3f                	push   $0x3f
  800aad:	ff 55 08             	call   *0x8(%ebp)
  800ab0:	83 c4 10             	add    $0x10,%esp
  800ab3:	eb 0d                	jmp    800ac2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800ab5:	83 ec 08             	sub    $0x8,%esp
  800ab8:	ff 75 0c             	pushl  0xc(%ebp)
  800abb:	52                   	push   %edx
  800abc:	ff 55 08             	call   *0x8(%ebp)
  800abf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ac2:	83 eb 01             	sub    $0x1,%ebx
  800ac5:	eb 1a                	jmp    800ae1 <vprintfmt+0x23f>
  800ac7:	89 75 08             	mov    %esi,0x8(%ebp)
  800aca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800acd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad3:	eb 0c                	jmp    800ae1 <vprintfmt+0x23f>
  800ad5:	89 75 08             	mov    %esi,0x8(%ebp)
  800ad8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800adb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ade:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ae1:	83 c7 01             	add    $0x1,%edi
  800ae4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ae8:	0f be d0             	movsbl %al,%edx
  800aeb:	85 d2                	test   %edx,%edx
  800aed:	74 23                	je     800b12 <vprintfmt+0x270>
  800aef:	85 f6                	test   %esi,%esi
  800af1:	78 a1                	js     800a94 <vprintfmt+0x1f2>
  800af3:	83 ee 01             	sub    $0x1,%esi
  800af6:	79 9c                	jns    800a94 <vprintfmt+0x1f2>
  800af8:	89 df                	mov    %ebx,%edi
  800afa:	8b 75 08             	mov    0x8(%ebp),%esi
  800afd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b00:	eb 18                	jmp    800b1a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b02:	83 ec 08             	sub    $0x8,%esp
  800b05:	53                   	push   %ebx
  800b06:	6a 20                	push   $0x20
  800b08:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b0a:	83 ef 01             	sub    $0x1,%edi
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	eb 08                	jmp    800b1a <vprintfmt+0x278>
  800b12:	89 df                	mov    %ebx,%edi
  800b14:	8b 75 08             	mov    0x8(%ebp),%esi
  800b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1a:	85 ff                	test   %edi,%edi
  800b1c:	7f e4                	jg     800b02 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b21:	e9 a2 fd ff ff       	jmp    8008c8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b26:	83 fa 01             	cmp    $0x1,%edx
  800b29:	7e 16                	jle    800b41 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8d 50 08             	lea    0x8(%eax),%edx
  800b31:	89 55 14             	mov    %edx,0x14(%ebp)
  800b34:	8b 50 04             	mov    0x4(%eax),%edx
  800b37:	8b 00                	mov    (%eax),%eax
  800b39:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b3c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b3f:	eb 32                	jmp    800b73 <vprintfmt+0x2d1>
	else if (lflag)
  800b41:	85 d2                	test   %edx,%edx
  800b43:	74 18                	je     800b5d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b45:	8b 45 14             	mov    0x14(%ebp),%eax
  800b48:	8d 50 04             	lea    0x4(%eax),%edx
  800b4b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4e:	8b 00                	mov    (%eax),%eax
  800b50:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b53:	89 c1                	mov    %eax,%ecx
  800b55:	c1 f9 1f             	sar    $0x1f,%ecx
  800b58:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b5b:	eb 16                	jmp    800b73 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b60:	8d 50 04             	lea    0x4(%eax),%edx
  800b63:	89 55 14             	mov    %edx,0x14(%ebp)
  800b66:	8b 00                	mov    (%eax),%eax
  800b68:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6b:	89 c1                	mov    %eax,%ecx
  800b6d:	c1 f9 1f             	sar    $0x1f,%ecx
  800b70:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b73:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b76:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b79:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b7e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b82:	79 74                	jns    800bf8 <vprintfmt+0x356>
				putch('-', putdat);
  800b84:	83 ec 08             	sub    $0x8,%esp
  800b87:	53                   	push   %ebx
  800b88:	6a 2d                	push   $0x2d
  800b8a:	ff d6                	call   *%esi
				num = -(long long) num;
  800b8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b92:	f7 d8                	neg    %eax
  800b94:	83 d2 00             	adc    $0x0,%edx
  800b97:	f7 da                	neg    %edx
  800b99:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ba1:	eb 55                	jmp    800bf8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ba3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba6:	e8 83 fc ff ff       	call   80082e <getuint>
			base = 10;
  800bab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800bb0:	eb 46                	jmp    800bf8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800bb2:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb5:	e8 74 fc ff ff       	call   80082e <getuint>
		        base = 8;
  800bba:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800bbf:	eb 37                	jmp    800bf8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800bc1:	83 ec 08             	sub    $0x8,%esp
  800bc4:	53                   	push   %ebx
  800bc5:	6a 30                	push   $0x30
  800bc7:	ff d6                	call   *%esi
			putch('x', putdat);
  800bc9:	83 c4 08             	add    $0x8,%esp
  800bcc:	53                   	push   %ebx
  800bcd:	6a 78                	push   $0x78
  800bcf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bd1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd4:	8d 50 04             	lea    0x4(%eax),%edx
  800bd7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bda:	8b 00                	mov    (%eax),%eax
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800be1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800be4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800be9:	eb 0d                	jmp    800bf8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800beb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bee:	e8 3b fc ff ff       	call   80082e <getuint>
			base = 16;
  800bf3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bff:	57                   	push   %edi
  800c00:	ff 75 e0             	pushl  -0x20(%ebp)
  800c03:	51                   	push   %ecx
  800c04:	52                   	push   %edx
  800c05:	50                   	push   %eax
  800c06:	89 da                	mov    %ebx,%edx
  800c08:	89 f0                	mov    %esi,%eax
  800c0a:	e8 70 fb ff ff       	call   80077f <printnum>
			break;
  800c0f:	83 c4 20             	add    $0x20,%esp
  800c12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c15:	e9 ae fc ff ff       	jmp    8008c8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c1a:	83 ec 08             	sub    $0x8,%esp
  800c1d:	53                   	push   %ebx
  800c1e:	51                   	push   %ecx
  800c1f:	ff d6                	call   *%esi
			break;
  800c21:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c27:	e9 9c fc ff ff       	jmp    8008c8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c2c:	83 ec 08             	sub    $0x8,%esp
  800c2f:	53                   	push   %ebx
  800c30:	6a 25                	push   $0x25
  800c32:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	eb 03                	jmp    800c3c <vprintfmt+0x39a>
  800c39:	83 ef 01             	sub    $0x1,%edi
  800c3c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c40:	75 f7                	jne    800c39 <vprintfmt+0x397>
  800c42:	e9 81 fc ff ff       	jmp    8008c8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 18             	sub    $0x18,%esp
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c5e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c62:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	74 26                	je     800c96 <vsnprintf+0x47>
  800c70:	85 d2                	test   %edx,%edx
  800c72:	7e 22                	jle    800c96 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c74:	ff 75 14             	pushl  0x14(%ebp)
  800c77:	ff 75 10             	pushl  0x10(%ebp)
  800c7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c7d:	50                   	push   %eax
  800c7e:	68 68 08 80 00       	push   $0x800868
  800c83:	e8 1a fc ff ff       	call   8008a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c8b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	eb 05                	jmp    800c9b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ca3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ca6:	50                   	push   %eax
  800ca7:	ff 75 10             	pushl  0x10(%ebp)
  800caa:	ff 75 0c             	pushl  0xc(%ebp)
  800cad:	ff 75 08             	pushl  0x8(%ebp)
  800cb0:	e8 9a ff ff ff       	call   800c4f <vsnprintf>
	va_end(ap);

	return rc;
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	eb 03                	jmp    800cc7 <strlen+0x10>
		n++;
  800cc4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ccb:	75 f7                	jne    800cc4 <strlen+0xd>
		n++;
	return n;
}
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdd:	eb 03                	jmp    800ce2 <strnlen+0x13>
		n++;
  800cdf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce2:	39 c2                	cmp    %eax,%edx
  800ce4:	74 08                	je     800cee <strnlen+0x1f>
  800ce6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cea:	75 f3                	jne    800cdf <strnlen+0x10>
  800cec:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	53                   	push   %ebx
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cfa:	89 c2                	mov    %eax,%edx
  800cfc:	83 c2 01             	add    $0x1,%edx
  800cff:	83 c1 01             	add    $0x1,%ecx
  800d02:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d06:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d09:	84 db                	test   %bl,%bl
  800d0b:	75 ef                	jne    800cfc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	53                   	push   %ebx
  800d14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d17:	53                   	push   %ebx
  800d18:	e8 9a ff ff ff       	call   800cb7 <strlen>
  800d1d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d20:	ff 75 0c             	pushl  0xc(%ebp)
  800d23:	01 d8                	add    %ebx,%eax
  800d25:	50                   	push   %eax
  800d26:	e8 c5 ff ff ff       	call   800cf0 <strcpy>
	return dst;
}
  800d2b:	89 d8                	mov    %ebx,%eax
  800d2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d30:	c9                   	leave  
  800d31:	c3                   	ret    

00800d32 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	8b 75 08             	mov    0x8(%ebp),%esi
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	89 f3                	mov    %esi,%ebx
  800d3f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d42:	89 f2                	mov    %esi,%edx
  800d44:	eb 0f                	jmp    800d55 <strncpy+0x23>
		*dst++ = *src;
  800d46:	83 c2 01             	add    $0x1,%edx
  800d49:	0f b6 01             	movzbl (%ecx),%eax
  800d4c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d4f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d52:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d55:	39 da                	cmp    %ebx,%edx
  800d57:	75 ed                	jne    800d46 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	8b 75 08             	mov    0x8(%ebp),%esi
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 10             	mov    0x10(%ebp),%edx
  800d6d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d6f:	85 d2                	test   %edx,%edx
  800d71:	74 21                	je     800d94 <strlcpy+0x35>
  800d73:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d77:	89 f2                	mov    %esi,%edx
  800d79:	eb 09                	jmp    800d84 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d7b:	83 c2 01             	add    $0x1,%edx
  800d7e:	83 c1 01             	add    $0x1,%ecx
  800d81:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d84:	39 c2                	cmp    %eax,%edx
  800d86:	74 09                	je     800d91 <strlcpy+0x32>
  800d88:	0f b6 19             	movzbl (%ecx),%ebx
  800d8b:	84 db                	test   %bl,%bl
  800d8d:	75 ec                	jne    800d7b <strlcpy+0x1c>
  800d8f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d94:	29 f0                	sub    %esi,%eax
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800da3:	eb 06                	jmp    800dab <strcmp+0x11>
		p++, q++;
  800da5:	83 c1 01             	add    $0x1,%ecx
  800da8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dab:	0f b6 01             	movzbl (%ecx),%eax
  800dae:	84 c0                	test   %al,%al
  800db0:	74 04                	je     800db6 <strcmp+0x1c>
  800db2:	3a 02                	cmp    (%edx),%al
  800db4:	74 ef                	je     800da5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800db6:	0f b6 c0             	movzbl %al,%eax
  800db9:	0f b6 12             	movzbl (%edx),%edx
  800dbc:	29 d0                	sub    %edx,%eax
}
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	53                   	push   %ebx
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dcf:	eb 06                	jmp    800dd7 <strncmp+0x17>
		n--, p++, q++;
  800dd1:	83 c0 01             	add    $0x1,%eax
  800dd4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dd7:	39 d8                	cmp    %ebx,%eax
  800dd9:	74 15                	je     800df0 <strncmp+0x30>
  800ddb:	0f b6 08             	movzbl (%eax),%ecx
  800dde:	84 c9                	test   %cl,%cl
  800de0:	74 04                	je     800de6 <strncmp+0x26>
  800de2:	3a 0a                	cmp    (%edx),%cl
  800de4:	74 eb                	je     800dd1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800de6:	0f b6 00             	movzbl (%eax),%eax
  800de9:	0f b6 12             	movzbl (%edx),%edx
  800dec:	29 d0                	sub    %edx,%eax
  800dee:	eb 05                	jmp    800df5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800df0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800df5:	5b                   	pop    %ebx
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e02:	eb 07                	jmp    800e0b <strchr+0x13>
		if (*s == c)
  800e04:	38 ca                	cmp    %cl,%dl
  800e06:	74 0f                	je     800e17 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e08:	83 c0 01             	add    $0x1,%eax
  800e0b:	0f b6 10             	movzbl (%eax),%edx
  800e0e:	84 d2                	test   %dl,%dl
  800e10:	75 f2                	jne    800e04 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e23:	eb 03                	jmp    800e28 <strfind+0xf>
  800e25:	83 c0 01             	add    $0x1,%eax
  800e28:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e2b:	38 ca                	cmp    %cl,%dl
  800e2d:	74 04                	je     800e33 <strfind+0x1a>
  800e2f:	84 d2                	test   %dl,%dl
  800e31:	75 f2                	jne    800e25 <strfind+0xc>
			break;
	return (char *) s;
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e41:	85 c9                	test   %ecx,%ecx
  800e43:	74 36                	je     800e7b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e45:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e4b:	75 28                	jne    800e75 <memset+0x40>
  800e4d:	f6 c1 03             	test   $0x3,%cl
  800e50:	75 23                	jne    800e75 <memset+0x40>
		c &= 0xFF;
  800e52:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e56:	89 d3                	mov    %edx,%ebx
  800e58:	c1 e3 08             	shl    $0x8,%ebx
  800e5b:	89 d6                	mov    %edx,%esi
  800e5d:	c1 e6 18             	shl    $0x18,%esi
  800e60:	89 d0                	mov    %edx,%eax
  800e62:	c1 e0 10             	shl    $0x10,%eax
  800e65:	09 f0                	or     %esi,%eax
  800e67:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	09 d0                	or     %edx,%eax
  800e6d:	c1 e9 02             	shr    $0x2,%ecx
  800e70:	fc                   	cld    
  800e71:	f3 ab                	rep stos %eax,%es:(%edi)
  800e73:	eb 06                	jmp    800e7b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e78:	fc                   	cld    
  800e79:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e7b:	89 f8                	mov    %edi,%eax
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e90:	39 c6                	cmp    %eax,%esi
  800e92:	73 35                	jae    800ec9 <memmove+0x47>
  800e94:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e97:	39 d0                	cmp    %edx,%eax
  800e99:	73 2e                	jae    800ec9 <memmove+0x47>
		s += n;
		d += n;
  800e9b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e9e:	89 d6                	mov    %edx,%esi
  800ea0:	09 fe                	or     %edi,%esi
  800ea2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ea8:	75 13                	jne    800ebd <memmove+0x3b>
  800eaa:	f6 c1 03             	test   $0x3,%cl
  800ead:	75 0e                	jne    800ebd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800eaf:	83 ef 04             	sub    $0x4,%edi
  800eb2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eb5:	c1 e9 02             	shr    $0x2,%ecx
  800eb8:	fd                   	std    
  800eb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ebb:	eb 09                	jmp    800ec6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ebd:	83 ef 01             	sub    $0x1,%edi
  800ec0:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ec3:	fd                   	std    
  800ec4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ec6:	fc                   	cld    
  800ec7:	eb 1d                	jmp    800ee6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ec9:	89 f2                	mov    %esi,%edx
  800ecb:	09 c2                	or     %eax,%edx
  800ecd:	f6 c2 03             	test   $0x3,%dl
  800ed0:	75 0f                	jne    800ee1 <memmove+0x5f>
  800ed2:	f6 c1 03             	test   $0x3,%cl
  800ed5:	75 0a                	jne    800ee1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ed7:	c1 e9 02             	shr    $0x2,%ecx
  800eda:	89 c7                	mov    %eax,%edi
  800edc:	fc                   	cld    
  800edd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800edf:	eb 05                	jmp    800ee6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ee1:	89 c7                	mov    %eax,%edi
  800ee3:	fc                   	cld    
  800ee4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800eed:	ff 75 10             	pushl  0x10(%ebp)
  800ef0:	ff 75 0c             	pushl  0xc(%ebp)
  800ef3:	ff 75 08             	pushl  0x8(%ebp)
  800ef6:	e8 87 ff ff ff       	call   800e82 <memmove>
}
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f08:	89 c6                	mov    %eax,%esi
  800f0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f0d:	eb 1a                	jmp    800f29 <memcmp+0x2c>
		if (*s1 != *s2)
  800f0f:	0f b6 08             	movzbl (%eax),%ecx
  800f12:	0f b6 1a             	movzbl (%edx),%ebx
  800f15:	38 d9                	cmp    %bl,%cl
  800f17:	74 0a                	je     800f23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f19:	0f b6 c1             	movzbl %cl,%eax
  800f1c:	0f b6 db             	movzbl %bl,%ebx
  800f1f:	29 d8                	sub    %ebx,%eax
  800f21:	eb 0f                	jmp    800f32 <memcmp+0x35>
		s1++, s2++;
  800f23:	83 c0 01             	add    $0x1,%eax
  800f26:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f29:	39 f0                	cmp    %esi,%eax
  800f2b:	75 e2                	jne    800f0f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	53                   	push   %ebx
  800f3a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f3d:	89 c1                	mov    %eax,%ecx
  800f3f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f42:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f46:	eb 0a                	jmp    800f52 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f48:	0f b6 10             	movzbl (%eax),%edx
  800f4b:	39 da                	cmp    %ebx,%edx
  800f4d:	74 07                	je     800f56 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f4f:	83 c0 01             	add    $0x1,%eax
  800f52:	39 c8                	cmp    %ecx,%eax
  800f54:	72 f2                	jb     800f48 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f56:	5b                   	pop    %ebx
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f65:	eb 03                	jmp    800f6a <strtol+0x11>
		s++;
  800f67:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f6a:	0f b6 01             	movzbl (%ecx),%eax
  800f6d:	3c 20                	cmp    $0x20,%al
  800f6f:	74 f6                	je     800f67 <strtol+0xe>
  800f71:	3c 09                	cmp    $0x9,%al
  800f73:	74 f2                	je     800f67 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f75:	3c 2b                	cmp    $0x2b,%al
  800f77:	75 0a                	jne    800f83 <strtol+0x2a>
		s++;
  800f79:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800f81:	eb 11                	jmp    800f94 <strtol+0x3b>
  800f83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f88:	3c 2d                	cmp    $0x2d,%al
  800f8a:	75 08                	jne    800f94 <strtol+0x3b>
		s++, neg = 1;
  800f8c:	83 c1 01             	add    $0x1,%ecx
  800f8f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f94:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f9a:	75 15                	jne    800fb1 <strtol+0x58>
  800f9c:	80 39 30             	cmpb   $0x30,(%ecx)
  800f9f:	75 10                	jne    800fb1 <strtol+0x58>
  800fa1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fa5:	75 7c                	jne    801023 <strtol+0xca>
		s += 2, base = 16;
  800fa7:	83 c1 02             	add    $0x2,%ecx
  800faa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800faf:	eb 16                	jmp    800fc7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fb1:	85 db                	test   %ebx,%ebx
  800fb3:	75 12                	jne    800fc7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fb5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fba:	80 39 30             	cmpb   $0x30,(%ecx)
  800fbd:	75 08                	jne    800fc7 <strtol+0x6e>
		s++, base = 8;
  800fbf:	83 c1 01             	add    $0x1,%ecx
  800fc2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fcf:	0f b6 11             	movzbl (%ecx),%edx
  800fd2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fd5:	89 f3                	mov    %esi,%ebx
  800fd7:	80 fb 09             	cmp    $0x9,%bl
  800fda:	77 08                	ja     800fe4 <strtol+0x8b>
			dig = *s - '0';
  800fdc:	0f be d2             	movsbl %dl,%edx
  800fdf:	83 ea 30             	sub    $0x30,%edx
  800fe2:	eb 22                	jmp    801006 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fe4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fe7:	89 f3                	mov    %esi,%ebx
  800fe9:	80 fb 19             	cmp    $0x19,%bl
  800fec:	77 08                	ja     800ff6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fee:	0f be d2             	movsbl %dl,%edx
  800ff1:	83 ea 57             	sub    $0x57,%edx
  800ff4:	eb 10                	jmp    801006 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ff6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ff9:	89 f3                	mov    %esi,%ebx
  800ffb:	80 fb 19             	cmp    $0x19,%bl
  800ffe:	77 16                	ja     801016 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801000:	0f be d2             	movsbl %dl,%edx
  801003:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801006:	3b 55 10             	cmp    0x10(%ebp),%edx
  801009:	7d 0b                	jge    801016 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80100b:	83 c1 01             	add    $0x1,%ecx
  80100e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801012:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801014:	eb b9                	jmp    800fcf <strtol+0x76>

	if (endptr)
  801016:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80101a:	74 0d                	je     801029 <strtol+0xd0>
		*endptr = (char *) s;
  80101c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80101f:	89 0e                	mov    %ecx,(%esi)
  801021:	eb 06                	jmp    801029 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801023:	85 db                	test   %ebx,%ebx
  801025:	74 98                	je     800fbf <strtol+0x66>
  801027:	eb 9e                	jmp    800fc7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801029:	89 c2                	mov    %eax,%edx
  80102b:	f7 da                	neg    %edx
  80102d:	85 ff                	test   %edi,%edi
  80102f:	0f 45 c2             	cmovne %edx,%eax
}
  801032:	5b                   	pop    %ebx
  801033:	5e                   	pop    %esi
  801034:	5f                   	pop    %edi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103d:	b8 00 00 00 00       	mov    $0x0,%eax
  801042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801045:	8b 55 08             	mov    0x8(%ebp),%edx
  801048:	89 c3                	mov    %eax,%ebx
  80104a:	89 c7                	mov    %eax,%edi
  80104c:	89 c6                	mov    %eax,%esi
  80104e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_cgetc>:

int
sys_cgetc(void)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	ba 00 00 00 00       	mov    $0x0,%edx
  801060:	b8 01 00 00 00       	mov    $0x1,%eax
  801065:	89 d1                	mov    %edx,%ecx
  801067:	89 d3                	mov    %edx,%ebx
  801069:	89 d7                	mov    %edx,%edi
  80106b:	89 d6                	mov    %edx,%esi
  80106d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801082:	b8 03 00 00 00       	mov    $0x3,%eax
  801087:	8b 55 08             	mov    0x8(%ebp),%edx
  80108a:	89 cb                	mov    %ecx,%ebx
  80108c:	89 cf                	mov    %ecx,%edi
  80108e:	89 ce                	mov    %ecx,%esi
  801090:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801092:	85 c0                	test   %eax,%eax
  801094:	7e 17                	jle    8010ad <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	50                   	push   %eax
  80109a:	6a 03                	push   $0x3
  80109c:	68 3f 2f 80 00       	push   $0x802f3f
  8010a1:	6a 23                	push   $0x23
  8010a3:	68 5c 2f 80 00       	push   $0x802f5c
  8010a8:	e8 e5 f5 ff ff       	call   800692 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	57                   	push   %edi
  8010b9:	56                   	push   %esi
  8010ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8010c5:	89 d1                	mov    %edx,%ecx
  8010c7:	89 d3                	mov    %edx,%ebx
  8010c9:	89 d7                	mov    %edx,%edi
  8010cb:	89 d6                	mov    %edx,%esi
  8010cd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_yield>:

void
sys_yield(void)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	ba 00 00 00 00       	mov    $0x0,%edx
  8010df:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010e4:	89 d1                	mov    %edx,%ecx
  8010e6:	89 d3                	mov    %edx,%ebx
  8010e8:	89 d7                	mov    %edx,%edi
  8010ea:	89 d6                	mov    %edx,%esi
  8010ec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5f                   	pop    %edi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fc:	be 00 00 00 00       	mov    $0x0,%esi
  801101:	b8 04 00 00 00       	mov    $0x4,%eax
  801106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801109:	8b 55 08             	mov    0x8(%ebp),%edx
  80110c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110f:	89 f7                	mov    %esi,%edi
  801111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 04                	push   $0x4
  80111d:	68 3f 2f 80 00       	push   $0x802f3f
  801122:	6a 23                	push   $0x23
  801124:	68 5c 2f 80 00       	push   $0x802f5c
  801129:	e8 64 f5 ff ff       	call   800692 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113f:	b8 05 00 00 00       	mov    $0x5,%eax
  801144:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801147:	8b 55 08             	mov    0x8(%ebp),%edx
  80114a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801150:	8b 75 18             	mov    0x18(%ebp),%esi
  801153:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801155:	85 c0                	test   %eax,%eax
  801157:	7e 17                	jle    801170 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	50                   	push   %eax
  80115d:	6a 05                	push   $0x5
  80115f:	68 3f 2f 80 00       	push   $0x802f3f
  801164:	6a 23                	push   $0x23
  801166:	68 5c 2f 80 00       	push   $0x802f5c
  80116b:	e8 22 f5 ff ff       	call   800692 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801181:	bb 00 00 00 00       	mov    $0x0,%ebx
  801186:	b8 06 00 00 00       	mov    $0x6,%eax
  80118b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118e:	8b 55 08             	mov    0x8(%ebp),%edx
  801191:	89 df                	mov    %ebx,%edi
  801193:	89 de                	mov    %ebx,%esi
  801195:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801197:	85 c0                	test   %eax,%eax
  801199:	7e 17                	jle    8011b2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	50                   	push   %eax
  80119f:	6a 06                	push   $0x6
  8011a1:	68 3f 2f 80 00       	push   $0x802f3f
  8011a6:	6a 23                	push   $0x23
  8011a8:	68 5c 2f 80 00       	push   $0x802f5c
  8011ad:	e8 e0 f4 ff ff       	call   800692 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8011cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d3:	89 df                	mov    %ebx,%edi
  8011d5:	89 de                	mov    %ebx,%esi
  8011d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	7e 17                	jle    8011f4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011dd:	83 ec 0c             	sub    $0xc,%esp
  8011e0:	50                   	push   %eax
  8011e1:	6a 08                	push   $0x8
  8011e3:	68 3f 2f 80 00       	push   $0x802f3f
  8011e8:	6a 23                	push   $0x23
  8011ea:	68 5c 2f 80 00       	push   $0x802f5c
  8011ef:	e8 9e f4 ff ff       	call   800692 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5f                   	pop    %edi
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	57                   	push   %edi
  801200:	56                   	push   %esi
  801201:	53                   	push   %ebx
  801202:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120a:	b8 09 00 00 00       	mov    $0x9,%eax
  80120f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801212:	8b 55 08             	mov    0x8(%ebp),%edx
  801215:	89 df                	mov    %ebx,%edi
  801217:	89 de                	mov    %ebx,%esi
  801219:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80121b:	85 c0                	test   %eax,%eax
  80121d:	7e 17                	jle    801236 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	50                   	push   %eax
  801223:	6a 09                	push   $0x9
  801225:	68 3f 2f 80 00       	push   $0x802f3f
  80122a:	6a 23                	push   $0x23
  80122c:	68 5c 2f 80 00       	push   $0x802f5c
  801231:	e8 5c f4 ff ff       	call   800692 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801236:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801239:	5b                   	pop    %ebx
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801247:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801254:	8b 55 08             	mov    0x8(%ebp),%edx
  801257:	89 df                	mov    %ebx,%edi
  801259:	89 de                	mov    %ebx,%esi
  80125b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80125d:	85 c0                	test   %eax,%eax
  80125f:	7e 17                	jle    801278 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801261:	83 ec 0c             	sub    $0xc,%esp
  801264:	50                   	push   %eax
  801265:	6a 0a                	push   $0xa
  801267:	68 3f 2f 80 00       	push   $0x802f3f
  80126c:	6a 23                	push   $0x23
  80126e:	68 5c 2f 80 00       	push   $0x802f5c
  801273:	e8 1a f4 ff ff       	call   800692 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801286:	be 00 00 00 00       	mov    $0x0,%esi
  80128b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801290:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801293:	8b 55 08             	mov    0x8(%ebp),%edx
  801296:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801299:	8b 7d 14             	mov    0x14(%ebp),%edi
  80129c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5f                   	pop    %edi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	57                   	push   %edi
  8012a7:	56                   	push   %esi
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b9:	89 cb                	mov    %ecx,%ebx
  8012bb:	89 cf                	mov    %ecx,%edi
  8012bd:	89 ce                	mov    %ecx,%esi
  8012bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	7e 17                	jle    8012dc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	50                   	push   %eax
  8012c9:	6a 0d                	push   $0xd
  8012cb:	68 3f 2f 80 00       	push   $0x802f3f
  8012d0:	6a 23                	push   $0x23
  8012d2:	68 5c 2f 80 00       	push   $0x802f5c
  8012d7:	e8 b6 f3 ff ff       	call   800692 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5e                   	pop    %esi
  8012e1:	5f                   	pop    %edi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	57                   	push   %edi
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ef:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012f4:	89 d1                	mov    %edx,%ecx
  8012f6:	89 d3                	mov    %edx,%ebx
  8012f8:	89 d7                	mov    %edx,%edi
  8012fa:	89 d6                	mov    %edx,%esi
  8012fc:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5f                   	pop    %edi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	57                   	push   %edi
  801307:	56                   	push   %esi
  801308:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801313:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801316:	8b 55 08             	mov    0x8(%ebp),%edx
  801319:	89 df                	mov    %ebx,%edi
  80131b:	89 de                	mov    %ebx,%esi
  80131d:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	8b 75 08             	mov    0x8(%ebp),%esi
  80132c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801332:	85 c0                	test   %eax,%eax
  801334:	74 0e                	je     801344 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801336:	83 ec 0c             	sub    $0xc,%esp
  801339:	50                   	push   %eax
  80133a:	e8 64 ff ff ff       	call   8012a3 <sys_ipc_recv>
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	eb 10                	jmp    801354 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801344:	83 ec 0c             	sub    $0xc,%esp
  801347:	68 00 00 00 f0       	push   $0xf0000000
  80134c:	e8 52 ff ff ff       	call   8012a3 <sys_ipc_recv>
  801351:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801354:	85 c0                	test   %eax,%eax
  801356:	74 0e                	je     801366 <ipc_recv+0x42>
    	*from_env_store = 0;
  801358:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  80135e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801364:	eb 24                	jmp    80138a <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801366:	85 f6                	test   %esi,%esi
  801368:	74 0a                	je     801374 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  80136a:	a1 08 50 80 00       	mov    0x805008,%eax
  80136f:	8b 40 74             	mov    0x74(%eax),%eax
  801372:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801374:	85 db                	test   %ebx,%ebx
  801376:	74 0a                	je     801382 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801378:	a1 08 50 80 00       	mov    0x805008,%eax
  80137d:	8b 40 78             	mov    0x78(%eax),%eax
  801380:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801382:	a1 08 50 80 00       	mov    0x805008,%eax
  801387:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80138a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	57                   	push   %edi
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8013a3:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8013a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8013aa:	0f 44 d8             	cmove  %eax,%ebx
  8013ad:	eb 1c                	jmp    8013cb <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8013af:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013b2:	74 12                	je     8013c6 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8013b4:	50                   	push   %eax
  8013b5:	68 6a 2f 80 00       	push   $0x802f6a
  8013ba:	6a 4b                	push   $0x4b
  8013bc:	68 82 2f 80 00       	push   $0x802f82
  8013c1:	e8 cc f2 ff ff       	call   800692 <_panic>
        }	
        sys_yield();
  8013c6:	e8 09 fd ff ff       	call   8010d4 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8013cb:	ff 75 14             	pushl  0x14(%ebp)
  8013ce:	53                   	push   %ebx
  8013cf:	56                   	push   %esi
  8013d0:	57                   	push   %edi
  8013d1:	e8 aa fe ff ff       	call   801280 <sys_ipc_try_send>
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	75 d2                	jne    8013af <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8013dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013eb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013f0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013f3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013f9:	8b 52 50             	mov    0x50(%edx),%edx
  8013fc:	39 ca                	cmp    %ecx,%edx
  8013fe:	75 0d                	jne    80140d <ipc_find_env+0x28>
			return envs[i].env_id;
  801400:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801403:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801408:	8b 40 48             	mov    0x48(%eax),%eax
  80140b:	eb 0f                	jmp    80141c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80140d:	83 c0 01             	add    $0x1,%eax
  801410:	3d 00 04 00 00       	cmp    $0x400,%eax
  801415:	75 d9                	jne    8013f0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	05 00 00 00 30       	add    $0x30000000,%eax
  801429:	c1 e8 0c             	shr    $0xc,%eax
}
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
  801434:	05 00 00 00 30       	add    $0x30000000,%eax
  801439:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80143e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    

00801445 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801450:	89 c2                	mov    %eax,%edx
  801452:	c1 ea 16             	shr    $0x16,%edx
  801455:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80145c:	f6 c2 01             	test   $0x1,%dl
  80145f:	74 11                	je     801472 <fd_alloc+0x2d>
  801461:	89 c2                	mov    %eax,%edx
  801463:	c1 ea 0c             	shr    $0xc,%edx
  801466:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80146d:	f6 c2 01             	test   $0x1,%dl
  801470:	75 09                	jne    80147b <fd_alloc+0x36>
			*fd_store = fd;
  801472:	89 01                	mov    %eax,(%ecx)
			return 0;
  801474:	b8 00 00 00 00       	mov    $0x0,%eax
  801479:	eb 17                	jmp    801492 <fd_alloc+0x4d>
  80147b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801480:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801485:	75 c9                	jne    801450 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801487:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80148d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801492:	5d                   	pop    %ebp
  801493:	c3                   	ret    

00801494 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80149a:	83 f8 1f             	cmp    $0x1f,%eax
  80149d:	77 36                	ja     8014d5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80149f:	c1 e0 0c             	shl    $0xc,%eax
  8014a2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	c1 ea 16             	shr    $0x16,%edx
  8014ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014b3:	f6 c2 01             	test   $0x1,%dl
  8014b6:	74 24                	je     8014dc <fd_lookup+0x48>
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	c1 ea 0c             	shr    $0xc,%edx
  8014bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c4:	f6 c2 01             	test   $0x1,%dl
  8014c7:	74 1a                	je     8014e3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cc:	89 02                	mov    %eax,(%edx)
	return 0;
  8014ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d3:	eb 13                	jmp    8014e8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014da:	eb 0c                	jmp    8014e8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e1:	eb 05                	jmp    8014e8 <fd_lookup+0x54>
  8014e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    

008014ea <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f3:	ba 0c 30 80 00       	mov    $0x80300c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014f8:	eb 13                	jmp    80150d <dev_lookup+0x23>
  8014fa:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014fd:	39 08                	cmp    %ecx,(%eax)
  8014ff:	75 0c                	jne    80150d <dev_lookup+0x23>
			*dev = devtab[i];
  801501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801504:	89 01                	mov    %eax,(%ecx)
			return 0;
  801506:	b8 00 00 00 00       	mov    $0x0,%eax
  80150b:	eb 2e                	jmp    80153b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80150d:	8b 02                	mov    (%edx),%eax
  80150f:	85 c0                	test   %eax,%eax
  801511:	75 e7                	jne    8014fa <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801513:	a1 08 50 80 00       	mov    0x805008,%eax
  801518:	8b 40 48             	mov    0x48(%eax),%eax
  80151b:	83 ec 04             	sub    $0x4,%esp
  80151e:	51                   	push   %ecx
  80151f:	50                   	push   %eax
  801520:	68 8c 2f 80 00       	push   $0x802f8c
  801525:	e8 41 f2 ff ff       	call   80076b <cprintf>
	*dev = 0;
  80152a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	56                   	push   %esi
  801541:	53                   	push   %ebx
  801542:	83 ec 10             	sub    $0x10,%esp
  801545:	8b 75 08             	mov    0x8(%ebp),%esi
  801548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80154b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801555:	c1 e8 0c             	shr    $0xc,%eax
  801558:	50                   	push   %eax
  801559:	e8 36 ff ff ff       	call   801494 <fd_lookup>
  80155e:	83 c4 08             	add    $0x8,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 05                	js     80156a <fd_close+0x2d>
	    || fd != fd2)
  801565:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801568:	74 0c                	je     801576 <fd_close+0x39>
		return (must_exist ? r : 0);
  80156a:	84 db                	test   %bl,%bl
  80156c:	ba 00 00 00 00       	mov    $0x0,%edx
  801571:	0f 44 c2             	cmove  %edx,%eax
  801574:	eb 41                	jmp    8015b7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	ff 36                	pushl  (%esi)
  80157f:	e8 66 ff ff ff       	call   8014ea <dev_lookup>
  801584:	89 c3                	mov    %eax,%ebx
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 1a                	js     8015a7 <fd_close+0x6a>
		if (dev->dev_close)
  80158d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801590:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801593:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801598:	85 c0                	test   %eax,%eax
  80159a:	74 0b                	je     8015a7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	56                   	push   %esi
  8015a0:	ff d0                	call   *%eax
  8015a2:	89 c3                	mov    %eax,%ebx
  8015a4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	56                   	push   %esi
  8015ab:	6a 00                	push   $0x0
  8015ad:	e8 c6 fb ff ff       	call   801178 <sys_page_unmap>
	return r;
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	89 d8                	mov    %ebx,%eax
}
  8015b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ba:	5b                   	pop    %ebx
  8015bb:	5e                   	pop    %esi
  8015bc:	5d                   	pop    %ebp
  8015bd:	c3                   	ret    

008015be <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	ff 75 08             	pushl  0x8(%ebp)
  8015cb:	e8 c4 fe ff ff       	call   801494 <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 10                	js     8015e7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	6a 01                	push   $0x1
  8015dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8015df:	e8 59 ff ff ff       	call   80153d <fd_close>
  8015e4:	83 c4 10             	add    $0x10,%esp
}
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <close_all>:

void
close_all(void)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015f5:	83 ec 0c             	sub    $0xc,%esp
  8015f8:	53                   	push   %ebx
  8015f9:	e8 c0 ff ff ff       	call   8015be <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015fe:	83 c3 01             	add    $0x1,%ebx
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	83 fb 20             	cmp    $0x20,%ebx
  801607:	75 ec                	jne    8015f5 <close_all+0xc>
		close(i);
}
  801609:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 2c             	sub    $0x2c,%esp
  801617:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80161a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	ff 75 08             	pushl  0x8(%ebp)
  801621:	e8 6e fe ff ff       	call   801494 <fd_lookup>
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	0f 88 c1 00 00 00    	js     8016f2 <dup+0xe4>
		return r;
	close(newfdnum);
  801631:	83 ec 0c             	sub    $0xc,%esp
  801634:	56                   	push   %esi
  801635:	e8 84 ff ff ff       	call   8015be <close>

	newfd = INDEX2FD(newfdnum);
  80163a:	89 f3                	mov    %esi,%ebx
  80163c:	c1 e3 0c             	shl    $0xc,%ebx
  80163f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801645:	83 c4 04             	add    $0x4,%esp
  801648:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164b:	e8 de fd ff ff       	call   80142e <fd2data>
  801650:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801652:	89 1c 24             	mov    %ebx,(%esp)
  801655:	e8 d4 fd ff ff       	call   80142e <fd2data>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801660:	89 f8                	mov    %edi,%eax
  801662:	c1 e8 16             	shr    $0x16,%eax
  801665:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80166c:	a8 01                	test   $0x1,%al
  80166e:	74 37                	je     8016a7 <dup+0x99>
  801670:	89 f8                	mov    %edi,%eax
  801672:	c1 e8 0c             	shr    $0xc,%eax
  801675:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80167c:	f6 c2 01             	test   $0x1,%dl
  80167f:	74 26                	je     8016a7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801681:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	25 07 0e 00 00       	and    $0xe07,%eax
  801690:	50                   	push   %eax
  801691:	ff 75 d4             	pushl  -0x2c(%ebp)
  801694:	6a 00                	push   $0x0
  801696:	57                   	push   %edi
  801697:	6a 00                	push   $0x0
  801699:	e8 98 fa ff ff       	call   801136 <sys_page_map>
  80169e:	89 c7                	mov    %eax,%edi
  8016a0:	83 c4 20             	add    $0x20,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 2e                	js     8016d5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016aa:	89 d0                	mov    %edx,%eax
  8016ac:	c1 e8 0c             	shr    $0xc,%eax
  8016af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b6:	83 ec 0c             	sub    $0xc,%esp
  8016b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8016be:	50                   	push   %eax
  8016bf:	53                   	push   %ebx
  8016c0:	6a 00                	push   $0x0
  8016c2:	52                   	push   %edx
  8016c3:	6a 00                	push   $0x0
  8016c5:	e8 6c fa ff ff       	call   801136 <sys_page_map>
  8016ca:	89 c7                	mov    %eax,%edi
  8016cc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016cf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d1:	85 ff                	test   %edi,%edi
  8016d3:	79 1d                	jns    8016f2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	53                   	push   %ebx
  8016d9:	6a 00                	push   $0x0
  8016db:	e8 98 fa ff ff       	call   801178 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e6:	6a 00                	push   $0x0
  8016e8:	e8 8b fa ff ff       	call   801178 <sys_page_unmap>
	return r;
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	89 f8                	mov    %edi,%eax
}
  8016f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 14             	sub    $0x14,%esp
  801701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	50                   	push   %eax
  801708:	53                   	push   %ebx
  801709:	e8 86 fd ff ff       	call   801494 <fd_lookup>
  80170e:	83 c4 08             	add    $0x8,%esp
  801711:	89 c2                	mov    %eax,%edx
  801713:	85 c0                	test   %eax,%eax
  801715:	78 6d                	js     801784 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171d:	50                   	push   %eax
  80171e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801721:	ff 30                	pushl  (%eax)
  801723:	e8 c2 fd ff ff       	call   8014ea <dev_lookup>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 4c                	js     80177b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80172f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801732:	8b 42 08             	mov    0x8(%edx),%eax
  801735:	83 e0 03             	and    $0x3,%eax
  801738:	83 f8 01             	cmp    $0x1,%eax
  80173b:	75 21                	jne    80175e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80173d:	a1 08 50 80 00       	mov    0x805008,%eax
  801742:	8b 40 48             	mov    0x48(%eax),%eax
  801745:	83 ec 04             	sub    $0x4,%esp
  801748:	53                   	push   %ebx
  801749:	50                   	push   %eax
  80174a:	68 d0 2f 80 00       	push   $0x802fd0
  80174f:	e8 17 f0 ff ff       	call   80076b <cprintf>
		return -E_INVAL;
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80175c:	eb 26                	jmp    801784 <read+0x8a>
	}
	if (!dev->dev_read)
  80175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801761:	8b 40 08             	mov    0x8(%eax),%eax
  801764:	85 c0                	test   %eax,%eax
  801766:	74 17                	je     80177f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801768:	83 ec 04             	sub    $0x4,%esp
  80176b:	ff 75 10             	pushl  0x10(%ebp)
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	52                   	push   %edx
  801772:	ff d0                	call   *%eax
  801774:	89 c2                	mov    %eax,%edx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	eb 09                	jmp    801784 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	eb 05                	jmp    801784 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80177f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801784:	89 d0                	mov    %edx,%eax
  801786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	57                   	push   %edi
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	83 ec 0c             	sub    $0xc,%esp
  801794:	8b 7d 08             	mov    0x8(%ebp),%edi
  801797:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80179f:	eb 21                	jmp    8017c2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a1:	83 ec 04             	sub    $0x4,%esp
  8017a4:	89 f0                	mov    %esi,%eax
  8017a6:	29 d8                	sub    %ebx,%eax
  8017a8:	50                   	push   %eax
  8017a9:	89 d8                	mov    %ebx,%eax
  8017ab:	03 45 0c             	add    0xc(%ebp),%eax
  8017ae:	50                   	push   %eax
  8017af:	57                   	push   %edi
  8017b0:	e8 45 ff ff ff       	call   8016fa <read>
		if (m < 0)
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 10                	js     8017cc <readn+0x41>
			return m;
		if (m == 0)
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	74 0a                	je     8017ca <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c0:	01 c3                	add    %eax,%ebx
  8017c2:	39 f3                	cmp    %esi,%ebx
  8017c4:	72 db                	jb     8017a1 <readn+0x16>
  8017c6:	89 d8                	mov    %ebx,%eax
  8017c8:	eb 02                	jmp    8017cc <readn+0x41>
  8017ca:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5f                   	pop    %edi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 14             	sub    $0x14,%esp
  8017db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	53                   	push   %ebx
  8017e3:	e8 ac fc ff ff       	call   801494 <fd_lookup>
  8017e8:	83 c4 08             	add    $0x8,%esp
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 68                	js     801859 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fb:	ff 30                	pushl  (%eax)
  8017fd:	e8 e8 fc ff ff       	call   8014ea <dev_lookup>
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	78 47                	js     801850 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801810:	75 21                	jne    801833 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801812:	a1 08 50 80 00       	mov    0x805008,%eax
  801817:	8b 40 48             	mov    0x48(%eax),%eax
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	53                   	push   %ebx
  80181e:	50                   	push   %eax
  80181f:	68 ec 2f 80 00       	push   $0x802fec
  801824:	e8 42 ef ff ff       	call   80076b <cprintf>
		return -E_INVAL;
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801831:	eb 26                	jmp    801859 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801833:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801836:	8b 52 0c             	mov    0xc(%edx),%edx
  801839:	85 d2                	test   %edx,%edx
  80183b:	74 17                	je     801854 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80183d:	83 ec 04             	sub    $0x4,%esp
  801840:	ff 75 10             	pushl  0x10(%ebp)
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	50                   	push   %eax
  801847:	ff d2                	call   *%edx
  801849:	89 c2                	mov    %eax,%edx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	eb 09                	jmp    801859 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801850:	89 c2                	mov    %eax,%edx
  801852:	eb 05                	jmp    801859 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801854:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801859:	89 d0                	mov    %edx,%eax
  80185b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <seek>:

int
seek(int fdnum, off_t offset)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801866:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801869:	50                   	push   %eax
  80186a:	ff 75 08             	pushl  0x8(%ebp)
  80186d:	e8 22 fc ff ff       	call   801494 <fd_lookup>
  801872:	83 c4 08             	add    $0x8,%esp
  801875:	85 c0                	test   %eax,%eax
  801877:	78 0e                	js     801887 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801879:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80187c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801882:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	53                   	push   %ebx
  80188d:	83 ec 14             	sub    $0x14,%esp
  801890:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801893:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801896:	50                   	push   %eax
  801897:	53                   	push   %ebx
  801898:	e8 f7 fb ff ff       	call   801494 <fd_lookup>
  80189d:	83 c4 08             	add    $0x8,%esp
  8018a0:	89 c2                	mov    %eax,%edx
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 65                	js     80190b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b0:	ff 30                	pushl  (%eax)
  8018b2:	e8 33 fc ff ff       	call   8014ea <dev_lookup>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 44                	js     801902 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c5:	75 21                	jne    8018e8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018c7:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018cc:	8b 40 48             	mov    0x48(%eax),%eax
  8018cf:	83 ec 04             	sub    $0x4,%esp
  8018d2:	53                   	push   %ebx
  8018d3:	50                   	push   %eax
  8018d4:	68 ac 2f 80 00       	push   $0x802fac
  8018d9:	e8 8d ee ff ff       	call   80076b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e6:	eb 23                	jmp    80190b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018eb:	8b 52 18             	mov    0x18(%edx),%edx
  8018ee:	85 d2                	test   %edx,%edx
  8018f0:	74 14                	je     801906 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	ff 75 0c             	pushl  0xc(%ebp)
  8018f8:	50                   	push   %eax
  8018f9:	ff d2                	call   *%edx
  8018fb:	89 c2                	mov    %eax,%edx
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	eb 09                	jmp    80190b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801902:	89 c2                	mov    %eax,%edx
  801904:	eb 05                	jmp    80190b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801906:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80190b:	89 d0                	mov    %edx,%eax
  80190d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801910:	c9                   	leave  
  801911:	c3                   	ret    

00801912 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	53                   	push   %ebx
  801916:	83 ec 14             	sub    $0x14,%esp
  801919:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191f:	50                   	push   %eax
  801920:	ff 75 08             	pushl  0x8(%ebp)
  801923:	e8 6c fb ff ff       	call   801494 <fd_lookup>
  801928:	83 c4 08             	add    $0x8,%esp
  80192b:	89 c2                	mov    %eax,%edx
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 58                	js     801989 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801937:	50                   	push   %eax
  801938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193b:	ff 30                	pushl  (%eax)
  80193d:	e8 a8 fb ff ff       	call   8014ea <dev_lookup>
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	78 37                	js     801980 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801950:	74 32                	je     801984 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801952:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801955:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80195c:	00 00 00 
	stat->st_isdir = 0;
  80195f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801966:	00 00 00 
	stat->st_dev = dev;
  801969:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	53                   	push   %ebx
  801973:	ff 75 f0             	pushl  -0x10(%ebp)
  801976:	ff 50 14             	call   *0x14(%eax)
  801979:	89 c2                	mov    %eax,%edx
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	eb 09                	jmp    801989 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801980:	89 c2                	mov    %eax,%edx
  801982:	eb 05                	jmp    801989 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801984:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801989:	89 d0                	mov    %edx,%eax
  80198b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801995:	83 ec 08             	sub    $0x8,%esp
  801998:	6a 00                	push   $0x0
  80199a:	ff 75 08             	pushl  0x8(%ebp)
  80199d:	e8 e7 01 00 00       	call   801b89 <open>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 1b                	js     8019c6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	ff 75 0c             	pushl  0xc(%ebp)
  8019b1:	50                   	push   %eax
  8019b2:	e8 5b ff ff ff       	call   801912 <fstat>
  8019b7:	89 c6                	mov    %eax,%esi
	close(fd);
  8019b9:	89 1c 24             	mov    %ebx,(%esp)
  8019bc:	e8 fd fb ff ff       	call   8015be <close>
	return r;
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	89 f0                	mov    %esi,%eax
}
  8019c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c9:	5b                   	pop    %ebx
  8019ca:	5e                   	pop    %esi
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    

008019cd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	89 c6                	mov    %eax,%esi
  8019d4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019d6:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019dd:	75 12                	jne    8019f1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	6a 01                	push   $0x1
  8019e4:	e8 fc f9 ff ff       	call   8013e5 <ipc_find_env>
  8019e9:	a3 00 50 80 00       	mov    %eax,0x805000
  8019ee:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019f1:	6a 07                	push   $0x7
  8019f3:	68 00 60 80 00       	push   $0x806000
  8019f8:	56                   	push   %esi
  8019f9:	ff 35 00 50 80 00    	pushl  0x805000
  8019ff:	e8 8d f9 ff ff       	call   801391 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a04:	83 c4 0c             	add    $0xc,%esp
  801a07:	6a 00                	push   $0x0
  801a09:	53                   	push   %ebx
  801a0a:	6a 00                	push   $0x0
  801a0c:	e8 13 f9 ff ff       	call   801324 <ipc_recv>
}
  801a11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a14:	5b                   	pop    %ebx
  801a15:	5e                   	pop    %esi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	8b 40 0c             	mov    0xc(%eax),%eax
  801a24:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2c:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	b8 02 00 00 00       	mov    $0x2,%eax
  801a3b:	e8 8d ff ff ff       	call   8019cd <fsipc>
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4e:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a53:	ba 00 00 00 00       	mov    $0x0,%edx
  801a58:	b8 06 00 00 00       	mov    $0x6,%eax
  801a5d:	e8 6b ff ff ff       	call   8019cd <fsipc>
}
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	53                   	push   %ebx
  801a68:	83 ec 04             	sub    $0x4,%esp
  801a6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	8b 40 0c             	mov    0xc(%eax),%eax
  801a74:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a79:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a83:	e8 45 ff ff ff       	call   8019cd <fsipc>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 2c                	js     801ab8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a8c:	83 ec 08             	sub    $0x8,%esp
  801a8f:	68 00 60 80 00       	push   $0x806000
  801a94:	53                   	push   %ebx
  801a95:	e8 56 f2 ff ff       	call   800cf0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a9a:	a1 80 60 80 00       	mov    0x806080,%eax
  801a9f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aa5:	a1 84 60 80 00       	mov    0x806084,%eax
  801aaa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 08             	sub    $0x8,%esp
  801ac4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801ac7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801acc:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801ad1:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ad4:	53                   	push   %ebx
  801ad5:	ff 75 0c             	pushl  0xc(%ebp)
  801ad8:	68 08 60 80 00       	push   $0x806008
  801add:	e8 a0 f3 ff ff       	call   800e82 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae8:	a3 00 60 80 00       	mov    %eax,0x806000
 	fsipcbuf.write.req_n = n;
  801aed:	89 1d 04 60 80 00    	mov    %ebx,0x806004

 	return fsipc(FSREQ_WRITE, NULL);
  801af3:	ba 00 00 00 00       	mov    $0x0,%edx
  801af8:	b8 04 00 00 00       	mov    $0x4,%eax
  801afd:	e8 cb fe ff ff       	call   8019cd <fsipc>
	//panic("devfile_write not implemented");
}
  801b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	8b 40 0c             	mov    0xc(%eax),%eax
  801b15:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b1a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b20:	ba 00 00 00 00       	mov    $0x0,%edx
  801b25:	b8 03 00 00 00       	mov    $0x3,%eax
  801b2a:	e8 9e fe ff ff       	call   8019cd <fsipc>
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	85 c0                	test   %eax,%eax
  801b33:	78 4b                	js     801b80 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b35:	39 c6                	cmp    %eax,%esi
  801b37:	73 16                	jae    801b4f <devfile_read+0x48>
  801b39:	68 20 30 80 00       	push   $0x803020
  801b3e:	68 27 30 80 00       	push   $0x803027
  801b43:	6a 7c                	push   $0x7c
  801b45:	68 3c 30 80 00       	push   $0x80303c
  801b4a:	e8 43 eb ff ff       	call   800692 <_panic>
	assert(r <= PGSIZE);
  801b4f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b54:	7e 16                	jle    801b6c <devfile_read+0x65>
  801b56:	68 47 30 80 00       	push   $0x803047
  801b5b:	68 27 30 80 00       	push   $0x803027
  801b60:	6a 7d                	push   $0x7d
  801b62:	68 3c 30 80 00       	push   $0x80303c
  801b67:	e8 26 eb ff ff       	call   800692 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b6c:	83 ec 04             	sub    $0x4,%esp
  801b6f:	50                   	push   %eax
  801b70:	68 00 60 80 00       	push   $0x806000
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	e8 05 f3 ff ff       	call   800e82 <memmove>
	return r;
  801b7d:	83 c4 10             	add    $0x10,%esp
}
  801b80:	89 d8                	mov    %ebx,%eax
  801b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 20             	sub    $0x20,%esp
  801b90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b93:	53                   	push   %ebx
  801b94:	e8 1e f1 ff ff       	call   800cb7 <strlen>
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ba1:	7f 67                	jg     801c0a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba9:	50                   	push   %eax
  801baa:	e8 96 f8 ff ff       	call   801445 <fd_alloc>
  801baf:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 57                	js     801c0f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bb8:	83 ec 08             	sub    $0x8,%esp
  801bbb:	53                   	push   %ebx
  801bbc:	68 00 60 80 00       	push   $0x806000
  801bc1:	e8 2a f1 ff ff       	call   800cf0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc9:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	e8 f2 fd ff ff       	call   8019cd <fsipc>
  801bdb:	89 c3                	mov    %eax,%ebx
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	79 14                	jns    801bf8 <open+0x6f>
		fd_close(fd, 0);
  801be4:	83 ec 08             	sub    $0x8,%esp
  801be7:	6a 00                	push   $0x0
  801be9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bec:	e8 4c f9 ff ff       	call   80153d <fd_close>
		return r;
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	89 da                	mov    %ebx,%edx
  801bf6:	eb 17                	jmp    801c0f <open+0x86>
	}

	return fd2num(fd);
  801bf8:	83 ec 0c             	sub    $0xc,%esp
  801bfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfe:	e8 1b f8 ff ff       	call   80141e <fd2num>
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	eb 05                	jmp    801c0f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c0a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c0f:	89 d0                	mov    %edx,%eax
  801c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c21:	b8 08 00 00 00       	mov    $0x8,%eax
  801c26:	e8 a2 fd ff ff       	call   8019cd <fsipc>
}
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c33:	68 53 30 80 00       	push   $0x803053
  801c38:	ff 75 0c             	pushl  0xc(%ebp)
  801c3b:	e8 b0 f0 ff ff       	call   800cf0 <strcpy>
	return 0;
}
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	53                   	push   %ebx
  801c4b:	83 ec 10             	sub    $0x10,%esp
  801c4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c51:	53                   	push   %ebx
  801c52:	e8 1c 09 00 00       	call   802573 <pageref>
  801c57:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c5a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c5f:	83 f8 01             	cmp    $0x1,%eax
  801c62:	75 10                	jne    801c74 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c64:	83 ec 0c             	sub    $0xc,%esp
  801c67:	ff 73 0c             	pushl  0xc(%ebx)
  801c6a:	e8 c0 02 00 00       	call   801f2f <nsipc_close>
  801c6f:	89 c2                	mov    %eax,%edx
  801c71:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c74:	89 d0                	mov    %edx,%eax
  801c76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c81:	6a 00                	push   $0x0
  801c83:	ff 75 10             	pushl  0x10(%ebp)
  801c86:	ff 75 0c             	pushl  0xc(%ebp)
  801c89:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8c:	ff 70 0c             	pushl  0xc(%eax)
  801c8f:	e8 78 03 00 00       	call   80200c <nsipc_send>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c9c:	6a 00                	push   $0x0
  801c9e:	ff 75 10             	pushl  0x10(%ebp)
  801ca1:	ff 75 0c             	pushl  0xc(%ebp)
  801ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca7:	ff 70 0c             	pushl  0xc(%eax)
  801caa:	e8 f1 02 00 00       	call   801fa0 <nsipc_recv>
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cb7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cba:	52                   	push   %edx
  801cbb:	50                   	push   %eax
  801cbc:	e8 d3 f7 ff ff       	call   801494 <fd_lookup>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 17                	js     801cdf <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccb:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801cd1:	39 08                	cmp    %ecx,(%eax)
  801cd3:	75 05                	jne    801cda <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801cd5:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd8:	eb 05                	jmp    801cdf <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801cda:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 1c             	sub    $0x1c,%esp
  801ce9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cee:	50                   	push   %eax
  801cef:	e8 51 f7 ff ff       	call   801445 <fd_alloc>
  801cf4:	89 c3                	mov    %eax,%ebx
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 1b                	js     801d18 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	68 07 04 00 00       	push   $0x407
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 e4 f3 ff ff       	call   8010f3 <sys_page_alloc>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	85 c0                	test   %eax,%eax
  801d16:	79 10                	jns    801d28 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	56                   	push   %esi
  801d1c:	e8 0e 02 00 00       	call   801f2f <nsipc_close>
		return r;
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	89 d8                	mov    %ebx,%eax
  801d26:	eb 24                	jmp    801d4c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d28:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d31:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d36:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d3d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	50                   	push   %eax
  801d44:	e8 d5 f6 ff ff       	call   80141e <fd2num>
  801d49:	83 c4 10             	add    $0x10,%esp
}
  801d4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	e8 50 ff ff ff       	call   801cb1 <fd2sockid>
		return r;
  801d61:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 1f                	js     801d86 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d67:	83 ec 04             	sub    $0x4,%esp
  801d6a:	ff 75 10             	pushl  0x10(%ebp)
  801d6d:	ff 75 0c             	pushl  0xc(%ebp)
  801d70:	50                   	push   %eax
  801d71:	e8 12 01 00 00       	call   801e88 <nsipc_accept>
  801d76:	83 c4 10             	add    $0x10,%esp
		return r;
  801d79:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	78 07                	js     801d86 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d7f:	e8 5d ff ff ff       	call   801ce1 <alloc_sockfd>
  801d84:	89 c1                	mov    %eax,%ecx
}
  801d86:	89 c8                	mov    %ecx,%eax
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	e8 19 ff ff ff       	call   801cb1 <fd2sockid>
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	78 12                	js     801dae <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	ff 75 10             	pushl  0x10(%ebp)
  801da2:	ff 75 0c             	pushl  0xc(%ebp)
  801da5:	50                   	push   %eax
  801da6:	e8 2d 01 00 00       	call   801ed8 <nsipc_bind>
  801dab:	83 c4 10             	add    $0x10,%esp
}
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <shutdown>:

int
shutdown(int s, int how)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	e8 f3 fe ff ff       	call   801cb1 <fd2sockid>
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	78 0f                	js     801dd1 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801dc2:	83 ec 08             	sub    $0x8,%esp
  801dc5:	ff 75 0c             	pushl  0xc(%ebp)
  801dc8:	50                   	push   %eax
  801dc9:	e8 3f 01 00 00       	call   801f0d <nsipc_shutdown>
  801dce:	83 c4 10             	add    $0x10,%esp
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	e8 d0 fe ff ff       	call   801cb1 <fd2sockid>
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 12                	js     801df7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	ff 75 10             	pushl  0x10(%ebp)
  801deb:	ff 75 0c             	pushl  0xc(%ebp)
  801dee:	50                   	push   %eax
  801def:	e8 55 01 00 00       	call   801f49 <nsipc_connect>
  801df4:	83 c4 10             	add    $0x10,%esp
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    

00801df9 <listen>:

int
listen(int s, int backlog)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dff:	8b 45 08             	mov    0x8(%ebp),%eax
  801e02:	e8 aa fe ff ff       	call   801cb1 <fd2sockid>
  801e07:	85 c0                	test   %eax,%eax
  801e09:	78 0f                	js     801e1a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e0b:	83 ec 08             	sub    $0x8,%esp
  801e0e:	ff 75 0c             	pushl  0xc(%ebp)
  801e11:	50                   	push   %eax
  801e12:	e8 67 01 00 00       	call   801f7e <nsipc_listen>
  801e17:	83 c4 10             	add    $0x10,%esp
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e22:	ff 75 10             	pushl  0x10(%ebp)
  801e25:	ff 75 0c             	pushl  0xc(%ebp)
  801e28:	ff 75 08             	pushl  0x8(%ebp)
  801e2b:	e8 3a 02 00 00       	call   80206a <nsipc_socket>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 05                	js     801e3c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e37:	e8 a5 fe ff ff       	call   801ce1 <alloc_sockfd>
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 04             	sub    $0x4,%esp
  801e45:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e47:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801e4e:	75 12                	jne    801e62 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e50:	83 ec 0c             	sub    $0xc,%esp
  801e53:	6a 02                	push   $0x2
  801e55:	e8 8b f5 ff ff       	call   8013e5 <ipc_find_env>
  801e5a:	a3 04 50 80 00       	mov    %eax,0x805004
  801e5f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e62:	6a 07                	push   $0x7
  801e64:	68 00 70 80 00       	push   $0x807000
  801e69:	53                   	push   %ebx
  801e6a:	ff 35 04 50 80 00    	pushl  0x805004
  801e70:	e8 1c f5 ff ff       	call   801391 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e75:	83 c4 0c             	add    $0xc,%esp
  801e78:	6a 00                	push   $0x0
  801e7a:	6a 00                	push   $0x0
  801e7c:	6a 00                	push   $0x0
  801e7e:	e8 a1 f4 ff ff       	call   801324 <ipc_recv>
}
  801e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	56                   	push   %esi
  801e8c:	53                   	push   %ebx
  801e8d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e98:	8b 06                	mov    (%esi),%eax
  801e9a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e9f:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea4:	e8 95 ff ff ff       	call   801e3e <nsipc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	85 c0                	test   %eax,%eax
  801ead:	78 20                	js     801ecf <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801eaf:	83 ec 04             	sub    $0x4,%esp
  801eb2:	ff 35 10 70 80 00    	pushl  0x807010
  801eb8:	68 00 70 80 00       	push   $0x807000
  801ebd:	ff 75 0c             	pushl  0xc(%ebp)
  801ec0:	e8 bd ef ff ff       	call   800e82 <memmove>
		*addrlen = ret->ret_addrlen;
  801ec5:	a1 10 70 80 00       	mov    0x807010,%eax
  801eca:	89 06                	mov    %eax,(%esi)
  801ecc:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ecf:	89 d8                	mov    %ebx,%eax
  801ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	53                   	push   %ebx
  801edc:	83 ec 08             	sub    $0x8,%esp
  801edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801eea:	53                   	push   %ebx
  801eeb:	ff 75 0c             	pushl  0xc(%ebp)
  801eee:	68 04 70 80 00       	push   $0x807004
  801ef3:	e8 8a ef ff ff       	call   800e82 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ef8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801efe:	b8 02 00 00 00       	mov    $0x2,%eax
  801f03:	e8 36 ff ff ff       	call   801e3e <nsipc>
}
  801f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0b:	c9                   	leave  
  801f0c:	c3                   	ret    

00801f0d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f13:	8b 45 08             	mov    0x8(%ebp),%eax
  801f16:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f23:	b8 03 00 00 00       	mov    $0x3,%eax
  801f28:	e8 11 ff ff ff       	call   801e3e <nsipc>
}
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    

00801f2f <nsipc_close>:

int
nsipc_close(int s)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f3d:	b8 04 00 00 00       	mov    $0x4,%eax
  801f42:	e8 f7 fe ff ff       	call   801e3e <nsipc>
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	53                   	push   %ebx
  801f4d:	83 ec 08             	sub    $0x8,%esp
  801f50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f53:	8b 45 08             	mov    0x8(%ebp),%eax
  801f56:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f5b:	53                   	push   %ebx
  801f5c:	ff 75 0c             	pushl  0xc(%ebp)
  801f5f:	68 04 70 80 00       	push   $0x807004
  801f64:	e8 19 ef ff ff       	call   800e82 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f69:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801f6f:	b8 05 00 00 00       	mov    $0x5,%eax
  801f74:	e8 c5 fe ff ff       	call   801e3e <nsipc>
}
  801f79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7c:	c9                   	leave  
  801f7d:	c3                   	ret    

00801f7e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f84:	8b 45 08             	mov    0x8(%ebp),%eax
  801f87:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801f94:	b8 06 00 00 00       	mov    $0x6,%eax
  801f99:	e8 a0 fe ff ff       	call   801e3e <nsipc>
}
  801f9e:	c9                   	leave  
  801f9f:	c3                   	ret    

00801fa0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	56                   	push   %esi
  801fa4:	53                   	push   %ebx
  801fa5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fab:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801fb0:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801fb6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb9:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801fbe:	b8 07 00 00 00       	mov    $0x7,%eax
  801fc3:	e8 76 fe ff ff       	call   801e3e <nsipc>
  801fc8:	89 c3                	mov    %eax,%ebx
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 35                	js     802003 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801fce:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801fd3:	7f 04                	jg     801fd9 <nsipc_recv+0x39>
  801fd5:	39 c6                	cmp    %eax,%esi
  801fd7:	7d 16                	jge    801fef <nsipc_recv+0x4f>
  801fd9:	68 5f 30 80 00       	push   $0x80305f
  801fde:	68 27 30 80 00       	push   $0x803027
  801fe3:	6a 62                	push   $0x62
  801fe5:	68 74 30 80 00       	push   $0x803074
  801fea:	e8 a3 e6 ff ff       	call   800692 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fef:	83 ec 04             	sub    $0x4,%esp
  801ff2:	50                   	push   %eax
  801ff3:	68 00 70 80 00       	push   $0x807000
  801ff8:	ff 75 0c             	pushl  0xc(%ebp)
  801ffb:	e8 82 ee ff ff       	call   800e82 <memmove>
  802000:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802003:	89 d8                	mov    %ebx,%eax
  802005:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    

0080200c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	53                   	push   %ebx
  802010:	83 ec 04             	sub    $0x4,%esp
  802013:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802016:	8b 45 08             	mov    0x8(%ebp),%eax
  802019:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80201e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802024:	7e 16                	jle    80203c <nsipc_send+0x30>
  802026:	68 80 30 80 00       	push   $0x803080
  80202b:	68 27 30 80 00       	push   $0x803027
  802030:	6a 6d                	push   $0x6d
  802032:	68 74 30 80 00       	push   $0x803074
  802037:	e8 56 e6 ff ff       	call   800692 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80203c:	83 ec 04             	sub    $0x4,%esp
  80203f:	53                   	push   %ebx
  802040:	ff 75 0c             	pushl  0xc(%ebp)
  802043:	68 0c 70 80 00       	push   $0x80700c
  802048:	e8 35 ee ff ff       	call   800e82 <memmove>
	nsipcbuf.send.req_size = size;
  80204d:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802053:	8b 45 14             	mov    0x14(%ebp),%eax
  802056:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80205b:	b8 08 00 00 00       	mov    $0x8,%eax
  802060:	e8 d9 fd ff ff       	call   801e3e <nsipc>
}
  802065:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802068:	c9                   	leave  
  802069:	c3                   	ret    

0080206a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802070:	8b 45 08             	mov    0x8(%ebp),%eax
  802073:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207b:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802080:	8b 45 10             	mov    0x10(%ebp),%eax
  802083:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802088:	b8 09 00 00 00       	mov    $0x9,%eax
  80208d:	e8 ac fd ff ff       	call   801e3e <nsipc>
}
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	56                   	push   %esi
  802098:	53                   	push   %ebx
  802099:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80209c:	83 ec 0c             	sub    $0xc,%esp
  80209f:	ff 75 08             	pushl  0x8(%ebp)
  8020a2:	e8 87 f3 ff ff       	call   80142e <fd2data>
  8020a7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020a9:	83 c4 08             	add    $0x8,%esp
  8020ac:	68 8c 30 80 00       	push   $0x80308c
  8020b1:	53                   	push   %ebx
  8020b2:	e8 39 ec ff ff       	call   800cf0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020b7:	8b 46 04             	mov    0x4(%esi),%eax
  8020ba:	2b 06                	sub    (%esi),%eax
  8020bc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020c9:	00 00 00 
	stat->st_dev = &devpipe;
  8020cc:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  8020d3:	40 80 00 
	return 0;
}
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5e                   	pop    %esi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    

008020e2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	53                   	push   %ebx
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020ec:	53                   	push   %ebx
  8020ed:	6a 00                	push   $0x0
  8020ef:	e8 84 f0 ff ff       	call   801178 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020f4:	89 1c 24             	mov    %ebx,(%esp)
  8020f7:	e8 32 f3 ff ff       	call   80142e <fd2data>
  8020fc:	83 c4 08             	add    $0x8,%esp
  8020ff:	50                   	push   %eax
  802100:	6a 00                	push   $0x0
  802102:	e8 71 f0 ff ff       	call   801178 <sys_page_unmap>
}
  802107:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	57                   	push   %edi
  802110:	56                   	push   %esi
  802111:	53                   	push   %ebx
  802112:	83 ec 1c             	sub    $0x1c,%esp
  802115:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802118:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80211a:	a1 08 50 80 00       	mov    0x805008,%eax
  80211f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802122:	83 ec 0c             	sub    $0xc,%esp
  802125:	ff 75 e0             	pushl  -0x20(%ebp)
  802128:	e8 46 04 00 00       	call   802573 <pageref>
  80212d:	89 c3                	mov    %eax,%ebx
  80212f:	89 3c 24             	mov    %edi,(%esp)
  802132:	e8 3c 04 00 00       	call   802573 <pageref>
  802137:	83 c4 10             	add    $0x10,%esp
  80213a:	39 c3                	cmp    %eax,%ebx
  80213c:	0f 94 c1             	sete   %cl
  80213f:	0f b6 c9             	movzbl %cl,%ecx
  802142:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802145:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80214b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80214e:	39 ce                	cmp    %ecx,%esi
  802150:	74 1b                	je     80216d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802152:	39 c3                	cmp    %eax,%ebx
  802154:	75 c4                	jne    80211a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802156:	8b 42 58             	mov    0x58(%edx),%eax
  802159:	ff 75 e4             	pushl  -0x1c(%ebp)
  80215c:	50                   	push   %eax
  80215d:	56                   	push   %esi
  80215e:	68 93 30 80 00       	push   $0x803093
  802163:	e8 03 e6 ff ff       	call   80076b <cprintf>
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	eb ad                	jmp    80211a <_pipeisclosed+0xe>
	}
}
  80216d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    

00802178 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	57                   	push   %edi
  80217c:	56                   	push   %esi
  80217d:	53                   	push   %ebx
  80217e:	83 ec 28             	sub    $0x28,%esp
  802181:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802184:	56                   	push   %esi
  802185:	e8 a4 f2 ff ff       	call   80142e <fd2data>
  80218a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80218c:	83 c4 10             	add    $0x10,%esp
  80218f:	bf 00 00 00 00       	mov    $0x0,%edi
  802194:	eb 4b                	jmp    8021e1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802196:	89 da                	mov    %ebx,%edx
  802198:	89 f0                	mov    %esi,%eax
  80219a:	e8 6d ff ff ff       	call   80210c <_pipeisclosed>
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	75 48                	jne    8021eb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021a3:	e8 2c ef ff ff       	call   8010d4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8021ab:	8b 0b                	mov    (%ebx),%ecx
  8021ad:	8d 51 20             	lea    0x20(%ecx),%edx
  8021b0:	39 d0                	cmp    %edx,%eax
  8021b2:	73 e2                	jae    802196 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021b7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021bb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	c1 fa 1f             	sar    $0x1f,%edx
  8021c3:	89 d1                	mov    %edx,%ecx
  8021c5:	c1 e9 1b             	shr    $0x1b,%ecx
  8021c8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8021cb:	83 e2 1f             	and    $0x1f,%edx
  8021ce:	29 ca                	sub    %ecx,%edx
  8021d0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8021d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021d8:	83 c0 01             	add    $0x1,%eax
  8021db:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021de:	83 c7 01             	add    $0x1,%edi
  8021e1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021e4:	75 c2                	jne    8021a8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8021e9:	eb 05                	jmp    8021f0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021eb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    

008021f8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	57                   	push   %edi
  8021fc:	56                   	push   %esi
  8021fd:	53                   	push   %ebx
  8021fe:	83 ec 18             	sub    $0x18,%esp
  802201:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802204:	57                   	push   %edi
  802205:	e8 24 f2 ff ff       	call   80142e <fd2data>
  80220a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802214:	eb 3d                	jmp    802253 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802216:	85 db                	test   %ebx,%ebx
  802218:	74 04                	je     80221e <devpipe_read+0x26>
				return i;
  80221a:	89 d8                	mov    %ebx,%eax
  80221c:	eb 44                	jmp    802262 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80221e:	89 f2                	mov    %esi,%edx
  802220:	89 f8                	mov    %edi,%eax
  802222:	e8 e5 fe ff ff       	call   80210c <_pipeisclosed>
  802227:	85 c0                	test   %eax,%eax
  802229:	75 32                	jne    80225d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80222b:	e8 a4 ee ff ff       	call   8010d4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802230:	8b 06                	mov    (%esi),%eax
  802232:	3b 46 04             	cmp    0x4(%esi),%eax
  802235:	74 df                	je     802216 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802237:	99                   	cltd   
  802238:	c1 ea 1b             	shr    $0x1b,%edx
  80223b:	01 d0                	add    %edx,%eax
  80223d:	83 e0 1f             	and    $0x1f,%eax
  802240:	29 d0                	sub    %edx,%eax
  802242:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80224a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80224d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802250:	83 c3 01             	add    $0x1,%ebx
  802253:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802256:	75 d8                	jne    802230 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802258:	8b 45 10             	mov    0x10(%ebp),%eax
  80225b:	eb 05                	jmp    802262 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80225d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5f                   	pop    %edi
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    

0080226a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	56                   	push   %esi
  80226e:	53                   	push   %ebx
  80226f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802275:	50                   	push   %eax
  802276:	e8 ca f1 ff ff       	call   801445 <fd_alloc>
  80227b:	83 c4 10             	add    $0x10,%esp
  80227e:	89 c2                	mov    %eax,%edx
  802280:	85 c0                	test   %eax,%eax
  802282:	0f 88 2c 01 00 00    	js     8023b4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802288:	83 ec 04             	sub    $0x4,%esp
  80228b:	68 07 04 00 00       	push   $0x407
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	6a 00                	push   $0x0
  802295:	e8 59 ee ff ff       	call   8010f3 <sys_page_alloc>
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	89 c2                	mov    %eax,%edx
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	0f 88 0d 01 00 00    	js     8023b4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022a7:	83 ec 0c             	sub    $0xc,%esp
  8022aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022ad:	50                   	push   %eax
  8022ae:	e8 92 f1 ff ff       	call   801445 <fd_alloc>
  8022b3:	89 c3                	mov    %eax,%ebx
  8022b5:	83 c4 10             	add    $0x10,%esp
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	0f 88 e2 00 00 00    	js     8023a2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c0:	83 ec 04             	sub    $0x4,%esp
  8022c3:	68 07 04 00 00       	push   $0x407
  8022c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8022cb:	6a 00                	push   $0x0
  8022cd:	e8 21 ee ff ff       	call   8010f3 <sys_page_alloc>
  8022d2:	89 c3                	mov    %eax,%ebx
  8022d4:	83 c4 10             	add    $0x10,%esp
  8022d7:	85 c0                	test   %eax,%eax
  8022d9:	0f 88 c3 00 00 00    	js     8023a2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022df:	83 ec 0c             	sub    $0xc,%esp
  8022e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e5:	e8 44 f1 ff ff       	call   80142e <fd2data>
  8022ea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ec:	83 c4 0c             	add    $0xc,%esp
  8022ef:	68 07 04 00 00       	push   $0x407
  8022f4:	50                   	push   %eax
  8022f5:	6a 00                	push   $0x0
  8022f7:	e8 f7 ed ff ff       	call   8010f3 <sys_page_alloc>
  8022fc:	89 c3                	mov    %eax,%ebx
  8022fe:	83 c4 10             	add    $0x10,%esp
  802301:	85 c0                	test   %eax,%eax
  802303:	0f 88 89 00 00 00    	js     802392 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802309:	83 ec 0c             	sub    $0xc,%esp
  80230c:	ff 75 f0             	pushl  -0x10(%ebp)
  80230f:	e8 1a f1 ff ff       	call   80142e <fd2data>
  802314:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80231b:	50                   	push   %eax
  80231c:	6a 00                	push   $0x0
  80231e:	56                   	push   %esi
  80231f:	6a 00                	push   $0x0
  802321:	e8 10 ee ff ff       	call   801136 <sys_page_map>
  802326:	89 c3                	mov    %eax,%ebx
  802328:	83 c4 20             	add    $0x20,%esp
  80232b:	85 c0                	test   %eax,%eax
  80232d:	78 55                	js     802384 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80232f:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802338:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80233a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802344:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80234a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80234d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80234f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802352:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802359:	83 ec 0c             	sub    $0xc,%esp
  80235c:	ff 75 f4             	pushl  -0xc(%ebp)
  80235f:	e8 ba f0 ff ff       	call   80141e <fd2num>
  802364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802367:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802369:	83 c4 04             	add    $0x4,%esp
  80236c:	ff 75 f0             	pushl  -0x10(%ebp)
  80236f:	e8 aa f0 ff ff       	call   80141e <fd2num>
  802374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802377:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	ba 00 00 00 00       	mov    $0x0,%edx
  802382:	eb 30                	jmp    8023b4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802384:	83 ec 08             	sub    $0x8,%esp
  802387:	56                   	push   %esi
  802388:	6a 00                	push   $0x0
  80238a:	e8 e9 ed ff ff       	call   801178 <sys_page_unmap>
  80238f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802392:	83 ec 08             	sub    $0x8,%esp
  802395:	ff 75 f0             	pushl  -0x10(%ebp)
  802398:	6a 00                	push   $0x0
  80239a:	e8 d9 ed ff ff       	call   801178 <sys_page_unmap>
  80239f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023a2:	83 ec 08             	sub    $0x8,%esp
  8023a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a8:	6a 00                	push   $0x0
  8023aa:	e8 c9 ed ff ff       	call   801178 <sys_page_unmap>
  8023af:	83 c4 10             	add    $0x10,%esp
  8023b2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8023b4:	89 d0                	mov    %edx,%eax
  8023b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023b9:	5b                   	pop    %ebx
  8023ba:	5e                   	pop    %esi
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    

008023bd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023bd:	55                   	push   %ebp
  8023be:	89 e5                	mov    %esp,%ebp
  8023c0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c6:	50                   	push   %eax
  8023c7:	ff 75 08             	pushl  0x8(%ebp)
  8023ca:	e8 c5 f0 ff ff       	call   801494 <fd_lookup>
  8023cf:	83 c4 10             	add    $0x10,%esp
  8023d2:	85 c0                	test   %eax,%eax
  8023d4:	78 18                	js     8023ee <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023d6:	83 ec 0c             	sub    $0xc,%esp
  8023d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8023dc:	e8 4d f0 ff ff       	call   80142e <fd2data>
	return _pipeisclosed(fd, p);
  8023e1:	89 c2                	mov    %eax,%edx
  8023e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e6:	e8 21 fd ff ff       	call   80210c <_pipeisclosed>
  8023eb:	83 c4 10             	add    $0x10,%esp
}
  8023ee:	c9                   	leave  
  8023ef:	c3                   	ret    

008023f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023f0:	55                   	push   %ebp
  8023f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    

008023fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023fa:	55                   	push   %ebp
  8023fb:	89 e5                	mov    %esp,%ebp
  8023fd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802400:	68 ab 30 80 00       	push   $0x8030ab
  802405:	ff 75 0c             	pushl  0xc(%ebp)
  802408:	e8 e3 e8 ff ff       	call   800cf0 <strcpy>
	return 0;
}
  80240d:	b8 00 00 00 00       	mov    $0x0,%eax
  802412:	c9                   	leave  
  802413:	c3                   	ret    

00802414 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802414:	55                   	push   %ebp
  802415:	89 e5                	mov    %esp,%ebp
  802417:	57                   	push   %edi
  802418:	56                   	push   %esi
  802419:	53                   	push   %ebx
  80241a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802420:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802425:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80242b:	eb 2d                	jmp    80245a <devcons_write+0x46>
		m = n - tot;
  80242d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802430:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802432:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802435:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80243a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80243d:	83 ec 04             	sub    $0x4,%esp
  802440:	53                   	push   %ebx
  802441:	03 45 0c             	add    0xc(%ebp),%eax
  802444:	50                   	push   %eax
  802445:	57                   	push   %edi
  802446:	e8 37 ea ff ff       	call   800e82 <memmove>
		sys_cputs(buf, m);
  80244b:	83 c4 08             	add    $0x8,%esp
  80244e:	53                   	push   %ebx
  80244f:	57                   	push   %edi
  802450:	e8 e2 eb ff ff       	call   801037 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802455:	01 de                	add    %ebx,%esi
  802457:	83 c4 10             	add    $0x10,%esp
  80245a:	89 f0                	mov    %esi,%eax
  80245c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80245f:	72 cc                	jb     80242d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802461:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5f                   	pop    %edi
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    

00802469 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802469:	55                   	push   %ebp
  80246a:	89 e5                	mov    %esp,%ebp
  80246c:	83 ec 08             	sub    $0x8,%esp
  80246f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802474:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802478:	74 2a                	je     8024a4 <devcons_read+0x3b>
  80247a:	eb 05                	jmp    802481 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80247c:	e8 53 ec ff ff       	call   8010d4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802481:	e8 cf eb ff ff       	call   801055 <sys_cgetc>
  802486:	85 c0                	test   %eax,%eax
  802488:	74 f2                	je     80247c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80248a:	85 c0                	test   %eax,%eax
  80248c:	78 16                	js     8024a4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80248e:	83 f8 04             	cmp    $0x4,%eax
  802491:	74 0c                	je     80249f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802493:	8b 55 0c             	mov    0xc(%ebp),%edx
  802496:	88 02                	mov    %al,(%edx)
	return 1;
  802498:	b8 01 00 00 00       	mov    $0x1,%eax
  80249d:	eb 05                	jmp    8024a4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80249f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024a4:	c9                   	leave  
  8024a5:	c3                   	ret    

008024a6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024a6:	55                   	push   %ebp
  8024a7:	89 e5                	mov    %esp,%ebp
  8024a9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8024af:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024b2:	6a 01                	push   $0x1
  8024b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024b7:	50                   	push   %eax
  8024b8:	e8 7a eb ff ff       	call   801037 <sys_cputs>
}
  8024bd:	83 c4 10             	add    $0x10,%esp
  8024c0:	c9                   	leave  
  8024c1:	c3                   	ret    

008024c2 <getchar>:

int
getchar(void)
{
  8024c2:	55                   	push   %ebp
  8024c3:	89 e5                	mov    %esp,%ebp
  8024c5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024c8:	6a 01                	push   $0x1
  8024ca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024cd:	50                   	push   %eax
  8024ce:	6a 00                	push   $0x0
  8024d0:	e8 25 f2 ff ff       	call   8016fa <read>
	if (r < 0)
  8024d5:	83 c4 10             	add    $0x10,%esp
  8024d8:	85 c0                	test   %eax,%eax
  8024da:	78 0f                	js     8024eb <getchar+0x29>
		return r;
	if (r < 1)
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	7e 06                	jle    8024e6 <getchar+0x24>
		return -E_EOF;
	return c;
  8024e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024e4:	eb 05                	jmp    8024eb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024eb:	c9                   	leave  
  8024ec:	c3                   	ret    

008024ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024ed:	55                   	push   %ebp
  8024ee:	89 e5                	mov    %esp,%ebp
  8024f0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f6:	50                   	push   %eax
  8024f7:	ff 75 08             	pushl  0x8(%ebp)
  8024fa:	e8 95 ef ff ff       	call   801494 <fd_lookup>
  8024ff:	83 c4 10             	add    $0x10,%esp
  802502:	85 c0                	test   %eax,%eax
  802504:	78 11                	js     802517 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802506:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802509:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80250f:	39 10                	cmp    %edx,(%eax)
  802511:	0f 94 c0             	sete   %al
  802514:	0f b6 c0             	movzbl %al,%eax
}
  802517:	c9                   	leave  
  802518:	c3                   	ret    

00802519 <opencons>:

int
opencons(void)
{
  802519:	55                   	push   %ebp
  80251a:	89 e5                	mov    %esp,%ebp
  80251c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80251f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802522:	50                   	push   %eax
  802523:	e8 1d ef ff ff       	call   801445 <fd_alloc>
  802528:	83 c4 10             	add    $0x10,%esp
		return r;
  80252b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80252d:	85 c0                	test   %eax,%eax
  80252f:	78 3e                	js     80256f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802531:	83 ec 04             	sub    $0x4,%esp
  802534:	68 07 04 00 00       	push   $0x407
  802539:	ff 75 f4             	pushl  -0xc(%ebp)
  80253c:	6a 00                	push   $0x0
  80253e:	e8 b0 eb ff ff       	call   8010f3 <sys_page_alloc>
  802543:	83 c4 10             	add    $0x10,%esp
		return r;
  802546:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802548:	85 c0                	test   %eax,%eax
  80254a:	78 23                	js     80256f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80254c:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802555:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802557:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802561:	83 ec 0c             	sub    $0xc,%esp
  802564:	50                   	push   %eax
  802565:	e8 b4 ee ff ff       	call   80141e <fd2num>
  80256a:	89 c2                	mov    %eax,%edx
  80256c:	83 c4 10             	add    $0x10,%esp
}
  80256f:	89 d0                	mov    %edx,%eax
  802571:	c9                   	leave  
  802572:	c3                   	ret    

00802573 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802573:	55                   	push   %ebp
  802574:	89 e5                	mov    %esp,%ebp
  802576:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802579:	89 d0                	mov    %edx,%eax
  80257b:	c1 e8 16             	shr    $0x16,%eax
  80257e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802585:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80258a:	f6 c1 01             	test   $0x1,%cl
  80258d:	74 1d                	je     8025ac <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80258f:	c1 ea 0c             	shr    $0xc,%edx
  802592:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802599:	f6 c2 01             	test   $0x1,%dl
  80259c:	74 0e                	je     8025ac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259e:	c1 ea 0c             	shr    $0xc,%edx
  8025a1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a8:	ef 
  8025a9:	0f b7 c0             	movzwl %ax,%eax
}
  8025ac:	5d                   	pop    %ebp
  8025ad:	c3                   	ret    
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 f6                	test   %esi,%esi
  8025c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025cd:	89 ca                	mov    %ecx,%edx
  8025cf:	89 f8                	mov    %edi,%eax
  8025d1:	75 3d                	jne    802610 <__udivdi3+0x60>
  8025d3:	39 cf                	cmp    %ecx,%edi
  8025d5:	0f 87 c5 00 00 00    	ja     8026a0 <__udivdi3+0xf0>
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	89 fd                	mov    %edi,%ebp
  8025df:	75 0b                	jne    8025ec <__udivdi3+0x3c>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  8025e8:	f7 f7                	div    %edi
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	89 c8                	mov    %ecx,%eax
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	f7 f5                	div    %ebp
  8025f2:	89 c1                	mov    %eax,%ecx
  8025f4:	89 d8                	mov    %ebx,%eax
  8025f6:	89 cf                	mov    %ecx,%edi
  8025f8:	f7 f5                	div    %ebp
  8025fa:	89 c3                	mov    %eax,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	89 fa                	mov    %edi,%edx
  802600:	83 c4 1c             	add    $0x1c,%esp
  802603:	5b                   	pop    %ebx
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
  802608:	90                   	nop
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	39 ce                	cmp    %ecx,%esi
  802612:	77 74                	ja     802688 <__udivdi3+0xd8>
  802614:	0f bd fe             	bsr    %esi,%edi
  802617:	83 f7 1f             	xor    $0x1f,%edi
  80261a:	0f 84 98 00 00 00    	je     8026b8 <__udivdi3+0x108>
  802620:	bb 20 00 00 00       	mov    $0x20,%ebx
  802625:	89 f9                	mov    %edi,%ecx
  802627:	89 c5                	mov    %eax,%ebp
  802629:	29 fb                	sub    %edi,%ebx
  80262b:	d3 e6                	shl    %cl,%esi
  80262d:	89 d9                	mov    %ebx,%ecx
  80262f:	d3 ed                	shr    %cl,%ebp
  802631:	89 f9                	mov    %edi,%ecx
  802633:	d3 e0                	shl    %cl,%eax
  802635:	09 ee                	or     %ebp,%esi
  802637:	89 d9                	mov    %ebx,%ecx
  802639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263d:	89 d5                	mov    %edx,%ebp
  80263f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802643:	d3 ed                	shr    %cl,%ebp
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e2                	shl    %cl,%edx
  802649:	89 d9                	mov    %ebx,%ecx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	09 c2                	or     %eax,%edx
  80264f:	89 d0                	mov    %edx,%eax
  802651:	89 ea                	mov    %ebp,%edx
  802653:	f7 f6                	div    %esi
  802655:	89 d5                	mov    %edx,%ebp
  802657:	89 c3                	mov    %eax,%ebx
  802659:	f7 64 24 0c          	mull   0xc(%esp)
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	72 10                	jb     802671 <__udivdi3+0xc1>
  802661:	8b 74 24 08          	mov    0x8(%esp),%esi
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e6                	shl    %cl,%esi
  802669:	39 c6                	cmp    %eax,%esi
  80266b:	73 07                	jae    802674 <__udivdi3+0xc4>
  80266d:	39 d5                	cmp    %edx,%ebp
  80266f:	75 03                	jne    802674 <__udivdi3+0xc4>
  802671:	83 eb 01             	sub    $0x1,%ebx
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 d8                	mov    %ebx,%eax
  802678:	89 fa                	mov    %edi,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	31 ff                	xor    %edi,%edi
  80268a:	31 db                	xor    %ebx,%ebx
  80268c:	89 d8                	mov    %ebx,%eax
  80268e:	89 fa                	mov    %edi,%edx
  802690:	83 c4 1c             	add    $0x1c,%esp
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	90                   	nop
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d8                	mov    %ebx,%eax
  8026a2:	f7 f7                	div    %edi
  8026a4:	31 ff                	xor    %edi,%edi
  8026a6:	89 c3                	mov    %eax,%ebx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 fa                	mov    %edi,%edx
  8026ac:	83 c4 1c             	add    $0x1c,%esp
  8026af:	5b                   	pop    %ebx
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	39 ce                	cmp    %ecx,%esi
  8026ba:	72 0c                	jb     8026c8 <__udivdi3+0x118>
  8026bc:	31 db                	xor    %ebx,%ebx
  8026be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026c2:	0f 87 34 ff ff ff    	ja     8025fc <__udivdi3+0x4c>
  8026c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026cd:	e9 2a ff ff ff       	jmp    8025fc <__udivdi3+0x4c>
  8026d2:	66 90                	xchg   %ax,%ax
  8026d4:	66 90                	xchg   %ax,%ax
  8026d6:	66 90                	xchg   %ax,%ax
  8026d8:	66 90                	xchg   %ax,%ax
  8026da:	66 90                	xchg   %ax,%ax
  8026dc:	66 90                	xchg   %ax,%ax
  8026de:	66 90                	xchg   %ax,%ax

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	53                   	push   %ebx
  8026e4:	83 ec 1c             	sub    $0x1c,%esp
  8026e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026f7:	85 d2                	test   %edx,%edx
  8026f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f3                	mov    %esi,%ebx
  802703:	89 3c 24             	mov    %edi,(%esp)
  802706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80270a:	75 1c                	jne    802728 <__umoddi3+0x48>
  80270c:	39 f7                	cmp    %esi,%edi
  80270e:	76 50                	jbe    802760 <__umoddi3+0x80>
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	f7 f7                	div    %edi
  802716:	89 d0                	mov    %edx,%eax
  802718:	31 d2                	xor    %edx,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	89 d0                	mov    %edx,%eax
  80272c:	77 52                	ja     802780 <__umoddi3+0xa0>
  80272e:	0f bd ea             	bsr    %edx,%ebp
  802731:	83 f5 1f             	xor    $0x1f,%ebp
  802734:	75 5a                	jne    802790 <__umoddi3+0xb0>
  802736:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80273a:	0f 82 e0 00 00 00    	jb     802820 <__umoddi3+0x140>
  802740:	39 0c 24             	cmp    %ecx,(%esp)
  802743:	0f 86 d7 00 00 00    	jbe    802820 <__umoddi3+0x140>
  802749:	8b 44 24 08          	mov    0x8(%esp),%eax
  80274d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802751:	83 c4 1c             	add    $0x1c,%esp
  802754:	5b                   	pop    %ebx
  802755:	5e                   	pop    %esi
  802756:	5f                   	pop    %edi
  802757:	5d                   	pop    %ebp
  802758:	c3                   	ret    
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	85 ff                	test   %edi,%edi
  802762:	89 fd                	mov    %edi,%ebp
  802764:	75 0b                	jne    802771 <__umoddi3+0x91>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f7                	div    %edi
  80276f:	89 c5                	mov    %eax,%ebp
  802771:	89 f0                	mov    %esi,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f5                	div    %ebp
  802777:	89 c8                	mov    %ecx,%eax
  802779:	f7 f5                	div    %ebp
  80277b:	89 d0                	mov    %edx,%eax
  80277d:	eb 99                	jmp    802718 <__umoddi3+0x38>
  80277f:	90                   	nop
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	83 c4 1c             	add    $0x1c,%esp
  802787:	5b                   	pop    %ebx
  802788:	5e                   	pop    %esi
  802789:	5f                   	pop    %edi
  80278a:	5d                   	pop    %ebp
  80278b:	c3                   	ret    
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	8b 34 24             	mov    (%esp),%esi
  802793:	bf 20 00 00 00       	mov    $0x20,%edi
  802798:	89 e9                	mov    %ebp,%ecx
  80279a:	29 ef                	sub    %ebp,%edi
  80279c:	d3 e0                	shl    %cl,%eax
  80279e:	89 f9                	mov    %edi,%ecx
  8027a0:	89 f2                	mov    %esi,%edx
  8027a2:	d3 ea                	shr    %cl,%edx
  8027a4:	89 e9                	mov    %ebp,%ecx
  8027a6:	09 c2                	or     %eax,%edx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 14 24             	mov    %edx,(%esp)
  8027ad:	89 f2                	mov    %esi,%edx
  8027af:	d3 e2                	shl    %cl,%edx
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	89 e9                	mov    %ebp,%ecx
  8027bf:	89 c6                	mov    %eax,%esi
  8027c1:	d3 e3                	shl    %cl,%ebx
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 d0                	mov    %edx,%eax
  8027c7:	d3 e8                	shr    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	09 d8                	or     %ebx,%eax
  8027cd:	89 d3                	mov    %edx,%ebx
  8027cf:	89 f2                	mov    %esi,%edx
  8027d1:	f7 34 24             	divl   (%esp)
  8027d4:	89 d6                	mov    %edx,%esi
  8027d6:	d3 e3                	shl    %cl,%ebx
  8027d8:	f7 64 24 04          	mull   0x4(%esp)
  8027dc:	39 d6                	cmp    %edx,%esi
  8027de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027e2:	89 d1                	mov    %edx,%ecx
  8027e4:	89 c3                	mov    %eax,%ebx
  8027e6:	72 08                	jb     8027f0 <__umoddi3+0x110>
  8027e8:	75 11                	jne    8027fb <__umoddi3+0x11b>
  8027ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ee:	73 0b                	jae    8027fb <__umoddi3+0x11b>
  8027f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027f4:	1b 14 24             	sbb    (%esp),%edx
  8027f7:	89 d1                	mov    %edx,%ecx
  8027f9:	89 c3                	mov    %eax,%ebx
  8027fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ff:	29 da                	sub    %ebx,%edx
  802801:	19 ce                	sbb    %ecx,%esi
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 f0                	mov    %esi,%eax
  802807:	d3 e0                	shl    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	d3 ea                	shr    %cl,%edx
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	d3 ee                	shr    %cl,%esi
  802811:	09 d0                	or     %edx,%eax
  802813:	89 f2                	mov    %esi,%edx
  802815:	83 c4 1c             	add    $0x1c,%esp
  802818:	5b                   	pop    %ebx
  802819:	5e                   	pop    %esi
  80281a:	5f                   	pop    %edi
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	8d 76 00             	lea    0x0(%esi),%esi
  802820:	29 f9                	sub    %edi,%ecx
  802822:	19 d6                	sbb    %edx,%esi
  802824:	89 74 24 04          	mov    %esi,0x4(%esp)
  802828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80282c:	e9 18 ff ff ff       	jmp    802749 <__umoddi3+0x69>
