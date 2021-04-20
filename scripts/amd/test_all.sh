# set path to tests
export PATH=${PATH}:$(pwd)/third_party/kaldi/submodule/src/featbin/:$(pwd)/third_party/install/bin
export KALDI_ROOT=$(pwd)

export TORCHAUDIO_TEST_WITH_ROCM=1


# # List up all the tests
# pytest test --collect-only

# Run all the test suites
pytest test \
    2>&1 | tee test.log

# # Run tests on sox_effects module
# pytest test/torchaudio_unittest/sox_effect
