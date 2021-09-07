# Battery Management System (BMS) - Simulations

This repository contains all the simulations related to the BMS project 
[BMS project](https://github.com/moyamartin/bms_unr). Keep in mind that these
simulation were written in Matlab version R2018a

# Features

Inside this repository there are several simulation for the BMS, where each of
them has its own explanation:

* Battery model parameters estimation.
* SOC estimation algorithm based on a Kalman filter coupled with a battery
  model.
* Charge and discharge simulation.
* Passive battery equalization algorithm

Afterwards, these simulations were combined in a single BMS model implemented in
Simulink. Furthermore, we managed to implement these algorithms/models in our
[hardware](https://github.com/moyamartin/bms_hardware) and
[firmware](https://github.com/moyamartin/bms_firmware) design.
