# # List up all the tests
# pytest test --collect-only

export PATH="${PATH}:/dockerx/audio/third_party/kaldi/submodule/src/featbin/"
export PATH="${PATH}:/dockerx/audio/third_party/install/bin"

# Run all the test suites
pytest test \
    2>&1 | tee test.log
