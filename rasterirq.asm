; irqscanline.asm - Example stable scanline IRQ handler for C64 / VIC-II video
; 
; Copyright (c) 2024 by David R. Van Wagner
; MIT LICENSE
; github.com/davervw/rasterirq
; davevw.com
;

scanline1_interrupt = 120
scanline1_wait = 149
scanline2_interrupt = 0

*=$c000
  jmp install_irq_scanline
  jmp release_irq_scanline
  brk

install_irq_scanline:  
  sei ; disallow IRQ
  lda #scanline1_interrupt
  sta scanline_set
  lda #$00
  sta $d012
  lda $d011
  and #$7f
  sta $d011
  lda $0314
  ldx $0315
  cpx #>irq_scanline
  beq + ; branch if already set
  sta jmp_orig_irq+1
  stx jmp_orig_irq+2
  lda #<irq_scanline
  ldx #>irq_scanline
  sta $0314
  stx $0315
+ lda $d01a
  ora #$01
  sta $d01a
  cli ; re-enable IRQ
  rts

release_irq_scanline:
  sei ; disallow IRQ
  lda jmp_orig_irq+1
  ldx jmp_orig_irq+2
  sta $0314
  stx $0315
  lda $d01a
  and #$fe ; disable raster interrupt
  sta $d01a
  cli ; re-enable IRQ
  rts

irq_scanline:
  bit $d019 ; vic-ii irq status
  bmi + ; branch if not a vic-ii irq
jmp_orig_irq:
  jmp $ea31 ; resume IRQ (note: self modifying code, see init_irq_scanline)
+ lda $d019
  and #$01
  beq jmp_orig_irq ; branch if not a scanline irq

  lda scanline_set
  beq + ; branch if zero

  ; wait for actual scanline
- lda $d012 ; vic-ii scanline
  cmp #scanline1_wait
  bcc -

  ; slight delay
  ldx #10
- dex
  bne -

  ; change background color
  inc $d021

  ; set next scanline interrupt
  lda #scanline2_interrupt
  sta $d012
  sta scanline_set
  lda $d011
  and #$7f
  sta $d011 ; clear 8th bit

  ; release interrupt
  lda #$01
  sta $d019
  jmp ++

  ; zero scanline
+ dec $d021

  ; set next scanline interrupt
  lda #scanline1_interrupt
  sta $d012
  sta scanline_set
  lda $d011
  and #$7f
  sta $d011 ; clear 8th bit

  ; release interrupt
  lda #$01
  sta $d019

; return from ROM IRQ handler
++pla
  tay
  pla
  tax
  pla
  rti

scanline_set: !byte 0
