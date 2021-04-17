# circleci setup

circleci config validate

sh scripts/amd/clean.sh
sh scripts/amd/regenerate.sh

circleci config process .circleci/config.yml >process.yml

# jobs
circleci local execute -c process.yml --job binary_rocm_linux_wheel_py3.6
# circleci local execute -c process.yml --job nightly_binary_rocm_linux_wheel_py3.6
# circleci local execute -c process.yml --job unittest_linux_gpu_rocm_py3.6

sh scripts/amd/clean.sh
