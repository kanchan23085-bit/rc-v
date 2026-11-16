# P49 Performance counters - dossier

## U1 Digital logic

My Digital circuit has two 8-bit counters, CYCLE and INSTRET. I used the
incrementer part for my truth table. For one bit, with input bit `a` and
carry-in `c`, the next bit is `a XOR c` and carry-out is `a AND c`.

Truth table for one bit:
| a | c | next | carry-out |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

Simplified: `next = a ^ c`, `carry_out = a & c`. The first bit uses `c = 1`
because we add 1. I needed XOR gates, AND gates and D flip-flops. One
flip-flop stores one bit, so 8 flip-flops per counter, 16 in total. CLEAR
and RST force all flip-flops to 0 through the reset / mux logic.

## U2 Digital components

The circuit uses:
- 16 D flip-flops: 8 for CYCLE, 8 for INSTRET.
- 8-bit adders / incrementers: made from XOR + AND gates, one per bit,
  chained by carry. They do `count + 1`.
- Multiplexers: select between hold (same value), increment (+1) and clear (0).
  CYCLE mux selects increment on every clock, clear on CLEAR/RST.
  INSTRET mux selects increment only when COMMIT = 1, otherwise hold.
- No RAM/ROM, no decoder. Only gates, muxes and flip-flops, as allowed.

Connection: `clk` goes to all flip-flops. `rst/clear` goes to the mux
select / reset. `commit` goes only to the INSTRET mux. Outputs `cycle` and
`instret` come directly from the flip-flop outputs.

## U3 Data representation

Three test vectors from my block (8-bit version):

1. Reset: `cycle = 00000000 = 0x00 = 0`. Both counters 0.
2. After 5 clocks, no commit: `cycle = 00000101 = 0x05 = 5`,
   `instret = 00000000 = 0x00 = 0`. Difference shows stalls.
3. After 300 clocks in the 32-bit Verilog version:
   `cycle = 301 = 0x0000012D`, `instret = 300 = 0x0000012C`,
   `extra = cycle - instret = 1`.

Overflow: in the 8-bit Digital version, after 255 comes 0 again
(255 + 1 wraps). That is why the real Verilog uses 32-bit counters, so
overflow does not happen in normal programs. Sign extension is not an
issue here because counters are unsigned, but if we treated them as
signed, values above 127 in 8-bit would look negative.

## U4 Computer organisation

My block works in the execute / memory stage of the instruction cycle.
CYCLE increases on every clock, so it counts fetch + decode + execute +
memory + write-back time together. INSTRET increases only in write-back,
when an instruction is really committed.

Instructions that need it: all of them, because every instruction is
counted. But the block is most useful for loads/stores (memory stage) and
branches, because they show stalls. It does not fetch or decode itself.

## U5 Processors

A CISC processor would do the same job with a complex microcoded
instruction, like one `RDTSC`-style instruction that reads both counters.
A stack machine has no general registers, so it would push CYCLE and
INSTRET on the stack with two push operations instead of reading memory-
mapped registers. A GPU would have one counter per core / warp and would
need to add them together, because many threads run at the same time.
Our RISC-V way is simplest: two plain counters, read like I/O registers.

## U6 Memory and I/O

My block does not do a memory access by itself, it is not RAM and it does
not move data like DMA does. It is a memory-mapped I/O block.

How it works: the CPU does a normal load, for example `lw x5, 0(x6)` where
`x6` holds the address of CYCLE. The neighbouring blocks do the real work:
the address decoder sees that the address is for P49, the bus / memory
controller routes the read to my block instead of RAM, and my block puts
the current CYCLE value on the data bus. The CPU then writes that value
into `x5` in write-back.

For a write / clear, the CPU does a store to the CLEAR address. The bus
carries the address + data to my block, and my block clears both counters
to 0. So data reaches my block through the bus and address decoder, and
leaves my block through the data bus back to the CPU.


## E1 Instruction trace: BGE

Instruction: `BGE x1, x2, label` - branch if x1 >= x2 (signed).

Trace through RC-V:
1. Fetch: PC goes to instruction memory, instruction word is fetched.
   Example: `x1 = 10, x2 = 5, PC = 0x100`.
2. Decode: opcode = branch (1100011), funct3 = 101 for BGE, rs1 = x1,
   rs2 = x2, immediate = branch offset.
3. Register read: register file gives `rs1 = 10`, `rs2 = 5`.
4. Execute: ALU / branch unit does `rs1 - rs2 = 5`. Sign flag = 0,
   so `rs1 >= rs2` is true. Branch taken = 1.
5. Memory: no memory access for BGE.
6. Write-back: no register is written. PC is updated to `PC + offset`
   because branch was taken. If not taken, PC would be `PC + 4`.
7. Counters: CYCLE +1, INSTRET +1 because the branch committed.

## E2 Neighbour review

Review partners: P66 (Reset controller) and P50 (Multiplier shift and add).

My review comments:
- P66: The reset design is clean, but I suggested checking that reset
  clears all registers on the same clock edge, and that reset does not
  fight with a normal write in the same cycle. Otherwise the first
  instruction after reset could read a stale value.
- P50: The shift-and-add idea is correct. I suggested checking the
  32-bit overflow case and making sure the loop runs exactly 32 times,
  and that the sign handling for negative numbers is tested.

Links to my review comments:
- P66 PR review: [paste your P66 PR review link here]
- P50 PR review: [paste your P50 PR review link here]

## E3 Where my block sits

My block is at the datapath / I/O layer. It is fed by `clk`, `rst`,
`commit` and `clear` from the control / CPU core. Its output (CYCLE and
INSTRET counts) is used by the program through memory-mapped I/O reads,
and by the programmer to calculate CPI = CYCLE / INSTRET.

## E4 Syllabus map

Tick every syllabus topic your work touched (main units: Unit 4, Unit 5).

- [x] Logic gates, Boolean algebra, K-maps
- [x] Combinational circuits (adders, decoders, encoders, multiplexers)
- [x] Flip-flops, registers, counters
- [ ] Memory (RAM, ROM)
- [x] Number systems, complements, signed arithmetic
- [x] Bus organisation, instruction codes and formats
- [x] Instruction cycle, hardwired vs microprogrammed control
- [ ] Interrupts and the interrupt cycle
- [ ] Pipelining
- [x] Register organisation, stack, addressing modes
- [x] RISC vs CISC, multicore, GPU
- [ ] Memory hierarchy, cache
- [x] I/O interface, programmed / interrupt-driven I/O, DMA
