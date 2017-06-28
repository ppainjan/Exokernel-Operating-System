
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 5b 05 00 00       	call   80058c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 40 2a 80 00       	push   $0x802a40
  80003f:	e8 8b 06 00 00       	call   8006cf <cprintf>
	exit();
  800044:	e8 93 05 00 00       	call   8005dc <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec 20 04 00 00    	sub    $0x420,%esp
  80005a:	89 c3                	mov    %eax,%ebx
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005c:	68 00 02 00 00       	push   $0x200
  800061:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800067:	50                   	push   %eax
  800068:	53                   	push   %ebx
  800069:	e8 f6 14 00 00       	call   801564 <read>
  80006e:	83 c4 10             	add    $0x10,%esp
  800071:	85 c0                	test   %eax,%eax
  800073:	79 17                	jns    80008c <handle_client+0x3e>
			panic("failed to read");
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	68 44 2a 80 00       	push   $0x802a44
  80007d:	68 04 01 00 00       	push   $0x104
  800082:	68 53 2a 80 00       	push   $0x802a53
  800087:	e8 6a 05 00 00       	call   8005f6 <_panic>

		memset(req, 0, sizeof(req));
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 04                	push   $0x4
  800091:	6a 00                	push   $0x0
  800093:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800096:	50                   	push   %eax
  800097:	e8 fd 0c 00 00       	call   800d99 <memset>

		req->sock = sock;
  80009c:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  80009f:	83 c4 0c             	add    $0xc,%esp
  8000a2:	6a 04                	push   $0x4
  8000a4:	68 60 2a 80 00       	push   $0x802a60
  8000a9:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000af:	50                   	push   %eax
  8000b0:	e8 6f 0c 00 00       	call   800d24 <strncmp>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	0f 85 95 00 00 00    	jne    800155 <handle_client+0x107>
  8000c0:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  8000c6:	eb 03                	jmp    8000cb <handle_client+0x7d>
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  8000c8:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  8000cb:	f6 03 df             	testb  $0xdf,(%ebx)
  8000ce:	75 f8                	jne    8000c8 <handle_client+0x7a>
		request++;
	url_len = request - url;
  8000d0:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
  8000d6:	89 de                	mov    %ebx,%esi
  8000d8:	29 fe                	sub    %edi,%esi

	req->url = malloc(url_len + 1);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	8d 46 01             	lea    0x1(%esi),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 c6 1e 00 00       	call   801fac <malloc>
  8000e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  8000e9:	83 c4 0c             	add    $0xc,%esp
  8000ec:	56                   	push   %esi
  8000ed:	57                   	push   %edi
  8000ee:	50                   	push   %eax
  8000ef:	e8 f2 0c 00 00       	call   800de6 <memmove>
	req->url[url_len] = '\0';
  8000f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000f7:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)

	// skip space
	request++;
  8000fb:	8d 73 01             	lea    0x1(%ebx),%esi
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	89 f0                	mov    %esi,%eax
  800103:	eb 03                	jmp    800108 <handle_client+0xba>

	version = request;
	while (*request && *request != '\n')
		request++;
  800105:	83 c0 01             	add    $0x1,%eax

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  800108:	0f b6 10             	movzbl (%eax),%edx
  80010b:	84 d2                	test   %dl,%dl
  80010d:	74 05                	je     800114 <handle_client+0xc6>
  80010f:	80 fa 0a             	cmp    $0xa,%dl
  800112:	75 f1                	jne    800105 <handle_client+0xb7>
		request++;
	version_len = request - version;
  800114:	29 f0                	sub    %esi,%eax
  800116:	89 c3                	mov    %eax,%ebx

	req->version = malloc(version_len + 1);
  800118:	83 ec 0c             	sub    $0xc,%esp
  80011b:	8d 40 01             	lea    0x1(%eax),%eax
  80011e:	50                   	push   %eax
  80011f:	e8 88 1e 00 00       	call   801fac <malloc>
  800124:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  800127:	83 c4 0c             	add    $0xc,%esp
  80012a:	53                   	push   %ebx
  80012b:	56                   	push   %esi
  80012c:	50                   	push   %eax
  80012d:	e8 b4 0c 00 00       	call   800de6 <memmove>
	req->version[version_len] = '\0';
  800132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800135:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
	// if the file does not exist, send a 404 error using send_error
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
	panic("send_file not implemented");
  800139:	83 c4 0c             	add    $0xc,%esp
  80013c:	68 65 2a 80 00       	push   $0x802a65
  800141:	68 e2 00 00 00       	push   $0xe2
  800146:	68 53 2a 80 00       	push   $0x802a53
  80014b:	e8 a6 04 00 00       	call   8005f6 <_panic>

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
		if (e->code == code)
			break;
		e++;
  800150:	83 c0 08             	add    $0x8,%eax
  800153:	eb 05                	jmp    80015a <handle_client+0x10c>
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  800155:	b8 00 40 80 00       	mov    $0x804000,%eax
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  80015a:	8b 10                	mov    (%eax),%edx
  80015c:	85 d2                	test   %edx,%edx
  80015e:	74 3e                	je     80019e <handle_client+0x150>
		if (e->code == code)
  800160:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800164:	74 08                	je     80016e <handle_client+0x120>
  800166:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  80016c:	75 e2                	jne    800150 <handle_client+0x102>
	}

	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  80016e:	8b 40 04             	mov    0x4(%eax),%eax
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	50                   	push   %eax
  800175:	52                   	push   %edx
  800176:	50                   	push   %eax
  800177:	52                   	push   %edx
  800178:	68 b4 2a 80 00       	push   $0x802ab4
  80017d:	68 00 02 00 00       	push   $0x200
  800182:	8d b5 dc fb ff ff    	lea    -0x424(%ebp),%esi
  800188:	56                   	push   %esi
  800189:	e8 73 0a 00 00       	call   800c01 <snprintf>
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  80018e:	83 c4 1c             	add    $0x1c,%esp
  800191:	50                   	push   %eax
  800192:	56                   	push   %esi
  800193:	ff 75 dc             	pushl  -0x24(%ebp)
  800196:	e8 a3 14 00 00       	call   80163e <write>
  80019b:	83 c4 10             	add    $0x10,%esp
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a4:	e8 55 1d 00 00       	call   801efe <free>
	free(req->version);
  8001a9:	83 c4 04             	add    $0x4,%esp
  8001ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001af:	e8 4a 1d 00 00       	call   801efe <free>

		// no keep alive
		break;
	}

	close(sock);
  8001b4:	89 1c 24             	mov    %ebx,(%esp)
  8001b7:	e8 6c 12 00 00       	call   801428 <close>
}
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5e                   	pop    %esi
  8001c4:	5f                   	pop    %edi
  8001c5:	5d                   	pop    %ebp
  8001c6:	c3                   	ret    

008001c7 <umain>:

void
umain(int argc, char **argv)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 40             	sub    $0x40,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  8001d0:	c7 05 20 40 80 00 7f 	movl   $0x802a7f,0x804020
  8001d7:	2a 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8001da:	6a 06                	push   $0x6
  8001dc:	6a 01                	push   $0x1
  8001de:	6a 02                	push   $0x2
  8001e0:	e8 a1 1a 00 00       	call   801c86 <socket>
  8001e5:	89 c6                	mov    %eax,%esi
  8001e7:	83 c4 10             	add    $0x10,%esp
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	79 0a                	jns    8001f8 <umain+0x31>
		die("Failed to create socket");
  8001ee:	b8 86 2a 80 00       	mov    $0x802a86,%eax
  8001f3:	e8 3b fe ff ff       	call   800033 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  8001f8:	83 ec 04             	sub    $0x4,%esp
  8001fb:	6a 10                	push   $0x10
  8001fd:	6a 00                	push   $0x0
  8001ff:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800202:	53                   	push   %ebx
  800203:	e8 91 0b 00 00       	call   800d99 <memset>
	server.sin_family = AF_INET;			// Internet/IP
  800208:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  80020c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800213:	e8 43 01 00 00       	call   80035b <htonl>
  800218:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  80021b:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  800222:	e8 1a 01 00 00       	call   800341 <htons>
  800227:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  80022b:	83 c4 0c             	add    $0xc,%esp
  80022e:	6a 10                	push   $0x10
  800230:	53                   	push   %ebx
  800231:	56                   	push   %esi
  800232:	e8 bd 19 00 00       	call   801bf4 <bind>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	85 c0                	test   %eax,%eax
  80023c:	79 0a                	jns    800248 <umain+0x81>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  80023e:	b8 30 2b 80 00       	mov    $0x802b30,%eax
  800243:	e8 eb fd ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	6a 05                	push   $0x5
  80024d:	56                   	push   %esi
  80024e:	e8 10 1a 00 00       	call   801c63 <listen>
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	85 c0                	test   %eax,%eax
  800258:	79 0a                	jns    800264 <umain+0x9d>
		die("Failed to listen on server socket");
  80025a:	b8 54 2b 80 00       	mov    $0x802b54,%eax
  80025f:	e8 cf fd ff ff       	call   800033 <die>

	cprintf("Waiting for http connections...\n");
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	68 78 2b 80 00       	push   $0x802b78
  80026c:	e8 5e 04 00 00       	call   8006cf <cprintf>
  800271:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800274:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  800277:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  80027e:	83 ec 04             	sub    $0x4,%esp
  800281:	57                   	push   %edi
  800282:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800285:	50                   	push   %eax
  800286:	56                   	push   %esi
  800287:	e8 31 19 00 00       	call   801bbd <accept>
  80028c:	89 c3                	mov    %eax,%ebx
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	85 c0                	test   %eax,%eax
  800293:	79 0a                	jns    80029f <umain+0xd8>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  800295:	b8 9c 2b 80 00       	mov    $0x802b9c,%eax
  80029a:	e8 94 fd ff ff       	call   800033 <die>
		}
		handle_client(clientsock);
  80029f:	89 d8                	mov    %ebx,%eax
  8002a1:	e8 a8 fd ff ff       	call   80004e <handle_client>
	}
  8002a6:	eb cf                	jmp    800277 <umain+0xb0>

008002a8 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8002b7:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8002ba:	c7 45 e0 00 50 80 00 	movl   $0x805000,-0x20(%ebp)
  8002c1:	0f b6 0f             	movzbl (%edi),%ecx
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8002c9:	0f b6 d9             	movzbl %cl,%ebx
  8002cc:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8002cf:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8002d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d5:	66 c1 e8 0b          	shr    $0xb,%ax
  8002d9:	89 c3                	mov    %eax,%ebx
  8002db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002de:	01 c0                	add    %eax,%eax
  8002e0:	29 c1                	sub    %eax,%ecx
  8002e2:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  8002e4:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  8002e6:	8d 72 01             	lea    0x1(%edx),%esi
  8002e9:	0f b6 d2             	movzbl %dl,%edx
  8002ec:	83 c0 30             	add    $0x30,%eax
  8002ef:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  8002f3:	89 f2                	mov    %esi,%edx
    } while(*ap);
  8002f5:	84 db                	test   %bl,%bl
  8002f7:	75 d0                	jne    8002c9 <inet_ntoa+0x21>
  8002f9:	c6 07 00             	movb   $0x0,(%edi)
  8002fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002ff:	eb 0d                	jmp    80030e <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800301:	0f b6 c2             	movzbl %dl,%eax
  800304:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800309:	88 01                	mov    %al,(%ecx)
  80030b:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80030e:	83 ea 01             	sub    $0x1,%edx
  800311:	80 fa ff             	cmp    $0xff,%dl
  800314:	75 eb                	jne    800301 <inet_ntoa+0x59>
  800316:	89 f0                	mov    %esi,%eax
  800318:	0f b6 f0             	movzbl %al,%esi
  80031b:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  80031e:	8d 46 01             	lea    0x1(%esi),%eax
  800321:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800324:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  800327:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80032a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80032d:	39 c7                	cmp    %eax,%edi
  80032f:	75 90                	jne    8002c1 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800331:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800334:	b8 00 50 80 00       	mov    $0x805000,%eax
  800339:	83 c4 14             	add    $0x14,%esp
  80033c:	5b                   	pop    %ebx
  80033d:	5e                   	pop    %esi
  80033e:	5f                   	pop    %edi
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800344:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800348:	66 c1 c0 08          	rol    $0x8,%ax
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800351:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800355:	66 c1 c0 08          	rol    $0x8,%ax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800361:	89 d1                	mov    %edx,%ecx
  800363:	c1 e1 18             	shl    $0x18,%ecx
  800366:	89 d0                	mov    %edx,%eax
  800368:	c1 e8 18             	shr    $0x18,%eax
  80036b:	09 c8                	or     %ecx,%eax
  80036d:	89 d1                	mov    %edx,%ecx
  80036f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800375:	c1 e1 08             	shl    $0x8,%ecx
  800378:	09 c8                	or     %ecx,%eax
  80037a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800380:	c1 ea 08             	shr    $0x8,%edx
  800383:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	57                   	push   %edi
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 20             	sub    $0x20,%esp
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800393:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800396:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800399:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80039c:	0f b6 ca             	movzbl %dl,%ecx
  80039f:	83 e9 30             	sub    $0x30,%ecx
  8003a2:	83 f9 09             	cmp    $0x9,%ecx
  8003a5:	0f 87 94 01 00 00    	ja     80053f <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8003ab:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8003b2:	83 fa 30             	cmp    $0x30,%edx
  8003b5:	75 2b                	jne    8003e2 <inet_aton+0x5b>
      c = *++cp;
  8003b7:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8003bb:	89 d1                	mov    %edx,%ecx
  8003bd:	83 e1 df             	and    $0xffffffdf,%ecx
  8003c0:	80 f9 58             	cmp    $0x58,%cl
  8003c3:	74 0f                	je     8003d4 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8003c5:	83 c0 01             	add    $0x1,%eax
  8003c8:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8003cb:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8003d2:	eb 0e                	jmp    8003e2 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8003d4:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8003d8:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8003db:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  8003e2:	83 c0 01             	add    $0x1,%eax
  8003e5:	be 00 00 00 00       	mov    $0x0,%esi
  8003ea:	eb 03                	jmp    8003ef <inet_aton+0x68>
  8003ec:	83 c0 01             	add    $0x1,%eax
  8003ef:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8003f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003f5:	0f b6 fa             	movzbl %dl,%edi
  8003f8:	8d 4f d0             	lea    -0x30(%edi),%ecx
  8003fb:	83 f9 09             	cmp    $0x9,%ecx
  8003fe:	77 0d                	ja     80040d <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800400:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800404:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800408:	0f be 10             	movsbl (%eax),%edx
  80040b:	eb df                	jmp    8003ec <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  80040d:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800411:	75 32                	jne    800445 <inet_aton+0xbe>
  800413:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800416:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800419:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041c:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800422:	83 e9 41             	sub    $0x41,%ecx
  800425:	83 f9 05             	cmp    $0x5,%ecx
  800428:	77 1b                	ja     800445 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80042a:	c1 e6 04             	shl    $0x4,%esi
  80042d:	83 c2 0a             	add    $0xa,%edx
  800430:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800434:	19 c9                	sbb    %ecx,%ecx
  800436:	83 e1 20             	and    $0x20,%ecx
  800439:	83 c1 41             	add    $0x41,%ecx
  80043c:	29 ca                	sub    %ecx,%edx
  80043e:	09 d6                	or     %edx,%esi
        c = *++cp;
  800440:	0f be 10             	movsbl (%eax),%edx
  800443:	eb a7                	jmp    8003ec <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800445:	83 fa 2e             	cmp    $0x2e,%edx
  800448:	75 23                	jne    80046d <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80044a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80044d:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800450:	39 f8                	cmp    %edi,%eax
  800452:	0f 84 ee 00 00 00    	je     800546 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800458:	83 c0 04             	add    $0x4,%eax
  80045b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80045e:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800461:	8d 43 01             	lea    0x1(%ebx),%eax
  800464:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800468:	e9 2f ff ff ff       	jmp    80039c <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80046d:	85 d2                	test   %edx,%edx
  80046f:	74 25                	je     800496 <inet_aton+0x10f>
  800471:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800479:	83 f9 5f             	cmp    $0x5f,%ecx
  80047c:	0f 87 d0 00 00 00    	ja     800552 <inet_aton+0x1cb>
  800482:	83 fa 20             	cmp    $0x20,%edx
  800485:	74 0f                	je     800496 <inet_aton+0x10f>
  800487:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048a:	83 ea 09             	sub    $0x9,%edx
  80048d:	83 fa 04             	cmp    $0x4,%edx
  800490:	0f 87 bc 00 00 00    	ja     800552 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800496:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800499:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049c:	29 c2                	sub    %eax,%edx
  80049e:	c1 fa 02             	sar    $0x2,%edx
  8004a1:	83 c2 01             	add    $0x1,%edx
  8004a4:	83 fa 02             	cmp    $0x2,%edx
  8004a7:	74 20                	je     8004c9 <inet_aton+0x142>
  8004a9:	83 fa 02             	cmp    $0x2,%edx
  8004ac:	7f 0f                	jg     8004bd <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	0f 84 97 00 00 00    	je     800552 <inet_aton+0x1cb>
  8004bb:	eb 67                	jmp    800524 <inet_aton+0x19d>
  8004bd:	83 fa 03             	cmp    $0x3,%edx
  8004c0:	74 1e                	je     8004e0 <inet_aton+0x159>
  8004c2:	83 fa 04             	cmp    $0x4,%edx
  8004c5:	74 38                	je     8004ff <inet_aton+0x178>
  8004c7:	eb 5b                	jmp    800524 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8004c9:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8004ce:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8004d4:	77 7c                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8004d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d9:	c1 e0 18             	shl    $0x18,%eax
  8004dc:	09 c6                	or     %eax,%esi
    break;
  8004de:	eb 44                	jmp    800524 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8004e5:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  8004eb:	77 65                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8004ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f0:	c1 e2 18             	shl    $0x18,%edx
  8004f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8004f6:	c1 e0 10             	shl    $0x10,%eax
  8004f9:	09 d0                	or     %edx,%eax
  8004fb:	09 c6                	or     %eax,%esi
    break;
  8004fd:	eb 25                	jmp    800524 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800504:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  80050a:	77 46                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80050c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050f:	c1 e2 18             	shl    $0x18,%edx
  800512:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800515:	c1 e0 10             	shl    $0x10,%eax
  800518:	09 c2                	or     %eax,%edx
  80051a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80051d:	c1 e0 08             	shl    $0x8,%eax
  800520:	09 d0                	or     %edx,%eax
  800522:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800524:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800528:	74 23                	je     80054d <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  80052a:	56                   	push   %esi
  80052b:	e8 2b fe ff ff       	call   80035b <htonl>
  800530:	83 c4 04             	add    $0x4,%esp
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	89 03                	mov    %eax,(%ebx)
  return (1);
  800538:	b8 01 00 00 00       	mov    $0x1,%eax
  80053d:	eb 13                	jmp    800552 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80053f:	b8 00 00 00 00       	mov    $0x0,%eax
  800544:	eb 0c                	jmp    800552 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	eb 05                	jmp    800552 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80054d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800552:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800555:	5b                   	pop    %ebx
  800556:	5e                   	pop    %esi
  800557:	5f                   	pop    %edi
  800558:	5d                   	pop    %ebp
  800559:	c3                   	ret    

0080055a <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800560:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800563:	50                   	push   %eax
  800564:	ff 75 08             	pushl  0x8(%ebp)
  800567:	e8 1b fe ff ff       	call   800387 <inet_aton>
  80056c:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80056f:	85 c0                	test   %eax,%eax
  800571:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800576:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80057f:	ff 75 08             	pushl  0x8(%ebp)
  800582:	e8 d4 fd ff ff       	call   80035b <htonl>
  800587:	83 c4 04             	add    $0x4,%esp
}
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    

0080058c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	56                   	push   %esi
  800590:	53                   	push   %ebx
  800591:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800594:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800597:	c7 05 1c 50 80 00 00 	movl   $0x0,0x80501c
  80059e:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a1:	e8 73 0a 00 00       	call   801019 <sys_getenvid>
  8005a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b3:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b8:	85 db                	test   %ebx,%ebx
  8005ba:	7e 07                	jle    8005c3 <libmain+0x37>
		binaryname = argv[0];
  8005bc:	8b 06                	mov    (%esi),%eax
  8005be:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	56                   	push   %esi
  8005c7:	53                   	push   %ebx
  8005c8:	e8 fa fb ff ff       	call   8001c7 <umain>

	// exit gracefully
	exit();
  8005cd:	e8 0a 00 00 00       	call   8005dc <exit>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d8:	5b                   	pop    %ebx
  8005d9:	5e                   	pop    %esi
  8005da:	5d                   	pop    %ebp
  8005db:	c3                   	ret    

008005dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e2:	e8 6c 0e 00 00       	call   801453 <close_all>
	sys_env_destroy(0);
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	6a 00                	push   $0x0
  8005ec:	e8 e7 09 00 00       	call   800fd8 <sys_env_destroy>
}
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	c9                   	leave  
  8005f5:	c3                   	ret    

008005f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	56                   	push   %esi
  8005fa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005fe:	8b 35 20 40 80 00    	mov    0x804020,%esi
  800604:	e8 10 0a 00 00       	call   801019 <sys_getenvid>
  800609:	83 ec 0c             	sub    $0xc,%esp
  80060c:	ff 75 0c             	pushl  0xc(%ebp)
  80060f:	ff 75 08             	pushl  0x8(%ebp)
  800612:	56                   	push   %esi
  800613:	50                   	push   %eax
  800614:	68 f0 2b 80 00       	push   $0x802bf0
  800619:	e8 b1 00 00 00       	call   8006cf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061e:	83 c4 18             	add    $0x18,%esp
  800621:	53                   	push   %ebx
  800622:	ff 75 10             	pushl  0x10(%ebp)
  800625:	e8 54 00 00 00       	call   80067e <vcprintf>
	cprintf("\n");
  80062a:	c7 04 24 b5 30 80 00 	movl   $0x8030b5,(%esp)
  800631:	e8 99 00 00 00       	call   8006cf <cprintf>
  800636:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800639:	cc                   	int3   
  80063a:	eb fd                	jmp    800639 <_panic+0x43>

0080063c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	53                   	push   %ebx
  800640:	83 ec 04             	sub    $0x4,%esp
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800646:	8b 13                	mov    (%ebx),%edx
  800648:	8d 42 01             	lea    0x1(%edx),%eax
  80064b:	89 03                	mov    %eax,(%ebx)
  80064d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800650:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800654:	3d ff 00 00 00       	cmp    $0xff,%eax
  800659:	75 1a                	jne    800675 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	68 ff 00 00 00       	push   $0xff
  800663:	8d 43 08             	lea    0x8(%ebx),%eax
  800666:	50                   	push   %eax
  800667:	e8 2f 09 00 00       	call   800f9b <sys_cputs>
		b->idx = 0;
  80066c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800672:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800675:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067c:	c9                   	leave  
  80067d:	c3                   	ret    

0080067e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800687:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068e:	00 00 00 
	b.cnt = 0;
  800691:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800698:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	ff 75 08             	pushl  0x8(%ebp)
  8006a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a7:	50                   	push   %eax
  8006a8:	68 3c 06 80 00       	push   $0x80063c
  8006ad:	e8 54 01 00 00       	call   800806 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b2:	83 c4 08             	add    $0x8,%esp
  8006b5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c1:	50                   	push   %eax
  8006c2:	e8 d4 08 00 00       	call   800f9b <sys_cputs>

	return b.cnt;
}
  8006c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 08             	pushl  0x8(%ebp)
  8006dc:	e8 9d ff ff ff       	call   80067e <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	57                   	push   %edi
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 1c             	sub    $0x1c,%esp
  8006ec:	89 c7                	mov    %eax,%edi
  8006ee:	89 d6                	mov    %edx,%esi
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800704:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800707:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070a:	39 d3                	cmp    %edx,%ebx
  80070c:	72 05                	jb     800713 <printnum+0x30>
  80070e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800711:	77 45                	ja     800758 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800713:	83 ec 0c             	sub    $0xc,%esp
  800716:	ff 75 18             	pushl  0x18(%ebp)
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80071f:	53                   	push   %ebx
  800720:	ff 75 10             	pushl  0x10(%ebp)
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	ff 75 e4             	pushl  -0x1c(%ebp)
  800729:	ff 75 e0             	pushl  -0x20(%ebp)
  80072c:	ff 75 dc             	pushl  -0x24(%ebp)
  80072f:	ff 75 d8             	pushl  -0x28(%ebp)
  800732:	e8 69 20 00 00       	call   8027a0 <__udivdi3>
  800737:	83 c4 18             	add    $0x18,%esp
  80073a:	52                   	push   %edx
  80073b:	50                   	push   %eax
  80073c:	89 f2                	mov    %esi,%edx
  80073e:	89 f8                	mov    %edi,%eax
  800740:	e8 9e ff ff ff       	call   8006e3 <printnum>
  800745:	83 c4 20             	add    $0x20,%esp
  800748:	eb 18                	jmp    800762 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	56                   	push   %esi
  80074e:	ff 75 18             	pushl  0x18(%ebp)
  800751:	ff d7                	call   *%edi
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb 03                	jmp    80075b <printnum+0x78>
  800758:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075b:	83 eb 01             	sub    $0x1,%ebx
  80075e:	85 db                	test   %ebx,%ebx
  800760:	7f e8                	jg     80074a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	56                   	push   %esi
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076c:	ff 75 e0             	pushl  -0x20(%ebp)
  80076f:	ff 75 dc             	pushl  -0x24(%ebp)
  800772:	ff 75 d8             	pushl  -0x28(%ebp)
  800775:	e8 56 21 00 00       	call   8028d0 <__umoddi3>
  80077a:	83 c4 14             	add    $0x14,%esp
  80077d:	0f be 80 13 2c 80 00 	movsbl 0x802c13(%eax),%eax
  800784:	50                   	push   %eax
  800785:	ff d7                	call   *%edi
}
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5f                   	pop    %edi
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800795:	83 fa 01             	cmp    $0x1,%edx
  800798:	7e 0e                	jle    8007a8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80079a:	8b 10                	mov    (%eax),%edx
  80079c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80079f:	89 08                	mov    %ecx,(%eax)
  8007a1:	8b 02                	mov    (%edx),%eax
  8007a3:	8b 52 04             	mov    0x4(%edx),%edx
  8007a6:	eb 22                	jmp    8007ca <getuint+0x38>
	else if (lflag)
  8007a8:	85 d2                	test   %edx,%edx
  8007aa:	74 10                	je     8007bc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007ac:	8b 10                	mov    (%eax),%edx
  8007ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b1:	89 08                	mov    %ecx,(%eax)
  8007b3:	8b 02                	mov    (%edx),%eax
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ba:	eb 0e                	jmp    8007ca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c1:	89 08                	mov    %ecx,(%eax)
  8007c3:	8b 02                	mov    (%edx),%eax
  8007c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d6:	8b 10                	mov    (%eax),%edx
  8007d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8007db:	73 0a                	jae    8007e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e0:	89 08                	mov    %ecx,(%eax)
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	88 02                	mov    %al,(%edx)
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f2:	50                   	push   %eax
  8007f3:	ff 75 10             	pushl  0x10(%ebp)
  8007f6:	ff 75 0c             	pushl  0xc(%ebp)
  8007f9:	ff 75 08             	pushl  0x8(%ebp)
  8007fc:	e8 05 00 00 00       	call   800806 <vprintfmt>
	va_end(ap);
}
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	57                   	push   %edi
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	83 ec 2c             	sub    $0x2c,%esp
  80080f:	8b 75 08             	mov    0x8(%ebp),%esi
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800815:	8b 7d 10             	mov    0x10(%ebp),%edi
  800818:	eb 12                	jmp    80082c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80081a:	85 c0                	test   %eax,%eax
  80081c:	0f 84 89 03 00 00    	je     800bab <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	53                   	push   %ebx
  800826:	50                   	push   %eax
  800827:	ff d6                	call   *%esi
  800829:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082c:	83 c7 01             	add    $0x1,%edi
  80082f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800833:	83 f8 25             	cmp    $0x25,%eax
  800836:	75 e2                	jne    80081a <vprintfmt+0x14>
  800838:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80083c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800843:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80084a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
  800856:	eb 07                	jmp    80085f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800858:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80085b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085f:	8d 47 01             	lea    0x1(%edi),%eax
  800862:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800865:	0f b6 07             	movzbl (%edi),%eax
  800868:	0f b6 c8             	movzbl %al,%ecx
  80086b:	83 e8 23             	sub    $0x23,%eax
  80086e:	3c 55                	cmp    $0x55,%al
  800870:	0f 87 1a 03 00 00    	ja     800b90 <vprintfmt+0x38a>
  800876:	0f b6 c0             	movzbl %al,%eax
  800879:	ff 24 85 60 2d 80 00 	jmp    *0x802d60(,%eax,4)
  800880:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800883:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800887:	eb d6                	jmp    80085f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800889:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
  800891:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800894:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800897:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80089b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80089e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8008a1:	83 fa 09             	cmp    $0x9,%edx
  8008a4:	77 39                	ja     8008df <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a9:	eb e9                	jmp    800894 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8d 48 04             	lea    0x4(%eax),%ecx
  8008b1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b4:	8b 00                	mov    (%eax),%eax
  8008b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008bc:	eb 27                	jmp    8008e5 <vprintfmt+0xdf>
  8008be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c8:	0f 49 c8             	cmovns %eax,%ecx
  8008cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d1:	eb 8c                	jmp    80085f <vprintfmt+0x59>
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008dd:	eb 80                	jmp    80085f <vprintfmt+0x59>
  8008df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e9:	0f 89 70 ff ff ff    	jns    80085f <vprintfmt+0x59>
				width = precision, precision = -1;
  8008ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008fc:	e9 5e ff ff ff       	jmp    80085f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800901:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800904:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800907:	e9 53 ff ff ff       	jmp    80085f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8d 50 04             	lea    0x4(%eax),%edx
  800912:	89 55 14             	mov    %edx,0x14(%ebp)
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	53                   	push   %ebx
  800919:	ff 30                	pushl  (%eax)
  80091b:	ff d6                	call   *%esi
			break;
  80091d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800920:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800923:	e9 04 ff ff ff       	jmp    80082c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8d 50 04             	lea    0x4(%eax),%edx
  80092e:	89 55 14             	mov    %edx,0x14(%ebp)
  800931:	8b 00                	mov    (%eax),%eax
  800933:	99                   	cltd   
  800934:	31 d0                	xor    %edx,%eax
  800936:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800938:	83 f8 0f             	cmp    $0xf,%eax
  80093b:	7f 0b                	jg     800948 <vprintfmt+0x142>
  80093d:	8b 14 85 c0 2e 80 00 	mov    0x802ec0(,%eax,4),%edx
  800944:	85 d2                	test   %edx,%edx
  800946:	75 18                	jne    800960 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800948:	50                   	push   %eax
  800949:	68 2b 2c 80 00       	push   $0x802c2b
  80094e:	53                   	push   %ebx
  80094f:	56                   	push   %esi
  800950:	e8 94 fe ff ff       	call   8007e9 <printfmt>
  800955:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800958:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80095b:	e9 cc fe ff ff       	jmp    80082c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800960:	52                   	push   %edx
  800961:	68 f5 2f 80 00       	push   $0x802ff5
  800966:	53                   	push   %ebx
  800967:	56                   	push   %esi
  800968:	e8 7c fe ff ff       	call   8007e9 <printfmt>
  80096d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 b4 fe ff ff       	jmp    80082c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8d 50 04             	lea    0x4(%eax),%edx
  80097e:	89 55 14             	mov    %edx,0x14(%ebp)
  800981:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800983:	85 ff                	test   %edi,%edi
  800985:	b8 24 2c 80 00       	mov    $0x802c24,%eax
  80098a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80098d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800991:	0f 8e 94 00 00 00    	jle    800a2b <vprintfmt+0x225>
  800997:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80099b:	0f 84 98 00 00 00    	je     800a39 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a1:	83 ec 08             	sub    $0x8,%esp
  8009a4:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a7:	57                   	push   %edi
  8009a8:	e8 86 02 00 00       	call   800c33 <strnlen>
  8009ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009b0:	29 c1                	sub    %eax,%ecx
  8009b2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009bf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c4:	eb 0f                	jmp    8009d5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009c6:	83 ec 08             	sub    $0x8,%esp
  8009c9:	53                   	push   %ebx
  8009ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8009cd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cf:	83 ef 01             	sub    $0x1,%edi
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	85 ff                	test   %edi,%edi
  8009d7:	7f ed                	jg     8009c6 <vprintfmt+0x1c0>
  8009d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009dc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009df:	85 c9                	test   %ecx,%ecx
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	0f 49 c1             	cmovns %ecx,%eax
  8009e9:	29 c1                	sub    %eax,%ecx
  8009eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f4:	89 cb                	mov    %ecx,%ebx
  8009f6:	eb 4d                	jmp    800a45 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fc:	74 1b                	je     800a19 <vprintfmt+0x213>
  8009fe:	0f be c0             	movsbl %al,%eax
  800a01:	83 e8 20             	sub    $0x20,%eax
  800a04:	83 f8 5e             	cmp    $0x5e,%eax
  800a07:	76 10                	jbe    800a19 <vprintfmt+0x213>
					putch('?', putdat);
  800a09:	83 ec 08             	sub    $0x8,%esp
  800a0c:	ff 75 0c             	pushl  0xc(%ebp)
  800a0f:	6a 3f                	push   $0x3f
  800a11:	ff 55 08             	call   *0x8(%ebp)
  800a14:	83 c4 10             	add    $0x10,%esp
  800a17:	eb 0d                	jmp    800a26 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a19:	83 ec 08             	sub    $0x8,%esp
  800a1c:	ff 75 0c             	pushl  0xc(%ebp)
  800a1f:	52                   	push   %edx
  800a20:	ff 55 08             	call   *0x8(%ebp)
  800a23:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a26:	83 eb 01             	sub    $0x1,%ebx
  800a29:	eb 1a                	jmp    800a45 <vprintfmt+0x23f>
  800a2b:	89 75 08             	mov    %esi,0x8(%ebp)
  800a2e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a31:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a34:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a37:	eb 0c                	jmp    800a45 <vprintfmt+0x23f>
  800a39:	89 75 08             	mov    %esi,0x8(%ebp)
  800a3c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a3f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a42:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a45:	83 c7 01             	add    $0x1,%edi
  800a48:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a4c:	0f be d0             	movsbl %al,%edx
  800a4f:	85 d2                	test   %edx,%edx
  800a51:	74 23                	je     800a76 <vprintfmt+0x270>
  800a53:	85 f6                	test   %esi,%esi
  800a55:	78 a1                	js     8009f8 <vprintfmt+0x1f2>
  800a57:	83 ee 01             	sub    $0x1,%esi
  800a5a:	79 9c                	jns    8009f8 <vprintfmt+0x1f2>
  800a5c:	89 df                	mov    %ebx,%edi
  800a5e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a64:	eb 18                	jmp    800a7e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a66:	83 ec 08             	sub    $0x8,%esp
  800a69:	53                   	push   %ebx
  800a6a:	6a 20                	push   $0x20
  800a6c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6e:	83 ef 01             	sub    $0x1,%edi
  800a71:	83 c4 10             	add    $0x10,%esp
  800a74:	eb 08                	jmp    800a7e <vprintfmt+0x278>
  800a76:	89 df                	mov    %ebx,%edi
  800a78:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7e:	85 ff                	test   %edi,%edi
  800a80:	7f e4                	jg     800a66 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a85:	e9 a2 fd ff ff       	jmp    80082c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8a:	83 fa 01             	cmp    $0x1,%edx
  800a8d:	7e 16                	jle    800aa5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a92:	8d 50 08             	lea    0x8(%eax),%edx
  800a95:	89 55 14             	mov    %edx,0x14(%ebp)
  800a98:	8b 50 04             	mov    0x4(%eax),%edx
  800a9b:	8b 00                	mov    (%eax),%eax
  800a9d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa3:	eb 32                	jmp    800ad7 <vprintfmt+0x2d1>
	else if (lflag)
  800aa5:	85 d2                	test   %edx,%edx
  800aa7:	74 18                	je     800ac1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aa9:	8b 45 14             	mov    0x14(%ebp),%eax
  800aac:	8d 50 04             	lea    0x4(%eax),%edx
  800aaf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab2:	8b 00                	mov    (%eax),%eax
  800ab4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab7:	89 c1                	mov    %eax,%ecx
  800ab9:	c1 f9 1f             	sar    $0x1f,%ecx
  800abc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800abf:	eb 16                	jmp    800ad7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ac1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac4:	8d 50 04             	lea    0x4(%eax),%edx
  800ac7:	89 55 14             	mov    %edx,0x14(%ebp)
  800aca:	8b 00                	mov    (%eax),%eax
  800acc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800acf:	89 c1                	mov    %eax,%ecx
  800ad1:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ada:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800add:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae6:	79 74                	jns    800b5c <vprintfmt+0x356>
				putch('-', putdat);
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	53                   	push   %ebx
  800aec:	6a 2d                	push   $0x2d
  800aee:	ff d6                	call   *%esi
				num = -(long long) num;
  800af0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800af3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af6:	f7 d8                	neg    %eax
  800af8:	83 d2 00             	adc    $0x0,%edx
  800afb:	f7 da                	neg    %edx
  800afd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b00:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b05:	eb 55                	jmp    800b5c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b07:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0a:	e8 83 fc ff ff       	call   800792 <getuint>
			base = 10;
  800b0f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b14:	eb 46                	jmp    800b5c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b16:	8d 45 14             	lea    0x14(%ebp),%eax
  800b19:	e8 74 fc ff ff       	call   800792 <getuint>
		        base = 8;
  800b1e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800b23:	eb 37                	jmp    800b5c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	53                   	push   %ebx
  800b29:	6a 30                	push   $0x30
  800b2b:	ff d6                	call   *%esi
			putch('x', putdat);
  800b2d:	83 c4 08             	add    $0x8,%esp
  800b30:	53                   	push   %ebx
  800b31:	6a 78                	push   $0x78
  800b33:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b35:	8b 45 14             	mov    0x14(%ebp),%eax
  800b38:	8d 50 04             	lea    0x4(%eax),%edx
  800b3b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3e:	8b 00                	mov    (%eax),%eax
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b45:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b48:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b4d:	eb 0d                	jmp    800b5c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b4f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b52:	e8 3b fc ff ff       	call   800792 <getuint>
			base = 16;
  800b57:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b63:	57                   	push   %edi
  800b64:	ff 75 e0             	pushl  -0x20(%ebp)
  800b67:	51                   	push   %ecx
  800b68:	52                   	push   %edx
  800b69:	50                   	push   %eax
  800b6a:	89 da                	mov    %ebx,%edx
  800b6c:	89 f0                	mov    %esi,%eax
  800b6e:	e8 70 fb ff ff       	call   8006e3 <printnum>
			break;
  800b73:	83 c4 20             	add    $0x20,%esp
  800b76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b79:	e9 ae fc ff ff       	jmp    80082c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b7e:	83 ec 08             	sub    $0x8,%esp
  800b81:	53                   	push   %ebx
  800b82:	51                   	push   %ecx
  800b83:	ff d6                	call   *%esi
			break;
  800b85:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b8b:	e9 9c fc ff ff       	jmp    80082c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b90:	83 ec 08             	sub    $0x8,%esp
  800b93:	53                   	push   %ebx
  800b94:	6a 25                	push   $0x25
  800b96:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	eb 03                	jmp    800ba0 <vprintfmt+0x39a>
  800b9d:	83 ef 01             	sub    $0x1,%edi
  800ba0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ba4:	75 f7                	jne    800b9d <vprintfmt+0x397>
  800ba6:	e9 81 fc ff ff       	jmp    80082c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 18             	sub    $0x18,%esp
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bc2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	74 26                	je     800bfa <vsnprintf+0x47>
  800bd4:	85 d2                	test   %edx,%edx
  800bd6:	7e 22                	jle    800bfa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd8:	ff 75 14             	pushl  0x14(%ebp)
  800bdb:	ff 75 10             	pushl  0x10(%ebp)
  800bde:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be1:	50                   	push   %eax
  800be2:	68 cc 07 80 00       	push   $0x8007cc
  800be7:	e8 1a fc ff ff       	call   800806 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf5:	83 c4 10             	add    $0x10,%esp
  800bf8:	eb 05                	jmp    800bff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bfa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c07:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c0a:	50                   	push   %eax
  800c0b:	ff 75 10             	pushl  0x10(%ebp)
  800c0e:	ff 75 0c             	pushl  0xc(%ebp)
  800c11:	ff 75 08             	pushl  0x8(%ebp)
  800c14:	e8 9a ff ff ff       	call   800bb3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	eb 03                	jmp    800c2b <strlen+0x10>
		n++;
  800c28:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c2b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c2f:	75 f7                	jne    800c28 <strlen+0xd>
		n++;
	return n;
}
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c39:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	eb 03                	jmp    800c46 <strnlen+0x13>
		n++;
  800c43:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c46:	39 c2                	cmp    %eax,%edx
  800c48:	74 08                	je     800c52 <strnlen+0x1f>
  800c4a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c4e:	75 f3                	jne    800c43 <strnlen+0x10>
  800c50:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	53                   	push   %ebx
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c5e:	89 c2                	mov    %eax,%edx
  800c60:	83 c2 01             	add    $0x1,%edx
  800c63:	83 c1 01             	add    $0x1,%ecx
  800c66:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c6a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c6d:	84 db                	test   %bl,%bl
  800c6f:	75 ef                	jne    800c60 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c71:	5b                   	pop    %ebx
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	53                   	push   %ebx
  800c78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c7b:	53                   	push   %ebx
  800c7c:	e8 9a ff ff ff       	call   800c1b <strlen>
  800c81:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c84:	ff 75 0c             	pushl  0xc(%ebp)
  800c87:	01 d8                	add    %ebx,%eax
  800c89:	50                   	push   %eax
  800c8a:	e8 c5 ff ff ff       	call   800c54 <strcpy>
	return dst;
}
  800c8f:	89 d8                	mov    %ebx,%eax
  800c91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    

00800c96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca6:	89 f2                	mov    %esi,%edx
  800ca8:	eb 0f                	jmp    800cb9 <strncpy+0x23>
		*dst++ = *src;
  800caa:	83 c2 01             	add    $0x1,%edx
  800cad:	0f b6 01             	movzbl (%ecx),%eax
  800cb0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cb3:	80 39 01             	cmpb   $0x1,(%ecx)
  800cb6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb9:	39 da                	cmp    %ebx,%edx
  800cbb:	75 ed                	jne    800caa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cbd:	89 f0                	mov    %esi,%eax
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 10             	mov    0x10(%ebp),%edx
  800cd1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cd3:	85 d2                	test   %edx,%edx
  800cd5:	74 21                	je     800cf8 <strlcpy+0x35>
  800cd7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	eb 09                	jmp    800ce8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cdf:	83 c2 01             	add    $0x1,%edx
  800ce2:	83 c1 01             	add    $0x1,%ecx
  800ce5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce8:	39 c2                	cmp    %eax,%edx
  800cea:	74 09                	je     800cf5 <strlcpy+0x32>
  800cec:	0f b6 19             	movzbl (%ecx),%ebx
  800cef:	84 db                	test   %bl,%bl
  800cf1:	75 ec                	jne    800cdf <strlcpy+0x1c>
  800cf3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cf5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf8:	29 f0                	sub    %esi,%eax
}
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d04:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d07:	eb 06                	jmp    800d0f <strcmp+0x11>
		p++, q++;
  800d09:	83 c1 01             	add    $0x1,%ecx
  800d0c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d0f:	0f b6 01             	movzbl (%ecx),%eax
  800d12:	84 c0                	test   %al,%al
  800d14:	74 04                	je     800d1a <strcmp+0x1c>
  800d16:	3a 02                	cmp    (%edx),%al
  800d18:	74 ef                	je     800d09 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1a:	0f b6 c0             	movzbl %al,%eax
  800d1d:	0f b6 12             	movzbl (%edx),%edx
  800d20:	29 d0                	sub    %edx,%eax
}
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	53                   	push   %ebx
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2e:	89 c3                	mov    %eax,%ebx
  800d30:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d33:	eb 06                	jmp    800d3b <strncmp+0x17>
		n--, p++, q++;
  800d35:	83 c0 01             	add    $0x1,%eax
  800d38:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d3b:	39 d8                	cmp    %ebx,%eax
  800d3d:	74 15                	je     800d54 <strncmp+0x30>
  800d3f:	0f b6 08             	movzbl (%eax),%ecx
  800d42:	84 c9                	test   %cl,%cl
  800d44:	74 04                	je     800d4a <strncmp+0x26>
  800d46:	3a 0a                	cmp    (%edx),%cl
  800d48:	74 eb                	je     800d35 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d4a:	0f b6 00             	movzbl (%eax),%eax
  800d4d:	0f b6 12             	movzbl (%edx),%edx
  800d50:	29 d0                	sub    %edx,%eax
  800d52:	eb 05                	jmp    800d59 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d66:	eb 07                	jmp    800d6f <strchr+0x13>
		if (*s == c)
  800d68:	38 ca                	cmp    %cl,%dl
  800d6a:	74 0f                	je     800d7b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d6c:	83 c0 01             	add    $0x1,%eax
  800d6f:	0f b6 10             	movzbl (%eax),%edx
  800d72:	84 d2                	test   %dl,%dl
  800d74:	75 f2                	jne    800d68 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d87:	eb 03                	jmp    800d8c <strfind+0xf>
  800d89:	83 c0 01             	add    $0x1,%eax
  800d8c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d8f:	38 ca                	cmp    %cl,%dl
  800d91:	74 04                	je     800d97 <strfind+0x1a>
  800d93:	84 d2                	test   %dl,%dl
  800d95:	75 f2                	jne    800d89 <strfind+0xc>
			break;
	return (char *) s;
}
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da5:	85 c9                	test   %ecx,%ecx
  800da7:	74 36                	je     800ddf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daf:	75 28                	jne    800dd9 <memset+0x40>
  800db1:	f6 c1 03             	test   $0x3,%cl
  800db4:	75 23                	jne    800dd9 <memset+0x40>
		c &= 0xFF;
  800db6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dba:	89 d3                	mov    %edx,%ebx
  800dbc:	c1 e3 08             	shl    $0x8,%ebx
  800dbf:	89 d6                	mov    %edx,%esi
  800dc1:	c1 e6 18             	shl    $0x18,%esi
  800dc4:	89 d0                	mov    %edx,%eax
  800dc6:	c1 e0 10             	shl    $0x10,%eax
  800dc9:	09 f0                	or     %esi,%eax
  800dcb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dcd:	89 d8                	mov    %ebx,%eax
  800dcf:	09 d0                	or     %edx,%eax
  800dd1:	c1 e9 02             	shr    $0x2,%ecx
  800dd4:	fc                   	cld    
  800dd5:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd7:	eb 06                	jmp    800ddf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddc:	fc                   	cld    
  800ddd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df4:	39 c6                	cmp    %eax,%esi
  800df6:	73 35                	jae    800e2d <memmove+0x47>
  800df8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dfb:	39 d0                	cmp    %edx,%eax
  800dfd:	73 2e                	jae    800e2d <memmove+0x47>
		s += n;
		d += n;
  800dff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e02:	89 d6                	mov    %edx,%esi
  800e04:	09 fe                	or     %edi,%esi
  800e06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e0c:	75 13                	jne    800e21 <memmove+0x3b>
  800e0e:	f6 c1 03             	test   $0x3,%cl
  800e11:	75 0e                	jne    800e21 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e13:	83 ef 04             	sub    $0x4,%edi
  800e16:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e19:	c1 e9 02             	shr    $0x2,%ecx
  800e1c:	fd                   	std    
  800e1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1f:	eb 09                	jmp    800e2a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e21:	83 ef 01             	sub    $0x1,%edi
  800e24:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e27:	fd                   	std    
  800e28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e2a:	fc                   	cld    
  800e2b:	eb 1d                	jmp    800e4a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2d:	89 f2                	mov    %esi,%edx
  800e2f:	09 c2                	or     %eax,%edx
  800e31:	f6 c2 03             	test   $0x3,%dl
  800e34:	75 0f                	jne    800e45 <memmove+0x5f>
  800e36:	f6 c1 03             	test   $0x3,%cl
  800e39:	75 0a                	jne    800e45 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e3b:	c1 e9 02             	shr    $0x2,%ecx
  800e3e:	89 c7                	mov    %eax,%edi
  800e40:	fc                   	cld    
  800e41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e43:	eb 05                	jmp    800e4a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e45:	89 c7                	mov    %eax,%edi
  800e47:	fc                   	cld    
  800e48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e51:	ff 75 10             	pushl  0x10(%ebp)
  800e54:	ff 75 0c             	pushl  0xc(%ebp)
  800e57:	ff 75 08             	pushl  0x8(%ebp)
  800e5a:	e8 87 ff ff ff       	call   800de6 <memmove>
}
  800e5f:	c9                   	leave  
  800e60:	c3                   	ret    

00800e61 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
  800e69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6c:	89 c6                	mov    %eax,%esi
  800e6e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e71:	eb 1a                	jmp    800e8d <memcmp+0x2c>
		if (*s1 != *s2)
  800e73:	0f b6 08             	movzbl (%eax),%ecx
  800e76:	0f b6 1a             	movzbl (%edx),%ebx
  800e79:	38 d9                	cmp    %bl,%cl
  800e7b:	74 0a                	je     800e87 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e7d:	0f b6 c1             	movzbl %cl,%eax
  800e80:	0f b6 db             	movzbl %bl,%ebx
  800e83:	29 d8                	sub    %ebx,%eax
  800e85:	eb 0f                	jmp    800e96 <memcmp+0x35>
		s1++, s2++;
  800e87:	83 c0 01             	add    $0x1,%eax
  800e8a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8d:	39 f0                	cmp    %esi,%eax
  800e8f:	75 e2                	jne    800e73 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	53                   	push   %ebx
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ea1:	89 c1                	mov    %eax,%ecx
  800ea3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eaa:	eb 0a                	jmp    800eb6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eac:	0f b6 10             	movzbl (%eax),%edx
  800eaf:	39 da                	cmp    %ebx,%edx
  800eb1:	74 07                	je     800eba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb3:	83 c0 01             	add    $0x1,%eax
  800eb6:	39 c8                	cmp    %ecx,%eax
  800eb8:	72 f2                	jb     800eac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eba:	5b                   	pop    %ebx
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec9:	eb 03                	jmp    800ece <strtol+0x11>
		s++;
  800ecb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ece:	0f b6 01             	movzbl (%ecx),%eax
  800ed1:	3c 20                	cmp    $0x20,%al
  800ed3:	74 f6                	je     800ecb <strtol+0xe>
  800ed5:	3c 09                	cmp    $0x9,%al
  800ed7:	74 f2                	je     800ecb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed9:	3c 2b                	cmp    $0x2b,%al
  800edb:	75 0a                	jne    800ee7 <strtol+0x2a>
		s++;
  800edd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ee0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee5:	eb 11                	jmp    800ef8 <strtol+0x3b>
  800ee7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800eec:	3c 2d                	cmp    $0x2d,%al
  800eee:	75 08                	jne    800ef8 <strtol+0x3b>
		s++, neg = 1;
  800ef0:	83 c1 01             	add    $0x1,%ecx
  800ef3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800efe:	75 15                	jne    800f15 <strtol+0x58>
  800f00:	80 39 30             	cmpb   $0x30,(%ecx)
  800f03:	75 10                	jne    800f15 <strtol+0x58>
  800f05:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f09:	75 7c                	jne    800f87 <strtol+0xca>
		s += 2, base = 16;
  800f0b:	83 c1 02             	add    $0x2,%ecx
  800f0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f13:	eb 16                	jmp    800f2b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f15:	85 db                	test   %ebx,%ebx
  800f17:	75 12                	jne    800f2b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f19:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f1e:	80 39 30             	cmpb   $0x30,(%ecx)
  800f21:	75 08                	jne    800f2b <strtol+0x6e>
		s++, base = 8;
  800f23:	83 c1 01             	add    $0x1,%ecx
  800f26:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f30:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f33:	0f b6 11             	movzbl (%ecx),%edx
  800f36:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f39:	89 f3                	mov    %esi,%ebx
  800f3b:	80 fb 09             	cmp    $0x9,%bl
  800f3e:	77 08                	ja     800f48 <strtol+0x8b>
			dig = *s - '0';
  800f40:	0f be d2             	movsbl %dl,%edx
  800f43:	83 ea 30             	sub    $0x30,%edx
  800f46:	eb 22                	jmp    800f6a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f48:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f4b:	89 f3                	mov    %esi,%ebx
  800f4d:	80 fb 19             	cmp    $0x19,%bl
  800f50:	77 08                	ja     800f5a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f52:	0f be d2             	movsbl %dl,%edx
  800f55:	83 ea 57             	sub    $0x57,%edx
  800f58:	eb 10                	jmp    800f6a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f5a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f5d:	89 f3                	mov    %esi,%ebx
  800f5f:	80 fb 19             	cmp    $0x19,%bl
  800f62:	77 16                	ja     800f7a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f64:	0f be d2             	movsbl %dl,%edx
  800f67:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f6a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f6d:	7d 0b                	jge    800f7a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f6f:	83 c1 01             	add    $0x1,%ecx
  800f72:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f76:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f78:	eb b9                	jmp    800f33 <strtol+0x76>

	if (endptr)
  800f7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f7e:	74 0d                	je     800f8d <strtol+0xd0>
		*endptr = (char *) s;
  800f80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f83:	89 0e                	mov    %ecx,(%esi)
  800f85:	eb 06                	jmp    800f8d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f87:	85 db                	test   %ebx,%ebx
  800f89:	74 98                	je     800f23 <strtol+0x66>
  800f8b:	eb 9e                	jmp    800f2b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f8d:	89 c2                	mov    %eax,%edx
  800f8f:	f7 da                	neg    %edx
  800f91:	85 ff                	test   %edi,%edi
  800f93:	0f 45 c2             	cmovne %edx,%eax
}
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	89 c3                	mov    %eax,%ebx
  800fae:	89 c7                	mov    %eax,%edi
  800fb0:	89 c6                	mov    %eax,%esi
  800fb2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	57                   	push   %edi
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc9:	89 d1                	mov    %edx,%ecx
  800fcb:	89 d3                	mov    %edx,%ebx
  800fcd:	89 d7                	mov    %edx,%edi
  800fcf:	89 d6                	mov    %edx,%esi
  800fd1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe6:	b8 03 00 00 00       	mov    $0x3,%eax
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	89 cb                	mov    %ecx,%ebx
  800ff0:	89 cf                	mov    %ecx,%edi
  800ff2:	89 ce                	mov    %ecx,%esi
  800ff4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	7e 17                	jle    801011 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	50                   	push   %eax
  800ffe:	6a 03                	push   $0x3
  801000:	68 1f 2f 80 00       	push   $0x802f1f
  801005:	6a 23                	push   $0x23
  801007:	68 3c 2f 80 00       	push   $0x802f3c
  80100c:	e8 e5 f5 ff ff       	call   8005f6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801011:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	57                   	push   %edi
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101f:	ba 00 00 00 00       	mov    $0x0,%edx
  801024:	b8 02 00 00 00       	mov    $0x2,%eax
  801029:	89 d1                	mov    %edx,%ecx
  80102b:	89 d3                	mov    %edx,%ebx
  80102d:	89 d7                	mov    %edx,%edi
  80102f:	89 d6                	mov    %edx,%esi
  801031:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <sys_yield>:

void
sys_yield(void)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	57                   	push   %edi
  80103c:	56                   	push   %esi
  80103d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103e:	ba 00 00 00 00       	mov    $0x0,%edx
  801043:	b8 0b 00 00 00       	mov    $0xb,%eax
  801048:	89 d1                	mov    %edx,%ecx
  80104a:	89 d3                	mov    %edx,%ebx
  80104c:	89 d7                	mov    %edx,%edi
  80104e:	89 d6                	mov    %edx,%esi
  801050:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801060:	be 00 00 00 00       	mov    $0x0,%esi
  801065:	b8 04 00 00 00       	mov    $0x4,%eax
  80106a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106d:	8b 55 08             	mov    0x8(%ebp),%edx
  801070:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801073:	89 f7                	mov    %esi,%edi
  801075:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	7e 17                	jle    801092 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	50                   	push   %eax
  80107f:	6a 04                	push   $0x4
  801081:	68 1f 2f 80 00       	push   $0x802f1f
  801086:	6a 23                	push   $0x23
  801088:	68 3c 2f 80 00       	push   $0x802f3c
  80108d:	e8 64 f5 ff ff       	call   8005f6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801092:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801095:	5b                   	pop    %ebx
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a3:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b4:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	7e 17                	jle    8010d4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	50                   	push   %eax
  8010c1:	6a 05                	push   $0x5
  8010c3:	68 1f 2f 80 00       	push   $0x802f1f
  8010c8:	6a 23                	push   $0x23
  8010ca:	68 3c 2f 80 00       	push   $0x802f3c
  8010cf:	e8 22 f5 ff ff       	call   8005f6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8010ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f5:	89 df                	mov    %ebx,%edi
  8010f7:	89 de                	mov    %ebx,%esi
  8010f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	7e 17                	jle    801116 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ff:	83 ec 0c             	sub    $0xc,%esp
  801102:	50                   	push   %eax
  801103:	6a 06                	push   $0x6
  801105:	68 1f 2f 80 00       	push   $0x802f1f
  80110a:	6a 23                	push   $0x23
  80110c:	68 3c 2f 80 00       	push   $0x802f3c
  801111:	e8 e0 f4 ff ff       	call   8005f6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801127:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112c:	b8 08 00 00 00       	mov    $0x8,%eax
  801131:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801134:	8b 55 08             	mov    0x8(%ebp),%edx
  801137:	89 df                	mov    %ebx,%edi
  801139:	89 de                	mov    %ebx,%esi
  80113b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80113d:	85 c0                	test   %eax,%eax
  80113f:	7e 17                	jle    801158 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	50                   	push   %eax
  801145:	6a 08                	push   $0x8
  801147:	68 1f 2f 80 00       	push   $0x802f1f
  80114c:	6a 23                	push   $0x23
  80114e:	68 3c 2f 80 00       	push   $0x802f3c
  801153:	e8 9e f4 ff ff       	call   8005f6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801169:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116e:	b8 09 00 00 00       	mov    $0x9,%eax
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801176:	8b 55 08             	mov    0x8(%ebp),%edx
  801179:	89 df                	mov    %ebx,%edi
  80117b:	89 de                	mov    %ebx,%esi
  80117d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80117f:	85 c0                	test   %eax,%eax
  801181:	7e 17                	jle    80119a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	50                   	push   %eax
  801187:	6a 09                	push   $0x9
  801189:	68 1f 2f 80 00       	push   $0x802f1f
  80118e:	6a 23                	push   $0x23
  801190:	68 3c 2f 80 00       	push   $0x802f3c
  801195:	e8 5c f4 ff ff       	call   8005f6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80119a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	57                   	push   %edi
  8011a6:	56                   	push   %esi
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bb:	89 df                	mov    %ebx,%edi
  8011bd:	89 de                	mov    %ebx,%esi
  8011bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	7e 17                	jle    8011dc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c5:	83 ec 0c             	sub    $0xc,%esp
  8011c8:	50                   	push   %eax
  8011c9:	6a 0a                	push   $0xa
  8011cb:	68 1f 2f 80 00       	push   $0x802f1f
  8011d0:	6a 23                	push   $0x23
  8011d2:	68 3c 2f 80 00       	push   $0x802f3c
  8011d7:	e8 1a f4 ff ff       	call   8005f6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	57                   	push   %edi
  8011e8:	56                   	push   %esi
  8011e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ea:	be 00 00 00 00       	mov    $0x0,%esi
  8011ef:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011fd:	8b 7d 14             	mov    0x14(%ebp),%edi
  801200:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	57                   	push   %edi
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801210:	b9 00 00 00 00       	mov    $0x0,%ecx
  801215:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121a:	8b 55 08             	mov    0x8(%ebp),%edx
  80121d:	89 cb                	mov    %ecx,%ebx
  80121f:	89 cf                	mov    %ecx,%edi
  801221:	89 ce                	mov    %ecx,%esi
  801223:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801225:	85 c0                	test   %eax,%eax
  801227:	7e 17                	jle    801240 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801229:	83 ec 0c             	sub    $0xc,%esp
  80122c:	50                   	push   %eax
  80122d:	6a 0d                	push   $0xd
  80122f:	68 1f 2f 80 00       	push   $0x802f1f
  801234:	6a 23                	push   $0x23
  801236:	68 3c 2f 80 00       	push   $0x802f3c
  80123b:	e8 b6 f3 ff ff       	call   8005f6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	57                   	push   %edi
  80124c:	56                   	push   %esi
  80124d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124e:	ba 00 00 00 00       	mov    $0x0,%edx
  801253:	b8 0e 00 00 00       	mov    $0xe,%eax
  801258:	89 d1                	mov    %edx,%ecx
  80125a:	89 d3                	mov    %edx,%ebx
  80125c:	89 d7                	mov    %edx,%edi
  80125e:	89 d6                	mov    %edx,%esi
  801260:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801262:	5b                   	pop    %ebx
  801263:	5e                   	pop    %esi
  801264:	5f                   	pop    %edi
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    

00801267 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	57                   	push   %edi
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801272:	b8 0f 00 00 00       	mov    $0xf,%eax
  801277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127a:	8b 55 08             	mov    0x8(%ebp),%edx
  80127d:	89 df                	mov    %ebx,%edi
  80127f:	89 de                	mov    %ebx,%esi
  801281:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80128b:	8b 45 08             	mov    0x8(%ebp),%eax
  80128e:	05 00 00 00 30       	add    $0x30000000,%eax
  801293:	c1 e8 0c             	shr    $0xc,%eax
}
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
  80129e:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012a8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	c1 ea 16             	shr    $0x16,%edx
  8012bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c6:	f6 c2 01             	test   $0x1,%dl
  8012c9:	74 11                	je     8012dc <fd_alloc+0x2d>
  8012cb:	89 c2                	mov    %eax,%edx
  8012cd:	c1 ea 0c             	shr    $0xc,%edx
  8012d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d7:	f6 c2 01             	test   $0x1,%dl
  8012da:	75 09                	jne    8012e5 <fd_alloc+0x36>
			*fd_store = fd;
  8012dc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e3:	eb 17                	jmp    8012fc <fd_alloc+0x4d>
  8012e5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ef:	75 c9                	jne    8012ba <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012f1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012f7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801304:	83 f8 1f             	cmp    $0x1f,%eax
  801307:	77 36                	ja     80133f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801309:	c1 e0 0c             	shl    $0xc,%eax
  80130c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801311:	89 c2                	mov    %eax,%edx
  801313:	c1 ea 16             	shr    $0x16,%edx
  801316:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80131d:	f6 c2 01             	test   $0x1,%dl
  801320:	74 24                	je     801346 <fd_lookup+0x48>
  801322:	89 c2                	mov    %eax,%edx
  801324:	c1 ea 0c             	shr    $0xc,%edx
  801327:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132e:	f6 c2 01             	test   $0x1,%dl
  801331:	74 1a                	je     80134d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801333:	8b 55 0c             	mov    0xc(%ebp),%edx
  801336:	89 02                	mov    %eax,(%edx)
	return 0;
  801338:	b8 00 00 00 00       	mov    $0x0,%eax
  80133d:	eb 13                	jmp    801352 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80133f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801344:	eb 0c                	jmp    801352 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801346:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134b:	eb 05                	jmp    801352 <fd_lookup+0x54>
  80134d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135d:	ba c8 2f 80 00       	mov    $0x802fc8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801362:	eb 13                	jmp    801377 <dev_lookup+0x23>
  801364:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801367:	39 08                	cmp    %ecx,(%eax)
  801369:	75 0c                	jne    801377 <dev_lookup+0x23>
			*dev = devtab[i];
  80136b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
  801375:	eb 2e                	jmp    8013a5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801377:	8b 02                	mov    (%edx),%eax
  801379:	85 c0                	test   %eax,%eax
  80137b:	75 e7                	jne    801364 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80137d:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801382:	8b 40 48             	mov    0x48(%eax),%eax
  801385:	83 ec 04             	sub    $0x4,%esp
  801388:	51                   	push   %ecx
  801389:	50                   	push   %eax
  80138a:	68 4c 2f 80 00       	push   $0x802f4c
  80138f:	e8 3b f3 ff ff       	call   8006cf <cprintf>
	*dev = 0;
  801394:	8b 45 0c             	mov    0xc(%ebp),%eax
  801397:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 10             	sub    $0x10,%esp
  8013af:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b8:	50                   	push   %eax
  8013b9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013bf:	c1 e8 0c             	shr    $0xc,%eax
  8013c2:	50                   	push   %eax
  8013c3:	e8 36 ff ff ff       	call   8012fe <fd_lookup>
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 05                	js     8013d4 <fd_close+0x2d>
	    || fd != fd2)
  8013cf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013d2:	74 0c                	je     8013e0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013d4:	84 db                	test   %bl,%bl
  8013d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013db:	0f 44 c2             	cmove  %edx,%eax
  8013de:	eb 41                	jmp    801421 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	ff 36                	pushl  (%esi)
  8013e9:	e8 66 ff ff ff       	call   801354 <dev_lookup>
  8013ee:	89 c3                	mov    %eax,%ebx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 1a                	js     801411 <fd_close+0x6a>
		if (dev->dev_close)
  8013f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fa:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013fd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801402:	85 c0                	test   %eax,%eax
  801404:	74 0b                	je     801411 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	56                   	push   %esi
  80140a:	ff d0                	call   *%eax
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	56                   	push   %esi
  801415:	6a 00                	push   $0x0
  801417:	e8 c0 fc ff ff       	call   8010dc <sys_page_unmap>
	return r;
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	89 d8                	mov    %ebx,%eax
}
  801421:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	ff 75 08             	pushl  0x8(%ebp)
  801435:	e8 c4 fe ff ff       	call   8012fe <fd_lookup>
  80143a:	83 c4 08             	add    $0x8,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 10                	js     801451 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	6a 01                	push   $0x1
  801446:	ff 75 f4             	pushl  -0xc(%ebp)
  801449:	e8 59 ff ff ff       	call   8013a7 <fd_close>
  80144e:	83 c4 10             	add    $0x10,%esp
}
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <close_all>:

void
close_all(void)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	53                   	push   %ebx
  801457:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80145a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	53                   	push   %ebx
  801463:	e8 c0 ff ff ff       	call   801428 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801468:	83 c3 01             	add    $0x1,%ebx
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	83 fb 20             	cmp    $0x20,%ebx
  801471:	75 ec                	jne    80145f <close_all+0xc>
		close(i);
}
  801473:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	57                   	push   %edi
  80147c:	56                   	push   %esi
  80147d:	53                   	push   %ebx
  80147e:	83 ec 2c             	sub    $0x2c,%esp
  801481:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801484:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	ff 75 08             	pushl  0x8(%ebp)
  80148b:	e8 6e fe ff ff       	call   8012fe <fd_lookup>
  801490:	83 c4 08             	add    $0x8,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	0f 88 c1 00 00 00    	js     80155c <dup+0xe4>
		return r;
	close(newfdnum);
  80149b:	83 ec 0c             	sub    $0xc,%esp
  80149e:	56                   	push   %esi
  80149f:	e8 84 ff ff ff       	call   801428 <close>

	newfd = INDEX2FD(newfdnum);
  8014a4:	89 f3                	mov    %esi,%ebx
  8014a6:	c1 e3 0c             	shl    $0xc,%ebx
  8014a9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014af:	83 c4 04             	add    $0x4,%esp
  8014b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b5:	e8 de fd ff ff       	call   801298 <fd2data>
  8014ba:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014bc:	89 1c 24             	mov    %ebx,(%esp)
  8014bf:	e8 d4 fd ff ff       	call   801298 <fd2data>
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ca:	89 f8                	mov    %edi,%eax
  8014cc:	c1 e8 16             	shr    $0x16,%eax
  8014cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d6:	a8 01                	test   $0x1,%al
  8014d8:	74 37                	je     801511 <dup+0x99>
  8014da:	89 f8                	mov    %edi,%eax
  8014dc:	c1 e8 0c             	shr    $0xc,%eax
  8014df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e6:	f6 c2 01             	test   $0x1,%dl
  8014e9:	74 26                	je     801511 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fa:	50                   	push   %eax
  8014fb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014fe:	6a 00                	push   $0x0
  801500:	57                   	push   %edi
  801501:	6a 00                	push   $0x0
  801503:	e8 92 fb ff ff       	call   80109a <sys_page_map>
  801508:	89 c7                	mov    %eax,%edi
  80150a:	83 c4 20             	add    $0x20,%esp
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 2e                	js     80153f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801511:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801514:	89 d0                	mov    %edx,%eax
  801516:	c1 e8 0c             	shr    $0xc,%eax
  801519:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	25 07 0e 00 00       	and    $0xe07,%eax
  801528:	50                   	push   %eax
  801529:	53                   	push   %ebx
  80152a:	6a 00                	push   $0x0
  80152c:	52                   	push   %edx
  80152d:	6a 00                	push   $0x0
  80152f:	e8 66 fb ff ff       	call   80109a <sys_page_map>
  801534:	89 c7                	mov    %eax,%edi
  801536:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801539:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80153b:	85 ff                	test   %edi,%edi
  80153d:	79 1d                	jns    80155c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80153f:	83 ec 08             	sub    $0x8,%esp
  801542:	53                   	push   %ebx
  801543:	6a 00                	push   $0x0
  801545:	e8 92 fb ff ff       	call   8010dc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80154a:	83 c4 08             	add    $0x8,%esp
  80154d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801550:	6a 00                	push   $0x0
  801552:	e8 85 fb ff ff       	call   8010dc <sys_page_unmap>
	return r;
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	89 f8                	mov    %edi,%eax
}
  80155c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5f                   	pop    %edi
  801562:	5d                   	pop    %ebp
  801563:	c3                   	ret    

00801564 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	53                   	push   %ebx
  801568:	83 ec 14             	sub    $0x14,%esp
  80156b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	53                   	push   %ebx
  801573:	e8 86 fd ff ff       	call   8012fe <fd_lookup>
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 6d                	js     8015ee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158b:	ff 30                	pushl  (%eax)
  80158d:	e8 c2 fd ff ff       	call   801354 <dev_lookup>
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 4c                	js     8015e5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801599:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80159c:	8b 42 08             	mov    0x8(%edx),%eax
  80159f:	83 e0 03             	and    $0x3,%eax
  8015a2:	83 f8 01             	cmp    $0x1,%eax
  8015a5:	75 21                	jne    8015c8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a7:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8015ac:	8b 40 48             	mov    0x48(%eax),%eax
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	50                   	push   %eax
  8015b4:	68 8d 2f 80 00       	push   $0x802f8d
  8015b9:	e8 11 f1 ff ff       	call   8006cf <cprintf>
		return -E_INVAL;
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c6:	eb 26                	jmp    8015ee <read+0x8a>
	}
	if (!dev->dev_read)
  8015c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cb:	8b 40 08             	mov    0x8(%eax),%eax
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	74 17                	je     8015e9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015d2:	83 ec 04             	sub    $0x4,%esp
  8015d5:	ff 75 10             	pushl  0x10(%ebp)
  8015d8:	ff 75 0c             	pushl  0xc(%ebp)
  8015db:	52                   	push   %edx
  8015dc:	ff d0                	call   *%eax
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	eb 09                	jmp    8015ee <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	eb 05                	jmp    8015ee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015ee:	89 d0                	mov    %edx,%eax
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	57                   	push   %edi
  8015f9:	56                   	push   %esi
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 0c             	sub    $0xc,%esp
  8015fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801601:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801604:	bb 00 00 00 00       	mov    $0x0,%ebx
  801609:	eb 21                	jmp    80162c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80160b:	83 ec 04             	sub    $0x4,%esp
  80160e:	89 f0                	mov    %esi,%eax
  801610:	29 d8                	sub    %ebx,%eax
  801612:	50                   	push   %eax
  801613:	89 d8                	mov    %ebx,%eax
  801615:	03 45 0c             	add    0xc(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	57                   	push   %edi
  80161a:	e8 45 ff ff ff       	call   801564 <read>
		if (m < 0)
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 10                	js     801636 <readn+0x41>
			return m;
		if (m == 0)
  801626:	85 c0                	test   %eax,%eax
  801628:	74 0a                	je     801634 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162a:	01 c3                	add    %eax,%ebx
  80162c:	39 f3                	cmp    %esi,%ebx
  80162e:	72 db                	jb     80160b <readn+0x16>
  801630:	89 d8                	mov    %ebx,%eax
  801632:	eb 02                	jmp    801636 <readn+0x41>
  801634:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5f                   	pop    %edi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 14             	sub    $0x14,%esp
  801645:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	53                   	push   %ebx
  80164d:	e8 ac fc ff ff       	call   8012fe <fd_lookup>
  801652:	83 c4 08             	add    $0x8,%esp
  801655:	89 c2                	mov    %eax,%edx
  801657:	85 c0                	test   %eax,%eax
  801659:	78 68                	js     8016c3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	ff 30                	pushl  (%eax)
  801667:	e8 e8 fc ff ff       	call   801354 <dev_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 47                	js     8016ba <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801676:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167a:	75 21                	jne    80169d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80167c:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801681:	8b 40 48             	mov    0x48(%eax),%eax
  801684:	83 ec 04             	sub    $0x4,%esp
  801687:	53                   	push   %ebx
  801688:	50                   	push   %eax
  801689:	68 a9 2f 80 00       	push   $0x802fa9
  80168e:	e8 3c f0 ff ff       	call   8006cf <cprintf>
		return -E_INVAL;
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169b:	eb 26                	jmp    8016c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80169d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8016a3:	85 d2                	test   %edx,%edx
  8016a5:	74 17                	je     8016be <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	ff 75 10             	pushl  0x10(%ebp)
  8016ad:	ff 75 0c             	pushl  0xc(%ebp)
  8016b0:	50                   	push   %eax
  8016b1:	ff d2                	call   *%edx
  8016b3:	89 c2                	mov    %eax,%edx
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	eb 09                	jmp    8016c3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	eb 05                	jmp    8016c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016c3:	89 d0                	mov    %edx,%eax
  8016c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	ff 75 08             	pushl  0x8(%ebp)
  8016d7:	e8 22 fc ff ff       	call   8012fe <fd_lookup>
  8016dc:	83 c4 08             	add    $0x8,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 0e                	js     8016f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 14             	sub    $0x14,%esp
  8016fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	53                   	push   %ebx
  801702:	e8 f7 fb ff ff       	call   8012fe <fd_lookup>
  801707:	83 c4 08             	add    $0x8,%esp
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 65                	js     801775 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	ff 30                	pushl  (%eax)
  80171c:	e8 33 fc ff ff       	call   801354 <dev_lookup>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 44                	js     80176c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801728:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80172f:	75 21                	jne    801752 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801731:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801736:	8b 40 48             	mov    0x48(%eax),%eax
  801739:	83 ec 04             	sub    $0x4,%esp
  80173c:	53                   	push   %ebx
  80173d:	50                   	push   %eax
  80173e:	68 6c 2f 80 00       	push   $0x802f6c
  801743:	e8 87 ef ff ff       	call   8006cf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801750:	eb 23                	jmp    801775 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801752:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801755:	8b 52 18             	mov    0x18(%edx),%edx
  801758:	85 d2                	test   %edx,%edx
  80175a:	74 14                	je     801770 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80175c:	83 ec 08             	sub    $0x8,%esp
  80175f:	ff 75 0c             	pushl  0xc(%ebp)
  801762:	50                   	push   %eax
  801763:	ff d2                	call   *%edx
  801765:	89 c2                	mov    %eax,%edx
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	eb 09                	jmp    801775 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176c:	89 c2                	mov    %eax,%edx
  80176e:	eb 05                	jmp    801775 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801770:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801775:	89 d0                	mov    %edx,%eax
  801777:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 14             	sub    $0x14,%esp
  801783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801786:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801789:	50                   	push   %eax
  80178a:	ff 75 08             	pushl  0x8(%ebp)
  80178d:	e8 6c fb ff ff       	call   8012fe <fd_lookup>
  801792:	83 c4 08             	add    $0x8,%esp
  801795:	89 c2                	mov    %eax,%edx
  801797:	85 c0                	test   %eax,%eax
  801799:	78 58                	js     8017f3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a1:	50                   	push   %eax
  8017a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a5:	ff 30                	pushl  (%eax)
  8017a7:	e8 a8 fb ff ff       	call   801354 <dev_lookup>
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 37                	js     8017ea <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ba:	74 32                	je     8017ee <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017bc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017bf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017c6:	00 00 00 
	stat->st_isdir = 0;
  8017c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d0:	00 00 00 
	stat->st_dev = dev;
  8017d3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	53                   	push   %ebx
  8017dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e0:	ff 50 14             	call   *0x14(%eax)
  8017e3:	89 c2                	mov    %eax,%edx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	eb 09                	jmp    8017f3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ea:	89 c2                	mov    %eax,%edx
  8017ec:	eb 05                	jmp    8017f3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017f3:	89 d0                	mov    %edx,%eax
  8017f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	6a 00                	push   $0x0
  801804:	ff 75 08             	pushl  0x8(%ebp)
  801807:	e8 e7 01 00 00       	call   8019f3 <open>
  80180c:	89 c3                	mov    %eax,%ebx
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	85 c0                	test   %eax,%eax
  801813:	78 1b                	js     801830 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	ff 75 0c             	pushl  0xc(%ebp)
  80181b:	50                   	push   %eax
  80181c:	e8 5b ff ff ff       	call   80177c <fstat>
  801821:	89 c6                	mov    %eax,%esi
	close(fd);
  801823:	89 1c 24             	mov    %ebx,(%esp)
  801826:	e8 fd fb ff ff       	call   801428 <close>
	return r;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	89 f0                	mov    %esi,%eax
}
  801830:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801833:	5b                   	pop    %ebx
  801834:	5e                   	pop    %esi
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
  80183c:	89 c6                	mov    %eax,%esi
  80183e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801840:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801847:	75 12                	jne    80185b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801849:	83 ec 0c             	sub    $0xc,%esp
  80184c:	6a 01                	push   $0x1
  80184e:	e8 d9 0e 00 00       	call   80272c <ipc_find_env>
  801853:	a3 10 50 80 00       	mov    %eax,0x805010
  801858:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80185b:	6a 07                	push   $0x7
  80185d:	68 00 60 80 00       	push   $0x806000
  801862:	56                   	push   %esi
  801863:	ff 35 10 50 80 00    	pushl  0x805010
  801869:	e8 6a 0e 00 00       	call   8026d8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80186e:	83 c4 0c             	add    $0xc,%esp
  801871:	6a 00                	push   $0x0
  801873:	53                   	push   %ebx
  801874:	6a 00                	push   $0x0
  801876:	e8 f0 0d 00 00       	call   80266b <ipc_recv>
}
  80187b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	8b 40 0c             	mov    0xc(%eax),%eax
  80188e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801893:	8b 45 0c             	mov    0xc(%ebp),%eax
  801896:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a5:	e8 8d ff ff ff       	call   801837 <fsipc>
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b8:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c7:	e8 6b ff ff ff       	call   801837 <fsipc>
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 04             	sub    $0x4,%esp
  8018d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018db:	8b 40 0c             	mov    0xc(%eax),%eax
  8018de:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ed:	e8 45 ff ff ff       	call   801837 <fsipc>
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	78 2c                	js     801922 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f6:	83 ec 08             	sub    $0x8,%esp
  8018f9:	68 00 60 80 00       	push   $0x806000
  8018fe:	53                   	push   %ebx
  8018ff:	e8 50 f3 ff ff       	call   800c54 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801904:	a1 80 60 80 00       	mov    0x806080,%eax
  801909:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80190f:	a1 84 60 80 00       	mov    0x806084,%eax
  801914:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	53                   	push   %ebx
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801931:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801936:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80193b:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80193e:	53                   	push   %ebx
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	68 08 60 80 00       	push   $0x806008
  801947:	e8 9a f4 ff ff       	call   800de6 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80194c:	8b 45 08             	mov    0x8(%ebp),%eax
  80194f:	8b 40 0c             	mov    0xc(%eax),%eax
  801952:	a3 00 60 80 00       	mov    %eax,0x806000
 	fsipcbuf.write.req_n = n;
  801957:	89 1d 04 60 80 00    	mov    %ebx,0x806004

 	return fsipc(FSREQ_WRITE, NULL);
  80195d:	ba 00 00 00 00       	mov    $0x0,%edx
  801962:	b8 04 00 00 00       	mov    $0x4,%eax
  801967:	e8 cb fe ff ff       	call   801837 <fsipc>
	//panic("devfile_write not implemented");
}
  80196c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	56                   	push   %esi
  801975:	53                   	push   %ebx
  801976:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801979:	8b 45 08             	mov    0x8(%ebp),%eax
  80197c:	8b 40 0c             	mov    0xc(%eax),%eax
  80197f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801984:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	b8 03 00 00 00       	mov    $0x3,%eax
  801994:	e8 9e fe ff ff       	call   801837 <fsipc>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 4b                	js     8019ea <devfile_read+0x79>
		return r;
	assert(r <= n);
  80199f:	39 c6                	cmp    %eax,%esi
  8019a1:	73 16                	jae    8019b9 <devfile_read+0x48>
  8019a3:	68 dc 2f 80 00       	push   $0x802fdc
  8019a8:	68 e3 2f 80 00       	push   $0x802fe3
  8019ad:	6a 7c                	push   $0x7c
  8019af:	68 f8 2f 80 00       	push   $0x802ff8
  8019b4:	e8 3d ec ff ff       	call   8005f6 <_panic>
	assert(r <= PGSIZE);
  8019b9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019be:	7e 16                	jle    8019d6 <devfile_read+0x65>
  8019c0:	68 03 30 80 00       	push   $0x803003
  8019c5:	68 e3 2f 80 00       	push   $0x802fe3
  8019ca:	6a 7d                	push   $0x7d
  8019cc:	68 f8 2f 80 00       	push   $0x802ff8
  8019d1:	e8 20 ec ff ff       	call   8005f6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019d6:	83 ec 04             	sub    $0x4,%esp
  8019d9:	50                   	push   %eax
  8019da:	68 00 60 80 00       	push   $0x806000
  8019df:	ff 75 0c             	pushl  0xc(%ebp)
  8019e2:	e8 ff f3 ff ff       	call   800de6 <memmove>
	return r;
  8019e7:	83 c4 10             	add    $0x10,%esp
}
  8019ea:	89 d8                	mov    %ebx,%eax
  8019ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	53                   	push   %ebx
  8019f7:	83 ec 20             	sub    $0x20,%esp
  8019fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019fd:	53                   	push   %ebx
  8019fe:	e8 18 f2 ff ff       	call   800c1b <strlen>
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a0b:	7f 67                	jg     801a74 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a13:	50                   	push   %eax
  801a14:	e8 96 f8 ff ff       	call   8012af <fd_alloc>
  801a19:	83 c4 10             	add    $0x10,%esp
		return r;
  801a1c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 57                	js     801a79 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	53                   	push   %ebx
  801a26:	68 00 60 80 00       	push   $0x806000
  801a2b:	e8 24 f2 ff ff       	call   800c54 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a40:	e8 f2 fd ff ff       	call   801837 <fsipc>
  801a45:	89 c3                	mov    %eax,%ebx
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	79 14                	jns    801a62 <open+0x6f>
		fd_close(fd, 0);
  801a4e:	83 ec 08             	sub    $0x8,%esp
  801a51:	6a 00                	push   $0x0
  801a53:	ff 75 f4             	pushl  -0xc(%ebp)
  801a56:	e8 4c f9 ff ff       	call   8013a7 <fd_close>
		return r;
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	89 da                	mov    %ebx,%edx
  801a60:	eb 17                	jmp    801a79 <open+0x86>
	}

	return fd2num(fd);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	ff 75 f4             	pushl  -0xc(%ebp)
  801a68:	e8 1b f8 ff ff       	call   801288 <fd2num>
  801a6d:	89 c2                	mov    %eax,%edx
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	eb 05                	jmp    801a79 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a74:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a79:	89 d0                	mov    %edx,%eax
  801a7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a86:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a90:	e8 a2 fd ff ff       	call   801837 <fsipc>
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a9d:	68 0f 30 80 00       	push   $0x80300f
  801aa2:	ff 75 0c             	pushl  0xc(%ebp)
  801aa5:	e8 aa f1 ff ff       	call   800c54 <strcpy>
	return 0;
}
  801aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 10             	sub    $0x10,%esp
  801ab8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801abb:	53                   	push   %ebx
  801abc:	e8 a4 0c 00 00       	call   802765 <pageref>
  801ac1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ac9:	83 f8 01             	cmp    $0x1,%eax
  801acc:	75 10                	jne    801ade <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	ff 73 0c             	pushl  0xc(%ebx)
  801ad4:	e8 c0 02 00 00       	call   801d99 <nsipc_close>
  801ad9:	89 c2                	mov    %eax,%edx
  801adb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ade:	89 d0                	mov    %edx,%eax
  801ae0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aeb:	6a 00                	push   $0x0
  801aed:	ff 75 10             	pushl  0x10(%ebp)
  801af0:	ff 75 0c             	pushl  0xc(%ebp)
  801af3:	8b 45 08             	mov    0x8(%ebp),%eax
  801af6:	ff 70 0c             	pushl  0xc(%eax)
  801af9:	e8 78 03 00 00       	call   801e76 <nsipc_send>
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b06:	6a 00                	push   $0x0
  801b08:	ff 75 10             	pushl  0x10(%ebp)
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	ff 70 0c             	pushl  0xc(%eax)
  801b14:	e8 f1 02 00 00       	call   801e0a <nsipc_recv>
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b21:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b24:	52                   	push   %edx
  801b25:	50                   	push   %eax
  801b26:	e8 d3 f7 ff ff       	call   8012fe <fd_lookup>
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	78 17                	js     801b49 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b35:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  801b3b:	39 08                	cmp    %ecx,(%eax)
  801b3d:	75 05                	jne    801b44 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b42:	eb 05                	jmp    801b49 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	56                   	push   %esi
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 1c             	sub    $0x1c,%esp
  801b53:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b58:	50                   	push   %eax
  801b59:	e8 51 f7 ff ff       	call   8012af <fd_alloc>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 1b                	js     801b82 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b67:	83 ec 04             	sub    $0x4,%esp
  801b6a:	68 07 04 00 00       	push   $0x407
  801b6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b72:	6a 00                	push   $0x0
  801b74:	e8 de f4 ff ff       	call   801057 <sys_page_alloc>
  801b79:	89 c3                	mov    %eax,%ebx
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	79 10                	jns    801b92 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	56                   	push   %esi
  801b86:	e8 0e 02 00 00       	call   801d99 <nsipc_close>
		return r;
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	89 d8                	mov    %ebx,%eax
  801b90:	eb 24                	jmp    801bb6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b92:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ba7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	50                   	push   %eax
  801bae:	e8 d5 f6 ff ff       	call   801288 <fd2num>
  801bb3:	83 c4 10             	add    $0x10,%esp
}
  801bb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc6:	e8 50 ff ff ff       	call   801b1b <fd2sockid>
		return r;
  801bcb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 1f                	js     801bf0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bd1:	83 ec 04             	sub    $0x4,%esp
  801bd4:	ff 75 10             	pushl  0x10(%ebp)
  801bd7:	ff 75 0c             	pushl  0xc(%ebp)
  801bda:	50                   	push   %eax
  801bdb:	e8 12 01 00 00       	call   801cf2 <nsipc_accept>
  801be0:	83 c4 10             	add    $0x10,%esp
		return r;
  801be3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 07                	js     801bf0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801be9:	e8 5d ff ff ff       	call   801b4b <alloc_sockfd>
  801bee:	89 c1                	mov    %eax,%ecx
}
  801bf0:	89 c8                	mov    %ecx,%eax
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    

00801bf4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	e8 19 ff ff ff       	call   801b1b <fd2sockid>
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 12                	js     801c18 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c06:	83 ec 04             	sub    $0x4,%esp
  801c09:	ff 75 10             	pushl  0x10(%ebp)
  801c0c:	ff 75 0c             	pushl  0xc(%ebp)
  801c0f:	50                   	push   %eax
  801c10:	e8 2d 01 00 00       	call   801d42 <nsipc_bind>
  801c15:	83 c4 10             	add    $0x10,%esp
}
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    

00801c1a <shutdown>:

int
shutdown(int s, int how)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c20:	8b 45 08             	mov    0x8(%ebp),%eax
  801c23:	e8 f3 fe ff ff       	call   801b1b <fd2sockid>
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	78 0f                	js     801c3b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c2c:	83 ec 08             	sub    $0x8,%esp
  801c2f:	ff 75 0c             	pushl  0xc(%ebp)
  801c32:	50                   	push   %eax
  801c33:	e8 3f 01 00 00       	call   801d77 <nsipc_shutdown>
  801c38:	83 c4 10             	add    $0x10,%esp
}
  801c3b:	c9                   	leave  
  801c3c:	c3                   	ret    

00801c3d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	e8 d0 fe ff ff       	call   801b1b <fd2sockid>
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 12                	js     801c61 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c4f:	83 ec 04             	sub    $0x4,%esp
  801c52:	ff 75 10             	pushl  0x10(%ebp)
  801c55:	ff 75 0c             	pushl  0xc(%ebp)
  801c58:	50                   	push   %eax
  801c59:	e8 55 01 00 00       	call   801db3 <nsipc_connect>
  801c5e:	83 c4 10             	add    $0x10,%esp
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <listen>:

int
listen(int s, int backlog)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c69:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6c:	e8 aa fe ff ff       	call   801b1b <fd2sockid>
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 0f                	js     801c84 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c75:	83 ec 08             	sub    $0x8,%esp
  801c78:	ff 75 0c             	pushl  0xc(%ebp)
  801c7b:	50                   	push   %eax
  801c7c:	e8 67 01 00 00       	call   801de8 <nsipc_listen>
  801c81:	83 c4 10             	add    $0x10,%esp
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c8c:	ff 75 10             	pushl  0x10(%ebp)
  801c8f:	ff 75 0c             	pushl  0xc(%ebp)
  801c92:	ff 75 08             	pushl  0x8(%ebp)
  801c95:	e8 3a 02 00 00       	call   801ed4 <nsipc_socket>
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 05                	js     801ca6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ca1:	e8 a5 fe ff ff       	call   801b4b <alloc_sockfd>
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	53                   	push   %ebx
  801cac:	83 ec 04             	sub    $0x4,%esp
  801caf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cb1:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  801cb8:	75 12                	jne    801ccc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cba:	83 ec 0c             	sub    $0xc,%esp
  801cbd:	6a 02                	push   $0x2
  801cbf:	e8 68 0a 00 00       	call   80272c <ipc_find_env>
  801cc4:	a3 14 50 80 00       	mov    %eax,0x805014
  801cc9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ccc:	6a 07                	push   $0x7
  801cce:	68 00 70 80 00       	push   $0x807000
  801cd3:	53                   	push   %ebx
  801cd4:	ff 35 14 50 80 00    	pushl  0x805014
  801cda:	e8 f9 09 00 00       	call   8026d8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cdf:	83 c4 0c             	add    $0xc,%esp
  801ce2:	6a 00                	push   $0x0
  801ce4:	6a 00                	push   $0x0
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 7e 09 00 00       	call   80266b <ipc_recv>
}
  801ced:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
  801cf7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d02:	8b 06                	mov    (%esi),%eax
  801d04:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d09:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0e:	e8 95 ff ff ff       	call   801ca8 <nsipc>
  801d13:	89 c3                	mov    %eax,%ebx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 20                	js     801d39 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d19:	83 ec 04             	sub    $0x4,%esp
  801d1c:	ff 35 10 70 80 00    	pushl  0x807010
  801d22:	68 00 70 80 00       	push   $0x807000
  801d27:	ff 75 0c             	pushl  0xc(%ebp)
  801d2a:	e8 b7 f0 ff ff       	call   800de6 <memmove>
		*addrlen = ret->ret_addrlen;
  801d2f:	a1 10 70 80 00       	mov    0x807010,%eax
  801d34:	89 06                	mov    %eax,(%esi)
  801d36:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d39:	89 d8                	mov    %ebx,%eax
  801d3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3e:	5b                   	pop    %ebx
  801d3f:	5e                   	pop    %esi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    

00801d42 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	53                   	push   %ebx
  801d46:	83 ec 08             	sub    $0x8,%esp
  801d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d54:	53                   	push   %ebx
  801d55:	ff 75 0c             	pushl  0xc(%ebp)
  801d58:	68 04 70 80 00       	push   $0x807004
  801d5d:	e8 84 f0 ff ff       	call   800de6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d62:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801d68:	b8 02 00 00 00       	mov    $0x2,%eax
  801d6d:	e8 36 ff ff ff       	call   801ca8 <nsipc>
}
  801d72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d88:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d8d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d92:	e8 11 ff ff ff       	call   801ca8 <nsipc>
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <nsipc_close>:

int
nsipc_close(int s)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801da2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801da7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dac:	e8 f7 fe ff ff       	call   801ca8 <nsipc>
}
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	53                   	push   %ebx
  801db7:	83 ec 08             	sub    $0x8,%esp
  801dba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dc5:	53                   	push   %ebx
  801dc6:	ff 75 0c             	pushl  0xc(%ebp)
  801dc9:	68 04 70 80 00       	push   $0x807004
  801dce:	e8 13 f0 ff ff       	call   800de6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dd3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801dd9:	b8 05 00 00 00       	mov    $0x5,%eax
  801dde:	e8 c5 fe ff ff       	call   801ca8 <nsipc>
}
  801de3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df9:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801dfe:	b8 06 00 00 00       	mov    $0x6,%eax
  801e03:	e8 a0 fe ff ff       	call   801ca8 <nsipc>
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	56                   	push   %esi
  801e0e:	53                   	push   %ebx
  801e0f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e12:	8b 45 08             	mov    0x8(%ebp),%eax
  801e15:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801e1a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801e20:	8b 45 14             	mov    0x14(%ebp),%eax
  801e23:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e28:	b8 07 00 00 00       	mov    $0x7,%eax
  801e2d:	e8 76 fe ff ff       	call   801ca8 <nsipc>
  801e32:	89 c3                	mov    %eax,%ebx
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 35                	js     801e6d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e38:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e3d:	7f 04                	jg     801e43 <nsipc_recv+0x39>
  801e3f:	39 c6                	cmp    %eax,%esi
  801e41:	7d 16                	jge    801e59 <nsipc_recv+0x4f>
  801e43:	68 1b 30 80 00       	push   $0x80301b
  801e48:	68 e3 2f 80 00       	push   $0x802fe3
  801e4d:	6a 62                	push   $0x62
  801e4f:	68 30 30 80 00       	push   $0x803030
  801e54:	e8 9d e7 ff ff       	call   8005f6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e59:	83 ec 04             	sub    $0x4,%esp
  801e5c:	50                   	push   %eax
  801e5d:	68 00 70 80 00       	push   $0x807000
  801e62:	ff 75 0c             	pushl  0xc(%ebp)
  801e65:	e8 7c ef ff ff       	call   800de6 <memmove>
  801e6a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e6d:	89 d8                	mov    %ebx,%eax
  801e6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e72:	5b                   	pop    %ebx
  801e73:	5e                   	pop    %esi
  801e74:	5d                   	pop    %ebp
  801e75:	c3                   	ret    

00801e76 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	53                   	push   %ebx
  801e7a:	83 ec 04             	sub    $0x4,%esp
  801e7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e80:	8b 45 08             	mov    0x8(%ebp),%eax
  801e83:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e88:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e8e:	7e 16                	jle    801ea6 <nsipc_send+0x30>
  801e90:	68 3c 30 80 00       	push   $0x80303c
  801e95:	68 e3 2f 80 00       	push   $0x802fe3
  801e9a:	6a 6d                	push   $0x6d
  801e9c:	68 30 30 80 00       	push   $0x803030
  801ea1:	e8 50 e7 ff ff       	call   8005f6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ea6:	83 ec 04             	sub    $0x4,%esp
  801ea9:	53                   	push   %ebx
  801eaa:	ff 75 0c             	pushl  0xc(%ebp)
  801ead:	68 0c 70 80 00       	push   $0x80700c
  801eb2:	e8 2f ef ff ff       	call   800de6 <memmove>
	nsipcbuf.send.req_size = size;
  801eb7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801ebd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ec5:	b8 08 00 00 00       	mov    $0x8,%eax
  801eca:	e8 d9 fd ff ff       	call   801ca8 <nsipc>
}
  801ecf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    

00801ed4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee5:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801eea:	8b 45 10             	mov    0x10(%ebp),%eax
  801eed:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801ef2:	b8 09 00 00 00       	mov    $0x9,%eax
  801ef7:	e8 ac fd ff ff       	call   801ca8 <nsipc>
}
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <free>:
	return v;
}

void
free(void *v)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	53                   	push   %ebx
  801f02:	83 ec 04             	sub    $0x4,%esp
  801f05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  801f08:	85 db                	test   %ebx,%ebx
  801f0a:	0f 84 97 00 00 00    	je     801fa7 <free+0xa9>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  801f10:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  801f16:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  801f1b:	76 16                	jbe    801f33 <free+0x35>
  801f1d:	68 48 30 80 00       	push   $0x803048
  801f22:	68 e3 2f 80 00       	push   $0x802fe3
  801f27:	6a 7a                	push   $0x7a
  801f29:	68 78 30 80 00       	push   $0x803078
  801f2e:	e8 c3 e6 ff ff       	call   8005f6 <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  801f33:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  801f39:	eb 3a                	jmp    801f75 <free+0x77>
		sys_page_unmap(0, c);
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	53                   	push   %ebx
  801f3f:	6a 00                	push   $0x0
  801f41:	e8 96 f1 ff ff       	call   8010dc <sys_page_unmap>
		c += PGSIZE;
  801f46:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  801f4c:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  801f5a:	76 19                	jbe    801f75 <free+0x77>
  801f5c:	68 85 30 80 00       	push   $0x803085
  801f61:	68 e3 2f 80 00       	push   $0x802fe3
  801f66:	68 81 00 00 00       	push   $0x81
  801f6b:	68 78 30 80 00       	push   $0x803078
  801f70:	e8 81 e6 ff ff       	call   8005f6 <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  801f75:	89 d8                	mov    %ebx,%eax
  801f77:	c1 e8 0c             	shr    $0xc,%eax
  801f7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f81:	f6 c4 02             	test   $0x2,%ah
  801f84:	75 b5                	jne    801f3b <free+0x3d>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  801f86:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  801f8c:	83 e8 01             	sub    $0x1,%eax
  801f8f:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  801f95:	85 c0                	test   %eax,%eax
  801f97:	75 0e                	jne    801fa7 <free+0xa9>
		sys_page_unmap(0, c);
  801f99:	83 ec 08             	sub    $0x8,%esp
  801f9c:	53                   	push   %ebx
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 38 f1 ff ff       	call   8010dc <sys_page_unmap>
  801fa4:	83 c4 10             	add    $0x10,%esp
}
  801fa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	57                   	push   %edi
  801fb0:	56                   	push   %esi
  801fb1:	53                   	push   %ebx
  801fb2:	83 ec 1c             	sub    $0x1c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  801fb5:	a1 18 50 80 00       	mov    0x805018,%eax
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	75 22                	jne    801fe0 <malloc+0x34>
		mptr = mbegin;
  801fbe:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  801fc5:	00 00 08 

	n = ROUNDUP(n, 4);
  801fc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcb:	83 c0 03             	add    $0x3,%eax
  801fce:	83 e0 fc             	and    $0xfffffffc,%eax
  801fd1:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if (n >= MAXMALLOC)
  801fd4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  801fd9:	76 74                	jbe    80204f <malloc+0xa3>
  801fdb:	e9 7a 01 00 00       	jmp    80215a <malloc+0x1ae>
	void *v;

	if (mptr == 0)
		mptr = mbegin;

	n = ROUNDUP(n, 4);
  801fe0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801fe3:	8d 53 03             	lea    0x3(%ebx),%edx
  801fe6:	83 e2 fc             	and    $0xfffffffc,%edx
  801fe9:	89 55 dc             	mov    %edx,-0x24(%ebp)

	if (n >= MAXMALLOC)
  801fec:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  801ff2:	0f 87 69 01 00 00    	ja     802161 <malloc+0x1b5>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  801ff8:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801ffd:	74 50                	je     80204f <malloc+0xa3>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  801fff:	89 c1                	mov    %eax,%ecx
  802001:	c1 e9 0c             	shr    $0xc,%ecx
  802004:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  802008:	c1 ea 0c             	shr    $0xc,%edx
  80200b:	39 d1                	cmp    %edx,%ecx
  80200d:	75 20                	jne    80202f <malloc+0x83>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  80200f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  802015:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  80201b:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  80201f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802022:	01 c2                	add    %eax,%edx
  802024:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  80202a:	e9 55 01 00 00       	jmp    802184 <malloc+0x1d8>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  80202f:	83 ec 0c             	sub    $0xc,%esp
  802032:	50                   	push   %eax
  802033:	e8 c6 fe ff ff       	call   801efe <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802038:	a1 18 50 80 00       	mov    0x805018,%eax
  80203d:	05 00 10 00 00       	add    $0x1000,%eax
  802042:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802047:	a3 18 50 80 00       	mov    %eax,0x805018
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	8b 35 18 50 80 00    	mov    0x805018,%esi
	return 1;
}

void*
malloc(size_t n)
{
  802055:	c7 45 d8 02 00 00 00 	movl   $0x2,-0x28(%ebp)
  80205c:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802060:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802063:	8d 78 04             	lea    0x4(%eax),%edi
  802066:	89 75 e0             	mov    %esi,-0x20(%ebp)
  802069:	89 fb                	mov    %edi,%ebx
  80206b:	8d 0c 37             	lea    (%edi,%esi,1),%ecx
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80206e:	89 f0                	mov    %esi,%eax
  802070:	eb 36                	jmp    8020a8 <malloc+0xfc>
		if (va >= (uintptr_t) mend
  802072:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  802077:	0f 87 eb 00 00 00    	ja     802168 <malloc+0x1bc>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  80207d:	89 c2                	mov    %eax,%edx
  80207f:	c1 ea 16             	shr    $0x16,%edx
  802082:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802089:	f6 c2 01             	test   $0x1,%dl
  80208c:	74 15                	je     8020a3 <malloc+0xf7>
  80208e:	89 c2                	mov    %eax,%edx
  802090:	c1 ea 0c             	shr    $0xc,%edx
  802093:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80209a:	f6 c2 01             	test   $0x1,%dl
  80209d:	0f 85 c5 00 00 00    	jne    802168 <malloc+0x1bc>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8020a3:	05 00 10 00 00       	add    $0x1000,%eax
  8020a8:	39 c8                	cmp    %ecx,%eax
  8020aa:	72 c6                	jb     802072 <malloc+0xc6>
  8020ac:	eb 79                	jmp    802127 <malloc+0x17b>
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  8020ae:	be 00 00 00 08       	mov    $0x8000000,%esi
  8020b3:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
			if (++nwrap == 2)
  8020b7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8020bb:	75 a9                	jne    802066 <malloc+0xba>
  8020bd:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8020c4:	00 00 08 
				return 0;	/* out of address space */
  8020c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020cc:	e9 b3 00 00 00       	jmp    802184 <malloc+0x1d8>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8020d1:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  8020d7:	39 df                	cmp    %ebx,%edi
  8020d9:	19 c0                	sbb    %eax,%eax
  8020db:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8020e0:	83 ec 04             	sub    $0x4,%esp
  8020e3:	83 c8 07             	or     $0x7,%eax
  8020e6:	50                   	push   %eax
  8020e7:	03 15 18 50 80 00    	add    0x805018,%edx
  8020ed:	52                   	push   %edx
  8020ee:	6a 00                	push   $0x0
  8020f0:	e8 62 ef ff ff       	call   801057 <sys_page_alloc>
  8020f5:	83 c4 10             	add    $0x10,%esp
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	78 20                	js     80211c <malloc+0x170>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  8020fc:	89 fe                	mov    %edi,%esi
  8020fe:	eb 3a                	jmp    80213a <malloc+0x18e>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  802100:	83 ec 08             	sub    $0x8,%esp
  802103:	89 f0                	mov    %esi,%eax
  802105:	03 05 18 50 80 00    	add    0x805018,%eax
  80210b:	50                   	push   %eax
  80210c:	6a 00                	push   $0x0
  80210e:	e8 c9 ef ff ff       	call   8010dc <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802113:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	85 f6                	test   %esi,%esi
  80211e:	79 e0                	jns    802100 <malloc+0x154>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  802120:	b8 00 00 00 00       	mov    $0x0,%eax
  802125:	eb 5d                	jmp    802184 <malloc+0x1d8>
  802127:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80212b:	74 08                	je     802135 <malloc+0x189>
  80212d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802130:	a3 18 50 80 00       	mov    %eax,0x805018

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  802135:	be 00 00 00 00       	mov    $0x0,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  80213a:	89 f2                	mov    %esi,%edx
  80213c:	39 f3                	cmp    %esi,%ebx
  80213e:	77 91                	ja     8020d1 <malloc+0x125>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  802140:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802145:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  80214c:	00 
	v = mptr;
	mptr += n;
  80214d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802150:	01 c2                	add    %eax,%edx
  802152:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  802158:	eb 2a                	jmp    802184 <malloc+0x1d8>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  80215a:	b8 00 00 00 00       	mov    $0x0,%eax
  80215f:	eb 23                	jmp    802184 <malloc+0x1d8>
  802161:	b8 00 00 00 00       	mov    $0x0,%eax
  802166:	eb 1c                	jmp    802184 <malloc+0x1d8>
  802168:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
  80216e:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
  802172:	89 c6                	mov    %eax,%esi
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  802174:	3d 00 00 00 10       	cmp    $0x10000000,%eax
  802179:	0f 85 e7 fe ff ff    	jne    802066 <malloc+0xba>
  80217f:	e9 2a ff ff ff       	jmp    8020ae <malloc+0x102>
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  802184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    

0080218c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	56                   	push   %esi
  802190:	53                   	push   %ebx
  802191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802194:	83 ec 0c             	sub    $0xc,%esp
  802197:	ff 75 08             	pushl  0x8(%ebp)
  80219a:	e8 f9 f0 ff ff       	call   801298 <fd2data>
  80219f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021a1:	83 c4 08             	add    $0x8,%esp
  8021a4:	68 9d 30 80 00       	push   $0x80309d
  8021a9:	53                   	push   %ebx
  8021aa:	e8 a5 ea ff ff       	call   800c54 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021af:	8b 46 04             	mov    0x4(%esi),%eax
  8021b2:	2b 06                	sub    (%esi),%eax
  8021b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021ba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021c1:	00 00 00 
	stat->st_dev = &devpipe;
  8021c4:	c7 83 88 00 00 00 5c 	movl   $0x80405c,0x88(%ebx)
  8021cb:	40 80 00 
	return 0;
}
  8021ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021d6:	5b                   	pop    %ebx
  8021d7:	5e                   	pop    %esi
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    

008021da <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021da:	55                   	push   %ebp
  8021db:	89 e5                	mov    %esp,%ebp
  8021dd:	53                   	push   %ebx
  8021de:	83 ec 0c             	sub    $0xc,%esp
  8021e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021e4:	53                   	push   %ebx
  8021e5:	6a 00                	push   $0x0
  8021e7:	e8 f0 ee ff ff       	call   8010dc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021ec:	89 1c 24             	mov    %ebx,(%esp)
  8021ef:	e8 a4 f0 ff ff       	call   801298 <fd2data>
  8021f4:	83 c4 08             	add    $0x8,%esp
  8021f7:	50                   	push   %eax
  8021f8:	6a 00                	push   $0x0
  8021fa:	e8 dd ee ff ff       	call   8010dc <sys_page_unmap>
}
  8021ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802202:	c9                   	leave  
  802203:	c3                   	ret    

00802204 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	57                   	push   %edi
  802208:	56                   	push   %esi
  802209:	53                   	push   %ebx
  80220a:	83 ec 1c             	sub    $0x1c,%esp
  80220d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802210:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802212:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802217:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80221a:	83 ec 0c             	sub    $0xc,%esp
  80221d:	ff 75 e0             	pushl  -0x20(%ebp)
  802220:	e8 40 05 00 00       	call   802765 <pageref>
  802225:	89 c3                	mov    %eax,%ebx
  802227:	89 3c 24             	mov    %edi,(%esp)
  80222a:	e8 36 05 00 00       	call   802765 <pageref>
  80222f:	83 c4 10             	add    $0x10,%esp
  802232:	39 c3                	cmp    %eax,%ebx
  802234:	0f 94 c1             	sete   %cl
  802237:	0f b6 c9             	movzbl %cl,%ecx
  80223a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80223d:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802243:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802246:	39 ce                	cmp    %ecx,%esi
  802248:	74 1b                	je     802265 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80224a:	39 c3                	cmp    %eax,%ebx
  80224c:	75 c4                	jne    802212 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80224e:	8b 42 58             	mov    0x58(%edx),%eax
  802251:	ff 75 e4             	pushl  -0x1c(%ebp)
  802254:	50                   	push   %eax
  802255:	56                   	push   %esi
  802256:	68 a4 30 80 00       	push   $0x8030a4
  80225b:	e8 6f e4 ff ff       	call   8006cf <cprintf>
  802260:	83 c4 10             	add    $0x10,%esp
  802263:	eb ad                	jmp    802212 <_pipeisclosed+0xe>
	}
}
  802265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80226b:	5b                   	pop    %ebx
  80226c:	5e                   	pop    %esi
  80226d:	5f                   	pop    %edi
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	57                   	push   %edi
  802274:	56                   	push   %esi
  802275:	53                   	push   %ebx
  802276:	83 ec 28             	sub    $0x28,%esp
  802279:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80227c:	56                   	push   %esi
  80227d:	e8 16 f0 ff ff       	call   801298 <fd2data>
  802282:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802284:	83 c4 10             	add    $0x10,%esp
  802287:	bf 00 00 00 00       	mov    $0x0,%edi
  80228c:	eb 4b                	jmp    8022d9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80228e:	89 da                	mov    %ebx,%edx
  802290:	89 f0                	mov    %esi,%eax
  802292:	e8 6d ff ff ff       	call   802204 <_pipeisclosed>
  802297:	85 c0                	test   %eax,%eax
  802299:	75 48                	jne    8022e3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80229b:	e8 98 ed ff ff       	call   801038 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8022a3:	8b 0b                	mov    (%ebx),%ecx
  8022a5:	8d 51 20             	lea    0x20(%ecx),%edx
  8022a8:	39 d0                	cmp    %edx,%eax
  8022aa:	73 e2                	jae    80228e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022af:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022b3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022b6:	89 c2                	mov    %eax,%edx
  8022b8:	c1 fa 1f             	sar    $0x1f,%edx
  8022bb:	89 d1                	mov    %edx,%ecx
  8022bd:	c1 e9 1b             	shr    $0x1b,%ecx
  8022c0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022c3:	83 e2 1f             	and    $0x1f,%edx
  8022c6:	29 ca                	sub    %ecx,%edx
  8022c8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022d0:	83 c0 01             	add    $0x1,%eax
  8022d3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022d6:	83 c7 01             	add    $0x1,%edi
  8022d9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022dc:	75 c2                	jne    8022a0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022de:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e1:	eb 05                	jmp    8022e8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022e3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022eb:	5b                   	pop    %ebx
  8022ec:	5e                   	pop    %esi
  8022ed:	5f                   	pop    %edi
  8022ee:	5d                   	pop    %ebp
  8022ef:	c3                   	ret    

008022f0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	57                   	push   %edi
  8022f4:	56                   	push   %esi
  8022f5:	53                   	push   %ebx
  8022f6:	83 ec 18             	sub    $0x18,%esp
  8022f9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022fc:	57                   	push   %edi
  8022fd:	e8 96 ef ff ff       	call   801298 <fd2data>
  802302:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802304:	83 c4 10             	add    $0x10,%esp
  802307:	bb 00 00 00 00       	mov    $0x0,%ebx
  80230c:	eb 3d                	jmp    80234b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80230e:	85 db                	test   %ebx,%ebx
  802310:	74 04                	je     802316 <devpipe_read+0x26>
				return i;
  802312:	89 d8                	mov    %ebx,%eax
  802314:	eb 44                	jmp    80235a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802316:	89 f2                	mov    %esi,%edx
  802318:	89 f8                	mov    %edi,%eax
  80231a:	e8 e5 fe ff ff       	call   802204 <_pipeisclosed>
  80231f:	85 c0                	test   %eax,%eax
  802321:	75 32                	jne    802355 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802323:	e8 10 ed ff ff       	call   801038 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802328:	8b 06                	mov    (%esi),%eax
  80232a:	3b 46 04             	cmp    0x4(%esi),%eax
  80232d:	74 df                	je     80230e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80232f:	99                   	cltd   
  802330:	c1 ea 1b             	shr    $0x1b,%edx
  802333:	01 d0                	add    %edx,%eax
  802335:	83 e0 1f             	and    $0x1f,%eax
  802338:	29 d0                	sub    %edx,%eax
  80233a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80233f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802342:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802345:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802348:	83 c3 01             	add    $0x1,%ebx
  80234b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80234e:	75 d8                	jne    802328 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802350:	8b 45 10             	mov    0x10(%ebp),%eax
  802353:	eb 05                	jmp    80235a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802355:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80235a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    

00802362 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802362:	55                   	push   %ebp
  802363:	89 e5                	mov    %esp,%ebp
  802365:	56                   	push   %esi
  802366:	53                   	push   %ebx
  802367:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80236a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236d:	50                   	push   %eax
  80236e:	e8 3c ef ff ff       	call   8012af <fd_alloc>
  802373:	83 c4 10             	add    $0x10,%esp
  802376:	89 c2                	mov    %eax,%edx
  802378:	85 c0                	test   %eax,%eax
  80237a:	0f 88 2c 01 00 00    	js     8024ac <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802380:	83 ec 04             	sub    $0x4,%esp
  802383:	68 07 04 00 00       	push   $0x407
  802388:	ff 75 f4             	pushl  -0xc(%ebp)
  80238b:	6a 00                	push   $0x0
  80238d:	e8 c5 ec ff ff       	call   801057 <sys_page_alloc>
  802392:	83 c4 10             	add    $0x10,%esp
  802395:	89 c2                	mov    %eax,%edx
  802397:	85 c0                	test   %eax,%eax
  802399:	0f 88 0d 01 00 00    	js     8024ac <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80239f:	83 ec 0c             	sub    $0xc,%esp
  8023a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023a5:	50                   	push   %eax
  8023a6:	e8 04 ef ff ff       	call   8012af <fd_alloc>
  8023ab:	89 c3                	mov    %eax,%ebx
  8023ad:	83 c4 10             	add    $0x10,%esp
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	0f 88 e2 00 00 00    	js     80249a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023b8:	83 ec 04             	sub    $0x4,%esp
  8023bb:	68 07 04 00 00       	push   $0x407
  8023c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8023c3:	6a 00                	push   $0x0
  8023c5:	e8 8d ec ff ff       	call   801057 <sys_page_alloc>
  8023ca:	89 c3                	mov    %eax,%ebx
  8023cc:	83 c4 10             	add    $0x10,%esp
  8023cf:	85 c0                	test   %eax,%eax
  8023d1:	0f 88 c3 00 00 00    	js     80249a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023d7:	83 ec 0c             	sub    $0xc,%esp
  8023da:	ff 75 f4             	pushl  -0xc(%ebp)
  8023dd:	e8 b6 ee ff ff       	call   801298 <fd2data>
  8023e2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e4:	83 c4 0c             	add    $0xc,%esp
  8023e7:	68 07 04 00 00       	push   $0x407
  8023ec:	50                   	push   %eax
  8023ed:	6a 00                	push   $0x0
  8023ef:	e8 63 ec ff ff       	call   801057 <sys_page_alloc>
  8023f4:	89 c3                	mov    %eax,%ebx
  8023f6:	83 c4 10             	add    $0x10,%esp
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	0f 88 89 00 00 00    	js     80248a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802401:	83 ec 0c             	sub    $0xc,%esp
  802404:	ff 75 f0             	pushl  -0x10(%ebp)
  802407:	e8 8c ee ff ff       	call   801298 <fd2data>
  80240c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802413:	50                   	push   %eax
  802414:	6a 00                	push   $0x0
  802416:	56                   	push   %esi
  802417:	6a 00                	push   $0x0
  802419:	e8 7c ec ff ff       	call   80109a <sys_page_map>
  80241e:	89 c3                	mov    %eax,%ebx
  802420:	83 c4 20             	add    $0x20,%esp
  802423:	85 c0                	test   %eax,%eax
  802425:	78 55                	js     80247c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802427:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80242d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802430:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802435:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80243c:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802445:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802447:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80244a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802451:	83 ec 0c             	sub    $0xc,%esp
  802454:	ff 75 f4             	pushl  -0xc(%ebp)
  802457:	e8 2c ee ff ff       	call   801288 <fd2num>
  80245c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80245f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802461:	83 c4 04             	add    $0x4,%esp
  802464:	ff 75 f0             	pushl  -0x10(%ebp)
  802467:	e8 1c ee ff ff       	call   801288 <fd2num>
  80246c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80246f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	ba 00 00 00 00       	mov    $0x0,%edx
  80247a:	eb 30                	jmp    8024ac <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80247c:	83 ec 08             	sub    $0x8,%esp
  80247f:	56                   	push   %esi
  802480:	6a 00                	push   $0x0
  802482:	e8 55 ec ff ff       	call   8010dc <sys_page_unmap>
  802487:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80248a:	83 ec 08             	sub    $0x8,%esp
  80248d:	ff 75 f0             	pushl  -0x10(%ebp)
  802490:	6a 00                	push   $0x0
  802492:	e8 45 ec ff ff       	call   8010dc <sys_page_unmap>
  802497:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80249a:	83 ec 08             	sub    $0x8,%esp
  80249d:	ff 75 f4             	pushl  -0xc(%ebp)
  8024a0:	6a 00                	push   $0x0
  8024a2:	e8 35 ec ff ff       	call   8010dc <sys_page_unmap>
  8024a7:	83 c4 10             	add    $0x10,%esp
  8024aa:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8024ac:	89 d0                	mov    %edx,%eax
  8024ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b1:	5b                   	pop    %ebx
  8024b2:	5e                   	pop    %esi
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    

008024b5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024be:	50                   	push   %eax
  8024bf:	ff 75 08             	pushl  0x8(%ebp)
  8024c2:	e8 37 ee ff ff       	call   8012fe <fd_lookup>
  8024c7:	83 c4 10             	add    $0x10,%esp
  8024ca:	85 c0                	test   %eax,%eax
  8024cc:	78 18                	js     8024e6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024ce:	83 ec 0c             	sub    $0xc,%esp
  8024d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8024d4:	e8 bf ed ff ff       	call   801298 <fd2data>
	return _pipeisclosed(fd, p);
  8024d9:	89 c2                	mov    %eax,%edx
  8024db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024de:	e8 21 fd ff ff       	call   802204 <_pipeisclosed>
  8024e3:	83 c4 10             	add    $0x10,%esp
}
  8024e6:	c9                   	leave  
  8024e7:	c3                   	ret    

008024e8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024e8:	55                   	push   %ebp
  8024e9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    

008024f2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024f2:	55                   	push   %ebp
  8024f3:	89 e5                	mov    %esp,%ebp
  8024f5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8024f8:	68 bc 30 80 00       	push   $0x8030bc
  8024fd:	ff 75 0c             	pushl  0xc(%ebp)
  802500:	e8 4f e7 ff ff       	call   800c54 <strcpy>
	return 0;
}
  802505:	b8 00 00 00 00       	mov    $0x0,%eax
  80250a:	c9                   	leave  
  80250b:	c3                   	ret    

0080250c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80250c:	55                   	push   %ebp
  80250d:	89 e5                	mov    %esp,%ebp
  80250f:	57                   	push   %edi
  802510:	56                   	push   %esi
  802511:	53                   	push   %ebx
  802512:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802518:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80251d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802523:	eb 2d                	jmp    802552 <devcons_write+0x46>
		m = n - tot;
  802525:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802528:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80252a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80252d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802532:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802535:	83 ec 04             	sub    $0x4,%esp
  802538:	53                   	push   %ebx
  802539:	03 45 0c             	add    0xc(%ebp),%eax
  80253c:	50                   	push   %eax
  80253d:	57                   	push   %edi
  80253e:	e8 a3 e8 ff ff       	call   800de6 <memmove>
		sys_cputs(buf, m);
  802543:	83 c4 08             	add    $0x8,%esp
  802546:	53                   	push   %ebx
  802547:	57                   	push   %edi
  802548:	e8 4e ea ff ff       	call   800f9b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80254d:	01 de                	add    %ebx,%esi
  80254f:	83 c4 10             	add    $0x10,%esp
  802552:	89 f0                	mov    %esi,%eax
  802554:	3b 75 10             	cmp    0x10(%ebp),%esi
  802557:	72 cc                	jb     802525 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802559:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80255c:	5b                   	pop    %ebx
  80255d:	5e                   	pop    %esi
  80255e:	5f                   	pop    %edi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    

00802561 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	83 ec 08             	sub    $0x8,%esp
  802567:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80256c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802570:	74 2a                	je     80259c <devcons_read+0x3b>
  802572:	eb 05                	jmp    802579 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802574:	e8 bf ea ff ff       	call   801038 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802579:	e8 3b ea ff ff       	call   800fb9 <sys_cgetc>
  80257e:	85 c0                	test   %eax,%eax
  802580:	74 f2                	je     802574 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802582:	85 c0                	test   %eax,%eax
  802584:	78 16                	js     80259c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802586:	83 f8 04             	cmp    $0x4,%eax
  802589:	74 0c                	je     802597 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80258b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80258e:	88 02                	mov    %al,(%edx)
	return 1;
  802590:	b8 01 00 00 00       	mov    $0x1,%eax
  802595:	eb 05                	jmp    80259c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802597:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80259c:	c9                   	leave  
  80259d:	c3                   	ret    

0080259e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80259e:	55                   	push   %ebp
  80259f:	89 e5                	mov    %esp,%ebp
  8025a1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8025a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025aa:	6a 01                	push   $0x1
  8025ac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025af:	50                   	push   %eax
  8025b0:	e8 e6 e9 ff ff       	call   800f9b <sys_cputs>
}
  8025b5:	83 c4 10             	add    $0x10,%esp
  8025b8:	c9                   	leave  
  8025b9:	c3                   	ret    

008025ba <getchar>:

int
getchar(void)
{
  8025ba:	55                   	push   %ebp
  8025bb:	89 e5                	mov    %esp,%ebp
  8025bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025c0:	6a 01                	push   $0x1
  8025c2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025c5:	50                   	push   %eax
  8025c6:	6a 00                	push   $0x0
  8025c8:	e8 97 ef ff ff       	call   801564 <read>
	if (r < 0)
  8025cd:	83 c4 10             	add    $0x10,%esp
  8025d0:	85 c0                	test   %eax,%eax
  8025d2:	78 0f                	js     8025e3 <getchar+0x29>
		return r;
	if (r < 1)
  8025d4:	85 c0                	test   %eax,%eax
  8025d6:	7e 06                	jle    8025de <getchar+0x24>
		return -E_EOF;
	return c;
  8025d8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025dc:	eb 05                	jmp    8025e3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025de:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025e3:	c9                   	leave  
  8025e4:	c3                   	ret    

008025e5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025e5:	55                   	push   %ebp
  8025e6:	89 e5                	mov    %esp,%ebp
  8025e8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ee:	50                   	push   %eax
  8025ef:	ff 75 08             	pushl  0x8(%ebp)
  8025f2:	e8 07 ed ff ff       	call   8012fe <fd_lookup>
  8025f7:	83 c4 10             	add    $0x10,%esp
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	78 11                	js     80260f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802601:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802607:	39 10                	cmp    %edx,(%eax)
  802609:	0f 94 c0             	sete   %al
  80260c:	0f b6 c0             	movzbl %al,%eax
}
  80260f:	c9                   	leave  
  802610:	c3                   	ret    

00802611 <opencons>:

int
opencons(void)
{
  802611:	55                   	push   %ebp
  802612:	89 e5                	mov    %esp,%ebp
  802614:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80261a:	50                   	push   %eax
  80261b:	e8 8f ec ff ff       	call   8012af <fd_alloc>
  802620:	83 c4 10             	add    $0x10,%esp
		return r;
  802623:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802625:	85 c0                	test   %eax,%eax
  802627:	78 3e                	js     802667 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802629:	83 ec 04             	sub    $0x4,%esp
  80262c:	68 07 04 00 00       	push   $0x407
  802631:	ff 75 f4             	pushl  -0xc(%ebp)
  802634:	6a 00                	push   $0x0
  802636:	e8 1c ea ff ff       	call   801057 <sys_page_alloc>
  80263b:	83 c4 10             	add    $0x10,%esp
		return r;
  80263e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802640:	85 c0                	test   %eax,%eax
  802642:	78 23                	js     802667 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802644:	8b 15 78 40 80 00    	mov    0x804078,%edx
  80264a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80264f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802652:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802659:	83 ec 0c             	sub    $0xc,%esp
  80265c:	50                   	push   %eax
  80265d:	e8 26 ec ff ff       	call   801288 <fd2num>
  802662:	89 c2                	mov    %eax,%edx
  802664:	83 c4 10             	add    $0x10,%esp
}
  802667:	89 d0                	mov    %edx,%eax
  802669:	c9                   	leave  
  80266a:	c3                   	ret    

0080266b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80266b:	55                   	push   %ebp
  80266c:	89 e5                	mov    %esp,%ebp
  80266e:	56                   	push   %esi
  80266f:	53                   	push   %ebx
  802670:	8b 75 08             	mov    0x8(%ebp),%esi
  802673:	8b 45 0c             	mov    0xc(%ebp),%eax
  802676:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802679:	85 c0                	test   %eax,%eax
  80267b:	74 0e                	je     80268b <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  80267d:	83 ec 0c             	sub    $0xc,%esp
  802680:	50                   	push   %eax
  802681:	e8 81 eb ff ff       	call   801207 <sys_ipc_recv>
  802686:	83 c4 10             	add    $0x10,%esp
  802689:	eb 10                	jmp    80269b <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80268b:	83 ec 0c             	sub    $0xc,%esp
  80268e:	68 00 00 00 f0       	push   $0xf0000000
  802693:	e8 6f eb ff ff       	call   801207 <sys_ipc_recv>
  802698:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80269b:	85 c0                	test   %eax,%eax
  80269d:	74 0e                	je     8026ad <ipc_recv+0x42>
    	*from_env_store = 0;
  80269f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8026a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8026ab:	eb 24                	jmp    8026d1 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8026ad:	85 f6                	test   %esi,%esi
  8026af:	74 0a                	je     8026bb <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8026b1:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8026b6:	8b 40 74             	mov    0x74(%eax),%eax
  8026b9:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8026bb:	85 db                	test   %ebx,%ebx
  8026bd:	74 0a                	je     8026c9 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8026bf:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8026c4:	8b 40 78             	mov    0x78(%eax),%eax
  8026c7:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8026c9:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8026ce:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8026d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    

008026d8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026d8:	55                   	push   %ebp
  8026d9:	89 e5                	mov    %esp,%ebp
  8026db:	57                   	push   %edi
  8026dc:	56                   	push   %esi
  8026dd:	53                   	push   %ebx
  8026de:	83 ec 0c             	sub    $0xc,%esp
  8026e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8026ea:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8026ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8026f1:	0f 44 d8             	cmove  %eax,%ebx
  8026f4:	eb 1c                	jmp    802712 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8026f6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026f9:	74 12                	je     80270d <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8026fb:	50                   	push   %eax
  8026fc:	68 c8 30 80 00       	push   $0x8030c8
  802701:	6a 4b                	push   $0x4b
  802703:	68 e0 30 80 00       	push   $0x8030e0
  802708:	e8 e9 de ff ff       	call   8005f6 <_panic>
        }	
        sys_yield();
  80270d:	e8 26 e9 ff ff       	call   801038 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802712:	ff 75 14             	pushl  0x14(%ebp)
  802715:	53                   	push   %ebx
  802716:	56                   	push   %esi
  802717:	57                   	push   %edi
  802718:	e8 c7 ea ff ff       	call   8011e4 <sys_ipc_try_send>
  80271d:	83 c4 10             	add    $0x10,%esp
  802720:	85 c0                	test   %eax,%eax
  802722:	75 d2                	jne    8026f6 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802727:	5b                   	pop    %ebx
  802728:	5e                   	pop    %esi
  802729:	5f                   	pop    %edi
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    

0080272c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80272c:	55                   	push   %ebp
  80272d:	89 e5                	mov    %esp,%ebp
  80272f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802732:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802737:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80273a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802740:	8b 52 50             	mov    0x50(%edx),%edx
  802743:	39 ca                	cmp    %ecx,%edx
  802745:	75 0d                	jne    802754 <ipc_find_env+0x28>
			return envs[i].env_id;
  802747:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80274a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80274f:	8b 40 48             	mov    0x48(%eax),%eax
  802752:	eb 0f                	jmp    802763 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802754:	83 c0 01             	add    $0x1,%eax
  802757:	3d 00 04 00 00       	cmp    $0x400,%eax
  80275c:	75 d9                	jne    802737 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80275e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802763:	5d                   	pop    %ebp
  802764:	c3                   	ret    

00802765 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802765:	55                   	push   %ebp
  802766:	89 e5                	mov    %esp,%ebp
  802768:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80276b:	89 d0                	mov    %edx,%eax
  80276d:	c1 e8 16             	shr    $0x16,%eax
  802770:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802777:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80277c:	f6 c1 01             	test   $0x1,%cl
  80277f:	74 1d                	je     80279e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802781:	c1 ea 0c             	shr    $0xc,%edx
  802784:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80278b:	f6 c2 01             	test   $0x1,%dl
  80278e:	74 0e                	je     80279e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802790:	c1 ea 0c             	shr    $0xc,%edx
  802793:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80279a:	ef 
  80279b:	0f b7 c0             	movzwl %ax,%eax
}
  80279e:	5d                   	pop    %ebp
  80279f:	c3                   	ret    

008027a0 <__udivdi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 f6                	test   %esi,%esi
  8027b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bd:	89 ca                	mov    %ecx,%edx
  8027bf:	89 f8                	mov    %edi,%eax
  8027c1:	75 3d                	jne    802800 <__udivdi3+0x60>
  8027c3:	39 cf                	cmp    %ecx,%edi
  8027c5:	0f 87 c5 00 00 00    	ja     802890 <__udivdi3+0xf0>
  8027cb:	85 ff                	test   %edi,%edi
  8027cd:	89 fd                	mov    %edi,%ebp
  8027cf:	75 0b                	jne    8027dc <__udivdi3+0x3c>
  8027d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d6:	31 d2                	xor    %edx,%edx
  8027d8:	f7 f7                	div    %edi
  8027da:	89 c5                	mov    %eax,%ebp
  8027dc:	89 c8                	mov    %ecx,%eax
  8027de:	31 d2                	xor    %edx,%edx
  8027e0:	f7 f5                	div    %ebp
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	89 d8                	mov    %ebx,%eax
  8027e6:	89 cf                	mov    %ecx,%edi
  8027e8:	f7 f5                	div    %ebp
  8027ea:	89 c3                	mov    %eax,%ebx
  8027ec:	89 d8                	mov    %ebx,%eax
  8027ee:	89 fa                	mov    %edi,%edx
  8027f0:	83 c4 1c             	add    $0x1c,%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	90                   	nop
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	39 ce                	cmp    %ecx,%esi
  802802:	77 74                	ja     802878 <__udivdi3+0xd8>
  802804:	0f bd fe             	bsr    %esi,%edi
  802807:	83 f7 1f             	xor    $0x1f,%edi
  80280a:	0f 84 98 00 00 00    	je     8028a8 <__udivdi3+0x108>
  802810:	bb 20 00 00 00       	mov    $0x20,%ebx
  802815:	89 f9                	mov    %edi,%ecx
  802817:	89 c5                	mov    %eax,%ebp
  802819:	29 fb                	sub    %edi,%ebx
  80281b:	d3 e6                	shl    %cl,%esi
  80281d:	89 d9                	mov    %ebx,%ecx
  80281f:	d3 ed                	shr    %cl,%ebp
  802821:	89 f9                	mov    %edi,%ecx
  802823:	d3 e0                	shl    %cl,%eax
  802825:	09 ee                	or     %ebp,%esi
  802827:	89 d9                	mov    %ebx,%ecx
  802829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80282d:	89 d5                	mov    %edx,%ebp
  80282f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802833:	d3 ed                	shr    %cl,%ebp
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e2                	shl    %cl,%edx
  802839:	89 d9                	mov    %ebx,%ecx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	09 c2                	or     %eax,%edx
  80283f:	89 d0                	mov    %edx,%eax
  802841:	89 ea                	mov    %ebp,%edx
  802843:	f7 f6                	div    %esi
  802845:	89 d5                	mov    %edx,%ebp
  802847:	89 c3                	mov    %eax,%ebx
  802849:	f7 64 24 0c          	mull   0xc(%esp)
  80284d:	39 d5                	cmp    %edx,%ebp
  80284f:	72 10                	jb     802861 <__udivdi3+0xc1>
  802851:	8b 74 24 08          	mov    0x8(%esp),%esi
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e6                	shl    %cl,%esi
  802859:	39 c6                	cmp    %eax,%esi
  80285b:	73 07                	jae    802864 <__udivdi3+0xc4>
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	75 03                	jne    802864 <__udivdi3+0xc4>
  802861:	83 eb 01             	sub    $0x1,%ebx
  802864:	31 ff                	xor    %edi,%edi
  802866:	89 d8                	mov    %ebx,%eax
  802868:	89 fa                	mov    %edi,%edx
  80286a:	83 c4 1c             	add    $0x1c,%esp
  80286d:	5b                   	pop    %ebx
  80286e:	5e                   	pop    %esi
  80286f:	5f                   	pop    %edi
  802870:	5d                   	pop    %ebp
  802871:	c3                   	ret    
  802872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802878:	31 ff                	xor    %edi,%edi
  80287a:	31 db                	xor    %ebx,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 d8                	mov    %ebx,%eax
  802892:	f7 f7                	div    %edi
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 c3                	mov    %eax,%ebx
  802898:	89 d8                	mov    %ebx,%eax
  80289a:	89 fa                	mov    %edi,%edx
  80289c:	83 c4 1c             	add    $0x1c,%esp
  80289f:	5b                   	pop    %ebx
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    
  8028a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	39 ce                	cmp    %ecx,%esi
  8028aa:	72 0c                	jb     8028b8 <__udivdi3+0x118>
  8028ac:	31 db                	xor    %ebx,%ebx
  8028ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028b2:	0f 87 34 ff ff ff    	ja     8027ec <__udivdi3+0x4c>
  8028b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028bd:	e9 2a ff ff ff       	jmp    8027ec <__udivdi3+0x4c>
  8028c2:	66 90                	xchg   %ax,%ax
  8028c4:	66 90                	xchg   %ax,%ax
  8028c6:	66 90                	xchg   %ax,%ax
  8028c8:	66 90                	xchg   %ax,%ax
  8028ca:	66 90                	xchg   %ax,%ax
  8028cc:	66 90                	xchg   %ax,%ax
  8028ce:	66 90                	xchg   %ax,%ax

008028d0 <__umoddi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	83 ec 1c             	sub    $0x1c,%esp
  8028d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e7:	85 d2                	test   %edx,%edx
  8028e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028f1:	89 f3                	mov    %esi,%ebx
  8028f3:	89 3c 24             	mov    %edi,(%esp)
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	75 1c                	jne    802918 <__umoddi3+0x48>
  8028fc:	39 f7                	cmp    %esi,%edi
  8028fe:	76 50                	jbe    802950 <__umoddi3+0x80>
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	f7 f7                	div    %edi
  802906:	89 d0                	mov    %edx,%eax
  802908:	31 d2                	xor    %edx,%edx
  80290a:	83 c4 1c             	add    $0x1c,%esp
  80290d:	5b                   	pop    %ebx
  80290e:	5e                   	pop    %esi
  80290f:	5f                   	pop    %edi
  802910:	5d                   	pop    %ebp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	39 f2                	cmp    %esi,%edx
  80291a:	89 d0                	mov    %edx,%eax
  80291c:	77 52                	ja     802970 <__umoddi3+0xa0>
  80291e:	0f bd ea             	bsr    %edx,%ebp
  802921:	83 f5 1f             	xor    $0x1f,%ebp
  802924:	75 5a                	jne    802980 <__umoddi3+0xb0>
  802926:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80292a:	0f 82 e0 00 00 00    	jb     802a10 <__umoddi3+0x140>
  802930:	39 0c 24             	cmp    %ecx,(%esp)
  802933:	0f 86 d7 00 00 00    	jbe    802a10 <__umoddi3+0x140>
  802939:	8b 44 24 08          	mov    0x8(%esp),%eax
  80293d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802941:	83 c4 1c             	add    $0x1c,%esp
  802944:	5b                   	pop    %ebx
  802945:	5e                   	pop    %esi
  802946:	5f                   	pop    %edi
  802947:	5d                   	pop    %ebp
  802948:	c3                   	ret    
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	85 ff                	test   %edi,%edi
  802952:	89 fd                	mov    %edi,%ebp
  802954:	75 0b                	jne    802961 <__umoddi3+0x91>
  802956:	b8 01 00 00 00       	mov    $0x1,%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	f7 f7                	div    %edi
  80295f:	89 c5                	mov    %eax,%ebp
  802961:	89 f0                	mov    %esi,%eax
  802963:	31 d2                	xor    %edx,%edx
  802965:	f7 f5                	div    %ebp
  802967:	89 c8                	mov    %ecx,%eax
  802969:	f7 f5                	div    %ebp
  80296b:	89 d0                	mov    %edx,%eax
  80296d:	eb 99                	jmp    802908 <__umoddi3+0x38>
  80296f:	90                   	nop
  802970:	89 c8                	mov    %ecx,%eax
  802972:	89 f2                	mov    %esi,%edx
  802974:	83 c4 1c             	add    $0x1c,%esp
  802977:	5b                   	pop    %ebx
  802978:	5e                   	pop    %esi
  802979:	5f                   	pop    %edi
  80297a:	5d                   	pop    %ebp
  80297b:	c3                   	ret    
  80297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802980:	8b 34 24             	mov    (%esp),%esi
  802983:	bf 20 00 00 00       	mov    $0x20,%edi
  802988:	89 e9                	mov    %ebp,%ecx
  80298a:	29 ef                	sub    %ebp,%edi
  80298c:	d3 e0                	shl    %cl,%eax
  80298e:	89 f9                	mov    %edi,%ecx
  802990:	89 f2                	mov    %esi,%edx
  802992:	d3 ea                	shr    %cl,%edx
  802994:	89 e9                	mov    %ebp,%ecx
  802996:	09 c2                	or     %eax,%edx
  802998:	89 d8                	mov    %ebx,%eax
  80299a:	89 14 24             	mov    %edx,(%esp)
  80299d:	89 f2                	mov    %esi,%edx
  80299f:	d3 e2                	shl    %cl,%edx
  8029a1:	89 f9                	mov    %edi,%ecx
  8029a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029ab:	d3 e8                	shr    %cl,%eax
  8029ad:	89 e9                	mov    %ebp,%ecx
  8029af:	89 c6                	mov    %eax,%esi
  8029b1:	d3 e3                	shl    %cl,%ebx
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 d0                	mov    %edx,%eax
  8029b7:	d3 e8                	shr    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	09 d8                	or     %ebx,%eax
  8029bd:	89 d3                	mov    %edx,%ebx
  8029bf:	89 f2                	mov    %esi,%edx
  8029c1:	f7 34 24             	divl   (%esp)
  8029c4:	89 d6                	mov    %edx,%esi
  8029c6:	d3 e3                	shl    %cl,%ebx
  8029c8:	f7 64 24 04          	mull   0x4(%esp)
  8029cc:	39 d6                	cmp    %edx,%esi
  8029ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029d2:	89 d1                	mov    %edx,%ecx
  8029d4:	89 c3                	mov    %eax,%ebx
  8029d6:	72 08                	jb     8029e0 <__umoddi3+0x110>
  8029d8:	75 11                	jne    8029eb <__umoddi3+0x11b>
  8029da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029de:	73 0b                	jae    8029eb <__umoddi3+0x11b>
  8029e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029e4:	1b 14 24             	sbb    (%esp),%edx
  8029e7:	89 d1                	mov    %edx,%ecx
  8029e9:	89 c3                	mov    %eax,%ebx
  8029eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ef:	29 da                	sub    %ebx,%edx
  8029f1:	19 ce                	sbb    %ecx,%esi
  8029f3:	89 f9                	mov    %edi,%ecx
  8029f5:	89 f0                	mov    %esi,%eax
  8029f7:	d3 e0                	shl    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	d3 ea                	shr    %cl,%edx
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	d3 ee                	shr    %cl,%esi
  802a01:	09 d0                	or     %edx,%eax
  802a03:	89 f2                	mov    %esi,%edx
  802a05:	83 c4 1c             	add    $0x1c,%esp
  802a08:	5b                   	pop    %ebx
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	29 f9                	sub    %edi,%ecx
  802a12:	19 d6                	sbb    %edx,%esi
  802a14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a1c:	e9 18 ff ff ff       	jmp    802939 <__umoddi3+0x69>
