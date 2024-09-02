#!/bin/bash

declare -a successCases=(
[0]=tests/step1/valid.json
[1]=tests/step2/valid.json
[2]=tests/step2/valid2.json
[3]=tests/step3/valid.json
[4]=tests/step4/valid.json
[5]=tests/step4/valid2.json
)

declare -a failureCases=(
[0]=tests/step1/invalid.json
[1]=tests/step2/invalid.json
[2]=tests/step2/invalid2.json
[3]=tests/step3/invalid.json
[4]=tests/step4/invalid.json
)

for i in ${successCases[@]}
do
  echo "---------------- Executing $i --------------------"
  swift run json-parser $i
  exit_code=$?
  if [ "$exit_code" -eq 1 ]; then
    echo "Test case $i FAILED"
    exit 1
  fi
done

for i in ${failureCases[@]}
do
  echo "---------------- Executing $i --------------------"
  swift run json-parser $i
  exit_code=$?
  if [ "$exit_code" -eq 0 ]; then
    echo "Test case $i FAILED"
    exit 1
  fi
done

echo "All test cases PASSED"
