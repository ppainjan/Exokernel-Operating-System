
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 79 04 00 00       	call   8004aa <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 c0 26 80 00       	push   $0x8026c0
  80003f:	e8 63 05 00 00       	call   8005a7 <cprintf>
	exit();
  800044:	e8 b1 04 00 00       	call   8004fa <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 58             	sub    $0x58,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  800057:	68 c4 26 80 00       	push   $0x8026c4
  80005c:	e8 46 05 00 00       	call   8005a7 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800061:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  800068:	e8 0b 04 00 00       	call   800478 <inet_addr>
  80006d:	83 c4 0c             	add    $0xc,%esp
  800070:	50                   	push   %eax
  800071:	68 d4 26 80 00       	push   $0x8026d4
  800076:	68 de 26 80 00       	push   $0x8026de
  80007b:	e8 27 05 00 00       	call   8005a7 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	6a 06                	push   $0x6
  800085:	6a 01                	push   $0x1
  800087:	6a 02                	push   $0x2
  800089:	e8 d0 1a 00 00       	call   801b5e <socket>
  80008e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 0a                	jns    8000a2 <umain+0x54>
		die("Failed to create socket");
  800098:	b8 f3 26 80 00       	mov    $0x8026f3,%eax
  80009d:	e8 91 ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	68 0b 27 80 00       	push   $0x80270b
  8000aa:	e8 f8 04 00 00       	call   8005a7 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 10                	push   $0x10
  8000b4:	6a 00                	push   $0x0
  8000b6:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b9:	53                   	push   %ebx
  8000ba:	e8 b2 0b 00 00       	call   800c71 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000bf:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000c3:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  8000ca:	e8 a9 03 00 00       	call   800478 <inet_addr>
  8000cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000d2:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000d9:	e8 81 01 00 00       	call   80025f <htons>
  8000de:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  8000e2:	c7 04 24 1a 27 80 00 	movl   $0x80271a,(%esp)
  8000e9:	e8 b9 04 00 00       	call   8005a7 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000ee:	83 c4 0c             	add    $0xc,%esp
  8000f1:	6a 10                	push   $0x10
  8000f3:	53                   	push   %ebx
  8000f4:	ff 75 b4             	pushl  -0x4c(%ebp)
  8000f7:	e8 19 1a 00 00       	call   801b15 <connect>
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 c0                	test   %eax,%eax
  800101:	79 0a                	jns    80010d <umain+0xbf>
		die("Failed to connect with server");
  800103:	b8 37 27 80 00       	mov    $0x802737,%eax
  800108:	e8 26 ff ff ff       	call   800033 <die>

	cprintf("connected to server\n");
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	68 55 27 80 00       	push   $0x802755
  800115:	e8 8d 04 00 00       	call   8005a7 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 00 30 80 00    	pushl  0x803000
  800123:	e8 cb 09 00 00       	call   800af3 <strlen>
  800128:	89 c7                	mov    %eax,%edi
  80012a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80012d:	83 c4 0c             	add    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	ff 35 00 30 80 00    	pushl  0x803000
  800137:	ff 75 b4             	pushl  -0x4c(%ebp)
  80013a:	e8 d7 13 00 00       	call   801516 <write>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	39 c7                	cmp    %eax,%edi
  800144:	74 0a                	je     800150 <umain+0x102>
		die("Mismatch in number of sent bytes");
  800146:	b8 84 27 80 00       	mov    $0x802784,%eax
  80014b:	e8 e3 fe ff ff       	call   800033 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	68 6a 27 80 00       	push   $0x80276a
  800158:	e8 4a 04 00 00       	call   8005a7 <cprintf>
	while (received < echolen) {
  80015d:	83 c4 10             	add    $0x10,%esp
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800160:	be 00 00 00 00       	mov    $0x0,%esi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800165:	8d 7d b8             	lea    -0x48(%ebp),%edi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800168:	eb 34                	jmp    80019e <umain+0x150>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80016a:	83 ec 04             	sub    $0x4,%esp
  80016d:	6a 1f                	push   $0x1f
  80016f:	57                   	push   %edi
  800170:	ff 75 b4             	pushl  -0x4c(%ebp)
  800173:	e8 c4 12 00 00       	call   80143c <read>
  800178:	89 c3                	mov    %eax,%ebx
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	7f 0a                	jg     80018b <umain+0x13d>
			die("Failed to receive bytes from server");
  800181:	b8 a8 27 80 00       	mov    $0x8027a8,%eax
  800186:	e8 a8 fe ff ff       	call   800033 <die>
		}
		received += bytes;
  80018b:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  80018d:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	57                   	push   %edi
  800196:	e8 0c 04 00 00       	call   8005a7 <cprintf>
  80019b:	83 c4 10             	add    $0x10,%esp
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  80019e:	39 75 b0             	cmp    %esi,-0x50(%ebp)
  8001a1:	77 c7                	ja     80016a <umain+0x11c>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 74 27 80 00       	push   $0x802774
  8001ab:	e8 f7 03 00 00       	call   8005a7 <cprintf>

	close(sock);
  8001b0:	83 c4 04             	add    $0x4,%esp
  8001b3:	ff 75 b4             	pushl  -0x4c(%ebp)
  8001b6:	e8 45 11 00 00       	call   801300 <close>
}
  8001bb:	83 c4 10             	add    $0x10,%esp
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001d5:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001d8:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001df:	0f b6 0f             	movzbl (%edi),%ecx
  8001e2:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001e7:	0f b6 d9             	movzbl %cl,%ebx
  8001ea:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8001ed:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8001f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001f3:	66 c1 e8 0b          	shr    $0xb,%ax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001fc:	01 c0                	add    %eax,%eax
  8001fe:	29 c1                	sub    %eax,%ecx
  800200:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800202:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800204:	8d 72 01             	lea    0x1(%edx),%esi
  800207:	0f b6 d2             	movzbl %dl,%edx
  80020a:	83 c0 30             	add    $0x30,%eax
  80020d:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800211:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800213:	84 db                	test   %bl,%bl
  800215:	75 d0                	jne    8001e7 <inet_ntoa+0x21>
  800217:	c6 07 00             	movb   $0x0,(%edi)
  80021a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80021d:	eb 0d                	jmp    80022c <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  80021f:	0f b6 c2             	movzbl %dl,%eax
  800222:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800227:	88 01                	mov    %al,(%ecx)
  800229:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80022c:	83 ea 01             	sub    $0x1,%edx
  80022f:	80 fa ff             	cmp    $0xff,%dl
  800232:	75 eb                	jne    80021f <inet_ntoa+0x59>
  800234:	89 f0                	mov    %esi,%eax
  800236:	0f b6 f0             	movzbl %al,%esi
  800239:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  80023c:	8d 46 01             	lea    0x1(%esi),%eax
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  800245:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80024b:	39 c7                	cmp    %eax,%edi
  80024d:	75 90                	jne    8001df <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  80024f:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800252:	b8 00 40 80 00       	mov    $0x804000,%eax
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800262:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800266:	66 c1 c0 08          	rol    $0x8,%ax
}
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  return htons(n);
  80026f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800273:	66 c1 c0 08          	rol    $0x8,%ax
}
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  80027f:	89 d1                	mov    %edx,%ecx
  800281:	c1 e1 18             	shl    $0x18,%ecx
  800284:	89 d0                	mov    %edx,%eax
  800286:	c1 e8 18             	shr    $0x18,%eax
  800289:	09 c8                	or     %ecx,%eax
  80028b:	89 d1                	mov    %edx,%ecx
  80028d:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800293:	c1 e1 08             	shl    $0x8,%ecx
  800296:	09 c8                	or     %ecx,%eax
  800298:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80029e:	c1 ea 08             	shr    $0x8,%edx
  8002a1:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 20             	sub    $0x20,%esp
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002b1:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002b4:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002b7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002ba:	0f b6 ca             	movzbl %dl,%ecx
  8002bd:	83 e9 30             	sub    $0x30,%ecx
  8002c0:	83 f9 09             	cmp    $0x9,%ecx
  8002c3:	0f 87 94 01 00 00    	ja     80045d <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002c9:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002d0:	83 fa 30             	cmp    $0x30,%edx
  8002d3:	75 2b                	jne    800300 <inet_aton+0x5b>
      c = *++cp;
  8002d5:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002d9:	89 d1                	mov    %edx,%ecx
  8002db:	83 e1 df             	and    $0xffffffdf,%ecx
  8002de:	80 f9 58             	cmp    $0x58,%cl
  8002e1:	74 0f                	je     8002f2 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002e3:	83 c0 01             	add    $0x1,%eax
  8002e6:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8002e9:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8002f0:	eb 0e                	jmp    800300 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8002f2:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8002f6:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8002f9:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800300:	83 c0 01             	add    $0x1,%eax
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	eb 03                	jmp    80030d <inet_aton+0x68>
  80030a:	83 c0 01             	add    $0x1,%eax
  80030d:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800310:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800313:	0f b6 fa             	movzbl %dl,%edi
  800316:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800319:	83 f9 09             	cmp    $0x9,%ecx
  80031c:	77 0d                	ja     80032b <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  80031e:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800322:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800326:	0f be 10             	movsbl (%eax),%edx
  800329:	eb df                	jmp    80030a <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  80032b:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80032f:	75 32                	jne    800363 <inet_aton+0xbe>
  800331:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800334:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800337:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033a:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800340:	83 e9 41             	sub    $0x41,%ecx
  800343:	83 f9 05             	cmp    $0x5,%ecx
  800346:	77 1b                	ja     800363 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800348:	c1 e6 04             	shl    $0x4,%esi
  80034b:	83 c2 0a             	add    $0xa,%edx
  80034e:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800352:	19 c9                	sbb    %ecx,%ecx
  800354:	83 e1 20             	and    $0x20,%ecx
  800357:	83 c1 41             	add    $0x41,%ecx
  80035a:	29 ca                	sub    %ecx,%edx
  80035c:	09 d6                	or     %edx,%esi
        c = *++cp;
  80035e:	0f be 10             	movsbl (%eax),%edx
  800361:	eb a7                	jmp    80030a <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800363:	83 fa 2e             	cmp    $0x2e,%edx
  800366:	75 23                	jne    80038b <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	8d 7d f0             	lea    -0x10(%ebp),%edi
  80036e:	39 f8                	cmp    %edi,%eax
  800370:	0f 84 ee 00 00 00    	je     800464 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800376:	83 c0 04             	add    $0x4,%eax
  800379:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80037c:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  80037f:	8d 43 01             	lea    0x1(%ebx),%eax
  800382:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800386:	e9 2f ff ff ff       	jmp    8002ba <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 25                	je     8003b4 <inet_aton+0x10f>
  80038f:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800397:	83 f9 5f             	cmp    $0x5f,%ecx
  80039a:	0f 87 d0 00 00 00    	ja     800470 <inet_aton+0x1cb>
  8003a0:	83 fa 20             	cmp    $0x20,%edx
  8003a3:	74 0f                	je     8003b4 <inet_aton+0x10f>
  8003a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a8:	83 ea 09             	sub    $0x9,%edx
  8003ab:	83 fa 04             	cmp    $0x4,%edx
  8003ae:	0f 87 bc 00 00 00    	ja     800470 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003ba:	29 c2                	sub    %eax,%edx
  8003bc:	c1 fa 02             	sar    $0x2,%edx
  8003bf:	83 c2 01             	add    $0x1,%edx
  8003c2:	83 fa 02             	cmp    $0x2,%edx
  8003c5:	74 20                	je     8003e7 <inet_aton+0x142>
  8003c7:	83 fa 02             	cmp    $0x2,%edx
  8003ca:	7f 0f                	jg     8003db <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	0f 84 97 00 00 00    	je     800470 <inet_aton+0x1cb>
  8003d9:	eb 67                	jmp    800442 <inet_aton+0x19d>
  8003db:	83 fa 03             	cmp    $0x3,%edx
  8003de:	74 1e                	je     8003fe <inet_aton+0x159>
  8003e0:	83 fa 04             	cmp    $0x4,%edx
  8003e3:	74 38                	je     80041d <inet_aton+0x178>
  8003e5:	eb 5b                	jmp    800442 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8003ec:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8003f2:	77 7c                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8003f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f7:	c1 e0 18             	shl    $0x18,%eax
  8003fa:	09 c6                	or     %eax,%esi
    break;
  8003fc:	eb 44                	jmp    800442 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800403:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800409:	77 65                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	c1 e2 18             	shl    $0x18,%edx
  800411:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800414:	c1 e0 10             	shl    $0x10,%eax
  800417:	09 d0                	or     %edx,%eax
  800419:	09 c6                	or     %eax,%esi
    break;
  80041b:	eb 25                	jmp    800442 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800422:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800428:	77 46                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80042a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042d:	c1 e2 18             	shl    $0x18,%edx
  800430:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800433:	c1 e0 10             	shl    $0x10,%eax
  800436:	09 c2                	or     %eax,%edx
  800438:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80043b:	c1 e0 08             	shl    $0x8,%eax
  80043e:	09 d0                	or     %edx,%eax
  800440:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800442:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800446:	74 23                	je     80046b <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800448:	56                   	push   %esi
  800449:	e8 2b fe ff ff       	call   800279 <htonl>
  80044e:	83 c4 04             	add    $0x4,%esp
  800451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800454:	89 03                	mov    %eax,(%ebx)
  return (1);
  800456:	b8 01 00 00 00       	mov    $0x1,%eax
  80045b:	eb 13                	jmp    800470 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	eb 0c                	jmp    800470 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800464:	b8 00 00 00 00       	mov    $0x0,%eax
  800469:	eb 05                	jmp    800470 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80046b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800473:	5b                   	pop    %ebx
  800474:	5e                   	pop    %esi
  800475:	5f                   	pop    %edi
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    

00800478 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80047e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800481:	50                   	push   %eax
  800482:	ff 75 08             	pushl  0x8(%ebp)
  800485:	e8 1b fe ff ff       	call   8002a5 <inet_aton>
  80048a:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80048d:	85 c0                	test   %eax,%eax
  80048f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800494:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    

0080049a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80049d:	ff 75 08             	pushl  0x8(%ebp)
  8004a0:	e8 d4 fd ff ff       	call   800279 <htonl>
  8004a5:	83 c4 04             	add    $0x4,%esp
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	56                   	push   %esi
  8004ae:	53                   	push   %ebx
  8004af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8004b5:	c7 05 18 40 80 00 00 	movl   $0x0,0x804018
  8004bc:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8004bf:	e8 2d 0a 00 00       	call   800ef1 <sys_getenvid>
  8004c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004d1:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004d6:	85 db                	test   %ebx,%ebx
  8004d8:	7e 07                	jle    8004e1 <libmain+0x37>
		binaryname = argv[0];
  8004da:	8b 06                	mov    (%esi),%eax
  8004dc:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	e8 63 fb ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  8004eb:	e8 0a 00 00 00       	call   8004fa <exit>
}
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800500:	e8 26 0e 00 00       	call   80132b <close_all>
	sys_env_destroy(0);
  800505:	83 ec 0c             	sub    $0xc,%esp
  800508:	6a 00                	push   $0x0
  80050a:	e8 a1 09 00 00       	call   800eb0 <sys_env_destroy>
}
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	c9                   	leave  
  800513:	c3                   	ret    

00800514 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	53                   	push   %ebx
  800518:	83 ec 04             	sub    $0x4,%esp
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80051e:	8b 13                	mov    (%ebx),%edx
  800520:	8d 42 01             	lea    0x1(%edx),%eax
  800523:	89 03                	mov    %eax,(%ebx)
  800525:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800528:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80052c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800531:	75 1a                	jne    80054d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	68 ff 00 00 00       	push   $0xff
  80053b:	8d 43 08             	lea    0x8(%ebx),%eax
  80053e:	50                   	push   %eax
  80053f:	e8 2f 09 00 00       	call   800e73 <sys_cputs>
		b->idx = 0;
  800544:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80054a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80054d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80055f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800566:	00 00 00 
	b.cnt = 0;
  800569:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800570:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	ff 75 08             	pushl  0x8(%ebp)
  800579:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80057f:	50                   	push   %eax
  800580:	68 14 05 80 00       	push   $0x800514
  800585:	e8 54 01 00 00       	call   8006de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80058a:	83 c4 08             	add    $0x8,%esp
  80058d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800593:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800599:	50                   	push   %eax
  80059a:	e8 d4 08 00 00       	call   800e73 <sys_cputs>

	return b.cnt;
}
  80059f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    

008005a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005b0:	50                   	push   %eax
  8005b1:	ff 75 08             	pushl  0x8(%ebp)
  8005b4:	e8 9d ff ff ff       	call   800556 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005b9:	c9                   	leave  
  8005ba:	c3                   	ret    

008005bb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005bb:	55                   	push   %ebp
  8005bc:	89 e5                	mov    %esp,%ebp
  8005be:	57                   	push   %edi
  8005bf:	56                   	push   %esi
  8005c0:	53                   	push   %ebx
  8005c1:	83 ec 1c             	sub    $0x1c,%esp
  8005c4:	89 c7                	mov    %eax,%edi
  8005c6:	89 d6                	mov    %edx,%esi
  8005c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005dc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005df:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005e2:	39 d3                	cmp    %edx,%ebx
  8005e4:	72 05                	jb     8005eb <printnum+0x30>
  8005e6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005e9:	77 45                	ja     800630 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005eb:	83 ec 0c             	sub    $0xc,%esp
  8005ee:	ff 75 18             	pushl  0x18(%ebp)
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005f7:	53                   	push   %ebx
  8005f8:	ff 75 10             	pushl  0x10(%ebp)
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800601:	ff 75 e0             	pushl  -0x20(%ebp)
  800604:	ff 75 dc             	pushl  -0x24(%ebp)
  800607:	ff 75 d8             	pushl  -0x28(%ebp)
  80060a:	e8 21 1e 00 00       	call   802430 <__udivdi3>
  80060f:	83 c4 18             	add    $0x18,%esp
  800612:	52                   	push   %edx
  800613:	50                   	push   %eax
  800614:	89 f2                	mov    %esi,%edx
  800616:	89 f8                	mov    %edi,%eax
  800618:	e8 9e ff ff ff       	call   8005bb <printnum>
  80061d:	83 c4 20             	add    $0x20,%esp
  800620:	eb 18                	jmp    80063a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	56                   	push   %esi
  800626:	ff 75 18             	pushl  0x18(%ebp)
  800629:	ff d7                	call   *%edi
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	eb 03                	jmp    800633 <printnum+0x78>
  800630:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800633:	83 eb 01             	sub    $0x1,%ebx
  800636:	85 db                	test   %ebx,%ebx
  800638:	7f e8                	jg     800622 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	56                   	push   %esi
  80063e:	83 ec 04             	sub    $0x4,%esp
  800641:	ff 75 e4             	pushl  -0x1c(%ebp)
  800644:	ff 75 e0             	pushl  -0x20(%ebp)
  800647:	ff 75 dc             	pushl  -0x24(%ebp)
  80064a:	ff 75 d8             	pushl  -0x28(%ebp)
  80064d:	e8 0e 1f 00 00       	call   802560 <__umoddi3>
  800652:	83 c4 14             	add    $0x14,%esp
  800655:	0f be 80 d6 27 80 00 	movsbl 0x8027d6(%eax),%eax
  80065c:	50                   	push   %eax
  80065d:	ff d7                	call   *%edi
}
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800665:	5b                   	pop    %ebx
  800666:	5e                   	pop    %esi
  800667:	5f                   	pop    %edi
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80066d:	83 fa 01             	cmp    $0x1,%edx
  800670:	7e 0e                	jle    800680 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8d 4a 08             	lea    0x8(%edx),%ecx
  800677:	89 08                	mov    %ecx,(%eax)
  800679:	8b 02                	mov    (%edx),%eax
  80067b:	8b 52 04             	mov    0x4(%edx),%edx
  80067e:	eb 22                	jmp    8006a2 <getuint+0x38>
	else if (lflag)
  800680:	85 d2                	test   %edx,%edx
  800682:	74 10                	je     800694 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800684:	8b 10                	mov    (%eax),%edx
  800686:	8d 4a 04             	lea    0x4(%edx),%ecx
  800689:	89 08                	mov    %ecx,(%eax)
  80068b:	8b 02                	mov    (%edx),%eax
  80068d:	ba 00 00 00 00       	mov    $0x0,%edx
  800692:	eb 0e                	jmp    8006a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800694:	8b 10                	mov    (%eax),%edx
  800696:	8d 4a 04             	lea    0x4(%edx),%ecx
  800699:	89 08                	mov    %ecx,(%eax)
  80069b:	8b 02                	mov    (%edx),%eax
  80069d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006aa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	3b 50 04             	cmp    0x4(%eax),%edx
  8006b3:	73 0a                	jae    8006bf <sprintputch+0x1b>
		*b->buf++ = ch;
  8006b5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006b8:	89 08                	mov    %ecx,(%eax)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	88 02                	mov    %al,(%edx)
}
  8006bf:	5d                   	pop    %ebp
  8006c0:	c3                   	ret    

008006c1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006ca:	50                   	push   %eax
  8006cb:	ff 75 10             	pushl  0x10(%ebp)
  8006ce:	ff 75 0c             	pushl  0xc(%ebp)
  8006d1:	ff 75 08             	pushl  0x8(%ebp)
  8006d4:	e8 05 00 00 00       	call   8006de <vprintfmt>
	va_end(ap);
}
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 2c             	sub    $0x2c,%esp
  8006e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ed:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006f0:	eb 12                	jmp    800704 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	0f 84 89 03 00 00    	je     800a83 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	50                   	push   %eax
  8006ff:	ff d6                	call   *%esi
  800701:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800704:	83 c7 01             	add    $0x1,%edi
  800707:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070b:	83 f8 25             	cmp    $0x25,%eax
  80070e:	75 e2                	jne    8006f2 <vprintfmt+0x14>
  800710:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800714:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80071b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800722:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800729:	ba 00 00 00 00       	mov    $0x0,%edx
  80072e:	eb 07                	jmp    800737 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800733:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800737:	8d 47 01             	lea    0x1(%edi),%eax
  80073a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073d:	0f b6 07             	movzbl (%edi),%eax
  800740:	0f b6 c8             	movzbl %al,%ecx
  800743:	83 e8 23             	sub    $0x23,%eax
  800746:	3c 55                	cmp    $0x55,%al
  800748:	0f 87 1a 03 00 00    	ja     800a68 <vprintfmt+0x38a>
  80074e:	0f b6 c0             	movzbl %al,%eax
  800751:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80075b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80075f:	eb d6                	jmp    800737 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80076c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80076f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800773:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800776:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800779:	83 fa 09             	cmp    $0x9,%edx
  80077c:	77 39                	ja     8007b7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80077e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800781:	eb e9                	jmp    80076c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 48 04             	lea    0x4(%eax),%ecx
  800789:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800791:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800794:	eb 27                	jmp    8007bd <vprintfmt+0xdf>
  800796:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800799:	85 c0                	test   %eax,%eax
  80079b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a0:	0f 49 c8             	cmovns %eax,%ecx
  8007a3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a9:	eb 8c                	jmp    800737 <vprintfmt+0x59>
  8007ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007ae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007b5:	eb 80                	jmp    800737 <vprintfmt+0x59>
  8007b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ba:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007c1:	0f 89 70 ff ff ff    	jns    800737 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007cd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007d4:	e9 5e ff ff ff       	jmp    800737 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007d9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007df:	e9 53 ff ff ff       	jmp    800737 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	53                   	push   %ebx
  8007f1:	ff 30                	pushl  (%eax)
  8007f3:	ff d6                	call   *%esi
			break;
  8007f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007fb:	e9 04 ff ff ff       	jmp    800704 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 00                	mov    (%eax),%eax
  80080b:	99                   	cltd   
  80080c:	31 d0                	xor    %edx,%eax
  80080e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800810:	83 f8 0f             	cmp    $0xf,%eax
  800813:	7f 0b                	jg     800820 <vprintfmt+0x142>
  800815:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  80081c:	85 d2                	test   %edx,%edx
  80081e:	75 18                	jne    800838 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800820:	50                   	push   %eax
  800821:	68 ee 27 80 00       	push   $0x8027ee
  800826:	53                   	push   %ebx
  800827:	56                   	push   %esi
  800828:	e8 94 fe ff ff       	call   8006c1 <printfmt>
  80082d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800830:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800833:	e9 cc fe ff ff       	jmp    800704 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800838:	52                   	push   %edx
  800839:	68 b5 2b 80 00       	push   $0x802bb5
  80083e:	53                   	push   %ebx
  80083f:	56                   	push   %esi
  800840:	e8 7c fe ff ff       	call   8006c1 <printfmt>
  800845:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800848:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80084b:	e9 b4 fe ff ff       	jmp    800704 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80085b:	85 ff                	test   %edi,%edi
  80085d:	b8 e7 27 80 00       	mov    $0x8027e7,%eax
  800862:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800865:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800869:	0f 8e 94 00 00 00    	jle    800903 <vprintfmt+0x225>
  80086f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800873:	0f 84 98 00 00 00    	je     800911 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	ff 75 d0             	pushl  -0x30(%ebp)
  80087f:	57                   	push   %edi
  800880:	e8 86 02 00 00       	call   800b0b <strnlen>
  800885:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800888:	29 c1                	sub    %eax,%ecx
  80088a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80088d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800890:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800894:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800897:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80089a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089c:	eb 0f                	jmp    8008ad <vprintfmt+0x1cf>
					putch(padc, putdat);
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	53                   	push   %ebx
  8008a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a7:	83 ef 01             	sub    $0x1,%edi
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	85 ff                	test   %edi,%edi
  8008af:	7f ed                	jg     80089e <vprintfmt+0x1c0>
  8008b1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008b4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008b7:	85 c9                	test   %ecx,%ecx
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008be:	0f 49 c1             	cmovns %ecx,%eax
  8008c1:	29 c1                	sub    %eax,%ecx
  8008c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8008c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008cc:	89 cb                	mov    %ecx,%ebx
  8008ce:	eb 4d                	jmp    80091d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008d4:	74 1b                	je     8008f1 <vprintfmt+0x213>
  8008d6:	0f be c0             	movsbl %al,%eax
  8008d9:	83 e8 20             	sub    $0x20,%eax
  8008dc:	83 f8 5e             	cmp    $0x5e,%eax
  8008df:	76 10                	jbe    8008f1 <vprintfmt+0x213>
					putch('?', putdat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	6a 3f                	push   $0x3f
  8008e9:	ff 55 08             	call   *0x8(%ebp)
  8008ec:	83 c4 10             	add    $0x10,%esp
  8008ef:	eb 0d                	jmp    8008fe <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	52                   	push   %edx
  8008f8:	ff 55 08             	call   *0x8(%ebp)
  8008fb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fe:	83 eb 01             	sub    $0x1,%ebx
  800901:	eb 1a                	jmp    80091d <vprintfmt+0x23f>
  800903:	89 75 08             	mov    %esi,0x8(%ebp)
  800906:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800909:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80090c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80090f:	eb 0c                	jmp    80091d <vprintfmt+0x23f>
  800911:	89 75 08             	mov    %esi,0x8(%ebp)
  800914:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800917:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80091a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80091d:	83 c7 01             	add    $0x1,%edi
  800920:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800924:	0f be d0             	movsbl %al,%edx
  800927:	85 d2                	test   %edx,%edx
  800929:	74 23                	je     80094e <vprintfmt+0x270>
  80092b:	85 f6                	test   %esi,%esi
  80092d:	78 a1                	js     8008d0 <vprintfmt+0x1f2>
  80092f:	83 ee 01             	sub    $0x1,%esi
  800932:	79 9c                	jns    8008d0 <vprintfmt+0x1f2>
  800934:	89 df                	mov    %ebx,%edi
  800936:	8b 75 08             	mov    0x8(%ebp),%esi
  800939:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80093c:	eb 18                	jmp    800956 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	53                   	push   %ebx
  800942:	6a 20                	push   $0x20
  800944:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800946:	83 ef 01             	sub    $0x1,%edi
  800949:	83 c4 10             	add    $0x10,%esp
  80094c:	eb 08                	jmp    800956 <vprintfmt+0x278>
  80094e:	89 df                	mov    %ebx,%edi
  800950:	8b 75 08             	mov    0x8(%ebp),%esi
  800953:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800956:	85 ff                	test   %edi,%edi
  800958:	7f e4                	jg     80093e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80095d:	e9 a2 fd ff ff       	jmp    800704 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800962:	83 fa 01             	cmp    $0x1,%edx
  800965:	7e 16                	jle    80097d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800967:	8b 45 14             	mov    0x14(%ebp),%eax
  80096a:	8d 50 08             	lea    0x8(%eax),%edx
  80096d:	89 55 14             	mov    %edx,0x14(%ebp)
  800970:	8b 50 04             	mov    0x4(%eax),%edx
  800973:	8b 00                	mov    (%eax),%eax
  800975:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800978:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80097b:	eb 32                	jmp    8009af <vprintfmt+0x2d1>
	else if (lflag)
  80097d:	85 d2                	test   %edx,%edx
  80097f:	74 18                	je     800999 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800981:	8b 45 14             	mov    0x14(%ebp),%eax
  800984:	8d 50 04             	lea    0x4(%eax),%edx
  800987:	89 55 14             	mov    %edx,0x14(%ebp)
  80098a:	8b 00                	mov    (%eax),%eax
  80098c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098f:	89 c1                	mov    %eax,%ecx
  800991:	c1 f9 1f             	sar    $0x1f,%ecx
  800994:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800997:	eb 16                	jmp    8009af <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800999:	8b 45 14             	mov    0x14(%ebp),%eax
  80099c:	8d 50 04             	lea    0x4(%eax),%edx
  80099f:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a2:	8b 00                	mov    (%eax),%eax
  8009a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a7:	89 c1                	mov    %eax,%ecx
  8009a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8009ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009af:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009be:	79 74                	jns    800a34 <vprintfmt+0x356>
				putch('-', putdat);
  8009c0:	83 ec 08             	sub    $0x8,%esp
  8009c3:	53                   	push   %ebx
  8009c4:	6a 2d                	push   $0x2d
  8009c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009ce:	f7 d8                	neg    %eax
  8009d0:	83 d2 00             	adc    $0x0,%edx
  8009d3:	f7 da                	neg    %edx
  8009d5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009d8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009dd:	eb 55                	jmp    800a34 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009df:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e2:	e8 83 fc ff ff       	call   80066a <getuint>
			base = 10;
  8009e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009ec:	eb 46                	jmp    800a34 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f1:	e8 74 fc ff ff       	call   80066a <getuint>
		        base = 8;
  8009f6:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8009fb:	eb 37                	jmp    800a34 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8009fd:	83 ec 08             	sub    $0x8,%esp
  800a00:	53                   	push   %ebx
  800a01:	6a 30                	push   $0x30
  800a03:	ff d6                	call   *%esi
			putch('x', putdat);
  800a05:	83 c4 08             	add    $0x8,%esp
  800a08:	53                   	push   %ebx
  800a09:	6a 78                	push   $0x78
  800a0b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a10:	8d 50 04             	lea    0x4(%eax),%edx
  800a13:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a16:	8b 00                	mov    (%eax),%eax
  800a18:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a1d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a20:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a25:	eb 0d                	jmp    800a34 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a27:	8d 45 14             	lea    0x14(%ebp),%eax
  800a2a:	e8 3b fc ff ff       	call   80066a <getuint>
			base = 16;
  800a2f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a34:	83 ec 0c             	sub    $0xc,%esp
  800a37:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a3b:	57                   	push   %edi
  800a3c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a3f:	51                   	push   %ecx
  800a40:	52                   	push   %edx
  800a41:	50                   	push   %eax
  800a42:	89 da                	mov    %ebx,%edx
  800a44:	89 f0                	mov    %esi,%eax
  800a46:	e8 70 fb ff ff       	call   8005bb <printnum>
			break;
  800a4b:	83 c4 20             	add    $0x20,%esp
  800a4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a51:	e9 ae fc ff ff       	jmp    800704 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a56:	83 ec 08             	sub    $0x8,%esp
  800a59:	53                   	push   %ebx
  800a5a:	51                   	push   %ecx
  800a5b:	ff d6                	call   *%esi
			break;
  800a5d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a63:	e9 9c fc ff ff       	jmp    800704 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	53                   	push   %ebx
  800a6c:	6a 25                	push   $0x25
  800a6e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a70:	83 c4 10             	add    $0x10,%esp
  800a73:	eb 03                	jmp    800a78 <vprintfmt+0x39a>
  800a75:	83 ef 01             	sub    $0x1,%edi
  800a78:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a7c:	75 f7                	jne    800a75 <vprintfmt+0x397>
  800a7e:	e9 81 fc ff ff       	jmp    800704 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	83 ec 18             	sub    $0x18,%esp
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a97:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a9a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a9e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aa8:	85 c0                	test   %eax,%eax
  800aaa:	74 26                	je     800ad2 <vsnprintf+0x47>
  800aac:	85 d2                	test   %edx,%edx
  800aae:	7e 22                	jle    800ad2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ab0:	ff 75 14             	pushl  0x14(%ebp)
  800ab3:	ff 75 10             	pushl  0x10(%ebp)
  800ab6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ab9:	50                   	push   %eax
  800aba:	68 a4 06 80 00       	push   $0x8006a4
  800abf:	e8 1a fc ff ff       	call   8006de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ac4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ac7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800acd:	83 c4 10             	add    $0x10,%esp
  800ad0:	eb 05                	jmp    800ad7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ad2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ad7:	c9                   	leave  
  800ad8:	c3                   	ret    

00800ad9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800adf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ae2:	50                   	push   %eax
  800ae3:	ff 75 10             	pushl  0x10(%ebp)
  800ae6:	ff 75 0c             	pushl  0xc(%ebp)
  800ae9:	ff 75 08             	pushl  0x8(%ebp)
  800aec:	e8 9a ff ff ff       	call   800a8b <vsnprintf>
	va_end(ap);

	return rc;
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	eb 03                	jmp    800b03 <strlen+0x10>
		n++;
  800b00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b07:	75 f7                	jne    800b00 <strlen+0xd>
		n++;
	return n;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b11:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	eb 03                	jmp    800b1e <strnlen+0x13>
		n++;
  800b1b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b1e:	39 c2                	cmp    %eax,%edx
  800b20:	74 08                	je     800b2a <strnlen+0x1f>
  800b22:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b26:	75 f3                	jne    800b1b <strnlen+0x10>
  800b28:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	53                   	push   %ebx
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	83 c2 01             	add    $0x1,%edx
  800b3b:	83 c1 01             	add    $0x1,%ecx
  800b3e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b42:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b45:	84 db                	test   %bl,%bl
  800b47:	75 ef                	jne    800b38 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	53                   	push   %ebx
  800b50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b53:	53                   	push   %ebx
  800b54:	e8 9a ff ff ff       	call   800af3 <strlen>
  800b59:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b5c:	ff 75 0c             	pushl  0xc(%ebp)
  800b5f:	01 d8                	add    %ebx,%eax
  800b61:	50                   	push   %eax
  800b62:	e8 c5 ff ff ff       	call   800b2c <strcpy>
	return dst;
}
  800b67:	89 d8                	mov    %ebx,%eax
  800b69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	8b 75 08             	mov    0x8(%ebp),%esi
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b7e:	89 f2                	mov    %esi,%edx
  800b80:	eb 0f                	jmp    800b91 <strncpy+0x23>
		*dst++ = *src;
  800b82:	83 c2 01             	add    $0x1,%edx
  800b85:	0f b6 01             	movzbl (%ecx),%eax
  800b88:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b8b:	80 39 01             	cmpb   $0x1,(%ecx)
  800b8e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b91:	39 da                	cmp    %ebx,%edx
  800b93:	75 ed                	jne    800b82 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b95:	89 f0                	mov    %esi,%eax
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 10             	mov    0x10(%ebp),%edx
  800ba9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bab:	85 d2                	test   %edx,%edx
  800bad:	74 21                	je     800bd0 <strlcpy+0x35>
  800baf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bb3:	89 f2                	mov    %esi,%edx
  800bb5:	eb 09                	jmp    800bc0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bb7:	83 c2 01             	add    $0x1,%edx
  800bba:	83 c1 01             	add    $0x1,%ecx
  800bbd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bc0:	39 c2                	cmp    %eax,%edx
  800bc2:	74 09                	je     800bcd <strlcpy+0x32>
  800bc4:	0f b6 19             	movzbl (%ecx),%ebx
  800bc7:	84 db                	test   %bl,%bl
  800bc9:	75 ec                	jne    800bb7 <strlcpy+0x1c>
  800bcb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bcd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bd0:	29 f0                	sub    %esi,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bdf:	eb 06                	jmp    800be7 <strcmp+0x11>
		p++, q++;
  800be1:	83 c1 01             	add    $0x1,%ecx
  800be4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800be7:	0f b6 01             	movzbl (%ecx),%eax
  800bea:	84 c0                	test   %al,%al
  800bec:	74 04                	je     800bf2 <strcmp+0x1c>
  800bee:	3a 02                	cmp    (%edx),%al
  800bf0:	74 ef                	je     800be1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf2:	0f b6 c0             	movzbl %al,%eax
  800bf5:	0f b6 12             	movzbl (%edx),%edx
  800bf8:	29 d0                	sub    %edx,%eax
}
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	53                   	push   %ebx
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c06:	89 c3                	mov    %eax,%ebx
  800c08:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c0b:	eb 06                	jmp    800c13 <strncmp+0x17>
		n--, p++, q++;
  800c0d:	83 c0 01             	add    $0x1,%eax
  800c10:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c13:	39 d8                	cmp    %ebx,%eax
  800c15:	74 15                	je     800c2c <strncmp+0x30>
  800c17:	0f b6 08             	movzbl (%eax),%ecx
  800c1a:	84 c9                	test   %cl,%cl
  800c1c:	74 04                	je     800c22 <strncmp+0x26>
  800c1e:	3a 0a                	cmp    (%edx),%cl
  800c20:	74 eb                	je     800c0d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c22:	0f b6 00             	movzbl (%eax),%eax
  800c25:	0f b6 12             	movzbl (%edx),%edx
  800c28:	29 d0                	sub    %edx,%eax
  800c2a:	eb 05                	jmp    800c31 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c3e:	eb 07                	jmp    800c47 <strchr+0x13>
		if (*s == c)
  800c40:	38 ca                	cmp    %cl,%dl
  800c42:	74 0f                	je     800c53 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c44:	83 c0 01             	add    $0x1,%eax
  800c47:	0f b6 10             	movzbl (%eax),%edx
  800c4a:	84 d2                	test   %dl,%dl
  800c4c:	75 f2                	jne    800c40 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c5f:	eb 03                	jmp    800c64 <strfind+0xf>
  800c61:	83 c0 01             	add    $0x1,%eax
  800c64:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c67:	38 ca                	cmp    %cl,%dl
  800c69:	74 04                	je     800c6f <strfind+0x1a>
  800c6b:	84 d2                	test   %dl,%dl
  800c6d:	75 f2                	jne    800c61 <strfind+0xc>
			break;
	return (char *) s;
}
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c7d:	85 c9                	test   %ecx,%ecx
  800c7f:	74 36                	je     800cb7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c87:	75 28                	jne    800cb1 <memset+0x40>
  800c89:	f6 c1 03             	test   $0x3,%cl
  800c8c:	75 23                	jne    800cb1 <memset+0x40>
		c &= 0xFF;
  800c8e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c92:	89 d3                	mov    %edx,%ebx
  800c94:	c1 e3 08             	shl    $0x8,%ebx
  800c97:	89 d6                	mov    %edx,%esi
  800c99:	c1 e6 18             	shl    $0x18,%esi
  800c9c:	89 d0                	mov    %edx,%eax
  800c9e:	c1 e0 10             	shl    $0x10,%eax
  800ca1:	09 f0                	or     %esi,%eax
  800ca3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ca5:	89 d8                	mov    %ebx,%eax
  800ca7:	09 d0                	or     %edx,%eax
  800ca9:	c1 e9 02             	shr    $0x2,%ecx
  800cac:	fc                   	cld    
  800cad:	f3 ab                	rep stos %eax,%es:(%edi)
  800caf:	eb 06                	jmp    800cb7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb4:	fc                   	cld    
  800cb5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cb7:	89 f8                	mov    %edi,%eax
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ccc:	39 c6                	cmp    %eax,%esi
  800cce:	73 35                	jae    800d05 <memmove+0x47>
  800cd0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cd3:	39 d0                	cmp    %edx,%eax
  800cd5:	73 2e                	jae    800d05 <memmove+0x47>
		s += n;
		d += n;
  800cd7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cda:	89 d6                	mov    %edx,%esi
  800cdc:	09 fe                	or     %edi,%esi
  800cde:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ce4:	75 13                	jne    800cf9 <memmove+0x3b>
  800ce6:	f6 c1 03             	test   $0x3,%cl
  800ce9:	75 0e                	jne    800cf9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ceb:	83 ef 04             	sub    $0x4,%edi
  800cee:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cf1:	c1 e9 02             	shr    $0x2,%ecx
  800cf4:	fd                   	std    
  800cf5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf7:	eb 09                	jmp    800d02 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cf9:	83 ef 01             	sub    $0x1,%edi
  800cfc:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cff:	fd                   	std    
  800d00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d02:	fc                   	cld    
  800d03:	eb 1d                	jmp    800d22 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d05:	89 f2                	mov    %esi,%edx
  800d07:	09 c2                	or     %eax,%edx
  800d09:	f6 c2 03             	test   $0x3,%dl
  800d0c:	75 0f                	jne    800d1d <memmove+0x5f>
  800d0e:	f6 c1 03             	test   $0x3,%cl
  800d11:	75 0a                	jne    800d1d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d13:	c1 e9 02             	shr    $0x2,%ecx
  800d16:	89 c7                	mov    %eax,%edi
  800d18:	fc                   	cld    
  800d19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d1b:	eb 05                	jmp    800d22 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d1d:	89 c7                	mov    %eax,%edi
  800d1f:	fc                   	cld    
  800d20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d29:	ff 75 10             	pushl  0x10(%ebp)
  800d2c:	ff 75 0c             	pushl  0xc(%ebp)
  800d2f:	ff 75 08             	pushl  0x8(%ebp)
  800d32:	e8 87 ff ff ff       	call   800cbe <memmove>
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d44:	89 c6                	mov    %eax,%esi
  800d46:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d49:	eb 1a                	jmp    800d65 <memcmp+0x2c>
		if (*s1 != *s2)
  800d4b:	0f b6 08             	movzbl (%eax),%ecx
  800d4e:	0f b6 1a             	movzbl (%edx),%ebx
  800d51:	38 d9                	cmp    %bl,%cl
  800d53:	74 0a                	je     800d5f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d55:	0f b6 c1             	movzbl %cl,%eax
  800d58:	0f b6 db             	movzbl %bl,%ebx
  800d5b:	29 d8                	sub    %ebx,%eax
  800d5d:	eb 0f                	jmp    800d6e <memcmp+0x35>
		s1++, s2++;
  800d5f:	83 c0 01             	add    $0x1,%eax
  800d62:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d65:	39 f0                	cmp    %esi,%eax
  800d67:	75 e2                	jne    800d4b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	53                   	push   %ebx
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d79:	89 c1                	mov    %eax,%ecx
  800d7b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d7e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d82:	eb 0a                	jmp    800d8e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d84:	0f b6 10             	movzbl (%eax),%edx
  800d87:	39 da                	cmp    %ebx,%edx
  800d89:	74 07                	je     800d92 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d8b:	83 c0 01             	add    $0x1,%eax
  800d8e:	39 c8                	cmp    %ecx,%eax
  800d90:	72 f2                	jb     800d84 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d92:	5b                   	pop    %ebx
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da1:	eb 03                	jmp    800da6 <strtol+0x11>
		s++;
  800da3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da6:	0f b6 01             	movzbl (%ecx),%eax
  800da9:	3c 20                	cmp    $0x20,%al
  800dab:	74 f6                	je     800da3 <strtol+0xe>
  800dad:	3c 09                	cmp    $0x9,%al
  800daf:	74 f2                	je     800da3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800db1:	3c 2b                	cmp    $0x2b,%al
  800db3:	75 0a                	jne    800dbf <strtol+0x2a>
		s++;
  800db5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800db8:	bf 00 00 00 00       	mov    $0x0,%edi
  800dbd:	eb 11                	jmp    800dd0 <strtol+0x3b>
  800dbf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dc4:	3c 2d                	cmp    $0x2d,%al
  800dc6:	75 08                	jne    800dd0 <strtol+0x3b>
		s++, neg = 1;
  800dc8:	83 c1 01             	add    $0x1,%ecx
  800dcb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dd0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dd6:	75 15                	jne    800ded <strtol+0x58>
  800dd8:	80 39 30             	cmpb   $0x30,(%ecx)
  800ddb:	75 10                	jne    800ded <strtol+0x58>
  800ddd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800de1:	75 7c                	jne    800e5f <strtol+0xca>
		s += 2, base = 16;
  800de3:	83 c1 02             	add    $0x2,%ecx
  800de6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800deb:	eb 16                	jmp    800e03 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ded:	85 db                	test   %ebx,%ebx
  800def:	75 12                	jne    800e03 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800df1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800df6:	80 39 30             	cmpb   $0x30,(%ecx)
  800df9:	75 08                	jne    800e03 <strtol+0x6e>
		s++, base = 8;
  800dfb:	83 c1 01             	add    $0x1,%ecx
  800dfe:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e03:	b8 00 00 00 00       	mov    $0x0,%eax
  800e08:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e0b:	0f b6 11             	movzbl (%ecx),%edx
  800e0e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e11:	89 f3                	mov    %esi,%ebx
  800e13:	80 fb 09             	cmp    $0x9,%bl
  800e16:	77 08                	ja     800e20 <strtol+0x8b>
			dig = *s - '0';
  800e18:	0f be d2             	movsbl %dl,%edx
  800e1b:	83 ea 30             	sub    $0x30,%edx
  800e1e:	eb 22                	jmp    800e42 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e20:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e23:	89 f3                	mov    %esi,%ebx
  800e25:	80 fb 19             	cmp    $0x19,%bl
  800e28:	77 08                	ja     800e32 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e2a:	0f be d2             	movsbl %dl,%edx
  800e2d:	83 ea 57             	sub    $0x57,%edx
  800e30:	eb 10                	jmp    800e42 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e32:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e35:	89 f3                	mov    %esi,%ebx
  800e37:	80 fb 19             	cmp    $0x19,%bl
  800e3a:	77 16                	ja     800e52 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e3c:	0f be d2             	movsbl %dl,%edx
  800e3f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e42:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e45:	7d 0b                	jge    800e52 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e47:	83 c1 01             	add    $0x1,%ecx
  800e4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e4e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e50:	eb b9                	jmp    800e0b <strtol+0x76>

	if (endptr)
  800e52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e56:	74 0d                	je     800e65 <strtol+0xd0>
		*endptr = (char *) s;
  800e58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e5b:	89 0e                	mov    %ecx,(%esi)
  800e5d:	eb 06                	jmp    800e65 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e5f:	85 db                	test   %ebx,%ebx
  800e61:	74 98                	je     800dfb <strtol+0x66>
  800e63:	eb 9e                	jmp    800e03 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	f7 da                	neg    %edx
  800e69:	85 ff                	test   %edi,%edi
  800e6b:	0f 45 c2             	cmovne %edx,%eax
}
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e81:	8b 55 08             	mov    0x8(%ebp),%edx
  800e84:	89 c3                	mov    %eax,%ebx
  800e86:	89 c7                	mov    %eax,%edi
  800e88:	89 c6                	mov    %eax,%esi
  800e8a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea1:	89 d1                	mov    %edx,%ecx
  800ea3:	89 d3                	mov    %edx,%ebx
  800ea5:	89 d7                	mov    %edx,%edi
  800ea7:	89 d6                	mov    %edx,%esi
  800ea9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebe:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 cb                	mov    %ecx,%ebx
  800ec8:	89 cf                	mov    %ecx,%edi
  800eca:	89 ce                	mov    %ecx,%esi
  800ecc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	7e 17                	jle    800ee9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	50                   	push   %eax
  800ed6:	6a 03                	push   $0x3
  800ed8:	68 df 2a 80 00       	push   $0x802adf
  800edd:	6a 23                	push   $0x23
  800edf:	68 fc 2a 80 00       	push   $0x802afc
  800ee4:	e8 cc 13 00 00       	call   8022b5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ee9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  800efc:	b8 02 00 00 00       	mov    $0x2,%eax
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 d3                	mov    %edx,%ebx
  800f05:	89 d7                	mov    %edx,%edi
  800f07:	89 d6                	mov    %edx,%esi
  800f09:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <sys_yield>:

void
sys_yield(void)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f20:	89 d1                	mov    %edx,%ecx
  800f22:	89 d3                	mov    %edx,%ebx
  800f24:	89 d7                	mov    %edx,%edi
  800f26:	89 d6                	mov    %edx,%esi
  800f28:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f38:	be 00 00 00 00       	mov    $0x0,%esi
  800f3d:	b8 04 00 00 00       	mov    $0x4,%eax
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4b:	89 f7                	mov    %esi,%edi
  800f4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	7e 17                	jle    800f6a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	50                   	push   %eax
  800f57:	6a 04                	push   $0x4
  800f59:	68 df 2a 80 00       	push   $0x802adf
  800f5e:	6a 23                	push   $0x23
  800f60:	68 fc 2a 80 00       	push   $0x802afc
  800f65:	e8 4b 13 00 00       	call   8022b5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
  800f86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f8c:	8b 75 18             	mov    0x18(%ebp),%esi
  800f8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 17                	jle    800fac <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	50                   	push   %eax
  800f99:	6a 05                	push   $0x5
  800f9b:	68 df 2a 80 00       	push   $0x802adf
  800fa0:	6a 23                	push   $0x23
  800fa2:	68 fc 2a 80 00       	push   $0x802afc
  800fa7:	e8 09 13 00 00       	call   8022b5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800fc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fca:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcd:	89 df                	mov    %ebx,%edi
  800fcf:	89 de                	mov    %ebx,%esi
  800fd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	7e 17                	jle    800fee <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	50                   	push   %eax
  800fdb:	6a 06                	push   $0x6
  800fdd:	68 df 2a 80 00       	push   $0x802adf
  800fe2:	6a 23                	push   $0x23
  800fe4:	68 fc 2a 80 00       	push   $0x802afc
  800fe9:	e8 c7 12 00 00       	call   8022b5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801004:	b8 08 00 00 00       	mov    $0x8,%eax
  801009:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100c:	8b 55 08             	mov    0x8(%ebp),%edx
  80100f:	89 df                	mov    %ebx,%edi
  801011:	89 de                	mov    %ebx,%esi
  801013:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801015:	85 c0                	test   %eax,%eax
  801017:	7e 17                	jle    801030 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	50                   	push   %eax
  80101d:	6a 08                	push   $0x8
  80101f:	68 df 2a 80 00       	push   $0x802adf
  801024:	6a 23                	push   $0x23
  801026:	68 fc 2a 80 00       	push   $0x802afc
  80102b:	e8 85 12 00 00       	call   8022b5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	57                   	push   %edi
  80103c:	56                   	push   %esi
  80103d:	53                   	push   %ebx
  80103e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801041:	bb 00 00 00 00       	mov    $0x0,%ebx
  801046:	b8 09 00 00 00       	mov    $0x9,%eax
  80104b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104e:	8b 55 08             	mov    0x8(%ebp),%edx
  801051:	89 df                	mov    %ebx,%edi
  801053:	89 de                	mov    %ebx,%esi
  801055:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801057:	85 c0                	test   %eax,%eax
  801059:	7e 17                	jle    801072 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	50                   	push   %eax
  80105f:	6a 09                	push   $0x9
  801061:	68 df 2a 80 00       	push   $0x802adf
  801066:	6a 23                	push   $0x23
  801068:	68 fc 2a 80 00       	push   $0x802afc
  80106d:	e8 43 12 00 00       	call   8022b5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801072:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801075:	5b                   	pop    %ebx
  801076:	5e                   	pop    %esi
  801077:	5f                   	pop    %edi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	53                   	push   %ebx
  801080:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801083:	bb 00 00 00 00       	mov    $0x0,%ebx
  801088:	b8 0a 00 00 00       	mov    $0xa,%eax
  80108d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801090:	8b 55 08             	mov    0x8(%ebp),%edx
  801093:	89 df                	mov    %ebx,%edi
  801095:	89 de                	mov    %ebx,%esi
  801097:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801099:	85 c0                	test   %eax,%eax
  80109b:	7e 17                	jle    8010b4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	50                   	push   %eax
  8010a1:	6a 0a                	push   $0xa
  8010a3:	68 df 2a 80 00       	push   $0x802adf
  8010a8:	6a 23                	push   $0x23
  8010aa:	68 fc 2a 80 00       	push   $0x802afc
  8010af:	e8 01 12 00 00       	call   8022b5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	57                   	push   %edi
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c2:	be 00 00 00 00       	mov    $0x0,%esi
  8010c7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ed:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f5:	89 cb                	mov    %ecx,%ebx
  8010f7:	89 cf                	mov    %ecx,%edi
  8010f9:	89 ce                	mov    %ecx,%esi
  8010fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	7e 17                	jle    801118 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	50                   	push   %eax
  801105:	6a 0d                	push   $0xd
  801107:	68 df 2a 80 00       	push   $0x802adf
  80110c:	6a 23                	push   $0x23
  80110e:	68 fc 2a 80 00       	push   $0x802afc
  801113:	e8 9d 11 00 00       	call   8022b5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801126:	ba 00 00 00 00       	mov    $0x0,%edx
  80112b:	b8 0e 00 00 00       	mov    $0xe,%eax
  801130:	89 d1                	mov    %edx,%ecx
  801132:	89 d3                	mov    %edx,%ebx
  801134:	89 d7                	mov    %edx,%edi
  801136:	89 d6                	mov    %edx,%esi
  801138:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80113a:	5b                   	pop    %ebx
  80113b:	5e                   	pop    %esi
  80113c:	5f                   	pop    %edi
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	57                   	push   %edi
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801145:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80114f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801152:	8b 55 08             	mov    0x8(%ebp),%edx
  801155:	89 df                	mov    %ebx,%edi
  801157:	89 de                	mov    %ebx,%esi
  801159:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	05 00 00 00 30       	add    $0x30000000,%eax
  80116b:	c1 e8 0c             	shr    $0xc,%eax
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	05 00 00 00 30       	add    $0x30000000,%eax
  80117b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801180:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 16             	shr    $0x16,%edx
  801197:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 11                	je     8011b4 <fd_alloc+0x2d>
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	c1 ea 0c             	shr    $0xc,%edx
  8011a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011af:	f6 c2 01             	test   $0x1,%dl
  8011b2:	75 09                	jne    8011bd <fd_alloc+0x36>
			*fd_store = fd;
  8011b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bb:	eb 17                	jmp    8011d4 <fd_alloc+0x4d>
  8011bd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c7:	75 c9                	jne    801192 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011dc:	83 f8 1f             	cmp    $0x1f,%eax
  8011df:	77 36                	ja     801217 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e1:	c1 e0 0c             	shl    $0xc,%eax
  8011e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 16             	shr    $0x16,%edx
  8011ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	74 24                	je     80121e <fd_lookup+0x48>
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 0c             	shr    $0xc,%edx
  8011ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 1a                	je     801225 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	89 02                	mov    %eax,(%edx)
	return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	eb 13                	jmp    80122a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121c:	eb 0c                	jmp    80122a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801223:	eb 05                	jmp    80122a <fd_lookup+0x54>
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801235:	ba 88 2b 80 00       	mov    $0x802b88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80123a:	eb 13                	jmp    80124f <dev_lookup+0x23>
  80123c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80123f:	39 08                	cmp    %ecx,(%eax)
  801241:	75 0c                	jne    80124f <dev_lookup+0x23>
			*dev = devtab[i];
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	89 01                	mov    %eax,(%ecx)
			return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	eb 2e                	jmp    80127d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80124f:	8b 02                	mov    (%edx),%eax
  801251:	85 c0                	test   %eax,%eax
  801253:	75 e7                	jne    80123c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801255:	a1 18 40 80 00       	mov    0x804018,%eax
  80125a:	8b 40 48             	mov    0x48(%eax),%eax
  80125d:	83 ec 04             	sub    $0x4,%esp
  801260:	51                   	push   %ecx
  801261:	50                   	push   %eax
  801262:	68 0c 2b 80 00       	push   $0x802b0c
  801267:	e8 3b f3 ff ff       	call   8005a7 <cprintf>
	*dev = 0;
  80126c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 10             	sub    $0x10,%esp
  801287:	8b 75 08             	mov    0x8(%ebp),%esi
  80128a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801297:	c1 e8 0c             	shr    $0xc,%eax
  80129a:	50                   	push   %eax
  80129b:	e8 36 ff ff ff       	call   8011d6 <fd_lookup>
  8012a0:	83 c4 08             	add    $0x8,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 05                	js     8012ac <fd_close+0x2d>
	    || fd != fd2)
  8012a7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012aa:	74 0c                	je     8012b8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012ac:	84 db                	test   %bl,%bl
  8012ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b3:	0f 44 c2             	cmove  %edx,%eax
  8012b6:	eb 41                	jmp    8012f9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	ff 36                	pushl  (%esi)
  8012c1:	e8 66 ff ff ff       	call   80122c <dev_lookup>
  8012c6:	89 c3                	mov    %eax,%ebx
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 1a                	js     8012e9 <fd_close+0x6a>
		if (dev->dev_close)
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	74 0b                	je     8012e9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012de:	83 ec 0c             	sub    $0xc,%esp
  8012e1:	56                   	push   %esi
  8012e2:	ff d0                	call   *%eax
  8012e4:	89 c3                	mov    %eax,%ebx
  8012e6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	56                   	push   %esi
  8012ed:	6a 00                	push   $0x0
  8012ef:	e8 c0 fc ff ff       	call   800fb4 <sys_page_unmap>
	return r;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 d8                	mov    %ebx,%eax
}
  8012f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	ff 75 08             	pushl  0x8(%ebp)
  80130d:	e8 c4 fe ff ff       	call   8011d6 <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 10                	js     801329 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	6a 01                	push   $0x1
  80131e:	ff 75 f4             	pushl  -0xc(%ebp)
  801321:	e8 59 ff ff ff       	call   80127f <fd_close>
  801326:	83 c4 10             	add    $0x10,%esp
}
  801329:	c9                   	leave  
  80132a:	c3                   	ret    

0080132b <close_all>:

void
close_all(void)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	53                   	push   %ebx
  80132f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801332:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	53                   	push   %ebx
  80133b:	e8 c0 ff ff ff       	call   801300 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801340:	83 c3 01             	add    $0x1,%ebx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	83 fb 20             	cmp    $0x20,%ebx
  801349:	75 ec                	jne    801337 <close_all+0xc>
		close(i);
}
  80134b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134e:	c9                   	leave  
  80134f:	c3                   	ret    

00801350 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	57                   	push   %edi
  801354:	56                   	push   %esi
  801355:	53                   	push   %ebx
  801356:	83 ec 2c             	sub    $0x2c,%esp
  801359:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80135c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 6e fe ff ff       	call   8011d6 <fd_lookup>
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	0f 88 c1 00 00 00    	js     801434 <dup+0xe4>
		return r;
	close(newfdnum);
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	56                   	push   %esi
  801377:	e8 84 ff ff ff       	call   801300 <close>

	newfd = INDEX2FD(newfdnum);
  80137c:	89 f3                	mov    %esi,%ebx
  80137e:	c1 e3 0c             	shl    $0xc,%ebx
  801381:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801387:	83 c4 04             	add    $0x4,%esp
  80138a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80138d:	e8 de fd ff ff       	call   801170 <fd2data>
  801392:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801394:	89 1c 24             	mov    %ebx,(%esp)
  801397:	e8 d4 fd ff ff       	call   801170 <fd2data>
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013a2:	89 f8                	mov    %edi,%eax
  8013a4:	c1 e8 16             	shr    $0x16,%eax
  8013a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ae:	a8 01                	test   $0x1,%al
  8013b0:	74 37                	je     8013e9 <dup+0x99>
  8013b2:	89 f8                	mov    %edi,%eax
  8013b4:	c1 e8 0c             	shr    $0xc,%eax
  8013b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013be:	f6 c2 01             	test   $0x1,%dl
  8013c1:	74 26                	je     8013e9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d2:	50                   	push   %eax
  8013d3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d6:	6a 00                	push   $0x0
  8013d8:	57                   	push   %edi
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 92 fb ff ff       	call   800f72 <sys_page_map>
  8013e0:	89 c7                	mov    %eax,%edi
  8013e2:	83 c4 20             	add    $0x20,%esp
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 2e                	js     801417 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ec:	89 d0                	mov    %edx,%eax
  8013ee:	c1 e8 0c             	shr    $0xc,%eax
  8013f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801400:	50                   	push   %eax
  801401:	53                   	push   %ebx
  801402:	6a 00                	push   $0x0
  801404:	52                   	push   %edx
  801405:	6a 00                	push   $0x0
  801407:	e8 66 fb ff ff       	call   800f72 <sys_page_map>
  80140c:	89 c7                	mov    %eax,%edi
  80140e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801411:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801413:	85 ff                	test   %edi,%edi
  801415:	79 1d                	jns    801434 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	53                   	push   %ebx
  80141b:	6a 00                	push   $0x0
  80141d:	e8 92 fb ff ff       	call   800fb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801422:	83 c4 08             	add    $0x8,%esp
  801425:	ff 75 d4             	pushl  -0x2c(%ebp)
  801428:	6a 00                	push   $0x0
  80142a:	e8 85 fb ff ff       	call   800fb4 <sys_page_unmap>
	return r;
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	89 f8                	mov    %edi,%eax
}
  801434:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5f                   	pop    %edi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	53                   	push   %ebx
  801440:	83 ec 14             	sub    $0x14,%esp
  801443:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801446:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	53                   	push   %ebx
  80144b:	e8 86 fd ff ff       	call   8011d6 <fd_lookup>
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	89 c2                	mov    %eax,%edx
  801455:	85 c0                	test   %eax,%eax
  801457:	78 6d                	js     8014c6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801463:	ff 30                	pushl  (%eax)
  801465:	e8 c2 fd ff ff       	call   80122c <dev_lookup>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 4c                	js     8014bd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801471:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801474:	8b 42 08             	mov    0x8(%edx),%eax
  801477:	83 e0 03             	and    $0x3,%eax
  80147a:	83 f8 01             	cmp    $0x1,%eax
  80147d:	75 21                	jne    8014a0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80147f:	a1 18 40 80 00       	mov    0x804018,%eax
  801484:	8b 40 48             	mov    0x48(%eax),%eax
  801487:	83 ec 04             	sub    $0x4,%esp
  80148a:	53                   	push   %ebx
  80148b:	50                   	push   %eax
  80148c:	68 4d 2b 80 00       	push   $0x802b4d
  801491:	e8 11 f1 ff ff       	call   8005a7 <cprintf>
		return -E_INVAL;
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80149e:	eb 26                	jmp    8014c6 <read+0x8a>
	}
	if (!dev->dev_read)
  8014a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a3:	8b 40 08             	mov    0x8(%eax),%eax
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	74 17                	je     8014c1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	ff 75 10             	pushl  0x10(%ebp)
  8014b0:	ff 75 0c             	pushl  0xc(%ebp)
  8014b3:	52                   	push   %edx
  8014b4:	ff d0                	call   *%eax
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	eb 09                	jmp    8014c6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bd:	89 c2                	mov    %eax,%edx
  8014bf:	eb 05                	jmp    8014c6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014c6:	89 d0                	mov    %edx,%eax
  8014c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    

008014cd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	57                   	push   %edi
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e1:	eb 21                	jmp    801504 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	89 f0                	mov    %esi,%eax
  8014e8:	29 d8                	sub    %ebx,%eax
  8014ea:	50                   	push   %eax
  8014eb:	89 d8                	mov    %ebx,%eax
  8014ed:	03 45 0c             	add    0xc(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	57                   	push   %edi
  8014f2:	e8 45 ff ff ff       	call   80143c <read>
		if (m < 0)
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 10                	js     80150e <readn+0x41>
			return m;
		if (m == 0)
  8014fe:	85 c0                	test   %eax,%eax
  801500:	74 0a                	je     80150c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801502:	01 c3                	add    %eax,%ebx
  801504:	39 f3                	cmp    %esi,%ebx
  801506:	72 db                	jb     8014e3 <readn+0x16>
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	eb 02                	jmp    80150e <readn+0x41>
  80150c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80150e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801511:	5b                   	pop    %ebx
  801512:	5e                   	pop    %esi
  801513:	5f                   	pop    %edi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 14             	sub    $0x14,%esp
  80151d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801520:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	53                   	push   %ebx
  801525:	e8 ac fc ff ff       	call   8011d6 <fd_lookup>
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 68                	js     80159b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	ff 30                	pushl  (%eax)
  80153f:	e8 e8 fc ff ff       	call   80122c <dev_lookup>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 47                	js     801592 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801552:	75 21                	jne    801575 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801554:	a1 18 40 80 00       	mov    0x804018,%eax
  801559:	8b 40 48             	mov    0x48(%eax),%eax
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	53                   	push   %ebx
  801560:	50                   	push   %eax
  801561:	68 69 2b 80 00       	push   $0x802b69
  801566:	e8 3c f0 ff ff       	call   8005a7 <cprintf>
		return -E_INVAL;
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801573:	eb 26                	jmp    80159b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801575:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801578:	8b 52 0c             	mov    0xc(%edx),%edx
  80157b:	85 d2                	test   %edx,%edx
  80157d:	74 17                	je     801596 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	ff 75 10             	pushl  0x10(%ebp)
  801585:	ff 75 0c             	pushl  0xc(%ebp)
  801588:	50                   	push   %eax
  801589:	ff d2                	call   *%edx
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	eb 09                	jmp    80159b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801592:	89 c2                	mov    %eax,%edx
  801594:	eb 05                	jmp    80159b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801596:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	ff 75 08             	pushl  0x8(%ebp)
  8015af:	e8 22 fc ff ff       	call   8011d6 <fd_lookup>
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 0e                	js     8015c9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 14             	sub    $0x14,%esp
  8015d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	53                   	push   %ebx
  8015da:	e8 f7 fb ff ff       	call   8011d6 <fd_lookup>
  8015df:	83 c4 08             	add    $0x8,%esp
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 65                	js     80164d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	ff 30                	pushl  (%eax)
  8015f4:	e8 33 fc ff ff       	call   80122c <dev_lookup>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 44                	js     801644 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801607:	75 21                	jne    80162a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801609:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80160e:	8b 40 48             	mov    0x48(%eax),%eax
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	53                   	push   %ebx
  801615:	50                   	push   %eax
  801616:	68 2c 2b 80 00       	push   $0x802b2c
  80161b:	e8 87 ef ff ff       	call   8005a7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801628:	eb 23                	jmp    80164d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80162a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162d:	8b 52 18             	mov    0x18(%edx),%edx
  801630:	85 d2                	test   %edx,%edx
  801632:	74 14                	je     801648 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	ff 75 0c             	pushl  0xc(%ebp)
  80163a:	50                   	push   %eax
  80163b:	ff d2                	call   *%edx
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	eb 09                	jmp    80164d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801644:	89 c2                	mov    %eax,%edx
  801646:	eb 05                	jmp    80164d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801648:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80164d:	89 d0                	mov    %edx,%eax
  80164f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
  801658:	83 ec 14             	sub    $0x14,%esp
  80165b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	ff 75 08             	pushl  0x8(%ebp)
  801665:	e8 6c fb ff ff       	call   8011d6 <fd_lookup>
  80166a:	83 c4 08             	add    $0x8,%esp
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 58                	js     8016cb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	ff 30                	pushl  (%eax)
  80167f:	e8 a8 fb ff ff       	call   80122c <dev_lookup>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 37                	js     8016c2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80168b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801692:	74 32                	je     8016c6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801694:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801697:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169e:	00 00 00 
	stat->st_isdir = 0;
  8016a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a8:	00 00 00 
	stat->st_dev = dev;
  8016ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	53                   	push   %ebx
  8016b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b8:	ff 50 14             	call   *0x14(%eax)
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	eb 09                	jmp    8016cb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	eb 05                	jmp    8016cb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016cb:	89 d0                	mov    %edx,%eax
  8016cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	6a 00                	push   $0x0
  8016dc:	ff 75 08             	pushl  0x8(%ebp)
  8016df:	e8 e7 01 00 00       	call   8018cb <open>
  8016e4:	89 c3                	mov    %eax,%ebx
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 1b                	js     801708 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	ff 75 0c             	pushl  0xc(%ebp)
  8016f3:	50                   	push   %eax
  8016f4:	e8 5b ff ff ff       	call   801654 <fstat>
  8016f9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016fb:	89 1c 24             	mov    %ebx,(%esp)
  8016fe:	e8 fd fb ff ff       	call   801300 <close>
	return r;
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	89 f0                	mov    %esi,%eax
}
  801708:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	89 c6                	mov    %eax,%esi
  801716:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801718:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  80171f:	75 12                	jne    801733 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801721:	83 ec 0c             	sub    $0xc,%esp
  801724:	6a 01                	push   $0x1
  801726:	e8 91 0c 00 00       	call   8023bc <ipc_find_env>
  80172b:	a3 10 40 80 00       	mov    %eax,0x804010
  801730:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801733:	6a 07                	push   $0x7
  801735:	68 00 50 80 00       	push   $0x805000
  80173a:	56                   	push   %esi
  80173b:	ff 35 10 40 80 00    	pushl  0x804010
  801741:	e8 22 0c 00 00       	call   802368 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801746:	83 c4 0c             	add    $0xc,%esp
  801749:	6a 00                	push   $0x0
  80174b:	53                   	push   %ebx
  80174c:	6a 00                	push   $0x0
  80174e:	e8 a8 0b 00 00       	call   8022fb <ipc_recv>
}
  801753:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	8b 40 0c             	mov    0xc(%eax),%eax
  801766:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
  801778:	b8 02 00 00 00       	mov    $0x2,%eax
  80177d:	e8 8d ff ff ff       	call   80170f <fsipc>
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
  80179a:	b8 06 00 00 00       	mov    $0x6,%eax
  80179f:	e8 6b ff ff ff       	call   80170f <fsipc>
}
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 04             	sub    $0x4,%esp
  8017ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c5:	e8 45 ff ff ff       	call   80170f <fsipc>
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 2c                	js     8017fa <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ce:	83 ec 08             	sub    $0x8,%esp
  8017d1:	68 00 50 80 00       	push   $0x805000
  8017d6:	53                   	push   %ebx
  8017d7:	e8 50 f3 ff ff       	call   800b2c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017dc:	a1 80 50 80 00       	mov    0x805080,%eax
  8017e1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e7:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ec:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	53                   	push   %ebx
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801809:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80180e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801813:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801816:	53                   	push   %ebx
  801817:	ff 75 0c             	pushl  0xc(%ebp)
  80181a:	68 08 50 80 00       	push   $0x805008
  80181f:	e8 9a f4 ff ff       	call   800cbe <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 40 0c             	mov    0xc(%eax),%eax
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  80182f:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 04 00 00 00       	mov    $0x4,%eax
  80183f:	e8 cb fe ff ff       	call   80170f <fsipc>
	//panic("devfile_write not implemented");
}
  801844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	8b 40 0c             	mov    0xc(%eax),%eax
  801857:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80185c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801862:	ba 00 00 00 00       	mov    $0x0,%edx
  801867:	b8 03 00 00 00       	mov    $0x3,%eax
  80186c:	e8 9e fe ff ff       	call   80170f <fsipc>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	85 c0                	test   %eax,%eax
  801875:	78 4b                	js     8018c2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801877:	39 c6                	cmp    %eax,%esi
  801879:	73 16                	jae    801891 <devfile_read+0x48>
  80187b:	68 9c 2b 80 00       	push   $0x802b9c
  801880:	68 a3 2b 80 00       	push   $0x802ba3
  801885:	6a 7c                	push   $0x7c
  801887:	68 b8 2b 80 00       	push   $0x802bb8
  80188c:	e8 24 0a 00 00       	call   8022b5 <_panic>
	assert(r <= PGSIZE);
  801891:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801896:	7e 16                	jle    8018ae <devfile_read+0x65>
  801898:	68 c3 2b 80 00       	push   $0x802bc3
  80189d:	68 a3 2b 80 00       	push   $0x802ba3
  8018a2:	6a 7d                	push   $0x7d
  8018a4:	68 b8 2b 80 00       	push   $0x802bb8
  8018a9:	e8 07 0a 00 00       	call   8022b5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	50                   	push   %eax
  8018b2:	68 00 50 80 00       	push   $0x805000
  8018b7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ba:	e8 ff f3 ff ff       	call   800cbe <memmove>
	return r;
  8018bf:	83 c4 10             	add    $0x10,%esp
}
  8018c2:	89 d8                	mov    %ebx,%eax
  8018c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	53                   	push   %ebx
  8018cf:	83 ec 20             	sub    $0x20,%esp
  8018d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d5:	53                   	push   %ebx
  8018d6:	e8 18 f2 ff ff       	call   800af3 <strlen>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e3:	7f 67                	jg     80194c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018eb:	50                   	push   %eax
  8018ec:	e8 96 f8 ff ff       	call   801187 <fd_alloc>
  8018f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 57                	js     801951 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	53                   	push   %ebx
  8018fe:	68 00 50 80 00       	push   $0x805000
  801903:	e8 24 f2 ff ff       	call   800b2c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801910:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801913:	b8 01 00 00 00       	mov    $0x1,%eax
  801918:	e8 f2 fd ff ff       	call   80170f <fsipc>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	85 c0                	test   %eax,%eax
  801924:	79 14                	jns    80193a <open+0x6f>
		fd_close(fd, 0);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	6a 00                	push   $0x0
  80192b:	ff 75 f4             	pushl  -0xc(%ebp)
  80192e:	e8 4c f9 ff ff       	call   80127f <fd_close>
		return r;
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	89 da                	mov    %ebx,%edx
  801938:	eb 17                	jmp    801951 <open+0x86>
	}

	return fd2num(fd);
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	ff 75 f4             	pushl  -0xc(%ebp)
  801940:	e8 1b f8 ff ff       	call   801160 <fd2num>
  801945:	89 c2                	mov    %eax,%edx
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	eb 05                	jmp    801951 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80194c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801951:	89 d0                	mov    %edx,%eax
  801953:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195e:	ba 00 00 00 00       	mov    $0x0,%edx
  801963:	b8 08 00 00 00       	mov    $0x8,%eax
  801968:	e8 a2 fd ff ff       	call   80170f <fsipc>
}
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801975:	68 cf 2b 80 00       	push   $0x802bcf
  80197a:	ff 75 0c             	pushl  0xc(%ebp)
  80197d:	e8 aa f1 ff ff       	call   800b2c <strcpy>
	return 0;
}
  801982:	b8 00 00 00 00       	mov    $0x0,%eax
  801987:	c9                   	leave  
  801988:	c3                   	ret    

00801989 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	53                   	push   %ebx
  80198d:	83 ec 10             	sub    $0x10,%esp
  801990:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801993:	53                   	push   %ebx
  801994:	e8 5c 0a 00 00       	call   8023f5 <pageref>
  801999:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80199c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019a1:	83 f8 01             	cmp    $0x1,%eax
  8019a4:	75 10                	jne    8019b6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	ff 73 0c             	pushl  0xc(%ebx)
  8019ac:	e8 c0 02 00 00       	call   801c71 <nsipc_close>
  8019b1:	89 c2                	mov    %eax,%edx
  8019b3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019b6:	89 d0                	mov    %edx,%eax
  8019b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019c3:	6a 00                	push   $0x0
  8019c5:	ff 75 10             	pushl  0x10(%ebp)
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ce:	ff 70 0c             	pushl  0xc(%eax)
  8019d1:	e8 78 03 00 00       	call   801d4e <nsipc_send>
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019de:	6a 00                	push   $0x0
  8019e0:	ff 75 10             	pushl  0x10(%ebp)
  8019e3:	ff 75 0c             	pushl  0xc(%ebp)
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	ff 70 0c             	pushl  0xc(%eax)
  8019ec:	e8 f1 02 00 00       	call   801ce2 <nsipc_recv>
}
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019f9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019fc:	52                   	push   %edx
  8019fd:	50                   	push   %eax
  8019fe:	e8 d3 f7 ff ff       	call   8011d6 <fd_lookup>
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 17                	js     801a21 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0d:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801a13:	39 08                	cmp    %ecx,(%eax)
  801a15:	75 05                	jne    801a1c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a17:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1a:	eb 05                	jmp    801a21 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a1c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	83 ec 1c             	sub    $0x1c,%esp
  801a2b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a30:	50                   	push   %eax
  801a31:	e8 51 f7 ff ff       	call   801187 <fd_alloc>
  801a36:	89 c3                	mov    %eax,%ebx
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	78 1b                	js     801a5a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	68 07 04 00 00       	push   $0x407
  801a47:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4a:	6a 00                	push   $0x0
  801a4c:	e8 de f4 ff ff       	call   800f2f <sys_page_alloc>
  801a51:	89 c3                	mov    %eax,%ebx
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	85 c0                	test   %eax,%eax
  801a58:	79 10                	jns    801a6a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	56                   	push   %esi
  801a5e:	e8 0e 02 00 00       	call   801c71 <nsipc_close>
		return r;
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	89 d8                	mov    %ebx,%eax
  801a68:	eb 24                	jmp    801a8e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a6a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a73:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a78:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a7f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	50                   	push   %eax
  801a86:	e8 d5 f6 ff ff       	call   801160 <fd2num>
  801a8b:	83 c4 10             	add    $0x10,%esp
}
  801a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9e:	e8 50 ff ff ff       	call   8019f3 <fd2sockid>
		return r;
  801aa3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 1f                	js     801ac8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aa9:	83 ec 04             	sub    $0x4,%esp
  801aac:	ff 75 10             	pushl  0x10(%ebp)
  801aaf:	ff 75 0c             	pushl  0xc(%ebp)
  801ab2:	50                   	push   %eax
  801ab3:	e8 12 01 00 00       	call   801bca <nsipc_accept>
  801ab8:	83 c4 10             	add    $0x10,%esp
		return r;
  801abb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 07                	js     801ac8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ac1:	e8 5d ff ff ff       	call   801a23 <alloc_sockfd>
  801ac6:	89 c1                	mov    %eax,%ecx
}
  801ac8:	89 c8                	mov    %ecx,%eax
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad5:	e8 19 ff ff ff       	call   8019f3 <fd2sockid>
  801ada:	85 c0                	test   %eax,%eax
  801adc:	78 12                	js     801af0 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ade:	83 ec 04             	sub    $0x4,%esp
  801ae1:	ff 75 10             	pushl  0x10(%ebp)
  801ae4:	ff 75 0c             	pushl  0xc(%ebp)
  801ae7:	50                   	push   %eax
  801ae8:	e8 2d 01 00 00       	call   801c1a <nsipc_bind>
  801aed:	83 c4 10             	add    $0x10,%esp
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <shutdown>:

int
shutdown(int s, int how)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	e8 f3 fe ff ff       	call   8019f3 <fd2sockid>
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 0f                	js     801b13 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b04:	83 ec 08             	sub    $0x8,%esp
  801b07:	ff 75 0c             	pushl  0xc(%ebp)
  801b0a:	50                   	push   %eax
  801b0b:	e8 3f 01 00 00       	call   801c4f <nsipc_shutdown>
  801b10:	83 c4 10             	add    $0x10,%esp
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	e8 d0 fe ff ff       	call   8019f3 <fd2sockid>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	78 12                	js     801b39 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b27:	83 ec 04             	sub    $0x4,%esp
  801b2a:	ff 75 10             	pushl  0x10(%ebp)
  801b2d:	ff 75 0c             	pushl  0xc(%ebp)
  801b30:	50                   	push   %eax
  801b31:	e8 55 01 00 00       	call   801c8b <nsipc_connect>
  801b36:	83 c4 10             	add    $0x10,%esp
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <listen>:

int
listen(int s, int backlog)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b41:	8b 45 08             	mov    0x8(%ebp),%eax
  801b44:	e8 aa fe ff ff       	call   8019f3 <fd2sockid>
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 0f                	js     801b5c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b4d:	83 ec 08             	sub    $0x8,%esp
  801b50:	ff 75 0c             	pushl  0xc(%ebp)
  801b53:	50                   	push   %eax
  801b54:	e8 67 01 00 00       	call   801cc0 <nsipc_listen>
  801b59:	83 c4 10             	add    $0x10,%esp
}
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b64:	ff 75 10             	pushl  0x10(%ebp)
  801b67:	ff 75 0c             	pushl  0xc(%ebp)
  801b6a:	ff 75 08             	pushl  0x8(%ebp)
  801b6d:	e8 3a 02 00 00       	call   801dac <nsipc_socket>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 05                	js     801b7e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b79:	e8 a5 fe ff ff       	call   801a23 <alloc_sockfd>
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	53                   	push   %ebx
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b89:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801b90:	75 12                	jne    801ba4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	6a 02                	push   $0x2
  801b97:	e8 20 08 00 00       	call   8023bc <ipc_find_env>
  801b9c:	a3 14 40 80 00       	mov    %eax,0x804014
  801ba1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ba4:	6a 07                	push   $0x7
  801ba6:	68 00 60 80 00       	push   $0x806000
  801bab:	53                   	push   %ebx
  801bac:	ff 35 14 40 80 00    	pushl  0x804014
  801bb2:	e8 b1 07 00 00       	call   802368 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bb7:	83 c4 0c             	add    $0xc,%esp
  801bba:	6a 00                	push   $0x0
  801bbc:	6a 00                	push   $0x0
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 36 07 00 00       	call   8022fb <ipc_recv>
}
  801bc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bda:	8b 06                	mov    (%esi),%eax
  801bdc:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	e8 95 ff ff ff       	call   801b80 <nsipc>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 20                	js     801c11 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bf1:	83 ec 04             	sub    $0x4,%esp
  801bf4:	ff 35 10 60 80 00    	pushl  0x806010
  801bfa:	68 00 60 80 00       	push   $0x806000
  801bff:	ff 75 0c             	pushl  0xc(%ebp)
  801c02:	e8 b7 f0 ff ff       	call   800cbe <memmove>
		*addrlen = ret->ret_addrlen;
  801c07:	a1 10 60 80 00       	mov    0x806010,%eax
  801c0c:	89 06                	mov    %eax,(%esi)
  801c0e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c11:	89 d8                	mov    %ebx,%eax
  801c13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	53                   	push   %ebx
  801c1e:	83 ec 08             	sub    $0x8,%esp
  801c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c2c:	53                   	push   %ebx
  801c2d:	ff 75 0c             	pushl  0xc(%ebp)
  801c30:	68 04 60 80 00       	push   $0x806004
  801c35:	e8 84 f0 ff ff       	call   800cbe <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c3a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c40:	b8 02 00 00 00       	mov    $0x2,%eax
  801c45:	e8 36 ff ff ff       	call   801b80 <nsipc>
}
  801c4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c60:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c65:	b8 03 00 00 00       	mov    $0x3,%eax
  801c6a:	e8 11 ff ff ff       	call   801b80 <nsipc>
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <nsipc_close>:

int
nsipc_close(int s)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c7f:	b8 04 00 00 00       	mov    $0x4,%eax
  801c84:	e8 f7 fe ff ff       	call   801b80 <nsipc>
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	53                   	push   %ebx
  801c8f:	83 ec 08             	sub    $0x8,%esp
  801c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c9d:	53                   	push   %ebx
  801c9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ca1:	68 04 60 80 00       	push   $0x806004
  801ca6:	e8 13 f0 ff ff       	call   800cbe <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cab:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cb1:	b8 05 00 00 00       	mov    $0x5,%eax
  801cb6:	e8 c5 fe ff ff       	call   801b80 <nsipc>
}
  801cbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cd6:	b8 06 00 00 00       	mov    $0x6,%eax
  801cdb:	e8 a0 fe ff ff       	call   801b80 <nsipc>
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	56                   	push   %esi
  801ce6:	53                   	push   %ebx
  801ce7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cf2:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cf8:	8b 45 14             	mov    0x14(%ebp),%eax
  801cfb:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d00:	b8 07 00 00 00       	mov    $0x7,%eax
  801d05:	e8 76 fe ff ff       	call   801b80 <nsipc>
  801d0a:	89 c3                	mov    %eax,%ebx
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 35                	js     801d45 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d10:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d15:	7f 04                	jg     801d1b <nsipc_recv+0x39>
  801d17:	39 c6                	cmp    %eax,%esi
  801d19:	7d 16                	jge    801d31 <nsipc_recv+0x4f>
  801d1b:	68 db 2b 80 00       	push   $0x802bdb
  801d20:	68 a3 2b 80 00       	push   $0x802ba3
  801d25:	6a 62                	push   $0x62
  801d27:	68 f0 2b 80 00       	push   $0x802bf0
  801d2c:	e8 84 05 00 00       	call   8022b5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d31:	83 ec 04             	sub    $0x4,%esp
  801d34:	50                   	push   %eax
  801d35:	68 00 60 80 00       	push   $0x806000
  801d3a:	ff 75 0c             	pushl  0xc(%ebp)
  801d3d:	e8 7c ef ff ff       	call   800cbe <memmove>
  801d42:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d45:	89 d8                	mov    %ebx,%eax
  801d47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	53                   	push   %ebx
  801d52:	83 ec 04             	sub    $0x4,%esp
  801d55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d60:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d66:	7e 16                	jle    801d7e <nsipc_send+0x30>
  801d68:	68 fc 2b 80 00       	push   $0x802bfc
  801d6d:	68 a3 2b 80 00       	push   $0x802ba3
  801d72:	6a 6d                	push   $0x6d
  801d74:	68 f0 2b 80 00       	push   $0x802bf0
  801d79:	e8 37 05 00 00       	call   8022b5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d7e:	83 ec 04             	sub    $0x4,%esp
  801d81:	53                   	push   %ebx
  801d82:	ff 75 0c             	pushl  0xc(%ebp)
  801d85:	68 0c 60 80 00       	push   $0x80600c
  801d8a:	e8 2f ef ff ff       	call   800cbe <memmove>
	nsipcbuf.send.req_size = size;
  801d8f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d95:	8b 45 14             	mov    0x14(%ebp),%eax
  801d98:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d9d:	b8 08 00 00 00       	mov    $0x8,%eax
  801da2:	e8 d9 fd ff ff       	call   801b80 <nsipc>
}
  801da7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbd:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dca:	b8 09 00 00 00       	mov    $0x9,%eax
  801dcf:	e8 ac fd ff ff       	call   801b80 <nsipc>
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	ff 75 08             	pushl  0x8(%ebp)
  801de4:	e8 87 f3 ff ff       	call   801170 <fd2data>
  801de9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801deb:	83 c4 08             	add    $0x8,%esp
  801dee:	68 08 2c 80 00       	push   $0x802c08
  801df3:	53                   	push   %ebx
  801df4:	e8 33 ed ff ff       	call   800b2c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801df9:	8b 46 04             	mov    0x4(%esi),%eax
  801dfc:	2b 06                	sub    (%esi),%eax
  801dfe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e04:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e0b:	00 00 00 
	stat->st_dev = &devpipe;
  801e0e:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801e15:	30 80 00 
	return 0;
}
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e20:	5b                   	pop    %ebx
  801e21:	5e                   	pop    %esi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    

00801e24 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	53                   	push   %ebx
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e2e:	53                   	push   %ebx
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 7e f1 ff ff       	call   800fb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e36:	89 1c 24             	mov    %ebx,(%esp)
  801e39:	e8 32 f3 ff ff       	call   801170 <fd2data>
  801e3e:	83 c4 08             	add    $0x8,%esp
  801e41:	50                   	push   %eax
  801e42:	6a 00                	push   $0x0
  801e44:	e8 6b f1 ff ff       	call   800fb4 <sys_page_unmap>
}
  801e49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
  801e57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e5a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e5c:	a1 18 40 80 00       	mov    0x804018,%eax
  801e61:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	ff 75 e0             	pushl  -0x20(%ebp)
  801e6a:	e8 86 05 00 00       	call   8023f5 <pageref>
  801e6f:	89 c3                	mov    %eax,%ebx
  801e71:	89 3c 24             	mov    %edi,(%esp)
  801e74:	e8 7c 05 00 00       	call   8023f5 <pageref>
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	39 c3                	cmp    %eax,%ebx
  801e7e:	0f 94 c1             	sete   %cl
  801e81:	0f b6 c9             	movzbl %cl,%ecx
  801e84:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e87:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801e8d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e90:	39 ce                	cmp    %ecx,%esi
  801e92:	74 1b                	je     801eaf <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e94:	39 c3                	cmp    %eax,%ebx
  801e96:	75 c4                	jne    801e5c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e98:	8b 42 58             	mov    0x58(%edx),%eax
  801e9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e9e:	50                   	push   %eax
  801e9f:	56                   	push   %esi
  801ea0:	68 0f 2c 80 00       	push   $0x802c0f
  801ea5:	e8 fd e6 ff ff       	call   8005a7 <cprintf>
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	eb ad                	jmp    801e5c <_pipeisclosed+0xe>
	}
}
  801eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5f                   	pop    %edi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	57                   	push   %edi
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	83 ec 28             	sub    $0x28,%esp
  801ec3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ec6:	56                   	push   %esi
  801ec7:	e8 a4 f2 ff ff       	call   801170 <fd2data>
  801ecc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	bf 00 00 00 00       	mov    $0x0,%edi
  801ed6:	eb 4b                	jmp    801f23 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ed8:	89 da                	mov    %ebx,%edx
  801eda:	89 f0                	mov    %esi,%eax
  801edc:	e8 6d ff ff ff       	call   801e4e <_pipeisclosed>
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	75 48                	jne    801f2d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ee5:	e8 26 f0 ff ff       	call   800f10 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eea:	8b 43 04             	mov    0x4(%ebx),%eax
  801eed:	8b 0b                	mov    (%ebx),%ecx
  801eef:	8d 51 20             	lea    0x20(%ecx),%edx
  801ef2:	39 d0                	cmp    %edx,%eax
  801ef4:	73 e2                	jae    801ed8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801efd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f00:	89 c2                	mov    %eax,%edx
  801f02:	c1 fa 1f             	sar    $0x1f,%edx
  801f05:	89 d1                	mov    %edx,%ecx
  801f07:	c1 e9 1b             	shr    $0x1b,%ecx
  801f0a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f0d:	83 e2 1f             	and    $0x1f,%edx
  801f10:	29 ca                	sub    %ecx,%edx
  801f12:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f16:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f1a:	83 c0 01             	add    $0x1,%eax
  801f1d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f20:	83 c7 01             	add    $0x1,%edi
  801f23:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f26:	75 c2                	jne    801eea <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f28:	8b 45 10             	mov    0x10(%ebp),%eax
  801f2b:	eb 05                	jmp    801f32 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f2d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	57                   	push   %edi
  801f3e:	56                   	push   %esi
  801f3f:	53                   	push   %ebx
  801f40:	83 ec 18             	sub    $0x18,%esp
  801f43:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f46:	57                   	push   %edi
  801f47:	e8 24 f2 ff ff       	call   801170 <fd2data>
  801f4c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f56:	eb 3d                	jmp    801f95 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f58:	85 db                	test   %ebx,%ebx
  801f5a:	74 04                	je     801f60 <devpipe_read+0x26>
				return i;
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	eb 44                	jmp    801fa4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f60:	89 f2                	mov    %esi,%edx
  801f62:	89 f8                	mov    %edi,%eax
  801f64:	e8 e5 fe ff ff       	call   801e4e <_pipeisclosed>
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	75 32                	jne    801f9f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f6d:	e8 9e ef ff ff       	call   800f10 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f72:	8b 06                	mov    (%esi),%eax
  801f74:	3b 46 04             	cmp    0x4(%esi),%eax
  801f77:	74 df                	je     801f58 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f79:	99                   	cltd   
  801f7a:	c1 ea 1b             	shr    $0x1b,%edx
  801f7d:	01 d0                	add    %edx,%eax
  801f7f:	83 e0 1f             	and    $0x1f,%eax
  801f82:	29 d0                	sub    %edx,%eax
  801f84:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f8c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f8f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f92:	83 c3 01             	add    $0x1,%ebx
  801f95:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f98:	75 d8                	jne    801f72 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f9a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9d:	eb 05                	jmp    801fa4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	56                   	push   %esi
  801fb0:	53                   	push   %ebx
  801fb1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb7:	50                   	push   %eax
  801fb8:	e8 ca f1 ff ff       	call   801187 <fd_alloc>
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	89 c2                	mov    %eax,%edx
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	0f 88 2c 01 00 00    	js     8020f6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fca:	83 ec 04             	sub    $0x4,%esp
  801fcd:	68 07 04 00 00       	push   $0x407
  801fd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd5:	6a 00                	push   $0x0
  801fd7:	e8 53 ef ff ff       	call   800f2f <sys_page_alloc>
  801fdc:	83 c4 10             	add    $0x10,%esp
  801fdf:	89 c2                	mov    %eax,%edx
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	0f 88 0d 01 00 00    	js     8020f6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fe9:	83 ec 0c             	sub    $0xc,%esp
  801fec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fef:	50                   	push   %eax
  801ff0:	e8 92 f1 ff ff       	call   801187 <fd_alloc>
  801ff5:	89 c3                	mov    %eax,%ebx
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	0f 88 e2 00 00 00    	js     8020e4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802002:	83 ec 04             	sub    $0x4,%esp
  802005:	68 07 04 00 00       	push   $0x407
  80200a:	ff 75 f0             	pushl  -0x10(%ebp)
  80200d:	6a 00                	push   $0x0
  80200f:	e8 1b ef ff ff       	call   800f2f <sys_page_alloc>
  802014:	89 c3                	mov    %eax,%ebx
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	85 c0                	test   %eax,%eax
  80201b:	0f 88 c3 00 00 00    	js     8020e4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	ff 75 f4             	pushl  -0xc(%ebp)
  802027:	e8 44 f1 ff ff       	call   801170 <fd2data>
  80202c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202e:	83 c4 0c             	add    $0xc,%esp
  802031:	68 07 04 00 00       	push   $0x407
  802036:	50                   	push   %eax
  802037:	6a 00                	push   $0x0
  802039:	e8 f1 ee ff ff       	call   800f2f <sys_page_alloc>
  80203e:	89 c3                	mov    %eax,%ebx
  802040:	83 c4 10             	add    $0x10,%esp
  802043:	85 c0                	test   %eax,%eax
  802045:	0f 88 89 00 00 00    	js     8020d4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204b:	83 ec 0c             	sub    $0xc,%esp
  80204e:	ff 75 f0             	pushl  -0x10(%ebp)
  802051:	e8 1a f1 ff ff       	call   801170 <fd2data>
  802056:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80205d:	50                   	push   %eax
  80205e:	6a 00                	push   $0x0
  802060:	56                   	push   %esi
  802061:	6a 00                	push   $0x0
  802063:	e8 0a ef ff ff       	call   800f72 <sys_page_map>
  802068:	89 c3                	mov    %eax,%ebx
  80206a:	83 c4 20             	add    $0x20,%esp
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 55                	js     8020c6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802071:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802077:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80207c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802086:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80208c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80208f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802091:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802094:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80209b:	83 ec 0c             	sub    $0xc,%esp
  80209e:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a1:	e8 ba f0 ff ff       	call   801160 <fd2num>
  8020a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020a9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020ab:	83 c4 04             	add    $0x4,%esp
  8020ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b1:	e8 aa f0 ff ff       	call   801160 <fd2num>
  8020b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020bc:	83 c4 10             	add    $0x10,%esp
  8020bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8020c4:	eb 30                	jmp    8020f6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020c6:	83 ec 08             	sub    $0x8,%esp
  8020c9:	56                   	push   %esi
  8020ca:	6a 00                	push   $0x0
  8020cc:	e8 e3 ee ff ff       	call   800fb4 <sys_page_unmap>
  8020d1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020d4:	83 ec 08             	sub    $0x8,%esp
  8020d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8020da:	6a 00                	push   $0x0
  8020dc:	e8 d3 ee ff ff       	call   800fb4 <sys_page_unmap>
  8020e1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020e4:	83 ec 08             	sub    $0x8,%esp
  8020e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ea:	6a 00                	push   $0x0
  8020ec:	e8 c3 ee ff ff       	call   800fb4 <sys_page_unmap>
  8020f1:	83 c4 10             	add    $0x10,%esp
  8020f4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fb:	5b                   	pop    %ebx
  8020fc:	5e                   	pop    %esi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802105:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802108:	50                   	push   %eax
  802109:	ff 75 08             	pushl  0x8(%ebp)
  80210c:	e8 c5 f0 ff ff       	call   8011d6 <fd_lookup>
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	85 c0                	test   %eax,%eax
  802116:	78 18                	js     802130 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802118:	83 ec 0c             	sub    $0xc,%esp
  80211b:	ff 75 f4             	pushl  -0xc(%ebp)
  80211e:	e8 4d f0 ff ff       	call   801170 <fd2data>
	return _pipeisclosed(fd, p);
  802123:	89 c2                	mov    %eax,%edx
  802125:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802128:	e8 21 fd ff ff       	call   801e4e <_pipeisclosed>
  80212d:	83 c4 10             	add    $0x10,%esp
}
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802135:	b8 00 00 00 00       	mov    $0x0,%eax
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    

0080213c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802142:	68 27 2c 80 00       	push   $0x802c27
  802147:	ff 75 0c             	pushl  0xc(%ebp)
  80214a:	e8 dd e9 ff ff       	call   800b2c <strcpy>
	return 0;
}
  80214f:	b8 00 00 00 00       	mov    $0x0,%eax
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	57                   	push   %edi
  80215a:	56                   	push   %esi
  80215b:	53                   	push   %ebx
  80215c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802162:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802167:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80216d:	eb 2d                	jmp    80219c <devcons_write+0x46>
		m = n - tot;
  80216f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802172:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802174:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802177:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80217c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217f:	83 ec 04             	sub    $0x4,%esp
  802182:	53                   	push   %ebx
  802183:	03 45 0c             	add    0xc(%ebp),%eax
  802186:	50                   	push   %eax
  802187:	57                   	push   %edi
  802188:	e8 31 eb ff ff       	call   800cbe <memmove>
		sys_cputs(buf, m);
  80218d:	83 c4 08             	add    $0x8,%esp
  802190:	53                   	push   %ebx
  802191:	57                   	push   %edi
  802192:	e8 dc ec ff ff       	call   800e73 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802197:	01 de                	add    %ebx,%esi
  802199:	83 c4 10             	add    $0x10,%esp
  80219c:	89 f0                	mov    %esi,%eax
  80219e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021a1:	72 cc                	jb     80216f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a6:	5b                   	pop    %ebx
  8021a7:	5e                   	pop    %esi
  8021a8:	5f                   	pop    %edi
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    

008021ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	83 ec 08             	sub    $0x8,%esp
  8021b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021ba:	74 2a                	je     8021e6 <devcons_read+0x3b>
  8021bc:	eb 05                	jmp    8021c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021be:	e8 4d ed ff ff       	call   800f10 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021c3:	e8 c9 ec ff ff       	call   800e91 <sys_cgetc>
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	74 f2                	je     8021be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	78 16                	js     8021e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021d0:	83 f8 04             	cmp    $0x4,%eax
  8021d3:	74 0c                	je     8021e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d8:	88 02                	mov    %al,(%edx)
	return 1;
  8021da:	b8 01 00 00 00       	mov    $0x1,%eax
  8021df:	eb 05                	jmp    8021e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021e6:	c9                   	leave  
  8021e7:	c3                   	ret    

008021e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021f4:	6a 01                	push   $0x1
  8021f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021f9:	50                   	push   %eax
  8021fa:	e8 74 ec ff ff       	call   800e73 <sys_cputs>
}
  8021ff:	83 c4 10             	add    $0x10,%esp
  802202:	c9                   	leave  
  802203:	c3                   	ret    

00802204 <getchar>:

int
getchar(void)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80220a:	6a 01                	push   $0x1
  80220c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80220f:	50                   	push   %eax
  802210:	6a 00                	push   $0x0
  802212:	e8 25 f2 ff ff       	call   80143c <read>
	if (r < 0)
  802217:	83 c4 10             	add    $0x10,%esp
  80221a:	85 c0                	test   %eax,%eax
  80221c:	78 0f                	js     80222d <getchar+0x29>
		return r;
	if (r < 1)
  80221e:	85 c0                	test   %eax,%eax
  802220:	7e 06                	jle    802228 <getchar+0x24>
		return -E_EOF;
	return c;
  802222:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802226:	eb 05                	jmp    80222d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802228:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80222d:	c9                   	leave  
  80222e:	c3                   	ret    

0080222f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802235:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802238:	50                   	push   %eax
  802239:	ff 75 08             	pushl  0x8(%ebp)
  80223c:	e8 95 ef ff ff       	call   8011d6 <fd_lookup>
  802241:	83 c4 10             	add    $0x10,%esp
  802244:	85 c0                	test   %eax,%eax
  802246:	78 11                	js     802259 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802248:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224b:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802251:	39 10                	cmp    %edx,(%eax)
  802253:	0f 94 c0             	sete   %al
  802256:	0f b6 c0             	movzbl %al,%eax
}
  802259:	c9                   	leave  
  80225a:	c3                   	ret    

0080225b <opencons>:

int
opencons(void)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802264:	50                   	push   %eax
  802265:	e8 1d ef ff ff       	call   801187 <fd_alloc>
  80226a:	83 c4 10             	add    $0x10,%esp
		return r;
  80226d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 3e                	js     8022b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802273:	83 ec 04             	sub    $0x4,%esp
  802276:	68 07 04 00 00       	push   $0x407
  80227b:	ff 75 f4             	pushl  -0xc(%ebp)
  80227e:	6a 00                	push   $0x0
  802280:	e8 aa ec ff ff       	call   800f2f <sys_page_alloc>
  802285:	83 c4 10             	add    $0x10,%esp
		return r;
  802288:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80228a:	85 c0                	test   %eax,%eax
  80228c:	78 23                	js     8022b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80228e:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802294:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802297:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802299:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022a3:	83 ec 0c             	sub    $0xc,%esp
  8022a6:	50                   	push   %eax
  8022a7:	e8 b4 ee ff ff       	call   801160 <fd2num>
  8022ac:	89 c2                	mov    %eax,%edx
  8022ae:	83 c4 10             	add    $0x10,%esp
}
  8022b1:	89 d0                	mov    %edx,%eax
  8022b3:	c9                   	leave  
  8022b4:	c3                   	ret    

008022b5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	56                   	push   %esi
  8022b9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022ba:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022bd:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8022c3:	e8 29 ec ff ff       	call   800ef1 <sys_getenvid>
  8022c8:	83 ec 0c             	sub    $0xc,%esp
  8022cb:	ff 75 0c             	pushl  0xc(%ebp)
  8022ce:	ff 75 08             	pushl  0x8(%ebp)
  8022d1:	56                   	push   %esi
  8022d2:	50                   	push   %eax
  8022d3:	68 34 2c 80 00       	push   $0x802c34
  8022d8:	e8 ca e2 ff ff       	call   8005a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022dd:	83 c4 18             	add    $0x18,%esp
  8022e0:	53                   	push   %ebx
  8022e1:	ff 75 10             	pushl  0x10(%ebp)
  8022e4:	e8 6d e2 ff ff       	call   800556 <vcprintf>
	cprintf("\n");
  8022e9:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  8022f0:	e8 b2 e2 ff ff       	call   8005a7 <cprintf>
  8022f5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022f8:	cc                   	int3   
  8022f9:	eb fd                	jmp    8022f8 <_panic+0x43>

008022fb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	56                   	push   %esi
  8022ff:	53                   	push   %ebx
  802300:	8b 75 08             	mov    0x8(%ebp),%esi
  802303:	8b 45 0c             	mov    0xc(%ebp),%eax
  802306:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802309:	85 c0                	test   %eax,%eax
  80230b:	74 0e                	je     80231b <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  80230d:	83 ec 0c             	sub    $0xc,%esp
  802310:	50                   	push   %eax
  802311:	e8 c9 ed ff ff       	call   8010df <sys_ipc_recv>
  802316:	83 c4 10             	add    $0x10,%esp
  802319:	eb 10                	jmp    80232b <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80231b:	83 ec 0c             	sub    $0xc,%esp
  80231e:	68 00 00 00 f0       	push   $0xf0000000
  802323:	e8 b7 ed ff ff       	call   8010df <sys_ipc_recv>
  802328:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80232b:	85 c0                	test   %eax,%eax
  80232d:	74 0e                	je     80233d <ipc_recv+0x42>
    	*from_env_store = 0;
  80232f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802335:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  80233b:	eb 24                	jmp    802361 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  80233d:	85 f6                	test   %esi,%esi
  80233f:	74 0a                	je     80234b <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802341:	a1 18 40 80 00       	mov    0x804018,%eax
  802346:	8b 40 74             	mov    0x74(%eax),%eax
  802349:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  80234b:	85 db                	test   %ebx,%ebx
  80234d:	74 0a                	je     802359 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  80234f:	a1 18 40 80 00       	mov    0x804018,%eax
  802354:	8b 40 78             	mov    0x78(%eax),%eax
  802357:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802359:	a1 18 40 80 00       	mov    0x804018,%eax
  80235e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802361:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    

00802368 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802368:	55                   	push   %ebp
  802369:	89 e5                	mov    %esp,%ebp
  80236b:	57                   	push   %edi
  80236c:	56                   	push   %esi
  80236d:	53                   	push   %ebx
  80236e:	83 ec 0c             	sub    $0xc,%esp
  802371:	8b 7d 08             	mov    0x8(%ebp),%edi
  802374:	8b 75 0c             	mov    0xc(%ebp),%esi
  802377:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  80237a:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  80237c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802381:	0f 44 d8             	cmove  %eax,%ebx
  802384:	eb 1c                	jmp    8023a2 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802386:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802389:	74 12                	je     80239d <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  80238b:	50                   	push   %eax
  80238c:	68 58 2c 80 00       	push   $0x802c58
  802391:	6a 4b                	push   $0x4b
  802393:	68 70 2c 80 00       	push   $0x802c70
  802398:	e8 18 ff ff ff       	call   8022b5 <_panic>
        }	
        sys_yield();
  80239d:	e8 6e eb ff ff       	call   800f10 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8023a2:	ff 75 14             	pushl  0x14(%ebp)
  8023a5:	53                   	push   %ebx
  8023a6:	56                   	push   %esi
  8023a7:	57                   	push   %edi
  8023a8:	e8 0f ed ff ff       	call   8010bc <sys_ipc_try_send>
  8023ad:	83 c4 10             	add    $0x10,%esp
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	75 d2                	jne    802386 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8023b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    

008023bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023bc:	55                   	push   %ebp
  8023bd:	89 e5                	mov    %esp,%ebp
  8023bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023c7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023d0:	8b 52 50             	mov    0x50(%edx),%edx
  8023d3:	39 ca                	cmp    %ecx,%edx
  8023d5:	75 0d                	jne    8023e4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8023d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023df:	8b 40 48             	mov    0x48(%eax),%eax
  8023e2:	eb 0f                	jmp    8023f3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023e4:	83 c0 01             	add    $0x1,%eax
  8023e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023ec:	75 d9                	jne    8023c7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    

008023f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023f5:	55                   	push   %ebp
  8023f6:	89 e5                	mov    %esp,%ebp
  8023f8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023fb:	89 d0                	mov    %edx,%eax
  8023fd:	c1 e8 16             	shr    $0x16,%eax
  802400:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802407:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80240c:	f6 c1 01             	test   $0x1,%cl
  80240f:	74 1d                	je     80242e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802411:	c1 ea 0c             	shr    $0xc,%edx
  802414:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80241b:	f6 c2 01             	test   $0x1,%dl
  80241e:	74 0e                	je     80242e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802420:	c1 ea 0c             	shr    $0xc,%edx
  802423:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80242a:	ef 
  80242b:	0f b7 c0             	movzwl %ax,%eax
}
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    

00802430 <__udivdi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80243b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80243f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 f6                	test   %esi,%esi
  802449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80244d:	89 ca                	mov    %ecx,%edx
  80244f:	89 f8                	mov    %edi,%eax
  802451:	75 3d                	jne    802490 <__udivdi3+0x60>
  802453:	39 cf                	cmp    %ecx,%edi
  802455:	0f 87 c5 00 00 00    	ja     802520 <__udivdi3+0xf0>
  80245b:	85 ff                	test   %edi,%edi
  80245d:	89 fd                	mov    %edi,%ebp
  80245f:	75 0b                	jne    80246c <__udivdi3+0x3c>
  802461:	b8 01 00 00 00       	mov    $0x1,%eax
  802466:	31 d2                	xor    %edx,%edx
  802468:	f7 f7                	div    %edi
  80246a:	89 c5                	mov    %eax,%ebp
  80246c:	89 c8                	mov    %ecx,%eax
  80246e:	31 d2                	xor    %edx,%edx
  802470:	f7 f5                	div    %ebp
  802472:	89 c1                	mov    %eax,%ecx
  802474:	89 d8                	mov    %ebx,%eax
  802476:	89 cf                	mov    %ecx,%edi
  802478:	f7 f5                	div    %ebp
  80247a:	89 c3                	mov    %eax,%ebx
  80247c:	89 d8                	mov    %ebx,%eax
  80247e:	89 fa                	mov    %edi,%edx
  802480:	83 c4 1c             	add    $0x1c,%esp
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	90                   	nop
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	39 ce                	cmp    %ecx,%esi
  802492:	77 74                	ja     802508 <__udivdi3+0xd8>
  802494:	0f bd fe             	bsr    %esi,%edi
  802497:	83 f7 1f             	xor    $0x1f,%edi
  80249a:	0f 84 98 00 00 00    	je     802538 <__udivdi3+0x108>
  8024a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	89 c5                	mov    %eax,%ebp
  8024a9:	29 fb                	sub    %edi,%ebx
  8024ab:	d3 e6                	shl    %cl,%esi
  8024ad:	89 d9                	mov    %ebx,%ecx
  8024af:	d3 ed                	shr    %cl,%ebp
  8024b1:	89 f9                	mov    %edi,%ecx
  8024b3:	d3 e0                	shl    %cl,%eax
  8024b5:	09 ee                	or     %ebp,%esi
  8024b7:	89 d9                	mov    %ebx,%ecx
  8024b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024bd:	89 d5                	mov    %edx,%ebp
  8024bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024c3:	d3 ed                	shr    %cl,%ebp
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e2                	shl    %cl,%edx
  8024c9:	89 d9                	mov    %ebx,%ecx
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	09 c2                	or     %eax,%edx
  8024cf:	89 d0                	mov    %edx,%eax
  8024d1:	89 ea                	mov    %ebp,%edx
  8024d3:	f7 f6                	div    %esi
  8024d5:	89 d5                	mov    %edx,%ebp
  8024d7:	89 c3                	mov    %eax,%ebx
  8024d9:	f7 64 24 0c          	mull   0xc(%esp)
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	72 10                	jb     8024f1 <__udivdi3+0xc1>
  8024e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e6                	shl    %cl,%esi
  8024e9:	39 c6                	cmp    %eax,%esi
  8024eb:	73 07                	jae    8024f4 <__udivdi3+0xc4>
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	75 03                	jne    8024f4 <__udivdi3+0xc4>
  8024f1:	83 eb 01             	sub    $0x1,%ebx
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 d8                	mov    %ebx,%eax
  8024f8:	89 fa                	mov    %edi,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	31 ff                	xor    %edi,%edi
  80250a:	31 db                	xor    %ebx,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d8                	mov    %ebx,%eax
  802522:	f7 f7                	div    %edi
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 c3                	mov    %eax,%ebx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 fa                	mov    %edi,%edx
  80252c:	83 c4 1c             	add    $0x1c,%esp
  80252f:	5b                   	pop    %ebx
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    
  802534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802538:	39 ce                	cmp    %ecx,%esi
  80253a:	72 0c                	jb     802548 <__udivdi3+0x118>
  80253c:	31 db                	xor    %ebx,%ebx
  80253e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802542:	0f 87 34 ff ff ff    	ja     80247c <__udivdi3+0x4c>
  802548:	bb 01 00 00 00       	mov    $0x1,%ebx
  80254d:	e9 2a ff ff ff       	jmp    80247c <__udivdi3+0x4c>
  802552:	66 90                	xchg   %ax,%ax
  802554:	66 90                	xchg   %ax,%ax
  802556:	66 90                	xchg   %ax,%ax
  802558:	66 90                	xchg   %ax,%ax
  80255a:	66 90                	xchg   %ax,%ax
  80255c:	66 90                	xchg   %ax,%ax
  80255e:	66 90                	xchg   %ax,%ax

00802560 <__umoddi3>:
  802560:	55                   	push   %ebp
  802561:	57                   	push   %edi
  802562:	56                   	push   %esi
  802563:	53                   	push   %ebx
  802564:	83 ec 1c             	sub    $0x1c,%esp
  802567:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80256b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80256f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802573:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802577:	85 d2                	test   %edx,%edx
  802579:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80257d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802581:	89 f3                	mov    %esi,%ebx
  802583:	89 3c 24             	mov    %edi,(%esp)
  802586:	89 74 24 04          	mov    %esi,0x4(%esp)
  80258a:	75 1c                	jne    8025a8 <__umoddi3+0x48>
  80258c:	39 f7                	cmp    %esi,%edi
  80258e:	76 50                	jbe    8025e0 <__umoddi3+0x80>
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	f7 f7                	div    %edi
  802596:	89 d0                	mov    %edx,%eax
  802598:	31 d2                	xor    %edx,%edx
  80259a:	83 c4 1c             	add    $0x1c,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	39 f2                	cmp    %esi,%edx
  8025aa:	89 d0                	mov    %edx,%eax
  8025ac:	77 52                	ja     802600 <__umoddi3+0xa0>
  8025ae:	0f bd ea             	bsr    %edx,%ebp
  8025b1:	83 f5 1f             	xor    $0x1f,%ebp
  8025b4:	75 5a                	jne    802610 <__umoddi3+0xb0>
  8025b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ba:	0f 82 e0 00 00 00    	jb     8026a0 <__umoddi3+0x140>
  8025c0:	39 0c 24             	cmp    %ecx,(%esp)
  8025c3:	0f 86 d7 00 00 00    	jbe    8026a0 <__umoddi3+0x140>
  8025c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025d1:	83 c4 1c             	add    $0x1c,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	85 ff                	test   %edi,%edi
  8025e2:	89 fd                	mov    %edi,%ebp
  8025e4:	75 0b                	jne    8025f1 <__umoddi3+0x91>
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	f7 f7                	div    %edi
  8025ef:	89 c5                	mov    %eax,%ebp
  8025f1:	89 f0                	mov    %esi,%eax
  8025f3:	31 d2                	xor    %edx,%edx
  8025f5:	f7 f5                	div    %ebp
  8025f7:	89 c8                	mov    %ecx,%eax
  8025f9:	f7 f5                	div    %ebp
  8025fb:	89 d0                	mov    %edx,%eax
  8025fd:	eb 99                	jmp    802598 <__umoddi3+0x38>
  8025ff:	90                   	nop
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	83 c4 1c             	add    $0x1c,%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5f                   	pop    %edi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    
  80260c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802610:	8b 34 24             	mov    (%esp),%esi
  802613:	bf 20 00 00 00       	mov    $0x20,%edi
  802618:	89 e9                	mov    %ebp,%ecx
  80261a:	29 ef                	sub    %ebp,%edi
  80261c:	d3 e0                	shl    %cl,%eax
  80261e:	89 f9                	mov    %edi,%ecx
  802620:	89 f2                	mov    %esi,%edx
  802622:	d3 ea                	shr    %cl,%edx
  802624:	89 e9                	mov    %ebp,%ecx
  802626:	09 c2                	or     %eax,%edx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 14 24             	mov    %edx,(%esp)
  80262d:	89 f2                	mov    %esi,%edx
  80262f:	d3 e2                	shl    %cl,%edx
  802631:	89 f9                	mov    %edi,%ecx
  802633:	89 54 24 04          	mov    %edx,0x4(%esp)
  802637:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80263b:	d3 e8                	shr    %cl,%eax
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	89 c6                	mov    %eax,%esi
  802641:	d3 e3                	shl    %cl,%ebx
  802643:	89 f9                	mov    %edi,%ecx
  802645:	89 d0                	mov    %edx,%eax
  802647:	d3 e8                	shr    %cl,%eax
  802649:	89 e9                	mov    %ebp,%ecx
  80264b:	09 d8                	or     %ebx,%eax
  80264d:	89 d3                	mov    %edx,%ebx
  80264f:	89 f2                	mov    %esi,%edx
  802651:	f7 34 24             	divl   (%esp)
  802654:	89 d6                	mov    %edx,%esi
  802656:	d3 e3                	shl    %cl,%ebx
  802658:	f7 64 24 04          	mull   0x4(%esp)
  80265c:	39 d6                	cmp    %edx,%esi
  80265e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802662:	89 d1                	mov    %edx,%ecx
  802664:	89 c3                	mov    %eax,%ebx
  802666:	72 08                	jb     802670 <__umoddi3+0x110>
  802668:	75 11                	jne    80267b <__umoddi3+0x11b>
  80266a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80266e:	73 0b                	jae    80267b <__umoddi3+0x11b>
  802670:	2b 44 24 04          	sub    0x4(%esp),%eax
  802674:	1b 14 24             	sbb    (%esp),%edx
  802677:	89 d1                	mov    %edx,%ecx
  802679:	89 c3                	mov    %eax,%ebx
  80267b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80267f:	29 da                	sub    %ebx,%edx
  802681:	19 ce                	sbb    %ecx,%esi
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 f0                	mov    %esi,%eax
  802687:	d3 e0                	shl    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	d3 ea                	shr    %cl,%edx
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	d3 ee                	shr    %cl,%esi
  802691:	09 d0                	or     %edx,%eax
  802693:	89 f2                	mov    %esi,%edx
  802695:	83 c4 1c             	add    $0x1c,%esp
  802698:	5b                   	pop    %ebx
  802699:	5e                   	pop    %esi
  80269a:	5f                   	pop    %edi
  80269b:	5d                   	pop    %ebp
  80269c:	c3                   	ret    
  80269d:	8d 76 00             	lea    0x0(%esi),%esi
  8026a0:	29 f9                	sub    %edi,%ecx
  8026a2:	19 d6                	sbb    %edx,%esi
  8026a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ac:	e9 18 ff ff ff       	jmp    8025c9 <__umoddi3+0x69>
