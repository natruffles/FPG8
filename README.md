# FPG8
Verilog implementation of a computer architecture project (single-bus control unit) on an iCEstick FPGA

## Initial Writeup
In our [computer architecture class](https://eecs.ceas.uc.edu/~wilseypa/classes/eece3026/), we were tasked with a [project](https://eecs.ceas.uc.edu/~wilseypa/classes/eece3026/project/project3.pdf) which involved developing a gate-level design of a single-bus control unit that implements 16 different instructions. The control unit in the project was required to have a 16-bit word size and a 16-bit single data bus with byte addressable memory. However, our FPGA, an [iCEstick Evaluation Kit](https://www.latticesemi.com/icestick), only has 12 I/O ports so we will need to input/output data over the process of multiple clock cycles.

My [project writeup](https://docs.google.com/presentation/d/1Ky87abrqP6Sl-3wUcDA0iaXHDzWbXQxgTyut-tx8uL8/edit?usp=sharing) will be a good starting resource in transferring my gate-level design to an FPGA, as well as my Logisim implementation, which I will upload to this repo shortly. 

I also plan to use [Shawn Hymel's FPGA tutorial](https://www.digikey.com/en/maker/projects/introduction-to-fpga-part-1-what-is-an-fpga/3ee5f6c8fa594161a655a9f960060893) as well as [Phil Does Tech's CPU on an FPGA series](https://www.youtube.com/watch?v=sa1id9DIick) for insipiration. 
