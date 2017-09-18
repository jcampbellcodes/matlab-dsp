MATLAB DSP Projects
===================

This is a small repository for DSP testbeds in MATLAB. It includes several simple examples of offline convolution in the time domain (FIR) and frequency domain (DFT multiplication), as well as a very simple comb filter implementation.

The main project here is the real-time convolution reverb that served as my testbed when cross-referencing several partitioned convolution reverb techniques used in real-time reverbs (a mix of Gardner's and Farina's approaches). I considered the project a proof of concept and have now moved on to exploring a practical implementation in a real-time game audio engine via audio plugins or low-level audio APIs.

If you are interested in running the projects, just edit the source to point to your chosen IR and input signal (both WAV files) and run it in MATLAB or Octave! 

----------