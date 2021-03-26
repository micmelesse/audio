# set path to tests
export PATH="${PATH}:/dockerx/audio/third_party/kaldi/submodule/src/featbin/"
export PATH="${PATH}:/dockerx/audio/third_party/install/bin"

# # List up all the tests
# pytest test --collect-only

# Run all the test suites
pytest test \
    2>&1 | tee test.log

# # Run tests on sox_effects module
# pytest test/torchaudio_unittest/sox_effect
