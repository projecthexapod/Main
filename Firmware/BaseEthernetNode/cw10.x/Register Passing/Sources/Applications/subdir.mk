################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../../makefile.local

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS_QUOTED += \
"C:/Users/jwhong/Documents/Project-Hexapod/Firmware/BaseEthernetNode/Sources/APPLICATIONS/main.c" \

C_SRCS += \
C:/Users/jwhong/Documents/Project-Hexapod/Firmware/BaseEthernetNode/Sources/APPLICATIONS/main.c \

OBJS += \
./Sources/Applications/main_c.obj \

OBJS_QUOTED += \
"./Sources/Applications/main_c.obj" \

C_DEPS += \
./Sources/Applications/main_c.d \

OBJS_OS_FORMAT += \
./Sources/Applications/main_c.obj \

C_DEPS_QUOTED += \
"./Sources/Applications/main_c.d" \


# Each subdirectory must supply rules for building sources it contributes
Sources/Applications/main_c.obj: C:/Users/jwhong/Documents/Project-Hexapod/Firmware/BaseEthernetNode/Sources/APPLICATIONS/main.c
	@echo 'Building file: $<'
	@echo 'Executing target #84 $<'
	@echo 'Invoking: ColdFire Compiler'
	"$(CF_ToolsDirEnv)/mwccmcf" @@"Sources/Applications/main.args" -o "Sources/Applications/main_c.obj" "$<" -MD -gccdep
	@echo 'Finished building: $<'
	@echo ' '

Sources/Applications/main_c.d: C:/Users/jwhong/Documents/Project-Hexapod/Firmware/BaseEthernetNode/Sources/APPLICATIONS/main.c
	@echo 'Regenerating dependency file: $@'
	
	@echo ' '


