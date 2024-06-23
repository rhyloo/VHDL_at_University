![GitHub](https://img.shields.io/github/license/izanamador/SEA)


# Electronic Systems for Automation
This repository contains the work done for the subject Electronic Systems for Automation by Izan Amador and Jorge Benavides. The before mentioned subject belongs to fourth course in the bachelor\'s of Electronics, Robotics and Mechatronics Engineering from the University of Malaga.

The main objective of the subject is to learn the principles of VHDL coding, as well as, formal verification with test benches and RTL.

https://github.com/izanamador/SEA/assets/33180470/4b169f20-c342-408d-8115-dfe5aa10e6c0

# List of projects

## Exercises

### exercise0_synchronizer

### exercise1_adder

### exercise2_shiftregister

### exercise3_multiplexer

### exercise4_upcounter

These exercises involve selecting two combinational circuits and two sequential circuits from the proposed options and briefly explaining how the models work in a preliminary study. A Vivado project should be generated for each chosen model, and a Test Bench with file handling should be generated for the simulation phase to illustrate the correct functioning of the models. The models should be synthesized at the RTL level to verify that they are indeed combinational or sequential. A
report should be prepared that illustrates the design, simulation, and synthesis process, including screenshots of simulation timelines and RTL schematics. The VHDL codes used and the generated .CSV files, as well as the original stimulus file, should be included in the PDF.

### exercise5_rommux

The exercise involves simulating and synthesizing the proposed ROM and MUX from the previous slides. The ROM should have a maximum of 4 addresses, or equivalently, the MUX should have two selection lines. The data bus for both the ROM and MUX should be no more than 1 byte. You will need to generate a single Vivado project for both modules and create a single Test Bench with file handling for the simulation phase to illustrate the correct operation of both systems and their equivalence as combinational systems. This means that for the same input, both systems should produce the same output (there are 2 DUTs in the TB: the ROM and the MUX). Synthesize them at the RTL level (RTL Analysis) to verify that they are indeed combinational (do not have memory elements) and correspond to what they represent.

### exercise6_fsm

The exercise involves designing, simulating, and synthesizing a Mealy or Moore Finite State Machine (FSM) of your choice with between 3 and 8 states and only 2 processes: one sequential and one combinational. The FSM should have a maximum of 2 inputs and 3 outputs. You will need to create a report that illustrates the design, simulation, and synthesis process, including screenshots (simulation waveforms, RTL schematic), etc. The report should also include the VHDL codes used, a screenshot of the generated .CSV file, and the original stimulus file as a function of delay.

### exercise7_timeverificator

The exercise involves checking the setup and rise times of the signal as well as other fundamental properties of it.

## Assignments

### assignment1_resolutionfunction

The assignment involves conducting a detailed study on how the supplied code works and generating a project in Vivado to run the simulation. The assignment also includes answering questions about the meaning of certain lines in the code and the types of circuits that can use resolved logic with multiple drivers. A report should be prepared that illustrates the design and simulation process, including answers to the questions. Screenshots of simulation timelines can be used.

### assignment2_universalshiftregister

The assignment involves coding and verifying the functionality of a generic 𝑛-bit universal register and FSM scheme in VHDL. The register has a 3-bit control bus that allows changing its functionality according to the table provided. As a special requirement, the ieee numeric_std package cannot be used.

### assignment3_genericplc

The assignment involves describing the supplied PLC code, which cannot be modified once the FSM style (Moore or Mealy) has been selected. The system will have fixed parameters of k_Max = 3 inputs, p_Max = 4 outputs, and m_Max = 4 flip-flops. A single Vivado project must be generated to implement the PLC. A Test Bench must be designed with file handling to illustrate the correct operation of the system with fixed parameters for all k=k_Max, p=p_Max, and m=m_Max. Bounces must be generated in the Trigger signal as if it were an external Pull-Up switch from a process. The only VHDL code to be included in the report will be the designed Test Bench, commented and correctly indented. The PLC must be synthesized at RTL level (RTL Analysis) for k=k_Max, p=p_Max, and m=m_Max to verify that it corresponds to what it represents.

# Folder structure

Every project has the following structure. It includes the full vivado project and the separated files with the source codes of the test bench and the designed component, for easier readability and usage.

### .vhd

Contains the code of the component.

### .tb

Contains the code of the test bench.

### vivado_roject

Contains the full vivado project.
