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

#define   f_sample  8000
#define   N         200


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

.var/circ Q1Q2_buff[2];    			// ultimele 2 valori ale lui Q
	
.var	port_in;					// portul de intrare

.var in_sample;               		// esantionul de intrare curent 

.var      countN;                  	//numara esantioanele 1, 2, 3, ..., N  

// "tone-present" mnsqr level 
.var      min_tone_level=0x0100;

// amplitudinea (in  1.15)  mnsqr Goertzel
.var mnsqr;      

// frecventa existenta (1) sau nu (0)    
.var freq_OK;

.var index_set;
.var SW7_6;
.var SW5_4;
.var SW3_0;
.var PF7_6;
.var PF5_4;
.var PF3_0;
.var OK;
.var index_freq1;
.var ok_afisor;
.var freq2_OK;
.var dtmf_freq_cnt;

.section/pm pm_da;
// 2.14 coeficientii Goertzel : 2*cos(2*PI*k/N) pentru toate cele 8 frecvente
// 200, 360, 520, 680, 1240, 1400, 1560, 1720

.var/circ coefs0[8]=0x7E6D, 0x7AEB, 0x7579, 0x6E2D, 0x47F2, 0x3A1C, 0x2B5C, 0x1BEC;
.var/circ coefs1[8]=0x7CEB, 0x786F, 0x720D, 0x69DE, 0x4E74, 0x4128, 0x32D6, 0x23B6;
.var/circ coefs2[8]=0x7E6D, 0x7AEB, 0x7579, 0x6E2D, 0x4E74, 0x4128, 0x32D6, 0x23B6;
.var/circ coefs3[8]=0x7CEB, 0x786F, 0x720D, 0x69DE, 0x47F2, 0x3A1C, 0x2B5C, 0x1BEC;


/*** Interrupt Vector Table ***/
.SECTION/PM     interrupts;
		jump start; rti; rti; rti;     /*00: reset */
        
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
        ax0=0;
        dm(OK)=ax0; dm(index_freq1)=ax0;
		
        ax0=1; dm(ok_afisor)=ax0; dm(dtmf_freq_cnt)=ax0;
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
        // aici dau pe streams rx_buf+2 manual

nofilt: /*sr=ashift sr1 by -1 (hi);*/   /* save the audience's ears from damage */
        mr1=sr1;
        
        
        si=IO(PORT_IN); 
        sr=lshift si by -6 (hi);
        ax0=sr1; // ax0=SW7-6
        dm(SW7_6)=ax0;

        ax1=si;
        ay1=0x0030; 
        ar=ax1 and ay1;
        sr=lshift ar by -4 (hi);
        ay0=sr1; // ay0=SW5-4
        dm(SW5_4)=ay0;
        
        ay1=0x000F;
        ar=ax1 and ay1;
        ax1=ar; // ax1=SW3-0
        dm(SW3_0)=ax1;
        
        // iau fiecare set de biti si ii stochez undeva ***FACUT***
        //IO(PORT_OUT)=si; aici '= si' e de test
output:
        
		// PF inputs 0-7
		si=dm(Prog_Flag_Data);
		dm(PF_input)=si;
		
		sr=lshift si by -6 (hi);
		mx0=sr1; // PF7-6
		dm(PF7_6)=mx0;
		
		ay1=0x0030;
		sr0=si;
		ar=sr0 and ay1;
		sr=lshift ar by -4 (hi);
		my0=sr1; // PF5-4
		dm(PF5_4)=my0;
		
		ay1=0x000F;
		sr0=si;
		ar=sr0 and ay1;
		mx1=ar; // PF3-0
		dm(PF3_0)=mx1;
		        
        //mod de lucru: mai intai test_ext sa vedem ca merge, apoi integrat goertzel, 
        //cu cazurile stop, frecv, apoi dtmf
        //scale il fac variabil
        
        // AICI TREBUIE GOERTZEL
        
        l5=8; //alegere set de frecvente
        ar=dm(SW5_4);
        ar=ar-0;
        if eq jump set_0;
        ar=ar-1;
        if eq jump set_1;
        ar=ar-1;
        if eq jump set_2;
        ar=ar-1;
        if eq jump set_3; // final alegere set frecvente

set_0:	i5=coefs0;
		jump verif_id;
set_1:	i5=coefs1;
		jump verif_id;
set_2:	i5=coefs2;
		jump verif_id;
set_3:	i5=coefs3;
		jump verif_id;
                
verif_id:
		ax0=dm(SW7_6);
        ay0=dm(PF7_6);
        ar=ax0-ay0;
        if eq jump id_ok;
        if ne rti;
        
id_ok:	
		ax0=dm(PF5_4);
		ay0=1;
		ar=ax0-ay0;
		if eq jump caz_freq;
		ay0=2;
		ar=ax0-ay0;
		if eq jump caz_dtmf;
		ay0=3;
		ar=ax0-ay0;
		if eq jump caz_stop;
		rti;
		
caz_freq:
		ax0=dm(PF3_0);
		dm(index_freq1)=ax0;
		ar=dm(OK);
        ar=ar-2;
        if eq jump final_freq;
		jump goertzel;
		
caz_dtmf:
		ax0=dm(dtmf_freq_cnt);
		ar=ax0-2;
		if eq jump caz_dtmf_2;
		si=dm(PF3_0);
		sr=ashift si by -2 (hi);
		dm(index_freq1)=sr1;
		ar=dm(OK);
        ar=ar-2;
        if eq jump final_dtmf;
		jump goertzel;
caz_dtmf_2:
		sr0=dm(PF3_0);
		ay1=0x0003;
		ar=sr0 and ay1;
		ar=ar+4;
		dm(index_freq1)=ar;
		ar=dm(OK);
        ar=ar-2;
        if eq jump final_dtmf_2;
		jump goertzel;
		
caz_stop:		
		ax0=0x00;
        IO(PORT_OUT)=ax0;
		rti;
                
final_freq:
		ax0=dm(freq_OK);
		ar=ax0-1;
		if ne call drawErr;
		if eq call drawLetter;
		ax0=0;
		dm(OK)=ax0;
		rti;

drawLetter:
		ax0=dm(PF3_0);
		ar=ax0-0;
		if eq call draw0;
		ar=ax0-1;
		if eq call draw1;
		ax0=ar;
		ar=ax0-1;
		if eq call draw2;
		ax0=ar;
		ar=ax0-1;
		if eq call draw3;
		ax0=ar;
		ar=ax0-1;
		if eq call draw4;
		ax0=ar;
		ar=ax0-1;
		if eq call draw5;
		ax0=ar;
		ar=ax0-1;
		if eq call draw6;
		ax0=ar;
		ar=ax0-1;
		if eq call draw7;
		rts;
		
afisor_modif:
		dm(ok_afisor)=ax0;	
		rts;	
		
final_dtmf:
		ar=dm(freq_OK);
		dm(freq2_OK)=ar;
		ar=2;
		dm(dtmf_freq_cnt)=ar;
		ax0=0;
		dm(OK)=ax0;
		rti;
		
final_dtmf_2:
		ax0=dm(freq_OK);
		ay0=dm(freq2_OK);
		ar=ax0 and ay0;
		ar=ar-0;
		if eq call drawErr_dtmf;
		if ne call drawLetter_dtmf;
		ax0=0;
		dm(OK)=ax0;
		ax0=1;
		dm(dtmf_freq_cnt)=ax0;
		rti;

drawLetter_dtmf:
		ax0=dm(PF3_0);
		ar=ax0-0;
		if eq call draw0;
		ar=ax0-1;
		if eq call draw1;
		ax0=ar;
		ar=ax0-1;
		if eq call draw2;
		ax0=ar;
		ar=ax0-1;
		if eq call draw3;
		ax0=ar;
		ar=ax0-1;
		if eq call draw4;
		ax0=ar;
		ar=ax0-1;
		if eq call draw5;
		ax0=ar;
		ar=ax0-1;
		if eq call draw6;
		ax0=ar;
		ar=ax0-1;
		if eq call draw7;
		ax0=ar;
		ar=ax0-1;
		if eq call draw8;
		ax0=ar;
		ar=ax0-1;
		if eq call draw9;
		ax0=ar;
		ar=ax0-1;
		if eq call drawA;
		ax0=ar;
		ar=ax0-1;
		if eq call drawB;
		ax0=ar;
		ar=ax0-1;
		if eq call drawC;
		ax0=ar;
		ar=ax0-1;
		if eq call drawD;
		ax0=ar;
		ar=ax0-1;
		if eq call drawE;
		ax0=ar;
		ar=ax0-1;
		if eq call drawF;
		call drawPoint;
		rts;
				
goertzel:
		ar=dm(OK);
        ar=ar-0;
        if eq jump begin; // intra sa calculeze esantionul goertzel
        if gt jump processing;
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


        
        
        
///////////////////CODUL GOERTZEL/////////////////////////////

                




//------------------------------------------------------------------------------
//-------------------- PROGRAMUL PRINCIPAL -------------------------------------
//------------------------------------------------------------------------------

        
begin:	call setup;
        call restart;
	
		i0=Q1Q2_buff;
		m5=dm(index_freq1);
        modify(i5,m5);	// i5 pointer catre coeficientul asociat frecventei testate
        dm(index_set)=i5;
        ax0=1;
        dm(OK)=ax0;
        //IMASK = 0x200;	// valideaza intreruperea IRQ2, deja validata
        
//stop : jump stop; 		// asteapta intreruperi, deja e in intrerupere

//--------- PROCESAREA UNUI ESANTION -------------------------------------------
//    
processing:                                                                          
i5=dm(index_set);
si=mr1;         // citeste esantionul curent 

// det_freq function

// input: 
// si - esantionul de intrare 
// scale - factorul de scalare
// countN - numarul de esantioane 
// min_tone_level - apmlitudinea minima a frecventei detectate
// i0 - pointer la bufferul Q (ultimele 2 valori ale lui Q)
// l0 = 2
// m0 = 1, m1 = -1
// i5 - pointer la coeficientul asociuat frecventei testate
// l5 = 8
// m4 = 0

// output
// freq_OK =	1 - frecventa a fost detectata
//				0 - frecventa nu a fost detectata
call det_freq;

rti;
 
//---------------------------------------------------------------------------------

det_freq:

		 ax1=dm(SW3_0);
loopScale:
		 ar=ax1-1;
		 ax1=ar;		 
		 sr=ashift si by -1 (hi);
		 si=sr1;
		 if gt jump loopScale;
         dm(in_sample)=sr1;      // stocarea esantionului de intrare , scalat
         
//---------- DECREMENTAREA CONTORULUI DE ESANTIOANE ----------------------------
//                                                                              
decN:    
		 ay0=dm(countN);
         ar=ay0-1;
         dm(countN)=ar;
         if lt jump skip_backs;

//----------- F A Z A   F E E D B A C K ---------------------------------------
//                                                                             
feedback: 
			ay1=dm(in_sample);              // extrage esantionul la intrare AY1=1.15
            mx0=dm(i0,m0), my0=pm(i5,m4);   //extrage Q1 si COEF Q1=1.15, COEF=2.14
            mr=mx0*my0(rnd), ay0=dm(i0,m1); //inmulteste, get Q2   MR=2.30,  Q2=1.15
            sr=ashift mr1 by 1 (hi);        //schimba 2.30 in 1.15             
            ar=sr1-ay0;                     //Q1*COEF - Q2             AR=1.15
            ar=ar+ay1;                      //Q1*COEF - Q2 + intrarea     AR=1.15
            dm(i0,m0)=ar;                   //rezultatul = noul Q1                
    	    dm(i0,m0)=mx0;                  //vechiul Q1 = noul Q2             
          	jump end;;

//---------- F A Z A   F E E D B A C K   E S T E  G A T A  -------------
//                                                                              
skip_backs:
          call feedforward;
          call test_and_output;
          call restart;

end:	  
		  rts;
		  
// functii de initializare si reinitializare 
                                                               
setup:  

        l0 =  2;
               
        l5 =  8;
      
        m0 =  1;
        m1 = -1;
        m4 =  0;

        rts;
                                                                 
restart:     i0=Q1Q2_buff;
             cntr=2;
             do zloop until ce;
zloop:           dm(i0,m0)=0;
             ax0=N;    
             dm(countN)=ax0;
             //ax0=0;
             //dm(freq_OK)=ax0;
             rts;

//%%%%%%%%%%% F A Z A   F E E D F O R W A R D %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//                                                                              
feedforward: 
               mx0=dm(i0,m0);            // extrage doua copii Q1         1.15 
               my0=mx0;
               mx1=dm(i0,m0);            // extrage doua copii Q2         1.15 
               my1=mx1;
               ar=pm(i5,m4);             // extrage COEF                  2.14 
               mr=0;
               mf=mx0*my1(rnd);          //  Q1*Q2                       1.15 
               mr=mr-ar*mf(rnd);         // -Q1*Q2*COEF                  2.14 
               sr=ashift mr1 by 1 (hi);  // 2.14 -> 1.15 format conv.    1.15 
               mr=0;
               mr1=sr1;
               mr=mr+mx0*my0(ss);        // Q1*Q1 + -Q1*Q2*COEF          1.15 
               mr=mr+mx1*my1(rnd);       // Q1*Q1 + Q2*Q2 + -Q1*Q2*COEF  1.15 
	           dm(mnsqr)=mr1;            // socheaza in mnsqr  1.15 
             rts;

//%%%%%% Testarea nivelului  %%%%%%%%%%%%%%%%%%%%%%%%%%%
//                                                                       
test_and_output: 

				ar=dm(mnsqr);
				ay0=dm(min_tone_level);
				ar=ar-ay0;
				if lt jump no_freq;
				si=1;
				jump rez;
		no_freq:
				si=0;
		rez:
				dm(freq_OK)=si;
				ax0=2;
				dm(OK)=ax0;
				rts;
				
				
draw0: 	ax0=0x3F;
		IO(PORT_OUT)=ax0;
		rts;
draw1:	ax0=0x06;
		IO(PORT_OUT)=ax0;
		rts;
draw2:	ax0=0x5B;
		IO(PORT_OUT)=ax0;
		rts;
draw3:	ax0=0x4F;
		IO(PORT_OUT)=ax0;
		rts;
draw4:	ax0=0x66;
		IO(PORT_OUT)=ax0;
		rts;
draw5:	ax0=0x6D;
		IO(PORT_OUT)=ax0;
		rts;
draw6:	ax0=0x7D;
		IO(PORT_OUT)=ax0;
		rts;
draw7:	ax0=0x07;
		IO(PORT_OUT)=ax0;
		rts;
draw8:	ax0=0x7F;
		IO(PORT_OUT)=ax0;
		rts;
draw9:	ax0=0x6F;
		IO(PORT_OUT)=ax0;
		rts;
drawA:	ax0=0x77;
		IO(PORT_OUT)=ax0;
		rts;
drawB:	ax0=0x7C;
		IO(PORT_OUT)=ax0;
		rts;
drawC:	ax0=0x39;
		IO(PORT_OUT)=ax0;
		rts;
drawD:	ax0=0x5E;
		IO(PORT_OUT)=ax0;
		rts;
drawE:	ax0=0x79;
		IO(PORT_OUT)=ax0;
		rts;
drawF:	ax0=0x71;
		IO(PORT_OUT)=ax0;
		rts;
drawPoint:
		ax0=IO(PORT_OUT);
		ay0=0x80;
		ar=ax0 or ay0;
		IO(PORT_OUT)=ar;
		rts;
drawErr:
		ax0=0x40;
		IO(PORT_OUT)=ax0;
		rts;
drawErr_dtmf:
		ax0=0xC0;
		IO(PORT_OUT)=ax0;
		rts;
