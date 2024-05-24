/*{
  Acest exemplu ne prezinta detectia DTMF utilizand algoritmul Goertzel.
  
}
*/

#define   f_sample  8000
#define   N         200

#define   scale -8

.section/dm data1;

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

.section/pm pm_da;
// 2.14 coeficientii Goertzel : 2*cos(2*PI*k/N) pentru toate cele 8 frecvente
// 200, 360, 520, 680, 1240, 1400, 1560, 1720

.var/circ coefs[8]=0x7E6D,0x7AEB,0x7579,0x6E2D, 0x47F2, 0x3A1C, 0x2B5C, 0x1BEC;


//------------------------------------------------------------------------------
//-------------------- PROGRAMUL PRINCIPAL -------------------------------------
//------------------------------------------------------------------------------
.section/pm interrupts;

        jump begin;  rti; rti; rti;     // 00: reset 
       	jump processing;
		             rti; rti; rti;     // 04: IRQ2 
        rti;         rti; rti; rti;     // 08: IRQL1 
        rti;         rti; rti; rti;     // 0c: IRQL0 
      	rti;         rti; rti; rti;		// 10: SPORT) tx
        rti;		 rti; rti; rti;     // 14: SPORT0 rx 
        rti;         rti; rti; rti;     // 18: IRQE 
        rti;         rti; rti; rti;     // 1c: BDMA 
        rti;         rti; rti; rti;     // 20: SPORT1 tx or IRQ1 
        rti;         rti; rti; rti;     // 24: SPORT1 rx or IRQ0 
        rti;         rti; rti; rti;     // 28: timer 
        rti;         rti; rti; rti;     // 2c: power down 



.section/pm seg_code;
        
begin:	call setup;
        call restart;
	
		i0=Q1Q2_buff;
        i5=coefs;
		m5=2;
        modify(i5,m5);	// i5 pointer catre coeficientul asociat frecventei testate
        
        IMASK = 0x200;	// valideaza intreruperea IRQ2
        
stop : jump stop; 		// asteapta intreruperi

//--------- PROCESAREA UNUI ESANTION -------------------------------------------
//    
processing:                                                                          

si=dm(port_in);         // citeste esantionul curent 

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

		 
		 sr=ashift si by scale (hi);
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
				rts;
					

