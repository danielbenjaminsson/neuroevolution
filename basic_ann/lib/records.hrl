records.hrl
-record(sensor, {id, cx_id, name, vl, fanout_ids}).
-record(actuator,{id, cx_id, name, vl, fanin_ids}).
-record(neuron, {id, cx_id, af, input_idps, output_ids}).
-record(cortex, {id, sensor_ids, actuator_ids, nids}).