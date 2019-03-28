#include<stdio.h>
#include<stdlib.h>
#include<wiringPi.h>

int pin = 18;

int main(int argc, char *argv[]) {
	if (wiringPiSetupGpio() < 0) {
		fprintf(stderr, "Error: Failed to setup gpio.\n");
		return 1;
	}

	pinMode(pin, PWM_OUTPUT);
	pwmSetMode(PWM_MODE_MS);
	pwmSetRange(3);
	pwmSetClock(168);

	int state = 0;
	pwmWrite(pin, state);
	for(int i = 1; i < argc; i++){
		pwmWrite(pin, state = !state);
		delayMicroseconds(atoi(argv[i]));
	}

	pwmWrite(pin, 0);
	return 0;
}
