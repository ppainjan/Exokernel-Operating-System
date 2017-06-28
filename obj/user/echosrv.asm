
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 91 04 00 00       	call   8004c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 30 27 80 00       	push   $0x802730
  80003f:	e8 7b 05 00 00       	call   8005bf <cprintf>
	exit();
  800044:	e8 c9 04 00 00       	call   800512 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:

void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 30             	sub    $0x30,%esp
  800057:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005a:	6a 20                	push   $0x20
  80005c:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	56                   	push   %esi
  800061:	e8 ee 13 00 00       	call   801454 <read>
  800066:	89 c3                	mov    %eax,%ebx
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	79 0a                	jns    800079 <handle_client+0x2b>
		die("Failed to receive initial bytes from client");
  80006f:	b8 34 27 80 00       	mov    $0x802734,%eax
  800074:	e8 ba ff ff ff       	call   800033 <die>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  800079:	8d 7d c8             	lea    -0x38(%ebp),%edi
  80007c:	eb 3b                	jmp    8000b9 <handle_client+0x6b>
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	53                   	push   %ebx
  800082:	57                   	push   %edi
  800083:	56                   	push   %esi
  800084:	e8 a5 14 00 00       	call   80152e <write>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	39 c3                	cmp    %eax,%ebx
  80008e:	74 0a                	je     80009a <handle_client+0x4c>
			die("Failed to send bytes to client");
  800090:	b8 60 27 80 00       	mov    $0x802760,%eax
  800095:	e8 99 ff ff ff       	call   800033 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	6a 20                	push   $0x20
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	e8 ae 13 00 00       	call   801454 <read>
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 0a                	jns    8000b9 <handle_client+0x6b>
			die("Failed to receive additional bytes from client");
  8000af:	b8 80 27 80 00       	mov    $0x802780,%eax
  8000b4:	e8 7a ff ff ff       	call   800033 <die>
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000b9:	85 db                	test   %ebx,%ebx
  8000bb:	7f c1                	jg     80007e <handle_client+0x30>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	56                   	push   %esi
  8000c1:	e8 52 12 00 00       	call   801318 <close>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <umain>:

void
umain(int argc, char **argv)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 40             	sub    $0x40,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000da:	6a 06                	push   $0x6
  8000dc:	6a 01                	push   $0x1
  8000de:	6a 02                	push   $0x2
  8000e0:	e8 91 1a 00 00       	call   801b76 <socket>
  8000e5:	89 c6                	mov    %eax,%esi
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	79 0a                	jns    8000f8 <umain+0x27>
		die("Failed to create socket");
  8000ee:	b8 e0 26 80 00       	mov    $0x8026e0,%eax
  8000f3:	e8 3b ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	68 f8 26 80 00       	push   $0x8026f8
  800100:	e8 ba 04 00 00       	call   8005bf <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800105:	83 c4 0c             	add    $0xc,%esp
  800108:	6a 10                	push   $0x10
  80010a:	6a 00                	push   $0x0
  80010c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80010f:	53                   	push   %ebx
  800110:	e8 74 0b 00 00       	call   800c89 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  800115:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800120:	e8 6c 01 00 00       	call   800291 <htonl>
  800125:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800128:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80012f:	e8 43 01 00 00       	call   800277 <htons>
  800134:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800138:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  80013f:	e8 7b 04 00 00       	call   8005bf <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  800144:	83 c4 0c             	add    $0xc,%esp
  800147:	6a 10                	push   $0x10
  800149:	53                   	push   %ebx
  80014a:	56                   	push   %esi
  80014b:	e8 94 19 00 00       	call   801ae4 <bind>
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	85 c0                	test   %eax,%eax
  800155:	79 0a                	jns    800161 <umain+0x90>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800157:	b8 b0 27 80 00       	mov    $0x8027b0,%eax
  80015c:	e8 d2 fe ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	6a 05                	push   $0x5
  800166:	56                   	push   %esi
  800167:	e8 e7 19 00 00       	call   801b53 <listen>
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	85 c0                	test   %eax,%eax
  800171:	79 0a                	jns    80017d <umain+0xac>
		die("Failed to listen on server socket");
  800173:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
  800178:	e8 b6 fe ff ff       	call   800033 <die>

	cprintf("bound\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 17 27 80 00       	push   $0x802717
  800185:	e8 35 04 00 00       	call   8005bf <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  80018d:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  800190:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	57                   	push   %edi
  80019b:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	56                   	push   %esi
  8001a0:	e8 08 19 00 00       	call   801aad <accept>
  8001a5:	89 c3                	mov    %eax,%ebx
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	79 0a                	jns    8001b8 <umain+0xe7>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001ae:	b8 f8 27 80 00       	mov    $0x8027f8,%eax
  8001b3:	e8 7b fe ff ff       	call   800033 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	ff 75 cc             	pushl  -0x34(%ebp)
  8001be:	e8 1b 00 00 00       	call   8001de <inet_ntoa>
  8001c3:	83 c4 08             	add    $0x8,%esp
  8001c6:	50                   	push   %eax
  8001c7:	68 1e 27 80 00       	push   $0x80271e
  8001cc:	e8 ee 03 00 00       	call   8005bf <cprintf>
		handle_client(clientsock);
  8001d1:	89 1c 24             	mov    %ebx,(%esp)
  8001d4:	e8 75 fe ff ff       	call   80004e <handle_client>
	}
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb b2                	jmp    800190 <umain+0xbf>

008001de <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	57                   	push   %edi
  8001e2:	56                   	push   %esi
  8001e3:	53                   	push   %ebx
  8001e4:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001f0:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001f7:	0f b6 0f             	movzbl (%edi),%ecx
  8001fa:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001ff:	0f b6 d9             	movzbl %cl,%ebx
  800202:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800205:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800208:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80020b:	66 c1 e8 0b          	shr    $0xb,%ax
  80020f:	89 c3                	mov    %eax,%ebx
  800211:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800214:	01 c0                	add    %eax,%eax
  800216:	29 c1                	sub    %eax,%ecx
  800218:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  80021a:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80021c:	8d 72 01             	lea    0x1(%edx),%esi
  80021f:	0f b6 d2             	movzbl %dl,%edx
  800222:	83 c0 30             	add    $0x30,%eax
  800225:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800229:	89 f2                	mov    %esi,%edx
    } while(*ap);
  80022b:	84 db                	test   %bl,%bl
  80022d:	75 d0                	jne    8001ff <inet_ntoa+0x21>
  80022f:	c6 07 00             	movb   $0x0,(%edi)
  800232:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800235:	eb 0d                	jmp    800244 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800237:	0f b6 c2             	movzbl %dl,%eax
  80023a:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  80023f:	88 01                	mov    %al,(%ecx)
  800241:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800244:	83 ea 01             	sub    $0x1,%edx
  800247:	80 fa ff             	cmp    $0xff,%dl
  80024a:	75 eb                	jne    800237 <inet_ntoa+0x59>
  80024c:	89 f0                	mov    %esi,%eax
  80024e:	0f b6 f0             	movzbl %al,%esi
  800251:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  800254:	8d 46 01             	lea    0x1(%esi),%eax
  800257:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025a:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  80025d:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800263:	39 c7                	cmp    %eax,%edi
  800265:	75 90                	jne    8001f7 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800267:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  80026a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80027a:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80027e:	66 c1 c0 08          	rol    $0x8,%ax
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800287:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80028b:	66 c1 c0 08          	rol    $0x8,%ax
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800297:	89 d1                	mov    %edx,%ecx
  800299:	c1 e1 18             	shl    $0x18,%ecx
  80029c:	89 d0                	mov    %edx,%eax
  80029e:	c1 e8 18             	shr    $0x18,%eax
  8002a1:	09 c8                	or     %ecx,%eax
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002ab:	c1 e1 08             	shl    $0x8,%ecx
  8002ae:	09 c8                	or     %ecx,%eax
  8002b0:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002b6:	c1 ea 08             	shr    $0x8,%edx
  8002b9:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 20             	sub    $0x20,%esp
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002c9:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002cc:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002cf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002d2:	0f b6 ca             	movzbl %dl,%ecx
  8002d5:	83 e9 30             	sub    $0x30,%ecx
  8002d8:	83 f9 09             	cmp    $0x9,%ecx
  8002db:	0f 87 94 01 00 00    	ja     800475 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002e1:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002e8:	83 fa 30             	cmp    $0x30,%edx
  8002eb:	75 2b                	jne    800318 <inet_aton+0x5b>
      c = *++cp;
  8002ed:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002f1:	89 d1                	mov    %edx,%ecx
  8002f3:	83 e1 df             	and    $0xffffffdf,%ecx
  8002f6:	80 f9 58             	cmp    $0x58,%cl
  8002f9:	74 0f                	je     80030a <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002fb:	83 c0 01             	add    $0x1,%eax
  8002fe:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800301:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800308:	eb 0e                	jmp    800318 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80030a:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80030e:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800311:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800318:	83 c0 01             	add    $0x1,%eax
  80031b:	be 00 00 00 00       	mov    $0x0,%esi
  800320:	eb 03                	jmp    800325 <inet_aton+0x68>
  800322:	83 c0 01             	add    $0x1,%eax
  800325:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800328:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80032b:	0f b6 fa             	movzbl %dl,%edi
  80032e:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800331:	83 f9 09             	cmp    $0x9,%ecx
  800334:	77 0d                	ja     800343 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800336:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  80033a:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  80033e:	0f be 10             	movsbl (%eax),%edx
  800341:	eb df                	jmp    800322 <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  800343:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800347:	75 32                	jne    80037b <inet_aton+0xbe>
  800349:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  80034c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80034f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800352:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800358:	83 e9 41             	sub    $0x41,%ecx
  80035b:	83 f9 05             	cmp    $0x5,%ecx
  80035e:	77 1b                	ja     80037b <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800360:	c1 e6 04             	shl    $0x4,%esi
  800363:	83 c2 0a             	add    $0xa,%edx
  800366:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  80036a:	19 c9                	sbb    %ecx,%ecx
  80036c:	83 e1 20             	and    $0x20,%ecx
  80036f:	83 c1 41             	add    $0x41,%ecx
  800372:	29 ca                	sub    %ecx,%edx
  800374:	09 d6                	or     %edx,%esi
        c = *++cp;
  800376:	0f be 10             	movsbl (%eax),%edx
  800379:	eb a7                	jmp    800322 <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  80037b:	83 fa 2e             	cmp    $0x2e,%edx
  80037e:	75 23                	jne    8003a3 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800380:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800383:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800386:	39 f8                	cmp    %edi,%eax
  800388:	0f 84 ee 00 00 00    	je     80047c <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  80038e:	83 c0 04             	add    $0x4,%eax
  800391:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800394:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800397:	8d 43 01             	lea    0x1(%ebx),%eax
  80039a:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  80039e:	e9 2f ff ff ff       	jmp    8002d2 <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003a3:	85 d2                	test   %edx,%edx
  8003a5:	74 25                	je     8003cc <inet_aton+0x10f>
  8003a7:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003af:	83 f9 5f             	cmp    $0x5f,%ecx
  8003b2:	0f 87 d0 00 00 00    	ja     800488 <inet_aton+0x1cb>
  8003b8:	83 fa 20             	cmp    $0x20,%edx
  8003bb:	74 0f                	je     8003cc <inet_aton+0x10f>
  8003bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c0:	83 ea 09             	sub    $0x9,%edx
  8003c3:	83 fa 04             	cmp    $0x4,%edx
  8003c6:	0f 87 bc 00 00 00    	ja     800488 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003d2:	29 c2                	sub    %eax,%edx
  8003d4:	c1 fa 02             	sar    $0x2,%edx
  8003d7:	83 c2 01             	add    $0x1,%edx
  8003da:	83 fa 02             	cmp    $0x2,%edx
  8003dd:	74 20                	je     8003ff <inet_aton+0x142>
  8003df:	83 fa 02             	cmp    $0x2,%edx
  8003e2:	7f 0f                	jg     8003f3 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	0f 84 97 00 00 00    	je     800488 <inet_aton+0x1cb>
  8003f1:	eb 67                	jmp    80045a <inet_aton+0x19d>
  8003f3:	83 fa 03             	cmp    $0x3,%edx
  8003f6:	74 1e                	je     800416 <inet_aton+0x159>
  8003f8:	83 fa 04             	cmp    $0x4,%edx
  8003fb:	74 38                	je     800435 <inet_aton+0x178>
  8003fd:	eb 5b                	jmp    80045a <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800404:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  80040a:	77 7c                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  80040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040f:	c1 e0 18             	shl    $0x18,%eax
  800412:	09 c6                	or     %eax,%esi
    break;
  800414:	eb 44                	jmp    80045a <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80041b:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800421:	77 65                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800426:	c1 e2 18             	shl    $0x18,%edx
  800429:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80042c:	c1 e0 10             	shl    $0x10,%eax
  80042f:	09 d0                	or     %edx,%eax
  800431:	09 c6                	or     %eax,%esi
    break;
  800433:	eb 25                	jmp    80045a <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80043a:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800440:	77 46                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800445:	c1 e2 18             	shl    $0x18,%edx
  800448:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80044b:	c1 e0 10             	shl    $0x10,%eax
  80044e:	09 c2                	or     %eax,%edx
  800450:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800453:	c1 e0 08             	shl    $0x8,%eax
  800456:	09 d0                	or     %edx,%eax
  800458:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  80045a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80045e:	74 23                	je     800483 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800460:	56                   	push   %esi
  800461:	e8 2b fe ff ff       	call   800291 <htonl>
  800466:	83 c4 04             	add    $0x4,%esp
  800469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80046c:	89 03                	mov    %eax,(%ebx)
  return (1);
  80046e:	b8 01 00 00 00       	mov    $0x1,%eax
  800473:	eb 13                	jmp    800488 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	eb 0c                	jmp    800488 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	eb 05                	jmp    800488 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800483:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800496:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800499:	50                   	push   %eax
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	e8 1b fe ff ff       	call   8002bd <inet_aton>
  8004a2:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004ac:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	e8 d4 fd ff ff       	call   800291 <htonl>
  8004bd:	83 c4 04             	add    $0x4,%esp
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	56                   	push   %esi
  8004c6:	53                   	push   %ebx
  8004c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8004cd:	c7 05 18 40 80 00 00 	movl   $0x0,0x804018
  8004d4:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8004d7:	e8 2d 0a 00 00       	call   800f09 <sys_getenvid>
  8004dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004e9:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004ee:	85 db                	test   %ebx,%ebx
  8004f0:	7e 07                	jle    8004f9 <libmain+0x37>
		binaryname = argv[0];
  8004f2:	8b 06                	mov    (%esi),%eax
  8004f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	56                   	push   %esi
  8004fd:	53                   	push   %ebx
  8004fe:	e8 ce fb ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  800503:	e8 0a 00 00 00       	call   800512 <exit>
}
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800518:	e8 26 0e 00 00       	call   801343 <close_all>
	sys_env_destroy(0);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	6a 00                	push   $0x0
  800522:	e8 a1 09 00 00       	call   800ec8 <sys_env_destroy>
}
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	53                   	push   %ebx
  800530:	83 ec 04             	sub    $0x4,%esp
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800536:	8b 13                	mov    (%ebx),%edx
  800538:	8d 42 01             	lea    0x1(%edx),%eax
  80053b:	89 03                	mov    %eax,(%ebx)
  80053d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800540:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800544:	3d ff 00 00 00       	cmp    $0xff,%eax
  800549:	75 1a                	jne    800565 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	68 ff 00 00 00       	push   $0xff
  800553:	8d 43 08             	lea    0x8(%ebx),%eax
  800556:	50                   	push   %eax
  800557:	e8 2f 09 00 00       	call   800e8b <sys_cputs>
		b->idx = 0;
  80055c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800562:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800565:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    

0080056e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800577:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057e:	00 00 00 
	b.cnt = 0;
  800581:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800588:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	ff 75 08             	pushl  0x8(%ebp)
  800591:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800597:	50                   	push   %eax
  800598:	68 2c 05 80 00       	push   $0x80052c
  80059d:	e8 54 01 00 00       	call   8006f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b1:	50                   	push   %eax
  8005b2:	e8 d4 08 00 00       	call   800e8b <sys_cputs>

	return b.cnt;
}
  8005b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bd:	c9                   	leave  
  8005be:	c3                   	ret    

008005bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c8:	50                   	push   %eax
  8005c9:	ff 75 08             	pushl  0x8(%ebp)
  8005cc:	e8 9d ff ff ff       	call   80056e <vcprintf>
	va_end(ap);

	return cnt;
}
  8005d1:	c9                   	leave  
  8005d2:	c3                   	ret    

008005d3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d3:	55                   	push   %ebp
  8005d4:	89 e5                	mov    %esp,%ebp
  8005d6:	57                   	push   %edi
  8005d7:	56                   	push   %esi
  8005d8:	53                   	push   %ebx
  8005d9:	83 ec 1c             	sub    $0x1c,%esp
  8005dc:	89 c7                	mov    %eax,%edi
  8005de:	89 d6                	mov    %edx,%esi
  8005e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005fa:	39 d3                	cmp    %edx,%ebx
  8005fc:	72 05                	jb     800603 <printnum+0x30>
  8005fe:	39 45 10             	cmp    %eax,0x10(%ebp)
  800601:	77 45                	ja     800648 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	ff 75 18             	pushl  0x18(%ebp)
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060f:	53                   	push   %ebx
  800610:	ff 75 10             	pushl  0x10(%ebp)
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	ff 75 e4             	pushl  -0x1c(%ebp)
  800619:	ff 75 e0             	pushl  -0x20(%ebp)
  80061c:	ff 75 dc             	pushl  -0x24(%ebp)
  80061f:	ff 75 d8             	pushl  -0x28(%ebp)
  800622:	e8 29 1e 00 00       	call   802450 <__udivdi3>
  800627:	83 c4 18             	add    $0x18,%esp
  80062a:	52                   	push   %edx
  80062b:	50                   	push   %eax
  80062c:	89 f2                	mov    %esi,%edx
  80062e:	89 f8                	mov    %edi,%eax
  800630:	e8 9e ff ff ff       	call   8005d3 <printnum>
  800635:	83 c4 20             	add    $0x20,%esp
  800638:	eb 18                	jmp    800652 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	56                   	push   %esi
  80063e:	ff 75 18             	pushl  0x18(%ebp)
  800641:	ff d7                	call   *%edi
  800643:	83 c4 10             	add    $0x10,%esp
  800646:	eb 03                	jmp    80064b <printnum+0x78>
  800648:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80064b:	83 eb 01             	sub    $0x1,%ebx
  80064e:	85 db                	test   %ebx,%ebx
  800650:	7f e8                	jg     80063a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	56                   	push   %esi
  800656:	83 ec 04             	sub    $0x4,%esp
  800659:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065c:	ff 75 e0             	pushl  -0x20(%ebp)
  80065f:	ff 75 dc             	pushl  -0x24(%ebp)
  800662:	ff 75 d8             	pushl  -0x28(%ebp)
  800665:	e8 16 1f 00 00       	call   802580 <__umoddi3>
  80066a:	83 c4 14             	add    $0x14,%esp
  80066d:	0f be 80 25 28 80 00 	movsbl 0x802825(%eax),%eax
  800674:	50                   	push   %eax
  800675:	ff d7                	call   *%edi
}
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067d:	5b                   	pop    %ebx
  80067e:	5e                   	pop    %esi
  80067f:	5f                   	pop    %edi
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800685:	83 fa 01             	cmp    $0x1,%edx
  800688:	7e 0e                	jle    800698 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068f:	89 08                	mov    %ecx,(%eax)
  800691:	8b 02                	mov    (%edx),%eax
  800693:	8b 52 04             	mov    0x4(%edx),%edx
  800696:	eb 22                	jmp    8006ba <getuint+0x38>
	else if (lflag)
  800698:	85 d2                	test   %edx,%edx
  80069a:	74 10                	je     8006ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a1:	89 08                	mov    %ecx,(%eax)
  8006a3:	8b 02                	mov    (%edx),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006aa:	eb 0e                	jmp    8006ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b1:	89 08                	mov    %ecx,(%eax)
  8006b3:	8b 02                	mov    (%edx),%eax
  8006b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006ba:	5d                   	pop    %ebp
  8006bb:	c3                   	ret    

008006bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	3b 50 04             	cmp    0x4(%eax),%edx
  8006cb:	73 0a                	jae    8006d7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006d0:	89 08                	mov    %ecx,(%eax)
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	88 02                	mov    %al,(%edx)
}
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e2:	50                   	push   %eax
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	ff 75 08             	pushl  0x8(%ebp)
  8006ec:	e8 05 00 00 00       	call   8006f6 <vprintfmt>
	va_end(ap);
}
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	57                   	push   %edi
  8006fa:	56                   	push   %esi
  8006fb:	53                   	push   %ebx
  8006fc:	83 ec 2c             	sub    $0x2c,%esp
  8006ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800702:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800705:	8b 7d 10             	mov    0x10(%ebp),%edi
  800708:	eb 12                	jmp    80071c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80070a:	85 c0                	test   %eax,%eax
  80070c:	0f 84 89 03 00 00    	je     800a9b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	50                   	push   %eax
  800717:	ff d6                	call   *%esi
  800719:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071c:	83 c7 01             	add    $0x1,%edi
  80071f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800723:	83 f8 25             	cmp    $0x25,%eax
  800726:	75 e2                	jne    80070a <vprintfmt+0x14>
  800728:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800733:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80073a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	eb 07                	jmp    80074f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800748:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80074b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	8d 47 01             	lea    0x1(%edi),%eax
  800752:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800755:	0f b6 07             	movzbl (%edi),%eax
  800758:	0f b6 c8             	movzbl %al,%ecx
  80075b:	83 e8 23             	sub    $0x23,%eax
  80075e:	3c 55                	cmp    $0x55,%al
  800760:	0f 87 1a 03 00 00    	ja     800a80 <vprintfmt+0x38a>
  800766:	0f b6 c0             	movzbl %al,%eax
  800769:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  800770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800773:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800777:	eb d6                	jmp    80074f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077c:	b8 00 00 00 00       	mov    $0x0,%eax
  800781:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800784:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800787:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80078b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800791:	83 fa 09             	cmp    $0x9,%edx
  800794:	77 39                	ja     8007cf <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800796:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800799:	eb e9                	jmp    800784 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 48 04             	lea    0x4(%eax),%ecx
  8007a1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a4:	8b 00                	mov    (%eax),%eax
  8007a6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007ac:	eb 27                	jmp    8007d5 <vprintfmt+0xdf>
  8007ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b8:	0f 49 c8             	cmovns %eax,%ecx
  8007bb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c1:	eb 8c                	jmp    80074f <vprintfmt+0x59>
  8007c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cd:	eb 80                	jmp    80074f <vprintfmt+0x59>
  8007cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d9:	0f 89 70 ff ff ff    	jns    80074f <vprintfmt+0x59>
				width = precision, precision = -1;
  8007df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ec:	e9 5e ff ff ff       	jmp    80074f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f7:	e9 53 ff ff ff       	jmp    80074f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8d 50 04             	lea    0x4(%eax),%edx
  800802:	89 55 14             	mov    %edx,0x14(%ebp)
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	53                   	push   %ebx
  800809:	ff 30                	pushl  (%eax)
  80080b:	ff d6                	call   *%esi
			break;
  80080d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800810:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800813:	e9 04 ff ff ff       	jmp    80071c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8d 50 04             	lea    0x4(%eax),%edx
  80081e:	89 55 14             	mov    %edx,0x14(%ebp)
  800821:	8b 00                	mov    (%eax),%eax
  800823:	99                   	cltd   
  800824:	31 d0                	xor    %edx,%eax
  800826:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800828:	83 f8 0f             	cmp    $0xf,%eax
  80082b:	7f 0b                	jg     800838 <vprintfmt+0x142>
  80082d:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800834:	85 d2                	test   %edx,%edx
  800836:	75 18                	jne    800850 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800838:	50                   	push   %eax
  800839:	68 3d 28 80 00       	push   $0x80283d
  80083e:	53                   	push   %ebx
  80083f:	56                   	push   %esi
  800840:	e8 94 fe ff ff       	call   8006d9 <printfmt>
  800845:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800848:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80084b:	e9 cc fe ff ff       	jmp    80071c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800850:	52                   	push   %edx
  800851:	68 f5 2b 80 00       	push   $0x802bf5
  800856:	53                   	push   %ebx
  800857:	56                   	push   %esi
  800858:	e8 7c fe ff ff       	call   8006d9 <printfmt>
  80085d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800863:	e9 b4 fe ff ff       	jmp    80071c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800873:	85 ff                	test   %edi,%edi
  800875:	b8 36 28 80 00       	mov    $0x802836,%eax
  80087a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800881:	0f 8e 94 00 00 00    	jle    80091b <vprintfmt+0x225>
  800887:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80088b:	0f 84 98 00 00 00    	je     800929 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800891:	83 ec 08             	sub    $0x8,%esp
  800894:	ff 75 d0             	pushl  -0x30(%ebp)
  800897:	57                   	push   %edi
  800898:	e8 86 02 00 00       	call   800b23 <strnlen>
  80089d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008a0:	29 c1                	sub    %eax,%ecx
  8008a2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008af:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b4:	eb 0f                	jmp    8008c5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bf:	83 ef 01             	sub    $0x1,%edi
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 ff                	test   %edi,%edi
  8008c7:	7f ed                	jg     8008b6 <vprintfmt+0x1c0>
  8008c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008cc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cf:	85 c9                	test   %ecx,%ecx
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	0f 49 c1             	cmovns %ecx,%eax
  8008d9:	29 c1                	sub    %eax,%ecx
  8008db:	89 75 08             	mov    %esi,0x8(%ebp)
  8008de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e4:	89 cb                	mov    %ecx,%ebx
  8008e6:	eb 4d                	jmp    800935 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ec:	74 1b                	je     800909 <vprintfmt+0x213>
  8008ee:	0f be c0             	movsbl %al,%eax
  8008f1:	83 e8 20             	sub    $0x20,%eax
  8008f4:	83 f8 5e             	cmp    $0x5e,%eax
  8008f7:	76 10                	jbe    800909 <vprintfmt+0x213>
					putch('?', putdat);
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	ff 75 0c             	pushl  0xc(%ebp)
  8008ff:	6a 3f                	push   $0x3f
  800901:	ff 55 08             	call   *0x8(%ebp)
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb 0d                	jmp    800916 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800909:	83 ec 08             	sub    $0x8,%esp
  80090c:	ff 75 0c             	pushl  0xc(%ebp)
  80090f:	52                   	push   %edx
  800910:	ff 55 08             	call   *0x8(%ebp)
  800913:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800916:	83 eb 01             	sub    $0x1,%ebx
  800919:	eb 1a                	jmp    800935 <vprintfmt+0x23f>
  80091b:	89 75 08             	mov    %esi,0x8(%ebp)
  80091e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800921:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800924:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800927:	eb 0c                	jmp    800935 <vprintfmt+0x23f>
  800929:	89 75 08             	mov    %esi,0x8(%ebp)
  80092c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800932:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800935:	83 c7 01             	add    $0x1,%edi
  800938:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093c:	0f be d0             	movsbl %al,%edx
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 23                	je     800966 <vprintfmt+0x270>
  800943:	85 f6                	test   %esi,%esi
  800945:	78 a1                	js     8008e8 <vprintfmt+0x1f2>
  800947:	83 ee 01             	sub    $0x1,%esi
  80094a:	79 9c                	jns    8008e8 <vprintfmt+0x1f2>
  80094c:	89 df                	mov    %ebx,%edi
  80094e:	8b 75 08             	mov    0x8(%ebp),%esi
  800951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800954:	eb 18                	jmp    80096e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800956:	83 ec 08             	sub    $0x8,%esp
  800959:	53                   	push   %ebx
  80095a:	6a 20                	push   $0x20
  80095c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	83 c4 10             	add    $0x10,%esp
  800964:	eb 08                	jmp    80096e <vprintfmt+0x278>
  800966:	89 df                	mov    %ebx,%edi
  800968:	8b 75 08             	mov    0x8(%ebp),%esi
  80096b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096e:	85 ff                	test   %edi,%edi
  800970:	7f e4                	jg     800956 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800972:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800975:	e9 a2 fd ff ff       	jmp    80071c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80097a:	83 fa 01             	cmp    $0x1,%edx
  80097d:	7e 16                	jle    800995 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097f:	8b 45 14             	mov    0x14(%ebp),%eax
  800982:	8d 50 08             	lea    0x8(%eax),%edx
  800985:	89 55 14             	mov    %edx,0x14(%ebp)
  800988:	8b 50 04             	mov    0x4(%eax),%edx
  80098b:	8b 00                	mov    (%eax),%eax
  80098d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800990:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800993:	eb 32                	jmp    8009c7 <vprintfmt+0x2d1>
	else if (lflag)
  800995:	85 d2                	test   %edx,%edx
  800997:	74 18                	je     8009b1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800999:	8b 45 14             	mov    0x14(%ebp),%eax
  80099c:	8d 50 04             	lea    0x4(%eax),%edx
  80099f:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a2:	8b 00                	mov    (%eax),%eax
  8009a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a7:	89 c1                	mov    %eax,%ecx
  8009a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8009ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009af:	eb 16                	jmp    8009c7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b4:	8d 50 04             	lea    0x4(%eax),%edx
  8009b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ba:	8b 00                	mov    (%eax),%eax
  8009bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bf:	89 c1                	mov    %eax,%ecx
  8009c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d6:	79 74                	jns    800a4c <vprintfmt+0x356>
				putch('-', putdat);
  8009d8:	83 ec 08             	sub    $0x8,%esp
  8009db:	53                   	push   %ebx
  8009dc:	6a 2d                	push   $0x2d
  8009de:	ff d6                	call   *%esi
				num = -(long long) num;
  8009e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e6:	f7 d8                	neg    %eax
  8009e8:	83 d2 00             	adc    $0x0,%edx
  8009eb:	f7 da                	neg    %edx
  8009ed:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f5:	eb 55                	jmp    800a4c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fa:	e8 83 fc ff ff       	call   800682 <getuint>
			base = 10;
  8009ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a04:	eb 46                	jmp    800a4c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a06:	8d 45 14             	lea    0x14(%ebp),%eax
  800a09:	e8 74 fc ff ff       	call   800682 <getuint>
		        base = 8;
  800a0e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800a13:	eb 37                	jmp    800a4c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	53                   	push   %ebx
  800a19:	6a 30                	push   $0x30
  800a1b:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1d:	83 c4 08             	add    $0x8,%esp
  800a20:	53                   	push   %ebx
  800a21:	6a 78                	push   $0x78
  800a23:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a25:	8b 45 14             	mov    0x14(%ebp),%eax
  800a28:	8d 50 04             	lea    0x4(%eax),%edx
  800a2b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2e:	8b 00                	mov    (%eax),%eax
  800a30:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a35:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a38:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3d:	eb 0d                	jmp    800a4c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a42:	e8 3b fc ff ff       	call   800682 <getuint>
			base = 16;
  800a47:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4c:	83 ec 0c             	sub    $0xc,%esp
  800a4f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a53:	57                   	push   %edi
  800a54:	ff 75 e0             	pushl  -0x20(%ebp)
  800a57:	51                   	push   %ecx
  800a58:	52                   	push   %edx
  800a59:	50                   	push   %eax
  800a5a:	89 da                	mov    %ebx,%edx
  800a5c:	89 f0                	mov    %esi,%eax
  800a5e:	e8 70 fb ff ff       	call   8005d3 <printnum>
			break;
  800a63:	83 c4 20             	add    $0x20,%esp
  800a66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a69:	e9 ae fc ff ff       	jmp    80071c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6e:	83 ec 08             	sub    $0x8,%esp
  800a71:	53                   	push   %ebx
  800a72:	51                   	push   %ecx
  800a73:	ff d6                	call   *%esi
			break;
  800a75:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a7b:	e9 9c fc ff ff       	jmp    80071c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a80:	83 ec 08             	sub    $0x8,%esp
  800a83:	53                   	push   %ebx
  800a84:	6a 25                	push   $0x25
  800a86:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a88:	83 c4 10             	add    $0x10,%esp
  800a8b:	eb 03                	jmp    800a90 <vprintfmt+0x39a>
  800a8d:	83 ef 01             	sub    $0x1,%edi
  800a90:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a94:	75 f7                	jne    800a8d <vprintfmt+0x397>
  800a96:	e9 81 fc ff ff       	jmp    80071c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	83 ec 18             	sub    $0x18,%esp
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ac0:	85 c0                	test   %eax,%eax
  800ac2:	74 26                	je     800aea <vsnprintf+0x47>
  800ac4:	85 d2                	test   %edx,%edx
  800ac6:	7e 22                	jle    800aea <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac8:	ff 75 14             	pushl  0x14(%ebp)
  800acb:	ff 75 10             	pushl  0x10(%ebp)
  800ace:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad1:	50                   	push   %eax
  800ad2:	68 bc 06 80 00       	push   $0x8006bc
  800ad7:	e8 1a fc ff ff       	call   8006f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800adc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800adf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae5:	83 c4 10             	add    $0x10,%esp
  800ae8:	eb 05                	jmp    800aef <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800aea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    

00800af1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800afa:	50                   	push   %eax
  800afb:	ff 75 10             	pushl  0x10(%ebp)
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	ff 75 08             	pushl  0x8(%ebp)
  800b04:	e8 9a ff ff ff       	call   800aa3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    

00800b0b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	eb 03                	jmp    800b1b <strlen+0x10>
		n++;
  800b18:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b1b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1f:	75 f7                	jne    800b18 <strlen+0xd>
		n++;
	return n;
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	eb 03                	jmp    800b36 <strnlen+0x13>
		n++;
  800b33:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b36:	39 c2                	cmp    %eax,%edx
  800b38:	74 08                	je     800b42 <strnlen+0x1f>
  800b3a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3e:	75 f3                	jne    800b33 <strnlen+0x10>
  800b40:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	53                   	push   %ebx
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	83 c1 01             	add    $0x1,%ecx
  800b56:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b5a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5d:	84 db                	test   %bl,%bl
  800b5f:	75 ef                	jne    800b50 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b61:	5b                   	pop    %ebx
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	53                   	push   %ebx
  800b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b6b:	53                   	push   %ebx
  800b6c:	e8 9a ff ff ff       	call   800b0b <strlen>
  800b71:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b74:	ff 75 0c             	pushl  0xc(%ebp)
  800b77:	01 d8                	add    %ebx,%eax
  800b79:	50                   	push   %eax
  800b7a:	e8 c5 ff ff ff       	call   800b44 <strcpy>
	return dst;
}
  800b7f:	89 d8                	mov    %ebx,%eax
  800b81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    

00800b86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	89 f3                	mov    %esi,%ebx
  800b93:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b96:	89 f2                	mov    %esi,%edx
  800b98:	eb 0f                	jmp    800ba9 <strncpy+0x23>
		*dst++ = *src;
  800b9a:	83 c2 01             	add    $0x1,%edx
  800b9d:	0f b6 01             	movzbl (%ecx),%eax
  800ba0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba3:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba9:	39 da                	cmp    %ebx,%edx
  800bab:	75 ed                	jne    800b9a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 10             	mov    0x10(%ebp),%edx
  800bc1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc3:	85 d2                	test   %edx,%edx
  800bc5:	74 21                	je     800be8 <strlcpy+0x35>
  800bc7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bcb:	89 f2                	mov    %esi,%edx
  800bcd:	eb 09                	jmp    800bd8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	83 c1 01             	add    $0x1,%ecx
  800bd5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd8:	39 c2                	cmp    %eax,%edx
  800bda:	74 09                	je     800be5 <strlcpy+0x32>
  800bdc:	0f b6 19             	movzbl (%ecx),%ebx
  800bdf:	84 db                	test   %bl,%bl
  800be1:	75 ec                	jne    800bcf <strlcpy+0x1c>
  800be3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be8:	29 f0                	sub    %esi,%eax
}
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf7:	eb 06                	jmp    800bff <strcmp+0x11>
		p++, q++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
  800bfc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bff:	0f b6 01             	movzbl (%ecx),%eax
  800c02:	84 c0                	test   %al,%al
  800c04:	74 04                	je     800c0a <strcmp+0x1c>
  800c06:	3a 02                	cmp    (%edx),%al
  800c08:	74 ef                	je     800bf9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c0a:	0f b6 c0             	movzbl %al,%eax
  800c0d:	0f b6 12             	movzbl (%edx),%edx
  800c10:	29 d0                	sub    %edx,%eax
}
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	53                   	push   %ebx
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1e:	89 c3                	mov    %eax,%ebx
  800c20:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c23:	eb 06                	jmp    800c2b <strncmp+0x17>
		n--, p++, q++;
  800c25:	83 c0 01             	add    $0x1,%eax
  800c28:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c2b:	39 d8                	cmp    %ebx,%eax
  800c2d:	74 15                	je     800c44 <strncmp+0x30>
  800c2f:	0f b6 08             	movzbl (%eax),%ecx
  800c32:	84 c9                	test   %cl,%cl
  800c34:	74 04                	je     800c3a <strncmp+0x26>
  800c36:	3a 0a                	cmp    (%edx),%cl
  800c38:	74 eb                	je     800c25 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c3a:	0f b6 00             	movzbl (%eax),%eax
  800c3d:	0f b6 12             	movzbl (%edx),%edx
  800c40:	29 d0                	sub    %edx,%eax
  800c42:	eb 05                	jmp    800c49 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c56:	eb 07                	jmp    800c5f <strchr+0x13>
		if (*s == c)
  800c58:	38 ca                	cmp    %cl,%dl
  800c5a:	74 0f                	je     800c6b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5c:	83 c0 01             	add    $0x1,%eax
  800c5f:	0f b6 10             	movzbl (%eax),%edx
  800c62:	84 d2                	test   %dl,%dl
  800c64:	75 f2                	jne    800c58 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	8b 45 08             	mov    0x8(%ebp),%eax
  800c73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c77:	eb 03                	jmp    800c7c <strfind+0xf>
  800c79:	83 c0 01             	add    $0x1,%eax
  800c7c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7f:	38 ca                	cmp    %cl,%dl
  800c81:	74 04                	je     800c87 <strfind+0x1a>
  800c83:	84 d2                	test   %dl,%dl
  800c85:	75 f2                	jne    800c79 <strfind+0xc>
			break;
	return (char *) s;
}
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c95:	85 c9                	test   %ecx,%ecx
  800c97:	74 36                	je     800ccf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9f:	75 28                	jne    800cc9 <memset+0x40>
  800ca1:	f6 c1 03             	test   $0x3,%cl
  800ca4:	75 23                	jne    800cc9 <memset+0x40>
		c &= 0xFF;
  800ca6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800caa:	89 d3                	mov    %edx,%ebx
  800cac:	c1 e3 08             	shl    $0x8,%ebx
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	c1 e6 18             	shl    $0x18,%esi
  800cb4:	89 d0                	mov    %edx,%eax
  800cb6:	c1 e0 10             	shl    $0x10,%eax
  800cb9:	09 f0                	or     %esi,%eax
  800cbb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbd:	89 d8                	mov    %ebx,%eax
  800cbf:	09 d0                	or     %edx,%eax
  800cc1:	c1 e9 02             	shr    $0x2,%ecx
  800cc4:	fc                   	cld    
  800cc5:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc7:	eb 06                	jmp    800ccf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccc:	fc                   	cld    
  800ccd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccf:	89 f8                	mov    %edi,%eax
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce4:	39 c6                	cmp    %eax,%esi
  800ce6:	73 35                	jae    800d1d <memmove+0x47>
  800ce8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ceb:	39 d0                	cmp    %edx,%eax
  800ced:	73 2e                	jae    800d1d <memmove+0x47>
		s += n;
		d += n;
  800cef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf2:	89 d6                	mov    %edx,%esi
  800cf4:	09 fe                	or     %edi,%esi
  800cf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfc:	75 13                	jne    800d11 <memmove+0x3b>
  800cfe:	f6 c1 03             	test   $0x3,%cl
  800d01:	75 0e                	jne    800d11 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d03:	83 ef 04             	sub    $0x4,%edi
  800d06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d09:	c1 e9 02             	shr    $0x2,%ecx
  800d0c:	fd                   	std    
  800d0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0f:	eb 09                	jmp    800d1a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d11:	83 ef 01             	sub    $0x1,%edi
  800d14:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d17:	fd                   	std    
  800d18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d1a:	fc                   	cld    
  800d1b:	eb 1d                	jmp    800d3a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1d:	89 f2                	mov    %esi,%edx
  800d1f:	09 c2                	or     %eax,%edx
  800d21:	f6 c2 03             	test   $0x3,%dl
  800d24:	75 0f                	jne    800d35 <memmove+0x5f>
  800d26:	f6 c1 03             	test   $0x3,%cl
  800d29:	75 0a                	jne    800d35 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d2b:	c1 e9 02             	shr    $0x2,%ecx
  800d2e:	89 c7                	mov    %eax,%edi
  800d30:	fc                   	cld    
  800d31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d33:	eb 05                	jmp    800d3a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d35:	89 c7                	mov    %eax,%edi
  800d37:	fc                   	cld    
  800d38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d41:	ff 75 10             	pushl  0x10(%ebp)
  800d44:	ff 75 0c             	pushl  0xc(%ebp)
  800d47:	ff 75 08             	pushl  0x8(%ebp)
  800d4a:	e8 87 ff ff ff       	call   800cd6 <memmove>
}
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    

00800d51 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5c:	89 c6                	mov    %eax,%esi
  800d5e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d61:	eb 1a                	jmp    800d7d <memcmp+0x2c>
		if (*s1 != *s2)
  800d63:	0f b6 08             	movzbl (%eax),%ecx
  800d66:	0f b6 1a             	movzbl (%edx),%ebx
  800d69:	38 d9                	cmp    %bl,%cl
  800d6b:	74 0a                	je     800d77 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6d:	0f b6 c1             	movzbl %cl,%eax
  800d70:	0f b6 db             	movzbl %bl,%ebx
  800d73:	29 d8                	sub    %ebx,%eax
  800d75:	eb 0f                	jmp    800d86 <memcmp+0x35>
		s1++, s2++;
  800d77:	83 c0 01             	add    $0x1,%eax
  800d7a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7d:	39 f0                	cmp    %esi,%eax
  800d7f:	75 e2                	jne    800d63 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	53                   	push   %ebx
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d91:	89 c1                	mov    %eax,%ecx
  800d93:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d96:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d9a:	eb 0a                	jmp    800da6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9c:	0f b6 10             	movzbl (%eax),%edx
  800d9f:	39 da                	cmp    %ebx,%edx
  800da1:	74 07                	je     800daa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da3:	83 c0 01             	add    $0x1,%eax
  800da6:	39 c8                	cmp    %ecx,%eax
  800da8:	72 f2                	jb     800d9c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800daa:	5b                   	pop    %ebx
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db9:	eb 03                	jmp    800dbe <strtol+0x11>
		s++;
  800dbb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbe:	0f b6 01             	movzbl (%ecx),%eax
  800dc1:	3c 20                	cmp    $0x20,%al
  800dc3:	74 f6                	je     800dbb <strtol+0xe>
  800dc5:	3c 09                	cmp    $0x9,%al
  800dc7:	74 f2                	je     800dbb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc9:	3c 2b                	cmp    $0x2b,%al
  800dcb:	75 0a                	jne    800dd7 <strtol+0x2a>
		s++;
  800dcd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd5:	eb 11                	jmp    800de8 <strtol+0x3b>
  800dd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ddc:	3c 2d                	cmp    $0x2d,%al
  800dde:	75 08                	jne    800de8 <strtol+0x3b>
		s++, neg = 1;
  800de0:	83 c1 01             	add    $0x1,%ecx
  800de3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dee:	75 15                	jne    800e05 <strtol+0x58>
  800df0:	80 39 30             	cmpb   $0x30,(%ecx)
  800df3:	75 10                	jne    800e05 <strtol+0x58>
  800df5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df9:	75 7c                	jne    800e77 <strtol+0xca>
		s += 2, base = 16;
  800dfb:	83 c1 02             	add    $0x2,%ecx
  800dfe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e03:	eb 16                	jmp    800e1b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e05:	85 db                	test   %ebx,%ebx
  800e07:	75 12                	jne    800e1b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e09:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0e:	80 39 30             	cmpb   $0x30,(%ecx)
  800e11:	75 08                	jne    800e1b <strtol+0x6e>
		s++, base = 8;
  800e13:	83 c1 01             	add    $0x1,%ecx
  800e16:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e23:	0f b6 11             	movzbl (%ecx),%edx
  800e26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e29:	89 f3                	mov    %esi,%ebx
  800e2b:	80 fb 09             	cmp    $0x9,%bl
  800e2e:	77 08                	ja     800e38 <strtol+0x8b>
			dig = *s - '0';
  800e30:	0f be d2             	movsbl %dl,%edx
  800e33:	83 ea 30             	sub    $0x30,%edx
  800e36:	eb 22                	jmp    800e5a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e38:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e3b:	89 f3                	mov    %esi,%ebx
  800e3d:	80 fb 19             	cmp    $0x19,%bl
  800e40:	77 08                	ja     800e4a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e42:	0f be d2             	movsbl %dl,%edx
  800e45:	83 ea 57             	sub    $0x57,%edx
  800e48:	eb 10                	jmp    800e5a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e4a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4d:	89 f3                	mov    %esi,%ebx
  800e4f:	80 fb 19             	cmp    $0x19,%bl
  800e52:	77 16                	ja     800e6a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e54:	0f be d2             	movsbl %dl,%edx
  800e57:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e5a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5d:	7d 0b                	jge    800e6a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5f:	83 c1 01             	add    $0x1,%ecx
  800e62:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e66:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e68:	eb b9                	jmp    800e23 <strtol+0x76>

	if (endptr)
  800e6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6e:	74 0d                	je     800e7d <strtol+0xd0>
		*endptr = (char *) s;
  800e70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e73:	89 0e                	mov    %ecx,(%esi)
  800e75:	eb 06                	jmp    800e7d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e77:	85 db                	test   %ebx,%ebx
  800e79:	74 98                	je     800e13 <strtol+0x66>
  800e7b:	eb 9e                	jmp    800e1b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7d:	89 c2                	mov    %eax,%edx
  800e7f:	f7 da                	neg    %edx
  800e81:	85 ff                	test   %edi,%edi
  800e83:	0f 45 c2             	cmovne %edx,%eax
}
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	89 c3                	mov    %eax,%ebx
  800e9e:	89 c7                	mov    %eax,%edi
  800ea0:	89 c6                	mov    %eax,%esi
  800ea2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb9:	89 d1                	mov    %edx,%ecx
  800ebb:	89 d3                	mov    %edx,%ebx
  800ebd:	89 d7                	mov    %edx,%edi
  800ebf:	89 d6                	mov    %edx,%esi
  800ec1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed6:	b8 03 00 00 00       	mov    $0x3,%eax
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	89 cb                	mov    %ecx,%ebx
  800ee0:	89 cf                	mov    %ecx,%edi
  800ee2:	89 ce                	mov    %ecx,%esi
  800ee4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	7e 17                	jle    800f01 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	50                   	push   %eax
  800eee:	6a 03                	push   $0x3
  800ef0:	68 1f 2b 80 00       	push   $0x802b1f
  800ef5:	6a 23                	push   $0x23
  800ef7:	68 3c 2b 80 00       	push   $0x802b3c
  800efc:	e8 cc 13 00 00       	call   8022cd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f14:	b8 02 00 00 00       	mov    $0x2,%eax
  800f19:	89 d1                	mov    %edx,%ecx
  800f1b:	89 d3                	mov    %edx,%ebx
  800f1d:	89 d7                	mov    %edx,%edi
  800f1f:	89 d6                	mov    %edx,%esi
  800f21:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_yield>:

void
sys_yield(void)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f38:	89 d1                	mov    %edx,%ecx
  800f3a:	89 d3                	mov    %edx,%ebx
  800f3c:	89 d7                	mov    %edx,%edi
  800f3e:	89 d6                	mov    %edx,%esi
  800f40:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	be 00 00 00 00       	mov    $0x0,%esi
  800f55:	b8 04 00 00 00       	mov    $0x4,%eax
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f63:	89 f7                	mov    %esi,%edi
  800f65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f67:	85 c0                	test   %eax,%eax
  800f69:	7e 17                	jle    800f82 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	50                   	push   %eax
  800f6f:	6a 04                	push   $0x4
  800f71:	68 1f 2b 80 00       	push   $0x802b1f
  800f76:	6a 23                	push   $0x23
  800f78:	68 3c 2b 80 00       	push   $0x802b3c
  800f7d:	e8 4b 13 00 00       	call   8022cd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f93:	b8 05 00 00 00       	mov    $0x5,%eax
  800f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa4:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 17                	jle    800fc4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	50                   	push   %eax
  800fb1:	6a 05                	push   $0x5
  800fb3:	68 1f 2b 80 00       	push   $0x802b1f
  800fb8:	6a 23                	push   $0x23
  800fba:	68 3c 2b 80 00       	push   $0x802b3c
  800fbf:	e8 09 13 00 00       	call   8022cd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc7:	5b                   	pop    %ebx
  800fc8:	5e                   	pop    %esi
  800fc9:	5f                   	pop    %edi
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	57                   	push   %edi
  800fd0:	56                   	push   %esi
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fda:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe5:	89 df                	mov    %ebx,%edi
  800fe7:	89 de                	mov    %ebx,%esi
  800fe9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	7e 17                	jle    801006 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	50                   	push   %eax
  800ff3:	6a 06                	push   $0x6
  800ff5:	68 1f 2b 80 00       	push   $0x802b1f
  800ffa:	6a 23                	push   $0x23
  800ffc:	68 3c 2b 80 00       	push   $0x802b3c
  801001:	e8 c7 12 00 00       	call   8022cd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801006:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801017:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101c:	b8 08 00 00 00       	mov    $0x8,%eax
  801021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	89 df                	mov    %ebx,%edi
  801029:	89 de                	mov    %ebx,%esi
  80102b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102d:	85 c0                	test   %eax,%eax
  80102f:	7e 17                	jle    801048 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	50                   	push   %eax
  801035:	6a 08                	push   $0x8
  801037:	68 1f 2b 80 00       	push   $0x802b1f
  80103c:	6a 23                	push   $0x23
  80103e:	68 3c 2b 80 00       	push   $0x802b3c
  801043:	e8 85 12 00 00       	call   8022cd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801048:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
  801056:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801059:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105e:	b8 09 00 00 00       	mov    $0x9,%eax
  801063:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
  801069:	89 df                	mov    %ebx,%edi
  80106b:	89 de                	mov    %ebx,%esi
  80106d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106f:	85 c0                	test   %eax,%eax
  801071:	7e 17                	jle    80108a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	50                   	push   %eax
  801077:	6a 09                	push   $0x9
  801079:	68 1f 2b 80 00       	push   $0x802b1f
  80107e:	6a 23                	push   $0x23
  801080:	68 3c 2b 80 00       	push   $0x802b3c
  801085:	e8 43 12 00 00       	call   8022cd <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80108a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108d:	5b                   	pop    %ebx
  80108e:	5e                   	pop    %esi
  80108f:	5f                   	pop    %edi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ab:	89 df                	mov    %ebx,%edi
  8010ad:	89 de                	mov    %ebx,%esi
  8010af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	7e 17                	jle    8010cc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	50                   	push   %eax
  8010b9:	6a 0a                	push   $0xa
  8010bb:	68 1f 2b 80 00       	push   $0x802b1f
  8010c0:	6a 23                	push   $0x23
  8010c2:	68 3c 2b 80 00       	push   $0x802b3c
  8010c7:	e8 01 12 00 00       	call   8022cd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  8010da:	be 00 00 00 00       	mov    $0x0,%esi
  8010df:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ed:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801100:	b9 00 00 00 00       	mov    $0x0,%ecx
  801105:	b8 0d 00 00 00       	mov    $0xd,%eax
  80110a:	8b 55 08             	mov    0x8(%ebp),%edx
  80110d:	89 cb                	mov    %ecx,%ebx
  80110f:	89 cf                	mov    %ecx,%edi
  801111:	89 ce                	mov    %ecx,%esi
  801113:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801115:	85 c0                	test   %eax,%eax
  801117:	7e 17                	jle    801130 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801119:	83 ec 0c             	sub    $0xc,%esp
  80111c:	50                   	push   %eax
  80111d:	6a 0d                	push   $0xd
  80111f:	68 1f 2b 80 00       	push   $0x802b1f
  801124:	6a 23                	push   $0x23
  801126:	68 3c 2b 80 00       	push   $0x802b3c
  80112b:	e8 9d 11 00 00       	call   8022cd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113e:	ba 00 00 00 00       	mov    $0x0,%edx
  801143:	b8 0e 00 00 00       	mov    $0xe,%eax
  801148:	89 d1                	mov    %edx,%ecx
  80114a:	89 d3                	mov    %edx,%ebx
  80114c:	89 d7                	mov    %edx,%edi
  80114e:	89 d6                	mov    %edx,%esi
  801150:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5f                   	pop    %edi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801162:	b8 0f 00 00 00       	mov    $0xf,%eax
  801167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116a:	8b 55 08             	mov    0x8(%ebp),%edx
  80116d:	89 df                	mov    %ebx,%edi
  80116f:	89 de                	mov    %ebx,%esi
  801171:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	05 00 00 00 30       	add    $0x30000000,%eax
  801183:	c1 e8 0c             	shr    $0xc,%eax
}
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	05 00 00 00 30       	add    $0x30000000,%eax
  801193:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801198:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	c1 ea 16             	shr    $0x16,%edx
  8011af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b6:	f6 c2 01             	test   $0x1,%dl
  8011b9:	74 11                	je     8011cc <fd_alloc+0x2d>
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	c1 ea 0c             	shr    $0xc,%edx
  8011c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c7:	f6 c2 01             	test   $0x1,%dl
  8011ca:	75 09                	jne    8011d5 <fd_alloc+0x36>
			*fd_store = fd;
  8011cc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d3:	eb 17                	jmp    8011ec <fd_alloc+0x4d>
  8011d5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011da:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011df:	75 c9                	jne    8011aa <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f4:	83 f8 1f             	cmp    $0x1f,%eax
  8011f7:	77 36                	ja     80122f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f9:	c1 e0 0c             	shl    $0xc,%eax
  8011fc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801201:	89 c2                	mov    %eax,%edx
  801203:	c1 ea 16             	shr    $0x16,%edx
  801206:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120d:	f6 c2 01             	test   $0x1,%dl
  801210:	74 24                	je     801236 <fd_lookup+0x48>
  801212:	89 c2                	mov    %eax,%edx
  801214:	c1 ea 0c             	shr    $0xc,%edx
  801217:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121e:	f6 c2 01             	test   $0x1,%dl
  801221:	74 1a                	je     80123d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801223:	8b 55 0c             	mov    0xc(%ebp),%edx
  801226:	89 02                	mov    %eax,(%edx)
	return 0;
  801228:	b8 00 00 00 00       	mov    $0x0,%eax
  80122d:	eb 13                	jmp    801242 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801234:	eb 0c                	jmp    801242 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801236:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123b:	eb 05                	jmp    801242 <fd_lookup+0x54>
  80123d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 08             	sub    $0x8,%esp
  80124a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124d:	ba c8 2b 80 00       	mov    $0x802bc8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801252:	eb 13                	jmp    801267 <dev_lookup+0x23>
  801254:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801257:	39 08                	cmp    %ecx,(%eax)
  801259:	75 0c                	jne    801267 <dev_lookup+0x23>
			*dev = devtab[i];
  80125b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
  801265:	eb 2e                	jmp    801295 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801267:	8b 02                	mov    (%edx),%eax
  801269:	85 c0                	test   %eax,%eax
  80126b:	75 e7                	jne    801254 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126d:	a1 18 40 80 00       	mov    0x804018,%eax
  801272:	8b 40 48             	mov    0x48(%eax),%eax
  801275:	83 ec 04             	sub    $0x4,%esp
  801278:	51                   	push   %ecx
  801279:	50                   	push   %eax
  80127a:	68 4c 2b 80 00       	push   $0x802b4c
  80127f:	e8 3b f3 ff ff       	call   8005bf <cprintf>
	*dev = 0;
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
  801287:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	83 ec 10             	sub    $0x10,%esp
  80129f:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012af:	c1 e8 0c             	shr    $0xc,%eax
  8012b2:	50                   	push   %eax
  8012b3:	e8 36 ff ff ff       	call   8011ee <fd_lookup>
  8012b8:	83 c4 08             	add    $0x8,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 05                	js     8012c4 <fd_close+0x2d>
	    || fd != fd2)
  8012bf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c2:	74 0c                	je     8012d0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c4:	84 db                	test   %bl,%bl
  8012c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cb:	0f 44 c2             	cmove  %edx,%eax
  8012ce:	eb 41                	jmp    801311 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d6:	50                   	push   %eax
  8012d7:	ff 36                	pushl  (%esi)
  8012d9:	e8 66 ff ff ff       	call   801244 <dev_lookup>
  8012de:	89 c3                	mov    %eax,%ebx
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 1a                	js     801301 <fd_close+0x6a>
		if (dev->dev_close)
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ed:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	74 0b                	je     801301 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012f6:	83 ec 0c             	sub    $0xc,%esp
  8012f9:	56                   	push   %esi
  8012fa:	ff d0                	call   *%eax
  8012fc:	89 c3                	mov    %eax,%ebx
  8012fe:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	56                   	push   %esi
  801305:	6a 00                	push   $0x0
  801307:	e8 c0 fc ff ff       	call   800fcc <sys_page_unmap>
	return r;
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	89 d8                	mov    %ebx,%eax
}
  801311:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	ff 75 08             	pushl  0x8(%ebp)
  801325:	e8 c4 fe ff ff       	call   8011ee <fd_lookup>
  80132a:	83 c4 08             	add    $0x8,%esp
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 10                	js     801341 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	6a 01                	push   $0x1
  801336:	ff 75 f4             	pushl  -0xc(%ebp)
  801339:	e8 59 ff ff ff       	call   801297 <fd_close>
  80133e:	83 c4 10             	add    $0x10,%esp
}
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <close_all>:

void
close_all(void)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	53                   	push   %ebx
  801347:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	53                   	push   %ebx
  801353:	e8 c0 ff ff ff       	call   801318 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801358:	83 c3 01             	add    $0x1,%ebx
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	83 fb 20             	cmp    $0x20,%ebx
  801361:	75 ec                	jne    80134f <close_all+0xc>
		close(i);
}
  801363:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	57                   	push   %edi
  80136c:	56                   	push   %esi
  80136d:	53                   	push   %ebx
  80136e:	83 ec 2c             	sub    $0x2c,%esp
  801371:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801374:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	ff 75 08             	pushl  0x8(%ebp)
  80137b:	e8 6e fe ff ff       	call   8011ee <fd_lookup>
  801380:	83 c4 08             	add    $0x8,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	0f 88 c1 00 00 00    	js     80144c <dup+0xe4>
		return r;
	close(newfdnum);
  80138b:	83 ec 0c             	sub    $0xc,%esp
  80138e:	56                   	push   %esi
  80138f:	e8 84 ff ff ff       	call   801318 <close>

	newfd = INDEX2FD(newfdnum);
  801394:	89 f3                	mov    %esi,%ebx
  801396:	c1 e3 0c             	shl    $0xc,%ebx
  801399:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80139f:	83 c4 04             	add    $0x4,%esp
  8013a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a5:	e8 de fd ff ff       	call   801188 <fd2data>
  8013aa:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ac:	89 1c 24             	mov    %ebx,(%esp)
  8013af:	e8 d4 fd ff ff       	call   801188 <fd2data>
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ba:	89 f8                	mov    %edi,%eax
  8013bc:	c1 e8 16             	shr    $0x16,%eax
  8013bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c6:	a8 01                	test   $0x1,%al
  8013c8:	74 37                	je     801401 <dup+0x99>
  8013ca:	89 f8                	mov    %edi,%eax
  8013cc:	c1 e8 0c             	shr    $0xc,%eax
  8013cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d6:	f6 c2 01             	test   $0x1,%dl
  8013d9:	74 26                	je     801401 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ea:	50                   	push   %eax
  8013eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ee:	6a 00                	push   $0x0
  8013f0:	57                   	push   %edi
  8013f1:	6a 00                	push   $0x0
  8013f3:	e8 92 fb ff ff       	call   800f8a <sys_page_map>
  8013f8:	89 c7                	mov    %eax,%edi
  8013fa:	83 c4 20             	add    $0x20,%esp
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 2e                	js     80142f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801404:	89 d0                	mov    %edx,%eax
  801406:	c1 e8 0c             	shr    $0xc,%eax
  801409:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	25 07 0e 00 00       	and    $0xe07,%eax
  801418:	50                   	push   %eax
  801419:	53                   	push   %ebx
  80141a:	6a 00                	push   $0x0
  80141c:	52                   	push   %edx
  80141d:	6a 00                	push   $0x0
  80141f:	e8 66 fb ff ff       	call   800f8a <sys_page_map>
  801424:	89 c7                	mov    %eax,%edi
  801426:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801429:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142b:	85 ff                	test   %edi,%edi
  80142d:	79 1d                	jns    80144c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	53                   	push   %ebx
  801433:	6a 00                	push   $0x0
  801435:	e8 92 fb ff ff       	call   800fcc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143a:	83 c4 08             	add    $0x8,%esp
  80143d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801440:	6a 00                	push   $0x0
  801442:	e8 85 fb ff ff       	call   800fcc <sys_page_unmap>
	return r;
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	89 f8                	mov    %edi,%eax
}
  80144c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5f                   	pop    %edi
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    

00801454 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	53                   	push   %ebx
  801458:	83 ec 14             	sub    $0x14,%esp
  80145b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	53                   	push   %ebx
  801463:	e8 86 fd ff ff       	call   8011ee <fd_lookup>
  801468:	83 c4 08             	add    $0x8,%esp
  80146b:	89 c2                	mov    %eax,%edx
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 6d                	js     8014de <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147b:	ff 30                	pushl  (%eax)
  80147d:	e8 c2 fd ff ff       	call   801244 <dev_lookup>
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 4c                	js     8014d5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801489:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148c:	8b 42 08             	mov    0x8(%edx),%eax
  80148f:	83 e0 03             	and    $0x3,%eax
  801492:	83 f8 01             	cmp    $0x1,%eax
  801495:	75 21                	jne    8014b8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801497:	a1 18 40 80 00       	mov    0x804018,%eax
  80149c:	8b 40 48             	mov    0x48(%eax),%eax
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	53                   	push   %ebx
  8014a3:	50                   	push   %eax
  8014a4:	68 8d 2b 80 00       	push   $0x802b8d
  8014a9:	e8 11 f1 ff ff       	call   8005bf <cprintf>
		return -E_INVAL;
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b6:	eb 26                	jmp    8014de <read+0x8a>
	}
	if (!dev->dev_read)
  8014b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bb:	8b 40 08             	mov    0x8(%eax),%eax
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	74 17                	je     8014d9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	ff 75 10             	pushl  0x10(%ebp)
  8014c8:	ff 75 0c             	pushl  0xc(%ebp)
  8014cb:	52                   	push   %edx
  8014cc:	ff d0                	call   *%eax
  8014ce:	89 c2                	mov    %eax,%edx
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	eb 09                	jmp    8014de <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d5:	89 c2                	mov    %eax,%edx
  8014d7:	eb 05                	jmp    8014de <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014de:	89 d0                	mov    %edx,%eax
  8014e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	57                   	push   %edi
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 0c             	sub    $0xc,%esp
  8014ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f9:	eb 21                	jmp    80151c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	89 f0                	mov    %esi,%eax
  801500:	29 d8                	sub    %ebx,%eax
  801502:	50                   	push   %eax
  801503:	89 d8                	mov    %ebx,%eax
  801505:	03 45 0c             	add    0xc(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	57                   	push   %edi
  80150a:	e8 45 ff ff ff       	call   801454 <read>
		if (m < 0)
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	78 10                	js     801526 <readn+0x41>
			return m;
		if (m == 0)
  801516:	85 c0                	test   %eax,%eax
  801518:	74 0a                	je     801524 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151a:	01 c3                	add    %eax,%ebx
  80151c:	39 f3                	cmp    %esi,%ebx
  80151e:	72 db                	jb     8014fb <readn+0x16>
  801520:	89 d8                	mov    %ebx,%eax
  801522:	eb 02                	jmp    801526 <readn+0x41>
  801524:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801526:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801529:	5b                   	pop    %ebx
  80152a:	5e                   	pop    %esi
  80152b:	5f                   	pop    %edi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 14             	sub    $0x14,%esp
  801535:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801538:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	53                   	push   %ebx
  80153d:	e8 ac fc ff ff       	call   8011ee <fd_lookup>
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	89 c2                	mov    %eax,%edx
  801547:	85 c0                	test   %eax,%eax
  801549:	78 68                	js     8015b3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801555:	ff 30                	pushl  (%eax)
  801557:	e8 e8 fc ff ff       	call   801244 <dev_lookup>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 47                	js     8015aa <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801566:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156a:	75 21                	jne    80158d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156c:	a1 18 40 80 00       	mov    0x804018,%eax
  801571:	8b 40 48             	mov    0x48(%eax),%eax
  801574:	83 ec 04             	sub    $0x4,%esp
  801577:	53                   	push   %ebx
  801578:	50                   	push   %eax
  801579:	68 a9 2b 80 00       	push   $0x802ba9
  80157e:	e8 3c f0 ff ff       	call   8005bf <cprintf>
		return -E_INVAL;
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158b:	eb 26                	jmp    8015b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801590:	8b 52 0c             	mov    0xc(%edx),%edx
  801593:	85 d2                	test   %edx,%edx
  801595:	74 17                	je     8015ae <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801597:	83 ec 04             	sub    $0x4,%esp
  80159a:	ff 75 10             	pushl  0x10(%ebp)
  80159d:	ff 75 0c             	pushl  0xc(%ebp)
  8015a0:	50                   	push   %eax
  8015a1:	ff d2                	call   *%edx
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	eb 09                	jmp    8015b3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	eb 05                	jmp    8015b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b3:	89 d0                	mov    %edx,%eax
  8015b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	ff 75 08             	pushl  0x8(%ebp)
  8015c7:	e8 22 fc ff ff       	call   8011ee <fd_lookup>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 0e                	js     8015e1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 14             	sub    $0x14,%esp
  8015ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	53                   	push   %ebx
  8015f2:	e8 f7 fb ff ff       	call   8011ee <fd_lookup>
  8015f7:	83 c4 08             	add    $0x8,%esp
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 65                	js     801665 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160a:	ff 30                	pushl  (%eax)
  80160c:	e8 33 fc ff ff       	call   801244 <dev_lookup>
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 44                	js     80165c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161f:	75 21                	jne    801642 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801621:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801626:	8b 40 48             	mov    0x48(%eax),%eax
  801629:	83 ec 04             	sub    $0x4,%esp
  80162c:	53                   	push   %ebx
  80162d:	50                   	push   %eax
  80162e:	68 6c 2b 80 00       	push   $0x802b6c
  801633:	e8 87 ef ff ff       	call   8005bf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801640:	eb 23                	jmp    801665 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801642:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801645:	8b 52 18             	mov    0x18(%edx),%edx
  801648:	85 d2                	test   %edx,%edx
  80164a:	74 14                	je     801660 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	ff 75 0c             	pushl  0xc(%ebp)
  801652:	50                   	push   %eax
  801653:	ff d2                	call   *%edx
  801655:	89 c2                	mov    %eax,%edx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 09                	jmp    801665 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	eb 05                	jmp    801665 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801660:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801665:	89 d0                	mov    %edx,%eax
  801667:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 14             	sub    $0x14,%esp
  801673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	ff 75 08             	pushl  0x8(%ebp)
  80167d:	e8 6c fb ff ff       	call   8011ee <fd_lookup>
  801682:	83 c4 08             	add    $0x8,%esp
  801685:	89 c2                	mov    %eax,%edx
  801687:	85 c0                	test   %eax,%eax
  801689:	78 58                	js     8016e3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	ff 30                	pushl  (%eax)
  801697:	e8 a8 fb ff ff       	call   801244 <dev_lookup>
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 37                	js     8016da <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016aa:	74 32                	je     8016de <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ac:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016af:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b6:	00 00 00 
	stat->st_isdir = 0;
  8016b9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c0:	00 00 00 
	stat->st_dev = dev;
  8016c3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	53                   	push   %ebx
  8016cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d0:	ff 50 14             	call   *0x14(%eax)
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	eb 09                	jmp    8016e3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	eb 05                	jmp    8016e3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e3:	89 d0                	mov    %edx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	6a 00                	push   $0x0
  8016f4:	ff 75 08             	pushl  0x8(%ebp)
  8016f7:	e8 e7 01 00 00       	call   8018e3 <open>
  8016fc:	89 c3                	mov    %eax,%ebx
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 1b                	js     801720 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	50                   	push   %eax
  80170c:	e8 5b ff ff ff       	call   80166c <fstat>
  801711:	89 c6                	mov    %eax,%esi
	close(fd);
  801713:	89 1c 24             	mov    %ebx,(%esp)
  801716:	e8 fd fb ff ff       	call   801318 <close>
	return r;
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	89 f0                	mov    %esi,%eax
}
  801720:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	89 c6                	mov    %eax,%esi
  80172e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801730:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  801737:	75 12                	jne    80174b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	6a 01                	push   $0x1
  80173e:	e8 91 0c 00 00       	call   8023d4 <ipc_find_env>
  801743:	a3 10 40 80 00       	mov    %eax,0x804010
  801748:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174b:	6a 07                	push   $0x7
  80174d:	68 00 50 80 00       	push   $0x805000
  801752:	56                   	push   %esi
  801753:	ff 35 10 40 80 00    	pushl  0x804010
  801759:	e8 22 0c 00 00       	call   802380 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175e:	83 c4 0c             	add    $0xc,%esp
  801761:	6a 00                	push   $0x0
  801763:	53                   	push   %ebx
  801764:	6a 00                	push   $0x0
  801766:	e8 a8 0b 00 00       	call   802313 <ipc_recv>
}
  80176b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8b 40 0c             	mov    0xc(%eax),%eax
  80177e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801783:	8b 45 0c             	mov    0xc(%ebp),%eax
  801786:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80178b:	ba 00 00 00 00       	mov    $0x0,%edx
  801790:	b8 02 00 00 00       	mov    $0x2,%eax
  801795:	e8 8d ff ff ff       	call   801727 <fsipc>
}
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b7:	e8 6b ff ff ff       	call   801727 <fsipc>
}
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017dd:	e8 45 ff ff ff       	call   801727 <fsipc>
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 2c                	js     801812 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	68 00 50 80 00       	push   $0x805000
  8017ee:	53                   	push   %ebx
  8017ef:	e8 50 f3 ff ff       	call   800b44 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f4:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017ff:	a1 84 50 80 00       	mov    0x805084,%eax
  801804:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	53                   	push   %ebx
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801821:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801826:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80182b:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80182e:	53                   	push   %ebx
  80182f:	ff 75 0c             	pushl  0xc(%ebp)
  801832:	68 08 50 80 00       	push   $0x805008
  801837:	e8 9a f4 ff ff       	call   800cd6 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	8b 40 0c             	mov    0xc(%eax),%eax
  801842:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801847:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 04 00 00 00       	mov    $0x4,%eax
  801857:	e8 cb fe ff ff       	call   801727 <fsipc>
	//panic("devfile_write not implemented");
}
  80185c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	56                   	push   %esi
  801865:	53                   	push   %ebx
  801866:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	8b 40 0c             	mov    0xc(%eax),%eax
  80186f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801874:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187a:	ba 00 00 00 00       	mov    $0x0,%edx
  80187f:	b8 03 00 00 00       	mov    $0x3,%eax
  801884:	e8 9e fe ff ff       	call   801727 <fsipc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 4b                	js     8018da <devfile_read+0x79>
		return r;
	assert(r <= n);
  80188f:	39 c6                	cmp    %eax,%esi
  801891:	73 16                	jae    8018a9 <devfile_read+0x48>
  801893:	68 dc 2b 80 00       	push   $0x802bdc
  801898:	68 e3 2b 80 00       	push   $0x802be3
  80189d:	6a 7c                	push   $0x7c
  80189f:	68 f8 2b 80 00       	push   $0x802bf8
  8018a4:	e8 24 0a 00 00       	call   8022cd <_panic>
	assert(r <= PGSIZE);
  8018a9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ae:	7e 16                	jle    8018c6 <devfile_read+0x65>
  8018b0:	68 03 2c 80 00       	push   $0x802c03
  8018b5:	68 e3 2b 80 00       	push   $0x802be3
  8018ba:	6a 7d                	push   $0x7d
  8018bc:	68 f8 2b 80 00       	push   $0x802bf8
  8018c1:	e8 07 0a 00 00       	call   8022cd <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c6:	83 ec 04             	sub    $0x4,%esp
  8018c9:	50                   	push   %eax
  8018ca:	68 00 50 80 00       	push   $0x805000
  8018cf:	ff 75 0c             	pushl  0xc(%ebp)
  8018d2:	e8 ff f3 ff ff       	call   800cd6 <memmove>
	return r;
  8018d7:	83 c4 10             	add    $0x10,%esp
}
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	53                   	push   %ebx
  8018e7:	83 ec 20             	sub    $0x20,%esp
  8018ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ed:	53                   	push   %ebx
  8018ee:	e8 18 f2 ff ff       	call   800b0b <strlen>
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fb:	7f 67                	jg     801964 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fd:	83 ec 0c             	sub    $0xc,%esp
  801900:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801903:	50                   	push   %eax
  801904:	e8 96 f8 ff ff       	call   80119f <fd_alloc>
  801909:	83 c4 10             	add    $0x10,%esp
		return r;
  80190c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 57                	js     801969 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801912:	83 ec 08             	sub    $0x8,%esp
  801915:	53                   	push   %ebx
  801916:	68 00 50 80 00       	push   $0x805000
  80191b:	e8 24 f2 ff ff       	call   800b44 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801920:	8b 45 0c             	mov    0xc(%ebp),%eax
  801923:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801928:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192b:	b8 01 00 00 00       	mov    $0x1,%eax
  801930:	e8 f2 fd ff ff       	call   801727 <fsipc>
  801935:	89 c3                	mov    %eax,%ebx
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	79 14                	jns    801952 <open+0x6f>
		fd_close(fd, 0);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	6a 00                	push   $0x0
  801943:	ff 75 f4             	pushl  -0xc(%ebp)
  801946:	e8 4c f9 ff ff       	call   801297 <fd_close>
		return r;
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	89 da                	mov    %ebx,%edx
  801950:	eb 17                	jmp    801969 <open+0x86>
	}

	return fd2num(fd);
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	ff 75 f4             	pushl  -0xc(%ebp)
  801958:	e8 1b f8 ff ff       	call   801178 <fd2num>
  80195d:	89 c2                	mov    %eax,%edx
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	eb 05                	jmp    801969 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801964:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801969:	89 d0                	mov    %edx,%eax
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801976:	ba 00 00 00 00       	mov    $0x0,%edx
  80197b:	b8 08 00 00 00       	mov    $0x8,%eax
  801980:	e8 a2 fd ff ff       	call   801727 <fsipc>
}
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80198d:	68 0f 2c 80 00       	push   $0x802c0f
  801992:	ff 75 0c             	pushl  0xc(%ebp)
  801995:	e8 aa f1 ff ff       	call   800b44 <strcpy>
	return 0;
}
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 10             	sub    $0x10,%esp
  8019a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019ab:	53                   	push   %ebx
  8019ac:	e8 5c 0a 00 00       	call   80240d <pageref>
  8019b1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019b4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019b9:	83 f8 01             	cmp    $0x1,%eax
  8019bc:	75 10                	jne    8019ce <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	ff 73 0c             	pushl  0xc(%ebx)
  8019c4:	e8 c0 02 00 00       	call   801c89 <nsipc_close>
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019ce:	89 d0                	mov    %edx,%eax
  8019d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019db:	6a 00                	push   $0x0
  8019dd:	ff 75 10             	pushl  0x10(%ebp)
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	ff 70 0c             	pushl  0xc(%eax)
  8019e9:	e8 78 03 00 00       	call   801d66 <nsipc_send>
}
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019f6:	6a 00                	push   $0x0
  8019f8:	ff 75 10             	pushl  0x10(%ebp)
  8019fb:	ff 75 0c             	pushl  0xc(%ebp)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	ff 70 0c             	pushl  0xc(%eax)
  801a04:	e8 f1 02 00 00       	call   801cfa <nsipc_recv>
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a11:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a14:	52                   	push   %edx
  801a15:	50                   	push   %eax
  801a16:	e8 d3 f7 ff ff       	call   8011ee <fd_lookup>
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 17                	js     801a39 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a2b:	39 08                	cmp    %ecx,(%eax)
  801a2d:	75 05                	jne    801a34 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a2f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a32:	eb 05                	jmp    801a39 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a34:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
  801a40:	83 ec 1c             	sub    $0x1c,%esp
  801a43:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a48:	50                   	push   %eax
  801a49:	e8 51 f7 ff ff       	call   80119f <fd_alloc>
  801a4e:	89 c3                	mov    %eax,%ebx
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 1b                	js     801a72 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a57:	83 ec 04             	sub    $0x4,%esp
  801a5a:	68 07 04 00 00       	push   $0x407
  801a5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a62:	6a 00                	push   $0x0
  801a64:	e8 de f4 ff ff       	call   800f47 <sys_page_alloc>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	79 10                	jns    801a82 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a72:	83 ec 0c             	sub    $0xc,%esp
  801a75:	56                   	push   %esi
  801a76:	e8 0e 02 00 00       	call   801c89 <nsipc_close>
		return r;
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	89 d8                	mov    %ebx,%eax
  801a80:	eb 24                	jmp    801aa6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a82:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a90:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a97:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	50                   	push   %eax
  801a9e:	e8 d5 f6 ff ff       	call   801178 <fd2num>
  801aa3:	83 c4 10             	add    $0x10,%esp
}
  801aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	e8 50 ff ff ff       	call   801a0b <fd2sockid>
		return r;
  801abb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 1f                	js     801ae0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac1:	83 ec 04             	sub    $0x4,%esp
  801ac4:	ff 75 10             	pushl  0x10(%ebp)
  801ac7:	ff 75 0c             	pushl  0xc(%ebp)
  801aca:	50                   	push   %eax
  801acb:	e8 12 01 00 00       	call   801be2 <nsipc_accept>
  801ad0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 07                	js     801ae0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ad9:	e8 5d ff ff ff       	call   801a3b <alloc_sockfd>
  801ade:	89 c1                	mov    %eax,%ecx
}
  801ae0:	89 c8                	mov    %ecx,%eax
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	e8 19 ff ff ff       	call   801a0b <fd2sockid>
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 12                	js     801b08 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801af6:	83 ec 04             	sub    $0x4,%esp
  801af9:	ff 75 10             	pushl  0x10(%ebp)
  801afc:	ff 75 0c             	pushl  0xc(%ebp)
  801aff:	50                   	push   %eax
  801b00:	e8 2d 01 00 00       	call   801c32 <nsipc_bind>
  801b05:	83 c4 10             	add    $0x10,%esp
}
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <shutdown>:

int
shutdown(int s, int how)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b10:	8b 45 08             	mov    0x8(%ebp),%eax
  801b13:	e8 f3 fe ff ff       	call   801a0b <fd2sockid>
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	78 0f                	js     801b2b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	ff 75 0c             	pushl  0xc(%ebp)
  801b22:	50                   	push   %eax
  801b23:	e8 3f 01 00 00       	call   801c67 <nsipc_shutdown>
  801b28:	83 c4 10             	add    $0x10,%esp
}
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	e8 d0 fe ff ff       	call   801a0b <fd2sockid>
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	78 12                	js     801b51 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b3f:	83 ec 04             	sub    $0x4,%esp
  801b42:	ff 75 10             	pushl  0x10(%ebp)
  801b45:	ff 75 0c             	pushl  0xc(%ebp)
  801b48:	50                   	push   %eax
  801b49:	e8 55 01 00 00       	call   801ca3 <nsipc_connect>
  801b4e:	83 c4 10             	add    $0x10,%esp
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <listen>:

int
listen(int s, int backlog)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	e8 aa fe ff ff       	call   801a0b <fd2sockid>
  801b61:	85 c0                	test   %eax,%eax
  801b63:	78 0f                	js     801b74 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b65:	83 ec 08             	sub    $0x8,%esp
  801b68:	ff 75 0c             	pushl  0xc(%ebp)
  801b6b:	50                   	push   %eax
  801b6c:	e8 67 01 00 00       	call   801cd8 <nsipc_listen>
  801b71:	83 c4 10             	add    $0x10,%esp
}
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b7c:	ff 75 10             	pushl  0x10(%ebp)
  801b7f:	ff 75 0c             	pushl  0xc(%ebp)
  801b82:	ff 75 08             	pushl  0x8(%ebp)
  801b85:	e8 3a 02 00 00       	call   801dc4 <nsipc_socket>
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	78 05                	js     801b96 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b91:	e8 a5 fe ff ff       	call   801a3b <alloc_sockfd>
}
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 04             	sub    $0x4,%esp
  801b9f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba1:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801ba8:	75 12                	jne    801bbc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	6a 02                	push   $0x2
  801baf:	e8 20 08 00 00       	call   8023d4 <ipc_find_env>
  801bb4:	a3 14 40 80 00       	mov    %eax,0x804014
  801bb9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bbc:	6a 07                	push   $0x7
  801bbe:	68 00 60 80 00       	push   $0x806000
  801bc3:	53                   	push   %ebx
  801bc4:	ff 35 14 40 80 00    	pushl  0x804014
  801bca:	e8 b1 07 00 00       	call   802380 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bcf:	83 c4 0c             	add    $0xc,%esp
  801bd2:	6a 00                	push   $0x0
  801bd4:	6a 00                	push   $0x0
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 36 07 00 00       	call   802313 <ipc_recv>
}
  801bdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	56                   	push   %esi
  801be6:	53                   	push   %ebx
  801be7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bf2:	8b 06                	mov    (%esi),%eax
  801bf4:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bf9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfe:	e8 95 ff ff ff       	call   801b98 <nsipc>
  801c03:	89 c3                	mov    %eax,%ebx
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 20                	js     801c29 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c09:	83 ec 04             	sub    $0x4,%esp
  801c0c:	ff 35 10 60 80 00    	pushl  0x806010
  801c12:	68 00 60 80 00       	push   $0x806000
  801c17:	ff 75 0c             	pushl  0xc(%ebp)
  801c1a:	e8 b7 f0 ff ff       	call   800cd6 <memmove>
		*addrlen = ret->ret_addrlen;
  801c1f:	a1 10 60 80 00       	mov    0x806010,%eax
  801c24:	89 06                	mov    %eax,(%esi)
  801c26:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c29:	89 d8                	mov    %ebx,%eax
  801c2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	53                   	push   %ebx
  801c36:	83 ec 08             	sub    $0x8,%esp
  801c39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c44:	53                   	push   %ebx
  801c45:	ff 75 0c             	pushl  0xc(%ebp)
  801c48:	68 04 60 80 00       	push   $0x806004
  801c4d:	e8 84 f0 ff ff       	call   800cd6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c52:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c58:	b8 02 00 00 00       	mov    $0x2,%eax
  801c5d:	e8 36 ff ff ff       	call   801b98 <nsipc>
}
  801c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c78:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c7d:	b8 03 00 00 00       	mov    $0x3,%eax
  801c82:	e8 11 ff ff ff       	call   801b98 <nsipc>
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <nsipc_close>:

int
nsipc_close(int s)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c97:	b8 04 00 00 00       	mov    $0x4,%eax
  801c9c:	e8 f7 fe ff ff       	call   801b98 <nsipc>
}
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 08             	sub    $0x8,%esp
  801caa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cad:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cb5:	53                   	push   %ebx
  801cb6:	ff 75 0c             	pushl  0xc(%ebp)
  801cb9:	68 04 60 80 00       	push   $0x806004
  801cbe:	e8 13 f0 ff ff       	call   800cd6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cc3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cc9:	b8 05 00 00 00       	mov    $0x5,%eax
  801cce:	e8 c5 fe ff ff       	call   801b98 <nsipc>
}
  801cd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cee:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf3:	e8 a0 fe ff ff       	call   801b98 <nsipc>
}
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	56                   	push   %esi
  801cfe:	53                   	push   %ebx
  801cff:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d02:	8b 45 08             	mov    0x8(%ebp),%eax
  801d05:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d0a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d10:	8b 45 14             	mov    0x14(%ebp),%eax
  801d13:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d18:	b8 07 00 00 00       	mov    $0x7,%eax
  801d1d:	e8 76 fe ff ff       	call   801b98 <nsipc>
  801d22:	89 c3                	mov    %eax,%ebx
  801d24:	85 c0                	test   %eax,%eax
  801d26:	78 35                	js     801d5d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d28:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d2d:	7f 04                	jg     801d33 <nsipc_recv+0x39>
  801d2f:	39 c6                	cmp    %eax,%esi
  801d31:	7d 16                	jge    801d49 <nsipc_recv+0x4f>
  801d33:	68 1b 2c 80 00       	push   $0x802c1b
  801d38:	68 e3 2b 80 00       	push   $0x802be3
  801d3d:	6a 62                	push   $0x62
  801d3f:	68 30 2c 80 00       	push   $0x802c30
  801d44:	e8 84 05 00 00       	call   8022cd <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d49:	83 ec 04             	sub    $0x4,%esp
  801d4c:	50                   	push   %eax
  801d4d:	68 00 60 80 00       	push   $0x806000
  801d52:	ff 75 0c             	pushl  0xc(%ebp)
  801d55:	e8 7c ef ff ff       	call   800cd6 <memmove>
  801d5a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d5d:	89 d8                	mov    %ebx,%eax
  801d5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d62:	5b                   	pop    %ebx
  801d63:	5e                   	pop    %esi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	53                   	push   %ebx
  801d6a:	83 ec 04             	sub    $0x4,%esp
  801d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d70:	8b 45 08             	mov    0x8(%ebp),%eax
  801d73:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d78:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d7e:	7e 16                	jle    801d96 <nsipc_send+0x30>
  801d80:	68 3c 2c 80 00       	push   $0x802c3c
  801d85:	68 e3 2b 80 00       	push   $0x802be3
  801d8a:	6a 6d                	push   $0x6d
  801d8c:	68 30 2c 80 00       	push   $0x802c30
  801d91:	e8 37 05 00 00       	call   8022cd <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d96:	83 ec 04             	sub    $0x4,%esp
  801d99:	53                   	push   %ebx
  801d9a:	ff 75 0c             	pushl  0xc(%ebp)
  801d9d:	68 0c 60 80 00       	push   $0x80600c
  801da2:	e8 2f ef ff ff       	call   800cd6 <memmove>
	nsipcbuf.send.req_size = size;
  801da7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dad:	8b 45 14             	mov    0x14(%ebp),%eax
  801db0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801db5:	b8 08 00 00 00       	mov    $0x8,%eax
  801dba:	e8 d9 fd ff ff       	call   801b98 <nsipc>
}
  801dbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dca:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dda:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801de2:	b8 09 00 00 00       	mov    $0x9,%eax
  801de7:	e8 ac fd ff ff       	call   801b98 <nsipc>
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801df6:	83 ec 0c             	sub    $0xc,%esp
  801df9:	ff 75 08             	pushl  0x8(%ebp)
  801dfc:	e8 87 f3 ff ff       	call   801188 <fd2data>
  801e01:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e03:	83 c4 08             	add    $0x8,%esp
  801e06:	68 48 2c 80 00       	push   $0x802c48
  801e0b:	53                   	push   %ebx
  801e0c:	e8 33 ed ff ff       	call   800b44 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e11:	8b 46 04             	mov    0x4(%esi),%eax
  801e14:	2b 06                	sub    (%esi),%eax
  801e16:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e1c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e23:	00 00 00 
	stat->st_dev = &devpipe;
  801e26:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e2d:	30 80 00 
	return 0;
}
  801e30:	b8 00 00 00 00       	mov    $0x0,%eax
  801e35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	53                   	push   %ebx
  801e40:	83 ec 0c             	sub    $0xc,%esp
  801e43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e46:	53                   	push   %ebx
  801e47:	6a 00                	push   $0x0
  801e49:	e8 7e f1 ff ff       	call   800fcc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e4e:	89 1c 24             	mov    %ebx,(%esp)
  801e51:	e8 32 f3 ff ff       	call   801188 <fd2data>
  801e56:	83 c4 08             	add    $0x8,%esp
  801e59:	50                   	push   %eax
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 6b f1 ff ff       	call   800fcc <sys_page_unmap>
}
  801e61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	57                   	push   %edi
  801e6a:	56                   	push   %esi
  801e6b:	53                   	push   %ebx
  801e6c:	83 ec 1c             	sub    $0x1c,%esp
  801e6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e72:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e74:	a1 18 40 80 00       	mov    0x804018,%eax
  801e79:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e7c:	83 ec 0c             	sub    $0xc,%esp
  801e7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801e82:	e8 86 05 00 00       	call   80240d <pageref>
  801e87:	89 c3                	mov    %eax,%ebx
  801e89:	89 3c 24             	mov    %edi,(%esp)
  801e8c:	e8 7c 05 00 00       	call   80240d <pageref>
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	39 c3                	cmp    %eax,%ebx
  801e96:	0f 94 c1             	sete   %cl
  801e99:	0f b6 c9             	movzbl %cl,%ecx
  801e9c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e9f:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801ea5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ea8:	39 ce                	cmp    %ecx,%esi
  801eaa:	74 1b                	je     801ec7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801eac:	39 c3                	cmp    %eax,%ebx
  801eae:	75 c4                	jne    801e74 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb0:	8b 42 58             	mov    0x58(%edx),%eax
  801eb3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801eb6:	50                   	push   %eax
  801eb7:	56                   	push   %esi
  801eb8:	68 4f 2c 80 00       	push   $0x802c4f
  801ebd:	e8 fd e6 ff ff       	call   8005bf <cprintf>
  801ec2:	83 c4 10             	add    $0x10,%esp
  801ec5:	eb ad                	jmp    801e74 <_pipeisclosed+0xe>
	}
}
  801ec7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 28             	sub    $0x28,%esp
  801edb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ede:	56                   	push   %esi
  801edf:	e8 a4 f2 ff ff       	call   801188 <fd2data>
  801ee4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	bf 00 00 00 00       	mov    $0x0,%edi
  801eee:	eb 4b                	jmp    801f3b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ef0:	89 da                	mov    %ebx,%edx
  801ef2:	89 f0                	mov    %esi,%eax
  801ef4:	e8 6d ff ff ff       	call   801e66 <_pipeisclosed>
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	75 48                	jne    801f45 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801efd:	e8 26 f0 ff ff       	call   800f28 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f02:	8b 43 04             	mov    0x4(%ebx),%eax
  801f05:	8b 0b                	mov    (%ebx),%ecx
  801f07:	8d 51 20             	lea    0x20(%ecx),%edx
  801f0a:	39 d0                	cmp    %edx,%eax
  801f0c:	73 e2                	jae    801ef0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f11:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f15:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f18:	89 c2                	mov    %eax,%edx
  801f1a:	c1 fa 1f             	sar    $0x1f,%edx
  801f1d:	89 d1                	mov    %edx,%ecx
  801f1f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f22:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f25:	83 e2 1f             	and    $0x1f,%edx
  801f28:	29 ca                	sub    %ecx,%edx
  801f2a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f2e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f32:	83 c0 01             	add    $0x1,%eax
  801f35:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f38:	83 c7 01             	add    $0x1,%edi
  801f3b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f3e:	75 c2                	jne    801f02 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f40:	8b 45 10             	mov    0x10(%ebp),%eax
  801f43:	eb 05                	jmp    801f4a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    

00801f52 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	57                   	push   %edi
  801f56:	56                   	push   %esi
  801f57:	53                   	push   %ebx
  801f58:	83 ec 18             	sub    $0x18,%esp
  801f5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f5e:	57                   	push   %edi
  801f5f:	e8 24 f2 ff ff       	call   801188 <fd2data>
  801f64:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f6e:	eb 3d                	jmp    801fad <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f70:	85 db                	test   %ebx,%ebx
  801f72:	74 04                	je     801f78 <devpipe_read+0x26>
				return i;
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	eb 44                	jmp    801fbc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f78:	89 f2                	mov    %esi,%edx
  801f7a:	89 f8                	mov    %edi,%eax
  801f7c:	e8 e5 fe ff ff       	call   801e66 <_pipeisclosed>
  801f81:	85 c0                	test   %eax,%eax
  801f83:	75 32                	jne    801fb7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f85:	e8 9e ef ff ff       	call   800f28 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f8a:	8b 06                	mov    (%esi),%eax
  801f8c:	3b 46 04             	cmp    0x4(%esi),%eax
  801f8f:	74 df                	je     801f70 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f91:	99                   	cltd   
  801f92:	c1 ea 1b             	shr    $0x1b,%edx
  801f95:	01 d0                	add    %edx,%eax
  801f97:	83 e0 1f             	and    $0x1f,%eax
  801f9a:	29 d0                	sub    %edx,%eax
  801f9c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fa7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801faa:	83 c3 01             	add    $0x1,%ebx
  801fad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fb0:	75 d8                	jne    801f8a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb5:	eb 05                	jmp    801fbc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5e                   	pop    %esi
  801fc1:	5f                   	pop    %edi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcf:	50                   	push   %eax
  801fd0:	e8 ca f1 ff ff       	call   80119f <fd_alloc>
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	89 c2                	mov    %eax,%edx
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	0f 88 2c 01 00 00    	js     80210e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe2:	83 ec 04             	sub    $0x4,%esp
  801fe5:	68 07 04 00 00       	push   $0x407
  801fea:	ff 75 f4             	pushl  -0xc(%ebp)
  801fed:	6a 00                	push   $0x0
  801fef:	e8 53 ef ff ff       	call   800f47 <sys_page_alloc>
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	89 c2                	mov    %eax,%edx
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	0f 88 0d 01 00 00    	js     80210e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802001:	83 ec 0c             	sub    $0xc,%esp
  802004:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802007:	50                   	push   %eax
  802008:	e8 92 f1 ff ff       	call   80119f <fd_alloc>
  80200d:	89 c3                	mov    %eax,%ebx
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	85 c0                	test   %eax,%eax
  802014:	0f 88 e2 00 00 00    	js     8020fc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201a:	83 ec 04             	sub    $0x4,%esp
  80201d:	68 07 04 00 00       	push   $0x407
  802022:	ff 75 f0             	pushl  -0x10(%ebp)
  802025:	6a 00                	push   $0x0
  802027:	e8 1b ef ff ff       	call   800f47 <sys_page_alloc>
  80202c:	89 c3                	mov    %eax,%ebx
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	0f 88 c3 00 00 00    	js     8020fc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802039:	83 ec 0c             	sub    $0xc,%esp
  80203c:	ff 75 f4             	pushl  -0xc(%ebp)
  80203f:	e8 44 f1 ff ff       	call   801188 <fd2data>
  802044:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802046:	83 c4 0c             	add    $0xc,%esp
  802049:	68 07 04 00 00       	push   $0x407
  80204e:	50                   	push   %eax
  80204f:	6a 00                	push   $0x0
  802051:	e8 f1 ee ff ff       	call   800f47 <sys_page_alloc>
  802056:	89 c3                	mov    %eax,%ebx
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	0f 88 89 00 00 00    	js     8020ec <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802063:	83 ec 0c             	sub    $0xc,%esp
  802066:	ff 75 f0             	pushl  -0x10(%ebp)
  802069:	e8 1a f1 ff ff       	call   801188 <fd2data>
  80206e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802075:	50                   	push   %eax
  802076:	6a 00                	push   $0x0
  802078:	56                   	push   %esi
  802079:	6a 00                	push   $0x0
  80207b:	e8 0a ef ff ff       	call   800f8a <sys_page_map>
  802080:	89 c3                	mov    %eax,%ebx
  802082:	83 c4 20             	add    $0x20,%esp
  802085:	85 c0                	test   %eax,%eax
  802087:	78 55                	js     8020de <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802089:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802092:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802094:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802097:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80209e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b3:	83 ec 0c             	sub    $0xc,%esp
  8020b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b9:	e8 ba f0 ff ff       	call   801178 <fd2num>
  8020be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c3:	83 c4 04             	add    $0x4,%esp
  8020c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c9:	e8 aa f0 ff ff       	call   801178 <fd2num>
  8020ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8020dc:	eb 30                	jmp    80210e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020de:	83 ec 08             	sub    $0x8,%esp
  8020e1:	56                   	push   %esi
  8020e2:	6a 00                	push   $0x0
  8020e4:	e8 e3 ee ff ff       	call   800fcc <sys_page_unmap>
  8020e9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020ec:	83 ec 08             	sub    $0x8,%esp
  8020ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 d3 ee ff ff       	call   800fcc <sys_page_unmap>
  8020f9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020fc:	83 ec 08             	sub    $0x8,%esp
  8020ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802102:	6a 00                	push   $0x0
  802104:	e8 c3 ee ff ff       	call   800fcc <sys_page_unmap>
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80210e:	89 d0                	mov    %edx,%eax
  802110:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5d                   	pop    %ebp
  802116:	c3                   	ret    

00802117 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802117:	55                   	push   %ebp
  802118:	89 e5                	mov    %esp,%ebp
  80211a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802120:	50                   	push   %eax
  802121:	ff 75 08             	pushl  0x8(%ebp)
  802124:	e8 c5 f0 ff ff       	call   8011ee <fd_lookup>
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	85 c0                	test   %eax,%eax
  80212e:	78 18                	js     802148 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802130:	83 ec 0c             	sub    $0xc,%esp
  802133:	ff 75 f4             	pushl  -0xc(%ebp)
  802136:	e8 4d f0 ff ff       	call   801188 <fd2data>
	return _pipeisclosed(fd, p);
  80213b:	89 c2                	mov    %eax,%edx
  80213d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802140:	e8 21 fd ff ff       	call   801e66 <_pipeisclosed>
  802145:	83 c4 10             	add    $0x10,%esp
}
  802148:	c9                   	leave  
  802149:	c3                   	ret    

0080214a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80214d:	b8 00 00 00 00       	mov    $0x0,%eax
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80215a:	68 67 2c 80 00       	push   $0x802c67
  80215f:	ff 75 0c             	pushl  0xc(%ebp)
  802162:	e8 dd e9 ff ff       	call   800b44 <strcpy>
	return 0;
}
  802167:	b8 00 00 00 00       	mov    $0x0,%eax
  80216c:	c9                   	leave  
  80216d:	c3                   	ret    

0080216e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80217a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802185:	eb 2d                	jmp    8021b4 <devcons_write+0x46>
		m = n - tot;
  802187:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80218a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80218c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80218f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802194:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802197:	83 ec 04             	sub    $0x4,%esp
  80219a:	53                   	push   %ebx
  80219b:	03 45 0c             	add    0xc(%ebp),%eax
  80219e:	50                   	push   %eax
  80219f:	57                   	push   %edi
  8021a0:	e8 31 eb ff ff       	call   800cd6 <memmove>
		sys_cputs(buf, m);
  8021a5:	83 c4 08             	add    $0x8,%esp
  8021a8:	53                   	push   %ebx
  8021a9:	57                   	push   %edi
  8021aa:	e8 dc ec ff ff       	call   800e8b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021af:	01 de                	add    %ebx,%esi
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	89 f0                	mov    %esi,%eax
  8021b6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021b9:	72 cc                	jb     802187 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021be:	5b                   	pop    %ebx
  8021bf:	5e                   	pop    %esi
  8021c0:	5f                   	pop    %edi
  8021c1:	5d                   	pop    %ebp
  8021c2:	c3                   	ret    

008021c3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	83 ec 08             	sub    $0x8,%esp
  8021c9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d2:	74 2a                	je     8021fe <devcons_read+0x3b>
  8021d4:	eb 05                	jmp    8021db <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021d6:	e8 4d ed ff ff       	call   800f28 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021db:	e8 c9 ec ff ff       	call   800ea9 <sys_cgetc>
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	74 f2                	je     8021d6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	78 16                	js     8021fe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021e8:	83 f8 04             	cmp    $0x4,%eax
  8021eb:	74 0c                	je     8021f9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f0:	88 02                	mov    %al,(%edx)
	return 1;
  8021f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f7:	eb 05                	jmp    8021fe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021f9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021fe:	c9                   	leave  
  8021ff:	c3                   	ret    

00802200 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802206:	8b 45 08             	mov    0x8(%ebp),%eax
  802209:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80220c:	6a 01                	push   $0x1
  80220e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802211:	50                   	push   %eax
  802212:	e8 74 ec ff ff       	call   800e8b <sys_cputs>
}
  802217:	83 c4 10             	add    $0x10,%esp
  80221a:	c9                   	leave  
  80221b:	c3                   	ret    

0080221c <getchar>:

int
getchar(void)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802222:	6a 01                	push   $0x1
  802224:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802227:	50                   	push   %eax
  802228:	6a 00                	push   $0x0
  80222a:	e8 25 f2 ff ff       	call   801454 <read>
	if (r < 0)
  80222f:	83 c4 10             	add    $0x10,%esp
  802232:	85 c0                	test   %eax,%eax
  802234:	78 0f                	js     802245 <getchar+0x29>
		return r;
	if (r < 1)
  802236:	85 c0                	test   %eax,%eax
  802238:	7e 06                	jle    802240 <getchar+0x24>
		return -E_EOF;
	return c;
  80223a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80223e:	eb 05                	jmp    802245 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802240:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802245:	c9                   	leave  
  802246:	c3                   	ret    

00802247 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802247:	55                   	push   %ebp
  802248:	89 e5                	mov    %esp,%ebp
  80224a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802250:	50                   	push   %eax
  802251:	ff 75 08             	pushl  0x8(%ebp)
  802254:	e8 95 ef ff ff       	call   8011ee <fd_lookup>
  802259:	83 c4 10             	add    $0x10,%esp
  80225c:	85 c0                	test   %eax,%eax
  80225e:	78 11                	js     802271 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802260:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802263:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802269:	39 10                	cmp    %edx,(%eax)
  80226b:	0f 94 c0             	sete   %al
  80226e:	0f b6 c0             	movzbl %al,%eax
}
  802271:	c9                   	leave  
  802272:	c3                   	ret    

00802273 <opencons>:

int
opencons(void)
{
  802273:	55                   	push   %ebp
  802274:	89 e5                	mov    %esp,%ebp
  802276:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802279:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227c:	50                   	push   %eax
  80227d:	e8 1d ef ff ff       	call   80119f <fd_alloc>
  802282:	83 c4 10             	add    $0x10,%esp
		return r;
  802285:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802287:	85 c0                	test   %eax,%eax
  802289:	78 3e                	js     8022c9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80228b:	83 ec 04             	sub    $0x4,%esp
  80228e:	68 07 04 00 00       	push   $0x407
  802293:	ff 75 f4             	pushl  -0xc(%ebp)
  802296:	6a 00                	push   $0x0
  802298:	e8 aa ec ff ff       	call   800f47 <sys_page_alloc>
  80229d:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	78 23                	js     8022c9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022a6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022af:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022bb:	83 ec 0c             	sub    $0xc,%esp
  8022be:	50                   	push   %eax
  8022bf:	e8 b4 ee ff ff       	call   801178 <fd2num>
  8022c4:	89 c2                	mov    %eax,%edx
  8022c6:	83 c4 10             	add    $0x10,%esp
}
  8022c9:	89 d0                	mov    %edx,%eax
  8022cb:	c9                   	leave  
  8022cc:	c3                   	ret    

008022cd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022cd:	55                   	push   %ebp
  8022ce:	89 e5                	mov    %esp,%ebp
  8022d0:	56                   	push   %esi
  8022d1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022d2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022d5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022db:	e8 29 ec ff ff       	call   800f09 <sys_getenvid>
  8022e0:	83 ec 0c             	sub    $0xc,%esp
  8022e3:	ff 75 0c             	pushl  0xc(%ebp)
  8022e6:	ff 75 08             	pushl  0x8(%ebp)
  8022e9:	56                   	push   %esi
  8022ea:	50                   	push   %eax
  8022eb:	68 74 2c 80 00       	push   $0x802c74
  8022f0:	e8 ca e2 ff ff       	call   8005bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022f5:	83 c4 18             	add    $0x18,%esp
  8022f8:	53                   	push   %ebx
  8022f9:	ff 75 10             	pushl  0x10(%ebp)
  8022fc:	e8 6d e2 ff ff       	call   80056e <vcprintf>
	cprintf("\n");
  802301:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  802308:	e8 b2 e2 ff ff       	call   8005bf <cprintf>
  80230d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802310:	cc                   	int3   
  802311:	eb fd                	jmp    802310 <_panic+0x43>

00802313 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802313:	55                   	push   %ebp
  802314:	89 e5                	mov    %esp,%ebp
  802316:	56                   	push   %esi
  802317:	53                   	push   %ebx
  802318:	8b 75 08             	mov    0x8(%ebp),%esi
  80231b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802321:	85 c0                	test   %eax,%eax
  802323:	74 0e                	je     802333 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  802325:	83 ec 0c             	sub    $0xc,%esp
  802328:	50                   	push   %eax
  802329:	e8 c9 ed ff ff       	call   8010f7 <sys_ipc_recv>
  80232e:	83 c4 10             	add    $0x10,%esp
  802331:	eb 10                	jmp    802343 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802333:	83 ec 0c             	sub    $0xc,%esp
  802336:	68 00 00 00 f0       	push   $0xf0000000
  80233b:	e8 b7 ed ff ff       	call   8010f7 <sys_ipc_recv>
  802340:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  802343:	85 c0                	test   %eax,%eax
  802345:	74 0e                	je     802355 <ipc_recv+0x42>
    	*from_env_store = 0;
  802347:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  80234d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  802353:	eb 24                	jmp    802379 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  802355:	85 f6                	test   %esi,%esi
  802357:	74 0a                	je     802363 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802359:	a1 18 40 80 00       	mov    0x804018,%eax
  80235e:	8b 40 74             	mov    0x74(%eax),%eax
  802361:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802363:	85 db                	test   %ebx,%ebx
  802365:	74 0a                	je     802371 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802367:	a1 18 40 80 00       	mov    0x804018,%eax
  80236c:	8b 40 78             	mov    0x78(%eax),%eax
  80236f:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802371:	a1 18 40 80 00       	mov    0x804018,%eax
  802376:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802379:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5e                   	pop    %esi
  80237e:	5d                   	pop    %ebp
  80237f:	c3                   	ret    

00802380 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	57                   	push   %edi
  802384:	56                   	push   %esi
  802385:	53                   	push   %ebx
  802386:	83 ec 0c             	sub    $0xc,%esp
  802389:	8b 7d 08             	mov    0x8(%ebp),%edi
  80238c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80238f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802392:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802394:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802399:	0f 44 d8             	cmove  %eax,%ebx
  80239c:	eb 1c                	jmp    8023ba <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80239e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023a1:	74 12                	je     8023b5 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8023a3:	50                   	push   %eax
  8023a4:	68 98 2c 80 00       	push   $0x802c98
  8023a9:	6a 4b                	push   $0x4b
  8023ab:	68 b0 2c 80 00       	push   $0x802cb0
  8023b0:	e8 18 ff ff ff       	call   8022cd <_panic>
        }	
        sys_yield();
  8023b5:	e8 6e eb ff ff       	call   800f28 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8023ba:	ff 75 14             	pushl  0x14(%ebp)
  8023bd:	53                   	push   %ebx
  8023be:	56                   	push   %esi
  8023bf:	57                   	push   %edi
  8023c0:	e8 0f ed ff ff       	call   8010d4 <sys_ipc_try_send>
  8023c5:	83 c4 10             	add    $0x10,%esp
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	75 d2                	jne    80239e <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8023cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023cf:	5b                   	pop    %ebx
  8023d0:	5e                   	pop    %esi
  8023d1:	5f                   	pop    %edi
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    

008023d4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023df:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023e2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023e8:	8b 52 50             	mov    0x50(%edx),%edx
  8023eb:	39 ca                	cmp    %ecx,%edx
  8023ed:	75 0d                	jne    8023fc <ipc_find_env+0x28>
			return envs[i].env_id;
  8023ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023f7:	8b 40 48             	mov    0x48(%eax),%eax
  8023fa:	eb 0f                	jmp    80240b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023fc:	83 c0 01             	add    $0x1,%eax
  8023ff:	3d 00 04 00 00       	cmp    $0x400,%eax
  802404:	75 d9                	jne    8023df <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802406:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    

0080240d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802413:	89 d0                	mov    %edx,%eax
  802415:	c1 e8 16             	shr    $0x16,%eax
  802418:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80241f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802424:	f6 c1 01             	test   $0x1,%cl
  802427:	74 1d                	je     802446 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802429:	c1 ea 0c             	shr    $0xc,%edx
  80242c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802433:	f6 c2 01             	test   $0x1,%dl
  802436:	74 0e                	je     802446 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802438:	c1 ea 0c             	shr    $0xc,%edx
  80243b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802442:	ef 
  802443:	0f b7 c0             	movzwl %ax,%eax
}
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	66 90                	xchg   %ax,%ax
  80244a:	66 90                	xchg   %ax,%ax
  80244c:	66 90                	xchg   %ax,%ax
  80244e:	66 90                	xchg   %ax,%ax

00802450 <__udivdi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	53                   	push   %ebx
  802454:	83 ec 1c             	sub    $0x1c,%esp
  802457:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80245b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80245f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802463:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802467:	85 f6                	test   %esi,%esi
  802469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80246d:	89 ca                	mov    %ecx,%edx
  80246f:	89 f8                	mov    %edi,%eax
  802471:	75 3d                	jne    8024b0 <__udivdi3+0x60>
  802473:	39 cf                	cmp    %ecx,%edi
  802475:	0f 87 c5 00 00 00    	ja     802540 <__udivdi3+0xf0>
  80247b:	85 ff                	test   %edi,%edi
  80247d:	89 fd                	mov    %edi,%ebp
  80247f:	75 0b                	jne    80248c <__udivdi3+0x3c>
  802481:	b8 01 00 00 00       	mov    $0x1,%eax
  802486:	31 d2                	xor    %edx,%edx
  802488:	f7 f7                	div    %edi
  80248a:	89 c5                	mov    %eax,%ebp
  80248c:	89 c8                	mov    %ecx,%eax
  80248e:	31 d2                	xor    %edx,%edx
  802490:	f7 f5                	div    %ebp
  802492:	89 c1                	mov    %eax,%ecx
  802494:	89 d8                	mov    %ebx,%eax
  802496:	89 cf                	mov    %ecx,%edi
  802498:	f7 f5                	div    %ebp
  80249a:	89 c3                	mov    %eax,%ebx
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	89 fa                	mov    %edi,%edx
  8024a0:	83 c4 1c             	add    $0x1c,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
  8024a8:	90                   	nop
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	39 ce                	cmp    %ecx,%esi
  8024b2:	77 74                	ja     802528 <__udivdi3+0xd8>
  8024b4:	0f bd fe             	bsr    %esi,%edi
  8024b7:	83 f7 1f             	xor    $0x1f,%edi
  8024ba:	0f 84 98 00 00 00    	je     802558 <__udivdi3+0x108>
  8024c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	89 c5                	mov    %eax,%ebp
  8024c9:	29 fb                	sub    %edi,%ebx
  8024cb:	d3 e6                	shl    %cl,%esi
  8024cd:	89 d9                	mov    %ebx,%ecx
  8024cf:	d3 ed                	shr    %cl,%ebp
  8024d1:	89 f9                	mov    %edi,%ecx
  8024d3:	d3 e0                	shl    %cl,%eax
  8024d5:	09 ee                	or     %ebp,%esi
  8024d7:	89 d9                	mov    %ebx,%ecx
  8024d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024dd:	89 d5                	mov    %edx,%ebp
  8024df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024e3:	d3 ed                	shr    %cl,%ebp
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e2                	shl    %cl,%edx
  8024e9:	89 d9                	mov    %ebx,%ecx
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	09 c2                	or     %eax,%edx
  8024ef:	89 d0                	mov    %edx,%eax
  8024f1:	89 ea                	mov    %ebp,%edx
  8024f3:	f7 f6                	div    %esi
  8024f5:	89 d5                	mov    %edx,%ebp
  8024f7:	89 c3                	mov    %eax,%ebx
  8024f9:	f7 64 24 0c          	mull   0xc(%esp)
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	72 10                	jb     802511 <__udivdi3+0xc1>
  802501:	8b 74 24 08          	mov    0x8(%esp),%esi
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e6                	shl    %cl,%esi
  802509:	39 c6                	cmp    %eax,%esi
  80250b:	73 07                	jae    802514 <__udivdi3+0xc4>
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	75 03                	jne    802514 <__udivdi3+0xc4>
  802511:	83 eb 01             	sub    $0x1,%ebx
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 d8                	mov    %ebx,%eax
  802518:	89 fa                	mov    %edi,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	31 ff                	xor    %edi,%edi
  80252a:	31 db                	xor    %ebx,%ebx
  80252c:	89 d8                	mov    %ebx,%eax
  80252e:	89 fa                	mov    %edi,%edx
  802530:	83 c4 1c             	add    $0x1c,%esp
  802533:	5b                   	pop    %ebx
  802534:	5e                   	pop    %esi
  802535:	5f                   	pop    %edi
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	90                   	nop
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d8                	mov    %ebx,%eax
  802542:	f7 f7                	div    %edi
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 c3                	mov    %eax,%ebx
  802548:	89 d8                	mov    %ebx,%eax
  80254a:	89 fa                	mov    %edi,%edx
  80254c:	83 c4 1c             	add    $0x1c,%esp
  80254f:	5b                   	pop    %ebx
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
  802554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802558:	39 ce                	cmp    %ecx,%esi
  80255a:	72 0c                	jb     802568 <__udivdi3+0x118>
  80255c:	31 db                	xor    %ebx,%ebx
  80255e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802562:	0f 87 34 ff ff ff    	ja     80249c <__udivdi3+0x4c>
  802568:	bb 01 00 00 00       	mov    $0x1,%ebx
  80256d:	e9 2a ff ff ff       	jmp    80249c <__udivdi3+0x4c>
  802572:	66 90                	xchg   %ax,%ax
  802574:	66 90                	xchg   %ax,%ax
  802576:	66 90                	xchg   %ax,%ax
  802578:	66 90                	xchg   %ax,%ax
  80257a:	66 90                	xchg   %ax,%ax
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__umoddi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80258b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80258f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 d2                	test   %edx,%edx
  802599:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 f3                	mov    %esi,%ebx
  8025a3:	89 3c 24             	mov    %edi,(%esp)
  8025a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025aa:	75 1c                	jne    8025c8 <__umoddi3+0x48>
  8025ac:	39 f7                	cmp    %esi,%edi
  8025ae:	76 50                	jbe    802600 <__umoddi3+0x80>
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	f7 f7                	div    %edi
  8025b6:	89 d0                	mov    %edx,%eax
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	83 c4 1c             	add    $0x1c,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	39 f2                	cmp    %esi,%edx
  8025ca:	89 d0                	mov    %edx,%eax
  8025cc:	77 52                	ja     802620 <__umoddi3+0xa0>
  8025ce:	0f bd ea             	bsr    %edx,%ebp
  8025d1:	83 f5 1f             	xor    $0x1f,%ebp
  8025d4:	75 5a                	jne    802630 <__umoddi3+0xb0>
  8025d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025da:	0f 82 e0 00 00 00    	jb     8026c0 <__umoddi3+0x140>
  8025e0:	39 0c 24             	cmp    %ecx,(%esp)
  8025e3:	0f 86 d7 00 00 00    	jbe    8026c0 <__umoddi3+0x140>
  8025e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025f1:	83 c4 1c             	add    $0x1c,%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	85 ff                	test   %edi,%edi
  802602:	89 fd                	mov    %edi,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x91>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f7                	div    %edi
  80260f:	89 c5                	mov    %eax,%ebp
  802611:	89 f0                	mov    %esi,%eax
  802613:	31 d2                	xor    %edx,%edx
  802615:	f7 f5                	div    %ebp
  802617:	89 c8                	mov    %ecx,%eax
  802619:	f7 f5                	div    %ebp
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	eb 99                	jmp    8025b8 <__umoddi3+0x38>
  80261f:	90                   	nop
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	83 c4 1c             	add    $0x1c,%esp
  802627:	5b                   	pop    %ebx
  802628:	5e                   	pop    %esi
  802629:	5f                   	pop    %edi
  80262a:	5d                   	pop    %ebp
  80262b:	c3                   	ret    
  80262c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802630:	8b 34 24             	mov    (%esp),%esi
  802633:	bf 20 00 00 00       	mov    $0x20,%edi
  802638:	89 e9                	mov    %ebp,%ecx
  80263a:	29 ef                	sub    %ebp,%edi
  80263c:	d3 e0                	shl    %cl,%eax
  80263e:	89 f9                	mov    %edi,%ecx
  802640:	89 f2                	mov    %esi,%edx
  802642:	d3 ea                	shr    %cl,%edx
  802644:	89 e9                	mov    %ebp,%ecx
  802646:	09 c2                	or     %eax,%edx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 14 24             	mov    %edx,(%esp)
  80264d:	89 f2                	mov    %esi,%edx
  80264f:	d3 e2                	shl    %cl,%edx
  802651:	89 f9                	mov    %edi,%ecx
  802653:	89 54 24 04          	mov    %edx,0x4(%esp)
  802657:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80265b:	d3 e8                	shr    %cl,%eax
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	89 c6                	mov    %eax,%esi
  802661:	d3 e3                	shl    %cl,%ebx
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 d0                	mov    %edx,%eax
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	09 d8                	or     %ebx,%eax
  80266d:	89 d3                	mov    %edx,%ebx
  80266f:	89 f2                	mov    %esi,%edx
  802671:	f7 34 24             	divl   (%esp)
  802674:	89 d6                	mov    %edx,%esi
  802676:	d3 e3                	shl    %cl,%ebx
  802678:	f7 64 24 04          	mull   0x4(%esp)
  80267c:	39 d6                	cmp    %edx,%esi
  80267e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802682:	89 d1                	mov    %edx,%ecx
  802684:	89 c3                	mov    %eax,%ebx
  802686:	72 08                	jb     802690 <__umoddi3+0x110>
  802688:	75 11                	jne    80269b <__umoddi3+0x11b>
  80268a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80268e:	73 0b                	jae    80269b <__umoddi3+0x11b>
  802690:	2b 44 24 04          	sub    0x4(%esp),%eax
  802694:	1b 14 24             	sbb    (%esp),%edx
  802697:	89 d1                	mov    %edx,%ecx
  802699:	89 c3                	mov    %eax,%ebx
  80269b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80269f:	29 da                	sub    %ebx,%edx
  8026a1:	19 ce                	sbb    %ecx,%esi
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 f0                	mov    %esi,%eax
  8026a7:	d3 e0                	shl    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	d3 ea                	shr    %cl,%edx
  8026ad:	89 e9                	mov    %ebp,%ecx
  8026af:	d3 ee                	shr    %cl,%esi
  8026b1:	09 d0                	or     %edx,%eax
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	83 c4 1c             	add    $0x1c,%esp
  8026b8:	5b                   	pop    %ebx
  8026b9:	5e                   	pop    %esi
  8026ba:	5f                   	pop    %edi
  8026bb:	5d                   	pop    %ebp
  8026bc:	c3                   	ret    
  8026bd:	8d 76 00             	lea    0x0(%esi),%esi
  8026c0:	29 f9                	sub    %edi,%ecx
  8026c2:	19 d6                	sbb    %edx,%esi
  8026c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026cc:	e9 18 ff ff ff       	jmp    8025e9 <__umoddi3+0x69>
