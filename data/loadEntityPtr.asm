.text:00007FF855B7E1B0                 mov     rax, rsp
.text:00007FF855B7E1B3                 mov     [rax+8], entityPtr
.text:00007FF855B7E1B7                 mov     [rax+20h], r9
.text:00007FF855B7E1BB                 mov     [rax+18h], r8w
.text:00007FF855B7E1C0                 push    rbp
.text:00007FF855B7E1C1                 push    rsi
.text:00007FF855B7E1C2                 push    rdi
.text:00007FF855B7E1C3                 push    r12
.text:00007FF855B7E1C5                 push    r13
.text:00007FF855B7E1C7                 push    r14
.text:00007FF855B7E1C9                 push    r15
.text:00007FF855B7E1CB                 sub     rsp, 80h
.text:00007FF855B7E1D2                 mov     r12, cs:qword_7FF856A482C8
.text:00007FF855B7E1D9                 movzx   r13d, dx
.text:00007FF855B7E1DD                 mov     r11, cs:qword_7FF8579CD980
.text:00007FF855B7E1E4                 movaps  xmmword ptr [rax-48h], xmm6
.text:00007FF855B7E1E8                 movaps  xmmword ptr [rax-58h], xmm7
.text:00007FF855B7E1EC                 movaps  xmmword ptr [rax-68h], xmm8
.text:00007FF855B7E1F1                 movaps  xmmword ptr [rax-78h], xmm9
.text:00007FF855B7E1F6                 movzx   r10d, cx
.text:00007FF855B7E1FA                 mov     r15d, ecx
.text:00007FF855B7E1FD                 lea     rax, [r10+r10*2]
.text:00007FF855B7E201                 lea     rcx, ds:0[rax*4]
.text:00007FF855B7E209                 movsxd  rax, dword ptr [r12+34h]
.text:00007FF855B7E20E                 add     rax, rcx
.text:00007FF855B7E211                 mov     [rsp+0B8h+var_88], rcx
.text:00007FF855B7E216                 movsxd  rsi, dword ptr [rax+r12+8]
.text:00007FF855B7E21B                 cmp     esi, 0FFFFFFFFh
.text:00007FF855B7E21E                 jnz     short loc_7FF855B7E224
.text:00007FF855B7E220                 xor     ebx, ebx
.text:00007FF855B7E222                 jmp     short loc_7FF855B7E22B
.text:00007FF855B7E224 ; ---------------------------------------------------------------------------
.text:00007FF855B7E224
.text:00007FF855B7E224 loc_7FF855B7E224:                       ; CODE XREF: damageEntity+6E↑j
.text:00007FF855B7E224                 lea     entityPtr, [r11+34h]
.text:00007FF855B7E228                 add     entityPtr, rsi