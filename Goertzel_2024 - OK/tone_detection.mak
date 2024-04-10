# Generated by the VisualDSP++ IDDE

# Note:  Any changes made to this Makefile will be lost the next time the
# matching project file is loaded into the IDDE.  If you wish to preserve
# changes, rename this file and run it externally to the IDDE.

# The syntax of this Makefile is such that GNU Make v3.77 or higher is
# required.

# The current working directory should be the directory in which this
# Makefile resides.

# Supported targets:
#     tone_detection_Debug
#     tone_detection_Debug_clean

# Define this variable if you wish to run this Makefile on a host
# other than the host that created it and VisualDSP++ may be installed
# in a different directory.

ADI_DSP=C:\Program Files (x86)\Analog Devices\VisualDSP 3.5 16-Bit

ifndef ADI_DSP_MAKE
ADI_DSP_MAKE=C:/Program\ Files\ (x86)/Analog\ Devices/VisualDSP\ 3.5\ 16-Bit
endif

# $VDSP is a gmake-friendly version of ADI_DIR

empty:=
space:= $(empty) $(empty)
VDSP_INTERMEDIATE=$(subst \,/,$(ADI_DSP))
VDSP=$(subst $(space),\$(space),$(VDSP_INTERMEDIATE))

# Define the command to use to delete files (which is different on Win95/98
# and Windows NT/2000)

ifeq ($(OS),Windows_NT)
RM=cmd /C del /F /Q
else
RM=command /C del
endif

#
# Begin "tone_detection_Debug" configuration
#

ifeq ($(MAKECMDGOALS),tone_detection_Debug)

tone_detection_Debug : ./Debug/tone_detection.dxe 

./Debug/tone_detection.doj :./tone_detection.dsp 
	$(VDSP)/easm218x.exe .\tone_detection.dsp -proc ADSP-2181 -g -o .\Debug\tone_detection.doj -MM

./Debug/tone_detection.dxe :./ADSP-2181.ldf ./Debug/tone_detection.doj 
	$(VDSP)/cc218x.exe .\Debug\tone_detection.doj -T .\ADSP-2181.ldf -L .\Debug -flags-link -od,.\Debug -o .\Debug\tone_detection.dxe -proc ADSP-2181 -flags-link -MM

endif

ifeq ($(MAKECMDGOALS),tone_detection_Debug_clean)

tone_detection_Debug_clean:
	$(RM) ".\Debug\tone_detection.doj"
	$(RM) ".\Debug\tone_detection.dxe"
	$(RM) ".\Debug\*.ipa"
	$(RM) ".\Debug\*.opa"
	$(RM) ".\Debug\*.ti"

endif


