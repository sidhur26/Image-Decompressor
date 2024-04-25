## COE3DQ5 project

### Project Overview

This project involved the design and implementation of an Image Decompressor using digital signal processing algorithms in a hardware setting. The main challenge was to develop a system that operates efficiently under a 50 MHz clock constraint, with specific attention to latency and hardware resource optimization.

Read [this](doc/3dq5-2023-project-description.pdf) detailed project document.

### Objective

To build a robust and efficient image decompressor capable of handling complex processing tasks within stringent hardware constraints.

### Features and Technicalities

**Hardware Design:** Implemented digital signal processing algorithms on hardware, ensuring compatibility and performance within a 50 MHz clock environment.

**Efficient Resource Management:** Designed the system to make optimal use of hardware resources (4 multipliers), avoiding wastage while fulfilling functional requirements.

**Latency Considerations:** Developed the system to adhere to specific latency constraints, balancing between processing speed and resource efficiency (75% multilier efficiency minimum).

### Development Process

**Base Code Utilization:** Started from a foundational code base, enhancing and adapting it to meet the specific needs of the image decompressor project.

**Software Modeling and Simulation:** Employed a software model for the image decoder to guide the development process, ensuring accuracy and efficiency.

**Enhanced Verification:** Developed and utilized additional testbenches for thorough testing and validation of the system.

### Technical Details

**Languages and Technologies:** The project predominantly used Verilog for hardware description, Quartus Prime for hardware synthesis, and ModelSim for simulation.

**Key Functionalities:** The system featured efficient decoding of image data, translating it into displayable formats while maintaining image fidelity.

### Project Outcome

The final design met all specified requirements, demonstrating efficient decoding capabilities and maintaining performance under the set clock constraint. The project showcased my ability to apply hardware engineering principles to practical problems, deepening my understanding of digital signal processing in a hardware context.

### Repository Contents

rtl/: Contains the base Verilog code for the project.

sw/: Includes the software model for the image decoder.

tb/: Testbenches for system verification and testing.

doc/: Documentation and detailed report on the project.
