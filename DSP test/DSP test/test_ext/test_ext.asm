/*	

	Acest program initializeaza placa de dezvoltare EZ_LITE 2181
	 - procesorul ADSP2181 ( mod de lucru)
	 - codecul AD1847
	- testeaza extensia IO pentru EZ-KIT_LITE
	- porul de intrare ( citire SW) - la adresa 0x1FF
	- portul de iesire ( afisare ) - la adresa 0xFF
	- testeaza PF ports
*/


#include    "def2181.h"    


#define PORT_OUT 0xFF
#define PORT_IN 0x1FF


.SECTION/DM		buf_var1;
.var    rx_buf[3];      /* Status + L data + R data */

.SECTION/DM		buf_var2;
.var    	tx_buf[3] = 0xc000, 0x0000, 0x0000;      /* Cmd + L data + R data    */

.SECTION/DM		buf_var3;
.var    init_cmds[13] = 0xc002,     /*
                        				Left input control reg
                        				b7-6: 0=left line 1
                              			1=left aux 1
                              			2=left line 2
                              			3=left line 1 post-mixed loopback
                        			b5-4: res
                        			b3-0: left input gain x 1.5 dB
                    				*/
        				0xc102,     /*
                        				Right input control reg
                        				b7-6: 0=right line 1
                              				1=right aux 1
                              				2=right line 2
                              				3=right line 1 post-mixed loopback
                        				b5-4: res
                        				b3-0: right input gain x 1.5 dB
                    				*/
        				0xc288,     /*
                        				left aux 1 control reg
                        				b7  : 1=left aux 1 mute
                        				b6-5: res
                        				b4-0: gain/atten x 1.5, 08= 0dB, 00= 12dB
                    				*/
        				0xc388,     /*
                        				right aux 1 control reg
                        				b7  : 1=right aux 1 mute
                        				b6-5: res
                        				b4-0: gain/atten x 1.5, 08= 0dB, 00= 12dB
                    				*/
        				0xc488,     /*
                        				left aux 2 control reg
                        				b7  : 1=left aux 2 mute
                        				b6-5: res
                        				b4-0: gain/atten x 1.5, 08= 0dB, 00= 12dB
                    				*/
        				0xc588,     /*
                        				right aux 2 control reg
                        				b7  : 1=right aux 2 mute
                        				b6-5: res
                        				b4-0: gain/atten x 1.5, 08= 0dB, 00= 12dB
                    				*/
        				0xc680,     /*
                        				left DAC control reg
                        				b7  : 1=left DAC mute
                        				b6  : res
                        				b5-0: attenuation x 1.5 dB
                    				*/
        				0xc780,     /*
                        				right DAC control reg
                        				b7  : 1=right DAC mute
                        				b6  : res
                        				b5-0: attenuation x 1.5 dB
                    				*/
        				0xc85c,     /*
                        				data format register
                        				b7  : res
                        				b5-6: 0=8-bit unsigned linear PCM
                              				1=8-bit u-law companded
                              				2=16-bit signed linear PCM
                              				3=8-bit A-law companded
                        				b4  : 0=mono, 1=stereo
                        				b0-3: 0=  8.
                              				1=  5.5125
                              				2= 16.
                              				3= 11.025
                              				4= 27.42857
                              				5= 18.9
                              				6= 32.
                              				7= 22.05
                              				8=   .
                              				9= 37.8
                              				a=   .
                              				b= 44.1
                              				c= 48.
                              				d= 33.075
                              				e=  9.6
                              				f=  6.615
                       				(b0) : 0=XTAL1 24.576 MHz; 1=XTAL2 16.9344 MHz
                    				*/
        				0xc909,     /*
                        				interface configuration reg
                        				b7-4: res
                        				b3  : 1=autocalibrate
                        				b2-1: res
                        				b0  : 1=playback enabled
                    				*/
        				0xca00,     /*
                        				pin control reg
                        				b7  : logic state of pin XCTL1
                       					b6  : logic state of pin XCTL0
                        				b5  : master - 1=tri-state CLKOUT
                              				slave  - x=tri-state CLKOUT
                        				b4-0: res
                    				*/
        				0xcc40,     /*
	THIS PROGRAM USES 16 SLOTS PER FRAME
                        				miscellaneous information reg
                        				b7  : 1=16 slots per frame, 0=32 slots per frame
                        				b6  : 1=2-wire system, 0=1-wire system
                        				b5-0: res
                    				*/
        				0xcd00;     /*
                        				digital mix control reg
                        				b7-2: attenuation x 1.5 dB
                        				b1  : res
                        				b0  : 1=digital mix enabled
                    				*/

.SECTION/DM		data1;
.var        stat_flag;

.var 	PF_input;
.var 	PF_output;


.SECTION/PM		pm_da;


/*** Interrupt Vector Table ***/
.SECTION/PM     interrupts;
		jump start;  rti; rti; rti;     /*00: reset */
        
		//rti;         rti; rti; rti;     /*04: IRQ2 */
        
		jump input_samples;         rti; rti; rti;
		
        rti;         rti; rti; rti;     /*08: IRQL1 */
        rti;         rti; rti; rti;     /*0c: IRQL0 */
        ar = dm(stat_flag);             /*10: SPORT0 tx */
        ar = pass ar;
        if eq rti;
        jump next_cmd;
        jump input_samples;             /*14: SPORT0 rx */
                     rti; rti; rti;
        rti;         rti; rti; rti;     /*18: IRQE */
        rti;         rti; rti; rti;     /*1c: BDMA */
        rti;         rti; rti; rti;     /*20: SPORT1 tx or IRQ1 */
        rti;         rti; rti; rti;     /*24: SPORT1 rx or IRQ0 */
        nop;         rti; rti; rti;     /*28: timer */
        rti;         rti; rti; rti;     /*2c: power down */


.SECTION/PM		seg_code;
/*******************************************************************************
 *
 *  ADSP 2181 intialization
 *
 *******************************************************************************/
start:
        /*   shut down sport 0 */
        ax0 = b#0000100000000000;   
		dm (Sys_Ctrl_Reg) = ax0;
		ena timer;

        i5 = rx_buf;
        l5 = LENGTH(rx_buf);
        i6 = tx_buf;
        l6 = LENGTH(tx_buf);
        i3 = init_cmds;
        l3 = LENGTH(init_cmds);

        m1 = 1;
        m5 = 1;


/*================== S E R I A L   P O R T   #0   S T U F F ==================*/
        ax0 = b#0000110011010111;   dm (Sport0_Autobuf_Ctrl) = ax0;
            /*  |||!|-/!/|-/|/|+- receive autobuffering 0=off, 1=on
                |||!|  ! |  | +-- transmit autobuffering 0=off, 1=on
                |||!|  ! |  +---- | receive m?
                |||!|  ! |        | m5
                |||!|  ! +------- ! receive i?
                |||!|  !          ! i5
                |||!|  !          !
                |||!|  +========= | transmit m?
                |||!|             | m5
                |||!+------------ ! transmit i?
                |||!              ! i6
                |||!              !
                |||+============= | BIASRND MAC biased rounding control bit
                ||+-------------- 0
                |+--------------- | CLKODIS CLKOUT disable control bit
                +---------------- 0
            */

        ax0 = 0;    dm (Sport0_Rfsdiv) = ax0;
            /*   RFSDIV = SCLK Hz/RFS Hz - 1 */
        ax0 = 0;    dm (Sport0_Sclkdiv) = ax0;
            /*   SCLK = CLKOUT / (2  (SCLKDIV + 1) */
        ax0 = b#1000011000001111;   dm (Sport0_Ctrl_Reg) = ax0;
            /*  multichannel
                ||+--/|!||+/+---/ | number of bit per word - 1
                |||   |!|||       | = 15
                |||   |!|||       |
                |||   |!|||       |
                |||   |!||+====== ! 0=right just, 0-fill; 1=right just, signed
                |||   |!||        ! 2=compand u-law; 3=compand A-law
                |||   |!|+------- receive framing logic 0=pos, 1=neg
                |||   |!+-------- transmit data valid logic 0=pos, 1=neg
                |||   |+========= RFS 0=ext, 1=int
                |||   +---------- multichannel length 0=24, 1=32 words
                ||+-------------- | frame sync to occur this number of clock
                ||                | cycle before first bit
                ||                |
                ||                |
                |+--------------- ISCLK 0=ext, 1=int
                +---------------- multichannel 0=disable, 1=enable
            */
            /*  non-multichannel
                |||!|||!|||!+---/ | number of bit per word - 1
                |||!|||!|||!      | = 15
                |||!|||!|||!      |
                |||!|||!|||!      |
                |||!|||!|||+===== ! 0=right just, 0-fill; 1=right just, signed
                |||!|||!||+------ ! 2=compand u-law; 3=compand A-law
                |||!|||!|+------- receive framing logic 0=pos, 1=neg
                |||!|||!+-------- transmit framing logic 0=pos, 1=neg
                |||!|||+========= RFS 0=ext, 1=int
                |||!||+---------- TFS 0=ext, 1=int
                |||!|+----------- TFS width 0=FS before data, 1=FS in sync
                |||!+------------ TFS 0=no, 1=required
                |||+============= RFS width 0=FS before data, 1=FS in sync
                ||+-------------- RFS 0=no, 1=required
                |+--------------- ISCLK 0=ext, 1=int
                +---------------- multichannel 0=disable, 1=enable
            */


        ax0 = b#0000000000000111;   dm (Sport0_Tx_Words0) = ax0;
            /*  ^15          00^   transmit word enables: channel # == bit # */
        ax0 = b#0000000000000111;   dm (Sport0_Tx_Words1) = ax0;
            /*  ^31          16^   transmit word enables: channel # == bit # */
        ax0 = b#0000000000000111;   dm (Sport0_Rx_Words0) = ax0;
            /*  ^15          00^   receive word enables: channel # == bit # */
        ax0 = b#0000000000000111;   dm (Sport0_Rx_Words1) = ax0;
            /*  ^31          16^   receive word enables: channel # == bit # */


/*============== S Y S T E M   A N D   M E M O R Y   S T U F F ==============*/
        ax0 = b#0001100000000000;   dm (Sys_Ctrl_Reg) = ax0;
            /*  +-/!||+-----/+-/- | program memory wait states
                |  !|||           | 0
                |  !|||           |
                |  !||+---------- 0
                |  !||            0
                |  !||            0
                |  !||            0
                |  !||            0
                |  !||            0
                |  !||            0
                |  !|+----------- SPORT1 1=serial port, 0=FI, FO, IRQ0, IRQ1,..
                |  !+------------ SPORT1 1=enabled, 0=disabled
                |  +============= SPORT0 1=enabled, 0=disabled
                +---------------- 0
                                  0
                                  0
            */



        ifc = b#00000011111110;         /* clear pending interrupt */
        nop;


        icntl = b#00010;
            /*    ||||+- | IRQ0: 0=level, 1=edge
                  |||+-- | IRQ1: 0=level, 1=edge
                  ||+--- | IRQ2: 0=level, 1=edge
                  |+---- 0
                  |----- | IRQ nesting: 0=disabled, 1=enabled
            */


        mstat = b#1100000;
            /*    ||||||+- | Data register bank select
                  |||||+-- | FFT bit reverse mode (DAG1)
                  ||||+--- | ALU overflow latch mode, 1=sticky
                  |||+---- | AR saturation mode, 1=saturate, 0=wrap
                  ||+----- | MAC result, 0=fractional, 1=integer
                  |+------ | timer enable
                  +------- | GO MODE
            */


//

jump skip;

//

/*******************************************************************************
 *
 *  ADSP 1847 Codec intialization
 *
 *******************************************************************************/

        /*   clear flag */
        ax0 = 1;
        dm(stat_flag) = ax0;

        /*   enable transmit interrupt */
        ena ints;
        imask = b#0001000001;
            /*    |||||||||+ | timer
                  ||||||||+- | SPORT1 rec or IRQ0
                  |||||||+-- | SPORT1 trx or IRQ1
                  ||||||+--- | BDMA
                  |||||+---- | IRQE
                  ||||+----- | SPORT0 rec
                  |||+------ | SPORT0 trx
                  ||+------- | IRQL0
                  |+-------- | IRQL1
                  +--------- | IRQ2
            */


        ax0 = dm (i6, m5);          /* start interrupt */
        tx0 = ax0;

check_init:
        ax0 = dm (stat_flag);       /* wait for entire init */
        af = pass ax0;              /* buffer to be sent to */
        if ne jump check_init;      /* the codec            */

        ay0 = 2;
check_aci1:
        ax0 = dm (rx_buf);          /* once initialized, wait for codec */
        ar = ax0 and ay0;           /* to come out of autocalibration */
        if eq jump check_aci1;      /* wait for bit set */

check_aci2:
        ax0 = dm (rx_buf);          /* wait for bit clear */
        ar = ax0 and ay0;
        if ne jump check_aci2;
        idle;

        ay0 = 0xbf3f;               /* unmute left DAC */
        ax0 = dm (init_cmds + 6);
        ar = ax0 AND ay0;
        dm (tx_buf) = ar;
        idle;

        ax0 = dm (init_cmds + 7);   /* unmute right DAC */
        ar = ax0 AND ay0;
        dm (tx_buf) = ar;
        idle;


        ifc = b#00000011111110;     /* clear any pending interrupt */
        nop;

		imask = b#0001100001;       /* enable rx0 interrupt */
            /*    |||||||||+ | timer
                  ||||||||+- | SPORT1 rec or IRQ0
                  |||||||+-- | SPORT1 trx or IRQ1
                  ||||||+--- | BDMA
                  |||||+---- | IRQE
                  ||||+----- | SPORT0 rec
                  |||+------ | SPORT0 trx
                  ||+------- | IRQL0
                  |+-------- | IRQL1
                  +--------- | IRQ2
            */

/*   end codec initialization, begin filter demo initialization */

skip: imask = 0x200;

// wait states

si=0xFFFF;
dm(Dm_Wait_Reg)=si;

// PF ports

si=0x0000;
dm(Prog_Flag_Comp_Sel_Ctrl)=si; // PF0-7 inputs 

/* wait for char to go out */
wt:

		nop;
        jump wt;


/*------------------------------------------------------------------------------
 -
 -  SPORT0 interrupt handler
 -
 ------------------------------------------------------------------------------*/

input_samples:
        ena sec_reg;                /* use shadow register bank */

        sr1 = dm (rx_buf + 2); /* get new sample from SPORT0 (from codec) */

nofilt: /*sr=ashift sr1 by -1 (hi);*/   /* save the audience's ears from damage */
        mr1=sr1;
        
        si=IO(PORT_IN);
        IO(PORT_OUT)=si;
output:
        dm (tx_buf + 1) = mr1;      /* filtered output to SPORT (to spkr) */
        dm (tx_buf + 2) = mr1;      /* filtered output to SPORT (to spkr) */
        
        //
        
        // test PF
		// PF inputs 0-3
		ax0=dm(Prog_Flag_Data);
		ay0=0x000F;
		ar=ax0 and ay0;
		dm(PF_input)=ar;
		// PF outputs 4-7
		ar=dm(PF_output);
		sr=lshift ar by 4 (hi);
		ax0=sr1;
		dm(Prog_Flag_Data)=ax0;
        
        //
        
        rti;
/*------------------------------------------------------------------------------
 -
 -  transmit interrupt used for Codec initialization
 -
 ------------------------------------------------------------------------------*/
next_cmd:
        ena sec_reg;
        ax0 = dm (i3, m1);          /* fetch next control word and */
        dm (tx_buf) = ax0;          /* place in transmit slot 0    */
        ax0 = i3;
        ay0 = init_cmds;
        ar = ax0 - ay0;
        if gt rti;                  /* rti if more control words still waiting */
        ax0 = 0xaf00;               /* else set done flag and */
        dm (tx_buf) = ax0;          /* remove MCE if done initialization */
        ax0 = 0;
        dm (stat_flag) = ax0;       /* reset status flag */
        rti;



