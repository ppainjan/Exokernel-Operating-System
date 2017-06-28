
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 00 23 80 00       	push   $0x802300
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 cd 01 00 00       	call   80022b <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 03 23 80 00       	push   $0x802303
  80008f:	6a 01                	push   $0x1
  800091:	e8 d5 0a 00 00       	call   800b6b <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 a4 00 00 00       	call   800148 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 b9 0a 00 00       	call   800b6b <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 50 24 80 00       	push   $0x802450
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 98 0a 00 00       	call   800b6b <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e9:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000f0:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f3:	e8 4e 04 00 00       	call   800546 <sys_getenvid>
  8000f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800100:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800105:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010a:	85 db                	test   %ebx,%ebx
  80010c:	7e 07                	jle    800115 <libmain+0x37>
		binaryname = argv[0];
  80010e:	8b 06                	mov    (%esi),%eax
  800110:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
  80011a:	e8 14 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011f:	e8 0a 00 00 00       	call   80012e <exit>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800134:	e8 47 08 00 00       	call   800980 <close_all>
	sys_env_destroy(0);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	6a 00                	push   $0x0
  80013e:	e8 c2 03 00 00       	call   800505 <sys_env_destroy>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	b8 00 00 00 00       	mov    $0x0,%eax
  800153:	eb 03                	jmp    800158 <strlen+0x10>
		n++;
  800155:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800158:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80015c:	75 f7                	jne    800155 <strlen+0xd>
		n++;
	return n;
}
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800166:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	ba 00 00 00 00       	mov    $0x0,%edx
  80016e:	eb 03                	jmp    800173 <strnlen+0x13>
		n++;
  800170:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800173:	39 c2                	cmp    %eax,%edx
  800175:	74 08                	je     80017f <strnlen+0x1f>
  800177:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80017b:	75 f3                	jne    800170 <strnlen+0x10>
  80017d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	53                   	push   %ebx
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80018b:	89 c2                	mov    %eax,%edx
  80018d:	83 c2 01             	add    $0x1,%edx
  800190:	83 c1 01             	add    $0x1,%ecx
  800193:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800197:	88 5a ff             	mov    %bl,-0x1(%edx)
  80019a:	84 db                	test   %bl,%bl
  80019c:	75 ef                	jne    80018d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80019e:	5b                   	pop    %ebx
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	53                   	push   %ebx
  8001a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001a8:	53                   	push   %ebx
  8001a9:	e8 9a ff ff ff       	call   800148 <strlen>
  8001ae:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001b1:	ff 75 0c             	pushl  0xc(%ebp)
  8001b4:	01 d8                	add    %ebx,%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 c5 ff ff ff       	call   800181 <strcpy>
	return dst;
}
  8001bc:	89 d8                	mov    %ebx,%eax
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	56                   	push   %esi
  8001c7:	53                   	push   %ebx
  8001c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ce:	89 f3                	mov    %esi,%ebx
  8001d0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001d3:	89 f2                	mov    %esi,%edx
  8001d5:	eb 0f                	jmp    8001e6 <strncpy+0x23>
		*dst++ = *src;
  8001d7:	83 c2 01             	add    $0x1,%edx
  8001da:	0f b6 01             	movzbl (%ecx),%eax
  8001dd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001e0:	80 39 01             	cmpb   $0x1,(%ecx)
  8001e3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001e6:	39 da                	cmp    %ebx,%edx
  8001e8:	75 ed                	jne    8001d7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001ea:	89 f0                	mov    %esi,%eax
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    

008001f0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 10             	mov    0x10(%ebp),%edx
  8001fe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800200:	85 d2                	test   %edx,%edx
  800202:	74 21                	je     800225 <strlcpy+0x35>
  800204:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800208:	89 f2                	mov    %esi,%edx
  80020a:	eb 09                	jmp    800215 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80020c:	83 c2 01             	add    $0x1,%edx
  80020f:	83 c1 01             	add    $0x1,%ecx
  800212:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800215:	39 c2                	cmp    %eax,%edx
  800217:	74 09                	je     800222 <strlcpy+0x32>
  800219:	0f b6 19             	movzbl (%ecx),%ebx
  80021c:	84 db                	test   %bl,%bl
  80021e:	75 ec                	jne    80020c <strlcpy+0x1c>
  800220:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800222:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800225:	29 f0                	sub    %esi,%eax
}
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800231:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800234:	eb 06                	jmp    80023c <strcmp+0x11>
		p++, q++;
  800236:	83 c1 01             	add    $0x1,%ecx
  800239:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80023c:	0f b6 01             	movzbl (%ecx),%eax
  80023f:	84 c0                	test   %al,%al
  800241:	74 04                	je     800247 <strcmp+0x1c>
  800243:	3a 02                	cmp    (%edx),%al
  800245:	74 ef                	je     800236 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800247:	0f b6 c0             	movzbl %al,%eax
  80024a:	0f b6 12             	movzbl (%edx),%edx
  80024d:	29 d0                	sub    %edx,%eax
}
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	53                   	push   %ebx
  800255:	8b 45 08             	mov    0x8(%ebp),%eax
  800258:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025b:	89 c3                	mov    %eax,%ebx
  80025d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800260:	eb 06                	jmp    800268 <strncmp+0x17>
		n--, p++, q++;
  800262:	83 c0 01             	add    $0x1,%eax
  800265:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800268:	39 d8                	cmp    %ebx,%eax
  80026a:	74 15                	je     800281 <strncmp+0x30>
  80026c:	0f b6 08             	movzbl (%eax),%ecx
  80026f:	84 c9                	test   %cl,%cl
  800271:	74 04                	je     800277 <strncmp+0x26>
  800273:	3a 0a                	cmp    (%edx),%cl
  800275:	74 eb                	je     800262 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800277:	0f b6 00             	movzbl (%eax),%eax
  80027a:	0f b6 12             	movzbl (%edx),%edx
  80027d:	29 d0                	sub    %edx,%eax
  80027f:	eb 05                	jmp    800286 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800281:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800286:	5b                   	pop    %ebx
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800293:	eb 07                	jmp    80029c <strchr+0x13>
		if (*s == c)
  800295:	38 ca                	cmp    %cl,%dl
  800297:	74 0f                	je     8002a8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800299:	83 c0 01             	add    $0x1,%eax
  80029c:	0f b6 10             	movzbl (%eax),%edx
  80029f:	84 d2                	test   %dl,%dl
  8002a1:	75 f2                	jne    800295 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8002a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002b4:	eb 03                	jmp    8002b9 <strfind+0xf>
  8002b6:	83 c0 01             	add    $0x1,%eax
  8002b9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002bc:	38 ca                	cmp    %cl,%dl
  8002be:	74 04                	je     8002c4 <strfind+0x1a>
  8002c0:	84 d2                	test   %dl,%dl
  8002c2:	75 f2                	jne    8002b6 <strfind+0xc>
			break;
	return (char *) s;
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002d2:	85 c9                	test   %ecx,%ecx
  8002d4:	74 36                	je     80030c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002d6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002dc:	75 28                	jne    800306 <memset+0x40>
  8002de:	f6 c1 03             	test   $0x3,%cl
  8002e1:	75 23                	jne    800306 <memset+0x40>
		c &= 0xFF;
  8002e3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002e7:	89 d3                	mov    %edx,%ebx
  8002e9:	c1 e3 08             	shl    $0x8,%ebx
  8002ec:	89 d6                	mov    %edx,%esi
  8002ee:	c1 e6 18             	shl    $0x18,%esi
  8002f1:	89 d0                	mov    %edx,%eax
  8002f3:	c1 e0 10             	shl    $0x10,%eax
  8002f6:	09 f0                	or     %esi,%eax
  8002f8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002fa:	89 d8                	mov    %ebx,%eax
  8002fc:	09 d0                	or     %edx,%eax
  8002fe:	c1 e9 02             	shr    $0x2,%ecx
  800301:	fc                   	cld    
  800302:	f3 ab                	rep stos %eax,%es:(%edi)
  800304:	eb 06                	jmp    80030c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800306:	8b 45 0c             	mov    0xc(%ebp),%eax
  800309:	fc                   	cld    
  80030a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80030c:	89 f8                	mov    %edi,%eax
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	8b 45 08             	mov    0x8(%ebp),%eax
  80031b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800321:	39 c6                	cmp    %eax,%esi
  800323:	73 35                	jae    80035a <memmove+0x47>
  800325:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800328:	39 d0                	cmp    %edx,%eax
  80032a:	73 2e                	jae    80035a <memmove+0x47>
		s += n;
		d += n;
  80032c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80032f:	89 d6                	mov    %edx,%esi
  800331:	09 fe                	or     %edi,%esi
  800333:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800339:	75 13                	jne    80034e <memmove+0x3b>
  80033b:	f6 c1 03             	test   $0x3,%cl
  80033e:	75 0e                	jne    80034e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800340:	83 ef 04             	sub    $0x4,%edi
  800343:	8d 72 fc             	lea    -0x4(%edx),%esi
  800346:	c1 e9 02             	shr    $0x2,%ecx
  800349:	fd                   	std    
  80034a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80034c:	eb 09                	jmp    800357 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80034e:	83 ef 01             	sub    $0x1,%edi
  800351:	8d 72 ff             	lea    -0x1(%edx),%esi
  800354:	fd                   	std    
  800355:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800357:	fc                   	cld    
  800358:	eb 1d                	jmp    800377 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80035a:	89 f2                	mov    %esi,%edx
  80035c:	09 c2                	or     %eax,%edx
  80035e:	f6 c2 03             	test   $0x3,%dl
  800361:	75 0f                	jne    800372 <memmove+0x5f>
  800363:	f6 c1 03             	test   $0x3,%cl
  800366:	75 0a                	jne    800372 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800368:	c1 e9 02             	shr    $0x2,%ecx
  80036b:	89 c7                	mov    %eax,%edi
  80036d:	fc                   	cld    
  80036e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800370:	eb 05                	jmp    800377 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800372:	89 c7                	mov    %eax,%edi
  800374:	fc                   	cld    
  800375:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	ff 75 0c             	pushl  0xc(%ebp)
  800384:	ff 75 08             	pushl  0x8(%ebp)
  800387:	e8 87 ff ff ff       	call   800313 <memmove>
}
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	56                   	push   %esi
  800392:	53                   	push   %ebx
  800393:	8b 45 08             	mov    0x8(%ebp),%eax
  800396:	8b 55 0c             	mov    0xc(%ebp),%edx
  800399:	89 c6                	mov    %eax,%esi
  80039b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80039e:	eb 1a                	jmp    8003ba <memcmp+0x2c>
		if (*s1 != *s2)
  8003a0:	0f b6 08             	movzbl (%eax),%ecx
  8003a3:	0f b6 1a             	movzbl (%edx),%ebx
  8003a6:	38 d9                	cmp    %bl,%cl
  8003a8:	74 0a                	je     8003b4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003aa:	0f b6 c1             	movzbl %cl,%eax
  8003ad:	0f b6 db             	movzbl %bl,%ebx
  8003b0:	29 d8                	sub    %ebx,%eax
  8003b2:	eb 0f                	jmp    8003c3 <memcmp+0x35>
		s1++, s2++;
  8003b4:	83 c0 01             	add    $0x1,%eax
  8003b7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003ba:	39 f0                	cmp    %esi,%eax
  8003bc:	75 e2                	jne    8003a0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c3:	5b                   	pop    %ebx
  8003c4:	5e                   	pop    %esi
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	53                   	push   %ebx
  8003cb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003ce:	89 c1                	mov    %eax,%ecx
  8003d0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003d3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d7:	eb 0a                	jmp    8003e3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003d9:	0f b6 10             	movzbl (%eax),%edx
  8003dc:	39 da                	cmp    %ebx,%edx
  8003de:	74 07                	je     8003e7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003e0:	83 c0 01             	add    $0x1,%eax
  8003e3:	39 c8                	cmp    %ecx,%eax
  8003e5:	72 f2                	jb     8003d9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003e7:	5b                   	pop    %ebx
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	57                   	push   %edi
  8003ee:	56                   	push   %esi
  8003ef:	53                   	push   %ebx
  8003f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f6:	eb 03                	jmp    8003fb <strtol+0x11>
		s++;
  8003f8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003fb:	0f b6 01             	movzbl (%ecx),%eax
  8003fe:	3c 20                	cmp    $0x20,%al
  800400:	74 f6                	je     8003f8 <strtol+0xe>
  800402:	3c 09                	cmp    $0x9,%al
  800404:	74 f2                	je     8003f8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800406:	3c 2b                	cmp    $0x2b,%al
  800408:	75 0a                	jne    800414 <strtol+0x2a>
		s++;
  80040a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80040d:	bf 00 00 00 00       	mov    $0x0,%edi
  800412:	eb 11                	jmp    800425 <strtol+0x3b>
  800414:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800419:	3c 2d                	cmp    $0x2d,%al
  80041b:	75 08                	jne    800425 <strtol+0x3b>
		s++, neg = 1;
  80041d:	83 c1 01             	add    $0x1,%ecx
  800420:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800425:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80042b:	75 15                	jne    800442 <strtol+0x58>
  80042d:	80 39 30             	cmpb   $0x30,(%ecx)
  800430:	75 10                	jne    800442 <strtol+0x58>
  800432:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800436:	75 7c                	jne    8004b4 <strtol+0xca>
		s += 2, base = 16;
  800438:	83 c1 02             	add    $0x2,%ecx
  80043b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800440:	eb 16                	jmp    800458 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800442:	85 db                	test   %ebx,%ebx
  800444:	75 12                	jne    800458 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800446:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80044b:	80 39 30             	cmpb   $0x30,(%ecx)
  80044e:	75 08                	jne    800458 <strtol+0x6e>
		s++, base = 8;
  800450:	83 c1 01             	add    $0x1,%ecx
  800453:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800460:	0f b6 11             	movzbl (%ecx),%edx
  800463:	8d 72 d0             	lea    -0x30(%edx),%esi
  800466:	89 f3                	mov    %esi,%ebx
  800468:	80 fb 09             	cmp    $0x9,%bl
  80046b:	77 08                	ja     800475 <strtol+0x8b>
			dig = *s - '0';
  80046d:	0f be d2             	movsbl %dl,%edx
  800470:	83 ea 30             	sub    $0x30,%edx
  800473:	eb 22                	jmp    800497 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800475:	8d 72 9f             	lea    -0x61(%edx),%esi
  800478:	89 f3                	mov    %esi,%ebx
  80047a:	80 fb 19             	cmp    $0x19,%bl
  80047d:	77 08                	ja     800487 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80047f:	0f be d2             	movsbl %dl,%edx
  800482:	83 ea 57             	sub    $0x57,%edx
  800485:	eb 10                	jmp    800497 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800487:	8d 72 bf             	lea    -0x41(%edx),%esi
  80048a:	89 f3                	mov    %esi,%ebx
  80048c:	80 fb 19             	cmp    $0x19,%bl
  80048f:	77 16                	ja     8004a7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800491:	0f be d2             	movsbl %dl,%edx
  800494:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800497:	3b 55 10             	cmp    0x10(%ebp),%edx
  80049a:	7d 0b                	jge    8004a7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80049c:	83 c1 01             	add    $0x1,%ecx
  80049f:	0f af 45 10          	imul   0x10(%ebp),%eax
  8004a3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8004a5:	eb b9                	jmp    800460 <strtol+0x76>

	if (endptr)
  8004a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004ab:	74 0d                	je     8004ba <strtol+0xd0>
		*endptr = (char *) s;
  8004ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004b0:	89 0e                	mov    %ecx,(%esi)
  8004b2:	eb 06                	jmp    8004ba <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004b4:	85 db                	test   %ebx,%ebx
  8004b6:	74 98                	je     800450 <strtol+0x66>
  8004b8:	eb 9e                	jmp    800458 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004ba:	89 c2                	mov    %eax,%edx
  8004bc:	f7 da                	neg    %edx
  8004be:	85 ff                	test   %edi,%edi
  8004c0:	0f 45 c2             	cmovne %edx,%eax
}
  8004c3:	5b                   	pop    %ebx
  8004c4:	5e                   	pop    %esi
  8004c5:	5f                   	pop    %edi
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	57                   	push   %edi
  8004cc:	56                   	push   %esi
  8004cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d9:	89 c3                	mov    %eax,%ebx
  8004db:	89 c7                	mov    %eax,%edi
  8004dd:	89 c6                	mov    %eax,%esi
  8004df:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004e1:	5b                   	pop    %ebx
  8004e2:	5e                   	pop    %esi
  8004e3:	5f                   	pop    %edi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8004f6:	89 d1                	mov    %edx,%ecx
  8004f8:	89 d3                	mov    %edx,%ebx
  8004fa:	89 d7                	mov    %edx,%edi
  8004fc:	89 d6                	mov    %edx,%esi
  8004fe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800500:	5b                   	pop    %ebx
  800501:	5e                   	pop    %esi
  800502:	5f                   	pop    %edi
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	57                   	push   %edi
  800509:	56                   	push   %esi
  80050a:	53                   	push   %ebx
  80050b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80050e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800513:	b8 03 00 00 00       	mov    $0x3,%eax
  800518:	8b 55 08             	mov    0x8(%ebp),%edx
  80051b:	89 cb                	mov    %ecx,%ebx
  80051d:	89 cf                	mov    %ecx,%edi
  80051f:	89 ce                	mov    %ecx,%esi
  800521:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800523:	85 c0                	test   %eax,%eax
  800525:	7e 17                	jle    80053e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800527:	83 ec 0c             	sub    $0xc,%esp
  80052a:	50                   	push   %eax
  80052b:	6a 03                	push   $0x3
  80052d:	68 0f 23 80 00       	push   $0x80230f
  800532:	6a 23                	push   $0x23
  800534:	68 2c 23 80 00       	push   $0x80232c
  800539:	e8 cc 13 00 00       	call   80190a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80053e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800541:	5b                   	pop    %ebx
  800542:	5e                   	pop    %esi
  800543:	5f                   	pop    %edi
  800544:	5d                   	pop    %ebp
  800545:	c3                   	ret    

00800546 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	57                   	push   %edi
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80054c:	ba 00 00 00 00       	mov    $0x0,%edx
  800551:	b8 02 00 00 00       	mov    $0x2,%eax
  800556:	89 d1                	mov    %edx,%ecx
  800558:	89 d3                	mov    %edx,%ebx
  80055a:	89 d7                	mov    %edx,%edi
  80055c:	89 d6                	mov    %edx,%esi
  80055e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800560:	5b                   	pop    %ebx
  800561:	5e                   	pop    %esi
  800562:	5f                   	pop    %edi
  800563:	5d                   	pop    %ebp
  800564:	c3                   	ret    

00800565 <sys_yield>:

void
sys_yield(void)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	57                   	push   %edi
  800569:	56                   	push   %esi
  80056a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80056b:	ba 00 00 00 00       	mov    $0x0,%edx
  800570:	b8 0b 00 00 00       	mov    $0xb,%eax
  800575:	89 d1                	mov    %edx,%ecx
  800577:	89 d3                	mov    %edx,%ebx
  800579:	89 d7                	mov    %edx,%edi
  80057b:	89 d6                	mov    %edx,%esi
  80057d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80057f:	5b                   	pop    %ebx
  800580:	5e                   	pop    %esi
  800581:	5f                   	pop    %edi
  800582:	5d                   	pop    %ebp
  800583:	c3                   	ret    

00800584 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	57                   	push   %edi
  800588:	56                   	push   %esi
  800589:	53                   	push   %ebx
  80058a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80058d:	be 00 00 00 00       	mov    $0x0,%esi
  800592:	b8 04 00 00 00       	mov    $0x4,%eax
  800597:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80059a:	8b 55 08             	mov    0x8(%ebp),%edx
  80059d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a0:	89 f7                	mov    %esi,%edi
  8005a2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	7e 17                	jle    8005bf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a8:	83 ec 0c             	sub    $0xc,%esp
  8005ab:	50                   	push   %eax
  8005ac:	6a 04                	push   $0x4
  8005ae:	68 0f 23 80 00       	push   $0x80230f
  8005b3:	6a 23                	push   $0x23
  8005b5:	68 2c 23 80 00       	push   $0x80232c
  8005ba:	e8 4b 13 00 00       	call   80190a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c2:	5b                   	pop    %ebx
  8005c3:	5e                   	pop    %esi
  8005c4:	5f                   	pop    %edi
  8005c5:	5d                   	pop    %ebp
  8005c6:	c3                   	ret    

008005c7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	57                   	push   %edi
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8005d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005e1:	8b 75 18             	mov    0x18(%ebp),%esi
  8005e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	7e 17                	jle    800601 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	50                   	push   %eax
  8005ee:	6a 05                	push   $0x5
  8005f0:	68 0f 23 80 00       	push   $0x80230f
  8005f5:	6a 23                	push   $0x23
  8005f7:	68 2c 23 80 00       	push   $0x80232c
  8005fc:	e8 09 13 00 00       	call   80190a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800601:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800604:	5b                   	pop    %ebx
  800605:	5e                   	pop    %esi
  800606:	5f                   	pop    %edi
  800607:	5d                   	pop    %ebp
  800608:	c3                   	ret    

00800609 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800609:	55                   	push   %ebp
  80060a:	89 e5                	mov    %esp,%ebp
  80060c:	57                   	push   %edi
  80060d:	56                   	push   %esi
  80060e:	53                   	push   %ebx
  80060f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800612:	bb 00 00 00 00       	mov    $0x0,%ebx
  800617:	b8 06 00 00 00       	mov    $0x6,%eax
  80061c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80061f:	8b 55 08             	mov    0x8(%ebp),%edx
  800622:	89 df                	mov    %ebx,%edi
  800624:	89 de                	mov    %ebx,%esi
  800626:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800628:	85 c0                	test   %eax,%eax
  80062a:	7e 17                	jle    800643 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80062c:	83 ec 0c             	sub    $0xc,%esp
  80062f:	50                   	push   %eax
  800630:	6a 06                	push   $0x6
  800632:	68 0f 23 80 00       	push   $0x80230f
  800637:	6a 23                	push   $0x23
  800639:	68 2c 23 80 00       	push   $0x80232c
  80063e:	e8 c7 12 00 00       	call   80190a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800643:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800646:	5b                   	pop    %ebx
  800647:	5e                   	pop    %esi
  800648:	5f                   	pop    %edi
  800649:	5d                   	pop    %ebp
  80064a:	c3                   	ret    

0080064b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	57                   	push   %edi
  80064f:	56                   	push   %esi
  800650:	53                   	push   %ebx
  800651:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800654:	bb 00 00 00 00       	mov    $0x0,%ebx
  800659:	b8 08 00 00 00       	mov    $0x8,%eax
  80065e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800661:	8b 55 08             	mov    0x8(%ebp),%edx
  800664:	89 df                	mov    %ebx,%edi
  800666:	89 de                	mov    %ebx,%esi
  800668:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80066a:	85 c0                	test   %eax,%eax
  80066c:	7e 17                	jle    800685 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80066e:	83 ec 0c             	sub    $0xc,%esp
  800671:	50                   	push   %eax
  800672:	6a 08                	push   $0x8
  800674:	68 0f 23 80 00       	push   $0x80230f
  800679:	6a 23                	push   $0x23
  80067b:	68 2c 23 80 00       	push   $0x80232c
  800680:	e8 85 12 00 00       	call   80190a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800685:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800688:	5b                   	pop    %ebx
  800689:	5e                   	pop    %esi
  80068a:	5f                   	pop    %edi
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	57                   	push   %edi
  800691:	56                   	push   %esi
  800692:	53                   	push   %ebx
  800693:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800696:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069b:	b8 09 00 00 00       	mov    $0x9,%eax
  8006a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a6:	89 df                	mov    %ebx,%edi
  8006a8:	89 de                	mov    %ebx,%esi
  8006aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	7e 17                	jle    8006c7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	50                   	push   %eax
  8006b4:	6a 09                	push   $0x9
  8006b6:	68 0f 23 80 00       	push   $0x80230f
  8006bb:	6a 23                	push   $0x23
  8006bd:	68 2c 23 80 00       	push   $0x80232c
  8006c2:	e8 43 12 00 00       	call   80190a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	5f                   	pop    %edi
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	57                   	push   %edi
  8006d3:	56                   	push   %esi
  8006d4:	53                   	push   %ebx
  8006d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e8:	89 df                	mov    %ebx,%edi
  8006ea:	89 de                	mov    %ebx,%esi
  8006ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	7e 17                	jle    800709 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f2:	83 ec 0c             	sub    $0xc,%esp
  8006f5:	50                   	push   %eax
  8006f6:	6a 0a                	push   $0xa
  8006f8:	68 0f 23 80 00       	push   $0x80230f
  8006fd:	6a 23                	push   $0x23
  8006ff:	68 2c 23 80 00       	push   $0x80232c
  800704:	e8 01 12 00 00       	call   80190a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	57                   	push   %edi
  800715:	56                   	push   %esi
  800716:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800717:	be 00 00 00 00       	mov    $0x0,%esi
  80071c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800724:	8b 55 08             	mov    0x8(%ebp),%edx
  800727:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80072a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80072d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80072f:	5b                   	pop    %ebx
  800730:	5e                   	pop    %esi
  800731:	5f                   	pop    %edi
  800732:	5d                   	pop    %ebp
  800733:	c3                   	ret    

00800734 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	57                   	push   %edi
  800738:	56                   	push   %esi
  800739:	53                   	push   %ebx
  80073a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800742:	b8 0d 00 00 00       	mov    $0xd,%eax
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
  80074a:	89 cb                	mov    %ecx,%ebx
  80074c:	89 cf                	mov    %ecx,%edi
  80074e:	89 ce                	mov    %ecx,%esi
  800750:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800752:	85 c0                	test   %eax,%eax
  800754:	7e 17                	jle    80076d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800756:	83 ec 0c             	sub    $0xc,%esp
  800759:	50                   	push   %eax
  80075a:	6a 0d                	push   $0xd
  80075c:	68 0f 23 80 00       	push   $0x80230f
  800761:	6a 23                	push   $0x23
  800763:	68 2c 23 80 00       	push   $0x80232c
  800768:	e8 9d 11 00 00       	call   80190a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80076d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800770:	5b                   	pop    %ebx
  800771:	5e                   	pop    %esi
  800772:	5f                   	pop    %edi
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80077b:	ba 00 00 00 00       	mov    $0x0,%edx
  800780:	b8 0e 00 00 00       	mov    $0xe,%eax
  800785:	89 d1                	mov    %edx,%ecx
  800787:	89 d3                	mov    %edx,%ebx
  800789:	89 d7                	mov    %edx,%edi
  80078b:	89 d6                	mov    %edx,%esi
  80078d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80078f:	5b                   	pop    %ebx
  800790:	5e                   	pop    %esi
  800791:	5f                   	pop    %edi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	57                   	push   %edi
  800798:	56                   	push   %esi
  800799:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80079a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80079f:	b8 0f 00 00 00       	mov    $0xf,%eax
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007aa:	89 df                	mov    %ebx,%edi
  8007ac:	89 de                	mov    %ebx,%esi
  8007ae:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5f                   	pop    %edi
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	05 00 00 00 30       	add    $0x30000000,%eax
  8007c0:	c1 e8 0c             	shr    $0xc,%eax
}
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	05 00 00 00 30       	add    $0x30000000,%eax
  8007d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007d5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	c1 ea 16             	shr    $0x16,%edx
  8007ec:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007f3:	f6 c2 01             	test   $0x1,%dl
  8007f6:	74 11                	je     800809 <fd_alloc+0x2d>
  8007f8:	89 c2                	mov    %eax,%edx
  8007fa:	c1 ea 0c             	shr    $0xc,%edx
  8007fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800804:	f6 c2 01             	test   $0x1,%dl
  800807:	75 09                	jne    800812 <fd_alloc+0x36>
			*fd_store = fd;
  800809:	89 01                	mov    %eax,(%ecx)
			return 0;
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	eb 17                	jmp    800829 <fd_alloc+0x4d>
  800812:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800817:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80081c:	75 c9                	jne    8007e7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80081e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800824:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800831:	83 f8 1f             	cmp    $0x1f,%eax
  800834:	77 36                	ja     80086c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800836:	c1 e0 0c             	shl    $0xc,%eax
  800839:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80083e:	89 c2                	mov    %eax,%edx
  800840:	c1 ea 16             	shr    $0x16,%edx
  800843:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80084a:	f6 c2 01             	test   $0x1,%dl
  80084d:	74 24                	je     800873 <fd_lookup+0x48>
  80084f:	89 c2                	mov    %eax,%edx
  800851:	c1 ea 0c             	shr    $0xc,%edx
  800854:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80085b:	f6 c2 01             	test   $0x1,%dl
  80085e:	74 1a                	je     80087a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
  800863:	89 02                	mov    %eax,(%edx)
	return 0;
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
  80086a:	eb 13                	jmp    80087f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80086c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800871:	eb 0c                	jmp    80087f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800873:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800878:	eb 05                	jmp    80087f <fd_lookup+0x54>
  80087a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088a:	ba b8 23 80 00       	mov    $0x8023b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80088f:	eb 13                	jmp    8008a4 <dev_lookup+0x23>
  800891:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800894:	39 08                	cmp    %ecx,(%eax)
  800896:	75 0c                	jne    8008a4 <dev_lookup+0x23>
			*dev = devtab[i];
  800898:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb 2e                	jmp    8008d2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008a4:	8b 02                	mov    (%edx),%eax
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	75 e7                	jne    800891 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8008af:	8b 40 48             	mov    0x48(%eax),%eax
  8008b2:	83 ec 04             	sub    $0x4,%esp
  8008b5:	51                   	push   %ecx
  8008b6:	50                   	push   %eax
  8008b7:	68 3c 23 80 00       	push   $0x80233c
  8008bc:	e8 22 11 00 00       	call   8019e3 <cprintf>
	*dev = 0;
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	83 ec 10             	sub    $0x10,%esp
  8008dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e5:	50                   	push   %eax
  8008e6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008ec:	c1 e8 0c             	shr    $0xc,%eax
  8008ef:	50                   	push   %eax
  8008f0:	e8 36 ff ff ff       	call   80082b <fd_lookup>
  8008f5:	83 c4 08             	add    $0x8,%esp
  8008f8:	85 c0                	test   %eax,%eax
  8008fa:	78 05                	js     800901 <fd_close+0x2d>
	    || fd != fd2)
  8008fc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008ff:	74 0c                	je     80090d <fd_close+0x39>
		return (must_exist ? r : 0);
  800901:	84 db                	test   %bl,%bl
  800903:	ba 00 00 00 00       	mov    $0x0,%edx
  800908:	0f 44 c2             	cmove  %edx,%eax
  80090b:	eb 41                	jmp    80094e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800913:	50                   	push   %eax
  800914:	ff 36                	pushl  (%esi)
  800916:	e8 66 ff ff ff       	call   800881 <dev_lookup>
  80091b:	89 c3                	mov    %eax,%ebx
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	85 c0                	test   %eax,%eax
  800922:	78 1a                	js     80093e <fd_close+0x6a>
		if (dev->dev_close)
  800924:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800927:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80092a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80092f:	85 c0                	test   %eax,%eax
  800931:	74 0b                	je     80093e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	56                   	push   %esi
  800937:	ff d0                	call   *%eax
  800939:	89 c3                	mov    %eax,%ebx
  80093b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	56                   	push   %esi
  800942:	6a 00                	push   $0x0
  800944:	e8 c0 fc ff ff       	call   800609 <sys_page_unmap>
	return r;
  800949:	83 c4 10             	add    $0x10,%esp
  80094c:	89 d8                	mov    %ebx,%eax
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80095b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80095e:	50                   	push   %eax
  80095f:	ff 75 08             	pushl  0x8(%ebp)
  800962:	e8 c4 fe ff ff       	call   80082b <fd_lookup>
  800967:	83 c4 08             	add    $0x8,%esp
  80096a:	85 c0                	test   %eax,%eax
  80096c:	78 10                	js     80097e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80096e:	83 ec 08             	sub    $0x8,%esp
  800971:	6a 01                	push   $0x1
  800973:	ff 75 f4             	pushl  -0xc(%ebp)
  800976:	e8 59 ff ff ff       	call   8008d4 <fd_close>
  80097b:	83 c4 10             	add    $0x10,%esp
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <close_all>:

void
close_all(void)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800987:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80098c:	83 ec 0c             	sub    $0xc,%esp
  80098f:	53                   	push   %ebx
  800990:	e8 c0 ff ff ff       	call   800955 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800995:	83 c3 01             	add    $0x1,%ebx
  800998:	83 c4 10             	add    $0x10,%esp
  80099b:	83 fb 20             	cmp    $0x20,%ebx
  80099e:	75 ec                	jne    80098c <close_all+0xc>
		close(i);
}
  8009a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	83 ec 2c             	sub    $0x2c,%esp
  8009ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009b4:	50                   	push   %eax
  8009b5:	ff 75 08             	pushl  0x8(%ebp)
  8009b8:	e8 6e fe ff ff       	call   80082b <fd_lookup>
  8009bd:	83 c4 08             	add    $0x8,%esp
  8009c0:	85 c0                	test   %eax,%eax
  8009c2:	0f 88 c1 00 00 00    	js     800a89 <dup+0xe4>
		return r;
	close(newfdnum);
  8009c8:	83 ec 0c             	sub    $0xc,%esp
  8009cb:	56                   	push   %esi
  8009cc:	e8 84 ff ff ff       	call   800955 <close>

	newfd = INDEX2FD(newfdnum);
  8009d1:	89 f3                	mov    %esi,%ebx
  8009d3:	c1 e3 0c             	shl    $0xc,%ebx
  8009d6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8009dc:	83 c4 04             	add    $0x4,%esp
  8009df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009e2:	e8 de fd ff ff       	call   8007c5 <fd2data>
  8009e7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8009e9:	89 1c 24             	mov    %ebx,(%esp)
  8009ec:	e8 d4 fd ff ff       	call   8007c5 <fd2data>
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009f7:	89 f8                	mov    %edi,%eax
  8009f9:	c1 e8 16             	shr    $0x16,%eax
  8009fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a03:	a8 01                	test   $0x1,%al
  800a05:	74 37                	je     800a3e <dup+0x99>
  800a07:	89 f8                	mov    %edi,%eax
  800a09:	c1 e8 0c             	shr    $0xc,%eax
  800a0c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a13:	f6 c2 01             	test   $0x1,%dl
  800a16:	74 26                	je     800a3e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a18:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a1f:	83 ec 0c             	sub    $0xc,%esp
  800a22:	25 07 0e 00 00       	and    $0xe07,%eax
  800a27:	50                   	push   %eax
  800a28:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a2b:	6a 00                	push   $0x0
  800a2d:	57                   	push   %edi
  800a2e:	6a 00                	push   $0x0
  800a30:	e8 92 fb ff ff       	call   8005c7 <sys_page_map>
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	83 c4 20             	add    $0x20,%esp
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	78 2e                	js     800a6c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a41:	89 d0                	mov    %edx,%eax
  800a43:	c1 e8 0c             	shr    $0xc,%eax
  800a46:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a4d:	83 ec 0c             	sub    $0xc,%esp
  800a50:	25 07 0e 00 00       	and    $0xe07,%eax
  800a55:	50                   	push   %eax
  800a56:	53                   	push   %ebx
  800a57:	6a 00                	push   $0x0
  800a59:	52                   	push   %edx
  800a5a:	6a 00                	push   $0x0
  800a5c:	e8 66 fb ff ff       	call   8005c7 <sys_page_map>
  800a61:	89 c7                	mov    %eax,%edi
  800a63:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a66:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a68:	85 ff                	test   %edi,%edi
  800a6a:	79 1d                	jns    800a89 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	6a 00                	push   $0x0
  800a72:	e8 92 fb ff ff       	call   800609 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a77:	83 c4 08             	add    $0x8,%esp
  800a7a:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a7d:	6a 00                	push   $0x0
  800a7f:	e8 85 fb ff ff       	call   800609 <sys_page_unmap>
	return r;
  800a84:	83 c4 10             	add    $0x10,%esp
  800a87:	89 f8                	mov    %edi,%eax
}
  800a89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	53                   	push   %ebx
  800a95:	83 ec 14             	sub    $0x14,%esp
  800a98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a9e:	50                   	push   %eax
  800a9f:	53                   	push   %ebx
  800aa0:	e8 86 fd ff ff       	call   80082b <fd_lookup>
  800aa5:	83 c4 08             	add    $0x8,%esp
  800aa8:	89 c2                	mov    %eax,%edx
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	78 6d                	js     800b1b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aae:	83 ec 08             	sub    $0x8,%esp
  800ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab4:	50                   	push   %eax
  800ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab8:	ff 30                	pushl  (%eax)
  800aba:	e8 c2 fd ff ff       	call   800881 <dev_lookup>
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	78 4c                	js     800b12 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ac6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ac9:	8b 42 08             	mov    0x8(%edx),%eax
  800acc:	83 e0 03             	and    $0x3,%eax
  800acf:	83 f8 01             	cmp    $0x1,%eax
  800ad2:	75 21                	jne    800af5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ad4:	a1 08 40 80 00       	mov    0x804008,%eax
  800ad9:	8b 40 48             	mov    0x48(%eax),%eax
  800adc:	83 ec 04             	sub    $0x4,%esp
  800adf:	53                   	push   %ebx
  800ae0:	50                   	push   %eax
  800ae1:	68 7d 23 80 00       	push   $0x80237d
  800ae6:	e8 f8 0e 00 00       	call   8019e3 <cprintf>
		return -E_INVAL;
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800af3:	eb 26                	jmp    800b1b <read+0x8a>
	}
	if (!dev->dev_read)
  800af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af8:	8b 40 08             	mov    0x8(%eax),%eax
  800afb:	85 c0                	test   %eax,%eax
  800afd:	74 17                	je     800b16 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800aff:	83 ec 04             	sub    $0x4,%esp
  800b02:	ff 75 10             	pushl  0x10(%ebp)
  800b05:	ff 75 0c             	pushl  0xc(%ebp)
  800b08:	52                   	push   %edx
  800b09:	ff d0                	call   *%eax
  800b0b:	89 c2                	mov    %eax,%edx
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	eb 09                	jmp    800b1b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b12:	89 c2                	mov    %eax,%edx
  800b14:	eb 05                	jmp    800b1b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b16:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800b1b:	89 d0                	mov    %edx,%eax
  800b1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	83 ec 0c             	sub    $0xc,%esp
  800b2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b36:	eb 21                	jmp    800b59 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b38:	83 ec 04             	sub    $0x4,%esp
  800b3b:	89 f0                	mov    %esi,%eax
  800b3d:	29 d8                	sub    %ebx,%eax
  800b3f:	50                   	push   %eax
  800b40:	89 d8                	mov    %ebx,%eax
  800b42:	03 45 0c             	add    0xc(%ebp),%eax
  800b45:	50                   	push   %eax
  800b46:	57                   	push   %edi
  800b47:	e8 45 ff ff ff       	call   800a91 <read>
		if (m < 0)
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	78 10                	js     800b63 <readn+0x41>
			return m;
		if (m == 0)
  800b53:	85 c0                	test   %eax,%eax
  800b55:	74 0a                	je     800b61 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b57:	01 c3                	add    %eax,%ebx
  800b59:	39 f3                	cmp    %esi,%ebx
  800b5b:	72 db                	jb     800b38 <readn+0x16>
  800b5d:	89 d8                	mov    %ebx,%eax
  800b5f:	eb 02                	jmp    800b63 <readn+0x41>
  800b61:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 14             	sub    $0x14,%esp
  800b72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b75:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b78:	50                   	push   %eax
  800b79:	53                   	push   %ebx
  800b7a:	e8 ac fc ff ff       	call   80082b <fd_lookup>
  800b7f:	83 c4 08             	add    $0x8,%esp
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	85 c0                	test   %eax,%eax
  800b86:	78 68                	js     800bf0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b88:	83 ec 08             	sub    $0x8,%esp
  800b8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b8e:	50                   	push   %eax
  800b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b92:	ff 30                	pushl  (%eax)
  800b94:	e8 e8 fc ff ff       	call   800881 <dev_lookup>
  800b99:	83 c4 10             	add    $0x10,%esp
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	78 47                	js     800be7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ba7:	75 21                	jne    800bca <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ba9:	a1 08 40 80 00       	mov    0x804008,%eax
  800bae:	8b 40 48             	mov    0x48(%eax),%eax
  800bb1:	83 ec 04             	sub    $0x4,%esp
  800bb4:	53                   	push   %ebx
  800bb5:	50                   	push   %eax
  800bb6:	68 99 23 80 00       	push   $0x802399
  800bbb:	e8 23 0e 00 00       	call   8019e3 <cprintf>
		return -E_INVAL;
  800bc0:	83 c4 10             	add    $0x10,%esp
  800bc3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bc8:	eb 26                	jmp    800bf0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800bca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bcd:	8b 52 0c             	mov    0xc(%edx),%edx
  800bd0:	85 d2                	test   %edx,%edx
  800bd2:	74 17                	je     800beb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800bd4:	83 ec 04             	sub    $0x4,%esp
  800bd7:	ff 75 10             	pushl  0x10(%ebp)
  800bda:	ff 75 0c             	pushl  0xc(%ebp)
  800bdd:	50                   	push   %eax
  800bde:	ff d2                	call   *%edx
  800be0:	89 c2                	mov    %eax,%edx
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	eb 09                	jmp    800bf0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800be7:	89 c2                	mov    %eax,%edx
  800be9:	eb 05                	jmp    800bf0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800beb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800bf0:	89 d0                	mov    %edx,%eax
  800bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf5:	c9                   	leave  
  800bf6:	c3                   	ret    

00800bf7 <seek>:

int
seek(int fdnum, off_t offset)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bfd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c00:	50                   	push   %eax
  800c01:	ff 75 08             	pushl  0x8(%ebp)
  800c04:	e8 22 fc ff ff       	call   80082b <fd_lookup>
  800c09:	83 c4 08             	add    $0x8,%esp
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	78 0e                	js     800c1e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c16:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	53                   	push   %ebx
  800c24:	83 ec 14             	sub    $0x14,%esp
  800c27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c2d:	50                   	push   %eax
  800c2e:	53                   	push   %ebx
  800c2f:	e8 f7 fb ff ff       	call   80082b <fd_lookup>
  800c34:	83 c4 08             	add    $0x8,%esp
  800c37:	89 c2                	mov    %eax,%edx
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	78 65                	js     800ca2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c3d:	83 ec 08             	sub    $0x8,%esp
  800c40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c43:	50                   	push   %eax
  800c44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c47:	ff 30                	pushl  (%eax)
  800c49:	e8 33 fc ff ff       	call   800881 <dev_lookup>
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	85 c0                	test   %eax,%eax
  800c53:	78 44                	js     800c99 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c58:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c5c:	75 21                	jne    800c7f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c5e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c63:	8b 40 48             	mov    0x48(%eax),%eax
  800c66:	83 ec 04             	sub    $0x4,%esp
  800c69:	53                   	push   %ebx
  800c6a:	50                   	push   %eax
  800c6b:	68 5c 23 80 00       	push   $0x80235c
  800c70:	e8 6e 0d 00 00       	call   8019e3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c7d:	eb 23                	jmp    800ca2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c82:	8b 52 18             	mov    0x18(%edx),%edx
  800c85:	85 d2                	test   %edx,%edx
  800c87:	74 14                	je     800c9d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c89:	83 ec 08             	sub    $0x8,%esp
  800c8c:	ff 75 0c             	pushl  0xc(%ebp)
  800c8f:	50                   	push   %eax
  800c90:	ff d2                	call   *%edx
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	eb 09                	jmp    800ca2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c99:	89 c2                	mov    %eax,%edx
  800c9b:	eb 05                	jmp    800ca2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c9d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800ca2:	89 d0                	mov    %edx,%eax
  800ca4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	53                   	push   %ebx
  800cad:	83 ec 14             	sub    $0x14,%esp
  800cb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cb6:	50                   	push   %eax
  800cb7:	ff 75 08             	pushl  0x8(%ebp)
  800cba:	e8 6c fb ff ff       	call   80082b <fd_lookup>
  800cbf:	83 c4 08             	add    $0x8,%esp
  800cc2:	89 c2                	mov    %eax,%edx
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	78 58                	js     800d20 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cc8:	83 ec 08             	sub    $0x8,%esp
  800ccb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cce:	50                   	push   %eax
  800ccf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd2:	ff 30                	pushl  (%eax)
  800cd4:	e8 a8 fb ff ff       	call   800881 <dev_lookup>
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	78 37                	js     800d17 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ce7:	74 32                	je     800d1b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ce9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cf3:	00 00 00 
	stat->st_isdir = 0;
  800cf6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cfd:	00 00 00 
	stat->st_dev = dev;
  800d00:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d06:	83 ec 08             	sub    $0x8,%esp
  800d09:	53                   	push   %ebx
  800d0a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d0d:	ff 50 14             	call   *0x14(%eax)
  800d10:	89 c2                	mov    %eax,%edx
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	eb 09                	jmp    800d20 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d17:	89 c2                	mov    %eax,%edx
  800d19:	eb 05                	jmp    800d20 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d1b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d20:	89 d0                	mov    %edx,%eax
  800d22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d2c:	83 ec 08             	sub    $0x8,%esp
  800d2f:	6a 00                	push   $0x0
  800d31:	ff 75 08             	pushl  0x8(%ebp)
  800d34:	e8 e7 01 00 00       	call   800f20 <open>
  800d39:	89 c3                	mov    %eax,%ebx
  800d3b:	83 c4 10             	add    $0x10,%esp
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	78 1b                	js     800d5d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d42:	83 ec 08             	sub    $0x8,%esp
  800d45:	ff 75 0c             	pushl  0xc(%ebp)
  800d48:	50                   	push   %eax
  800d49:	e8 5b ff ff ff       	call   800ca9 <fstat>
  800d4e:	89 c6                	mov    %eax,%esi
	close(fd);
  800d50:	89 1c 24             	mov    %ebx,(%esp)
  800d53:	e8 fd fb ff ff       	call   800955 <close>
	return r;
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	89 f0                	mov    %esi,%eax
}
  800d5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	89 c6                	mov    %eax,%esi
  800d6b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d6d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d74:	75 12                	jne    800d88 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	6a 01                	push   $0x1
  800d7b:	e8 70 12 00 00       	call   801ff0 <ipc_find_env>
  800d80:	a3 00 40 80 00       	mov    %eax,0x804000
  800d85:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d88:	6a 07                	push   $0x7
  800d8a:	68 00 50 80 00       	push   $0x805000
  800d8f:	56                   	push   %esi
  800d90:	ff 35 00 40 80 00    	pushl  0x804000
  800d96:	e8 01 12 00 00       	call   801f9c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d9b:	83 c4 0c             	add    $0xc,%esp
  800d9e:	6a 00                	push   $0x0
  800da0:	53                   	push   %ebx
  800da1:	6a 00                	push   $0x0
  800da3:	e8 87 11 00 00       	call   801f2f <ipc_recv>
}
  800da8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	8b 40 0c             	mov    0xc(%eax),%eax
  800dbb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 02 00 00 00       	mov    $0x2,%eax
  800dd2:	e8 8d ff ff ff       	call   800d64 <fsipc>
}
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    

00800dd9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	8b 40 0c             	mov    0xc(%eax),%eax
  800de5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800dea:	ba 00 00 00 00       	mov    $0x0,%edx
  800def:	b8 06 00 00 00       	mov    $0x6,%eax
  800df4:	e8 6b ff ff ff       	call   800d64 <fsipc>
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	8b 40 0c             	mov    0xc(%eax),%eax
  800e0b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1a:	e8 45 ff ff ff       	call   800d64 <fsipc>
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 2c                	js     800e4f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e23:	83 ec 08             	sub    $0x8,%esp
  800e26:	68 00 50 80 00       	push   $0x805000
  800e2b:	53                   	push   %ebx
  800e2c:	e8 50 f3 ff ff       	call   800181 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e31:	a1 80 50 80 00       	mov    0x805080,%eax
  800e36:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e3c:	a1 84 50 80 00       	mov    0x805084,%eax
  800e41:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e47:	83 c4 10             	add    $0x10,%esp
  800e4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	53                   	push   %ebx
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  800e5e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e63:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800e68:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  800e6b:	53                   	push   %ebx
  800e6c:	ff 75 0c             	pushl  0xc(%ebp)
  800e6f:	68 08 50 80 00       	push   $0x805008
  800e74:	e8 9a f4 ff ff       	call   800313 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	8b 40 0c             	mov    0xc(%eax),%eax
  800e7f:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  800e84:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  800e8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800e94:	e8 cb fe ff ff       	call   800d64 <fsipc>
	//panic("devfile_write not implemented");
}
  800e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    

00800e9e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	8b 40 0c             	mov    0xc(%eax),%eax
  800eac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800eb1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800eb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec1:	e8 9e fe ff ff       	call   800d64 <fsipc>
  800ec6:	89 c3                	mov    %eax,%ebx
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 4b                	js     800f17 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ecc:	39 c6                	cmp    %eax,%esi
  800ece:	73 16                	jae    800ee6 <devfile_read+0x48>
  800ed0:	68 cc 23 80 00       	push   $0x8023cc
  800ed5:	68 d3 23 80 00       	push   $0x8023d3
  800eda:	6a 7c                	push   $0x7c
  800edc:	68 e8 23 80 00       	push   $0x8023e8
  800ee1:	e8 24 0a 00 00       	call   80190a <_panic>
	assert(r <= PGSIZE);
  800ee6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800eeb:	7e 16                	jle    800f03 <devfile_read+0x65>
  800eed:	68 f3 23 80 00       	push   $0x8023f3
  800ef2:	68 d3 23 80 00       	push   $0x8023d3
  800ef7:	6a 7d                	push   $0x7d
  800ef9:	68 e8 23 80 00       	push   $0x8023e8
  800efe:	e8 07 0a 00 00       	call   80190a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	50                   	push   %eax
  800f07:	68 00 50 80 00       	push   $0x805000
  800f0c:	ff 75 0c             	pushl  0xc(%ebp)
  800f0f:	e8 ff f3 ff ff       	call   800313 <memmove>
	return r;
  800f14:	83 c4 10             	add    $0x10,%esp
}
  800f17:	89 d8                	mov    %ebx,%eax
  800f19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	53                   	push   %ebx
  800f24:	83 ec 20             	sub    $0x20,%esp
  800f27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f2a:	53                   	push   %ebx
  800f2b:	e8 18 f2 ff ff       	call   800148 <strlen>
  800f30:	83 c4 10             	add    $0x10,%esp
  800f33:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f38:	7f 67                	jg     800fa1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f40:	50                   	push   %eax
  800f41:	e8 96 f8 ff ff       	call   8007dc <fd_alloc>
  800f46:	83 c4 10             	add    $0x10,%esp
		return r;
  800f49:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 57                	js     800fa6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f4f:	83 ec 08             	sub    $0x8,%esp
  800f52:	53                   	push   %ebx
  800f53:	68 00 50 80 00       	push   $0x805000
  800f58:	e8 24 f2 ff ff       	call   800181 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f68:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6d:	e8 f2 fd ff ff       	call   800d64 <fsipc>
  800f72:	89 c3                	mov    %eax,%ebx
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	79 14                	jns    800f8f <open+0x6f>
		fd_close(fd, 0);
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	6a 00                	push   $0x0
  800f80:	ff 75 f4             	pushl  -0xc(%ebp)
  800f83:	e8 4c f9 ff ff       	call   8008d4 <fd_close>
		return r;
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	89 da                	mov    %ebx,%edx
  800f8d:	eb 17                	jmp    800fa6 <open+0x86>
	}

	return fd2num(fd);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	ff 75 f4             	pushl  -0xc(%ebp)
  800f95:	e8 1b f8 ff ff       	call   8007b5 <fd2num>
  800f9a:	89 c2                	mov    %eax,%edx
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	eb 05                	jmp    800fa6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800fa1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800fa6:	89 d0                	mov    %edx,%eax
  800fa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbd:	e8 a2 fd ff ff       	call   800d64 <fsipc>
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800fca:	68 ff 23 80 00       	push   $0x8023ff
  800fcf:	ff 75 0c             	pushl  0xc(%ebp)
  800fd2:	e8 aa f1 ff ff       	call   800181 <strcpy>
	return 0;
}
  800fd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    

00800fde <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	53                   	push   %ebx
  800fe2:	83 ec 10             	sub    $0x10,%esp
  800fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800fe8:	53                   	push   %ebx
  800fe9:	e8 3b 10 00 00       	call   802029 <pageref>
  800fee:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800ff1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800ff6:	83 f8 01             	cmp    $0x1,%eax
  800ff9:	75 10                	jne    80100b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	ff 73 0c             	pushl  0xc(%ebx)
  801001:	e8 c0 02 00 00       	call   8012c6 <nsipc_close>
  801006:	89 c2                	mov    %eax,%edx
  801008:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80100b:	89 d0                	mov    %edx,%eax
  80100d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801018:	6a 00                	push   $0x0
  80101a:	ff 75 10             	pushl  0x10(%ebp)
  80101d:	ff 75 0c             	pushl  0xc(%ebp)
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
  801023:	ff 70 0c             	pushl  0xc(%eax)
  801026:	e8 78 03 00 00       	call   8013a3 <nsipc_send>
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801033:	6a 00                	push   $0x0
  801035:	ff 75 10             	pushl  0x10(%ebp)
  801038:	ff 75 0c             	pushl  0xc(%ebp)
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	ff 70 0c             	pushl  0xc(%eax)
  801041:	e8 f1 02 00 00       	call   801337 <nsipc_recv>
}
  801046:	c9                   	leave  
  801047:	c3                   	ret    

00801048 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80104e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801051:	52                   	push   %edx
  801052:	50                   	push   %eax
  801053:	e8 d3 f7 ff ff       	call   80082b <fd_lookup>
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 17                	js     801076 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80105f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801062:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801068:	39 08                	cmp    %ecx,(%eax)
  80106a:	75 05                	jne    801071 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80106c:	8b 40 0c             	mov    0xc(%eax),%eax
  80106f:	eb 05                	jmp    801076 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801071:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
  80107d:	83 ec 1c             	sub    $0x1c,%esp
  801080:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801082:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801085:	50                   	push   %eax
  801086:	e8 51 f7 ff ff       	call   8007dc <fd_alloc>
  80108b:	89 c3                	mov    %eax,%ebx
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	78 1b                	js     8010af <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	68 07 04 00 00       	push   $0x407
  80109c:	ff 75 f4             	pushl  -0xc(%ebp)
  80109f:	6a 00                	push   $0x0
  8010a1:	e8 de f4 ff ff       	call   800584 <sys_page_alloc>
  8010a6:	89 c3                	mov    %eax,%ebx
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	79 10                	jns    8010bf <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	56                   	push   %esi
  8010b3:	e8 0e 02 00 00       	call   8012c6 <nsipc_close>
		return r;
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	89 d8                	mov    %ebx,%eax
  8010bd:	eb 24                	jmp    8010e3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8010bf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8010c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8010ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010cd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8010d4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	50                   	push   %eax
  8010db:	e8 d5 f6 ff ff       	call   8007b5 <fd2num>
  8010e0:	83 c4 10             	add    $0x10,%esp
}
  8010e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	e8 50 ff ff ff       	call   801048 <fd2sockid>
		return r;
  8010f8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	78 1f                	js     80111d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	ff 75 10             	pushl  0x10(%ebp)
  801104:	ff 75 0c             	pushl  0xc(%ebp)
  801107:	50                   	push   %eax
  801108:	e8 12 01 00 00       	call   80121f <nsipc_accept>
  80110d:	83 c4 10             	add    $0x10,%esp
		return r;
  801110:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	78 07                	js     80111d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801116:	e8 5d ff ff ff       	call   801078 <alloc_sockfd>
  80111b:	89 c1                	mov    %eax,%ecx
}
  80111d:	89 c8                	mov    %ecx,%eax
  80111f:	c9                   	leave  
  801120:	c3                   	ret    

00801121 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
  80112a:	e8 19 ff ff ff       	call   801048 <fd2sockid>
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 12                	js     801145 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	ff 75 10             	pushl  0x10(%ebp)
  801139:	ff 75 0c             	pushl  0xc(%ebp)
  80113c:	50                   	push   %eax
  80113d:	e8 2d 01 00 00       	call   80126f <nsipc_bind>
  801142:	83 c4 10             	add    $0x10,%esp
}
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <shutdown>:

int
shutdown(int s, int how)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	e8 f3 fe ff ff       	call   801048 <fd2sockid>
  801155:	85 c0                	test   %eax,%eax
  801157:	78 0f                	js     801168 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	ff 75 0c             	pushl  0xc(%ebp)
  80115f:	50                   	push   %eax
  801160:	e8 3f 01 00 00       	call   8012a4 <nsipc_shutdown>
  801165:	83 c4 10             	add    $0x10,%esp
}
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	e8 d0 fe ff ff       	call   801048 <fd2sockid>
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 12                	js     80118e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	ff 75 10             	pushl  0x10(%ebp)
  801182:	ff 75 0c             	pushl  0xc(%ebp)
  801185:	50                   	push   %eax
  801186:	e8 55 01 00 00       	call   8012e0 <nsipc_connect>
  80118b:	83 c4 10             	add    $0x10,%esp
}
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <listen>:

int
listen(int s, int backlog)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	e8 aa fe ff ff       	call   801048 <fd2sockid>
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 0f                	js     8011b1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	ff 75 0c             	pushl  0xc(%ebp)
  8011a8:	50                   	push   %eax
  8011a9:	e8 67 01 00 00       	call   801315 <nsipc_listen>
  8011ae:	83 c4 10             	add    $0x10,%esp
}
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8011b9:	ff 75 10             	pushl  0x10(%ebp)
  8011bc:	ff 75 0c             	pushl  0xc(%ebp)
  8011bf:	ff 75 08             	pushl  0x8(%ebp)
  8011c2:	e8 3a 02 00 00       	call   801401 <nsipc_socket>
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 05                	js     8011d3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8011ce:	e8 a5 fe ff ff       	call   801078 <alloc_sockfd>
}
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 04             	sub    $0x4,%esp
  8011dc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8011de:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8011e5:	75 12                	jne    8011f9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	6a 02                	push   $0x2
  8011ec:	e8 ff 0d 00 00       	call   801ff0 <ipc_find_env>
  8011f1:	a3 04 40 80 00       	mov    %eax,0x804004
  8011f6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8011f9:	6a 07                	push   $0x7
  8011fb:	68 00 60 80 00       	push   $0x806000
  801200:	53                   	push   %ebx
  801201:	ff 35 04 40 80 00    	pushl  0x804004
  801207:	e8 90 0d 00 00       	call   801f9c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80120c:	83 c4 0c             	add    $0xc,%esp
  80120f:	6a 00                	push   $0x0
  801211:	6a 00                	push   $0x0
  801213:	6a 00                	push   $0x0
  801215:	e8 15 0d 00 00       	call   801f2f <ipc_recv>
}
  80121a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801227:	8b 45 08             	mov    0x8(%ebp),%eax
  80122a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80122f:	8b 06                	mov    (%esi),%eax
  801231:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801236:	b8 01 00 00 00       	mov    $0x1,%eax
  80123b:	e8 95 ff ff ff       	call   8011d5 <nsipc>
  801240:	89 c3                	mov    %eax,%ebx
  801242:	85 c0                	test   %eax,%eax
  801244:	78 20                	js     801266 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	ff 35 10 60 80 00    	pushl  0x806010
  80124f:	68 00 60 80 00       	push   $0x806000
  801254:	ff 75 0c             	pushl  0xc(%ebp)
  801257:	e8 b7 f0 ff ff       	call   800313 <memmove>
		*addrlen = ret->ret_addrlen;
  80125c:	a1 10 60 80 00       	mov    0x806010,%eax
  801261:	89 06                	mov    %eax,(%esi)
  801263:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801266:	89 d8                	mov    %ebx,%eax
  801268:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126b:	5b                   	pop    %ebx
  80126c:	5e                   	pop    %esi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	53                   	push   %ebx
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801279:	8b 45 08             	mov    0x8(%ebp),%eax
  80127c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801281:	53                   	push   %ebx
  801282:	ff 75 0c             	pushl  0xc(%ebp)
  801285:	68 04 60 80 00       	push   $0x806004
  80128a:	e8 84 f0 ff ff       	call   800313 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80128f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801295:	b8 02 00 00 00       	mov    $0x2,%eax
  80129a:	e8 36 ff ff ff       	call   8011d5 <nsipc>
}
  80129f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8012b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8012ba:	b8 03 00 00 00       	mov    $0x3,%eax
  8012bf:	e8 11 ff ff ff       	call   8011d5 <nsipc>
}
  8012c4:	c9                   	leave  
  8012c5:	c3                   	ret    

008012c6 <nsipc_close>:

int
nsipc_close(int s)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8012cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cf:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8012d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8012d9:	e8 f7 fe ff ff       	call   8011d5 <nsipc>
}
  8012de:	c9                   	leave  
  8012df:	c3                   	ret    

008012e0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8012ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ed:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8012f2:	53                   	push   %ebx
  8012f3:	ff 75 0c             	pushl  0xc(%ebp)
  8012f6:	68 04 60 80 00       	push   $0x806004
  8012fb:	e8 13 f0 ff ff       	call   800313 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801300:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801306:	b8 05 00 00 00       	mov    $0x5,%eax
  80130b:	e8 c5 fe ff ff       	call   8011d5 <nsipc>
}
  801310:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801323:	8b 45 0c             	mov    0xc(%ebp),%eax
  801326:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80132b:	b8 06 00 00 00       	mov    $0x6,%eax
  801330:	e8 a0 fe ff ff       	call   8011d5 <nsipc>
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
  80133c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80133f:	8b 45 08             	mov    0x8(%ebp),%eax
  801342:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801347:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80134d:	8b 45 14             	mov    0x14(%ebp),%eax
  801350:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801355:	b8 07 00 00 00       	mov    $0x7,%eax
  80135a:	e8 76 fe ff ff       	call   8011d5 <nsipc>
  80135f:	89 c3                	mov    %eax,%ebx
  801361:	85 c0                	test   %eax,%eax
  801363:	78 35                	js     80139a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801365:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80136a:	7f 04                	jg     801370 <nsipc_recv+0x39>
  80136c:	39 c6                	cmp    %eax,%esi
  80136e:	7d 16                	jge    801386 <nsipc_recv+0x4f>
  801370:	68 0b 24 80 00       	push   $0x80240b
  801375:	68 d3 23 80 00       	push   $0x8023d3
  80137a:	6a 62                	push   $0x62
  80137c:	68 20 24 80 00       	push   $0x802420
  801381:	e8 84 05 00 00       	call   80190a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801386:	83 ec 04             	sub    $0x4,%esp
  801389:	50                   	push   %eax
  80138a:	68 00 60 80 00       	push   $0x806000
  80138f:	ff 75 0c             	pushl  0xc(%ebp)
  801392:	e8 7c ef ff ff       	call   800313 <memmove>
  801397:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80139a:	89 d8                	mov    %ebx,%eax
  80139c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8013b5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8013bb:	7e 16                	jle    8013d3 <nsipc_send+0x30>
  8013bd:	68 2c 24 80 00       	push   $0x80242c
  8013c2:	68 d3 23 80 00       	push   $0x8023d3
  8013c7:	6a 6d                	push   $0x6d
  8013c9:	68 20 24 80 00       	push   $0x802420
  8013ce:	e8 37 05 00 00       	call   80190a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8013d3:	83 ec 04             	sub    $0x4,%esp
  8013d6:	53                   	push   %ebx
  8013d7:	ff 75 0c             	pushl  0xc(%ebp)
  8013da:	68 0c 60 80 00       	push   $0x80600c
  8013df:	e8 2f ef ff ff       	call   800313 <memmove>
	nsipcbuf.send.req_size = size;
  8013e4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8013ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ed:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8013f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8013f7:	e8 d9 fd ff ff       	call   8011d5 <nsipc>
}
  8013fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801407:	8b 45 08             	mov    0x8(%ebp),%eax
  80140a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80140f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801412:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801417:	8b 45 10             	mov    0x10(%ebp),%eax
  80141a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80141f:	b8 09 00 00 00       	mov    $0x9,%eax
  801424:	e8 ac fd ff ff       	call   8011d5 <nsipc>
}
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	56                   	push   %esi
  80142f:	53                   	push   %ebx
  801430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801433:	83 ec 0c             	sub    $0xc,%esp
  801436:	ff 75 08             	pushl  0x8(%ebp)
  801439:	e8 87 f3 ff ff       	call   8007c5 <fd2data>
  80143e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801440:	83 c4 08             	add    $0x8,%esp
  801443:	68 38 24 80 00       	push   $0x802438
  801448:	53                   	push   %ebx
  801449:	e8 33 ed ff ff       	call   800181 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80144e:	8b 46 04             	mov    0x4(%esi),%eax
  801451:	2b 06                	sub    (%esi),%eax
  801453:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801459:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801460:	00 00 00 
	stat->st_dev = &devpipe;
  801463:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80146a:	30 80 00 
	return 0;
}
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
  801472:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	53                   	push   %ebx
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801483:	53                   	push   %ebx
  801484:	6a 00                	push   $0x0
  801486:	e8 7e f1 ff ff       	call   800609 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80148b:	89 1c 24             	mov    %ebx,(%esp)
  80148e:	e8 32 f3 ff ff       	call   8007c5 <fd2data>
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	50                   	push   %eax
  801497:	6a 00                	push   $0x0
  801499:	e8 6b f1 ff ff       	call   800609 <sys_page_unmap>
}
  80149e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	57                   	push   %edi
  8014a7:	56                   	push   %esi
  8014a8:	53                   	push   %ebx
  8014a9:	83 ec 1c             	sub    $0x1c,%esp
  8014ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014af:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8014b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8014bf:	e8 65 0b 00 00       	call   802029 <pageref>
  8014c4:	89 c3                	mov    %eax,%ebx
  8014c6:	89 3c 24             	mov    %edi,(%esp)
  8014c9:	e8 5b 0b 00 00       	call   802029 <pageref>
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	39 c3                	cmp    %eax,%ebx
  8014d3:	0f 94 c1             	sete   %cl
  8014d6:	0f b6 c9             	movzbl %cl,%ecx
  8014d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8014dc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8014e2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8014e5:	39 ce                	cmp    %ecx,%esi
  8014e7:	74 1b                	je     801504 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8014e9:	39 c3                	cmp    %eax,%ebx
  8014eb:	75 c4                	jne    8014b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8014ed:	8b 42 58             	mov    0x58(%edx),%eax
  8014f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014f3:	50                   	push   %eax
  8014f4:	56                   	push   %esi
  8014f5:	68 3f 24 80 00       	push   $0x80243f
  8014fa:	e8 e4 04 00 00       	call   8019e3 <cprintf>
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	eb ad                	jmp    8014b1 <_pipeisclosed+0xe>
	}
}
  801504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801507:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150a:	5b                   	pop    %ebx
  80150b:	5e                   	pop    %esi
  80150c:	5f                   	pop    %edi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	57                   	push   %edi
  801513:	56                   	push   %esi
  801514:	53                   	push   %ebx
  801515:	83 ec 28             	sub    $0x28,%esp
  801518:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80151b:	56                   	push   %esi
  80151c:	e8 a4 f2 ff ff       	call   8007c5 <fd2data>
  801521:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	bf 00 00 00 00       	mov    $0x0,%edi
  80152b:	eb 4b                	jmp    801578 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80152d:	89 da                	mov    %ebx,%edx
  80152f:	89 f0                	mov    %esi,%eax
  801531:	e8 6d ff ff ff       	call   8014a3 <_pipeisclosed>
  801536:	85 c0                	test   %eax,%eax
  801538:	75 48                	jne    801582 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80153a:	e8 26 f0 ff ff       	call   800565 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80153f:	8b 43 04             	mov    0x4(%ebx),%eax
  801542:	8b 0b                	mov    (%ebx),%ecx
  801544:	8d 51 20             	lea    0x20(%ecx),%edx
  801547:	39 d0                	cmp    %edx,%eax
  801549:	73 e2                	jae    80152d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80154b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801552:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801555:	89 c2                	mov    %eax,%edx
  801557:	c1 fa 1f             	sar    $0x1f,%edx
  80155a:	89 d1                	mov    %edx,%ecx
  80155c:	c1 e9 1b             	shr    $0x1b,%ecx
  80155f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801562:	83 e2 1f             	and    $0x1f,%edx
  801565:	29 ca                	sub    %ecx,%edx
  801567:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80156b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80156f:	83 c0 01             	add    $0x1,%eax
  801572:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801575:	83 c7 01             	add    $0x1,%edi
  801578:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80157b:	75 c2                	jne    80153f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80157d:	8b 45 10             	mov    0x10(%ebp),%eax
  801580:	eb 05                	jmp    801587 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801582:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801587:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	57                   	push   %edi
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	83 ec 18             	sub    $0x18,%esp
  801598:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80159b:	57                   	push   %edi
  80159c:	e8 24 f2 ff ff       	call   8007c5 <fd2data>
  8015a1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ab:	eb 3d                	jmp    8015ea <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8015ad:	85 db                	test   %ebx,%ebx
  8015af:	74 04                	je     8015b5 <devpipe_read+0x26>
				return i;
  8015b1:	89 d8                	mov    %ebx,%eax
  8015b3:	eb 44                	jmp    8015f9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8015b5:	89 f2                	mov    %esi,%edx
  8015b7:	89 f8                	mov    %edi,%eax
  8015b9:	e8 e5 fe ff ff       	call   8014a3 <_pipeisclosed>
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	75 32                	jne    8015f4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8015c2:	e8 9e ef ff ff       	call   800565 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8015c7:	8b 06                	mov    (%esi),%eax
  8015c9:	3b 46 04             	cmp    0x4(%esi),%eax
  8015cc:	74 df                	je     8015ad <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8015ce:	99                   	cltd   
  8015cf:	c1 ea 1b             	shr    $0x1b,%edx
  8015d2:	01 d0                	add    %edx,%eax
  8015d4:	83 e0 1f             	and    $0x1f,%eax
  8015d7:	29 d0                	sub    %edx,%eax
  8015d9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8015de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8015e4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015e7:	83 c3 01             	add    $0x1,%ebx
  8015ea:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015ed:	75 d8                	jne    8015c7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8015ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f2:	eb 05                	jmp    8015f9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8015f4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8015f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5f                   	pop    %edi
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
  801606:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801609:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	e8 ca f1 ff ff       	call   8007dc <fd_alloc>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	89 c2                	mov    %eax,%edx
  801617:	85 c0                	test   %eax,%eax
  801619:	0f 88 2c 01 00 00    	js     80174b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	68 07 04 00 00       	push   $0x407
  801627:	ff 75 f4             	pushl  -0xc(%ebp)
  80162a:	6a 00                	push   $0x0
  80162c:	e8 53 ef ff ff       	call   800584 <sys_page_alloc>
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	89 c2                	mov    %eax,%edx
  801636:	85 c0                	test   %eax,%eax
  801638:	0f 88 0d 01 00 00    	js     80174b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80163e:	83 ec 0c             	sub    $0xc,%esp
  801641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	e8 92 f1 ff ff       	call   8007dc <fd_alloc>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	0f 88 e2 00 00 00    	js     801739 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801657:	83 ec 04             	sub    $0x4,%esp
  80165a:	68 07 04 00 00       	push   $0x407
  80165f:	ff 75 f0             	pushl  -0x10(%ebp)
  801662:	6a 00                	push   $0x0
  801664:	e8 1b ef ff ff       	call   800584 <sys_page_alloc>
  801669:	89 c3                	mov    %eax,%ebx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	0f 88 c3 00 00 00    	js     801739 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	ff 75 f4             	pushl  -0xc(%ebp)
  80167c:	e8 44 f1 ff ff       	call   8007c5 <fd2data>
  801681:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801683:	83 c4 0c             	add    $0xc,%esp
  801686:	68 07 04 00 00       	push   $0x407
  80168b:	50                   	push   %eax
  80168c:	6a 00                	push   $0x0
  80168e:	e8 f1 ee ff ff       	call   800584 <sys_page_alloc>
  801693:	89 c3                	mov    %eax,%ebx
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	0f 88 89 00 00 00    	js     801729 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016a0:	83 ec 0c             	sub    $0xc,%esp
  8016a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a6:	e8 1a f1 ff ff       	call   8007c5 <fd2data>
  8016ab:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8016b2:	50                   	push   %eax
  8016b3:	6a 00                	push   $0x0
  8016b5:	56                   	push   %esi
  8016b6:	6a 00                	push   $0x0
  8016b8:	e8 0a ef ff ff       	call   8005c7 <sys_page_map>
  8016bd:	89 c3                	mov    %eax,%ebx
  8016bf:	83 c4 20             	add    $0x20,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 55                	js     80171b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8016c6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8016cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8016d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8016db:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8016e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f6:	e8 ba f0 ff ff       	call   8007b5 <fd2num>
  8016fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fe:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801700:	83 c4 04             	add    $0x4,%esp
  801703:	ff 75 f0             	pushl  -0x10(%ebp)
  801706:	e8 aa f0 ff ff       	call   8007b5 <fd2num>
  80170b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	ba 00 00 00 00       	mov    $0x0,%edx
  801719:	eb 30                	jmp    80174b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	56                   	push   %esi
  80171f:	6a 00                	push   $0x0
  801721:	e8 e3 ee ff ff       	call   800609 <sys_page_unmap>
  801726:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	ff 75 f0             	pushl  -0x10(%ebp)
  80172f:	6a 00                	push   $0x0
  801731:	e8 d3 ee ff ff       	call   800609 <sys_page_unmap>
  801736:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	ff 75 f4             	pushl  -0xc(%ebp)
  80173f:	6a 00                	push   $0x0
  801741:	e8 c3 ee ff ff       	call   800609 <sys_page_unmap>
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80174b:	89 d0                	mov    %edx,%eax
  80174d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801750:	5b                   	pop    %ebx
  801751:	5e                   	pop    %esi
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	ff 75 08             	pushl  0x8(%ebp)
  801761:	e8 c5 f0 ff ff       	call   80082b <fd_lookup>
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 18                	js     801785 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	ff 75 f4             	pushl  -0xc(%ebp)
  801773:	e8 4d f0 ff ff       	call   8007c5 <fd2data>
	return _pipeisclosed(fd, p);
  801778:	89 c2                	mov    %eax,%edx
  80177a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177d:	e8 21 fd ff ff       	call   8014a3 <_pipeisclosed>
  801782:	83 c4 10             	add    $0x10,%esp
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801797:	68 57 24 80 00       	push   $0x802457
  80179c:	ff 75 0c             	pushl  0xc(%ebp)
  80179f:	e8 dd e9 ff ff       	call   800181 <strcpy>
	return 0;
}
  8017a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	57                   	push   %edi
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017b7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8017bc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017c2:	eb 2d                	jmp    8017f1 <devcons_write+0x46>
		m = n - tot;
  8017c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017c7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8017c9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8017cc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8017d1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	53                   	push   %ebx
  8017d8:	03 45 0c             	add    0xc(%ebp),%eax
  8017db:	50                   	push   %eax
  8017dc:	57                   	push   %edi
  8017dd:	e8 31 eb ff ff       	call   800313 <memmove>
		sys_cputs(buf, m);
  8017e2:	83 c4 08             	add    $0x8,%esp
  8017e5:	53                   	push   %ebx
  8017e6:	57                   	push   %edi
  8017e7:	e8 dc ec ff ff       	call   8004c8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017ec:	01 de                	add    %ebx,%esi
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	89 f0                	mov    %esi,%eax
  8017f3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017f6:	72 cc                	jb     8017c4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8017f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5f                   	pop    %edi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80180b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80180f:	74 2a                	je     80183b <devcons_read+0x3b>
  801811:	eb 05                	jmp    801818 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801813:	e8 4d ed ff ff       	call   800565 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801818:	e8 c9 ec ff ff       	call   8004e6 <sys_cgetc>
  80181d:	85 c0                	test   %eax,%eax
  80181f:	74 f2                	je     801813 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801821:	85 c0                	test   %eax,%eax
  801823:	78 16                	js     80183b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801825:	83 f8 04             	cmp    $0x4,%eax
  801828:	74 0c                	je     801836 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80182a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182d:	88 02                	mov    %al,(%edx)
	return 1;
  80182f:	b8 01 00 00 00       	mov    $0x1,%eax
  801834:	eb 05                	jmp    80183b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801849:	6a 01                	push   $0x1
  80184b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80184e:	50                   	push   %eax
  80184f:	e8 74 ec ff ff       	call   8004c8 <sys_cputs>
}
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <getchar>:

int
getchar(void)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80185f:	6a 01                	push   $0x1
  801861:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801864:	50                   	push   %eax
  801865:	6a 00                	push   $0x0
  801867:	e8 25 f2 ff ff       	call   800a91 <read>
	if (r < 0)
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 0f                	js     801882 <getchar+0x29>
		return r;
	if (r < 1)
  801873:	85 c0                	test   %eax,%eax
  801875:	7e 06                	jle    80187d <getchar+0x24>
		return -E_EOF;
	return c;
  801877:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80187b:	eb 05                	jmp    801882 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80187d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80188a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188d:	50                   	push   %eax
  80188e:	ff 75 08             	pushl  0x8(%ebp)
  801891:	e8 95 ef ff ff       	call   80082b <fd_lookup>
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 11                	js     8018ae <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018a6:	39 10                	cmp    %edx,(%eax)
  8018a8:	0f 94 c0             	sete   %al
  8018ab:	0f b6 c0             	movzbl %al,%eax
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <opencons>:

int
opencons(void)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8018b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b9:	50                   	push   %eax
  8018ba:	e8 1d ef ff ff       	call   8007dc <fd_alloc>
  8018bf:	83 c4 10             	add    $0x10,%esp
		return r;
  8018c2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 3e                	js     801906 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8018c8:	83 ec 04             	sub    $0x4,%esp
  8018cb:	68 07 04 00 00       	push   $0x407
  8018d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 aa ec ff ff       	call   800584 <sys_page_alloc>
  8018da:	83 c4 10             	add    $0x10,%esp
		return r;
  8018dd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 23                	js     801906 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8018e3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8018ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	50                   	push   %eax
  8018fc:	e8 b4 ee ff ff       	call   8007b5 <fd2num>
  801901:	89 c2                	mov    %eax,%edx
  801903:	83 c4 10             	add    $0x10,%esp
}
  801906:	89 d0                	mov    %edx,%eax
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	56                   	push   %esi
  80190e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80190f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801912:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801918:	e8 29 ec ff ff       	call   800546 <sys_getenvid>
  80191d:	83 ec 0c             	sub    $0xc,%esp
  801920:	ff 75 0c             	pushl  0xc(%ebp)
  801923:	ff 75 08             	pushl  0x8(%ebp)
  801926:	56                   	push   %esi
  801927:	50                   	push   %eax
  801928:	68 64 24 80 00       	push   $0x802464
  80192d:	e8 b1 00 00 00       	call   8019e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801932:	83 c4 18             	add    $0x18,%esp
  801935:	53                   	push   %ebx
  801936:	ff 75 10             	pushl  0x10(%ebp)
  801939:	e8 54 00 00 00       	call   801992 <vcprintf>
	cprintf("\n");
  80193e:	c7 04 24 50 24 80 00 	movl   $0x802450,(%esp)
  801945:	e8 99 00 00 00       	call   8019e3 <cprintf>
  80194a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80194d:	cc                   	int3   
  80194e:	eb fd                	jmp    80194d <_panic+0x43>

00801950 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	53                   	push   %ebx
  801954:	83 ec 04             	sub    $0x4,%esp
  801957:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80195a:	8b 13                	mov    (%ebx),%edx
  80195c:	8d 42 01             	lea    0x1(%edx),%eax
  80195f:	89 03                	mov    %eax,(%ebx)
  801961:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801964:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801968:	3d ff 00 00 00       	cmp    $0xff,%eax
  80196d:	75 1a                	jne    801989 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	68 ff 00 00 00       	push   $0xff
  801977:	8d 43 08             	lea    0x8(%ebx),%eax
  80197a:	50                   	push   %eax
  80197b:	e8 48 eb ff ff       	call   8004c8 <sys_cputs>
		b->idx = 0;
  801980:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801986:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801989:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80198d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80199b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019a2:	00 00 00 
	b.cnt = 0;
  8019a5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8019ac:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8019af:	ff 75 0c             	pushl  0xc(%ebp)
  8019b2:	ff 75 08             	pushl  0x8(%ebp)
  8019b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8019bb:	50                   	push   %eax
  8019bc:	68 50 19 80 00       	push   $0x801950
  8019c1:	e8 54 01 00 00       	call   801b1a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8019c6:	83 c4 08             	add    $0x8,%esp
  8019c9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8019cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8019d5:	50                   	push   %eax
  8019d6:	e8 ed ea ff ff       	call   8004c8 <sys_cputs>

	return b.cnt;
}
  8019db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019e9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8019ec:	50                   	push   %eax
  8019ed:	ff 75 08             	pushl  0x8(%ebp)
  8019f0:	e8 9d ff ff ff       	call   801992 <vcprintf>
	va_end(ap);

	return cnt;
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	57                   	push   %edi
  8019fb:	56                   	push   %esi
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 1c             	sub    $0x1c,%esp
  801a00:	89 c7                	mov    %eax,%edi
  801a02:	89 d6                	mov    %edx,%esi
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a0d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a10:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a13:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a18:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801a1b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801a1e:	39 d3                	cmp    %edx,%ebx
  801a20:	72 05                	jb     801a27 <printnum+0x30>
  801a22:	39 45 10             	cmp    %eax,0x10(%ebp)
  801a25:	77 45                	ja     801a6c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	ff 75 18             	pushl  0x18(%ebp)
  801a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a30:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801a33:	53                   	push   %ebx
  801a34:	ff 75 10             	pushl  0x10(%ebp)
  801a37:	83 ec 08             	sub    $0x8,%esp
  801a3a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a40:	ff 75 dc             	pushl  -0x24(%ebp)
  801a43:	ff 75 d8             	pushl  -0x28(%ebp)
  801a46:	e8 25 06 00 00       	call   802070 <__udivdi3>
  801a4b:	83 c4 18             	add    $0x18,%esp
  801a4e:	52                   	push   %edx
  801a4f:	50                   	push   %eax
  801a50:	89 f2                	mov    %esi,%edx
  801a52:	89 f8                	mov    %edi,%eax
  801a54:	e8 9e ff ff ff       	call   8019f7 <printnum>
  801a59:	83 c4 20             	add    $0x20,%esp
  801a5c:	eb 18                	jmp    801a76 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	56                   	push   %esi
  801a62:	ff 75 18             	pushl  0x18(%ebp)
  801a65:	ff d7                	call   *%edi
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	eb 03                	jmp    801a6f <printnum+0x78>
  801a6c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801a6f:	83 eb 01             	sub    $0x1,%ebx
  801a72:	85 db                	test   %ebx,%ebx
  801a74:	7f e8                	jg     801a5e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801a76:	83 ec 08             	sub    $0x8,%esp
  801a79:	56                   	push   %esi
  801a7a:	83 ec 04             	sub    $0x4,%esp
  801a7d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a80:	ff 75 e0             	pushl  -0x20(%ebp)
  801a83:	ff 75 dc             	pushl  -0x24(%ebp)
  801a86:	ff 75 d8             	pushl  -0x28(%ebp)
  801a89:	e8 12 07 00 00       	call   8021a0 <__umoddi3>
  801a8e:	83 c4 14             	add    $0x14,%esp
  801a91:	0f be 80 87 24 80 00 	movsbl 0x802487(%eax),%eax
  801a98:	50                   	push   %eax
  801a99:	ff d7                	call   *%edi
}
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa1:	5b                   	pop    %ebx
  801aa2:	5e                   	pop    %esi
  801aa3:	5f                   	pop    %edi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801aa9:	83 fa 01             	cmp    $0x1,%edx
  801aac:	7e 0e                	jle    801abc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801aae:	8b 10                	mov    (%eax),%edx
  801ab0:	8d 4a 08             	lea    0x8(%edx),%ecx
  801ab3:	89 08                	mov    %ecx,(%eax)
  801ab5:	8b 02                	mov    (%edx),%eax
  801ab7:	8b 52 04             	mov    0x4(%edx),%edx
  801aba:	eb 22                	jmp    801ade <getuint+0x38>
	else if (lflag)
  801abc:	85 d2                	test   %edx,%edx
  801abe:	74 10                	je     801ad0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801ac0:	8b 10                	mov    (%eax),%edx
  801ac2:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ac5:	89 08                	mov    %ecx,(%eax)
  801ac7:	8b 02                	mov    (%edx),%eax
  801ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ace:	eb 0e                	jmp    801ade <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801ad0:	8b 10                	mov    (%eax),%edx
  801ad2:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ad5:	89 08                	mov    %ecx,(%eax)
  801ad7:	8b 02                	mov    (%edx),%eax
  801ad9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801ae6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801aea:	8b 10                	mov    (%eax),%edx
  801aec:	3b 50 04             	cmp    0x4(%eax),%edx
  801aef:	73 0a                	jae    801afb <sprintputch+0x1b>
		*b->buf++ = ch;
  801af1:	8d 4a 01             	lea    0x1(%edx),%ecx
  801af4:	89 08                	mov    %ecx,(%eax)
  801af6:	8b 45 08             	mov    0x8(%ebp),%eax
  801af9:	88 02                	mov    %al,(%edx)
}
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    

00801afd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b03:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b06:	50                   	push   %eax
  801b07:	ff 75 10             	pushl  0x10(%ebp)
  801b0a:	ff 75 0c             	pushl  0xc(%ebp)
  801b0d:	ff 75 08             	pushl  0x8(%ebp)
  801b10:	e8 05 00 00 00       	call   801b1a <vprintfmt>
	va_end(ap);
}
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	57                   	push   %edi
  801b1e:	56                   	push   %esi
  801b1f:	53                   	push   %ebx
  801b20:	83 ec 2c             	sub    $0x2c,%esp
  801b23:	8b 75 08             	mov    0x8(%ebp),%esi
  801b26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b29:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b2c:	eb 12                	jmp    801b40 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	0f 84 89 03 00 00    	je     801ebf <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801b36:	83 ec 08             	sub    $0x8,%esp
  801b39:	53                   	push   %ebx
  801b3a:	50                   	push   %eax
  801b3b:	ff d6                	call   *%esi
  801b3d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801b40:	83 c7 01             	add    $0x1,%edi
  801b43:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801b47:	83 f8 25             	cmp    $0x25,%eax
  801b4a:	75 e2                	jne    801b2e <vprintfmt+0x14>
  801b4c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801b50:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801b57:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801b5e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801b65:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6a:	eb 07                	jmp    801b73 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801b6f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b73:	8d 47 01             	lea    0x1(%edi),%eax
  801b76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b79:	0f b6 07             	movzbl (%edi),%eax
  801b7c:	0f b6 c8             	movzbl %al,%ecx
  801b7f:	83 e8 23             	sub    $0x23,%eax
  801b82:	3c 55                	cmp    $0x55,%al
  801b84:	0f 87 1a 03 00 00    	ja     801ea4 <vprintfmt+0x38a>
  801b8a:	0f b6 c0             	movzbl %al,%eax
  801b8d:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  801b94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801b97:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801b9b:	eb d6                	jmp    801b73 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801ba8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801bab:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801baf:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801bb2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801bb5:	83 fa 09             	cmp    $0x9,%edx
  801bb8:	77 39                	ja     801bf3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801bba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801bbd:	eb e9                	jmp    801ba8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801bbf:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc2:	8d 48 04             	lea    0x4(%eax),%ecx
  801bc5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801bc8:	8b 00                	mov    (%eax),%eax
  801bca:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bcd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801bd0:	eb 27                	jmp    801bf9 <vprintfmt+0xdf>
  801bd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  801bdc:	0f 49 c8             	cmovns %eax,%ecx
  801bdf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801be5:	eb 8c                	jmp    801b73 <vprintfmt+0x59>
  801be7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801bea:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801bf1:	eb 80                	jmp    801b73 <vprintfmt+0x59>
  801bf3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801bf6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801bf9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801bfd:	0f 89 70 ff ff ff    	jns    801b73 <vprintfmt+0x59>
				width = precision, precision = -1;
  801c03:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c06:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c09:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c10:	e9 5e ff ff ff       	jmp    801b73 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c15:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c1b:	e9 53 ff ff ff       	jmp    801b73 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c20:	8b 45 14             	mov    0x14(%ebp),%eax
  801c23:	8d 50 04             	lea    0x4(%eax),%edx
  801c26:	89 55 14             	mov    %edx,0x14(%ebp)
  801c29:	83 ec 08             	sub    $0x8,%esp
  801c2c:	53                   	push   %ebx
  801c2d:	ff 30                	pushl  (%eax)
  801c2f:	ff d6                	call   *%esi
			break;
  801c31:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801c37:	e9 04 ff ff ff       	jmp    801b40 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801c3f:	8d 50 04             	lea    0x4(%eax),%edx
  801c42:	89 55 14             	mov    %edx,0x14(%ebp)
  801c45:	8b 00                	mov    (%eax),%eax
  801c47:	99                   	cltd   
  801c48:	31 d0                	xor    %edx,%eax
  801c4a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c4c:	83 f8 0f             	cmp    $0xf,%eax
  801c4f:	7f 0b                	jg     801c5c <vprintfmt+0x142>
  801c51:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  801c58:	85 d2                	test   %edx,%edx
  801c5a:	75 18                	jne    801c74 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801c5c:	50                   	push   %eax
  801c5d:	68 9f 24 80 00       	push   $0x80249f
  801c62:	53                   	push   %ebx
  801c63:	56                   	push   %esi
  801c64:	e8 94 fe ff ff       	call   801afd <printfmt>
  801c69:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801c6f:	e9 cc fe ff ff       	jmp    801b40 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801c74:	52                   	push   %edx
  801c75:	68 e5 23 80 00       	push   $0x8023e5
  801c7a:	53                   	push   %ebx
  801c7b:	56                   	push   %esi
  801c7c:	e8 7c fe ff ff       	call   801afd <printfmt>
  801c81:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c87:	e9 b4 fe ff ff       	jmp    801b40 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801c8c:	8b 45 14             	mov    0x14(%ebp),%eax
  801c8f:	8d 50 04             	lea    0x4(%eax),%edx
  801c92:	89 55 14             	mov    %edx,0x14(%ebp)
  801c95:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801c97:	85 ff                	test   %edi,%edi
  801c99:	b8 98 24 80 00       	mov    $0x802498,%eax
  801c9e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801ca1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ca5:	0f 8e 94 00 00 00    	jle    801d3f <vprintfmt+0x225>
  801cab:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801caf:	0f 84 98 00 00 00    	je     801d4d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801cb5:	83 ec 08             	sub    $0x8,%esp
  801cb8:	ff 75 d0             	pushl  -0x30(%ebp)
  801cbb:	57                   	push   %edi
  801cbc:	e8 9f e4 ff ff       	call   800160 <strnlen>
  801cc1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801cc4:	29 c1                	sub    %eax,%ecx
  801cc6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801cc9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801ccc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801cd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cd3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801cd6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801cd8:	eb 0f                	jmp    801ce9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	53                   	push   %ebx
  801cde:	ff 75 e0             	pushl  -0x20(%ebp)
  801ce1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ce3:	83 ef 01             	sub    $0x1,%edi
  801ce6:	83 c4 10             	add    $0x10,%esp
  801ce9:	85 ff                	test   %edi,%edi
  801ceb:	7f ed                	jg     801cda <vprintfmt+0x1c0>
  801ced:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801cf0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801cf3:	85 c9                	test   %ecx,%ecx
  801cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfa:	0f 49 c1             	cmovns %ecx,%eax
  801cfd:	29 c1                	sub    %eax,%ecx
  801cff:	89 75 08             	mov    %esi,0x8(%ebp)
  801d02:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d05:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d08:	89 cb                	mov    %ecx,%ebx
  801d0a:	eb 4d                	jmp    801d59 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d0c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d10:	74 1b                	je     801d2d <vprintfmt+0x213>
  801d12:	0f be c0             	movsbl %al,%eax
  801d15:	83 e8 20             	sub    $0x20,%eax
  801d18:	83 f8 5e             	cmp    $0x5e,%eax
  801d1b:	76 10                	jbe    801d2d <vprintfmt+0x213>
					putch('?', putdat);
  801d1d:	83 ec 08             	sub    $0x8,%esp
  801d20:	ff 75 0c             	pushl  0xc(%ebp)
  801d23:	6a 3f                	push   $0x3f
  801d25:	ff 55 08             	call   *0x8(%ebp)
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	eb 0d                	jmp    801d3a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801d2d:	83 ec 08             	sub    $0x8,%esp
  801d30:	ff 75 0c             	pushl  0xc(%ebp)
  801d33:	52                   	push   %edx
  801d34:	ff 55 08             	call   *0x8(%ebp)
  801d37:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d3a:	83 eb 01             	sub    $0x1,%ebx
  801d3d:	eb 1a                	jmp    801d59 <vprintfmt+0x23f>
  801d3f:	89 75 08             	mov    %esi,0x8(%ebp)
  801d42:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d45:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d48:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d4b:	eb 0c                	jmp    801d59 <vprintfmt+0x23f>
  801d4d:	89 75 08             	mov    %esi,0x8(%ebp)
  801d50:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d53:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d56:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d59:	83 c7 01             	add    $0x1,%edi
  801d5c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d60:	0f be d0             	movsbl %al,%edx
  801d63:	85 d2                	test   %edx,%edx
  801d65:	74 23                	je     801d8a <vprintfmt+0x270>
  801d67:	85 f6                	test   %esi,%esi
  801d69:	78 a1                	js     801d0c <vprintfmt+0x1f2>
  801d6b:	83 ee 01             	sub    $0x1,%esi
  801d6e:	79 9c                	jns    801d0c <vprintfmt+0x1f2>
  801d70:	89 df                	mov    %ebx,%edi
  801d72:	8b 75 08             	mov    0x8(%ebp),%esi
  801d75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d78:	eb 18                	jmp    801d92 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801d7a:	83 ec 08             	sub    $0x8,%esp
  801d7d:	53                   	push   %ebx
  801d7e:	6a 20                	push   $0x20
  801d80:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801d82:	83 ef 01             	sub    $0x1,%edi
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	eb 08                	jmp    801d92 <vprintfmt+0x278>
  801d8a:	89 df                	mov    %ebx,%edi
  801d8c:	8b 75 08             	mov    0x8(%ebp),%esi
  801d8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d92:	85 ff                	test   %edi,%edi
  801d94:	7f e4                	jg     801d7a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d99:	e9 a2 fd ff ff       	jmp    801b40 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801d9e:	83 fa 01             	cmp    $0x1,%edx
  801da1:	7e 16                	jle    801db9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801da3:	8b 45 14             	mov    0x14(%ebp),%eax
  801da6:	8d 50 08             	lea    0x8(%eax),%edx
  801da9:	89 55 14             	mov    %edx,0x14(%ebp)
  801dac:	8b 50 04             	mov    0x4(%eax),%edx
  801daf:	8b 00                	mov    (%eax),%eax
  801db1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801db4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801db7:	eb 32                	jmp    801deb <vprintfmt+0x2d1>
	else if (lflag)
  801db9:	85 d2                	test   %edx,%edx
  801dbb:	74 18                	je     801dd5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801dbd:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc0:	8d 50 04             	lea    0x4(%eax),%edx
  801dc3:	89 55 14             	mov    %edx,0x14(%ebp)
  801dc6:	8b 00                	mov    (%eax),%eax
  801dc8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dcb:	89 c1                	mov    %eax,%ecx
  801dcd:	c1 f9 1f             	sar    $0x1f,%ecx
  801dd0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801dd3:	eb 16                	jmp    801deb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801dd5:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd8:	8d 50 04             	lea    0x4(%eax),%edx
  801ddb:	89 55 14             	mov    %edx,0x14(%ebp)
  801dde:	8b 00                	mov    (%eax),%eax
  801de0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801de3:	89 c1                	mov    %eax,%ecx
  801de5:	c1 f9 1f             	sar    $0x1f,%ecx
  801de8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801deb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801dee:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801df1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801df6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801dfa:	79 74                	jns    801e70 <vprintfmt+0x356>
				putch('-', putdat);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	53                   	push   %ebx
  801e00:	6a 2d                	push   $0x2d
  801e02:	ff d6                	call   *%esi
				num = -(long long) num;
  801e04:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e07:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e0a:	f7 d8                	neg    %eax
  801e0c:	83 d2 00             	adc    $0x0,%edx
  801e0f:	f7 da                	neg    %edx
  801e11:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e14:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801e19:	eb 55                	jmp    801e70 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e1b:	8d 45 14             	lea    0x14(%ebp),%eax
  801e1e:	e8 83 fc ff ff       	call   801aa6 <getuint>
			base = 10;
  801e23:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801e28:	eb 46                	jmp    801e70 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801e2a:	8d 45 14             	lea    0x14(%ebp),%eax
  801e2d:	e8 74 fc ff ff       	call   801aa6 <getuint>
		        base = 8;
  801e32:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801e37:	eb 37                	jmp    801e70 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801e39:	83 ec 08             	sub    $0x8,%esp
  801e3c:	53                   	push   %ebx
  801e3d:	6a 30                	push   $0x30
  801e3f:	ff d6                	call   *%esi
			putch('x', putdat);
  801e41:	83 c4 08             	add    $0x8,%esp
  801e44:	53                   	push   %ebx
  801e45:	6a 78                	push   $0x78
  801e47:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801e49:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4c:	8d 50 04             	lea    0x4(%eax),%edx
  801e4f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801e52:	8b 00                	mov    (%eax),%eax
  801e54:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801e59:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801e5c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801e61:	eb 0d                	jmp    801e70 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801e63:	8d 45 14             	lea    0x14(%ebp),%eax
  801e66:	e8 3b fc ff ff       	call   801aa6 <getuint>
			base = 16;
  801e6b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801e70:	83 ec 0c             	sub    $0xc,%esp
  801e73:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801e77:	57                   	push   %edi
  801e78:	ff 75 e0             	pushl  -0x20(%ebp)
  801e7b:	51                   	push   %ecx
  801e7c:	52                   	push   %edx
  801e7d:	50                   	push   %eax
  801e7e:	89 da                	mov    %ebx,%edx
  801e80:	89 f0                	mov    %esi,%eax
  801e82:	e8 70 fb ff ff       	call   8019f7 <printnum>
			break;
  801e87:	83 c4 20             	add    $0x20,%esp
  801e8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e8d:	e9 ae fc ff ff       	jmp    801b40 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801e92:	83 ec 08             	sub    $0x8,%esp
  801e95:	53                   	push   %ebx
  801e96:	51                   	push   %ecx
  801e97:	ff d6                	call   *%esi
			break;
  801e99:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e9c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801e9f:	e9 9c fc ff ff       	jmp    801b40 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ea4:	83 ec 08             	sub    $0x8,%esp
  801ea7:	53                   	push   %ebx
  801ea8:	6a 25                	push   $0x25
  801eaa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	eb 03                	jmp    801eb4 <vprintfmt+0x39a>
  801eb1:	83 ef 01             	sub    $0x1,%edi
  801eb4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801eb8:	75 f7                	jne    801eb1 <vprintfmt+0x397>
  801eba:	e9 81 fc ff ff       	jmp    801b40 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ebf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec2:	5b                   	pop    %ebx
  801ec3:	5e                   	pop    %esi
  801ec4:	5f                   	pop    %edi
  801ec5:	5d                   	pop    %ebp
  801ec6:	c3                   	ret    

00801ec7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 18             	sub    $0x18,%esp
  801ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ed3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ed6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801eda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801edd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	74 26                	je     801f0e <vsnprintf+0x47>
  801ee8:	85 d2                	test   %edx,%edx
  801eea:	7e 22                	jle    801f0e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801eec:	ff 75 14             	pushl  0x14(%ebp)
  801eef:	ff 75 10             	pushl  0x10(%ebp)
  801ef2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ef5:	50                   	push   %eax
  801ef6:	68 e0 1a 80 00       	push   $0x801ae0
  801efb:	e8 1a fc ff ff       	call   801b1a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f03:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	eb 05                	jmp    801f13 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f1b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f1e:	50                   	push   %eax
  801f1f:	ff 75 10             	pushl  0x10(%ebp)
  801f22:	ff 75 0c             	pushl  0xc(%ebp)
  801f25:	ff 75 08             	pushl  0x8(%ebp)
  801f28:	e8 9a ff ff ff       	call   801ec7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    

00801f2f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	8b 75 08             	mov    0x8(%ebp),%esi
  801f37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	74 0e                	je     801f4f <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801f41:	83 ec 0c             	sub    $0xc,%esp
  801f44:	50                   	push   %eax
  801f45:	e8 ea e7 ff ff       	call   800734 <sys_ipc_recv>
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	eb 10                	jmp    801f5f <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	68 00 00 00 f0       	push   $0xf0000000
  801f57:	e8 d8 e7 ff ff       	call   800734 <sys_ipc_recv>
  801f5c:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	74 0e                	je     801f71 <ipc_recv+0x42>
    	*from_env_store = 0;
  801f63:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801f69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801f6f:	eb 24                	jmp    801f95 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801f71:	85 f6                	test   %esi,%esi
  801f73:	74 0a                	je     801f7f <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801f75:	a1 08 40 80 00       	mov    0x804008,%eax
  801f7a:	8b 40 74             	mov    0x74(%eax),%eax
  801f7d:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801f7f:	85 db                	test   %ebx,%ebx
  801f81:	74 0a                	je     801f8d <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801f83:	a1 08 40 80 00       	mov    0x804008,%eax
  801f88:	8b 40 78             	mov    0x78(%eax),%eax
  801f8b:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801f8d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f92:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    

00801f9c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	57                   	push   %edi
  801fa0:	56                   	push   %esi
  801fa1:	53                   	push   %ebx
  801fa2:	83 ec 0c             	sub    $0xc,%esp
  801fa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801fae:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fb5:	0f 44 d8             	cmove  %eax,%ebx
  801fb8:	eb 1c                	jmp    801fd6 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801fba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fbd:	74 12                	je     801fd1 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801fbf:	50                   	push   %eax
  801fc0:	68 80 27 80 00       	push   $0x802780
  801fc5:	6a 4b                	push   $0x4b
  801fc7:	68 98 27 80 00       	push   $0x802798
  801fcc:	e8 39 f9 ff ff       	call   80190a <_panic>
        }	
        sys_yield();
  801fd1:	e8 8f e5 ff ff       	call   800565 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fd6:	ff 75 14             	pushl  0x14(%ebp)
  801fd9:	53                   	push   %ebx
  801fda:	56                   	push   %esi
  801fdb:	57                   	push   %edi
  801fdc:	e8 30 e7 ff ff       	call   800711 <sys_ipc_try_send>
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	75 d2                	jne    801fba <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801feb:	5b                   	pop    %ebx
  801fec:	5e                   	pop    %esi
  801fed:	5f                   	pop    %edi
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    

00801ff0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ff6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ffb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ffe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802004:	8b 52 50             	mov    0x50(%edx),%edx
  802007:	39 ca                	cmp    %ecx,%edx
  802009:	75 0d                	jne    802018 <ipc_find_env+0x28>
			return envs[i].env_id;
  80200b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802013:	8b 40 48             	mov    0x48(%eax),%eax
  802016:	eb 0f                	jmp    802027 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802018:	83 c0 01             	add    $0x1,%eax
  80201b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802020:	75 d9                	jne    801ffb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802022:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202f:	89 d0                	mov    %edx,%eax
  802031:	c1 e8 16             	shr    $0x16,%eax
  802034:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802040:	f6 c1 01             	test   $0x1,%cl
  802043:	74 1d                	je     802062 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802045:	c1 ea 0c             	shr    $0xc,%edx
  802048:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204f:	f6 c2 01             	test   $0x1,%dl
  802052:	74 0e                	je     802062 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802054:	c1 ea 0c             	shr    $0xc,%edx
  802057:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80205e:	ef 
  80205f:	0f b7 c0             	movzwl %ax,%eax
}
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
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
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
