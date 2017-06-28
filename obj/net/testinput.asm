
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 fb 06 00 00       	call   80072c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 78 11 00 00       	call   8011b9 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 00 	movl   $0x802d00,0x804000
  80004a:	2d 80 00 

	output_envid = fork();
  80004d:	e8 d0 14 00 00       	call   801522 <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 0a 2d 80 00       	push   $0x802d0a
  800063:	6a 4d                	push   $0x4d
  800065:	68 18 2d 80 00       	push   $0x802d18
  80006a:	e8 27 07 00 00       	call   800796 <_panic>
	else if (output_envid == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 11                	jne    800084 <umain+0x51>
		output(ns_envid);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	53                   	push   %ebx
  800077:	e8 bd 03 00 00       	call   800439 <output>
		return;
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	e9 0b 03 00 00       	jmp    80038f <umain+0x35c>
	}

	input_envid = fork();
  800084:	e8 99 14 00 00       	call   801522 <fork>
  800089:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 0a 2d 80 00       	push   $0x802d0a
  80009a:	6a 55                	push   $0x55
  80009c:	68 18 2d 80 00       	push   $0x802d18
  8000a1:	e8 f0 06 00 00       	call   800796 <_panic>
	else if (input_envid == 0) {
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 11                	jne    8000bb <umain+0x88>
		input(ns_envid);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	53                   	push   %ebx
  8000ae:	e8 77 03 00 00       	call   80042a <input>
		return;
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	e9 d4 02 00 00       	jmp    80038f <umain+0x35c>
	}

	cprintf("Sending ARP announcement...\n");
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 28 2d 80 00       	push   $0x802d28
  8000c3:	e8 a7 07 00 00       	call   80086f <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000c8:	c6 45 98 52          	movb   $0x52,-0x68(%ebp)
  8000cc:	c6 45 99 54          	movb   $0x54,-0x67(%ebp)
  8000d0:	c6 45 9a 00          	movb   $0x0,-0x66(%ebp)
  8000d4:	c6 45 9b 12          	movb   $0x12,-0x65(%ebp)
  8000d8:	c6 45 9c 34          	movb   $0x34,-0x64(%ebp)
  8000dc:	c6 45 9d 56          	movb   $0x56,-0x63(%ebp)
	uint32_t myip = inet_addr(IP);
  8000e0:	c7 04 24 45 2d 80 00 	movl   $0x802d45,(%esp)
  8000e7:	e8 0e 06 00 00       	call   8006fa <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 4f 2d 80 00 	movl   $0x802d4f,(%esp)
  8000f6:	e8 ff 05 00 00       	call   8006fa <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 e8 10 00 00       	call   8011f7 <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 58 2d 80 00       	push   $0x802d58
  80011c:	6a 19                	push   $0x19
  80011e:	68 18 2d 80 00       	push   $0x802d18
  800123:	e8 6e 06 00 00       	call   800796 <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 f3 0d 00 00       	call   800f39 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 95 0e 00 00       	call   800fee <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 7c 03 00 00       	call   8004e1 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 6a 03 00 00       	call   8004e1 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 58 03 00 00       	call   8004e1 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 46 03 00 00       	call   8004e1 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 34 03 00 00       	call   8004e1 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 2b 0e 00 00       	call   800fee <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 18 0e 00 00       	call   800fee <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 52 0d 00 00       	call   800f39 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 f4 0d 00 00       	call   800fee <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 04 50 80 00    	pushl  0x805004
  800209:	e8 96 15 00 00       	call   8017a4 <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 5f 10 00 00       	call   80127c <sys_page_unmap>
  80021d:	83 c4 10             	add    $0x10,%esp

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800220:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  800227:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800230:	50                   	push   %eax
  800231:	68 00 b0 fe 0f       	push   $0xffeb000
  800236:	8d 45 90             	lea    -0x70(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	e8 f8 14 00 00       	call   801737 <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 69 2d 80 00       	push   $0x802d69
  80024c:	6a 64                	push   $0x64
  80024e:	68 18 2d 80 00       	push   $0x802d18
  800253:	e8 3e 05 00 00       	call   800796 <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 c0 2d 80 00       	push   $0x802dc0
  800269:	6a 66                	push   $0x66
  80026b:	68 18 2d 80 00       	push   $0x802d18
  800270:	e8 21 05 00 00       	call   800796 <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 76 2d 80 00       	push   $0x802d76
  800280:	6a 68                	push   $0x68
  800282:	68 18 2d 80 00       	push   $0x802d18
  800287:	e8 0a 05 00 00       	call   800796 <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80028c:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800291:	89 45 84             	mov    %eax,-0x7c(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800294:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80029e:	83 e8 01             	sub    $0x1,%eax
  8002a1:	89 45 80             	mov    %eax,-0x80(%ebp)
  8002a4:	e9 a5 00 00 00       	jmp    80034e <umain+0x31b>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	f6 c3 0f             	test   $0xf,%bl
  8002ae:	75 22                	jne    8002d2 <umain+0x29f>
			out = buf + snprintf(buf, end - buf,
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	53                   	push   %ebx
  8002b4:	68 88 2d 80 00       	push   $0x802d88
  8002b9:	68 90 2d 80 00       	push   $0x802d90
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 d8 0a 00 00       	call   800da1 <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 9a 2d 80 00       	push   $0x802d9a
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f0                	sub    %esi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	56                   	push   %esi
  8002e8:	e8 b4 0a 00 00       	call   800da1 <snprintf>
  8002ed:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8002ef:	89 d8                	mov    %ebx,%eax
  8002f1:	c1 f8 1f             	sar    $0x1f,%eax
  8002f4:	c1 e8 1c             	shr    $0x1c,%eax
  8002f7:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8002fa:	83 e7 0f             	and    $0xf,%edi
  8002fd:	29 c7                	sub    %eax,%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	83 ff 0f             	cmp    $0xf,%edi
  800305:	74 05                	je     80030c <umain+0x2d9>
  800307:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  80030a:	75 1c                	jne    800328 <umain+0x2f5>
			cprintf("%.*s\n", out - buf, buf);
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	8d 45 98             	lea    -0x68(%ebp),%eax
  800312:	50                   	push   %eax
  800313:	89 f0                	mov    %esi,%eax
  800315:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  800318:	29 c8                	sub    %ecx,%eax
  80031a:	50                   	push   %eax
  80031b:	68 9f 2d 80 00       	push   $0x802d9f
  800320:	e8 4a 05 00 00       	call   80086f <cprintf>
  800325:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  800328:	89 da                	mov    %ebx,%edx
  80032a:	c1 ea 1f             	shr    $0x1f,%edx
  80032d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800330:	83 e0 01             	and    $0x1,%eax
  800333:	29 d0                	sub    %edx,%eax
  800335:	83 f8 01             	cmp    $0x1,%eax
  800338:	75 06                	jne    800340 <umain+0x30d>
			*(out++) = ' ';
  80033a:	c6 06 20             	movb   $0x20,(%esi)
  80033d:	8d 76 01             	lea    0x1(%esi),%esi
		if (i % 16 == 7)
  800340:	83 ff 07             	cmp    $0x7,%edi
  800343:	75 06                	jne    80034b <umain+0x318>
			*(out++) = ' ';
  800345:	c6 06 20             	movb   $0x20,(%esi)
  800348:	8d 76 01             	lea    0x1(%esi),%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80034b:	83 c3 01             	add    $0x1,%ebx
  80034e:	3b 5d 84             	cmp    -0x7c(%ebp),%ebx
  800351:	0f 8c 52 ff ff ff    	jl     8002a9 <umain+0x276>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	68 da 31 80 00       	push   $0x8031da
  80035f:	e8 0b 05 00 00       	call   80086f <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 a5 2d 80 00       	push   $0x802da5
  800378:	e8 f2 04 00 00       	call   80086f <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp
		first = 0;
  800380:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  800387:	00 00 00 
	}
  80038a:	e9 9b fe ff ff       	jmp    80022a <umain+0x1f7>
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 1c             	sub    $0x1c,%esp
  8003a0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003a3:	e8 40 10 00 00       	call   8013e8 <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 40 80 00 e5 	movl   $0x802de5,0x804000
  8003b4:	2d 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003b7:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003ba:	eb 05                	jmp    8003c1 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  8003bc:	e8 17 0e 00 00       	call   8011d8 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 22 10 00 00       	call   8013e8 <sys_time_msec>
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	78 04                	js     8003d0 <timer+0x39>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	77 ec                	ja     8003bc <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	79 12                	jns    8003e6 <timer+0x4f>
			panic("sys_time_msec: %e", r);
  8003d4:	52                   	push   %edx
  8003d5:	68 ee 2d 80 00       	push   $0x802dee
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 00 2e 80 00       	push   $0x802e00
  8003e1:	e8 b0 03 00 00       	call   800796 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 b2 13 00 00       	call   8017a4 <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 35 13 00 00       	call   801737 <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 f0                	cmp    %esi,%eax
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 0c 2e 80 00       	push   $0x802e0c
  800417:	e8 53 04 00 00       	call   80086f <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 c2 0f 00 00       	call   8013e8 <sys_time_msec>
  800426:	01 c3                	add    %eax,%ebx
  800428:	eb 97                	jmp    8003c1 <timer+0x2a>

0080042a <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  80042d:	c7 05 00 40 80 00 47 	movl   $0x802e47,0x804000
  800434:	2e 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    

00800439 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  80043c:	c7 05 00 40 80 00 50 	movl   $0x802e50,0x804000
  800443:	2e 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800457:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80045a:	c7 45 e0 08 50 80 00 	movl   $0x805008,-0x20(%ebp)
  800461:	0f b6 0f             	movzbl (%edi),%ecx
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800469:	0f b6 d9             	movzbl %cl,%ebx
  80046c:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80046f:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800472:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800475:	66 c1 e8 0b          	shr    $0xb,%ax
  800479:	89 c3                	mov    %eax,%ebx
  80047b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047e:	01 c0                	add    %eax,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800484:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800486:	8d 72 01             	lea    0x1(%edx),%esi
  800489:	0f b6 d2             	movzbl %dl,%edx
  80048c:	83 c0 30             	add    $0x30,%eax
  80048f:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800493:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800495:	84 db                	test   %bl,%bl
  800497:	75 d0                	jne    800469 <inet_ntoa+0x21>
  800499:	c6 07 00             	movb   $0x0,(%edi)
  80049c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049f:	eb 0d                	jmp    8004ae <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8004a1:	0f b6 c2             	movzbl %dl,%eax
  8004a4:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8004a9:	88 01                	mov    %al,(%ecx)
  8004ab:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8004ae:	83 ea 01             	sub    $0x1,%edx
  8004b1:	80 fa ff             	cmp    $0xff,%dl
  8004b4:	75 eb                	jne    8004a1 <inet_ntoa+0x59>
  8004b6:	89 f0                	mov    %esi,%eax
  8004b8:	0f b6 f0             	movzbl %al,%esi
  8004bb:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  8004be:	8d 46 01             	lea    0x1(%esi),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  8004c7:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8004ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cd:	39 c7                	cmp    %eax,%edi
  8004cf:	75 90                	jne    800461 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  8004d1:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  8004d4:	b8 08 50 80 00       	mov    $0x805008,%eax
  8004d9:	83 c4 14             	add    $0x14,%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8004e4:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004e8:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  return htons(n);
  8004f1:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004f5:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800501:	89 d1                	mov    %edx,%ecx
  800503:	c1 e1 18             	shl    $0x18,%ecx
  800506:	89 d0                	mov    %edx,%eax
  800508:	c1 e8 18             	shr    $0x18,%eax
  80050b:	09 c8                	or     %ecx,%eax
  80050d:	89 d1                	mov    %edx,%ecx
  80050f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800515:	c1 e1 08             	shl    $0x8,%ecx
  800518:	09 c8                	or     %ecx,%eax
  80051a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800520:	c1 ea 08             	shr    $0x8,%edx
  800523:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 20             	sub    $0x20,%esp
  800530:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800533:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800536:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800539:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80053c:	0f b6 ca             	movzbl %dl,%ecx
  80053f:	83 e9 30             	sub    $0x30,%ecx
  800542:	83 f9 09             	cmp    $0x9,%ecx
  800545:	0f 87 94 01 00 00    	ja     8006df <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  80054b:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  800552:	83 fa 30             	cmp    $0x30,%edx
  800555:	75 2b                	jne    800582 <inet_aton+0x5b>
      c = *++cp;
  800557:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80055b:	89 d1                	mov    %edx,%ecx
  80055d:	83 e1 df             	and    $0xffffffdf,%ecx
  800560:	80 f9 58             	cmp    $0x58,%cl
  800563:	74 0f                	je     800574 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800565:	83 c0 01             	add    $0x1,%eax
  800568:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  80056b:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800572:	eb 0e                	jmp    800582 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800574:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800578:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  80057b:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800582:	83 c0 01             	add    $0x1,%eax
  800585:	be 00 00 00 00       	mov    $0x0,%esi
  80058a:	eb 03                	jmp    80058f <inet_aton+0x68>
  80058c:	83 c0 01             	add    $0x1,%eax
  80058f:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800592:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800595:	0f b6 fa             	movzbl %dl,%edi
  800598:	8d 4f d0             	lea    -0x30(%edi),%ecx
  80059b:	83 f9 09             	cmp    $0x9,%ecx
  80059e:	77 0d                	ja     8005ad <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8005a0:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8005a4:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8005a8:	0f be 10             	movsbl (%eax),%edx
  8005ab:	eb df                	jmp    80058c <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  8005ad:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8005b1:	75 32                	jne    8005e5 <inet_aton+0xbe>
  8005b3:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8005b6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bc:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  8005c2:	83 e9 41             	sub    $0x41,%ecx
  8005c5:	83 f9 05             	cmp    $0x5,%ecx
  8005c8:	77 1b                	ja     8005e5 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8005ca:	c1 e6 04             	shl    $0x4,%esi
  8005cd:	83 c2 0a             	add    $0xa,%edx
  8005d0:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  8005d4:	19 c9                	sbb    %ecx,%ecx
  8005d6:	83 e1 20             	and    $0x20,%ecx
  8005d9:	83 c1 41             	add    $0x41,%ecx
  8005dc:	29 ca                	sub    %ecx,%edx
  8005de:	09 d6                	or     %edx,%esi
        c = *++cp;
  8005e0:	0f be 10             	movsbl (%eax),%edx
  8005e3:	eb a7                	jmp    80058c <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  8005e5:	83 fa 2e             	cmp    $0x2e,%edx
  8005e8:	75 23                	jne    80060d <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8005ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  8005f0:	39 f8                	cmp    %edi,%eax
  8005f2:	0f 84 ee 00 00 00    	je     8006e6 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  8005f8:	83 c0 04             	add    $0x4,%eax
  8005fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005fe:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800601:	8d 43 01             	lea    0x1(%ebx),%eax
  800604:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800608:	e9 2f ff ff ff       	jmp    80053c <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80060d:	85 d2                	test   %edx,%edx
  80060f:	74 25                	je     800636 <inet_aton+0x10f>
  800611:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800614:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800619:	83 f9 5f             	cmp    $0x5f,%ecx
  80061c:	0f 87 d0 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  800622:	83 fa 20             	cmp    $0x20,%edx
  800625:	74 0f                	je     800636 <inet_aton+0x10f>
  800627:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80062a:	83 ea 09             	sub    $0x9,%edx
  80062d:	83 fa 04             	cmp    $0x4,%edx
  800630:	0f 87 bc 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800636:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800639:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063c:	29 c2                	sub    %eax,%edx
  80063e:	c1 fa 02             	sar    $0x2,%edx
  800641:	83 c2 01             	add    $0x1,%edx
  800644:	83 fa 02             	cmp    $0x2,%edx
  800647:	74 20                	je     800669 <inet_aton+0x142>
  800649:	83 fa 02             	cmp    $0x2,%edx
  80064c:	7f 0f                	jg     80065d <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  80064e:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800653:	85 d2                	test   %edx,%edx
  800655:	0f 84 97 00 00 00    	je     8006f2 <inet_aton+0x1cb>
  80065b:	eb 67                	jmp    8006c4 <inet_aton+0x19d>
  80065d:	83 fa 03             	cmp    $0x3,%edx
  800660:	74 1e                	je     800680 <inet_aton+0x159>
  800662:	83 fa 04             	cmp    $0x4,%edx
  800665:	74 38                	je     80069f <inet_aton+0x178>
  800667:	eb 5b                	jmp    8006c4 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800669:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80066e:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  800674:	77 7c                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  800676:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800679:	c1 e0 18             	shl    $0x18,%eax
  80067c:	09 c6                	or     %eax,%esi
    break;
  80067e:	eb 44                	jmp    8006c4 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800680:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800685:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  80068b:	77 65                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80068d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800690:	c1 e2 18             	shl    $0x18,%edx
  800693:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800696:	c1 e0 10             	shl    $0x10,%eax
  800699:	09 d0                	or     %edx,%eax
  80069b:	09 c6                	or     %eax,%esi
    break;
  80069d:	eb 25                	jmp    8006c4 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80069f:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8006a4:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  8006aa:	77 46                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8006ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006af:	c1 e2 18             	shl    $0x18,%edx
  8006b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006b5:	c1 e0 10             	shl    $0x10,%eax
  8006b8:	09 c2                	or     %eax,%edx
  8006ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bd:	c1 e0 08             	shl    $0x8,%eax
  8006c0:	09 d0                	or     %edx,%eax
  8006c2:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  8006c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c8:	74 23                	je     8006ed <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  8006ca:	56                   	push   %esi
  8006cb:	e8 2b fe ff ff       	call   8004fb <htonl>
  8006d0:	83 c4 04             	add    $0x4,%esp
  8006d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d6:	89 03                	mov    %eax,(%ebx)
  return (1);
  8006d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8006dd:	eb 13                	jmp    8006f2 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 0c                	jmp    8006f2 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 05                	jmp    8006f2 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8006ed:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800700:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	ff 75 08             	pushl  0x8(%ebp)
  800707:	e8 1b fe ff ff       	call   800527 <inet_aton>
  80070c:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80070f:	85 c0                	test   %eax,%eax
  800711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800716:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80071f:	ff 75 08             	pushl  0x8(%ebp)
  800722:	e8 d4 fd ff ff       	call   8004fb <htonl>
  800727:	83 c4 04             	add    $0x4,%esp
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800734:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800737:	c7 05 20 50 80 00 00 	movl   $0x0,0x805020
  80073e:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800741:	e8 73 0a 00 00       	call   8011b9 <sys_getenvid>
  800746:	25 ff 03 00 00       	and    $0x3ff,%eax
  80074b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80074e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800753:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800758:	85 db                	test   %ebx,%ebx
  80075a:	7e 07                	jle    800763 <libmain+0x37>
		binaryname = argv[0];
  80075c:	8b 06                	mov    (%esi),%eax
  80075e:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	e8 c6 f8 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80076d:	e8 0a 00 00 00       	call   80077c <exit>
}
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800778:	5b                   	pop    %ebx
  800779:	5e                   	pop    %esi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800782:	e8 75 12 00 00       	call   8019fc <close_all>
	sys_env_destroy(0);
  800787:	83 ec 0c             	sub    $0xc,%esp
  80078a:	6a 00                	push   $0x0
  80078c:	e8 e7 09 00 00       	call   801178 <sys_env_destroy>
}
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80079b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80079e:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8007a4:	e8 10 0a 00 00       	call   8011b9 <sys_getenvid>
  8007a9:	83 ec 0c             	sub    $0xc,%esp
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	ff 75 08             	pushl  0x8(%ebp)
  8007b2:	56                   	push   %esi
  8007b3:	50                   	push   %eax
  8007b4:	68 64 2e 80 00       	push   $0x802e64
  8007b9:	e8 b1 00 00 00       	call   80086f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8007be:	83 c4 18             	add    $0x18,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	e8 54 00 00 00       	call   80081e <vcprintf>
	cprintf("\n");
  8007ca:	c7 04 24 da 31 80 00 	movl   $0x8031da,(%esp)
  8007d1:	e8 99 00 00 00       	call   80086f <cprintf>
  8007d6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8007d9:	cc                   	int3   
  8007da:	eb fd                	jmp    8007d9 <_panic+0x43>

008007dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	83 ec 04             	sub    $0x4,%esp
  8007e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007e6:	8b 13                	mov    (%ebx),%edx
  8007e8:	8d 42 01             	lea    0x1(%edx),%eax
  8007eb:	89 03                	mov    %eax,(%ebx)
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8007f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007f9:	75 1a                	jne    800815 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	68 ff 00 00 00       	push   $0xff
  800803:	8d 43 08             	lea    0x8(%ebx),%eax
  800806:	50                   	push   %eax
  800807:	e8 2f 09 00 00       	call   80113b <sys_cputs>
		b->idx = 0;
  80080c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800812:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800815:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800827:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80082e:	00 00 00 
	b.cnt = 0;
  800831:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800838:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80083b:	ff 75 0c             	pushl  0xc(%ebp)
  80083e:	ff 75 08             	pushl  0x8(%ebp)
  800841:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	68 dc 07 80 00       	push   $0x8007dc
  80084d:	e8 54 01 00 00       	call   8009a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800852:	83 c4 08             	add    $0x8,%esp
  800855:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80085b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800861:	50                   	push   %eax
  800862:	e8 d4 08 00 00       	call   80113b <sys_cputs>

	return b.cnt;
}
  800867:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800875:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800878:	50                   	push   %eax
  800879:	ff 75 08             	pushl  0x8(%ebp)
  80087c:	e8 9d ff ff ff       	call   80081e <vcprintf>
	va_end(ap);

	return cnt;
}
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	57                   	push   %edi
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	83 ec 1c             	sub    $0x1c,%esp
  80088c:	89 c7                	mov    %eax,%edi
  80088e:	89 d6                	mov    %edx,%esi
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
  800896:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800899:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80089c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80089f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8008a7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008aa:	39 d3                	cmp    %edx,%ebx
  8008ac:	72 05                	jb     8008b3 <printnum+0x30>
  8008ae:	39 45 10             	cmp    %eax,0x10(%ebp)
  8008b1:	77 45                	ja     8008f8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8008b3:	83 ec 0c             	sub    $0xc,%esp
  8008b6:	ff 75 18             	pushl  0x18(%ebp)
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8008bf:	53                   	push   %ebx
  8008c0:	ff 75 10             	pushl  0x10(%ebp)
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8008cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8008cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8008d2:	e8 89 21 00 00       	call   802a60 <__udivdi3>
  8008d7:	83 c4 18             	add    $0x18,%esp
  8008da:	52                   	push   %edx
  8008db:	50                   	push   %eax
  8008dc:	89 f2                	mov    %esi,%edx
  8008de:	89 f8                	mov    %edi,%eax
  8008e0:	e8 9e ff ff ff       	call   800883 <printnum>
  8008e5:	83 c4 20             	add    $0x20,%esp
  8008e8:	eb 18                	jmp    800902 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	56                   	push   %esi
  8008ee:	ff 75 18             	pushl  0x18(%ebp)
  8008f1:	ff d7                	call   *%edi
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	eb 03                	jmp    8008fb <printnum+0x78>
  8008f8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008fb:	83 eb 01             	sub    $0x1,%ebx
  8008fe:	85 db                	test   %ebx,%ebx
  800900:	7f e8                	jg     8008ea <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	56                   	push   %esi
  800906:	83 ec 04             	sub    $0x4,%esp
  800909:	ff 75 e4             	pushl  -0x1c(%ebp)
  80090c:	ff 75 e0             	pushl  -0x20(%ebp)
  80090f:	ff 75 dc             	pushl  -0x24(%ebp)
  800912:	ff 75 d8             	pushl  -0x28(%ebp)
  800915:	e8 76 22 00 00       	call   802b90 <__umoddi3>
  80091a:	83 c4 14             	add    $0x14,%esp
  80091d:	0f be 80 87 2e 80 00 	movsbl 0x802e87(%eax),%eax
  800924:	50                   	push   %eax
  800925:	ff d7                	call   *%edi
}
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800935:	83 fa 01             	cmp    $0x1,%edx
  800938:	7e 0e                	jle    800948 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80093a:	8b 10                	mov    (%eax),%edx
  80093c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80093f:	89 08                	mov    %ecx,(%eax)
  800941:	8b 02                	mov    (%edx),%eax
  800943:	8b 52 04             	mov    0x4(%edx),%edx
  800946:	eb 22                	jmp    80096a <getuint+0x38>
	else if (lflag)
  800948:	85 d2                	test   %edx,%edx
  80094a:	74 10                	je     80095c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80094c:	8b 10                	mov    (%eax),%edx
  80094e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800951:	89 08                	mov    %ecx,(%eax)
  800953:	8b 02                	mov    (%edx),%eax
  800955:	ba 00 00 00 00       	mov    $0x0,%edx
  80095a:	eb 0e                	jmp    80096a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80095c:	8b 10                	mov    (%eax),%edx
  80095e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800961:	89 08                	mov    %ecx,(%eax)
  800963:	8b 02                	mov    (%edx),%eax
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800972:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800976:	8b 10                	mov    (%eax),%edx
  800978:	3b 50 04             	cmp    0x4(%eax),%edx
  80097b:	73 0a                	jae    800987 <sprintputch+0x1b>
		*b->buf++ = ch;
  80097d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800980:	89 08                	mov    %ecx,(%eax)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	88 02                	mov    %al,(%edx)
}
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80098f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800992:	50                   	push   %eax
  800993:	ff 75 10             	pushl  0x10(%ebp)
  800996:	ff 75 0c             	pushl  0xc(%ebp)
  800999:	ff 75 08             	pushl  0x8(%ebp)
  80099c:	e8 05 00 00 00       	call   8009a6 <vprintfmt>
	va_end(ap);
}
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	83 ec 2c             	sub    $0x2c,%esp
  8009af:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009b8:	eb 12                	jmp    8009cc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009ba:	85 c0                	test   %eax,%eax
  8009bc:	0f 84 89 03 00 00    	je     800d4b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	53                   	push   %ebx
  8009c6:	50                   	push   %eax
  8009c7:	ff d6                	call   *%esi
  8009c9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009cc:	83 c7 01             	add    $0x1,%edi
  8009cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009d3:	83 f8 25             	cmp    $0x25,%eax
  8009d6:	75 e2                	jne    8009ba <vprintfmt+0x14>
  8009d8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009ea:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f6:	eb 07                	jmp    8009ff <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009fb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ff:	8d 47 01             	lea    0x1(%edi),%eax
  800a02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a05:	0f b6 07             	movzbl (%edi),%eax
  800a08:	0f b6 c8             	movzbl %al,%ecx
  800a0b:	83 e8 23             	sub    $0x23,%eax
  800a0e:	3c 55                	cmp    $0x55,%al
  800a10:	0f 87 1a 03 00 00    	ja     800d30 <vprintfmt+0x38a>
  800a16:	0f b6 c0             	movzbl %al,%eax
  800a19:	ff 24 85 c0 2f 80 00 	jmp    *0x802fc0(,%eax,4)
  800a20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a23:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a27:	eb d6                	jmp    8009ff <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a29:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a34:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a37:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800a3b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800a3e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800a41:	83 fa 09             	cmp    $0x9,%edx
  800a44:	77 39                	ja     800a7f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a46:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a49:	eb e9                	jmp    800a34 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4e:	8d 48 04             	lea    0x4(%eax),%ecx
  800a51:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a54:	8b 00                	mov    (%eax),%eax
  800a56:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a5c:	eb 27                	jmp    800a85 <vprintfmt+0xdf>
  800a5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a61:	85 c0                	test   %eax,%eax
  800a63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a68:	0f 49 c8             	cmovns %eax,%ecx
  800a6b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a71:	eb 8c                	jmp    8009ff <vprintfmt+0x59>
  800a73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a76:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a7d:	eb 80                	jmp    8009ff <vprintfmt+0x59>
  800a7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a82:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a85:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a89:	0f 89 70 ff ff ff    	jns    8009ff <vprintfmt+0x59>
				width = precision, precision = -1;
  800a8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a92:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a95:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a9c:	e9 5e ff ff ff       	jmp    8009ff <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800aa1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800aa7:	e9 53 ff ff ff       	jmp    8009ff <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800aac:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaf:	8d 50 04             	lea    0x4(%eax),%edx
  800ab2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab5:	83 ec 08             	sub    $0x8,%esp
  800ab8:	53                   	push   %ebx
  800ab9:	ff 30                	pushl  (%eax)
  800abb:	ff d6                	call   *%esi
			break;
  800abd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800ac3:	e9 04 ff ff ff       	jmp    8009cc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ac8:	8b 45 14             	mov    0x14(%ebp),%eax
  800acb:	8d 50 04             	lea    0x4(%eax),%edx
  800ace:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad1:	8b 00                	mov    (%eax),%eax
  800ad3:	99                   	cltd   
  800ad4:	31 d0                	xor    %edx,%eax
  800ad6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ad8:	83 f8 0f             	cmp    $0xf,%eax
  800adb:	7f 0b                	jg     800ae8 <vprintfmt+0x142>
  800add:	8b 14 85 20 31 80 00 	mov    0x803120(,%eax,4),%edx
  800ae4:	85 d2                	test   %edx,%edx
  800ae6:	75 18                	jne    800b00 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800ae8:	50                   	push   %eax
  800ae9:	68 9f 2e 80 00       	push   $0x802e9f
  800aee:	53                   	push   %ebx
  800aef:	56                   	push   %esi
  800af0:	e8 94 fe ff ff       	call   800989 <printfmt>
  800af5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800afb:	e9 cc fe ff ff       	jmp    8009cc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800b00:	52                   	push   %edx
  800b01:	68 d1 33 80 00       	push   $0x8033d1
  800b06:	53                   	push   %ebx
  800b07:	56                   	push   %esi
  800b08:	e8 7c fe ff ff       	call   800989 <printfmt>
  800b0d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b13:	e9 b4 fe ff ff       	jmp    8009cc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b18:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1b:	8d 50 04             	lea    0x4(%eax),%edx
  800b1e:	89 55 14             	mov    %edx,0x14(%ebp)
  800b21:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800b23:	85 ff                	test   %edi,%edi
  800b25:	b8 98 2e 80 00       	mov    $0x802e98,%eax
  800b2a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800b2d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b31:	0f 8e 94 00 00 00    	jle    800bcb <vprintfmt+0x225>
  800b37:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b3b:	0f 84 98 00 00 00    	je     800bd9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	ff 75 d0             	pushl  -0x30(%ebp)
  800b47:	57                   	push   %edi
  800b48:	e8 86 02 00 00       	call   800dd3 <strnlen>
  800b4d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b50:	29 c1                	sub    %eax,%ecx
  800b52:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800b55:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800b58:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b5f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b62:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b64:	eb 0f                	jmp    800b75 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800b66:	83 ec 08             	sub    $0x8,%esp
  800b69:	53                   	push   %ebx
  800b6a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b6d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b6f:	83 ef 01             	sub    $0x1,%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	85 ff                	test   %edi,%edi
  800b77:	7f ed                	jg     800b66 <vprintfmt+0x1c0>
  800b79:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b7c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b7f:	85 c9                	test   %ecx,%ecx
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	0f 49 c1             	cmovns %ecx,%eax
  800b89:	29 c1                	sub    %eax,%ecx
  800b8b:	89 75 08             	mov    %esi,0x8(%ebp)
  800b8e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b91:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b94:	89 cb                	mov    %ecx,%ebx
  800b96:	eb 4d                	jmp    800be5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b98:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b9c:	74 1b                	je     800bb9 <vprintfmt+0x213>
  800b9e:	0f be c0             	movsbl %al,%eax
  800ba1:	83 e8 20             	sub    $0x20,%eax
  800ba4:	83 f8 5e             	cmp    $0x5e,%eax
  800ba7:	76 10                	jbe    800bb9 <vprintfmt+0x213>
					putch('?', putdat);
  800ba9:	83 ec 08             	sub    $0x8,%esp
  800bac:	ff 75 0c             	pushl  0xc(%ebp)
  800baf:	6a 3f                	push   $0x3f
  800bb1:	ff 55 08             	call   *0x8(%ebp)
  800bb4:	83 c4 10             	add    $0x10,%esp
  800bb7:	eb 0d                	jmp    800bc6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800bb9:	83 ec 08             	sub    $0x8,%esp
  800bbc:	ff 75 0c             	pushl  0xc(%ebp)
  800bbf:	52                   	push   %edx
  800bc0:	ff 55 08             	call   *0x8(%ebp)
  800bc3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bc6:	83 eb 01             	sub    $0x1,%ebx
  800bc9:	eb 1a                	jmp    800be5 <vprintfmt+0x23f>
  800bcb:	89 75 08             	mov    %esi,0x8(%ebp)
  800bce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bd1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bd4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bd7:	eb 0c                	jmp    800be5 <vprintfmt+0x23f>
  800bd9:	89 75 08             	mov    %esi,0x8(%ebp)
  800bdc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bdf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800be2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800be5:	83 c7 01             	add    $0x1,%edi
  800be8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800bec:	0f be d0             	movsbl %al,%edx
  800bef:	85 d2                	test   %edx,%edx
  800bf1:	74 23                	je     800c16 <vprintfmt+0x270>
  800bf3:	85 f6                	test   %esi,%esi
  800bf5:	78 a1                	js     800b98 <vprintfmt+0x1f2>
  800bf7:	83 ee 01             	sub    $0x1,%esi
  800bfa:	79 9c                	jns    800b98 <vprintfmt+0x1f2>
  800bfc:	89 df                	mov    %ebx,%edi
  800bfe:	8b 75 08             	mov    0x8(%ebp),%esi
  800c01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c04:	eb 18                	jmp    800c1e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c06:	83 ec 08             	sub    $0x8,%esp
  800c09:	53                   	push   %ebx
  800c0a:	6a 20                	push   $0x20
  800c0c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c0e:	83 ef 01             	sub    $0x1,%edi
  800c11:	83 c4 10             	add    $0x10,%esp
  800c14:	eb 08                	jmp    800c1e <vprintfmt+0x278>
  800c16:	89 df                	mov    %ebx,%edi
  800c18:	8b 75 08             	mov    0x8(%ebp),%esi
  800c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1e:	85 ff                	test   %edi,%edi
  800c20:	7f e4                	jg     800c06 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c25:	e9 a2 fd ff ff       	jmp    8009cc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c2a:	83 fa 01             	cmp    $0x1,%edx
  800c2d:	7e 16                	jle    800c45 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800c2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c32:	8d 50 08             	lea    0x8(%eax),%edx
  800c35:	89 55 14             	mov    %edx,0x14(%ebp)
  800c38:	8b 50 04             	mov    0x4(%eax),%edx
  800c3b:	8b 00                	mov    (%eax),%eax
  800c3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c40:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c43:	eb 32                	jmp    800c77 <vprintfmt+0x2d1>
	else if (lflag)
  800c45:	85 d2                	test   %edx,%edx
  800c47:	74 18                	je     800c61 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800c49:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4c:	8d 50 04             	lea    0x4(%eax),%edx
  800c4f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c52:	8b 00                	mov    (%eax),%eax
  800c54:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c57:	89 c1                	mov    %eax,%ecx
  800c59:	c1 f9 1f             	sar    $0x1f,%ecx
  800c5c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c5f:	eb 16                	jmp    800c77 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800c61:	8b 45 14             	mov    0x14(%ebp),%eax
  800c64:	8d 50 04             	lea    0x4(%eax),%edx
  800c67:	89 55 14             	mov    %edx,0x14(%ebp)
  800c6a:	8b 00                	mov    (%eax),%eax
  800c6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c6f:	89 c1                	mov    %eax,%ecx
  800c71:	c1 f9 1f             	sar    $0x1f,%ecx
  800c74:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c77:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c7d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c82:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c86:	79 74                	jns    800cfc <vprintfmt+0x356>
				putch('-', putdat);
  800c88:	83 ec 08             	sub    $0x8,%esp
  800c8b:	53                   	push   %ebx
  800c8c:	6a 2d                	push   $0x2d
  800c8e:	ff d6                	call   *%esi
				num = -(long long) num;
  800c90:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c93:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c96:	f7 d8                	neg    %eax
  800c98:	83 d2 00             	adc    $0x0,%edx
  800c9b:	f7 da                	neg    %edx
  800c9d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ca0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ca5:	eb 55                	jmp    800cfc <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ca7:	8d 45 14             	lea    0x14(%ebp),%eax
  800caa:	e8 83 fc ff ff       	call   800932 <getuint>
			base = 10;
  800caf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800cb4:	eb 46                	jmp    800cfc <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800cb6:	8d 45 14             	lea    0x14(%ebp),%eax
  800cb9:	e8 74 fc ff ff       	call   800932 <getuint>
		        base = 8;
  800cbe:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800cc3:	eb 37                	jmp    800cfc <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800cc5:	83 ec 08             	sub    $0x8,%esp
  800cc8:	53                   	push   %ebx
  800cc9:	6a 30                	push   $0x30
  800ccb:	ff d6                	call   *%esi
			putch('x', putdat);
  800ccd:	83 c4 08             	add    $0x8,%esp
  800cd0:	53                   	push   %ebx
  800cd1:	6a 78                	push   $0x78
  800cd3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cd5:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd8:	8d 50 04             	lea    0x4(%eax),%edx
  800cdb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cde:	8b 00                	mov    (%eax),%eax
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ce5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ce8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ced:	eb 0d                	jmp    800cfc <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf2:	e8 3b fc ff ff       	call   800932 <getuint>
			base = 16;
  800cf7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800d03:	57                   	push   %edi
  800d04:	ff 75 e0             	pushl  -0x20(%ebp)
  800d07:	51                   	push   %ecx
  800d08:	52                   	push   %edx
  800d09:	50                   	push   %eax
  800d0a:	89 da                	mov    %ebx,%edx
  800d0c:	89 f0                	mov    %esi,%eax
  800d0e:	e8 70 fb ff ff       	call   800883 <printnum>
			break;
  800d13:	83 c4 20             	add    $0x20,%esp
  800d16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d19:	e9 ae fc ff ff       	jmp    8009cc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d1e:	83 ec 08             	sub    $0x8,%esp
  800d21:	53                   	push   %ebx
  800d22:	51                   	push   %ecx
  800d23:	ff d6                	call   *%esi
			break;
  800d25:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d2b:	e9 9c fc ff ff       	jmp    8009cc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d30:	83 ec 08             	sub    $0x8,%esp
  800d33:	53                   	push   %ebx
  800d34:	6a 25                	push   $0x25
  800d36:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	eb 03                	jmp    800d40 <vprintfmt+0x39a>
  800d3d:	83 ef 01             	sub    $0x1,%edi
  800d40:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800d44:	75 f7                	jne    800d3d <vprintfmt+0x397>
  800d46:	e9 81 fc ff ff       	jmp    8009cc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 18             	sub    $0x18,%esp
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d62:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d66:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	74 26                	je     800d9a <vsnprintf+0x47>
  800d74:	85 d2                	test   %edx,%edx
  800d76:	7e 22                	jle    800d9a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d78:	ff 75 14             	pushl  0x14(%ebp)
  800d7b:	ff 75 10             	pushl  0x10(%ebp)
  800d7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d81:	50                   	push   %eax
  800d82:	68 6c 09 80 00       	push   $0x80096c
  800d87:	e8 1a fc ff ff       	call   8009a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d8f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	eb 05                	jmp    800d9f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800da7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800daa:	50                   	push   %eax
  800dab:	ff 75 10             	pushl  0x10(%ebp)
  800dae:	ff 75 0c             	pushl  0xc(%ebp)
  800db1:	ff 75 08             	pushl  0x8(%ebp)
  800db4:	e8 9a ff ff ff       	call   800d53 <vsnprintf>
	va_end(ap);

	return rc;
}
  800db9:	c9                   	leave  
  800dba:	c3                   	ret    

00800dbb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	eb 03                	jmp    800dcb <strlen+0x10>
		n++;
  800dc8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800dcb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dcf:	75 f7                	jne    800dc8 <strlen+0xd>
		n++;
	return n;
}
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ddc:	ba 00 00 00 00       	mov    $0x0,%edx
  800de1:	eb 03                	jmp    800de6 <strnlen+0x13>
		n++;
  800de3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800de6:	39 c2                	cmp    %eax,%edx
  800de8:	74 08                	je     800df2 <strnlen+0x1f>
  800dea:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800dee:	75 f3                	jne    800de3 <strnlen+0x10>
  800df0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	53                   	push   %ebx
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800dfe:	89 c2                	mov    %eax,%edx
  800e00:	83 c2 01             	add    $0x1,%edx
  800e03:	83 c1 01             	add    $0x1,%ecx
  800e06:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800e0a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e0d:	84 db                	test   %bl,%bl
  800e0f:	75 ef                	jne    800e00 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800e11:	5b                   	pop    %ebx
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	53                   	push   %ebx
  800e18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e1b:	53                   	push   %ebx
  800e1c:	e8 9a ff ff ff       	call   800dbb <strlen>
  800e21:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800e24:	ff 75 0c             	pushl  0xc(%ebp)
  800e27:	01 d8                	add    %ebx,%eax
  800e29:	50                   	push   %eax
  800e2a:	e8 c5 ff ff ff       	call   800df4 <strcpy>
	return dst;
}
  800e2f:	89 d8                	mov    %ebx,%eax
  800e31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    

00800e36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e41:	89 f3                	mov    %esi,%ebx
  800e43:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e46:	89 f2                	mov    %esi,%edx
  800e48:	eb 0f                	jmp    800e59 <strncpy+0x23>
		*dst++ = *src;
  800e4a:	83 c2 01             	add    $0x1,%edx
  800e4d:	0f b6 01             	movzbl (%ecx),%eax
  800e50:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e53:	80 39 01             	cmpb   $0x1,(%ecx)
  800e56:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e59:	39 da                	cmp    %ebx,%edx
  800e5b:	75 ed                	jne    800e4a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e5d:	89 f0                	mov    %esi,%eax
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
  800e68:	8b 75 08             	mov    0x8(%ebp),%esi
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6e:	8b 55 10             	mov    0x10(%ebp),%edx
  800e71:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e73:	85 d2                	test   %edx,%edx
  800e75:	74 21                	je     800e98 <strlcpy+0x35>
  800e77:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e7b:	89 f2                	mov    %esi,%edx
  800e7d:	eb 09                	jmp    800e88 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e7f:	83 c2 01             	add    $0x1,%edx
  800e82:	83 c1 01             	add    $0x1,%ecx
  800e85:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e88:	39 c2                	cmp    %eax,%edx
  800e8a:	74 09                	je     800e95 <strlcpy+0x32>
  800e8c:	0f b6 19             	movzbl (%ecx),%ebx
  800e8f:	84 db                	test   %bl,%bl
  800e91:	75 ec                	jne    800e7f <strlcpy+0x1c>
  800e93:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e95:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e98:	29 f0                	sub    %esi,%eax
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ea7:	eb 06                	jmp    800eaf <strcmp+0x11>
		p++, q++;
  800ea9:	83 c1 01             	add    $0x1,%ecx
  800eac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800eaf:	0f b6 01             	movzbl (%ecx),%eax
  800eb2:	84 c0                	test   %al,%al
  800eb4:	74 04                	je     800eba <strcmp+0x1c>
  800eb6:	3a 02                	cmp    (%edx),%al
  800eb8:	74 ef                	je     800ea9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800eba:	0f b6 c0             	movzbl %al,%eax
  800ebd:	0f b6 12             	movzbl (%edx),%edx
  800ec0:	29 d0                	sub    %edx,%eax
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	53                   	push   %ebx
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ed3:	eb 06                	jmp    800edb <strncmp+0x17>
		n--, p++, q++;
  800ed5:	83 c0 01             	add    $0x1,%eax
  800ed8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800edb:	39 d8                	cmp    %ebx,%eax
  800edd:	74 15                	je     800ef4 <strncmp+0x30>
  800edf:	0f b6 08             	movzbl (%eax),%ecx
  800ee2:	84 c9                	test   %cl,%cl
  800ee4:	74 04                	je     800eea <strncmp+0x26>
  800ee6:	3a 0a                	cmp    (%edx),%cl
  800ee8:	74 eb                	je     800ed5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800eea:	0f b6 00             	movzbl (%eax),%eax
  800eed:	0f b6 12             	movzbl (%edx),%edx
  800ef0:	29 d0                	sub    %edx,%eax
  800ef2:	eb 05                	jmp    800ef9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ef9:	5b                   	pop    %ebx
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f06:	eb 07                	jmp    800f0f <strchr+0x13>
		if (*s == c)
  800f08:	38 ca                	cmp    %cl,%dl
  800f0a:	74 0f                	je     800f1b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f0c:	83 c0 01             	add    $0x1,%eax
  800f0f:	0f b6 10             	movzbl (%eax),%edx
  800f12:	84 d2                	test   %dl,%dl
  800f14:	75 f2                	jne    800f08 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
  800f23:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f27:	eb 03                	jmp    800f2c <strfind+0xf>
  800f29:	83 c0 01             	add    $0x1,%eax
  800f2c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f2f:	38 ca                	cmp    %cl,%dl
  800f31:	74 04                	je     800f37 <strfind+0x1a>
  800f33:	84 d2                	test   %dl,%dl
  800f35:	75 f2                	jne    800f29 <strfind+0xc>
			break;
	return (char *) s;
}
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f45:	85 c9                	test   %ecx,%ecx
  800f47:	74 36                	je     800f7f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f49:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f4f:	75 28                	jne    800f79 <memset+0x40>
  800f51:	f6 c1 03             	test   $0x3,%cl
  800f54:	75 23                	jne    800f79 <memset+0x40>
		c &= 0xFF;
  800f56:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f5a:	89 d3                	mov    %edx,%ebx
  800f5c:	c1 e3 08             	shl    $0x8,%ebx
  800f5f:	89 d6                	mov    %edx,%esi
  800f61:	c1 e6 18             	shl    $0x18,%esi
  800f64:	89 d0                	mov    %edx,%eax
  800f66:	c1 e0 10             	shl    $0x10,%eax
  800f69:	09 f0                	or     %esi,%eax
  800f6b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f6d:	89 d8                	mov    %ebx,%eax
  800f6f:	09 d0                	or     %edx,%eax
  800f71:	c1 e9 02             	shr    $0x2,%ecx
  800f74:	fc                   	cld    
  800f75:	f3 ab                	rep stos %eax,%es:(%edi)
  800f77:	eb 06                	jmp    800f7f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7c:	fc                   	cld    
  800f7d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f7f:	89 f8                	mov    %edi,%eax
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f94:	39 c6                	cmp    %eax,%esi
  800f96:	73 35                	jae    800fcd <memmove+0x47>
  800f98:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f9b:	39 d0                	cmp    %edx,%eax
  800f9d:	73 2e                	jae    800fcd <memmove+0x47>
		s += n;
		d += n;
  800f9f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa2:	89 d6                	mov    %edx,%esi
  800fa4:	09 fe                	or     %edi,%esi
  800fa6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fac:	75 13                	jne    800fc1 <memmove+0x3b>
  800fae:	f6 c1 03             	test   $0x3,%cl
  800fb1:	75 0e                	jne    800fc1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fb3:	83 ef 04             	sub    $0x4,%edi
  800fb6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fb9:	c1 e9 02             	shr    $0x2,%ecx
  800fbc:	fd                   	std    
  800fbd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fbf:	eb 09                	jmp    800fca <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fc1:	83 ef 01             	sub    $0x1,%edi
  800fc4:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fc7:	fd                   	std    
  800fc8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fca:	fc                   	cld    
  800fcb:	eb 1d                	jmp    800fea <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fcd:	89 f2                	mov    %esi,%edx
  800fcf:	09 c2                	or     %eax,%edx
  800fd1:	f6 c2 03             	test   $0x3,%dl
  800fd4:	75 0f                	jne    800fe5 <memmove+0x5f>
  800fd6:	f6 c1 03             	test   $0x3,%cl
  800fd9:	75 0a                	jne    800fe5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fdb:	c1 e9 02             	shr    $0x2,%ecx
  800fde:	89 c7                	mov    %eax,%edi
  800fe0:	fc                   	cld    
  800fe1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fe3:	eb 05                	jmp    800fea <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fe5:	89 c7                	mov    %eax,%edi
  800fe7:	fc                   	cld    
  800fe8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ff1:	ff 75 10             	pushl  0x10(%ebp)
  800ff4:	ff 75 0c             	pushl  0xc(%ebp)
  800ff7:	ff 75 08             	pushl  0x8(%ebp)
  800ffa:	e8 87 ff ff ff       	call   800f86 <memmove>
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	8b 45 08             	mov    0x8(%ebp),%eax
  801009:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100c:	89 c6                	mov    %eax,%esi
  80100e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801011:	eb 1a                	jmp    80102d <memcmp+0x2c>
		if (*s1 != *s2)
  801013:	0f b6 08             	movzbl (%eax),%ecx
  801016:	0f b6 1a             	movzbl (%edx),%ebx
  801019:	38 d9                	cmp    %bl,%cl
  80101b:	74 0a                	je     801027 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80101d:	0f b6 c1             	movzbl %cl,%eax
  801020:	0f b6 db             	movzbl %bl,%ebx
  801023:	29 d8                	sub    %ebx,%eax
  801025:	eb 0f                	jmp    801036 <memcmp+0x35>
		s1++, s2++;
  801027:	83 c0 01             	add    $0x1,%eax
  80102a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80102d:	39 f0                	cmp    %esi,%eax
  80102f:	75 e2                	jne    801013 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801031:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	53                   	push   %ebx
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801041:	89 c1                	mov    %eax,%ecx
  801043:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801046:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80104a:	eb 0a                	jmp    801056 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80104c:	0f b6 10             	movzbl (%eax),%edx
  80104f:	39 da                	cmp    %ebx,%edx
  801051:	74 07                	je     80105a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801053:	83 c0 01             	add    $0x1,%eax
  801056:	39 c8                	cmp    %ecx,%eax
  801058:	72 f2                	jb     80104c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80105a:	5b                   	pop    %ebx
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801066:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801069:	eb 03                	jmp    80106e <strtol+0x11>
		s++;
  80106b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80106e:	0f b6 01             	movzbl (%ecx),%eax
  801071:	3c 20                	cmp    $0x20,%al
  801073:	74 f6                	je     80106b <strtol+0xe>
  801075:	3c 09                	cmp    $0x9,%al
  801077:	74 f2                	je     80106b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801079:	3c 2b                	cmp    $0x2b,%al
  80107b:	75 0a                	jne    801087 <strtol+0x2a>
		s++;
  80107d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801080:	bf 00 00 00 00       	mov    $0x0,%edi
  801085:	eb 11                	jmp    801098 <strtol+0x3b>
  801087:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80108c:	3c 2d                	cmp    $0x2d,%al
  80108e:	75 08                	jne    801098 <strtol+0x3b>
		s++, neg = 1;
  801090:	83 c1 01             	add    $0x1,%ecx
  801093:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801098:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80109e:	75 15                	jne    8010b5 <strtol+0x58>
  8010a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8010a3:	75 10                	jne    8010b5 <strtol+0x58>
  8010a5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010a9:	75 7c                	jne    801127 <strtol+0xca>
		s += 2, base = 16;
  8010ab:	83 c1 02             	add    $0x2,%ecx
  8010ae:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010b3:	eb 16                	jmp    8010cb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8010b5:	85 db                	test   %ebx,%ebx
  8010b7:	75 12                	jne    8010cb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010b9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010be:	80 39 30             	cmpb   $0x30,(%ecx)
  8010c1:	75 08                	jne    8010cb <strtol+0x6e>
		s++, base = 8;
  8010c3:	83 c1 01             	add    $0x1,%ecx
  8010c6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d3:	0f b6 11             	movzbl (%ecx),%edx
  8010d6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010d9:	89 f3                	mov    %esi,%ebx
  8010db:	80 fb 09             	cmp    $0x9,%bl
  8010de:	77 08                	ja     8010e8 <strtol+0x8b>
			dig = *s - '0';
  8010e0:	0f be d2             	movsbl %dl,%edx
  8010e3:	83 ea 30             	sub    $0x30,%edx
  8010e6:	eb 22                	jmp    80110a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8010e8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010eb:	89 f3                	mov    %esi,%ebx
  8010ed:	80 fb 19             	cmp    $0x19,%bl
  8010f0:	77 08                	ja     8010fa <strtol+0x9d>
			dig = *s - 'a' + 10;
  8010f2:	0f be d2             	movsbl %dl,%edx
  8010f5:	83 ea 57             	sub    $0x57,%edx
  8010f8:	eb 10                	jmp    80110a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8010fa:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010fd:	89 f3                	mov    %esi,%ebx
  8010ff:	80 fb 19             	cmp    $0x19,%bl
  801102:	77 16                	ja     80111a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801104:	0f be d2             	movsbl %dl,%edx
  801107:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80110a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80110d:	7d 0b                	jge    80111a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80110f:	83 c1 01             	add    $0x1,%ecx
  801112:	0f af 45 10          	imul   0x10(%ebp),%eax
  801116:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801118:	eb b9                	jmp    8010d3 <strtol+0x76>

	if (endptr)
  80111a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80111e:	74 0d                	je     80112d <strtol+0xd0>
		*endptr = (char *) s;
  801120:	8b 75 0c             	mov    0xc(%ebp),%esi
  801123:	89 0e                	mov    %ecx,(%esi)
  801125:	eb 06                	jmp    80112d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801127:	85 db                	test   %ebx,%ebx
  801129:	74 98                	je     8010c3 <strtol+0x66>
  80112b:	eb 9e                	jmp    8010cb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	f7 da                	neg    %edx
  801131:	85 ff                	test   %edi,%edi
  801133:	0f 45 c2             	cmovne %edx,%eax
}
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	5f                   	pop    %edi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	57                   	push   %edi
  80113f:	56                   	push   %esi
  801140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	89 c3                	mov    %eax,%ebx
  80114e:	89 c7                	mov    %eax,%edi
  801150:	89 c6                	mov    %eax,%esi
  801152:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <sys_cgetc>:

int
sys_cgetc(void)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	57                   	push   %edi
  80115d:	56                   	push   %esi
  80115e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115f:	ba 00 00 00 00       	mov    $0x0,%edx
  801164:	b8 01 00 00 00       	mov    $0x1,%eax
  801169:	89 d1                	mov    %edx,%ecx
  80116b:	89 d3                	mov    %edx,%ebx
  80116d:	89 d7                	mov    %edx,%edi
  80116f:	89 d6                	mov    %edx,%esi
  801171:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  801181:	b9 00 00 00 00       	mov    $0x0,%ecx
  801186:	b8 03 00 00 00       	mov    $0x3,%eax
  80118b:	8b 55 08             	mov    0x8(%ebp),%edx
  80118e:	89 cb                	mov    %ecx,%ebx
  801190:	89 cf                	mov    %ecx,%edi
  801192:	89 ce                	mov    %ecx,%esi
  801194:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801196:	85 c0                	test   %eax,%eax
  801198:	7e 17                	jle    8011b1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	50                   	push   %eax
  80119e:	6a 03                	push   $0x3
  8011a0:	68 7f 31 80 00       	push   $0x80317f
  8011a5:	6a 23                	push   $0x23
  8011a7:	68 9c 31 80 00       	push   $0x80319c
  8011ac:	e8 e5 f5 ff ff       	call   800796 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8011c9:	89 d1                	mov    %edx,%ecx
  8011cb:	89 d3                	mov    %edx,%ebx
  8011cd:	89 d7                	mov    %edx,%edi
  8011cf:	89 d6                	mov    %edx,%esi
  8011d1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <sys_yield>:

void
sys_yield(void)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	57                   	push   %edi
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011de:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011e8:	89 d1                	mov    %edx,%ecx
  8011ea:	89 d3                	mov    %edx,%ebx
  8011ec:	89 d7                	mov    %edx,%edi
  8011ee:	89 d6                	mov    %edx,%esi
  8011f0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801200:	be 00 00 00 00       	mov    $0x0,%esi
  801205:	b8 04 00 00 00       	mov    $0x4,%eax
  80120a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120d:	8b 55 08             	mov    0x8(%ebp),%edx
  801210:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801213:	89 f7                	mov    %esi,%edi
  801215:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801217:	85 c0                	test   %eax,%eax
  801219:	7e 17                	jle    801232 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121b:	83 ec 0c             	sub    $0xc,%esp
  80121e:	50                   	push   %eax
  80121f:	6a 04                	push   $0x4
  801221:	68 7f 31 80 00       	push   $0x80317f
  801226:	6a 23                	push   $0x23
  801228:	68 9c 31 80 00       	push   $0x80319c
  80122d:	e8 64 f5 ff ff       	call   800796 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5f                   	pop    %edi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	57                   	push   %edi
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
  801240:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801243:	b8 05 00 00 00       	mov    $0x5,%eax
  801248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124b:	8b 55 08             	mov    0x8(%ebp),%edx
  80124e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801251:	8b 7d 14             	mov    0x14(%ebp),%edi
  801254:	8b 75 18             	mov    0x18(%ebp),%esi
  801257:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801259:	85 c0                	test   %eax,%eax
  80125b:	7e 17                	jle    801274 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125d:	83 ec 0c             	sub    $0xc,%esp
  801260:	50                   	push   %eax
  801261:	6a 05                	push   $0x5
  801263:	68 7f 31 80 00       	push   $0x80317f
  801268:	6a 23                	push   $0x23
  80126a:	68 9c 31 80 00       	push   $0x80319c
  80126f:	e8 22 f5 ff ff       	call   800796 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801274:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5f                   	pop    %edi
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	57                   	push   %edi
  801280:	56                   	push   %esi
  801281:	53                   	push   %ebx
  801282:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128a:	b8 06 00 00 00       	mov    $0x6,%eax
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	8b 55 08             	mov    0x8(%ebp),%edx
  801295:	89 df                	mov    %ebx,%edi
  801297:	89 de                	mov    %ebx,%esi
  801299:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80129b:	85 c0                	test   %eax,%eax
  80129d:	7e 17                	jle    8012b6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80129f:	83 ec 0c             	sub    $0xc,%esp
  8012a2:	50                   	push   %eax
  8012a3:	6a 06                	push   $0x6
  8012a5:	68 7f 31 80 00       	push   $0x80317f
  8012aa:	6a 23                	push   $0x23
  8012ac:	68 9c 31 80 00       	push   $0x80319c
  8012b1:	e8 e0 f4 ff ff       	call   800796 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5f                   	pop    %edi
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8012d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d7:	89 df                	mov    %ebx,%edi
  8012d9:	89 de                	mov    %ebx,%esi
  8012db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	7e 17                	jle    8012f8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	50                   	push   %eax
  8012e5:	6a 08                	push   $0x8
  8012e7:	68 7f 31 80 00       	push   $0x80317f
  8012ec:	6a 23                	push   $0x23
  8012ee:	68 9c 31 80 00       	push   $0x80319c
  8012f3:	e8 9e f4 ff ff       	call   800796 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	57                   	push   %edi
  801304:	56                   	push   %esi
  801305:	53                   	push   %ebx
  801306:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130e:	b8 09 00 00 00       	mov    $0x9,%eax
  801313:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801316:	8b 55 08             	mov    0x8(%ebp),%edx
  801319:	89 df                	mov    %ebx,%edi
  80131b:	89 de                	mov    %ebx,%esi
  80131d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80131f:	85 c0                	test   %eax,%eax
  801321:	7e 17                	jle    80133a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	50                   	push   %eax
  801327:	6a 09                	push   $0x9
  801329:	68 7f 31 80 00       	push   $0x80317f
  80132e:	6a 23                	push   $0x23
  801330:	68 9c 31 80 00       	push   $0x80319c
  801335:	e8 5c f4 ff ff       	call   800796 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80133a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	57                   	push   %edi
  801346:	56                   	push   %esi
  801347:	53                   	push   %ebx
  801348:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80134b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801350:	b8 0a 00 00 00       	mov    $0xa,%eax
  801355:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801358:	8b 55 08             	mov    0x8(%ebp),%edx
  80135b:	89 df                	mov    %ebx,%edi
  80135d:	89 de                	mov    %ebx,%esi
  80135f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801361:	85 c0                	test   %eax,%eax
  801363:	7e 17                	jle    80137c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	50                   	push   %eax
  801369:	6a 0a                	push   $0xa
  80136b:	68 7f 31 80 00       	push   $0x80317f
  801370:	6a 23                	push   $0x23
  801372:	68 9c 31 80 00       	push   $0x80319c
  801377:	e8 1a f4 ff ff       	call   800796 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80137c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137f:	5b                   	pop    %ebx
  801380:	5e                   	pop    %esi
  801381:	5f                   	pop    %edi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	57                   	push   %edi
  801388:	56                   	push   %esi
  801389:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80138a:	be 00 00 00 00       	mov    $0x0,%esi
  80138f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801394:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801397:	8b 55 08             	mov    0x8(%ebp),%edx
  80139a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80139d:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013a0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5f                   	pop    %edi
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	57                   	push   %edi
  8013ab:	56                   	push   %esi
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bd:	89 cb                	mov    %ecx,%ebx
  8013bf:	89 cf                	mov    %ecx,%edi
  8013c1:	89 ce                	mov    %ecx,%esi
  8013c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	7e 17                	jle    8013e0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c9:	83 ec 0c             	sub    $0xc,%esp
  8013cc:	50                   	push   %eax
  8013cd:	6a 0d                	push   $0xd
  8013cf:	68 7f 31 80 00       	push   $0x80317f
  8013d4:	6a 23                	push   $0x23
  8013d6:	68 9c 31 80 00       	push   $0x80319c
  8013db:	e8 b6 f3 ff ff       	call   800796 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5f                   	pop    %edi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	57                   	push   %edi
  8013ec:	56                   	push   %esi
  8013ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f3:	b8 0e 00 00 00       	mov    $0xe,%eax
  8013f8:	89 d1                	mov    %edx,%ecx
  8013fa:	89 d3                	mov    %edx,%ebx
  8013fc:	89 d7                	mov    %edx,%edi
  8013fe:	89 d6                	mov    %edx,%esi
  801400:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801402:	5b                   	pop    %ebx
  801403:	5e                   	pop    %esi
  801404:	5f                   	pop    %edi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	57                   	push   %edi
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80140d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801412:	b8 0f 00 00 00       	mov    $0xf,%eax
  801417:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141a:	8b 55 08             	mov    0x8(%ebp),%edx
  80141d:	89 df                	mov    %ebx,%edi
  80141f:	89 de                	mov    %ebx,%esi
  801421:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801432:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  801434:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801438:	74 2e                	je     801468 <pgfault+0x40>
  80143a:	89 c2                	mov    %eax,%edx
  80143c:	c1 ea 16             	shr    $0x16,%edx
  80143f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801446:	f6 c2 01             	test   $0x1,%dl
  801449:	74 1d                	je     801468 <pgfault+0x40>
  80144b:	89 c2                	mov    %eax,%edx
  80144d:	c1 ea 0c             	shr    $0xc,%edx
  801450:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801457:	f6 c1 01             	test   $0x1,%cl
  80145a:	74 0c                	je     801468 <pgfault+0x40>
  80145c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801463:	f6 c6 08             	test   $0x8,%dh
  801466:	75 14                	jne    80147c <pgfault+0x54>
        panic("Not copy-on-write\n");
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	68 aa 31 80 00       	push   $0x8031aa
  801470:	6a 1d                	push   $0x1d
  801472:	68 bd 31 80 00       	push   $0x8031bd
  801477:	e8 1a f3 ff ff       	call   800796 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  80147c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801481:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	6a 07                	push   $0x7
  801488:	68 00 f0 7f 00       	push   $0x7ff000
  80148d:	6a 00                	push   $0x0
  80148f:	e8 63 fd ff ff       	call   8011f7 <sys_page_alloc>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	79 14                	jns    8014af <pgfault+0x87>
		panic("page alloc failed \n");
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	68 c8 31 80 00       	push   $0x8031c8
  8014a3:	6a 28                	push   $0x28
  8014a5:	68 bd 31 80 00       	push   $0x8031bd
  8014aa:	e8 e7 f2 ff ff       	call   800796 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	68 00 10 00 00       	push   $0x1000
  8014b7:	53                   	push   %ebx
  8014b8:	68 00 f0 7f 00       	push   $0x7ff000
  8014bd:	e8 2c fb ff ff       	call   800fee <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  8014c2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8014c9:	53                   	push   %ebx
  8014ca:	6a 00                	push   $0x0
  8014cc:	68 00 f0 7f 00       	push   $0x7ff000
  8014d1:	6a 00                	push   $0x0
  8014d3:	e8 62 fd ff ff       	call   80123a <sys_page_map>
  8014d8:	83 c4 20             	add    $0x20,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	79 14                	jns    8014f3 <pgfault+0xcb>
        panic("page map failed \n");
  8014df:	83 ec 04             	sub    $0x4,%esp
  8014e2:	68 dc 31 80 00       	push   $0x8031dc
  8014e7:	6a 2b                	push   $0x2b
  8014e9:	68 bd 31 80 00       	push   $0x8031bd
  8014ee:	e8 a3 f2 ff ff       	call   800796 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	68 00 f0 7f 00       	push   $0x7ff000
  8014fb:	6a 00                	push   $0x0
  8014fd:	e8 7a fd ff ff       	call   80127c <sys_page_unmap>
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	85 c0                	test   %eax,%eax
  801507:	79 14                	jns    80151d <pgfault+0xf5>
        panic("page unmap failed\n");
  801509:	83 ec 04             	sub    $0x4,%esp
  80150c:	68 ee 31 80 00       	push   $0x8031ee
  801511:	6a 2d                	push   $0x2d
  801513:	68 bd 31 80 00       	push   $0x8031bd
  801518:	e8 79 f2 ff ff       	call   800796 <_panic>
	
	//panic("pgfault not implemented");
}
  80151d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	57                   	push   %edi
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  80152b:	68 28 14 80 00       	push   $0x801428
  801530:	e8 51 14 00 00       	call   802986 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801535:	b8 07 00 00 00       	mov    $0x7,%eax
  80153a:	cd 30                	int    $0x30
  80153c:	89 c7                	mov    %eax,%edi
  80153e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	79 12                	jns    80155a <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  801548:	50                   	push   %eax
  801549:	68 01 32 80 00       	push   $0x803201
  80154e:	6a 7a                	push   $0x7a
  801550:	68 bd 31 80 00       	push   $0x8031bd
  801555:	e8 3c f2 ff ff       	call   800796 <_panic>
  80155a:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  80155f:	85 c0                	test   %eax,%eax
  801561:	75 21                	jne    801584 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  801563:	e8 51 fc ff ff       	call   8011b9 <sys_getenvid>
  801568:	25 ff 03 00 00       	and    $0x3ff,%eax
  80156d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801570:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801575:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  80157a:	b8 00 00 00 00       	mov    $0x0,%eax
  80157f:	e9 91 01 00 00       	jmp    801715 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  801584:	89 d8                	mov    %ebx,%eax
  801586:	c1 e8 16             	shr    $0x16,%eax
  801589:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801590:	a8 01                	test   $0x1,%al
  801592:	0f 84 06 01 00 00    	je     80169e <fork+0x17c>
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	c1 e8 0c             	shr    $0xc,%eax
  80159d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015a4:	f6 c2 01             	test   $0x1,%dl
  8015a7:	0f 84 f1 00 00 00    	je     80169e <fork+0x17c>
  8015ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015b4:	f6 c2 04             	test   $0x4,%dl
  8015b7:	0f 84 e1 00 00 00    	je     80169e <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  8015bd:	89 c6                	mov    %eax,%esi
  8015bf:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  8015c2:	89 f2                	mov    %esi,%edx
  8015c4:	c1 ea 16             	shr    $0x16,%edx
  8015c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  8015ce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  8015d5:	f6 c6 04             	test   $0x4,%dh
  8015d8:	74 39                	je     801613 <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  8015da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e9:	50                   	push   %eax
  8015ea:	56                   	push   %esi
  8015eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ee:	56                   	push   %esi
  8015ef:	6a 00                	push   $0x0
  8015f1:	e8 44 fc ff ff       	call   80123a <sys_page_map>
  8015f6:	83 c4 20             	add    $0x20,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	0f 89 9d 00 00 00    	jns    80169e <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  801601:	50                   	push   %eax
  801602:	68 58 32 80 00       	push   $0x803258
  801607:	6a 4b                	push   $0x4b
  801609:	68 bd 31 80 00       	push   $0x8031bd
  80160e:	e8 83 f1 ff ff       	call   800796 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  801613:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801619:	74 59                	je     801674 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	68 05 08 00 00       	push   $0x805
  801623:	56                   	push   %esi
  801624:	ff 75 e4             	pushl  -0x1c(%ebp)
  801627:	56                   	push   %esi
  801628:	6a 00                	push   $0x0
  80162a:	e8 0b fc ff ff       	call   80123a <sys_page_map>
  80162f:	83 c4 20             	add    $0x20,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	79 12                	jns    801648 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  801636:	50                   	push   %eax
  801637:	68 88 32 80 00       	push   $0x803288
  80163c:	6a 50                	push   $0x50
  80163e:	68 bd 31 80 00       	push   $0x8031bd
  801643:	e8 4e f1 ff ff       	call   800796 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	68 05 08 00 00       	push   $0x805
  801650:	56                   	push   %esi
  801651:	6a 00                	push   $0x0
  801653:	56                   	push   %esi
  801654:	6a 00                	push   $0x0
  801656:	e8 df fb ff ff       	call   80123a <sys_page_map>
  80165b:	83 c4 20             	add    $0x20,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	79 3c                	jns    80169e <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  801662:	50                   	push   %eax
  801663:	68 b0 32 80 00       	push   $0x8032b0
  801668:	6a 53                	push   $0x53
  80166a:	68 bd 31 80 00       	push   $0x8031bd
  80166f:	e8 22 f1 ff ff       	call   800796 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  801674:	83 ec 0c             	sub    $0xc,%esp
  801677:	6a 05                	push   $0x5
  801679:	56                   	push   %esi
  80167a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167d:	56                   	push   %esi
  80167e:	6a 00                	push   $0x0
  801680:	e8 b5 fb ff ff       	call   80123a <sys_page_map>
  801685:	83 c4 20             	add    $0x20,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	79 12                	jns    80169e <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  80168c:	50                   	push   %eax
  80168d:	68 d8 32 80 00       	push   $0x8032d8
  801692:	6a 58                	push   $0x58
  801694:	68 bd 31 80 00       	push   $0x8031bd
  801699:	e8 f8 f0 ff ff       	call   800796 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  80169e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8016a4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8016aa:	0f 85 d4 fe ff ff    	jne    801584 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  8016b0:	83 ec 04             	sub    $0x4,%esp
  8016b3:	6a 07                	push   $0x7
  8016b5:	68 00 f0 bf ee       	push   $0xeebff000
  8016ba:	57                   	push   %edi
  8016bb:	e8 37 fb ff ff       	call   8011f7 <sys_page_alloc>
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	79 17                	jns    8016de <fork+0x1bc>
        panic("page alloc failed\n");
  8016c7:	83 ec 04             	sub    $0x4,%esp
  8016ca:	68 13 32 80 00       	push   $0x803213
  8016cf:	68 87 00 00 00       	push   $0x87
  8016d4:	68 bd 31 80 00       	push   $0x8031bd
  8016d9:	e8 b8 f0 ff ff       	call   800796 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	68 f5 29 80 00       	push   $0x8029f5
  8016e6:	57                   	push   %edi
  8016e7:	e8 56 fc ff ff       	call   801342 <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8016ec:	83 c4 08             	add    $0x8,%esp
  8016ef:	6a 02                	push   $0x2
  8016f1:	57                   	push   %edi
  8016f2:	e8 c7 fb ff ff       	call   8012be <sys_env_set_status>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	79 15                	jns    801713 <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  8016fe:	50                   	push   %eax
  8016ff:	68 26 32 80 00       	push   $0x803226
  801704:	68 8c 00 00 00       	push   $0x8c
  801709:	68 bd 31 80 00       	push   $0x8031bd
  80170e:	e8 83 f0 ff ff       	call   800796 <_panic>

	return envid;
  801713:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  801715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5f                   	pop    %edi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <sfork>:

// Challenge!
int
sfork(void)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801723:	68 3f 32 80 00       	push   $0x80323f
  801728:	68 98 00 00 00       	push   $0x98
  80172d:	68 bd 31 80 00       	push   $0x8031bd
  801732:	e8 5f f0 ff ff       	call   800796 <_panic>

00801737 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	8b 75 08             	mov    0x8(%ebp),%esi
  80173f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801742:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801745:	85 c0                	test   %eax,%eax
  801747:	74 0e                	je     801757 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801749:	83 ec 0c             	sub    $0xc,%esp
  80174c:	50                   	push   %eax
  80174d:	e8 55 fc ff ff       	call   8013a7 <sys_ipc_recv>
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	eb 10                	jmp    801767 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	68 00 00 00 f0       	push   $0xf0000000
  80175f:	e8 43 fc ff ff       	call   8013a7 <sys_ipc_recv>
  801764:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801767:	85 c0                	test   %eax,%eax
  801769:	74 0e                	je     801779 <ipc_recv+0x42>
    	*from_env_store = 0;
  80176b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801771:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801777:	eb 24                	jmp    80179d <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801779:	85 f6                	test   %esi,%esi
  80177b:	74 0a                	je     801787 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  80177d:	a1 20 50 80 00       	mov    0x805020,%eax
  801782:	8b 40 74             	mov    0x74(%eax),%eax
  801785:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801787:	85 db                	test   %ebx,%ebx
  801789:	74 0a                	je     801795 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  80178b:	a1 20 50 80 00       	mov    0x805020,%eax
  801790:	8b 40 78             	mov    0x78(%eax),%eax
  801793:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801795:	a1 20 50 80 00       	mov    0x805020,%eax
  80179a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80179d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	57                   	push   %edi
  8017a8:	56                   	push   %esi
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 0c             	sub    $0xc,%esp
  8017ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8017b6:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8017b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8017bd:	0f 44 d8             	cmove  %eax,%ebx
  8017c0:	eb 1c                	jmp    8017de <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8017c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017c5:	74 12                	je     8017d9 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8017c7:	50                   	push   %eax
  8017c8:	68 04 33 80 00       	push   $0x803304
  8017cd:	6a 4b                	push   $0x4b
  8017cf:	68 1c 33 80 00       	push   $0x80331c
  8017d4:	e8 bd ef ff ff       	call   800796 <_panic>
        }	
        sys_yield();
  8017d9:	e8 fa f9 ff ff       	call   8011d8 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8017de:	ff 75 14             	pushl  0x14(%ebp)
  8017e1:	53                   	push   %ebx
  8017e2:	56                   	push   %esi
  8017e3:	57                   	push   %edi
  8017e4:	e8 9b fb ff ff       	call   801384 <sys_ipc_try_send>
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	75 d2                	jne    8017c2 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8017f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5f                   	pop    %edi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8017fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801803:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801806:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80180c:	8b 52 50             	mov    0x50(%edx),%edx
  80180f:	39 ca                	cmp    %ecx,%edx
  801811:	75 0d                	jne    801820 <ipc_find_env+0x28>
			return envs[i].env_id;
  801813:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801816:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80181b:	8b 40 48             	mov    0x48(%eax),%eax
  80181e:	eb 0f                	jmp    80182f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801820:	83 c0 01             	add    $0x1,%eax
  801823:	3d 00 04 00 00       	cmp    $0x400,%eax
  801828:	75 d9                	jne    801803 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80182a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	05 00 00 00 30       	add    $0x30000000,%eax
  80183c:	c1 e8 0c             	shr    $0xc,%eax
}
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	05 00 00 00 30       	add    $0x30000000,%eax
  80184c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801851:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801863:	89 c2                	mov    %eax,%edx
  801865:	c1 ea 16             	shr    $0x16,%edx
  801868:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80186f:	f6 c2 01             	test   $0x1,%dl
  801872:	74 11                	je     801885 <fd_alloc+0x2d>
  801874:	89 c2                	mov    %eax,%edx
  801876:	c1 ea 0c             	shr    $0xc,%edx
  801879:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801880:	f6 c2 01             	test   $0x1,%dl
  801883:	75 09                	jne    80188e <fd_alloc+0x36>
			*fd_store = fd;
  801885:	89 01                	mov    %eax,(%ecx)
			return 0;
  801887:	b8 00 00 00 00       	mov    $0x0,%eax
  80188c:	eb 17                	jmp    8018a5 <fd_alloc+0x4d>
  80188e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801893:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801898:	75 c9                	jne    801863 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80189a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8018a0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8018ad:	83 f8 1f             	cmp    $0x1f,%eax
  8018b0:	77 36                	ja     8018e8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8018b2:	c1 e0 0c             	shl    $0xc,%eax
  8018b5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	c1 ea 16             	shr    $0x16,%edx
  8018bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8018c6:	f6 c2 01             	test   $0x1,%dl
  8018c9:	74 24                	je     8018ef <fd_lookup+0x48>
  8018cb:	89 c2                	mov    %eax,%edx
  8018cd:	c1 ea 0c             	shr    $0xc,%edx
  8018d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018d7:	f6 c2 01             	test   $0x1,%dl
  8018da:	74 1a                	je     8018f6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018df:	89 02                	mov    %eax,(%edx)
	return 0;
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e6:	eb 13                	jmp    8018fb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018ed:	eb 0c                	jmp    8018fb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f4:	eb 05                	jmp    8018fb <fd_lookup+0x54>
  8018f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801906:	ba a4 33 80 00       	mov    $0x8033a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80190b:	eb 13                	jmp    801920 <dev_lookup+0x23>
  80190d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801910:	39 08                	cmp    %ecx,(%eax)
  801912:	75 0c                	jne    801920 <dev_lookup+0x23>
			*dev = devtab[i];
  801914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801917:	89 01                	mov    %eax,(%ecx)
			return 0;
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
  80191e:	eb 2e                	jmp    80194e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801920:	8b 02                	mov    (%edx),%eax
  801922:	85 c0                	test   %eax,%eax
  801924:	75 e7                	jne    80190d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801926:	a1 20 50 80 00       	mov    0x805020,%eax
  80192b:	8b 40 48             	mov    0x48(%eax),%eax
  80192e:	83 ec 04             	sub    $0x4,%esp
  801931:	51                   	push   %ecx
  801932:	50                   	push   %eax
  801933:	68 28 33 80 00       	push   $0x803328
  801938:	e8 32 ef ff ff       	call   80086f <cprintf>
	*dev = 0;
  80193d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801940:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
  801955:	83 ec 10             	sub    $0x10,%esp
  801958:	8b 75 08             	mov    0x8(%ebp),%esi
  80195b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80195e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801968:	c1 e8 0c             	shr    $0xc,%eax
  80196b:	50                   	push   %eax
  80196c:	e8 36 ff ff ff       	call   8018a7 <fd_lookup>
  801971:	83 c4 08             	add    $0x8,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	78 05                	js     80197d <fd_close+0x2d>
	    || fd != fd2)
  801978:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80197b:	74 0c                	je     801989 <fd_close+0x39>
		return (must_exist ? r : 0);
  80197d:	84 db                	test   %bl,%bl
  80197f:	ba 00 00 00 00       	mov    $0x0,%edx
  801984:	0f 44 c2             	cmove  %edx,%eax
  801987:	eb 41                	jmp    8019ca <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198f:	50                   	push   %eax
  801990:	ff 36                	pushl  (%esi)
  801992:	e8 66 ff ff ff       	call   8018fd <dev_lookup>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 1a                	js     8019ba <fd_close+0x6a>
		if (dev->dev_close)
  8019a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8019a6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	74 0b                	je     8019ba <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	56                   	push   %esi
  8019b3:	ff d0                	call   *%eax
  8019b5:	89 c3                	mov    %eax,%ebx
  8019b7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	56                   	push   %esi
  8019be:	6a 00                	push   $0x0
  8019c0:	e8 b7 f8 ff ff       	call   80127c <sys_page_unmap>
	return r;
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	89 d8                	mov    %ebx,%eax
}
  8019ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5e                   	pop    %esi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019da:	50                   	push   %eax
  8019db:	ff 75 08             	pushl  0x8(%ebp)
  8019de:	e8 c4 fe ff ff       	call   8018a7 <fd_lookup>
  8019e3:	83 c4 08             	add    $0x8,%esp
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	78 10                	js     8019fa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	6a 01                	push   $0x1
  8019ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f2:	e8 59 ff ff ff       	call   801950 <fd_close>
  8019f7:	83 c4 10             	add    $0x10,%esp
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <close_all>:

void
close_all(void)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801a03:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	53                   	push   %ebx
  801a0c:	e8 c0 ff ff ff       	call   8019d1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a11:	83 c3 01             	add    $0x1,%ebx
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	83 fb 20             	cmp    $0x20,%ebx
  801a1a:	75 ec                	jne    801a08 <close_all+0xc>
		close(i);
}
  801a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	57                   	push   %edi
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	83 ec 2c             	sub    $0x2c,%esp
  801a2a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a2d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a30:	50                   	push   %eax
  801a31:	ff 75 08             	pushl  0x8(%ebp)
  801a34:	e8 6e fe ff ff       	call   8018a7 <fd_lookup>
  801a39:	83 c4 08             	add    $0x8,%esp
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	0f 88 c1 00 00 00    	js     801b05 <dup+0xe4>
		return r;
	close(newfdnum);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	56                   	push   %esi
  801a48:	e8 84 ff ff ff       	call   8019d1 <close>

	newfd = INDEX2FD(newfdnum);
  801a4d:	89 f3                	mov    %esi,%ebx
  801a4f:	c1 e3 0c             	shl    $0xc,%ebx
  801a52:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801a58:	83 c4 04             	add    $0x4,%esp
  801a5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a5e:	e8 de fd ff ff       	call   801841 <fd2data>
  801a63:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801a65:	89 1c 24             	mov    %ebx,(%esp)
  801a68:	e8 d4 fd ff ff       	call   801841 <fd2data>
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801a73:	89 f8                	mov    %edi,%eax
  801a75:	c1 e8 16             	shr    $0x16,%eax
  801a78:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a7f:	a8 01                	test   $0x1,%al
  801a81:	74 37                	je     801aba <dup+0x99>
  801a83:	89 f8                	mov    %edi,%eax
  801a85:	c1 e8 0c             	shr    $0xc,%eax
  801a88:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a8f:	f6 c2 01             	test   $0x1,%dl
  801a92:	74 26                	je     801aba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a94:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	25 07 0e 00 00       	and    $0xe07,%eax
  801aa3:	50                   	push   %eax
  801aa4:	ff 75 d4             	pushl  -0x2c(%ebp)
  801aa7:	6a 00                	push   $0x0
  801aa9:	57                   	push   %edi
  801aaa:	6a 00                	push   $0x0
  801aac:	e8 89 f7 ff ff       	call   80123a <sys_page_map>
  801ab1:	89 c7                	mov    %eax,%edi
  801ab3:	83 c4 20             	add    $0x20,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 2e                	js     801ae8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801aba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801abd:	89 d0                	mov    %edx,%eax
  801abf:	c1 e8 0c             	shr    $0xc,%eax
  801ac2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	25 07 0e 00 00       	and    $0xe07,%eax
  801ad1:	50                   	push   %eax
  801ad2:	53                   	push   %ebx
  801ad3:	6a 00                	push   $0x0
  801ad5:	52                   	push   %edx
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 5d f7 ff ff       	call   80123a <sys_page_map>
  801add:	89 c7                	mov    %eax,%edi
  801adf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801ae2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ae4:	85 ff                	test   %edi,%edi
  801ae6:	79 1d                	jns    801b05 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ae8:	83 ec 08             	sub    $0x8,%esp
  801aeb:	53                   	push   %ebx
  801aec:	6a 00                	push   $0x0
  801aee:	e8 89 f7 ff ff       	call   80127c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801af3:	83 c4 08             	add    $0x8,%esp
  801af6:	ff 75 d4             	pushl  -0x2c(%ebp)
  801af9:	6a 00                	push   $0x0
  801afb:	e8 7c f7 ff ff       	call   80127c <sys_page_unmap>
	return r;
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	89 f8                	mov    %edi,%eax
}
  801b05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5f                   	pop    %edi
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    

00801b0d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	53                   	push   %ebx
  801b11:	83 ec 14             	sub    $0x14,%esp
  801b14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b1a:	50                   	push   %eax
  801b1b:	53                   	push   %ebx
  801b1c:	e8 86 fd ff ff       	call   8018a7 <fd_lookup>
  801b21:	83 c4 08             	add    $0x8,%esp
  801b24:	89 c2                	mov    %eax,%edx
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 6d                	js     801b97 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b2a:	83 ec 08             	sub    $0x8,%esp
  801b2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b34:	ff 30                	pushl  (%eax)
  801b36:	e8 c2 fd ff ff       	call   8018fd <dev_lookup>
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 4c                	js     801b8e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b42:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b45:	8b 42 08             	mov    0x8(%edx),%eax
  801b48:	83 e0 03             	and    $0x3,%eax
  801b4b:	83 f8 01             	cmp    $0x1,%eax
  801b4e:	75 21                	jne    801b71 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801b50:	a1 20 50 80 00       	mov    0x805020,%eax
  801b55:	8b 40 48             	mov    0x48(%eax),%eax
  801b58:	83 ec 04             	sub    $0x4,%esp
  801b5b:	53                   	push   %ebx
  801b5c:	50                   	push   %eax
  801b5d:	68 69 33 80 00       	push   $0x803369
  801b62:	e8 08 ed ff ff       	call   80086f <cprintf>
		return -E_INVAL;
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b6f:	eb 26                	jmp    801b97 <read+0x8a>
	}
	if (!dev->dev_read)
  801b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b74:	8b 40 08             	mov    0x8(%eax),%eax
  801b77:	85 c0                	test   %eax,%eax
  801b79:	74 17                	je     801b92 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801b7b:	83 ec 04             	sub    $0x4,%esp
  801b7e:	ff 75 10             	pushl  0x10(%ebp)
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	52                   	push   %edx
  801b85:	ff d0                	call   *%eax
  801b87:	89 c2                	mov    %eax,%edx
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	eb 09                	jmp    801b97 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b8e:	89 c2                	mov    %eax,%edx
  801b90:	eb 05                	jmp    801b97 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801b92:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801b97:	89 d0                	mov    %edx,%eax
  801b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 0c             	sub    $0xc,%esp
  801ba7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801baa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb2:	eb 21                	jmp    801bd5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801bb4:	83 ec 04             	sub    $0x4,%esp
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	29 d8                	sub    %ebx,%eax
  801bbb:	50                   	push   %eax
  801bbc:	89 d8                	mov    %ebx,%eax
  801bbe:	03 45 0c             	add    0xc(%ebp),%eax
  801bc1:	50                   	push   %eax
  801bc2:	57                   	push   %edi
  801bc3:	e8 45 ff ff ff       	call   801b0d <read>
		if (m < 0)
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 10                	js     801bdf <readn+0x41>
			return m;
		if (m == 0)
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	74 0a                	je     801bdd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bd3:	01 c3                	add    %eax,%ebx
  801bd5:	39 f3                	cmp    %esi,%ebx
  801bd7:	72 db                	jb     801bb4 <readn+0x16>
  801bd9:	89 d8                	mov    %ebx,%eax
  801bdb:	eb 02                	jmp    801bdf <readn+0x41>
  801bdd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be2:	5b                   	pop    %ebx
  801be3:	5e                   	pop    %esi
  801be4:	5f                   	pop    %edi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	53                   	push   %ebx
  801beb:	83 ec 14             	sub    $0x14,%esp
  801bee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bf1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	53                   	push   %ebx
  801bf6:	e8 ac fc ff ff       	call   8018a7 <fd_lookup>
  801bfb:	83 c4 08             	add    $0x8,%esp
  801bfe:	89 c2                	mov    %eax,%edx
  801c00:	85 c0                	test   %eax,%eax
  801c02:	78 68                	js     801c6c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c04:	83 ec 08             	sub    $0x8,%esp
  801c07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0a:	50                   	push   %eax
  801c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0e:	ff 30                	pushl  (%eax)
  801c10:	e8 e8 fc ff ff       	call   8018fd <dev_lookup>
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	78 47                	js     801c63 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c23:	75 21                	jne    801c46 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801c25:	a1 20 50 80 00       	mov    0x805020,%eax
  801c2a:	8b 40 48             	mov    0x48(%eax),%eax
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	53                   	push   %ebx
  801c31:	50                   	push   %eax
  801c32:	68 85 33 80 00       	push   $0x803385
  801c37:	e8 33 ec ff ff       	call   80086f <cprintf>
		return -E_INVAL;
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c44:	eb 26                	jmp    801c6c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c49:	8b 52 0c             	mov    0xc(%edx),%edx
  801c4c:	85 d2                	test   %edx,%edx
  801c4e:	74 17                	je     801c67 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c50:	83 ec 04             	sub    $0x4,%esp
  801c53:	ff 75 10             	pushl  0x10(%ebp)
  801c56:	ff 75 0c             	pushl  0xc(%ebp)
  801c59:	50                   	push   %eax
  801c5a:	ff d2                	call   *%edx
  801c5c:	89 c2                	mov    %eax,%edx
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	eb 09                	jmp    801c6c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c63:	89 c2                	mov    %eax,%edx
  801c65:	eb 05                	jmp    801c6c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801c67:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801c6c:	89 d0                	mov    %edx,%eax
  801c6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <seek>:

int
seek(int fdnum, off_t offset)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c79:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c7c:	50                   	push   %eax
  801c7d:	ff 75 08             	pushl  0x8(%ebp)
  801c80:	e8 22 fc ff ff       	call   8018a7 <fd_lookup>
  801c85:	83 c4 08             	add    $0x8,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	78 0e                	js     801c9a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801c8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c92:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	53                   	push   %ebx
  801ca0:	83 ec 14             	sub    $0x14,%esp
  801ca3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ca6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca9:	50                   	push   %eax
  801caa:	53                   	push   %ebx
  801cab:	e8 f7 fb ff ff       	call   8018a7 <fd_lookup>
  801cb0:	83 c4 08             	add    $0x8,%esp
  801cb3:	89 c2                	mov    %eax,%edx
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 65                	js     801d1e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cb9:	83 ec 08             	sub    $0x8,%esp
  801cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbf:	50                   	push   %eax
  801cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc3:	ff 30                	pushl  (%eax)
  801cc5:	e8 33 fc ff ff       	call   8018fd <dev_lookup>
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	78 44                	js     801d15 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801cd8:	75 21                	jne    801cfb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801cda:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801cdf:	8b 40 48             	mov    0x48(%eax),%eax
  801ce2:	83 ec 04             	sub    $0x4,%esp
  801ce5:	53                   	push   %ebx
  801ce6:	50                   	push   %eax
  801ce7:	68 48 33 80 00       	push   $0x803348
  801cec:	e8 7e eb ff ff       	call   80086f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801cf9:	eb 23                	jmp    801d1e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801cfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cfe:	8b 52 18             	mov    0x18(%edx),%edx
  801d01:	85 d2                	test   %edx,%edx
  801d03:	74 14                	je     801d19 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801d05:	83 ec 08             	sub    $0x8,%esp
  801d08:	ff 75 0c             	pushl  0xc(%ebp)
  801d0b:	50                   	push   %eax
  801d0c:	ff d2                	call   *%edx
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	eb 09                	jmp    801d1e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d15:	89 c2                	mov    %eax,%edx
  801d17:	eb 05                	jmp    801d1e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801d19:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801d1e:	89 d0                	mov    %edx,%eax
  801d20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	53                   	push   %ebx
  801d29:	83 ec 14             	sub    $0x14,%esp
  801d2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d32:	50                   	push   %eax
  801d33:	ff 75 08             	pushl  0x8(%ebp)
  801d36:	e8 6c fb ff ff       	call   8018a7 <fd_lookup>
  801d3b:	83 c4 08             	add    $0x8,%esp
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	85 c0                	test   %eax,%eax
  801d42:	78 58                	js     801d9c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4e:	ff 30                	pushl  (%eax)
  801d50:	e8 a8 fb ff ff       	call   8018fd <dev_lookup>
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	78 37                	js     801d93 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801d63:	74 32                	je     801d97 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d65:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d68:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d6f:	00 00 00 
	stat->st_isdir = 0;
  801d72:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d79:	00 00 00 
	stat->st_dev = dev;
  801d7c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d82:	83 ec 08             	sub    $0x8,%esp
  801d85:	53                   	push   %ebx
  801d86:	ff 75 f0             	pushl  -0x10(%ebp)
  801d89:	ff 50 14             	call   *0x14(%eax)
  801d8c:	89 c2                	mov    %eax,%edx
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	eb 09                	jmp    801d9c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d93:	89 c2                	mov    %eax,%edx
  801d95:	eb 05                	jmp    801d9c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d97:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d9c:	89 d0                	mov    %edx,%eax
  801d9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	56                   	push   %esi
  801da7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801da8:	83 ec 08             	sub    $0x8,%esp
  801dab:	6a 00                	push   $0x0
  801dad:	ff 75 08             	pushl  0x8(%ebp)
  801db0:	e8 e7 01 00 00       	call   801f9c <open>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	78 1b                	js     801dd9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801dbe:	83 ec 08             	sub    $0x8,%esp
  801dc1:	ff 75 0c             	pushl  0xc(%ebp)
  801dc4:	50                   	push   %eax
  801dc5:	e8 5b ff ff ff       	call   801d25 <fstat>
  801dca:	89 c6                	mov    %eax,%esi
	close(fd);
  801dcc:	89 1c 24             	mov    %ebx,(%esp)
  801dcf:	e8 fd fb ff ff       	call   8019d1 <close>
	return r;
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	89 f0                	mov    %esi,%eax
}
  801dd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ddc:	5b                   	pop    %ebx
  801ddd:	5e                   	pop    %esi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
  801de5:	89 c6                	mov    %eax,%esi
  801de7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801de9:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801df0:	75 12                	jne    801e04 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801df2:	83 ec 0c             	sub    $0xc,%esp
  801df5:	6a 01                	push   $0x1
  801df7:	e8 fc f9 ff ff       	call   8017f8 <ipc_find_env>
  801dfc:	a3 18 50 80 00       	mov    %eax,0x805018
  801e01:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e04:	6a 07                	push   $0x7
  801e06:	68 00 60 80 00       	push   $0x806000
  801e0b:	56                   	push   %esi
  801e0c:	ff 35 18 50 80 00    	pushl  0x805018
  801e12:	e8 8d f9 ff ff       	call   8017a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801e17:	83 c4 0c             	add    $0xc,%esp
  801e1a:	6a 00                	push   $0x0
  801e1c:	53                   	push   %ebx
  801e1d:	6a 00                	push   $0x0
  801e1f:	e8 13 f9 ff ff       	call   801737 <ipc_recv>
}
  801e24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801e31:	8b 45 08             	mov    0x8(%ebp),%eax
  801e34:	8b 40 0c             	mov    0xc(%eax),%eax
  801e37:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3f:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e44:	ba 00 00 00 00       	mov    $0x0,%edx
  801e49:	b8 02 00 00 00       	mov    $0x2,%eax
  801e4e:	e8 8d ff ff ff       	call   801de0 <fsipc>
}
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e61:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e66:	ba 00 00 00 00       	mov    $0x0,%edx
  801e6b:	b8 06 00 00 00       	mov    $0x6,%eax
  801e70:	e8 6b ff ff ff       	call   801de0 <fsipc>
}
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	53                   	push   %ebx
  801e7b:	83 ec 04             	sub    $0x4,%esp
  801e7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e81:	8b 45 08             	mov    0x8(%ebp),%eax
  801e84:	8b 40 0c             	mov    0xc(%eax),%eax
  801e87:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e91:	b8 05 00 00 00       	mov    $0x5,%eax
  801e96:	e8 45 ff ff ff       	call   801de0 <fsipc>
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 2c                	js     801ecb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e9f:	83 ec 08             	sub    $0x8,%esp
  801ea2:	68 00 60 80 00       	push   $0x806000
  801ea7:	53                   	push   %ebx
  801ea8:	e8 47 ef ff ff       	call   800df4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ead:	a1 80 60 80 00       	mov    0x806080,%eax
  801eb2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801eb8:	a1 84 60 80 00       	mov    0x806084,%eax
  801ebd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 08             	sub    $0x8,%esp
  801ed7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801eda:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801edf:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801ee4:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ee7:	53                   	push   %ebx
  801ee8:	ff 75 0c             	pushl  0xc(%ebp)
  801eeb:	68 08 60 80 00       	push   $0x806008
  801ef0:	e8 91 f0 ff ff       	call   800f86 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef8:	8b 40 0c             	mov    0xc(%eax),%eax
  801efb:	a3 00 60 80 00       	mov    %eax,0x806000
 	fsipcbuf.write.req_n = n;
  801f00:	89 1d 04 60 80 00    	mov    %ebx,0x806004

 	return fsipc(FSREQ_WRITE, NULL);
  801f06:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0b:	b8 04 00 00 00       	mov    $0x4,%eax
  801f10:	e8 cb fe ff ff       	call   801de0 <fsipc>
	//panic("devfile_write not implemented");
}
  801f15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	56                   	push   %esi
  801f1e:	53                   	push   %ebx
  801f1f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	8b 40 0c             	mov    0xc(%eax),%eax
  801f28:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801f2d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801f33:	ba 00 00 00 00       	mov    $0x0,%edx
  801f38:	b8 03 00 00 00       	mov    $0x3,%eax
  801f3d:	e8 9e fe ff ff       	call   801de0 <fsipc>
  801f42:	89 c3                	mov    %eax,%ebx
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 4b                	js     801f93 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801f48:	39 c6                	cmp    %eax,%esi
  801f4a:	73 16                	jae    801f62 <devfile_read+0x48>
  801f4c:	68 b8 33 80 00       	push   $0x8033b8
  801f51:	68 bf 33 80 00       	push   $0x8033bf
  801f56:	6a 7c                	push   $0x7c
  801f58:	68 d4 33 80 00       	push   $0x8033d4
  801f5d:	e8 34 e8 ff ff       	call   800796 <_panic>
	assert(r <= PGSIZE);
  801f62:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f67:	7e 16                	jle    801f7f <devfile_read+0x65>
  801f69:	68 df 33 80 00       	push   $0x8033df
  801f6e:	68 bf 33 80 00       	push   $0x8033bf
  801f73:	6a 7d                	push   $0x7d
  801f75:	68 d4 33 80 00       	push   $0x8033d4
  801f7a:	e8 17 e8 ff ff       	call   800796 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f7f:	83 ec 04             	sub    $0x4,%esp
  801f82:	50                   	push   %eax
  801f83:	68 00 60 80 00       	push   $0x806000
  801f88:	ff 75 0c             	pushl  0xc(%ebp)
  801f8b:	e8 f6 ef ff ff       	call   800f86 <memmove>
	return r;
  801f90:	83 c4 10             	add    $0x10,%esp
}
  801f93:	89 d8                	mov    %ebx,%eax
  801f95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    

00801f9c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 20             	sub    $0x20,%esp
  801fa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801fa6:	53                   	push   %ebx
  801fa7:	e8 0f ee ff ff       	call   800dbb <strlen>
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801fb4:	7f 67                	jg     80201d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801fb6:	83 ec 0c             	sub    $0xc,%esp
  801fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbc:	50                   	push   %eax
  801fbd:	e8 96 f8 ff ff       	call   801858 <fd_alloc>
  801fc2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fc5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 57                	js     802022 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801fcb:	83 ec 08             	sub    $0x8,%esp
  801fce:	53                   	push   %ebx
  801fcf:	68 00 60 80 00       	push   $0x806000
  801fd4:	e8 1b ee ff ff       	call   800df4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fdc:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801fe1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fe4:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe9:	e8 f2 fd ff ff       	call   801de0 <fsipc>
  801fee:	89 c3                	mov    %eax,%ebx
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	79 14                	jns    80200b <open+0x6f>
		fd_close(fd, 0);
  801ff7:	83 ec 08             	sub    $0x8,%esp
  801ffa:	6a 00                	push   $0x0
  801ffc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fff:	e8 4c f9 ff ff       	call   801950 <fd_close>
		return r;
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	89 da                	mov    %ebx,%edx
  802009:	eb 17                	jmp    802022 <open+0x86>
	}

	return fd2num(fd);
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	ff 75 f4             	pushl  -0xc(%ebp)
  802011:	e8 1b f8 ff ff       	call   801831 <fd2num>
  802016:	89 c2                	mov    %eax,%edx
  802018:	83 c4 10             	add    $0x10,%esp
  80201b:	eb 05                	jmp    802022 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80201d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802022:	89 d0                	mov    %edx,%eax
  802024:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802027:	c9                   	leave  
  802028:	c3                   	ret    

00802029 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80202f:	ba 00 00 00 00       	mov    $0x0,%edx
  802034:	b8 08 00 00 00       	mov    $0x8,%eax
  802039:	e8 a2 fd ff ff       	call   801de0 <fsipc>
}
  80203e:	c9                   	leave  
  80203f:	c3                   	ret    

00802040 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802046:	68 eb 33 80 00       	push   $0x8033eb
  80204b:	ff 75 0c             	pushl  0xc(%ebp)
  80204e:	e8 a1 ed ff ff       	call   800df4 <strcpy>
	return 0;
}
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
  802058:	c9                   	leave  
  802059:	c3                   	ret    

0080205a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	53                   	push   %ebx
  80205e:	83 ec 10             	sub    $0x10,%esp
  802061:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802064:	53                   	push   %ebx
  802065:	e8 af 09 00 00       	call   802a19 <pageref>
  80206a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80206d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802072:	83 f8 01             	cmp    $0x1,%eax
  802075:	75 10                	jne    802087 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802077:	83 ec 0c             	sub    $0xc,%esp
  80207a:	ff 73 0c             	pushl  0xc(%ebx)
  80207d:	e8 c0 02 00 00       	call   802342 <nsipc_close>
  802082:	89 c2                	mov    %eax,%edx
  802084:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802087:	89 d0                	mov    %edx,%eax
  802089:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802094:	6a 00                	push   $0x0
  802096:	ff 75 10             	pushl  0x10(%ebp)
  802099:	ff 75 0c             	pushl  0xc(%ebp)
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	ff 70 0c             	pushl  0xc(%eax)
  8020a2:	e8 78 03 00 00       	call   80241f <nsipc_send>
}
  8020a7:	c9                   	leave  
  8020a8:	c3                   	ret    

008020a9 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8020af:	6a 00                	push   $0x0
  8020b1:	ff 75 10             	pushl  0x10(%ebp)
  8020b4:	ff 75 0c             	pushl  0xc(%ebp)
  8020b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ba:	ff 70 0c             	pushl  0xc(%eax)
  8020bd:	e8 f1 02 00 00       	call   8023b3 <nsipc_recv>
}
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8020ca:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8020cd:	52                   	push   %edx
  8020ce:	50                   	push   %eax
  8020cf:	e8 d3 f7 ff ff       	call   8018a7 <fd_lookup>
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 17                	js     8020f2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8020db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020de:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  8020e4:	39 08                	cmp    %ecx,(%eax)
  8020e6:	75 05                	jne    8020ed <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8020e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8020eb:	eb 05                	jmp    8020f2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8020ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8020f2:	c9                   	leave  
  8020f3:	c3                   	ret    

008020f4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	56                   	push   %esi
  8020f8:	53                   	push   %ebx
  8020f9:	83 ec 1c             	sub    $0x1c,%esp
  8020fc:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802101:	50                   	push   %eax
  802102:	e8 51 f7 ff ff       	call   801858 <fd_alloc>
  802107:	89 c3                	mov    %eax,%ebx
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	85 c0                	test   %eax,%eax
  80210e:	78 1b                	js     80212b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802110:	83 ec 04             	sub    $0x4,%esp
  802113:	68 07 04 00 00       	push   $0x407
  802118:	ff 75 f4             	pushl  -0xc(%ebp)
  80211b:	6a 00                	push   $0x0
  80211d:	e8 d5 f0 ff ff       	call   8011f7 <sys_page_alloc>
  802122:	89 c3                	mov    %eax,%ebx
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	85 c0                	test   %eax,%eax
  802129:	79 10                	jns    80213b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80212b:	83 ec 0c             	sub    $0xc,%esp
  80212e:	56                   	push   %esi
  80212f:	e8 0e 02 00 00       	call   802342 <nsipc_close>
		return r;
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	89 d8                	mov    %ebx,%eax
  802139:	eb 24                	jmp    80215f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80213b:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802141:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802144:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802146:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802149:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802150:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802153:	83 ec 0c             	sub    $0xc,%esp
  802156:	50                   	push   %eax
  802157:	e8 d5 f6 ff ff       	call   801831 <fd2num>
  80215c:	83 c4 10             	add    $0x10,%esp
}
  80215f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802162:	5b                   	pop    %ebx
  802163:	5e                   	pop    %esi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    

00802166 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80216c:	8b 45 08             	mov    0x8(%ebp),%eax
  80216f:	e8 50 ff ff ff       	call   8020c4 <fd2sockid>
		return r;
  802174:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802176:	85 c0                	test   %eax,%eax
  802178:	78 1f                	js     802199 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80217a:	83 ec 04             	sub    $0x4,%esp
  80217d:	ff 75 10             	pushl  0x10(%ebp)
  802180:	ff 75 0c             	pushl  0xc(%ebp)
  802183:	50                   	push   %eax
  802184:	e8 12 01 00 00       	call   80229b <nsipc_accept>
  802189:	83 c4 10             	add    $0x10,%esp
		return r;
  80218c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80218e:	85 c0                	test   %eax,%eax
  802190:	78 07                	js     802199 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802192:	e8 5d ff ff ff       	call   8020f4 <alloc_sockfd>
  802197:	89 c1                	mov    %eax,%ecx
}
  802199:	89 c8                	mov    %ecx,%eax
  80219b:	c9                   	leave  
  80219c:	c3                   	ret    

0080219d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80219d:	55                   	push   %ebp
  80219e:	89 e5                	mov    %esp,%ebp
  8021a0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a6:	e8 19 ff ff ff       	call   8020c4 <fd2sockid>
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	78 12                	js     8021c1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8021af:	83 ec 04             	sub    $0x4,%esp
  8021b2:	ff 75 10             	pushl  0x10(%ebp)
  8021b5:	ff 75 0c             	pushl  0xc(%ebp)
  8021b8:	50                   	push   %eax
  8021b9:	e8 2d 01 00 00       	call   8022eb <nsipc_bind>
  8021be:	83 c4 10             	add    $0x10,%esp
}
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    

008021c3 <shutdown>:

int
shutdown(int s, int how)
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cc:	e8 f3 fe ff ff       	call   8020c4 <fd2sockid>
  8021d1:	85 c0                	test   %eax,%eax
  8021d3:	78 0f                	js     8021e4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8021d5:	83 ec 08             	sub    $0x8,%esp
  8021d8:	ff 75 0c             	pushl  0xc(%ebp)
  8021db:	50                   	push   %eax
  8021dc:	e8 3f 01 00 00       	call   802320 <nsipc_shutdown>
  8021e1:	83 c4 10             	add    $0x10,%esp
}
  8021e4:	c9                   	leave  
  8021e5:	c3                   	ret    

008021e6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ef:	e8 d0 fe ff ff       	call   8020c4 <fd2sockid>
  8021f4:	85 c0                	test   %eax,%eax
  8021f6:	78 12                	js     80220a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8021f8:	83 ec 04             	sub    $0x4,%esp
  8021fb:	ff 75 10             	pushl  0x10(%ebp)
  8021fe:	ff 75 0c             	pushl  0xc(%ebp)
  802201:	50                   	push   %eax
  802202:	e8 55 01 00 00       	call   80235c <nsipc_connect>
  802207:	83 c4 10             	add    $0x10,%esp
}
  80220a:	c9                   	leave  
  80220b:	c3                   	ret    

0080220c <listen>:

int
listen(int s, int backlog)
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802212:	8b 45 08             	mov    0x8(%ebp),%eax
  802215:	e8 aa fe ff ff       	call   8020c4 <fd2sockid>
  80221a:	85 c0                	test   %eax,%eax
  80221c:	78 0f                	js     80222d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80221e:	83 ec 08             	sub    $0x8,%esp
  802221:	ff 75 0c             	pushl  0xc(%ebp)
  802224:	50                   	push   %eax
  802225:	e8 67 01 00 00       	call   802391 <nsipc_listen>
  80222a:	83 c4 10             	add    $0x10,%esp
}
  80222d:	c9                   	leave  
  80222e:	c3                   	ret    

0080222f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802235:	ff 75 10             	pushl  0x10(%ebp)
  802238:	ff 75 0c             	pushl  0xc(%ebp)
  80223b:	ff 75 08             	pushl  0x8(%ebp)
  80223e:	e8 3a 02 00 00       	call   80247d <nsipc_socket>
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	85 c0                	test   %eax,%eax
  802248:	78 05                	js     80224f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80224a:	e8 a5 fe ff ff       	call   8020f4 <alloc_sockfd>
}
  80224f:	c9                   	leave  
  802250:	c3                   	ret    

00802251 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	53                   	push   %ebx
  802255:	83 ec 04             	sub    $0x4,%esp
  802258:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80225a:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  802261:	75 12                	jne    802275 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802263:	83 ec 0c             	sub    $0xc,%esp
  802266:	6a 02                	push   $0x2
  802268:	e8 8b f5 ff ff       	call   8017f8 <ipc_find_env>
  80226d:	a3 1c 50 80 00       	mov    %eax,0x80501c
  802272:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802275:	6a 07                	push   $0x7
  802277:	68 00 70 80 00       	push   $0x807000
  80227c:	53                   	push   %ebx
  80227d:	ff 35 1c 50 80 00    	pushl  0x80501c
  802283:	e8 1c f5 ff ff       	call   8017a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802288:	83 c4 0c             	add    $0xc,%esp
  80228b:	6a 00                	push   $0x0
  80228d:	6a 00                	push   $0x0
  80228f:	6a 00                	push   $0x0
  802291:	e8 a1 f4 ff ff       	call   801737 <ipc_recv>
}
  802296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802299:	c9                   	leave  
  80229a:	c3                   	ret    

0080229b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	56                   	push   %esi
  80229f:	53                   	push   %ebx
  8022a0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8022a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8022ab:	8b 06                	mov    (%esi),%eax
  8022ad:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8022b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b7:	e8 95 ff ff ff       	call   802251 <nsipc>
  8022bc:	89 c3                	mov    %eax,%ebx
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	78 20                	js     8022e2 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8022c2:	83 ec 04             	sub    $0x4,%esp
  8022c5:	ff 35 10 70 80 00    	pushl  0x807010
  8022cb:	68 00 70 80 00       	push   $0x807000
  8022d0:	ff 75 0c             	pushl  0xc(%ebp)
  8022d3:	e8 ae ec ff ff       	call   800f86 <memmove>
		*addrlen = ret->ret_addrlen;
  8022d8:	a1 10 70 80 00       	mov    0x807010,%eax
  8022dd:	89 06                	mov    %eax,(%esi)
  8022df:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8022e2:	89 d8                	mov    %ebx,%eax
  8022e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    

008022eb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	53                   	push   %ebx
  8022ef:	83 ec 08             	sub    $0x8,%esp
  8022f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8022f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8022fd:	53                   	push   %ebx
  8022fe:	ff 75 0c             	pushl  0xc(%ebp)
  802301:	68 04 70 80 00       	push   $0x807004
  802306:	e8 7b ec ff ff       	call   800f86 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80230b:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802311:	b8 02 00 00 00       	mov    $0x2,%eax
  802316:	e8 36 ff ff ff       	call   802251 <nsipc>
}
  80231b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    

00802320 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802326:	8b 45 08             	mov    0x8(%ebp),%eax
  802329:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80232e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802331:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802336:	b8 03 00 00 00       	mov    $0x3,%eax
  80233b:	e8 11 ff ff ff       	call   802251 <nsipc>
}
  802340:	c9                   	leave  
  802341:	c3                   	ret    

00802342 <nsipc_close>:

int
nsipc_close(int s)
{
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802348:	8b 45 08             	mov    0x8(%ebp),%eax
  80234b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802350:	b8 04 00 00 00       	mov    $0x4,%eax
  802355:	e8 f7 fe ff ff       	call   802251 <nsipc>
}
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	53                   	push   %ebx
  802360:	83 ec 08             	sub    $0x8,%esp
  802363:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802366:	8b 45 08             	mov    0x8(%ebp),%eax
  802369:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80236e:	53                   	push   %ebx
  80236f:	ff 75 0c             	pushl  0xc(%ebp)
  802372:	68 04 70 80 00       	push   $0x807004
  802377:	e8 0a ec ff ff       	call   800f86 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80237c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802382:	b8 05 00 00 00       	mov    $0x5,%eax
  802387:	e8 c5 fe ff ff       	call   802251 <nsipc>
}
  80238c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80238f:	c9                   	leave  
  802390:	c3                   	ret    

00802391 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802397:	8b 45 08             	mov    0x8(%ebp),%eax
  80239a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80239f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a2:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8023a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8023ac:	e8 a0 fe ff ff       	call   802251 <nsipc>
}
  8023b1:	c9                   	leave  
  8023b2:	c3                   	ret    

008023b3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8023b3:	55                   	push   %ebp
  8023b4:	89 e5                	mov    %esp,%ebp
  8023b6:	56                   	push   %esi
  8023b7:	53                   	push   %ebx
  8023b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023be:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8023c3:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8023c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8023cc:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8023d1:	b8 07 00 00 00       	mov    $0x7,%eax
  8023d6:	e8 76 fe ff ff       	call   802251 <nsipc>
  8023db:	89 c3                	mov    %eax,%ebx
  8023dd:	85 c0                	test   %eax,%eax
  8023df:	78 35                	js     802416 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8023e1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8023e6:	7f 04                	jg     8023ec <nsipc_recv+0x39>
  8023e8:	39 c6                	cmp    %eax,%esi
  8023ea:	7d 16                	jge    802402 <nsipc_recv+0x4f>
  8023ec:	68 f7 33 80 00       	push   $0x8033f7
  8023f1:	68 bf 33 80 00       	push   $0x8033bf
  8023f6:	6a 62                	push   $0x62
  8023f8:	68 0c 34 80 00       	push   $0x80340c
  8023fd:	e8 94 e3 ff ff       	call   800796 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802402:	83 ec 04             	sub    $0x4,%esp
  802405:	50                   	push   %eax
  802406:	68 00 70 80 00       	push   $0x807000
  80240b:	ff 75 0c             	pushl  0xc(%ebp)
  80240e:	e8 73 eb ff ff       	call   800f86 <memmove>
  802413:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802416:	89 d8                	mov    %ebx,%eax
  802418:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80241b:	5b                   	pop    %ebx
  80241c:	5e                   	pop    %esi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    

0080241f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80241f:	55                   	push   %ebp
  802420:	89 e5                	mov    %esp,%ebp
  802422:	53                   	push   %ebx
  802423:	83 ec 04             	sub    $0x4,%esp
  802426:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802429:	8b 45 08             	mov    0x8(%ebp),%eax
  80242c:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802431:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802437:	7e 16                	jle    80244f <nsipc_send+0x30>
  802439:	68 18 34 80 00       	push   $0x803418
  80243e:	68 bf 33 80 00       	push   $0x8033bf
  802443:	6a 6d                	push   $0x6d
  802445:	68 0c 34 80 00       	push   $0x80340c
  80244a:	e8 47 e3 ff ff       	call   800796 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80244f:	83 ec 04             	sub    $0x4,%esp
  802452:	53                   	push   %ebx
  802453:	ff 75 0c             	pushl  0xc(%ebp)
  802456:	68 0c 70 80 00       	push   $0x80700c
  80245b:	e8 26 eb ff ff       	call   800f86 <memmove>
	nsipcbuf.send.req_size = size;
  802460:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802466:	8b 45 14             	mov    0x14(%ebp),%eax
  802469:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80246e:	b8 08 00 00 00       	mov    $0x8,%eax
  802473:	e8 d9 fd ff ff       	call   802251 <nsipc>
}
  802478:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80247b:	c9                   	leave  
  80247c:	c3                   	ret    

0080247d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80247d:	55                   	push   %ebp
  80247e:	89 e5                	mov    %esp,%ebp
  802480:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802483:	8b 45 08             	mov    0x8(%ebp),%eax
  802486:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80248b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248e:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802493:	8b 45 10             	mov    0x10(%ebp),%eax
  802496:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80249b:	b8 09 00 00 00       	mov    $0x9,%eax
  8024a0:	e8 ac fd ff ff       	call   802251 <nsipc>
}
  8024a5:	c9                   	leave  
  8024a6:	c3                   	ret    

008024a7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8024a7:	55                   	push   %ebp
  8024a8:	89 e5                	mov    %esp,%ebp
  8024aa:	56                   	push   %esi
  8024ab:	53                   	push   %ebx
  8024ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8024af:	83 ec 0c             	sub    $0xc,%esp
  8024b2:	ff 75 08             	pushl  0x8(%ebp)
  8024b5:	e8 87 f3 ff ff       	call   801841 <fd2data>
  8024ba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8024bc:	83 c4 08             	add    $0x8,%esp
  8024bf:	68 24 34 80 00       	push   $0x803424
  8024c4:	53                   	push   %ebx
  8024c5:	e8 2a e9 ff ff       	call   800df4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8024ca:	8b 46 04             	mov    0x4(%esi),%eax
  8024cd:	2b 06                	sub    (%esi),%eax
  8024cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8024d5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8024dc:	00 00 00 
	stat->st_dev = &devpipe;
  8024df:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8024e6:	40 80 00 
	return 0;
}
  8024e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8024ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024f1:	5b                   	pop    %ebx
  8024f2:	5e                   	pop    %esi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    

008024f5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024f5:	55                   	push   %ebp
  8024f6:	89 e5                	mov    %esp,%ebp
  8024f8:	53                   	push   %ebx
  8024f9:	83 ec 0c             	sub    $0xc,%esp
  8024fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024ff:	53                   	push   %ebx
  802500:	6a 00                	push   $0x0
  802502:	e8 75 ed ff ff       	call   80127c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802507:	89 1c 24             	mov    %ebx,(%esp)
  80250a:	e8 32 f3 ff ff       	call   801841 <fd2data>
  80250f:	83 c4 08             	add    $0x8,%esp
  802512:	50                   	push   %eax
  802513:	6a 00                	push   $0x0
  802515:	e8 62 ed ff ff       	call   80127c <sys_page_unmap>
}
  80251a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80251d:	c9                   	leave  
  80251e:	c3                   	ret    

0080251f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80251f:	55                   	push   %ebp
  802520:	89 e5                	mov    %esp,%ebp
  802522:	57                   	push   %edi
  802523:	56                   	push   %esi
  802524:	53                   	push   %ebx
  802525:	83 ec 1c             	sub    $0x1c,%esp
  802528:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80252b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80252d:	a1 20 50 80 00       	mov    0x805020,%eax
  802532:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802535:	83 ec 0c             	sub    $0xc,%esp
  802538:	ff 75 e0             	pushl  -0x20(%ebp)
  80253b:	e8 d9 04 00 00       	call   802a19 <pageref>
  802540:	89 c3                	mov    %eax,%ebx
  802542:	89 3c 24             	mov    %edi,(%esp)
  802545:	e8 cf 04 00 00       	call   802a19 <pageref>
  80254a:	83 c4 10             	add    $0x10,%esp
  80254d:	39 c3                	cmp    %eax,%ebx
  80254f:	0f 94 c1             	sete   %cl
  802552:	0f b6 c9             	movzbl %cl,%ecx
  802555:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802558:	8b 15 20 50 80 00    	mov    0x805020,%edx
  80255e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802561:	39 ce                	cmp    %ecx,%esi
  802563:	74 1b                	je     802580 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802565:	39 c3                	cmp    %eax,%ebx
  802567:	75 c4                	jne    80252d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802569:	8b 42 58             	mov    0x58(%edx),%eax
  80256c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80256f:	50                   	push   %eax
  802570:	56                   	push   %esi
  802571:	68 2b 34 80 00       	push   $0x80342b
  802576:	e8 f4 e2 ff ff       	call   80086f <cprintf>
  80257b:	83 c4 10             	add    $0x10,%esp
  80257e:	eb ad                	jmp    80252d <_pipeisclosed+0xe>
	}
}
  802580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802583:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802586:	5b                   	pop    %ebx
  802587:	5e                   	pop    %esi
  802588:	5f                   	pop    %edi
  802589:	5d                   	pop    %ebp
  80258a:	c3                   	ret    

0080258b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80258b:	55                   	push   %ebp
  80258c:	89 e5                	mov    %esp,%ebp
  80258e:	57                   	push   %edi
  80258f:	56                   	push   %esi
  802590:	53                   	push   %ebx
  802591:	83 ec 28             	sub    $0x28,%esp
  802594:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802597:	56                   	push   %esi
  802598:	e8 a4 f2 ff ff       	call   801841 <fd2data>
  80259d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80259f:	83 c4 10             	add    $0x10,%esp
  8025a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8025a7:	eb 4b                	jmp    8025f4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8025a9:	89 da                	mov    %ebx,%edx
  8025ab:	89 f0                	mov    %esi,%eax
  8025ad:	e8 6d ff ff ff       	call   80251f <_pipeisclosed>
  8025b2:	85 c0                	test   %eax,%eax
  8025b4:	75 48                	jne    8025fe <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8025b6:	e8 1d ec ff ff       	call   8011d8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025bb:	8b 43 04             	mov    0x4(%ebx),%eax
  8025be:	8b 0b                	mov    (%ebx),%ecx
  8025c0:	8d 51 20             	lea    0x20(%ecx),%edx
  8025c3:	39 d0                	cmp    %edx,%eax
  8025c5:	73 e2                	jae    8025a9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8025c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025ca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8025ce:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8025d1:	89 c2                	mov    %eax,%edx
  8025d3:	c1 fa 1f             	sar    $0x1f,%edx
  8025d6:	89 d1                	mov    %edx,%ecx
  8025d8:	c1 e9 1b             	shr    $0x1b,%ecx
  8025db:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8025de:	83 e2 1f             	and    $0x1f,%edx
  8025e1:	29 ca                	sub    %ecx,%edx
  8025e3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8025e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8025eb:	83 c0 01             	add    $0x1,%eax
  8025ee:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025f1:	83 c7 01             	add    $0x1,%edi
  8025f4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025f7:	75 c2                	jne    8025bb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8025f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8025fc:	eb 05                	jmp    802603 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025fe:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802606:	5b                   	pop    %ebx
  802607:	5e                   	pop    %esi
  802608:	5f                   	pop    %edi
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    

0080260b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80260b:	55                   	push   %ebp
  80260c:	89 e5                	mov    %esp,%ebp
  80260e:	57                   	push   %edi
  80260f:	56                   	push   %esi
  802610:	53                   	push   %ebx
  802611:	83 ec 18             	sub    $0x18,%esp
  802614:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802617:	57                   	push   %edi
  802618:	e8 24 f2 ff ff       	call   801841 <fd2data>
  80261d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80261f:	83 c4 10             	add    $0x10,%esp
  802622:	bb 00 00 00 00       	mov    $0x0,%ebx
  802627:	eb 3d                	jmp    802666 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802629:	85 db                	test   %ebx,%ebx
  80262b:	74 04                	je     802631 <devpipe_read+0x26>
				return i;
  80262d:	89 d8                	mov    %ebx,%eax
  80262f:	eb 44                	jmp    802675 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802631:	89 f2                	mov    %esi,%edx
  802633:	89 f8                	mov    %edi,%eax
  802635:	e8 e5 fe ff ff       	call   80251f <_pipeisclosed>
  80263a:	85 c0                	test   %eax,%eax
  80263c:	75 32                	jne    802670 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80263e:	e8 95 eb ff ff       	call   8011d8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802643:	8b 06                	mov    (%esi),%eax
  802645:	3b 46 04             	cmp    0x4(%esi),%eax
  802648:	74 df                	je     802629 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80264a:	99                   	cltd   
  80264b:	c1 ea 1b             	shr    $0x1b,%edx
  80264e:	01 d0                	add    %edx,%eax
  802650:	83 e0 1f             	and    $0x1f,%eax
  802653:	29 d0                	sub    %edx,%eax
  802655:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80265a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80265d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802660:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802663:	83 c3 01             	add    $0x1,%ebx
  802666:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802669:	75 d8                	jne    802643 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80266b:	8b 45 10             	mov    0x10(%ebp),%eax
  80266e:	eb 05                	jmp    802675 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802670:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802675:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    

0080267d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80267d:	55                   	push   %ebp
  80267e:	89 e5                	mov    %esp,%ebp
  802680:	56                   	push   %esi
  802681:	53                   	push   %ebx
  802682:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802685:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802688:	50                   	push   %eax
  802689:	e8 ca f1 ff ff       	call   801858 <fd_alloc>
  80268e:	83 c4 10             	add    $0x10,%esp
  802691:	89 c2                	mov    %eax,%edx
  802693:	85 c0                	test   %eax,%eax
  802695:	0f 88 2c 01 00 00    	js     8027c7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80269b:	83 ec 04             	sub    $0x4,%esp
  80269e:	68 07 04 00 00       	push   $0x407
  8026a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8026a6:	6a 00                	push   $0x0
  8026a8:	e8 4a eb ff ff       	call   8011f7 <sys_page_alloc>
  8026ad:	83 c4 10             	add    $0x10,%esp
  8026b0:	89 c2                	mov    %eax,%edx
  8026b2:	85 c0                	test   %eax,%eax
  8026b4:	0f 88 0d 01 00 00    	js     8027c7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8026ba:	83 ec 0c             	sub    $0xc,%esp
  8026bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026c0:	50                   	push   %eax
  8026c1:	e8 92 f1 ff ff       	call   801858 <fd_alloc>
  8026c6:	89 c3                	mov    %eax,%ebx
  8026c8:	83 c4 10             	add    $0x10,%esp
  8026cb:	85 c0                	test   %eax,%eax
  8026cd:	0f 88 e2 00 00 00    	js     8027b5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026d3:	83 ec 04             	sub    $0x4,%esp
  8026d6:	68 07 04 00 00       	push   $0x407
  8026db:	ff 75 f0             	pushl  -0x10(%ebp)
  8026de:	6a 00                	push   $0x0
  8026e0:	e8 12 eb ff ff       	call   8011f7 <sys_page_alloc>
  8026e5:	89 c3                	mov    %eax,%ebx
  8026e7:	83 c4 10             	add    $0x10,%esp
  8026ea:	85 c0                	test   %eax,%eax
  8026ec:	0f 88 c3 00 00 00    	js     8027b5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8026f2:	83 ec 0c             	sub    $0xc,%esp
  8026f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8026f8:	e8 44 f1 ff ff       	call   801841 <fd2data>
  8026fd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026ff:	83 c4 0c             	add    $0xc,%esp
  802702:	68 07 04 00 00       	push   $0x407
  802707:	50                   	push   %eax
  802708:	6a 00                	push   $0x0
  80270a:	e8 e8 ea ff ff       	call   8011f7 <sys_page_alloc>
  80270f:	89 c3                	mov    %eax,%ebx
  802711:	83 c4 10             	add    $0x10,%esp
  802714:	85 c0                	test   %eax,%eax
  802716:	0f 88 89 00 00 00    	js     8027a5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80271c:	83 ec 0c             	sub    $0xc,%esp
  80271f:	ff 75 f0             	pushl  -0x10(%ebp)
  802722:	e8 1a f1 ff ff       	call   801841 <fd2data>
  802727:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80272e:	50                   	push   %eax
  80272f:	6a 00                	push   $0x0
  802731:	56                   	push   %esi
  802732:	6a 00                	push   $0x0
  802734:	e8 01 eb ff ff       	call   80123a <sys_page_map>
  802739:	89 c3                	mov    %eax,%ebx
  80273b:	83 c4 20             	add    $0x20,%esp
  80273e:	85 c0                	test   %eax,%eax
  802740:	78 55                	js     802797 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802742:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80274b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80274d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802750:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802757:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80275d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802760:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802762:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802765:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80276c:	83 ec 0c             	sub    $0xc,%esp
  80276f:	ff 75 f4             	pushl  -0xc(%ebp)
  802772:	e8 ba f0 ff ff       	call   801831 <fd2num>
  802777:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80277a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80277c:	83 c4 04             	add    $0x4,%esp
  80277f:	ff 75 f0             	pushl  -0x10(%ebp)
  802782:	e8 aa f0 ff ff       	call   801831 <fd2num>
  802787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80278a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80278d:	83 c4 10             	add    $0x10,%esp
  802790:	ba 00 00 00 00       	mov    $0x0,%edx
  802795:	eb 30                	jmp    8027c7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802797:	83 ec 08             	sub    $0x8,%esp
  80279a:	56                   	push   %esi
  80279b:	6a 00                	push   $0x0
  80279d:	e8 da ea ff ff       	call   80127c <sys_page_unmap>
  8027a2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8027a5:	83 ec 08             	sub    $0x8,%esp
  8027a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8027ab:	6a 00                	push   $0x0
  8027ad:	e8 ca ea ff ff       	call   80127c <sys_page_unmap>
  8027b2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8027b5:	83 ec 08             	sub    $0x8,%esp
  8027b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8027bb:	6a 00                	push   $0x0
  8027bd:	e8 ba ea ff ff       	call   80127c <sys_page_unmap>
  8027c2:	83 c4 10             	add    $0x10,%esp
  8027c5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8027c7:	89 d0                	mov    %edx,%eax
  8027c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027cc:	5b                   	pop    %ebx
  8027cd:	5e                   	pop    %esi
  8027ce:	5d                   	pop    %ebp
  8027cf:	c3                   	ret    

008027d0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8027d0:	55                   	push   %ebp
  8027d1:	89 e5                	mov    %esp,%ebp
  8027d3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027d9:	50                   	push   %eax
  8027da:	ff 75 08             	pushl  0x8(%ebp)
  8027dd:	e8 c5 f0 ff ff       	call   8018a7 <fd_lookup>
  8027e2:	83 c4 10             	add    $0x10,%esp
  8027e5:	85 c0                	test   %eax,%eax
  8027e7:	78 18                	js     802801 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8027e9:	83 ec 0c             	sub    $0xc,%esp
  8027ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8027ef:	e8 4d f0 ff ff       	call   801841 <fd2data>
	return _pipeisclosed(fd, p);
  8027f4:	89 c2                	mov    %eax,%edx
  8027f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027f9:	e8 21 fd ff ff       	call   80251f <_pipeisclosed>
  8027fe:	83 c4 10             	add    $0x10,%esp
}
  802801:	c9                   	leave  
  802802:	c3                   	ret    

00802803 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802803:	55                   	push   %ebp
  802804:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802806:	b8 00 00 00 00       	mov    $0x0,%eax
  80280b:	5d                   	pop    %ebp
  80280c:	c3                   	ret    

0080280d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80280d:	55                   	push   %ebp
  80280e:	89 e5                	mov    %esp,%ebp
  802810:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802813:	68 43 34 80 00       	push   $0x803443
  802818:	ff 75 0c             	pushl  0xc(%ebp)
  80281b:	e8 d4 e5 ff ff       	call   800df4 <strcpy>
	return 0;
}
  802820:	b8 00 00 00 00       	mov    $0x0,%eax
  802825:	c9                   	leave  
  802826:	c3                   	ret    

00802827 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802827:	55                   	push   %ebp
  802828:	89 e5                	mov    %esp,%ebp
  80282a:	57                   	push   %edi
  80282b:	56                   	push   %esi
  80282c:	53                   	push   %ebx
  80282d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802833:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802838:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80283e:	eb 2d                	jmp    80286d <devcons_write+0x46>
		m = n - tot;
  802840:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802843:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802845:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802848:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80284d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802850:	83 ec 04             	sub    $0x4,%esp
  802853:	53                   	push   %ebx
  802854:	03 45 0c             	add    0xc(%ebp),%eax
  802857:	50                   	push   %eax
  802858:	57                   	push   %edi
  802859:	e8 28 e7 ff ff       	call   800f86 <memmove>
		sys_cputs(buf, m);
  80285e:	83 c4 08             	add    $0x8,%esp
  802861:	53                   	push   %ebx
  802862:	57                   	push   %edi
  802863:	e8 d3 e8 ff ff       	call   80113b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802868:	01 de                	add    %ebx,%esi
  80286a:	83 c4 10             	add    $0x10,%esp
  80286d:	89 f0                	mov    %esi,%eax
  80286f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802872:	72 cc                	jb     802840 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802874:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802877:	5b                   	pop    %ebx
  802878:	5e                   	pop    %esi
  802879:	5f                   	pop    %edi
  80287a:	5d                   	pop    %ebp
  80287b:	c3                   	ret    

0080287c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80287c:	55                   	push   %ebp
  80287d:	89 e5                	mov    %esp,%ebp
  80287f:	83 ec 08             	sub    $0x8,%esp
  802882:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802887:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80288b:	74 2a                	je     8028b7 <devcons_read+0x3b>
  80288d:	eb 05                	jmp    802894 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80288f:	e8 44 e9 ff ff       	call   8011d8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802894:	e8 c0 e8 ff ff       	call   801159 <sys_cgetc>
  802899:	85 c0                	test   %eax,%eax
  80289b:	74 f2                	je     80288f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80289d:	85 c0                	test   %eax,%eax
  80289f:	78 16                	js     8028b7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8028a1:	83 f8 04             	cmp    $0x4,%eax
  8028a4:	74 0c                	je     8028b2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8028a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028a9:	88 02                	mov    %al,(%edx)
	return 1;
  8028ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8028b0:	eb 05                	jmp    8028b7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8028b2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8028b7:	c9                   	leave  
  8028b8:	c3                   	ret    

008028b9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8028b9:	55                   	push   %ebp
  8028ba:	89 e5                	mov    %esp,%ebp
  8028bc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8028bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8028c2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8028c5:	6a 01                	push   $0x1
  8028c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028ca:	50                   	push   %eax
  8028cb:	e8 6b e8 ff ff       	call   80113b <sys_cputs>
}
  8028d0:	83 c4 10             	add    $0x10,%esp
  8028d3:	c9                   	leave  
  8028d4:	c3                   	ret    

008028d5 <getchar>:

int
getchar(void)
{
  8028d5:	55                   	push   %ebp
  8028d6:	89 e5                	mov    %esp,%ebp
  8028d8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8028db:	6a 01                	push   $0x1
  8028dd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028e0:	50                   	push   %eax
  8028e1:	6a 00                	push   $0x0
  8028e3:	e8 25 f2 ff ff       	call   801b0d <read>
	if (r < 0)
  8028e8:	83 c4 10             	add    $0x10,%esp
  8028eb:	85 c0                	test   %eax,%eax
  8028ed:	78 0f                	js     8028fe <getchar+0x29>
		return r;
	if (r < 1)
  8028ef:	85 c0                	test   %eax,%eax
  8028f1:	7e 06                	jle    8028f9 <getchar+0x24>
		return -E_EOF;
	return c;
  8028f3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8028f7:	eb 05                	jmp    8028fe <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8028f9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8028fe:	c9                   	leave  
  8028ff:	c3                   	ret    

00802900 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802900:	55                   	push   %ebp
  802901:	89 e5                	mov    %esp,%ebp
  802903:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802906:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802909:	50                   	push   %eax
  80290a:	ff 75 08             	pushl  0x8(%ebp)
  80290d:	e8 95 ef ff ff       	call   8018a7 <fd_lookup>
  802912:	83 c4 10             	add    $0x10,%esp
  802915:	85 c0                	test   %eax,%eax
  802917:	78 11                	js     80292a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802919:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80291c:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802922:	39 10                	cmp    %edx,(%eax)
  802924:	0f 94 c0             	sete   %al
  802927:	0f b6 c0             	movzbl %al,%eax
}
  80292a:	c9                   	leave  
  80292b:	c3                   	ret    

0080292c <opencons>:

int
opencons(void)
{
  80292c:	55                   	push   %ebp
  80292d:	89 e5                	mov    %esp,%ebp
  80292f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802932:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802935:	50                   	push   %eax
  802936:	e8 1d ef ff ff       	call   801858 <fd_alloc>
  80293b:	83 c4 10             	add    $0x10,%esp
		return r;
  80293e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802940:	85 c0                	test   %eax,%eax
  802942:	78 3e                	js     802982 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802944:	83 ec 04             	sub    $0x4,%esp
  802947:	68 07 04 00 00       	push   $0x407
  80294c:	ff 75 f4             	pushl  -0xc(%ebp)
  80294f:	6a 00                	push   $0x0
  802951:	e8 a1 e8 ff ff       	call   8011f7 <sys_page_alloc>
  802956:	83 c4 10             	add    $0x10,%esp
		return r;
  802959:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80295b:	85 c0                	test   %eax,%eax
  80295d:	78 23                	js     802982 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80295f:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802965:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802968:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80296a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80296d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802974:	83 ec 0c             	sub    $0xc,%esp
  802977:	50                   	push   %eax
  802978:	e8 b4 ee ff ff       	call   801831 <fd2num>
  80297d:	89 c2                	mov    %eax,%edx
  80297f:	83 c4 10             	add    $0x10,%esp
}
  802982:	89 d0                	mov    %edx,%eax
  802984:	c9                   	leave  
  802985:	c3                   	ret    

00802986 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802986:	55                   	push   %ebp
  802987:	89 e5                	mov    %esp,%ebp
  802989:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80298c:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802993:	75 2c                	jne    8029c1 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802995:	83 ec 04             	sub    $0x4,%esp
  802998:	6a 07                	push   $0x7
  80299a:	68 00 f0 bf ee       	push   $0xeebff000
  80299f:	6a 00                	push   $0x0
  8029a1:	e8 51 e8 ff ff       	call   8011f7 <sys_page_alloc>
  8029a6:	83 c4 10             	add    $0x10,%esp
  8029a9:	85 c0                	test   %eax,%eax
  8029ab:	79 14                	jns    8029c1 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  8029ad:	83 ec 04             	sub    $0x4,%esp
  8029b0:	68 4f 34 80 00       	push   $0x80344f
  8029b5:	6a 22                	push   $0x22
  8029b7:	68 66 34 80 00       	push   $0x803466
  8029bc:	e8 d5 dd ff ff       	call   800796 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  8029c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8029c4:	a3 00 80 80 00       	mov    %eax,0x808000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8029c9:	83 ec 08             	sub    $0x8,%esp
  8029cc:	68 f5 29 80 00       	push   $0x8029f5
  8029d1:	6a 00                	push   $0x0
  8029d3:	e8 6a e9 ff ff       	call   801342 <sys_env_set_pgfault_upcall>
  8029d8:	83 c4 10             	add    $0x10,%esp
  8029db:	85 c0                	test   %eax,%eax
  8029dd:	79 14                	jns    8029f3 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8029df:	83 ec 04             	sub    $0x4,%esp
  8029e2:	68 74 34 80 00       	push   $0x803474
  8029e7:	6a 27                	push   $0x27
  8029e9:	68 66 34 80 00       	push   $0x803466
  8029ee:	e8 a3 dd ff ff       	call   800796 <_panic>
    
}
  8029f3:	c9                   	leave  
  8029f4:	c3                   	ret    

008029f5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8029f5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8029f6:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8029fb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8029fd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  802a00:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  802a04:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  802a09:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802a0d:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802a0f:	83 c4 08             	add    $0x8,%esp
	popal
  802a12:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  802a13:	83 c4 04             	add    $0x4,%esp
	popfl
  802a16:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802a17:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802a18:	c3                   	ret    

00802a19 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a19:	55                   	push   %ebp
  802a1a:	89 e5                	mov    %esp,%ebp
  802a1c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a1f:	89 d0                	mov    %edx,%eax
  802a21:	c1 e8 16             	shr    $0x16,%eax
  802a24:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a2b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a30:	f6 c1 01             	test   $0x1,%cl
  802a33:	74 1d                	je     802a52 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a35:	c1 ea 0c             	shr    $0xc,%edx
  802a38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a3f:	f6 c2 01             	test   $0x1,%dl
  802a42:	74 0e                	je     802a52 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a44:	c1 ea 0c             	shr    $0xc,%edx
  802a47:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a4e:	ef 
  802a4f:	0f b7 c0             	movzwl %ax,%eax
}
  802a52:	5d                   	pop    %ebp
  802a53:	c3                   	ret    
  802a54:	66 90                	xchg   %ax,%ax
  802a56:	66 90                	xchg   %ax,%ax
  802a58:	66 90                	xchg   %ax,%ax
  802a5a:	66 90                	xchg   %ax,%ax
  802a5c:	66 90                	xchg   %ax,%ax
  802a5e:	66 90                	xchg   %ax,%ax

00802a60 <__udivdi3>:
  802a60:	55                   	push   %ebp
  802a61:	57                   	push   %edi
  802a62:	56                   	push   %esi
  802a63:	53                   	push   %ebx
  802a64:	83 ec 1c             	sub    $0x1c,%esp
  802a67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a77:	85 f6                	test   %esi,%esi
  802a79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a7d:	89 ca                	mov    %ecx,%edx
  802a7f:	89 f8                	mov    %edi,%eax
  802a81:	75 3d                	jne    802ac0 <__udivdi3+0x60>
  802a83:	39 cf                	cmp    %ecx,%edi
  802a85:	0f 87 c5 00 00 00    	ja     802b50 <__udivdi3+0xf0>
  802a8b:	85 ff                	test   %edi,%edi
  802a8d:	89 fd                	mov    %edi,%ebp
  802a8f:	75 0b                	jne    802a9c <__udivdi3+0x3c>
  802a91:	b8 01 00 00 00       	mov    $0x1,%eax
  802a96:	31 d2                	xor    %edx,%edx
  802a98:	f7 f7                	div    %edi
  802a9a:	89 c5                	mov    %eax,%ebp
  802a9c:	89 c8                	mov    %ecx,%eax
  802a9e:	31 d2                	xor    %edx,%edx
  802aa0:	f7 f5                	div    %ebp
  802aa2:	89 c1                	mov    %eax,%ecx
  802aa4:	89 d8                	mov    %ebx,%eax
  802aa6:	89 cf                	mov    %ecx,%edi
  802aa8:	f7 f5                	div    %ebp
  802aaa:	89 c3                	mov    %eax,%ebx
  802aac:	89 d8                	mov    %ebx,%eax
  802aae:	89 fa                	mov    %edi,%edx
  802ab0:	83 c4 1c             	add    $0x1c,%esp
  802ab3:	5b                   	pop    %ebx
  802ab4:	5e                   	pop    %esi
  802ab5:	5f                   	pop    %edi
  802ab6:	5d                   	pop    %ebp
  802ab7:	c3                   	ret    
  802ab8:	90                   	nop
  802ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ac0:	39 ce                	cmp    %ecx,%esi
  802ac2:	77 74                	ja     802b38 <__udivdi3+0xd8>
  802ac4:	0f bd fe             	bsr    %esi,%edi
  802ac7:	83 f7 1f             	xor    $0x1f,%edi
  802aca:	0f 84 98 00 00 00    	je     802b68 <__udivdi3+0x108>
  802ad0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802ad5:	89 f9                	mov    %edi,%ecx
  802ad7:	89 c5                	mov    %eax,%ebp
  802ad9:	29 fb                	sub    %edi,%ebx
  802adb:	d3 e6                	shl    %cl,%esi
  802add:	89 d9                	mov    %ebx,%ecx
  802adf:	d3 ed                	shr    %cl,%ebp
  802ae1:	89 f9                	mov    %edi,%ecx
  802ae3:	d3 e0                	shl    %cl,%eax
  802ae5:	09 ee                	or     %ebp,%esi
  802ae7:	89 d9                	mov    %ebx,%ecx
  802ae9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802aed:	89 d5                	mov    %edx,%ebp
  802aef:	8b 44 24 08          	mov    0x8(%esp),%eax
  802af3:	d3 ed                	shr    %cl,%ebp
  802af5:	89 f9                	mov    %edi,%ecx
  802af7:	d3 e2                	shl    %cl,%edx
  802af9:	89 d9                	mov    %ebx,%ecx
  802afb:	d3 e8                	shr    %cl,%eax
  802afd:	09 c2                	or     %eax,%edx
  802aff:	89 d0                	mov    %edx,%eax
  802b01:	89 ea                	mov    %ebp,%edx
  802b03:	f7 f6                	div    %esi
  802b05:	89 d5                	mov    %edx,%ebp
  802b07:	89 c3                	mov    %eax,%ebx
  802b09:	f7 64 24 0c          	mull   0xc(%esp)
  802b0d:	39 d5                	cmp    %edx,%ebp
  802b0f:	72 10                	jb     802b21 <__udivdi3+0xc1>
  802b11:	8b 74 24 08          	mov    0x8(%esp),%esi
  802b15:	89 f9                	mov    %edi,%ecx
  802b17:	d3 e6                	shl    %cl,%esi
  802b19:	39 c6                	cmp    %eax,%esi
  802b1b:	73 07                	jae    802b24 <__udivdi3+0xc4>
  802b1d:	39 d5                	cmp    %edx,%ebp
  802b1f:	75 03                	jne    802b24 <__udivdi3+0xc4>
  802b21:	83 eb 01             	sub    $0x1,%ebx
  802b24:	31 ff                	xor    %edi,%edi
  802b26:	89 d8                	mov    %ebx,%eax
  802b28:	89 fa                	mov    %edi,%edx
  802b2a:	83 c4 1c             	add    $0x1c,%esp
  802b2d:	5b                   	pop    %ebx
  802b2e:	5e                   	pop    %esi
  802b2f:	5f                   	pop    %edi
  802b30:	5d                   	pop    %ebp
  802b31:	c3                   	ret    
  802b32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b38:	31 ff                	xor    %edi,%edi
  802b3a:	31 db                	xor    %ebx,%ebx
  802b3c:	89 d8                	mov    %ebx,%eax
  802b3e:	89 fa                	mov    %edi,%edx
  802b40:	83 c4 1c             	add    $0x1c,%esp
  802b43:	5b                   	pop    %ebx
  802b44:	5e                   	pop    %esi
  802b45:	5f                   	pop    %edi
  802b46:	5d                   	pop    %ebp
  802b47:	c3                   	ret    
  802b48:	90                   	nop
  802b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b50:	89 d8                	mov    %ebx,%eax
  802b52:	f7 f7                	div    %edi
  802b54:	31 ff                	xor    %edi,%edi
  802b56:	89 c3                	mov    %eax,%ebx
  802b58:	89 d8                	mov    %ebx,%eax
  802b5a:	89 fa                	mov    %edi,%edx
  802b5c:	83 c4 1c             	add    $0x1c,%esp
  802b5f:	5b                   	pop    %ebx
  802b60:	5e                   	pop    %esi
  802b61:	5f                   	pop    %edi
  802b62:	5d                   	pop    %ebp
  802b63:	c3                   	ret    
  802b64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b68:	39 ce                	cmp    %ecx,%esi
  802b6a:	72 0c                	jb     802b78 <__udivdi3+0x118>
  802b6c:	31 db                	xor    %ebx,%ebx
  802b6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b72:	0f 87 34 ff ff ff    	ja     802aac <__udivdi3+0x4c>
  802b78:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b7d:	e9 2a ff ff ff       	jmp    802aac <__udivdi3+0x4c>
  802b82:	66 90                	xchg   %ax,%ax
  802b84:	66 90                	xchg   %ax,%ax
  802b86:	66 90                	xchg   %ax,%ax
  802b88:	66 90                	xchg   %ax,%ax
  802b8a:	66 90                	xchg   %ax,%ax
  802b8c:	66 90                	xchg   %ax,%ax
  802b8e:	66 90                	xchg   %ax,%ax

00802b90 <__umoddi3>:
  802b90:	55                   	push   %ebp
  802b91:	57                   	push   %edi
  802b92:	56                   	push   %esi
  802b93:	53                   	push   %ebx
  802b94:	83 ec 1c             	sub    $0x1c,%esp
  802b97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ba7:	85 d2                	test   %edx,%edx
  802ba9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802bad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bb1:	89 f3                	mov    %esi,%ebx
  802bb3:	89 3c 24             	mov    %edi,(%esp)
  802bb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802bba:	75 1c                	jne    802bd8 <__umoddi3+0x48>
  802bbc:	39 f7                	cmp    %esi,%edi
  802bbe:	76 50                	jbe    802c10 <__umoddi3+0x80>
  802bc0:	89 c8                	mov    %ecx,%eax
  802bc2:	89 f2                	mov    %esi,%edx
  802bc4:	f7 f7                	div    %edi
  802bc6:	89 d0                	mov    %edx,%eax
  802bc8:	31 d2                	xor    %edx,%edx
  802bca:	83 c4 1c             	add    $0x1c,%esp
  802bcd:	5b                   	pop    %ebx
  802bce:	5e                   	pop    %esi
  802bcf:	5f                   	pop    %edi
  802bd0:	5d                   	pop    %ebp
  802bd1:	c3                   	ret    
  802bd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bd8:	39 f2                	cmp    %esi,%edx
  802bda:	89 d0                	mov    %edx,%eax
  802bdc:	77 52                	ja     802c30 <__umoddi3+0xa0>
  802bde:	0f bd ea             	bsr    %edx,%ebp
  802be1:	83 f5 1f             	xor    $0x1f,%ebp
  802be4:	75 5a                	jne    802c40 <__umoddi3+0xb0>
  802be6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802bea:	0f 82 e0 00 00 00    	jb     802cd0 <__umoddi3+0x140>
  802bf0:	39 0c 24             	cmp    %ecx,(%esp)
  802bf3:	0f 86 d7 00 00 00    	jbe    802cd0 <__umoddi3+0x140>
  802bf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  802bfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c01:	83 c4 1c             	add    $0x1c,%esp
  802c04:	5b                   	pop    %ebx
  802c05:	5e                   	pop    %esi
  802c06:	5f                   	pop    %edi
  802c07:	5d                   	pop    %ebp
  802c08:	c3                   	ret    
  802c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c10:	85 ff                	test   %edi,%edi
  802c12:	89 fd                	mov    %edi,%ebp
  802c14:	75 0b                	jne    802c21 <__umoddi3+0x91>
  802c16:	b8 01 00 00 00       	mov    $0x1,%eax
  802c1b:	31 d2                	xor    %edx,%edx
  802c1d:	f7 f7                	div    %edi
  802c1f:	89 c5                	mov    %eax,%ebp
  802c21:	89 f0                	mov    %esi,%eax
  802c23:	31 d2                	xor    %edx,%edx
  802c25:	f7 f5                	div    %ebp
  802c27:	89 c8                	mov    %ecx,%eax
  802c29:	f7 f5                	div    %ebp
  802c2b:	89 d0                	mov    %edx,%eax
  802c2d:	eb 99                	jmp    802bc8 <__umoddi3+0x38>
  802c2f:	90                   	nop
  802c30:	89 c8                	mov    %ecx,%eax
  802c32:	89 f2                	mov    %esi,%edx
  802c34:	83 c4 1c             	add    $0x1c,%esp
  802c37:	5b                   	pop    %ebx
  802c38:	5e                   	pop    %esi
  802c39:	5f                   	pop    %edi
  802c3a:	5d                   	pop    %ebp
  802c3b:	c3                   	ret    
  802c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c40:	8b 34 24             	mov    (%esp),%esi
  802c43:	bf 20 00 00 00       	mov    $0x20,%edi
  802c48:	89 e9                	mov    %ebp,%ecx
  802c4a:	29 ef                	sub    %ebp,%edi
  802c4c:	d3 e0                	shl    %cl,%eax
  802c4e:	89 f9                	mov    %edi,%ecx
  802c50:	89 f2                	mov    %esi,%edx
  802c52:	d3 ea                	shr    %cl,%edx
  802c54:	89 e9                	mov    %ebp,%ecx
  802c56:	09 c2                	or     %eax,%edx
  802c58:	89 d8                	mov    %ebx,%eax
  802c5a:	89 14 24             	mov    %edx,(%esp)
  802c5d:	89 f2                	mov    %esi,%edx
  802c5f:	d3 e2                	shl    %cl,%edx
  802c61:	89 f9                	mov    %edi,%ecx
  802c63:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c6b:	d3 e8                	shr    %cl,%eax
  802c6d:	89 e9                	mov    %ebp,%ecx
  802c6f:	89 c6                	mov    %eax,%esi
  802c71:	d3 e3                	shl    %cl,%ebx
  802c73:	89 f9                	mov    %edi,%ecx
  802c75:	89 d0                	mov    %edx,%eax
  802c77:	d3 e8                	shr    %cl,%eax
  802c79:	89 e9                	mov    %ebp,%ecx
  802c7b:	09 d8                	or     %ebx,%eax
  802c7d:	89 d3                	mov    %edx,%ebx
  802c7f:	89 f2                	mov    %esi,%edx
  802c81:	f7 34 24             	divl   (%esp)
  802c84:	89 d6                	mov    %edx,%esi
  802c86:	d3 e3                	shl    %cl,%ebx
  802c88:	f7 64 24 04          	mull   0x4(%esp)
  802c8c:	39 d6                	cmp    %edx,%esi
  802c8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c92:	89 d1                	mov    %edx,%ecx
  802c94:	89 c3                	mov    %eax,%ebx
  802c96:	72 08                	jb     802ca0 <__umoddi3+0x110>
  802c98:	75 11                	jne    802cab <__umoddi3+0x11b>
  802c9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c9e:	73 0b                	jae    802cab <__umoddi3+0x11b>
  802ca0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802ca4:	1b 14 24             	sbb    (%esp),%edx
  802ca7:	89 d1                	mov    %edx,%ecx
  802ca9:	89 c3                	mov    %eax,%ebx
  802cab:	8b 54 24 08          	mov    0x8(%esp),%edx
  802caf:	29 da                	sub    %ebx,%edx
  802cb1:	19 ce                	sbb    %ecx,%esi
  802cb3:	89 f9                	mov    %edi,%ecx
  802cb5:	89 f0                	mov    %esi,%eax
  802cb7:	d3 e0                	shl    %cl,%eax
  802cb9:	89 e9                	mov    %ebp,%ecx
  802cbb:	d3 ea                	shr    %cl,%edx
  802cbd:	89 e9                	mov    %ebp,%ecx
  802cbf:	d3 ee                	shr    %cl,%esi
  802cc1:	09 d0                	or     %edx,%eax
  802cc3:	89 f2                	mov    %esi,%edx
  802cc5:	83 c4 1c             	add    $0x1c,%esp
  802cc8:	5b                   	pop    %ebx
  802cc9:	5e                   	pop    %esi
  802cca:	5f                   	pop    %edi
  802ccb:	5d                   	pop    %ebp
  802ccc:	c3                   	ret    
  802ccd:	8d 76 00             	lea    0x0(%esi),%esi
  802cd0:	29 f9                	sub    %edi,%ecx
  802cd2:	19 d6                	sbb    %edx,%esi
  802cd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cdc:	e9 18 ff ff ff       	jmp    802bf9 <__umoddi3+0x69>
