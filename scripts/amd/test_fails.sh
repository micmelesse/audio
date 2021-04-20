# set path to tests
export PATH=${PATH}:$(pwd)/third_party/kaldi/submodule/src/featbin/:$(pwd)/third_party/install/bin
export KALDI_ROOT=$(pwd)

export TORCHAUDIO_TEST_WITH_ROCM=1

# FAILING UNIT TESTS
pytest -s test/torchaudio_unittest/backend/soundfile/save_test.py::TestFileObject::test_fileobj_flac

pytest test/torchaudio_unittest/functional/torchscript_consistency_cuda_test.py::TestFunctionalFloat32::test_griffinlim
pytest test/torchaudio_unittest/functional/torchscript_consistency_cuda_test.py::TestFunctionalFloat64::test_griffinlim

pytest test/torchaudio_unittest/transforms/torchscript_consistency_cuda_test.py::TestTransformsFloat32::test_GriffinLim
pytest test/torchaudio_unittest/transforms/torchscript_consistency_cuda_test.py::TestTransformsFloat64::test_GriffinLim

