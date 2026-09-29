#!/usr/bin/env bash

working_dir="$(pwd)"

protoc --swift_out="$working_dir/MyIntervalsIcu/Data/Models/Database" \
--proto_path="$working_dir/Protobuf/" \
"$working_dir/Protobuf/skylinechart.proto"
