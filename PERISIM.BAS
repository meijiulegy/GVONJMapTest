REM     PROGRAM PERISIM


        ver$ = "6.00, 22-12-2021"

REM     latest update by Nomdo Jansonius on abovementioned date

REM     Ga uit van een venster met verhouding 4:3 (800x600 of 1024x768 geeft
REM     1.33 = 4:3; 1280x1024 geeft 1.25). Instructie voor gebruik is dat de 
REM     afstand van oog tot scherm gelijk moet zijn aan de vensterdiagonaal.
REM     Dan haal je langs de vensterdiagonaal 26.6 graden eccentriciteit, en
REM     daarmee horizontaal 21.3 en vertikaal 15.9 graden. Aangezien stimuli 
REM     niet helemaal tot aan de rand mogen, is het max. 18 resp. 12 graden.
REM     In full-screen mode (Alt-Enter) met 16:9 monitor wordt het 23.2/13.0 
REM     i.p.v. 21.3/15.9 graden, waarmee de stimuli horizontaal 9% verder en
REM     vertikaal 18% dichterbij liggen dan bedoeld.

REM     version history

REM     1.40  first public release (uncalibrated)
REM     2.00  first calibrated version; dynamic range reduced because lowest possible contrast
REM           with default QB45 gray values was higher than expected
REM     2.10  background luminance reduced from maximum luminance to 50% of maximum luminance
REM     2.20  dynamic range extended by moving to size II (Ricco's area) / duration 50 ms (within
REM           temporal summation and shortest duration reliably possible with 60 Hz frame rate)
REM           and adding size I and IV to extend the range with +0.6 and -0.6, respectively
REM     3.00  simplified version with only size III / duration 200 ms (closest to SAP) and thus
REM           with somewhat limited dynamic range; previous version renamed to PERISIMX
REM     3.14  four test locations added and grid optimized (version 'Chrismas pi')
REM     3.20  false-positive catch trials added
REM     4.00  non-default QB45 gray value added to extend the Weber contrast range to -0.10
REM     4.10  one more non-default gray value added to extend, foveally, the range to -0.05
REM     4.20  timer added to document beginning and end of test
REM     4.21  bug repair: no comma allowed in input string (otherwise remaining input truncated) 
REM     4.40  to speed up the test, contrast range extension to -0.10 limited to ecc < 10 deg
REM     5.00  calibration revised
REM     5.10  two test locations added
REM     5.20  eccentricity specific binary picto plot: for being normal, logCS must be at least
REM           0.8 in fovea, at least 0.4 for 0.5 to 10 deg, and at least 0.0 outside 10 deg
REM     6.00  output summarized in single graphical report instead of three text windows

        ntl% = 25                       REM number of test locations

        DIM tlx%(1 to ntl%)             REM x-cordinates of the test locations
        DIM tly%(1 to ntl%)             REM y-cordinates of the test locations
        DIM lcs!(1 to ntl%)             REM Weber logCS of the test locations

REM     define non-default gray values for Weber contrast -0.10 and -0.05 with PALETTE
REM     note: this must, apparently, be repeated at each occurrence in the code
        rood% = 43
        groen% = 43
        blauw% = 43 
        grijs2& = 65536*blauw% + 256*groen% + rood%
        rood% = 44
        groen% = 44
        blauw% = 44 
        grijs1& = 65536*blauw% + 256*groen% + rood%

REM     select appropriate window size
100     SCREEN 0
        COLOR 15,3
        CLS
        PRINT ""
        COLOR 0,3
        PRINT "  PERISIM - almost standard automated perimetry on a monitor" 
        PRINT ""
        PRINT ""
        COLOR 15,3
        PRINT "  choose window size: (1) = small, (2) = medium, (3) = large"
        PRINT ""
        PRINT "  choose the largest window that fits entirely on the screen"
        PRINT ""
        PRINT ""
        COLOR 0,3
        PRINT "  choose h for the specifications and calibration, q to quit"
        PRINT ""
        DO
          keuze$ = INKEY$
        LOOP WHILE keuze$ = ""
        IF keuze$ = "1" THEN
          screenkeuze% = 19
          xres% = 800
          yres% = 600
          COLOR 7,0
          CLS
          PRINT ""
          PRINT "  to interrupt the test at any point in time, return to this"
          PRINT "  window and press Ctrl-C"
          GOTO 120
        ELSEIF keuze$ = "2" THEN 
          screenkeuze% = 20
          xres% = 1024
          yres% = 768
          COLOR 7,0
          CLS
          PRINT ""
          PRINT "  to interrupt the test at any point in time, return to this"
          PRINT "  window and press Ctrl-C"
          GOTO 120
        ELSEIF keuze$ = "3" THEN 
          screenkeuze% = 21
          xres% = 1280
          yres% = 1024
          COLOR 7,0
          CLS
          PRINT ""
          PRINT "  to interrupt the test at any point in time, return to this"
          PRINT "  window and press Ctrl-C"
          GOTO 120
        ELSEIF keuze$ = "h" THEN 
          GOTO 110
        ELSEIF keuze$ = "q" THEN
          GOTO 890
        ELSE
          GOTO 100
        ENDIF

REM     specs and calibration
110     SCREEN 19
        COLOR 1,31
        CLS                             REM needed to get a uniform background color
        PRINT ""
        PRINT "  PERISIM is *NOT* a medical device; it is an open source programme for lecturing perimetry"
        PRINT ""
        PRINT ""
        PRINT "  specifications"
        PRINT ""
        PRINT "    psychophysical method           :  3-3 dB staircase"
        PRINT "    stimulus size / duration / type :  Goldmann size III / 200 ms / decrement"
        PRINT "    dynamic range                   :  Weber contrast -1.0 to -0.05 => logCS 0.0 to 1.3"
        PRINT ""
        PRINT ""
        PRINT "  calibration"
        PRINT ""
        PRINT "    the relative luminance in the squares below has to be 1 - 0.95 - 0.90 - 0.80 - 0.50 - 0"
        PRINT ""
        PRINT "    (if not, the programme can still be used as long as the luminance changes monotonically"
        PRINT "    but the reported Weber logCS values are less accurate)"
        PRINT ""
	PRINT ""
        PRINT "  press b to go back to previous screen"
REM     kader
        LINE (100,375)-(700,375),1 
        LINE (100,525)-(700,525),1
        LINE (100,375)-(100,525),1
        LINE (700,375)-(700,525),1
REM     binnengrenzen
        LINE (200,375)-(200,525),1
        LINE (300,375)-(300,525),1
        LINE (400,375)-(400,525),1
        LINE (500,375)-(500,525),1
        LINE (600,375)-(600,525),1
REM     inkleuring
        PAINT (150,450),28,1
REM     non-default gray value (arbitrarily called 14, defined above)
        PALETTE 14, grijs1&
        PAINT (250,450),14,1
REM     non-default gray value (arbitrarily called 15, defined above)
        PALETTE 15, grijs2&
        PAINT (350,450),15,1
        PAINT (450,450),27,1
        PAINT (550,450),25,1
        PAINT (650,450),16,1
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT ""        
        PRINT ""
        PRINT "  version ",ver$,"            author: Nomdo Jansonius (c) 2020-2066"
115     DO
          keuze$ = INKEY$
        LOOP WHILE keuze$ = ""
        IF keuze$ = "b" THEN
          SCREEN 0
          GOTO 100
        ELSE
          GOTO 115
        ENDIF        

120     SCREEN screenkeuze%
        COLOR 1,28
        CLS                             REM CLS needed here to get a uniform background color
        PRINT ""
        PRINT ""        
        PRINT "    press b to go back to previous screen for selecting another window size"
        PRINT ""
        LINE (10,yres%-10)-(xres%-10,10),1
        CIRCLE (7,yres%-7),5,1
        CIRCLE (xres%-7,7),5,1
        PAINT (7,yres%-7),1,1
        PAINT (xres%-7,7),1,1
        PRINT ""
        PRINT "    make testing distance equal to diagonal size of selected window"
        PRINT ""
        PRINT ""
        PRINT "    cover one eye"
        PRINT ""
        PRINT "    look at the middle of the circle on the next screen"
        PRINT ""
        PRINT "    each time a stimulus is seen, press spacebar"
        PRINT ""
        PRINT "    the test takes between 3 and 5 minutes"
        PRINT ""
        PRINT ""
        PRINT ""
        PRINT "    ready? press spacebar to start"
130     DO
          keuze$ = INKEY$
        LOOP WHILE keuze$ = ""
        IF keuze$ = "b" THEN
          SCREEN 0
          GOTO 100
        ENDIF
        
        CLS
REM     draw a circle with radius 1 deg as fixation target 
        xecc! = 0
        yecc! = 0
        GOSUB 940
        CIRCLE (xpos%,ypos%),xres%/42.6,1
	SLEEP(3)

REM     test locations (based on "jansonius-map"; made symmetrical L/R eye)
        tlx%(1) =   0
        tly%(1) =   0
        tlx%(2) =  10
        tly%(2) =  12
        tlx%(3) = -10 
        tly%(3) = -12
        tlx%(4) =  10
        tly%(4) = -12
        tlx%(5) = -10
        tly%(5) =  12
        tlx%(6) =   2 
        tly%(6) =   2
        tlx%(7) =  -2
        tly%(7) =  -2
        tlx%(8) =   2
        tly%(8) =  -2
        tlx%(9) =  -2
        tly%(9) =   2
        tlx%(10) =  18
        tly%(10) =   4
        tlx%(11) = -18
        tly%(11) =  -8
        tlx%(12) =  18
        tly%(12) =  -8
        tlx%(13) = -18
        tly%(13) =   4
        tlx%(14) =   6 
        tly%(14) =   2
        tlx%(15) =  -6
        tly%(15) =  -2
        tlx%(16) =   6
        tly%(16) =  -2
        tlx%(17) =  -6
        tly%(17) =   2
        tlx%(18) =  15                  REM blind spot OD (if changed: update mean sensitivity calculation)
        tly%(18) =  -2
        tlx%(19) = -15                  REM blind spot OS (if changed: update mean sensitivity calculation)
        tly%(19) =  -2
        tlx%(20) =   2
        tly%(20) =   8
        tlx%(21) =  -2
        tly%(21) =  -8
        tlx%(22) =   2
        tly%(22) =  -8
        tlx%(23) =  -2
        tly%(23) =   8
        tlx%(24) =  12
        tly%(24) =   4
        tlx%(25) = -12
        tly%(25) =   4

REM     perimetrie in engere zin
        t0$ = TIME$
        fpcount% = 0                    REM number of FP responses counted during test
        FOR i% = 1 TO ntl%              REM i% denotes the test location
        xecc! = tlx%(i%)
        yecc! = tly%(i%)
        GOSUB 940
REM     staircase procedure upstairs    REM start with stimulus 3 or 4 depending on eccentricity
        IF (xecc!*xecc!+yecc!*yecc!) < 100 THEN
          GOTO 150
        ELSE
          GOTO 155
        ENDIF
150     stim% = 3
        GOSUB 930                       REM present stimulus
        GOSUB 920                       REM wait for response
        IF antwoord$ <> "" THEN
          GOTO 210                      REM stim 3 seen
        ENDIF
155     stim% = 4
        GOSUB 930
        GOSUB 920
        IF antwoord$ <> "" THEN
          GOTO 205                      REM stim 4 seen
        ENDIF
        stim% = 5                       
        GOSUB 930
        GOSUB 920
        IF antwoord$ <> "" THEN
          GOTO 200                      REM stim 5 seen
        ELSE
          lcs!(i%) = -0.2               REM stim 5 not seen (assumed final sensitivity = stim 5 - 0.2) 
          GOTO 290
        ENDIF
REM     staircase procedure downstairs
200     stim% = 4
        GOSUB 930
        GOSUB 920
        IF antwoord$ = "" THEN
          lcs!(i%) = 0.1                REM stim 5 seen, stim 4 not seen (assumed final sensitivity stim 5 + 0.1 = stim 4 - 0.2)  
          GOTO 290
        ENDIF
205     stim% = 3
        GOSUB 930
        GOSUB 920
        IF antwoord$ = "" THEN
          lcs!(i%) = 0.4                REM stim 4 seen, stim 3 not seen (assumed final sensitivity stim 4 + 0.1 = stim 3 - 0.2)  
          GOTO 290
        ELSE   
          lcs!(i%) = 0.8
          IF (xecc!*xecc!+yecc!*yecc!) > 100 THEN         
            GOTO 290
          ELSE
            GOTO 210                    REM only within 10 deg eccentricity a weaker stimulus is tested 
          ENDIF
        ENDIF
210     stim% = 2
        GOSUB 930
        GOSUB 920
        IF antwoord$ = "" THEN
          lcs!(i%) = 0.8                REM stim 3 seen, stim 2 not seen (assumed final sensitivity stim 3 + 0.1 = stim 2 - 0.2)  
          GOTO 290
        ELSE
          lcs!(i%) = 1.1                REM stim 2 seen (assumed final sensitivity = stim 2 + 0.1)  
          IF (xecc!*xecc!+yecc!*yecc!) > 0.25 THEN         
            GOTO 290
          ELSE
            GOTO 215                    REM only in fovea an even weaker stimulus is tested 
          ENDIF
        ENDIF
215     stim% = 1
        GOSUB 930
        GOSUB 920
        IF antwoord$ = "" THEN
          lcs!(i%) = 1.1                REM stim 2 seen, stim 1 not seen (assumed final sensitivity stim 2 + 0.1 = stim 1 - 0.2)  
          GOTO 290
        ELSE
          lcs!(i%) = 1.4                REM stim 1 seen (assumed final sensitivity = stim 1 + 0.1)  
          GOTO 290
        ENDIF

REM     probing false positive responses
290     IF i% = 3 OR i% = 8 OR i% = 14 THEN
          stim% = 0
          GOSUB 930
          GOSUB 920
          IF antwoord$ <> "" THEN fpcount% = fpcount%+1         
        ENDIF
REM     some rest before going to the next test location
        SLEEP(0.0)                      REM no rest was best
        NEXT i%                         REM einde van perimetrie in engere zin
        SLEEP(1.0)                      REM before closing perimetry window/screen

        t1$ = TIME$

REM     collecting some information for graphical report and output datafile
500     SCREEN 0
        COLOR 0,3
        CLS
        PRINT ""
        PRINT "  which eye was tested: OD (r) or OS (l)?"
        DO
          keuze$ = INKEY$
        LOOP WHILE keuze$ = ""
        IF keuze$ = "r" THEN
          oog$ = "OD"
        ELSEIF keuze$ = "l" THEN
          oog$ = "OS"
        ELSE
          GOTO 500
        ENDIF
        PRINT ""
        PRINT "  tested eye:",oog$
        PRINT ""
        PRINT "  comment to include in output (single line; no , allowed):"
        PRINT ""
        INPUT commentaar$
        
REM     nicer FP response presentation
        IF fpcount% = 0 THEN fpcount$ = "0/3"
        IF fpcount% = 1 THEN fpcount$ = "1/3"
        IF fpcount% = 2 THEN fpcount$ = "2/3"
        IF fpcount% = 3 THEN fpcount$ = "3/3"
        
REM     calculation of mean sensitivity
        sms! = 0
        FOR i% = 1 TO ntl%        
          sms! = sms! + lcs!(i%)
        NEXT i%
REM     removal of blind spot value from mean sensitivity calculation   
        IF oog$ = "OD" THEN sms! = sms!-lcs!(18) ELSE sms! = sms!-lcs!(19)
REM     rounding to maximum 2 decimals after decimal point
        ms! = 0.01*CINT(100*sms!/(ntl%-1))
REM     final value put in string for aligned presentation        
        ms$ = LTRIM$(STR$(ms!))                    
        
REM     make a graphical report
600     SCREEN 19
        COLOR 1,31
        CLS                             REM needed to get a uniform background color
REM     kader rond het gezichtsveld
        LINE (20,2)-(627,2),1 
        LINE (20,395)-(627,395),1
        LINE (20,2)-(20,395),1
        LINE (627,2)-(627,395),1
        FOR i% = 1 TO ntl%
        xecc! = tlx%(i%)
        yecc! = tly%(i%)
        ecc2! = xecc!*xecc!+yecc!*yecc!
        x% = CINT(tlx%(i%)*1.88+39)     REM 40/21.3 = 1.88 
        y% = tly%(i%)*-1.0+13
        IF y% = 1 THEN
          y% = 2
        ELSEIF y% = 25 THEN
          y% = 24
        ENDIF
        LOCATE y%,x%,0
        IF lcs!(i%) = -0.2 THEN
          COLOR 0,31
          PRINT " < 0"
        ELSE
          COLOR 3,31
          PRINT lcs!(i%)
        ENDIF
        NEXT i%
        COLOR 1,31
        LOCATE 2,91
        PRINT "PERISIM"
        LOCATE 3,82
        PRINT ver$
        LOCATE 20,93
        PRINT oog$
        LOCATE 27,5
        PRINT "date of test            ",DATE$
        LOCATE 28,5
        PRINT "beginning of test       ",t0$
        LOCATE 29,5
        PRINT "end of test             ",t1$
        LOCATE 30,5
        PRINT "false-positive responses",fpcount$
        LOCATE 31,5
        PRINT "mean sensitivity        ",ms$
        LOCATE 33,5
        COLOR 3,31
        PRINT commentaar$
        COLOR 1,31
        LOCATE 35,5
        PRINT "the programme does not save this graphical report; you may use"
        LOCATE 36,5
        PRINT "Alt-PrintScrn; numerical data are stored automatically on exit"
        LOCATE 35,90
        PRINT "back (b)"
        LOCATE 36,90
        PRINT "exit (e)"
610     DO
          keuze$ = INKEY$
        LOOP WHILE keuze$ = ""
        IF keuze$ = "b" THEN
          GOTO 500
        ELSEIF keuze$ = "e" THEN
          GOTO 640
        ELSE
          GOTO 610
        ENDIF

REM     export results to datafile
640     OPEN "perisim.dat" FOR APPEND AS #12
        PRINT #12, "PERISIM ",ver$
        PRINT #12, ""
        PRINT #12, "tested eye       ",oog$
        PRINT #12, "date of test     ",DATE$
        PRINT #12, "beginning of test",t0$
        PRINT #12, "end of test      ",t1$
        PRINT #12, "false-positive responses",fpcount$
        PRINT #12, "mean sensitivity ",ms$
        PRINT #12, ""
        PRINT #12, commentaar$
        PRINT #12, ""
        PRINT #12, "             x (deg)       y (deg)     Weber logCS"
        PRINT #12, ""
        FOR i% = 1 TO ntl%
        PRINT #12, " ", tlx%(i%), tly%(i%), lcs!(i%)
        NEXT i%
        PRINT #12, ""
        PRINT #12, "---------------------------------------------------"
        PRINT #12, ""
        CLOSE #12

890     SCREEN 0
        COLOR 7,0
        CLS
899     PRINT ""
        PRINT "  Thank you for using PERISIM!"
        PRINT ""

        END


920     DO                              REM keyboard buffer leegmaken
        LOOP WHILE INKEY$ <> "" 
        SLEEP(1.5)                      REM wait until any key has been pressed but continue anyway after 1.5 seconds
        antwoord$ = INKEY$
        RETURN

REM     project stimulus with size size! relative to Goldmann size III (0.43 deg diameter) and duration delay!
REM
REM     -----------------------------------------------------------------------------------------
REM      QB45 color (gray values 16-31)    RGB value (0-63)     Weber contrast (%)         logCS
REM
REM                28                           45                 background*
REM                27                           40                     20                   0.7
REM                25                           32                     50                   0.3
REM                16                            0                    100                   0.0
REM
REM              grijs2                         43                     10                   1.0
REM              grijs1                         44                      5                   1.3
REM    
REM      * = luminance of gray value 28 is ~50% of max. luminance (white; gray value 31) 
REM     -----------------------------------------------------------------------------------------

930     IF stim% = 1 THEN
REM     non-default gray value (arbitrarily called 14, defined above)
        PALETTE 14, grijs1&
          kleur% = 14                   REM Weber contrast ~ 0.05
          delay! = 0.2                  REM duration 200 ms
          size! = 1.0                   REM Goldmann size III
        ENDIF
        IF stim% = 2 THEN
REM     non-default gray value (arbitrarily called 15, defined above)
        PALETTE 15, grijs2&
          kleur% = 15                   REM Weber contrast ~ 0.10
          delay! = 0.2                  REM duration 200 ms
          size! = 1.0                   REM Goldmann size III
        ENDIF
        IF stim% = 3 THEN
          kleur% = 27                   REM Weber contrast ~ 0.20
          delay! = 0.2
          size! = 1.0
        ENDIF
        IF stim% = 4 THEN
          kleur% = 25                   REM Weber contrast ~ 0.50
          delay! = 0.2
          size! = 1.0
        ENDIF  
        IF stim% = 5 THEN
          kleur% = 16                   REM Weber contrast ~ 1.00
          delay! = 0.2
          size! = 1.0
        ENDIF
        IF stim% = 0 THEN
          kleur% = 28                   REM contrast = 0 for testing false-positive responses 
          delay! = 0.2
          size! = 1.0
        ENDIF  

        SLEEP(1.5)                      REM 1.5 s delay between previous stimulus/respons and next
        COLOR kleur%
        CIRCLE (xpos%,ypos%),size!*0.5*0.43*xres%/42.6
        PAINT (xpos%,ypos%),kleur%,kleur%
REM     wait delay! seconds 
        nu# = TIMER
        WHILE TIMER < nu#+delay!
        WEND 
        PAINT (xpos%,ypos%),28,28
        RETURN

REM     convert x and y eccentricity into position in window
940     xpos% = (xecc!+21.3)*xres%/42.6 REM xecc! is hor eccentricity in deg
        ypos% = (15.9-yecc!)*yres%/31.8 REM yecc! is ver eccentricity in deg
        RETURN

