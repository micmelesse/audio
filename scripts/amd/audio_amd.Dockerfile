# FROM rocm/pytorch-private:rocm4.0.1_ubuntu18.04_py3.6_pytorch_master
FROM rocm/pytorch-private:rocm4.0.1_ubuntu18.04_py3.6_pytorch_audio_for_rocm

RUN pip3 install ninja