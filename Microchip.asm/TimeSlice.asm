#INCLUDE<P16F877A.INC>
__CONFIG 3F32H
;�ĸ�������ұ�����ʵ����һ������ĸ���ɫ���������ұߵ�K20һ�������������һ����K19���һ����K18���л�����ֹͣ�Ϳ�ʼ����K17��������
;���������������ֻ���ʾִ�г��������Ǹ�ʱ��Ƭ�ڳ���ִ������֮��TMR0��ʱ���ļ���ֵ��16���ơ�ע��TMR0�ļ����Ǵӳ�ֵ28��ʼ��

;............��ʼ��һЩֵ..............;
K_TMR0_200us    EQU  d'28'       ;��TMR0����ֵ��������������ĸ���ʵ������������18.432M�£����ֵ��28��TMR0��ʱ��Լ����200��s
F_CNT1ms        EQU  020H        ;������������1msʱ���
F_CNT10ms       EQU  021H        ;������������10msʱ���
F_CNT100ms      EQU  022H        ;������������100msʱ���
F_CNT1s         EQU  023H        ;������������1sʱ���
                                 
F_X200us        EQU  024H        ;�������ý����X��200usʱ���
F_X1ms          EQU  025H        ;�������ý����X��1msʱ���
F_X10ms         EQU  026H        ;�������ý����X��10msʱ���
F_X100ms        EQU  027H        ;�������ý����X��100msʱ���
F_LED           EQU  028H        ;����LED��ʾ

F_NUM_SEL       EQU  029H        ;���������λѡ
F_NUM0          EQU  02AH        ;�������ʾ��ֵ,0�����ұߵ��Ǹ�
F_NUM1          EQU  02BH        ;
F_NUM2          EQU  02CH        ;
F_NUM3          EQU  02DH        ;
F_KEY0          EQU  02EH        ;������λ�Ĵ水������,���а������
F_KEY1          EQU  02FH        ;
F_KEY2          EQU  030H        ;
F_KEY3          EQU  031H        ;
F_NUMCTRL       EQU  032H        ;��0λ���ڿ�������ֹͣ�Ϳ���
F_W             EQU  033H        ;�����ݴ�W
F_TMR0MAX       EQU  034H        ;����TMR0���ֵ�������鿴�ĸ�ʱ��Ƭ��ʱ��࣬���ֵ����ʾ������ܵ������λ��16����


;............��  ��  ��..............;
   ORG				0000H		           ;�������������ĵ�ַ
MAIN                             
   NOP                           ;����һ��ICD����Ŀղ���ָ��
   CALL     PORT_INIT            ;���ö˿ڳ�ʼ��
   BSF      STATUS,RP0           ;�����ļ��Ĵ���Ϊ��1
   MOVLW    01H			             ;����ѡ��Ĵ�����ֵ��00:2��Ƶ��01:4��Ƶ��
   MOVWF    OPTION_REG	         ;��00H��ֵ��ѡ��Ĵ��� �ڲ�ʱ��Դ��4��Ƶ����ʱ�ӷ����TMR0
   BCF      STATUS,RP0	         ;�ص���0
   CLRF     INTCON               ;���жϣ������
   CALL     REG_INIT             ;���ø��Ĵ�������ֵ
   
LOOP_MAIN                        
   BCF			    INTCON,2         ;TMR0������
   MOVLW		    K_TMR0_200us     ;TMR0��ֵ
   MOVWF		    TMR0	           ;��TMR0����������ʱ����
   
;.....��������1msʱ���.....;      
   DECFSZ       F_CNT1ms,F       ;�Լ�1��dΪ1�����F,���Ϊ������һ��
   GOTO         ELSE_1ms         ;
   MOVLW        d'5'             ;���Ϊ���򸳻س�ֵ5����ִ������ļ���
   MOVWF        F_CNT1ms         
;.....��������10msʱ���....;    
   DECFSZ       F_CNT10ms,F      
   GOTO         ELSE_1ms         
   MOVLW        d'10'            ;���Ϊ���򸳻س�ֵ10
   MOVWF        F_CNT10ms       
;.....��������100msʱ���...;    
   DECFSZ       F_CNT100ms,F     
   GOTO         ELSE_1ms         
   MOVLW        d'10'            ;���Ϊ���򸳻س�ֵ10
   MOVWF        F_CNT100ms         
;.....��������1sʱ���......;    
   DECFSZ       F_CNT1s,F        
   GOTO         ELSE_1ms         
   MOVLW        d'10'            ;���Ϊ���򸳻س�ֵ10
   MOVWF        F_CNT1s
ELSE_1ms
;.....ʱ����������.........;   

;.....ѡ��ĳ��ʱ��Ƭִ�г���.;
  ;......5��200usʱ��Ƭ......; 
   MOVLW        05H
   XORWF        F_CNT1ms,W        ;�Ƚ��Ƿ����
   BTFSS        STATUS,Z          ;�����Ⱦ�����   
   GOTO         END_IF200us_5
  ;��5��200usʱ��Ƭ��ִ����Щ����  
   MOVLW        d'10'                    
   MOVWF        F_X1ms	     
   MOVLW        d'10'                   
   MOVWF        F_X10ms	 
   MOVLW        d'5'                    
   MOVWF        F_X100ms      
   CALL         Enter_x100ms.x10ms.x1ms  ;����5.10.10���ʱ��Ƭ
   BTFSS        STATUS,Z          
   GOTO         END_5_10_10              ;���Ǿ���������
   CALL         LED_RUN                  ;��5.10.10���ʱ��Ƭ�͵�����Ҫִ�еĳ�������ƣ�1�����һ��  
   CALL         TMR0MAX_DISPLAY          ;��ʾ��ʱ�ʱ��Ƭ���������TRM0��ֵ
END_5_10_10   
   MOVLW        d'5'                    
   MOVWF        F_X1ms	     
   MOVLW        d'8'                   
   MOVWF        F_X10ms	 
   MOVF         F_CNT1s,W                            
   MOVWF        F_X100ms                 ;����������������ڵļ������൱�ں����������
   CALL         Enter_x100ms.x10ms.x1ms  
   BTFSS        STATUS,Z          
   GOTO         END_x_8_8              
   CALL         NUM_RUN                  ;��x.9.9���ʱ��Ƭ�͵�����Ҫִ�еĳ���  
END_x_8_8   
   
END_IF200us_5

;......4��200usʱ��Ƭ......; 
   MOVLW        04H
   XORWF        F_CNT1ms,W        ;�Ƚ��Ƿ����
   BTFSS        STATUS,Z          ;�����Ⱦ�����   
   GOTO         END_IF200us_4
  ;��4��200usʱ��Ƭ��ִ����Щ����
   MOVLW        09H
   XORWF        F_CNT10ms,W       ;�Ƚ��Ƿ����
   BTFSS        STATUS,Z          ;�����Ⱦ�����   
   GOTO         END_IF200us_4
  ;..����9��1msʱ��Ƭ
   CALL         KEY_DETECT        ;������⣬10msһ��
  
END_IF200us_4

 ;......3��200usʱ��Ƭ......; 
   MOVLW        03H
   XORWF        F_CNT1ms,W        ;�Ƚ��Ƿ����
   BTFSS        STATUS,Z          ;�����Ⱦ�����   
   GOTO         END_IF200us_3
  ;��3��200usʱ��Ƭ��ִ����Щ����
   BTFSS        F_CNT10ms,0       ;��ż����ȥˢ����ܣ�2msˢһ��
   CALL         DISPLAY_NUM                                                     

END_IF200us_3
     
         
;.....�������Բ���..........; 
   MOVLW        01H
   XORWF        F_CNT1ms,W       ;�Ƚ��Ƿ����
   BTFSS        STATUS,Z           ;�����Ⱦ�����
   GOTO         ELSE1             
   BCF          PORTB,RB5   
   GOTO         END_IF1
ELSE1
   BSF			PORTB,RB5   
END_IF1

;...�ҳ�ʱ��Ƭ���ռ����...;
   MOVF     TMR0,0
   SUBWF    F_TMR0MAX,W       ;MAX��ֵ��ȥTMR0
   BTFSC    STATUS,C          
   GOTO     FINDMAX_ELSE
   MOVF     TMR0,W            ;С�ھ�������
   MOVWF    F_TMR0MAX           
   BCF		  PORTB,RB4
   GOTO     FINDMAX_END
FINDMAX_ELSE
   MOVF     TMR0,W
   SUBWF    F_TMR0MAX,W       
   BTFSC    STATUS,C
   GOTO     FINDMAX_ELSE
   BCF		PORTB,RB4
FINDMAX_END   
   
   BCF			PORTB,RB4             ;�����0����RB4�˿����������

;���TMR0�Ƿ���������Ƴ�������LOOP_OF������LOOP_MAIN
LOOP_OF                      
   BTFSS    INTCON,2              ;������������GOTO LOOP_OF
   GOTO     LOOP_OF               
   BSF      PORTB,RB4             ;����������
   GOTO     LOOP_MAIN


;............���������..............;
;.......................................����һ����������ӳ���ķָ���................................;
   
;......����ܲ���ӳ���.........;
NUM_TABLE
   MOVWF     F_W
   SUBLW     d'16'               ;�ж��Ƿ����16�����ھͲ��ܲ�����ظ�-
   MOVF      F_W,W
   BTFSS     STATUS,C
   RETLW     03FH
   ADDWF     PCL,F
   RETLW     0C0H
   RETLW     0F9H
   RETLW     0A4H
   RETLW     0B0H
   RETLW     099H
   RETLW     092H
   RETLW     082H
   RETLW     0F8H
   RETLW     080H
   RETLW     090H
   RETLW     088H
   RETLW     083H
   RETLW     0C6H
   RETLW     0A1H
   RETLW     086H
   RETLW     08EH
   RETLW     0BFH
   
;....����x100ms.x10ms.x1msʱ��Ƭ�ӳ���..;
Enter_x100ms.x10ms.x1ms
   MOVF     F_X1ms,W             ;��F_X1ms����ֵ�͵�W;
   XORWF    F_CNT10ms,W          ;�Ƚ��Ƿ����,���ʱ���Ϊ0���͵���W  
   BTFSS    STATUS,Z             ;�����Ⱦ�������һ��
   GOTO     END_Enter_xxx        ;����Ⱦ�ֱ�ӽ�������ʱW�е�ֵ��Ϊ0
   MOVF     F_X10ms,W            ;��F_X10ms����ֵ�͵�W;               
   XORWF    F_CNT100ms,W         ;�Ƚ��Ƿ����,���ʱ���Ϊ0���͵���W  
   BTFSS    STATUS,Z             ;�����Ⱦ�������һ��
   GOTO     END_Enter_xxx        ;����Ⱦ�ֱ�ӽ�������ʱW�е�ֵ��Ϊ0
   MOVF     F_X100ms,W           ;��F_X100ms����ֵ�͵�W;               
   XORWF    F_CNT1s,W            ;�Ƚ��Ƿ����,���ʱ���Ϊ0���͵���W              
          
END_Enter_xxx                    ;������W����0����־λZ����1
   return
;....��F_TMR0MAX��ֵ�������....;
TMR0MAX_DISPLAY
  MOVF      F_TMR0MAX,W   
  ANDLW     b'00001111'
  MOVWF     F_NUM2
  MOVF      F_TMR0MAX,W
 ANDLW     b'11110000'
  MOVWF     F_NUM3
  SWAPF     F_NUM3     
  return
;.........������ӳ���..........;
LED_RUN
   BSF			PORTC,RC5            ;����LED������ʹ��
   MOVF     F_LED,W
   MOVWF    PORTD
   BCF			PORTC,RC5            ;�ر�LED������ʹ��
   ;ѭ������F_LED
   BCF      STATUS,C             ;��0��λ����0
   BTFSC    F_LED,7              ;���������0��1����0����
   BSF      STATUS,C             ;��1��λ����1
   RLF      F_LED,1              ;��λ��������Ч��    
   return
   
;...........����ӳ���...........;
NUM_RUN
  BTFSC  F_NUMCTRL,0             ;���Ƶ�0λ��0�Ͳ������
  CALL   NUM_ADD
  return 
  
;..........����...............;
NUM_ADD
   MOVLW     09H 
   XORWF     F_NUM0,W
   BTFSS     STATUS,Z               ;�����Ⱦ�������һ��
   GOTO      Add1_F_NUM0
   CLRF      F_NUM0                 ;�ӵ�9������
   MOVLW     09H
   XORWF     F_NUM1,W
   BTFSS     STATUS,Z             ;�����Ⱦ�������һ��
   GOTO      Add1_F_NUM1
   CLRF      F_NUM1
   GOTO      Add1_F_NUM1_END
  Add1_F_NUM1
     INCF      F_NUM1,F   
  Add1_F_NUM1_END   
   GOTO      Add1_F_NUM0_END  
Add1_F_NUM0
   INCF      F_NUM0,F
Add1_F_NUM0_END           
   return
;..........����...............;
NUM_SUB
   MOVLW    09H
   MOVF     F_NUM0,F
   BTFSS    STATUS,Z                 ;����0��ȥ����Ϊ9
   GOTO     SUB1_F_NUM0     
   MOVWF    F_NUM0                   ;��Ϊ9
   MOVF     F_NUM1,F
   BTFSS    STATUS,Z               ;����0��ȥ����Ϊ9
   GOTO     SUB1_F_NUM1     
   MOVWF    F_NUM1                 ;��Ϊ9
   GOTO     SUB1_NUM1_END
   SUB1_F_NUM1
   DECF     F_NUM1,F
   SUB1_NUM1_END  
   GOTO     SUB1_NUM0_END
SUB1_F_NUM0
   DECF     F_NUM0,F
SUB1_NUM0_END
    
   return
;......�������ʾ�ӳ���.........;
DISPLAY_NUM
   MOVF     F_NUM_SEL,W
   BSF      PORTC,RC4            ;����λѡ������ʹ��
   MOVWF    PORTD                ;���λѡ
   BCF			PORTC,RC4            ;�ر�λѡ������ʹ��
  ;....����λѡ�ӼĴ����ж�����Ӧλ��ֵ
   BTFSC    F_NUM_SEL,0          ;Ϊ0�����������ж�����λ
   GOTO     DISPLAY0
   BTFSC    F_NUM_SEL,1          ;Ϊ0�����������ж�����λ
   GOTO     DISPLAY1
   BTFSC    F_NUM_SEL,2          ;Ϊ0�����������ж�����λ
   GOTO     DISPLAY2
   BTFSC    F_NUM_SEL,3          ;Ϊ0�����������ж�����λ
   GOTO     DISPLAY3

DISPLAY0
   MOVF     F_NUM0,W
   GOTO     END_NUM_SELECT  
DISPLAY1
   MOVF     F_NUM1,W
   GOTO     END_NUM_SELECT
DISPLAY2
   MOVF     F_NUM2,W
   GOTO     END_NUM_SELECT    
DISPLAY3
   MOVF     F_NUM3,W
   GOTO     END_NUM_SELECT  
   
END_NUM_SELECT     
  ;......��W�����ֵ���ת������ʾ��
   CALL     NUM_TABLE            ;���ת��
   BSF      PORTC,RC3            ;������ѡ������ʹ��
   MOVWF    PORTD                ;�����ѡ
   BCF      PORTC,RC3            ;�رն�ѡ������ʹ��
   
   ;ѭ������F_NUM_SEL
   BCF      STATUS,C             ;��0��λ����0
   BTFSC    F_NUM_SEL,7          ;���������0��1����0����
   BSF      STATUS,C             ;��1��λ����1    
   RLF      F_NUM_SEL,F          ;��λѭ��ˢ�����
   return

;......��������ӳ���...........;
KEY_DETECT
  ;...��ⰴ��K17��RB0...;  
  BCF      STATUS,C             ;�Ȱѽ�λ����
  BTFSC    PORTB,W              
  BSF      STATUS,C             ;����������1�Ͱѽ�λ��Ϊ1
  RLF      F_KEY0               ;ÿ10����Ѱ���������λ�Ĵ浽����Ĵ�������
  MOVLW    b'11110000'          ;������м�⿪ʼ����
  XORWF    F_KEY0,W             
  BTFSS    STATUS,Z             ;�����Ⱦ�������һ��
  GOTO     END_KEY_DETECTK17_1
  CLRF     F_NUM0
  CLRF     F_NUM1
  CLRF     F_NUM2
  CLRF     F_NUM3
END_KEY_DETECTK17_1
  MOVLW    b'00000000'          ;������м��һֱ����
  XORWF    F_KEY0,W             
  BTFSS    STATUS,Z             ;�����Ⱦ�������һ��
  GOTO     END_KEY_DETECTK17_2
  CLRF     F_NUM0
  CLRF     F_NUM1
  CLRF     F_NUM2
  CLRF     F_NUM3
END_KEY_DETECTK17_2
  ;...��ⰴ��K18��RB1...;  
  BCF      STATUS,C             ;�Ȱѽ�λ����
  BTFSC    PORTB,F              
  BSF      STATUS,C             ;����������1�Ͱѽ�λ��Ϊ1
  RLF      F_KEY1               ;ÿ10����Ѱ���������λ�Ĵ浽����Ĵ�������
  MOVLW    b'11110000'          ;������м�⿪ʼ����
  XORWF    F_KEY1,W             
  BTFSS    STATUS,Z             ;�����Ⱦ�������һ��
  GOTO     END_KEY_DETECTK18_1
  COMF     F_NUMCTRL,1  
END_KEY_DETECTK18_1    
  ;...��ⰴ��K19��RB2...;  
  BCF      STATUS,C             ;�Ȱѽ�λ����
  BTFSC    PORTB,2              
  BSF      STATUS,C             ;����������1�Ͱѽ�λ��Ϊ1
  RLF      F_KEY2               ;ÿ10����Ѱ���������λ�Ĵ浽����Ĵ�������
  MOVLW    b'11110000'          ;������м�⿪ʼ����
  XORWF    F_KEY2,W             
  BTFSS    STATUS,Z             ;�����Ⱦ�������һ��
  GOTO     END_KEY_DETECTK19_1
  CALL     NUM_ADD 
END_KEY_DETECTK19_1    
 ;...��ⰴ��K20��RB3...;  
  BCF      STATUS,C             ;�Ȱѽ�λ����
  BTFSC    PORTB,3              
  BSF      STATUS,C             ;����������1�Ͱѽ�λ��Ϊ1
  RLF      F_KEY3               ;ÿ10����Ѱ���������λ�Ĵ浽����Ĵ�������
  MOVLW    b'11110000'          ;������м�⿪ʼ����
  XORWF    F_KEY3,W             
  BTFSS    STATUS,Z             ;�����Ⱦ�������һ��
  GOTO     END_KEY_DETECTK20_1
  CALL     NUM_SUB 
END_KEY_DETECTK20_1    
  return      
  
;.......�˿ڳ�ʼ���ӳ���........;
PORT_INIT
   CLRF 	STATUS                 ;ѡ��0;Bank0 
   CLRF 	PORTA                  ;��ն˿����
   CLRF 	PORTB                  ;
   CLRF 	PORTC                  ;
   CLRF 	PORTD                  ;
   BSF   	STATUS,RP0	           ;�����ļ��Ĵ���Ϊ��1
   MOVLW	b'00000000'            ;�����ö˿�Ϊ���뻹�������0�����
   MOVWF	TRISA
   MOVLW	b'00001111'
   MOVWF	TRISB
   MOVLW	b'00000000'
   MOVWF	TRISC
   MOVLW	b'00000000'
   MOVWF	TRISD
   return		         

;.......���Ĵ�������ֵ�ӳ���.........;
REG_INIT   
   MOVLW    b'11111110'            
   MOVWF    F_LED                ;��LED�Ĵ�������ֵ�����������  
   MOVLW    b'00010001'
   MOVWF    F_NUM_SEL
   MOVLW    d'0'
   MOVWF    F_NUM0              ;������ϵ�ʱ����ʾ��FF00��
   MOVLW    d'0'
   MOVWF    F_NUM1
   MOVLW    0FH
   MOVWF    F_NUM2
   MOVLW    0FH
   MOVWF    F_NUM3
   CLRF     F_TMR0MAX
  return

END   